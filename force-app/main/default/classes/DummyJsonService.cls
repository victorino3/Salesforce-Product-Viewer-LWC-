public with sharing class DummyJsonService {
    private static final String ERROR_SOURCE = 'DummyJSON Sync';
    
    @AuraEnabled(cacheable=true)
    public static List<Product__c> getProductsFromSF() {
        return [
            SELECT Id, Name, Category__c, Brand__c, Price__c, Stock__c, 
                   Thumbnail_URL__c, Description__c, API_Id__c
            FROM Product__c 
            ORDER BY Name 
            LIMIT 1000
        ];
    }
    
    @AuraEnabled
    public static void syncProductsWithAPI() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:DummyJSON_API/products?limit=100');
        req.setMethod('GET');
        
        HttpResponse res = new Http().send(req);
        
        if (res.getStatusCode() != 200) {
            throw new CalloutException('API Error: ' + res.getStatusCode() + ' ' + res.getStatus());
        }
        
        processApiResponse(JSON.deserializeUntyped(res.getBody()));
    }
    
    public static void processApiResponse(Object response) {
        try {
            Map<String, Object> responseMap = (Map<String, Object>)response;
            List<Object> products = (List<Object>)responseMap.get('products');
            
            if (products == null || products.isEmpty()) return;
            
            List<Error_Log__c> errorLogs = new List<Error_Log__c>();
            Set<String> apiIds = extractApiIds(products);
            
            handleProductDeletion(apiIds, errorLogs);
            handleProductUpsert(prepareProductsForUpsert(products), errorLogs);
            
            if (!errorLogs.isEmpty()) {
                insert errorLogs;
            }
        } catch (Exception e) {
            System.debug('Exception trying to process'+e);
        }
    }

    public static List<Product__c> prepareProductsForUpsert(List<Object> products) {
        List<Product__c> upsertProducts = new List<Product__c>();
        for (Object productObj : products) {
            Map<String, Object> productMap = (Map<String, Object>)productObj;
            upsertProducts.add(createProductFromMap(productMap));
        }
        return upsertProducts;
    }

    public static Set<String> extractApiIds(List<Object> products) {
        Set<String> apiIds = new Set<String>();
        for (Object productObj : products) {
            Map<String, Object> productMap = (Map<String, Object>)productObj;
            apiIds.add(String.valueOf(productMap.get('id')));
        }
        return apiIds;
    }

    public static void handleProductDeletion(Set<String> apiIds, List<Error_Log__c> errorLogs) {
        if (!Schema.sObjectType.Product__c.isDeletable()) {
            throw new DmlException('Insufficient delete permissions');
        }
        
        List<Product__c> productsToDelete = [
            SELECT Id 
            FROM Product__c 
            WHERE API_Id__c NOT IN :apiIds
        ];
        
        for (Database.DeleteResult dr : Database.delete(productsToDelete, false)) {
            if (!dr.isSuccess()) {
                errorLogs.add(createErrorLog(
                    'Delete failed: ' + dr.getErrors()[0].getMessage(),
                    'High'
                ));
            }
        }
    }

    public static void handleProductUpsert(List<Product__c> upsertProducts, List<Error_Log__c> errorLogs) {
        if (!Schema.sObjectType.Product__c.isCreateable() || !Schema.sObjectType.Product__c.isUpdateable()) {
            throw new DmlException('Insufficient upsert permissions');
        }
        
        for (Database.UpsertResult ur : Database.upsert(upsertProducts, Product__c.API_Id__c, false)) {
            if (!ur.isSuccess()) {
                errorLogs.add(createErrorLog(
                    'Upsert failed: ' + ur.getErrors()[0].getMessage(),
                    'High'
                ));
            }
        }
    }

    public static Product__c createProductFromMap(Map<String, Object> productMap) {
        return new Product__c(
            Name = (String)productMap.get('title'),
            Category__c = (String)productMap.get('category'),
            Brand__c = (String)productMap.get('brand'),
            Price__c = (Decimal)productMap.get('price'),
            Stock__c = (Integer)productMap.get('stock'),
            Thumbnail_URL__c = (String)productMap.get('thumbnail'),
            Description__c = (String)productMap.get('description'),
            API_Id__c = String.valueOf(productMap.get('id'))
        );
    }
    
    public static Error_Log__c createErrorLog(String message, String severity) {
        return new Error_Log__c(
            Error_Message__c = message,
            Source__c = ERROR_SOURCE,
            Severity__c = severity
        );
    }
    
}
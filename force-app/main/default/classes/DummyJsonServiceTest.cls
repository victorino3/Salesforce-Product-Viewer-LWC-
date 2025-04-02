@isTest
private class DummyJsonServiceTest {
    @testSetup
    static void setupTestData() {
        List<Product__c> products = new List<Product__c>{
            new Product__c(Name = 'Product 1', Category__c = 'Electronics', Brand__c = 'Brand A',
                Price__c = 100, Stock__c = 10, Thumbnail_URL__c = 'http://image.com/1',
                Description__c = 'Sample Product', API_Id__c = '1'),
            new Product__c(Name = 'Product 2', Category__c = 'Home', Brand__c = 'Brand B',
                Price__c = 50, Stock__c = 5, Thumbnail_URL__c = 'http://image.com/2',
                Description__c = 'Another Product', API_Id__c = '2')
        };
        insert products;
    }

    @isTest
    static void testGetProductsFromSF() {
        Test.startTest();
        List<Product__c> products = DummyJsonService.getProductsFromSF();
        Test.stopTest();
        System.assert(products.size() > 0, 'Products should be returned');
    }

    @isTest
    static void testSyncProductsWithAPI() {
        Test.setMock(HttpCalloutMock.class, new DummyJsonServiceMock());
        Test.startTest();
        DummyJsonService.syncProductsWithAPI();
        Test.stopTest();
        System.assertEquals([SELECT COUNT() FROM Product__c], 2, 'Products should be inserted/updated');
    }

    @isTest
    static void testProcessApiResponse() {
        String jsonResponse = '{"products":[{"id": "3", "title": "New Product", "category": "Books", "brand": "Brand C", "price": 20, "stock": 15, "thumbnail": "http://image.com/3", "description": "New Book"}] }';
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        Test.startTest();
        DummyJsonService.processApiResponse(responseMap);
        Test.stopTest();
        System.assertEquals([SELECT COUNT() FROM Product__c WHERE API_Id__c = '3'], 1, 'New product should be inserted');
    }

    @isTest
    static void testCreateErrorLog() {
        Test.startTest();
        Error_Log__c errorLog = DummyJsonService.createErrorLog('Test Error', 'High');
        Test.stopTest();
        System.assertEquals('Test Error', errorLog.Error_Message__c, 'Error message should match');
        System.assertEquals('High', errorLog.Severity__c, 'Severity should match');
    }
    
        @isTest
    static void testProcessApiResponseNoPrivilege() {
        String jsonResponse = '{"products":[{"id": "3", "title": "New Product", "category": "Books", "brand": "Brand C", "price": 20, "stock": 15, "thumbnail": "http://image.com/3", "description": "New Book"}]}';
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        String uniqueUsername = 'testuser_' + System.currentTimeMillis() + '@example.com'; // Unique username using timestamp
        Profile limitedProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'testuser', 
            Email = 'testuser@example.com', 
            LastName = 'Test',
            Username = uniqueUsername, 
            ProfileId = limitedProfile.Id, 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        System.runAs(testUser) {
            Test.startTest();
            DummyJsonService.processApiResponse(responseMap);
            Test.stopTest();
            System.assertEquals([SELECT COUNT() FROM Product__c WHERE API_Id__c = '3'], 0, 'No product should be inserted');
        }
    }
    
    @isTest
    static void testCreateErrorLogNoPrivilege() {
        // Create a test user with a unique username
        String uniqueUsername = 'testuser_' + System.currentTimeMillis() + '@example.com'; // Unique username using timestamp
        Profile limitedProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'testuser', 
            Email = 'testuser@example.com',
            LastName = 'Gomes1',
            Username = uniqueUsername, 
            ProfileId = limitedProfile.Id, 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        System.runAs(testUser) {
            Test.startTest();
            Error_Log__c errorLog = DummyJsonService.createErrorLog('Test Error', 'High');
            Test.stopTest();
            System.assertEquals('Test Error', errorLog.Error_Message__c, 'Error message should match');
            System.assertEquals('High', errorLog.Severity__c, 'Severity should match');
        }
    }


    private class DummyJsonServiceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"products": [{"id": "1", "title": "Product 1", "category": "Electronics", "brand": "Brand A", "price": 100, "stock": 10, "thumbnail": "http://image.com/1", "description": "Sample Product"},{"id": "2", "title": "Product 2", "category": "Home", "brand": "Brand B", "price": 50, "stock": 5, "thumbnail": "http://image.com/2", "description": "Another Product"}]}');
            return res;
        }
    }
}
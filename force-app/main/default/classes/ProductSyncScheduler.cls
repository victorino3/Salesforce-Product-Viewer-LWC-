public with sharing class ProductSyncScheduler implements Schedulable {
    public void execute(SchedulableContext ctx) {
        try {
            DummyJsonService.syncProductsWithAPI();

            System.debug('Successfully synced products at: ' + System.now());
            
        } catch (Exception e) {
            Error_Log__c log = new Error_Log__c(
                Error_Message__c = e.getMessage(),
                Stack_Trace__c = e.getStackTraceString(),
                Source__c = 'ProductSyncScheduler',
                Severity__c = 'High'
            );
            if (Schema.sObjectType.Error_Log__c.isCreateable()) {
                insert log;
            } else {
                System.debug('Insufficient permissions to create Error_Log__c records.');
            }
 }
    }
}
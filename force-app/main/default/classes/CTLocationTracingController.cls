public with sharing class CTLocationTracingController {
    public static List<Location_Tracing__c> getVisitor(String locationId){
        return [SELECT Name, IsDeleted, Id, Visit_Date__c,Location__c,Person__r.Health_Status__c,Person__r.Token__c
                FROM Location_Tracing__c WHERE Id =: locationId
                WITH SECURITY_ENFORCED
                ORDER BY Visit_Date__c DESC
               ];   
    }
    public static List<Location_Tracing__c> getLocationsByPersonIds(Set<Id> personIds){
        return [SELECT Id,Location__c, Person__c
        FROM Location_Tracing__c WHERE Person__c IN: personIds AND Visit_Date__c  = LAST_N_Days:10 WITH SECURITY_ENFORCED];
    }
    public static List<Location_Tracing__c> getLocationByLocationIds(Set<Id> locationId){
        String state='Green';
        return [SELECT Id,Person__c,Location__c
                FROM Location_Tracing__c 
                WHERE Person__r.Health_Status__c =: state AND Location__c  IN :locationId
                WITH SECURITY_ENFORCED];
    }

    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> locationTraces){
       Set<Id> locationIds = new Set<Id>();
       Set<Id> personIds = new Set<Id>();
       for (Location_Tracing__c index : locationTraces) {
            locationIds.add(index.Location__c);
            personIds.add(index.Person__c);
       }
       List<Location_Tracing__c> existingRecords = [SELECT Id, Name,Person__c,Location__c
                                                    FROM Location_Tracing__c
                                                    WHERE Person__c IN :personIds AND Location__c IN:locationIds
                                                    WITH SECURITY_ENFORCED
                                                    ];
       Map<Id,Set<Id>> mapOfExistingRecords = new Map<Id,Set<Id>>();
       List <Location_Tracing__c> duplicate = new List<Location_Tracing__c>();
       if(existingRecords != null && existingRecords.size() > 0){
        
        for (Location_Tracing__c index : existingRecords) {
            if(!mapOfExistingRecords.containsKey(index.Location__c)) {
                //add indice into Map (Key)
                mapOfExistingRecords.put(index.Location__c, new Set<Id>());
            }
            //add person in Set (Value)
            mapOfExistingRecords.get(index.Location__c).add(index.Person__c);
        }
        
        for (Location_Tracing__c value : locationTraces) {
            if (mapOfExistingRecords.containsKey(value.Location__c) &&
                mapOfExistingRecords.get(value.Location__c).contains(value.Person__c)) {
                duplicate.add(value);
            }
        }
       }
       return duplicate;

    }
}
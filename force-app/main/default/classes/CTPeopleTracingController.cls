public with sharing class CTPeopleTracingController {

    public static List<People_Tracing__c> getTraces(String recordId){
        List<People_Tracing__c> peopleTrace = [SELECT IsDeleted, Name, Contact_Date__c, Contact_Type__c, Person_1__c, Person_2__c, Id 
                                                FROM People_Tracing__c 
                                                WHERE Id =: recordId
                                                WITH SECURITY_ENFORCED
                                                ORDER BY Contact_Date__c  NULLS LAST];
        return peopleTrace;
    } 
    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> peopleTraces){
        Set<Id> person1 = new Set<Id>();
        Set<Id> person2 = new Set<Id>();
        for (People_Tracing__c index : peopleTraces) {
             person1.add(index.Person_1__c);
             person2.add(index.Person_2__c);
        }
        List<People_Tracing__c> existingRecords = [SELECT Id, Person_1__c, Person_2__c 
                                                    FROM People_Tracing__c 
                                                    WHERE Person_1__c IN :person1 
                                                    AND Person_2__c IN :person2
                                                    WITH SECURITY_ENFORCED
                                                    ORDER BY Contact_Date__c  NULLS LAST
                                                    ];

        List <People_Tracing__c> duplicate = new List<People_Tracing__c>();
        Map <Id,Set<Id>> mapsOfIdAnValue = new Map<Id,Set<Id>>();
        if (existingRecords == null && existingRecords.size() < 0) {
            return null;
        }else {
            for (People_Tracing__c firIndex : existingRecords) {
                if (!MapsOfIdAnValue.containsKey(firIndex.Person_1__c)) {
                    MapsOfIdAnValue.put(firIndex.Person_1__c, new Set<Id>());
                }
                MapsOfIdAnValue.get(firIndex.Person_1__c).add(firIndex.Person_2__c);
                
                if (!MapsOfIdAnValue.containsKey(firIndex.Person_2__c)) {
                    MapsOfIdAnValue.put(firIndex.Person_1__c, new Set<Id>());
                }
                MapsOfIdAnValue.get(firIndex.Person_2__c).add(firIndex.Person_1__c);
            }
            
        }
        for (People_Tracing__c value : peopleTraces) {
            if ( (MapsOfIdAnValue.containsKey(value.Person_1__c) && MapsOfIdAnValue.get(value.Person_1__c).contains(value.Person_2__c)) 
                || (MapsOfIdAnValue.containsKey(value.Person_2__c) && MapsOfIdAnValue.get(value.Person_2__c).contains(value.Person_1__c) )) {
                duplicate.add(value);
            }
        }
        
        
        return duplicate;
 
     }
}
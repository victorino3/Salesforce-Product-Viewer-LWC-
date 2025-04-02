public with sharing class CTPersonController {

    public static String getToken(String phone){
        if (String.isEmpty(phone) || phone == null) {
            return null;
        }else {
            Blob targetBlob = Blob.valueOf(Phone);
            Blob hash = Crypto.generateDigest('MD5', targetBlob);
            return EncodingUtil.base64Encode(hash);
        }    
    }
    public List<Person__c> getRecentHealthChanges(){
        List<Person__c> person = [SELECT Id,Health_Status__c,Mobile__c,Name,Status_Update_Date__c,Token__c 
                                  FROM Person__c WITH SECURITY_ENFORCED
                                  ORDER BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
        return person;
    }

    public static List<Person__c> searchPeople(String searchItem){
        searchItem = searchItem+'%';
        List<Person__c> location = [SELECT Id,Health_Status__c,Mobile__c,Name,Status_Update_Date__c,Token__c 
                                   FROM Person__c
                                   WHERE (Name  LIKE :searchItem OR  Mobile__c  LIKE :searchItem OR Token__c LIKE :searchItem)
                                   WITH SECURITY_ENFORCED
                                   ORDER BY Status_Update_Date__c DESC  NULLS LAST];
        return location;
    }
    public static Person__c  getPersonById(String personId){
        List<Person__c> person = [SELECT Id,Health_Status__c,Mobile__c,Name,Status_Update_Date__c,Token__c 
                                  FROM Person__c
                                  WHERE Id =:personId
                                  WITH SECURITY_ENFORCED];
        if (person != null && person.size() > 0) {
            return person[0];
        }
        return null;
    }

    public static Map<String,Integer> getHealthStatus(){
        Map<String,Integer> statusCounter = new Map<String,Integer>();
        for(AggregateResult st : [SELECT COUNT(Id) PkI, Health_Status__c FROM Person__c WHERE Health_Status__c != NULL WITH SECURITY_ENFORCED GROUP BY Health_Status__c ]){
            statusCounter.put((String)st.get('Health_Status__c'),(Integer)st.get('PkI'));
        }
        return statusCounter;
    }
    
    
}
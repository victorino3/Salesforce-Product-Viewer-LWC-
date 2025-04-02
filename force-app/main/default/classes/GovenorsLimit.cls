public with sharing class GovenorsLimit {
    public GovenorsLimit() {
        setNewProfile();
    }
    public void setNewProfile(){
        List<Opportunity> opportunities = [SELECT Id, Amount, Profile__c FROM Opportunity];
        
        for(Opportunity opp : opportunities){
            if(opp.Amount < 10000){
                opp.Profile__c = 'Low';
            }
            else if(opp.Amount > 10000 && opp.Amount <50000){
                opp.Profile__c = 'Medium';
            }
            else {
                opp.Profile__c = 'High';
            }
        }
        
        update opportunities;
    }

    public static void heapSize(){
        List<Account> accounts = [SELECT Name, Phone FROM Account];
        while (1==1) {
            if (Limits.getHeapSize() * 2 > Limits.getLimitHeapSize()){
                break;
            }
            List<Account> doubleAcc = accounts;
            accounts.addAll(doubleAcc);
        }
        System.debug('Got in end: '+ accounts.size());
    }
    
    public static void updateAvgCaseResolutionDays(List<Id> accountId){
        Integer totalDays = 0;
        Integer totalCases = 0;
        Integer resolutionDays=0;
        // retrive all the cases for this account
        // get resolution days for each account (ClosedDate - CreatedDate)
        List<Case>  caseObjX = [SELECT Id, CreatedDate, ClosedDate FROM Case WHERE IsClosed=true AND AccountId =: accountId];
        Integer counter = 0;
        List<Account> account = new List<Account>();
        for(Case caseObj: caseObjX ){
            
                // increase number of cases
                totalCases++;
                // get duration in days and add it to totalDays
                totalDays += caseObj.CreatedDate.date().daysBetween(caseObj.ClosedDate.date());
                resolutionDays = totalDays/totalCases;               
     
        }
        for (Id index : accountId){
            account.add(new Account(Id=index, Avg_Case_Resolution_Days__c = resolutionDays));
        }     
        // update account object  
        update account;
        System.debug('End: '+account.size());
    }
    /**List <Id> ids = new List<Id>();
        List<Account>account = [SELECT Id FROM Account];
        for(Account index: account){
            ids.add(index.Id);
        } */
    public static void setClosed(List<Id> accountId){
        List<Case>  caseObjX = [SELECT Id, CreatedDate, ClosedDate FROM Case WHERE  AccountId =: accountId];
        for(Case key : caseObjX){
            key.Status = 'Closed';          
        }
        update caseObjX;
        System.debug('Result: '+caseObjX);
    }

    
}
public class PropertyUtility {
    public PropertyUtility(){
        newListedProperties();
    }
    public void newListedProperties(){
        List<Property__c> newPropList=[SELECT Name, Broker__r.Email__c, Days_On_Market__c FROM Property__c WHERE Days_On_Market__c <= 30];
        for(Property__c info: newPropList ){
            System.debug('Name: '+info.Name+' PropertyEmail: '+info.Broker__r.Email__c);
        }
    }
    
    public static void insertObject(Account account,List<Account> accountList){
        if(account!= null){
            insert account;
        }else{
            Database.insert(accountList,false);
        }
    }
    
    public static Integer updateAccount(String name){
        Id id = PropertyUtility.getId(name);
        Account account = [SELECT Id,Name,Site FROM Account WHERE Id = :id];
        account.Name='Victorino';
        account.Site='victorino.com';
        if(id == account.id){
           update account;
           return 0;
            
          }else{
           
        }
        return 1;
    }
    
    public static String getId(String name){
        if (String.isBlank(name)) {
            return null;
        }
        
        try {
            Account account = [SELECT Id FROM Account WHERE Name = :name LIMIT 1];
            return account != null ? String.valueOf(account.Id) : null;
        } catch (System.QueryException e) {
            System.debug('Query Exception: ' + e.getMessage());
            return null;
        }
            
     }
    public static void deleteAccount(List<Account> account, Account accountSingle){
        if(account!= null){
            delete account;
            System.debug('Number of Account deleted in apex query: '+account.size());
        }else{
            Database.delete(accountSingle,false);
            System.debug('Number of Account deleted in Database query: '+account.size());
        }
    }
    public static List<Account> getObject(String searchTerm){
        String query = 'SELECT Id, Name,Site FROM Account WHERE Name LIKE \'%' + searchTerm + '%\'  LIMIT 4';
        List<Account> account = Database.query(query);
        return Account;
    }
    public static void restoreDeleted(){
        List<Account> account = [SELECT Id, Name,Site FROM Account WHERE isDeleted=true ALL ROWS];
        undelete Account;
    }
    public static void printAccount(String searchTerm){
        List<Account> account = getObject(searchTerm);
        for(Account info: account ){
            System.debug('ID: '+info.Id+' Name: '+info.Name+' Site: '+info.Site);
        }
    }
    
    public static void getFieldPoupulated(String name){
        Account a = [select Id,Name from Account where Name=:name];
        Map<String, Object> fieldsToValue = a.getPopulatedFieldsAsMap();
        
        for (String fieldName : fieldsToValue.keySet()){
            System.debug('field name is ' + fieldName + ', value is ' + 
                fieldsToValue.get(fieldName));
        }
    }
}
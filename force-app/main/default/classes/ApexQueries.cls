public class ApexQueries {
    
    public ApexQueries(){
        //getObjectQueries();
        //getParentAndCildRecord();
        //bindObject();
        dinamicQuery();
        
    }
    public void getObjectQueries(){
        Map<Id,Contact> contacts =new Map<Id,Contact>([SELECT Name, Department, Title FROM Contact]);
        for (Id contactId : contacts.keySet()) {
            Contact con = contacts.get(contactId);
            System.debug('Con: '+con.Id +'Name: ' + con.Name + ' Department: ' + con.Department);
        }
    }
    
    public void getParentAndCildRecord(){
        List<Contact> contacts = [SELECT Account.Name,Account.Rating,Name,Department, Title,(Select CaseNumber, Subject FROM Cases WHERE IsClosed = false) FROM Contact WHERE Account.Rating = 'Hot' AND Department = 'Technology' ORDER BY Name];
        for(Contact con : contacts){
            System.debug('Con: '+con.Id +'Name: ' + con.Name + ' Department: ' + con.Department +' Acount Name: '+Con.Account.Name);
            for(Case caseO : con.Cases){
                System.debug('CaseNumber: '+caseO.CaseNumber +' Case Subject: ' + caseO.Subject);
            }
        }
    }
    
    public void bindObject(){
        List<String> Names = new List<String>{'Maria Clfton','July Walker'};
        List<Contact> contacts = [SELECT Name FROM Contact WHERE Name IN :Names];
        System.debug('Result '+contacts);
        System.debug('Len '+contacts.size());
    }
    
    public void dinamicQuery(){
        String changeSite ='trocasegurao.com ';
        String query = 'SELECT Name, Site,AnnualRevenue FROM Account';
        if(changeSite == 'trocasegurao.com'){
            query+=' WHERE Name=\'Mondocorp\'';
            System.debug('Result: '+Database.query(query).size());
        }else{
            query+=' LIMIT 5';
            System.debug('Result: '+Database.query(query).size());
        }
        
    }

}
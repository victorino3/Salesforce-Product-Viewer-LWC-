public class SobjectsDML {
    public static void getSobject(){
        List<Sobject> account = [SELECT Name,Site FROM Account ORDER BY Name LIMIT 5 ];
        for(Sobject info : account){
            System.debug('Name: '+String.valueOf(info.get('Name'))+' Site: '+String.valueOf(info.get('Site')));
        }
        System.debug('Size: '+account.size());
    } 
    public static void getFieldNameSobjctChilToParent(){
        SObject con = [SELECT Id FROM contact WHERE Phone LIKE '(720) 444-1229'];
        String ids = (String) con.get('id');
        SObject contactDB = [SELECT Id, Phone,AccountId, Account.Name FROM Contact WHERE id = '0017R00002yjb6OQAQ'];
        System.debug('Name Account: '+(String) contactDB.getSObject('Account').get('Name')
                   +' Phone: '+contactDB.get('Phone'));
    }  
    public static void getFieldNameSobjctParentToChild(){
        SObject con = [SELECT Id FROM Account LIMIT 1 OFFSET 15];
        String ids = (String) con.get('id');
        SObject[] a = [SELECT id, (SELECT Name FROM Contacts LIMIT 1) FROM Account WHERE id =:ids];
        SObject[] fields = a.get(0).getSObjects('Contacts');
        for(SObject info: a){
            for(SObject data: fields){
            System.debug('Account Id: '+info.get('Id')+'  ************* Name: '+(String)data.get('Name'));
        	}
    	}
    }
    
    public static void createSObject(Map<Object, Object> myObject) {
        if (myObject.containsKey('Name') && myObject.containsKey('Phone')) {           
            SObject account = (SObject) Type.forName('Account').newInstance();
            account.put('Name', myObject.get('Name'));
            account.put('Phone', myObject.get('Phone'));
            insert account;
        } else {
            System.debug('Chaves ausentes no mapa');
        }
    }

}
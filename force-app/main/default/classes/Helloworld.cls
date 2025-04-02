public class Helloworld {
    private String greet='Good Morning';
    public static String greeting ='Good Afternoon';
    protected Double Num;
    public static Double dec;
    
    public Helloworld(){
        System.debug('Contruct with no assigment!');
    }
    public Helloworld( Double Num){
        this();
    	this.Num = Num;
        dec = Num;
        
    }

    public static void callMany(double Num){
        Helloworld test =new Helloworld(Num);
        System.debug('Num: '+test.Num+' Dec'+dec);
    }

}
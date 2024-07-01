public without sharing class MKT_Auth_Request {

    public String client_id;
    public String client_secret;
    public final String grant_type = 'client_credentials';
    private static final transient String IE_Conf_Name = 'MC_Unsub_Login';
    //private transient IE_configuration__c conf;
    public MKT_Auth_Request(IE_configuration__c conf) {
        /*
        List<IE_Configuration__c> confList = [SELECT Id, Endpoint__c, ClientId__c,Client_Secret__c, HTTPMethod__c FROM IE_Configuration__c WHERE name = 'MC_Unsub_Login'];
        if(!confList.isEmpty()){
            conf = confList.get(0);*/
            
        //}
        client_id = conf.ClientId__c;
        client_secret = conf.Client_Secret__c;

    }
    public MKT_Auth_Request(String client_id, String Client_Secret ) {
   
        this.client_id = client_id;
        this.client_secret = Client_Secret;

    }
    public static String getConfName(){
        return IE_Conf_Name;
    }
    
}
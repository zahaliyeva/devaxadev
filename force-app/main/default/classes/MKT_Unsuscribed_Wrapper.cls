public class MKT_Unsuscribed_Wrapper {
    public linksWrapper Links;
    public String requestToken;
    public String tokenExpireDateUtc;
    public String customObjectId;
    
    public String customObjectKey;
    public Integer pageSize;
	public Integer page;
    public Integer count;
	
    private static final transient String IE_Conf_Name = 'MC_Unsub_GetDetail';

    @AuraEnabled
    public List<itemsWrapper> items {get;set;}
    @AuraEnabled
    public String message {get;set;}
    @AuraEnabled
    public String errorcode {get;set;}
    @AuraEnabled
    public String documentation {get;set;}
    @AuraEnabled
    public String retryAfter {get;set;}

    public class ValueWrapper{
        @AuraEnabled
        public String ndg {get;set;}
        @AuraEnabled
        public String emailaddress {get;set;}
        @AuraEnabled
        public String expirationdate {get;set;}
        @AuraEnabled
        public String accountid {get;set;}
        @AuraEnabled
        public String firstname {get;set;}
        @AuraEnabled
        public String mobilephone {get;set;}
        @AuraEnabled
        public String insertdate {get;set;}
        @AuraEnabled
        public String channel {get;set;}
    }
    
    
    public class itemsWrapper{
        @AuraEnabled
        public ValueWrapper values {get;set;}
        @AuraEnabled
        public keysWrapper keys {get;set;}
    }
    
    public class linksWrapper{
        public String self;
    }
    
    public class keysWrapper{
        public String token;
    }

    public String getConfName(){
        return IE_Conf_Name;
    }
    /*
    public List<Map<String,String>> getValues(){
        List<Map<String,String>> toRet = new List<Map<String,String>>();
        
        for(itemsWrapper i : items){
            Map<String,String> m = new Map<String,String>();
            m.put('ndg',i.values.ndg);
            m.put('emailaddress', i.values.emailaddress);
			m.put('expirationdate', i.values.expirationdate);
            m.put('accountid', i.values.accountid);
            toRet.add(m);
        }
        return toRet;
    }*/
}
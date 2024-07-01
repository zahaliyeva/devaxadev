public class MKT_Utility {
    public static MKT_Utility__c marketingCloudUtility = MKT_Utility__c.getOrgDefaults();
    public static String KEYWORD = SMSCaringKeyword__c.getValues('SMSKeyword').Keyword__c;
    public static String KEYWORDSTT = SMSCaringKeyword__c.getValues('SMSKeywordSTT').Keyword__c;
    public static Boolean Subscribe = true;
    public static Boolean Resubscribe = true;
    public static Boolean pls_Override = false;
    public static Map<String, IE_Configuration__c> confMap;
    
    public static List<IE_Integration_Record__c> recToIns = new List<IE_Integration_Record__c>();
    public static HttpResponse sendSms(String sendSmsWrapperJson, String templateId, String authToken){
        IE_Configuration__c conf;
        if(confMap != null){
            conf = confMap.get('MC_sendSMS');
        }
        String confId = conf != null ? conf.Id : null;
        MKT_Utility__c marketingCloudUtility = MKT_Utility__c.getOrgDefaults();
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type','application/json');
        request.setEndpoint(marketingCloudUtility.MKT_SMS_ALERT_URL__c.replace('{templateId}',templateId));
        request.setMethod('POST'); 
        request.setHeader('Authorization','Bearer '+authToken);
        String body = sendSmsWrapperJson;
        system.debug('### body:'+body);
        request.setBody(body);
        Http call = new Http();
        HttpResponse response = call.send(request);
        if(confId != null){
            IE_Integration_Record__c toIns = new IE_Integration_Record__c(
                RequestBody__c = body,
                ResponseBody__c = response.getBody(),
                Status__c = response.getStatus(),
                IE_Configuration__c = confId,
                URLRequest__c = marketingCloudUtility.MKT_SMS_ALERT_URL__c.replace('{templateId}',templateId)
            );
            if(recToIns != null){
                recToIns.add(toIns);
            }
        }
        return response;
    }


    public static HttpResponse getAuthToken(){
        if(confMap == null){
            confMap = new Map<String, IE_Configuration__c>();
            List<IE_Configuration__c> confList = [Select Id, Name from IE_Configuration__c where name like 'MC_%']; 
            for(IE_Configuration__c conf : confList){
                confMap.put(conf.Name, conf);
            }
        }
        IE_Configuration__c conf = confMap.get('MC_AuthToken');
        String confId = conf != null ? conf.Id : null;
        HttpRequest request = new HttpRequest();
        //String body ='{\"clientId\":\"'+marketingCloudUtility.MKT_SMS_CLIENTID__c+'\",\"clientSecret\":\"'+marketingCloudUtility.MKT_SMS_CLIENTSECRET__c+'\"}';
        //*-+
        MKT_Auth_Request mkt_tem_req = new MKT_Auth_Request (marketingCloudUtility.MKT_SMS_CLIENTID__c,marketingCloudUtility.MKT_SMS_CLIENTSECRET__c) ;
        String body = JSON.serialize(mkt_tem_req);
        request.setHeader('Content-Type','application/json');
        request.setBody(body);
        request.setEndpoint(marketingCloudUtility.MKT_SMS_URL_AUTH__c);
        request.setMethod('POST');
        Http call = new Http();
        HttpResponse response = call.send(request);
        String respString = response.getBody();
        System.debug('**** respString:'+respString);
        if(confId != null){
            IE_Integration_Record__c toIns = new IE_Integration_Record__c(
                RequestBody__c = body,
                ResponseBody__c = respString,
                Status__c = response.getStatus(),
                IE_Configuration__c = confId,
                URLRequest__c = marketingCloudUtility.MKT_SMS_URL_AUTH__c
            );
            if(recToIns != null){
                recToIns.add(toIns);
            }
        }

        return response;

        /*
        String respString = response.getBody();
        System.debug('**** respString:'+respString);
        Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(respString);
       
        
        return String.valueOf(respMap.get('accessToken'));
		*/
    }
    
    public static String getSendSMSWrapper( String mobileNumber, String subscriberKey, String firstName, String accountId){
        SendSmsWrapper sendSmsWrapper = new SendSmsWrapper();
        sendSmsWrapper.keyword = KEYWORD;
        sendSmsWrapper.Subscribe = Subscribe;
        sendSmsWrapper.Resubscribe = Resubscribe;
        sendSmsWrapper.pls_Override = pls_Override;
        sendSmsWrapper.Subscribers = new List<SendSmsWrapper.SubscriberItem>();
        
        SendSmsWrapper.SubscriberItem subscribeItem= new SendSmsWrapper.SubscriberItem();
        subscribeItem.MobileNumber = mobileNumber;
        subscribeItem.SubscriberKey = subscriberKey;
        subscribeItem.Attributes = new SendSmsWrapper.AttributeItem();
        
        subscribeItem.Attributes.FirstName = firstName;
        subscribeItem.Attributes.AccountId = accountId;
        
     
        sendSmsWrapper.Subscribers.add(subscribeItem);
        
        String jsonBody = JSON.serialize(sendSmsWrapper).replace('pls_Override','Override');
        
        return jsonBody;
    }
    public static String getSendSMSWrapper( String mobileNumber, String subscriberKey, String firstName, String accountId,String URL){
        SendSmsWrapper sendSmsWrapper = new SendSmsWrapper();
        sendSmsWrapper.keyword = KEYWORD;
        sendSmsWrapper.Subscribe = Subscribe;
        sendSmsWrapper.Resubscribe = Resubscribe;
        sendSmsWrapper.pls_Override = pls_Override;
        sendSmsWrapper.Subscribers = new List<SendSmsWrapper.SubscriberItem>();
        
        SendSmsWrapper.SubscriberItem subscribeItem= new SendSmsWrapper.SubscriberItem();
        subscribeItem.MobileNumber = mobileNumber;
        subscribeItem.SubscriberKey = subscriberKey;
        subscribeItem.Attributes = new SendSmsWrapper.AttributeItem();
        subscribeItem.Attributes.URL = URL;
        subscribeItem.Attributes.FirstName = firstName;
        subscribeItem.Attributes.AccountId = accountId;
        
     
        sendSmsWrapper.Subscribers.add(subscribeItem);
        
        String jsonBody = JSON.serialize(sendSmsWrapper).replace('pls_Override','Override');
        
        return jsonBody;
    }
    public static String getSendSMSWrapper( String customKeyword, String mobileNumber, String subscriberKey, String firstName, String accountId,String URL){
        SendSmsWrapper sendSmsWrapper = new SendSmsWrapper();
        sendSmsWrapper.keyword = customKeyword;
        sendSmsWrapper.Subscribe = Subscribe;
        sendSmsWrapper.Resubscribe = Resubscribe;
        sendSmsWrapper.pls_Override = pls_Override;
        sendSmsWrapper.Subscribers = new List<SendSmsWrapper.SubscriberItem>();
        
        SendSmsWrapper.SubscriberItem subscribeItem= new SendSmsWrapper.SubscriberItem();
        subscribeItem.MobileNumber = mobileNumber;
        subscribeItem.SubscriberKey = subscriberKey;
        subscribeItem.Attributes = new SendSmsWrapper.AttributeItem();
        subscribeItem.Attributes.URL = URL;
        subscribeItem.Attributes.FirstName = firstName;
        subscribeItem.Attributes.AccountId = accountId;
        
     
        sendSmsWrapper.Subscribers.add(subscribeItem);
        
        String jsonBody = JSON.serialize(sendSmsWrapper).replace('pls_Override','Override');
        
        return jsonBody;
    }
    //NEW WRAPPER PER SMS STT Nicolo del papa
    public static String getSendSMSWrapperNew(String mobileNumber, String subscriberKey, String caseId, String accountId){
        SendSmsWrapper sendSmsWrapper = new SendSmsWrapper();
        sendSmsWrapper.keyword = KEYWORDSTT;
        sendSmsWrapper.Subscribe = Subscribe;
        sendSmsWrapper.Resubscribe = Resubscribe;
        sendSmsWrapper.pls_Override = pls_Override;
        sendSmsWrapper.Subscribers = new List<SendSmsWrapper.SubscriberItem>();
        
        SendSmsWrapper.SubscriberItem subscribeItem= new SendSmsWrapper.SubscriberItem();
        subscribeItem.MobileNumber = mobileNumber;
        subscribeItem.SubscriberKey = subscriberKey;
        subscribeItem.Attributes = new SendSmsWrapper.AttributeItem();
        subscribeItem.Attributes.Case_ID = caseId;
        subscribeItem.Attributes.AccountID = accountId;
        
     
        sendSmsWrapper.Subscribers.add(subscribeItem);
        
        String jsonBody = JSON.serialize(sendSmsWrapper,true).replace('pls_Override','Override');
        
        return jsonBody;
    }
    public static IE_Integration_Record__c getAuthTokenUnsub(IE_Configuration__c conf, MKT_Auth_Request reqWrapper){
        HttpRequest request = new HttpRequest();
        
        String body = JSON.serializePretty(reqWrapper);
        
        request.setHeader('Content-Type','application/json');
        request.setBody(body);
        request.setEndpoint(conf.Endpoint__c);
        request.setMethod(conf.HTTPMethod__c);
        Http call = new Http();
        HttpResponse response = call.send(request);
        
        String respString = response.getBody();
        IE_Integration_Record__c  IR = new IE_Integration_Record__c (IE_Configuration__c = conf.id,
                                                                     RequestBody__c = body,
                                                                    ResponseBody__c = respString,
                                                                    URLRequest__c = conf.Endpoint__c);
        
        
        return IR;
    }

    public static IE_Integration_Record__c getDataFromMC(IE_Configuration__c conf, String authToken, String reqToken){
        //System.debug('**** respString:'+respString);
        HttpRequest request = new HttpRequest();
        String Endpoint = conf.Endpoint__c.replace('{reqToken}', reqToken);
        request.setHeader('Content-Type','application/json');
        request.setEndpoint(Endpoint);
        request.setMethod(conf.HTTPMethod__c); 
        request.setHeader('Authorization','Bearer '+authToken);
        
        Http call = new Http();
        HttpResponse response = call.send(request);

        

        String respString = response.getBody();
        IE_Integration_Record__c  IR = new IE_Integration_Record__c (IE_Configuration__c = conf.id,
                                                                     RequestBody__c = Endpoint,
                                                                    ResponseBody__c = respString
                                                                    );
        return IR;
    }


    //Costretto da MC.
    public static Datetime parseDateTimeFromString(String dateToParse){

        List<String> ls = dateToParse.split(' '); //the first part is date, and the second is time. Last one is AM/PM

        if(ls.size() == 3){
            String dateString = ls[0];
            String timeString = ls[1];
            String meridian   = ls[2];
            Integer year;
            Integer month;
            Integer day;
            Integer hour;
            Integer minute;
            Integer second;
            //date split by '/' and parse
            List<String> lsDate = dateString.split('/');
            if(lsDate.size() == 3){
                year    = Integer.valueOf(lsDate[2]);
                month   = Integer.valueOf(lsDate[0]);
                day     = Integer.valueOf(lsDate[1]);
            }
            
            else {
                return null;
            }
            //time split by ':' and parse
            List<String> lsTime = timeString.split(':');
            if(lsTime.size() == 3){
                hour    = Integer.valueOf(lsTime[0]);
                minute  = Integer.valueOf(lsTime[1]);
                second  = Integer.valueOf(lsTime[2]);
                switch on meridian {
                    when  'AM' {
                        if(hour == 12){
                            hour = 0;
                        }
                    }
                    when else {
                        if(hour != 12)
                            hour += 12;
                    }
                }
            }
            else{
                return null;
            }
            return Datetime.newInstance(year, month, day, hour, minute, second);
        }
        return null;
        
    } 
}
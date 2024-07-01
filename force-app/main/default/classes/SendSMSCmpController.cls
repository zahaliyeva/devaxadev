public without sharing class SendSMSCmpController {
    
    @AuraEnabled
    public static MobileOutput init(String caseId, String accountId){
        System.debug('*** caseId:'+caseId);
        Case currentCase = [select Id, AccountId, Account.isPersonAccount,ContactId From Case Where Id = :caseId];
        String contactIdToSend = '';
        if(String.isBlank(currentCase.ContactId) && String.isNotBlank(currentCase.AccountId)){
            List<Contact> cList = [Select id from Contact where accountId = :currentCase.AccountId];
            contactIdToSend = cList.size() == 1 ? cList.get(0).id : '' ;
        }
        else if(String.isNotBlank(currentCase.ContactId)){
            contactIdToSend = currentCase.ContactId;
        }
        String currentAccountId = String.isNotBlank(accountId) ? accountId : currentCase.AccountId;
        if(String.isBlank(currentAccountId)) throw new AuraHandledException('È necessario associare un cliente al case per procedere.');
        List<Account> customerList = new List<Account>();
        System.debug('### case:'+currentCase);
        
         customerList = ([Select Id,
                                       FirstName,
                                       LastName,
                                       PersonContactId,
                                       CIF_MobilePhone__c,
                                       CIF_PersonMobilePhone__c,                                                                                       
                                       PersonMobilePhone,
                                       Additional_Phone__c,
                                       MobilePhone__c,
                                       Claim_PersonalMobile__c,
                                       RecordTypeId,
                                       TECH_Company__c,
                                       isPersonAccount
                                       from Account
                                       where Id=:currentAccountId and isPersonAccount = true]);
        
        if ( customerList.isEmpty() ){
            customerList = ([Select Id,
                                       Name,
                                       CIF_MobilePhone__c,
                                       CIF_PersonMobilePhone__c,                                                                                       
                                       Additional_Phone__c,
                                       MobilePhone__c,
                                       Claim_PersonalMobile__c,
                                       RecordTypeId,
                                       TECH_Company__c,
                             		   isPersonAccount
                                       from Account
                                       where Id=: currentAccountId and isPersonAccount = false]);
        }
        
        MobileOutput mobileOut = new MobileOutput();
        mobileOut = MobileOutput.ObtainMobileNumber(CustomerList[0], contactIdToSend);
        System.debug(mobileOut);
        
        return mobileOut;
    }
    
    public class ResponseWrapper{
        @AuraEnabled
        public String status{get;set;}
        @AuraEnabled
        public String errorMessage {get;set;}
    }
    
    public class MobileOutput
    {
        Boolean NumFound;
        @AuraEnabled
        public List<String> AutomaticMobileList{get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String contactId {get;set;}
        @AuraEnabled
        public String accountId {get;set;}
        @AuraEnabled
        public String company{get;set;}
    }
    
    public class URLWrapper{
        @AuraEnabled
        public String URLWebAPP;
        @AuraEnabled
        public String URLSMS;
    }
    
    public static MobileOutput ObtainMobileNumber(Account a, String contactId)
    {
        map<String,Id> acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
        
        MobileOutput Mb = new MobileOutput();
        Mb.NumFound = false;
        Mb.company = (a.TECH_Company__c!=null && a.TECH_Company__c.contains('MPS'))? 'MPS':(a.TECH_Company__c!=null && a.TECH_Company__c.contains('AAI'))?'AAI':a.TECH_Company__c;
        Mb.contactId = String.isNotBlank(contactId) ? contactId : (a.IsPersonAccount ?  a.PersonContactId : '');
        Mb.name = a.IsPersonAccount ? a.FirstName + ' '+a.LastName : a.Name;
        Mb.AutomaticMobileList = new list<String>();
        Mb.accountId = a.Id;
        /*
        system.debug('##CustomerList: '+a);
                
            if(a.RecordTypeId == acc_developerIdMap.get(AP_Constants.rtAccIndividualClient))
            {
                String AdditionalMobile = '';               
                String PersonMobile = '';
                String MobileCTL ='';              		
                
                if(String.isNotBlank(a.Additional_Phone__c))
                {
                    AdditionalMobile = (a.Additional_Phone__c).deleteWhitespace();
                    AdditionalMobile = AdditionalMobile.remove('(');
                    AdditionalMobile = AdditionalMobile.remove(')');
                }
                
                if(String.isNotBlank(a.PersonMobilePhone))
                {
                    PersonMobile = (a.PersonMobilePhone).deleteWhitespace();
                    PersonMobile = PersonMobile.remove('(');
                    PersonMobile = PersonMobile.remove(')');
                }
                
                if(String.isNotBlank(a.Claim_PersonalMobile__c))
                {
                    MobileCTL = (a.Claim_PersonalMobile__c).deleteWhitespace();
                    MobileCTL = MobileCTL.remove('(');
                    MobileCTL = MobileCTL.remove(')');
                }               
                
                if(String.isNotBlank(AdditionalMobile))
                {
                    if(String.isNotBlank(CheckMobileFormat(AdditionalMobile)))
                    {
                       // MB.ListMobileNumbers.add(new selectoption(CheckMobileFormat(AdditionalMobile),CheckMobileFormat(AdditionalMobile)));	                    
                        Mb.AutomaticMobileList.add(CheckMobileFormat(AdditionalMobile));
                    }	                    
                }
                
                if(String.isNotBlank(PersonMobile))
                {
                    if(String.isNotBlank(CheckMobileFormat(PersonMobile)))
                    {
                     //   MB.ListMobileNumbers.add(new selectoption(CheckMobileFormat(PersonMobile),CheckMobileFormat(PersonMobile)));	                    
                        Mb.AutomaticMobileList.add(CheckMobileFormat(PersonMobile));
                    }	                    
                }
                
                if(String.isNotBlank(MobileCTL))
                {
                    if(String.isNotBlank(CheckMobileFormat(MobileCTL)))
                    {
                       // MB.ListMobileNumbers.add(new selectoption(CheckMobileFormat(MobileCTL),CheckMobileFormat(MobileCTL)));	                    
                        Mb.AutomaticMobileList.add(CheckMobileFormat(MobileCTL));
                    }	                    
                }               
                system.debug('##Mb: '+Mb.AutomaticMobileList);
            }
            else if(a.RecordTypeId == acc_developerIdMap.get(AP_Constants.rtAccCorporateClient))
            {
                String AdditionalMobile = '';
                String PersonMobile = '';
                String MobileCTL = '';                 
                
                if(String.isNotBlank((a.Additional_Phone__c)))
                {
                    AdditionalMobile = (a.Additional_Phone__c).deleteWhitespace();
                    AdditionalMobile = AdditionalMobile.remove('(');
                    AdditionalMobile = AdditionalMobile.remove(')');                      
                }
                
                if(String.isNotBlank((a.MobilePhone__c)))
                {
                    PersonMobile = (a.MobilePhone__c).deleteWhitespace();
                    PersonMobile = PersonMobile.remove('(');
                    PersonMobile = PersonMobile.remove(')');                        
                }
                
                if(String.isNotBlank((a.Claim_PersonalMobile__c)))
                {
                    MobileCTL = (a.Claim_PersonalMobile__c).deleteWhitespace();
                    MobileCTL = MobileCTL.remove('(');
                    MobileCTL = MobileCTL.remove(')');                        
                }               
                
                if(String.isNotBlank(AdditionalMobile))
                {
                    if(String.isNotBlank(CheckMobileFormat(AdditionalMobile)))  
                    {
                      //  MB.ListMobileNumbers.add(new selectoption(CheckMobileFormat(AdditionalMobile),CheckMobileFormat(AdditionalMobile)));	                    
                        Mb.AutomaticMobileList.add(CheckMobileFormat(AdditionalMobile));
                    }                  
                }
                
                if(String.isNotBlank(PersonMobile))
                {
                    if(String.isNotBlank(CheckMobileFormat(PersonMobile)))	     
                    {
                      //  MB.ListMobileNumbers.add(new selectoption(CheckMobileFormat(PersonMobile),CheckMobileFormat(PersonMobile)));	                    
                        Mb.AutomaticMobileList.add(CheckMobileFormat(PersonMobile));                        
                    }               
                }
                
                if(String.isNotBlank(MobileCTL))
                {
                    if(String.isNotBlank(CheckMobileFormat(MobileCTL)))	     
                    {
                       // MB.ListMobileNumbers.add(new selectoption(CheckMobileFormat(MobileCTL),CheckMobileFormat(MobileCTL)));	                    
                        Mb.AutomaticMobileList.add(CheckMobileFormat(MobileCTL));                        
                    }               
                }                
            }
            else if(a.RecordTypeId == acc_developerIdMap.get(AP_Constants.rtAccAAFB2C))
            {
                String AdditionalMobile = '';
                String PersonMobile = '';
                
                if(String.isNotBlank(a.Additional_Phone__c))
                {
                    AdditionalMobile = (a.Additional_Phone__c).deleteWhitespace();                   
                    AdditionalMobile = AdditionalMobile.remove('(');
                    AdditionalMobile = AdditionalMobile.remove(')');                   
                }
                
                if(String.isNotBlank(a.MobilePhone__c))
                {
                    PersonMobile = (a.MobilePhone__c).deleteWhitespace();
                    PersonMobile = PersonMobile.remove('(');
                    PersonMobile = PersonMobile.remove(')');                    
                }
                
                if(String.isNotBlank(AdditionalMobile))
                {
                    if(String.isNotBlank(CheckMobileFormat(AdditionalMobile))) 
                    {
                      //  MB.ListMobileNumbers.add(new selectoption(CheckMobileFormat(AdditionalMobile),CheckMobileFormat(AdditionalMobile)));	                    
                        Mb.AutomaticMobileList.add(CheckMobileFormat(AdditionalMobile));                        
                    }                   
                }
                
                if(String.isNotBlank(PersonMobile))
                {
                    if(String.isNotBlank(CheckMobileFormat(PersonMobile)))
                    {
                        //MB.ListMobileNumbers.add(new selectoption(CheckMobileFormat(PersonMobile),CheckMobileFormat(PersonMobile)));	                    
                        Mb.AutomaticMobileList.add(CheckMobileFormat(CheckMobileFormat(PersonMobile)));                        
                    }	                    
                }           		    
            }
            else if(a.RecordTypeId == acc_developerIdMap.get(AP_Constants.rtAccB2C))
            {
                String AdditionalMobile = '';
                String PersonMobile = '';
                String MobileCTL = '';
                
                if(String.isNotBlank(a.Additional_Phone__c))
                {
                    AdditionalMobile = (a.Additional_Phone__c).deleteWhitespace();
                    AdditionalMobile = AdditionalMobile.remove('(');
                    AdditionalMobile = AdditionalMobile.remove(')');
                }	
                
                if(String.isNotBlank(a.CIF_PersonMobilePhone__c))
                {
                    PersonMobile = (a.CIF_PersonMobilePhone__c).deleteWhitespace();
                    PersonMobile = PersonMobile.remove('(');
                    PersonMobile = PersonMobile.remove(')');
                }
                
                if(String.isNotBlank(a.Claim_PersonalMobile__c))
                {
                    MobileCTL = (a.Claim_PersonalMobile__c).deleteWhitespace();
                    MobileCTL = MobileCTL.remove('(');
                    MobileCTL = MobileCTL.remove(')');
                }	               
                
                if(String.isNotBlank(PersonMobile))
                {
                    if(String.isNotBlank(CheckMobileFormat(PersonMobile)))
                       // MB.ListMobileNumbers.add(new selectoption(CheckMobileFormat(PersonMobile),CheckMobileFormat(PersonMobile)));
                        Mb.AutomaticMobileList.add(CheckMobileFormat(PersonMobile));

                }
                
                if(String.isNotBlank(AdditionalMobile))
                {
                    if(String.isNotBlank(CheckMobileFormat(AdditionalMobile)))
                       // MB.ListMobileNumbers.add(new selectoption(CheckMobileFormat(AdditionalMobile),CheckMobileFormat(AdditionalMobile)));
                       Mb.AutomaticMobileList.add(CheckMobileFormat(AdditionalMobile));
	                    
                }
                
                if(String.isNotBlank(MobileCTL))
                {
                    if(String.isNotBlank(CheckMobileFormat(MobileCTL)))
                       // MB.ListMobileNumbers.add(new selectoption(CheckMobileFormat(MobileCTL),CheckMobileFormat(MobileCTL)));
                       Mb.AutomaticMobileList.add(CheckMobileFormat(MobileCTL));
                    
                }                   
            }             
            else if(a.RecordTypeId == acc_developerIdMap.get(AP_Constants.rtAccB2B))
            {
                String AdditionalMobile = '';
                String Mobile = '';
                String MobileCTL = '';
                
                if(String.isNotBlank(a.Additional_Phone__c))
                {
                    AdditionalMobile = (a.Additional_Phone__c).deleteWhitespace();
                    AdditionalMobile = AdditionalMobile.remove('(');
                    AdditionalMobile = AdditionalMobile.remove(')');
                }	                   
                
                if(String.isNotBlank(a.CIF_MobilePhone__c))
                {
                    Mobile = (a.CIF_MobilePhone__c).deleteWhitespace();
                    Mobile = Mobile.remove('(');
                    Mobile = Mobile.remove(')');
                }
                
                if(String.isNotBlank(a.Claim_PersonalMobile__c))
                {
                    MobileCTL = (a.Claim_PersonalMobile__c).deleteWhitespace();
                    MobileCTL = MobileCTL.remove('(');
                    MobileCTL = MobileCTL.remove(')');
                }	               
                
                if(String.isNotBlank(Mobile))
                {
                    if(String.isNotBlank(CheckMobileFormat(Mobile)))
                       // MB.ListMobileNumbers.add(new selectoption(CheckMobileFormat(Mobile),CheckMobileFormat(Mobile)));
                        Mb.AutomaticMobileList.add(CheckMobileFormat(Mobile));

                }
                
                if(String.isNotBlank(AdditionalMobile))
                {
                    if(String.isNotBlank(CheckMobileFormat(AdditionalMobile)))
                      //  MB.ListMobileNumbers.add(new selectoption(CheckMobileFormat(AdditionalMobile),CheckMobileFormat(AdditionalMobile)));	
                        Mb.AutomaticMobileList.add(CheckMobileFormat(AdditionalMobile));
                    
                } 
                
                if(String.isNotBlank(MobileCTL))
                {
                    if(String.isNotBlank(CheckMobileFormat(MobileCTL)))
                      //  MB.ListMobileNumbers.add(new selectoption(CheckMobileFormat(MobileCTL),CheckMobileFormat(MobileCTL)));	
                        Mb.AutomaticMobileList.add(CheckMobileFormat(MobileCTL));
                    
                }                
            }
        
        
        if(MB.AutomaticMobileList.size()>0)
            Mb.NumFound = true;  
        */
        
        return Mb;
    }
    
    /*
    public static String CheckMobileFormat(String NumberToCheck)
    {
        String NewFormat = '';
        
        if(String.isNotBlank(NumberToCheck))
        {                 
            if((String.valueOf(NumberToCheck)).left(4) == '0039')
            {
                //if(((NumberToCheck).substring(4)).isnumeric() && ((NumberToCheck).substring(4)).left(1)=='3' && ((NumberToCheck).substring(4)).length()<=10)
                if(((NumberToCheck).substring(4)).isnumeric() && ((NumberToCheck).substring(4)).left(1)=='3')    
                    NewFormat = (NumberToCheck).substring(4);
            }
            else if((String.valueOf(NumberToCheck)).left(3) == '+39')
            {
                //if(((NumberToCheck).substring(3)).isnumeric() && ((NumberToCheck).substring(3)).left(1)=='3' && ((NumberToCheck).substring(3)).length()<=10)
                if(((NumberToCheck).substring(3)).isnumeric() && ((NumberToCheck).substring(3)).left(1)=='3')
                    NewFormat = (NumberToCheck).substring(3);
            }
            //else if((String.valueOf(NumberToCheck)).left(2) == '03' && ((NumberToCheck).substring(1)).length()<=10)
            else if((String.valueOf(NumberToCheck)).left(2) == '03')
            {
                if(((NumberToCheck).substring(1)).isnumeric())
                    NewFormat = (NumberToCheck).substring(1);
            }
            //else if((String.valueOf(NumberToCheck)).left(1) == '3' && (NumberToCheck).length()<=10)
            else if((String.valueOf(NumberToCheck)).left(1) == '3')
            {
                if(((NumberToCheck).substring(1)).isnumeric())
                    NewFormat = NumberToCheck;
            }
        }
        
        return NewFormat;
    }
    */
    @AuraEnabled
    public static boolean validate(String PhoneNumber){
        if(String.isBlank(PhoneNumber)) return false;
        String regEx = [Select RegEx__c from Field_Validator_Setting__mdt where DeveloperName = 'National_Mobile_Phone_RegEx'].RegEx__c;
        Pattern temp = Pattern.compile(regEx);
        Matcher tempMatcher = temp.matcher(PhoneNumber);
        return tempMatcher.matches();
    }

    @AuraEnabled
    public static ResponseWrapper sendSms( MobileOutput mobileOutput, String motive, String phoneNumber ){
        String authToken = '';
        String phoneNumberComplete = '39'+phoneNumber;
        String company = String.isBlank(mobileOutput.company) ? 'AAI' : mobileOutput.company;
        SMS_Message__mdt smsMessageMDT = getSMSMessageMDT(motive+'_'+company);
        System.debug('*** motive:'+motive+'_'+company);
        System.debug('*** template id:'+smsMessageMDT.ID_Template__c);
        ResponseWrapper responseWrapper = new ResponseWrapper();
        HttpResponse response = MKT_Utility.getAuthToken();
        if( response.getStatusCode() != 200 ){
            responseWrapper.status = 'KO';
            responseWrapper.errorMessage = response.getBody();
            if(MKT_Utility.recToIns != null && !MKT_Utility.recToIns.isEmpty()){
                insert MKT_Utility.recToIns;
            }
            return responseWrapper;
        }
        
        Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
        authToken = String.valueOf(respMap.get('access_token'));
        
        System.debug('*** '+MKT_Utility.getSendSMSWrapper(phoneNumberComplete, mobileOutput.contactId, mobileOutput.name, mobileOutput.accountId));
        
        response = MKT_Utility.sendSms(MKT_Utility.getSendSMSWrapper(phoneNumberComplete, mobileOutput.contactId, mobileOutput.name, mobileOutput.accountId),smsMessageMDT.ID_Template__c,authToken);
        if(MKT_Utility.recToIns != null && !MKT_Utility.recToIns.isEmpty()){
            insert MKT_Utility.recToIns;
        }
        if( response.getStatusCode() != 202 ){
            responseWrapper.status = 'KO';
            responseWrapper.errorMessage = response.getBody();
            return responseWrapper;
        }
        
       responseWrapper.status = 'OK';
        return responseWrapper;
        
    }
    @AuraEnabled
    public static ResponseWrapper sendSms2(String caseId, MobileOutput mobileOutput, String motive, String phoneNumber ,String URL){
        String authToken = '';
        String phoneNumberComplete = '39'+phoneNumber;
        String company = String.isBlank(mobileOutput.company) ? 'AAI' : mobileOutput.company;
        SMS_Message__mdt smsMessageMDT = getSMSMessageMDT(motive+'_'+company);
        ResponseWrapper responseWrapper = new ResponseWrapper();
        HttpResponse response = MKT_Utility.getAuthToken();
        if( response.getStatusCode() != 200 ){
            responseWrapper.status = 'KO';
            responseWrapper.errorMessage = response.getBody();
            if(MKT_Utility.recToIns != null && !MKT_Utility.recToIns.isEmpty()){
                insert MKT_Utility.recToIns;
            }
            return responseWrapper;
        }
        
        Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
        authToken = String.valueOf(respMap.get('access_token'));

        System.debug('*** '+MKT_Utility.getSendSMSWrapper(InviaCaiKeyWord__c.getOrgDefaults().value__c,phoneNumberComplete, mobileOutput.contactId, mobileOutput.name, mobileOutput.accountId));
        
        response = MKT_Utility.sendSms(MKT_Utility.getSendSMSWrapper(InviaCaiKeyWord__c.getOrgDefaults().value__c,phoneNumberComplete, mobileOutput.contactId, mobileOutput.name, mobileOutput.accountId, URL),smsMessageMDT.ID_Template__c,authToken);
        if(MKT_Utility.recToIns != null && !MKT_Utility.recToIns.isEmpty()){
            insert MKT_Utility.recToIns;
        }
        if( response.getStatusCode() != 202 ){
            responseWrapper.status = 'KO';
            responseWrapper.errorMessage = response.getBody();
            return responseWrapper;
        }
    	setCAIDigitale(caseId);
       responseWrapper.status = 'OK';
        return responseWrapper;     
    }

    public class SMSReqWrapper{

        public MobileOutput mobileOutput;
        public String template;
        public String phoneNumber;
        public Map<String, Object> attributeParams = new Map<String, Object>();

    }
    
    public static ResponseWrapper sendParametricSMS(SMSReqWrapper input){

        String authToken = '';
        String phoneNumberComplete = '39'+input.phoneNumber;
        
        SMS_Message__mdt smsMessageMDT = getSMSMessageMDT(input.template);
        
        
        ResponseWrapper responseWrapper = new ResponseWrapper();
        HttpResponse response = MKT_Utility.getAuthToken();
        if( response.getStatusCode() != 200 ){
            responseWrapper.status = 'KO';
            responseWrapper.errorMessage = response.getBody();
            if(MKT_Utility.recToIns != null && !MKT_Utility.recToIns.isEmpty()){
                insert MKT_Utility.recToIns;
            }
            return responseWrapper;
        }
        
        Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
        authToken = String.valueOf(respMap.get('access_token'));
        
        //get object wrapper
        SendSmsWrapper SMSWrapper = (SendSmsWrapper)JSON.deserialize(MKT_Utility.getSendSMSWrapper(phoneNumberComplete, input.mobileOutput.contactId, input.mobileOutput.name, input.mobileOutput.accountId), SendSmsWrapper.class);
        
        //get Attributes as map String Object

        Map<String, object> Attributes = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(SMSWrapper.Subscribers[0].Attributes));
        
        //set params
        for(String s : input.attributeParams.keySet()){
            Attributes.put(s, input.attributeParams.get(s));
        }

        //restore wrapper

        SMSWrapper.Subscribers[0].Attributes = (SendSmsWrapper.AttributeItem) JSON.deserialize(JSON.serialize(Attributes), SendSmsWrapper.AttributeItem.class);

        //restore wrapper string

        String SMSWrapperString = Json.serialize(SMSWrapper);


        response = MKT_Utility.sendSms(SMSWrapperString,smsMessageMDT.ID_Template__c,authToken);
        if(MKT_Utility.recToIns != null && !MKT_Utility.recToIns.isEmpty()){
            insert MKT_Utility.recToIns;
        }
        if( response.getStatusCode() != 202 ){
            responseWrapper.status = 'KO';
            responseWrapper.errorMessage = response.getBody();
            return responseWrapper;
        }
        
        responseWrapper.status = 'OK';
        return responseWrapper;
        
    }
    public static SMS_Message__mdt getSMSMessageMDT(String keyString){
        return [SELECT ID_Template__c FROM SMS_Message__mdt Where MasterLabel = :keyString][0];
    }
    
    @AuraEnabled
    public static URLWrapper ConnectToDatlas(String caseId){
        
        HttpRequest req = new HttpRequest();
     	

        DatlasEndpointConfiguration__c CS = DatlasEndpointConfiguration__c.getOrgDefaults();
        Case c = [Select id, Distribution_Network__c from case where id =: caseId];
        String clientType = 'RCI'.equalsIgnoreCase(c.Distribution_Network__c) ? 'RCI':'';
        URLWrapper wp = new URLWrapper();
        wp.URLWebApp = CS.EndpointWebApp__c + '?' + CS.firstParameter__c + '=' + CaseId + '&user=ab&'+CS.secondParameter__c+'&'+CS.Third_Parameter__c+'='+clientType;
        req.setEndpoint(CS.Endpoint__c);
     	req.setMethod('GET');
        req.setHeader('token', CaseId);
        //req.setHeader('caseid', CaseId);
        req.setHeader('source','SFDC');
        req.setHeader('clientType',clientType);
        HTTP http = new HTTP();
        Httpresponse resp = Http.send(req);
        system.debug('body: ' + resp.getBody());
        system.debug('header: ' + resp.getHeader('URL'));
        system.debug('URL: ' + resp.getBody().substringAfter('URL=\'').substringBefore('\'"'));
        if(resp.getStatusCode() == 200){
            wp.URLSMS = resp.getBody().substringAfter('URL=\'').substringBefore('\'"')/*+CS.secondParameter__c*/;
            return wp;
        }
        else{
            throw new AuraHandledException('Http Response Code is not 200');
        }
    }
    
    @AuraEnabled
    public static void setCAIDigitale(String caseId){
        case c=[select id from case where id=:caseId];
        c.CAI_Digitale__c='CAI Richiesta';
        update c;
    }
        
}
public without sharing class VFC03_Feedback {
    /*
----------------------------------------------------------------------
-- - Name          : VFC_Feedback 
-- - Author        : Spoon Consulting
-- - Description   : Extension for VFP_Feedback 
-- Maintenance History:
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 22-SEP-2014  NAP   1.0      Initial version 
----------------------------------------------------------------------
*/
    //variable declaration
    public Feedback__c feedback {get;set;}
    public Boolean hasFeedback {get;set;}
    public Boolean hasComplaint {get;set;}
    public String feedbackMsg {get;set;}
    public Case complaint {get;set;}
    private Id feedbackRecordTypeId;    
    private Map<string, id> mapRTFeedback;
    
    //MOSCATELLI_M 12112015: EVO-37-----START
    public String Question1 {get;set;}
    public String Question2 {get;set;}
    public String Question3 {get;set;}
    public String WelcomeMsg {get;set;}
    public String ErrorMsg {get;set;}
    //Giorgio Bonifazi START
    public String ErrorMsgLowScore {get;set;}
    public Boolean ShowErrorLowScore {get;set;}
    //Giorgio Bonifazi END
    public Boolean FeedbckConfound;
    public id idConfFeedbk;
    public Boolean ShowError {get;set;}
    public Boolean HasRatings { get; private set;}
    //MOSCATELLI_M 12112015: EVO-37-----END
    
    //MOSCATELLI_M 14122016: EVO-72--START
    public String Question4 {get;set;}
	public list<SelectOption> SelectRating {get;set;}
    public String SelectedRating1{set;get;}
    public String SelectedRating2{set;get;}
    public String SelectedRating3{set;get;}
    public String SelectedRating4{set;get;}
    public Integer Feedback1Value{get;set;}
    public Integer Feedback2Value{get;set;}
    public Integer Feedback3Value{get;set;}
    public Integer Feedback4Value{get;set;}
    public String selected{set;get;}
    //MOSCATELLI_M 14122016: EVO-72--END
    
    //MMOSCATELLI 22/07/2016: EVO 63 -- START
    public map<string,Id> mapFeedbackRT = AP_Constants.getDeveloperIdMap('Feedback__c');
    //MMOSCATELLI 22/07/2016: EVO 63 -- END

    //MOSCATELLI_M 16-03-2017: EVO 78 -- START
  	public String ChatCaseId; 
    public String SurveyOrigin;
    public Boolean IsCapchaNeeded{get;set;}
    //MOSCATELLI_M 16-03-2017: EVO 78 -- END    
    
    /*reCAPTCHA Configuration*/
    // The API endpoint for the reCAPTCHA service
    private static String baseUrl = system.label.reCAPTCHAbaseURL;  // baseUrl: https://www.google.com/recaptcha/api/verify
    
    // The keys you get by signing up for reCAPTCHA for your domain
    private static String privateKey = system.label.reCAPTCHAprivateKey;
    public String publicKey { 
        get { return system.label.reCAPTCHApublicKey; } 
    }
    
    // Create properties for the non-VF component input fields generated
    // by the reCAPTCHA JavaScript.
    public String challenge { 
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_challenge_field');
        }
    }
    public String response  { 
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_response_field');
        }
    }
    
    // Whether the submission has passed reCAPTCHA validation or not
    public Boolean verified { get; private set; }
    
    /*Constructor*/
    public VFC03_Feedback() {
        system.debug('## >>> START VFC_Feedback - contructor <<< run by ' + UserInfo.getUserName());

        //MOSCATELLI_M 16-03-2017: EVO 78 -- START
        //IsCapchaNeeded = true; MOSCATELLI_M 08/06/2018: Google disabled captcha v1 fix
        IsCapchaNeeded = false;
        SurveyOrigin = 'Email';
        String ChatCaseId ='';
        
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('attachedRecords')))
        {
            system.debug('##attachedRecords: '+ApexPages.currentPage().getParameters().get('attachedRecords'));
             Map<String, Object> MapPageAttachedRecords = (Map<String, Object>)JSON.deserializeUntyped(ApexPages.currentPage().getParameters().get('attachedRecords'));
            ChatCaseId = (String)MapPageAttachedRecords.get('CaseId');               
        }              
        
        if(String.isNotBlank(ChatCaseId))
        {
            IsCapchaNeeded = false;
            SurveyOrigin = 'Chat';
        }          
            
        Id caseId = (ApexPages.currentPage().getParameters().get('id')!=null)?ApexPages.currentPage().getParameters().get('id'):((ChatCaseId!='')?ChatCaseId:null);
        //Id caseId=ApexPages.currentPage().getParameters().get('id');
        //MOSCATELLI_M 16-03-2017: EVO 78 -- END 
        system.debug('##Id passed : ' + caseId);
        
        //MOSCATELLI_M 14122016: EVO-72-----START
        ShowError=false;
        ShowErrorLowScore=false;
        SelectRating = new list<SelectOption>();
        
        Feedback1Value =0;
        Feedback2Value =0;
        Feedback3Value =0;
        Feedback4Value =0;
       
        if(UserInfo.getLanguage()=='it')
            SelectRating.add(new selectoption('','--Nessuno--'));
        else        
            SelectRating.add(new selectoption('','--None--'));
        
        for(Integer i=0;i<11;i++)
        {
            SelectRating.add(new selectoption(String.valueOf(i),String.valueOf(i)));
        }
        
        SelectedRating1 = '';
        SelectedRating2 = '';
        SelectedRating3 = '';
        SelectedRating4 = '';
    
        //MOSCATELLI_M 14122016: EVO-72-----END     
        
        if(caseId == null){
            system.debug('## Complaint not found!!');
            hasComplaint = false;
            // feedbackRecordTypeId = mapRTFeedback.get(AP_Constants.rtGeneralFeedbk);
        }
        else{
            // complaint = (Case)controller.getRecord();
            
            //MOSCATELLI_M 26062015: Query Modified by introducing the record type-----START
            //complaint = [select id,Subject,Description,Account.Name,accountid,CaseNumber from case where id = :caseId];
            
            //MOSCATELLI_M 14122016: EVO-72-----START
            //complaint = [select id,Subject,Description,Account.Name,accountid,CaseNumber,RecordType.Name from case where id = :caseId];
            complaint = [select id,Subject,Description,Account.Name,accountid,CaseNumber,RecordType.Name,Complainant__c from case where id = :caseId];
            //MOSCATELLI_M 14122016: EVO-72-----END
            
            //MOSCATELLI_M 26062015: Query Modified by introducing the record type-----END
            
            system.debug('## Complaint found!! : ' + complaint);
            hasComplaint = true;
            
            //MOSCATELLI_M 12112015: EVO-37-----START
            
            //MOSCATELLI_M 14122016: EVO-72-----START
            String AllValues = 'All';
            Map<String,Feedback_Configuration__c>FeedbckConfMap=new Map<String,Feedback_Configuration__c>();
            
            for(Feedback_Configuration__c fc:[SELECT Id,Case_Record_Type__c,Complainant__c,Error_Message__c,Question_1__c,Question_2__c,Question_3__c,Question_4__c,Welcome_Message__c,Case_Origin__c , Error_Message_Low_Score__c FROM Feedback_Configuration__c  WHERE Rule_Active__c = true])
            {
              //MOSCATELLI_M 16-03-2017: EVO 78 -- START
              //FeedbckConfMap.put(fc.Case_Record_Type__c+'|'+fc.Complainant__c,fc);
              FeedbckConfMap.put(fc.Case_Record_Type__c+'|'+fc.Complainant__c+'|'+fc.Case_Origin__c,fc);    
              //MOSCATELLI_M 16-03-2017: EVO 78 -- END     
            }
            
            system.debug('##FeedbckConfMap: '+FeedbckConfMap);
            
            //MOSCATELLI_M 16-03-2017: EVO 78 -- START
            system.debug('##ConfSearch: '+complaint.RecordType.Name+'|'+complaint.Complainant__c+'|'+SurveyOrigin);
            
            if(FeedbckConfMap.containsKey(complaint.RecordType.Name+'|'+complaint.Complainant__c+'|'+SurveyOrigin))
            {
                Question1   = FeedbckConfMap.get(complaint.RecordType.Name+'|'+complaint.Complainant__c+'|'+SurveyOrigin).Question_1__c;
                Question2   = FeedbckConfMap.get(complaint.RecordType.Name+'|'+complaint.Complainant__c+'|'+SurveyOrigin).Question_2__c;
                Question3   = FeedbckConfMap.get(complaint.RecordType.Name+'|'+complaint.Complainant__c+'|'+SurveyOrigin).Question_3__c;
                Question4   = FeedbckConfMap.get(complaint.RecordType.Name+'|'+complaint.Complainant__c+'|'+SurveyOrigin).Question_4__c;
                WelcomeMsg  = FeedbckConfMap.get(complaint.RecordType.Name+'|'+complaint.Complainant__c+'|'+SurveyOrigin).Welcome_Message__c;
                ErrorMsg    = FeedbckConfMap.get(complaint.RecordType.Name+'|'+complaint.Complainant__c+'|'+SurveyOrigin).Error_Message__c;
                //Giorgio Bonifazi START
                ErrorMsgLowScore =FeedbckConfMap.get(complaint.RecordType.Name+'|'+complaint.Complainant__c+'|'+SurveyOrigin).Error_Message_Low_Score__c;
                //Giorgio Bonifazi END                 
            }
            else if(FeedbckConfMap.containsKey(complaint.RecordType.Name+'|'+AllValues+'|'+SurveyOrigin))
            {
                Question1   = FeedbckConfMap.get(complaint.RecordType.Name+'|'+AllValues+'|'+SurveyOrigin).Question_1__c;
                Question2   = FeedbckConfMap.get(complaint.RecordType.Name+'|'+AllValues+'|'+SurveyOrigin).Question_2__c;
                Question3   = FeedbckConfMap.get(complaint.RecordType.Name+'|'+AllValues+'|'+SurveyOrigin).Question_3__c;
                Question4   = FeedbckConfMap.get(complaint.RecordType.Name+'|'+AllValues+'|'+SurveyOrigin).Question_4__c;
                WelcomeMsg  = FeedbckConfMap.get(complaint.RecordType.Name+'|'+AllValues+'|'+SurveyOrigin).Welcome_Message__c;
                ErrorMsg    = FeedbckConfMap.get(complaint.RecordType.Name+'|'+AllValues+'|'+SurveyOrigin).Error_Message__c;
                //Giorgio Bonifazi START
                ErrorMsgLowScore =FeedbckConfMap.get(complaint.RecordType.Name+'|'+AllValues+'|'+SurveyOrigin).Error_Message_Low_Score__c;
                //Giorgio Bonifazi END              
            }
            else if(FeedbckConfMap.containsKey(AllValues+'|'+complaint.Complainant__c+'|'+SurveyOrigin))
            {
                Question1   = FeedbckConfMap.get(AllValues+'|'+complaint.Complainant__c+'|'+SurveyOrigin).Question_1__c;
                Question2   = FeedbckConfMap.get(AllValues+'|'+complaint.Complainant__c+'|'+SurveyOrigin).Question_2__c;
                Question3   = FeedbckConfMap.get(AllValues+'|'+complaint.Complainant__c+'|'+SurveyOrigin).Question_3__c;
                Question4   = FeedbckConfMap.get(AllValues+'|'+complaint.Complainant__c+'|'+SurveyOrigin).Question_4__c;
                WelcomeMsg  = FeedbckConfMap.get(AllValues+'|'+complaint.Complainant__c+'|'+SurveyOrigin).Welcome_Message__c;
                ErrorMsg    = FeedbckConfMap.get(AllValues+'|'+complaint.Complainant__c+'|'+SurveyOrigin).Error_Message__c;
                //Giorgio Bonifazi START
                ErrorMsgLowScore =FeedbckConfMap.get(AllValues +'|'+complaint.Complainant__c+'|'+SurveyOrigin).Error_Message_Low_Score__c;
                //Giorgio Bonifazi END                 
            }
            else
            {
                Question1   = FeedbckConfMap.get(AllValues+'|'+AllValues+'|'+SurveyOrigin).Question_1__c;
                Question2   = FeedbckConfMap.get(AllValues+'|'+AllValues+'|'+SurveyOrigin).Question_2__c;
                Question3   = FeedbckConfMap.get(AllValues+'|'+AllValues+'|'+SurveyOrigin).Question_3__c;
                Question4   = FeedbckConfMap.get(AllValues+'|'+AllValues+'|'+SurveyOrigin).Question_4__c;
                WelcomeMsg  = FeedbckConfMap.get(AllValues+'|'+AllValues+'|'+SurveyOrigin).Welcome_Message__c;
                ErrorMsg    = FeedbckConfMap.get(AllValues+'|'+AllValues+'|'+SurveyOrigin).Error_Message__c;
                //Giorgio Bonifazi START
                ErrorMsgLowScore =FeedbckConfMap.get(AllValues+'|'+AllValues+'|'+SurveyOrigin).Error_Message_Low_Score__c;
                //Giorgio Bonifazi END                 
            }
            //MOSCATELLI_M 16-03-2017: EVO 78 -- END             
            /*
            FeedbckConfound = false;
            list <Feedback_Configuration__c> FeedbckConfList = [SELECT Id,Case_Record_Type__c FROM Feedback_Configuration__c  WHERE Rule_Active__c = true];
            
            if(!FeedbckConfList.isEmpty())
            {                
                for(integer iConf=0;iConf<FeedbckConfList.size();iConf++)
                {
                    if(!FeedbckConfound)
                    {
                        if(FeedbckConfList[iConf].Case_Record_Type__c == complaint.RecordType.Name)
                        {
                            FeedbckConfound = true;
                            idConfFeedbk = FeedbckConfList[iConf].Id;
                        }
                    }        
                }
            }
            
            if(FeedbckConfound)
            {
                system.debug('#########Configurazione Feedback Trovata: '+complaint.RecordType.Name);
                list <Feedback_Configuration__c> FeedbckConf = [SELECT Id,Case_Record_Type__c,Error_Message__c,Question_1__c,Question_2__c,Question_3__c,Rule_Active__c,Welcome_Message__c FROM Feedback_Configuration__c  WHERE id =: idConfFeedbk];
                
                if(!FeedbckConf.isEmpty())
                {
                    Question1   = FeedbckConf[0].Question_1__c;
                    Question2   = FeedbckConf[0].Question_2__c;
                    Question3   = FeedbckConf[0].Question_3__c;
                    WelcomeMsg   = FeedbckConf[0].Welcome_Message__c;
                    ErrorMsg   = FeedbckConf[0].Error_Message__c;
                    system.debug('Domanda1: '+Question1+' Domanda2: '+Question2+' Domanda3: '+Question3+' Welcome: '+WelcomeMsg+' Error: '+ ErrorMsg);
                }
            }
            else
            {
                system.debug('#########Configurazione Feedback NON Trovata#########');
                list <Feedback_Configuration__c> FeedbckConf = [SELECT Id,Case_Record_Type__c,Error_Message__c,Question_1__c,Question_2__c,Question_3__c,Rule_Active__c,Welcome_Message__c FROM Feedback_Configuration__c  WHERE Case_Record_Type__c = 'All'];        
                if(!FeedbckConf.isEmpty())
                {
                    Question1   = FeedbckConf[0].Question_1__c;
                    Question2   = FeedbckConf[0].Question_2__c;
                    Question3   = FeedbckConf[0].Question_3__c;
                    WelcomeMsg   = FeedbckConf[0].Welcome_Message__c;
                    ErrorMsg   = FeedbckConf[0].Error_Message__c;
                    system.debug('Domanda1: '+Question1+' Domanda2: '+Question2+' Domanda3: '+Question3+' Welcome: '+WelcomeMsg+' Error: '+ ErrorMsg);  
                }
            }
            */
            //MOSCATELLI_M 14122016: EVO-72-----END
            //MOSCATELLI_M 12112015: EVO-37-----END            
        }
        /*
mapRTFeedback = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectFeedbk);

if(controller.getId() == null){
system.debug('## Complaint not found!!');
hasComplaint = false;
feedbackRecordTypeId = mapRTFeedback.get(AP_Constants.rtGeneralFeedbk);
}else{
//retrieve complaint from standard controller
complaint = (Case)controller.getRecord();
system.debug('## Complaint found!! : ' + complaint);
hasComplaint = true;
feedbackRecordTypeId = mapRTFeedback.get(AP_Constants.rtComplaintFeeedback);
}
*/
        //initialise feedback object
        //MMOSCATELLI 22/07/2016: EVO 63 -- START
        //feedback = new Feedback__c();
        //MOSCATELLI_M 16-03-2017: EVO 78 --START
        //Id FeedbackRTId = mapFeedbackRT.get(AP_Constants.rtGeneralFeedbk);
        //feedback = new Feedback__c(Survey_Origin__c=AP_Constants.rtFeedbackFromEmail,RecordTypeId=FeedbackRTId);
        feedback = new Feedback__c(Survey_Origin__c=SurveyOrigin,RecordTypeId=(SurveyOrigin=='Email')?mapFeedbackRT.get(AP_Constants.rtGeneralFeedbk):mapFeedbackRT.get(AP_Constants.rtChatSurveyFeedback));
        //MOSCATELLI_M 16-03-2017: EVO 78 --END
        //MMOSCATELLI 22/07/2016: EVO 63 -- END
        
        //search if a feedback is already available if a complaint id has been passed as parameter
        if(hasComplaint){
            try{
                feedback.FeedbackComments__c = [SELECT FeedbackComments__c,Survey_Origin__c FROM Feedback__c WHERE Complaint__c = :complaint.Id and Survey_Origin__c=:AP_Constants.rtFeedbackFromEmail LIMIT 1].FeedbackComments__c ;
            }catch(Exception e){
                system.debug('## Exception : ' + e);
               //MOSCATELLI_M 16-03-2017: EVO 78 --START
                //feedback = new Feedback__c(Complaint__c = complaint.Id, Account__c = complaint.AccountId,Survey_Origin__c=AP_Constants.rtFeedbackFromEmail,RecordTypeId=FeedbackRTId);
                feedback = new Feedback__c(Complaint__c = complaint.Id, Account__c = complaint.AccountId,Survey_Origin__c=(SurveyOrigin=='Email')?AP_Constants.rtFeedbackFromEmail:AP_Constants.rtFeedbackFromChat,RecordTypeId=(SurveyOrigin=='Email')?mapFeedbackRT.get(AP_Constants.rtGeneralFeedbk):mapFeedbackRT.get(AP_Constants.rtChatSurveyFeedback));
              //MOSCATELLI_M 16-03-2017: EVO 78 --END
            }
            
            //if feedback is already present
            if(!String.isBlank(feedback.FeedbackComments__c) ){
                system.debug('## There is already a feedback for this complaint!');
                feedbackMsg = system.label.FeedbackResponseAlreadyRegistered; 
                hasFeedback = true;
            }//end if
        }//end if complaint has been found
        
        // feedback.recordTypeId = feedbackRecordTypeId;
        //reCAPTCHA settings
        this.verified = false;
        
        system.debug('## >>> END VFC_Feedback - constructor <<<');
    }//end controller
    
    /*Method to submit feedback*/
    public PageReference submit(){
        system.debug('## >>> START method VFC_Feedback - submit() <<< run by ' + UserInfo.getUserName());
        
        //MOSCATELLI_M 12112015: EVO-37-----START
        ShowError = false;
        ShowErrorLowScore = false;
        this.HasRatings = true;
        
       
        
        
        //MOSCATELLI_M 14122016: EVO-72-----START
        feedback.Rating1__c = 0;
        feedback.Rating2__c = 0;
        feedback.Rating3__c = 0;
        feedback.Rating4__c = 0;
        
        if(String.isNotBlank(SelectedRating1))
        	feedback.Rating1__c = Feedback1Value;
        if(String.isNotBlank(SelectedRating2))
        	feedback.Rating2__c = Feedback2Value;
        if(String.isNotBlank(SelectedRating3))
        	feedback.Rating3__c = Feedback3Value;
        if(String.isNotBlank(SelectedRating4))
       		feedback.Rating4__c = Feedback4Value;
        
        system.debug(feedback.Rating1__c+' '+feedback.Rating2__c+' '+feedback.Rating3__c+' '+feedback.Rating4__c);
        
   
        //if((feedback.Rating1__c ==0 || feedback.Rating2__c ==0 || feedback.Rating3__c ==0) || (feedback.Rating1__c ==0 && feedback.Rating2__c ==0 && feedback.Rating3__c ==0))
        if(String.isBlank(SelectedRating1) || String.isBlank(SelectedRating2) || String.isBlank(SelectedRating3) || String.isBlank(SelectedRating4))
        //MOSCATELLI_M 14122016: EVO-72-----END
        {
            ShowError = true;
            this.HasRatings = false;
            feedback.Rating1__c = 0;
            feedback.Rating2__c = 0;
            feedback.Rating3__c = 0;
            feedback.Rating4__c = 0;//MOSCATELLI_M 14122016: EVO-72
        }
        
         //Giorgio Bonifazi START
         if(String.isNotBlank(SelectedRating1)){
            if(Integer.valueOf(SelectedRating1) <=6  &&  String.isBlank(feedback.FeedbackComments__c)) 
                ShowErrorLowScore = true;
            else{
                
                if(String.isNotBlank(SelectedRating2)){
                    if(Integer.valueOf(SelectedRating2) <=6  &&  String.isBlank(feedback.FeedbackComments__c)) 
                        ShowErrorLowScore = true;
                    else{
                        
                        if(String.isNotBlank(SelectedRating3)){
                            if(Integer.valueOf(SelectedRating3) <=6  &&  String.isBlank(feedback.FeedbackComments__c)) 
                                ShowErrorLowScore = true;
                            else{
                                
                                if(String.isNotBlank(SelectedRating4)){
                                    if(Integer.valueOf(SelectedRating4) <=6  &&  String.isBlank(feedback.FeedbackComments__c)) 
                                        ShowErrorLowScore = true;
                                    else{  
                                        ShowErrorLowScore = false;                                                                   
                                    }}}}}}}}   
        
       
        //Giorgio Bonifazi END
   

        //MOSCATELLI_M 12112015: EVO-37-----END 

        //MOSCATELLI_M 16-03-2017: EVO 78 -- START
        if(!IsCapchaNeeded)
        {
          this.verified = true;    
        }
        else
        {          
            //reCAPTCHA
            System.debug('reCAPTCHA verification attempt');
            // On first page load, form is empty, so no request to make yet
             if ( challenge == null || response == null ) { 
                System.debug('reCAPTCHA verification attempt with empty form');
                return null; 
            }
            
            HttpResponse r = makeRequest(baseUrl,
                                         'privatekey=' + privateKey + 
                                         '&remoteip='  + remoteHost + 
                                         '&challenge=' + challenge +
                                         '&response='  + response
                                        );
            
            //if running a test class
            if(Test.isRunningTest()){
                r = new HttpResponse();
                r.setBody('true');
            }
            
            if ( r!= null ) {
                this.verified = (r.getBody().startsWithIgnoreCase('true'));
            }
        }
        //MOSCATELLI_M 16-03-2017: EVO 78 -- END 
        
        //MOSCATELLI_M 12112015: EVO-37-----START
        //if(this.verified) {
        if(this.HasRatings && this.verified && !ShowErrorLowScore) {
         //MOSCATELLI_M 12112015: EVO-37-----END
            //logic implemented after reCAPTCHA passed is implemented below
            //if(!String.isBlank(feedback.FeedbackComments__c)){
            insert feedback;
            hasFeedback = true;
            feedbackMsg = system.label.FeedbackResponseRegistered;
            //}
            system.debug('## >>> END method VFC_Feedback - submit() <<<');  
            return null;
        }
        else {
            system.debug('## >>> END method VFC_Feedback - submit() <<<');
            // stay on page to re-try reCAPTCHA
            return null; 
        }
    }//end method submit()
    
    public PageReference reset() {
        return null; 
    }   
    
    /* Private helper methods */
    
    private static HttpResponse makeRequest(string url, string body)  {
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        try {
            Http http = new Http();
            response = http.send(req);
            System.debug('reCAPTCHA response: ' + response);
            System.debug('reCAPTCHA body: ' + response.getBody());
        } catch(System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return response;
    }   
    
    private String remoteHost { 
        get { 
            String ret = '127.0.0.1';
            // also could use x-original-remote-host 
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr')!= null)
                ret =  hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP')!= null)
                ret =  hdrs.get('X-Salesforce-SIP');
            return ret;
        }
    }
    
    //MOSCATELLI_M 14122016: EVO-72-----START
    public void setChoiceValue()
    {
        system.debug(SelectedRating1+' '+SelectedRating2+' '+SelectedRating3+' '+SelectedRating4);
       
        if(String.isNotBlank(SelectedRating1) && selected=='1')
        	Feedback1Value = Integer.valueOf(SelectedRating1);
        if(String.isNotBlank(SelectedRating2)  && selected=='2')
        	Feedback2Value = Integer.valueOf(SelectedRating2);
        if(String.isNotBlank(SelectedRating3) && selected=='3')
        	Feedback3Value = Integer.valueOf(SelectedRating3);
        if(String.isNotBlank(SelectedRating4) && selected=='4')
        	Feedback4Value = Integer.valueOf(SelectedRating4);        
    }
    //MOSCATELLI_M 14122016: EVO-72-----END
}//end extension class VFC_Feedback
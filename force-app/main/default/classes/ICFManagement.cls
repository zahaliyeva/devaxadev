/*------------------------------------------------------------------------
Author:        Francesca Marchese
Company:       Deloitte
Class:         ICFManagement
Description:   Apex class with reusable methods whose purpose is to verify the role of the current
               User, the sending of a reminder to specific Users if there are selectable interactions
               and the sending of selected interactions to Sandsiv in order to send survey to the customer 

History

6/12/2016     Created - F.M.
----------------------------------------------------------------------------*/
/**
 * @description PURE IT 22/05 - commentata la classe
 */
public class ICFManagement {
    /** PURE IT
    //method used in controller ICFInteractionsSelectionController to identify 'AAI - Vendite Avanzato' on Agency node.
    public static Boolean AuthorizedAgent() {
        
        Set <String> ProfiledNodes = new Set <String>();
        String UserId=UserInfo.GetUserId();
        User CurrentUser = new User();
        CurrentUser=[SELECT Id,Name,FirstName,LastName, IsPortalEnabled,Profile.Name,UserRole.DeveloperName, Contact.Account.isPartner, Nodes__c, Agency_code__c FROM User WHERE Id=:UserId Limit 1];
        
        if(CurrentUser.Profile.Name == 'AAI - Vendite Avanzato'){
            
            ProfiledNodes.addAll(CurrentUser.Nodes__c.split(';'));
            
            //system.debug('SETProfiledNodes'+ProfiledNodes);
            
        }
        if ((CurrentUser.Profile.Name == 'System Administrator') || (CurrentUser.Profile.Name == 'AAI - Vendite Avanzato' && ProfiledNodes.contains('DIF_'+CurrentUser.Agency_code__c))){
            return true;
        }else{
            return false;
        }
        
    } PURE IT */
    
  /* public static Boolean isAgent (User U) {
        
        Set <String> ProfiledNodes = new Set <String>();
        ProfiledNodes.addAll(U.Nodes__c.split(';'));
        if ( ProfiledNodes.contains('DIF_'+U.Agency_code__c)){
            return true;
        }else{
            return false;
        }
    }*/
    /** PURE IT
    //method used in batch BatchReminder to send Email to specific Users if there are selectable interactions
    public static List <User> ICFSendreminder (List<User> UserVenditeAvazato) {
        
        Set<String> AgencyCodes = new Set<String>();
        List<User> UserReceivingEmail = new List <User>();
        List<Interazione__c> SelectableInteractions = new List <Interazione__c>();
        //SelectableInteractions=[SELECT Account__c,Id,Limite_massimo_invio_survey__c,Stato__c,TECH_Agency_code__c FROM Interazione__c WHERE Limite_massimo_invio_survey__c >= TODAY AND (Account__r.CIF_PersonEmail__c!=null OR Account__r.CIF_PersonMobilePhone__c !=null) AND TECH_Agency_code__c = :U.Agency_code__c AND Stato__c='' AND TECH_Da_inviare__c=false LIMIT 200]
        SelectableInteractions=[SELECT Account__c,Id,Limite_massimo_invio_survey__c,Stato__c,TECH_Agency_code__c FROM Interazione__c WHERE Limite_massimo_invio_survey__c >= TODAY AND (Account__r.CIF_PersonEmail__c!=null OR Account__r.CIF_PersonMobilePhone__c !=null) AND Stato__c='' AND TECH_Da_inviare__c=false];
        
        system.debug('*****Selectable interactions'+SelectableInteractions);
        
        for(Interazione__c I: SelectableInteractions){
        
        AgencyCodes.add(I.TECH_Agency_code__c);
        
        }
        
        system.debug('***The list of AgencyCodes'+AgencyCodes);
        
        for (User U: UserVenditeAvazato){
            Set <String> ProfiledNodes = new Set <String>();
            ProfiledNodes.addAll(U.Nodes__c.split(';'));
            if (ProfiledNodes.contains('DIF_'+U.Agency_code__c)) {
                
                
                if (AgencyCodes.contains(U.Agency_code__c)){
                
                
                
                    
                    User thisUser = new User();
                    thisUser = [SELECT Name, Email From User WHERE Id=:U.Id];
                    EmailTemplate[] templates = [SELECT HtmlValue, Body, Subject FROM EmailTemplate WHERE Name ='AAI - Reminder per invio survey' ];
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    String[] toAddresses = new String[] {thisUser.Email};
                    
                    mail.setTemplateId(templates[0].Id);
                    mail.setToAddresses(toAddresses);
                    mail.setHtmlBody(templates[0].HtmlValue);
                    mail.setSubject(templates[0].Subject);
                    mail.setTargetObjectId(U.id);
                    mail.setSaveAsActivity(false);
                    
                    
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    system.debug('+++++EMAIL limit (calls/limit)='+Limits.getEmailInvocations()+'/'+Limits.getLimitEmailInvocations());
                    
                    UserReceivingEmail.add(U);
                    
                    
                }
                
                
            }
            
        }
        return UserReceivingEmail;
    }
    
    
    //method used in batch BatchICFIntegration to send the request of Integration with Sandsiv
    public static List <XMLInformation> ICFSendSurveys (List<Interazione__c> InteractionstoSend) {             //(Interazione__c I)
        
        List <XMLInformation> Surveysinformation = new List <XMLInformation>();
        
        if(InteractionstoSend.size()!=0){
            
            system.debug('++++'+InteractionstoSend);
            
            for (Interazione__c IntExt: InteractionstoSend){
                
                XMLInformation singleXML = new XMLInformation(IntExt);
                
                SurveysInformation.add(singleXML);
                
            }
            system.debug('********'+SurveysInformation);
            
            
        }
        
        List <XMLInformation> SurveysInformationAfterIntegration = Request(SurveysInformation);
        
        
        return SurveysInformationAfterIntegration;
        
        
    }
    
    //method used to realize the effective integration. It is called in ICFSendSurveys
    public static List <XMLInformation> Request (List <XMLInformation> thelist){
        
        
        String ScopeId = '';
        
        for (ICFManagement.XMLInformation l: thelist){
            
            ScopeId = ScopeId + l.I.Id +';';
            //scopeIds.add(l.I.Id);
            
        }
        
        
        String IE_Configuration_Name = 'ICF_Sales';
        
        
        IE_Configuration__c conf = [select id, Name from IE_Configuration__c where Name = :IE_Configuration_Name limit 1];
        IE_Integration_Record__c MyIERecord = new IE_Integration_Record__c (ScopeID__c = ScopeId);
        
        
        MyIERecord.IE_Configuration__c= conf.id;
        
        IE_Engine MYIEinstance = new IE_Engine(MyIERecord);
        
        MYIEinstance.compileRequest();
        
        system.debug(MYIEinstance.compiledXML);
        system.debug('#####################'+Limits.getDMLRows());
        MYIEinstance.sendRequest();
        
        MYIEinstance.interpretresponse();
        
        String Id_of_import_operation = MYIEinstance.JSONResponse;
        
        List <XMLInformation> SurveysInformationAfterIntegration = new List <XMLInformation>();
        
        for (XMLInformation x: thelist){
            
            x.Id_of_import_operation= String.ValueOf(Id_of_import_operation);
            SurveysInformationAfterIntegration.add(x);
        }
        
        system.debug('*+*+*'+SurveysInformationAfterIntegration);
        return SurveysInformationAfterIntegration;
    }
    
    
    
    public static void UpdateRecords(List<XMLInformation> InteractionstoUpdate) {
        
        
        List <Interazione__c> RecordstoUpdate = new List <Interazione__c>();
        List <Feedback__c> FeedbacktoInsert = new List <Feedback__c>();
        
        
        
        for (XMLInformation XML: InteractionstoUpdate){
            
            if (!(String.isEmpty(XML.Id_of_import_operation))){     //meglio String.isEmpty()
                
                XML.I.TECH_Da_inviare__c=false;
                XML.I.Stato__c='Questionario inviato';
                RecordstoUpdate.add(XML.I);
                
                Feedback__c CurrentFeedback = new Feedback__c();
                CurrentFeedback.RecordTypeId =[SELECT Id,SobjectType,Name FROM RecordType WHERE Name ='AAI Feedback' AND SobjectType ='Feedback__c'  limit 1].Id;
                CurrentFeedback.TECH_Logic_Key__c = XML.LogicKeyFeedback;
                CurrentFeedback.Interazione__c= XML.I.Id;
                CurrentFeedback.Account__c=XML.I.Account__c;
                CurrentFeedback.Questionario_richiesto_da__c=XML.I.Questionario_richiesto_da__c;
                system.debug(' * * * '+CurrentFeedback.Questionario_richiesto_da__c);
                CurrentFeedback.Created_By__c=XML.I.CreatedById;
                system.debug(' * * * '+CurrentFeedback.Created_By__c);
                CurrentFeedback.TECH_Id_of_import_operation__c= XML.Id_of_import_operation;
                FeedbacktoInsert.add(CurrentFeedback);
                
                
                
            }else{
                
                XML.I.TECH_Da_inviare__c=false;
                XML.I.Stato__c=null;
                RecordstoUpdate.add(XML.I);
            }
            
        }
        system.debug('****'+FeedbacktoInsert);
        
        update RecordstoUpdate;
        insert FeedbacktoInsert;
        
    }
    
    
    
    
    //class for the preparation of the list of XML data for the request sending
    public with sharing class XMLInformation {
        //Add here columns for the XML information
        public Interazione__c I;
        public String LogicKeyFeedback;
        public String Language;
        public String Address;
        public String Survey_Id;
        public String Id_of_import_operation;
        
        public XMLInformation (Interazione__c I) {
            
            String OrgId= UserInfo.getOrganizationId();
            this.I=I;
            this.LogicKeyFeedback = OrgId +'_'+ I.Account__r.NDG__c +'_'+ I.Id;
            this.Language = 'IT';
            if (I.Account__r.CIF_PersonEmail__c!=null){
                
                this.Address = I.Account__r.CIF_PersonEmail__c;
                this.Survey_Id='818';
                
            }else{
                
                this.Address = I.Account__r.CIF_PersonMobilePhone__c;
                this.Survey_Id='14';
                
            }
            this.Id_of_import_operation='';
        }
    }
    PURE IT */
}
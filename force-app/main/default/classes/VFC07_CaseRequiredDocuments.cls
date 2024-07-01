public with sharing class VFC07_CaseRequiredDocuments {
    public VFC07_CaseRequiredDocuments(){} //for lightning 
   
    /*Wrapper class*/
    public class retrieveDocW{
        public boolean selected{get;set;}
        public string docName{get;set;}
        
        public retrieveDocW(){
            selected = false;
            docName = '';     
        }
    }
    
    /*Variables*/
    public list<retrieveDocW> docResults{get;set;}
    public Case caseRec{get;set;}
    public Boolean saveFlg{get;set;}
    public Boolean VisualizeButton{set;get;}//MOSCATELLI_M 20/04/2018: Apertura sinistri da email
    
    public list<String> requiredDocs; 
    
    /*Controller*/
    public VFC07_CaseRequiredDocuments(ApexPages.StandardController controller){
        system.debug('## >>> Starting Class constructor VFC07_CaseRequiredDocuments by ' + userInfo.getName());
        
        //initialize variables
        docResults = new list<retrieveDocW>();
        requiredDocs = new list<String>();
        saveFlg =  false;
        
        caseRec = (Case)controller.getRecord();
        system.debug('caseRec:'+caseRec);

        //MOSCATELLI_M 20/04/2018: Apertura sinistri da email -- START
        VisualizeButton = true;
        String CaseType = caseRec.RecordType.developername;

        if(CaseType==AP_Constants.rtCaseSinistro || CaseType==AP_Constants.rtCaseSinistriAAI)
            VisualizeButton = false;
        //MOSCATELLI_M 20/04/2018: Apertura sinistri da email -- END        
       

        if(caseRec.RequiredDocumentList__c <> null) requiredDocs = caseRec.RequiredDocumentList__c.split('\n');
        
        system.debug('## requiredDocs: '+requiredDocs);
        
        //Call Method
        retrieveAllDocuments();
    }
    
    /*Method retrieveAllDocuments*/
    public void retrieveAllDocuments(){
        system.debug('## Start method retrieveAllDocuments');
        
        list<String> docNames = new list<String>();
        list<String> docTemp = new list<String>();
        String message; 
        
        //loop in all values  
        if(caseRec.SubCategory__c <>  ''){
            for(RequiredDocuments__c csDocs:RequiredDocuments__c.getall().values()){
                if(caseRec.SubCategory__c == csDocs.SubCategory__c){
                    system.debug('##csDocs: '+csDocs);
                    
                    if(csDocs.RequiredDocuments1__c!=null && csDocs.RequiredDocuments1__c.contains(',')){
                        
                        docNames.addAll(csDocs.RequiredDocuments1__c.split(','));
                        system.debug('## 1 '+docNames);
                    }
                    else{
                        if(csDocs.RequiredDocuments1__c!=null) docNames.add(csDocs.RequiredDocuments1__c);
                        system.debug('## 2 '+docNames);
                    }
                    
                    if(csDocs.RequiredDocuments2__c!=null && csDocs.RequiredDocuments2__c.contains(',')){
                        docNames.addAll(csDocs.RequiredDocuments2__c.split(','));
                    }
                    else{
                        if(csDocs.RequiredDocuments2__c!=null) docNames.add(csDocs.RequiredDocuments2__c);
                    }
                }//end if
            }//end for
        }else{
            message = system.Label.VFC07_NoSubCategory;
        }//end if
        system.debug('##docNames:'+docNames);
        
        retrieveDocW docRecW; 
        
        system.debug('## requiredDocs: '+requiredDocs);
        //add docName in wrapper list
        for(string s:docNames){
            docRecW = new retrieveDocW();
            docRecW.docName = s;
            system.debug('## s: '+s);
            for(String reqDoc :requiredDocs){
                system.debug('## reqDoc: '+reqDoc);
                if (reqDoc.trim() == s.trim()){
                    docRecW.selected = true;
                    continue;
                }
            }
            
            system.debug('## docRecW.selected: '+docRecW.selected);
            docResults.add(docRecW);
            
        }//end for
        
        if(docResults.size() == 0 && message != '')
            message = system.Label.VFC07_NoDocuments;
        
        if(message != null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,message));
        
        system.debug('##docResults:'+docResults);
        system.debug('## END retrieveAllDocuments');    
    }
    public pageReference allowUpdate(){
        saveFlg = true;
        return null;
    }
    public pageReference save(){
        system.debug('## Start method save');      
        String missingDocs='';
        caseRec.RequiredDocumentList__c = '';
        integer i = 0;
        
        for(retrieveDocW doc: docResults){
            if(doc.selected == true){
                caseRec.RequiredDocumentList__c = caseRec.RequiredDocumentList__c + doc.docName +'\n'; 
            }else{
                i++;
                missingDocs += i+'. '+doc.docName +'<br/>'; 
                caseRec.status = AP_Constants.caseStatusPending;
            }
        }
        system.debug('## caseRec '+caseRec);
        try{
            update caseRec;
        }catch(Exception e){
            system.debug('## Error on Case Update: '+e.getMessage());
        }
        saveFlg = false;
        if(missingDocs != '') {
            sendMail(missingDocs.removeEnd('\n'));
        }
        system.debug('## End method save'); 
        
        return null;
    }
    public void sendMail(String missingDocs){
        system.debug('## START - VFC07_CaseRequiredDocuments.sendMail');
        
        //Contact c = new Contact();
        
        list<Messaging.SingleEmailMessage> listEmail = new list<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();            
        
        EmailTemplate etem = [Select e.Markup,e.HtmlValue, subject, body From EmailTemplate e where DeveloperName = :System.Label.VFC07_MissingDocumentList];
        
        //system.debug('## caseRec.PersonAccountId__c: '+caseRec.PersonAccountId__c);
        list<string> listEmails = new list<string>();
        id accId = (caseRec.AgentName__c==null)?caseRec.AccountId:caseRec.AgentName__c;
        if(accId <>null)
        {
            //MMOSCATELLI 17/02/2017: Evo 77 -- START
            /*
for (Account acc : [Select PersonEmail, name, Account_email__c,recordtype.developername, ispersonaccount,PersonContactId
From Account 
Where Id = :accId ]){
string accEmail = (acc.PersonEmail==null)?acc.Account_email__c:acc.PersonEmail;
*/
            for (Account acc : [Select PersonEmail, name, Account_email__c,recordtype.developername, ispersonaccount,PersonContactId,Additional_email__c,Subject_email__c, CIF_PersonalEmail__c,CIF_Work_email__c,CIF_PersonEmail__c,Claim_PersonalEmail__c
                                From Account 
                                Where Id = :accId ])
            {
                string accEmail = '';
                
                if(String.isNotBlank(acc.Additional_email__c))
                    accEmail = acc.Additional_email__c;
                else if(acc.recordtype.developername == AP_Constants.rtAccCorporateClient && acc.Account_email__c!='')
                    accEmail = acc.Account_email__c;
                else if(acc.recordtype.developername == AP_Constants.rtAccB2B)
                {
                    if(String.isNotBlank(acc.CIF_PersonalEmail__c))
                      accEmail = acc.CIF_PersonalEmail__c;
                    else if(String.isNotBlank(acc.CIF_Work_email__c))
                      accEmail = acc.CIF_Work_email__c;
                    else if(String.isNotBlank(acc.Subject_email__c))
                      accEmail = acc.Subject_email__c;
                }
                else if(acc.recordtype.developername == AP_Constants.rtAccB2C)
                {
                    if(String.isNotBlank(acc.CIF_PersonEmail__c))
                      accEmail = acc.CIF_PersonEmail__c;
                    else if(String.isNotBlank(acc.CIF_Work_email__c))
                      accEmail = acc.CIF_Work_email__c;
                    else if(String.isNotBlank(acc.PersonEmail))
                      accEmail = acc.PersonEmail;
                }                
                else if(acc.PersonEmail!='')
                    accEmail = acc.PersonEmail;
                else if(String.isNotBlank(acc.Claim_PersonalEmail__c))
                    accEmail = acc.Claim_PersonalEmail__c;
                //MMOSCATELLI 17/02/2017: Evo 77 -- END
                
                if(string.isnotblank(accEmail)){
                    listEmails.add(accEmail);
                }
            }//end loop                      
        }
        
        if(listEmails.size()>0)  {
            //system.debug('## c: '+c);
            
            string orgemail = (caseRec.RecordType.developername == AP_Constants.rtCaseMotor)?system.label.OrgWideEmailDisplayNameMotor:((caseRec.RecordType.developername == AP_Constants.rtCaseNonMotor)?system.label.OrgWideEmailDisplayNameNonMotor:system.label.OrgWideEmailDisplayName);
                // set from email
                for(OrgWideEmailAddress org: [SELECT ID,DisplayName,Address 
                                              FROM OrgWideEmailAddress 
                                              WHERE DisplayName = :orgemail LIMIT 1])
            {
                email.setOrgWideEmailAddressId(org.Id);
            }
            
            
            //html body
            String htmlBody = etem.HtmlValue;
            htmlBody = htmlBody.replace('{!User.Name}',userinfo.getName());
            htmlBody = htmlBody.replace('{!Case.RequiredDocumentList__c}',missingDocs);
            htmlBody = htmlBody.replace('{!Contact.Name}',((caseRec.AccountID==null||caseRec.Account.name==null)?'':caseRec.Account.name));
            // htmlBody = htmlBody.replaceAll('\n','<br/>');
            
            //email setup
            
            string subj =  etem.subject.replace('{!Case.CaseNumber}',(caseRec.CaseNumber==null?'{!Case.CaseNumber}':caseRec.CaseNumber));
            subj =  subj.replace('{!Case.TECHThreadId__c}',(caseRec.TECHThreadId__c==null?'{!Case.TECHThreadId__c}':caseRec.TECHThreadId__c));
            
            email.setSubject(subj);
            email.emailPriority='High';
            //email.setToAddresses(listEmails);
            system.debug('####### caseRec.contactid:'+caseRec.contactid);
            if(string.isNotBlank(caseRec.contactid)){
                email.setTargetObjectId(caseRec.contactid);
            }
            else{        
                email.setToAddresses(listEmails);
            }
            email.setHtmlBody(htmlBody);
            email.setWhatId(caseRec.id);
            email.saveAsActivity = true;
            listEmail.add(email);
            
            //send email
            try{
                Messaging.sendEmail(listEmail);  
            }
            catch( Exception e ){              
                if(ApexPages.currentPage() != null) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));  
                system.debug('## Error while sending email: '+e.getMessage() );
            }          
        }
        system.debug('## END - VFC07_CaseRequiredDocuments.sendMail');
    }
}
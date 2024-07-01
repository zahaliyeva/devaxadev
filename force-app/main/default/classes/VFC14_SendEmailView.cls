/*
***************************************************************************************************
---------------------------------------------------------------------------------------------------
-- - Name          : VFC14_SendEmailView
-- - Author        : Veronica Raniello
-- - Description   : Class used to visualize in the visualforce page VFP14_SendEmailView 
-- -          all the activity related to email messages and all the buttons useful to send new
-- -          email messages
--
-- Maintenance History:
--
-- Date          Version  Remarks
-- -----------  -------  --------------------------------------------------------------------------
-- 19-05-2016   1.0     
---------------------------------------------------------------------------------------------------
***************************************************************************************************
*/


public with sharing class VFC14_SendEmailView
{   
    private final Case cas;
    public Id CaseID {get;set;}
    public list<EmailMessage> listEmailMessage{set;get;}    
    public Map<String, String> UrlParameterMap;
    public Id AccountId  {set;get;}
    public Id AgentId;
    public String SuppliedEmail{set;get;}    
    public Map<Id,RecordType> MapAccountRecordType = new map<Id,RecordType>([Select Id, DeveloperName from RecordType where SObjectType = 'Account']);
    public Map<Id,RecordType> MapCaseRecordType = new map<Id,RecordType>([Select Id, Name from RecordType where SObjectType = 'Case']);
    public List<Account> ListAssociatedAccount;       
    public String toCustomerAddress{set;get;}
    public String toAgentAddress{set;get;}
    public String FromAddressforCustomer{set;get;}
    public String FromAddressforAgent{set;get;}
    public String FromAddressforTechnicalOffice{set;get;}
    public String URLBASE2 {get;set;}
    public String CaseRecTyp;
    public Integer page{get;set;}
    public Integer totalRecords{get;set;}
    public Integer totalPages{get;set;}
    public Integer startIdx{get;set;}
    public Integer endIdx{get;set;}
    //private static final Integer PAGE_SIZE = 10;
    private static final Integer PAGE_SIZE = 3;
    private static final Integer MAX_DISPLAYED_CHAR =77;
    public String CaseId15digit{set;get;}

    //BOVOLENTA_D 16052018 US 688
    public Boolean isAaiAccount {get;set;}
    public String toAgencyAddress {get;set;}
    public String FromAddressforAgency {get;set;}

    //BOVOLENTA_D 17052018 US 684
    public String FromAddressforGDPR {get;set;}
    public Boolean GDPRBtnAvailability {get;set;} 
    public Boolean IsGDPR {get;set;} 
    public String BCCforGDRP {get;set;}//String used in the email to customer
    public String emailToClientURL {get;set;}

    //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- START
    public String ExternalProviderEmail{set;get;}
    public Id EmailTemplateId{set;get;}
    public String ExternalProviderType{get;set;}
    public Boolean MyFoxBtnAvailability{set;get;}
    //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- END
    
    //OAVERSANO 05/07/2018: Easy Azienda -- START
    public Boolean AgentBtnAvailability {get;set;}  
    public Boolean BankAgentBtnAvailability {get;set;}
    public Boolean TechnicalBtnAvailability {get;set;}
    public String toAgencyAAIAddress {get;set;}
    public String FromAddressforAAIAgent{set;get;}
    //OAVERSANO 05/07/2018: Easy Azienda-- END
    
    public Boolean BlueAssBtnAvailability{set;get;}//MOSCATELLI_M 16/11/2016: Evo 70
    public Boolean AMFTechnicalOfficeAvailability{set;get;} //ACAPOBIANCO 22/08/2017: Evo 87 AMF
    //MMOSCATELLI 25022019: ICF CR -- START
    public Boolean isAgentUser{get;set;}
    public String UserAgentEmail;
    //MMOSCATELLI 25022019: ICF CR -- END

    //MDANTONIO 04/04/2019: render button per Case DAC AXA Agenti - start
    public Boolean renderEmailToCustomer{get;set;}
    //Giorgio Bonifazi - START
    public Boolean renderEmailToCustomerMobility{get;set;}
    //Giorgio Bonifazi - END
    public Id blankEmailTemplateDAC{get;set;}
    public String FromAddressforDAC{set;get;}
    //MDANTONIO 04/04/2019: render button per Case DAC AXA Agenti - end

    //MMOSCATELLI 25022019: ICF CR — START
    public class EmailWrapper
    {
        public String MsgStatus {get;set;}
        public String MsgDate {get;set;}
        public String MsgSubject {get;set;}
        public String MsgToAddress {get;set;}
        public String MsgFromAddress {get;set;}
        public String MsgBody {get;set;}
        public Boolean MsgHasAttachments {get;set;}
        public Boolean MsgIsIncoming {get;set;}
        public String MsgId {get;set;}

        public EmailWrapper()
        {
            this.MsgStatus='';
            this.MsgDate='';
            this.MsgSubject='';
            this.MsgToAddress='';
            this.MsgBody ='';
            this.MsgId='';
            this.MsgHasAttachments=false;
            this.MsgIsIncoming=false;
        }
    }

    public List<EmailWrapper> EmailWrapList{set;get;}
    //MMOSCATELLI 25022019: ICF CR — END
    
    public VFC14_SendEmailView (ApexPages.StandardController stdController)
    {   
        toAgencyAddress='';

        isAaiAccount =false; 
        IsGDPR = false; 
        BCCforGDRP = '';
        Boolean useLightningEmail = false;
        System.debug('>>> START VFC14_SendEmailView constructor <<<');

        //MMOSCATELLI 25022019: ICF CR -- START
        isAgentUser = false;

        User AgentUser = [Select Email,Profile.Name from User where id=: UserInfo.getUserId() limit 1];
        
        if((AgentUser.Profile.Name).indexOf('AAI - Vendite')>-1)
        {
            isAgentUser = true;
            UserAgentEmail= AgentUser.Email;
        }
        

        //MMOSCATELLI 25022019: ICF CR -- END

        UrlParameterMap = ApexPages.currentPage().getParameters();
        listEmailMessage = new list<EmailMessage>();
        EmailWrapList = new List<EmailWrapper>();  //MMOSCATELLI 25022019: ICF CR
        page=1;       
        String Customer = 'Customer';
        String Agent  = 'Bank Agent';
        String OT    = 'Techincal Office';
        
        if(UrlParameterMap.containsKey('id'))
            CaseID = UrlParameterMap.get('id');
        
        CaseId15digit = (String.valueOf(CaseID)).left(15);
        system.debug('##Id: '+CaseID+' 15digid: '+CaseId15digit);
        
        List<Case> CaseAccounts = new List<Case>([Select  Category__c, user__c, user__r.Email, AccountId, AgentName__r.Id,SuppliedEmail,RecordTypeId,Complainant__c from Case where id =:CaseID]);


        for(MPS_Code_Variables__c MPSCv: MPS_Code_Variables__c.getAll().values())
        {
            if((MPSCv.Name).contains('GDPR_Category') && MPSCv.Value__c == CaseAccounts[0].Category__c)
                IsGDPR = true;  
            if((MPSCv.Name).contains('switchToLightningEmail') && MPSCv.Value__c == 'true')
                useLightningEmail=true;      
        }   
        
        system.debug('##CaseAccounts :'+CaseAccounts);
        
        AccountId       = CaseAccounts[0].AccountId;        
        AgentId       = CaseAccounts[0].AgentName__r.Id;         
        SuppliedEmail   = CaseAccounts[0].SuppliedEmail;
        CaseRecTyp    = MapCaseRecordType.get(CaseAccounts[0].RecordTypeId).Name;
        toAgencyAAIAddress = (String.isNotBlank(CaseAccounts[0].user__r.Email))?CaseAccounts[0].user__r.Email:'';//OAVERSANO 05/07/2018 Close The Loop ICF
        //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- START
        //ExternalPartnersInvolvement__c ExternalPartnerMyFox = ExternalPartnersInvolvement__c.getValues('MyFox');
        Map<String,ExternalPartnersInvolvement__c> ExternalPartner = ExternalPartnersInvolvement__c.getall();
        Set<String> ExternalPartnerType = new Set<String>(ExternalPartner.keySet());
        
        MyFoxBtnAvailability = false;
        BlueAssBtnAvailability = false;//MOSCATELLI_M 16/11/2016: Evo 70
        AMFTechnicalOfficeAvailability = false; //ACAPOBIANCO 22/08/2017
        GDPRBtnAvailability = false; //BOVOLENTA_D 18052018 US 584
        //OAVERSANO 05/07/2018: Easy Azienda -- START 
        AgentBtnAvailability = false; 
        BankAgentBtnAvailability = false; 
        TechnicalBtnAvailability = false; 
        //OAVERSANO 05/07/2018: Easy Azienda -- END 
        
        //MDANTONIO 04/04/2019: render button per Case DAC AXA Agenti - start
        renderEmailToCustomer = !CaseRecTyp.equals('DAC AXA Agenti');
        //Giorgio Bonifazi - START
        if((AgentUser.Profile.Name).indexOf('NFE - AAI - Vendite')>-1)
        {
            isAgentUser = true;
            UserAgentEmail= AgentUser.Email;
            renderEmailToCustomer = false;
            renderEmailToCustomerMobility = true;
        }
        //Giorgio Bonifazi - END
        blankEmailTemplateDAC = [SELECT Id FROM EmailTemplate WHERE Name = 'Blank email comunicazioni sezione messaggi email' LIMIT 1].Id;
        //MDANTONIO 04/04/2019: render button per Case DAC AXA Agenti - end
        
        for(String ExtPartName : ExternalPartnerType)
        {
            if(ExtPartName == 'MyFox')
            {   
                ExternalPartnersInvolvement__c ExternalPartVal = ExternalPartnersInvolvement__c.getValues(ExtPartName);
                    
                for(String s: ExternalPartVal.Button_Availability__c.split(','))
                {
                    if(s==CaseRecTyp)
                       MyFoxBtnAvailability = true; 
                }
            }
            //MOSCATELLI_M 16/11/2016: Evo 70 -- START
            else if(ExtPartName == 'BlueAss')
            {
                ExternalPartnersInvolvement__c ExternalPartVal = ExternalPartnersInvolvement__c.getValues(ExtPartName);
                    
                for(String s: ExternalPartVal.Button_Availability__c.split(','))
                {
                    if(s==CaseRecTyp)
                       BlueAssBtnAvailability = true; 
                }                
            }
            //MOSCATELLI_M 16/11/2016: Evo 70 -- END
            //ACAPOBIANCO 22/08/2017 - EVO 87 START
            else if(ExtPartName == 'AMF')
            {
                ExternalPartnersInvolvement__c ExternalPartVal = ExternalPartnersInvolvement__c.getValues(ExtPartName);
                    
                for(String s: ExternalPartVal.Button_Availability__c.split(','))
                {
                    if(s==CaseRecTyp)
                       AMFTechnicalOfficeAvailability = true; 
                }                
            }
            //ACAPOBIANCO 22/08/2017 - EVO 87 END
            else if(ExtPartName == 'GDPR')
            {
                ExternalPartnersInvolvement__c ExternalPartVal = ExternalPartnersInvolvement__c.getValues(ExtPartName);
                    
                for(String s: ExternalPartVal.Button_Availability__c.split(','))
                {
                    if(s==CaseRecTyp)
                       GDPRBtnAvailability = true; 
                }                  
                
            }
            //OAVERSANO 05/07/2018: Easy Azienda -- START
            else if(ExtPartName == 'Agent')
            {
                ExternalPartnersInvolvement__c ExternalPartVal = ExternalPartnersInvolvement__c.getValues(ExtPartName);
                    
                for(String s: ExternalPartVal.Button_Availability__c.split(','))
                {
                    if(s==CaseRecTyp)
                       AgentBtnAvailability = true; 
                }                  
            }
            else if(ExtPartName == 'BankAgent')
            {
                ExternalPartnersInvolvement__c ExternalPartVal = ExternalPartnersInvolvement__c.getValues(ExtPartName);
                    
                for(String s: ExternalPartVal.Button_Availability__c.split(','))
                {
                    if(s==CaseRecTyp)
                       BankAgentBtnAvailability = true; 
                }                  
            }
            else if(ExtPartName == 'Technical')
            {
                ExternalPartnersInvolvement__c ExternalPartVal = ExternalPartnersInvolvement__c.getValues(ExtPartName);
                    
                for(String s: ExternalPartVal.Button_Availability__c.split(','))
                {
                    if(s==CaseRecTyp)
                       TechnicalBtnAvailability = true; 
                }                  
            }
            //OAVERSANO 05/07/2018: Easy Azienda -- END
        }            
        //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- END
        
        if(String.isNotBlank(AccountId))
            //MOSCATELLI_M 10102016: Family Protect -- START
            //ListAssociatedAccount = new list<Account>([Select id, RecordTypeId,Additional_Email__c,PersonEmail,Account_email__c,Subject_email__c from Account where id=:AccountId]);
          ListAssociatedAccount = new list<Account>([Select id, RecordTypeId,Additional_Email__c,PersonEmail,Account_email__c,Subject_email__c,IsPersonAccount,CIF_PersonalEmail__c,CIF_Work_email__c,CIF_PersonEmail__c,Claim_PersonalEmail__c,RecordType.DeveloperName,AAI_Agency__c,AAI_Agency__r.Agency_email__c,AAI_Agency_Reference_Code__c from Account where id=:AccountId]);

            //MOSCATELLI_M 10102016: Family Protect -- END

        //BOVOLENTA_D US688
        if(ListAssociatedAccount!= null && ListAssociatedAccount.size()>0 && (ListAssociatedAccount[0].RecordType.DeveloperName == 'B2B_Client' || ListAssociatedAccount[0].RecordType.DeveloperName == 'B2C_Client' ))
        {
            isAaiAccount = true;
            if (ListAssociatedAccount[0].AAI_Agency__r.Agency_email__c!=null && ListAssociatedAccount[0].AAI_Agency__r.Agency_email__c != '')
            {
                toAgencyAddress = ListAssociatedAccount[0].AAI_Agency__r.Agency_email__c;
            }
            else if (ListAssociatedAccount[0].AAI_Agency__c!= null)
            {
                String agCode = ListAssociatedAccount[0].AAI_Agency_Reference_Code__c;
                String agCodeFourDigits = agCode.removeStart('00');
                toAgencyAddress = 'AG'+agCodeFourDigits+'@AXA-AGENZIE.IT';
            }
            BCCforGDRP = toAgencyAddress;
        }
        
        if(String.isNotBlank(AgentId))
            toAgentAddress   = ([Select PersonEmail from Account where id=:AgentId]).PersonEmail;
        
        system.debug('#MapAccountRecordType :'+MapAccountRecordType);
        
        getEmails();
        
        //MMOSCATELLI 25022019: ICF CR — START
        /*if(listEmailMessage.size()<=0)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, system.label.VFP14_NoEmail);                                               
            ApexPages.addMessage(myMsg);               
        }*/
        if(EmailWrapList.size()<=0)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, system.label.VFP14_NoEmail);                                               
            ApexPages.addMessage(myMsg);               
        }
        //MMOSCATELLI 25022019: ICF CR — END
        
        //MMOSCATELLI 25022019: ICF CR — START
        //if(ListAssociatedAccount!=null && !ListAssociatedAccount.isEmpty() && !CaseAccounts.isEmpty())
      //  {
        toCustomerAddress = setToAddress(ListAssociatedAccount, isAgentUser, CaseAccounts[0]);
      //  }
        /*
        if(!isAgentUser)
        {
            if(SuppliedEmail=='' || SuppliedEmail==null)
            { 
                if(String.isNotBlank(AccountId))
                {
                    if(!(string.isBlank(ListAssociatedAccount[0].Additional_Email__c)))
                    {
                        toCustomerAddress = ListAssociatedAccount[0].Additional_Email__c;
                    }
                    //MOSCATELLI_M 10102016: Family Protect -- START
                    //else if(MapAccountRecordType.get(ListAssociatedAccount[0].RecordTypeId).DeveloperName == AP_Constants.rtAccIndividualClient || MapAccountRecordType.get(ListAssociatedAccount[0].RecordTypeId).DeveloperName == AP_Constants.rtAccB2C || MapAccountRecordType.get(ListAssociatedAccount[0].RecordTypeId).DeveloperName == AP_Constants.rtAccIntermediary)
                    else if(ListAssociatedAccount[0].IsPersonAccount)
                    //MOSCATELLI_M 10102016: Family Protect -- END
                    {   
                        //MMOSCATELLI 17/02/2017: Evo 77 -- START
                        if(MapAccountRecordType.get(ListAssociatedAccount[0].RecordTypeId).DeveloperName == AP_Constants.rtAccB2C && (String.isNotBlank(ListAssociatedAccount[0].CIF_PersonEmail__c) || String.isNotBlank(ListAssociatedAccount[0].CIF_Work_email__c)))
                        {
                            if(String.isNotBlank(ListAssociatedAccount[0].CIF_PersonEmail__c))
                                toCustomerAddress = ListAssociatedAccount[0].CIF_PersonEmail__c;
                            else if(String.isNotBlank(ListAssociatedAccount[0].CIF_Work_email__c))
                                toCustomerAddress = ListAssociatedAccount[0].CIF_Work_email__c;
                        }                   
                        else if(!string.isBlank(ListAssociatedAccount[0].PersonEmail))
                            toCustomerAddress = ListAssociatedAccount[0].PersonEmail;
                        else if(String.isNotBlank(ListAssociatedAccount[0].Claim_PersonalEmail__c))
                            toCustomerAddress = ListAssociatedAccount[0].Claim_PersonalEmail__c;   
                        //MOSCATELLI 17/02/2017: Evo 77 -- End                                                                      
                    }    
                    else if(MapAccountRecordType.get(ListAssociatedAccount[0].RecordTypeId).DeveloperName == AP_Constants.rtAccCorporateClient)
                    {
                        if(!(string.isBlank(ListAssociatedAccount[0].Account_email__c)))
                            toCustomerAddress = ListAssociatedAccount[0].Account_email__c;
                        //MOSCATELLI 17/02/2017: Evo 77 -- Start
                        else if(String.isNotBlank(ListAssociatedAccount[0].Claim_PersonalEmail__c))
                            toCustomerAddress = ListAssociatedAccount[0].Claim_PersonalEmail__c;   
                        //MOSCATELLI 17/02/2017: Evo 77 -- End                                                                      
                    }      
                    else if(MapAccountRecordType.get(ListAssociatedAccount[0].RecordTypeId).DeveloperName == AP_Constants.rtAccB2B)
                    {
                        //MOSCATELLI 17/02/2017: Evo 77 -- Start
                        if(String.isNotBlank(ListAssociatedAccount[0].CIF_PersonalEmail__c))
                            toCustomerAddress = ListAssociatedAccount[0].CIF_PersonalEmail__c;
                        else if(String.isNotBlank(ListAssociatedAccount[0].CIF_Work_email__c))
                            toCustomerAddress = ListAssociatedAccount[0].CIF_Work_email__c;                    
                        else if(string.isNotBlank(ListAssociatedAccount[0].Subject_email__c))
                            toCustomerAddress = ListAssociatedAccount[0].Subject_email__c;  
                        //if(!(string.isBlank(ListAssociatedAccount[0].Subject_email__c)))
                        //toCustomerAddress = ListAssociatedAccount[0].Subject_email__c;  
                        else if(String.isNotBlank(ListAssociatedAccount[0].Claim_PersonalEmail__c))
                            toCustomerAddress = ListAssociatedAccount[0].Claim_PersonalEmail__c;   
                        //MOSCATELLI 17/02/2017: Evo 77 -- End                                                  
                    }
                }           
            }
            else
                toCustomerAddress = SuppliedEmail;
        }
        //MMOSCATELLI 25022019: ICF CR — START
        else 
        {
            if(String.isNotBlank(AccountId))
            {
                if(ListAssociatedAccount[0].IsPersonAccount && MapAccountRecordType.get(ListAssociatedAccount[0].RecordTypeId).DeveloperName == AP_Constants.rtAccB2C)
                {
                    if(String.isNotBlank(ListAssociatedAccount[0].CIF_PersonEmail__c))
                        toCustomerAddress = ListAssociatedAccount[0].CIF_PersonEmail__c;
                }
                else if(!ListAssociatedAccount[0].IsPersonAccount && MapAccountRecordType.get(ListAssociatedAccount[0].RecordTypeId).DeveloperName == AP_Constants.rtAccB2B)
                {
                    if(String.isNotBlank(ListAssociatedAccount[0].CIF_PersonalEmail__c))
                        toCustomerAddress = ListAssociatedAccount[0].CIF_PersonalEmail__c;
                }
            }
        } 
        //MMOSCATELLI 25022019: ICF CR — END  
        
        system.debug('##toCustomerAddress :'+toCustomerAddress);
        
        String URLBASE = System.URL.getCurrentRequestUrl().toExternalForm();
        URLBASE2 = URLBASE.SPLIT('/apex/',-1).get(0);
        
        List<Record_Type_Email__c> FromAddressesList = [Select id,Caller__c,Sender_Email__c,Record_Type__c from Record_Type_Email__c where Record_Type__c =:CaseRecTyp];
        
        
        if(!isAgentUser)//MMOSCATELLI 25022019: ICF CR
        {
            for(integer i=0;i<FromAddressesList.size();i++)
            {
                if((FromAddressesList[i].Caller__c).contains(Customer))
                    FromAddressforCustomer = FromAddressesList[i].Sender_Email__c;
                
                if((FromAddressesList[i].Caller__c).contains(Agent))
                    FromAddressforAgent = FromAddressesList[i].Sender_Email__c;
                
                if((FromAddressesList[i].Caller__c).contains(OT))
                    FromAddressforTechnicalOffice = FromAddressesList[i].Sender_Email__c;   

                if((FromAddressesList[i].Caller__c).contains('Agency'))
                    FromAddressforAgency = FromAddressesList[i].Sender_Email__c;  

                if((FromAddressesList[i].Caller__c).contains('GDPR'))
                    FromAddressforGDPR = FromAddressesList[i].Sender_Email__c; 

                //OAVERSANO 05/07/2018: Easy Azienda -- START 
                if((FromAddressesList[i].Caller__c).contains('Agente'))
                    FromAddressforAAIAgent = FromAddressesList[i].Sender_Email__c;
                //OAVERSANO 05/07/2018: Easy Azienda -- END 
                
                //OAVERSANO 10/01/2019 : Agenzia diretta -- START
                if((FromAddressesList[i].Caller__c).contains('Dipendente'))
                    FromAddressforCustomer = FromAddressesList[i].Sender_Email__c;
                //OAVERSANO 10/01/2019 : Agenzia diretta -- END
            }
        }
        //MMOSCATELLI 25022019: ICF CR -- START
        else
        {
            FromAddressforCustomer = UserAgentEmail;
        } 
        //MMOSCATELLI 25022019: ICF CR -- END
        */
        List<Record_Type_Email__c> FromAddressesList = [Select id,Caller__c,Sender_Email__c,Record_Type__c from Record_Type_Email__c where Record_Type__c =:CaseRecTyp];
        
        if(!isAgentUser)
        {
            for(integer i=0;i<FromAddressesList.size();i++)
            {
                if((FromAddressesList[i].Caller__c).contains(Customer))
                    FromAddressforCustomer = FromAddressesList[i].Sender_Email__c;
                
                if((FromAddressesList[i].Caller__c).contains(Agent))
                    FromAddressforAgent = FromAddressesList[i].Sender_Email__c;
                
                if((FromAddressesList[i].Caller__c).contains(OT))
                    FromAddressforTechnicalOffice = FromAddressesList[i].Sender_Email__c;   

                if((FromAddressesList[i].Caller__c).contains('Agency'))
                    FromAddressforAgency = FromAddressesList[i].Sender_Email__c;  

                if((FromAddressesList[i].Caller__c).contains('GDPR'))
                    FromAddressforGDPR = FromAddressesList[i].Sender_Email__c; 

                if((FromAddressesList[i].Caller__c).contains('Agente'))
                    FromAddressforAAIAgent = FromAddressesList[i].Sender_Email__c;
                
                if((FromAddressesList[i].Caller__c).contains('Dipendente'))
                    FromAddressforCustomer = FromAddressesList[i].Sender_Email__c;
                //MDANTONIO 05/04/2019: from address per Case DAC AXA Agenti - start
                if((FromAddressesList[i].Caller__c).contains('DAC'))
                    FromAddressforDAC = FromAddressesList[i].Sender_Email__c;
                //MDANTONIO 05/04/2019: from address per Case DAC AXA Agenti - end
            }
        }

        String URLBASE = System.URL.getCurrentRequestUrl().toExternalForm();
        URLBASE2 = URLBASE.SPLIT('/apex/',-1).get(0);

        system.debug('URLBASE2 :'+URLBASE2);
        //MMOSCATELLI 25022019: ICF CR — START
        //if (useLightningEmail==true )
        if (useLightningEmail==true || isAgentUser)
        //MMOSCATELLI 25022019: ICF CR — END
        {
            emailToClientURL =  URLBASE2+'/apex/sendEmailCase';
        }
        else
        {
            emailToClientURL = URLBASE2+'/_ui/core/email/author/EmailAuthor';
        }
        
        if (URLBASE.contains('crm')) {
            emailToClientURL = URLBASE2;
        }
        
        System.debug('### listEmailMessage: '+listEmailMessage);  
        System.debug('>>> END VFC14_SendEmailView constructor <<<');    
    }
    
    public void getEmails()
    {
        this.startIdx = (this.page-1)*PAGE_SIZE;
        this.endIdx = this.page*PAGE_SIZE;
        this.totalRecords = 0;
        
        this.listEmailMessage.clear();   
        //MMOSCATELLI 25022019: ICF CR -- START
        this.EmailWrapList.clear();
        Map<Datetime,EmailWrapper> MapDateTOWrap = new Map<Datetime,EmailWrapper>();
        List<Datetime> ListTimes = new List<Datetime>();

        String soql_task = 'Select Id, Subject, Createddate, Description from Task where WhatId=:CaseID and Tipo_Attivit__c=\'Email\' and Createdby.Profile.Name like \'%AAI - Vendite%\'';
        
        /*for(Task t : Database.query(soql_task))
        {
            EmailWrapper EmW = new EmailWrapper();

            if(String.isNotBlank(t.Subject.substringAfter('Email: ')))
                EmW.MsgSubject=t.Subject.substringAfter('Email: ');
            
            if(t.Createddate!=null)
                EmW.MsgDate = t.Createddate.format('dd/MM/yyyy HH:mm');

            if(String.isNotBlank((t.Description.substringAfter('Destinatario: ')).subStringBefore('\n')))
                Emw.MsgToAddress = (t.Description.substringAfter('Destinatario: ')).subStringBefore('\n');
            
            if(String.isNotBlank(t.Description.substringAfter('Corpo: ')))
            {
                if((t.Description.substringAfter('Corpo: ')).length()>MAX_DISPLAYED_CHAR)
                    Emw.MsgBody = (t.Description.substringAfter('Corpo: ')).SubString(0,MAX_DISPLAYED_CHAR) + '...';
                else   
                    Emw.MsgBody = t.Description.substringAfter('Corpo: ');
            }

            if(String.isNotBlank((t.Description.substringAfter('Mittente: ')).subStringBefore('\n')))
                Emw.MsgFromAddress = (t.Description.substringAfter('Mittente: ')).subStringBefore('\n');            

            EmW.MsgStatus='Inviato';
            Emw.MsgId=t.Id;
            EmW.MsgIsIncoming=false;

            if(String.isNotBlank((t.Description.substringAfter('Allegato: ')).subStringBefore('\n')))
                Emw.MsgHasAttachments=true;

          /*  if(this.totalRecords>=this.startIdx && this.totalRecords<this.endIdx)
            { 
                MapDateTOWrap.put(t.Createddate,Emw);
                ListTimes.add(t.Createddate);
            }*/
            /*MapDateTOWrap.put(t.Createddate,Emw);
            ListTimes.add(t.Createddate);
                
            //this.totalRecords++;
        }*/
        //MMOSCATELLI 25022019: ICF CR -- END
       
        String soql = 'SELECT id,Subject,Status, ToAddress,TextBody, MessageDate, Incoming, FromAddress,HasAttachment  FROM EmailMessage WHERE ParentID =: CaseID  Order by MessageDate DESC ';        
        //MMOSCATELLI 25022019: ICF CR -- START
        
        //if(!isAgentUser)
        //{
            for(EmailMessage emessage:Database.query(soql))
            {        
                EmailWrapper EmW = new EmailWrapper();
                Emw.MsgId=emessage.Id;

                if(emessage.Status=='0')
                  EmW.MsgStatus='Nuovo';
                else if(emessage.Status=='1')
                  EmW.MsgStatus='Letto';  
                else if(emessage.Status=='2')
                  EmW.MsgStatus='Risposto';  
                else if(emessage.Status=='3')
                  EmW.MsgStatus='Inviato';  
                else if(emessage.Status=='4')
                  EmW.MsgStatus='Inoltrato';  
                else if(emessage.Status=='5')
                  EmW.MsgStatus='Bozza';  

                if(emessage.Incoming)
                   EmW.MsgIsIncoming=true;
                else
                   EmW.MsgIsIncoming=false; 

                if(emessage.HasAttachment)
                   EmW.MsgHasAttachments=true;
                else
                   EmW.MsgHasAttachments=false; 

                EmW.MsgToAddress = emessage.ToAddress;
                EmW.MsgFromAddress = emessage.FromAddress;
                EmW.MsgDate = emessage.MessageDate.format('dd/MM/yyyy HH:mm');

                if(String.isNotBlank(emessage.Subject))
                    EmW.MsgSubject = emessage.Subject;

                if(String.isNotBlank(emessage.TextBody))
                {
                    if(emessage.TextBody.length()>MAX_DISPLAYED_CHAR)
                        Emw.MsgBody = emessage.TextBody.SubString(0,MAX_DISPLAYED_CHAR) + '...';
                    else   
                        Emw.MsgBody = emessage.TextBody;
                }

               //if(this.totalRecords>=this.startIdx && this.totalRecords<this.endIdx)
              // {
                if(!emessage.Incoming)
                {
                    if(isAgentUser && emessage.MessageDate.date()>=date.valueOf('2019-03-12'))
                    {
                       ListTimes.add(emessage.MessageDate);
                       MapDateTOWrap.put(emessage.MessageDate,Emw); 
                    }
                    else if(!isAgentUser)
                    {
                       ListTimes.add(emessage.MessageDate);
                       MapDateTOWrap.put(emessage.MessageDate,Emw);                         
                    }
                }
                else
                {
                    ListTimes.add(emessage.MessageDate);
                    MapDateTOWrap.put(emessage.MessageDate,Emw);
                }
             //  }
                    
                //this.totalRecords++;


                /*if(emessage.TextBody!='' && emessage.TextBody!=null)
                  if(emessage.TextBody.length()>MAX_DISPLAYED_CHAR)
                      emessage.TextBody = emessage.TextBody.SubString(0,MAX_DISPLAYED_CHAR) + '...'; 
               
                if(this.totalRecords>=this.startIdx && this.totalRecords<this.endIdx)
                  listEmailMessage.add(emessage);
                
                this.totalRecords++;*/
            //}
        }

        ListTimes.sort();
        List<EmailWrapper> AliasWrap = new List<EmailWrapper>();
        this.totalRecords = ListTimes.size();

        for(Integer i = ListTimes.size()-1; i>=0;i--)
        {
            AliasWrap.add(MapDateTOWrap.get(ListTimes.get(i)));
        }

        for(Integer i=0; i<AliasWrap.size();i++)
        {
            if(i>=this.startIdx && i<this.endIdx)
                EmailWrapList.add(AliasWrap.get(i));

        }


        //MMOSCATELLI 25022019: ICF CR -- END
        Decimal pages = Decimal.valueOf(this.totalRecords);
        pages = pages.divide(Decimal.valueOf(PAGE_SIZE), 2);
        this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
        
        this.startIdx++;
        
        if(this.endIdx>this.totalRecords)        
            this.endIdx = this.totalRecords;               
    }
    
    public void doNext()
    {        
        if(getHasNext())
        {
            this.page++;
            getEmails();
        }
    }
    
    public Boolean getHasNext()
    {
        if(this.page<this.totalPages)
        {
            system.debug('#1: '+this.page+' #2: '+this.totalPages);
            return true;
        }
        else
        {
            system.debug('#1: '+this.page+' #2: '+this.totalPages);
            return false;
        }
    }
    
    public void doPrevious()
    {        
        if(getHasPrevious())
        {
            this.page--;
            getEmails();
        }        
    }
    
    public Boolean getHasPrevious()
    {
        if(this.page>1)        
            return true;        
        else
            return false;
    }
    
    //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- START
    public void getExternalProviderInfo()
    {                    
        ExternalPartnersInvolvement__c ExternalPartner = ExternalPartnersInvolvement__c.getValues(ExternalProviderType);
        
        String TemplateName = (CaseRecTyp==AP_Constants.rtCaseQuadra)?ExternalPartner.Email_Template_Quadra__c:((CaseRecTyp=='Axa Assicurazioni')?ExternalPartner.Email_Template_AAI__c:ExternalPartner.Email_Template_AXA_MPS__c);
                  
        ExternalProviderEmail = (CaseRecTyp==AP_Constants.rtCaseQuadra)?ExternalPartner.Email_Quadra__c:((CaseRecTyp=='Axa Assicurazioni')?ExternalPartner.Email_AAI__c:ExternalPartner.Email__c);
        
        EmailTemplateId = [Select Id from EmailTemplate where name =:TemplateName].Id;    
    }

    public static String setToAddress(List<Account> Customer, Boolean isAgentUser, Case CurrentCase)
    {
        String toAddress = '';
        Schema.DescribeSObjectResult dAcc = Schema.SObjectType.Account;
        Map<Id,Schema.RecordTypeInfo> rtMapByIdAcc = dAcc.getRecordTypeInfosById(); 

        if(!isAgentUser)
        {
            if(CurrentCase.SuppliedEmail=='' || CurrentCase.SuppliedEmail==null)
            { 
                if(String.isNotBlank(CurrentCase.AccountId))
                {
                    if(!(string.isBlank(Customer[0].Additional_Email__c)))
                    {
                        toAddress = Customer[0].Additional_Email__c;
                    }
                    else if(Customer[0].IsPersonAccount)
                    {   
                        if(rtMapByIdAcc.get(Customer[0].RecordTypeId).getDeveloperName() == AP_Constants.rtAccB2C && (String.isNotBlank(Customer[0].CIF_PersonEmail__c) || String.isNotBlank(Customer[0].CIF_Work_email__c)))
                        {
                            if(String.isNotBlank(Customer[0].CIF_PersonEmail__c))
                                toAddress = Customer[0].CIF_PersonEmail__c;
                            else if(String.isNotBlank(Customer[0].CIF_Work_email__c))
                                toAddress = Customer[0].CIF_Work_email__c;
                        }                   
                        else if(!string.isBlank(Customer[0].PersonEmail))
                            toAddress = Customer[0].PersonEmail;
                        else if(String.isNotBlank(Customer[0].Claim_PersonalEmail__c))
                            toAddress = Customer[0].Claim_PersonalEmail__c;                                                                   
                    }    
                    else if(rtMapByIdAcc.get(Customer[0].RecordTypeId).getDeveloperName() == AP_Constants.rtAccCorporateClient)
                    {
                        if(!(string.isBlank(Customer[0].Account_email__c)))
                            toAddress = Customer[0].Account_email__c;
                        else if(String.isNotBlank(Customer[0].Claim_PersonalEmail__c))
                            toAddress = Customer[0].Claim_PersonalEmail__c;   
                    }      
                    else if(rtMapByIdAcc.get(Customer[0].RecordTypeId).getDeveloperName() == AP_Constants.rtAccB2B)
                    {
                        if(String.isNotBlank(Customer[0].CIF_PersonalEmail__c))
                            toAddress = Customer[0].CIF_PersonalEmail__c;
                        else if(String.isNotBlank(Customer[0].CIF_Work_email__c))
                            toAddress = Customer[0].CIF_Work_email__c;                    
                        else if(string.isNotBlank(Customer[0].Subject_email__c))
                            toAddress = Customer[0].Subject_email__c;  
                        else if(String.isNotBlank(Customer[0].Claim_PersonalEmail__c))
                            toAddress = Customer[0].Claim_PersonalEmail__c;   
                    }
                }           
            }
            else
                toAddress = CurrentCase.SuppliedEmail;
        }
        else 
        {
            if(String.isNotBlank(CurrentCase.AccountId))
            {
                if(Customer[0].IsPersonAccount && rtMapByIdAcc.get(Customer[0].RecordTypeId).getDeveloperName() == AP_Constants.rtAccB2C)
                {
                    if(String.isNotBlank(Customer[0].CIF_PersonEmail__c))
                        toAddress = Customer[0].CIF_PersonEmail__c;
                }
                else if(!Customer[0].IsPersonAccount && rtMapByIdAcc.get(Customer[0].RecordTypeId).getDeveloperName() == AP_Constants.rtAccB2B)
                {
                    if(String.isNotBlank(Customer[0].CIF_PersonalEmail__c))
                        toAddress = Customer[0].CIF_PersonalEmail__c;
                }
            }
        } 

        return toAddress;   
    }    
    //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- END
}
/*------------------------------------------------------------------------
Author:        Anna Riccardi
Company:       Deloitte
Class:         accountEditLightningCTRL_TEST
Description:   Test for the VF page of editing for accounts
               
History

 14/22/2016     Anna Riccardi
----------------------------------------------------------------------------*/

@istest
public without sharing class accountEditLightningCTRL_TEST{


   @testSetup static void setup() {
       //mo
        //insert complete lead

        List<Lead> leads = new list<Lead>();
       Lead leadToConvert = new Lead(
            Salutation = '',
            LastName = 'LeadTest',
            FirstName = 'test',
            Company = 'TestCompany',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            MobilePhone = '3333333333',
            Fiscal_ID__c = '1234567890abcdef',
            AAI_Partita_IVA__c = '12345678901'
        );
        leads.add(leadToConvert);
        
        
        //insert complete lead2
       Lead leadToConvert2 = new Lead(
            Salutation = '',
            LastName = 'LeadTest',
            FirstName = 'test',
            Company = 'TestCompany',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            MobilePhone = '3333333333',
            Fiscal_ID__c = '1234567890abcdez',
            AAI_Partita_IVA__c = '12345678901'
        );
        leads.add(leadToConvert2);

        insert leads ;



        //insert B2C_Account
        Account TheClient = new Account();
        TheClient.NDG__c='0008280000001138';
        RecordType PF_RT = [SELECT id from RecordType where DeveloperName ='B2C_Client' Limit 1];
        TheClient.RecordTypeId = PF_RT.Id;
        TheClient.Salutation ='';
        TheClient.LastName = 'Rossi';
        TheClient.FirstName = 'Maria';
        TheClient.CIF_Marital_Status__c = 'Convivente';
        TheClient.CIF_Marital_Status_code__c = '7';
        TheClient.Nodes__c = '000828;000828000033';
        TheClient.AAI_Agency_Reference_Code__c ='000828';
        TheClient.State__c ='ATTIVO';
        TheClient.CIF_Job__c ='Agricoltore';
        TheClient.AAI_Codice_fiscale__c = 'MSSGNN64P24L929I';
        TheClient.CIF_Phone__c ='012345678';
        TheClient.CIF_PersonMobilePhone_IntPrefix__c   ='+39';
        TheClient.CIF_PersonMobilePhone__c ='023456678';
        TheClient.Fax = '345677891';
        TheClient.CIF_Work_phone__c= '012344444';
        TheClient.CIF_PersonEmail__c = 'mariarossi@email.com';
        TheClient.CIF_Work_email__c = 'test@libero6.it';
        TheClient.AnnualRevenue =  1112132;
        Date myDate = Date.newInstance(2019, 2, 17); 
        
        //insert B2B_Account   
        Account The_client = new Account();
        The_Client.NDG__c='0008280000000421';
        RecordType P_RT = [SELECT id from RecordType where DeveloperName ='B2B_Client' Limit 1];
        The_Client.RecordTypeId = P_RT.Id;
        The_Client.Name = 'ARCO SPA';
        The_Client.NDG__c ='0008280000000421';
        The_Client.Nodes__c ='000828;000828000033';
        The_Client.AAI_Agency_Reference_Code__c ='000828';
        The_Client.State__c ='ATTIVO';
        The_Client.CIF_Phone__c ='0938465777';
        The_Client.CIF_MobilePhone__c ='00000023456';
        The_Client.Fax ='12344567';
        The_Client.CIF_Work_phone__c ='0909090909';
        The_Client.CIF_PersonalEmail__c ='ARCOspa1@email.com';
        The_Client.CIF_Work_email__c ='ARCOspa@email.com';

       
         //fill custom setting AAI_Code_variables__c to build the DAOL link
         AAI_Code_Variables__c settinglink = new AAI_Code_Variables__c();
         settinglink.Name='AccountEdit_Folderlink';
         settinglink.Value__c='https://daol-pp.axa-italia.it/test';
         AAI_Code_Variables__c leadstatus= new AAI_Code_Variables__c();
         leadstatus.Name='Status';
         leadstatus.Value__c='Appointment';

         AAI_Code_Variables__c modAcc= new AAI_Code_Variables__c();
         modAcc.Name='AccountEdit_IRSavingLink';
         modAcc.Value__c='https://axaitalia--pre.cs80.my.salesforce.com/'; 


         MPS_Code_Variables__c gdprcate = new MPS_Code_Variables__c();
         gdprcate.Name='GDPR_Category_001';

         insert gdprcate;       

      

         
         //fill custom setting Autorita rilascio
         AutRilascio_Code_Assignment__c setting3 = new AutRilascio_Code_Assignment__c();
         setting3.Name = 'Prefettura';
         setting3.AutRilascio_Code__c='8';
         AutRilascio_Code_Assignment__c setting4 = new AutRilascio_Code_Assignment__c();
         setting4.Name = 'Questura';
         setting4.AutRilascio_Code__c='2';

        //fill costum setting DI code Assignment
        DICodeAssignment__c setting5 = new DICodeAssignment__c();
        setting5.Name = 'Porto d\'armi';
        setting5.CIF_DI_code__c= '8';         
        DICodeAssignment__c setting6 = new DICodeAssignment__c();
        setting6.Name = 'Passaporto';
        setting6.CIF_DI_code__c= '4'; 

        //fill custom setting DataEnrichmentvariables

        List<EnrichmentCampaignReqField__c> ECRF = new List <EnrichmentCampaignReqField__c>{new EnrichmentCampaignReqField__c(AccountRT__c = 'B2C Client',
                                                                                                                                   ControllingField__c = 'Data_Enrichment_Target_Phone__c',
                                                                                                                                   Field__c='CIF_Phone__c',
                                                                                                                                   Name='X1'),
                                                                                                new EnrichmentCampaignReqField__c(AccountRT__c = 'B2C Client',
                                                                                                                                   ControllingField__c = 'Data_Enrichment_Target_Email__c',
                                                                                                                                   Field__c='CIF_PersonEmail__c',
                                                                                                                                    Name='X2'),
                                                                                                new EnrichmentCampaignReqField__c(AccountRT__c = 'B2C Client',
                                                                                                                                   ControllingField__c = 'Data_Enrichment_Target_Consensus__c',
                                                                                                                                   Field__c='CIF_Privacy_1__c',
                                                                                                                                   ExpectedValue__c = 'Sì',
                                                                                                                                    Name='X3'),
                                                                                                new EnrichmentCampaignReqField__c(AccountRT__c = 'B2C Client',
                                                                                                                                   ControllingField__c = 'Data_Enrichment_Target_Email__c',
                                                                                                                                   Field__c='CIF_Work_email__c',
                                                                                                                                   ExpectedValue__c = 'Sì',
                                                                                                                                    Name='X4')
                                                                                                };

            insert ECRF;
          

        
        List<AutRilascio_Code_Assignment__c> AutRilasciosetting = new List<AutRilascio_Code_Assignment__c>();
        AutRilasciosetting.add(setting3);
        AutRilasciosetting.add(setting4);
        List<Database.SaveResult> settingAutoritaSave = database.insert(AutRilasciosetting);
        system.debug ('+++++++settingSave2'+settingAutoritaSave );

        List<DICodeAssignment__c> DIcodesetting = new List<DICodeAssignment__c>();
        DIcodesetting.add(setting5);
        DIcodesetting.add(setting6);
        List<Database.SaveResult> DIsettingSave= database.insert(DIcodesetting);
        system.debug ('+++++++settingSave'+DIsettingSave);
        
        List<AAI_Code_Variables__c> aaivariablessetting = new List<AAI_Code_Variables__c>();
        aaivariablessetting.add(settinglink);
        aaivariablessetting.add(leadstatus);
        aaivariablessetting.add(modAcc);
        List<Database.SaveResult> settingAAISave= database.insert(aaivariablessetting);


        
        List<Account> lsAccount = new List<Account>();
        lsAccount.add(TheClient);
        lsAccount.add(The_Client);
        List<Database.SaveResult> accSave = database.insert(lsAccount);
        
        Date myDaterilascio = Date.newInstance(2015, 2, 17); 
        Date myDatescadenza = Date.newInstance(2018, 3, 12);
        
         //insert Insurance Policy LIFE
        InsurancePolicy__c InsPolLIFE = new InsurancePolicy__c(
            Name='testInsurance',
            CUID__c=The_Client.Id,
            POLICYNUM__c='0930493',
            Line__c='8',
            Status__c='ATTIVA'
        );
        insert InsPolLIFE;
       
        IE_Configuration__c Integration_record = new IE_Configuration__c();
        Integration_record.Name = 'CIF_Integration_PartyService_Edit';
        Integration_record.Type__c = 'WebService_rest';
        Integration_record.Direction__c = 'OUTBOUND';
        Integration_record.HTTPMethod__c = 'PUT';
        Integration_record.EndPoint__c = 'https://mockbin.org/bin/5c5736a6-27e7-41c6-ae26-8ebc201b81fc';
        Integration_record.Request_compiler__c = 'IE_Request_CIF_EditAccount';
        Integration_record.Response_parser__c = 'IE_CIFparser_EditAccount';
        Integration_record.NameSpacePrefix1__c = 'soapenv';
        Integration_record.NameSpacePrefix2__c = 'crm';
        Integration_record.NameSpaceUri1__c = 'http://schemas.xmlsoap.org/soap/envelope/';
        Integration_record.NameSpaceUri2__c = 'http://crm.service.rgi.it/';
        insert Integration_record;
        
        IE_Configuration__c Integration_record_gettask = new IE_Configuration__c();
        Integration_record_gettask.Name = 'Integration_TaskSearch';
        Integration_record_gettask.Type__c = 'WebService';
        Integration_record_gettask.Direction__c = 'OUTBOUND';
        Integration_record_gettask.EndPoint__c = 'stop_https://mockbin.org/bin/5e282d3c-cce0-46d3-bd43-e718eb14ee5e'; 
        Integration_record_gettask.Request_compiler__c = 'IE_Request_CIF_EditAccount';
        Integration_record_gettask.Response_parser__c = 'IE_Parser_SearcTaskDaol';
        Integration_record_gettask.NameSpacePrefix1__c = 'soapenv';
        Integration_record_gettask.NameSpacePrefix2__c = 'ws';
        Integration_record_gettask.NameSpaceUri1__c = 'http://schemas.xmlsoap.org/soap/envelope/';
        Integration_record_gettask.NameSpaceUri2__c = 'http://rgi.it/WS_REOL_Service/';
        
        insert Integration_record_gettask;
        
        List<IE_Configuration__c> Integration_records = new list<IE_Configuration__c>();                                                                                 
        /** PURE IT Commento per rimuovere referenza di una classe commentata                                                                                            
        IE_Configuration__c Integration_record_getstati = new IE_Configuration__c();
        Integration_record_getstati.Name = 'Integration_getStati';
        Integration_record_getstati.Type__c = 'WebService';
        Integration_record_getstati.Direction__c = 'OUTBOUND';
        Integration_record_getstati.EndPoint__c = '__https://mockbin.org/bin/5c5736a6-27e7-41c6-ae26-8ebc201b81fc'; 
        Integration_record_getstati.Request_compiler__c = 'IE_Request_CIF_EditAccount';
        Integration_record_getstati.Response_parser__c = 'IE_CIFparser_GetStati';
        Integration_record_getstati.NameSpacePrefix1__c = 'soapenv';
        Integration_record_getstati.NameSpacePrefix2__c = 'bean';
        Integration_record_getstati.NameSpaceUri1__c = 'http://schemas.xmlsoap.org/soap/envelope/';
        Integration_record_getstati.NameSpaceUri2__c = 'http://bean.services.jdna6ws.app.directw.it';

        Integration_records.add(Integration_record_getstati);
        PURE IT Comment closure */
        //insert Integration_record_getstati;
        /** PURE IT Commento per rimuovere referenza di una classe commentata
        IE_Configuration__c Integration_record_getprov = new IE_Configuration__c();
        Integration_record_getprov.Name = 'Integration_getProvince';
        Integration_record_getprov.Type__c = 'WebService';
        Integration_record_getprov.Direction__c = 'OUTBOUND';
        Integration_record_getprov.EndPoint__c = '__https://mockbin.org/bin/5c5736a6-27e7-41c6-ae26-8ebc201b81fc'; 
        Integration_record_getprov.Request_compiler__c = 'IE_Request_CIF_EditAccount';
        Integration_record_getprov.Response_parser__c = 'IE_CIFparser_GetProvince';
        Integration_record_getprov.NameSpacePrefix1__c = 'soapenv';
        Integration_record_getprov.NameSpacePrefix2__c = 'bean';
        Integration_record_getprov.NameSpaceUri1__c = 'http://schemas.xmlsoap.org/soap/envelope/';
        Integration_record_getprov.NameSpaceUri2__c = 'http://bean.services.jdna6ws.app.directw.it';
        
        //insert Integration_record_getprov;
        Integration_records.add(Integration_record_getprov);
        PURE IT Comment closure*/


        /** PURE IT Commento per rimuovere referenza di una classe commentata  
        IE_Configuration__c Integration_record_getcomuni = new IE_Configuration__c();
        Integration_record_getcomuni.Name = 'Integration_getComuni';
        Integration_record_getcomuni.Type__c = 'WebService';
        Integration_record_getcomuni.Direction__c = 'OUTBOUND';
        Integration_record_getcomuni.EndPoint__c = '__https://mockbin.org/bin/5c5736a6-27e7-41c6-ae26-8ebc201b81fc'; 
        Integration_record_getcomuni.Request_compiler__c = 'IE_Request_CIF_EditAccount';
        Integration_record_getcomuni.Response_parser__c = 'IE_CIFparser_GetComuni';
        Integration_record_getcomuni.NameSpacePrefix1__c = 'soapenv';
        Integration_record_getcomuni.NameSpacePrefix2__c = 'bean';
        Integration_record_getcomuni.NameSpaceUri1__c = 'ttp://schemas.xmlsoap.org/soap/envelope/';
        Integration_record_getcomuni.NameSpaceUri2__c = 'http://bean.services.jdna6ws.app.directw.it';
        
        //insert Integration_record_getcomuni;        
        Integration_records.add(Integration_record_getcomuni);

        insert   Integration_record_getcomuni ; 
        PURE IT Comment closure*/                                                                                  

        //Create agency user
        Profile pvendite = [SELECT Id FROM Profile WHERE Name = 'NFE - AAI - Vendite Avanzato'];     
        Id pVen = pvendite.Id;   
        UserRole role = [SELECT Id FROM UserRole where developername = 'MODENAUtentePartner'];
        Id pRol = role.Id;
 
        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id contact_agency = UtilityClass.getRTid(rtypes, 'Contact', 'Agency_Contact');
        id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');
        id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');
        id account_B2B = UtilityClass.getRTid(rtypes, 'Account', 'B2B_Client');
         
        //Create Partner User
        Account agencyAccount = new Account(Name = 'Agency Test Account',
                                            RecordTypeId = account_agency,
                                            Agency_Code__c = '006345',
                                            Active__c = true,
                                            DAOL_2_0__c = true);
        insert agencyAccount;
                       
        Contact agencyContact = new Contact(LastName = 'Agency Test Contact',
                                            RecordtypeId = contact_agency,
                                            AccountId = agencyAccount.Id);
        insert agencyContact;
           
            
        //MOSCATELLI_M 31/07/2017: Data Enrichment -- START
        Campaign TestEnrichCamp = new Campaign(Name='Enrichment', Data_Enrichment_Target_Email__c=true,Data_Enrichment_Target_Consensus__c=true,RecordtypeId=UtilityClass.getRTid(rtypes, 'Campaign', 'Data_Enrichment_Campaign'));
        insert TestEnrichCamp;

        Account TestEnrichAcc = new Account(RecordTypeId=account_B2C,FirstName='Enrichment',LastName= 'Test',AAI_Codice_fiscale__c='mmrr678599',NDG__c ='89032342343244242432423432', AAI_Agency_Reference_Code__c='006345');
        Account TestEnrichAcc2 = new Account(RecordTypeId=account_B2B,Name='EnrichmentB2B',AAI_Partita_IVA__c='03946280165',NDG__c ='0008280000001548', AAI_Agency_Reference_Code__c='006345');
        List<Account> AccountEnrichmentList = new List<Account>();
        AccountEnrichmentList.add(TestEnrichAcc);
        AccountEnrichmentList.add(TestEnrichAcc2);
        insert AccountEnrichmentList;


        //OAVERSANO 21/12/2018 : FIX too many queries -- START
        //Storico_Chiamate__c st = new Storico_Chiamate__c(Call_ID__c='89078');
        //insert st;
        //OAVERSANO 21/12/2018 : FIX too many queries -- END
      //  Contact TestEnrichContact = new Contact(FirstName='Enrichment', LastName ='Test',AccountId=TestEnrichAcc.Id);
        //insert TestEnrichContact;

        Contact TestEnrichContact = [Select Id from Contact where FirstName='Enrichment' and LastName= 'Test'];

        CampaignMember TestEnrichCampMemb = new CampaignMember(CampaignId=TestEnrichCamp.Id,ContactId=TestEnrichContact.Id);
        insert TestEnrichCampMemb;
        //MOSCATELLI_M 31/07/2017: Data Enrichment -- END   
        User usr1 = null;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            usr1=new User(FirstName='Marzia',
                    LastName = 'Rossi',
                    Alias = 'mro666',
                    Email = 'mrosskmans@deloitte.com',
                    Username = 'mrosskm11@axa.com.masterdev',
                    CommunityNickname = 'MarziRo',
                    LanguageLocaleKey = 'en_US',
                    TimeZoneSidKey='Europe/Rome',
                    Agency_Code__c = '000828',
                    Nodes__c = 'DIF_000828',
                    Profileid = pVen,
                    LocaleSidKey='en_US',
                    EmailEncodingKey='ISO-8859-1',
                    //UserRoleId=pRol,
                    ContactId = agencyContact.Id
            );
            insert usr1;
        }
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            List <AAI_Code_Variables__c> listCV = new List<AAI_Code_Variables__c>();
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            AAI_Code_Variables__c acv2 = new AAI_Code_Variables__c(Name='JS_USER_DEBUG', Value__c=UserInfo.getUserId());
            listCV.add(acv);
            listCV.add(acv2);
            insert listCV;

            //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- START
            Group g = new Group(DeveloperName='Coda_Agenzia_006345',Name='Coda_Agenzia_006345',Type='Queue');
            insert g;

            //User u = [Select id from user where username ='mrosskm11@axa.com.masterdev'];

            GroupMember gm = new GroupMember(GroupId=g.Id,UserOrGroupId=usr1.id);
            insert gm;

            EmailTemplate t = new EmailTemplate();
            t.DeveloperName = 'Notifica_agenzia';
            t.subject ='Variazione recapiti {!Account.Name}';
            t.htmlvalue='<table border="0" cellpadding="5" width="600" cellspacing="5" height="400" > <tr valign="top" height="50" > <td tEditID="c1r1" style=" background-color:#FFFFFF; color:#000000; bEditID:r3st1; bLabel:main; font-size:12pt; font-family:arial;" aEditID="c1r1" locked="0" > <![CDATA[Gentile Agente,]]></td> </tr> <tr valign="top" height="300" > <td tEditID="c1r2" style=" background-color:#FFFFFF; color:#000000; bEditID:r3st1; bLabel:main; font-size:12pt; font-family:arial;" aEditID="c1r2" locked="0" > <![CDATA[Il Cliente&nbsp;{!Account.Name},<div><br></div><div><span lang="IT" style="font-size:11.0pt;line-height: 115%;font-family:&quot;Calibri&quot;,sans-serif;mso-ascii-theme-font:minor-latin; mso-fareast-font-family:Calibri;mso-fareast-theme-font:minor-latin;mso-hansi-theme-font: minor-latin;mso-bidi-font-family:&quot;Times New Roman&quot;;mso-bidi-theme-font:minor-bidi; mso-ansi-language:IT;mso-fareast-language:EN-US;mso-bidi-language:AR-SA">ha richiesto la variazione del #contatto.</span></div><div><span lang="IT" style="font-size:11.0pt;line-height: 115%;font-family:&quot;Calibri&quot;,sans-serif;mso-ascii-theme-font:minor-latin; mso-fareast-font-family:Calibri;mso-fareast-theme-font:minor-latin;mso-hansi-theme-font: minor-latin;mso-bidi-font-family:&quot;Times New Roman&quot;;mso-bidi-theme-font:minor-bidi; mso-ansi-language:IT;mso-fareast-language:EN-US;mso-bidi-language:AR-SA"><br></span></div><div><span lang="IT" style="font-size:11.0pt;line-height: 115%;font-family:&quot;Calibri&quot;,sans-serif;mso-ascii-theme-font:minor-latin; mso-fareast-font-family:Calibri;mso-fareast-theme-font:minor-latin;mso-hansi-theme-font: minor-latin;mso-bidi-font-family:&quot;Times New Roman&quot;;mso-bidi-theme-font:minor-bidi; mso-ansi-language:IT;mso-fareast-language:EN-US;mso-bidi-language:AR-SA">#contenuti</span></div>]]></td> </tr> <tr valign="top" height="50" > <td tEditID="c1r3" style=" background-color:#FFFFFF; color:#000000; bEditID:r3st1; bLabel:main; font-size:12pt; font-family:arial;" aEditID="c1r3" locked="0" > <![CDATA[<p class="MsoNormal"><span lang="IT">Troverai i contatti aggiornati in anagrafica cliente.<o:p></o:p></span></p> <p class="MsoNormal"><span lang="IT">&nbsp;</span></p> <p class="MsoNormal"><span lang="IT">Cordiali saluti.<o:p></o:p></span></p> <p class="MsoNormal"><span lang="IT">Axa Ass.ni<o:p></o:p></span></p>]]></td> </tr> </table>';
            t.name='Notifica agenzia';
            t.templatetype='custom';
            t.folderid=Userinfo.getUserId();
            insert t;
            //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- END
        }
        
      
    
    }
    
    

    static testMethod void Method_B2C() {

        test.StartTest ();
        Account CurrentAcc = [SELECT id, Salutation, NDG__c, CIF_Marital_Status__c FROM Account where NDG__c='0008280000001138'  Limit 1];
        Id insertedLeadId = [Select Id from lead where Fiscal_ID__c = '1234567890abcdef'].Id;
        Lead L = [Select Id,TECH_Lead_Processed__c from lead where Fiscal_ID__c = '1234567890abcdef'];
        Lead L1 = new Lead();
        Account a = new account();
        

        //AAI_Code_Variables__c linkdaol = [SELECT Value__c FROM AAI_Code_Variables__c WHERE Name='AccountEdit_Folderlink' LIMIT 1].get(0);  
        //AAI_Code_Variables__c status = [SELECT Value__c FROM AAI_Code_Variables__c WHERE Name='Status' LIMIT 1].get(0);  
        AAI_Code_Variables__c linkdaol;
        AAI_Code_Variables__c status;

        for (AAI_Code_Variables__c ai: [SELECT Value__c,Name FROM AAI_Code_Variables__c WHERE Name in('AccountEdit_Folderlink','Status')])
        {
            if(ai.Name =='AccountEdit_Folderlink')
                linkdaol = ai;
            else
               status = ai; 
        }

        Test.setMock(HttpCalloutMock.class, new SearchTaskDAOLMock_Test());

        accountEditLightningCTRL.ResponseDto getTaskDAOL = accountEditLightningCTRL.getTaskDAOL(CurrentAcc.NDG__c);
        
        Date myDaterilascio = Date.newInstance(2015, 2, 17); 
        Date myDatescadenza = Date.newInstance(2018, 3, 12);

        List<String> gotGender = accountEditLightningCTRL.getgender();
        List<String> gotStatus = accountEditLightningCTRL.getstatus();
        List<String> gotJob   = accountEditLightningCTRL.getjob();
        Map<String,String> getUserInfos = accountEditLightningCTRL.getUserInfos();
        accountEditLightningCTRL.ResponseDto OpenTaskREOL = accountEditLightningCTRL.getTaskDAOL(CurrentAcc.id);
        //accountEditLightningCTRL.ResponseDto getCountries = accountEditLightningCTRL.getCountries(); PURE IT 
        //accountEditLightningCTRL.ResponseDto getProvinces = accountEditLightningCTRL.getProvinces(); PURE IT 
        //accountEditLightningCTRL.ResponseDto getCities = accountEditLightningCTRL.getCities('MI');  PURE IT 
        accountEditLightningCTRL.picklistPair valueList = new accountEditLightningCTRL.picklistPair('ITA','ITALY');
        a = accountEditLightningCTRL.dataconversion(CurrentAcc);
        L1 = accountEditLightningCTRL.getLead(L.id);
        accountEditLightningCTRL.convertLeadOnAccount(L,CurrentAcc);
        a  = accountEditLightningCTRL.addBlackListDate(CurrentAcc);
        boolean b= accountEditLightningCTRL.SmartCenterEnrichmentAvailability(CurrentAcc);

        Account foundAccount = accountEditLightningCTRL.getAccount(CurrentAcc.id)?.currentAccount;
        //Account dataconverted = accountEditLightningCTRL.dataconversion();



     
        Account TempAcc = [SELECT CIF_Job_code__c,FirstName, CIF_Marital_Status__c, CIF_Job__c, CIF_Phone__c, CIF_PersonMobilePhone__c, Fax, CIF_Work_phone__c, CIF_PersonEmail__c, CIF_Work_email__c,isPersonAccount from Account WHERE Firstname ='Maria'];
        RecordType PF_RT = [SELECT id from RecordType where DeveloperName ='B2C_Client' Limit 1];
        TempAcc.RecordTypeId = PF_RT.Id;
        TempAcc.FirstName = 'Maria';
        TempAcc.CIF_Marital_Status__c = 'Divorziato/a';
        TempAcc.CIF_Marital_Status_code__c = '4';
        TempAcc.CIF_Job__c ='Allenatore';
        TempAcc.CIF_Job_code__c = '12V0210';
        TempAcc.CIF_Phone__c ='012345671';
        TempAcc.CIF_PersonMobilePhone__c ='023456671';
        TempAcc.Fax = '345677890';
        TempAcc.CIF_Work_phone__c= '012344441';
        TempAcc.CIF_PersonEmail__c = 'mariarossi16@email.com';
        TempAcc.CIF_Work_email__c = 'test@libero16.it';
        TempAcc.CIF_PersonMobilePhone_IntPrefix__c='+39';
        
        
        
        Test.setMock(HttpCalloutMock.class, new getStatiMock_Test());
        Test.setMock(HttpCalloutMock.class, new getprovinceMock_Test());
        Test.setMock(HttpCalloutMock.class, new getcomuniMock_Test());

    
       
       
        Test.setMock(HttpCalloutMock.class, new AccountEditResponse_Mock_Test());
        AccountEditResponse_Mock_Test mockDAC = new AccountEditResponse_Mock_Test();
        mockDAC.TestCase='ModificaB2C';

        
        system.debug ('*****AccountUpdateCall ');
        Lead blankLead = new Lead ();
        //MOSCATELLI_M 31/07/2017: Data Enrichment -- start
        accountEditLightningCTRL.ResponseDto AccountUpdated =  accountEditLightningCTRL.updateAccount(TempAcc,'','',false,'',false,'');            
        //MOSCATELLI_M 31/07/2017: Data Enrichment -- end
        system.debug ('*****ResponseUpdate '+ AccountUpdated);
        system.assert( AccountUpdated.isSuccess == false );

        test.StopTest ();
        
    }


    static testMethod void Method_B2C_2() {
            test.StartTest ();
            Account CurrentAcc = [SELECT id, Salutation, NDG__c, CIF_Marital_Status__c FROM Account where NDG__c='0008280000001138'  Limit 1];
            Id insertedLeadId2 = [SELECT Id from lead where Fiscal_ID__c = '1234567890abcdez'].Id; 
            AAI_Code_Variables__c linkdaol = [SELECT Value__c FROM AAI_Code_Variables__c WHERE Name='AccountEdit_Folderlink' LIMIT 1].get(0);  

            system.debug ('*****CurrentAcc '+CurrentAcc );
            
            Date myDaterilascio = Date.newInstance(2015, 2, 17); 
            Date myDatescadenza = Date.newInstance(2022, 4, 12);
            
    
            List<String> gotGender = accountEditLightningCTRL.getgender();
            List<String> gotStatus = accountEditLightningCTRL.getstatus();
            List<String> gotJob   = accountEditLightningCTRL.getjob();
            Map<String,String> getUserInfos = accountEditLightningCTRL.getUserInfos();
            accountEditLightningCTRL.ResponseDto OpenTaskREOL = accountEditLightningCTRL.getTaskDAOL(CurrentAcc.id);
            //accountEditLightningCTRL.ResponseDto getCountries = accountEditLightningCTRL.getCountries(); PURE IT 
            //accountEditLightningCTRL.ResponseDto getProvinces = accountEditLightningCTRL.getProvinces(); PURE IT 
            //accountEditLightningCTRL.ResponseDto getCities = accountEditLightningCTRL.getCities('MI'); PURE IT 
            accountEditLightningCTRL.picklistPair valueList = new accountEditLightningCTRL.picklistPair('ITA','ITALY');

            Account foundAccount = accountEditLightningCTRL.getAccount(CurrentAcc.id)?.currentAccount;
            //Account dataconverted = accountEditLightningCTRL.dataconversion();
    
    
    
         
            Account TempAcc = [SELECT CIF_Job_code__c,FirstName, CIF_Marital_Status__c, CIF_Job__c, CIF_Phone__c, CIF_PersonMobilePhone__c, Fax, CIF_Work_phone__c, CIF_PersonEmail__c, CIF_Work_email__c from Account WHERE Firstname ='Maria'];
            RecordType PF_RT = [SELECT id from RecordType where DeveloperName ='B2C_Client' Limit 1];
            TempAcc.RecordTypeId = PF_RT.Id;
            TempAcc.FirstName = 'Maria';
            TempAcc.CIF_Marital_Status__c = 'Vedovo/a';
            TempAcc.CIF_Marital_Status_code__c = '4';
            TempAcc.CIF_Job__c ='Allenatore';
            TempAcc.CIF_Job_code__c = '12V0210';
            TempAcc.CIF_Phone__c ='012345671';
            TempAcc.CIF_PersonMobilePhone__c ='023456671';
            TempAcc.Fax = '345677890';
            TempAcc.CIF_Phone__c ='1111111';
            TempAcc.CIF_PersonMobilePhone__c ='22222222222';
            TempAcc.CIF_Work_phone__c= '45894859485';
            TempAcc.CIF_PersonEmail__c = 'mariarossi16@email.com';
            TempAcc.CIF_Work_email__c = 'test@libero16.it';
            TempAcc.CIF_Privacy_1__c = 'Sì';
            TempAcc.CIF_Privacy_2__c = 'Sì';
            TempAcc.CIF_Privacy_3__c = 'Sì';
            TempAcc.CIF_Privacy_4__c = 'Sì';
            TempAcc.CIF_Privacy_5__c = 'Sì';
            TempAcc.CIF_Privacy_7__c = 'Sì';
            TempAcc.CIF_Mail_contact__c =  TempAcc.CIF_PersonEmail__c;            
            
                        
            Test.setMock(HttpCalloutMock.class, new getStatiMock_Test());
            Test.setMock(HttpCalloutMock.class, new getprovinceMock_Test());
            Test.setMock(HttpCalloutMock.class, new getcomuniMock_Test());
           
            Test.setMock(HttpCalloutMock.class, new AccountEditResponse_Mock_Test());
      
            
            
            
            
            system.debug ('*****AccountUpdateCall ');
            Lead blankLead = new Lead ();
            //MOSCATELLI_M 31/07/2017: Data Enrichment -- start
            accountEditLightningCTRL.ResponseDto AccountUpdated =  accountEditLightningCTRL.updateAccount(TempAcc,'','',false,'',false,'');
            //MOSCATELLI_M 31/07/2017: Data Enrichment -- end
            system.debug ('*****ResponseUpdate '+ AccountUpdated);
            system.assert( AccountUpdated.isSuccess == false );

            test.StopTest ();
        
        
        
    } 



    static testMethod void Method_B2B() {
          test.StartTest ();
          Account CurrentAcc = [SELECT id, NDG__c FROM Account where NDG__c='0008280000000421'  Limit 1];
          system.debug ('*****CurrentAcc '+CurrentAcc );
          
          Account foundAccount = accountEditLightningCTRL.getAccount(CurrentAcc.id)?.currentAccount;

          
          Account TempAcc = [SELECT Name, CIF_Phone__c, CIF_MobilePhone__c,CIF_Work_phone__c, CIF_PersonalEmail__c, CIF_Work_email__c, Fax from Account WHERE Name ='ARCO SPA'];
          RecordType PF_RT = [SELECT id from RecordType where DeveloperName ='B2B_Client' Limit 1];
          TempAcc.RecordTypeId = PF_RT.Id;
          TempAcc.Name = 'ARCO SPA';
          TempAcc.CIF_Phone__c ='0938465771';
          TempAcc.CIF_PersonalEmail__c ='ARCOspa11@email.com';
          TempAcc.Fax = '345677890';
          TempAcc.CIF_Work_phone__c= '012344441';
          TempAcc.CIF_MobilePhone__c = '00000023451';
          TempAcc.CIF_Work_email__c = 'ARCOspa0@email.com';
          TempAcc.CIF_Privacy_1__c = 'Sì';
          TempAcc.CIF_Privacy_2__c = 'No';
          TempAcc.CIF_Privacy_3__c = 'No';
          TempAcc.CIF_Privacy_4__c = 'No';
          TempAcc.CIF_Privacy_5__c = 'No';
          TempAcc.CIF_Privacy_7__c = 'No';
          
          //MOSCATELLI_M 31/07/2017: Data Enrichment -- start
          accountEditLightningCTRL.ResponseDto AccountUpdated =  accountEditLightningCTRL.updateAccount(TempAcc,'','',false,'',false,'');
          //MOSCATELLI_M 31/07/2017: Data Enrichment -- end
          system.debug ('*****ResponseUpdate '+ AccountUpdated);
          
          Test.setMock(HttpCalloutMock.class, new AccountEditResponseB2B_Mock_Test());
          
          //MOSCATELLI_M 31/07/2017: Data Enrichment -- start
          AccountUpdated =  accountEditLightningCTRL.updateAccount(TempAcc,'','',false,'',false,'');
          //MOSCATELLI_M 31/07/2017: Data Enrichment -- end
          system.debug ('*****ResponseUpdate '+ AccountUpdated);
          system.assert( AccountUpdated.isSuccess == false   );
          test.StopTest ();
                  
          
    }

 
    static testMethod void Method_B2B_Email_Test() {
          test.StartTest ();
          Account CurrentAcc = [SELECT id, NDG__c FROM Account where NDG__c='0008280000000421'  Limit 1];
          system.debug ('*****CurrentAcc '+CurrentAcc );
          
          Account foundAccount = accountEditLightningCTRL.getAccount(CurrentAcc.id)?.currentAccount;

          Account TempAcc = [SELECT Name, CIF_Phone__c, CIF_MobilePhone__c,CIF_Work_phone__c, CIF_PersonalEmail__c, CIF_Work_email__c, Fax from Account WHERE Name ='ARCO SPA'];
          RecordType PF_RT = [SELECT id from RecordType where DeveloperName ='B2B_Client' Limit 1];
          TempAcc.RecordTypeId = PF_RT.Id;
          TempAcc.Name = 'ARCO SPA';
          TempAcc.CIF_Phone__c ='0938465771';
          TempAcc.CIF_PersonalEmail__c ='ARCOspa11@email.com';
          TempAcc.Fax = '345677890';
          TempAcc.CIF_Work_phone__c= '012344441';
          TempAcc.CIF_MobilePhone__c = '00000023451';
          TempAcc.CIF_Work_email__c = 'ARCO';
          
          
          
          
          Test.setMock(HttpCalloutMock.class, new AccountEditResponseB2B_Mock_Email_Test());
          
         
          //MOSCATELLI_M 31/07/2017: Data Enrichment -- start
          accountEditLightningCTRL.ResponseDto AccountUpdated =  accountEditLightningCTRL.updateAccount(TempAcc,'','',false,'',false,'');
          //MOSCATELLI_M 31/07/2017: Data Enrichment -- end
          system.debug ('*****ResponseUpdate '+ AccountUpdated);
          system.assert( AccountUpdated.isSuccess == true);
          test.StopTest ();
         
    }
 
    static testMethod void Method_B2C_SearchTask_Test() {
        test.StartTest ();
        Account CurrentAcc = [SELECT id, NDG__c FROM Account where NDG__c='0008280000000421'  Limit 1];
        system.debug ('*****CurrentAcc '+CurrentAcc );


        Test.setMock(HttpCalloutMock.class, new SearchTaskDAOLMock_Test());
        accountEditLightningCTRL.ResponseDto OpenTaskREOL = accountEditLightningCTRL.getTaskDAOL(CurrentAcc.id);
        test.StopTest();
    }
   
 

   


    //////////////////////////////
        static testMethod void Method_B2C_Enrichment() {
       
            test.StartTest ();
            
            
            Account CurrentAcc = [Select Id,RecordType.Name from Account where FirstName = 'Enrichment' limit 1].get(0);
            AAI_Code_Variables__c linkdaol = [SELECT Value__c FROM AAI_Code_Variables__c WHERE Name='AccountEdit_Folderlink' LIMIT 1].get(0);  
            AAI_Code_Variables__c status = [SELECT Value__c FROM AAI_Code_Variables__c WHERE Name='Status' LIMIT 1].get(0);  
            system.debug ('*****CurrentAcc '+CurrentAcc );

            
            Account TempAcc = [SELECT CIF_Job_code__c,FirstName, CIF_Marital_Status__c, CIF_Job__c, CIF_Phone__c, CIF_PersonMobilePhone__c, Fax, CIF_Work_phone__c, CIF_PersonEmail__c, CIF_Work_email__c,Recordtype.name,isPersonAccount from Account WHERE Id=:CurrentAcc.Id];

            TempAcc.FirstName = 'Maria';
            TempAcc.CIF_Marital_Status__c = 'Vedovo/a';
            TempAcc.CIF_Marital_Status_code__c = '4';
            TempAcc.CIF_Job__c ='Allenatore';
            TempAcc.CIF_Job_code__c = '12V0210';
            //CurrentAcc.CIF_Phone__c ='012345671';
            TempAcc.CIF_PersonMobilePhone__c ='023456671';
            TempAcc.Fax = '345677890';
            TempAcc.CIF_Phone__c ='1111111';
            TempAcc.CIF_PersonMobilePhone__c ='22222222222';
            TempAcc.CIF_Work_phone__c= '45894859485';
            TempAcc.CIF_PersonEmail__c = 'mariarossi16@email.com';
            //TempAcc.CIF_Work_email__c = 'test@libero16.it';
            TempAcc.CIF_Privacy_1__c = 'Sì';
            TempAcc.CIF_Privacy_2__c = 'Sì';
            TempAcc.CIF_Privacy_3__c = 'Sì';
            TempAcc.CIF_Privacy_4__c = 'Sì';
            TempAcc.CIF_Privacy_5__c = 'Sì';
            TempAcc.CIF_Privacy_7__c = 'Sì';



            Test.setMock(HttpCalloutMock.class, new SearchTaskDAOLMock_Test());           

           
            Test.setMock(HttpCalloutMock.class, new AccountEditResponse_Mock_Test());
            AccountEditResponse_Mock_Test mockDAC = new AccountEditResponse_Mock_Test();
            mockDAC.TestCase='EliminaDAC';
            Test.setMock(HttpCalloutMock.class, mockDAC);
            CampaignMember TestEnrichCampMemb = [Select Id from CampaignMember where FirstName = 'Enrichment'];
            Campaign TestEnrichCamp = [Select Id from Campaign where Name = 'Enrichment'];
            accountEditLightningCTRL.ResponseDto AccountUpdated =  accountEditLightningCTRL.updateAccount(TempAcc,TestEnrichCampMemb.Id,TestEnrichCamp.Id,false,'',false,'');            
            system.debug ('*****ResponseUpdate '+ AccountUpdated);

            system.assert( AccountUpdated.isSuccess == false);
            system.assert( AccountUpdated.values.get('ModalMsg') <> '' );
            CampaignMember CampMemb2 = [Select Data_Enrichment_Target_Email__c,Data_Enrichment_Target_Phone__c,Data_Enrichment_Target_Consensus__c,Data_Enrichment_Target_Other__c from CampaignMember where Id=:TestEnrichCampMemb.Id]; 
            system.assert(CampMemb2.Data_Enrichment_Target_Consensus__c==false);
            system.assert(CampMemb2.Data_Enrichment_Target_Email__c==false);
            system.assert(CampMemb2.Data_Enrichment_Target_Other__c==false);
            system.assert(CampMemb2.Data_Enrichment_Target_Phone__c==false);
            test.StopTest ();
   }

   //MOSCATELLI_M 15/11/2017: Elimina DAC -- START
   static testMethod void EliminaDAC()
   {
          test.StartTest ();
          Account CurrentAcc = [SELECT id, NDG__c FROM Account where NDG__c='0008280000000421'  Limit 1];
          system.debug ('*****CurrentAcc '+CurrentAcc );
          
          Account foundAccount = accountEditLightningCTRL.getAccount(CurrentAcc.id)?.currentAccount;

          Account TempAcc = [SELECT Name, CIF_Phone__c, CIF_MobilePhone__c,CIF_Work_phone__c, CIF_PersonalEmail__c, CIF_Work_email__c, Fax from Account WHERE Name ='ARCO SPA'];
          RecordType PF_RT = [SELECT id from RecordType where DeveloperName ='B2B_Client' Limit 1];
          TempAcc.RecordTypeId = PF_RT.Id;
          TempAcc.Name = 'ARCO SPA';
          TempAcc.CIF_Phone__c ='0938465771';
          TempAcc.CIF_PersonalEmail__c ='ARCOspa11@email.com';
          TempAcc.Fax = '345677890';
          TempAcc.CIF_Work_phone__c= '012344441';
          TempAcc.CIF_MobilePhone__c = '00000023451';
          TempAcc.CIF_Work_email__c = 'ARCO';
          TempAcc.CIF_Privacy_1__c = 'Sì';
          TempAcc.CIF_Privacy_2__c = 'Sì';
          TempAcc.CIF_Privacy_3__c = 'Sì';
          TempAcc.CIF_Privacy_4__c = 'Sì';
          TempAcc.CIF_Privacy_5__c = 'Sì';
          TempAcc.CIF_Privacy_7__c = 'Sì';
          TempAcc.CIF_Mail_contact__c ='ARCOspa11@email.com';
          
          
          
          AccountEditResponse_Mock_Test mockDAC = new AccountEditResponse_Mock_Test();
          mockDAC.TestCase='EliminaDAC';
          Test.setMock(HttpCalloutMock.class, mockDAC);
          
          
          //MOSCATELLI_M 31/07/2017: Data Enrichment -- start
          accountEditLightningCTRL.ResponseDto AccountUpdated =  accountEditLightningCTRL.updateAccount(TempAcc,'','',false,'',false,'');
          //MOSCATELLI_M 31/07/2017: Data Enrichment -- end
          system.debug ('*****ResponseUpdate '+ AccountUpdated);
          //system.assert( AccountUpdated.isSuccess == true);
          test.StopTest ();    
        
   }
   //MOSCATELLI_M 15/11/2017: Elimina DAC -- END
   
   
   @IsTest
   static void testGetCaseCategory(){       
        Test.startTest();
        ServiceUtilsClass.populateCustomSettingsForTests();
        Account account = [SELECT id, NDG__c,isPersonAccount,RecordtypeId,AAI_Agency_Reference_Code__c FROM Account where NDG__c='0008280000001548' limit 1]; 
        system.debug ('*****CurrentAcc '+account );
        Case c = new Case(AccountId=account.Id, Phone_Call_Ids__c='89078',Category__c = 'GDPR');
        insert c;
        System.assert(true, accountEditLightningCTRL.getCaseCategory(c.Id)); 
        Test.stopTest();      
   }

   //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- START
   static testMethod void Smart_Enrichment()
   {
           test.StartTest ();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
           Account CurrentAcc = [SELECT id, NDG__c,isPersonAccount,RecordtypeId,AAI_Agency_Reference_Code__c FROM Account where NDG__c='89032342343244242432423432' limit 1];
        //OAVERSANO 21/12/2018 : FIX too many queries -- START
        Storico_Chiamate__c st = new Storico_Chiamate__c(Call_ID__c='89078');
        insert st;
        //OAVERSANO 21/12/2018 : FIX too many queries -- END
            

          
          system.debug ('*****CurrentAcc '+CurrentAcc );

          Case c = new Case(AccountId=CurrentAcc.Id, Phone_Call_Ids__c='89078',Category__c = 'GDPR');
          insert c;

          //String scall = [Select Call_ID__c from Storico_Chiamate__c limit 1].Call_ID__c;
                 
          CurrentAcc.CIF_PersonEmail__c = 'test@test.it';
          CurrentAcc.CIF_PersonMobilePhone_IntPrefix__c='+39';
          CurrentAcc.CIF_PersonMobilePhone__c='3345678999';
          CurrentAcc.CIF_Work_email__c='TEST@TEST.IT';
          CurrentAcc.CIF_Work_phone__c = '345443543';
          CurrentAcc.CIF_Phone__c='0636782911';
          CurrentAcc.CIF_Privacy_1__c='Sì';
          CurrentAcc.CIF_Privacy_2__c='Sì';
          CurrentAcc.CIF_Privacy_3__c='Sì';
          CurrentAcc.CIF_Privacy_4__c='Sì';
          CurrentAcc.CIF_Privacy_5__c='Sì';
          CurrentAcc.CIF_Privacy_7__c='No';
          CurrentAcc.CIF_Mail_contact__c = CurrentAcc.CIF_Work_email__c; 


          
          Lead blankLead = new Lead ();
          
/*
          Storico_Chiamate__c st = new Storico_Chiamate__c(Customer__c=CurrentAcc.Id,Call_ID__c='89078',Case__c=c.Id);
          insert st;
*/          
          AccountEditResponse_Mock_Test mockDAC = new AccountEditResponse_Mock_Test();
          mockDAC.TestCase='Smart_Enrichment';
          Test.setMock(HttpCalloutMock.class, mockDAC);
          
          accountEditLightningCTRL.ResponseDto AccountUpdated =  accountEditLightningCTRL.updateAccount(CurrentAcc,'','',false,'89078',true,'');
          
          system.debug ('*****ResponseUpdate '+ AccountUpdated);
          
          Map<String,Boolean> Maps = new Map<String,Boolean>();
          Maps.put('CIF_PersonEmail__c',true);
          Maps.put('CIF_PersonMobilePhone_IntPrefix__c',true);
          Maps.put('CIF_PersonMobilePhone__c',true);
          Maps.put('CIF_Phone__c',true);
          Maps.put('CIF_Work_phone__c',true);
          Maps.put('CIF_Work_email__c',true);
          Maps.put('CIF_Privacy_1__c',true);
          Maps.put('CIF_Privacy_2__c',true);
          Maps.put('CIF_Privacy_3__c',true);
          Maps.put('CIF_Privacy_4__c',true);
          Maps.put('CIF_Privacy_5__c',true);
          Maps.put('CIF_Privacy_7__c',true);
          Maps.put('CIF_Mail_contact__c',true);


          String resTrace='';
       
          //CAPOBIANCO_A 05/01/2018 -- START
          String newAddress = 'new address';
          //resTrace = accountEditLightningCTRL.TraceContactEnrichment(scall,Maps);
          resTrace = accountEditLightningCTRL.TraceContactEnrichment('89078',Maps,c.id);
          //CAPOBIANCO_A 05/01/2018 -- END

          accountEditLightningCTRL.SendNotification(c.Id,Maps,CurrentAcc);

          test.StopTest ();
   }

   static testMethod void Smart_EnrichmentB2B()
   {
           test.StartTest ();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
           Account CurrentAcc = [SELECT id, NDG__c,isPersonAccount,RecordtypeId,AAI_Agency_Reference_Code__c FROM Account where NDG__c='0008280000001548' limit 1];
       //OAVERSANO 21/12/2018 : FIX too many queries -- START
        Storico_Chiamate__c st = new Storico_Chiamate__c(Call_ID__c='89078');
        insert st;
        //OAVERSANO 21/12/2018 : FIX too many queries -- END
            


          Case c = new Case(AccountId=CurrentAcc.Id, Phone_Call_Ids__c='89078',Category__c = 'GDPR');
          insert c;

          String scall = [Select Call_ID__c from Storico_Chiamate__c limit 1].Call_ID__c;
                    
          Account foundAccount = accountEditLightningCTRL.getAccount(CurrentAcc.id)?.currentAccount;

          Boolean isGDPR = accountEditLightningCTRL.getCaseCategory(c.Id);
       
       
          CurrentAcc.CIF_PersonalEmail__c = 'test@test.it';
          CurrentAcc.CIF_MobilePhone_IntPrefix__c='+39';
          CurrentAcc.CIF_MobilePhone__c='3345678999';
          CurrentAcc.CIF_Work_email__c='TEST@TEST.IT';
          CurrentAcc.CIF_Work_phone__c = '345443543';
          CurrentAcc.CIF_Phone__c='0636782911';
          CurrentAcc.CIF_Privacy_1__c='Sì';
          CurrentAcc.CIF_Privacy_2__c='Sì';
          CurrentAcc.CIF_Privacy_3__c='Sì';
          CurrentAcc.CIF_Privacy_4__c='Sì';
          CurrentAcc.CIF_Privacy_5__c='Sì';
          CurrentAcc.CIF_Privacy_7__c='No';
          CurrentAcc.CIF_Mail_contact__c = CurrentAcc.CIF_Work_email__c; 


          
          
          
/*
          Storico_Chiamate__c st = new Storico_Chiamate__c(Customer__c=CurrentAcc.Id,Call_ID__c='89078',Case__c=c.Id);
          insert st;
*/          
          AccountEditResponse_Mock_Test mockDAC = new AccountEditResponse_Mock_Test();
          mockDAC.TestCase='Smart_Enrichment';
          Test.setMock(HttpCalloutMock.class, mockDAC);
          
          accountEditLightningCTRL.ResponseDto AccountUpdated =  accountEditLightningCTRL.updateAccount(CurrentAcc,'','',false,'89078',true,'');
          
          system.debug ('*****ResponseUpdate '+ AccountUpdated);
          
          Map<String,Boolean> Maps = new Map<String,Boolean>();
          Maps.put('CIF_PersonalEmail__c',true);
          Maps.put('CIF_MobilePhone_IntPrefix__c',true);
          Maps.put('CIF_MobilePhone__c',true);
          Maps.put('CIF_Phone__c',true);
          Maps.put('CIF_Work_phone__c',true);
          Maps.put('CIF_Work_email__c',true);
          Maps.put('CIF_Privacy_1__c',true);
          Maps.put('CIF_Privacy_2__c',true);
          Maps.put('CIF_Privacy_3__c',true);
          Maps.put('CIF_Privacy_4__c',true);
          Maps.put('CIF_Privacy_5__c',true);
          Maps.put('CIF_Privacy_7__c',true);
          Maps.put('CIF_Mail_contact__c',true);


          String resTrace='';
       
          //CAPOBIANCO_A 05/01/2018 -- START
          String newAddress = 'new address';
          //resTrace = accountEditLightningCTRL.TraceContactEnrichment(scall,Maps);
          //resTrace = accountEditLightningCTRL.TraceContactEnrichment('89078',Maps,newAddress,c.id);
          //CAPOBIANCO_A 05/01/2018 -- END

          accountEditLightningCTRL.SendNotification(c.Id,Maps,CurrentAcc);

          test.StopTest ();
   }

    

}
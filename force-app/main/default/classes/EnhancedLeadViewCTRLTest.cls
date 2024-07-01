// /*------------------------------------------------------------------------
// Author:        Veronica Chianura
// Company:       Deloitte
// Class:         EnhancedLeadViewCTRLTest
// Description:   Test
               // VF Page: 
// History

 // 26/01/2016 
 // ---------------------------------------------------------------------------*/

@istest
public without sharing class EnhancedLeadViewCTRLTest{ 

 @testSetup static void setup() {
     Profile profilocorrente = [SELECT Id FROM Profile WHERE Name = 'AAI - Marketing Avanzato'];   
     Profile AdminProfile = [SELECT Id FROM Profile WHERE Name  IN ('Amministratore del Sistema', 'System Administrator') ];   
     Id pcor = profilocorrente.Id;   
     UserRole role = [SELECT Id FROM UserRole where name = 'AXA Assicurazioni'];
     Id pRol = role.Id;
                 
        User usr00828=new User(FirstName='Agente00828',
                           LastName = 'TESTUSER00', 
                           Alias = 'mree00', 
                           Email = 'mreekmans00@deloitte.com', 
                           Username = 'mreekm00@axa.com.masterdev', 
                           CommunityNickname = 'MartiRe00', 
                           LanguageLocaleKey = 'en_US',
                           TimeZoneSidKey='Europe/Rome',
                           Agency_Code__c = '000828',
                           Nodes__c = 'DIF_000828',
                           Profileid = pcor,
                           LocaleSidKey='en_US',
                           EmailEncodingKey='ISO-8859-1',
                           UserRoleId=pRol
                          );
                          // insert usr00828;
                          
        User usr000828=new User(FirstName='Agente000828',
                           LastName = 'TESTUSER000', 
                           Alias = 'mree000', 
                           Email = 'mreekmans000@deloitte.com', 
                           Username = 'mreekm000@axa.com.masterdev', 
                           CommunityNickname = 'MartiRe000', 
                           LanguageLocaleKey = 'en_US',
                           TimeZoneSidKey='Europe/Rome',
                           Agency_Code__c = '000828',
                           Nodes__c = 'DIF_000828',
                           Profileid = pcor,
                           LocaleSidKey='en_US',
                           EmailEncodingKey='ISO-8859-1',
                           UserRoleId=pRol
                           );
                          
                          
        User usrForInsert=new User(FirstName='Agente000828',
                           LastName = 'TESTUSER000', 
                           Alias = 'mree001', 
                           Email = 'mreekmans001@deloitte.com', 
                           Username = 'mreekm001@axa.com.masterdev', 
                           CommunityNickname = 'MartiRe001', 
                           LanguageLocaleKey = 'en_US',
                           TimeZoneSidKey='Europe/Rome',
                           Profileid = AdminProfile.Id,
                           LocaleSidKey='en_US',
                           EmailEncodingKey='ISO-8859-1',
                           UserRoleId=pRol
                          );                          // insert usr000828;
     
     System.runAs(new User(Id=UserInfo.getUserId())){
        List<User> myUsrList = new List<User>();
        myUsrList.add(usrForInsert);
        myUsrList.add(usr00828);
        myUsrList.add(usr000828);
        insert MyUsrList;
        list<Group> listGroup = [Select id from group where developername = 'Coda_Agenzia_000828'];
        if (listGroup.isempty()){
            Group g = new Group(Type='Queue', Name='Coda Agenzia 000828',developername ='Coda_Agenzia_000828');
            insert g;
            QueueSObject q = new QueueSObject(SobjectType='Lead', QueueId=g.Id);
            insert q;

            GroupMember member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = g.Id;
            insert member;
        }else
        {
            GroupMember member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = listGroup[0].Id;
            insert member;
        }
    }
     
     
     
     System.runAs(usrForInsert){
    list<Lead> leadList = new list<Lead>();
    //CAPOBIANCO_A 05/01/2018 -- START
    //Id idLdRt = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Auto').getRecordTypeId();
    Id idLdRt = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead AXA Assicurazioni').getRecordTypeId();
    //CAPOBIANCO_A 05/01/2018 -- END
     Lead ld1 = new Lead (
        FirstName = 'LeadTest',
        LastName = 'test',
        Email = 'lead@mail.test',
        Phone = '0333333333',
        MobilePhone = '3333333333',
        Fiscal_ID__c = '123456789012345P',
        Agency_Code__c = '000828',
        Provincia_di_nascita__c = 'MI',
        Birth_Place__c = 'Milano',
        Gender__c = 'Maschio',
        Street = 'Cadorna',
        City = 'Milano',
        StateCode = 'MI',
        Lead_Birthdate__c = date.parse('03/02/1956'),
        leadsource = 'Agency'
    //    recordTypeId = idLdRt       
     );
     Lead ld2 = new Lead (
        FirstName = 'LeadTest2',
        LastName = 'test2',
        Email = 'lead@mail.test',
        Phone = '0333333333',
        MobilePhone = '3333333333',
        Fiscal_ID__c = '123456789012345P',
        Agency_Code__c = '000828',
        Provincia_di_nascita__c = 'MI',
        Birth_Place__c = 'Milano',
        Gender__c = 'Maschio',
        Street = 'Cadorna',
        City = 'Milano',
        StateCode = 'MI',
        Company = 'TestCompany',
        AAI_Partita_iva__c = '12345678901',
        Lead_Birthdate__c = date.parse('03/02/1956'),
        recordTypeId = idLdRt,
        leadsource = 'Agency'    
     );
     leadList.add(ld1);
     leadList.add(ld2);
     insert leadList;

     list<IE_Configuration__c> listConfigs = new list<IE_Configuration__c>();
     IE_Configuration__c iec = new IE_Configuration__c (
        Request_compiler__c = 'IE_Request_StaticCompiler',
        Response_parser__c = 'IE_CIFparser',
        Type__c = 'WebService',
        Certificate__c = '',
        EndPoint__c = 'STOP__https://esg-pp.axa-medla.com/AXA_MEDLA/INT/it-cif-operations-v1-0-0',
        Name = 'CIF_Integration'
     );
     IE_Configuration__c iecpg = new IE_Configuration__c (
        Request_compiler__c = 'IE_Request_StaticCompiler',
        Response_parser__c = 'IE_CIFparser',
        Type__c = 'WebService',
        Certificate__c = '',
        EndPoint__c = 'STOP__https://esg-pp.axa-medla.com/AXA_MEDLA/INT/it-cif-operations-v1-0-0',
        Name = 'CIF_Integration_PG'
     );
     listConfigs.add(iec);
     listConfigs.add(iecpg);
     insert listConfigs;

     Account ac = new Account (
        FirstName = 'test',
        LastName = 'LeadTest',
        PersonEmail = 'account@mail.test',
        Phone = '0333333333',
        PersonMobilePhone = '3333333333',
        NDG__c = '0046100000000252',
        Nodes__c = '00828',
        //Policies_Expiration__c = '2015/09',
        Expiring_policy_branch__c = 'RE'
     );
     // insert ac;   
     
      Account ac000828 = new Account (
        FirstName = 'test',
        LastName = 'LeadTest',
        PersonEmail = 'account@mail.test',
        Phone = '0333333333',
        PersonMobilePhone = '3333333333',
        NDG__c = '0010010000115466',
        Nodes__c = '000828',
        //Policies_Expiration__c = '2015/09',
        Expiring_policy_branch__c = 'RE'
     );
     // insert ac000828;  
     
      Account ac001828 = new Account (
        FirstName = 'test1',
        LastName = 'LeadTest1',
        PersonEmail = 'account1@mail.test',
        Phone = '0333333333',
        PersonMobilePhone = '3333333333',
        NDG__c = '0008280000000001',
        Nodes__c = '000828',
        //Policies_Expiration__c = '2015/09',
        Expiring_policy_branch__c = 'RE'
     );
     // insert ac001828; 
    List<Account> AccToInsert = new List<Account>();
    AccToInsert.add(ac001828);
    AccToInsert.add(ac000828);
    AccToInsert.add(ac);
    
    insert AccToInsert;
    list<Attachment> attachList = new list<Attachment>();
     Attachment Myattachment = new Attachment();
         
         String sAttachment = 'Hello1';
         Myattachment.Body = Blob.valueOf(sAttachment);
         Myattachment.Name = 'test.txt';
         Myattachment.ParentId = iec.Id;
         attachList.add(Myattachment);
         Attachment Myattachment2 = new Attachment();

         Myattachment2.Body = Blob.valueOf(sAttachment);
         Myattachment2.Name = 'test.txt';
         Myattachment2.ParentId = iecpg.Id;
         attachList.add(Myattachment2);


         insert attachList; 
         
     IE_Placeholder__c iep = new IE_Placeholder__c (
        FieldToUse__c = 'Gender__c',
        Key__c = 'PH_Sesso',
        Sobject__c = 'Lead'
        );
        insert iep;
    list <IE_CR2PH_junction__c> junclist = new list <IE_CR2PH_junction__c>();
     IE_CR2PH_junction__c iej = new IE_CR2PH_junction__c (
        ExpV_External__c = 'M;M;F;F',
        ExpV_SFDC__c = 'male;maschio;female;femmina',
        IE_Configuration__c = iec.id,
        IE_Placeholder__c = iep.id,
        Is_Nillable__c = false,
        Tag__c = 'sesso',
        Type__c = 'REQUEST'
        );
     IE_CR2PH_junction__c iejpg = new IE_CR2PH_junction__c (
        ExpV_External__c = 'M;M;F;F',
        ExpV_SFDC__c = 'male;maschio;female;femmina',
        IE_Configuration__c = iecpg.id,
        IE_Placeholder__c = iep.id,
        Is_Nillable__c = false,
        Tag__c = 'sesso',
        Type__c = 'REQUEST'
        );
     junclist.add(iej);
     junclist.add(iejpg);
        insert junclist;
         
     }
     
     MappingProvince__c mpr = new MappingProvince__c (
        Name = '054',
        ProvinciaExternalKey__c = 'MI',
        SFDCexpected__c = 'Milano'
        );
        insert mpr;



    

}

    static testMethod void Test1(){ // ----------------------------> Test1, test Lead con Account senza i duplicati (Lead incompleto) 
     
     Lead ld = new Lead(
        LastName = 'LeadTest',
        FirstName = 'test',
        Email = 'lead@mail.test',
        Phone = '0333333333',
        MobilePhone = '3333333333',
        leadsource = 'Agency'

     );
     insert ld;
     
     Account ac = new Account (
        FirstName = 'test',
        LastName = 'LeadTest',
        PersonEmail = 'account@mail.test',
        Phone = '0333333333',
        PersonMobilePhone = '3333333333',
        NDG__c = 'Pippo',
        Nodes__c = '5014',
        //Policies_Expiration__c = '2015/09',
        Expiring_policy_branch__c = 'RE'
     );
     insert ac; 
    
     test.StartTest();
     EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));

     controller.closePopupLead();
     controller.closePopupResults();
     controller.closePopUpConvertedLead();
     controller.closePopUpGiuridico();
     controller.closePopUpCIFOnly();
     controller.closePopUpNoAccess();
     controller.leadConosciutoChoice='1';
     controller.choiceHandler();
     controller.leadConosciutoChoice='2';
     controller.choiceHandler();
     controller.leadConosciutoChoice='3';
     controller.choiceHandler();
     controller.leadConosciutoChoice='4';
     controller.choiceHandler();
     controller.saveLeadOnly();
     controller.closeProcess ();
     controller.userVisibilityCheck ();
     
     controller.SelectedNDG = 'Pippo';
    
     controller.getConvertedLeadStatus();
     
     controller.setDuplicatedAccountPicklistValues();
     
     controller.getAccountLink();
     controller.SaveAndSubmit();
     
     controller.ConvertedStatusValue = 'interessato';
     controller.DuplicatedAccountIDValue = '';
     controller.newAccountId = '0018E000007vk27';
     controller.SelectedNDG = 'Pippo';

     String fakesresponse = CIF_WebServicemanagement_IE.saveLocalObject ('A000Agent');
     fakesresponse = CIF_WebServicemanagement_IE.saveLocalObject ('A000SubAgent');
     fakesresponse = CIF_WebServicemanagement_IE.saveLocalObject ('A001');
     fakesresponse = CIF_WebServicemanagement_IE.saveLocalObject ('A001Single');
     fakesresponse = CIF_WebServicemanagement_IE.saveLocalObject ('A001SinglePG');
     fakesresponse = CIF_WebServicemanagement_IE.saveLocalObject ('A001SingleExisting');
     fakesresponse = CIF_WebServicemanagement_IE.saveLocalObject ('A001SingleImport');
     fakesresponse = CIF_WebServicemanagement_IE.saveLocalObject ('E401');
     fakesresponse = CIF_WebServicemanagement_IE.saveLocalObject ('E402');
     fakesresponse = CIF_WebServicemanagement_IE.saveLocalObject ('E403');
     test.StopTest();
    }
     

    
    static testMethod void Test3(){ // ----------------------------> Test3, test profilo diverso da profilo1,2,3,4 (entra nell' else della uservisibilitycheck) 
    
     Lead ld = new Lead(
        LastName = 'LeadTest',
        FirstName = 'test',
        Email = 'lead@mail.test',
        Phone = '0333333333',
        MobilePhone = '3333333333',
        leadsource = 'Agency'
     );
     insert ld;
     
     user MarketingUser = [Select id  FROM user where Profile.Name='AAI - Marketing Avanzato'  AND isactive=true limit 1];
     System.runAs(MarketingUser){
        EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));
     }
     

  
     } 
     
    static testMethod void Test4(){ // ----------------------------> Test4, test con finta risposta A000Agent (makeCIFcall) con inserimento user - 0 NDG - CHIAMATA VERA 
     lead ld = [select         FirstName ,  LastName ,  Email ,  Phone ,    MobilePhone ,   Fiscal_ID__c,  Agency_Code__c ,   Provincia_di_nascita__c ,  Birth_Place__c,  Gender__c , Street,  City , StateCode ,  Lead_Birthdate__c FROM lead where FirstName='LeadTest'        ];
     // lead ld = [select         FirstName ,  LastName ,  Email ,  Phone ,    MobilePhone ,   Fiscal_ID__c,  Agency_Code__c ,   Provincia_di_nascita__c ,  Birth_Place__c,  Gender__c , Street,  City , StateCode ,  Lead_Birthdate__c FROM lead where FirstName='LeadTest'        ];

     // Account ac000828 = [SELECT id,FirstName,LastName, PersonEmail,Phone, PersonMobilePhone, NDG__c, Nodes__c from Account where NDG__c = '0010010000115466'];
    
     Test.setMock(HttpCalloutMock.class, new CIF_MockWS_A000Agent_Test());
     
     EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));
        
          test.StartTest();
     controller.leadConosciutoChoice='3';
     controller.choiceHandler();
          test.StopTest();
     System.debug('questi sono i risultati +++++++'+controller.WS_Results );
     
     controller.SelectedNDG = '0010010000115466';
     
     }
     
    static testMethod void Test5(){ // ----------------------------> Test5, test con finta risposta A001 (makeCIFcall) con risposta - N NDG - CHIAMATA VERA 
     lead ld = [select         FirstName ,  LastName ,  Email ,  Phone ,    MobilePhone ,   Fiscal_ID__c,  Agency_Code__c ,   Provincia_di_nascita__c ,  Birth_Place__c,  Gender__c , Street,  City , StateCode ,  Lead_Birthdate__c FROM lead where FirstName='LeadTest'        ];
     // lead ld = [select         FirstName ,  LastName ,  Email ,  Phone ,    MobilePhone ,   Fiscal_ID__c,  Agency_Code__c ,   Provincia_di_nascita__c ,  Birth_Place__c,  Gender__c , Street,  City , StateCode ,  Lead_Birthdate__c FROM lead where FirstName='LeadTest'        ];

     // Account ac000828 = [SELECT id,FirstName,LastName, PersonEmail,Phone, PersonMobilePhone, NDG__c, Nodes__c from Account where NDG__c = '0010010000115466'];
    
     Test.setMock(HttpCalloutMock.class, new CIF_MockWS_A001_Test());
     
     EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));
        
          test.StartTest();
     controller.leadConosciutoChoice='3';
     controller.choiceHandler();
          
     System.debug('questi sono i risultati +++++++'+controller.WS_Results );
     
     controller.SelectedNDG = '0008280000000001';
     controller.convertToExisting();
     pagereference endReference = controller.forceConversion();
     test.StopTest();
     
     }
   
    static testMethod void Test6(){ // ----------------------------> Test6, test con finta risposta W103 
     lead ld = [select         FirstName ,  LastName ,  Email ,  Phone ,    MobilePhone ,   Fiscal_ID__c,  Agency_Code__c ,   Provincia_di_nascita__c ,  Birth_Place__c,  Gender__c , Street,  City , StateCode ,  Lead_Birthdate__c FROM lead where FirstName='LeadTest'        ];



         
     Test.setMock(HttpCalloutMock.class, new CIF_MockWS_W103_Test());
     
     EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));
          test.StartTest();

     controller.leadConosciutoChoice='3';
     controller.choiceHandler();
          test.StopTest();

     controller.SelectedNDG = 'Pippo';
     
     String rispW103 = CIF_WebServicemanagement_IE.saveLocalObject('W103');
      
    }


     static testMethod void Test8(){ // ----------------------------> Test8 giuridico con dati ok, test con finta risposta A001 (makeCIFcall) con risposta - N NDG - CHIAMATA VERA */
     lead ld = [select         FirstName ,  LastName ,  Email ,  Phone ,    MobilePhone ,   Fiscal_ID__c,  Agency_Code__c ,   Provincia_di_nascita__c ,  Birth_Place__c,  Gender__c , Street,  City , StateCode ,  Lead_Birthdate__c,Company,AAI_Partita_iva__c FROM lead where FirstName='LeadTest2'        ];
     // lead ld = [select         FirstName ,  LastName ,  Email ,  Phone ,    MobilePhone ,   Fiscal_ID__c,  Agency_Code__c ,   Provincia_di_nascita__c ,  Birth_Place__c,  Gender__c , Street,  City , StateCode ,  Lead_Birthdate__c FROM lead where FirstName='LeadTest'        ];

     // Account ac000828 = [SELECT id,FirstName,LastName, PersonEmail,Phone, PersonMobilePhone, NDG__c, Nodes__c from Account where NDG__c = '0010010000115466'];
    
     Test.setMock(HttpCalloutMock.class, new CIF_MockWS_A001_Test());
     
     EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));
     user currUs = [Select id  FROM user where FirstName='Agente000828'  AND isactive=true limit 1];
      System.runAs(currUs){
        
     
         test.StartTest();
         controller.leadConosciutoChoice='4';
         controller.choiceHandler();
         controller.conversionHelper();
              
         System.debug('questi sono i risultati +++++++'+controller.WS_Results );
         
         controller.SelectedNDG = '0008280000000001';
         controller.convertToExisting();
         test.StopTest();
        }  
    }

     static testMethod void TestAfterNewCif(){
        lead ld = [select         FirstName ,  LastName ,  Email ,  Phone ,    MobilePhone ,   Fiscal_ID__c,  Agency_Code__c ,   Provincia_di_nascita__c ,  Birth_Place__c,  Gender__c , Street,  City , StateCode ,  Lead_Birthdate__c,Company,AAI_Partita_iva__c FROM lead where FirstName='LeadTest2'        ];
        
        EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));
        EnhancedLeadViewCTRL.soggettoCIF newSOggetto = new  EnhancedLeadViewCTRL.soggettoCIF();
        newSOggetto.NDG = 'aaaa';
        newSOggetto.isSelected = false;


        user currUs = [Select id  FROM user where FirstName='Agente000828'  AND isactive=true limit 1];
        System.runAs(currUs){
            
         
            test.StartTest();
            controller.leadConosciutoChoice='4';
            controller.choiceHandler();
            controller.conversionHelper();
                 
            System.debug('questi sono i risultati +++++++'+controller.WS_Results );
             
            controller.SelectedNDG = '0008280000000001';
            controller.convertToExisting();
            controller.fromDuplicatedLeadtoCIFresultsPhysical();
            controller.fromDuplicatedLeadtoCIFresultsCompany();
            CIF_WebServiceManagement_IE IeClass = new CIF_WebServiceManagement_IE('CIF_Integration');
            CIF_WebServiceManagement_IE.esitoCheckSetInfo checkResult = IeClass.checkSetInfoPhysical(ld);
            CIF_WebServiceManagement_IE.CIF_Response cifResponse = IeClass.MakeCIFcall(checkResult);
            test.StopTest();        
         }
    }

}
    // static testMethod void Test7(){ /* ----------------------------> Test7, test con finta risposta E401 (makeCIFcall) (lead completo) */

     // Lead ld = new Lead (
        // FirstName = 'LeadTest',
        // LastName = 'test',
        // Email = 'lead@mail.test',
        // Phone = '0333333333',
        // MobilePhone = '3333333333',
        // Fiscal_ID__c = '123456789012345P',
        // Agency_Code__c = '501411',
        // Provincia_di_nascita__c = 'MI',
        // Birth_Place__c = 'Milano',
        // Gender__c = 'Maschio',
        // Street = 'Cadorna',
        // City = 'Milano',
        // StateCode = 'MI',
        // Lead_Birthdate__c = date.parse('03/02/1956')        
     // );
     // insert ld;
        
         // IE_Configuration__c iec = new IE_Configuration__c (
        // Request_compiler__c = 'IE_Request_StaticCompiler',
        // Response_parser__c = 'IE_CIFparser',
        // Type__c = 'WebService',
        // Certificate__c = 'AXA_MDV2_01',
        // EndPoint__c = 'https://esg-pp.axa-medla.com/AXA_MEDLA/INT/it-cif-operations-v1-0-0',
        // Name = 'CIF_Integration'
        // );
         // insert iec;
         
     // IE_Placeholder__c iep = new IE_Placeholder__c (
        // FieldToUse__c = 'Gender__c',
        // Key__c = 'PH_Sesso',
        // Sobject__c = 'Lead'
        // );
        // insert iep;
     
     // IE_CR2PH_junction__c iej = new IE_CR2PH_junction__c (
        // ExpV_External__c = 'M;M;F;F',
        // ExpV_SFDC__c = 'male;maschio;female;femmina',
        // IE_Configuration__c = iec.id,
        // IE_Placeholder__c = iep.id,
        // Is_Nillable__c = false,
        // Tag__c = 'sesso',
        // Type__c = 'REQUEST'
        // );
        // insert iej;
    
        // Attachment Myattachment = new Attachment();
         
         // String sAttachment = 'Hello1';
         // Myattachment.Body = Blob.valueOf(sAttachment);
         // Myattachment.Name = 'test.txt';
         // Myattachment.ParentId = iec.Id;
         // insert Myattachment;
         
     // Test.setMock(HttpCalloutMock.class, new CIF_MockWS_E401_Test());
     
   
     // EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));
     
     // controller.leadConosciutoChoice='3';
     // controller.choiceHandler();
 
     // controller.SelectedNDG = 'Pippo';
  
     // String rispE401 = CIF_WebServicemanagement_IE.saveLocalObject('E401');
   
    // }
    
    // static testMethod void Test8(){ /* ---------------------------->Test8, test con finta risposta E402 */

     // Lead ld = new Lead (
        // FirstName = 'LeadTest',
        // LastName = 'test',
        // Email = 'lead@mail.test',
        // Phone = '0333333333',
        // MobilePhone = '3333333333',
        // Fiscal_ID__c = '123456789012345P',
        // Agency_Code__c = '501411',
        // Provincia_di_nascita__c = 'MI',
        // Birth_Place__c = 'Milano',
        // Gender__c = 'Maschio',
        // Street = 'Cadorna',
        // City = 'Milano',
        // StateCode = 'MI',
        // Lead_Birthdate__c = date.parse('03/02/1956')        
     // );
     // insert ld;
     
    
         // IE_Configuration__c iec = new IE_Configuration__c (
        // Request_compiler__c = 'IE_Request_StaticCompiler',
        // Response_parser__c = 'IE_CIFparser',
        // Type__c = 'WebService',
        // Certificate__c = 'AXA_MDV2_01',
        // EndPoint__c = 'https://esg-pp.axa-medla.com/AXA_MEDLA/INT/it-cif-operations-v1-0-0',
        // Name = 'CIF_Integration'
        // );
         // insert iec;
         
     // IE_Placeholder__c iep = new IE_Placeholder__c (
        // FieldToUse__c = 'Gender__c',
        // Key__c = 'PH_Sesso',
        // Sobject__c = 'Lead'
        // );
        // insert iep;
     
     // IE_CR2PH_junction__c iej = new IE_CR2PH_junction__c (
        // ExpV_External__c = 'M;M;F;F',
        // ExpV_SFDC__c = 'male;maschio;female;femmina',
        // IE_Configuration__c = iec.id,
        // IE_Placeholder__c = iep.id,
        // Is_Nillable__c = false,
        // Tag__c = 'sesso',
        // Type__c = 'REQUEST'
        // );
        // insert iej;
    
        // Attachment Myattachment = new Attachment();
         
         // String sAttachment = 'Hello1';
         // Myattachment.Body = Blob.valueOf(sAttachment);
         // Myattachment.Name = 'test.txt';
         // Myattachment.ParentId = iec.Id;
         // insert Myattachment;
         
     // Test.setMock(HttpCalloutMock.class, new CIF_MockWS_E402_Test());
     
     // EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));

     // controller.leadConosciutoChoice='3';
     // controller.choiceHandler();
     
     // controller.SelectedNDG = 'Pippo';
      
     // String rispE402 = CIF_WebServicemanagement_IE.saveLocalObject('E402');
         
    // }
    
    // static testMethod void Test9(){ /* ----------------------------> Test9, test con finta risposta E403 */

     // Lead ld = new Lead (
        // FirstName = 'LeadTest',
        // LastName = 'test',
        // Email = 'lead@mail.test',
        // Phone = '0333333333',
        // MobilePhone = '3333333333',
        // Fiscal_ID__c = '123456789012345P',
        // Agency_Code__c = '501411',
        // Provincia_di_nascita__c = 'MI',
        // Birth_Place__c = 'Milano',
        // Gender__c = 'Maschio',
        // Street = 'Cadorna',
        // City = 'Milano',
        // StateCode = 'MI',
        // Lead_Birthdate__c = date.parse('03/02/1956')        
     // );
     // insert ld;
            
      // IE_Configuration__c iec = new IE_Configuration__c (
        // Request_compiler__c = 'IE_Request_StaticCompiler',
        // Response_parser__c = 'IE_CIFparser',
        // Type__c = 'WebService',
        // Certificate__c = 'AXA_MDV2_01',
        // EndPoint__c = 'https://esg-pp.axa-medla.com/AXA_MEDLA/INT/it-cif-operations-v1-0-0',
        // Name = 'CIF_Integration'
        // );
         // insert iec;
         
     // IE_Placeholder__c iep = new IE_Placeholder__c (
        // FieldToUse__c = 'Gender__c',
        // Key__c = 'PH_Sesso',
        // Sobject__c = 'Lead'
        // );
        // insert iep;
     
     // IE_CR2PH_junction__c iej = new IE_CR2PH_junction__c (
        // ExpV_External__c = 'M;M;F;F',
        // ExpV_SFDC__c = 'male;maschio;female;femmina',
        // IE_Configuration__c = iec.id,
        // IE_Placeholder__c = iep.id,
        // Is_Nillable__c = false,
        // Tag__c = 'sesso',
        // Type__c = 'REQUEST'
        // );
        // insert iej;
    
        // Attachment Myattachment = new Attachment();
         
         // String sAttachment = 'Hello1';
         // Myattachment.Body = Blob.valueOf(sAttachment);
         // Myattachment.Name = 'test.txt';
         // Myattachment.ParentId = iec.Id;
         // insert Myattachment;
         
     // Test.setMock(HttpCalloutMock.class, new CIF_MockWS_E403_Test());
  
     // EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));

     // controller.leadConosciutoChoice='3';
     // controller.choiceHandler();
     
     // controller.SelectedNDG = 'Pippo';
 
     // String rispE403 = CIF_WebServicemanagement_IE.saveLocalObject('E403');
     
    // }
    
    // static testMethod void Test10(){ /* ----------------------------> Test10, test con finta risposta A000Agent */

     // Lead ld = new Lead (
        // FirstName = 'LeadTest',
        // LastName = 'test',
        // Email = 'lead@mail.test',
        // Phone = '0333333333',
        // MobilePhone = '3333333333',
        // Fiscal_ID__c = '123456789012345P',
        // Agency_Code__c = '000828',
        // Provincia_di_nascita__c = 'MI',
        // Birth_Place__c = 'Milano',
        // Gender__c = 'Maschio',
        // Street = 'Cadorna',
        // City = 'Milano',
        // StateCode = 'MI',
        // Lead_Birthdate__c = date.parse('03/02/1956')        
     // );
     // insert ld;
           
            
      // IE_Configuration__c iec = new IE_Configuration__c (
        // Request_compiler__c = 'IE_Request_StaticCompiler',
        // Response_parser__c = 'IE_CIFparser',
        // Type__c = 'WebService',
        // Certificate__c = 'AXA_MDV2_01',
        // EndPoint__c = 'https://esg-pp.axa-medla.com/AXA_MEDLA/INT/it-cif-operations-v1-0-0',
        // Name = 'CIF_Integration'
        // );
         // insert iec;
         
     // IE_Placeholder__c iep = new IE_Placeholder__c (
        // FieldToUse__c = 'Gender__c',
        // Key__c = 'PH_Sesso',
        // Sobject__c = 'Lead'
        // );
        // insert iep;
     
     // IE_CR2PH_junction__c iej = new IE_CR2PH_junction__c (
        // ExpV_External__c = 'M;M;F;F',
        // ExpV_SFDC__c = 'male;maschio;female;femmina',
        // IE_Configuration__c = iec.id,
        // IE_Placeholder__c = iep.id,
        // Is_Nillable__c = false,
        // Tag__c = 'sesso',
        // Type__c = 'REQUEST'
        // );
        // insert iej;
    
        // Attachment Myattachment = new Attachment();
         
         // String sAttachment = 'Hello1';
         // Myattachment.Body = Blob.valueOf(sAttachment);
         // Myattachment.Name = 'test.txt';
         // Myattachment.ParentId = iec.Id;
         // insert Myattachment;
     
     // Test.setMock(HttpCalloutMock.class, new CIF_MockWS_A000Agent_Test());
  
     // EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));
     
     // controller.leadConosciutoChoice='3';
     // controller.choiceHandler();
     
     // controller.SelectedNDG = '0010010000115499';  

     // String rispA000Agent = CIF_WebServicemanagement_IE.saveLocalObject('A000Agent');
    
    // }
    
    // static testMethod void Test11(){ /* ----------------------------> Test11, test con finta risposta A000SubAgent */
 
     // Lead ld = new Lead (
        // FirstName = 'LeadTest',
        // LastName = 'test',
        // Email = 'lead@mail.test',
        // Phone = '0333333333',
        // MobilePhone = '3333333333',
        // Fiscal_ID__c = '123456789012345P',
        // Agency_Code__c = '000828',
        // Provincia_di_nascita__c = 'MI',
        // Birth_Place__c = 'Milano',
        // Gender__c = 'Maschio',
        // Street = 'Cadorna',
        // City = 'Milano',
        // StateCode = 'MI',
        // Lead_Birthdate__c = date.parse('03/02/1956')        
     // );
     // insert ld;
     
        
      // IE_Configuration__c iec = new IE_Configuration__c (
        // Request_compiler__c = 'IE_Request_StaticCompiler',
        // Response_parser__c = 'IE_CIFparser',
        // Type__c = 'WebService',
        // Certificate__c = 'AXA_MDV2_01',
        // EndPoint__c = 'https://esg-pp.axa-medla.com/AXA_MEDLA/INT/it-cif-operations-v1-0-0',
        // Name = 'CIF_Integration'
        // );
         // insert iec;
         
     // IE_Placeholder__c iep = new IE_Placeholder__c (
        // FieldToUse__c = 'Gender__c',
        // Key__c = 'PH_Sesso',
        // Sobject__c = 'Lead'
        // );
        // insert iep;
     
     // IE_CR2PH_junction__c iej = new IE_CR2PH_junction__c (
        // ExpV_External__c = 'M;M;F;F',
        // ExpV_SFDC__c = 'male;maschio;female;femmina',
        // IE_Configuration__c = iec.id,
        // IE_Placeholder__c = iep.id,
        // Is_Nillable__c = false,
        // Tag__c = 'sesso',
        // Type__c = 'REQUEST'
        // );
        // insert iej;
    
          // Attachment Myattachment = new Attachment();
         
         // String sAttachment = 'Hello1';
         // Myattachment.Body = Blob.valueOf(sAttachment);
         // Myattachment.Name = 'test.txt';
         // Myattachment.ParentId = iec.Id;
         // insert Myattachment;

     // Test.setMock(HttpCalloutMock.class, new CIF_MockWS_A000SubAgent_Test());

     // EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));
 
     // controller.leadConosciutoChoice='3';
     // controller.choiceHandler();
     
     // controller.SelectedNDG = '0010010000115466';
     
     // String rispA000SubAgent = CIF_WebServicemanagement_IE.saveLocalObject('A000SubAgent');
            
    // }
    
    // static testMethod void Test12(){ /* ----------------------------> Test12, test con finta risposta A001Single */
  
     // Lead ld = new Lead (
        // FirstName = 'LeadTest',
        // LastName = 'test',
        // Email = 'lead@mail.test',
        // Phone = '0333333333',
        // MobilePhone = '3333333333',
        // Fiscal_ID__c = '123456789012345P',
        // Agency_Code__c = '000828',
        // Provincia_di_nascita__c = 'MI',
        // Birth_Place__c = 'Milano',
        // Gender__c = 'Maschio',
        // Street = 'Cadorna',
        // City = 'Milano',
        // StateCode = 'MI',
        // Lead_Birthdate__c = date.parse('03/02/1956')        
     // );
     // insert ld;
   
     // IE_Configuration__c iec = new IE_Configuration__c (
        // Request_compiler__c = 'IE_Request_StaticCompiler',
        // Response_parser__c = 'IE_CIFparser',
        // Type__c = 'WebService',
        // Certificate__c = 'AXA_MDV2_01',
        // EndPoint__c = 'https://esg-pp.axa-medla.com/AXA_MEDLA/INT/it-cif-operations-v1-0-0',
        // Name = 'CIF_Integration'
        // );
         // insert iec;
         
     // IE_Placeholder__c iep = new IE_Placeholder__c (
        // FieldToUse__c = 'Gender__c',
        // Key__c = 'PH_Sesso',
        // Sobject__c = 'Lead'
        // );
        // insert iep;
     
     // IE_CR2PH_junction__c iej = new IE_CR2PH_junction__c (
        // ExpV_External__c = 'M;M;F;F',
        // ExpV_SFDC__c = 'male;maschio;female;femmina',
        // IE_Configuration__c = iec.id,
        // IE_Placeholder__c = iep.id,
        // Is_Nillable__c = false,
        // Tag__c = 'sesso',
        // Type__c = 'REQUEST'
        // );
        // insert iej;
    
    
          // Attachment Myattachment = new Attachment();
         
         // String sAttachment = 'Hello1';
         // Myattachment.Body = Blob.valueOf(sAttachment);
         // Myattachment.Name = 'test.txt';
         // Myattachment.ParentId = iec.Id;
         // insert Myattachment;

     // Test.setMock(HttpCalloutMock.class, new CIF_MockWS_A001Single_Test());
  
     // EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));

     // controller.leadConosciutoChoice='3';
     // controller.choiceHandler();
      
     // controller.SelectedNDG = '0046100000011111';
     
     // String rispA001Single = CIF_WebServicemanagement_IE.saveLocalObject('A001Single');
     
    // }
    
    // static testMethod void Test13(){ /* ----------------------------> Test13, test con finta risposta A001SinglePG (makeCIFcall) (lead completo) Query*/

     // lead ld = [select         FirstName ,  LastName ,  Email ,  Phone ,    MobilePhone ,   Fiscal_ID__c,  Agency_Code__c ,   Provincia_di_nascita__c ,  Birth_Place__c,  Gender__c , Street,  City , StateCode ,  Lead_Birthdate__c FROM lead where FirstName='LeadTest'        ];
        
     // EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));

     // controller.leadConosciutoChoice='3';
     
     // Test.startTest();
     // Test.setMock(HttpCalloutMock.class, new CIF_MockWS_A001SinglePG_Test());
     // controller.choiceHandler();
     // Test.stopTest();
     
     // controller.SelectedNDG = '0046100000000252';
          
    // }
    
    // static testMethod void Test14(){/* -------------------> Test14, test con finta risposta A001SinglePG */

     // Lead ld = new Lead (
        // FirstName = 'LeadTest',
        // LastName = 'test',
        // Email = 'lead@mail.test',
        // Phone = '0333333333',
        // MobilePhone = '3333333333',
        // Fiscal_ID__c = '123456789012345P',
        // Agency_Code__c = '000828',
        // Provincia_di_nascita__c = 'MI',
        // Birth_Place__c = 'Milano',
        // Gender__c = 'Maschio',
        // Street = 'Cadorna',
        // City = 'Milano',
        // StateCode = 'MI',
        // Lead_Birthdate__c = date.parse('03/02/1956')        
     // );
     // insert ld;
             
     // IE_Configuration__c iec = new IE_Configuration__c (
        // Request_compiler__c = 'IE_Request_StaticCompiler',
        // Response_parser__c = 'IE_CIFparser',
        // Type__c = 'WebService',
        // Certificate__c = 'AXA_MDV2_01',
        // EndPoint__c = 'https://esg-pp.axa-medla.com/AXA_MEDLA/INT/it-cif-operations-v1-0-0',
        // Name = 'CIF_Integration'
        // );
         // insert iec;
         
    // IE_Placeholder__c iep = new IE_Placeholder__c (
        // FieldToUse__c = 'Gender__c',
        // Key__c = 'PH_Sesso',
        // Sobject__c = 'Lead'
        // );
        // insert iep;
     
     // IE_CR2PH_junction__c iej = new IE_CR2PH_junction__c (
        // ExpV_External__c = 'M;M;F;F',
        // ExpV_SFDC__c = 'male;maschio;female;femmina',
        // IE_Configuration__c = iec.id,
        // IE_Placeholder__c = iep.id,
        // Is_Nillable__c = false,
        // Tag__c = 'sesso',
        // Type__c = 'REQUEST'
        // );
        // insert iej;
    
    
          // Attachment Myattachment = new Attachment();
         
         // String sAttachment = 'Hello1';
         // Myattachment.Body = Blob.valueOf(sAttachment);
         // Myattachment.Name = 'test.txt';
         // Myattachment.ParentId = iec.Id;
         // insert Myattachment;


     // Test.setMock(HttpCalloutMock.class, new CIF_MockWS_A001SinglePG_Test());
  
     // EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));
     
    
     // controller.leadConosciutoChoice='3';
     // controller.choiceHandler();
     
     // controller.SelectedNDG = '0046100000000252';
         
     // String rispA001SinglePG = CIF_WebServicemanagement_IE.saveLocalObject('A001SinglePG');

    // }
  
    // static testMethod void Test15(){ /* ----------------------------> Test15, test con finta risposta A001SingleImport  */

     // Lead ld = new Lead (
        // FirstName = 'LeadTest',
        // LastName = 'test',
        // Email = 'lead@mail.test',
        // Phone = '0333333333',
        // MobilePhone = '3333333333',
        // Fiscal_ID__c = '123456789012345P',
        // Agency_Code__c = '000828',
        // Provincia_di_nascita__c = 'MI',
        // Birth_Place__c = 'Milano',
        // Gender__c = 'Maschio',
        // Street = 'Cadorna',
        // City = 'Milano',
        // StateCode = 'MI',
        // Lead_Birthdate__c = date.parse('03/02/1956')        
     // );
     // insert ld;
         
     // IE_Configuration__c iec = new IE_Configuration__c (
        // Request_compiler__c = 'IE_Request_StaticCompiler',
        // Response_parser__c = 'IE_CIFparser',
        // Type__c = 'WebService',
        // Certificate__c = 'AXA_MDV2_01',
        // EndPoint__c = 'https://esg-pp.axa-medla.com/AXA_MEDLA/INT/it-cif-operations-v1-0-0',
        // Name = 'CIF_Integration'
        // );
         // insert iec;
         
     // IE_Placeholder__c iep = new IE_Placeholder__c (
        // FieldToUse__c = 'Gender__c',
        // Key__c = 'PH_Sesso',
        // Sobject__c = 'Lead'
        // );
        // insert iep;
     
     // IE_CR2PH_junction__c iej = new IE_CR2PH_junction__c (
        // ExpV_External__c = 'M;M;F;F',
        // ExpV_SFDC__c = 'male;maschio;female;femmina',
        // IE_Configuration__c = iec.id,
        // IE_Placeholder__c = iep.id,
        // Is_Nillable__c = false,
        // Tag__c = 'sesso',
        // Type__c = 'REQUEST'
        // );
        // insert iej;
    
     // Attachment Myattachment = new Attachment();
         
         // String sAttachment = 'Hello1';
         // Myattachment.Body = Blob.valueOf(sAttachment);
         // Myattachment.Name = 'test.txt';
         // Myattachment.ParentId = iec.Id;
         // insert Myattachment;


     // Test.setMock(HttpCalloutMock.class, new CIF_MockWS_A001SingleImport_Test());
     
     // EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));
      
     // controller.leadConosciutoChoice='3';
     // controller.choiceHandler();
     
     // controller.SelectedNDG = 'Esempio NDG3';
    
     // String rispA001SingleImport = CIF_WebServicemanagement_IE.saveLocalObject('A001SingleImport');
     
    // }
    
    // static testMethod void Test16(){ /* -------------------> Test16, test con finta risposta A001SingleExisting  */

     // Lead ld = new Lead (
        // FirstName = 'LeadTest',
        // LastName = 'test',
        // Email = 'lead@mail.test',
        // Phone = '0333333333',
        // MobilePhone = '3333333333',
        // Fiscal_ID__c = '123456789012345P',
        // Agency_Code__c = '000828',
        // Provincia_di_nascita__c = 'MI',
        // Birth_Place__c = 'Milano',
        // Gender__c = 'Maschio',
        // Street = 'Cadorna',
        // City = 'Milano',
        // StateCode = 'MI',
        // Lead_Birthdate__c = date.parse('03/02/1956')        
     // );
     // insert ld;
     
     // IE_Configuration__c iec = new IE_Configuration__c (
        // Request_compiler__c = 'IE_Request_StaticCompiler',
        // Response_parser__c = 'IE_CIFparser',
        // Type__c = 'WebService',
        // Certificate__c = 'AXA_MDV2_01',
        // EndPoint__c = 'https://esg-pp.axa-medla.com/AXA_MEDLA/INT/it-cif-operations-v1-0-0',
        // Name = 'CIF_Integration'
        // );
         // insert iec;
         
     // IE_Placeholder__c iep = new IE_Placeholder__c (
        // FieldToUse__c = 'Gender__c',
        // Key__c = 'PH_Sesso',
        // Sobject__c = 'Lead'
        // );
        // insert iep;
     
     // IE_CR2PH_junction__c iej = new IE_CR2PH_junction__c (
        // ExpV_External__c = 'M;M;F;F',
        // ExpV_SFDC__c = 'male;maschio;female;femmina',
        // IE_Configuration__c = iec.id,
        // IE_Placeholder__c = iep.id,
        // Is_Nillable__c = false,
        // Tag__c = 'sesso',
        // Type__c = 'REQUEST'
        // );
        // insert iej;
  
     
     // Attachment Myattachment = new Attachment();
         
         // String sAttachment = 'Hello1';
         // Myattachment.Body = Blob.valueOf(sAttachment);
         // Myattachment.Name = 'test.txt';
         // Myattachment.ParentId = iec.Id;
         // insert Myattachment;


     // Test.setMock(HttpCalloutMock.class, new CIF_MockWS_A001SingleExisting_Test());
     
     // EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));

     // controller.leadConosciutoChoice='3';
     // controller.choiceHandler();
     
     // controller.SelectedNDG = '0046100000000252';
     
     // String rispA001SingleExisting = CIF_WebServicemanagement_IE.saveLocalObject('A001SingleExisting');
    // }
     
    // static testMethod void Test17(){ /* -------------------> Test17, test con finta risposta A001 */

     // Lead ld = new Lead (
        // FirstName = 'LeadTest',
        // LastName = 'test',
        // Email = 'lead@mail.test',
        // Phone = '0333333333',
        // MobilePhone = '3333333333',
        // Fiscal_ID__c = '123456789012345P',
        // Agency_Code__c = '000828',
        // Provincia_di_nascita__c = 'MI',
        // Birth_Place__c = 'Milano',
        // Gender__c = 'Maschio',
        // Street = 'Cadorna',
        // City = 'Milano',
        // StateCode = 'MI',
        // Lead_Birthdate__c = date.parse('03/02/1956')        
     // );
     // insert ld;
     
     // IE_Configuration__c iec = new IE_Configuration__c (
        // Request_compiler__c = 'IE_Request_StaticCompiler',
        // Response_parser__c = 'IE_CIFparser',
        // Type__c = 'WebService',
        // Certificate__c = 'AXA_MDV2_01',
        // EndPoint__c = 'https://esg-pp.axa-medla.com/AXA_MEDLA/INT/it-cif-operations-v1-0-0',
        // Name = 'CIF_Integration'
        // );
         // insert iec;
         
     // IE_Placeholder__c iep = new IE_Placeholder__c (
        // FieldToUse__c = 'Gender__c',
        // Key__c = 'PH_Sesso',
        // Sobject__c = 'Lead'
        // );
        // insert iep;
     
     // IE_CR2PH_junction__c iej = new IE_CR2PH_junction__c (
        // ExpV_External__c = 'M;M;F;F',
        // ExpV_SFDC__c = 'male;maschio;female;femmina',
        // IE_Configuration__c = iec.id,
        // IE_Placeholder__c = iep.id,
        // Is_Nillable__c = false,
        // Tag__c = 'sesso',
        // Type__c = 'REQUEST'
        // );
        // insert iej;
  
     
     // Attachment Myattachment = new Attachment();
         
         // String sAttachment = 'Hello1';
         // Myattachment.Body = Blob.valueOf(sAttachment);
         // Myattachment.Name = 'test.txt';
         // Myattachment.ParentId = iec.Id;
         // insert Myattachment;


     // Test.setMock(HttpCalloutMock.class, new CIF_MockWS_A001SingleExisting_Test());
     
     // EnhancedLeadViewCTRL controller = new EnhancedLeadViewCTRL(new ApexPages.StandardController(ld));

     // controller.leadConosciutoChoice='3';
     // controller.choiceHandler();
     
     // controller.SelectedNDG = '0008280000000001';
     
     // String rispA001SingleExisting = CIF_WebServicemanagement_IE.saveLocalObject('A001');
    // }
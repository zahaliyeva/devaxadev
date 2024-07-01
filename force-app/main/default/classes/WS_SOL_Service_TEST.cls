@isTest
public class WS_SOL_Service_TEST 
{
    @testSetup static void setup()
    {
        test.startTest();
        
        //Some custom settings
        System.runAs(new User(Id=UserInfo.getUserId())) 
        {
            AAI_Code_Variables__c acv1 = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            AAI_Code_Variables__c acv2 = new AAI_Code_Variables__c(Name='FORCE_VISIBILITY_SHARE', Value__c='true');
            
            List<AAI_Code_Variables__c> acv = new List<AAI_Code_Variables__c>();
            acv.add(acv1);
            acv.add(acv2);
            
            insert acv;
            
            /* List<Caring_Angel__mdt> CarMeta = new List<Caring_Angel__mdt>
{
new Caring_Angel__mdt(label='EmailTemplate0001',DeveloperName='EmailTemplate0001',key__c = 'Cliente|Chiuso',value__c='Chiusura_d_ufficio_case'),
new Caring_Angel__mdt(DeveloperName='StatusChange0001',label = 'StatusChange0001',key__c='Assegnato II Livello|APERTURA_SINISTRO',value__c='Chiuso'),
new Caring_Angel__mdt(DeveloperName='StatusChange0002',label = 'StatusChange0002',key__c='Assegnato II Livello|APERTURA_SINISTRO|CTTR in stanza',value__c='In attesa documento')
};

insert CarMeta;*/
            
            List<Profile> SmartProfile = [Select Id From Profile Where name in ('Caring Angel - Supporto HD1','HD2 Caring Angel') order by name];
            
            List<User> HDUsers = new List<User>
            {
                new User(Username = UserInfo.getOrganizationId() + String.valueOf(System.now().millisecond()) + '@test' + String.valueof((Math.random() * 1000)) + '.com',
                         LastName = 'testuser',
                         LanguageLocaleKey = 'en_US',
                         FirstName = 'test',
                         Email = 'test@test.com',
                         Alias = 'test',
                         TimeZoneSidKey = 'Europe/Dublin',
                         LocaleSidKey = 'en_US',
                         EmailEncodingKey = 'UTF-8',
                         ProfileId =  SmartProfile[0].Id),
                    new User(Username = UserInfo.getOrganizationId() + String.valueOf(System.now().millisecond()) + '@test' + String.valueof((Math.random() * 1000)) + '.com',
                             LastName = 'testuser2',
                             LanguageLocaleKey = 'en_US',
                             FirstName = 'test2',
                             Email = 'test2@test.com',
                             Alias = 'test2',
                             TimeZoneSidKey = 'Europe/Dublin',
                             LocaleSidKey = 'en_US',
                             EmailEncodingKey = 'UTF-8',
                             ProfileId =  SmartProfile[1].Id)
                    };
                        
                        insert HDUsers;                      
            
            Case c = new Case(Status='Assegnato II Livello',Account_email__c='',OwnerId=HDUsers[1].Id);
            insert c;
            
            Questionario_CA__c CA = new Questionario_CA__c(Claim_Id__c='123456',Case__c=c.Id);
            insert CA;
            //OAVERSANO 03/12/2018 : Caring Angel -- START
            Case cs = new Case(Status='Assegnato I Livello',Account_email__c='',OwnerId=HDUsers[1].Id);
            insert cs;
            Questionario_CA__c CA2 = new Questionario_CA__c(Case__c=cs.Id);
        	insert CA2;
            //OAVERSANO 03/12/2018 : Caring Angel -- END
        }
    }
    
    static testmethod void refreshCase()
    {
        test.startTest();
        Case c = [Select Id, Casenumber, Status, Account_email__c, OwnerId from Case where Status='Assegnato II Livello'];
        
        WS_SOL_Service.SOL_Item theinput = new WS_SOL_Service.SOL_Item();
        WS_SOL_Service.SOL_Item_caseInfo theRealInput = new WS_SOL_Service.SOL_Item_caseInfo(); //OAVERSANO 15/11/2018 : Caring Angel
        WS_SOL_Service.SOL_Service_Result theoutput = new WS_SOL_Service.SOL_Service_Result();
        
        //Missing fields
        //OAVERSANO 15/11/2018 : Caring Angel -- START
        theinput.caseinfo  = theRealInput;
        theinput.caseInfo.EventType = 'APERTURA_SINISTRO'; 
        theinput.caseInfo.CaseId = '';
        //OAVERSANO 15/11/2018 : Caring Angel -- END
        theoutput = WS_SOL_Service.refreshCase(theinput);
        
        //now compiling all required fields
        theinput.caseInfo.CaseId=c.Id;
        theinput.caseInfo.ClaimId='123456';
        theinput.caseInfo.ClaimNumber='013899000006';
        theinput.caseInfo.EventDateTime='2018-09-20-13-20-30';
        theinput.caseInfo.EventDateTimeSent='2018-09-22-15-20-30';
        theinput.caseInfo.EventType='APERTURA_SINISTRO';
        theinput.caseInfo.PolicyNumber='1.1807.5.062715027';
        theinput.caseInfo.CAIGenerable='1F';
        theinput.caseInfo.ClaimType='CTTR in stanza';
        theoutput = WS_SOL_Service.refreshCase(theinput);
        theoutput = WS_SOL_Service.refreshCase(theinput);
        system.debug(System.LoggingLevel.ERROR,'++++theOUTPUT for inserting proposta'+theoutput);
        
        test.stopTest();
    }        
    
    //OAVERSANO 03/12/2018 : Caring Angel -- START
    static testmethod void refreshCase2()
    {
        test.startTest();
        Case c = [Select Id, Casenumber, Status, Account_email__c, OwnerId from Case where Status='Assegnato I Livello'];
        
        WS_SOL_Service.SOL_Item theinput = new WS_SOL_Service.SOL_Item();
        WS_SOL_Service.SOL_Item_caseInfo theRealInput = new WS_SOL_Service.SOL_Item_caseInfo(); //OAVERSANO 15/11/2018 : Caring Angel
        WS_SOL_Service.SOL_Service_Result theoutput = new WS_SOL_Service.SOL_Service_Result();
        
        //Missing fields
        //OAVERSANO 15/11/2018 : Caring Angel -- START
        theinput.caseinfo  = theRealInput;
        theinput.caseInfo.EventType = 'APERTURA_SINISTRO'; 
        theinput.caseInfo.CaseId = '';
        //OAVERSANO 15/11/2018 : Caring Angel -- END
        theoutput = WS_SOL_Service.refreshCase(theinput);
        
        //now compiling all required fields
        theinput.caseInfo.CaseId=c.Id;
        theinput.caseInfo.ClaimId='123456';
        theinput.caseInfo.ClaimNumber='013899000006';
        theinput.caseInfo.EventDateTime='2018-09-20-13-20-30';
        theinput.caseInfo.EventDateTimeSent='2018-09-22-15-20-30';
        theinput.caseInfo.EventType='APERTURA_SINISTRO';
        theinput.caseInfo.PolicyNumber='1.1807.5.062715027';
        theinput.caseInfo.CAIGenerable='1F';
        theinput.caseInfo.ClaimType='CTTR in stanza';
        theoutput = WS_SOL_Service.refreshCase(theinput);
        theoutput = WS_SOL_Service.refreshCase(theinput);
        system.debug(System.LoggingLevel.ERROR,'++++theOUTPUT for inserting proposta'+theoutput);
        
        test.stopTest();
    }        
    //OAVERSANO 03/12/2018 : Caring Angel -- END
    
    @istest
    static  void sendNotificationEmailTest()
    {
        WS_SOL_Service.SOL_Item theinput = new WS_SOL_Service.SOL_Item();
     WS_SOL_Service.SOL_Request_STATE currentState = new WS_SOL_Service.SOL_Request_STATE(theinput); 
        case c=[SELECT TECHThreadId__c FROM Case limit 1];
            currentState.EmInfo.AddresseeType='Cliente';
        currentState.EmInfo.CaseStatus='Chiuso';
        currentState.EmInfo.CustomerName='test';
        currentState.threadId= c.TECHThreadId__c;
        Id caseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sinistri_AAI').getRecordTypeId();
        Case caseObj1 = new Case(RecordTypeId = caseRT,status='Assegnato II Livello',origin='phone');
        insert caseObj1;
        currentState.RelatedCase=caseObj1;
        currentState.RelatedCase.RecordtypeId=caseObj1.RecordTypeId;
        currentState.input=theinput;
        WS_SOL_Service.SOL_Item_caseInfo theRealInput = new WS_SOL_Service.SOL_Item_caseInfo(); //OAVERSANO 15/11/2018 : Caring Angel

        theinput.caseinfo  = theRealInput;

        currentState.input.caseInfo.EventType='APERTURA_SINISTRO';
       test.startTest();
        WS_SOL_Service_Management.sendNotificationEmail(currentState);
        WS_SOL_Service_Management.PopulateCaseInstance(currentState);
        test.stopTest();
    }
    @istest
    static  void sendNotificationEmailTest2()
    {
        WS_SOL_Service_Management.isSinistri=true;
        WS_SOL_Service.SOL_Item theinput = new WS_SOL_Service.SOL_Item();
     WS_SOL_Service.SOL_Request_STATE currentState = new WS_SOL_Service.SOL_Request_STATE(theinput); 
        case c=[SELECT TECHThreadId__c FROM Case limit 1];
            currentState.EmInfo.AddresseeType='Cliente';
        currentState.EmInfo.CaseStatus='Chiuso';
        currentState.EmInfo.CustomerName='test';
        currentState.threadId= c.TECHThreadId__c;
        Id caseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sinistri_AAI').getRecordTypeId();
        Case caseObj1 = new Case(RecordTypeId = caseRT,status='Assegnato II Livello',origin='phone');
        insert caseObj1;
        currentState.RelatedCase=caseObj1;
        currentState.RelatedCase.RecordtypeId=caseObj1.RecordTypeId;
        currentState.input=theinput;
        WS_SOL_Service.SOL_Item_caseInfo theRealInput = new WS_SOL_Service.SOL_Item_caseInfo(); //OAVERSANO 15/11/2018 : Caring Angel

        theinput.caseinfo  = theRealInput;

        currentState.input.caseInfo.EventType='APERTURA_SINISTRO';
        currentState.input.caseInfo.ClaimLink='test';
       test.startTest();
        WS_SOL_Service_Management.sendNotificationEmail(currentState);
        WS_SOL_Service_Management.PopulateCaseInstance(currentState);
        WS_SOL_Service_Management.validateFieldsFormat(currentState);
        test.stopTest();
    }
    
    
    
}
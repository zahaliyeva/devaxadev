@isTest
private class agencyHdChartsCTRL_TEST {

    @testSetup static void setup() 
    {
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        insert new MPS_Code_Variables__c(Name = 'ProponiSoluzioneHD2', value__c = 'true');
        Id caseRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Assistenza_Agenti').getRecordTypeId();

        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name = 'NFE - AAI - Vendite Base'];
        Profile p;
        Id pAgent;
        if (profiles.size() > 0)
        {
            p      = profiles[0];
            pAgent = p.Id;
        } 
        
        Account acct = new Account(Name = 'SFDC Account');
        insert acct;
        Id accId     = acct.Id;

        Contact con = new Contact(FirstName = 'Joe',
                                  LastName  = 'Smith',
                                  Phone     = '415.555.1212',
                                  AccountId = accId);
        insert con;
        Id conId = con.Id;
        
        User newAgent = new User(Username                     = 'agente@axa.test.com',
                                 LastName                     = 'testuser',
                                 LanguageLocaleKey            = 'it',
                                 FirstName                    = 'test',
                                 Email                        = 'test@test.com', 
                                 Alias                        = 'test',
                                 TimeZoneSidKey               = 'Europe/Dublin',
                                 LocaleSidKey                 = 'it_IT',
                                 EmailEncodingKey             = 'UTF-8',
                                 ProfileId                    = pAgent,
                                 ContactId                    = conId,
                                 UserPermissionsKnowledgeUser = true);
        insert newAgent;
        
        Case caseObj1 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Open',
                                 Origin    = 'Front end Agenti',
                                 OwnerId   = newAgent.Id,
                                 User__c =  newAgent.Id,
                                 RecordTypeId = caseRT);
        insert caseObj1;
        
       
       
    }
    
	@isTest static void emptyFilters() {
		agencyHdChartsCTRL.ResponseDto firstResult = agencyHdChartsCTRL.getCasesByStatus('','','','','','','');
		agencyHdChartsCTRL.ResponseDto secondResult = agencyHdChartsCTRL.getAverageRating('','','','','','','');
		agencyHdChartsCTRL.ResponseDto thirdResult = agencyHdChartsCTRL.getCasesResolutionTime('','','','','','','');
	}

	@isTest static void populatedFilter() {
		agencyHdChartsCTRL.ResponseDto firstResult = agencyHdChartsCTRL.getCasesByStatus('2018','07','01','IT','AUTO','ANNULLAMENTI','CurrentUser');
		agencyHdChartsCTRL.ResponseDto thirdResult = agencyHdChartsCTRL.getCasesResolutionTime('2018','07','01','IT','AUTO','ANNULLAMENTI','CurrentUser');
	}
    
}
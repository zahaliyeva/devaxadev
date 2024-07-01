@IsTest
public class MobilityLeadControllerTest {

    @testSetup static void setup(){

        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2@test.com' + System.now().millisecond(), //CAPOBIANCO_A Aggiunto il 2° System.now
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert portalAccountOwner1; 
        
        //OAVERSANO 27/11/2018 : ICF Close The Loop -- START
        Group grp = new Group();
        	grp.name = 'Coda Agenzia 00127';
        	grp.Type = 'Queue'; 
        	Insert grp; 
 
            //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = portalAccountOwner1.Id;
            grpMem1.GroupId = grp.Id;
            Insert grpMem1;
        //OAVERSANO 27/11/2018 : ICF Close The Loop -- END
      
    }


    static testMethod void testLeadList() {

        //creo una lista fittizia di lead
        List<Lead> leads = new List<Lead> ();
        for (Integer count = 0; count < 50; count++) {
                leads.add(new Lead(
                    Phone = '000000',
                    FirstName = 'Giampaolo',
                    LastName = 'Alberti',
                    Email = 'mario'+count+'@invalid.invalid',
                    Fiscal_ID__c = 'LBRGPL80A01F205Y'
                ));
        }  

        //carico la lista
        insert leads;
        
        DateTime StartDate = DateTime.newInstance(2019, 10, 22, 0, 0, 0);
        DateTime EndDate = StartDate.addHours(16);
        
        //creo una lista fittizia di eventi
        List<Event> events = new List<Event> ();
        for (Integer count = 0; count < 5; count++) {
                events.add(new Event(
                    Subject = 'Chiamare',
                    StartDateTime = StartDate,
                    EndDateTime = EndDate
                ));
        }  

        //carico la lista
        insert events;
        
         //creo una lista fittizia di quotazioni
        List<Quotazione__c> quotazioni = new List<Quotazione__c> ();
        for (Integer count = 0; count < 5; count++) {
                quotazioni.add(new Quotazione__c(
                    Name = 'Quotazione'
                ));
        }  

        //carico la lista
        //insert quotazioni;
        
        //creo una lista fittizia di Task
        List<Task> tasks = new List<Task> ();
        for (Integer count = 0; count < 5; count++) {
                tasks.add(new Task(
                    Subject = 'Task'
                ));
        }  

        //carico la lista
        insert tasks;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        //creo una lista fittizia di User
        List<User> users = new List<User> ();
        users.add(new User(
            Alias = 'tst', 
            Email='invalid@invalid.invalid', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='testuser@invalid.invalid'
        ));  

        //carico la lista
        insert users;
        
        AAI_Code_Variables__c cs = new AAI_Code_Variables__c();
        cs.name='AdminAgencyCode';
        cs.Value__c='00127';
        
        insert cs;
        Test.startTest();

        //verifico che il caricamento corrisponda
        List<Lead> leadList1 = MobilityLeadController.getLeads();
        
        List<Lead> leadList = MobilityLeadController.getLeads(10);
        Lead lea = leadList[0];
        
        Id LeadId = lea.Id;

        System.assertEquals(LeadId!= null, true, 'Non puo essere null');
        
        lea.Ultima_data_di_riassegnazione__c = StartDate;
        lea.FirstName = 'Giampaolo';
        lea.LastName = 'Alberti';
        lea.Fiscal_ID__c = 'LBRGPL80A01F205Y';
        lea.Company = 'CIAO';
        lea.AAI_Partita_IVA__c = '12345678901';
            
        update lea;
        
        List<String> ListaId = new List<String>{LeadId};
        
        MobilityLeadController.getContactHistory(5,LeadId);
        
        MobilityLeadController.getContactHistoryPage(LeadId,10,2,2,20);
        
        //MobilityLeadController.getAgencyUsers(2,2);
        
        Map<string,boolean> Map1 = new Map<string,boolean>();
        Map1.put(users[0].Id,true);
        
        MobilityLeadController.saveAgencyUsers(Map1);    
        
        //MobilityLeadController.saveAgencyUsers(Map1);    
        
        Map <String,List<Object>> Map2 = new Map<String,List<Object>>();

        List<string> ListaFiltri = new List<string>{'Lead_AXA_Assicurazioni','eCommerce'};
        
        for (Integer count = 0;
             count < 2;
             count++) {
             Map2.put('RecordType.DeveloperName',ListaFiltri);
        }
        
        MobilityLeadController.getLeadListView(10,2,Map2,'Name','ASC','LeadSource');
        MobilityLeadController.proxyGetListView(10,2,Map2,'Name','ASC','LeadSource', 'Health');
        Map <String,List<Object>> Map3 = new Map<String,List<Object>>();
        
        List<String> ListaFiltriEvent = new List<String>{'Chiamare'};
        
        for (Integer count = 0;
             count < 1;
             count++) {
             Map3.put('Subject',ListaFiltriEvent);
        }
        
        MobilityLeadController.getEvent(10,2,Map3,'Subject','ASC','Subject');
        
        Map <String,List<Object>> Map4 = new Map<String,List<Object>>();
        
        List<String> ListaFiltriQuotazioni = new List<String>{'Quotazione'};
        
        for (Integer count = 0;
             count < 1;
             count++) {
             Map4.put('Name',ListaFiltriQuotazioni);
        }
        
        MobilityLeadController.getQuotations(10,2,Map4,'Name','ASC','Name');
        
        Map <String,List<Object>> Map5 = new Map<String,List<Object>>();
        
        List<String> ListaFiltriTask = new List<String>{'Task'};
        
        for (Integer count = 0;
             count < 1;
             count++) {
             Map5.put('Subject',ListaFiltriTask);
        }

        MobilityLeadController.getTask(10,2,Map5,'Subject','ASC','Subject');
        
        list <Group> tempQueues = [select id from Group where type = 'Queue'];
        id temp = tempQueues.isEmpty()? System.UserInfo.getProfileId(): tempQueues[0].id;

        MobilityLeadController.changeOwner(ListaId, temp, 'ciao');
        
        MobilityLeadController.getTimeStock(LeadId);
        
        MobilityLeadController.getCountActivities(LeadId);
        
        MobilityLeadController.getAccountReference('Mario');
        
        MobilityLeadController.getSubStatusList();
        MobilityLeadController.getQueueAxa();
        MobilityLeadController.validateConvertLead(lea);
        MobilityLeadController.canConvertLead(LeadId);
        
        MobilityLeadController.getDuplicatedCheck(LeadId);
        MobilityLeadController.getLeadEmail(LeadId);
        


        MobilityLeadController.getAgencyUsers(0,6);
        MobilityLeadController.getCountryCodes();
        MobilityLeadController.changeLeadOwner(LeadId);

        Test.stopTest();

        
    }
    
    static testMethod void testDuplicates(){
        Test.startTest();
        
        Map <String,List<Object>> Map2 = new Map<String,List<Object>>();
                
        SObjectTable.TablePagination temp = MobilityLeadController.searchDuplicates(10,2,Map2,'Name','ASC','LeadSource');

        System.assertEquals(temp!= null, true, 'Non puo essere null');
        
        Test.stopTest();
    }
    
    static testMethod void testMapColor(){
       
        
        List<Lead> l = new List<Lead>();
        l.add(new Lead (Dettaglio__c = 'Visualizza quotazione', Landing_Page__c = 'ConFido'));
        l.add(new Lead (LeadSource = 'Lead da MPS'));
        List<MobilityLeadController.LeadWrapper> res =  MobilityLeadController.getColorsFromLead(l);
        for(MobilityLeadController.LeadWrapper lw : res){
            system.assert(String.isNotBlank(lw.colorCode));
        }
    }

    
}
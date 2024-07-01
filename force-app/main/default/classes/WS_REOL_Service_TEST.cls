@isTest
public class WS_REOL_Service_TEST{

    @testSetup static void setup() {//preparing test database
        test.startTest();
        
        //Some custom settings
        System.runAs(new User(Id=UserInfo.getUserId())) {
            AAI_Code_Variables__c acv1 = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            AAI_Code_Variables__c acv2 = new AAI_Code_Variables__c(Name='FORCE_VISIBILITY_SHARE', Value__c='true');
            
            List<AAI_Code_Variables__c> acv = new List<AAI_Code_Variables__c>();
            acv.add(acv1);
            acv.add(acv2);
            
            insert acv;
        }
        //one agency code 999999, with 2 sub nodes 999999111111 and 999999222222
        Node__c testNode1= new Node__c();
        Node__c testNode2= new Node__c();   
        Node__c testNode3= new Node__c();   

        List<Node__c> NodesToInsert= new List<Node__c>();
        NodesToInsert.add(prepareNode('999999','parent',7));
        NodesToInsert.add(prepareNode('999999111111','parent',8));
        NodesToInsert.add(prepareNode('999999222222','parent',9));
        
        insert NodesToInsert;
        
        //Must set the agency as active. Shoudl be done adding a proper user, but for test purposes is OK to fix manually
        List<Account> theAgency = [SELECT id from Account WHERE Agency_Code__c='999999'];
        if (!theAgency.isempty()) {
            theAgency[0].Active__c = true;
            update theAgency;
        }

        
        //Some B2C clients on the AgencyCode
        list<Recordtype> SelectedRT_Acc = [SELECT id, DeveloperName from Recordtype where SobjectType ='Account' AND DeveloperName ='B2C_Client'];//B2B_Client OR B2C_Client
        List<Account> AccToInsert = new List<Account>();
        for (integer i=0; i<=10; i++) { 
            Account thisClient = new Account();
            
            thisClient.TECH_Company__c = 'AAI';
            
            thisClient.RecordTypeId = SelectedRT_Acc[0].Id;
            DateTime myNOW = DateTime.Now();
            string suffix = String.ValueOf(myNOW.year())+'_'+String.ValueOf(myNOW.month())+'_'+String.ValueOf(myNOW.day())+'_'+String.ValueOf(myNOW.hour())+'_'+String.ValueOf(myNOW.minute())+'_'+String.ValueOf(myNOW.second())+String.ValueOf(myNOW.millisecond())+'__'+i;
            

            thisClient.FirstName='FN_Test'+suffix;
            thisClient.LastName = 'LN_Test'+ suffix;

            
            thisClient.AAI_Agency_Reference_Code__c='999999';
            thisClient.Nodes__c='999999';
            
            thisClient.NDG__c='99999900000'+string.ValueOf(i);
            system.debug('++++++thisClient'+thisClient);
            AccToInsert.add(thisClient);
        }
        insert AccToInsert;
        
        //Some Opportunities on the accounts
        //list<Recordtype> SelectedRT_Opp = [SELECT id, DeveloperName from Recordtype where SobjectType ='Opportunity' AND DeveloperName ='No_Auto'];
        list<Recordtype> SelectedRT_Opp = [SELECT id, DeveloperName from Recordtype where SobjectType ='Opportunity' AND DeveloperName ='Opportunita_AXA_Assicurazioni']; //CAPOBIANCO_A 28/11/2017 Changed the RT

        List<Opportunity> OppToInsert = new List<Opportunity>();

        for (integer i=0; i<=10; i++) {
            Opportunity thisOpp = new Opportunity();
            
            thisOpp.Name='test'; //is going to be changed by the workflow;
            thisOpp.RecordTypeId = SelectedRT_Opp[0].Id;
            thisOpp.StageName = 'Open';
            thisOpp.AccountId=AccToInsert[i].Id;
            thisOpp.CloseDate = Date.Today().addDays(30);
            
            OppToInsert.add(thisOpp);
        }
        insert OppToInsert;
        
        test.stopTest();
    }
    
    //
    static testmethod void Polizza_Calls(){
        test.startTest();
        WS_REOL_Service.REOL_Item theinput = new WS_REOL_Service.REOL_Item();
        WS_REOL_Service.REOL_Service_Result theoutput = new WS_REOL_Service.REOL_Service_Result();
        
        //Missing fields
        theoutput = WS_REOL_Service.insertPolizza(theinput);
        
        //now compiling all required fields
        theinput.IdProposta=1;
        theinput.IdPolizza='zzz';
        theinput.NumeroPolizza='123123';
        theinput.AgencyCode='aaaa';
        theinput.Node='bbbb';
        theinput.Branch='ccc';
        theinput.Holder='ddd';
        theinput.SubAsaCode=1;
        theinput.SubAsaDesc='xxx';
        theinput.ProductName='yyy';
        theinput.ProductCode='222';
        theinput.ProductDesc='qqq';
        theinput.FrazionamentoCode='1212';
        theinput.FrazionamentoDesc='ttt';
        theinput.Premium=100;
        theinput.LastModifiedBy='eee';
        theinput.IdOpp=UserInfo.getUserId();//just an id to pass formal validation
        theinput.ObjectType='fff';
        theinput.PropostaStatusCode=1;
        theinput.NDG='ggg';
        theinput.PropostaStatusDesc='hhh';
        theinput.DataEffetto=Date.Today();
        theinput.DataScadenza=Date.Today();
        theinput.DataFineValidita=Date.Today();
        //CAPOBIANCO_A 28/11/2017 - SPRINT 55 -- START
        theinput.Targaveicolo = 'AA123AA';
        theinput.Modelloveicolo = 'zzz';
        theinput.Marcaveicolo = 'aaa' ;
        theinput.Versioneveicolo = 'bbb';
        theinput.Diritti = 10.00;
        theinput.Compensi = 10.00;
        theinput.Premiototaleapagare = 10.00;
        theinput.AsaCode = 1;
        //CAPOBIANCO_A 28/11/2017 - SPRINT 55 -- END

        theoutput = WS_REOL_Service.insertPolizza(theinput);
        
        //Fixing Obj Type
        theinput.ObjectType='POLIZZA';
        theoutput = WS_REOL_Service.insertPolizza(theinput);

        //Fixing Agency Type
        theinput.AgencyCode='999999';
        theoutput = WS_REOL_Service.insertPolizza(theinput);

        //Fixing the NDG
        theinput.NDG='999999000002';
        theoutput = WS_REOL_Service.insertPolizza(theinput);
        
        //Fixing the Opp Ref (just the ID) -->Still fail no proposta is found
        List<Opportunity> AllOpps = [Select id, Account.NDG__c FROM Opportunity LIMIT 1];
        if (!AllOpps.isempty()) {
        theinput.IdOpp = AllOpps[0].Id;//remember to use the same opp
        theoutput = WS_REOL_Service.insertPolizza(theinput);
        }
        
        // creating the Proposta
        WS_REOL_Service.REOL_Item theinputForProposta=theinput;
        theinputForProposta.ObjectType='PROPOSTA';
        theinputForProposta.NDG=AllOpps[0].Account.NDG__c;
        theinputForProposta.FrazionamentoDesc='ANNUALE';
        theinputForProposta.FrazionamentoCode='000001';
        theinputForProposta.PropostaStatusDesc='PROPOSTA VALIDA';
        theoutput = WS_REOL_Service.upsertProposta(theinputForProposta);
        
        system.debug(System.LoggingLevel.ERROR,'++++theOUTPUT for inserting proposta'+theoutput);
        // Now calling the insert of the polizza
        theinput.ObjectType='POLIZZA';
        theoutput = WS_REOL_Service.insertPolizza(theinput);
        
        //Calling again to check that nothing is done when the polizza already exists
        theoutput = WS_REOL_Service.insertPolizza(theinput);
        

        

/*
        //Fixing the NDG of the request with the NDG of the opportunity-->still failing as bad state
        if (!AllOpps.isempty()) {
        theinput.NDG=AllOpps[0].Account.Ndg__c;
        theoutput = WS_REOL_Service.insertPolizza(theinput);
        }
        system.debug(System.LoggingLevel.ERROR,'++++'+theoutput);
        
        //Fixing the status
        theinput.PropostaStatusDesc='PROPOSTA VALIDA';
        theoutput = WS_REOL_Service.insertPolizza(theinput);
        
        //calling again to simulate update
        theoutput = WS_REOL_Service.insertPolizza(theinput);
        */
        test.stopTest();
    }
    
    static testmethod void Proposta_Calls(){
        test.startTest();
        WS_REOL_Service.REOL_Item theinput = new WS_REOL_Service.REOL_Item();
        WS_REOL_Service.REOL_Service_Result theoutput = new WS_REOL_Service.REOL_Service_Result();
        
        //Missing Fields
        theoutput = WS_REOL_Service.upsertProposta(theinput);
        
        
        //now compiling all required fields
        theinput.IdProposta=1;
        theinput.AgencyCode='aaaa';
        theinput.Node='bbbb';
        theinput.Branch='ccc';
        theinput.Holder='ddd';
        theinput.LastModifiedBy='eee';
        theinput.IdOpp=UserInfo.getUserId();//just an id to pass formal validation
        theinput.ObjectType='fff';
        theinput.PropostaStatusCode=1;
        theinput.NDG='ggg';
        theinput.PropostaStatusDesc='hhh';
        
        theoutput = WS_REOL_Service.upsertProposta(theinput);
        
        //Fixing Obj Type
        theinput.ObjectType='PROPOSTA';
        theoutput = WS_REOL_Service.upsertProposta(theinput);

        //Fixing Agency Type
        theinput.AgencyCode='999999';
        theoutput = WS_REOL_Service.upsertProposta(theinput);
        
        //Fixing the Opp Ref (just the ID) -->Still fail as the rest (NDG for example) is not fixed
        List<Opportunity> AllOpps = [Select id, Account.NDG__c FROM Opportunity LIMIT 1];
        if (!AllOpps.isempty()) {
        theinput.IdOpp = AllOpps[0].Id;
        theoutput = WS_REOL_Service.upsertProposta(theinput);
        }
        
        //Fixing the NDG
        theinput.NDG='999999000001';
        theoutput = WS_REOL_Service.upsertProposta(theinput);

        //Fixing the NDG of the request with the NDG of the opportunity-->still failing as bad state
        if (!AllOpps.isempty()) {
        theinput.NDG=AllOpps[0].Account.Ndg__c;
        theoutput = WS_REOL_Service.upsertProposta(theinput);
        }
        system.debug(System.LoggingLevel.ERROR,'++++'+theoutput);
        
        //Fixing the status
        theinput.PropostaStatusDesc='PROPOSTA VALIDA';
        theoutput = WS_REOL_Service.upsertProposta(theinput);
        
        //calling again to simulate update
        theoutput = WS_REOL_Service.upsertProposta(theinput);
        
        //calling again changing the proposta id
        theinput.IdProposta=2;
        theoutput = WS_REOL_Service.upsertProposta(theinput);

        test.stopTest();

    }
    
    
    /////UTILITY TEST
    public static Node__c prepareNode(string Name, string Parent, integer level){
        Node__c testNode= new Node__c();    
        testNode.Node_description__c='testdescription'+Name;
        testNode.Node_level__c=level;
        testNode.Node_unique_code__c=Name;
        testNode.Parent_node_unique_code__c='Parent';
        testNode.Tree_name__c='DIF'; //does not work with different tree name due to naming convention
        testNode.Management_type__c='TGest';
        testNode.Intermediary_type__c='TIntermediario';
        return testNode;
    }
    
    // public static Account prepareClient(string Name, string NDG, string Nodes, string AgencyCode,  String type){
        // Account testAccount= new Account();    
        // testAccount.TECH_Company__c='AAI';
        // testAccount.FirstName=Name;
        // testAccount.LastName='LN'+Name;
        // testAccount.Nodes__c=Nodes;
        // testAccount.AAI_AGency_Reference_code__c=AgencyCode;        
        
        // Get the correct RT Id
        // Schema.DescribeSObjectResult d = Schema.SObjectType.Account;
        // Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        // Schema.RecordTypeInfo rtByName =  rtMapByName.get(type);
        // if (rtByName.getRecordTypeId()!=null) testAccount.REcordTypeId=rtByName.getRecordTypeId();
        
        // return testAccount;
    // }
    
}
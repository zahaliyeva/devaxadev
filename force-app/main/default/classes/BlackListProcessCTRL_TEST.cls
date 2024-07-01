/*------------------------------------------------------------------------
Author:        Davide fabris
Company:       Deloitte
Class:         BlackListProcessCTRL_TEST
Description:   Test for the VF page of insert for accounts
            
History

28/03/2017     Davide fabris - Created
----------------------------------------------------------------------------*/

@istest
public class BlackListProcessCTRL_TEST{

    @testSetup static void setup() {//preparing test database
        test.startTest();
        //Insert custom settings
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
        Apex_Schedulation_Manager__c ASM_CS= new Apex_Schedulation_Manager__c(
        Name='BulkRequestManager',
        Autoschedule__c=true,
        Expression__c='',
        Frequency__c=1,
        Scope__c=200,
        Send_Log__c=false
        );        
        insert ASM_CS;        
        
        
        //Some nodes for visibility
        List<Node__c> theNodes = new List<Node__c>();
        Node__c ManagerNode = new Node__c();
        ManagerNode.Node_level__c=6;
        ManagerNode.Node_unique_code__c='A001';
        ManagerNode.Parent_node_unique_code__c='TOP';
        ManagerNode.Tree_name__c='DIF';
        
        Node__c AgencyNode = new Node__c();
        AgencyNode.Node_level__c=7;
        AgencyNode.Node_unique_code__c='009999';
        AgencyNode.Parent_node_unique_code__c='A001';
        AgencyNode.Tree_name__c='DIF';
        
        Node__c SUBAgencyNode = new Node__c();
        SUBAgencyNode.Node_level__c=8;
        SUBAgencyNode.Node_unique_code__c='009999000001';
        SUBAgencyNode.Parent_node_unique_code__c='009999';
        SUBAgencyNode.Tree_name__c='DIF';
        
        
        List<Sobject> SoList = new List<Sobject>();
        SoList.add(AgencyNode);
        SoList.add(SUBAgencyNode);
        SoList.add(ManagerNode);

        Insert Solist;
        
        
        
        //Creating agent
        UserProvisioningAAI.UserDetailsInput UserInputAgent = new UserProvisioningAAI.UserDetailsInput();
        UserInputAgent.Active='0';
        UserInputAgent.FirstName='Agent';
        UserInputAgent.LastName='Agent';
        UserInputAgent.Email='agent@agent.it';
        UserInputAgent.UserName='agent@testpre.test';
        UserInputAgent.MyriamUserName = 'ag_agent';
        UserInputAgent.AgencyCode = '009999';
        
        UserProvisioningAAI.UserNodeInput theNode = new UserProvisioningAAI.UserNodeInput();
        theNode.NodeCode = '9999';
        theNode.NodeLevel = 7;
        theNode.Profile = 'NFE - AAI - Vendite Avanzato';
        theNode.Functionality = 'Manager';
        theNode.AdminFlag = true;
        List<UserProvisioningAAI.UserNodeInput> thenodelist = new List<UserProvisioningAAI.UserNodeInput>();
        thenodelist.add(theNode);
        
        UserInputAgent.Nodes = thenodelist;
        
        //preparing the answer
        UserProvisioningAAI.ServiceResult theanswer = new UserProvisioningAAI.ServiceResult();
        theanswer = UserProvisioningAAI.UpsertUserAAI(UserInputAgent);
        //system.debug('++++theanswer '+theanswer );
        
        
        //Creating SUB- agent
        UserProvisioningAAI.UserDetailsInput UserInputSUBAgent = new UserProvisioningAAI.UserDetailsInput();
        UserInputSUBAgent.Active='0';
        UserInputSUBAgent.FirstName='SUBAgent';
        UserInputSUBAgent.LastName='SUBAgent';
        UserInputSUBAgent.Email='SUBagent@agent.it';
        UserInputSUBAgent.UserName='SUBagent@test.test';
        UserInputSUBAgent.MyriamUserName = 'subag_subagent';
        UserInputSUBAgent.AgencyCode = '009999';
        
        UserProvisioningAAI.UserNodeInput theNodeSUB = new UserProvisioningAAI.UserNodeInput();
        theNodeSUB.NodeCode = '999900001';
        theNodeSUB.NodeLevel = 8;
        theNodeSUB.Profile = 'NFE - AAI - Vendite Avanzato';
        theNodeSUB.Functionality = 'User';
        theNodeSUB.AdminFlag = true;
        List<UserProvisioningAAI.UserNodeInput> thenodelistSUB = new List<UserProvisioningAAI.UserNodeInput>();
        thenodelistSUB.add(theNodeSUB);
        
        UserInputSUBAgent.Nodes = thenodelistSUB;
        
        //preparing the answer
        UserProvisioningAAI.ServiceResult theanswerSUB = new UserProvisioningAAI.ServiceResult();
        theanswerSUB = UserProvisioningAAI.UpsertUserAAI(UserInputSUBAgent);
        //system.debug('++++theanswer '+theanswerSUB );
        
        //Inserting some clients
        Account TheClient = new Account();
        TheClient.NDG__c='0099990000001138';
        RecordType PF_RT = [SELECT id from RecordType where DeveloperName ='B2C_Client' Limit 1];
        TheClient.RecordTypeId = PF_RT.Id;
        TheClient.LastName = 'Rossi';
        TheClient.FirstName = 'Maria';
        TheClient.CIF_Marital_Status__c = 'Coniugato/a';
        TheClient.CIF_Marital_Status_code__c = '1';
        TheClient.Nodes__c = '009999;999900001';
        TheClient.AAI_Agency_Reference_Code__c ='009999';
        TheClient.State__c ='ATTIVO';
        TheClient.CIF_Job__c ='Agricoltore';
        TheClient.AAI_Codice_fiscale__c = 'MSSGNN64P24L929I';
        
        insert TheClient;
        
        
        BulkRequestManager TheB = new BulkRequestManager();
        Database.ExecuteBatch(TheB);
        
        test.stopTest();
        
    }
    
    static testmethod void PageNodi(){ 
        PageReference pageRef = Page.BlackList;       
        Test.setCurrentPage(pageRef);
        User theAgent = [SELECT id from User where username='agent@testpre.test' Limit 1];
        system.runas(theAgent) {
            BlackListProcessCTRL ctrl = new BlackListProcessCTRL();
            string mystring = ctrl.AllNodes;
            ctrl.PageIsNodi();
            ctrl.PageIsClienti();
            ctrl.selectCampaign();
            string mystring2 = ctrl.AllCampaigns;
            
            ctrl.Auto=true;
            ctrl.Abitazione= true;
            ctrl.Infortuni= true;
            ctrl.Malattia= true;
            ctrl.Protection= true;
            ctrl.Saving= true;
            ctrl.Aziende= true;
            ctrl.Rinnovo= true;
            ctrl.Commerciale= true;
            ctrl.Servizio= false;
			ctrl.listProcess = new List<BlackListProcessCTRL.ProcessType>();
            //simple selection
            ctrl.SelectedNodesList='009999';
            ctrl.submitNodeRequest();
            
            //Forbidden selection
            ctrl.SelectedNodesList='0001';
            ctrl.submitNodeRequest();

            //reset
            ctrl.isreset=true;
            ctrl.SelectedNodesList='009999';
            ctrl.submitNodeRequest();
        }
    }

    private static List<String> getFields(){
        return new List<String>{
            'BlackList_Abitazione__c',
            'BlackList_Auto__c',
            'BlackList_Aziende__c',
            'BlackList_Infortuni__c',
            'BlackList_Malattia__c',
            'BlackList_Protection__c',
            'BlackList_Saving__c',
            'BlackList_Rinnovo__c',
            'BlackList_Commerciale__c',
            'BlackList_Servizio__c'
        };
    }

    //LUCA BASSANI - TEST - START
    static testmethod void setTuttiProdottiETutteCategorie(){
        List<String> fields = getFields();
        Map<String,String> fieldValues = new Map<String,String>();
        Account acc = [SELECT Id, NDG__c from Account where NDG__c='0099990000001138' LIMIT 1];
        fieldValues.put('BlackList_Processi__c','Rinnovi');
        User theAgent = [SELECT id from User where username='agent@testpre.test' Limit 1];
        system.runas(theAgent){
            BlackListProcessCTRL.ReturnClass result;
            result = BlackListProcessCTRL.saveClientiBlackList(new List<String>{'0099990000001138'}, fieldValues);
            acc = [SELECT Ultima_modifica_blacklist__c, BlackList_Abitazione__c, BlackList_Auto__c, BlackList_Aziende__c, BlackList_Infortuni__c, 
                   BlackList_Malattia__c, BlackList_Protection__c, BlackList_Saving__c, BlackList_Rinnovo__c, BlackList_Commerciale__c, BlackList_Servizio__c
                   FROM Account
                   WHERE NDG__c =: acc.NDG__c];
                   system.debug('result-->'+result);
            //system.assertEquals(result.prodotti,'Tutti');
            //system.assertEquals(result.campagne,'Tutte');
            //system.assertEquals(System.now().date(), acc.Ultima_modifica_blacklist__c.date());
            for(String field : fields){
                system.debug('acc.get(field)----->'+field+'=>'+acc.get(field));
                //system.assertEquals(acc.get(field),true);
            }
        }
    }

    static testmethod void setUnProdottoEUnaCategoria(){
        List<String> fields = getFields();
        Map<String,String> fieldValues = new Map<String,String>();
        Account acc = [SELECT Id,NDG__c from Account where NDG__c='0099990000001138' LIMIT 1];
        fieldValues.put('BlackList_Processi__c','Rinnovi');
        
        User theAgent = [SELECT id from User where username='agent@testpre.test' Limit 1];
        system.runas(theAgent){
            BlackListProcessCTRL.ReturnClass result;
            result = BlackListProcessCTRL.saveClientiBlackList(new List<String>{'0099990000001138'}, fieldValues);
            acc = [SELECT Ultima_modifica_blacklist__c, BlackList_Abitazione__c, BlackList_Auto__c, BlackList_Aziende__c, BlackList_Infortuni__c, 
                   BlackList_Malattia__c, BlackList_Protection__c, BlackList_Saving__c, BlackList_Rinnovo__c, BlackList_Commerciale__c, BlackList_Servizio__c
                   FROM Account
                   WHERE NDG__c =: acc.NDG__c];
            //system.assertEquals(result.prodotti,'Abitazione');
            //system.assertEquals(result.campagne,'Commerciale');
            //system.assertEquals(System.now().date(), acc.Ultima_modifica_blacklist__c.date());
            /*for(String field : fields){
                if(field != 'BlackList_Abitazione__c' && field != 'BlackList_Commerciale__c')
                    //system.assertEquals(acc.get(field),false);
            }*/
            //system.assert(acc.BlackList_Abitazione__c);
            //system.assert(acc.BlackList_Commerciale__c);
        }
    }

    static testmethod void setPiuProdottiEPiuCategorie(){
        List<String> fields = getFields();
        Map<String,string> fieldValues = new Map<String,String>();
        Account acc = [SELECT Id,NDG__c from Account where NDG__c='0099990000001138' LIMIT 1];
        
        
        fieldValues.put('BlackList_Processi__c','Rinnovi');
        

        BlackListProcessCTRL.ReturnClass result;
        result = BlackListProcessCTRL.saveClientiBlackList(new List<String>{'0099990000001138'}, fieldValues);
        //system.assertEquals(result.prodotti,'Abitazione, Auto');
        //system.assertEquals(result.campagne,'Commerciale, Servizio');
    }
    //LUCA BASSANI - TEST - END
    
    static testmethod void ValidaPagina(){
        BlackListProcessCTRL.ReturnClass result;
        result = BlackListProcessCTRL.validateClients(new List<String>{'0099990000001138'});

    }
    
    
    static testmethod void getMembers_NoFilter(){
        User theAgent = [SELECT id from User where username='agent@testpre.test' Limit 1];
        system.runas(theAgent) {
            BlackListProcessCTRL.getCampaignMember('','','','',true,'');
        }
    }

    static testmethod void getMembers_1(){
        User theAgent = [SELECT id from User where username='agent@testpre.test' Limit 1];
        system.runas(theAgent) {
            BlackListProcessCTRL.getCampaignMember(' AND CampaignId = \'nckjdsanckjdsan\'','TestSurname','TestName','',true,'B2C');
        }
    }
    
    static testmethod void getMembers_2(){
        User theAgent = [SELECT id from User where username='agent@testpre.test' Limit 1];
        system.runas(theAgent) {
            BlackListProcessCTRL.getCampaignMember(' AND CampaignId = \'nckjdsanckjdsan\'','','','TestName',true,'B2B');
        }
    }
    
    
}
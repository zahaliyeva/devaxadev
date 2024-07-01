@isTest
public class SvalidazioneCampagneCTRL_Test {
    @testSetup static void setup(){
    Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
    id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');

    Campaign camp1 = new Campaign(Name = 'Test Campaign 1',
    Startdate = system.today()-1,
    enddate = system.today()+2,
    Type = 'TCM',
    Status = 'On-going');
    insert camp1;

    Account acc1 = new Account( 
    FirstName = 'Sheldon',
    LastName = 'Last',
    Nodes__c = '001622,001622000124',
    PersonEmail = 'account@mail.test1',
    Ccod_Produttore__c='001622000124',
    RecordTypeID = account_B2C);

    insert acc1;

    Account acc2 = new Account( 
    FirstName = 'Leonard',
    LastName = 'Last',
    Nodes__c = '001622,001622000123',
    Ccod_Produttore__c='001622000123',
    RecordTypeID = account_B2C);

    insert acc2;
    List <contact> c=[select id, accountid from contact limit 2];

    campaignMember campm1= new campaignMember(  
        Status='Da assegnare',
        CampaignId=camp1.id,
        Stato_Adesione__c = 'ESCLUSO',
        ContactId=c[0].id,
        NeedAsyncBatchExecution__c=true);
    insert campm1;

    campaignMember campm2= new campaignMember(  
        Status='Da assegnare',
        CampaignId=camp1.id,
        Stato_Adesione__c = 'Incluso',
        ContactId=c[1].id,
        NeedAsyncBatchExecution__c=true);
        insert campm2;

        Node__c nodo = new Node__c ();
        nodo.Agency_holder__c = 'NODO Holder';
        nodo.Node_unique_code__c= '000024';
        nodo.Parent_node_unique_code__c= 'A001';
        nodo.Tree_name__c= 'DIF';
        nodo.Blacklist_Processi__c= 'Rinnovi';
        nodo.Node_description__c= 'Agency Away from Home';
        nodo.Node_level__c= 8;
        
        NodeHandler.setDeactivateTrigger(true);//avoid trigger for this node, non rules 
        insert nodo ;

    }
    public static testMethod void AllClass(){

        Campaign campagna = [Select id,Name from Campaign limit 1];

        list<campaignMember> listaCM = [Select id,Name from campaignMember where CampaignId =: campagna.id];

        SvalidazioneCampagneCTRL.getListCampaignForRT('Marketing_campaign');
        SvalidazioneCampagneCTRL.getListCampaignForRT('Informative_Campaign');

        String listaIds = '';
        for(campaignMember temp:listaCM)
            listaIds += ';' + String.valueOf(temp.id);

        SvalidazioneCampagneCTRL.getCampaignMembersFilterAll ( String.valueOf(campagna.id) ,  '001622' , '001622000123', 'No', '1900-01-01', '2100-01-01');
        SvalidazioneCampagneCTRL.modificaAdessione_Incl_or_esclude(listaIds,String.valueOf(campagna.id));
        SvalidazioneCampagneCTRL.validaPagina(listaIds);
        SvalidazioneCampagneCTRL.getListNodesByUser();
        SvalidazioneCampagneCTRL.getListNodoOmniaByUser();
        SvalidazioneCampagneCTRL.getListNodoOmniaByCampaign(String.valueOf(campagna.id));

    }
}
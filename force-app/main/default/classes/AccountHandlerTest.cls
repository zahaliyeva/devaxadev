@isTest
public class AccountHandlerTest{
    static testmethod void TestAccountHandler(){
    
    Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
    id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');
    id agencyRT = UtilityClass.getRTid(rtypes, 'Account', 'Agency');
    
    AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
    insert acv;
    
    //Create Account
    Account b2cClient1 = new Account(FirstName = 'Test',
                                     LastName = 'B2C Account',
                                     RecordTypeId = account_B2C,
                                     Nodes__c = '000024');
                                      
    insert b2cClient1;

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


    List<Account> accounts = new  List<Account>();
    List<id> accountsIDs = new  List<id>();

    Account Agency1 = new Account(name = 'Agencia1',
                            Agency_Code__c='000024',
                                 TECH_COMPANY__C = 'AAI',
                                     RecordTypeId = agencyRT);
                                      
   accounts.add(Agency1);

    Account Agency2 = new Account(name = 'Agencia2',
    Agency_Code__c='000026',
         TECH_COMPANY__C = 'AAI',
             RecordTypeId = agencyRT);
              
    accounts.add(Agency2);
    
    insert accounts;
    accountsIDs.add(Agency1.id);
    accountsIDs.add(Agency2.id);
   
    user u = [select id,Profile.Name from user where  Profile.Name like 'System%' and IsActive=true limit 1 ];

    system.runAs(u){
            //Modify Account
        b2cClient1.TECH_COMPANY__C  = 'AAI';
        b2cClient1.FirstName = 'Test2';      
        b2cClient1.AAI_Agency_Reference_Code__c  = Agency2.Agency_Code__c;
        b2cClient1.NeedAsyncTriggerExecution__c  = true;
        update b2cClient1;
        b2cClient1.Nodes__c  += ';000024000024000010';
        update b2cClient1;

        AccountHandler.setTechnicalUserOwnerId(accountsIDs);
        AccountHandler.setDeactivateTrigger(true);
        AccountHandler.checkCSVisibility();
        AccountHandler.DeactivateTrigger();
        delete b2cClient1;
        undelete b2cClient1;    
    }

    }

}
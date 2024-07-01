@IsTest 
public class CommunicationToCustomerHandlerTest {
   
    public @testSetup static void setup() 
    {
        final ID migrazioniProcesDigitalRecordTypeId = Schema.SObjectType.Communications_to_customer__c.getRecordTypeInfosByDeveloperName().get('Migrazione_Processi_Digital').getRecordTypeId();
        final ID pianoEditorialRecordTypeId = Schema.SObjectType.Communications_to_customer__c.getRecordTypeInfosByDeveloperName().get('Piano_Editoriale').getRecordTypeId();  
        final ID standarComRecordTypeId = Schema.SObjectType.Communications_to_customer__c.getRecordTypeInfosByDeveloperName().get('Standard_Communication').getRecordTypeId();
        final ID b2cRTAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2C_Client').getRecordTypeId();
        
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='PushNotification_Use_Iniz_Template', Value__c='true');
        insert acv;

        Iniziative_Marketing__c iniziativaM = new Iniziative_Marketing__c();
        iniziativaM.Communication_Code__c = 'push_notification';
        iniziativaM.Titolo__c = 'Titolo Texto';
        iniziativaM.Sottotitolo__c = 'Sottot Texto';
        iniziativaM.Contenuto__c = 'Html Texto conWild cards %%Nome%% in piu %%Insurance_Contract_Number__c%%';
        iniziativaM.Short_Message__c = 'mess Texto';
        iniziativaM.Attiva__c = true;
        
        insert iniziativaM;

        Account acc = new Account();
        acc.Firstname='Sheldon';
        acc.LastName='Cooper';
        acc.Mobile_Master_AAI__c = '+6666666666666';
        acc.Email_Master_AAI__c = 'killer@inst.invalid';
        acc.RecordTypeId = b2cRTAccount;

        insert acc;


        List<Communications_to_customer__c> listCommToCustomer = new List<Communications_to_customer__c>();
        Communications_to_customer__c comm2cust1 = new Communications_to_customer__c();
        Communications_to_customer__c comm2cust2 = new Communications_to_customer__c();
        
        comm2cust1.AccountId__c= acc.id;
        comm2cust1.RecordTypeId = migrazioniProcesDigitalRecordTypeId;
        comm2cust1.Communication_Code__c = 'push_notification';
        comm2cust1.Insurance_Contract_Number__c = '114484844411';

        comm2cust2.AccountId__c= acc.id;
        comm2cust2.RecordTypeId = standarComRecordTypeId;
        comm2cust2.Communication_Code__c = 'push_notification';
        comm2cust1.Insurance_Contract_Number__c = '1236857454';
        
        
        listCommToCustomer.add(comm2cust1);
        listCommToCustomer.add(comm2cust2);

        insert listCommToCustomer;

        MPS_Code_Utils__mdt ecollab_dashboard = MPS_Code_Utils__mdt.getInstance('PushFase2_Ecollab_DashboardId');
        List<Target__c> listTarget = new List<Target__c>();
        for (Integer i=0;i<5;i++) {
            Target__c target1 = new Target__c();
            target1.Name = 'target'+i;
            target1.Dashboard_ID__c = ecollab_dashboard.Value__c;
            target1.Descrizione__c = 'desc';
            target1.Active__c = true;
            listTarget.add(target1);
        }
        insert listTarget;

    }

    @IsTest
    static void metodo1(){

        CommunicationToCustomerHandler triggercomm = new CommunicationToCustomerHandler();
        
        SObject so =[select id,AccountId__c,RecordTypeId,Communication_Code__c from Communications_to_customer__c limit 1];

        List<SObject> lista = [select id,AccountId__c,RecordTypeId,Communication_Code__c from Communications_to_customer__c];

        triggercomm.beforeUpdate(so, so);
   
        triggercomm.beforeUpdate(lista,lista);
    
        triggercomm.beforeDelete(so);
    
        triggercomm.beforeDelete(lista);

        triggercomm.afterUpdate(so, so);

        triggercomm.afterUpdate(lista,lista);

        triggercomm.afterDelete( so); 
    
        triggercomm.afterUndelete( so); 
    
        triggercomm.afterDelete(lista);  

        triggercomm.afterUndelete( lista);         

    }
}
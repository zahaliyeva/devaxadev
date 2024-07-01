/*------------------------------------------------------------------------
Author:        --
Company:       --
Class:         BatchRunPolizzaTriggersTest
Description:   Test class for BatchRunPolizzaTriggers class

History

29/11/2021     Created - *-+

----------------------------------------------------------------------------*/
@istest
global without sharing class BatchRunPolizzaTriggersTest {
    @TestSetup static void setup(){
        
        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id account_B2B = UtilityClass.getRTid(rtypes, 'Account', 'B2B_Client');
        id rt_vita = UtilityClass.getRTid(rtypes, 'InsurancePolicy__c', 'Vita');
        id rt_motor = UtilityClass.getRTid(rtypes, 'InsurancePolicy__c', 'B2C_Motor');
        id rt_general = UtilityClass.getRTid(rtypes, 'InsurancePolicy__c', 'General_RecordType');
    
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());

        insert acv;

        Group g1 = new Group(DeveloperName='DIF_123456',Name='DIF_123456',Type='Regular');
     
        insert g1;

        //CUID_Nodes__c
        //set true disable trigger for account with Accounthandler
        PolizzaHandler.setDeactivateTrigger(true);
        System.runAs(new User(Id=UserInfo.getUserId()))
        {

            Account policyHolder = new Account (Name='Sheldon Cooper',NeedAsyncTriggerExecution__c=true,
                                            RecordTypeId =account_B2B,Nodes__c = '123456;');
            insert policyHolder ;

            InsurancePolicy__c polizzaVita = new InsurancePolicy__c(
                name='polizzavita', NeedAsyncTriggerExecution__c=true,
                CUID__c=policyHolder.id, RecordTypeId=rt_vita, TECH_Company__c  = 'AAI', Nodes__c='123456;'
            );
            InsurancePolicy__c polizzaMotor = new InsurancePolicy__c(
                name='polizzaMoto', NeedAsyncTriggerExecution__c=true,
                CUID__c=policyHolder.id, RecordTypeId=rt_motor, TECH_Company__c  = 'AAI', Nodes__c='123456;'
            );
            InsurancePolicy__c polizzaGeneral = new InsurancePolicy__c(
                name='polizzaGEn', NeedAsyncTriggerExecution__c=true,
                CUID__c=policyHolder.id, RecordTypeId=rt_general, TECH_Company__c  = 'AAI', Nodes__c='123456;'
            );
            insert polizzaVita ;
            insert polizzaMotor ;
            insert polizzaGeneral ;
        
        }// as user NOW
        Test.startTest();
        BatchRunPolizzaTriggers obj = new BatchRunPolizzaTriggers();
        DataBase.executeBatch(obj);
        Test.stopTest();

    }

    @IsTest
    static void executeTestForSharingPolizza() {

        list <InsurancePolicy__Share> polizza_shareds = [select UserOrGroupId, ParentId, AccessLevel, RowCause 
                                                    from InsurancePolicy__Share where RowCause = 'Manual'];
                                            
        list <Group> groups = [select id, name  from group where DeveloperName like 'DIF_123456%'] ;
    
        list <Id> idGrupos = new list<Id>();
        for (Group grupo : groups)
        idGrupos.add(grupo.id);

        InsurancePolicy__c polizzaMoto = [select id,NeedAsyncTriggerExecution__c from InsurancePolicy__c where name like 'polizzaMoto%' limit 1] ;
 
        list <InsurancePolicy__Share> polizzaMotoShared = [select UserOrGroupId, ParentId, AccessLevel, RowCause 
                                                         from InsurancePolicy__Share where RowCause = 'Manual' 
                                                         and ParentId =: polizzaMoto.id
                                                         and UserOrGroupId in : idGrupos];

        
        System.assert(polizza_shareds.size()!=0, 'Non Empty List if Manual Sharing Works');
        
        System.assertEquals(polizzaMotoShared.size(),1, 'Polizza Moto is Shared on ONE group');

        System.assert(!polizzaMoto.NeedAsyncTriggerExecution__c,'Polizza Update OK--Need Trigger field is FALSE');


    }
}
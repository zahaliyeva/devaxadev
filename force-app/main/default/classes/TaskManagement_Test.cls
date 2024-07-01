/*  
    created by *-+ 02/09/2022
    test class for coverage 
 */


@isTest
public class TaskManagement_Test {
    @testSetup static void setup() {

        final ID b2cRTAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2C_Client').getRecordTypeId();
        final ID caseAxa = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Axa_Assicurazioni').getRecordTypeId();
        final ID caseNonMotor = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NonMotor').getRecordTypeId();
     
        List<id> RecTypeList = new  List<id> ();
        RecTypeList.add(caseAxa);
        RecTypeList.add(caseNonMotor);
        // ('Axa_Assicurazioni','NonMotor')

        List<MPS_Code_Variables__c> settingsList = new List<MPS_Code_Variables__c>();
        MPS_Code_Variables__c setting = new MPS_Code_Variables__c();
        setting.Name = 'GDPR_Hierarchylevel1';
        setting.Value__c = 'DPO';
        settingsList.add(setting);
        MPS_Code_Variables__c setting2 = new MPS_Code_Variables__c();
        setting2.Name = 'GDPR_Category';
        setting2.Value__c = 'GDPR';
        settingsList.add(setting2);

        insert settingsList;


        Account acc = new Account();
        acc.Firstname='Sheldon';
        acc.LastName='Cooper';
        acc.Nodes__c = '001622;001622000070';
        acc.AAI_Agency_Reference_Code__c = '001622  ';
        acc.Type = 'Bank Agent';
        acc.Mobile_Master_AAI__c = '+6666666666666';
        acc.Email_Master_AAI__c = 'killer@inst.invalid';
        acc.RecordTypeId = b2cRTAccount;

        //insert acc;
        Contact contTemp = new Contact();
        contTemp.LastName = 'Cooper';
        insert contTemp;

        
        Knowledge__kav knowledgArt = new Knowledge__kav(UrlName    = 'ApexTestName'); 
        knowledgArt.Title = 'ApexTestName';
        knowledgArt.CaseManagement_Send_Email_Notification__c = false;
        Insert knowledgArt; 

        CaseHandler.RunTrigger = false;

        List<Case> CaseList = new List<Case>();
        Case temp = new Case(AccountId = acc.id, RecordTypeId = RecTypeList[0], Lob__c = 'Private Area and My Axa',Category__c = 'Richiesta codice sconto', Description = 'Test 1', SuppliedEmail = 'Test@test.it',SuppliedPhone = '11111111');
        temp.Data_primo_Task_DPO__c = System.now();
        temp.Data_primo_task_interno__c = System.now();
        CaseList.add(temp);
        Case temp1 = new Case (AccountId = acc.id, RecordTypeId = RecTypeList[0], Lob__c = 'Privacy',Category__c = 'test', Description = 'Test 2',SuppliedEmail = 'Test@test.it',SuppliedPhone = '11111111',Flag_Ivass41__c = true);
        temp1.Data_primo_Task_DPO__c = System.now();
        temp1.Data_primo_task_interno__c = System.now();
        CaseList.add(temp1);

        insert CaseList;

        //   tarea.HierarchyLevel1__c = 'DPO';
        List<Task> TasKlst = new List<Task>{
            new Task(WhatID = temp.id,Subject='Sample Task1',Priority='Normal',HierarchyLevel1__c='DPO',HierarchyLevel2__c='Commercial Line',HierarchyLevel3__c='Pre-sales Advice',Status='In progress'),
            new Task(WhatID = temp.id,Subject='Sample Task1',Priority='Normal',HierarchyLevel1__c='GDPR',HierarchyLevel2__c='GDPR1',HierarchyLevel3__c='GDPR2',Status='Open')    
            };
        insert TasKlst;
    
    }

    public @IsTest
    static void method1(){
        

        Contact accSheldon = [select id from Contact limit 1];
        Knowledge__kav articolo = [select id from Knowledge__kav limit 1];

        Task tarea = new task();

        tarea.OwnerId = UserInfo.getUserId();
        tarea.Subject='Donni';
        tarea.Status='Not Started';
        tarea.Priority='Normal';
        tarea.WhoId = accSheldon.id;
        tarea.Type = 'Email';

        tarea.TECH_ArticleVersionId__c = articolo.id ;
        tarea.TECH_ArticleFeedbackSource__c = 'Sito AXA' ;
        tarea.TECH_ArticleFeedbackVote__c = 'Thumbs_up' ;

        TaskManagement.saveTaskFromLWC(tarea);
        TaskManagement.RemainingObject tempObject = new TaskManagement.RemainingObject();
        list<task> TaskToDelete = [Select id from task];
        List<Id> idTaskToDelete = new List<Id>(new Map<Id, task>(TaskToDelete).keySet());
        TaskManagement.DeleteTasks deleteInstansce = new TaskManagement.DeleteTasks(idTaskToDelete);
        
    }

    public @IsTest 
    static void method2_triggerHandlerTask(){


        List<Task> created = [Select id, whatId, description from Task];
     
        for(task taskTemp: created){
            system.debug('temp: '+taskTemp);
            taskTemp.description = taskTemp.description+'passByTestClass';
            taskTemp.Status = 'Completed';
        }
        system.debug('Task created by case *-+'+created.size());
        update created;

        TaskHandler taskHandlerInst = new TaskHandler();

        taskHandlerInst.afterInsert(created);
        taskHandlerInst.afterUpdate(created,created);
       
        taskHandlerInst.beforeInsert(created[0]);
        taskHandlerInst.beforeUpdate(created,created);
        taskHandlerInst.beforeUpdate(created[0],created[0]);
        
        taskHandlerInst.beforeDelete(created[0]);
        taskHandlerInst.beforeDelete(created);
        taskHandlerInst.afterDelete(created);
        taskHandlerInst.afterUndelete(created);
        delete created;

    }
}
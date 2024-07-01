@isTest
public class TaskHandlerTest {
    @isTest static void method1(){
       AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv; 
        RecordType cpRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'Agency_campaign'];
        List<Campaign> allCampaigns = new List<Campaign>{
            new Campaign(
                Name = 'CampagnaTest',
                IsActive = true,
                Status = 'On-going',
                RecordTypeID = cpRT.Id      
            ),
            new Campaign(
                Name = 'CampagnaTest_Previous',
                IsActive = false,
                Status = 'Completed',
                RecordTypeID = cpRT.Id    
            )
        };
        insert allCampaigns;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
                
                RecordType accRT = [SELECT Id,IsPersonType FROM RecordType WHERE SObjectType = 'Account' and DeveloperName = 'B2C_Client' ];
                List<Account> accountz = new List<Account>{
                 new Account(
                FirstName = 'AccountTest99',
                LastName = 'AccountTest00',
                PersonEmail = 'account@mail.test',
                Phone = '0333333333',
                PersonMobilePhone = '3333333333',
                Nodes__c = '005014',
                RecordTypeID = accRT.id
            ),new Account(
                FirstName = 'AccountTest11',
                LastName = 'AccountTest22',
                PersonEmail = 'account@mail.test',
                Phone = '03333333331111',
                PersonMobilePhone = '3333333333111',
                Nodes__c = '005014',
                RecordTypeID = accRT.id
            )};
            insert accountz;
            List<account> allacc = [SELECT Id,PersonContactId,IsPersonAccount,RecordTypeId FROM Account WHERE PersonEmail= 'account@mail.test'];
        	account acc=allacc.get(0);
        	account acc2=allacc.get(1);
             Lead ld = new Lead(
            LastName = 'LeadTest',
            FirstName = 'test',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            MobilePhone = '3333333333'
        );
        insert ld;
            List<CampaignMember> campaignMembers = new List<CampaignMember>{
            new CampaignMember(
                LeadId = ld.Id, 
                ContactId = acc.PersonContactId,
                CampaignId = allCampaigns[0].Id,
                Owner__c = userinfo.getUserId(),
                Status = 'Interessato',
                Sottostato__c='Inviata Email',   
                Note__c = 'NoteTest'       
            ),
            new CampaignMember(
                LeadId = ld.Id, 
                ContactId = acc2.PersonContactId,
                CampaignId = allCampaigns[0].Id,
                Owner__c = userinfo.getUserId(),
                Status = 'Da contattare',
                Sottostato__c='Richiesta di contatto da Email',  
                Note__c = 'NoteTest2'       
            )
        };
        insert campaignMembers;

        List<Task> campaignTasks = new List<Task>{
            new Task(
                Subject = 'ContattoTEST',
                TECH_SourceId__c = campaignMembers[0].Id       
            ),
            new Task(
                Subject = 'ContattoTEST2',
                TECH_SourceId__c = campaignMembers[1].Id      
            )
        };
            Case temp1 = new Case (AccountId = acc.id, RecordTypeId = accRT.id, Lob__c = 'Privacy',Category__c = 'test', Description = 'Test 2',SuppliedEmail = 'Test@test.it',SuppliedPhone = '11111111',Flag_Ivass41__c = true);
            insert campaignTasks;
            task t=new task();
            t.Subject='ContattoTEST2';
            t.TECH_SourceId__c = campaignMembers[1].Id;
            t.WhatId=temp1.id;
            
            insert t;
            t.Subject='prova';
            update t;
            TaskHandler task = new TaskHandler();
            delete t;
            delete campaignTasks;
            CaseHandler.RunTrigger = false;
            
        final ID caseAxa = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Axa_Assicurazioni').getRecordTypeId();
        List<Case> CaseList = new List<Case>();
        Case temp = new Case(AccountId = acc.id, RecordTypeId = caseAxa, Lob__c = 'Private Area and My Axa',Category__c = 'Richiesta codice sconto', Description = 'Test 1', SuppliedEmail = 'Test@test.it',SuppliedPhone = '11111111');
        temp.Data_primo_Task_DPO__c = System.now();
        temp.Data_primo_task_interno__c = System.now();
        CaseList.add(temp);
        Case temp2 = new Case (AccountId = acc.id, RecordTypeId = caseAxa, Lob__c = 'Privacy',Category__c = 'test', Description = 'Test 2',SuppliedEmail = 'Test@test.it',SuppliedPhone = '11111111',Flag_Ivass41__c = true);
        temp2.Data_primo_Task_DPO__c = System.now();
        temp2.Data_primo_task_interno__c = System.now();
        CaseList.add(temp2);

        insert CaseList;

        //   tarea.HierarchyLevel1__c = 'DPO';
        List<Task> TasKlst = new List<Task>{
            new Task(WhatID = temp.id,Subject='Sample Task1',Priority='Normal',HierarchyLevel1__c='DPO',HierarchyLevel2__c='Commercial Line',HierarchyLevel3__c='Pre-sales Advice',Status='In progress'),
            new Task(WhatID = temp.id,Subject='Sample Task1',Priority='Normal',HierarchyLevel1__c='GDPR',HierarchyLevel2__c='GDPR1',HierarchyLevel3__c='GDPR2',Status='Open')    
            };
        insert TasKlst;
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
            
            
        }
    }
}
/*
*******************************************************************************************************
-------------------------------------------------------------------------------------------------------
-- - Name          : AP13_TaskAutomaticOpening
-- - Author        : Marco Moscatelli
-- - Description   : Apex Class invoked by trigger CaseAfterInsert used to create automatically new 
-- -                 Tasks for a new Case having specific characteristics, described into the dashboard
-- -                 "Apertura automatica Task"  
--
-- Maintenance History:
--
-- Date          Version  Remarks
-- -----------  -------  ------------------------------------------------------------------------------
-- 12-09-2016   1.0     
-------------------------------------------------------------------------------------------------------
*******************************************************************************************************
*/

global class AP13_TaskAutomaticOpening
{
    @future
    public static void CreateTask(Set<Id> IdOfCases)
    {
        system.debug('#### Start of class AP13_TaskAutomaticOpening ###');
        
        List<Case> ListOfCases = [Select Id,Casenumber,Origin,RecordType.developername,Category__c,SubCategory__c,Distribution_Network__c,Customer_Service_Model__c,Owner.Name,OwnerId,Complainant__c,AgentName__r.Name,Account.Name,Prodotto__c from Case where id in:IdOfCases and isClosed=false ]; // NOPMD  Fix CRUD violation
        Map<String, Apertura_automatica_Task__c> ConfigMap= new Map<String, Apertura_automatica_Task__c>();
        List<Task> NewTasksList = new List<Task>();
        Map<Id,Case> MapOfCases = new map<Id,Case>(ListOfCases);        
        List<Case> CaseToUpdateList = new List<Case>();
        List<Id> TechOffUsersId = new List<Id>();        
        Set<Task> SendEmailToTaskSet = new Set<Task>();
        Set<Id> AvoidUpdateforCaseSet = new Set<Id>();
        Set<Id> AllowUpdateforCaseSet = new Set<Id>();
        Set<Id> CheckTaskOnCaseSet    = new Set<Id>();
        Set<Id> TaskCorrectlyCreatedSet = new Set<Id>();                 
        Map<String,Id> MapRTTask = new Map<String,Id>();
        Map<String,String> MapModelliServizio = new map<String,String>();
        Map<String,Configurazione_SLA_Uffici_Tecnici__c> MapTaskSLAConfigurations = new map<String,Configurazione_SLA_Uffici_Tecnici__c>();
        Boolean isPrivate = false;
        Decimal TaskSLA;
        String CustServModel;
        String TaskHierarchyLevel1='';
        String TaskHierarchyLevel2='';
        String TaskHierarchyLevel3='';
        String TaskSubject='';
        String TaskKey = '';        
        String defaultHoursId='';
        String bhGDPR='';
        String HoursToUse = '';

        //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
        Set<Id> SmartCenterUser = new Set<Id>();
        String [] SmartProfile = new String[]{'SmartCenter AMF Advisor','SmartCenter AMF Manager','SmartCenter Motor Advisor','SmartCenter Motor Manager','SmartCenter Non Motor Advisor','SmartCenter Non Motor Manager'};

        for(User u :[Select Id from User where IsActive = true and Profile.Name in: SmartProfile ]) // NOPMD  Fix CRUD violation
        {
            SmartCenterUser.add(u.Id);
        }
        //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END

        for(BusinessHours bh: [select Id,IsDefault,Name from BusinessHours where IsActive =true ]) // NOPMD  Fix CRUD violation
        {
            if(bh.Name == 'Default')
                defaultHoursId = bh.Id;
            else if(bh.Name == 'GDPR')
                bhGDPR = bh.Id;
        }

        List<String> GDPRHierarchyLevels = new List<String>();
        List<String> GDPRCategories = new List<String>(); 

        for(MPS_Code_Variables__c MPSCv: MPS_Code_Variables__c.getAll().values())
        {
            if((MPSCv.Name).contains('GDPR_Hierarchylevel1'))
                GDPRHierarchyLevels.add(MPSCv.Value__c);

            if((MPSCv.Name).contains('GDPR_Category'))
                GDPRCategories.add(MPSCv.Value__c);            
        }           
        
        //MOSCATELLI_M 17/11/2016:EVO 70 -- START                
        Set<String> VIPCharacteristicsSet = new Set<String>();
        
        for(VIPCustomersCharacteristics__c  VIPChar: VIPCustomersCharacteristics__c.getAll().values())
        {
            VIPCharacteristicsSet.add(VIPChar.Case_Category__c);
        }
        system.debug('##VIPCharacteristicsSet: '+VIPCharacteristicsSet);
        //MOSCATELLI_M 17/11/2016:EVO 70 -- END
        
        for(Configurazione_SLA_Uffici_Tecnici__c ConfSLA :[Select id,SLA__c,SLA_for_Private_Customers__c,Hierarchy_Level_1__c,Hierarchy_Level_2__c,Hierarchy_Level_3__c,Task_Record_Type__c,Customer_Service_Type__c from Configurazione_SLA_Uffici_Tecnici__c where Rule_Active__c = true ]) // NOPMD  Fix CRUD violation
        {
            MapTaskSLAConfigurations.put(ConfSLA.Hierarchy_Level_1__c+'-'+ConfSLA.Hierarchy_Level_2__c+'-'+ConfSLA.Hierarchy_Level_3__c+'-'+ConfSLA.Task_Record_Type__c+'-'+ConfSLA.Customer_Service_Type__c,ConfSLA);
        }  
        
        for(Definizione_Modelli_di_Servizio__c ModServ:[Select Customer_Typology__c, Modello_di_Servizio__c from Definizione_Modelli_di_Servizio__c ]) // NOPMD  Fix CRUD violation
        {
            MapModelliServizio.put(ModServ.Modello_di_Servizio__c, ModServ.Customer_Typology__c);
        }
        
        for(RecordType TaskRT:[Select Id, Developername from RecordType where SObjectType = 'Task' ]) // NOPMD  Fix CRUD violation
        {
            MapRTTask.put(TaskRT.Developername, TaskRT.Id);
        }
        
        for(Apertura_automatica_Task__c AutoTask: [Select Id,Case_Origin__c,Case_Record_Type__c,Category__c,Sub_Category__c,Distribution_Network__c,Hierarchy_Level_1__c,Hierarchy_Level_2__c,Hierarchy_Level_3__c,Task_Subject__c,Technical_Office_Users_Ids__c from Apertura_automatica_Task__c where Rule_Active__c=:true ]) // NOPMD  Fix CRUD violation
        {
            ConfigMap.put(AutoTask.Case_Origin__c+'_'+AutoTask.Case_Record_Type__c+'_'+AutoTask.Category__c+'_'+AutoTask.Sub_Category__c+'_'+AutoTask.Distribution_Network__c, AutoTask);
        }
        
        if(ConfigMap.size()>0)
        {
            for(Case SelectedCase : ListOfCases)
            {
                HoursToUse = GDPRCategories.contains(SelectedCase.Category__c)?bhGDPR:defaultHoursId;
                
                //MOSCATELLI_M 17/11/2016:EVO 70 -- START
                Boolean isVIPCustomer = false;
                
                if(String.isNotBlank(SelectedCase.Category__c) || String.isNotBlank(SelectedCase.Prodotto__c))
                {
                    if(VIPCharacteristicsSet.contains(SelectedCase.Category__c) || VIPCharacteristicsSet.contains(SelectedCase.Prodotto__c))
                        isVIPCustomer = true;
                }
                //MOSCATELLI_M 17/11/2016:EVO 70 -- END
                               
             
                if(ConfigMap.containsKey(SelectedCase.Origin+'_'+SelectedCase.RecordType.developername+'_'+SelectedCase.Category__c+'_'+SelectedCase.SubCategory__c+'_'+SelectedCase.Distribution_Network__c))
                {
                    Case CaseToUpdate = new Case(Id = SelectedCase.Id,Status=Ap_Constants.caseStatusDelegated,RequiredAutomaticTaskOpening__c=true);
                    //CaseToUpdateList.add(CaseToUpdate);
                    TaskKey = System.Now()+'-'+SelectedCase.id;
                    Integer BackupTaskCount = 0;
                    
                    TechOffUsersId.clear();
                    TechOffUsersId     = (ConfigMap.get(SelectedCase.Origin+'_'+SelectedCase.RecordType.developername+'_'+SelectedCase.Category__c+'_'+SelectedCase.SubCategory__c+'_'+SelectedCase.Distribution_Network__c).Technical_Office_Users_Ids__c).split(';');
                    TaskHierarchyLevel1 = ConfigMap.get(SelectedCase.Origin+'_'+SelectedCase.RecordType.developername+'_'+SelectedCase.Category__c+'_'+SelectedCase.SubCategory__c+'_'+SelectedCase.Distribution_Network__c).Hierarchy_Level_1__c;
                    TaskHierarchyLevel2 = ConfigMap.get(SelectedCase.Origin+'_'+SelectedCase.RecordType.developername+'_'+SelectedCase.Category__c+'_'+SelectedCase.SubCategory__c+'_'+SelectedCase.Distribution_Network__c).Hierarchy_Level_2__c;                    
                    TaskHierarchyLevel3 = ConfigMap.get(SelectedCase.Origin+'_'+SelectedCase.RecordType.developername+'_'+SelectedCase.Category__c+'_'+SelectedCase.SubCategory__c+'_'+SelectedCase.Distribution_Network__c).Hierarchy_Level_3__c;                     
                    TaskSubject      = ConfigMap.get(SelectedCase.Origin+'_'+SelectedCase.RecordType.developername+'_'+SelectedCase.Category__c+'_'+SelectedCase.SubCategory__c+'_'+SelectedCase.Distribution_Network__c).Task_Subject__c;
                    
                    if(GDPRHierarchyLevels.contains(TaskHierarchyLevel1))
                        CaseToUpdate.Status = AP_Constants.caseStatusInAttesaDPO;

                   // CaseToUpdateList.add(CaseToUpdate);
                    //CAPOBIANCO_A 25/08/2017 EVO 87:AMF -- START
                    //Id TaskRecordType = (SelectedCase.RecordType.developername==Ap_Constants.rtCaseMotor)?MapRTTask.get(Ap_Constants.rtTaskMotor):((SelectedCase.RecordType.developername==Ap_Constants.rtCaseNonMotor)?MapRTTask.get(Ap_Constants.rtTaskNonMotor):((SelectedCase.RecordType.developername==Ap_Constants.rtCaseQuadra)?MapRTTask.get(Ap_Constants.rtTaskQuadra):MapRTTask.get(Ap_Constants.rtTaskAAI)));
                    //Id TaskRecordType = (SelectedCase.RecordType.developername==Ap_Constants.rtCaseMotor)?MapRTTask.get(Ap_Constants.rtTaskMotor):((SelectedCase.RecordType.developername==Ap_Constants.rtCaseNonMotor)?MapRTTask.get(Ap_Constants.rtTaskNonMotor):((SelectedCase.RecordType.developername==Ap_Constants.rtCaseQuadra)?MapRTTask.get(Ap_Constants.rtTaskQuadra):((SelectedCase.RecordType.developername==Ap_Constants.rtCaseAMF)?MapRTTask.get(Ap_Constants.rtTaskAMF):MapRTTask.get(Ap_Constants.rtTaskAAI))));
                    
                    //OAVERSANO 09/01/2019 : Agenzia diretta -- START 
                    //Id TaskRecordType = (SelectedCase.RecordType.developername==Ap_Constants.rtCaseMotor)?MapRTTask.get(Ap_Constants.rtTaskMotor):((SelectedCase.RecordType.developername==Ap_Constants.rtCaseNonMotor)?MapRTTask.get(Ap_Constants.rtTaskNonMotor):((SelectedCase.RecordType.developername==Ap_Constants.rtCaseQuadra)?MapRTTask.get(Ap_Constants.rtTaskQuadra):((SelectedCase.RecordType.developername==Ap_Constants.rtCaseAMF)?MapRTTask.get(Ap_Constants.rtTaskAMF):((SelectedCase.RecordType.developername==Ap_Constants.rtCaseSinistro)?MapRTTask.get(Ap_Constants.rtTaskSinistro):MapRTTask.get(Ap_Constants.rtTaskAAI)))));
                    Id TaskRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(CaseRTtoTaskRT__c.getInstance(SelectedCase.RecordType.developername).Task_RT_developername__c).getRecordTypeId();
                    //OAVERSANO 09/01/2019 : Agenzia diretta -- END                    
                    
                    //CAPOBIANCO_A 25/08/2017 EVO 87:AMF -- END

                    CustServModel = (String.isNotBlank(SelectedCase.Customer_Service_Model__c))?SelectedCase.Customer_Service_Model__c:'';
                    
                    if(String.isNotBlank(CustServModel))
                    {
                        if(MapModelliServizio.size()>0 && MapModelliServizio.containsKey(CustServModel))
                            isPrivate = (MapModelliServizio.get(CustServModel)=='Private'?true:false);
                        else
                            isPrivate = false;                        
                    }
                    
                    TaskSLA = 0;
                    
                    TaskSLA = VFC01_AddTasks.calculateSLA(MapTaskSLAConfigurations, TaskHierarchyLevel1,TaskHierarchyLevel2,TaskHierarchyLevel3,SelectedCase.RecordType.developername,CustServModel,IsPrivate,isVIPCustomer);
                    
                    Datetime EndDate = BusinessHours.addGMT(HoursToUse,system.now(),(TaskSLA*60 * 60 * 1000L).longValue());
                    
                    Boolean IsSmartUser = false;

                    for(Id TechOffUsr: TechOffUsersId)
                    {                        
                        if(SmartCenterUser.contains(TechOffUsr))
                            IsSmartUser = true;

                        Task NewTask = new Task();                        
                        
                        NewTask.Subject = String.isNotBlank(TaskSubject)?TaskSubject:'Altro';
                        NewTask.HierarchyLevel1__c = TaskHierarchyLevel1;
                        NewTask.HierarchyLevel2__c = TaskHierarchyLevel2;
                        NewTask.HierarchyLevel3__c = TaskHierarchyLevel3;
                        NewTask.WhatId = SelectedCase.Id;
                        NewTask.OwnerId = TechOffUsr;
                        NewTask.RecordTypeId = TaskRecordType;
                        NewTask.Status = Ap_Constants.taskStatusOpen;
                        NewTask.Customer_Service_Model__c = String.isNotBlank(CustServModel)?CustServModel:'';
                        NewTask.ActivityDate=date.valueof(EndDate);
                        NewTask.SLAHours__c = TaskSLA;
                        NewTask.Richiedente__c= SelectedCase.Complainant__c;
                        //NewTask.Tipo_Attivit__c='Task';
                        NewTask.Tipo_Attivit__c=(IsSmartUser)?'Task Interno':'Task';
                        NewTask.Send_email_to_case_owner__c=false;
                        NewTask.NomeReferente__c = (SelectedCase.AgentName__r.Name==null)?SelectedCase.Account.Name:SelectedCase.AgentName__r.Name;
                        NewTask.TECH_Key__c = TaskKey;
                        
                        if(BackupTaskCount>0)
                        NewTask.IsBackupTask__c = true;
                        
                        NewTasksList.add(NewTask);
                        BackupTaskCount++;
                    }

                    if(IsSmartUser)
                        CaseToUpdate.status = Ap_Constants.caseInAttesa2ndInterno;

                    CaseToUpdateList.add(CaseToUpdate);   
                }
            }
            if(NewTasksList.size()>0)
            {
                Database.SaveResult[] srList = Database.insert(NewTasksList, false);
                
                for(Integer i=0;i<srList.size();i++)
                {
                    if (srList[i].isSuccess())
                    {
                        SendEmailToTaskSet.add(NewTasksList[i]);
                        AllowUpdateforCaseSet.add(NewTasksList[i].WhatId);
                        TaskCorrectlyCreatedSet.add(NewTasksList[i].Id);
                    }
                    else
                    {
                        AvoidUpdateforCaseSet.add(NewTasksList[i].WhatId);
                        
                        if(!NewTasksList[i].IsBackupTask__c)
                            CheckTaskOnCaseSet.add(NewTasksList[i].WhatId);
                    }
                }
                system.debug('##CheckTaskOnCaseSet: '+CheckTaskOnCaseSet+ ', ');
                
               // String AvoidForId = '';
                system.debug('##OldCaseToUpdateList: '+CaseToUpdateList);

                for(Integer c=0;c<CaseToUpdateList.size();c++)
                {
                    if(AvoidUpdateforCaseSet.contains(CaseToUpdateList[c].Id) && !AllowUpdateforCaseSet.contains(CaseToUpdateList[c].Id))
                    {
                        //if(AvoidForId=='')
                            //AvoidForId=String.valueOf(c);
                            CaseToUpdateList.remove(c);
                       // else
                      //      AvoidForId+=';'+String.valueOf(c);
                    }                        
                }
                system.debug('##NewCaseToUpdateList: '+CaseToUpdateList);

                
  
                if(CheckTaskOnCaseSet.size()>0)
                {
                    Set<Id> TraceCheckedTaskIdSet = new Set<Id>();
                    List<Task> UpdateBackupFlgList = new List<Task>();
                    
                    for(Task UpTas: [Select id,WhatId from Task where whatid in:CheckTaskOnCaseSet and IsBackupTask__c=true and Id in:TaskCorrectlyCreatedSet ]) // NOPMD  Fix CRUD violation
                    {
                        if(!TraceCheckedTaskIdSet.contains(UpTas.WhatId))
                        {
                            Task UpdateTask = new Task(id=UpTas.Id,IsBackupTask__c=false);
                            TraceCheckedTaskIdSet.add(UpTas.WhatId);
                            UpdateBackupFlgList.add(UpdateTask);
                        }
                    }
                    system.debug('#UpdateBackupFlgList: '+UpdateBackupFlgList);
                    
                    if(UpdateBackupFlgList.size()>0)
                    update UpdateBackupFlgList; // NOPMD  Fix CRUD violation               
                }
                               
                if(CaseToUpdateList.size()>0)
                {
                    Update CaseToUpdateList;
                    SendEmail(SendEmailToTaskSet,MapOfCases,MapModelliServizio);
                }  
            } 
        }
    }
    
    public static void SendEmail(Set<Task> CreatedTasksList,Map<Id,Case>MapOfCases, Map<String,String> MapModelliServizio)
    {
        try
        {
            system.debug('#### Start of method sendMail');
            
            String SenderName = 'Smart Center AXA MPS';            
            Map<String,EmailTemplate> TemplateToSendMap = new map<String,EmailTemplate>();
            String[] TemplateName = new String[]{'TaskOpeningNotification', 'PrivateTaskOpeningNotification','AutomaticTaskOpeningAknowledgement'};
            String TaskEmailType;
            Set<Id> Empid = new Set<Id>();
            Set<Id> CaseId = new Set<Id>();
            Id FromAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE Address='servizioclienti@axa-mps.it' LIMIT 1].id;            
            for(EmailTemplate etem: [Select e.Subject,e.Markup,e.HtmlValue, body,DeveloperName From EmailTemplate e where DeveloperName in: TemplateName ]) // NOPMD  Fix CRUD violation
            {
                if(etem.DeveloperName =='TaskOpeningNotification')
                    TemplateToSendMap.put('StandardTask', etem);
                else if(etem.DeveloperName =='PrivateTaskOpeningNotification')
                    TemplateToSendMap.put('PrivateTask', etem);
                else
                    TemplateToSendMap.put('AdvisorComunication', etem);                
            }
            
            for(Task ta:CreatedTasksList)
            {
                Empid.add(ta.ownerid);
                CaseId.add(ta.WhatId);
            }
            
            Map<Id,User> Mapemp = new map<Id,User>([Select id,name from user where id in:Empid]);        
            
            list<Messaging.SingleEmailMessage> listEmail = new list<Messaging.SingleEmailMessage>();
            
            //Send aknowledgment email to Task Owners
            for(Task tsk:CreatedTasksList)
            {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                TaskEmailType = (MapModelliServizio.get(MapOfCases.get(tsk.whatid).Customer_Service_Model__c)=='Private')?'PrivateTask':'StandardTask';
                
                String htmlBody = TemplateToSendMap.get(TaskEmailType).HtmlValue;
                
                htmlBody = htmlBody.replace('{!Case.CaseNumber}',MapOfCases.get(tsk.whatid).CaseNumber);
                htmlBody = htmlBody.replace('{!Contact.Name}',Mapemp.get(tsk.ownerid).Name);
                htmlBody = htmlBody.replace('{!Task.Subject}',((tsk.Subject==null)?'':tsk.Subject));
                htmlBody = htmlBody.replace('{!Task.Description}',((tsk.Description==null)?'':tsk.Description));
                htmlBody = htmlBody.replace('{!Task.ActivityDate}',string.valueof(tsk.ActivityDate));
                htmlBody = htmlBody.replace('{!Task.HierarchyLevel3__c}',string.valueof(tsk.HierarchyLevel3__c));
                
                //MMOSCATELLI 20/04/2018: Fix per accesso tramite SAML -- START
                //htmlBody = htmlBody.replace('{!Task.Link}',URL.getSalesforceBaseUrl().toExternalForm() + '/' +tsk.Id );
                htmlBody = htmlBody.replace('{!Task.Link}','https://login.salesforce.com'+ '/' +tsk.Id );
                //MMOSCATELLI 20/04/2018: Fix per accesso tramite SAML -- END
                
                if(string.valueof(MapOfCases.get(tsk.whatid).OwnerId).startsWith(AP_Constants.UserKeyPrefix))
                    htmlBody = htmlBody.replace('{!User.Name}',MapOfCases.get(tsk.whatid).Owner.Name);
                else
                    htmlBody = htmlBody.replace('{!User.Name}',SenderName);
                
                email.setSubject(TemplateToSendMap.get(TaskEmailType).Subject);
                email.setOrgWideEmailAddressId(FromAddressId);
                email.emailPriority='High';
                email.setTargetObjectId(tsk.ownerid);
                email.setHtmlBody(htmlBody);
                email.saveAsActivity = false;
                listEmail.add(email);
                system.debug('##email: '+email);
            }
            
            //Send aknowledgment email to Case Owner
            for(Id cid:CaseId)
            {
                if(string.valueof(MapOfCases.get(cid).OwnerId).startsWith(AP_Constants.UserKeyPrefix))
                {                
                    Messaging.SingleEmailMessage email_1 = new Messaging.SingleEmailMessage();
                    String htmlBody_1 = TemplateToSendMap.get('AdvisorComunication').HtmlValue;
                    
                    htmlBody_1 = htmlBody_1.replace('{!Case.Link}',URL.getSalesforceBaseUrl().toExternalForm() + '/' +cid );
                    htmlBody_1 = htmlBody_1.replace('{!User.Name}',MapOfCases.get(cid).Owner.Name);
                    email_1.setSubject(TemplateToSendMap.get(TaskEmailType).Subject);
                    email_1.setOrgWideEmailAddressId(FromAddressId);
                    email_1.emailPriority='Normal';
                    email_1.setTargetObjectId(MapOfCases.get(cid).OwnerId);
                    email_1.setHtmlBody(htmlBody_1);
                    email_1.saveAsActivity = false;
                    listEmail.add(email_1);
                    system.debug('##email_1: '+email_1);
                }
            }            
            system.debug('#### End of method sendMail');
        }
        catch(exception ex)
        {
            System.debug('####ERROR for SendEmail: '+ex.getmessage());
        }
        system.debug('#### End of class AP13_TaskAutomaticOpening ###');
    }
    
    //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- START
    @future
    public static void ExternalPartnerTracingTask(Set<String> ExtPartResponseSet, Set<String> ExtPartRequestSet)
    { 
        List<Task> TracingTaskList = new list<Task>();
        Set<Case> UpdateCaseStatusSet = new Set<Case>();
        List<Case> UpdateCaseStatusList = new list<Case>();
        Map<Id,Case> RelatedTasksMap = new Map<Id,Case>();
        Map<String,ExternalPartnersInvolvement__c> ExtPartConfMap = ExternalPartnersInvolvement__c.getAll();
        Map<String,Configurazione_SLA_Uffici_Tecnici__c> MapTaskSLAConfigurations = new map<String,Configurazione_SLA_Uffici_Tecnici__c>();
        Map<String,String> MapModelliServizio = new map<String,String>();
        Map<String,Id> MapRTTask = new Map<String,Id>();
        Decimal TaskSLA =0;
        String CustServModel;
        String TaskHierarchyLevel1='';
        String TaskHierarchyLevel2='';
        String TaskHierarchyLevel3='';
        String defaultHoursId='';
        String bhGDPR='';
        String HoursToUse = '';
        Boolean isPrivate = false;
        Id TaskRecordType;
        String Complainant = '';
        Set<Id> CaseIdList = new Set<Id>();
        String TaskSubject='';
        String RecordCaseId ='';
        String CaseRecordType=''; 
        List<String> GDPRHierarchyLevels = new List<String>();
        List<String> GDPRCategories = new List<String>();

        for(BusinessHours bh: [select Id,IsDefault,Name from BusinessHours where IsActive =true ]) // NOPMD  Fix CRUD violation
        {
            if(bh.Name == 'Default')
                defaultHoursId = bh.Id;
            else if(bh.Name == 'GDPR')
                bhGDPR = bh.Id;
        }

        for(MPS_Code_Variables__c MPSCv: MPS_Code_Variables__c.getAll().values())
        {
            if((MPSCv.Name).contains('GDPR_Hierarchylevel1'))
                GDPRHierarchyLevels.add(MPSCv.Value__c);

            if((MPSCv.Name).contains('GDPR_Category'))
                GDPRCategories.add(MPSCv.Value__c);            
        }                
        
        //MOSCATELLI_M 17/11/2016:EVO 70 -- START                
        Set<String> VIPCharacteristicsSet = new Set<String>();
        
        for(VIPCustomersCharacteristics__c  VIPChar: VIPCustomersCharacteristics__c.getAll().values())
        {
            VIPCharacteristicsSet.add(VIPChar.Case_Category__c);
        }
        system.debug('##VIPCharacteristicsSet: '+VIPCharacteristicsSet);
        //MOSCATELLI_M 17/11/2016:EVO 70 -- END
        
        system.debug('##ExtPartRequestSet: '+ExtPartRequestSet);
        
        if(ExtPartRequestSet.size()>0)
        {
            for(String s:ExtPartRequestSet)
            {
                CaseIdList.add(s.substringAfterLast('|'));
            }
        }
        
        if(ExtPartResponseSet.size()>0)
        {
            for(String s:ExtPartResponseSet)
            {
                CaseIdList.add(s.substringAfterLast('|'));
            }
        }
        
        for(Case c:[Select id, Customer_Service_Model__c,RecordType.developername,Complainant__c,Prodotto__c, Category__c, (select id, Status, Tipo_Attivit__c,Whatid from Tasks where Tipo_Attivit__c in:ExtPartConfMap.keySet() and Status =: AP_Constants.taskStatusInProgress) from Case where id in:CaseIdList and isClosed=false])
        {
            RelatedTasksMap.put(c.id, c);
        }
        
        if(ExtPartRequestSet.size()>0)
        {            
            for(Configurazione_SLA_Uffici_Tecnici__c ConfSLA :[Select id,SLA__c,SLA_for_Private_Customers__c,Hierarchy_Level_1__c,Hierarchy_Level_2__c,Hierarchy_Level_3__c,Task_Record_Type__c,Customer_Service_Type__c from Configurazione_SLA_Uffici_Tecnici__c where Rule_Active__c = true ]) // NOPMD  Fix CRUD violation
            {
                MapTaskSLAConfigurations.put(ConfSLA.Hierarchy_Level_1__c+'-'+ConfSLA.Hierarchy_Level_2__c+'-'+ConfSLA.Hierarchy_Level_3__c+'-'+ConfSLA.Task_Record_Type__c+'-'+ConfSLA.Customer_Service_Type__c,ConfSLA);
            }
                        
            for(Definizione_Modelli_di_Servizio__c ModServ:[Select Customer_Typology__c, Modello_di_Servizio__c from Definizione_Modelli_di_Servizio__c ]) // NOPMD  Fix CRUD violation
            {
                MapModelliServizio.put(ModServ.Modello_di_Servizio__c, ModServ.Customer_Typology__c);
            }
            
            for(RecordType TaskRT:[Select Id, Developername from RecordType where SObjectType = 'Task' ]) // NOPMD  Fix CRUD violation
            {
                MapRTTask.put(TaskRT.Developername, TaskRT.Id);
            }
            
            for(String SentEmails:ExtPartRequestSet)
            {
                ExternalPartnersInvolvement__c ExternalPartner = ExternalPartnersInvolvement__c.getValues(SentEmails.substringBefore('|'));
                TaskHierarchyLevel1=ExternalPartner.Hierarchy_Level_1__c;
                TaskHierarchyLevel2=ExternalPartner.Hierarchy_Level_2__c;
                TaskHierarchyLevel3=ExternalPartner.Hierarchy_Level_3__c;
                TaskSubject=ExternalPartner.Task_Subject__c;
                RecordCaseId = SentEmails.substringAfterLast('|');
               
                //CAPOBIANCO_A 24/03/2017 BUGFIX: added filter to avoid execution for closed cases
                if(RelatedTasksMap.containsKey(RecordCaseId))
                {
                	CaseRecordType = RelatedTasksMap.get(RecordCaseId).RecordType.developername;
                   	CustServModel = (String.isNotBlank(RelatedTasksMap.get(RecordCaseId).Customer_Service_Model__c))?RelatedTasksMap.get(RecordCaseId).Customer_Service_Model__c:'';
                 
                	if(String.isNotBlank(CustServModel))
                	{
                    	if(MapModelliServizio.size()>0 && MapModelliServizio.containsKey(CustServModel))
                        	isPrivate = (MapModelliServizio.get(CustServModel)=='Private'?true:false);
                    	else
                        	isPrivate = false;                        
                	}
                
                	//MOSCATELLI_M 17/11/2016:EVO 70 -- START
                	Boolean isVIPCustomer = false;
                
                	if(String.isNotBlank(RelatedTasksMap.get(RecordCaseId).Category__c) || String.isNotBlank(RelatedTasksMap.get(RecordCaseId).Prodotto__c))
                	{
                    	if(VIPCharacteristicsSet.contains(RelatedTasksMap.get(RecordCaseId).Category__c) || VIPCharacteristicsSet.contains(RelatedTasksMap.get(RecordCaseId).Prodotto__c))
                        	isVIPCustomer = true;
                	}
                	//MOSCATELLI_M 17/11/2016:EVO 70 -- END
                
                	//MOSCATELLI 17/02/2017: Evo 77 -- Start
                	//TaskRecordType = (CaseRecordType==Ap_Constants.rtCaseMotor)?MapRTTask.get(Ap_Constants.rtTaskMotor):((CaseRecordType==Ap_Constants.rtCaseNonMotor)?MapRTTask.get(Ap_Constants.rtTaskNonMotor):((CaseRecordType==Ap_Constants.rtCaseQuadra)?MapRTTask.get(Ap_Constants.rtTaskQuadra):MapRTTask.get(Ap_Constants.rtTaskAAI)));       
                	
                    //ACAPOBIANCO 22/08/2017 EVO 87 -- START
                    //TaskRecordType = (CaseRecordType==Ap_Constants.rtCaseMotor)?MapRTTask.get(Ap_Constants.rtTaskMotor):((CaseRecordType==Ap_Constants.rtCaseNonMotor)?MapRTTask.get(Ap_Constants.rtTaskNonMotor):((CaseRecordType==Ap_Constants.rtCaseQuadra)?MapRTTask.get(Ap_Constants.rtTaskQuadra):((CaseRecordType==Ap_Constants.rtCaseAAI)?MapRTTask.get(Ap_Constants.rtTaskAAI):Ap_Constants.rtTaskCTL)));
                    //TaskRecordType = (CaseRecordType==Ap_Constants.rtCaseMotor)?MapRTTask.get(Ap_Constants.rtTaskMotor):((CaseRecordType==Ap_Constants.rtCaseNonMotor)?MapRTTask.get(Ap_Constants.rtTaskNonMotor):((CaseRecordType==Ap_Constants.rtCaseQuadra)?MapRTTask.get(Ap_Constants.rtTaskQuadra):((CaseRecordType==Ap_Constants.rtCaseAAI)?MapRTTask.get(Ap_Constants.rtTaskAAI):((CaseRecordType==AP_Constants.rtCaseAMF)?MapRTTask.get(AP_Constants.rtTaskAMF):Ap_Constants.rtTaskCTL))));
                    
					//OAVERSANO 09/01/2019 : Agenzia diretta -- START
                    //TaskRecordType = (CaseRecordType==Ap_Constants.rtCaseMotor)?MapRTTask.get(Ap_Constants.rtTaskMotor):((CaseRecordType==Ap_Constants.rtCaseNonMotor)?MapRTTask.get(Ap_Constants.rtTaskNonMotor):((CaseRecordType==Ap_Constants.rtCaseQuadra)?MapRTTask.get(Ap_Constants.rtTaskQuadra):((CaseRecordType==Ap_Constants.rtCaseAAI)?MapRTTask.get(Ap_Constants.rtTaskAAI):((CaseRecordType==AP_Constants.rtCaseAMF)?MapRTTask.get(AP_Constants.rtTaskAMF):((CaseRecordType==Ap_Constants.rtCaseSinistro)?MapRTTask.get(Ap_Constants.rtTaskSinistro):MapRTTask.get(Ap_Constants.rtTaskCTL))))));
                    TaskRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(CaseRTtoTaskRT__c.getInstance(CaseRecordType).Task_RT_developername__c).getRecordTypeId();                 
                    //OAVERSANO 09/01/2019 : Agenzia diretta -- END

                    //ACAPOBIANCO 22/08/2017 EVO 87 -- END

                    //MOSCATELLI 17/02/2017: Evo 77 -- End
                	Complainant = RelatedTasksMap.get(RecordCaseId).Complainant__c;
                
                	TaskSLA = VFC01_AddTasks.calculateSLA(MapTaskSLAConfigurations, TaskHierarchyLevel1,TaskHierarchyLevel2,TaskHierarchyLevel3,CaseRecordType,CustServModel,IsPrivate,isVIPCustomer);
                
                    HoursToUse = GDPRCategories.contains(RelatedTasksMap.get(RecordCaseId).Category__c)?bhGDPR:defaultHoursId;

                    Datetime EndDate = BusinessHours.addGMT(HoursToUse,system.now(),(TaskSLA*60 * 60 * 1000L).longValue());
                                                  
                	Task TracingTask = new Task();
                	TracingTask.Subject = TaskSubject;
                	TracingTask.HierarchyLevel1__c = TaskHierarchyLevel1;
                	TracingTask.HierarchyLevel2__c = TaskHierarchyLevel2;
                	TracingTask.HierarchyLevel3__c = TaskHierarchyLevel3;
                	TracingTask.WhatId = RecordCaseId;
                	TracingTask.RecordTypeId = TaskRecordType;
                	TracingTask.Status = Ap_Constants.taskStatusInProgress;
                	TracingTask.Customer_Service_Model__c = String.isNotBlank(CustServModel)?CustServModel:'';
                	TracingTask.ActivityDate=date.valueof(EndDate);
                	TracingTask.SLAHours__c = TaskSLA;
                	TracingTask.Richiedente__c= Complainant;
                	TracingTask.Tipo_Attivit__c=ExternalPartner.Name;
                	TracingTask.Send_email_to_case_owner__c=false;
                	TracingTask.TECH_Key__c = System.Now()+'-'+RecordCaseId;                                  
                                                  
              	    //Case UpdateCaseStatus = new Case(id = RecordCaseId,Status=AP_Constants.caseStatusDelegated);
                    Case UpdateCaseStatus = new Case(id = RecordCaseId,Status=GDPRHierarchyLevels.contains(TaskHierarchyLevel1)?AP_Constants.caseStatusInAttesaDPO:AP_Constants.caseStatusDelegated);
                	TracingTaskList.add(TracingTask);
                	UpdateCaseStatusSet.add(UpdateCaseStatus); 
                }
          	}
        }
        else if(ExtPartResponseSet.size()>0)
        {
            system.debug('#ExtPartResponseSet :'+ExtPartResponseSet);
            
            for(String ReceivedEmails:ExtPartResponseSet)
            {
                ExternalPartnersInvolvement__c ExternalPartner = ExternalPartnersInvolvement__c.getValues(ReceivedEmails.substringBefore('|'));
                
                RecordCaseId = ReceivedEmails.substringAfterLast('|');
                system.debug('#RecordCaseId: '+RecordCaseId+' '+'#RelatedTasksMap: '+RelatedTasksMap);
                
                if(RelatedTasksMap.containsKey(RecordCaseId))
                {
                    for(Task t : RelatedTasksMap.get(RecordCaseId).Tasks)
                    {
                        if(t.Tipo_Attivit__c == ExternalPartner.Name)
                        {
                            Task TracingTask = new Task(id=t.id, Status= AP_Constants.taskStatusClosed);
                            TracingTaskList.add(TracingTask);                            
                        }
                    }                    
                }   
            }
        }
    if(TracingTaskList.size()>0)
            Upsert TracingTaskList;
               
        if(UpdateCaseStatusSet.size()>0)
        {
            UpdateCaseStatusList.addAll(UpdateCaseStatusSet);
            Update UpdateCaseStatusList;
        }            
    }
    //MOSCATELLI_M 28/10/2016: Evo71-ConnectedHome -- END
}
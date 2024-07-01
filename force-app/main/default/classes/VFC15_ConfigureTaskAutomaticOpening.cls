/*
*******************************************************************************************************
-------------------------------------------------------------------------------------------------------
-- - Name          : VFC15_ConfigureTaskAutomaticOpening
-- - Author        : Marco Moscatelli
-- - Description   : Custom controller used by the visualforce page VFP15_ConfigureTaskAutomaticOpening 
--
-- Maintenance History:
--
-- Date          Version  Remarks
-- -----------  -------  ------------------------------------------------------------------------------
-- 01-09-2016   1.0     
-------------------------------------------------------------------------------------------------------
*******************************************************************************************************
*/

public with sharing class VFC15_ConfigureTaskAutomaticOpening 
{
    public User TechnicalOfficeUser {get;set;}
    public List<Employee> listEmp {get;set;}
    public Apertura_automatica_Task__c InvolvedCase {get;set;}
    public Map<String,Apertura_automatica_Task__c> MapExistentRules = new map<String,Apertura_automatica_Task__c>();    
    public Map<String,Apertura_automatica_Task__c> MapActiveRules = new map<String,Apertura_automatica_Task__c>();    
    public list<SelectOption> ListHierarchyLevel {get;set;}
    public Boolean ShowTaskConfigSection {set;get;}
    public Boolean Hierarchy1Selected {set;get;}
    public Boolean EnableButton {set;get;}
    public Boolean ShowConfirmation {set;get;}
    public Map<String, String> UrlParameterMap;
    public Id RuleId;
    public Boolean ShowEditFields {set;get;}
    public Map<String,Id> CasRecTypMap;
    public Case ExampleCase {set;get;}
    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
    public String IsInternalTask {get;set;}
    public list<SelectOption> TaskType {get;set;}
    public String EditingRuleKey;
    public set<SelectOption> SetType {get;set;}
    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
    
    public class Employee
    {
        public boolean selected {get;set;}
        public User emp {get;set;}
        
        public Employee(User acc)
        {
            selected = false;
            emp = acc;
        }
    }
    
    public VFC15_ConfigureTaskAutomaticOpening(ApexPages.StandardController stdController)
    {
        ShowTaskConfigSection = false;
        ListHierarchyLevel = new list<SelectOption>();
        listEmp = new list<Employee>();
        TechnicalOfficeUser = new User();
        Hierarchy1Selected = false;
        EnableButton = false;
        ShowConfirmation = false;
        UrlParameterMap = ApexPages.currentPage().getParameters();
        EditingRuleKey='';
        ShowEditFields = false;
		CasRecTypMap = new Map<String,Id>();
        ExampleCase = new Case();

        //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
        IsInternalTask = '';
       /* TaskType = new list<SelectOption>{
                                            new SelectOption('','--Nessuno--'),
                                            new SelectOption('true','Task Interno'),
                                            new SelectOption('false','Task per Ufficio Tecnico') 
                                        }; */
        //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END

		for(RecordType rec:[Select Id, Developername from Recordtype where sObjecttype = 'Case'])
        {
           CasRecTypMap.put(rec.developername, rec.id); 
        }
        
        if(UrlParameterMap.containsKey('id') && String.isNotBlank(UrlParameterMap.get('id')))
        {
            RuleId = UrlParameterMap.get('id');
            InvolvedCase = new Apertura_automatica_Task__c(Id=RuleId);
            system.debug('##invca: '+InvolvedCase);
        }
        else
            InvolvedCase = new Apertura_automatica_Task__c();        
        
        for(Apertura_automatica_Task__c ExistRule :[Select id,Lob__c,Case_Origin__c,Category__c,Sub_Category__c,Distribution_Network__c,Case_Record_Type__c,Task_Subject__c,Hierarchy_Level_1__c,Hierarchy_Level_2__c,Hierarchy_Level_3__c,Technical_Office_Users_Ids__c,Rule_Active__c,IsInternalTask__c from Apertura_automatica_Task__c])
        {
            String Lob =(String.isblank(ExistRule.Lob__c))?'Altro':ExistRule.Lob__c;

            MapExistentRules.put(ExistRule.Case_Origin__c+'_'+Lob+'_'+ExistRule.Category__c+'_'+ExistRule.Sub_Category__c+'_'+ExistRule.Distribution_Network__c+'_'+ExistRule.Case_Record_Type__c, ExistRule);
            
            if(ExistRule.Rule_Active__c)
                MapActiveRules.put(ExistRule.Case_Origin__c+'_'+Lob+'_'+ExistRule.Category__c+'_'+ExistRule.Sub_Category__c+'_'+ExistRule.Distribution_Network__c+'_'+ExistRule.Case_Record_Type__c, ExistRule);
            
            if(String.isNotBlank(RuleId) && ExistRule.Id==RuleId)
                EditingRuleKey = ExistRule.Case_Origin__c+'_'+Lob+'_'+ExistRule.Category__c+'_'+ExistRule.Sub_Category__c+'_'+ExistRule.Distribution_Network__c+'_'+ExistRule.Case_Record_Type__c;
        }
        
        if(EditingRuleKey!='')
        {
            List<Id> ListConfiguredId = new list<Id>();
            InvolvedCase.Case_Origin__c = MapExistentRules.get(EditingRuleKey).Case_Origin__c;
            InvolvedCase.Category__c = MapExistentRules.get(EditingRuleKey).Category__c;
            InvolvedCase.Sub_Category__c = MapExistentRules.get(EditingRuleKey).Sub_Category__c;
            InvolvedCase.Distribution_Network__c = MapExistentRules.get(EditingRuleKey).Distribution_Network__c;
            InvolvedCase.Case_Record_Type__c = MapExistentRules.get(EditingRuleKey).Case_Record_Type__c;
            InvolvedCase.Task_Subject__c = MapExistentRules.get(EditingRuleKey).Task_Subject__c;
            InvolvedCase.Rule_Active__c = MapExistentRules.get(EditingRuleKey).Rule_Active__c;                 
            InvolvedCase.IsInternalTask__c = MapExistentRules.get(EditingRuleKey).IsInternalTask__c;
            TechnicalOfficeUser.HierarchyLevel1__c = MapExistentRules.get(EditingRuleKey).Hierarchy_Level_1__c;
            TechnicalOfficeUser.HierarchyLevel2__c = MapExistentRules.get(EditingRuleKey).Hierarchy_Level_2__c;
            TechnicalOfficeUser.HierarchyLevel3__c = MapExistentRules.get(EditingRuleKey).Hierarchy_Level_3__c;
            ExampleCase.RecordTypeId = CasRecTypMap.get(InvolvedCase.Case_Record_Type__c);
            ExampleCase.Lob__c = MapExistentRules.get(EditingRuleKey).Lob__c;            
            ExampleCase.Category__c = MapExistentRules.get(EditingRuleKey).Category__c;
            ExampleCase.SubCategory__c = MapExistentRules.get(EditingRuleKey).Sub_Category__c;
            Hierarchy1Selected = true;
            ShowTaskConfigSection = true;
            ShowEditFields = true;
            EnableButton = true;

            IsInternalTask = (InvolvedCase.IsInternalTask__c)?'true':'false'; 
            
            NewRuleInitialChecks();
            ListConfiguredId = (MapExistentRules.get(EditingRuleKey).Technical_Office_Users_Ids__c).split(';');
            listEmp = new list<Employee>();
            
            for(User SelectedUser : [select id, name, Email, Phone, EmployeeNumber, Department from User where id in:ListConfiguredId])
            {
                listEmp.add(new Employee(SelectedUser));
            }
            
            for(Employee SelEmp: listEmp)
            {
                SelEmp.selected = true;
            }
            
            for(User NotSelectedUser:[select id, name, Email, Phone, EmployeeNumber, Department
                                      from User 
                                      where HierarchyLevel1__c = :TechnicalOfficeUser.HierarchyLevel1__c
                                      and HierarchyLevel2MP__c includes (:TechnicalOfficeUser.HierarchyLevel2__c)
                                      and HierarchyLevel3MP__c includes (:TechnicalOfficeUser.HierarchyLevel3__c)
                                      and id not in:ListConfiguredId
                                      and IsActive =:true
                                      order by name])
            {
                listEmp.add(new Employee(NotSelectedUser));
            }            
        }
    }
    
    public void NewRuleInitialChecks()
    {
        system.debug('##map: '+MapActiveRules);
        system.debug('##InvolvedCase: '+InvolvedCase);

        //changeDisplayedField();//MOSCATELLI_M 07/06/2018: Inoltro Task Interni
        String Lob =(String.isblank(InvolvedCase.Lob__c))?'Altro':InvolvedCase.Lob__c;
        TaskType = new list<SelectOption>();
        SetType = new Set<SelectOption>();
        SetType.add(new SelectOption('','--Nessuno--'));
        
        if(!ShowEditFields && MapActiveRules.size()>0 && MapActiveRules.containsKey(Lob+'_'+InvolvedCase.Case_Origin__c+'_'+ExampleCase.Category__c+'_'+ExampleCase.SubCategory__c+'_'+InvolvedCase.Distribution_Network__c+'_'+InvolvedCase.Case_Record_Type__c))
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.label.VFP15_RuleAlreadyExists);                                               
            ApexPages.addMessage(myMsg);
            ShowTaskConfigSection = false;
            EnableButton = false;
            Hierarchy1Selected = false;
        }
        else
        {
            if(ListHierarchyLevel.size()>0)
                ListHierarchyLevel.clear();
            
            if(UserInfo.getLanguage()=='it')
                ListHierarchyLevel.add(new selectoption('','--Nessuno--'));
            else
                ListHierarchyLevel.add(new selectoption('','--None--'));
            
            Boolean InternalT = (IsInternalTask=='true')?true:false;//MOSCATELLI_M 07/06/2018: Inoltro Task Interni

            for(Uffici_Tecnici_Record_Type__c HierarchyLev:[select id, Hierarchy_Level_1__c,Task_Record_Type__c,Valido_per_Task_interno__c
                                                            from Uffici_Tecnici_Record_Type__c
                                                            where Task_Record_Type__c includes (:InvolvedCase.Case_Record_Type__c)
                                                           // and Valido_per_Task_interno__c =: InternalT//MOSCATELLI_M 07/06/2018: Inoltro Task Interni                               
                                                            order by Hierarchy_Level_1__c])
            {
                if(String.isNotBlank(IsInternalTask))
                {
                    if(HierarchyLev.Valido_per_Task_interno__c==InternalT)
                        ListHierarchyLevel.add(new selectoption(HierarchyLev.Hierarchy_Level_1__c,HierarchyLev.Hierarchy_Level_1__c));           
                }
                else
                    ListHierarchyLevel.add(new selectoption(HierarchyLev.Hierarchy_Level_1__c,HierarchyLev.Hierarchy_Level_1__c));           
 
                if(HierarchyLev.Valido_per_Task_interno__c)
                    SetType.add(new SelectOption('true','Task Interno'));
                else
                    SetType.add(new SelectOption('false','Task per Ufficio Tecnico'));               
            } 
            
            if(ListHierarchyLevel.size()>1)
            {
                TaskType.addall(SetType);
                
                ShowTaskConfigSection =true;
            }
            else
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, System.label.VFP15_TechnicalOfficeNotAvailable);                                                
                ApexPages.addMessage(myMsg);                        
            }                
        }        
    }
    
    public void GetListOfEmployees()
    {
        EnableButton = false;        
        listEmp = new list<Employee>();
        
        //OAVERSANO 02/05/2019 : NMA - LOB VITA -- START
        Set<String> profileToRouteTasks = new Set<String>();
        if(MPS_Code_Variables__c.getValues('ProfileToRouteTasks')!=null)
        {
            if(String.isNotBlank(MPS_Code_Variables__c.getValues('ProfileToRouteTasks').value__c))
            {
                for(String s:(MPS_Code_Variables__c.getValues('ProfileToRouteTasks').value__c).split(';'))
                {
                    profileToRouteTasks.add(s);                
                }
            }
        }
        //OAVERSANO 02/05/2019 : NMA - LOB VITA -- END 
        
        //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
        /*
        for(User acc:[select id, name, Email, Phone, EmployeeNumber, Department
                      from User 
                      where HierarchyLevel1__c = :TechnicalOfficeUser.HierarchyLevel1__c
                      and HierarchyLevel2MP__c includes (:TechnicalOfficeUser.HierarchyLevel2__c)
                      and HierarchyLevel3MP__c includes (:TechnicalOfficeUser.HierarchyLevel3__c)
                      and IsActive =:true
                      order by name])
        */
        String Querys = 'Select id, name, Email, Phone, EmployeeNumber, Department from User where HierarchyLevel1__c= \''+TechnicalOfficeUser.HierarchyLevel1__c+'\' and HierarchyLevel2MP__c includes (\''+TechnicalOfficeUser.HierarchyLevel2__c+'\') and HierarchyLevel3MP__c includes (\''+TechnicalOfficeUser.HierarchyLevel3__c+'\') and isactive = true';
        
        if(IsInternalTask == 'false'){
        	//OAVERSANO 18/09/2018 : FIX PROFILI Nuovo Modello di Assistenza -- START
            Querys+= ' and Profile.Name IN:profileToRouteTasks';
            //Querys+= ' and Profile.Name = \'Technical Office\'';
            //OAVERSANO 18/09/2018 : FIX PROFILI Nuovo Modello di Assistenza -- END
        }

        Querys+=' order by name';

        system.debug('@@Querys: '+Querys);

        for(User acc : Database.query(Querys))
        {
            listEmp.add(new Employee(acc));                          
            	
            system.debug('#### getListEmployees - Hierarchy_Level_1__c :'+TechnicalOfficeUser.HierarchyLevel1__c);
            system.debug('#### getListEmployees - Hierarchy_Level_2__c :'+TechnicalOfficeUser.HierarchyLevel2__c);
            system.debug('#### getListEmployees - Hierarchy_Level_3__c :'+TechnicalOfficeUser.HierarchyLevel3__c);
            system.debug('#### getListEmployees - listEmp :'+listEmp);                          
        }
        //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
        
		if(listEmp.size()==0)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, System.label.VFP15_UsersNotAvailable);                                               
            ApexPages.addMessage(myMsg);              
        }        
    }
    
    public PageReference CreateAutomaticTaskRule()
    {
        InvolvedCase.Hierarchy_Level_1__c = TechnicalOfficeUser.HierarchyLevel1__c;
        InvolvedCase.Hierarchy_Level_2__c = TechnicalOfficeUser.HierarchyLevel2__c;
        InvolvedCase.Hierarchy_Level_3__c = TechnicalOfficeUser.HierarchyLevel3__c;
        InvolvedCase.Lob__c = ExampleCase.Lob__c;
        InvolvedCase.Category__c = ExampleCase.Category__c;
        InvolvedCase.Sub_Category__c = ExampleCase.SubCategory__c;
        InvolvedCase.IsInternalTask__c = (IsInternalTask=='true')?true:false;
        
        system.debug('##Insertrec: '+InvolvedCase);
        
        for(Employee emp:listEmp)
        {
            if(emp.selected)
            {
                if(String.isBlank(InvolvedCase.Technical_Office_Users_Ids__c))
                {
                    InvolvedCase.Technical_Office_Users_Ids__c=emp.emp.id;
                    InvolvedCase.Technical_Office_Users_Name__c=emp.emp.name;                  
                }
                else
                {
                    InvolvedCase.Technical_Office_Users_Ids__c+=';'+emp.emp.id;
                    InvolvedCase.Technical_Office_Users_Name__c+=';'+emp.emp.name;                    
                }
            }
        }
        
        if(String.isNotBlank(RuleId) && MapActiveRules.size()>0 && MapActiveRules.containsKey(InvolvedCase.Case_Origin__c+'_'+ExampleCase.Category__c+'_'+ExampleCase.SubCategory__c+'_'+InvolvedCase.Distribution_Network__c+'_'+InvolvedCase.Case_Record_Type__c) && MapActiveRules.get(InvolvedCase.Case_Origin__c+'_'+ExampleCase.Category__c+'_'+ExampleCase.SubCategory__c+'_'+InvolvedCase.Distribution_Network__c+'_'+InvolvedCase.Case_Record_Type__c).Id <> RuleId) 
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.label.VFP15_RuleAlreadyExists);                                               
            ApexPages.addMessage(myMsg);            
        }
        else
        {            
            Savepoint sp = Database.setSavepoint();
            
            try
            {   
                Upsert InvolvedCase; 
                
                String CorrectOperationMessage = '';
                
                if(!ShowEditFields)
                    CorrectOperationMessage = System.label.VFP15_RuleHasBeenCreated;
                else
                    CorrectOperationMessage = System.label.VFP15_RuleHasBeenUpdated;
                
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, CorrectOperationMessage);                                                
                ApexPages.addMessage(myMsg);
                ShowConfirmation = true;
            }
            catch(exception ex)
            {
                String ErrorMessage = '';
                
                if(!ShowEditFields)
                    ErrorMessage = System.label.VFP15_RuleNotCreated;
                else
                    ErrorMessage = System.label.VFP15_RuleNotUpdated;
                
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ErrorMessage+' '+ex.getmessage());                                                
                ApexPages.addMessage(myMsg);
                Database.rollback(sp);
            }
        }            
        return null;
    }
    
    public void setflag()
    {           
        if(TechnicalOfficeUser.HierarchyLevel1__c!=null && TechnicalOfficeUser.HierarchyLevel1__c!='')        
            Hierarchy1Selected = true;                         
    }
    
    public void changeDisplayedField()
    {
        Hierarchy1Selected= false;
        EnableButton = false;
        TechnicalOfficeUser.HierarchyLevel1__c = '';
        TechnicalOfficeUser.HierarchyLevel2__c = '';
        TechnicalOfficeUser.HierarchyLevel3__c = '';
        listEmp.clear();
        NewRuleInitialChecks();
    }
    
    public void ResetValues()
    {
        system.debug('ResetValues method');
        ExampleCase.RecordTypeId = CasRecTypMap.get(InvolvedCase.Case_Record_Type__c);
        ExampleCase.Lob__c = '';
        ExampleCase.Category__c ='';
        ExampleCase.SubCategory__c='';
        InvolvedCase.Lob__c = '';
        InvolvedCase.Category__c='';
        InvolvedCase.Sub_Category__c='';
        TechnicalOfficeUser.HierarchyLevel1__c = '';
        TechnicalOfficeUser.HierarchyLevel2__c = '';
        TechnicalOfficeUser.HierarchyLevel3__c = '';
        ShowTaskConfigSection = false;
        Hierarchy1Selected = false;
        ListHierarchyLevel.clear();
        listEmp.clear();
        EnableButton = false;    
    }
    
    public void CheckAllInputs()
    {
        system.debug('CheckAllInputs method');
        if(String.isNotBlank(InvolvedCase.Case_Origin__c) && String.isNotBlank(ExampleCase.Category__c) && String.isNotBlank(ExampleCase.SubCategory__c) && String.isNotBlank(ExampleCase.Lob__c) && String.isNotBlank(InvolvedCase.Case_Record_Type__c))
            NewRuleInitialChecks(); 
    }
    
    public void CheckSelected()
    {
        EnableButton = false;
        
        for(Employee SelEmp: listEmp)
        {
            if(SelEmp.selected)            
                EnableButton = true;                            
        }
    }
    
    public void ResetUserList()
    {
        listEmp.clear();
        EnableButton = false;
        TechnicalOfficeUser.HierarchyLevel3__c = '';        
    }    
}
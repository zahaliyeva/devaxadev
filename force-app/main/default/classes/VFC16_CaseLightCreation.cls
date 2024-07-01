/*
*******************************************************************************************************
-------------------------------------------------------------------------------------------------------
-- - Name          : VFC16_CaseLightCreation
-- - Author        : Marco Moscatelli
-- - Description   : Custom controller used by the visualforce page VFP16_CaseLightCreation 
--
-- Maintenance History:
--
-- Date          Version  Remarks
-- -----------  -------  ------------------------------------------------------------------------------
-- 21-12-2016   1.0     
-------------------------------------------------------------------------------------------------------
*******************************************************************************************************
*/
public with sharing class VFC16_CaseLightCreation 
{
    public list<SelectOption> ListCategory {get;set;}
    public list<SelectOption> ListSubCategory {get;set;}
    Map<String, String> UrlParameterMap;
    public String SelectedCategory{get;set;}
    public String SelectedSubCategory{get;set;}
    public String CaseType;
    public String CustType;
    public String Distribution;
    public String CallId;
    public String ClientId;
    public String AgentId;
    public String CreateCaseLightAccounts;
    public Set<String> Cat_SubCatMap = new Set<String>();
    public Set<String> CategorySet = new Set<String>();
    public Set<String> SubCategorySet = new Set<String>();
    public Boolean isPickAvailable{set;get;}
    public Boolean IsCreated{set;get;}
    public Boolean ShowError{set;get;}
    public String AAIAgentId;//MOSCATELLI_M 02/07/2018: Easy Azienda
    public String Lob;//MOSCATELLI_M 02/08/2018: Nuovo Modello di assistenza
    
    //START - LIGHTING MIGRATION
    public VFC16_CaseLightCreation(){
        this(ApexPages.currentPage().getParameters());
    }   
    //END - LIGHTING MIGRATION
    
    public VFC16_CaseLightCreation(Map<String,String> params)
    {
        isPickAvailable = false;
        IsCreated = false;
        ShowError = false;
        
        String[] types = new String[]{'Case'}; 
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types); 
        Map<String, Schema.RecordTypeInfo> MapCaseRecordType = new Map<String, Schema.RecordTypeInfo> ();

        CaseType = '';
        CustType='';
        Distribution='';
        CallId='';
        SelectedCategory = '';
        SelectedSubCategory = '';
        ListCategory = new list<SelectOption>();
        ListSubCategory = new list<SelectOption>();
        ClientId='';
        AgentId='';
        CreateCaseLightAccounts='';
        
        UrlParameterMap = ApexPages.currentPage().getParameters();
        system.debug('##UrlParameterMap16: '+UrlParameterMap);
        
        if(UrlParameterMap.containsKey('CaseType'))
            CaseType = UrlParameterMap.get('CaseType');
        
        if(UrlParameterMap.containsKey('CustType'))
            CustType = UrlParameterMap.get('CustType');
        
        if(UrlParameterMap.containsKey('Distribution'))
            Distribution= UrlParameterMap.get('Distribution');
        
        if(UrlParameterMap.containsKey('CallId'))
            CallId = UrlParameterMap.get('CallId');
        
        if(UrlParameterMap.containsKey('ClientId'))
            ClientId = UrlParameterMap.get('ClientId');
        
        if(UrlParameterMap.containsKey('AgentId'))
            AgentId = UrlParameterMap.get('AgentId'); 

        //MOSCATELLI_M 02/07/2018: Easy Azienda -- START
        if(UrlParameterMap.containsKey('AAIAgent'))
            AAIAgentId = UrlParameterMap.get('AAIAgent'); 
        //MOSCATELLI_M 02/07/2018: Easy Azienda -- END  

        //MOSCATELLI_M 02/08/2018: Nuovo Modello di assistenza -- START
        if(UrlParameterMap.containsKey('Lob'))
            Lob = UrlParameterMap.get('Lob');         
        //MOSCATELLI_M 02/08/2018: Nuovo Modello di assistenza -- START     
        
        if(UserInfo.getLanguage()=='it')
        {
            ListCategory.add(new selectoption('','--Nessuno--'));
            ListSubCategory.add(new selectoption('','--Nessuno--'));            
        }
        else
        {
            ListCategory.add(new selectoption('','--None--'));
            ListSubCategory.add(new selectoption('','--None--'));    
        }
        
        for (Schema.RecordTypeInfo ri: results[0].getRecordTypeInfos()) 
        { 
            MapCaseRecordType.put(ri.getRecordTypeId(), ri);
        }
        system.debug('##MapCaseRecordType: '+MapCaseRecordType);
        
        for(Case_Light_Categories__c LightConf: Case_Light_Categories__c.getAll().values())
        {
            if(String.isNotBlank(Lob))
            {
                if(Lob.equalsIgnoreCase(LightConf.Lob__c))
                {
                    if(String.isNotBlank(LightConf.Sub_Category__c))
                      Cat_SubCatMap.add(LightConf.Category__c+'|'+LightConf.Sub_Category__c);
                             
                    if(String.isBlank(LightConf.Record_Type__c))
                      CategorySet.add(LightConf.Category__c);                        
                    
                    else if(String.isNotBlank(CaseType) && MapCaseRecordType.containskey(CaseType))
                    {
                        for(String RT:(LightConf.Record_Type__c).split(','))
                        {
                            if(RT==MapCaseRecordType.get(CaseType).getName())
                                CategorySet.add(LightConf.Category__c);    
                        }                       
                    }                    
                }
            }
            else
            {
                if(String.isNotBlank(LightConf.Sub_Category__c))
                  Cat_SubCatMap.add(LightConf.Category__c+'|'+LightConf.Sub_Category__c);
                         
                if(String.isBlank(LightConf.Record_Type__c))
                  CategorySet.add(LightConf.Category__c);                        
                
                else if(String.isNotBlank(CaseType) && MapCaseRecordType.containskey(CaseType))
                {
                    for(String RT:(LightConf.Record_Type__c).split(','))
                    {
                        if(RT==MapCaseRecordType.get(CaseType).getName())
                            CategorySet.add(LightConf.Category__c);    
                    }                       
                }
            }
        }
        
        for(String s:CategorySet)
        {
            ListCategory.add(new selectoption(s,s));    
        }
        
        system.debug('###CaseType111= '+CaseType+' '+CustType+' '+CallId);
        
        List<Storico_Chiamate__c> ExistentLightCase = [Select id from Storico_Chiamate__c where Call_ID__c=:CallId];

        if(ExistentLightCase.size()>0)
        {      
            ShowError = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, system.label.VFP16_Button_not_available);                                              
            ApexPages.addMessage(myMsg);    
        }
    }
    public PageReference CreateCaseLight()
    {
        Case CaseLight = new Case();
        
        if(String.isBlank(SelectedCategory))
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, system.label.VFP16_Missing_Inputs);                                                           
            ApexPages.addMessage(myMsg);            
        }
        else
        {
            try
            { 
                system.debug('###CaseType= '+CaseType+' '+CustType+' '+CallId+' '+SelectedCategory+' '+SelectedSubCategory);
                
                //MOSCATELLI_M 02/07/2018: Easy Azienda -- START
                //String ComplainantType = (CustType == 'gestore')?AP_Constants.rtCaseAgentComp:AP_Constants.rtCaseCustComp;
                
                //OAVERSANO 10/01/2019 : Agenzia diretta -- START
                //String ComplainantType = (CustType == 'gestore')?AP_Constants.rtCaseAgentComp:((CustType=='agente')?AP_Constants.rtCallerIsAgente:AP_Constants.rtCaseCustComp);
                String ComplainantType = (CustType == 'gestore')?AP_Constants.rtCaseAgentComp:((CustType=='agente')?AP_Constants.rtCallerIsAgente:((CustType=='Dipendente')?AP_Constants.rtCallerIdDipendente:AP_Constants.rtCaseCustComp));
                //OAVERSANO 10/01/2019 : Agenzia diretta -- END
                
                //MOSCATELLI_M 02/07/2018: Easy Azienda -- END

                CaseLight = new Case(RecordTypeId=CaseType, Status = AP_Constants.caseStatusOutOfTime, Origin=AP_Constants.caseOriginPhone, Complainant__c=ComplainantType ,Distribution_Network__c=Distribution,Category__c=SelectedCategory,SubCategory__c=SelectedSubCategory,Phone_Call_Ids__c=CallId,IsCaseLight__c=true,Oggetto_apertura_case__c=SelectedCategory, LOB__c = Lob);        
                
                Id AssociatedAccnt;
                
                if(String.isNotBlank(ClientId))
                {
                    CaseLight.AccountId = ClientId;
                    
                    if(String.isBlank(CreateCaseLightAccounts))
                        CreateCaseLightAccounts = ClientId;
                    else
                        CreateCaseLightAccounts += ' ,'+ClientId;
                }                
                
                if(String.isNotBlank(AgentId))
                {
                    CaseLight.AgentName__c = AgentId;
                    
                    if(String.isBlank(CreateCaseLightAccounts))
                        CreateCaseLightAccounts = AgentId;
                    else
                        CreateCaseLightAccounts += ' ,'+AgentId;                
                }

                //MOSCATELLI_M 02/07/2018: Easy Azienda -- START
                if(String.isNotBlank(AAIAgentId))
                {
                    CaseLight.User__c = AAIAgentId;              
                }                
                //MOSCATELLI_M 02/07/2018: Easy Azienda -- END 

                
                upsert CaseLight;
                IsCreated = true;
                
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, system.label.VFC06_CaseLightCreated);                                                           
                ApexPages.addMessage(myMsg);       
            }
            catch(Exception e )
            {   
                ShowError = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, system.label.VFC06_CaseLightNotCreated);                                              
                ApexPages.addMessage(myMsg);
            }
        }        
        return null;
    }
    
    public void getSecondaryPickVals()
    {   
        if(String.isNotBlank(SelectedCategory))
        {
            ListSubCategory.clear();
            
            if(UserInfo.getLanguage()=='it')            
                ListSubCategory.add(new selectoption('','--Nessuno--'));                        
            else
                ListSubCategory.add(new selectoption('','--None--'));               
            
            for(String s: Cat_SubCatMap)
            {
                if(s.contains(SelectedCategory+'|'))
                    ListSubCategory.add(new selectoption(s.substringAfter('|'),s.substringAfter('|'))); 
            }
            
            if(ListCategory.size()>1)
                isPickAvailable = true;
        }
    }
}
/*
*******************************************************************************************************
-------------------------------------------------------------------------------------------------------
-- - Name          : VFC19_LiveAgentPreChatForm
-- - Author        : Marco Moscatelli
-- - Description   : Custom controller used by the visualforce page VFP19_LiveAgentPreChatForm 
--
-- Maintenance History:
--
-- Date          Version  Remarks
-- -----------  -------  ------------------------------------------------------------------------------
-- 27-03-2017   1.0     
-------------------------------------------------------------------------------------------------------
*******************************************************************************************************
*/

public class VFC19_LiveAgentPreChatForm 
{
    public List<SelectOption> ListCategories {get;set;}
    public List<SelectOption> ListSubCategories {get;set;}
    public String SelectedCategory {get;set;}
    public String SelectedSubCategory {get;set;}
    public String SelectedButton {set;get;}
    public Boolean isInOfOffice {get;set;}
    public Set<String> CategorySet;
    public Set<String> SubCategorySet;
    public Set<String> Cat_SubCatMap;
    public Map<String,Pre_chat_Form_Configuration__c> MapPreChatForm;
    public String SelectedRecordType {set;get;}
    public String CustomerComment {get;set;}
    public String WebPortal {set;get;}   
    public Boolean isButtonAvailable{get;set;}
    public String CasRecTyp {get;set;}
    
    public VFC19_LiveAgentPreChatForm()
    {
        isInOfOffice = false;
        ListCategories = new list<SelectOption>();
        ListSubCategories = new list<SelectOption>();
        SelectedCategory = '';
        SelectedSubCategory = '';
        SelectedButton = '';
        CategorySet = new Set<String>();
        SubCategorySet = new Set<String>();        
        Cat_SubCatMap = new Set<String>();
        MapPreChatForm = new Map<String,Pre_chat_Form_Configuration__c>();
        SelectedRecordType = '';
        CustomerComment = '';
        isButtonAvailable = false;
        CasRecTyp = '';
        String deploymentId='';
        
        Map <String,String> URLParameters = ApexPages.currentPage().getParameters();
        system.debug('##URLParameters: '+URLParameters);
        List<String> lista = new List<String>();
        if (URLParameters.get('endpoint') != null && (URLParameters.get('endpoint')).contains('#deployment_id') ) {
            lista = (URLParameters.get('endpoint')).split('#')[1].split('&');
        } else {
            lista = (URLParameters.get('endpoint')).split('&');
        }
        for (String s:lista){
            if (s.startsWith('deployment_id')) {
                deploymentId = s.split('=')[1];
                system.debug('##deploymentId: '+deploymentId);
            }
        }
        
        if(UserInfo.getLanguage()=='it')
        {
            ListCategories.add(new selectoption('','--Nessuno--'));
            ListSubCategories.add(new selectoption('','--Nessuno--'));            
        }
        else
        {
            ListCategories.add(new selectoption('','--None--'));
            ListSubCategories.add(new selectoption('','--None--'));    
        }
        
        for(Pre_chat_Form_Configuration__c PreChatConf: Pre_chat_Form_Configuration__c.getAll().values())
        {            
            if(deploymentId == PreChatConf.Deployment_id__c)
            {
                Cat_SubCatMap.add(PreChatConf.Category__c+'|'+PreChatConf.SubCategory__c);
            
                MapPreChatForm.put(PreChatConf.Category__c+'|'+PreChatConf.SubCategory__c, PreChatConf);
                
                WebPortal =  PreChatConf.Web_Portal_Type_del__c;
                
                if(WebPortal == PreChatConf.Web_Portal_Type_del__c)                
                    CategorySet.add(PreChatConf.Category__c);
            }  
        }
        
        system.debug('WebPortal: '+WebPortal);
        
        for(String s:CategorySet)
        {
            ListCategories.add(new selectoption(s,s));    
        }        
        
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        
        Boolean isWithin= BusinessHours.isWithin(bh.id, system.now());
        
        isInOfOffice = isWithin;
    }
    
    public void getSecondaryPickVals()
    {   
        ListSubCategories.clear();
        isButtonAvailable = false; 
        
        if(String.isNotBlank(SelectedCategory))
        {
            SelectedSubCategory = '';
            
            if(UserInfo.getLanguage()=='it')            
                ListSubCategories.add(new selectoption('','--Nessuno--'));                        
            else
                ListSubCategories.add(new selectoption('','--None--'));               
            
            for(String s: Cat_SubCatMap)
            {
                //if(s.contains(SelectedCategory))
                if(s.substringBefore('|') == SelectedCategory)
                {
                    ListSubCategories.add(new selectoption(s.substringAfter('|'),s.substringAfter('|')));                    
                }                     
            }
        }
        else
        {            
            if(UserInfo.getLanguage()=='it')
            {
                ListCategories.add(new selectoption('','--Nessuno--'));
                ListSubCategories.add(new selectoption('','--Nessuno--'));            
            }
            else
            {
                ListCategories.add(new selectoption('','--None--'));
                ListSubCategories.add(new selectoption('','--None--'));    
            }
        }            
    }
    
    public void SelectButton()
    {
        if(String.isNotBlank(SelectedSubCategory))
        {
            System.debug('VFC19_LiveAgentPreChatForm.SelectButton ' + 'Site Name: ' + Site.getName());
            SelectedButton = (Site.getName() != null  && Site.getName().containsIgnoreCase('CRM_Agenzie')) ? MapPreChatForm.get(SelectedCategory+'|'+SelectedSubCategory).SFDC_CRM_Agenzie_Button_Id__c : MapPreChatForm.get(SelectedCategory+'|'+SelectedSubCategory).SFDC_Button_Id__c;
            isButtonAvailable = true;
            CasRecTyp = MapPreChatForm.get(SelectedCategory+'|'+SelectedSubCategory).Case_Record_Type__c;
        }
        else
            isButtonAvailable = false;
    }
    
    public void setComment()
    {
        system.debug('##Comment: '+CustomerComment);    
    }
}
/*
***************************************************************************************************
---------------------------------------------------------------------------------------------------
-- - Name          : VFC12_SelectSenderEmail
-- - Author        : Veronica Raniello
-- - Description   : Class used to visualize in the visualforce page VFP12_SelectSenderEmail
-- - 				 all the email address among which you can choose to set a sender email address
--
-- Maintenance History:
--
-- Date          Version  Remarks
-- -----------  -------  --------------------------------------------------------------------------
-- 13-05-2016   1.0     
---------------------------------------------------------------------------------------------------
***************************************************************************************************
*/

public with sharing class VFC12_SelectSenderEmail
{
    private Record_Type_Email__c RTEmail;
    public Record_Type_Email__c RecEmail{get;set;} 
    public boolean transactionStatus{set;get;}
    public String transactionError{set;get;}
    public boolean created{get;set;}
    public Id RTemailid;
    public list<SelectOption> listEmailResult{set;get;}    
    public integer selectedEmailVal{set;get;}
    public OrgWideEmailAddress selectedEmail{set;get;}   
    public id RecordID;
    public Map<String, String> UrlParameterMap;
    public List<Record_Type_Email__c> ListExistentRule{set;get;} 
    
    
    public VFC12_SelectSenderEmail(ApexPages.StandardController stdController)
    {
        System.debug('>>> START VFC12_SelectSenderEmail constructor <<<');       
       
        UrlParameterMap = ApexPages.currentPage().getParameters();        
        
        if(UrlParameterMap.containsKey('id') && UrlParameterMap.get('id')!='' && UrlParameterMap.get('id')!=null)
        {
            RecordID = UrlParameterMap.get('id');
            RecEmail = new Record_Type_Email__c(Id=RecordID);
            
            ListExistentRule = [Select Id,Caller__c,Record_Type__c,Additional_Email__c,Email__c from Record_Type_Email__c where id=:RecordID ]; // NOPMD  Fix CRUD violation
            
            RecEmail.Caller__c 				= ListExistentRule[0].Caller__c;
            RecEmail.Record_Type__c 		= ListExistentRule[0].Record_Type__c;
            RecEmail.Additional_Email__c 	= ListExistentRule[0].Additional_Email__c;
            RecEmail.Email__c 				= ListExistentRule[0].Email__c;
        }
        else
            RecEmail = new Record_Type_Email__c();
        
                
        transactionStatus = false;
        transactionError = 'firstLoad';
        selectedEmail = new OrgWideEmailAddress(); 
        listEmailResult = new list<SelectOption>();  
        
        String soql = 'SELECT Address FROM OrgWideEmailAddress ';
        
        if(UserInfo.getLanguage()=='it')
            listEmailResult.add(new selectoption('','--Nessuno--'));
        else
            listEmailResult.add(new selectoption('','--None--'));
        
        for(OrgWideEmailAddress orgemail:Database.query(soql))
        {
            listEmailResult.add(new selectoption(orgemail.Address, orgemail.Address));
        }

        System.debug('### listEmailResult: '+listEmailResult);  
        System.debug('>>> END VFC12_SelectSenderEmail constructor <<<');        
    }
    
    Public PageReference SaveANDNew()
    {
        if(!(RecEmail.Email__c!=null && RecEmail.Additional_Email__c!=null))
        {
            if(RecEmail.Email__c!=null || RecEmail.Additional_Email__c!=null)
            {
                if (RecEmail.Email__c == null)        
                    RecEmail.Sender_Email__c = RecEmail.Additional_Email__c;        
                else 
                    RecEmail.Sender_Email__c = RecEmail.Email__c;
               
                String soql='';
                
                for(String Callertobesearched: (RecEmail.Caller__c).split(';'))
                {
                    if(soql=='')
                        soql = ' and Caller__c includes (\''+Callertobesearched+'\'';                    
                    else
                        soql += ', \''+Callertobesearched+'\'';
                }
                
                string soql1 = 'Select Id,Caller__c from Record_Type_Email__c where Record_Type__c=\''+RecEmail.Record_Type__c+'\''+soql+')';
                system.debug('##soql1: '+soql1);
                List<Record_Type_Email__c> ExistentRulesList = Database.query(soql1);
                system.debug('#ExistentRulesList :'+ExistentRulesList);
                
                if(ExistentRulesList.size()>1)
                {
                   string caller ='';
                   for(integer i=0;i<ExistentRulesList.size();i++)
                   {                    
                       for(String callerfound: (ExistentRulesList[i].Caller__c).split(';'))
                       {
                           if(caller=='' && (RecEmail.Caller__c).contains(callerfound))
                               caller = callerfound;
                           else if((!caller.contains(callerfound)) && (RecEmail.Caller__c).contains(callerfound))
                               caller+= ' ,'+callerfound;
                       }                                              
                   }
                                   
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, system.label.VFP12_Existing_rule+' '+caller+' '+system.label.VFP12_Existing_rule_end+' '+RecEmail.Record_Type__c);                                               
                   ApexPages.addMessage(myMsg);
                   return null;
                }
                else if(ExistentRulesList.size()==1)
                {
                    if(ExistentRulesList[0].Id == RecordID)
                    {
                        upsert RecEmail; // NOPMD  Fix CRUD violation
                        PageReference newpage = new PageReference('/apex/VFP12_SelectSenderEmail');
                        newpage.setRedirect(true);
                        return newpage;
                    }
                    else
                    {
                       string caller ='';
                       for(integer i=0;i<ExistentRulesList.size();i++)
                       {                    
                           for(String callerfound: (ExistentRulesList[i].Caller__c).split(';'))
                           {
                               if(caller=='' && (RecEmail.Caller__c).contains(callerfound))
                                   caller = callerfound;
                               else if((!caller.contains(callerfound)) && (RecEmail.Caller__c).contains(callerfound))
                                   caller+= ' ,'+callerfound;
                           }                                              
                       }
                        
                       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, system.label.VFP12_Existing_rule+' '+caller+' '+system.label.VFP12_Existing_rule_end+' '+RecEmail.Record_Type__c);                                               
                       ApexPages.addMessage(myMsg);
                       return null;                   
                    }
                }
                else if(ExistentRulesList.size()==0)
                {
                    upsert RecEmail; // NOPMD  Fix CRUD violation
                    PageReference newpage = new PageReference('/apex/VFP12_SelectSenderEmail');
                    newpage.setRedirect(true);
                    return newpage;             
                }               
                else
                {                      
                    upsert RecEmail; // NOPMD  Fix CRUD violation           
                    PageReference newpage = new PageReference('/apex/VFP12_SelectSenderEmail');
                    newpage.setRedirect(true);
                    return newpage;
                }
            }
            else
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, system.label.VFP12_No_Email_Selected);                                               
                ApexPages.addMessage(myMsg);  
                return null;            
            }
    	}
        else
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, system.label.VFP12_Two_Emails_Not_allowed);                                               
            ApexPages.addMessage(myMsg);  
            return null;              
        }
    }
       
    public PageReference save()
    {
        if(!(RecEmail.Email__c!=null && RecEmail.Additional_Email__c!=null))
        {
            if(RecEmail.Email__c!=null || RecEmail.Additional_Email__c!=null)
            {
                if (RecEmail.Email__c == null)        
                    RecEmail.Sender_Email__c = RecEmail.Additional_Email__c;        
                else
                    RecEmail.Sender_Email__c = RecEmail.Email__c;
                
                String soql='';
                
                for(String Callertobesearched: (RecEmail.Caller__c).split(';'))
                {
                    if(soql=='')
                        soql = ' and Caller__c includes (\''+Callertobesearched+'\'';                    
                    else
                        soql += ', \''+Callertobesearched+'\'';
                }
                
                string soql1 = 'Select Id,Caller__c from Record_Type_Email__c where Record_Type__c=\''+RecEmail.Record_Type__c+'\''+soql+')';
                system.debug('##soql1: '+soql1);
                List<Record_Type_Email__c> ExistentRulesList = Database.query(soql1);
                system.debug('#ExistentRulesList :'+ExistentRulesList);
                
                if(ExistentRulesList.size()>1)
                {
                   string caller ='';
                   for(integer i=0;i<ExistentRulesList.size();i++)
                   {                    
                       for(String callerfound: (ExistentRulesList[i].Caller__c).split(';'))
                       {
                           if(caller=='' && (RecEmail.Caller__c).contains(callerfound))
                               caller = callerfound;
                           else if((!caller.contains(callerfound)) && (RecEmail.Caller__c).contains(callerfound))
                               caller+= ' ,'+callerfound;
                       }                                              
                   }
                    
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, system.label.VFP12_Existing_rule+' '+caller+' '+system.label.VFP12_Existing_rule_end+' '+RecEmail.Record_Type__c);                                               
                   ApexPages.addMessage(myMsg);
                   return null;
                }
                else if(ExistentRulesList.size()==1)
                {
                    if(ExistentRulesList[0].Id == RecordID)
                    {
                        upsert RecEmail; // NOPMD  Fix CRUD violation
                        PageReference redirectSuccess = new ApexPages.StandardController(RecEmail).view();            
                        return redirectSuccess; 
                    }
                    else
                    {
                       string caller ='';
                       for(integer i=0;i<ExistentRulesList.size();i++)
                       {                    
                           for(String callerfound: (ExistentRulesList[i].Caller__c).split(';'))
                           {
                               if(caller=='' && (RecEmail.Caller__c).contains(callerfound))
                                   caller = callerfound;
                               else if((!caller.contains(callerfound)) && (RecEmail.Caller__c).contains(callerfound))
                                   caller+= ' ,'+callerfound;
                           }                                              
                       }
                        
                       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, system.label.VFP12_Existing_rule+' '+caller+' '+system.label.VFP12_Existing_rule_end+' '+RecEmail.Record_Type__c);                                               
                       ApexPages.addMessage(myMsg);
                       return null;                   
                    }
                }
                else if(ExistentRulesList.size()==0)
                {
                    upsert RecEmail; // NOPMD  Fix CRUD violation
                    PageReference redirectSuccess = new ApexPages.StandardController(RecEmail).view();            
                    return redirectSuccess;                 
                }       
                else
                {
                    upsert RecEmail; // NOPMD  Fix CRUD violation
        
                    PageReference redirectSuccess = new ApexPages.StandardController(RecEmail).view();            
                    return redirectSuccess; 
                }  
                
            }
            else
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, system.label.VFP12_No_Email_Selected);                                               
                ApexPages.addMessage(myMsg);  
                return null;
            }
        }
        else
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, system.label.VFP12_Two_Emails_Not_allowed);                                               
            ApexPages.addMessage(myMsg);  
            return null;                 
        }
    }  
}
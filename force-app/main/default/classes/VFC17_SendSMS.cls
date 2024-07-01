/*
*******************************************************************************************************
-------------------------------------------------------------------------------------------------------
-- - Name          : VFC17_SendSMS
-- - Author        : Marco Moscatelli
-- - Description   : Custom controller used by the visualforce page VFP17_SendSMS 
--
-- Maintenance History:
--
-- Date          Version  Remarks
-- -----------  -------  ------------------------------------------------------------------------------
-- 23-01-2017   1.0     
-------------------------------------------------------------------------------------------------------
*******************************************************************************************************
*/

public with sharing class VFC17_SendSMS 
{
    public String MessageContent{get;set;}
    public String SelectedTemplateId{get;set;}
    public String MobileNumber{get;set;}
    public String CustomerId;
    public String CaseId{set;get;}
    public list<SelectOption> ListTemplates{get;set;}
    public list<SelectOption> ListMobileNumbers{get;set;}
    public Boolean TemplatesExist{get;set;}
    public Map<String, String> UrlParameterMap;
    public map<String,Id> acc_developerIdMap;
    public List<Account> CustomerList;
    public Boolean MobileFound;
    public String NumberToCheck;
    public String NewFormat;
    public String FolderTemplateManualAccount;
    public String FolderTemplateManualCase;    
    public List<EmailTemplate> AvailableTemplateList;
    public Map<Id,String> TemplateMap;
    public List<Case> CaseList;
    public Boolean isConsole{set;get;}
    public Boolean ProcessEnd{set;get;}
    
    public VFC17_SendSMS()
    {
        FolderTemplateManualAccount = 'SMS Manuali - Account';
        FolderTemplateManualCase 	= 'SMS Manuali - Case';
        
        ListTemplates = new list<SelectOption>();
        ListMobileNumbers = new list<SelectOption>();
        CaseList = new List<Case>();
        SelectedTemplateId='';
        CustomerId='';
        CaseId='';
        MessageContent='';
        NumberToCheck='';
        MobileFound = false;
        acc_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc);
        TemplatesExist = false;
        TemplateMap = new map<Id,String>();
        isConsole = false;
        ProcessEnd = false;
        
        if(!System.isFuture())
        {
            UrlParameterMap = ApexPages.currentPage().getParameters();
            system.debug('##UrlParameterMap17: '+UrlParameterMap);
            
            if(UrlParameterMap.containsKey('CaseId'))
            {
                if(String.isNotBlank(UrlParameterMap.get('CaseId')))
                {
                    CaseId = UrlParameterMap.get('CaseId');	 
                    CaseList = [Select Id, AccountId, Linktopolicy__c from Case where id=:CaseId];
                    AvailableTemplateList = new List<EmailTemplate>([SELECT Id,Body,Folder.name,IsActive,Name FROM EmailTemplate where folder.name =: FolderTemplateManualCase]);
                }
                else
                    AvailableTemplateList = new List<EmailTemplate>([SELECT Id,Body,Folder.name,IsActive,Name FROM EmailTemplate where folder.name =: FolderTemplateManualAccount]);                    
            }
            
            if(UrlParameterMap.containsKey('AccountId') || UrlParameterMap.containsKey('CustomerId'))
            {
                if(String.isNotBlank(UrlParameterMap.get('AccountId')))
                    CustomerId = UrlParameterMap.get('AccountId');
                else if(String.isNotBlank(UrlParameterMap.get('CustomerId')))        
                    CustomerId = UrlParameterMap.get('CustomerId');
            }
            
            if(UrlParameterMap.containsKey('isConsole'))
                isConsole = (UrlParameterMap.get('isConsole')=='true')?false:true;
            
            if(UserInfo.getLanguage()=='it')
                ListTemplates.add(new selectoption('','--Nessuno--'));
            else
                ListTemplates.add(new selectoption('','--None--'));
            
            for(EmailTemplate em:AvailableTemplateList)
            {
                ListTemplates.add(new selectoption(em.Id,em.Name));
                TemplateMap.put(em.Id, em.Body);                
            }
            
            if(ListTemplates.size()==1)
                TemplatesExist = false;
            
            if(String.isNotBlank(CustomerId))
            {
                CustomerList =				([Select Id,
                                              CIF_MobilePhone__c,
                                              CIF_PersonMobilePhone__c,                                                                                       
                                              PersonMobilePhone,
                                              Additional_Phone__c,
                                              MobilePhone__c,
                                              Claim_PersonalMobile__c,
                                              RecordTypeId
                                              from Account
                                              where Id=:CustomerId]);
                
                MobileOutput Mb = new MobileOutput();
                Mb = ObtainMobileNumber(CustomerList);
                MobileFound = Mb.NumFound;
                
                if(!MobileFound)
                {
                    ProcessEnd = true;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, System.label.VFP17_No_Mobile);                                              
                    ApexPages.addMessage(myMsg);                     
                }
            }
            else
            {
                ProcessEnd = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, System.label.VFP17_No_Account);                                              
                ApexPages.addMessage(myMsg);     
            }
        }
    }
    
    public class MobileOutput
    {
    	Boolean NumFound;
        List<String> AutomaticMobileList;
    }
    
    public MobileOutput ObtainMobileNumber(List<Account> CustomerList)
    {
        MobileOutput Mb = new MobileOutput();
        Mb.NumFound = false;
        Mb.AutomaticMobileList = new list<String>();
        
        system.debug('##CustomerList: '+CustomerList);
        
        for(Account a:CustomerList)
        {
           if(a.RecordTypeId == acc_developerIdMap.get(AP_Constants.rtAccIndividualClient))
           {
               String AdditionalMobile = '';               
               String PersonMobile = '';
               String MobileCTL ='';              		
               
               if(String.isNotBlank(a.Additional_Phone__c))
               {
               		AdditionalMobile = (a.Additional_Phone__c).deleteWhitespace();
					AdditionalMobile = AdditionalMobile.remove('(');
                    AdditionalMobile = AdditionalMobile.remove(')');
               }
               
               if(String.isNotBlank(a.PersonMobilePhone))
               {
               		PersonMobile = (a.PersonMobilePhone).deleteWhitespace();
					PersonMobile = PersonMobile.remove('(');
                    PersonMobile = PersonMobile.remove(')');
               }
               
               if(String.isNotBlank(a.Claim_PersonalMobile__c))
               {
               		MobileCTL = (a.Claim_PersonalMobile__c).deleteWhitespace();
					MobileCTL = MobileCTL.remove('(');
                    MobileCTL = MobileCTL.remove(')');
               }               
               
               if(String.isNotBlank(AdditionalMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(AdditionalMobile)))
                    {
                        ListMobileNumbers.add(new selectoption(CheckMobileFormat(AdditionalMobile),CheckMobileFormat(AdditionalMobile)));	                    
                        Mb.AutomaticMobileList.add(CheckMobileFormat(AdditionalMobile));
                    }	                    
               }
               
               if(String.isNotBlank(PersonMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(PersonMobile)))
                    {
                        ListMobileNumbers.add(new selectoption(CheckMobileFormat(PersonMobile),CheckMobileFormat(PersonMobile)));	                    
                        Mb.AutomaticMobileList.add(CheckMobileFormat(PersonMobile));
                    }	                    
               }
               
               if(String.isNotBlank(MobileCTL))
               {
               		if(String.isNotBlank(CheckMobileFormat(MobileCTL)))
                    {
                        ListMobileNumbers.add(new selectoption(CheckMobileFormat(MobileCTL),CheckMobileFormat(MobileCTL)));	                    
                        Mb.AutomaticMobileList.add(CheckMobileFormat(MobileCTL));
                    }	                    
               }               
               system.debug('##Mb: '+Mb.AutomaticMobileList);
           }
           else if(a.RecordTypeId == acc_developerIdMap.get(AP_Constants.rtAccCorporateClient))
           {
               String AdditionalMobile = '';
               String PersonMobile = '';
               String MobileCTL = '';                 
               
               if(String.isNotBlank((a.Additional_Phone__c)))
               {
                   AdditionalMobile = (a.Additional_Phone__c).deleteWhitespace();
                   AdditionalMobile = AdditionalMobile.remove('(');
                   AdditionalMobile = AdditionalMobile.remove(')');                      
               }
                                  
               if(String.isNotBlank((a.MobilePhone__c)))
               {
                   PersonMobile = (a.MobilePhone__c).deleteWhitespace();
                   PersonMobile = PersonMobile.remove('(');
                   PersonMobile = PersonMobile.remove(')');                        
               }
               
               if(String.isNotBlank((a.Claim_PersonalMobile__c)))
               {
                   MobileCTL = (a.Claim_PersonalMobile__c).deleteWhitespace();
                   MobileCTL = MobileCTL.remove('(');
                   MobileCTL = MobileCTL.remove(')');                        
               }               
               
               if(String.isNotBlank(AdditionalMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(AdditionalMobile)))  
                    {
                        ListMobileNumbers.add(new selectoption(CheckMobileFormat(AdditionalMobile),CheckMobileFormat(AdditionalMobile)));	                    
                        Mb.AutomaticMobileList.add(CheckMobileFormat(AdditionalMobile));
                    }                  
               }
               
               if(String.isNotBlank(PersonMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(PersonMobile)))	     
                    {
                   		ListMobileNumbers.add(new selectoption(CheckMobileFormat(PersonMobile),CheckMobileFormat(PersonMobile)));	                    
                        Mb.AutomaticMobileList.add(CheckMobileFormat(PersonMobile));                        
                    }               
               }
               
               if(String.isNotBlank(MobileCTL))
               {
               		if(String.isNotBlank(CheckMobileFormat(MobileCTL)))	     
                    {
                   		ListMobileNumbers.add(new selectoption(CheckMobileFormat(MobileCTL),CheckMobileFormat(MobileCTL)));	                    
                        Mb.AutomaticMobileList.add(CheckMobileFormat(MobileCTL));                        
                    }               
               }                
           }
           else if(a.RecordTypeId == acc_developerIdMap.get(AP_Constants.rtAccAAFB2C))
           {
               String AdditionalMobile = '';
               String PersonMobile = '';
               
               if(String.isNotBlank(a.Additional_Phone__c))
               {
                   AdditionalMobile = (a.Additional_Phone__c).deleteWhitespace();                   
                   AdditionalMobile = AdditionalMobile.remove('(');
                   AdditionalMobile = AdditionalMobile.remove(')');                   
               }
               
               if(String.isNotBlank(a.MobilePhone__c))
               {
			   	   PersonMobile = (a.MobilePhone__c).deleteWhitespace();
                   PersonMobile = PersonMobile.remove('(');
                   PersonMobile = PersonMobile.remove(')');                    
               }
               
			   if(String.isNotBlank(AdditionalMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(AdditionalMobile))) 
                    {
                        ListMobileNumbers.add(new selectoption(CheckMobileFormat(AdditionalMobile),CheckMobileFormat(AdditionalMobile)));	                    
                        Mb.AutomaticMobileList.add(CheckMobileFormat(AdditionalMobile));                        
                    }                   
               }
               
               if(String.isNotBlank(PersonMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(PersonMobile)))
                    {
                        ListMobileNumbers.add(new selectoption(CheckMobileFormat(PersonMobile),CheckMobileFormat(PersonMobile)));	                    
                        Mb.AutomaticMobileList.add(CheckMobileFormat(CheckMobileFormat(PersonMobile)));                        
                    }	                    
               }           		    
           }
           else if(a.RecordTypeId == acc_developerIdMap.get(AP_Constants.rtAccB2C))
           {
               String AdditionalMobile = '';
               String PersonMobile = '';
               String MobileCTL = '';
               
               if(String.isNotBlank(a.Additional_Phone__c))
               {
                   AdditionalMobile = (a.Additional_Phone__c).deleteWhitespace();
                   AdditionalMobile = AdditionalMobile.remove('(');
                   AdditionalMobile = AdditionalMobile.remove(')');
               }	

               if(String.isNotBlank(a.CIF_PersonMobilePhone__c))
               {
                   PersonMobile = (a.CIF_PersonMobilePhone__c).deleteWhitespace();
                   PersonMobile = PersonMobile.remove('(');
                   PersonMobile = PersonMobile.remove(')');
               }
               
               if(String.isNotBlank(a.Claim_PersonalMobile__c))
               {
                   MobileCTL = (a.Claim_PersonalMobile__c).deleteWhitespace();
                   MobileCTL = MobileCTL.remove('(');
                   MobileCTL = MobileCTL.remove(')');
               }	               
               
			   if(String.isNotBlank(PersonMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(PersonMobile)))
                   		ListMobileNumbers.add(new selectoption(CheckMobileFormat(PersonMobile),CheckMobileFormat(PersonMobile)));	                    
               }
               
               if(String.isNotBlank(AdditionalMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(AdditionalMobile)))
                   		ListMobileNumbers.add(new selectoption(CheckMobileFormat(AdditionalMobile),CheckMobileFormat(AdditionalMobile)));	                    
               }
               
               if(String.isNotBlank(MobileCTL))
               {
               		if(String.isNotBlank(CheckMobileFormat(MobileCTL)))
                   		ListMobileNumbers.add(new selectoption(CheckMobileFormat(MobileCTL),CheckMobileFormat(MobileCTL)));	                    
               }                   
           }             
           else if(a.RecordTypeId == acc_developerIdMap.get(AP_Constants.rtAccB2B))
           {
               String AdditionalMobile = '';
               String Mobile = '';
               String MobileCTL = '';
               
               if(String.isNotBlank(a.Additional_Phone__c))
               {
                   AdditionalMobile = (a.Additional_Phone__c).deleteWhitespace();
                   AdditionalMobile = AdditionalMobile.remove('(');
                   AdditionalMobile = AdditionalMobile.remove(')');
               }	                   
               
               if(String.isNotBlank(a.CIF_MobilePhone__c))
               {
                   Mobile = (a.CIF_MobilePhone__c).deleteWhitespace();
                   Mobile = Mobile.remove('(');
                   Mobile = Mobile.remove(')');
               }
               
               if(String.isNotBlank(a.Claim_PersonalMobile__c))
               {
                   MobileCTL = (a.Claim_PersonalMobile__c).deleteWhitespace();
                   MobileCTL = MobileCTL.remove('(');
                   MobileCTL = MobileCTL.remove(')');
               }	               
               
			   if(String.isNotBlank(Mobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(Mobile)))
                   		ListMobileNumbers.add(new selectoption(CheckMobileFormat(Mobile),CheckMobileFormat(Mobile)));	                    
               }
               
               if(String.isNotBlank(AdditionalMobile))
               {
               		if(String.isNotBlank(CheckMobileFormat(AdditionalMobile)))
                   		ListMobileNumbers.add(new selectoption(CheckMobileFormat(AdditionalMobile),CheckMobileFormat(AdditionalMobile)));	                    
               } 
               
               if(String.isNotBlank(MobileCTL))
               {
               		if(String.isNotBlank(CheckMobileFormat(MobileCTL)))
                   		ListMobileNumbers.add(new selectoption(CheckMobileFormat(MobileCTL),CheckMobileFormat(MobileCTL)));	                    
               }                
           }
        }
        
        if(ListMobileNumbers.size()>0)
        	Mb.NumFound = true;   
        
        return Mb;
    }
    
    public String CheckMobileFormat(String NumberToCheck)
    {
        NewFormat = '';
        
        if(String.isNotBlank(NumberToCheck))
        {                 
            if((String.valueOf(NumberToCheck)).left(4) == '0039')
            {
                //if(((NumberToCheck).substring(4)).isnumeric() && ((NumberToCheck).substring(4)).left(1)=='3' && ((NumberToCheck).substring(4)).length()<=10)
                if(((NumberToCheck).substring(4)).isnumeric() && ((NumberToCheck).substring(4)).left(1)=='3')    
                    NewFormat = (NumberToCheck).substring(4);
            }
            else if((String.valueOf(NumberToCheck)).left(3) == '+39')
            {
                //if(((NumberToCheck).substring(3)).isnumeric() && ((NumberToCheck).substring(3)).left(1)=='3' && ((NumberToCheck).substring(3)).length()<=10)
                if(((NumberToCheck).substring(3)).isnumeric() && ((NumberToCheck).substring(3)).left(1)=='3')
                    NewFormat = (NumberToCheck).substring(3);
            }
            //else if((String.valueOf(NumberToCheck)).left(2) == '03' && ((NumberToCheck).substring(1)).length()<=10)
            else if((String.valueOf(NumberToCheck)).left(2) == '03')
            {
                if(((NumberToCheck).substring(1)).isnumeric())
                    NewFormat = (NumberToCheck).substring(1);
            }
            //else if((String.valueOf(NumberToCheck)).left(1) == '3' && (NumberToCheck).length()<=10)
            else if((String.valueOf(NumberToCheck)).left(1) == '3')
            {
                if(((NumberToCheck).substring(1)).isnumeric())
                    NewFormat = NumberToCheck;
            }
        }
        
        return NewFormat;
    }
    
    public void RetrieveMessage()
    {
        Calculatecontent('', SelectedTemplateId,Caseid,CustomerId,CaseList);
    }
    
    public String Calculatecontent(String MsgCont, String SelectedTemplateId, String Caseid, String CustomerId,List<Case> CaseList)
    {
        if(!System.isFuture())
        	MessageContent ='';
        else
            String MessageContent='';
        
        String SMSBody='';
        String MsgTxt = '';
        
        if(String.isNotBlank(SelectedTemplateId))
        {
            Map<String,String> queryAccount = new map<String,String>();
            Map<String,String> queryCase = new map<String,String>();
            Map<String,String> queryPolicy = new map<String,String>();
            
            if(!System.isFuture())
            	system.debug('##TemplateMap: '+TemplateMap);
            
            system.debug('##SelectedTemplateId: '+SelectedTemplateId);        
            
            if(!System.isFuture())
            	SMSBody = TemplateMap.get(SelectedTemplateId);
            else
                SMSBody = MsgCont;
            
            MessageContent = SMSBody;
            
            system.debug('SMSBody: '+SMSBody);
    
            List<String> TagsList = SMSBody.split('\\{!');
            List<String> FieldsForQueryList = new list<String>();
            List<String> FieldsForAccountList = new list<String>();
            List<String> FieldsForCaseList = new list<String>();
            List<String> FieldsForPolicyList = new list<String>();
            
            Map<String,String> MapforAccount = new map<String,String>();
            Map<String,String> MapforCase = new map<String,String>();
            Map<String,String> MapforPolicy = new map<String,String>();        
            
            system.debug('TagsList: '+TagsList);
            
            for(String str:TagsList)
            {
                for(String spl: str.split(','))
                {
                    system.debug(spl);
                    
                    if(spl.indexof('}')!=-1)
                    {
                        if(String.isnotblank(spl.substringBeforeLast('}')))
                            FieldsForQueryList.add(spl.substringbefore('}'));
                    }
                }
            }
            system.debug(FieldsForQueryList);
    
            for(String f:FieldsForQueryList)
            {
                if(f.substringBefore('.') == 'Account')
                {
                    if(!Account.getSobjectType().getDescribe().fields.getMap().containsKey(f.substringAfter('.')))
                    {                    
                        FieldsForAccountList.add(f.substringAfter('.')+'.Name'); 
                        MapforAccount.put(f.substringAfter('.')+'.Name',f.substringAfter('.'));
                    }                	
                    else if((f.substringAfter('.')).right(3) == '__c' )
                    {
                        if(!(String.valueof(Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get(f.substringAfter('.')).getDescribe().getType())=='REFERENCE'))
                        {
                            MapforAccount.put(f.substringAfter('.'),f.substringAfter('.'));
                            FieldsForAccountList.add(f.substringAfter('.'));
                        }
                        else
                        {
                            FieldsForAccountList.add((f.substringAfter('.')).replace('__c','__r')+'.Name');
                            MapforAccount.put((f.substringAfter('.')).replace('__c','__r')+'.Name',f.substringAfter('.'));                                                
                        }
                    }
                    else if(Account.getSobjectType().getDescribe().fields.getMap().containsKey(f.substringAfter('.')) && !((f.substringAfter('.')).right(3) == '__c'))
                    {
                            MapforAccount.put(f.substringAfter('.'),f.substringAfter('.'));
                            FieldsForAccountList.add(f.substringAfter('.'));                    
                    }  
                 }
                                      
                else if(f.substringBefore('.') == 'Case')
                {
                    if(!Case.getSobjectType().getDescribe().fields.getMap().containsKey(f.substringAfter('.')))
                    {                    
                        FieldsForCaseList.add(f.substringAfter('.')+'.Name'); 
                        MapforCase.put(f.substringAfter('.')+'.Name',f.substringAfter('.'));
                    }                	
                    else if((f.substringAfter('.')).right(3) == '__c' )
                    {
                        if(!(String.valueof(Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().get(f.substringAfter('.')).getDescribe().getType())=='REFERENCE'))
                        {
                            MapforCase.put(f.substringAfter('.'),f.substringAfter('.'));
                            FieldsForCaseList.add(f.substringAfter('.'));
                        }
                        else
                        {
                            FieldsForCaseList.add((f.substringAfter('.')).replace('__c','__r')+'.Name');
                            MapforCase.put((f.substringAfter('.')).replace('__c','__r')+'.Name',f.substringAfter('.'));                                                
                        }
                    }
                    else if(Case.getSobjectType().getDescribe().fields.getMap().containsKey(f.substringAfter('.')) && !((f.substringAfter('.')).right(3) == '__c'))
                    {
                            MapforCase.put(f.substringAfter('.'),f.substringAfter('.'));
                            FieldsForCaseList.add(f.substringAfter('.'));                    
                    }
                }                
                else if(f.substringBefore('.') == 'InsurancePolicy__c')
                {
                    if(!InsurancePolicy__c.getSobjectType().getDescribe().fields.getMap().containsKey(f.substringAfter('.')))
                    {                    
                        FieldsForPolicyList.add(f.substringAfter('.')+'.Name'); 
                        MapforPolicy.put(f.substringAfter('.')+'.Name',f.substringAfter('.'));
                    }                	
                    else if((f.substringAfter('.')).right(3) == '__c' )
                    {
                        if(!(String.valueof(Schema.getGlobalDescribe().get('InsurancePolicy__c').getDescribe().fields.getMap().get(f.substringAfter('.')).getDescribe().getType())=='REFERENCE'))
                        {
                            MapforPolicy.put(f.substringAfter('.'),f.substringAfter('.'));
                            FieldsForPolicyList.add(f.substringAfter('.'));
                        }
                        else
                        {
                            FieldsForPolicyList.add((f.substringAfter('.')).replace('__c','__r')+'.Name');
                            MapforPolicy.put((f.substringAfter('.')).replace('__c','__r')+'.Name',f.substringAfter('.'));                                                
                        }
                    }
                    else if(InsurancePolicy__c.getSobjectType().getDescribe().fields.getMap().containsKey(f.substringAfter('.')) && !((f.substringAfter('.')).right(3) == '__c'))
                    {
                            MapforPolicy.put(f.substringAfter('.'),f.substringAfter('.'));
                            FieldsForPolicyList.add(f.substringAfter('.'));                    
                    }                  
                }
            }
            
            if(FieldsForAccountList.size()>0 && String.isNotBlank(CustomerId))
            {
                system.debug('#AccountQ: '+'Select '+String.join(FieldsForAccountList, ',')+' from Account where id=\''+CustomerId+'\''+' LIMIT 1');
    
                List<Account> Accnt = Database.query('Select '+String.join(FieldsForAccountList, ',')+' from Account where id=\''+CustomerId+'\''+' LIMIT 1');
                
                for(String s:FieldsForAccountList)      
                {
                    queryAccount.put('Account.'+MapforAccount.get(s),EvaluateFieldValue(s,'Account',Accnt));
                }
                system.debug('#MapforAccount: '+MapforAccount);
                
                system.debug('#queryAccount: '+queryAccount);            
                
                for(String tag:FieldsForAccountList)
                {   
                    if(String.isNotBlank(queryAccount.get('Account.'+MapforAccount.get(tag))))
                    {
                        Integer foundPosition = MessageContent.indexOfIgnoreCase('{!Account.'+MapforAccount.get(tag)+'}', 0);
                        
                        MessageContent = MessageContent.left(foundPosition) +
                                queryAccount.get('Account.'+MapforAccount.get(tag)) +
                                MessageContent.substring(foundPosition + ('{!Account.'+MapforAccount.get(tag)+'}').length());
                    }
                    system.debug('##MessageContent: '+'{!Account.'+MapforAccount.get(tag)+'}'+'           '+queryAccount.get('Account.'+MapforAccount.get(tag))+'   '+MessageContent);        
                }
            }
    
            if(FieldsForCaseList.size()>0 && String.isNotBlank(CaseId))
            {
                system.debug('#CaseQ: '+'Select '+String.join(FieldsForCaseList, ',')+' from Case where id=\''+CaseId+'\''+' LIMIT 1');
    
                List<Case> casl = Database.query('Select '+String.join(FieldsForCaseList, ',')+' from Case where id=\''+CaseId+'\''+' LIMIT 1');
                
                for(String s:FieldsForCaseList)      
                {
                    if(s.substringBefore('.')=='Account')
                        queryCase.put('Case.'+MapforCase.get(s),(String)casl[0].Account.get(s.substringAfter('.')));
                    else if(s.substringBefore('.')=='LinktoPolicy__r' && String.isNotBlank(CaseList[0].LinkTopolicy__c))
                        queryCase.put('Case.'+MapforCase.get(s),(String)casl[0].LinktoPolicy__r.get(s.substringAfter('.')));
                    else
                        queryCase.put('Case.'+MapforCase.get(s),EvaluateFieldValue(s,'Case',casl));
                }
                system.debug('#MapforCase: '+MapforCase);
                
                system.debug('#queryCase: '+queryCase);            
                
                for(String tag:FieldsForCaseList)
                {   
                    if(String.isNotBlank(queryCase.get('Case.'+MapforCase.get(tag))))
                    {
                        Integer foundPosition = MessageContent.indexOfIgnoreCase('{!Case.'+MapforCase.get(tag)+'}', 0);
                        
                        MessageContent = MessageContent.left(foundPosition) +
                                queryCase.get('Case.'+MapforCase.get(tag)) +
                                MessageContent.substring(foundPosition + ('{!Case.'+MapforCase.get(tag)+'}').length());
                    }
                    system.debug('##MessageContent: '+'{!Case.'+MapforCase.get(tag)+'}'+'           '+queryCase.get('Case.'+MapforCase.get(tag))+'   '+MessageContent);        
                }            
            }
    
            if(FieldsForPolicyList.size()>0 && String.isNotBlank(CaseId))
            {
                if(String.isNotBlank(CaseList[0].linktopolicy__c))
                {    
                    system.debug('#PolicyQ: '+'Select '+String.join(FieldsForPolicyList, ',')+' from InsurancePolicy__c where id=\''+CaseList[0].linktopolicy__c+'\''+' LIMIT 1');
        
                    List<InsurancePolicy__c> Policy = Database.query('Select '+String.join(FieldsForPolicyList, ',')+' from InsurancePolicy__c where id=\''+CaseList[0].linktopolicy__c+'\''+' LIMIT 1');
                    
                    for(String s:FieldsForPolicyList)      
                    {
                        if(s.substringBefore('.')=='CUID__c')
                            queryPolicy.put('CUID__c.'+MapforPolicy.get(s),(String)Policy[0].CUID__r.get(s.substringAfter('.')));
                        else
                            queryPolicy.put('InsurancePolicy__c.'+MapforPolicy.get(s),EvaluateFieldValue(s,'InsurancePolicy__c',Policy));
                    }
                    system.debug('#MapforPolicy: '+MapforPolicy);
                    
                    system.debug('#queryPolicy: '+queryPolicy);            
                    
                    for(String tag:FieldsForPolicyList)
                    {   
                        if(String.isNotBlank(queryPolicy.get('InsurancePolicy__c.'+MapforPolicy.get(tag))))
                        {
                            Integer foundPosition = MessageContent.indexOfIgnoreCase('{!InsurancePolicy__c.'+MapforPolicy.get(tag)+'}', 0);
                            
                            MessageContent = MessageContent.left(foundPosition) +
                                    queryPolicy.get('InsurancePolicy__c.'+MapforPolicy.get(tag)) +
                                    MessageContent.substring(foundPosition + ('{!InsurancePolicy__c.'+MapforPolicy.get(tag)+'}').length());
                        }
                        system.debug('##MessageContent: '+'{!InsurancePolicy__c.'+MapforPolicy.get(tag)+'}'+'           '+queryCase.get('InsurancePolicy__c.'+MapforPolicy.get(tag))+'   '+MessageContent);        
                    }
                }
            }
        } 
        
        if(String.isNotBlank(MessageContent))
            MsgTxt = MessageContent;

        return MsgTxt;
    }
    
    public pageReference SendSMS()
    {
        if(String.isBlank(MessageContent))
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, System.label.VFP17_Content_Missing);                                              
            ApexPages.addMessage(myMsg);               
        }
        else
        {
            Communications_to_customer__c SMS = new Communications_to_customer__c(Notification_Typology__c='SMS',
                                                                                  AccountId__c=CustomerId,
                                                                                  Message__c = MessageContent,
                                                                                  Mobile_Phone__c = MobileNumber,
                                                                                  Request_Date__c = String.valueOf((system.now()).format()));
            
            if(String.isNotBlank(CaseId))
                SMS.CaseId__c = CaseId;
            
            if(String.isNotBlank(SelectedTemplateId))
               	SMS.SMS_Template_Id__c = SelectedTemplateId;
            
            Savepoint sp = Database.setSavepoint();
            
            try
            {
                insert SMS;
                ProcessEnd = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, System.label.VFP17_SMS_Sent);                                              
                ApexPages.addMessage(myMsg);   
            }
            catch(exception ex)
            {
                Database.rollback(sp);
                system.debug('Error: '+ex.getmessage());
                ProcessEnd = false;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.label.VFP17_SMS_Not_Sent);                                              
                ApexPages.addMessage(myMsg);   
            }
        }
        
        return null;
    }
    
	public String EvaluateFieldValue(String InputValue, String ObjectName, List<sObject> ObjList)
    {
        String FieldValue ='';
        String FieldType;
        
        system.debug('###InputValue: '+InputValue+' Obj: '+ObjectName+' List:'+ObjList);
        
        if(String.isNotBlank(InputValue) && !InputValue.contains('.'))
        {               
            FieldType = String.valueof(Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().get(InputValue).getDescribe().getType());
            
            if(FieldType=='DATETIME' && (Datetime)ObjList[0].get(InputValue)!=null)
                FieldValue =String.valueof((((Datetime)ObjList[0].get(InputValue)).date()).format());
            else if (FieldType=='STRING' || FieldType=='EMAIL' || FieldType=='PHONE' || FieldType=='FAX' || FieldType=='PERCENT' || FieldType=='PICKLIST' || FieldType=='TEXTAREA' || FieldType=='URL')
                FieldValue =String.valueof((String)ObjList[0].get(InputValue));
            else if (FieldType=='DATE' && (Date)ObjList[0].get(InputValue)!=null)
                FieldValue =String.valueof(((Date)ObjList[0].get(InputValue)).format());     
            else if (FieldType=='DECIMAL' && (Decimal)ObjList[0].get(InputValue)!=null)
                FieldValue =String.valueof(((Decimal)ObjList[0].get(InputValue)).round());          
            else if (FieldType=='DOUBLE' && (Double)ObjList[0].get(InputValue)!=null)
                FieldValue =String.valueof(((Double)ObjList[0].get(InputValue)).round());          
            else if (FieldType=='INTEGER')
                FieldValue =String.valueof((Integer)ObjList[0].get(InputValue));
            else if(FieldType=='ADDRESS')
            {
                if(String.isNotBlank(String.valueof(((Address)ObjList[0].get(InputValue)).getStreet())))
                	FieldValue =String.valueof(((Address)ObjList[0].get(InputValue)).getStreet())+' ';
                
                if(String.isNotBlank(String.valueof(((Address)ObjList[0].get(InputValue)).getPostalCode())))
                    if(String.isBlank(FieldValue))
                    	FieldValue =String.valueof(((Address)ObjList[0].get(InputValue)).getPostalCode())+' ';
                	else
                        FieldValue +=String.valueof(((Address)ObjList[0].get(InputValue)).getPostalCode())+' ';
                
                if(String.isNotBlank(String.valueof(((Address)ObjList[0].get(InputValue)).getCity())))
                    if(String.isBlank(FieldValue))
                    	FieldValue =String.valueof(((Address)ObjList[0].get(InputValue)).getCity())+' ';
                	else
                        FieldValue +=String.valueof(((Address)ObjList[0].get(InputValue)).getCity())+' ';
                
                if(String.isNotBlank(String.valueof(((Address)ObjList[0].get(InputValue)).getCountry())))
                    if(String.isBlank(FieldValue))
                    	FieldValue =String.valueof(((Address)ObjList[0].get(InputValue)).getCountry());
                	else
                        FieldValue +=String.valueof(((Address)ObjList[0].get(InputValue)).getCountry());
            }
        }
        
        system.debug('##FieldValue:' +FieldValue);
        
        return FieldValue;
    }
    
    public pageReference Cancel()
    {
        PageReference returnPage = new PageReference(ApexPages.currentPage().getParameters().get('retURL')); 
        return returnPage;
    }
    
    @future
    public static void AutomaticSMS(Set<String> SMSInput)
    {
        system.debug('##Automatic SMS Start');
        String FolderAutomaticSMS = 'SMS Automatici';
        
        for(String s:SMSInput)
        {
            system.debug('##SMSInput: '+s);
            
            String ParentCaseId =s.substringBefore('|');
            String ParentAccountId = s.substringBetween('|');
            String Mobile = '';
            VFC17_SendSMS SMSClass = new VFC17_SendSMS();
            List<EmailTemplate> AutomaticTemplate = new list<EmailTemplate>();
            List<Account> AccountList = new list<Account>();
            List<Case> CaseList = new list<Case>();
            String AutomaticTemplateId = '';
            String AutomaticTemplateBody ='';
            String SMSBody ='';
            String FoundAccountId='';
            
            if(String.isNotBlank(ParentCaseId))
            	CaseList = [Select Id, AccountId, Linktopolicy__c from Case where id=:ParentCaseId];
            
            if(String.isNotBlank(s.substringAfterLast('|')))
            	AutomaticTemplate = [SELECT Id,Body,Folder.name,IsActive,Name FROM EmailTemplate where folder.name =: FolderAutomaticSMS and Name=:s.substringAfterLast('|')];
            
            if(AutomaticTemplate.size()==1)
            {                           
                AutomaticTemplateId = AutomaticTemplate[0].Id;
                AutomaticTemplateBody = AutomaticTemplate[0].Body;
                
                SMSBody = SMSClass.Calculatecontent(AutomaticTemplateBody,AutomaticTemplateId,ParentCaseId,ParentAccountId,CaseList);
                
                if(String.isNotBlank(SMSBody))
                {
                    AccountList  =[Select id, 
                                   RecordTypeid,
                                   MobilePhone__c,
                                   Additional_Phone__c,
                                   PersonMobilePhone,
                                   CIF_MobilePhone__c,
                                   CIF_PersonMobilePhone__c,
                                   Claim_PersonalMobile__c
                                   from Account
                                   where Id=:ParentAccountId                                  
                                   LIMIT 1];
                    
                    if(AccountList.size()>0)
                    	FoundAccountId = AccountList[0].id;
                    
                    system.debug('##AccountList: '+AccountList);
                    
                    if(String.isNotBlank(FoundAccountId))
                    {
                        MobileOutput Mb = new MobileOutput();
                        
                        Mb = SMSClass.ObtainMobileNumber(AccountList);
                        Mobile = Mb.AutomaticMobileList[0];
                        
                        if(String.isNotBlank(Mobile) && !SMSBody.containsAny('\\{!'))
                        {
                            Communications_to_customer__c SMS = new Communications_to_customer__c(Notification_Typology__c='SMS',
                                                                                                  AccountId__c=FoundAccountId,
                                                                                                  Message__c = SMSBody,
                                                                                                  Mobile_Phone__c = Mobile,
                                                                                                  SMS_Template_Id__c=AutomaticTemplateId,
                                                                                                  Request_Date__c = String.valueOf((system.now()).format()));
                            
                            if(String.isNotBlank(ParentCaseId))
                                SMS.CaseId__c = ParentCaseId;
                            
                            Savepoint sp = Database.setSavepoint();
                            
                            try
                            {
                                insert SMS; 
                            }
                            catch(exception ex)
                            {
                                Database.rollback(sp);
                                system.debug('Error: '+ex.getmessage());  
                            }                       
                        }       
                    }
                }
            }
        }
    }
}
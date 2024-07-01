/*
***************************************************************************************************
---------------------------------------------------------------------------------------------------
-- - Name          : VFC11_CaseFindAssociatedPolicy
-- - Author        : Marco Moscatelli
-- - Description   : Class used to visualize in the visualforce page VFC11_CaseFindAssociatedPolicy 
                     all the policies associated to the Account Linked to the case and select the 
                     policy that has to be associated to the Case
--
-- Maintenance History:
--
-- Date          Version  Remarks
-- -----------  -------  --------------------------------------------------------------------------
-- 22-04-2016   1.0     
---------------------------------------------------------------------------------------------------
***************************************************************************************************
*/

public with sharing class VFC11_CaseFindAssociatedPolicy
{
    private final Case cas;
    public boolean transactionStatus{set;get;}
    public String transactionError{set;get;}
    public Id caseid;
    public Id AccountId;
    public Id PolicyId;
    public list<InsurancePolicy__c> listPolicyResult{set;get;}
    //MOSCATELLI_M 10102016: Family Protect -- START
    public list<InsurancePolicyAAF__c> listPolicyResultAAF {set;get;}
    public Boolean isFamilyProtect {set;get;}
    public String FamilyProtectid;
    public id PolicyFamProtectId;
    //MOSCATELLI_M 10102016: Family Protect -- END
    public Map<String, String> UrlParameterMap;
    public integer selectedPolicyVal{set;get;}
  	public InsurancePolicy__c selectedPolicy{set;get;}
    public boolean NoAccount{set;get;}
    public boolean NoPolicy{set;get;}
    
    public VFC11_CaseFindAssociatedPolicy(ApexPages.StandardController stdController)
    {
        System.debug('>>> START VFC11_CaseFindAssociatedPolicy constructor <<<');
       
        NoAccount= false;
    	NoPolicy = false;        
        transactionStatus = false;
        transactionError = 'firstLoad';
        selectedPolicy = new InsurancePolicy__c(); 
        listPolicyResult = new list<InsurancePolicy__c>();
        //MOSCATELLI_M 10102016: Family Protect -- START
        listPolicyResultAAF = new list<InsurancePolicyAAF__c>();
        isFamilyProtect = false;
        FamilyProtectid = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectAcc).get(AP_Constants.rtAccAAFB2C);
        //MOSCATELLI_M 10102016: Family Protect -- END        
    	UrlParameterMap = ApexPages.currentPage().getParameters();
        
        if(UrlParameterMap.containsKey('id'))
            caseid = UrlParameterMap.get('id');
        
         if(UrlParameterMap.containsKey('Account'))
         {
             if(String.isNotBlank(UrlParameterMap.get('Account')))
             //MOSCATELLI_M 10102016: Family Protect -- START
               //AccountId = UrlParameterMap.get('Account');
             {
                 AccountId = UrlParameterMap.get('Account');
                 List<Account>AccRecTypId = ([Select RecordTypeId from Account where Id=:AccountId]);
                 
                 if(AccRecTypId[0].RecordTypeId ==FamilyProtectid )
                     isFamilyProtect = true;                     
             }
             //MOSCATELLI_M 10102016: Family Protect -- END
             else
                NoAccount = true;                        
         }
        
        if(UrlParameterMap.containsKey('Policy'))
        {
            if(String.isNotBlank(UrlParameterMap.get('Policy')))
                PolicyId = UrlParameterMap.get('Policy');
            //MOSCATELLI_M 10102016: Family Protect -- START
            else if(String.isNotBlank(UrlParameterMap.get('PolicyAAF')))
            {
                isFamilyProtect = true;
                PolicyFamProtectId = UrlParameterMap.get('PolicyAAF'); 
            }                               
            //MOSCATELLI_M 10102016: Family Protect -- END
            else             
                NoPolicy = true;                      
        }
        
        if(NoPolicy && NoAccount)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, system.label.NoUserSelected );                                               
            ApexPages.addMessage(myMsg);  
        }

        if(!NoAccount)
        {
            //MOSCATELLI_M 10102016: Family Protect -- START
            if(!isFamilyProtect)
            {
                String soql = 'SELECT id, Name, TECH_Company__c,CUID__r.Name , Policy_Holder_Fiscal_Id__c,CCDATE__c,EXPIRY_DATE__c,Product__c FROM   InsurancePolicy__c where CUID__c =: AccountId '; 
                
                for(InsurancePolicy__c inpol:Database.query(soql))
                {
                    listPolicyResult.add(inpol);
                }
            }
            else
            {
                String soql1 = 'Select Id,Name,Subscriber_national_identifier__r.Name, Subscriber_national_identifier__r.Codice_Fiscale_AAF__c,Contract_Effective_date__c,Contract_Termination_Date__c,Product_code_ADP__c From InsurancePolicyAAF__c where Subscriber_national_identifier__c =: AccountId';
                
                for(InsurancePolicyAAF__c inpolAAF:Database.query(soql1))
                {
                    listPolicyResultAAF.add(inpolAAF);
                }
            }
            //MOSCATELLI_M 10102016: Family Protect -- END
            
            //MOSCATELLI_M 10102016: Family Protect -- START
            //if(listPolicyResult.size()<=0)
            if(listPolicyResult.size()<=0 && listPolicyResultAAF.size()<=0)
            //MOSCATELLI_M 10102016: Family Protect -- END
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, system.label.VFP11_No_Policies_Found );                                               
                ApexPages.addMessage(myMsg);                  
            }
            
            System.debug('### listPolicyResult: '+listPolicyResult);  
            System.debug('>>> END VFC11_CaseFindAssociatedPolicy constructor <<<');
        }
        else if(NoAccount && !NoPolicy)
        {
            //MOSCATELLI_M 10102016: Family Protect -- START
            if(!isFamilyProtect)
            {
                String soql = 'SELECT id, Name, TECH_Company__c,CUID__r.Name,CUID__r.Id  , Policy_Holder_Fiscal_Id__c,CCDATE__c,EXPIRY_DATE__c,Product__c FROM InsurancePolicy__c where Id =: PolicyId '; 
                
                for(InsurancePolicy__c inpol:Database.query(soql))
                {
                    listPolicyResult.add(inpol);
                }
            }
            else
            {
                String soql1 = 'Select Id,Name,Subscriber_national_identifier__r.id,Subscriber_national_identifier__r.Name, Subscriber_national_identifier__r.Codice_Fiscale_AAF__c,Contract_Effective_date__c,Contract_Termination_Date__c,Product_code_ADP__c From InsurancePolicyAAF__c where Id =: PolicyFamProtectId'; 
                
                for(InsurancePolicyAAF__c inpolAAF:Database.query(soql1))
                {
                    listPolicyResultAAF.add(inpolAAF);
                }                
            }
            //MOSCATELLI_M 10102016: Family Protect -- END
            
            System.debug('### listPolicyResult: '+listPolicyResult);  
            System.debug('>>> END VFC11_CaseFindAssociatedPolicy constructor <<<');            
        }        
    }
    
    public void asociatePolicyToCase()
    { 
        try{
            //system.debug('SelectedResult:'+listPolicyResult[selectedPolicyVal]);
            
      		//system.debug('##CaseUpdated: '+caseid+' ##PolicyAdded : '+listPolicyResult[selectedPolicyVal].Name);
            
            if(!NoAccount)
            //MOSCATELLI_M 10102016: Family Protect -- START
            //update new Case (id=caseid , LinkToPolicy__c =listPolicyResult[selectedPolicyVal].Id  );
            {
                if(!isFamilyProtect)
                	update new Case (id=caseid , LinkToPolicy__c =listPolicyResult[selectedPolicyVal].Id  );
                else
                    update new Case (id=caseid , Insurance_Policy_AAF__c =listPolicyResultAAF[selectedPolicyVal].Id  );
            }
			  
            else if(NoAccount && !NoPolicy)
            {
                if(!isFamilyProtect)
                	update new Case (id=caseid , AccountId = listPolicyResult[selectedPolicyVal].CUID__r.Id);
                else
                    update new Case (id=caseid , AccountId = listPolicyResultAAF[selectedPolicyVal].Subscriber_national_identifier__r.id);
            }
            //MOSCATELLI_M 10102016: Family Protect -- END 
            System.debug('### VFC11_CaseFindAssociatedPolicy Case : updated');
            
            transactionStatus = true;
            transactionError = 'success';
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, system.label.VFP11_Action_Performed);                                               
            ApexPages.addMessage(myMsg);    
            
            System.debug('### VFC11_CaseFindAssociatedPolicy transactionStatus : '+transactionStatus );
            System.debug('### VFC11_CaseFindAssociatedPolicy transactionError : '+transactionError );
           
            System.debug('>>> END VFC11_CaseFindAssociatedPolicy asociatePolicyToCase <<<');
        
        }catch(Exception e){
            transactionStatus = false;
            transactionError = e.getmessage();
            
            System.debug('>>> END VFC11_CaseFindAssociatedPolicy asociatePolicyToCase <<<');
        }
    }//end of method  
}//end of class
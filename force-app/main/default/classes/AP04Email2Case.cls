public with sharing class AP04Email2Case {
    /* 
----------------------------------------------------------------------
-- - Name          : AP04Email2Case
-- - Author        : Spoon Consulting
-- - Description   : Class to set account
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 27-JAN-2015  NAP     1.0     Initial version
----------------------------------------------------------------------
***********************************************************************/
    
    public static void setAccount(list<Case> listCase,set<String> setEmail,set<String> setAccId){
        System.debug('>>> START AP04Email2Case - setAccount <<<');
        list<Case> listUpdateCase = new list<Case>();
        map<String,account> mapEmail = new map<String,account>();
        map<String,account> mapAcc = new map<String,account>();
        
        //MMOSCATELLI 17/10/2016: Family Protect -- START
        /*
for (Account acc : [Select PersonEmail, Account_email__c,recordtype.developername, ispersonaccount,PersonContactId
From Account 
Where PersonEmail IN :setEmail //recordtype.developername IN (:AP_Constants.rtAccIndividualClient,:AP_Constants.rtAccCorporateClient)
Or Account_email__c IN :setEmail
Or Id in :setAccId
Order by lastmodifieddate asc]){
string accEmail = (acc.PersonEmail==null)?acc.Account_email__c:acc.PersonEmail;
mapEmail.put(accEmail,acc);
mapAcc.put(acc.id,acc);
}
*/            
        Map<Id, String> recordTypeMap = RecordTypeUtility.getRecordTypeMap('Account');
        Set <String> EmailtoRemove = new Set<String>();
        
        String queryAccount;
        
        for(String s: setEmail)
        {
            if(String.isblank(queryAccount))
               queryAccount = s;
            else
               queryAccount+=' OR '+s;
        }
        system.debug('queryAccount:'+queryAccount);
        
        List<List<SObject>> ListAccounts=[FIND :queryAccount IN ALL FIELDS RETURNING Account(ID)]; 
        List<Account> ListAccountsQuery = new list<Account>();
        ListAccountsQuery = ((List<Account>)ListAccounts[0]);
        
        //MOSCATELLI_M 02/07/2018: Easy Azienda -- START
        map<String,User> MapUserEmail = new map<String,User>();
        List<List<SObject>> ListUsers=[FIND :queryAccount IN ALL FIELDS RETURNING User(ID where profile.name in ('AAI - Vendite Avanzato','AAI - Vendite Base'))]; 
        List<User> ListUsersQuery = new list<User>();
        ListUsersQuery = ((List<User>)ListUsers[0]);
        String UserEmail = ''; 
		system.debug('ORLANDO -- @@ '+ListUsers+ ' ###  -- '+setEmail);
        for(User U: [Select Id, Name, FirstName, LastName, CommunityNickname, isActive, Email,Profile.Name, ContactId from User where id in:ListUsersQuery and Email in:setEmail])   
        {           
           UserEmail = U.Email;

            if(!MapUserEmail.containsKey(UserEmail))           
                MapUserEmail.put(UserEmail,U);
            else
                EmailtoRemove.add(UserEmail);
        }    
        //MOSCATELLI_M 02/07/2018: Easy Azienda -- END

        
        for (Account acc : [Select Id,PersonEmail,Account_email__c,Additional_email__c,Subject_email__c, recordtypeid, ispersonaccount,PersonContactId,recordtype.developername,CIF_PersonalEmail__c,CIF_Work_email__c,CIF_PersonEmail__c,Claim_PersonalEmail__c

                            From Account 
                            Where (id in:ListAccountsQuery OR id in:setAccId)
                            and (Additional_email__c IN :setEmail  
                            Or Account_email__c IN :setEmail
                            Or PersonEmail  IN: setEmail
                            Or Subject_email__c IN : setEmail
                            //MOSCATELLI 17/02/2017: Evo 77 -- Start
                            Or CIF_PersonalEmail__c IN : setEmail
                            Or CIF_Work_email__c IN : setEmail
                            Or CIF_PersonEmail__c IN : setEmail                            
                            Or Claim_PersonalEmail__c IN : setEmail)
                            //MOSCATELLI 17/02/2017: Evo 77 -- End
                            Order by lastmodifieddate asc]){
                                
                                String accEmail = '';
                                
                                if(String.isNotBlank(acc.Additional_email__c) && setEmail.contains(acc.Additional_email__c))
                                    accEmail = acc.Additional_email__c;
                                else if(recordTypeMap.containsKey(acc.recordtypeid) && (recordTypeMap.get(acc.recordtypeid) == AP_Constants.rtAccCorporateClient) && acc.Account_email__c!='' && setEmail.contains(acc.Account_email__c))
                                    accEmail = acc.Account_email__c;
                                //MOSCATELLI 17/02/2017: Evo 77 -- START
                                else if(recordTypeMap.containsKey(acc.recordtypeid) && (recordTypeMap.get(acc.recordtypeid) == AP_Constants.rtAccB2B) && (acc.CIF_PersonalEmail__c!='' || acc.CIF_Work_email__c!='' || acc.Subject_email__c!=''))    
                                {
                                    if(setEmail.contains(acc.CIF_PersonalEmail__c) && String.isNotBlank(acc.CIF_PersonalEmail__c))
                                        accEmail = acc.CIF_PersonalEmail__c;
                                    else if(setEmail.contains(acc.CIF_Work_email__c) && String.isNotBlank(acc.CIF_Work_email__c))
                                        accEmail = acc.CIF_Work_email__c;
                                    else if(setEmail.contains(acc.Subject_email__c) && String.isNotBlank(acc.Subject_email__c))
                                        accEmail = acc.Subject_email__c;
                                }	
                                    //accEmail = acc.Subject_email__c;
                                else if(recordTypeMap.containsKey(acc.recordtypeid) && (recordTypeMap.get(acc.recordtypeid) == AP_Constants.rtAccB2C) && (acc.CIF_PersonEmail__c!='' || acc.CIF_Work_email__c!=''))    
                                {
                                    if(setEmail.contains(acc.CIF_PersonEmail__c) && String.isNotBlank(acc.CIF_PersonEmail__c))
                                        accEmail = acc.CIF_PersonEmail__c;
                                    else if(setEmail.contains(acc.CIF_Work_email__c) && String.isNotBlank(acc.CIF_Work_email__c))
                                        accEmail = acc.CIF_Work_email__c;
                                }                                  
                                else if(acc.PersonEmail!='' && setEmail.contains(acc.PersonEmail))
                                    accEmail = acc.PersonEmail;
                                else if(acc.Claim_PersonalEmail__c!='' && setEmail.contains(acc.Claim_PersonalEmail__c))
                                    accEmail = acc.Claim_PersonalEmail__c;                                
                                //MOSCATELLI 17/02/2017: Evo 77 -- End                              
                                
                                if(!mapEmail.containsKey(accEmail))           
                                    mapEmail.put(accEmail,acc);
                                else
                                    EmailtoRemove.add(accEmail);
                                
                                mapAcc.put(acc.id,acc);                                                       
                            }//end loop
        
        //Avoid account automatic assignment in case the same email is associated to multiple accounts
        for(String rem : EmailtoRemove)
        {
            if(mapEmail.containsKey(rem))
                mapEmail.remove(rem);
        }      
        //MMOSCATELLI 17/10/2016: Family Protect -- END 
        
        //OAVERSANO 08/04/2019 : DAC Fase II -- START
        Map<String, Schema.RecordTypeInfo> MapCaseRecordType = new Map<String, Schema.RecordTypeInfo> ();
        String[] types = new String[]{'Case'}; 
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types); 
        for (Schema.RecordTypeInfo ri: results[0].getRecordTypeInfos()) 
	    { 
	        MapCaseRecordType.put(ri.getRecordTypeId(), ri);
	    } 
        
        for(Case cas:listCase)
        {
            Case caseUpdate = new Case(id=cas.id,origin=AP_Constants.caseOriginEmail);
            system.debug('####$$$'+cas.accountid);
            
            //MOSCATELLI_M 02/07/2018: Easy Azienda -- START 
            if(MapUserEmail.containskey(cas.SuppliedEmail))
            {
            	//OAVERSANO 08/04/2019 : DAC Fase II -- START
                if((MapUserEmail.get(cas.SuppliedEmail).Profile.Name == 'AAI - Vendite Avanzato' || MapUserEmail.get(cas.SuppliedEmail).Profile.Name =='AAI - Vendite Base')
                && (MapCaseRecordType.get(cas.RecordTypeId).getDeveloperName() <> Ap_Constants.rtCaseDACAgenti))
                
                {
                    caseUpdate.User__c = MapUserEmail.get(cas.SuppliedEmail).id;
                    caseUpdate.contactid = null;
                    caseUpdate.accountid=null;
                }
            }
            //if(cas.accountid<>null)
            //MOSCATELLI_M 02/07/2018: Easy Azienda -- END
            
            else if(cas.accountid<>null)
            {
                //MMOSCATELLI 17/10/2016: Family Protect -- START
                //if(mapAcc.get(cas.accountid).recordtype.developername == AP_Constants.rtAccIntermediary){
                if(mapAcc.containsKey(cas.accountid) && 
                    recordTypeMap.containsKey(mapAcc.get(cas.accountid).recordtypeid) && 
                    recordTypeMap.get(mapAcc.get(cas.accountid).recordtypeid)== AP_Constants.rtAccIntermediary)
                {    
                //MMOSCATELLI 17/10/2016: Family Protect -- END                   
                    system.debug('####$$$111111');
                    caseUpdate.AgentName__c = cas.accountid; 
                    caseUpdate.accountid=null;
                    caseUpdate.contactid=null;
                    system.debug('####$$$22222'+mapAcc.get(cas.accountid).recordtype.developername);
                }
                //system.debug('####$$$22222'+mapAcc.get(cas.accountid).recordtype.developername);
            }
            else if(mapEmail.containsKey(cas.SuppliedEmail))
            {

                if(mapEmail.get(cas.SuppliedEmail).recordtype.developername <> AP_Constants.rtAccIntermediary)
                {  
                    caseUpdate.accountid = mapEmail.get(cas.SuppliedEmail).id;
                    caseUpdate.contactid = mapEmail.get(cas.SuppliedEmail).PersonContactId;
                }
                else
                {
                    caseUpdate.AgentName__c = mapEmail.get(cas.SuppliedEmail).id; 
                    caseUpdate.accountid=null;
                }           
            }

            listUpdateCase.add(caseUpdate);
        }
        //update case
        if(listUpdateCase.size() > 0)
        {
            try
            {
                Database.update(listUpdateCase,false);
            }
            catch(exception ex)
            {
                system.debug('@@ Errore: '+ex.getMessage());
            }
        }//end of check size
        
        System.debug('>>> END AP04Email2Case - setAccount <<<');
    }//end of method SetCase
    
}//end of class
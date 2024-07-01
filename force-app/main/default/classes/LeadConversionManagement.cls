public without sharing class LeadConversionManagement{


          public  LeadConversionManagement(){}


          public static void handleLeadConversionOnCase (Lead inputLead, Account targetAccount){


            Account_Case__c.sObjectType.getDescribe().isCreateable();
            //FM_03/07/2018 : Easy Azienda - @Lead Conversion, if Lead is related to Cases, associate Account to those Cases
            List<Case> CaseRelatedToLead = [SELECT Id, Lead__c, AccountId FROM Case WHERE Lead__c =: inputLead.Id ];
            system.debug('My Cases List'+ CaseRelatedToLead);

            List<Feedback__c> FeedbackRelatedToLead = [SELECT Id, Complaint__c FROM Feedback__c WHERE Lead__c =: inputLead.Id];
            system.debug('My Feebback List'+ FeedbackRelatedToLead);


            if(CaseRelatedToLead.size()>0){

              for(Case c: CaseRelatedToLead){

                c.AccountId = targetAccount.Id;
                c.Lead__c = null;

              }

              if(FeedbackRelatedToLead.size()>0){

              for(Feedback__c f: FeedbackRelatedToLead){

                f.Account__c = targetAccount.Id;
                f.Lead__c = null;

              }
            }
              Database.update(CaseRelatedToLead);
              Database.update(FeedbackRelatedToLead);
            }


          }

          public static void ManageAccountCaseRecords (List<Case> Cases, Map<String,Case> OldValues, Map<String,Account> MapCaseAccount){

            List<Account_Case__c> ListACToInsert = new List<Account_Case__c>();
            List<Account_Case__c> ListACToDelete = new List<Account_Case__c>();
            Map<Id,List<Account_Case__c>> MapCaseAC = new map<Id,List<Account_Case__c>>();
            List<Account_Case__c> ListExistentAccountCase = new List<Account_Case__c>();
            String OldVal ='';
            String NewVal = '';
            
            for(Account_Case__c ac : [SELECT Id, Account__c, Case__c FROM Account_Case__c where Case__c in: OldValues.keySet()])
            {
                NewVal = ac.Case__c;
                
                if((OldVal == NewVal) || String.isBlank(OldVal))
                {
                    ListExistentAccountCase.add(ac);
                }
                else
                {
                    MapCaseAC.put(OldVal,ListExistentAccountCase);
                    ListExistentAccountCase.clear();
                    ListExistentAccountCase.add(ac);
                }               
                
                OldVal = NewVal;
            }
            
            if(ListExistentAccountCase.size()>0 && MapCaseAC.size()==0)
                MapCaseAC.put(OldVal,ListExistentAccountCase);
            
            for(Case c : Cases)
            {
                if(MapCaseAccount.containskey(c.AccountId))
                {
                    if(MapCaseAccount.get(c.AccountId).RecordType.developername == AP_Constants.rtAccB2C || MapCaseAccount.get(c.AccountId).RecordType.developername == AP_Constants.rtAccB2B)              
                    {
                        if(MapCaseAC.containsKey(c.id))
                            ListACToDelete.addAll(MapCaseAC.get(c.id));
                        
                        ListACToInsert.add(new Account_Case__c (Case__c = c.Id, Account__c = c.AccountId));
                    }    
                }                                   
            }
            
            if(ListACToDelete.size()>0)
            {
                Set<Account_Case__c> tempACDeleteSet = new Set<Account_Case__c>(ListACToDelete);
                ListACToDelete.clear();
                ListACToDelete.addAll(tempACDeleteSet);
                
                delete ListACToDelete;
            }
            
            if(ListACToInsert.size()>0)
                insert ListACToInsert;
            
          }
      
    }
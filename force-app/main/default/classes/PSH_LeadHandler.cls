/*------------------------------------------------------------------------
Author:        Lorenzo Santoro
Company:       Deloitte
Class:         PSH_LeadHandler 
Description:   this handler counts the Leads based on User. on the final step i Update the relevant DashboardRow

History
-22/08/2016   Lorenzo Santoro - Created

----------------------------------------------------------------------------*/

public class PSH_LeadHandler implements ProcedureStepHandler {
// No Final step required
// At each scope i save a DashboardRowSet
    public Map< String,Map<String,String> > WalkStep(Procedure_Step__c thisStep, List<Sobject> scope) {
         system.debug('+++walking step'+ thisStep.Step_Handler_Class__c);
         system.debug('+++scopesize'+scope.size());
    

        //USED ONLY FOR TESTS, INSTEAD OF PASSING THE RECORDS BY THE BATCH EXECUTION
        /*
        List<SObject> rList = [
            Select Id,Status,OwnerId, LastModifiedDate,LastModifiedDateOfInterest__c,LastmodifiedById,isconverted FROM Lead WHERE owner.isactive=true and 
            Owner.Profile.Name in ('AAI - Vendite Avanzato','AAI - Vendite Base') 
            and 
            (LastModifiedDateOfInterest__c=THIS_WEEK or Status IN ('To be contacted','Call again', 'Da contattare', 'Da ricontattare') ) 
            order by OwnerId
        ];    
        */
        
        List<Lead> rList = (List<Lead>) scope;
    
        Map<String,Map<String,string>> theresult = new Map<String,Map<String,string>>(); 
        
       
        for (Lead rec :rList) 
        {
        
        
            String timeRef = DashboardRemoter.getTimeRef();
            String currentKey = rec.OwnerId+'_'+timeRef+'';
            
            if (theresult.keyset().contains(currentKey) == false) 
            {

                //inserting first time this user and initialized to zero all counts
                Map<String,String> zerocount = new Map<String,String>();

                zerocount.put('Lead_Ownership__c','0');
                zerocount.put('Lead_Contacts__c','0');
                
                theresult.put(currentKey,zerocount);

            }


            //I have to add
            Map<String,String> currentCountforUser = theresult.get(currentKey);
            
            
            Set<String> Lead_Ownership_Status = new Set<String>{'To be contacted','Call again', 
                                                                'Da contattare', 'Da ricontattare'};
            Set<String> Lead_Contacts_Status = new Set<String>{'Interested', 'Not interested', 'Call again', 'Wrong contact information', 'Duplicated Lead',
                                                               'Interessato', 'Non interessato', 'Da ricontattare', 'Contatto errato', 'Lead duplicato'};
            
            if (Lead_Ownership_Status.contains(rec.Status+'')) { currentCountforUser.put('Lead_Ownership__c',String.ValueOf(integer.ValueOf(currentCountforUser.get('Lead_Ownership__c'))+1)); }
            if (DashboardRemoter.isInThisWeek(rec.LastModifiedDateOfInterest__c) && Lead_Contacts_Status.contains(rec.Status+'')) { currentCountforUser.put('Lead_Contacts__c',String.ValueOf(integer.ValueOf(currentCountforUser.get('Lead_Contacts__c'))+1)); }

            theresult.put(currentKey,currentCountforUser);

   

        }
        
        system.debug('theresult: '+ theresult);
        
        
        return theresult;
            
        

    }
    
    public void FinalAction(Procedure_Step__c thisStep, Map< String,Map<String,String> > thePropList) {
        system.debug('+++here i handle'+thePropList);
        DashboardRemoter.commitRowsNew(thePropList);
    }
    

    

}
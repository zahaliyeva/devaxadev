/*------------------------------------------------------------------------
Author:        Lorenzo Santoro
Company:       Deloitte
Class:         PSH_OpportunityHandler
Description:   this handler counts the Opportunity based on User. on the final step it Update the relevant DashboardRow

History
-23/08/2016   Lorenzo Santoro - Created
-07/09/2016   Davide Fabris
    - Added logic for current week vs previous week created Date
    - added logic to use field "isWon" and "isClosed" instead of direct comparison of stage names                        

----------------------------------------------------------------------------*/

public class PSH_OpportunityHandler implements ProcedureStepHandler {
    // No Final step required
    // At each scope i save a DashboardRowSet
    public Map< String,Map<String,String> > WalkStep(Procedure_Step__c thisStep, List<Sobject> scope) {
         system.debug('+++walking step'+ thisStep.Step_Handler_Class__c);
         system.debug('+++scopesize'+scope.size());
        

        //USED ONLY FOR TESTS, INSTEAD OF PASSING THE RECORDS BY THE BATCH EXECUTION
        //
        
        /*
        List<SObject> scope = [
            select id, ownerid, owner.name, LeadSource, StageName, CampaignId, lastmodifieddateOfInterest__c from opportunity where Owner.isactive=true and Owner.Profile.Name in ('AAI - Vendite Avanzato','AAI - Vendite Base') 
            and (lastmodifieddateOfInterest__c = THIS_WEEK or StageName not in ('Closed Won','Closed Lost')) 
            order by ownerid
            ];
        
        */
        
        List<Opportunity> rList = (List<Opportunity>) scope;
        
        Map<String,Map<String,string>> theresult = new Map<String,Map<String,string>>(); 
        
        
        for (Opportunity rec :rList) {
            
            string timeRef = DashboardRemoter.getTimeRef();
            string currentKey = rec.OwnerId+'_'+timeRef+'';
            
            if (theresult.keyset().contains(currentKey) == false) {

                //inserting first time this user and initialized to zero all counts
                Map<String,String> zerocount = new Map<String,String>();
                
                zerocount.put('Opportunity_Ownership__c','0');
                
                zerocount.put('Client_Opportunities__c','0');
                zerocount.put('Client_Opportunities_Won__c','0');
                zerocount.put('Client_Opportunities_Past__c','0');
                zerocount.put('Client_Opportunities_Won_Past__c','0');

                
                zerocount.put('Lead_Opportunities__c','0');
                zerocount.put('Lead_Opportunities_Won__c','0');
                zerocount.put('Lead_Opportunities_Past__c','0');
                zerocount.put('Lead_Opportunities_Won_Past__c','0');
                
                zerocount.put('Campaign_Opportunities__c','0');
                zerocount.put('Campaign_Opportunities_Won__c','0');
                zerocount.put('Campaign_Opportunities_Past__c','0');
                zerocount.put('Campaign_Opportunities_Won_Past__c','0');

                theresult.put(currentKey,zerocount);
            }

            //I have to add
            Map<String,String> currentCountforUser = theresult.get(currentKey);

            //This one just for counting total owned opportunities open
            if ( !rec.isClosed ) {
                currentCountforUser.put('Opportunity_Ownership__c',String.ValueOf(integer.ValueOf(currentCountforUser.get('Opportunity_Ownership__c'))+1));
            }

            /////COUNTING CLIENT OPPS ///////
            //All Opps
            if (DashboardRemoter.isInThisWeek(rec.LastModifiedDateOfInterest__c) && rec.LeadSource == null && rec.CampaignId == null ) {
                currentCountforUser.put('Client_Opportunities__c',String.ValueOf(integer.ValueOf(currentCountforUser.get('Client_Opportunities__c'))+1));

                //Adding logic for past weeks
                if (!DashboardRemoter.isInThisWeek(rec.createdDate)) {
                    currentCountforUser.put('Client_Opportunities_Past__c',String.ValueOf(integer.ValueOf(currentCountforUser.get('Client_Opportunities_Past__c'))+1));
                }
            }
            
            //Won Opps
            if (DashboardRemoter.isInThisWeek(rec.LastModifiedDateOfInterest__c) && rec.LeadSource == null && rec.CampaignId == null && rec.isWon ) {
                currentCountforUser.put('Client_Opportunities_Won__c',String.ValueOf(integer.ValueOf(currentCountforUser.get('Client_Opportunities_Won__c'))+1));
                //Adding logic for past weeks
                if (!DashboardRemoter.isInThisWeek(rec.createdDate)) {
                    currentCountforUser.put('Client_Opportunities_Won_Past__c',String.ValueOf(integer.ValueOf(currentCountforUser.get('Client_Opportunities_Won_Past__c'))+1)); 
                }
            }
            //CLIENT OPP COUNTED/////
            
            /////COUNTING Lead OPPS ///////
            //All Opps
            if (DashboardRemoter.isInThisWeek(rec.LastModifiedDateOfInterest__c) && rec.LeadSource != null) {
                currentCountforUser.put('Lead_Opportunities__c',String.ValueOf(integer.ValueOf(currentCountforUser.get('Lead_Opportunities__c'))+1));
                
                //Adding logic for past weeks
                if (!DashboardRemoter.isInThisWeek(rec.createdDate)) {
                    currentCountforUser.put('Lead_Opportunities_Past__c',String.ValueOf(integer.ValueOf(currentCountforUser.get('Lead_Opportunities_Past__c'))+1));
                }
            }
            
            //Won Opps
            if (DashboardRemoter.isInThisWeek(rec.LastModifiedDateOfInterest__c) && rec.LeadSource != null && rec.isWon) {
                currentCountforUser.put('Lead_Opportunities_Won__c',String.ValueOf(integer.ValueOf(currentCountforUser.get('Lead_Opportunities_Won__c'))+1));
                
                //Adding logic for past weeks
                if (!DashboardRemoter.isInThisWeek(rec.createdDate)) {
                    currentCountforUser.put('Lead_Opportunities_Won_Past__c',String.ValueOf(integer.ValueOf(currentCountforUser.get('Lead_Opportunities_Won_Past__c'))+1));
                }
            }
            //LEAD OPP COUNTED/////

            /////COUNTING Campaign OPPS ///////
            //All Opps
            if (DashboardRemoter.isInThisWeek(rec.LastModifiedDateOfInterest__c) && rec.CampaignId != null ) {
                currentCountforUser.put('Campaign_Opportunities__c',String.ValueOf(integer.ValueOf(currentCountforUser.get('Campaign_Opportunities__c'))+1));
                
                //Adding logic for past weeks
                if (!DashboardRemoter.isInThisWeek(rec.createdDate)) {
                    currentCountforUser.put('Campaign_Opportunities_Past__c',String.ValueOf(integer.ValueOf(currentCountforUser.get('Campaign_Opportunities_Past__c'))+1));
                }
            }
            //Won Opps
            if (DashboardRemoter.isInThisWeek(rec.LastModifiedDateOfInterest__c) && rec.CampaignId != null && rec.isWon) {
                currentCountforUser.put('Campaign_Opportunities_Won__c',String.ValueOf(integer.ValueOf(currentCountforUser.get('Campaign_Opportunities_Won__c'))+1));
                //Adding logic for past weeks
                if (!DashboardRemoter.isInThisWeek(rec.createdDate)) {
                    currentCountforUser.put('Campaign_Opportunities_Won_Past__c',String.ValueOf(integer.ValueOf(currentCountforUser.get('Campaign_Opportunities_Won_Past__c'))+1));
                }
            }




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
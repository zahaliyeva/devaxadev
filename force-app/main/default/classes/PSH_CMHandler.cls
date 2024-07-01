/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         PSH_CMHandler 
Description:   this handler counts the CampaignMembers based on User. on the final step i Update the relevant DashboardRow

History
-19/08/2016   Davide Fabris - Created

----------------------------------------------------------------------------*/

public class PSH_CMHandler implements ProcedureStepHandler {
// No Final step required
// At each scope i save a DashboardRowSet
    public Map< String,Map<String,String> > WalkStep(Procedure_Step__c thisStep, List<Sobject> scope) {
         system.debug('+++walking step'+ thisStep.Step_Handler_Class__c);
         system.debug('+++scopesize'+scope.size());        
        /*
        List<SObject> scope = [
            SELECT id, Owner__c, Status, LastModifieddateOfInterest__c, LastModifiedById, LastmodifiedDate, CampaignId,Agency_Code__c, Campaign_member_related_opportunity__c, Campaign_member_related_opportunity__r.StageName, Campaign_member_related_opportunity__r.LastModifieddateOfInterest__c, Campaign_member_related_opportunity__r.isWon FROM CampaignMember WHERE 
            Owner__c!='' and Owner__r.isactive=true 
            AND 
            ( 
            (LastModifieddateOfInterest__c=THIS_WEEK) 
            OR 
            (Status in ('To be contacted', 'Call again','Interested', 'Not interested', 'Wrong contact information') ) 
            ) 
            ORDER BY Owner__c, Agency_Code__c
        ];        
        */       
        
        List<CampaignMember> CMList = (List<CampaignMember>) scope;
        
        Map<String,Map<String,string>> theresult = new Map<String,Map<String,string>>();
       
        for (CampaignMember rec : CMList) {
            
            
            String timeRef = DashboardRemoter.getTimeRef();
            String currentKey = rec.Owner__c+'_'+timeRef+'';
            
            if (theresult.keyset().contains(currentKey) == false) 
            {

                //inserting first time this user and initialized to zero all counts
                Map<String,String> zerocount = new Map<String,String>();

                zerocount.put('CampaignMember_Ownership__c','0');
                zerocount.put('Campaign_contacts__c','0');
                
                
                theresult.put(currentKey,zerocount);

            }


            //I have to add
            Map<String,String> currentCountforUser = theresult.get(currentKey);
            
            system.debug('rec.Status: '+rec.Status);
            
            
            Set<String> CampaignMember_Ownership_Status = new Set<String>{'To be contacted', 'Call again',
                                                                          'Da contattare', 'Da ricontattare'};
            Set<String> Campaign_contacts_Status = new Set<String>{'Interested', 'Not interested', 'Call again', 'Wrong contact information', 
                                                                   'Interessato', 'Non interessato', 'Da ricontattare', 'Contatto errato'};
            
            if (CampaignMember_Ownership_Status.contains(rec.Status+'')) { currentCountforUser.put('CampaignMember_Ownership__c',String.ValueOf(integer.ValueOf(currentCountforUser.get('CampaignMember_Ownership__c'))+1)); }
            if (DashboardRemoter.isInThisWeek(rec.LastModifiedDateOfInterest__c) && Campaign_contacts_Status.contains(rec.Status+'')) { currentCountforUser.put('Campaign_contacts__c',String.ValueOf(integer.ValueOf(currentCountforUser.get('Campaign_contacts__c'))+1)); }
            

            theresult.put(currentKey,currentCountforUser);
             
            
        }
        
        System.debug('theresult: '+theresult);
        return theresult;
    }
    
    public void FinalAction(Procedure_Step__c thisStep, Map< String,Map<String,String> > thePropList) {
        system.debug('+++here i handle'+thePropList);
        DashboardRemoter.commitRowsNew(thePropList);
    }
    

    

}
global with sharing class UpdateMilestoneTimeTrigger implements Support.MilestoneTriggerTimeCalculator
{   
    global Integer calculateMilestoneTriggerTime (String caseId, String milestoneTypeId)
    {
       system.debug('###########Start Milestone Calculation');
        Case c = [SELECT EntitlementId,CreatedDate,SLAHours__c,SLAStartDate,Data_ricezione_richiesta_DPO__c,TECH_SLAHours__c,TotalNumHoursStatusPending__c, TotalNumHoursStatusDelegated__c from Case where Id =: caseId];  
        
        system.debug('EntitlementId1'+c.EntitlementId);

        if(c.SLAHours__c>0){  

            if(c.TECH_SLAHours__c == null){
                c.TECH_SLAHours__c = c.SLAHours__c;   
                update(c);
            }

            /*
            
            
            system.debug('EntitlementId2'+c.EntitlementId);
            try {
            CaseMilestone cm = [SELECT StartDate,SystemModstamp from CaseMilestone where CaseId =: caseId];
            cm.StartDate = c.Data_ricezione_richiesta_DPO__c;   
            system.debug('Case Milestone to update'+cm+' '+cm.StartDate+' '+ cm.ID);
            update(cm);
            CaseMilestone cmafterupdate = [SELECT StartDate,SystemModstamp from CaseMilestone WHERE CaseId =: caseId];
            system.debug('cm StartDate after update'+cmafterupdate.StartDate);
            system.debug('cm systemmodestamp'+cm.SystemModstamp);
            system.debug('cm cmafterupdate systemmodestamp'+cmafterupdate.SystemModstamp);
            }catch (exception e) {
            }
            c.SLAStartDate = c.Data_ricezione_richiesta_DPO__c;
            Database.SaveResult SaveResultC = database.update(c,false);*/

            
            system.debug('SLAHours'+integer.valueOf(c.SLAHours__c*60));

           

             return integer.valueOf(c.TECH_SLAHours__c*60); 


        
    	}else{
            system.debug('SLAHours negative'+c.SLAHours__c);


            //decimal totalHours = c.SLAHours__c + ((c.TotalNumHoursStatusPending__c==null)?0:c.TotalNumHoursStatusPending__c) +((c.TotalNumHoursStatusDelegated__c==null)?0:c.TotalNumHoursStatusDelegated__c);

    		/*CaseMilestone cm = [SELECT StartDate from CaseMilestone where CaseId =: caseId];
    		cm.StartDate = c.Data_ricezione_richiesta_DPO__c;	
    		c.SLAStartDate = c.Data_ricezione_richiesta_DPO__c;
            //c.CaseDueDate__c =  BusinessHours.addGMT('01m6E0000008UsU',c.CreatedDate,(totalHours*60 * 60 * 1000L).longValue());
            //c.NextStatusDate__c = c.CaseDueDate__c;
            //c.DueDate__c = date.newinstance(c.CaseDueDate__c.year(),c.CaseDueDate__c.month(), c.CaseDueDate__c.day());
    		//c.SLAHours__c = c.TECH_SLAHours__c;  

             
    		//update(cm);
            system.debug('Case Milestone to update'+cm+' '+cm.StartDate+' '+ cm.ID);
             Database.SaveResult SaveResult = database.update (cm,false); 
             system.debug('SaveResult'+SaveResult); 
             system.debug('cm StartDate'+cm.StartDate);  
             system.debug('cm systemmodestamp'+cm.SystemModstamp);		
			
            Database.SaveResult SaveResultC = database.update(c,false);
             system.debug('SaveResultC'+SaveResultC);  */

    		return integer.valueOf(c.TECH_SLAHours__c*60);
    		
    	
    	}

    }
}
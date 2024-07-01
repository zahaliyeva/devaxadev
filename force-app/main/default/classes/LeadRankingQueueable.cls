public class LeadRankingQueueable implements Queueable, Database.AllowsCallouts {
    
    public Lead singleLead; 

    public LeadRankingQueueable(Lead newLead){
        singleLead = newLead;
    }


    public void execute(QueueableContext context) {
        system.debug('***FM - in Queueable: ' + singleLead);
		singleLead = leadCounter(singleLead);
        LeadAssignment.ResponseDto results = LeadAssignment.sendRequest(singleLead);

        //BOVOLENTA_D 08082017 set a default if something went wrong
        if (results.isSuccess == False )
        {

            if (String.isEmpty(singleLead.Azioni_intraprese_sul_Lead__c))
            {
                singleLead.Azioni_intraprese_sul_Lead__c = 'Chiamata a Noovle fallita: '+results.message;
            }
            //BOVOLENTA_D 07092017 send to a dedicate queue if it's not requesting an appointment in a specific agency // removed exclusion as it is not assigned anyways: && singleLead.Dettaglio__c != 'Richiedi appuntamento' && String.isEmpty(singleLead.Agency_Code__c)
            Id leadGenericQueue = UtilityClass.retrieveGroupId('Queue','Coda_Lead_Non_Assegnati_Integrazione_KO');
            singleLead.OwnerId = leadGenericQueue;

            Database.SaveResult SaveResult = database.update (singleLead,false);
            //BOVOLENTA_D SPRINT 59 AUTO-RETRIES
            try{
	            Integer maxNoovleCalloutsRetries = Integer.valueOf(LeadAssignmentConfiguration__c.getValues('maxNoovleCalloutsRetries').DaysLimit__c);
	            if ((singleLead.Total_Noovle_callouts__c )<= maxNoovleCalloutsRetries)
	            {
		            LeadRankingQueueable agenciesRankingforLead = new LeadRankingQueueable(singleLead);   
					Id agenciesRankingforLeadJobId = System.enqueueJob(agenciesRankingforLead);
	            }
            }catch (Exception e)
            {
                    ApplicationLogHelper.ERROR('LeadRankingQueueable', e.getMessage(), e.getStackTraceString());
                
            }
        }     
        //BOVOLENTA_D END  

            
    }
    
    public static Lead leadCounter (Lead singleLead)
    {
        //BOVOLENTA_D SPRINT 59 AUTO-RETRIES
        if (singleLead.Total_Noovle_callouts__c != null)
        {
        	singleLead.Total_Noovle_callouts__c = singleLead.Total_Noovle_callouts__c +1;
        }
        else 
        {
        	singleLead.Total_Noovle_callouts__c = 1;
        }
        return singleLead;    	
    }


}
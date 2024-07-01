/**
* Class that addresses the lead's first assignment process 
* 
*/
public class LeadAssignmentQueueable implements Queueable {

    List<Lead> leadsToProcess;

    public LeadAssignmentQueueable(List<Lead> leadsList){
        leadsToProcess = leadsList;
    }

    public void execute(QueueableContext context) {
        system.debug('***JV - in Queueable: ' + leadsToProcess);
        List<Lead> leadsToUpdate = new List<Lead>();
        List<Lead> leadsToReassign = new List<Lead>();
        Map<Id,Lead> leadsForDuplicateClients = new Map<Id,Lead>();
        Set<Id> leadIdsToReassign = new Set<Id>();
        for(Lead tempLead:leadsToProcess){
            leadsForDuplicateClients.put(tempLead.Id,tempLead); 
        }
        List<Lead> leadSitiAgentiList = new List<Lead>();
        LeadAssignment.LeadsListsWrapper leadsAfterLeadDuplication = LeadAssignment.getDuplicatedLeadsWithLeads(leadsToProcess);
        if(leadsAfterLeadDuplication.leadsList1.size()>0)
            leadsToUpdate.addAll(leadsAfterLeadDuplication.leadsList1); 
        if(leadsAfterLeadDuplication.leadsList2.size()>0){
            for(Lead tempLead:leadsAfterLeadDuplication.leadsList2){
                //If the Leads comes from "Siti Agenti", or the "Provinenza campagne agenti" is indicated, 
                //it is not required the duplicate process on clients
                if(tempLead.Landing_Page__c == 'Siti Agenti' || 
                        (tempLead.Provenienza_Campagne_Agenti__c != null && 
                            tempLead.Provenienza_Campagne_Agenti__c != '')){
                                tempLead.TECH_Send_Email_Notification__c = true;
                    if(tempLead.Agency_Code__c != null){
                        tempLead.Ultima_data_di_riassegnazione__c = Datetime.now();
                        if(tempLead.Numero_assegnazioni_eseguite__c == null)
                            tempLead.Numero_assegnazioni_eseguite__c = 0;
                        tempLead.Numero_assegnazioni_eseguite__c += 1;
                        leadIdsToReassign.add(tempLead.Id);
                    }else{
                        tempLead.Azioni_intraprese_sul_Lead__c ='Il Lead Siti agenti non ha l\'agenzia a cui deve essere assegnato';
                    }
                    leadSitiAgentiList.add(tempLead); 
                    leadsForDuplicateClients.remove(tempLead.Id);
                }
            }
            leadsToUpdate.addAll(leadSitiAgentiList); 
            Id leadWithoutPhoneQueue = UtilityClass.retrieveGroupId('Queue','Coda_Web_Lead_senza_telefono');
            if(leadsForDuplicateClients.values().size()>0){
                LeadAssignment.LeadsListsWrapper leadsAfterClientDuplication = LeadAssignment.duplicationWithClients(leadsForDuplicateClients.values());
                system.debug('****JV - Leads duplicated with clients: ' + leadsAfterClientDuplication.leadsList2);
                system.debug('****JV - Leads not duplicated with clients: ' + leadsAfterClientDuplication.leadsList1);

                if(leadsAfterClientDuplication.leadsList1.size()>0){
                    for(Lead tempLead: leadsAfterClientDuplication.leadsList1){
                        //[05/07/2017]JV - Start-Integration Test: Lead without CAP will not be sent to Noovle
                        if(tempLead.PostalCode == null || tempLead.PostalCode == ''){
                            tempLead.Azioni_intraprese_sul_Lead__c = 'Il Lead non ha il CAP';
                            leadsToUpdate.add(tempLead);
                        }
                        //[05/07/2017]JV - End
                        //BOVOLENTA_D 11012018 Sprint 59 - Phone Check after deduplication
                        else if(tempLead.Phone == null || tempLead.Phone == ''){
                            tempLead.OwnerId = leadWithoutPhoneQueue;
                            tempLead.TECH_Send_Email_Notification__c = false;
                            leadsToUpdate.add(tempLead);
                        }
                        //BOVOLENTA_D END 11012018 Sprint 59 - Phone Check after deduplication
                        else{
                            LeadRankingQueueable agenciesRankingforLead = new LeadRankingQueueable(tempLead);   
                            if(!Test.isRunningTest())
                                Id agenciesRankingforLeadJobId = System.enqueueJob(agenciesRankingforLead);
                        }  
                    } 
                }
                if(leadsAfterClientDuplication.leadsList2.size()>0){
                    leadsToUpdate.addAll(leadsAfterClientDuplication.leadsList2); 
                    leadsToReassign.addAll(leadsAfterClientDuplication.leadsList2);                         
                }
            }       
        }  
        if(leadsToUpdate.size()>0){
            Database.SaveResult[] srList = Database.update(leadsToUpdate, false);
        }
        for(Lead tempLead:leadsToReassign){
            leadIdsToReassign.add(tempLead.Id);   
        }
        if(leadIdsToReassign.size()>0){
            LeadManagement.reassingLeadAAI(leadIdsToReassign);     
        }
            
    }
}
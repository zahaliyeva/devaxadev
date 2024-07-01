public class MobilityDeleteOpportunityController {

    
    @AuraEnabled
    public static Opportunity getOpportunityInfo(Id oppId){
        Opportunity OpportunityInfo =[SELECT Id, Numero_proposte__c
                 FROM Opportunity
                 WHERE id =: oppId
                 LIMIT 1];
        return OpportunityInfo;
    } 
    
    
    @AuraEnabled
    public static void getDeleteOpportunity(Opportunity opp){      
       Delete  opp;
    } 
    
}
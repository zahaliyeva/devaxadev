public with sharing class SchedaClienteCampagneController {
    
    @AuraEnabled 
    public static List<CampaignMember> getCampaignMembers(String accountId) {
        return [SELECT CampaignId, Campaign.Name, Campaign.Type, Campaign.StartDate, Campaign.EndDate, Campaign.Status from CampaignMember where Contact.Account.Id =:accountId order by CreatedDate desc LIMIT 5 ];
    }   

}
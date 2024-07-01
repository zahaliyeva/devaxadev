public with sharing class SchedaClienteCampagneLazyController {

    public class CampaignWrapper {
        @AuraEnabled
        public String campaignId;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public Date startDate;
        @AuraEnabled
        public Date endDate;
        @AuraEnabled
        public String status;
    }
   
    @AuraEnabled(cacheable=true)
    public static List<CampaignWrapper> getRecords(String id, Integer limits) {
        List<CampaignMember> campaignMembers = [SELECT CampaignId, Campaign.Name, Campaign.Type, Campaign.StartDate, Campaign.EndDate, Campaign.Status FROM CampaignMember WHERE Contact.Account.Id =:id order by CreatedDate desc LIMIT :Integer.valueof(limits) ];
        List<CampaignWrapper> campaignsWrapper = new List<CampaignWrapper>();
        for(CampaignMember campaignMember: campaignMembers){
            CampaignWrapper wrapper = new CampaignWrapper();
            wrapper.campaignId = '/' + campaignMember.CampaignId; 
            wrapper.name = campaignMember.Campaign.Name;
            wrapper.type = campaignMember.Campaign.Type;
            wrapper.startDate = campaignMember.Campaign.StartDate;
            wrapper.endDate = campaignMember.Campaign.EndDate;
            wrapper.status = campaignMember.Campaign.Status;
            campaignsWrapper.add(wrapper);
        }
        return campaignsWrapper;
    }  

    @AuraEnabled(cacheable=true)
    public static Integer getCount(String id){
        AggregateResult results = [SELECT Count(Id) Counter FROM CampaignMember WHERE Contact.Account.Id =:id];
        return ((Integer) results.get('Counter'));
    } 

}
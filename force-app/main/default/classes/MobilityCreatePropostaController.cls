public class MobilityCreatePropostaController {
    
    @AuraEnabled
    public static User getUserInfo(){
        User userInfo =[SELECT Agency_Code__c,CommunityNickname,Profile.Name 
                 FROM User
                 WHERE id =: UserInfo.getUserId() 
                 LIMIT 1];
        return userInfo;
    } 
    
    @AuraEnabled
    public static Opportunity getOpportunityInfo(Id oppId){
        Opportunity OpportunityInfo =[SELECT Id, Name , Numero_proposte__c, Account.NDG__c 
                 FROM Opportunity
                 WHERE id =: oppId
                 LIMIT 1];
        return OpportunityInfo;
    }    
    
    @AuraEnabled
    public static String getCreaPropostaDaolUrl(){
        return MobilityOpportunityDispatcher.getCreaPropostaDaolUrl(); 
    } 

}
public class OCNotificationCTRL {

    public class outputWrapper{
        @AuraEnabled
        public boolean automaticPickUp {get;set;}
    }
    
    @AuraEnabled
    public static outputWrapper getPageValues()
    {
       outputWrapper res = new outputWrapper();

       Map<String,String> PageValMap = new Map<String,String>();
       
       Map<String,Boolean> AACProfiles = new Map<String,Boolean>();

       List<SCV_Auto_Accept_Call__mdt> AACList = [SELECT Id, DeveloperName, Profile_Dev_Name__c, Active__c
                           FROM SCV_Auto_Accept_Call__mdt
                           ];
           
       String UserID = UserInfo.getUserId();

       String UserProfile='';

       User CurrentUser = [Select Name,Agency_Code__c,UserRole.name,Profile.Name from User where id=:UserID];

        UserProfile =  (String.isNotBlank(CurrentUser.Profile.Name))?CurrentUser.Profile.Name:'';  

        PageValMap.put('UserProfile',UserProfile);
      
       system.debug('getPageValues'+PageValMap);

        for(SCV_Auto_Accept_Call__mdt aacProf : AACList)
        {
      		
            AACProfiles.put(aacProf.Profile_Dev_Name__c, aacProf.Active__c);
      	}
        
        if(AACProfiles.containsKey(UserProfile)){
            res.automaticPickUp = AACProfiles.get(UserProfile);
        }
        else{
            res.automaticPickUp = false;
        }

        

       return res;
    }

}
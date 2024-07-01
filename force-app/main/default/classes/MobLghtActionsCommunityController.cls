public  class MobLghtActionsCommunityController {
   
    @AuraEnabled
    public static Case getInfoCase(Id recordId){
        return LghtCaseManageController.getCase(recordId);
    }
}
public with sharing class NFE_CrmChiudiCaseController {


    @AuraEnabled
    public static Case getCase(String id) {
        return LghtCaseManageController.getCase(id);
    }
}
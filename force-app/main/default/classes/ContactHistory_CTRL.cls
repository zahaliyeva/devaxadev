public with sharing class ContactHistory_CTRL {
    public boolean jsDebug { get; set; }
    public string apexPageId { get; set; }
    public integer apexNumberOfRows { get; set; }

    public ContactHistory_CTRL(ApexPages.StandardController controller) {
        Id user_debug_id;
        try {
            user_debug_id = (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG') != null ? (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG').Value__c : null;
        } catch (Exception e) {
            System.debug(e.getMessage());
            user_debug_id = null;
        }
        if (user_debug_id != null && (user_debug_id == UserInfo.getUserId())) {
            jsDebug = true;
        } else {
            jsDebug = false;
        }

        apexPageId = ApexPages.currentPage().getParameters().get('id');
        if (ApexPages.currentPage().getParameters().get('numberOfRows') != null) {
            apexNumberOfRows = Integer.valueOf(ApexPages.currentPage().getParameters().get('numberOfRows'));
        } else {
            apexNumberOfRows = 5;
        }
    }

}
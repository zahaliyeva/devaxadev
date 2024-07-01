({
	init : function(cmp, evt, helper) {
        const isFound = helper.redirectNotFound();
        if(isFound) return;
        
        if (window.location.href.indexOf('/crm/s/account/') !== -1) {
            helper.redirect(cmp, "c.getAccountPath", $A.get("$Label.c.NFE_AccountPath_Fallback"), '/crm/s/account/');
        } else if (window.location.href.indexOf('/crm/s/contact/') !== -1) {
            helper.redirect(cmp, "c.getContactPath", $A.get("$Label.c.NFE_ContactPath_Fallback"), '/crm/s/contact/');
        } else if (window.location.href.indexOf('/crm/s/lead/') !== -1) {
            helper.redirect(cmp, "c.getLeadPath", $A.get("$Label.c.NFE_LeadPath_Fallback"), '/crm/s/lead/');
        } else if (window.location.href.indexOf('/crm/s/campaign/') !== -1) {
            helper.redirect(cmp, "c.getCampaignPath", $A.get("$Label.c.NFE_CampaignPath_Fallback"), '/crm/s/campaign/');
        }
    }
})
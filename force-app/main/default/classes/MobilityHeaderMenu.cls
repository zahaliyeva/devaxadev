public class MobilityHeaderMenu extends RLY_Behaviour {

    @AuraEnabled(Cacheable=true)
    public static Boolean getVisibility(String menuItemLabel) {
        //MobilityDisabledMenuButton__c cs = MobilityDisabledMenuButton__c.getInstance(UserInfo.getProfileId());

        //switch on (menuItemLabel) {
        //    when 'menu_Home_Button' {
        //        return cs != null && !cs.Home_Button__c == true;
        //    }
        //    when 'menu_Dac_Button' {
        //        return cs != null && !cs.Dac_Button__c == true;
        //    }
        //    when 'menu_Opportunity_Button' {
        //        return cs != null && !cs.Opportunity_Button__c == true;
        //    }
        //    when 'menu_Report_Button' {
        //        return cs != null && !cs.Report_Button__c == true;
        //    }
        //    when 'menu_Dashboard_Button' {
        //        return cs != null && !cs.Dashboard_Button__c == true;
        //    }
        //    when 'menu_Monitoraggio_Button' {
        //        return cs != null && !cs.Monitoraggio_Button__c == true;
        //    }
        //    when 'menu_Knowledge_Button' {
        //        return cs != null && !cs.Knowledge_Button__c == true;
        //    }
        //    when 'menu_Black_List_Button' {
        //        return cs != null && !cs.Black_List_Button__c == true;
        //    }
        //}

        return true;

    }

}
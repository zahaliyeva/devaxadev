public without sharing class TriggerCaseAssignmentRules {
    @InvocableMethod(Label = 'Trigger Case Assignment Rules')
    public static void run (List<Id> CaseIds){
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        Case c = [Select id from case where id in: CaseIds];
        c.setOptions(dmo);
        update c;
    }

}
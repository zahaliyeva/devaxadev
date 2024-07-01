public class MobilityNewOpportunityController {
    
    @AuraEnabled
    public static List<String>  getASAList() {
        // Populates the ASA picklist
        
        list<String> options = new list<String>();   
              
        Schema.DescribeFieldResult fieldResult = Opportunity.ASA_Description__c.getDescribe();
        list<Schema.PicklistEntry> values = fieldResult.getPickListValues();               
        for (Schema.PicklistEntry a : values)
            options.add(a.getLabel());
        
        return options;
    }
    
    
    @AuraEnabled
    public static Id   createOpportunity(Id accId, String description) {
        Id newOppId;
        
        Opportunity opp = new Opportunity();
        opp.Name ='myNewOpportunity';
        opp.StageName='Open';
        opp.AccountId = accId;
        opp.ASA_Description__c = description;
        opp.CloseDate=  (date.today()).addDays(30);
        
        Database.SaveResult[] srList = Database.insert(new Opportunity[]{opp}, false);
        
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted Opportunity. Opportunity ID: ' + sr.getId());
                newOppId=sr.getId();
                
            }            
        }              
       return newOppId;
        
    }    
    
    
}
global with sharing class OpportunityInsertCtrl {
    
    public Opportunity OppToInsert {get;set;}
    public boolean showMessage {get;set;}
    public string pageMessage {get;set;}

    
    public OpportunityInsertCtrl(ApexPages.StandardController mycontroller) {
        // Constructor
        OppToInsert = new Opportunity();
        
        OppToInsert.CloseDate = (date.today()).addDays(30);
        OppToInsert.StageName = 'Open';
        OppToInsert.Name = 'myNewOpportunity';
        
        AccountId = ApexPages.currentPage().getParameters().get('accid');
        ContactId = ApexPages.currentPage().getParameters().get('ContactId');
        CampaignId = ApexPages.currentPage().getParameters().get('CampaignId');
    }
    
    
    
    //***************** New Opportunity Creation from Opportunity Page *****************\\
    
    public static String getAccountObjectKey(){
        // Method will return object key for Described object
        
        Schema.DescribeSObjectResult schemaResult = Account.sObjectType.getDescribe();
        return JSON.serialize(schemaResult.getKeyPrefix());
    }
    
    
    @RemoteAction   // AngularJS Remoting
    public static List<Account> searchAccount(String accountName){
        // Method will return List of Account
        
        String query = 'SELECT Id, Name FROM Account WHERE Name LIKE \'%'+accountName+'%\' AND RecordType.DeveloperName IN (\'B2B_Client\',\'B2C_Client\') LIMIT 20';
        return Database.query(query);
        
    }
    
        
    public List<SelectOption> getASAList() {
        // Populates the ASA picklist
        
        list<selectoption> options = new list<selectoption>();   
        options.add(new SelectOption('0', '--Nessuno--'));
        
        Schema.DescribeFieldResult fieldResult = Opportunity.ASA_Description__c.getDescribe();
        list<Schema.PicklistEntry> values = fieldResult.getPickListValues();               
        for (Schema.PicklistEntry a : values)
            options.add(new SelectOption(a.getLabel(), a.getValue()));
        
        return options;
    }
    
    
    public pageReference saveAccountId() {
        // Action when save button is pressed
        
        string myID = Apexpages.currentPage().getParameters().get('myAccountId');
        OppToInsert.AccountId = myID;
        return null;
    }

    
    public void deleteAccountId() {
        // Delete stored AccountId from memory when the input is deleted
        OppToInsert.AccountId = null;
    }
    
    
    public pageReference SaveOpportunity() {
        // Action when save button is pressed
        
        showMessage = false;
        
        // Validations
        Boolean noAccount = true;
        Boolean noASA = true;
        
        String errMsg1 = 'Compilare tutti i campi obbligatori:';
        Boolean first = true;
        
        if (OppToInsert.AccountId != null)
            noAccount = false;
        else {
            errMsg1 += ' Nome Cliente';
            first = false;
        }
        
        if (OppToInsert.ASA_Description__c != '0' && OppToInsert.ASA_Description__c != null)
            noASA = false;
        else {
            if(!first)
                errMsg1 += ' -';
            errMsg1 += ' ASA';
            first = false;
        }
        
        
        if(noAccount || noASA) {
            pageMessage = errMsg1;
            showMessage = true;
            return null;
        }
        
        else {
            try {
                insert OppToInsert;
                PageReference acctPage = new PageReference('/' + OppToInsert.ID);
                return acctPage;
            }
            
            catch (Exception e) {
                pageMessage = e.getMessage();
                showMessage = true;
                return null;
            }
        }
    }
    
    
    
    //***************** New Opportunity Creation from Account or Campaign Member Page *****************\\
    
    public Id AccountId {get;set;}
    public Id ContactId {get;set;}
    public Id CampaignId {get;set;}

    
    public pageReference NewOpportunityfromAccount() {
        // Action when new Opportunity is created from an account
        
        if(!(String.isBlank(AccountId))) {
            OppToInsert.AccountId = AccountId;
            
            try {
                insert OppToInsert;
                PageReference acctPage = new PageReference('/' + OppToInsert.ID);
                return acctPage;
            }
            
            catch (Exception e) {
                pageMessage = e.getMessage();
                showMessage = true;
                return null;
            }
        }
        
        if(!(String.isBlank(CampaignId))) {
            Contact mycontact = [SELECT Id, AccountId FROM Contact WHERE Id=:ContactId  LIMIT 1];
            Campaign myCampaign=  [SELECT ASA__c FROM Campaign WHERE Id=:CampaignId LIMIT 1].get(0);
            string ASA = myCampaign.ASA__c;
            Id myAccountId = mycontact.AccountId;
            OppToInsert.AccountId = myAccountId;
            OppToInsert.CampaignId = CampaignId;
            if(!(String.isBlank(ASA))){
                OppToInsert.Codice_ASA__c = ASA;
            }
            
            try {
                insert OppToInsert;
                PageReference acctPage = new PageReference('/' + OppToInsert.ID);
                return acctPage;
            }
            
            catch (Exception e) {
                pageMessage = e.getMessage();
                showMessage = true;
                return null;
            }
        }
        
        else
            return null;
    }   
    

    

}
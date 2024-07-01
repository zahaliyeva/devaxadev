public class LeadConversionQueueable implements Queueable, Database.AllowsCallouts {
    
    public Lead inputLead;
    public String convertedLeadStatus;
    public Account targetAccount;
    public Id targetAccountId;

    public LeadConversionQueueable(Lead newLead, String inputConvertedLeadStatus, Account inputTargetAccount, id inputTargetAccountId){
        inputLead = newLead;
        convertedLeadStatus = inputConvertedLeadStatus;
        targetAccount = inputTargetAccount;
        targetAccountId = inputTargetAccountId;
    }


    public void execute(QueueableContext context) {
        
        system.debug('#@#@ nel Queueable');
        Database.LeadConvert lc = new Database.LeadConvert();
        //inputLead.salutation = targetAccount.salutation;
        inputLead.TECH_Lead_Processed__c=true;
        
            
        update inputLead;

        //Set Lead ID
        lc.setLeadId(inputLead.id);  

        //Set Converted Lead Status
        lc.setConvertedStatus(convertedLeadStatus);
            
        //Set Account on which the lead shall be converted
        lc.setAccountId(targetAccountId); 
                    
        list<Contact> targetContact = [SELECT id FROM Contact WHERE AccountId = :targetAccountId AND (FirstName = :inputLead.FirstName AND LastName = :inputLead.LastName) AND (Email =:inputLead.Email OR Phone =:inputLead.Phone) LIMIT 1] ;
        if (targetContact.isEmpty() == false)
        {
            lc.setContactId(targetContact[0].id); 
        }

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        //QuotationManagement.createQuotationFromConversion(inputLead.Id, targetAccountId); //CAPOBIANCO_A 07/12/2017 - Sprint 57
    }


}
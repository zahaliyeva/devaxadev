/**
 * @description PURE IT 22/05 - commentata la classe
 */
public class SummarizeActiveCampaignOnAccount {}
     /** PURE IT
global class SummarizeActiveCampaignOnAccount implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    global Set<Id> CampaignProcessed = new Set<Id>();
    public string query = 'SELECT id, CampaignId, contactId, Contact.AccountId FROM CampaignMember where Campaign.TECH_Batch_required__c=true ORDER BY Contact.AccountId';
    public static INTEGER MAX_SCOPE = 200;

///////////TO MAKE IT BATCHABLE//////////////
    global Database.QueryLocator start(Database.BatchableContext BC){//Here I find first the Campaigns then ALL the CMs
        // AllCampaigns = new Map<ID, Campaign>([Select Id From Campaigns where TECH_Batch_required__c = true]);
        // Set<Id> AllCampaignId = AllCampaigns.keyset();
        system.debug('++++running query'+query);
        return Database.getQueryLocator(query);
   }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        CountActiveCampaignsOnAccount(scope);
    }
   

    global void finish(Database.BatchableContext BC){
        //when finishing I update the campaigns removing the flag
        try {
        List<Campaign> CampaignToUpdate = new List<Campaign>();
            for (ID thisCampaignID: CampaignProcessed) {
                Campaign tempCampaign = new Campaign(id=thisCampaignID, TECH_Batch_required__c=false);
                CampaignToUpdate.add(tempCampaign);
            }
            update CampaignToUpdate;
        } catch (Exception Ex) {
            system.debug(Ex);
        }
   }
///////////TO MAKE IT BATCHABLE //////////////

///////////TO MAKE IT SCHEDULABLE //////////////
    global void Execute(SchedulableContext SC) {  
        SummarizeActiveCampaignOnAccount b = new SummarizeActiveCampaignOnAccount();
        Database.ExecuteBatch(b,MAX_SCOPE);      
    } 
///////////TO MAKE IT SCHEDULABLE //////////////

///////// Methods available //////////////////
//given a list of CM counts the active campaigns on the corrisponding accounts
    public void CountActiveCampaignsOnAccount(List<Sobject> scope) {
        system.debug('++++scope'+scope);
        List<CampaignMember> scopeCM = (List<CampaignMember>) scope;
        system.debug('++++scopeCM'+scopeCM);
        Set<Id> AllAccountId = new Set<Id>();
   
        //retrieving all accounts from CM of this scope
        for (CampaignMember thisCM : scopeCM) {
            system.debug('++++thisCM'+thisCM);
            CampaignProcessed.add(thisCM.CampaignId);
            if (thisCM.contact.AccountId!=null) {
                AllAccountId.add(thisCM.contact.AccountId);
            } else {
                system.debug('+++campaign member without Account');
            }
        }
        
        // finding all active campaigns where the Accounts are present
        system.debug('+++calculating active campaignfor ' +AllAccountId.size() + 'Accounts' );
        List<CampaignMember> activeCM = [Select id, CampaignId, contactId, Contact.AccountId  from CampaignMember where Campaign.Status='On-going' and Contact.AccountId IN: AllAccountId];
        system.debug('+++++Found '+activeCM+' for the Accounts in this Scope');
        
        //Counting Active Campaings per each account
        Map<Id, Integer> AccountSummary = new Map<id, integer>();
   
        for (CampaignMember thisCM : activeCM) {
            if (AccountSummary.containskey(thisCM.contact.AccountId)) {
                integer currentCount = AccountSummary.get(thisCM.contact.AccountId);
                system.debug('++++currentCount'+currentCount);
                AccountSummary.put(thisCM.contact.AccountId,currentCount+1);
                system.debug('++++Updated'+currentCount);
            } else {
                if (thisCM.contact.AccountId!=null) {
                    AccountSummary.put(thisCM.contact.AccountId,1);
                }
            }
        }
        
        //Preparing the list of accounts to update
        List<Account> AccToUpdate = new List<Account>();
        for (id thisID: AccountSummary.Keyset()) {
            Account tempAcc = new Account(id = thisID, Active_Campaigns__c= AccountSummary.get(thisID));
            AccToUpdate.add(tempAcc);
            system.debug('++++tempAcc'+tempAcc);
        }
        system.debug('+++updating'+ AccToUpdate.size()+ 'Accounts++++');
        update AccToUpdate;
        }


}   PURE IT */
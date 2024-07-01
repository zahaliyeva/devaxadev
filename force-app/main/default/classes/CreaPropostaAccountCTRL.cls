public class CreaPropostaAccountCTRL {
    /* 
------------------------------------------------------------
-- - Name          : CreaPropostaAccountCTRL 
-- - Author        : Andrea Capobianco 
-- - Description   : Apex controller for visualforce page CreaPropostaAccount

--
-- Maintenance History: 
--
-- Date         Name               Version  Remarks 
-- -----------  -----------------  -------  -----------------------------
-- 15-NOV-17    Andrea Capobianco  1.0      Initial version
------------------------------------------------------------
*/
    
    public list<Opportunity> listOpp {get;set;}
    public Account account {get;set;}
    public User currentUser {get;set;}
    public Id currentUserId {get;set;}
    public String currentUserNickname {get;set;}
    public String currentUserAgencyCode {get;set;}
    public String currentUserProfile {get;set;}
    public Id accountId {get;set;}
    public Id opportunityRTId {get;set;}
    public Id oppId {get;set;}
    public String oppName {get;set;}
    public String accountNDG {get;set;}
    public String pageMessage {get;set;}
    public Boolean showError {get;set;}
    public String errorMessage {get;set;}
    public String urlForDaol {get;set;}
    
    //Constructor
    public CreaPropostaAccountCTRL(ApexPages.StandardController controller) {

        cmID = ApexPages.currentPage().getParameters().get('cmID');
        
        account = (Account)controller.getrecord();
        accountId = account.Id;
        accountNDG = [SELECT NDG__c FROM Account WHERE Account.Id =: accountId LIMIT 1].NDG__c;

        urlForDaol = [SELECT Value__c FROM AAI_Code_Variables__c WHERE Name = 'DAOL_URL_Prefix_CreaPropostaAccount'].Value__c;

        Id currentUserId = UserInfo.getuserid();
        User currentUser = [SELECT CommunityNickname,Agency_Code__c,Profile.Name FROM User WHERE Id =: currentUserId LIMIT 1];
        currentUserAgencyCode = currentUser.Agency_Code__c;
        currentUserNickname = currentUser.CommunityNickname;
        currentUserProfile = currentUser.Profile.Name;
        showError=false;
        errorMessage='';

        pageMessage = 'Vuoi associare la proposta ad una delle seguenti Trattative in corso?';

        getOpportunita();

    }
    
    public Id cmID {get;set;}
    public Id currentOpp {get;set;}
    
    public void addOpptoCM() {
        system.debug('I AM IN CONTROLLER: ' + currentOpp);
        CampaignMember myCM = [SELECT Id, Name, Status, Campaign_member_related_opportunity__c FROM CampaignMember WHERE Id =: cmID LIMIT 1];
        myCM.Campaign_member_related_opportunity__c = currentOpp;
        update myCM;
    }

    //Method used to retrieve the existing open and proposta-free Opportunities when pressing the "Crea Proposta" button
    public void getOpportunita(){

        listOpp = [SELECT Id, Name, ASA_Description__c, StageName, Prodotto__c, CreatedDate, ExpectedRevenue, Amount 
                   FROM Opportunity 
                   WHERE Account.Id =: accountId
                   AND StageName='Open'
                   AND Numero_proposte__c = 0];
    }

    //Method used to create a new Opportunity when the User chooses to from the Pop-Up
    public void createOpportunita(){

      try
      {
        opportunityRTId = [SELECT Id From RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Opportunita_AXA_Assicurazioni'].Id;
        Opportunity newOpportunity = new Opportunity( RecordTypeId = opportunityRTId,
                                                      Name = 'My new opportunity',
                                                      AccountId = accountId,
                                                      StageName = 'Open',
                                                      CloseDate = System.Today().addDays(30));

        Database.SaveResult SaveResult = Database.insert(newOpportunity,false);
        
        if(SaveResult.isSuccess())
        { 
          setOpportunityIdAndName();
        }
        else
        {
          String stringErrors = 'Si sono verificati i seguenti errori durante la creazione della Trattativa: ';
          for(Database.Error err : SaveResult.getErrors())
          {
            stringErrors = stringErrors+'<br/>';
            stringErrors = stringErrors+err.getMessage();   
          }
          showError=true;
          errorMessage = stringErrors;                            
        }
      }
      catch(Exception e)
      {
        String stringErrors = 'Si sono verificati i seguenti errori durante la creazione della Trattativa: '+e.getMessage();
        showError=true;
        errorMessage = stringErrors; 
      }

    }

    //method used to set the parameters to correctly perform the jump to DAOL
    public void setOpportunityIdAndName(){
      try
      {
        Opportunity oppCreated = [SELECT Id,Name FROM Opportunity WHERE AccountId =: AccountId ORDER BY CreatedDate DESC LIMIT 1];
        oppId = oppCreated.Id;
        oppName = oppCreated.Name;
      }
      catch(Exception e)
      {
        String stringErrors = 'Si sono verificati i seguenti errori: '+e.getMessage();
        showError=true;
        errorMessage = stringErrors; 
      }
    }

}
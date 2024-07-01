/**
 * @description PURE IT 22/05 - commentata la classe
 */
@isTest
public class ReassignAccountToAxaTechnicalUser_Test{
    /** PURE IT
    static testmethod void TestReassignAccount(){
        
        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id contact_agency = UtilityClass.getRTid(rtypes, 'Contact', 'Agency_Contact');
        id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');
        id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');
        Profile pvendite = [SELECT Id FROM Profile WHERE Name = 'NFE - AAI - Vendite Avanzato'];  
        
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv;
         
        //Create Partner User
        Account agencyAccount = new Account(Name = 'Agency Test Account',
                                            RecordTypeId = account_agency,
                                            Agency_Code__c = '006345');
        insert agencyAccount;
                       
        Contact agencyContact = new Contact(LastName = 'Agency Test Contact',
                                            RecordtypeId = contact_agency,
                                            AccountId = agencyAccount.Id);
        insert agencyContact;
               
        User usr1=new User(FirstName='Martijn',
                           LastName = 'Reekmans', 
                           Alias = 'mreekm11', 
                           Email = 'mreekmans@deloitte.com', 
                           Username = 'mreekm11@axa.com.masterdev', 
                           CommunityNickname = 'MartiRe', 
                           LanguageLocaleKey = 'en_US',
                           TimeZoneSidKey='Europe/Paris',
                           Agency_Code__c = '006345',
                           Nodes__c = 'DIF_006345',
                           Profileid = pvendite.Id,
                           LocaleSidKey='en_US',
                           EmailEncodingKey='ISO-8859-1',
                           ContactId = agencyContact.Id);
        insert usr1;
         
        String usr1id = usr1.id; 
        
         //Create B2C Account
         //System.runAs(usr1){
            Account b2cClient1 = new Account(FirstName = 'Test',
                                        LastName = 'B2C Account',
                                        RecordTypeId = account_B2C,
                                        TECH_Company__c = 'AAI',
                                        OwnerId = usr1id);         
            insert b2cClient1;
         //}
         

        
        //Test
        //Test.StartTest();
        ReassignAccountToAxaTechnicalUser reassign = new ReassignAccountToAxaTechnicalUser();
        ID batchprocessid = Database.executeBatch(reassign);
        ReassignAccountToAxaTechnicalUser TheB = new ReassignAccountToAxaTechnicalUser();
        String sch = '0 45 11 29 7 ? 2080'; // --> 29/07/2080 11:45
        System.Schedule('ReassignAccountToAxaTechnicalUser', sch, TheB);
        //Test.StopTest();
    }
    PURE IT */
}
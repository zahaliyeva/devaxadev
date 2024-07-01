/*------------------------------------------------------------------------
Author:        Francesca Marchese
Company:       Deloitte
Class:         ICFManagementTest
Description:   Test class for ICFManagement test class

History

6/12/2016     Created - F.M.
----------------------------------------------------------------------------*/
/**
 * @description PURE IT 22/05 - commentata la classe
 */

@istest
public without sharing class ICFManagementTest{
        /** PURE IT
@testSetup static void setup() { //preparing test database
UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
system.debug('portalRole is ' + portalRole);

Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
User portalAccountOwner1 = new User(
UserRoleId = portalRole.Id,
ProfileId = profile1.Id,
Username = System.now().millisecond()+Integer.valueof((Math.random() * 100)) + 'test4@test.com',
Alias = 'batman',
Email='bruce.wayne@wayneenterprises.com',
EmailEncodingKey='UTF-8',
Firstname='Bruce',
Lastname='Wayne',
LanguageLocaleKey='en_US',
LocaleSidKey='en_US',
TimeZoneSidKey='America/Chicago'
);
Database.insert(portalAccountOwner1);

//User u1 = [Select ID From User Where Id =: portalAccountOwner1.Id];

System.runAs ( portalAccountOwner1 ) {
//Create account
Account portalAccount1 = new Account(
Name = 'TestAccount',
OwnerId = portalAccountOwner1.Id
);
Database.insert(portalAccount1);

//Create contact
Contact contact1 = new Contact(
FirstName = 'Test',
Lastname = 'McTesty',
AccountId = portalAccount1.Id,
Email = System.now().millisecond() + 'test@test.com'
);
Database.insert(contact1);

//Create user
Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'NFE - AAI - Vendite Avanzato' limit 200];
Profile baseProfile = [SELECT Id FROM Profile WHERE  Name='NFE - AAI - Vendite Base' limit 200];
User usr000828 = new User(
                           FirstName='Agente000828',
                           LastName = 'TESTUSER000', 
                           Alias = 'mree000', 
                           Email = 'mreekmans000@deloitte.com', 
                           Username = 'mreekm000@axa.com.masterdev',
                           ContactId = contact1.Id, 
                           CommunityNickname = 'MartiRe000', 
                           LanguageLocaleKey = 'en_US',
                           TimeZoneSidKey='Europe/Rome',
                           Agency_Code__c = '000828',
                           Nodes__c = 'DIF_000828',
                           Profileid = portalProfile.Id,
                           LocaleSidKey='en_US',
                           EmailEncodingKey='ISO-8859-1'
                          
                           ); 

Database.insert(usr000828);



Account ac = new Account (
        FirstName = 'test',
        LastName = 'LeadTest',
        CIF_PersonEmail__c = '',
        Phone = '0333333333',
        CIF_PersonMobilePhone__c = '',
        NDG__c = '0008280000001175',
        Nodes__c = '000828;000828000302',
        TECH_Company__c='AAI',
        AAI_Agency_Reference_Code__c='000828'
        
     );
      Database.insert(ac);  
      
Interazione__c interazione = new Interazione__c();
interazione.Stato__c='Survey non inviata';
interazione.Account__c=ac.Id;
interazione.Tipologia__c='Altro';
Database.insert(interazione);


EmailTemplate validEmailTemplate = new EmailTemplate();
validEmailTemplate.isActive = true;
validEmailTemplate.Name = 'name';
validEmailTemplate.DeveloperName = 'test';
validEmailTemplate.TemplateType = 'text';
validEmailTemplate.FolderId = UserInfo.getUserId();
validEmailTemplate.Subject = 'Your Subject Here';

IE_Configuration__c Integration_record = new IE_Configuration__c();
        Integration_record.Name = 'ICF_Integration_Survey';
        Integration_record.Type__c = 'WebService';
        Integration_record.Direction__c = 'OUTBOUND';
        Integration_record.EndPoint__c = 'https://axa-api.sandsiv.com'; 
        Integration_record.Request_compiler__c = 'IE_ICF_Parser';
        Integration_record.Response_parser__c = 'IE_ICF_Compiler';
        insert Integration_record;


insert validEmailTemplate;
}

}
static testmethod void TEST_SendEmail(){
AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
insert acv;
User Admin= [Select Id from User where FirstName='Bruce' Limit 1 ];
System.runAs (Admin ) {
User theAgent = [Select Id, Name, Email from User where FirstName='Agente000828' Limit 1 ];



List<User> UserReceivingEmail = new List <User>();
UserReceivingEmail =[SELECT Id, Agency_Code__c, Nodes__c FROM User WHERE Profile.Name = 'NFE - AAI - Vendite Avanzato' limit 200];

 }
 
       
    }



PURE IT */


}
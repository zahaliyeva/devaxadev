/*------------------------------------------------------------------------
Author:        Veronica Chianura
Company:       Deloitte
Class:         CIF_WebServiceManagement_IETest
Description:   Test
               VF Page: 
History

 03/02/2016 
 ---------------------------------------------------------------------------*/

@isTest
public with sharing class CIF_WebServiceManagement_IETest{
    
   //   static testMethod void Test1(){/* -------------------> Test1, test costruttore */
    
        //MappingProvince__c m = new MappingProvince__c(ProvinciaExternalKey__c='MI', SFDCexpected__c='Milano');
        //insert m;
        //CIF_WebServiceManagement_IE c = new CIF_WebServiceManagement_IE ();
    //}
    
    static testMethod void Test2(){/* -------------------> Test2,  */
    
     Lead ld = new Lead (
        FirstName = 'LeadTest',
        LastName = 'test',
        Email = 'lead@mail.test',
        Phone = '0333333333',
        MobilePhone = '3333333333',
        Fiscal_ID__c = '123456789012345P',
        Agency_Code__c = '0015',
        Provincia_di_nascita__c = 'MI',
        Birth_Place__c = 'Milano',
        Gender__c = 'Maschio',
        Street = 'Cadorna',
        City = 'Milano',
        StateCode = 'MI',
        Lead_Birthdate__c = date.parse('03/02/1956')        
     );
     insert ld;
     
     Lead ld1 = new Lead (
        FirstName = 'test',
        LastName = 'LeadTest',
        Email = 'lead@mail.test',
        Phone = '0333333333',
        MobilePhone = '3333333333',
        Fiscal_ID__c = '123456789012345P',
        Agency_Code__c = '0015',
        Provincia_di_nascita__c = 'MI',
        Birth_Place__c = 'Milano',
        Gender__c = 'Maschio',
        Street = 'Cadorna',
        City = 'Milano',
        StateCode = 'MI',
        Lead_Birthdate__c = date.parse('03/02/1956')        
     );
     
     insert ld1;
     
      Lead ld2 = new Lead(
        LastName = 'LeadTest7b',
        FirstName = 'test7b',
        Email = 'lead@mail.test7b',
        Phone = '0333333337',
        MobilePhone = '3333333337'
     );
     insert ld2;
     
     Account ac = new Account (
        FirstName = 'test',
        LastName = 'LeadTest',
        PersonEmail = 'account@mail.test',
        Phone = '0333333333',
        PersonMobilePhone = '3333333333',
        Nodes__c = '5014'
     );
     insert ac;
     
    
     Profile profilocorrente = [SELECT Id FROM Profile WHERE Name = 'AAI - Marketing Avanzato'];     
     Id pcor = profilocorrente.Id;   
     UserRole role = [SELECT Id FROM UserRole where name = 'AXA Assicurazioni'];
     Id pRol = role.Id;
     System.runAs(new User(Id=UserInfo.getUserId())){
                 
        User usr1=new User(FirstName='Martijn12435123',
                           LastName = 'TESTUSER', 
                           Alias = 'mree999', 
                           Email = 'mreekmans@deloitte.com', 
                           Username = 'mreekm11@axa.com.masterdev', 
                           CommunityNickname = 'MartiRe', 
                           LanguageLocaleKey = 'en_US',
                           TimeZoneSidKey='Europe/Rome',
                           Agency_Code__c = '5014',
                           Nodes__c = 'DIF_5014',
                           Profileid = pcor,
                           LocaleSidKey='en_US',
                           EmailEncodingKey='ISO-8859-1',
                           UserRoleId=pRol
                          );
        insert usr1;
     
     
     System.runAs(usr1) {
     
    }
    }
    
    
    
    }  

    
}
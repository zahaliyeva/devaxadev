@isTest
public class RelationshipHandlerTest{
    static testmethod void TestRelationshipHandler(){
    
     Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
         id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');
    
         List<AAI_Code_Variables__c> listacv = new List<AAI_Code_Variables__c>();
         
         AAI_Code_Variables__c acv1 = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());    
         listacv.add(acv1);
         
         AAI_Code_Variables__c acv2 = new AAI_Code_Variables__c(Name='ACCOUNT_NAME_FIELD_ID ');    
         listacv.add(acv2);
         
         AAI_Code_Variables__c acv3 = new AAI_Code_Variables__c(Name='ACCOUNT_ID_FIELD_ID ');    
         listacv.add(acv3);
         
         AAI_Code_Variables__c acv4 = new AAI_Code_Variables__c(Name='RELATIONSHIP_OBJECT_PREFIX ');    
         listacv.add(acv4);
         
         insert listacv;
         
         //List<RelationshipExtendedView.CCWRowItem> rows = new List<RelationshipExtendedView.CCWRowItem>();
         
         // Create Account and Relationship
         Account b2cClient1 = new Account(FirstName = 'Test',
                                          LastName = 'B2C Account',
                                          RecordTypeId = account_B2C,
                                          TECH_Company__c = 'AAI');
                                      
         insert b2cClient1;
    
         Relationship__c rel1 = new Relationship__c(Account1__c = b2cClient1.Id,
                                                    Name2__c = 'Test',
                                                    Role1__c = 'Collega');
         insert rel1;
         
         // Update Relationship
         rel1.Name2__c = 'Test2';
         update rel1;
         
         // Delete and undelete Relationship
         delete rel1;
         undelete rel1;
     }
 }
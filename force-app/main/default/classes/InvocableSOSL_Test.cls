@isTest
public class InvocableSOSL_Test {
    
    static Id AccountId;

    @TestSetup
    static void makeData(){

        Account AccToInsert = new Account(
            Name = 'test Account', 
            CIF_PersonMobilePhone__c = '+39333333333'
        );

        insert AccToInsert;
        AccountId = AccToInsert.Id;
        

    } 

    @isTest
    static void testSOSL(){
        //Call Class methods
        List<account> accList = [select id from account];
        List<Id> fixedSearchResults = new List<Id>();
        for(Account a: accList){
            fixedSearchResults.add(a.Id);
        }
        Test.setFixedSearchResults(fixedSearchResults);
        //fixedSearchResults[0] = AccountId;
        List<InvocableSOSL.Requests> reqList = new List<InvocableSOSL.Requests>();

        InvocableSOSL.Requests req = new InvocableSOSL.Requests();
        req.objects = 'ACCOUNT (Id, CIF_PersonMobilePhone__c)';
        req.inClause = 'ALL FIELDS';
        req.searchTerm = '333333333';

        reqList.add(req);
        
        

        List<InvocableSOSL.Response> resultList = InvocableSOSL.executeSOSL(reqList);

        /*
         *   Complete Assertions
         */

        //result generic assertions
        System.assert(resultList != null);
        System.assertEquals(resultList.size(), 1);
        InvocableSOSL.Response result = resultList.get(0);
        System.assert(result!= null); 
        

        //result specific assertions
        List<SObject> sObjectList = result.resultList;
        System.assert(sObjectList != null);
        System.assertEquals(sObjectList.size(), 1);

        //Searched Account Specific Assertions
        Account accToAssert = (Account) sObjectList.get(0);
        System.assert(accToAssert != null);
        //System.assertEquals(accToAssert.Id, AccountId);
        System.assertEquals(accToAssert.CIF_PersonMobilePhone__c, '+39333333333');

    }

    @isTest
    static void testException(){
        //Call Class methods
        
        //fixedSearchResults[0] = AccountId;
        List<InvocableSOSL.Requests> reqList = new List<InvocableSOSL.Requests>();

        InvocableSOSL.Requests req = new InvocableSOSL.Requests();
        req.objects = 'Test';
        req.inClause = 'ALL FIELDS';
        req.searchTerm = '333333333';

        reqList.add(req);
        
        

        List<InvocableSOSL.Response> resultList = InvocableSOSL.executeSOSL(reqList);

        /*
         *   Complete Assertions
         */

        //result generic assertions
        System.assert(resultList != null);
        System.assertEquals(resultList.size(), 0);
        
        

    }

}
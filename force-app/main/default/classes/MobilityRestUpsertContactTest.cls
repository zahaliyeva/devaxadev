@isTest
global class MobilityRestUpsertContactTest {
    
    @isTest static void testUpsert(){
        MobilityRestUpsertContact.RequestUpsertContact req = new MobilityRestUpsertContact.RequestUpsertContact();
        req.contact=new Contact(LastName = 'Test', TECH_NDG__c = 'XXX');
        Test.startTest();
        List<MobilityRestUpsertContact.ResponseUpsertContact> res=MobilityRestUpsertContact.upsertConctact(req);
        Test.stopTest();
        System.assert(res[0].result.recordId!=null);
        System.assertEquals(1, [select id from Contact].size());
    }

    
    @isTest static void testUpsertKO(){
        try{
            MobilityRestUpsertContact.RequestUpsertContact req = new MobilityRestUpsertContact.RequestUpsertContact();
            req.contact=new Contact(TECH_NDG__c = 'XXX');
            Test.startTest();
            List<MobilityRestUpsertContact.ResponseUpsertContact> res=MobilityRestUpsertContact.upsertConctact(req);
            Test.stopTest();
            System.assert(res[0].result.recordId!=null);
            System.assertEquals(1, [select id from Contact].size());
        } catch(Exception ex){
            Assert.isTrue(ex.getStackTraceString().contains('Class.MobilityRestUpsertContact.upsertConctact: line 54'));
        }
    }

    @isTest static void testUpsertEmptyException(){
        try{
            MobilityRestUpsertContact.RequestUpsertContact req = new MobilityRestUpsertContact.RequestUpsertContact();
            req.contact= null;
            Test.startTest();
            List<MobilityRestUpsertContact.ResponseUpsertContact> res=MobilityRestUpsertContact.upsertConctact(req);
            Test.stopTest();
            System.assert(res[0].result.recordId!=null);
            System.assertEquals(1, [select id from Contact].size());
        } catch(Exception ex){
            Assert.isTrue(ex.getStackTraceString().contains('Class.MobilityRestUpsertContact.upsertConctact: line 51'));
        }
    }

    
    @isTest static void testUpsertDMLException(){ 
        try{
            MobilityRestUpsertContact.RequestUpsertContact req = new MobilityRestUpsertContact.RequestUpsertContact();
            String lastName = '';
            for(Integer i=0; i<500; i++){
                lastName +='x';
            }
            req.contact= new Contact(LastName = lastName, 
            TECH_NDG__c = 'XXX');
            Test.startTest();
            List<MobilityRestUpsertContact.ResponseUpsertContact> res=MobilityRestUpsertContact.upsertConctact(req);
            Test.stopTest();
            System.assert(res[0].result.recordId!=null);
            System.assertEquals(1, [select id from Contact].size());
        } catch(Exception ex){
            Assert.isTrue(ex.getStackTraceString().contains('Class.MobilityRestUpsertContact.upsertConctact: line 54'));
        }
    }


}
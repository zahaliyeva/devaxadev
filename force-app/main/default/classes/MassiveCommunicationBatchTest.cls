/**
 * Created by francesco on 2019-07-11.
 */

@IsTest
private class MassiveCommunicationBatchTest {

    @TestSetup
    static void testSetup() {
        ServiceUtilsClass.populateCustomSettingsForTests();
        insert new AAI_Code_Variables__c(Name = 'MassiveCommunicationBatchAddresses', Value__c = 'test1@test.com;test2@test.com');

    }

    @IsTest
    static void foundContactTest() {
        Id B2CId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2C_Client').getRecordTypeId();

        Account acc1 = new Account(
                FirstName = 'Piermauro',
                LastName = 'Tagliabue',
                NDG__c = '0008280000000888',
                AAI_Codice_fiscale__c = 'TGLPRM54C14G218F',
                RecordTypeId = B2CId);

        Account acc2 = new Account(
                FirstName = 'GianGiacomo',
                LastName = 'Serbelloni',
                NDG__c = '0008280000000999',
                AAI_Codice_fiscale__c = 'SRBGNG54C14G218F',
                RecordTypeId = B2CId);

        insert new List<Account>{
                acc1, acc2
        };

        List<Massive_Communication__c> communications = new List<Massive_Communication__c>();
        for (Integer i = 0; i < 200; i++) {
            Id accId = Math.mod(i, 2) == 0 ? acc1.Id : acc2.Id;
            Massive_Communication__c mc = new Massive_Communication__c(
                    Name = String.valueOf(i),
                    Account__c = accId,
                    Status__c = 'Draft',
                    Type__c = 'Digital');
            communications.add(mc);
        }

        insert communications;

        Test.startTest();
        MassiveCommunicationBatch batch = new MassiveCommunicationBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        communications = [
                SELECT Account__r.Name, Contact__r.Name, Status__c, TECH_Status_Update_Date__c
                FROM Massive_Communication__c
                WHERE Id IN :communications
        ];

        for (Massive_Communication__c mc : communications) {
            System.assertEquals(mc.Account__r.Name, mc.Contact__r.Name);
            System.assertEquals('Ready', mc.Status__c);
            Datetime dT = mc.TECH_Status_Update_Date__c;
            Date d = Date.newInstance(dT.year(), dT.month(), dT.day());
            System.assertEquals(System.today(), d);
        }

    }

    @IsTest
    static void noContactTest() {
        Account a = new Account(Name = 'No Contacts please');
        insert a;

        List<Massive_Communication__c> communications = new List<Massive_Communication__c>();
        for (Integer i = 0; i < 200; i++) {
            Massive_Communication__c mc = new Massive_Communication__c(
                    Name = String.valueOf(i),
                    Account__c = a.Id,
                    Status__c = 'Draft',
                    Type__c = 'Digital');
            communications.add(mc);
        }

        insert communications;

        Test.startTest();
        MassiveCommunicationBatch batch = new MassiveCommunicationBatch(true);
        Database.executeBatch(batch);
        Test.stopTest();

        communications = [
                SELECT Account__r.Name, Contact__r.Name, Status__c, TECH_Status_Update_Date__c
                FROM Massive_Communication__c
                WHERE Id IN :communications
        ];

        for (Massive_Communication__c mc : communications) {
            System.assertEquals('KO digital sending', mc.Status__c);
            Datetime dT = mc.TECH_Status_Update_Date__c;
            Date d = Date.newInstance(dT.year(), dT.month(), dT.day());
            System.assertEquals(System.today(), d);
        }

    }

    @IsTest
    static void schedulerTest() {
        try {
            Test.startTest();
            MassiveCommunicationBatchScheduler mcbs = new MassiveCommunicationBatchScheduler();
            String sch = '0 0 23 * * ?';
            System.schedule('MassiveCommunicationBatchScheduler', sch, mcbs);
            Test.stopTest();
            System.assert(true);

        } catch (Exception e) {
            System.assert(false);

        }
    }


}
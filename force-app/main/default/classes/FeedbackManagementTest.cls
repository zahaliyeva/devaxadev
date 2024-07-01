@isTest
public class FeedbackManagementTest{

    @TestSetup
    static void makeData(){
        Id recordtypeId = [Select Id from Recordtype Where Name = 'B2B Client' and sObjecttype='Account'].Id;
        Account account = new Account(Name = 'test',
            RecordtypeId = recordtypeId,
            NDG__c = 'test',
            AAI_Codice_fiscale__c = 'BB176176abcdefgh',
            AAI_Agency_Reference_Code__c = '004610',
            State__c = 'ATTIVO');
        insert account;
       

        Feedback__c feedbackSandSiv = new Feedback__c ();
        feedbackSandSiv.recordtypeId = Schema.SObjectType.Feedback__c.getRecordTypeInfosByName().get(AP_Constants.rtClaimSurveyFeedback).getRecordTypeId();
        feedbackSandSiv.Survey_Origin__c = 'Sinistri Check IN';
        feedbackSandSiv.Agency_Code__c = '001622'; 
        feedbackSandSiv.Company__c = 'AAI';
        feedbackSandSiv.Questions_Rating__c = 'Gestione sinistro secondo aspettative: \n no \n\n Ambiti_difficoltà_Opzione2: \n Interazione con l’Agenzia \n\n ';

        insert feedbackSandSiv ;

        Feedback__c feedbackSandSiv2 = new Feedback__c ();
        feedbackSandSiv2.recordtypeId = Schema.SObjectType.Feedback__c.getRecordTypeInfosByName().get(AP_Constants.rtClaimSurveyFeedback).getRecordTypeId();
        feedbackSandSiv2.Survey_Origin__c = 'Sinistri Check OUT';
        feedbackSandSiv2.Agency_Code__c = '001622'; 
        feedbackSandSiv2.Company__c = 'MPS';   
        insert feedbackSandSiv2 ;
    }

    @isTest
    public static void getAccountsSuccess(){
        Account account = [SELECT Id from Account LIMIT 1];
        account.Name = 'OK';
        update account;
        Test.startTest();
        System.assertEquals(false, FeedbackManagement.getAccounts(new Set<String>{'test'}).isEmpty(), 'List is not empty');
        Test.stopTest();
    }

    @isTest
    public static void getExcludedAccountsNDG(){
        Test.startTest();
        List<String> excludedAccountsNDG = FeedbackManagement.getExcludedAccountsNDG();
        System.assertEquals(true, excludedAccountsNDG.contains('0089850000000022'), 'Account CASSA ASSIST.ASS.NI AXA');
        System.assertEquals(true, excludedAccountsNDG.contains('0089850000000978'), 'Account AXA ITALIA SERVIZI SCPA');
        Test.stopTest();
    }

    @isTest
    public static void getIfCaseGoesToAgencyTest(){
       

        String[] types = new String[]{'Feedback__c'};
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types);
        Map<String,String> MapFeedbackRecordType = new Map<String,String>();
       // Feedback__c feedback = [select id,Company__c,RecordTypeId,Agency_Code__c,Questions_Rating__c,Survey_Origin__c  from Feedback__c];
        List <Feedback__c> feedbackList = [select id,Company__c,RecordTypeId,Agency_Code__c,Questions_Rating__c,Survey_Origin__c  from Feedback__c];

        Feedback__c feedbackAAI,feedbackMPS ; 
 
             if(feedbackList[0].Company__c=='AAI')
             {
                 feedbackAAI = feedbackList[0];
                 feedbackMPS = feedbackList[1];
             }
             else{
                 feedbackAAI = feedbackList[1];
                 feedbackMPS = feedbackList[0];
             }

             for(Schema.DescribeSobjectResult re: results){
                for (Schema.RecordTypeInfo ri: re.getRecordTypeInfos())
                    {
                        MapFeedbackRecordType.put(ri.getName(), ri.getRecordTypeId());
                    }
            }
    
            Test.startTest();
            boolean rispostaVerdad = FeedbackManagement.getIfCaseGoesToAgency(feedbackAAI, false,false, true, MapFeedbackRecordType);
            boolean rispostaVerdad1 = FeedbackManagement.getIfCaseGoesToAgency(feedbackAAI, false, false, false, MapFeedbackRecordType);
            boolean rispostaFalsa = FeedbackManagement.getIfCaseGoesToAgency(feedbackMPS, false, false, false, MapFeedbackRecordType);
            //coverage lines
            FeedbackManagement.getIfCaseGoesToAgency(feedbackAAI, true, false, false, MapFeedbackRecordType);
            FeedbackManagement.getIfCaseGoesToAgency(feedbackAAI, false, true, false, MapFeedbackRecordType);
    
            System.assertEquals(true,rispostaVerdad);
            System.assertEquals(true,rispostaVerdad1);
            System.assertEquals(false,rispostaFalsa);
            Test.stopTest();
    }
}
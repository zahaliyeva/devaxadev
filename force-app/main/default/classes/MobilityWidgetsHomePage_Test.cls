@isTest
public class MobilityWidgetsHomePage_Test {
	//zahra
    @isTest
    public static void method1(){ //MobilityWidgetsHomepage
        List<String> counters = new List<String>{
          'campaign',
          'lead',
          'feedback',
          'event',
          'task',
          'support'
        };
        MobilityWidgetsHomePage.getCounters(counters);
    }
    
    @isTest
    public static void method2(){//JSON2Apex_Converter
        JSON2Apex_Converter.parse('{"coverages":[{"name":"test","id":"test","shortDescriptionLines":[],"categoryName":"test","categoryId":"test","improvementIndicator":true,"riderName":"test","beneficiaries":[{"beneficiaryName":"test","coverageBenefitPercentage":10}],"restrictions":[{"type_Z":"test","value":10,"unitCode":"test","applicationCase":"test","description":"test"}],"benefit":{"descriptionLines":[],"lumpSumBenefit":{"value":10.0,"currencyCode":"test"},"scheduledBenefit":{"periodicity":{"code":"test","name":"test"},"endDate":"test","yearlyRenewalDate":"test"}},"clauses":[],"effectiveDate":"test","expirationDate":"test"}]}');
    }
    
    @isTest
    public static void method3(){//customLayoutUtility
        Campaign l = new Campaign(recordtypeId = [Select id from recordtype where developername = 'Data_Enrichment_Campaign'].Id, name = 'test');
        insert l;
        CustomLayoutUtility.getLayoutDefinition('', 'Campaign', 'Data_Enrichment_Campaign', l.Id);
    }

    @isTest 
    public static void CustomLayoutUtilityCoverage() {
        Campaign l = new Campaign(recordtypeId = [Select id from recordtype where developername = 'Data_Enrichment_Campaign'].Id, name = 'test');
        insert l;

        Test.startTest();
        CustomLayoutUtility.getRecord('',new Set < String >(),'');

        CustomLayoutUtility.getRecordType('','');
        
        CustomLayoutUtility.getLayout('',null,null);
        CustomLayoutUtility.getLayout('Campaign',l.id,'Data_Enrichment_Campaign');
        CustomLayoutUtility.getLayout('Campaign',l.id,null);
        
        CustomLayoutUtility.save(l);
        l.Name='';
        CustomLayoutUtility.save(l);
        
        CustomLayoutUtility.getFormattedDate(Date.today(),'YYYY-MM-DD');
        CustomLayoutUtility.getFormattedDatetime(Datetime.now(),'yyyy-MM-dd h:mm a');
        
        Account testAccount = new Account(NDG__c = 'TestNDG', Name = 'testNikolas');
        insert testAccount;
        Feedback__c testFeedback = new Feedback__c(
                NPS__c = 8,
                Survey_Origin__c = 'TestSurvey',
                Account__c = testaccount.id
              
            );
        insert testFeedback;

        // Chiamata al metodo getNDGData
        MobilityWidgetsHomepage.MobilityNDGData result = MobilityWidgetsHomepage.getNDGData('TestNDG');

        Test.stopTest();
    }
    
    
}
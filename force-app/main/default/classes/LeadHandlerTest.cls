@isTest
public class LeadHandlerTest{

    @testSetup static void setup() {
    
    insert new QueueAssignmentLogicParameters__c(Dettaglio__c='Visualizza quotazione',
      LandingPage__c='Auto',
      Name='ConFido1',
      ClienteAction__c='AG di appartenenza',
      NotClienteAction__c='Coda default',
      MCEmailClickAction__c='AG Noovle, riassegna',
      CodaDefault__c='Coda_Lead_Visualizza_Quotazione_EC');

    //fill custom setting MappingASA__c
        MappingASA__c mapASA = new MappingASA__c();
        mapASA.Name = '3';
        mapASA.ASA__c ='Famiglia';
        mapASA.Codice_ASA__c = 3;
        mapASA.ASA_Description__c ='3 - Famiglia';
        
        Database.insert(mapASA);
        
        //fill custom setting MappingSottoASA__c
        MappingSottoASA__c mapSottoASA = new MappingSottoASA__c();
        mapSottoASA.Name = '3.1';
        mapSottoASA.Sotto_ASA__c ='Abitazione';
        mapSottoASA.Codice_Sotto_ASA__c = 1;
        mapSottoASA.Sotto_ASA_Description__c ='3.1 Abitazione';
        
        Database.insert(mapSottoASA);
        
        List <LeadAssignmentConfiguration__c> configuration = new List<LeadAssignmentConfiguration__c>();
        
        //fill custom setting  LeadAssignmentConfiguration__c
        LeadAssignmentConfiguration__c confido = new LeadAssignmentConfiguration__c();
        confido.Name = 'ConFido';
        confido.ASA__c = 3;
        confido.Sub_ASA__c = 1;
        
        configuration.add(confido);

        LeadAssignmentConfiguration__c auto = new LeadAssignmentConfiguration__c();
        auto.Name = 'Auto';
        auto.ASA__c = 3;
        auto.Sub_ASA__c = 1;
        
        configuration.add(auto);
        
        //fill custom setting  LeadAssignmentConfiguration__c
        LeadAssignmentConfiguration__c LastndaysforLeadduplication = new LeadAssignmentConfiguration__c();
        LastndaysforLeadduplication.Name = 'Last n days for Lead duplication';
        LastndaysforLeadduplication.DaysLimit__c = 7;
        
        configuration.add(LastndaysforLeadduplication);
        
        
         //fill custom setting  LeadAssignmentConfiguration__c
        LeadAssignmentConfiguration__c LastndaysforduplicationMupload = new LeadAssignmentConfiguration__c();
        LastndaysforduplicationMupload.Name = 'Last n days for duplication M upload';
        LastndaysforduplicationMupload.DaysLimit__c = 7;
        
        configuration.add(LastndaysforduplicationMupload );  
          
        Database.insert(configuration);  
    
        AAI_Code_Variables__c nameConf = new AAI_Code_Variables__c(name = 'LeadTrackingDefaultAccount',value__c = 'TestAgency');
        Id AgencyRTID = [Select id from recordtype where sobjectType = 'Account' and developername = 'Agency'].Id;
        Account a = new Account(Name = 'TestAgency', recordtypeId = AgencyRTID);
        insert nameConf;
        insert a;
    
    }
    
    
    static testmethod void TestLeadHandler(){
    
    AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
    insert acv;
    
    //Create Lead
    Lead ld = new Lead(
            LastName = 'LeadTest',
            FirstName ='test',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            Agency_Code__c = '006345',
            MarketingCloudEmailClick__c=false,
            MobilePhone = '3333333333', 
            Dettaglio__c='Salva quotazione',
            Landing_page__c = 'Confido',
            Postalcode = '20090');
    insert ld;   
    
    //Modify lead
    ld.Phone = '0333333333';
    update ld;
    delete ld;
    undelete ld;
    lead ld2= new Lead(LastName = 'LeadTest2',
      FirstName ='test2',
      Email = 'lead@mail.test2',
      Phone = '1333333333',
      MarketingCloudEmailClick__c=false,
      Landing_page__c = 'Auto',
      Dettaglio__c='Visualizza quotazione',
      Postalcode = '20090');
    insert ld2;
    ld2.MarketingCloudEmailClick__c=true;
    update ld2;
    
    
  }
   
    static testmethod void TestTracking(){
        Lead ld = new Lead(
            LastName = 'LeadTest',
            FirstName ='test',
            Email = 'lead@mail.test',
            Phone = '0333333333',
            Agency_Code__c = '006345',
            MarketingCloudEmailClick__c=false,
            MobilePhone = '3333333333', 
            Dettaglio__c='Salva quotazione',
            Landing_page__c = 'Confido',
            Postalcode = '20090');
        insert ld;
        List<Lead> lToTrack = new List<Lead> ();
        lToTrack.add(ld);
        LeadTrackingManagement.InputWrapper i = new LeadTrackingManagement.InputWrapper();
            i.leadNew = lToTrack;
            i.isUpdate = false;
            LeadTrackingManagement.manageLead(i);
        Lead old = (Lead) ld;
        old.OwnerId = null;
        List<Lead> oldToTrack = new List<Lead> ();
        oldToTrack.add(old);
        i = new LeadTrackingManagement.InputWrapper();
            i.leadNew = lToTrack;
        	i.leadOld = oldToTrack;
            i.isUpdate = true;
            LeadTrackingManagement.manageLead(i);
    }

    static testmethod void TestTrackingUnableToLockRow(){
      Lead ld = new Lead(
          LastName = 'LeadTest',
          FirstName ='test',
          Email = 'lead@mail.test',
          Phone = '0333333333',
          Agency_Code__c = '006345',
          MarketingCloudEmailClick__c=false,
          MobilePhone = '3333333333', 
          Dettaglio__c='Salva quotazione',
          Landing_page__c = 'Confido',
          Postalcode = '20090');
      insert ld;

      List<Lead> ldd = [Select id from Lead where id =: ld.Id FOR UPDATE];

      TEST.startTest();
        List<Lead> lToTrack = new List<Lead> ();
        lToTrack.add(ld);
        LeadTrackingManagement.testingUnable = true;
        LeadTrackingManagement.InputWrapper i = new LeadTrackingManagement.InputWrapper();
        i.leadNew = lToTrack;
        i.isUpdate = false;
        LeadTrackingManagement.manageLead(i);
        system.assert([Select id from Bulk_Request__c where BulkRequestHandler__c = 'BulkRequest_TrackLeadHistory'].size() == 1);
      TEST.stopTest();
      
  }
    
}
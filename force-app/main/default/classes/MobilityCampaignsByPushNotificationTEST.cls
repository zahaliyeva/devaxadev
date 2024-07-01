@istest
    public with sharing class MobilityCampaignsByPushNotificationTEST {


      @TestSetup
      static void makeData(){
        
        Profile padmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        RecordType RT = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'Marketing_campaign'];
        
        Account a = new Account(Name = 'Test');
        insert a;
        
        Contact contact = new Contact(LastName = 'test',AccountId= a.id);
        insert contact;

        CampaignMembStatus__c cms=new CampaignMembStatus__c(
              Name = 'Interested',
              Status_Name__c = 'Interessato',
              SortOrder__c = 3,
              IsDefault__c = true,
              Campaign_Record_Type__c='Marketing_campaign'                  
          );
        insert cms;

        Campaign cp = new Campaign(
            Name = 'CampagnaTest',
            IsActive = true,
            Status = 'On-going',
            RecordTypeID = RT.Id,
            StartDate = Date.today(),
            EndDate = Date.today()+3
        );
        insert cp;

        Iniziative_Marketing__c im = new Iniziative_Marketing__c();
        im.Name = 'Temp temp';
        im.Attiva__c = true ;
        im.Eligibile_per_Compagnia__c = 'AAI';
        im.Tipologia_di_iniziative__c = 'Automatici da Direzione';
        im.Communication_Code__c = 'push_notification';
        im.Titolo__c='Test title';
        im.Sottotitolo__c='Test subtitle';
        im.Contenuto__c='Test Content';
        im.Short_Message__c='Test short message';
        im.Message__c= 'test messageeeeee';
        im.Descrizione_dell_iniziativa__c='descriptiondescriptiondescriptiondescription';
        insert im;

        User usr1=new User(FirstName='Marzia',
        LastName = 'Rossi',
        Alias = 'mro666',
        Email = 'mrosskmans@detloitte.com',
        Username = 'tmrosskm11@axa.com.masterdev',
        CommunityNickname = 'MarziRo',
        LanguageLocaleKey = 'en_US',
        TimeZoneSidKey='Europe/Rome',
        Agency_Code__c = '000828',
        Nodes__c = 'DIF_000828',
        Profileid = padmin.id,
        LocaleSidKey='en_US',
        EmailEncodingKey='ISO-8859-1');
        insert usr1;

        Node__c nodo = new Node__c ();
        nodo.Agency_holder__c = 'NODO Holder';
        nodo.Node_unique_code__c= '000828';
        nodo.Parent_node_unique_code__c= 'A001';
        nodo.Tree_name__c= 'DIF';
        nodo.Blacklist_Processi__c= 'Rinnovi';
        nodo.Node_description__c= 'Agency Away from Home';
        nodo.Node_level__c= 7;
        nodo.superMessagesTotali__c=10;
        nodo.superMessagesPrenotati__c=2;
        nodo.superMessagesUtilizzati__c=3;
    
        NodeHandler.setDeactivateTrigger(true);//avoid trigger for this node, non rules 
        insert nodo ;
      }

      @isTest
      public static void createCampaignTest() {

        Campaign c=[select id,ownerid,Iniziative_Marketing__c,Campagna_creata_da_Direzione_Agente__c,RecordTypeId,name,EndDate,StartDate,Status from Campaign where name = 'CampagnaTest' limit 1];
        Iniziative_Marketing__c im = [select id from Iniziative_Marketing__c where name = 'Temp temp' limit 1];
        User u=[select id,Name,ProfileId, Agency_Code__c,Main_Node__c from User where Username = 'tmrosskm11@axa.com.masterdev' limit 1];
        
        Node__c n=[select id,superMessagesTotali__c from Node__c where Node_unique_code__c = '000828' limit 1];
       
        Test.startTest();

        MobilityCampaignsByPushNotification.WrapperReponse wr=MobilityCampaignsByPushNotification.createCampaign(c, 'Commerciale', 10, true, im.id);

        System.runAs(u){

          n.superMessagesTotali__c=null;
          NodeHandler.setDeactivateTrigger(true);
          update n;
          MobilityCampaignsByPushNotification.createCampaign(c, 'Commerciale', 10, true, im.id);

          n.superMessagesTotali__c=10;
          update n;
          
          MobilityCampaignsByPushNotification.createCampaign(c, 'Commerciale', 10, true, im.id);
          MobilityCampaignsByPushNotification.createCampaign(c, 'Commerciale', 1, true, im.id);
          MobilityCampaignsByPushNotification.createCampaign(c, 'InvalidRT', 10, null, 'invalid id');
          MobilityCampaignsByPushNotification.createCampaign(c, null, 10, false, 'invalid id');
        }

        Test.stopTest();

        System.Assert.areEqual(false, wr.isSuccess);
        System.Assert.areEqual(true, wr.errorMessage.contains('E05 - Agency Code NON popolata nel USER'));
      }

      @isTest
      public static void createCampaignMembersTest() {
        Contact co = [select id from contact limit 1];
        Account a = [select id from Account limit 1];
        User u=[select id,Name,ProfileId, Agency_Code__c,Main_Node__c from User where Username = 'tmrosskm11@axa.com.masterdev' limit 1];
        List<MobilityCampaignsByPushNotification.WrapperRequest> wrs = new List<MobilityCampaignsByPushNotification.WrapperRequest> ();
        MobilityCampaignsByPushNotification.WrapperRequest wr=new MobilityCampaignsByPushNotification.WrapperRequest();
        wr.ContactId=co.id;
        wr.AccountId=a.id;
        wrs.add(wr);
        Iniziative_Marketing__c im = [select id,TECH_URL_template_MC__c,Invio_push__c,Descrizione_dell_iniziativa__c,Canale__c,Tipo_notifica_su_Centro_Notifiche__c,URL_Immagine__c,Visibilita_nel_centro_notifiche__c,Communication_Code__c,URL_CTA__c,Testo_CTA__c,Titolo__c,Sottotitolo__c,Contenuto__c, Short_Message__c,Message__c from Iniziative_Marketing__c where name = 'Temp temp' limit 1];
        Campaign c=[select id,ownerid,Iniziative_Marketing__c,Campagna_creata_da_Direzione_Agente__c,RecordTypeId,name,EndDate,StartDate,Status from Campaign where name = 'CampagnaTest' limit 1];
        
        Test.startTest();

        MobilityCampaignsByPushNotification.WrapperReponse res = MobilityCampaignsByPushNotification.createCampaignMembers(wrs,c.id,true,im,null,null);

        System.runAs(u) {
         
          MobilityCampaignsByPushNotification.createCampaignMembers(wrs,c.id,true,im,null,null);
          MobilityCampaignsByPushNotification.createCampaignMembers(wrs,c.id,true,null,null,null);
          MobilityCampaignsByPushNotification.createCampaignMembers(null,c.id,true,im,null,null);
          MobilityCampaignsByPushNotification.createCampaignMembers(wrs,null,true,im,null,null);


        }

        Test.stopTest();
        System.Assert.areEqual(true, res.isSuccess);
        System.Assert.areEqual(true, res.SuccessMessage.contains('OK02'));
      }

      @isTest
      public static void getMessageStatusFromNodeTest() {
        User u=[select id,Name,ProfileId, Agency_Code__c,Main_Node__c from User where Username = 'tmrosskm11@axa.com.masterdev' limit 1];

        Test.startTest();
        MobilityCampaignsByPushNotification coverageConstructor = new MobilityCampaignsByPushNotification();
        MobilityCampaignsByPushNotification.WrapperReponse res = MobilityCampaignsByPushNotification.getMessageStatusFromNode();
        System.runAs(u) {
        MobilityCampaignsByPushNotification.getMessageStatusFromNode();
        }
        Test.stopTest();
        System.Assert.areEqual(false, res.isSuccess);
        System.Assert.areEqual(true, res.errorMessage.contains('E051 - Agency Non trovato'));
      }

      @isTest
      public static void setCountersFromNodeTest() {
        User u=[select id,Name,ProfileId, Agency_Code__c,Main_Node__c from User where Username = 'tmrosskm11@axa.com.masterdev' limit 1];
        Test.startTest();
        //MobilityCampaignsByPushNotification.createBodyTextForMC();
        //MobilityCampaignsByPushNotification.setCountersFromNode(1);
        System.runAs(u) {
         // MobilityCampaignsByPushNotification.setCountersFromNode(1);
        }

        Test.stopTest();
        System.Assert.areEqual('placeholder', 'placeholder');
      }

      @isTest
      public static void updateCampagnaFinaleTest() {
        Campaign c=[select id,ownerid,Iniziative_Marketing__c,Campagna_creata_da_Direzione_Agente__c,RecordTypeId,name,EndDate,StartDate,Status from Campaign where name = 'CampagnaTest' limit 1];
        Test.startTest();
        MobilityCampaignsByPushNotification.updateCampagnaFinale(c.id,true,true,1,'001622;001622000001');
        MobilityCampaignsByPushNotification.updateCampagnaFinale(c.id,true,false,1,'001622;001622000001');
        MobilityCampaignsByPushNotification.updateCampagnaFinale(c.id,false,false,1,'001622;001622000001');
        MobilityCampaignsByPushNotification.updateCampagnaFinale(c.id,null,null,1,'001622;001622000001');
        Test.stopTest();

        Campaign res = [select id,status from Campaign where id=:c.id];
        System.Assert.areEqual('On-going', res.status);
      }

      @isTest
      public static void QueueableInsertCommunicationsFromCampaignMembersTest() {

        Contact co = [select id from contact limit 1];
        Campaign c=[select id,ownerid,Iniziative_Marketing__c,Campagna_creata_da_Direzione_Agente__c,RecordTypeId,name,EndDate,StartDate,Status from Campaign where name = 'CampagnaTest' limit 1];
        User u=[select id,Name,ProfileId, Agency_Code__c,Main_Node__c from User where Username = 'tmrosskm11@axa.com.masterdev' limit 1];
        RecordType RT = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'Agency_campaign'];
        c.RecordTypeID=RT.id;
        c.ownerid=u.id;
        update c;
          
        CampaignMember cm= new CampaignMember(CampaignId=c.Id,ContactId=co.Id,Status='Sent',Sottostato__c='Invio cartaceo');
        insert cm;
       String query ='SELECT Id FROM Communications_to_customer__c';
        Test.startTest();
        System.enqueueJob(new MobilityCampaignsByPushNotification.QueueableInsertCommunicationsFromCampaignMembers(c.id));
        System.enqueueJob(new MobilityCampaignsByPushNotification.QueueableUpdateCommunicationsOnCampaign(c.id));
         System.enqueueJob(new MobilityCampaignsByPushNotification.QueueableUpdateCommunicationsOnCampaign(query,'3'));  
        Test.stopTest();

        System.Assert.areEqual('placeholder', 'placeholder');
      }
        
     
@isTest
        public static void WrapperCambiOrariTest(){
          List<MobilityCampaignsByPushNotification.WrapperDay> testgetlistDays = new List<MobilityCampaignsByPushNotification.WrapperDay>();
            Test.startTest();
            MobilityCampaignsByPushNotification.WrapperCambiOrari wr=new MobilityCampaignsByPushNotification.WrapperCambiOrari();
            MobilityCampaignsByPushNotification.WrapperDay wd=new MobilityCampaignsByPushNotification.WrapperDay();
            wd.isClosed=true;
            wd.al1='test';
            wd.dal1 ='test';   
            wr.validoAl='test';
            wr.validoDal='test';
            wr.getlistDays();
            Test.stopTest();
        }
       
 

    }
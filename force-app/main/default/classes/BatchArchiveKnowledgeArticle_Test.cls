@istest
public class BatchArchiveKnowledgeArticle_Test {

    
    @TestSetup
    static void makeData(){
        ID newsRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('News').getRecordTypeId();
  
        // this art has to be archive by the batch
        Knowledge__kav art1 = new Knowledge__kav();
        art1.RecordTypeId = newsRecordTypeId ;
        art1.Title = 'Test APex Name';
        art1.UrlName = 'Test-APex-Name';
        art1.Article_Content__c = 'Oh oh sometimes, I get a good feeling';
        art1.FAQ_Valido_Da__c = Date.valueOf(System.now().addDays(-2).format('yyyy-MM-dd'));
        art1.FAQ_Valido_fino_a__c = Date.valueOf( System.now().addDays(-1).format('yyyy-MM-dd') );
        insert art1;

        // this one can not enter on the batch query so stays online status
        Knowledge__kav art2 = new Knowledge__kav();
        art2.RecordTypeId = newsRecordTypeId ;
        art2.Title = 'Test APex Name with FlowMails';
        art2.UrlName = 'Test-APex-Name2';
        art2.Article_Content__c = 'Oh oh sometimes, I get a good feeling';
        art2.CaseManagement_Send_Email_Notification__c = true;
        art2.Destinatario_Notifica__c = 'KM Agenzia Dipendenti';
        art2.FAQ_Valido_Da__c = Date.valueOf(System.now().addDays(-1).format('yyyy-MM-dd'));
        art2.FAQ_Valido_fino_a__c = Date.valueOf( System.now().addDays(1).format('yyyy-MM-dd') );
        insert art2;

    }

    @isTest
    static void TEST_Batch(){

        List<Knowledge__kav> listaKnow = [select id,KnowledgeArticleId,Title, Article_Content__c, ArticleCreatedDate, FAQ_Valido_Da__c, 
        FAQ_Valido_fino_a__c, PublishStatus, Destinatario_Notifica__c, CaseManagement_Send_Email_Notification__c
        from Knowledge__kav ];

        for(Knowledge__kav knoTemp: listaKnow)
        KbManagement.PublishingService.publishArticle(knoTemp.KnowledgeArticleId, true);

        system.debug('Lista arts pero non online ancora' + listaKnow);

        Test.startTest();
        Id batchJobId = Database.executeBatch(new BatchArchiveKnowledgeArticle(), 10);
        system.debug('id temps for batch - '+batchJobId);
        Test.stopTest();

        // problably the status do not update on the array, so make another call for arts on DB
        List<Knowledge__kav> listaKnowUpdateAfterBatch = [select id,KnowledgeArticleId,Title, Article_Content__c, ArticleCreatedDate, FAQ_Valido_Da__c, 
        FAQ_Valido_fino_a__c, PublishStatus, Destinatario_Notifica__c, CaseManagement_Send_Email_Notification__c
        from Knowledge__kav ];

        system.debug('Lista arts diferents status - ' + listaKnowUpdateAfterBatch);

               
        List<AsyncApexJob> listfetched = [select ApexClass.Name, Id, JobItemsProcessed, JobType, Status, NumberOfErrors,
        MethodName , CronTrigger.CronJobDetail.Name from AsyncApexJob where JobType in ('ScheduledApex')];

       // System.assertEquals(listfetched.size(), 1);

    }
    @isTest
    static void TEST_BatchErrors(){

        List<Knowledge__kav> listaKnow = [select id,KnowledgeArticleId,Title, Article_Content__c, ArticleCreatedDate, FAQ_Valido_Da__c, 
        FAQ_Valido_fino_a__c, PublishStatus, Destinatario_Notifica__c, CaseManagement_Send_Email_Notification__c
        from Knowledge__kav ];

        system.debug('Lista arts pero non online ancora' + listaKnow);
        for(Knowledge__kav knoTemp: listaKnow)
        KbManagement.PublishingService.publishArticle(knoTemp.KnowledgeArticleId, true);

        //per testare errore non si puo archiviare un art Online se ha asociato un art nel status Draft :) 
        String idNuovoDraft = KbManagement.PublishingService.editOnlineArticle (listaKnow[0].KnowledgeArticleId, true);

        Knowledge__kav nuovoDraft = [select id,KnowledgeArticleId,Title, Article_Content__c, ArticleCreatedDate, FAQ_Valido_Da__c, 
        FAQ_Valido_fino_a__c, PublishStatus, Destinatario_Notifica__c, CaseManagement_Send_Email_Notification__c
        from Knowledge__kav where id =: idNuovoDraft ];
        System.debug('nuovo draft asociato a'+nuovoDraft.Title+' Id: '+nuovoDraft.id + nuovoDraft);

        Test.startTest();
        BatchArchiveKnowledgeArticle batchKnw = new BatchArchiveKnowledgeArticle();
        batchKnw.needInfoLogWrite = true;
        batchKnw.isAutoSchedulable = true;
        batchKnw.query = 'Select id,ArchivedDate, ArticleNumber,RecordType.DeveloperName, Title,knowledgeArticleId, CreatedDate,FAQ_Valido_fino_a__c, PublishStatus ,CaseManagement_Article_Content__c,FAQ_Valido_Da__c from Knowledge__kav';
        Id batchJobId = Database.executeBatch(batchKnw, 10);
        system.debug('id temps for batch Errorv0 - '+batchJobId);
        Test.stopTest();

    }
}
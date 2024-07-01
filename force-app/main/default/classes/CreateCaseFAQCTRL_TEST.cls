@IsTest
public class CreateCaseFAQCTRL_TEST {
    
    @testSetup static void setup() 
    {
        insert new MPS_Code_Variables__c(Name = 'ProponiSoluzioneHD2', value__c = 'true');
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name = 'NFE - AAI - Vendite Avanzato'];
        Profile p;
        Id pAgent;
        if (profiles.size() > 0)
        {
            p      = profiles[0];
            pAgent = p.Id;
        } 
        
        Account acct = new Account(Name = 'SFDC Account');
        insert acct;
        Id accId     = acct.Id;
        
        Contact con = new Contact(FirstName = 'Joe',
                                  LastName  = 'Smith',
                                  Phone     = '415.555.1212',
                                  AccountId = accId);
        insert con;
        Id conId = con.Id;
        
        User newAgent = new User(Username                     = 'agente@axa.test.com',
                                 LastName                     = 'testuser',
                                 LanguageLocaleKey            = 'it',
                                 FirstName                    = 'test',
                                 Email                        = 'test@test.com', 
                                 Alias                        = 'test',
                                 TimeZoneSidKey               = 'Europe/Dublin',
                                 LocaleSidKey                 = 'it_IT',
                                 EmailEncodingKey             = 'UTF-8',
                                 ProfileId                    = pAgent,
                                 ContactId                    = conId,
                                 UserPermissionsKnowledgeUser = true);
        insert newAgent;
        
        
		/*
        FAQ__kav newArticle = new FAQ__kav(Title='test article', UrlName='testarticleurl', Summary = 'test from apex' );
        insert newArticle;
        FAQ__kav obj1 = [SELECT Id,Title,KnowledgeArticleId FROM FAQ__kav WHERE id =: newArticle.id];
        system.debug('obj1: '+obj1);
        KbManagement.PublishingService.publishArticle(obj1.KnowledgeArticleId, true);
        FAQ__kav obj2 = [SELECT Id,Title,KnowledgeArticleId,Publishstatus FROM FAQ__kav WHERE id =: newArticle.id];
        system.debug('obj2: '+obj2);
        knowledgearticleversion knowledge = new knowledgearticleversion();
        
        knowledge = [select id, title, KnowledgeArticleId, publishStatus, isLatestVersion FROM knowledgearticleversion ];
        
        system.debug('knowledge: '+knowledge);
        List<FAQ__DataCategorySelection> dataCategoryList = new List<FAQ__DataCategorySelection>();
        FAQ__DataCategorySelection dataCategoryVis = new FAQ__DataCategorySelection();
        dataCategoryVis.ParentId = newArticle.id;
        dataCategoryVis.DataCategoryGroupName = 'Visibilit';
        dataCategoryVis.DataCategoryName = 'Assistenza_Agenti';
        dataCategoryList.add(dataCategoryVis);
        FAQ__DataCategorySelection dataCategoryREc = new FAQ__DataCategorySelection();
        dataCategoryREc.ParentId = newArticle.id;
        dataCategoryREc.DataCategoryGroupName = 'Record_Type';
        dataCategoryREc.DataCategoryName = 'Assistenza_Agenti';
        dataCategoryList.add(dataCategoryREc);
        FAQ__DataCategorySelection dataCategoryCat = new FAQ__DataCategorySelection();
        dataCategoryCat.ParentId = newArticle.id;
        dataCategoryCat.DataCategoryGroupName = 'Categoria';
        dataCategoryCat.DataCategoryName = 'IT_AUTO';
        dataCategoryList.add(dataCategoryCat);
        insert dataCategoryList;
*/
        Id rtFAQ = [SELECT id from RecordType where DeveloperName ='FAQ' Limit 1].Id;
        
        Knowledge__kav newArticle = new Knowledge__kav(RecordTypeId=rtFAQ, Title='test article', UrlName='testarticleurl', Summary = 'test from apex' );
        insert newArticle;
        Knowledge__kav obj1 = [SELECT Id,Title,KnowledgeArticleId FROM Knowledge__kav WHERE id =: newArticle.id];
        system.debug('+++ lb obj1: '+obj1);
        KbManagement.PublishingService.publishArticle(obj1.KnowledgeArticleId, true);
        Knowledge__kav obj2 = [SELECT Id,Title,KnowledgeArticleId,Publishstatus FROM Knowledge__kav WHERE id =: newArticle.id];
        system.debug('+++ lb obj2: '+obj2);
        knowledgearticleversion knowledge = new knowledgearticleversion();
        
        knowledge = [select id, title, KnowledgeArticleId, publishStatus, isLatestVersion FROM knowledgearticleversion ];
        
        system.debug('+++ lb knowledge: '+knowledge);
        List<Knowledge__DataCategorySelection> dataCategoryList = new List<Knowledge__DataCategorySelection>();
        /*Knowledge__DataCategorySelection dataCategoryVis = new Knowledge__DataCategorySelection();
        dataCategoryVis.ParentId = newArticle.id;
        dataCategoryVis.DataCategoryGroupName = 'Visibilit';
        dataCategoryVis.DataCategoryName = 'Assistenza_Agenti';
        dataCategoryList.add(dataCategoryVis);*/
        Knowledge__DataCategorySelection dataCategoryREc = new Knowledge__DataCategorySelection();
        dataCategoryREc.ParentId = newArticle.id;
        dataCategoryREc.DataCategoryGroupName = 'Record_Type';
        dataCategoryREc.DataCategoryName = 'Assistenza_Agenti';
        dataCategoryList.add(dataCategoryREc);
        /*Knowledge__DataCategorySelection dataCategoryCat = new Knowledge__DataCategorySelection();
        dataCategoryCat.ParentId = newArticle.id;
        dataCategoryCat.DataCategoryGroupName = 'Categoria';
        dataCategoryCat.DataCategoryName = 'IT_AUTO';
        dataCategoryList.add(dataCategoryCat);*/
        insert dataCategoryList;
        
    }
    
    static testMethod void testmethod1() 
    {
        test.StartTest();
        
        User    agent      = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id, Origin FROM Case LIMIT 3];
        
        List<Knowledge__kav> obj1 = [SELECT Id,Title FROM Knowledge__kav WHERE Title ='test article'];
        system.debug('obj1: '+obj1);
        List<knowledgearticleversion> knowledge = new List<knowledgearticleversion>();
        
        knowledge = [select id, title, KnowledgeArticleId, publishStatus, isLatestVersion FROM knowledgearticleversion ];
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = knowledge[0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        List<CreateCaseFAQCTRL.knowledge> know = new List<CreateCaseFAQCTRL.knowledge>();
        know = CreateCaseFAQCTRL.getArticlesKnowledge('test', '', '', '');
        know = CreateCaseFAQCTRL.getArticlesKnowledge('test', 'rating', 'FAQ', 'AUTO');
        know = CreateCaseFAQCTRL.getArticlesKnowledge('article', 'Title asc', 'FAQ', 'AUTO');
        know = CreateCaseFAQCTRL.getArticlesKnowledge('test', 'Title desc', 'FAQ', 'AUTO');
        know = CreateCaseFAQCTRL.getArticlesKnowledge('test', 'LastPublishedDate desc', 'FAQ', 'AUTO');
        know = CreateCaseFAQCTRL.getArticlesKnowledge('', 'LastPublishedDate desc', 'FAQ', 'AUTO');
        //OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz -- START
        CreateCaseFAQCTRL.KnowledgeSORT sortKNW = new CreateCaseFAQCTRL.KnowledgeSORT(know[0], 'score');
        CreateCaseFAQCTRL.KnowledgeSORT sortKNW2 = new CreateCaseFAQCTRL.KnowledgeSORT(know[0], 'score');
        sortKNW.compareTo(sortKNW2);
        CreateCaseFAQCTRL.KnowledgeSORT sortKNW3 = new CreateCaseFAQCTRL.KnowledgeSORT(know[0], 'rating');
        CreateCaseFAQCTRL.KnowledgeSORT sortKNW4 = new CreateCaseFAQCTRL.KnowledgeSORT(know[0], 'rating');
        sortKNW3.compareTo(sortKNW4);
        //OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz -- END
        test.stopTest();
    } 
}
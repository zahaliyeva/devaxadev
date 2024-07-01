@isTest public class CommunityKnowledgeController_TEST {
    
    
    @TestSetup
    static void makeData(){
        
        
        

        Id recType = [Select id from Recordtype where SObjectType = 'Knowledge__kav' and developername = 'FAQ_Agenti'].Id;
        Knowledge__kav ka = new Knowledge__kav();
        ka.Title = 'Salesforce CRM';
        ka.UrlName = 'salesforce-crm';
        ka.Summary = 'Salesforce Cloud CRM';
        ka.Language = 'it';
        ka.FAQ_Risposta__c = 'Salesforce';
        ka.recordTypeId = recType;
        insert ka;

        List<Knowledge__DataCategorySelection> kList = new List<Knowledge__DataCategorySelection>();
        kList.add(new Knowledge__DataCategorySelection(ParentId = ka.Id, DataCategoryGroupName = 'Record_Type', DataCategoryName = 'Assistenza_Agenti'));
        kList.add(new Knowledge__DataCategorySelection(ParentId = ka.Id, DataCategoryGroupName = 'Processo', DataCategoryName = 'New_Business'));
        kList.add(new Knowledge__DataCategorySelection(ParentId = ka.Id, DataCategoryGroupName = 'Processo', DataCategoryName = 'Commercial_Line'));
        insert kList;

        Id Article = [Select KnowledgeArticleId from Knowledge__kav where id =: ka.Id].KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(Article, true);
    }


    private static CommunityKnowledgeController.BodyType getBody(){
        CommunityKnowledgeController.BodyType body = new CommunityKnowledgeController.BodyType();
        body.filter = 'Record_Type:Assistenza_Agenti-(Processo:New_Business)';
        body.recordtype = 'Assistenza_Agenti';
        body.processo = 'Commercial_Line';
        return body;
    }

    private static string getEncryptedBody(){
        CommunityKnowledgeController.BodyType body = getBody();
        try{
			Crypto_Values__mdt val = [Select Init_Vector__c, Key__c from Crypto_Values__mdt where developerName = 'Wizard_CL'];
			Blob passPhrase = Blob.valueOf(val.Key__c);
			Blob IV = Blob.valueOf(val.Init_Vector__c);
			Blob privateKey = Crypto.generateDigest('SHA-256',passPhrase);
			Blob b = Blob.valueOf(JSON.serializePretty(body));
			Blob encrypted = Crypto.encrypt('AES256', privateKey, IV, b);
			String encryptedBody = EncodingUtil.base64Encode(encrypted);
			return encryptedBody;
		}
		catch(Exception e){
			return '';
		}
    }

    @isTest
    public static void test1(){
        
        CommunityKnowledgeController.BodyType body = getBody();
        CommunityKnowledgeController.ResponseType res = CommunityKnowledgeController.decryptData(getEncryptedBody());
        CommunityKnowledgeController.decryptData('');
        
        system.assert( res.body.filter == body.filter );

       
    }

    @isTest
    public static void test2(){
        
        CommunityKnowledgeController.BodyType body = getBody();
        CommunityKnowledgeController.ResponseType res = new CommunityKnowledgeController.ResponseType();
        res.body = body;
        res.typeRequest = 'filter';
        res.limitData = 1;
        Map<String, Object> mapRes = (Map<String, Object>) JSON.deserializeUntyped(JSON.serializePretty(res));
        res = CommunityKnowledgeController.searchData(mapRes);
        system.assertEquals(1, res.listKnowledge.size());
    }

    @isTest
    public static void test3(){
        
        CommunityKnowledgeController.BodyType body = getBody();
        CommunityKnowledgeController.ResponseType res = new CommunityKnowledgeController.ResponseType();
        res.body = body;
        res.typeRequest = 'filter';
        res.stringToSearch = 'force';
        res.limitData = 20;
        Map<String, Object> mapRes = (Map<String, Object>) JSON.deserializeUntyped(JSON.serializePretty(res));
        
        res = CommunityKnowledgeController.searchData(mapRes);
        
    }

    @isTest
    public static void test4(){
        
        Id kId = [Select id from Knowledge__kav where publishStatus = 'Online' limit 1].Id;
        CommunityKnowledgeController.BodyType body = getBody();
        CommunityKnowledgeController.ResponseType res = new CommunityKnowledgeController.ResponseType();
        res.body = body;
        res.typeRequest = 'filter';
        res.stringToSearch = 'force';
        res.knowledgeId = kId;
        res.limitData = 20;
        Map<String, Object> mapRes = (Map<String, Object>) JSON.deserializeUntyped(JSON.serializePretty(res));
        
        res = CommunityKnowledgeController.searchData(mapRes);
        system.assertEquals(1, res.listKnowledge.size());
    }

    @isTest 
    public static void test6() {
        Id id=[select id from Knowledge__kav limit 1].id;
        Test.startTest();
        Integer res=CommunityKnowledgeController.voteArticle(id,'Thumbs_up');
        Integer res2=CommunityKnowledgeController.voteArticle(id,'Thumbs_down');
        Test.stopTest();
        Assert.areEqual(1, res);
        Assert.areEqual(1, res2);
    }

    @isTest 
    public static void test7() {
        CommunityKnowledgeController.ResponseType res= new CommunityKnowledgeController.ResponseType();
        res.stringToSearch='search';
        res.area='Altro_TP';
        Test.startTest();

        CommunityKnowledgeController.getStandardData(res);
        
        res.category='Commercial_Line';
        CommunityKnowledgeController.getStandardData(res);

        res.stringToSearch='';
        CommunityKnowledgeController.getStandardData(res);
        
        res.category='';
        CommunityKnowledgeController.getStandardData(res);
        
        res.area='';
        CommunityKnowledgeController.getStandardData(res);

        Test.stopTest();
    }

    /*@isTest
    public static void test5(){
        
        Id kId = [Select id from Knowledge__kav where publishStatus = 'Online' limit 1].Id;
        system.assertEquals(1,CommunityKnowledgeController.voteArticle(kid, 'Thumbs_up'));
        system.assertEquals(1,CommunityKnowledgeController.voteArticle(kid, 'Thumbs_down'));

        system.assertEquals(2, [Select id from Article_Feedback__c where Article__c =:kId ].size());
    }
*/
}
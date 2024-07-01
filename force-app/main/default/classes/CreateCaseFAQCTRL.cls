global class CreateCaseFAQCTRL {
    
    public static final String lastPublishedDateDesc = 'lastPublishedDateDesc';
    public static final String rating = 'rating';
    public static final String score = 'score';
    public static final String titleAsc = 'titleAsc';
    public static final String titleDesc = 'titleDesc';
    public static final Map<String,String> orderByMap = new Map<String,String>{lastPublishedDateDesc => 'LastPublishedDate desc',
        titleAsc => 'Title asc',
        titleDesc => 'Title desc',
        score => 'score',
        rating => 'rating'};
            @AuraEnabled
            public static List<knowledge> getArticlesKnowledge(String varToSearch, String orderBy, String ArticleType, String CategoryToSplit){
                system.debug('CategoryToSplit: '+CategoryToSplit);
                List<knowledge> toReturn = new List<knowledge>();
                List<KnowledgeSORT> KnowledgeFiltered;
                Map<String, KnowledgeArticleViewStat> articleViewMap = new Map<String, KnowledgeArticleViewStat>();
                Map<String, KnowledgeArticleVoteStat> articleVoteMap = new Map<String, KnowledgeArticleVoteStat>();

                // LB.
                Map<String, Knowledge__kav> articleValuesMap = new Map<String, Knowledge__kav>();
//                Map<String, Faq__kav> articleValuesMap = new Map<String, Faq__kav>();
                Map<String, String> CatNameCatAPINameMAp = new Map<String, String>();
                List<Modello_di_Assistenza__mdt> mdAssList = [SELECT Id, DeveloperName, Category_Knowledge__c, Category_Knowledge_API__c
                                                              FROM Modello_di_Assistenza__mdt 
                                                              WHERE DeveloperName  LIKE 'Knowledge%'];
                if(!mdAssList.isEmpty())
                {
                    for(Modello_di_Assistenza__mdt mdAss: mdAssList)
                    {
                        if(String.isNotBlank(mdAss.Category_Knowledge__c))
                        {
                            CatNameCatAPINameMAp.put(mdAss.Category_Knowledge__c, mdAss.Category_Knowledge_API__c);
                        }
                    }
                }
                List<KnowledgeArticleVersion> knowledges = new List<KnowledgeArticleVersion>();
                Set<Id> knowledgeArtId = new Set<Id>();
                Set<Id> knowledgeArtVersId = new Set<Id>();

                Id FAQRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('FAQ').getRecordTypeId();

                if(String.isNotBlank(varToSearch))
                {
                    if(varToSearch.length()>=2)
                    {  
                        List<List<SObject>> sObjectListList;
                        String toSearch = String.escapeSingleQuotes(varToSearch);
                        
                        // LB. 
                        String searchquery='FIND \'' + toSearch + '*\' RETURNING KnowledgeArticleVersion '
                                          +' (Id, Title, UrlName, ArticleNumber, KnowledgeArticleId, Summary, LastPublishedDate '
                                          +' WHERE PublishStatus=\'online\' '
                                          +'   AND IsLatestVersion = true '
                                          + '  AND KnowledgeArticleVersion.KnowledgeArticleId ' 
                                          + '   IN (SELECT KnowledgeArticleId ' 
                                          + '       FROM Knowledge__kav ' 
                                          + '       WHERE RecordTypeId = :FAQRecordTypeId)';
                        System.debug('*searchquery '+searchquery);
/*                        String searchquery='FIND \'' + toSearch + '*\' RETURNING KnowledgeArticleVersion '
                            +' (Id, Title, UrlName, ArticleNumber, ArticleType, KnowledgeArticleId, Summary, LastPublishedDate '
                            +' WHERE PublishStatus=\'online\' '
                            +' AND IsLatestVersion = true '
                                            +' AND ArticleType IN (\'FAQ__kav\')';*/
                        
                        if(orderBy != null && String.isNotBlank(orderBy) && orderBy !=''){
                            system.debug('orderBy != null: '+orderBy);
                            if(orderBy == lastPublishedDateDesc || orderBy == titleAsc || orderBy == titleDesc){
                                searchquery += ' ORDER BY '+orderByMap.get(orderBy)+') '; 
                            }
                            else searchquery += ')';
                        } else searchquery += ')';

                        /*searchquery += ' WITH DATA CATEGORY Visibilit__c AT Assistenza_Agenti__c '
                            +' AND Record_Type__c AT Assistenza_Agenti__c ';
                        if(String.isNotBlank(CategoryToSplit) && CatNameCatAPINameMAp.get(CategoryToSplit)!=null)
                        {
                            searchquery += ' AND Categoria__c AT '+CatNameCatAPINameMAp.get(CategoryToSplit);
                        }*/

                        system.debug('+++++searchquery: '+searchquery);
                        sObjectListList = search.query(searchquery);
                        system.debug('articles: '+sObjectListList);
                        knowledges = ((List<KnowledgeArticleVersion>)sObjectListList[0]);
                    }
                }
                else //INIT
                {

                    // LB. 
                  String searchquery= 'SELECT Id, KnowledgeArticleId, Title, UrlName, ArticleNumber, Summary, LastPublishedDate '
                                          + ' FROM KnowledgeArticleVersion ' 
                                          + ' WHERE PublishStatus=\'online\' '
                                          + '   AND IsLatestVersion = true '
                                          + '   AND KnowledgeArticleVersion.KnowledgeArticleId ' 
                                          + '    IN (SELECT KnowledgeArticleId ' 
                                          + '       FROM Knowledge__kav ' 
                                          + '       WHERE RecordTypeId = :FAQRecordTypeId)';
/*                    String searchquery= 'SELECT Id, Title, UrlName, ArticleNumber, ArticleType, KnowledgeArticleId, Summary, LastPublishedDate '
                                        +' FROM KnowledgeArticleVersion '
                                        +' WHERE PublishStatus=\'online\' '
                                        +' AND IsLatestVersion = true '
                                        +' AND ArticleType IN (\'FAQ__kav\')';
                       
                    searchquery += ' WITH DATA CATEGORY Visibilit__c AT Assistenza_Agenti__c '
                        +' AND Record_Type__c AT Assistenza_Agenti__c ';
                    if(String.isNotBlank(CategoryToSplit) && CatNameCatAPINameMAp.get(CategoryToSplit)!=null)
                    {
                        searchquery += ' AND Categoria__c AT '+CatNameCatAPINameMAp.get(CategoryToSplit);
                    }*/
                    if(orderBy != null && String.isNotBlank(orderBy) && orderBy !=''){
                        system.debug('orderBy != null: '+orderBy);
                        if(orderBy == lastPublishedDateDesc || orderBy == titleAsc || orderBy == titleDesc){
                            searchquery += ' ORDER BY '+orderByMap.get(orderBy); 
                        }
                    }
                    system.debug('+++++searchquery: '+searchquery);
                    knowledges = Database.query(searchquery);
                    system.debug('articles: '+knowledges);
                
                }
                for(KnowledgeArticleVersion article : knowledges)
                {
                    knowledgeArtId.add(article.KnowledgeArticleId);
                    knowledgeArtVersId.add(article.Id);
                }
                List<KnowledgeArticleViewStat> viewStatList = [SELECT Id, NormalizedScore, ViewCount, ParentId 
                                                               FROM KnowledgeArticleViewStat
                                                               WHERE ParentId IN:knowledgeArtId
                                                               AND Channel = 'AllChannels' ];
                List<KnowledgeArticleVoteStat> voteStatList = [SELECT Id, NormalizedScore, ParentId 
                                                               FROM KnowledgeArticleVoteStat
                                                               WHERE ParentId IN:knowledgeArtId
                                                               AND Channel ='AllChannels'];
                
                // LB. FROM Knowledge__kav
                List<Knowledge__kav> faqList = [SELECT Id, FAQ_Domanda__c, FAQ_Risposta__c, KnowledgeArticleId
                                          FROM Knowledge__kav
                                          WHERE Id IN:knowledgeArtVersId];
/*                List<FAQ__kav> faqList = [SELECT Id, Domanda__c, Risposta__c, KnowledgeArticleId
                                          FROM FAQ__kav
                                          WHERE Id IN:knowledgeArtVersId];*/

                for(KnowledgeArticleViewStat statist : viewStatList){
                    articleViewMap.put(statist.ParentId, statist);
                }
                for(KnowledgeArticleVoteStat statist : voteStatList){
                    articleVoteMap.put(statist.ParentId, statist);
                }

                // LB.
                for(Knowledge__kav faq : faqList){
                    articleValuesMap.put(faq.KnowledgeArticleId, faq);
                }
/*                for(FAQ__kav faq : faqList){
                    articleValuesMap.put(faq.KnowledgeArticleId, faq);
                }*/

                
                ArticleType = 'FAQ';  // sempre FAQ
                Map<string,sObject> KnowArticleIdCategoryMAP = new Map<string,sObject>();
                if(String.isNotBlank(ArticleType))
                {
                    List<sObject> categoryList = new List<sObject>();
                    // LB.
                    String queryCategory = 'SELECT Id, DataCategoryName, ParentId '
                                            +'FROM Knowledge__DataCategorySelection '
                                            +'WHERE ParentId IN: knowledgeArtVersId ';
/*                    String queryCategory = 'SELECT Id, DataCategoryName, ParentId '
                        +'FROM '+ArticleType+'__DataCategorySelection '
                                            +'WHERE ParentId IN: knowledgeArtVersId ';*/
                    categoryList = database.query(queryCategory);
                    if(!categoryList.isEmpty())    //consente di aggiungere dei tag nel component.
                    {
                        for(sObject so:categoryList)
                        {
                            KnowArticleIdCategoryMAP.put((String)so.get('ParentId'), so);
                        }
                        system.debug('KnowArticleIdCategoryMAP: '+KnowArticleIdCategoryMAP);
                    }
                }
                KnowledgeFiltered = new List<KnowledgeSORT>();
                for(KnowledgeArticleVersion article : knowledges)
                {
                    String artType;
                    String artLastPubDate;

                    // LB. 
                    artType = 'Knowledge';
                    /*if(String.isNotBlank(article.ArticleType))
                    {
                        artType = article.ArticleType;
                        if(artType.indexOf('__kav')!=-1)
                            artType = artType.replace('__kav','');
                    }*/


                    if(String.isNotBlank(String.valueOf(article.LastPublishedDate)))
                    {
                        /*artLastPubDate = String.valueOf(article.LastPublishedDate);
artLastPubDate = artLastPubDate.substring(0,10);*/
                        artLastPubDate = article.LastPublishedDate.format('dd-MM-yyyy');
                    }
                    knowledge knldg = new knowledge();
                    knldg.idArtVers = article.Id;
                    knldg.UrlName = article.UrlName;
                    knldg.idKnowArt = article.KnowledgeArticleId;
                    knldg.title = article.Title;
                    knldg.articleNumber = article.ArticleNumber;
                    knldg.articleType = ((String.isNotBlank(artType))?artType:'');
                    knldg.lastPublishedDate = ((String.isNotBlank(artLastPubDate))?artLastPubDate:'');
                    knldg.summary = article.Summary;
                    if(KnowArticleIdCategoryMAP.get(article.Id)!=null){
                        if((String)KnowArticleIdCategoryMAP.get(article.Id).get('DataCategoryName')!=null){
                            knldg.categoryGroup = (((String)KnowArticleIdCategoryMAP.get(article.Id).get('DataCategoryName')).indexOf('_')!=-1)?((String)KnowArticleIdCategoryMAP.get(article.Id).get('DataCategoryName')).replace('_',' '):(String)KnowArticleIdCategoryMAP.get(article.Id).get('DataCategoryName');
                            /*if(knldg.categoryTags== null)
{
knldg.categoryTags = new List<String>{ (String)KnowArticleIdCategoryMAP.get(article.Id).get('DataCategoryName')};
}
else{
knldg.categoryTags.add((String)KnowArticleIdCategoryMAP.get(article.Id).get('DataCategoryName'));
}
*/ //consente di aggiungere dei tag nel component.
                        }
                    }
                    if(articleViewMap.get(article.KnowledgeArticleId)!=null){
                        if(articleViewMap.get(article.KnowledgeArticleId).NormalizedScore!=null){
                            knldg.score = articleViewMap.get(article.KnowledgeArticleId).NormalizedScore;
                        }
                    }
                    if(articleVoteMap.get(article.KnowledgeArticleId)!=null){
                        if(articleVoteMap.get(article.KnowledgeArticleId).NormalizedScore!=null){
                            knldg.rating = articleVoteMap.get(article.KnowledgeArticleId).NormalizedScore;
                            knldg.nStars = '/img/samples/stars_'+Integer.valueOf(knldg.rating)+'00.gif';
                        }
                    }
                    if(articleValuesMap.get(article.KnowledgeArticleId)!=null){
                        knldg.question = articleValuesMap.get(article.KnowledgeArticleId).FAQ_Domanda__c;
                        knldg.shortQuestion = knldg.question != null && knldg.question.length() > 150 ? knldg.question.abbreviate(150) : knldg.question;
                    }
                    if(articleValuesMap.get(article.KnowledgeArticleId)!=null){
                        knldg.answer = articleValuesMap.get(article.KnowledgeArticleId).FAQ_Risposta__c;
                        knldg.shortAnswer = knldg.answer != null && knldg.answer.length() > 150 ? knldg.answer.abbreviate(150) : knldg.answer;
                    }

                    KnowledgeFiltered.add(new KnowledgeSORT(knldg,orderByMap.get(orderBy)));
                    
                }
                if(orderBy != null && String.isNotBlank(orderBy)){
                    if(orderBy == rating || orderBy == score){
                        system.debug('sort');
                        if(!KnowledgeFiltered.isEmpty())
                        {
                            KnowledgeFiltered.sort();
                        }
                    }
                }
                
                if(KnowledgeFiltered!=null){
                    if(!KnowledgeFiltered.isEmpty()){
                        for(knowledgeSORT know :KnowledgeFiltered){
                            toReturn.add(know.k);
                        }
                    }
                    
                }
                
                
                return toReturn;
            }
    
    public Class knowledge{
        @AuraEnabled public String idArtVers;
        @AuraEnabled public String idKnowArt;
        @AuraEnabled public String title;
        @AuraEnabled public String articleNumber;
        @AuraEnabled public String articleType;
        @AuraEnabled public String categoryGroup;
        @AuraEnabled public String UrlName;
        @AuraEnabled public String summary;
        @AuraEnabled public Decimal score;
        @AuraEnabled public String nStars;
        @AuraEnabled public Decimal rating;
        @AuraEnabled public String lastPublishedDate;
        @AuraEnabled public String[] categoryTags;
        @AuraEnabled public String question;
        @AuraEnabled public String answer;
        @AuraEnabled public String shortQuestion;
        @AuraEnabled public String shortAnswer;
        
        public knowledge(){}
    }
    
    
    //SORT
    global class KnowledgeSORT implements Comparable {
        @AuraEnabled public knowledge k; 
        public String orderby_field;
        
        public KnowledgeSORT(knowledge kno, String orderby_f) {
            k = kno;
            orderby_field = orderby_f;
        }
        
        global Integer compareTo(Object compareTo) {
            KnowledgeSORT compareToKnow = (KnowledgeSORT)compareTo;
            
            Integer returnValue = 0;
            system.debug('orderby_field: '+orderby_field);
            if (orderby_field == 'score' ) 
            {
                if (k.score > compareToKnow.k.score) {
                    returnValue = -1;
                } else if (k.score < compareToKnow.k.score) {
                    returnValue = 1;
                }
            } 
            else if (orderby_field == 'rating' ) 
            {
                if (k.rating > compareToKnow.k.rating) {
                    returnValue = -1;
                } else if (k.rating < compareToKnow.k.rating) {
                    returnValue = 1;
                }
            } 
            return returnValue;   
        }
    }
    
}
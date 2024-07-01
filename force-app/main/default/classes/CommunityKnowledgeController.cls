public without sharing class CommunityKnowledgeController {

	private static String queryBaseSuggest = 'FIND \'stringToSearch\' Returning Knowledge__kav (Id, Title, FAQ_Domanda__c ,FAQ_Risposta__c, Count_Feedback_Negativi__c, Count_Feedback_Positivi__c WHERE publishStatus = \'Online\' AND Recordtype.developerName = \'FAQ_Agenti\' AND language = \'it\' AND Title like \'%stringToSearch%\') WITH DATA CATEGORY Record_Type__c at {recType}__c and Processo__c at {processo}__c';
	private static String queryBaseSearch = 'FIND {stringToSearch}  Returning Knowledge__kav (Id, Title, FAQ_Domanda__c ,FAQ_Risposta__c, Count_Feedback_Negativi__c, Count_Feedback_Positivi__c WHERE publishStatus = \'Online\' AND Recordtype.developerName = \'FAQ_Agenti\' AND language = \'it\') WITH DATA CATEGORY Record_Type__c at {recType}__c and Processo__c at {processo}__c';

	public class ResponseType{
		@AuraEnabled public String typeRequest = 'filter|standard';
		@AuraEnabled public Integer limitData = 0;
		@AuraEnabled public String stringToSearch;
		@AuraEnabled public String knowledgeId;
		@AuraEnabled public String area;
		@AuraEnabled public String category;
		@AuraEnabled public String accountId;
		@AuraEnabled public String insuranceContactId;
		@AuraEnabled public List<Knowledge__kav> listKnowledge;
		@AuraEnabled public Knowledge__kav selectKnowledge;
		@AuraEnabled public Boolean isSuccess;
		@AuraEnabled public String errorMessage;
		@AuraEnabled public BodyType body;
	}

	public class BodyType{
		@AuraEnabled public String ndg;
		@AuraEnabled public String polizza;
		@AuraEnabled public String proposta;
		@AuraEnabled public String denominazione;
		@AuraEnabled public String cf_piva;
		@AuraEnabled public String codiceagenzia;
		@AuraEnabled public String filter;
		@AuraEnabled public String recordtype;
		@AuraEnabled public String processo;
	}

	@AuraEnabled
    public static ResponseType decryptData(String body){
		ResponseType response = new ResponseType();
		try{
			Crypto_Values__mdt val = [Select Init_Vector__c, Key__c from Crypto_Values__mdt where developerName = 'Wizard_CL'];
			Blob passPhrase = Blob.valueOf(val.Key__c);
			Blob IV = Blob.valueOf(val.Init_Vector__c);
			Blob privateKey = Crypto.generateDigest('SHA-256',passPhrase);
			Blob b = EncodingUtil.base64Decode(body);
			Blob decrypted = Crypto.decrypt('AES256', privateKey, IV, b);
			response.body = (BodyType) JSON.deserialize(decrypted.toString(), BodyType.class);
			response.isSuccess = true;
		}
		catch(Exception e){
			response.isSuccess = false;
			response.errorMessage = e.getMessage();
		}
		/*response.body = new BodyType();
		response.body.recordtype = 'Assistenza_Agenti';
		response.body.filter = 'Processo:Commercial_Lines-Processo:New_Business-Argomento:Liability_Non_Standard-(Argomento:7E58|Argomento:Prodotto_Generico)-Record_Type:FAQ_Statica-Record_Type:Assistenza_Agenti';
		response.body.processo = 'Commercial_Lines';
		response.area = 'Commercial_Lines';*/

        return response;
    }


	@AuraEnabled
	public static Integer voteArticle(String articleId, String vote){
		RecordType rtTask = [select Id , DeveloperName from RecordType where Name ='ArticleFeedbackTask' limit 1];
		Integer toRet;
		if(vote == 'Thumbs_up')
			toRet = (Integer) [Select Count_Feedback_Positivi__c from Knowledge__kav where id =: articleId limit 1].Count_Feedback_Positivi__c;
		else
			toRet = (Integer) [Select Count_Feedback_Negativi__c from Knowledge__kav where id =: articleId limit 1].Count_Feedback_Negativi__c;
	
		Task feedToCreate = new Task();
		feedToCreate.TECH_ArticleVersionId__c = articleId;
	    feedToCreate.TECH_ArticleFeedbackSource__c = 'Community';
	    feedToCreate.TECH_ArticleFeedbackVote__c = vote;		
		feedToCreate.RecordTypeId = rtTask.Id;
		
		try{
			insert feedToCreate;
			return toRet+1;

		}
		catch(Exception ex){
			ApplicationLogHelper.ERROR('CommunityKnowledgeController: Vote', ex.getMessage(), ex.getStackTraceString());
		}
		return toRet;
	}

    //query for connected callback
    @AuraEnabled
    public static ResponseType searchData(Map<String,Object> dataMap){
		ResponseType data = (ResponseType)JSON.deserialize(JSON.serialize(dataMap), ResponseType.class);
        //string inVar = :stringToSearch;
       //string tempInput = '%' + inVar + '%';
        //List<Contact> lst = [Select Id , FirstName, LastName from Contact where lastname like  : tempInput ];
        List<Knowledge__kav> content; /*= [
            SELECT Id, Title, FAQ_Domanda__c, FAQ_Risposta__c, Count_Feedback_Negativi__c, Count_Feedback_Positivi__c
            FROM Knowledge__kav
            //WHERE Title like :tempInput
        ];*/

		if(data.typeRequest == 'filter'){
			if(data.knowledgeId != null && !String.isEmpty(data.knowledgeId)){
				system.debug(data.knowledgeId);
				content = [SELECT Id, Title, FAQ_Domanda__c, FAQ_Risposta__c, Count_Feedback_Negativi__c, Count_Feedback_Positivi__c
				FROM Knowledge__kav where id = : data.knowledgeId limit 1];

				System.debug('articles: ' + content);
			}
			else if(data.stringToSearch != null && !String.isEmpty(data.stringToSearch)){
				content = getDataByKeyWord(data);
			}
			else
				content = getDataByFilterString(data);
		}
		else if(data.typeRequest == 'standard'){
			try{
				
			content = getStandardData(data);

			}catch(Exception error){
				System.debug('Exception - '+error.getStackTraceString());
			}
		
		}


		data.listKnowledge = content;
		system.debug(data);
		if(data.knowledgeId != null && !String.isEmpty(data.knowledgeId)){
			data.selectKnowledge = content[0];
		}

        return data;
    }

	private class FilterWrapper {
		public Map<String, List<String>> andConditions = new Map<String, List<String>>();
		public Map<String, List<String>> orConditions = new Map<String, List<String>>();
	}

	private static boolean containsAll(List<String> l1, List<String> l2){
		for(String s : l2){
			if(!l1.contains(s))
				return false;
		}
		return true;
	}
	private static boolean containsAny(List<String> l1, List<String> l2){
		for(String s : l2){
			if(l1.contains(s))
				return true;
		}
		return false;
	}

	private static FilterWrapper mapFilters(String filters){
		FilterWrapper toRet = new FilterWrapper();
		List<String> tokens = filters.split('-');
		for(String tkn : tokens){
			if(tkn.contains('(') && tkn.contains(')')){
				List<String> internalTkns = tkn.substringAfter('(').substringBefore(')').split('\\|');
				for(String itkn : internalTkns){
                    
					List<String> cond = itkn.split(':');
					if(cond.size()==2){
						if(toRet.orConditions.containsKey(cond[0])){
							toRet.orConditions.get(cond[0]).add(checkValue(cond[1]));
						}
						else{
							List<String> temp = new List<String>();
							temp.add(checkValue(cond[1]));
							toRet.orConditions.put(cond[0], temp);
						}
					}
					
				}
			}
			else{
				List<String> cond = tkn.split(':');
				if(cond.size()==2){
					if(toRet.andConditions.containsKey(cond[0])){
						toRet.andConditions.get(cond[0]).add(checkValue(cond[1]));
					}
					else{
						List<String> temp = new List<String>();
						temp.add(checkValue(cond[1]));
						toRet.andConditions.put(cond[0], temp);
					}
				}
			
			}
		}
		return toRet;

	}


	private static map<Id, map<String, List<String>>> parseDataMapping(List<Knowledge__DataCategorySelection> l){
		Map<Id, map<String, List<String>>> toRet = new Map<Id, map<String, List<String>>>();
		for(Knowledge__DataCategorySelection kdc : l){
			if(toRet.containsKey(kdc.parentId)){
				Map<String, List<String>> groups = toRet.get(kdc.parentId);
				if(groups != null){
					if(groups.containsKey(kdc.DataCategoryGroupName)){
						groups.get(kdc.DataCategoryGroupName).add(kdc.DataCategoryName);
					}
					else{
						List<String> temp = new List<String>();
						temp.add(kdc.DataCategoryName);
						groups.put(kdc.DataCategoryGroupName, temp);
					}
				}
				else{
					groups = new Map<String, List<String>>();
					List<String> temp = new List<String>();
					temp.add(kdc.DataCategoryName);
					groups.put(kdc.DataCategoryGroupName, temp);
					groups.put(kdc.DataCategoryGroupName, temp);
					toRet.put(kdc.parentId, groups);
				}
			}
			else{
				Map<String, List<String>> groups = new Map<String, List<String>>();
				List<String> temp = new List<String>();
				temp.add(kdc.DataCategoryName);
				groups.put(kdc.DataCategoryGroupName, temp);
				groups.put(kdc.DataCategoryGroupName, temp);
				toRet.put(kdc.parentId, groups);
			}
		}
		return toRet;
	}


	private static List<Knowledge__kav> getDataByKeyWord(ResponseType data){

		String stringToSearch = data.stringToSearch;
		String recType = data.body.recordtype;
		String processo = data.body.processo;
		String queryBase = data.limitData == 3 ? queryBaseSuggest : queryBaseSearch;

		String query = queryBase.replace('stringToSearch', stringToSearch);
		query = query.replace('{recType}', recType);
		query = query.replace('{processo}', processo);
		if(data.limitData != null && data.limitData != 0){
			query += ' LIMIT '+data.limitData;
		}
		List<List<SObject>> results = search.query(query);
    	List<Knowledge__kav>articleList = ((List<Knowledge__kav>) results[0]);
		return articleList;

	}
		@TestVisible
        private static List<Knowledge__kav> getStandardData(ResponseType data){
			String area = data.area!=null? data.area.replaceAll('[^a-zA-Z0-9_]', ''):null, category= data.category!=null? data.category.replaceAll('[^a-zA-Z0-9_]', ''):null;
		List<Knowledge__kav> toRet = new List<Knowledge__kav>();
			if(String.isNotBlank(area) && String.isNotBlank(category) && String.isNotBlank(data.stringToSearch)){
			try {
				String query = 'FIND \''+ data.stringToSearch + '\' Returning Knowledge__kav'+
				' (Id, Title, FAQ_Domanda__c ,FAQ_Risposta__c, Count_Feedback_Negativi__c, Count_Feedback_Positivi__c '+
				'WHERE publishStatus = \'Online\' AND Recordtype.developerName = \'FAQ_Agenti\' AND language = \'it\') WITH DATA CATEGORY '+
					'Processo__c AT ' + area + '__c AND Argomento__c AT ' + category + '__c';
				List<List<SObject>> results = search.query(query);
				toRet = ((List<Knowledge__kav>)results[0]);
			} catch (Exception err) {
				String query = 'FIND \''+ data.stringToSearch + '\' Returning Knowledge__kav'+
				' (Id, Title, FAQ_Domanda__c ,FAQ_Risposta__c, Count_Feedback_Negativi__c, Count_Feedback_Positivi__c '+
				'WHERE publishStatus = \'Online\' AND Recordtype.developerName = \'FAQ_Agenti\' AND language = \'it\') WITH DATA CATEGORY '+
					'Processo__c AT ' + area + '__c';
				List<List<SObject>> results = search.query(query);
				toRet = ((List<Knowledge__kav>)results[0]);
			}

			}else if(String.isNotBlank(area) && String.isNotBlank(data.stringToSearch)){
		
				String query = 'FIND \''+ data.stringToSearch + '\' Returning Knowledge__kav'+
				' (Id, Title, FAQ_Domanda__c ,FAQ_Risposta__c, Count_Feedback_Negativi__c, Count_Feedback_Positivi__c '+
				'WHERE publishStatus = \'Online\' AND Recordtype.developerName = \'FAQ_Agenti\' AND language = \'it\') WITH DATA CATEGORY '+
					'Processo__c AT ' + area + '__c' ;
				List<List<SObject>> results = search.query(query);
				toRet = ((List<Knowledge__kav>)results[0]);
		
		}
			else if(String.isNotBlank(area) && String.isNotBlank(category)){
			try {
				String query = 'SELECT Id, Title, FAQ_Domanda__c ,FAQ_Risposta__c, Count_Feedback_Negativi__c, Count_Feedback_Positivi__c '+
				'FROM Knowledge__kav '+
				' WHERE publishStatus = \'Online\' AND Recordtype.developerName = \'FAQ_Agenti\' AND language = \'it\' '+
				' WITH DATA CATEGORY '+
					'Processo__c AT ' + area + '__c AND Argomento__c AT ' + category + '__c';
				toRet = ((List<Knowledge__kav>) Database.query(query));
			} catch (Exception err) {
				String query = 'SELECT Id, Title, FAQ_Domanda__c ,FAQ_Risposta__c, Count_Feedback_Negativi__c, Count_Feedback_Positivi__c '+
				'FROM Knowledge__kav '+
				' WHERE publishStatus = \'Online\' AND Recordtype.developerName = \'FAQ_Agenti\' AND language = \'it\' '+
				' WITH DATA CATEGORY '+
					'Processo__c AT ' + area + '__c';
				toRet = ((List<Knowledge__kav>) Database.query(query));
			}

		}
			else if(String.isNotBlank(area) && String.isNotBlank(category)){
			try {
				String query = 'SELECT Id, Title, FAQ_Domanda__c ,FAQ_Risposta__c, Count_Feedback_Negativi__c, Count_Feedback_Positivi__c '+
				'FROM Knowledge__kav '+
				' WHERE publishStatus = \'Online\' AND Recordtype.developerName = \'FAQ_Agenti\' AND language = \'it\' '+
				' WITH DATA CATEGORY '+
					'Processo__c AT ' + area + '__c AND Argomento__c AT ' + category + '__c';
				toRet = ((List<Knowledge__kav>) Database.query(query));
			} catch (Exception err) {
				String query = 'SELECT Id, Title, FAQ_Domanda__c ,FAQ_Risposta__c, Count_Feedback_Negativi__c, Count_Feedback_Positivi__c '+
				'FROM Knowledge__kav '+
				' WHERE publishStatus = \'Online\' AND Recordtype.developerName = \'FAQ_Agenti\' AND language = \'it\' '+
				' WITH DATA CATEGORY '+
					'Processo__c AT ' + area + '__c';
				toRet = ((List<Knowledge__kav>) Database.query(query));
			}

		}
			else if(String.isNotBlank(area)){
			String query = 'SELECT Id, Title, FAQ_Domanda__c ,FAQ_Risposta__c, Count_Feedback_Negativi__c, Count_Feedback_Positivi__c '+
			'FROM Knowledge__kav '+
			'WHERE publishStatus = \'Online\' AND Recordtype.developerName = \'FAQ_Agenti\' AND language = \'it\' '+
			'WITH DATA CATEGORY '+
				'Processo__c AT ' + area + '__c';
			toRet = ((List<Knowledge__kav>) Database.query(query));
		}else{
			String query = 'FIND \''+ data.stringToSearch + '\' Returning Knowledge__kav'+
			' (Id, Title, FAQ_Domanda__c ,FAQ_Risposta__c, Count_Feedback_Negativi__c, Count_Feedback_Positivi__c '+
			'WHERE publishStatus = \'Online\' AND Recordtype.developerName = \'FAQ_Agenti\' AND language = \'it\')';
			List<List<SObject>> results = search.query(query);
			toRet = ((List<Knowledge__kav>)results[0]);
		}


		
		return toRet;

	}

	private static List<Knowledge__kav> getDataByFilterString(ResponseType data){
		FilterWrapper fw = mapFilters(data.body.filter);
			List<Knowledge__DataCategorySelection> Articles_category = [Select Id, ParentId, DataCategoryGroupName, DataCategoryName, CreatedDate, CreatedById, IsDeleted, SystemModstamp, Parent.PublishStatus
																		from Knowledge__DataCategorySelection
																		where Parent.PublishStatus = 'Online' AND Parent.recordtype.developername ='FAQ_Agenti' AND parent.language = 'it'];
			Map<Id, Map<String,List<String>>> article_category_map = parseDataMapping(Articles_category);

			Set<Id> idtoquery = new Set<ID>();
			for(Id i : article_category_map.keySet()){
				boolean add = true;
				Map<String, List<String>> temp = article_category_map.get(i);
				for(String groupName : fw.andConditions.keySet()){
					if(temp.containsKey(groupName)){
						if(!containsAll(temp.get(groupName), fw.andConditions.get(groupName))){
							add = false;
						}
					}
					else{
						add = false;
					}
				}
				if(add){
					for(String groupName : fw.orConditions.keySet()){
						if(temp.containsKey(groupName)){
							if(!containsAny(temp.get(groupName), fw.orConditions.get(groupName))){
								add = false;
							}
						}
						else{
							add = false;
						}
					}
				}
				if(add){
					idtoquery.add(i);
				}
			}

			if(data.limitData != null && data.limitData != 0)
				return [
					SELECT Id, Title, FAQ_Domanda__c, FAQ_Risposta__c, Count_Feedback_Negativi__c, Count_Feedback_Positivi__c
					FROM Knowledge__kav
					WHERE id in:idtoquery
					LIMIT :data.limitData
				];
			else
				return [
					SELECT Id, Title, FAQ_Domanda__c, FAQ_Risposta__c, Count_Feedback_Negativi__c, Count_Feedback_Positivi__c
					FROM Knowledge__kav
					WHERE id in:idtoquery
				];
	}
	
	


	//checks if the string starts with a digit, and in case adds an X as first char
	private static String checkValue(String val){
		
		return (val.left(1).isNumeric() ? 'X':'' ) + val;
		
	}

}
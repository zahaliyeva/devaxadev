/*------------------------------------------------------------------------------------------
Author:        Orlando Aversano
Company:       Deloitte
Class:         VFC30_NewQuestionarioCAICTRL
Description:   Apex class used to execute all the logics internal to the 
VISUALFORCE PAGE VFP30_NewQuestionarioCAI related to Caring Angel

History

9/10/2018     Created 
-------------------------------------------------------------------------------------------*/
public class VFC30_NewQuestionarioCAICTRL {
    
    
    public String TypeOfQuestionnary{get;set;}//MOSCATELLI_M 13/03/2019: Axa Assistance

    public VFC30_NewQuestionarioCAICTRL(ApexPages.StandardController stdController) 
    {
        //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
        String IdRecord = '';
        String CaseRT = '';
        
        if(ApexPages.currentPage().getParameters().containsKey('caseId'))
            IdRecord = ApexPages.currentPage().getParameters().get('caseId');
        else if(ApexPages.currentPage().getParameters().containsKey('id'))
            IdRecord = (ApexPages.currentPage().getParameters().get('id'));
        else if(ApexPages.currentPage().getParameters().containsKey('retURL'))
        {
            /*if(ApexPages.currentPage().getParameters().get('retURL').indexOf('%2F')<>-1)
                IdRecord = (ApexPages.currentPage().getParameters().get('retURL')).subStringAfter('%2F');
            else
                IdRecord = (ApexPages.currentPage().getParameters().get('retURL')).subStringAfter('/');*/
            if(ApexPages.currentPage().getParameters().get('retURL').startsWithIgnoreCase('%2F'))
                IdRecord = (ApexPages.currentPage().getParameters().get('retURL')).substring(3, 18);
            else if(ApexPages.currentPage().getParameters().get('retURL').startsWithIgnoreCase('/'))
                IdRecord = (ApexPages.currentPage().getParameters().get('retURL')).substring(1, 16);
            else if(ApexPages.currentPage().getParameters().get('retURL').startsWithIgnoreCase('500'))
                IdRecord = (ApexPages.currentPage().getParameters().get('retURL')).substring(0, 15);
        }
        system.debug('getParameters: '+ApexPages.currentPage().getParameters());
        system.debug('IdRecord: '+IdRecord);

        if(String.isNotBlank(IdRecord) && !IdRecord.startsWith('500'))
        {
            CaseRT = [Select Case__r.RecordTypeId from Questionario_CA__c where id=:IdRecord].Case__r.RecordTypeId;

        }
        else if(String.isNotBlank(IdRecord) && IdRecord.startsWith('500'))
            CaseRT = [Select RecordTypeId from Case where Id=:IdRecord].RecordTypeId;
        
        Schema.DescribeSObjectResult CasOb = Schema.SObjectType.Case; 
        Map<Id,Schema.RecordTypeInfo> rtMapById = CasOb.getRecordTypeInfosById();
        Schema.RecordTypeInfo rtById =  rtMapById.get(CaseRT);           

        if(rtById.getName() == 'Sinistri Danni Banca' ||
            rtById.getName() == 'Sinistri AAI')
            TypeOfQuestionnary='c:ReducedQuestionario';
        else if(rtById.getName() == 'AXA Caring Salute'){
            TypeOfQuestionnary='c:ReducedQuestionarioCaringSalute';
        }
        else if(rtById.getName() == 'Caring Angel Property'){
            TypeOfQuestionnary='c:ReducedQuestionarioCaringProperty';
        }
        else
            TypeOfQuestionnary = 'c:NewQuestionarioCAI';
        //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
    }
    
    public class WrapperClass{
        @AuraEnabled public Map<String, List<String>> pickValues;
        @AuraEnabled public Account cliente;
        @AuraEnabled public String idCase;
        @AuraEnabled public String persona;
        @AuraEnabled public String response;
        @AuraEnabled public String profileName;
        @AuraEnabled public String userRole;
        @AuraEnabled public Questionario_CA__c questionario;
        public WrapperClass(){}
    }
    
    
    @AuraEnabled
    public static WrapperClass initializeCaCTRL(String accountId, sObject pickObj, List<String> pickFields, String method, Map<String, String> parameterMap, String questionarioCAid, String caseId) {
        WrapperClass toReturn = new WrapperClass();
        User currentUser = [Select Profile.Name, UserRole.Name from User where id = :Userinfo.getUserId() ]; // NOPMD  Fix CRUD violation
        toReturn.profileName = currentUser.Profile.Name;
        toReturn.userRole = currentUser.UserRole.Name;
        system.debug('objObject --->' + pickObj);
        system.debug('flds --->' + pickFields);
        system.debug('accountId --->' + accountId);
        if(pickObj!=null && !pickFields.isEmpty())
        {
            Map<String, List<String>> picklistMap = new Map<String, List<String>>();
            Schema.sObjectType objType = pickObj.getSObjectType();
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            for(String field:pickFields)
            {
                List<String> allOpts = new List<String>();
                List<Schema.PicklistEntry> values = fieldMap.get(field).getDescribe().getPickListValues();
                for (Schema.PicklistEntry a: values) 
                {
                    allOpts.add(a.getValue());
                }
                system.debug('allOpts ---->' + allOpts);
                //allOpts.sort();
                picklistMap.put(field,allOpts);
            }
            
            toReturn.pickValues = picklistMap;
        }

        Case CurrentCase = new Case();

        if(String.isNotBlank(CaseId) && String.isBlank(accountId))
        {
            CurrentCase = [Select AccountId from Case where id=:CaseId]; // NOPMD  Fix CRUD

            if(String.isNotBlank(CurrentCase.AccountId))
                accountId = CurrentCase.AccountId;
        }

        if(String.isNotBlank(method) && method =='insert')
        {
            if(String.isNotBlank(accountId))
            {
                List<Account> clienteCA = [SELECT Id, FirstName, LastName, Name, PersonBirthdate, Codice_fiscale_ListView__c,  // NOPMD  Fix CRUD
                                           CIF_Personalemail__c, CIF_PersonEmail__c, CIF_Work_Email__c,
                                           PersonMailingStreet, PersonMailingCity, PersonMailingState, PersonMailingPostalCode, PersonMailingCountry,
                                           BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, RecordType.Name,
                                           CIF_Phone__c, PersonHomePhone, Phone,Email_ListView__c,Partita_IVA__c,AAI_Partita_IVA__c, Additional_Email__c,Telefono_cellulare_ListView__c //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I 
                                           FROM Account WHERE Id =:accountId LIMIT 1];
                
                if(!clienteCA.isEmpty())
                {
                    if(clienteCA[0].RecordType.Name == 'B2B Client' || clienteCA[0].RecordType.Name == 'Corporate')
                        toReturn.persona = 'giuridica';
                    else if(clienteCA[0].RecordType.Name == 'B2C Client' || clienteCA[0].RecordType.Name == 'Individual')
                        toReturn.persona = 'fisica';
                    toReturn.cliente = clienteCA[0];
                }
            }

            /*   Case Insert in vfc06
        Case caseToInsert = new Case();
        caseToInsert.Origin = AP_Constants.caseOriginPhone;
        caseToInsert.Complainant__c = 'Customer';
        caseToInsert.RecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseCaringAngel).getRecordTypeId(); 
        caseToInsert.Status = AP_Constants.caseStatusAssigned;
        if(!parameterMap.isEmpty())
        {
        if(parameterMap.containsKey('lob')) caseToInsert.LOB__c = parameterMap.get('lob');
        if(parameterMap.containsKey('category')) caseToInsert.Category__c = parameterMap.get('category');
        if(parameterMap.containsKey('subcategory')) caseToInsert.SubCategory__c = parameterMap.get('subcategory');
        }
        if(String.isNotBlank(accountId))
        {
        caseToInsert.AccountId = accountId;
        }
        try{
        insert caseToInsert;
        toReturn.idCase = caseToInsert.Id;
        }
        catch(exception ex)
        {
        system.debug(ex);
        toReturn.response = 'KO|Fallito'+ex.getMessage();
        }
        */
        }
        else if(String.isNotBlank(method) && method =='update')
        {
            if(String.isNotBlank(questionarioCAid))
            {
                //Bonifazi Giorgio 19/07/2019: Caring Angel Fase 2 - START
                List<Questionario_CA__c> questionarioList = [SELECT Id,  Name, Case__c, Claim_Id__c, Contraente__c,  Contraente__r.Codice_fiscale_ListView__c, Conducente__c,  // NOPMD  Fix CRUD
                                                             Nome_contraente__c, Nome_conducente__c, Cognome_Contraente__c,Indirizzo_Evento__c,//ZA prometeo 145 
                                                             Cognome_Conducente__c, Data_di_nascita_contraente__c, 
                                                             Data_di_nascita_conducente__c, Codice_fiscale_contraente__c, 
                                                             Codice_fiscale_conducente__c, Email_Contraente__c, Email_conducente__c, 
                                                             Targa__c, Compagnia__c, Conducente_contraente__c, Numero_Polizza__c, 
                                                             Id_Polizza__c, Cliente_GOLD__c, Categoria_Polizza__c, Decorrenza_Polizza__c, 
                                                             Scadenza_Polizza__c, Prodotto_Polizza__c, Stato_polizza__c, Marca_Veicolo__c, 
                                                             Tipo_Veicolo__c, Data_Evento__c, Luogo_Evento__c, Ora_Evento__c, 
                                                             Descrizione_dinamica__c, Telefono__c, Email__c, Numero_chiamante__c, 
                                                             Feriti__c, Ambulanza__c, Autorit__c, Carro__c, Indirizzo_Contraente__c, 
                                                             Indirizzo_Conducente__c, Indirizzo_Controparte__c, 
                                                             Indirizzo_Domicilio_Conducente__c, Indirizzo_Domicilio_Contraente__c, 
                                                             Indirizzo_Domicilio_Controparte__c, Citt_Conducente__c, Citt_Contraente__c, 
                                                             Citt_Controparte__c, Citt_Domicilio_Conducente__c, Citt_Domicilio_Controparte__c, 
                                                             Citt_Domicilio_Contraente__c, Provincia_Contraente__c, Provincia_Conducente__c, 
                                                             Provincia_Controparte__c, Provincia_Domicilio_Conducente__c, 
                                                             Provincia_Domicilio_Controparte__c, Provincia_Domicilio_Contraente__c, 
                                                             CAP_Conducente__c, CAP_Contraente__c, CAP_Controparte__c, 
                                                             CAP_Domicilio_Conducente__c, CAP_Domicilio_Controparte__c, 
                                                             CAP_Domicilio_Contraente__c, Stato_Contraente__c, Stato_Conducente__c, 
                                                             Stato_Controparte__c, Stato_Domicilio_Contraente__c, 
                                                             Stato_Domicilio_Controparte__c, Stato_Domicilio_Conducente__c, 
                                                             Tipo_controparte__c, Note_ambulanza__c, Note_autorit__c, Note_carroattrezzi__c, 
                                                             Targa_controparte__c, Nome_controparte__c, Cognome_Controparte__c, 
                                                             Data_di_nascita_controparte__c, Codice_fiscale_controparte__c, 
                                                             Email_Controparte__c, Link_su_SOL__c, Claim_Number__c, CAI_Generabile__c, 
                                                             Data_inserimento_sinistro_su_SOL__c, Data_comunicazione_sinistro_da_SOL__c, 
                                                             Event_Type__c, Claim_Type__c, Data_recall__c, Ora_recall__c, Note__c, 
                                                             Telefono_controparte__c, Telefono_conducente__c,Sinistro_aperto_su_SOL__c,
                                                             Sinistro_canalizzabile__c,Sinistro_canalizzato__c,assistenza_cai_richiesta__c,Note_HD2__c,
                                                             Tipologia_Targa__c,Motivo_trasferimento__c,Description__c,CheckFileAllegati__c,Numero_Cellulare_Contraente__c,
                                                             Stato_immatricolazione_veicolo__c,Presenza_Testimoni__c,Comune_di_Nascita_Controparte__c,
                                                             Provincia_Nascita_Controparte__c,Sesso_Controparte__c,Codice_Fiscale_Controparte_Contr__c,Nome_Controparte_Contr__c,
                                                             Cognome_Controparte_Contr__c,Sesso_Controparte_Contr__c,Data_Nascita_Controparte_Contr__c,Luogo_Nascita_Controparte_Contr__c,Provincia_Nascita_Conducente_Contr__c,
                                                             Email_Controparte_Contr__c,Numero_Cell_Controparte_Contraente__c,Survey_Status__c,Conducente_Controparte_contraente__c,
															 Codice_Fiscale_Caponucleo__c,Cognome_Caponucleo__c,Data_di_Nascita_Caponucleo__c,Luogo_di_Nascita_Caponucleo__c,Nome_Caponucleo__c,Provincia_di_Nascita_Caponucleo__c, Sesso_Caponucleo__c , Id_Polizza_SOL__c,
                                                             Indirizzo_Res_Controparte_Contr__c,Citt_Res_Controparte_Contr__c,Provincia_Res_Controparte_Contr__c,CAP_Res_Controparte_Contr__c,Stato_Res_Controparte_Contr__c,
                                                             Indirizzo_Dom_Controparte_Contr__c,Citt_Dom_Controparte_Contr__c,Provincia_Dom_Controparte_Contr__c,CAP_Dom_Controparte_Contr__c,Stato_Dom_Controparte_Contr__c,
                                                             Data_Ricontatto__c, Fast_Payment__c, Caring_Angel_Type__c
															 FROM Questionario_CA__c WHERE ID =:questionarioCAid];
                                                             //Bonifazi Giorgio 19/07/2019: Caring Angel Fase 2 - END
                if(!questionarioList.isEmpty())
                {
                    toReturn.questionario = questionarioList[0]; 
                    toReturn.idCase = questionarioList[0].Case__c;
                    
                }          
            }
        }
        
        return toReturn;
    }
    //Giorgio Bonifazi - Caring Angel fase 2 - START
    @AuraEnabled
    public static String upsertQuestionarioCACTRL(Questionario_CA__c questionario, String oraEvento, String minutiEvento, String oraRecall, String minutiRecall, String accountIdToUpdate, String QuestionarioToUpdate,String surveyStatus)
        {return upsertQuestionarioCACTRL(questionario,null,oraEvento,minutiEvento,oraRecall,minutiRecall,accountIdToUpdate,QuestionarioToUpdate,null,null,null,null,surveyStatus);}

    //Giorgio Bonifazi - Caring Angel fase 2 - END

    @AuraEnabled
    public static String upsertQuestionarioCACTRL(Questionario_CA__c questionario, String nodeCode, String oraEvento, String minutiEvento, String oraRecall, String minutiRecall, String accountIdToUpdate, String QuestionarioToUpdate, String NoteHD2,String Description,List<Testimone_Ferito__c> Testimoni,List<Testimone_Ferito__c> Feriti,String surveyStatus) {  //Giorgio Bonifazi - Caring Angel fase 2  //Giorgio Bonifazi CAI DIGITALE 
        String toReturn = '';
        system.debug('upsertQuestionarioCACTRL oraEvento --->'+ oraEvento);
        system.debug('upsertQuestionarioCACTRL oraRecall --->'+ oraRecall);
        system.debug('upsertQuestionarioCACTRL nodeCode --->'+ nodeCode);
        if(questionario!=null)
        {
            if(nodeCode!=null) questionario.TECH_Policy_Node__c=nodeCode;
            String NDG = questionario.TECH_NDG__c;
            List<Account> accListFromNDG=new List<Account>();
            if(NDG!=null){
                accListFromNDG = [Select id from Account where NDG__c = :NDG]; // NOPMD  Fix CRUD
            }
            if(!accListFromNDG.isEmpty()){
                if(accountIdToUpdate != accListFromNDG[0].Id){
                    accountIdToUpdate = accListFromNDG[0].Id;
                }
            }
              if(String.isNotBlank(surveyStatus))
            {
                questionario.Survey_Status__c =surveyStatus;
            }
            if(String.isNotBlank(QuestionarioToUpdate))
            {
                questionario.id =QuestionarioToUpdate;
            }
            if(String.isNotBlank(oraEvento) && String.isNotBlank(minutiEvento))
            {
                questionario.Ora_Evento__c = Time.newInstance(Integer.valueOf(oraEvento), Integer.valueOf(minutiEvento), 0, 00);
            }
            if(String.isNotBlank(oraRecall) && String.isNotBlank(minutiRecall))
            {
                questionario.Ora_recall__c = Time.newInstance(Integer.valueOf(oraRecall), Integer.valueOf(minutiRecall), 0, 00);
            }
            //Giorgio Bonifazi - START
            if(String.isNotBlank(Description)){
                questionario.Description__c = Description;
            }
            //Giorgio Bonifazi - END
            system.debug('upsertQuestionarioCACTRL questionario--->' + questionario);
            Case caseToUpdate;
            if(questionario.Case__c != null){
                caseToUpdate = setFastPayment(questionario.Case__c, questionario.Fast_Payment__c);
            }
            String subCategoryDetail=caseToUpdate.SubCategoryDetail__c;
            Account clientToUpdate; //OAVERSANO 27/05/2019 : AXA Assistance Enhancement Fase I
            if(questionario.Case__c!=null && String.isNotBlank(accountIdToUpdate))
            {
                caseToUpdate = new Case(Id = questionario.Case__c, AccountId = accountIdToUpdate, SubCategoryDetail__c=subCategoryDetail); 
            }
            //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
            List<String> recordTypeSinistri = new List<String>();
            if(MPS_Code_Variables__c.getValues('RecordTypeSinistriLabel')!=null)
            {
                if(String.isNotBlank(MPS_Code_Variables__c.getValues('RecordTypeSinistriLabel').value__c))
                {
                    for(String s:(MPS_Code_Variables__c.getValues('RecordTypeSinistriLabel').value__c).split(';'))
                    {
                        recordTypeSinistri.add(s);                
                    }
                }
            }
            //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
            try
            {
                //upsert questionario;
                //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
                system.debug('Email Contraente : '+questionario.Email_Contraente__c	);
                if(questionario.Case__c!=null && String.isNotBlank(questionario.Email_Contraente__c))
                {
                	List<Case> currentCase = [SELECT Id, Account_Email__c, AccountId, SuppliedEmail, RecordType.Name FROM Case WHERE Id =: questionario.Case__c]; // NOPMD  Fix CRUD
                	if(!currentCase.isEmpty())
                	{
                		if(recordTypeSinistri.contains(currentCase[0].RecordType.Name) ||  currentCase[0].RecordType.Name == 'Caring Angel Property' ||  currentCase[0].RecordType.Name == 'Caring Angel')
                		{
	                		if(currentCase[0].Account_Email__c!=questionario.Email_Contraente__c || currentCase[0].SuppliedEmail!=questionario.Email_Contraente__c)
	                		{
	                			if(caseToUpdate!=null)
	                			{
                                    if(recordTypeSinistri.contains(currentCase[0].RecordType.Name))
                                    {
	                				caseToUpdate.Account_Email__c = questionario.Email_Contraente__c;
	                				caseToUpdate.SuppliedEmail = questionario.Email_Contraente__c;
                                    } 
                                    else if(currentCase[0].RecordType.Name == 'Caring Angel Property')
                                    {
                                    caseToUpdate.SuppliedEmail = questionario.Email_Contraente__c;
                                    }
                                    else if(currentCase[0].RecordType.Name == 'Caring Angel')
                                    {
                                    caseToUpdate.SuppliedEmail = questionario.Email_conducente__c;
                                    }
                                }
	                			else
	                				caseToUpdate = new Case(Id= questionario.Case__c, Account_Email__c = questionario.Email_Contraente__c, SuppliedEmail = questionario.Email_Contraente__c);
	                		}
	                		if(String.isNotBlank(currentCase[0].AccountId) && currentCase[0].RecordType.Name != 'Caring Angel Property' && currentCase[0].RecordType.Name != 'Caring Angel')
			                {
			                	if(String.isNotBlank(accountIdToUpdate))
			                	{
				                	List<Account> currentClient = [SELECT Id, Additional_Email__c FROM Account WHERE Id =: accountIdToUpdate]; // NOPMD  Fix CRUD
				                	if(!currentClient.isEmpty())
				                	{
				                		if(currentClient[0].Additional_Email__c!=questionario.Email_Contraente__c)
				                		{
				                			clientToUpdate = new Account(Id = accountIdToUpdate, Additional_Email__c = questionario.Email_Contraente__c);
				                		}
				                	}
			                	}
			                	else
			                	{
			                		List<Account> currentClient = [SELECT Id, Additional_Email__c FROM Account WHERE Id =: currentCase[0].AccountId]; // NOPMD  Fix CRUD
				                	if(!currentClient.isEmpty())
				                	{
				                		if(currentClient[0].Additional_Email__c!=questionario.Email_Contraente__c)
				                		{
				                			clientToUpdate = new Account(Id = currentCase[0].AccountId, Additional_Email__c = questionario.Email_Contraente__c);
				                		}
				                	}	
			                	}
			                }
	                		
                		}
                	}
                } 
               
             else if(questionario.Case__c!=null && !String.isNotBlank(questionario.Email_Contraente__c))
             {
                List<Case> currentCaseCaringAngel = [SELECT Id, AccountId, SuppliedEmail, RecordType.Name FROM Case WHERE Id =: questionario.Case__c]; // NOPMD  Fix CRUD
                if(currentCaseCaringAngel[0].RecordType.Name == 'Caring Angel')
                    {
                         if(caseToUpdate!=null)
                        {
                        caseToUpdate.SuppliedEmail = questionario.Email_conducente__c;
                        }
                    }
             }
                

                






                //Giorgio Bonifazi - Caring Angel fase 2
                if(questionario.Case__c!=null && String.isNotBlank(questionario.Note_HD2__c)){

                                if(caseToUpdate!=null)
	                			{
	                				caseToUpdate.Note_HD2__c = questionario.Note_HD2__c;
	                				
	                			}
	                			else
	                				caseToUpdate = new Case(Id= questionario.Case__c, Note_HD2__c = questionario.Note_HD2__c);
                }
				if(questionario.Case__c!=null && questionario.Data_Ricontatto__c!= null){

                                if(caseToUpdate!=null)
	                			{
	                				caseToUpdate.Data_Ricontatto__c = questionario.Data_Ricontatto__c;
	                				
	                			}
	                			else
	                				caseToUpdate = new Case(Id= questionario.Case__c, Data_Ricontatto__c = questionario.Data_Ricontatto__c);
                }

                //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END

                
                //può esistere soltanto un questionario per Case (Wave 3)
                if(questionario.Case__c != null){
                    List<Questionario_CA__c> questionariCorrenti = [SELECT ID from Questionario_CA__c where Case__c = :questionario.Case__c]; // NOPMD  Fix CRUD
                    if(!questionariCorrenti.isEmpty()){
                        questionario.Id = questionariCorrenti.get(0).Id;
                    }
                }
                
                List<Questionario_CA__c> questionarioList = new List<Questionario_CA__c>();
                questionarioList.add(questionario);
                String UpsertedQuestionario = '';

                Database.UpsertResult[] srList = Database.upsert(questionarioList, false);
                
                for (Database.UpsertResult sr : srList) 
                {
                    if (sr.isSuccess()) 
                    {
                        // Operation was successful, so get the ID of the record that was processed
                        UpsertedQuestionario = sr.getId();
                        System.debug('Successfully upserted Questionario CA. ID: ' + sr.getId());
                    }
                    else{
                        System.debug('Error: '+sr.getErrors());
                    }
                }
                
                

                if(caseToUpdate!=null)
                {
                    if(questionario.TECH_Policy_Node__c != null && questionario.TECH_Policy_Node__c.startsWith('000729')){
                        caseToUpdate.Distribution_Network__c = 'RCI';
                    }
                    update caseToUpdate; // NOPMD  Fix CRUD
                } 
                //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
                if(clientToUpdate!=null)
                {
                    update clientToUpdate; // NOPMD  Fix CRUD
                }
                //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
                //toReturn = 'OK';
                toReturn = 'OK|'+UpsertedQuestionario;
                //Giorgio Bonifazi CAI DIGITALE START
                if(Testimoni != null &&  Testimoni.size()>0 && questionario.Case__c!=null)
                {
                    list<Testimone_Ferito__c> UpdatedTestimoneList = new list<Testimone_Ferito__c>();
                    Integer key = 0;
                        for(Testimone_Ferito__c obj : Testimoni){
                            
                            obj.RecordTypeId = Schema.SObjectType.Testimone_Ferito__c.getRecordTypeInfosByName().get('Testimone').getRecordTypeId();
                            if(!String.isNotBlank(QuestionarioToUpdate)){
                            obj.Questionario__c = UpsertedQuestionario;}
                            else
                            obj.Questionario__c = QuestionarioToUpdate;
                            obj.Case__c = questionario.Case__c;
                            obj.TestimoneFeritoKey__c = obj.Nome__c + obj.Cognome__c;
                            UpdatedTestimoneList.add(obj);
                        }
                        upsert UpdatedTestimoneList TestimoneFeritoKey__c ; // NOPMD  Fix CRUD

                }
                if(Feriti != null && Feriti.size()>0 && questionario.Case__c!=null)
                {
                    list<Testimone_Ferito__c> UpdatedFeritoList = new list<Testimone_Ferito__c>();
                        for(Testimone_Ferito__c obj : Feriti){

                            obj.RecordTypeId = Schema.SObjectType.Testimone_Ferito__c.getRecordTypeInfosByName().get('Ferito').getRecordTypeId();
                            if(!String.isNotBlank(QuestionarioToUpdate)){
                            obj.Questionario__c = UpsertedQuestionario;}
                            else
                            obj.Questionario__c = QuestionarioToUpdate;
                            obj.Case__c = questionario.Case__c;
                            obj.TestimoneFeritoKey__c = obj.Nome__c + obj.Cognome__c;
                            UpdatedFeritoList.add(obj);
                        }
                        upsert UpdatedFeritoList TestimoneFeritoKey__c; // NOPMD  Fix CRUD

                }
                //Giorgio Bonifazi CAI DIGITALE END
            }
            catch(exception ex)
            {
                toReturn = 'KO|Fallito'+ex.getMessage()+ex.getLineNumber();
            }
        }
        else
        {
            toReturn = 'KO|FallitoAttenzione ! Si è verificato un errore. Riprovare più tardi.';
        }
        return toReturn;
    }
    
    public class SOL_Response_Details
    {
        @AuraEnabled public String Url;
        @AuraEnabled public String Error;
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String QuestId; //OAVERSANO 05/12/2018 : FIX
        
        public SOL_Response_Details(){}
    }
    
    @AuraEnabled
    public static SOL_Response_Details OpenNewClaim(Questionario_CA__c theQuestionnaire, String theCase, String theQuestionnaireID)
    {
        SOL_Response_Details toReturn = new SOL_Response_Details();
        //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
        List<String> recordTypeSinistri = new List<String>();
        if(MPS_Code_Variables__c.getValues('RecordTypeSinistriLabel')!=null)
        {
            if(String.isNotBlank(MPS_Code_Variables__c.getValues('RecordTypeSinistriLabel').value__c))
            {
                for(String s:(MPS_Code_Variables__c.getValues('RecordTypeSinistriLabel').value__c).split(';'))
                {
                    recordTypeSinistri.add(s);                
                }
            }
        }
        Case caseToUpdate;
        Account clientToUpdate;
        //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
        if(String.isBlank(theCase))
        {
            toReturn.isSuccess = false;
            toReturn.Error = 'Il sistema SOL non è al momento raggiungibile, ti chiediamo di riprovare più tardi. Se il problema persiste contatta il tuo referente AXA';
        }
        else
        {
            IE_SOLClaimOpening.ResponseDto SOL_Response = new IE_SOLClaimOpening.ResponseDto();
            
            //bug doppio Questionario, nel momento della risposta si crea un secondo questionario, perche partono creazione
            // e request in paralelo, e non si leggeva piu dal database dopo la response-- *-+ 24-05-2023
            list <Questionario_CA__c> questionarioCommited = [select id from Questionario_CA__c where Case__c =: theCase WITH SYSTEM_MODE  order by CreatedDate asc]; // NOPMD  Fix CRUD
            if(!questionarioCommited.isEmpty()){
                theQuestionnaire.id = questionarioCommited[0].id;
            }    
         
            SOL_Response = IE_SOLClaimOpening.SOLCreateNewClaim(theQuestionnaire,theCase);
            
            if(SOL_Response.values.containsKey('url'))
            {
                if(String.isNotBlank((String)SOL_Response.values.get('url')))
                {
                    toReturn.Url = (String)SOL_Response.values.get('url');
                    //OAVERSANO 23/11/2018 : Caring Angel Enhancement -- START
                    theQuestionnaire.Link_su_SOL__c = (String)SOL_Response.values.get('url');
                    //theQuestionnaire.Sinistro_aperto_su_SOL__c = true;
                    //OAVERSANO 23/11/2018 : Caring Angel Enhancement -- END
                    
                    List<Questionario_CA__c> questionarioToInsertList = new List<Questionario_CA__c>();
                    questionarioToInsertList.add(theQuestionnaire);
                    
                    if(String.isBlank(theQuestionnaireID))
                    {
                        Database.UpsertResult[] srList = Database.upsert(questionarioToInsertList, false);
                        
                        for (Database.UpsertResult sr : srList) 
                        {
                            if (sr.isSuccess()) 
                            {
                                // Operation was successful, so get the ID of the record that was processed
                                System.debug('Successfully inserted questionario. ID: ' + sr.getId());
                                toReturn.QuestId = sr.getId();//OAVERSANO 05/12/2018 : FIX 
                            }
                        }      
                    }
                    else
                    {
                        Database.SaveResult[] srList = Database.update(questionarioToInsertList, false);
                        
                        for (Database.SaveResult sr : srList) 
                        {
                            if (sr.isSuccess()) 
                            {
                                // Operation was successful, so get the ID of the record that was processed
                                System.debug('Successfully updated questionario. ID: ' + sr.getId());
                                toReturn.QuestId = sr.getId();//OAVERSANO 05/12/2018 : FIX 
                            }
                        }      
                    }
                    
                    //case update
                    //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
	                if(theQuestionnaire.Case__c!=null && String.isNotBlank(theQuestionnaire.Email_Contraente__c))
	                {
	                	List<Case> currentCase = [SELECT Id, Account_Email__c, AccountId, SuppliedEmail, RecordType.Name FROM Case WHERE Id =: theQuestionnaire.Case__c]; // NOPMD  Fix CRUD
	                	if(!currentCase.isEmpty())
	                	{
	                		if(recordTypeSinistri.contains(currentCase[0].RecordType.Name))
	                		{
		                		if(currentCase[0].Account_Email__c!=theQuestionnaire.Email_Contraente__c || currentCase[0].SuppliedEmail!=theQuestionnaire.Email_Contraente__c)
		                		{
	                				caseToUpdate = new Case(Id= theQuestionnaire.Case__c, Account_Email__c = theQuestionnaire.Email_Contraente__c, SuppliedEmail = theQuestionnaire.Email_Contraente__c);
		                		}
		                		if(String.isNotBlank(currentCase[0].AccountId))
				                {
			                		List<Account> currentClient = [SELECT Id, Additional_Email__c FROM Account WHERE Id =: currentCase[0].AccountId]; // NOPMD  Fix CRUD
				                	if(!currentClient.isEmpty())
				                	{
				                		if(currentClient[0].Additional_Email__c!=theQuestionnaire.Email_Contraente__c)
				                		{
				                			clientToUpdate = new Account(Id = currentCase[0].AccountId, Additional_Email__c = theQuestionnaire.Email_Contraente__c);
				                		}
				                	}	
				                }
	                		}
	                	}
	                }
	                //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
                    if(String.IsNotBlank((String)SOL_Response.values.get('url')))
                    {
                    	//OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
                    	Case ccTOUpdate;
                    	if(caseToUpdate!=null)
                    		ccTOUpdate = caseToUpdate;
                    	else
                        	ccTOUpdate = new Case();
                    	//OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
                        ccTOUpdate.Id = theCase;
                        ccToUpdate.Visualizza_sinistro__c = '<a href="'+(String)SOL_Response.values.get('url')+'" >Visualizza su SOL</a>';
                        List<Case> caseToUpdList = new List<Case>();
                        caseToUpdList.add(ccTOUpdate);
                        Database.SaveResult[] srList = Database.update(caseToUpdList, false);
                        
                        for (Database.SaveResult sr : srList) 
                        {
                            if (sr.isSuccess()) 
                            {
                                // Operation was successful, so get the ID of the record that was processed
                                System.debug('Successfully updated case. ID: ' + sr.getId());
                            }
                        }   
                    }
                    //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
                    else{
                    	if(caseToUpdate!=null)
                    	{
                    		update caseToUpdate; // NOPMD  Fix CRUD
                    	}
                    }
                    if(clientToUpdate!=null)
                    {
                    	update clientToUpdate; // NOPMD  Fix CRUD
                    }
                    //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
                    //case update
                    
                    toReturn.isSuccess = SOL_Response.isSuccess;
                    toReturn.Error = SOL_Response.message;
                }
                else
                {
                    toReturn.isSuccess = false;
                    toReturn.Error = 'Il sistema SOL non è al momento raggiungibile, ti chiediamo di riprovare più tardi. Se il problema persiste contatta il tuo referente AXA';
                }          
            }
            else
            {
                toReturn.isSuccess = false;
                toReturn.Error = 'Il sistema SOL non è al momento raggiungibile, ti chiediamo di riprovare più tardi. Se il problema persiste contatta il tuo referente AXA';
            }
        }
        
        return toReturn;
    }
    //MMOSCATELLI 23/11/2018 : Caring Angel Enhancement -- START
    public class DeleteOutputs{
        @AuraEnabled public String Msg;
        @AuraEnabled public Boolean isSuccess;
        
        public DeleteOutputs(){
            this.isSuccess = false;
            this.Msg = '';
        }
    }
    
    @AuraEnabled
    public static DeleteOutputs eraseRecords(String CaseId, String QuestionarioId)
    {
        DeleteOutputs Dout = new DeleteOutputs();
        Savepoint sp = Database.setSavepoint();
        
        if(String.isNotBlank(QuestionarioId))
        {
            try
            {
                Database.DeleteResult DR_Dels = Database.delete(QuestionarioId);
                
                if(DR_Dels.isSuccess() && String.isNotBlank(CaseId))
                {
                    Database.DeleteResult DR_Dels_case = Database.delete(CaseId);
                    
                    if(DR_Dels_case.isSuccess())
                    {
                        Dout.isSuccess = true;
                        Dout.Msg = 'Il Case ed il Questionario CA creati sono stati eliminati con successo';
                    }
                    else
                    {
                        Database.rollback(sp);
                        Dout.isSuccess = false;
                        Dout.Msg = 'Non è stato possibile procedere con l\'eliminazione del Case e del Questionario CA. Contattare l\'Amministratore di sistema';
                    }            
                }
                else
                {
                    Database.rollback(sp);
                    Dout.isSuccess = false;
                    Dout.Msg = 'Non è stato possibile procedere con l\'eliminazione del Case e del Questionario CA. Contattare l\'Amministratore di sistema';            
                }
                
            }
            catch(Exception ex)
            {
                system.debug('@@Error: '+ex.getMessage());
                Database.rollback(sp);
                Dout.isSuccess = false;
                Dout.Msg = 'Non è stato possibile procedere con l\'eliminazione del Case e del Questionario CA. Contattare l\'Amministratore di sistema';             
            }
        }
        else
        {
            try
            {
                if(String.isNotBlank(CaseId))
                {
                    Database.DeleteResult DR_Dels_case = Database.delete(CaseId);
                    
                    if(DR_Dels_case.isSuccess())
                    {
                        Dout.isSuccess = true;
                        Dout.Msg = 'Il Case ed il Questionario CA creati sono stati eliminati con successo';
                    }
                    else
                    {
                        Database.rollback(sp);
                        Dout.isSuccess = false;
                        Dout.Msg = 'Non è stato possibile procedere con l\'eliminazione del Case e del Questionario CA. Contattare l\'Amministratore di sistema';
                    }          
                }
            }
            catch(exception ex)
            {
                Database.rollback(sp);
                Dout.isSuccess = false;
                Dout.Msg = 'Non è stato possibile procedere con l\'eliminazione del Case e del Questionario CA. Contattare l\'Amministratore di sistema';     
            }
        }
        return Dout;
    }
    //MMOSCATELLI 23/11/2018 : Caring Angel Enhancement -- END

    //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
    @AuraEnabled
    public static Boolean VerifyPolicy(String PolicyNumber)
    {
        AggregateResult[] ARs = [select count(id) totalSize, TECH_Company__c from InsurancePolicy__c where Name =: PolicyNumber  group by TECH_Company__c]; // NOPMD  Fix CRUD violation
        if(!ARs.isEmpty()){
        if((Integer)ARs[0].get('totalSize')>1)
            return true;
        else
        {
            if((String)ARs[0].get('TECH_Company__c')=='AAI')
                return true;
            else
                return false;
        }     
        }
        return false;
    }
    //MOSCATELLI_M 13/03/2019: Axa Assistance -- END


    //Giorgio Bonifazi CAI DIGITALE START
    @AuraEnabled
    public static List<Testimone_Ferito__c> initializeTestimoniCTRL(String questionarioCAid,list<Testimone_Ferito__c> testimoni){

        list<Testimone_Ferito__c> testimoniList = [SELECT Nome__c , Cognome__c , Telefono__c FROM Testimone_Ferito__c WHERE RecordType.Name='Testimone' AND Questionario__c =:questionarioCAid]; // NOPMD  Fix CRUD
        List<Testimone_Ferito__c> tempList = new list<Testimone_Ferito__c>();
        for(Testimone_Ferito__c temp : testimoniList){
            tempList.add(new Testimone_Ferito__c(Nome__c = temp.Nome__c, Cognome__c = temp.Cognome__c, Telefono__c = temp.Telefono__c));
        }
        return tempList;
    }

    @AuraEnabled
    public static List<Testimone_Ferito__c> initializeFeritiCTRL(String questionarioCAid,list<Testimone_Ferito__c> feriti){
        
        list<Testimone_Ferito__c> feritiList = [SELECT Nome__c , Cognome__c , Telefono__c,Data_Di_Nascita__c,Luogo_Di_Nascita__c,Email__c,Indirizzo_Residenza__c,Citt_Residenza__c,CAP_Residenza__c,Veicolo__c FROM Testimone_Ferito__c WHERE RecordType.Name='Ferito' AND Questionario__c =:questionarioCAid]; // NOPMD  Fix CRUD
        List<Testimone_Ferito__c> tempList = new list<Testimone_Ferito__c>();
        for(Testimone_Ferito__c temp : feritiList){
            tempList.add(new Testimone_Ferito__c(Nome__c = temp.Nome__c, Cognome__c = temp.Cognome__c, Telefono__c = temp.Telefono__c,Data_Di_Nascita__c=temp.Data_Di_Nascita__c,Luogo_Di_Nascita__c = temp.Luogo_Di_Nascita__c,Email__c=temp.Email__c,Indirizzo_Residenza__c=temp.Indirizzo_Residenza__c,Citt_Residenza__c=temp.Citt_Residenza__c,CAP_Residenza__c=temp.CAP_Residenza__c,Veicolo__c=temp.Veicolo__c));
        }
        return tempList;
    }
    //Giorgio Bonifazi CAI DIGITALE START
    
    @auraEnabled
    public static CAIServiceWrapper invokeSicAnia(String plate, String policyId, String publicId, String personId, String userId, String plateCounterParties ){
        CAIServiceWrapper wrapper = new CAIServiceWrapper();
        wrapper.tokenRequestWrapper.plate = plate.toUpperCase();
        wrapper.tokenRequestWrapper.policyId = policyId;
        wrapper.tokenRequestWrapper.publicId = publicId;
        wrapper.tokenRequestWrapper.personId = personId;
        wrapper.tokenRequestWrapper.userId = String.isNotBlank(userId) ? userId : 'user@axa.it';
		
        wrapper.counterPartiesRequestWrapper.plateCounterParties = plateCounterParties.toUpperCase(); 
        
        CAIServiceWrapper wrapperResponse = CAISicAniaService.invoke(wrapper);
        System.debug('###:'+wrapper);
        return wrapperResponse;
        																																			  																		
    }
	
	@auraEnabled
    public static String calculateFiscalCodeCtrl(String surname, String firstName, String city, String province, String birthdate, String gender){
        return Utils.getCF(surname, firstname, birthdate, gender, city, province);

    }
    
     @AuraEnabled
    public static List<Field_Validator_Setting__mdt> getListOfRegularExpressions() {
       return FieldValidator.getListOfRegularExpressions(); 
    }

    public static Case setFastPayment(Id caseId, String fastPayment){
        Case caseToUpdate = [SELECT SubCategoryDetail__c from Case where Id =: caseId]; // NOPMD  Fix CRUD
        if('SI'.equalsIgnoreCase(fastPayment)){
            caseToUpdate.SubCategoryDetail__c = 'Fast Payment';
        } else if('Fast Payment'.equalsIgnoreCase(caseToUpdate.SubCategoryDetail__c)){
            caseToUpdate.SubCategoryDetail__c = null;
        }
        return caseToUpdate;
    }
	
}
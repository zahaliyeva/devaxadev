/*------------------------------------------------------------------------------------------
Author:        Orlando Aversano
Company:       Deloitte
Class:         PrintableView
Description:   Apex class used to enable the "print" functionality in lex

History

03/01/2018     Created 
-------------------------------------------------------------------------------------------*/
public with sharing class PrintableView
{
	public Id CaseId								{ get; set; }
	public String PageLayoutName					{ get; set; }
   	public pageLayout dettaglioPagina 				{ get; set; }
   	public List<Case> CaseList						{ get; set; }
   	public Boolean showError						{ get; set; }
   	public String errorMessage						{ get; set; }
   	
    public PrintableView()
    {   
    	showError = false;
    	try{
	    	CaseId =ApexPages.CurrentPage().getParameters().get('id');
	    	PageLayoutName =ApexPages.CurrentPage().getParameters().get('plName');
	    	String sObjName = CaseId.getSObjectType().getDescribe().getName();
	    	List<String> fieldsToQuery = new List<String>();
	    	fieldsToQuery.add('Id');
	    	
	    	Map<String, String> APINameToLabelMapCaseFields = new Map<String, String>();
	    	Map<String, String> LookupIdToLookupNameMapCaseFields = new Map<String, String>();
	    	Map<String, String> LookupIdToObjectNameMapCaseFields = new Map<String, String>();
	    	String objectType = 'Case';
			Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
			Schema.SObjectType caseSchema = schemaMap.get(objectType);
			Schema.DescribeSObjectResult describeCaseResult = caseSchema.getDescribe();
			Map<String, Schema.SObjectField> fieldMap = describeCaseResult.fields.getMap();
			for (String fieldName: fieldMap.keySet()) {
				Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();
				String sdataType= string.valueOf(fieldResult.getType());
				if(sdataType=='REFERENCE')
				{
					System.debug(fieldResult.getRelationshipName()); 
					LookupIdToObjectNameMapCaseFields.put(fieldName, fieldResult.getName());
					LookupIdToLookupNameMapCaseFields.put(fieldName, fieldResult.getRelationshipName());
				}
				APINameToLabelMapCaseFields.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
			}
			
			Map<String,String> APINameObjToLabelObj = new Map<String,String>();
			List<Schema.SObjectType> AllObjectList = Schema.getGlobalDescribe().Values();    
			for(Schema.SObjectType f : AllObjectList)
			{
	  			APINameObjToLabelObj.put(f.getDescribe().getName(),f.getDescribe().getLabel());
			}
			
			Map<String, String> mpsCodeMapping = new Map<String, String>();
			Map<String, String> mpsCodeObjectsMapping = new Map<String, String>();
			List<MPS_Code_Utils__mdt> mpsCodeUtilList = [SELECT Id, DeveloperName, Key__c, Value__c 
														FROM MPS_Code_Utils__mdt 
														WHERE DeveloperName LIKE 'Printable%'];
			if(!mpsCodeUtilList.isEmpty())
			{
				for(MPS_Code_Utils__mdt mps : mpsCodeUtilList)
				{
					if(mps.DeveloperName.indexOf('PrintableView')!=-1)
						mpsCodeMapping.put(mps.Key__c, mps.Value__c);
					if(mps.DeveloperName.indexOf('PrintableObjectsView')!=-1)
						mpsCodeObjectsMapping.put(mps.Key__c, mps.Value__c);
				}
			}
			
	    	dettaglioPagina = new pageLayout();
	    	dettaglioPagina.sections = new List<section>();
	    	dettaglioPagina.relatedLists = new List<relatedList>();
	    	dettaglioPagina.relatedListsTable = new List<relatedListTable>();
	        List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List<String> {sObjName+'-'+PageLayoutName});
			Metadata.Layout layoutMd = (Metadata.Layout)layouts.get(0);
			for (Metadata.LayoutSection sect : layoutMd.layoutSections) {
				//system.debug('label sezione : '+sect.label);
				//system.debug('numero di colonne : '+sect.layoutColumns.size());
				//creazione sezione i-esima -- START
				section sec = new section();
	            sec.labelSection = sect.label;
	            if(sec.labelSection == 'Fields') sec.labelSection = 'Dettaglio';
	            sec.N_columns = String.valueOf(sect.layoutColumns.size());
	            sec.field_s = new List<field>();
				//creazione sezione i-esima -- START
	    		for (Metadata.LayoutColumn column : sect.layoutColumns) {
	        		if (column.layoutItems != null) {
	            		for (Metadata.LayoutItem item : column.layoutItems) {
	                		//System.debug('campo della sezione i-esima : '+item.field);
	                		field fld = new field();
	                		if(String.isNotBlank(item.field))
	                		{
	                 			String apiNameToLowerCase = item.field.toLowerCase();
	                			//add fields to a list to Query -- START
	                			if(LookupIdToLookupNameMapCaseFields.containsKey(apiNameToLowerCase))
	                			{
	                				fieldsToQuery.add(item.field); 
	                				fieldsToQuery.add(LookupIdToLookupNameMapCaseFields.get(apiNameToLowerCase)+'.Name');
	                			}
	                			else
	                			{
	                				fieldsToQuery.add(item.field); 
	                			}
	                			//add fields to a list to Query -- START
		                		if(APINameToLabelMapCaseFields.containsKey(apiNameToLowerCase))
		                		{
		                			fld.labelField = APINameToLabelMapCaseFields.get(apiNameToLowerCase);
		                			if(String.isnotBlank(fld.labelField) && fld.labelField.indexOf(' ID')!=-1)
		                			{
		                				fld.labelField = fld.labelField.replace(' ID','');
		                			}
		                			if(String.isnotBlank(fld.labelField) && fld.labelField.indexOf('ID ')!=-1)
		                			{
		                				fld.labelField = fld.labelField.replace('ID ','');
		                			}
		                		}
		                		fld.APIName = item.field;
	                		}
	                		
	                		sec.field_s.add(fld);
	                		
	            		}
	        		}
		    	}
		    	if((sec.labelSection == 'Custom Links' && !sec.field_s.isEmpty())
		    		||
		    		sec.labelSection != 'Custom Links'
		    	)
		    	{
		    		dettaglioPagina.sections.add(sec); //aggiunta sezione al page layout
		    	}
			}
			String fieldsJoined = String.join(fieldsToQuery, ', ');
			fieldsJoined = fieldsJoined.removeEnd(', ');
			String strQuery = 'SELECT ' + fieldsJoined + ', '+
				+'(SELECT Id, Name, BodyLength, Owner.Name, LastModifiedDate, LastModifiedby.Name FROM Attachments ORDER BY CreatedDate desc), '+
				+'(SELECT Id, Member.Name, LastModifiedDate, LastModifiedBy.Name, TeamRole.AccessLevel, TeamRole.Name, TeamRole.PreferencesVisibleInCSP FROM TeamMembers ORDER BY CreatedDate desc) '+
				+'FROM '+ objectType + ' WHERE id  =: CaseId';
			system.debug('strQuery: '+strQuery);
			CaseList = Database.query(strQuery);
			system.debug('--- CaseList ---'+CaseList);
            List<ContentDocumentLink> cntDocLinkList = new List<ContentDocumentLink>();
            String strFilesQuery = 'SELECT Id, ContentDocument.Title, ContentDocument.Owner.Name, ContentDocument.ContentSize, ContentDocument.LastModifiedby.Name, ContentDocument.LastModifiedDate FROM ContentDocumentLink WHERE  LinkedEntityId  =: CaseId ORDER BY ContentDocument.CreatedDate desc';
			system.debug('strFilesQuery: '+strFilesQuery);
			cntDocLinkList = Database.query(strFilesQuery);
			system.debug('--- cntDocLinkList ---'+cntDocLinkList);
			//page detail -- START
			if(!CaseList.isEmpty())
			{
				for(section sec : dettaglioPagina.sections)
				{
					for(field fld :sec.field_s)
					{
						if(fld.APIName!=null)
						{
							if(CaseList[0].get(fld.APIName)!=null)
							{
								String apiNameToLowerCase = fld.APIName.toLowerCase();
								if(LookupIdToObjectNameMapCaseFields.containsKey(apiNameToLowerCase))
	                			{
	                				SObject obj = CaseList[0].getSObject(LookupIdToLookupNameMapCaseFields.get(apiNameToLowerCase));
	                				if(obj!=null)
	                				{
										fld.value = (String) obj.get('name');
	                				}
	                			}
	                			else
	                			{
	                				fld.value = String.valueOf(CaseList[0].get(fld.APIName));
	                			}
								
							}
						}
					}
				}
				
				//related list -- START
				if(!CaseList[0].TeamMembers.isEmpty())
				{
					relatedListTable rList = new relatedListTable();
					rList.title = 'Team case';
					rList.records = new List<relatedListRecord>();
					for(CaseTeamMember csTeamMbr : CaseList[0].TeamMembers)
					{
						relatedListRecord record = new relatedListRecord();
						record.field_s = new List<field>();
						field memberName = new field();
						memberName.labelField = 'Membro';
						memberName.value = csTeamMbr.Member.Name;
						record.field_s.add(memberName);
						field memberRole = new field();
						memberRole.labelField = 'Ruolo membro';
						memberRole.value = csTeamMbr.TeamRole.Name;
						record.field_s.add(memberRole);
						field CaseAccess = new field();
						CaseAccess.labelField = 'Accesso case';
						CaseAccess.value = (csTeamMbr.TeamRole.AccessLevel=='Edit')?'Lettura/Scrittura':((csTeamMbr.TeamRole.AccessLevel=='Read')?'Lettura':'Nessuno');
						record.field_s.add(CaseAccess);
						field lastModifiedBy = new field();
						lastModifiedBy.labelField = 'Ultima modifica';
						lastModifiedBy.value = csTeamMbr.LastModifiedby.Name+', '+csTeamMbr.LastModifiedDate.format();
						record.field_s.add(lastModifiedBy);
						rList.records.add(record);
					}
					dettaglioPagina.relatedListsTable.add(rList);
				}
				if(!CaseList[0].Attachments.isEmpty() || !cntDocLinkList.isEmpty())
				{
					relatedList rList = new relatedList();
					rList.title = 'Allegati';
					rList.records = new List<relatedListRecord>();
                    if(!CaseList[0].Attachments.isEmpty())
                    {
                        for(Attachment attach : CaseList[0].Attachments)
                        {
                            relatedListRecord record = new relatedListRecord();
                            record.field_s = new List<field>();
                            field Name = new field();
                            Name.labelField = 'Titolo';
                            Name.value = attach.Name;
                            record.field_s.add(Name);
                            field titolare = new field();
                            titolare.labelField = 'Titolare';
                            titolare.value = attach.Owner.Name;
                            record.field_s.add(titolare);
                            field Dimensioni = new field();
                            Dimensioni.labelField = 'Dimensioni';
                            Dimensioni.value = FileSizeToString(attach.BodyLength);
                            record.field_s.add(Dimensioni);
                            field lastModifiedBy = new field();
                            lastModifiedBy.labelField = 'Ultima modifica';
                            lastModifiedBy.value = attach.LastModifiedby.Name+', '+attach.LastModifiedDate.format();
                            record.field_s.add(lastModifiedBy);
                            rList.records.add(record);
                        }
                    }
                    if(!cntDocLinkList.isEmpty())
                    {
                        for(ContentDocumentLink contDoc : cntDocLinkList)
                        {
                            relatedListRecord record = new relatedListRecord();
                            record.field_s = new List<field>();
                            field Name = new field();
                            Name.labelField = 'Titolo';
                            Name.value = contDoc.ContentDocument.Title;
                            record.field_s.add(Name);
                            field titolare = new field();
                            titolare.labelField = 'Titolare';
                            titolare.value = contDoc.ContentDocument.Owner.Name;
                            record.field_s.add(titolare);
                            field Dimensioni = new field();
                            Dimensioni.labelField = 'Dimensioni';
                            Dimensioni.value = FileSizeToString(contDoc.ContentDocument.ContentSize);
                            record.field_s.add(Dimensioni);
                            field lastModifiedBy = new field();
                            lastModifiedBy.labelField = 'Ultima modifica';
                            lastModifiedBy.value = contDoc.ContentDocument.LastModifiedby.Name+', '+contDoc.ContentDocument.LastModifiedDate.format();
                            record.field_s.add(lastModifiedBy);
                            rList.records.add(record);
                        }
                    }
					dettaglioPagina.relatedLists.add(rList);
				}
				//related list -- END
			}
			//page detail -- END
			//related list -- START
			Boolean checkRelatedAttachmentList = false;
			Boolean checkRelatedTeamMemberList = false;
			List<String> relatedListFields;
			for (Metadata.RelatedListItem relatedList : layoutMd.relatedLists) {
				system.debug('bottoni : '+relatedList.customButtons);
				system.debug('nome related list : '+relatedList.relatedList);
	    		system.debug('relatedList.fields : '+relatedList.fields);
	    		if(relatedList.relatedList == 'RelatedAttachmentList')
	    		{
	    			checkRelatedAttachmentList = true;
	    		}
	    		if(relatedList.relatedList == 'RelatedTeamMemberList')
	    		{
	    			checkRelatedTeamMemberList = true;
	    		}
	            if(relatedList.relatedList != 'RelatedAttachmentList'
	               && relatedList.relatedList != 'RelatedTeamMemberList')
	            {
	            	
	            	relatedListFields = new List<String>();
		            Map<String, String> LookupIdToLookupNameMapsObjFields = new Map<String, String>();
	    			Map<String, String> LookupIdToObjectNameMapsObjFields = new Map<String, String>();
	                Map<String, String> APINameToLabelMapsObjFields = new Map<String, String>();
	                String RelfieldsJoined;
	                String ObjectToQuery = '';
	                String fieldToFilter = '';
	                List<SObject> listData;
		            if(relatedList.fields!=null)
		            {
		            	for(String fld : relatedList.fields)
		            	{
		            		//fields cleaning START
		            		if(mpsCodeMapping.containsKey(fld))
		            		{
		            			if(String.isNotBlank(mpsCodeMapping.get(fld)))
		            			{
		            				relatedListFields.add(mpsCodeMapping.get(fld));
		            			}
		            		}
		            		else
		            		{
		            			relatedListFields.add(fld);
		            		}
		            		//fields cleaning END
		            	}
		            	RelfieldsJoined = String.join(relatedListFields, ', ');
		            	RelfieldsJoined = RelfieldsJoined.removeEnd(', ');
		            }
	                if(relatedList.relatedList.indexOf('.')!=-1)
	                {
	                	ObjectToQuery = relatedList.relatedList.substring(0,relatedList.relatedList.indexOf('.'));
	                	fieldToFilter = relatedList.relatedList.substring(relatedList.relatedList.indexOf('.')+1, relatedList.relatedList.length());
	                	if(mpsCodeObjectsMapping.containsKey(ObjectToQuery))
	                	{
	                		RelfieldsJoined = RelfieldsJoined+mpsCodeObjectsMapping.get(ObjectToQuery);
	                	}
	                }
	                if(relatedList.relatedList == 'RelatedLiveChatTranscriptList')
	                {
	                	ObjectToQuery = 'LiveChatTranscript';
	                	fieldToFilter = 'CaseId';
	                }
	                if(relatedList.relatedList == 'RelatedEmailMessageList')
	                {
	                	ObjectToQuery = 'EmailMessage';
	                	fieldToFilter = 'ParentId';
	                	RelfieldsJoined = 'Id, format(MessageDate), HasAttachment, FromAddress, tolabel(Status), Subject, TextBody'; 
	                	relatedListFields = new List<String>{'MessageDate','HasAttachment','FromAddress','Status','Subject','TextBody'};
	            	}
	                if(relatedList.relatedList == 'RelatedActivityList')
	                {
	                	List<Case> caseListTemp = new List<Case>();
	                	ObjectToQuery = 'OpenActivity';
	                	fieldToFilter = '';
	                	String strOpenActivitiesQuery = 'SELECT Id, '+
						+'(SELECT id, '+RelfieldsJoined+', Owner.Name, PrimaryWho.Name FROM OpenActivities ORDER BY CreatedDate desc)'+
						+'FROM CASE WHERE id  =: CaseId';
						system.debug('strOpenActivitiesQuery: '+strOpenActivitiesQuery);
						caseListTemp = (List<Case>)Database.query(strOpenActivitiesQuery);
						if(!caseListTemp.isEmpty())
						{
							if((caseListTemp[0].OpenActivities).size()>0)
							{
								listData = caseListTemp[0].OpenActivities;
							}
						}
	                }
	                if(relatedList.relatedList == 'RelatedHistoryList')
	                {
	                	List<Case> caseListTemp = new List<Case>();
	                	ObjectToQuery = 'ActivityHistory';
	                	fieldToFilter = '';
	                	relatedListFields.add('Description');
	                	String strActivityHistoriesQuery = 'SELECT Id, '+
						+'(SELECT id, '+RelfieldsJoined+', Description, Owner.Name, PrimaryWho.Name FROM ActivityHistories ORDER BY ActivityDate DESC, LastModifiedDate DESC LIMIT 500)'+
						+'FROM CASE WHERE id  =: CaseId';
						system.debug('strActivityHistoriesQuery: '+strActivityHistoriesQuery);
						caseListTemp = (List<Case>)Database.query(strActivityHistoriesQuery);
						if(!caseListTemp.isEmpty())
						{
							if((caseListTemp[0].ActivityHistories).size()>0)
							{
								listData = caseListTemp[0].ActivityHistories;
								system.debug('--- ActivityHistories ---'+listData);
							}
						}
	                }
	                if(relatedList.relatedList == 'RelatedCommentsList')
	                {
	                	ObjectToQuery = 'CaseComment';
	                	fieldToFilter = 'ParentId';
	                	RelfieldsJoined = 'Id, format(CreatedDate), CreatedBy.Name, IsPublished, CommentBody'; 
	                	relatedListFields = new List<String>{'CreatedDate','CreatedById','IsPublished','CommentBody'};
	            	}
	                
	                if(String.isNotBlank(ObjectToQuery) && String.isNotBlank(RelfieldsJoined) && String.isNotBlank(fieldToFilter))
	                {
		                String strRelQuery = 'SELECT ' + RelfieldsJoined;
		                if(ObjectToQuery!='EmailMessage' && ObjectToQuery!='CaseComment')
		                	strRelQuery += ', Owner.Name ';
		                strRelQuery += ' FROM '+ ObjectToQuery + ' WHERE '+fieldToFilter+'  =: CaseId ORDER BY CreatedDate desc';
		                system.debug('strQuery: '+strRelQuery);
		                listData = Database.query(strRelQuery);
		                system.debug('--- objectList ---'+listData);
		                
	                }
	                
	                ///
					Map<String, Schema.SObjectType> schemasObjMap = Schema.getGlobalDescribe();
					Schema.SObjectType sObjSchema = schemasObjMap.get(ObjectToQuery);
					if(sObjSchema!=null)
					{
						Schema.DescribeSObjectResult describesObjResult = sObjSchema.getDescribe();
						Map<String, Schema.SObjectField> fieldsObjMap = describesObjResult.fields.getMap();
						for (String fieldName: fieldsObjMap.keySet()) {
							Schema.DescribeFieldResult fieldResult = fieldsObjMap.get(fieldName).getDescribe();
							String sdataType= string.valueOf(fieldResult.getType());
							if(sdataType=='REFERENCE')
							{
								LookupIdToObjectNameMapsObjFields.put(fieldName, fieldResult.getName());
								LookupIdToLookupNameMapsObjFields.put(fieldName, fieldResult.getRelationshipName());
							}
							APINameToLabelMapsObjFields.put(fieldName, fieldsObjMap.get(fieldName).getDescribe().getLabel());
						}  
					}              
	                ///
	                relatedList rList = new relatedList();
	                system.debug('ObjectToQuery : '+ObjectToQuery);
	                if(listData!=null)
	                {
		                if(APINameObjToLabelObj.containsKey(ObjectToQuery))
		                {
		                	rList.title = APINameObjToLabelObj.get(ObjectToQuery);
		                	rList.APIName = ObjectToQuery;
		                	rList.records = new List<relatedListRecord>();
		                	for(SObject sObj : listData)
		                	{
		                		relatedListRecord relRec = new relatedListRecord();
		                		relRec.field_s = new List<field>();
		                		if(relatedListFields!=null)
		                		{
				                	for(String field : relatedListFields)
				                	{
				                		field fld = new field();
				                		fld.APIName = field;
				                		String apiNameToLowersObj = field.toLowerCase();
				                		if(APINameToLabelMapsObjFields.containsKey(apiNameToLowersObj))
				                		{
				                			fld.labelField = APINameToLabelMapsObjFields.get(apiNameToLowersObj);
				                			if(String.isnotBlank(fld.labelField) && fld.labelField.indexOf(' ID')!=-1)
				                			{
				                				fld.labelField = fld.labelField.replace(' ID','');
				                			}
				                			if(String.isnotBlank(fld.labelField) && fld.labelField.indexOf('ID ')!=-1)
				                			{
				                				fld.labelField = fld.labelField.replace('ID ','');
				                			}
				                		}
				                		if(listData.size()>0)
				                		{
				                			if(field.equalsIgnoreCase('name'))
				                			{
				                				relRec.nameRecord = String.valueOf(sObj.get(field));
				                			}
				                			///
				                			if(LookupIdToObjectNameMapsObjFields.containsKey(apiNameToLowersObj))
			                				{
			                					SObject obj = sObj.getSObject(LookupIdToLookupNameMapsObjFields.get(apiNameToLowersObj));
			                					system.debug('apiNameToLowersObj : '+apiNameToLowersObj+' & obj : '+obj);
												if(obj!=null)
													fld.value = (String) obj.get('name');
			                				}
			                				else
			                				{
			                					fld.value = String.valueOf(sObj.get(field));
			                				}
				                			if(fld.value == 'true')
				                				fld.value = 'Sì';
				                			else if(fld.value == 'false')
				                				fld.value = 'No';
				                		}
				                		relRec.field_s.add(fld);
				                	}
				                	rList.records.add(relRec);
		                		}
		                	}
		                }
	                }
	                dettaglioPagina.relatedLists.add(rList);
	            }
			}
			if(dettaglioPagina.relatedListsTable!=null)
			{
				if(!dettaglioPagina.relatedListsTable.isEmpty())
				{
					for(Integer i = 0; i<dettaglioPagina.relatedListsTable.size(); i++)
					{
						if(dettaglioPagina.relatedListsTable[i].title == 'Team case' && !checkRelatedTeamMemberList)
						{
							dettaglioPagina.relatedListsTable.remove(i);
							continue;
						}
					}
				}
			}
			if(dettaglioPagina.relatedLists!=null)
			{
				if(!dettaglioPagina.relatedLists.isEmpty())
				{
					for(Integer i = 0; i<dettaglioPagina.relatedLists.size(); i++)
					{
						if(dettaglioPagina.relatedLists[i].title == 'Allegati' && !checkRelatedAttachmentList)
						{
							dettaglioPagina.relatedLists.remove(i);
							continue;
						}
					}
				}
			}

			system.debug('dettaglioPagina : '+JSON.serializePretty(dettaglioPagina));
    	}
    	catch(Exception ex)
    	{
    		system.debug('Si è verificato nella seguente riga : '+ex.getLineNumber()+', il seguente errore : '+ex.getMessage());
    		errorMessage = 'Si è verificato il seguente errore: '+ex.getMessage()+'['+ex.getLineNumber()+']';
    		showError = true;
    	}
    }
    
    public String FileSizeToString(Long Value)
    {
        if(Value < 1024)
          	return string.valueOf(Value) + ' Bytes';
        else if(Value >= 1024 && Value < (1024*1024))
        {
          	//KB
          	Decimal kb = Decimal.valueOf(Value);
          	kb = kb.divide(1024,2);
          	return string.valueOf(kb) + ' KB';
        }
        else if (Value >= (1024*1024) && Value < (1024*1024*1024))
        {
          	//MB
          	Decimal mb = Decimal.valueOf(Value);
          	mb = mb.divide((1024*1024),2);
          	return string.valueOf(mb) + ' MB';
        }
        else
        {
          	//GB
          	Decimal gb = Decimal.valueOf(Value);
          	gb = gb.divide((1024*1024*1024),2);
	        return string.valueOf(gb) + ' GB';
        }    
    }
    
   
    
    public class pageLayout 
  	{
 		public List<section> sections 					{ get; set; } 
      	public List<relatedList> relatedLists			{ get; set; }
      	public List<relatedListTable> relatedListsTable { get; set; }
        
   		public pageLayout(){}
  	}
  	
  	public class section
  	{
  		public String labelSection						{ get; set; }
  		public String N_columns							{ get; set; }
  		public List<field> field_s						{ get; set; }
  	
  		public section(){}
  	}
  	
  	public class field
  	{
  		public String labelField						{ get; set; }
  		public String APIName							{ get; set; }
  		public String value								{ get; set; }
  		
  		public field(){}
  	}   
  	
  	public class relatedList
  	{
  		public String title								{ get; set; }
  		public String APIName							{ get; set; }
  		public List<relatedListRecord>	records			{ get; set; }
  		
  		public relatedList(){}
  	}
  	
  	public class relatedListTable
  	{
  		public String title								{ get; set; }
  		public String APIName							{ get; set; }
  		public List<relatedListRecord>	records			{ get; set; }
  		
  		public relatedListTable(){}
  	}
  	
  	public class relatedListRecord
  	{
  		public String nameRecord						{ get; set; }
  		public List<field> field_s						{ get; set; }
  		
  		public relatedListRecord(){}
  	}
}
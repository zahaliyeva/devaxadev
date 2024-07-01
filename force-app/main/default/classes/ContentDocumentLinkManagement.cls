/*------------------------------------------------------------------------------------------
Author:        Orlando Aversano
Company:       Deloitte
Class:         ContentDocumentLinkManagement
Description:   Apex class used to execute all the logics internal to the 
trigger related to the ContentDocumentLink object

History

09/11/2018     Created 
-------------------------------------------------------------------------------------------*/
public class ContentDocumentLinkManagement {
    
    
    public static void updateContentDocumentLinkVisibility(List<ContentDocumentLink> contDocLinkList, Map<String,Schema.RecordTypeInfo> MapCaseRecordType)
    {
    	List<ContentDocumentLink> contdocLinkListToUpdate = new List<ContentDocumentLink>();
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> contDocLinkIdSet = new Set<Id>();
        Set<String> HD2ProfileSet = new Set<String>();
        Set<String> HD2QueueSet = new Set<String>();
        Set<String> HD2BIZProfileSet = new Set<String>();
        Set<String> RecordTypeSet = new Set<String>();
        Set<Id> caseLinkedIdSet = new Set<Id>();
        Schema.DescribeSObjectResult r = Case.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        for(ContentDocumentLink cdl:contDocLinkList)
        {
        	contDocLinkIdSet.add(cdl.Id);
            if(cdl.LinkedEntityId!=null)
            {
                if((String.valueOf(cdl.LinkedEntityId)).startsWith(keyPrefix))
                {
                    caseIdSet.add(cdl.LinkedEntityId);
                }
            }
        }
        runQueryWOS queryWOS = new runQueryWOS();
        List<ContentDocumentLink> contDocLinkExtList = queryWOS.getContDocLinkExtList(contDocLinkIdSet, caseIdSet);
        Modello_di_Assistenza__mdt mdAss = [SELECT Id, DeveloperName,AgentProfile__c, CaseTriggerRecordType__c,
                                            HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c, 
                                            HD1BIZProfile__c, HD1BIZQueue__c, HD2BIZProfile__c, HD2BIZQueue__c 
                                            FROM Modello_di_Assistenza__mdt 
                                            WHERE DeveloperName  = 'ProfileManagementShareFiles'
                                            LIMIT 1];
        if(mdAss!=null)
        {
            if(String.isNotBlank(mdAss.HD2BIZProfile__c))
            {
                for(String s:mdAss.HD2BIZProfile__c.split(';'))
                {
                    HD2BIZProfileSet.add(s); 
                }
            }
            if(String.isNotBlank(mdAss.CaseTriggerRecordType__c))
            {
                for(String s:mdAss.CaseTriggerRecordType__c.split(';'))
                {
                    RecordTypeSet.add(s);  
                }
            }
        }
        List<Case> CaseLinkedList = [SELECT Id, RecordType.DeveloperName FROM Case WHERE Id IN:caseIdSet AND REcordType.DeveloperName IN:RecordTypeSet];
        for(Case cs:CaseLinkedList)
        {
            if(RecordTypeSet.contains(MapCaseRecordType.get(cs.RecordTypeId).getDeveloperName()))
            {
				caseLinkedIdSet.add(cs.Id);                
            }
        }
        for(ContentDocumentLink cdl:contDocLinkExtList){
        	system.debug('contDocLinkExtList: '+contDocLinkExtList);
            if((String.valueOf(cdl.LinkedEntityId)).startsWith(keyPrefix) 
            	&& caseLinkedIdSet.contains(cdl.LinkedEntityId) 
            	&& HD2BIZProfileSet.contains(cdl.ContentDocument.CreatedBy.Profile.Name)
               	//OAVERSANO 20/12/2018 : Enhancement NMA Biz III -- START
               	/*&& cdl.ContentDocument.Description != null
            	&& !cdl.ContentDocument.Description.contains('Allegato inserito da Storico Conversazioni') */
               	//OAVERSANO 20/12/2018 : Enhancement NMA Biz III -- END
            	&& cdl.Visibility != 'AllUsers'){
                    //OAVERSANO 22/02/2019 : fix Description -- START
                    if(cdl.ContentDocument.Description == null
                       ||
                       (cdl.ContentDocument.Description != null
                        && !cdl.ContentDocument.Description.contains('Allegato inserito da Storico Conversazioni')))
                    {
                        ContentDocumentLink contDocLinkToUpdate = new ContentDocumentLink(Id = cdl.Id, Visibility = 'AllUsers');
                        contdocLinkListToUpdate.add(contDocLinkToUpdate);
                    }
                    //OAVERSANO 22/02/2019 : fix Description -- END
            } 
        }
        try
        {
        	if(!contdocLinkListToUpdate.isEmpty())
        		update contdocLinkListToUpdate;
        }
        catch(Exception ex)
        {
        	system.debug('Error: '+ex.getMessage());
        }
    }
    
    
    public without sharing class runQueryWOS
    {
        public runQueryWOS(){}
        
   		public List<ContentDocumentLink> getContDocLinkExtList(Set<Id> contDocLinkIdSet, Set<Id> caseIdSet)
       	{ 
        	List<ContentDocumentLink> contDocListExtToReturn = new List<ContentDocumentLink>();
        	system.debug('contDocLinkIdSet: '+contDocLinkIdSet);
        	system.debug('caseIdSet: '+caseIdSet);
        	//OAVERSANO 20/12/2018 : Enhancement NMA Biz III -- START
        	//contDocListExtToReturn = [SELECT Id, LinkedEntityId, Visibility, ContentDocument.CreatedBy.Profile.Name FROM ContentDocumentLink WHERE Id IN:contDocLinkIdSet AND LinkedEntityId IN:caseIdSet];
        	contDocListExtToReturn = [SELECT Id, LinkedEntityId, Visibility, ContentDocument.CreatedBy.Profile.Name, ContentDocument.Description FROM ContentDocumentLink WHERE Id IN:contDocLinkIdSet AND LinkedEntityId IN:caseIdSet];
       		//OAVERSANO 20/12/2018 : Enhancement NMA Biz III -- END
       		system.debug('contDocListExtToReturn: '+contDocListExtToReturn);
       		return contDocListExtToReturn;
       	}
    } 

    public static Boolean hasValidExtensions(List<ContentDocumentLink> contentDocumentLinkList, List<ContentDocument> documents, Map<String, ContentVersion> fileExtensionMap, Map<Case, List<Id>> caseDocumentsMap){
        for(ContentDocumentLink contentDocumentLink: contentDocumentLinkList){
            ContentVersion contentVersion = fileExtensionMap.get(contentDocumentLink.ContentDocumentId);
            String filePath = contentVersion != null ? contentVersion.PathOnClient : null;
            Case caseToCheck = getCase(contentDocumentLink.ContentDocumentId, caseDocumentsMap);
            if(caseToCheck != null && FileUploadHelper.isFromEmailToCase(caseToCheck.Origin)){
                for(String invalidExtension: FileUploadHelper.getBadExtensionsEmailToCase()){
                    if(String.isNotBlank(filePath) && filePath.endsWithIgnoreCase(invalidExtension)){
                        String email = String.isNotBlank(caseToCheck.SuppliedEmail) ? caseToCheck.SuppliedEmail : caseToCheck.Account_Email__c;
                        if(String.isNotBlank(email) && String.isNotBlank(caseToCheck.Subject) && FileUploadHelper.isEnabledSendEmail()){
                            EventBus.publish(new SendEmail__e(Type__c='Invalid Extension', AttachmentName__c = contentVersion.PathOnClient, CaseSubjectReference__c = caseToCheck.Subject, Recipient__c = email) );
                        }
                        contentDocumentLink.addError('Estensione del file non valida ' + filePath);
                        return false;
                    }
                }
            } else {
                if(String.isNotBlank(filePath)){
                    for(String invalidExtension: FileUploadHelper.getBadExtensions()){
                        if(filePath.endsWithIgnoreCase(invalidExtension)){
                            contentDocumentLink.addError('Estensione del file non valida ' + filePath);
                            return false;
                        }
                        if(!FileUploadHelper.isFilePathAllowed(filePath)){
                            contentDocumentLink.addError('Estensione del file non valida ' + filePath);
                            return false;
                        }
                    }
                }
            }
        }
        return true;
    }

    private static Case getCase(Id documentId, Map<Case, List<Id>> caseDocumentsMap){
        for(Case c: caseDocumentsMap.keySet()){
            for(Id documentIdFromMap: caseDocumentsMap.get(c)){
                if(documentIdFromMap == documentId){
                    return c;
                }
            }
        }
        return null;
    }
}
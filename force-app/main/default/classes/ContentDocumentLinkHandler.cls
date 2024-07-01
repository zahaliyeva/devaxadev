/*------------------------------------------------------------------------------------------
Author:        Orlando Aversano
Company:       Deloitte
Class:         ContentDocumentLinkHandler
Description:   Trigger Handler for the ContentDocumentLink SObject. This class implements the ITrigger  
               interface to help ensure the trigger code is bulkified and all in one place.  

History

09/11/2018     Created 
-------------------------------------------------------------------------------------------*/
public with sharing class ContentDocumentLinkHandler implements ITrigger  
{ 
    public final Map<String, Schema.RecordTypeInfo> MapCaseRecordType = new Map<String, Schema.RecordTypeInfo> ();
    public final Map<String, ContentVersion> fileExtensionMap = new Map<String, ContentVersion>();
    public final Map<Case, List<Id>> caseDocumentsMap = new Map<Case, List<Id>>();
    public List<ContentDocument> documents = new List<ContentDocument>();


    // Constructor  
    public ContentDocumentLinkHandler() 
    {  
       	String[] casetypes = new String[]{'Case'}; 
        List<Schema.DescribeSobjectResult> caseresults = Schema.describeSObjects(casetypes); 
        for(Schema.RecordTypeInfo ri: caseresults[0].getRecordTypeInfos()) 
        { 
            MapCaseRecordType.put(ri.getRecordTypeId(), ri);
        }
    }  

    /**  
    * BULK 
    *  
    * Those methods are called prior to execution of a trigger. Use those to cache  
    * any data required into maps prior execution of the trigger.  
    */ 

    public void bulkBefore()
    {  

    }  

    public void bulkAfter()
    {  
        if(Trigger.isInsert && FileUploadHelper.isEnabledOnTriggerLightning()){
            Map<Id, Id> emailMessageContentDocumentMap = new  Map<Id, Id>();
            Map<Id, Id> caseContentDocumentMap = new Map<Id, Id>();
            List<String> documentIds = new List<String>();
            for(ContentDocumentLink doc: (List<ContentDocumentLink>) Trigger.new ) {
                // Il Parent del Document Link può essere un Email Message
                documentIds.add(doc.ContentDocumentId);
                if(String.isNotBlank(doc.LinkedEntityId) && 'EmailMessage'.equalsIgnoreCase(doc.LinkedEntityId.getSObjectType().getDescribe().getName())){
                    emailMessageContentDocumentMap.put(doc.LinkedEntityId, doc.ContentDocumentId);
                } 
            }
            for(EmailMessage message: [SELECT ParentId from EmailMessage where Id in :emailMessageContentDocumentMap.keySet()]){
                // Il Parent di un Email Message può essere un Case
                if(String.isNotBlank(message.ParentId) && 'Case'.equalsIgnoreCase(message.ParentId.getSObjectType().getDescribe().getName())){
                    caseContentDocumentMap.put(message.ParentId, emailMessageContentDocumentMap.get(message.Id));
                }
            } 
            if(!caseContentDocumentMap.isEmpty()){
                    List<Case> cases = [SELECT Id, Origin, Subject, SuppliedEmail, Account_Email__c from Case where Id in :caseContentDocumentMap.keySet()];
                    for(Case c: cases){
                        if(!caseDocumentsMap.containsKey(c)){
                            caseDocumentsMap.put(c,new List<Id>());
                        }
                        caseDocumentsMap.get(c).add(caseContentDocumentMap.get(c.Id));
                    }
            }
            documents = [SELECT Title FROM ContentDocument WHERE Id IN :documentIds];
            List<ContentVersion> contentVersions = [SELECT ContentDocumentId, PathOnClient, Title FROM ContentVersion WHERE ContentDocumentId = :documentIds AND IsLatest = true];
            for(ContentVersion content: contentVersions){
                fileExtensionMap.put(content.ContentDocumentId, content);
            }
        }

    }  
 
    /*BEFORE SINGLE METHOD*/
    public void beforeInsert(SObject so)
    {  

    }  

    public void beforeUpdate(SObject oldSo, SObject so)
    {  

    }  

    public void beforeDelete(SObject so)
    {     

    }
    
    /*BEFORE LIST METHOD*/
    public void beforeInsert(List<SObject> soList)
    {      

    }  

    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList)
    {
      
       
    }  

    public void beforeDelete(List<SObject> soList){     

    } 
    
    /*AFTER SINGLE METHOD*/
    public void afterInsert(SObject so)
    {  

    }         

    public void afterUpdate(SObject oldSo, SObject so)
    {  

    }  

    public void afterDelete(SObject so) 
    {  

    }
    
    public void afterUndelete(SObject so)
    {  

    }

    /*AFTER LIST METHOD*/
    public void afterInsert(List<SObject> soList) {  
        if(Trigger.isInsert && FileUploadHelper.isEnabledOnTriggerLightning()){
  	        List<ContentDocumentLink> ContDocLinkList = soList;

            for(ContentDocumentLink cdl : ContDocLinkList){
                if(((String)cdl.LinkedEntityId).startsWithIgnoreCase('ka')) return;
            }
            ContentDocumentLinkManagement.updateContentDocumentLinkVisibility(ContDocLinkList, MapCaseRecordType);
            ContentDocumentLinkManagement.hasValidExtensions(ContDocLinkList, documents, fileExtensionMap, caseDocumentsMap);
        }
    } 
    
    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)
    {  
    

              
    }  
    
    public void afterDelete(List<SObject> soList)
    {  

    }
    
    public void afterUndelete(List<SObject> soList){ 
 
       
    }

    public void andFinally(){  

    }      
}
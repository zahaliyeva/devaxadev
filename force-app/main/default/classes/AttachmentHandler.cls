public with sharing class AttachmentHandler implements ITrigger  {
     /**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers
     
      * Class AttachmentHandler  
     
      *  
     
      * Trigger Handler for the Attachment SObject. This class implements the ITrigger  
     
      * interface to help ensure the trigger code is bulkified and all in one place.  
     
      */ 
       
          Map<Case, List<Id>> caseAttachmentsMap = new Map<Case, List<Id>>();
     
         // Constructor  
     
         public AttachmentHandler()  
         {  
     
         }  
     
        
     
         /**  
     
          * bulkBefore  
     
          *  
     
          * This method is called prior to execution of a BEFORE trigger. Use this to cache  
     
          * any data required into maps prior execution of the trigger.  
     
          */ 
     
         public void bulkBefore()  
         {  
     
         }  
     
            
     
     public void bulkAfter(){  
          if(Trigger.isInsert && FileUploadHelper.isEnabledOnTriggerClassic()){
               Map<Id, List<Id>> caseIdAttachmentsMap = new Map<Id, List<Id>>();
              // Relazionare gli attachment che arrivano via email al Case
              Map<Id, List<Id>> attachmentEmailMessagesMap = new Map<Id, List<Id>>();
              List<Attachment> attachments = [SELECT ParentId from Attachment where Id = :Trigger.new];
              for(Attachment attachment: attachments){
                   System.debug('Attachment ParentId Type: ' + attachment.ParentId.getSObjectType().getDescribe().getName());
                    if(String.isNotBlank(attachment.ParentId) && 'Case'.equalsIgnoreCase(attachment.ParentId.getSObjectType().getDescribe().getName())){
                         if (!caseIdAttachmentsMap.containsKey(attachment.ParentId)) {
                              caseIdAttachmentsMap.put(attachment.ParentId,new List<Id>());
                         }
                         caseIdAttachmentsMap.get(attachment.ParentId).add(attachment.Id);
                    }
              }
              if(!caseIdAttachmentsMap.isEmpty()){
                    List<Case> cases = [SELECT Id, Origin, Subject, SuppliedEmail, Account_Email__c from Case where Id in :caseIdAttachmentsMap.keySet()];
                    for(Case c: cases){
                         for(Id caseId: caseIdAttachmentsMap.keySet()){
                              if(caseId == c.Id){
                                   caseAttachmentsMap.put(c, caseIdAttachmentsMap.get(c.Id));
                              }
                         }
                    }
              }
          }         
     }  
     
                
     
         public void beforeInsert(SObject so)  
         { 
      
         }  
         
         public void beforeInsert(List<SObject> soList) {  
              List<Attachment> rList = (List<Attachment>) soList; 
              AttachmentManagement.emailAttachmentReassigner (rList );   
         }   
         
         public void beforeUpdate(SObject oldSo, SObject so)  
         {  
             
      
         }  
     
             
         public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList)  
         {
                 
         }    
     
         /**  
     
          * beforeDelete  
     
          *  
     
          * This method is called iteratively for each record to be deleted during a BEFORE  
     
          * trigger.  
     
          */ 
     
         public void beforeDelete(SObject so)  
         {     
     
         }  
         
         public void beforeDelete(List<SObject> soList)  
         {  
     
         } 
     
         public void afterInsert(SObject so)  
         {  
               
         }  
     
     
         public void afterInsert(List<SObject> soList) {
               if(Trigger.isInsert && FileUploadHelper.isEnabledOnTriggerClassic()){
                    AttachmentManagement.checkExtension(caseAttachmentsMap, soList);   
               }
         } 
            
     
         public void afterUpdate(SObject oldSo, SObject so)  
         {  
     
         }  
     
         public void afterUpdate(List<SObject> oldSoList, List<SObject> soList)  
         {
     
         }  
     
         public void afterDelete(SObject so)  
         {  
     
         }  
         
         public void afterUndelete(SObject so)  
         {  
     
         }  
         
         public void afterDelete(List<SObject> soList)  
         {  
     
         }  
     
         public void afterUndelete(List<SObject> soList)  
         {  
     
         }         
     
         /**  
     
          * andFinally  
     
          *  
     
          * This method is called once all records have been processed by the trigger. Use this   
     
          * method to accomplish any final operations such as creation or updates of other records.  
     
          */ 
     
         public void andFinally()  
     
         {  
     
     
         }  
     
     }
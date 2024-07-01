//BOVOLENTA_D 21052018 moving existing attachment trigger
public class AttachmentManagement 
{ 
    //ORIGINAL LOGIC FROM emailAttachmentReassigner
    public static void emailAttachmentReassigner ( List<Attachment> attachList) 
    {
        //MOSCATELLI_M 14062016: Bugfix -- START
        List<Id> ListAttachmentParentId = new list<Id>();
        Map<Id,Id> MapAttachmentEmail = new map<Id,Id>();

        //MDANTONIO 10/07/2019: micro evolutive portale agenti - start
        List<String> casesId = new List<String>();
        for(Attachment a: attachList){
            if(String.isNotBlank(string.valueof(a.parentid)) && String.valueof(a.parentid).startsWith(AP_Constants.CaseKeyPrefix)){
                casesId.add(string.valueof(a.parentid));
            }
        }
        Map<Id, Case> cases = new Map<Id, Case>();
        if(casesId.size()>0){
            cases = new Map<Id,Case>([SELECT RecordType.Name FROM Case WHERE Id IN :casesId]);
            System.debug('===> cases related to attachments: ' + cases);
        }
        List<String> agencyProfilesId = AP_Constants.getAgencyProfilesId();
        //MDANTONIO 10/07/2019: micro evolutive portale agenti - end
        
        for(Attachment a : attachList)
        {
            if(String.isNotBlank(a.parentid))
            {
                String s = string.valueof(a.parentid); 
                
                if(s.startsWith('02s'))
                {
                    ListAttachmentParentId.add(a.parentid);
                    MapAttachmentEmail.put(a.id,a.parentid);           
                }
                //MDANTONIO 10/07/2019: micro evolutive portale agenti - start
                else if(s.startsWith(AP_Constants.CaseKeyPrefix)){
                    if(cases.get(s) != null && cases.get(s).RecordType.Name.equalsIgnoreCase(AP_Constants.rtCaseAssistenzaAgentiName) && agencyProfilesId.contains(UserInfo.getProfileId()) && AP_Constants.blockAttachmentInsert){
                        a.addError(System.label.Attachment_loading_block);
                    }
                }
                //MDANTONIO 10/07/2019: micro evolutive portale agenti - end
            }
        }
        
        if(ListAttachmentParentId.size()>0)
        {
            Map<Id,EmailMessage> MapEmailMessages = new map<Id,EmailMessage>([Select Id,parentID from EmailMessage where id in:ListAttachmentParentId AND Incoming =true]); //BOVOLENTA_D 15052018 ADDED incoming filter
            
            if(MapAttachmentEmail.size()>0)
            {           
                for(Attachment at:attachList)
                {
                    if(MapAttachmentEmail.containsKey(at.id))
                    {
                        if(MapEmailMessages.containsKey(MapAttachmentEmail.get(at.id)))
                        {
                            at.parentid = MapEmailMessages.get(MapAttachmentEmail.get(at.id)).parentID;
                        }                    
                    }
                }
            }        
        }
      
        /*
        for( Attachment a : trigger.new )
        {
            // Check the parent ID - if it's 02s, this is for an email message
            if( a.parentid == null )
                continue;
            
            String s = string.valueof( a.parentid );
            
            if( s.substring( 0, 3 ) == '02s' )
                a.parentid = [select parentID from EmailMessage where id = :a.parentid].parentID;
                
        }
        */
        //MOSCATELLI_M 14062016: Bugfix -- END    
        
    
    }  

    public static void checkExtension(Map<Case, List<Id>> caseAttachmentsMap, List<Attachment> attachments){
        for(Attachment attachment: attachments){
            System.debug('Attachment Name:' + attachment.Name);
            Case caseToCheck = getCase(attachment.Id, caseAttachmentsMap);
            if(caseToCheck != null && FileUploadHelper.isFromEmailToCase(caseToCheck.Origin)){
                for(String invalidExtension: FileUploadHelper.getBadExtensionsEmailToCase()){
                    if(attachment.Name != null && attachment.Name.endsWithIgnoreCase(invalidExtension)){
                        String email = String.isNotBlank(caseToCheck.SuppliedEmail) ? caseToCheck.SuppliedEmail : caseToCheck.Account_Email__c;
                        if(String.isNotBlank(email) && String.isNotBlank(caseToCheck.Subject) && FileUploadHelper.isEnabledSendEmail()){
                            EventBus.publish(new SendEmail__e(Type__c='Invalid Extension', AttachmentName__c = attachment.Name, CaseSubjectReference__c = caseToCheck.Subject, Recipient__c = email) );
                        }
                        attachment.addError('Estensione del file non valida ' + attachment.Name);
                    }
                }
            } else if(caseToCheck != null && FileUploadHelper.isFromWebForm(caseToCheck.Origin)){
                for(String invalidExtension: FileUploadHelper.getBadExtensionsWebForms()){
                    if(attachment.Name != null && attachment.Name.endsWithIgnoreCase(invalidExtension)){
                        String email = String.isNotBlank(caseToCheck.SuppliedEmail) ? caseToCheck.SuppliedEmail : caseToCheck.Account_Email__c;
                        if(String.isNotBlank(email) && String.isNotBlank(caseToCheck.Subject) && FileUploadHelper.isEnabledSendEmail()){
                            EventBus.publish(new SendEmail__e(Type__c='Invalid Extension', AttachmentName__c = attachment.Name, CaseSubjectReference__c = caseToCheck.Subject, Recipient__c = email) );
                        }
                        attachment.addError('Estensione del file non valida ' + attachment.Name);
                    }
                }
            } else {
                for(String invalidExtension: FileUploadHelper.getBadExtensions()){
                    if(attachment.Name != null && attachment.Name.endsWithIgnoreCase(invalidExtension)){
                        attachment.addError('Estensione del file non valida ' + attachment.Name);
                    }
                }
                if(attachment.Name != null && !FileUploadHelper.isFilePathAllowed(attachment.Name)){
                        attachment.addError('Estensione del file non valida ' + attachment.Name);
                }
            }
        } 
    } 

    private static Case getCase(Id attachmentId, Map<Case, List<Id>> caseAttachmentsMap){
        for(Case c: caseAttachmentsMap.keySet()){
            for(Id attachmentIdFromMap: caseAttachmentsMap.get(c)){
                if(attachmentIdFromMap == attachmentId){
                    return c;
                }
            }
        }
        return null;
    }

    
}
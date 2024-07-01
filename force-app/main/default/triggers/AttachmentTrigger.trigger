trigger AttachmentTrigger on Attachment (before insert, before update, after insert, after update, before delete, after delete, after undelete)
{  
    TriggerFactory.createHandler('AttachmentHandler');    
}
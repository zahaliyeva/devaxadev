// Jonathan Hersh - jhersh@salesforce.com
// November 13, 2008

trigger emailAttachmentReassigner on Attachment (before insert)
{
    //MOSCATELLI_M 14062016: Bugfix -- START
    List<Id> ListAttachmentParentId = new list<Id>();
    Map<Id,Id> MapAttachmentEmail = new map<Id,Id>();
    
    for(Attachment a : trigger.new)
    {
        if(String.isNotBlank(a.parentid))
        {
            String s = string.valueof(a.parentid);
            
            if(s.substring(0, 3) == '02s')
            {
                ListAttachmentParentId.add(a.parentid);
                MapAttachmentEmail.put(a.id,a.parentid);           
            }
        }
    }
    
    if(ListAttachmentParentId.size()>0)
    {
        Map<Id,EmailMessage> MapEmailMessages = new map<Id,EmailMessage>([Select Id,parentID from EmailMessage where id in:ListAttachmentParentId AND Incoming =true]); //BOVOLENTA_D 15052018 ADDED incoming filter
        
        if(MapAttachmentEmail.size()>0)
        {           
            for(Attachment at:trigger.new)
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
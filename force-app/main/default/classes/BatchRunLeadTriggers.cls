global class BatchRunLeadTriggers implements Database.Batchable<sObject>,Schedulable, Database.Stateful 
{
    global final String Query;
    private Integer currentChain;
    public List<String> impactedQueues;
    private Set<String> queues;
    public Boolean SendEmail;
    
    private Set<String> Totalqueues;
    
    global BatchRunLeadTriggers ()
    {
        
        Totalqueues= new Set<String>();
        
        Query='SELECT Id,FirstName,LastName,Company,TECH_Skip_triggers__c,TECH_COMPANY__C,Agency_Code__c,Landing_Page__c, LeadSource, OwnerId,Dettaglio__c FROM Lead WHERE TECH_Skip_triggers__c = true ORDER BY Agency_Code__c ASC';
        
    }
     
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<SObject> scope)
    {
     ReassignAndImpactedQueues(scope);
     system.debug ('*********theimpactedQueuescalculation'+Totalqueues);
    }
     
    global void finish(Database.BatchableContext BC)
    {

        // KMBatchCalculateDefaultVisibility newBatch = new KMBatchCalculateDefaultVisibility(currentChain);
       // Database.executeBatch(newBatch,100);
       
      
       system.debug ('*********theimpactedQueuescalculation'+Totalqueues);
       emailHandling (Totalqueues);
       
       
       
    }

    //for scheduling
    global void Execute(SchedulableContext SC)
    {  
        //KMBatchCalculateDefaultVisibility batch = new KMBatchCalculateDefaultVisibility(1);
       // Database.ExecuteBatch(batch,100);      
    } 




    
public Set <String> ReassignAndImpactedQueues(List<SObject> scope){
    
        
        List<Lead> rList = (List<Lead>) scope;
        
        system.debug('*******************'+rList);
        
        List<String> impactedQueues = new List<String>();
        Set<String> queues= new Set <String>();
        
        String ThePrefix = 'Coda_Agenzia_';
        Id defaultGroup;
        List<Group> groups = [Select id, name,developername from group where type = 'Queue' and developername = 'AAI_Lead_Queue'];
        Integer size = groups.size();
        if(size>0)
        {
            defaultGroup = groups[0].Id ;
        }
        Map<String,Id> theGroupMap = LeadManagement.LeadGroup (rList);
        System.debug('+++++++++++++++ theGroupMap: '+theGroupMap);
        
        
        
        for (Lead a :rList)
        {
       
            a.TECH_Skip_triggers__c = false;
            a.TECH_Lead_owner_email__c  = null;
          //  if (a.LeadSource != 'Web') //IF WEB SEND INDIVIDUAL EMAILZ
          //  {
            a.TECH_Send_Email_Notification__c = false;
           // } 
            a.TECH_Lead_owner_email__c = null;
            
            String currentQueue = ThePrefix+''+a.Agency_Code__c;

            Id QueueId = theGroupMap.containsKey(currentQueue) ? theGroupMap.get(currentQueue) : defaultGroup;
            System.debug('+++++++++++++++ QueueId: '+QueueId);
            
            a.ownerid = QueueId; 
            
            impactedQueues.add(currentQueue);
            queues.add(currentQueue);
            Totalqueues.add(currentQueue);

            //impactedQueues.add(a.QueueId);
            
            System.debug('************** ImpactedQueues:'+impactedQueues);
            System.debug('++++++++++++ Set of queues' +queues);
            
            
        }
        
        Database.Update (rList);
        
        
        return Totalqueues; 
         
   
    
}
    
    
  
    
    
    public static void emailHandling (Set<String> Setqueues)
    {

        list<GroupMember>  recipientPersonsG=[SELECT  GroupId,Id,SystemModstamp,UserOrGroupId,group.developername FROM GroupMember where group.developername in :setQueues ];
        map<String,Set<Id>> GroupNametoIds=new map<String,Set<Id>>();
        
        //map<String,Map<String,String>> theMap;
        list<Id> userIds = new list<Id>();
        for (GroupMember GM :recipientPersonsG)
        {
            if (String.valueOf(GM.UserOrGroupId).left(3)=='005')
            { 
                userIds.add(GM.UserOrGroupId);
                set<Id> tmpidset = new set<Id>();
                tmpidset = GroupNametoIds.get(GM.group.developername);
                if (tmpidset == null)
                {
                 System.debug('****************GM.UserOrGroupId '+GM.UserOrGroupId);
                    tmpidset  = new set<Id>();
                    tmpidset.add(GM.UserOrGroupId);
                    GroupNametoIds.put(GM.group.developername,tmpidset);
                }else
                {
                    tmpidset.add(GM.UserOrGroupId);
                    GroupNametoIds.put(GM.group.developername,tmpidset);
                }
                //usertoEmail.put(GM.UserOrGroupId,'');
                //theMap.put(GM.group.developername,
            }
        }
        list<User> recipientPersons=[SELECT id,email FROM User where isactive = true and id in :userIds];
        Map<Id, User> mapRecipients = new Map<Id, User>(recipientPersons);
        map<String,Set<String>> GroupNametoEmails = new map<String,Set<String>>();
        for(String currentQueue :setQueues)
        {
            set<Id> tmpidset = new set<Id>();
            tmpidset = GroupNametoIds.get(currentQueue);
            if (tmpidset != null)
            {
                for (Id currentId :tmpidset)
                { 
                    set<String> tmpStringSet = GroupNametoEmails.get(currentQueue);
                    System.debug('****************tmpStringSet  '+tmpStringSet );
                    if (tmpStringSet == null)
                    {
                        System.debug('****************currentId '+ currentId);
                        System.debug('****************mapRecipients.get(currentId) '+ mapRecipients.get(currentId));
                        tmpStringSet = new set<String>();
                        if (mapRecipients.get(currentId) != null )
                        {
                            tmpStringSet.add(mapRecipients.get(currentId).email);
                            GroupNametoEmails.put(currentQueue,tmpStringSet);
                        }
                    }else
                    {
                        System.debug('****************mapRecipients.get(currentId) '+mapRecipients.get(currentId));
                        
                        if (mapRecipients.get(currentId) != null )
                        {
                            tmpStringSet.add(mapRecipients.get(currentId).email);
                            GroupNametoEmails.put(currentQueue,tmpStringSet);
                        }
                    }
                }
            }          
        }
         System.debug('****************GroupNametoEmails '+GroupNametoEmails); 
         
         
        sendEmails(setQueues,GroupNametoEmails);
    }

 public static void sendEmails(Set<String> setQueueNames,map<String,Set<String>> GroupNametoEmails ){
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        //now do your loop
        List<EmailTemplate> template = new List<EmailTemplate>();
        template = [select id, Subject, HtmlValue, Body from EmailTemplate where developername = : 'Leads_Massive_new_assignment_notification_External_List'];  
        for (String currentQueue :setQueueNames) {
        
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String mailName ='Utente';
            integer recordNumber = 1000;
            
        
            system.debug('+++++++thisemailtemplate'+template.get(0));
            mail.setUseSignature(false);
            map<String,String> mapFieldToValue = new Map<String,String>();
            mapFieldToValue.put('{!User.FirstName}',mailName);
          //  mapFieldToValue.put('{!recordNumber}','dei' ); 
         //   mapFieldToValue.put('{!Link}','https://'+System.URL.getSalesforceBaseUrl().getHost()+'/00Q/o' );
            String tempURL = System.URL.getSalesforceBaseUrl().toExternalForm();
            //String tempURL= System.URL.getCurrentRequestUrl().toExternalForm();
           // mapFieldToValue.put('{!Link}',tempURL.SPLIT('/apex/',-1).get(0)+'/agenzie/00Q/o' );        
            mail = UtilityClass.prepareEmailTemplate(template.get(0),mapFieldToValue );
            list<String> destinations = new list<String>(GroupNametoEmails.get(currentQueue));
            mail.setToAddresses( destinations);
        
            mail.setSaveAsActivity(false);
        
            system.debug('+++++++++mail prepared'+mail);
          //  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            if (destinations!= null && destinations.size()>0){
                allMails.add(mail);
            }
        
        }
        //Finished your loop? Now you have an array of mails to send.
        //This uses 1 of your 10 calls to sendEmail that you are allowed
        try{ 
            if (allMails.size()>0){
                Messaging.sendEmail(allMails);
            }
        } catch (Exception e)
        {
            system.debug('Email Sending Exception');   
        }
        system.debug('+++++EMAIL limit (calls/limit)='+Limits.getEmailInvocations()+'/'+Limits.getLimitEmailInvocations());    
    }
    
    
    
}
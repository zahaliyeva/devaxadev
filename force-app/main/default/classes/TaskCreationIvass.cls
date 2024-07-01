/**
 * @description classe utilizzata per la creazione automatica di Task in base alle email da pb
 * @author      Reply
 */
public without sharing class TaskCreationIvass {
        
    /**
     * @description input wrapper class
     */
    public class PBInputs{
        
        
        public SObject Obj;

        @InvocableVariable 
        public String templateApiName;
        
        @InvocableVariable
        public Case caseObj;
            
        @InvocableVariable
        public Feedback__c FeedbackObject;
            
        @InvocableVariable
        public String ObjType;
        
        public String Message;
        
        public String Subject;
    }
           	
    /**
     * @description  metodo di partenza
     * @param inputs 
     */
	@InvocableMethod(label ='Create Task')
    public static void start(List<PBInputs> inputs){
        for(PBInputs temp : inputs){
            switch on temp.ObjType {
    			when 'Case' {		
                    temp.Obj = temp.caseObj;
    			}	
    			when 'Feedback' {
                    temp.Obj = temp.FeedbackObject;
    			}
            
            }
                   }
        createTask(inputs);
            }
                    
            
    /**
     * @description  metodo di creazione del task
     * @param inputs 
     */
    public static void createTask(List<PBInputs> inputs){
        //Setup -- Start
        String DefaultRecTypeName = 'Generico';
        List<String> InputTemplates = new List<String>();
        List<EmailMessage> EmailMessagesToInsert = new List<EmailMessage>();
        Map<String,String> RecIdToTemplateDevName = new Map<String, String>();
        Map<String,String> VisualforceTemplateDevNameToId = new Map<String, String>();
        List<Messaging.SingleEmailMessage> previewEmails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> EmailsComplete = new List<Messaging.SingleEmailMessage>();

        

        for(PBInputs temp : inputs){
            InputTemplates.add(temp.templateApiName);
            RecIdToTemplateDevName.put((String)temp.obj.get('Id'), temp.templateApiName);
        }
        List<Automatic_Email_task__mdt> CMList = [Select Object_Field__c,RecordType__c,Task_Type__c,Template__c,TemplateFields__c,Template_Type__c,Who__c,Task_Subject__c, From_Email__c  // NOPMD  Fix CRUD
                                           		  From Automatic_Email_task__mdt
                                                  WHERE Template__c in:InputTemplates WITH SYSTEM_MODE];
        Map<String,ID> RecTypeDevName = new Map<String,ID>();
        for(Recordtype temp : [Select id, developerName from recordtype where sobjectType = 'Task' WITH SYSTEM_MODE]){ // NOPMD  Fix CRUD
            RecTypeDevName.put(temp.developerName,temp.Id);
        }
        Map<String, Automatic_Email_task__mdt> CMMap = new Map<String, Automatic_Email_task__mdt>();
        for(Automatic_Email_task__mdt temp : CMList){
            CMMap.put(temp.Template__c, temp);
        }
        
        List<EmailTemplate> TempList = [Select Body, HtmlValue, DeveloperName, TemplateType, Name from EmailTemplate where DeveloperName in:InputTemplates WITH SYSTEM_MODE]; // NOPMD  Fix CRUD
        Map<String,String> TemplatesByDevName = new Map<String,String>();
        Map<String, String> TemplatesNameToDevName = new Map<String,String>();
        for(EmailTemplate temp : TempList){
            if('visualforce'.equalsIgnoreCase(temp.TemplateType)){
                VisualforceTemplateDevNameToId.put(temp.DeveloperName, temp.Id);
                TemplatesNameToDevName.put(temp.Name, temp.DeveloperName);
            }
            else
            TemplatesByDevName.put(temp.DeveloperName,String.isBlank(temp.Body)?temp.HTMLValue.stripHtmlTags() : temp.Body);
    }
        List<Task> TaskToInsert = new List<Task>();
        //Setup -- END
    
        for(PBInputs temp : inputs){
            String Description;
            String subject;
            if(CMMap.containsKey(temp.templateApiName)){
                Automatic_Email_task__mdt config = CMMap.get(temp.templateApiName);
                if((TemplatesByDevName.containsKey(temp.templateApiName)) || String.isNotBlank(temp.Message)){
                    Description = String.isNotBlank(temp.Message) ? temp.Message : evaluate(temp.Obj,TemplatesByDevName.get(temp.templateApiName),config);
                    
                    subject = config.Task_Subject__c;
                if(config.Task_Subject__c.contains('$Subject$') && String.isNotBlank(temp.Subject)){
                    subject = config.Task_Subject__c.replace('$Subject$',temp.Subject);
                }
                }
                if(VisualforceTemplateDevNameToId.containsKey(temp.templateApiName)){
                    subject = config.Task_Subject__c;
                    //Description = Messaging.renderStoredEmailTemplate(VisualforceTemplateDevNameToId.get(temp.templateApiName), (ID) temp.Obj.get(config.Who__c), (ID) temp.Obj.get('Id')).getHTMLBody().stripHtmlTags();
                    Messaging.SingleEmailMessage firstPreviewEmail = new Messaging.SingleEmailMessage();
                    /*List<String> toAddresses = new List<String>();
                    toAddresses.add((String) temp.Obj.get('SuppliedEmail'));*/
                    firstPreviewEmail.setUseSignature(false);
                    firstPreviewEmail.setSaveAsActivity(false);
                    firstPreviewEmail.setTemplateId(VisualforceTemplateDevNameToId.get(temp.templateApiName));
                    firstPreviewEmail.setTargetObjectId(UserInfo.getUserId());
                    firstPreviewEmail.setWhatId((ID) temp.Obj.get('Id'));
                    List<String> addresses = new List<String>();
                    addresses.add((String) temp.Obj.get('SuppliedEmail'));
                    firstPreviewEmail.setToAddresses(addresses);

                    previewEmails.add(firstPreviewEmail);
                    EmailsComplete.add(firstPreviewEmail);
                }
                else{
                TaskToInsert.add(new Task(
                    RecordtypeId = RecTypeDevName.containsKey(config.RecordType__c)?RecTypeDevName.get(config.RecordType__c):RecTypeDevName.get(DefaultRecTypeName),
                	WhoId = (ID) temp.Obj.get(config.Who__c),
                    Type = config.Task_Type__c,
                    TaskSubType = 'Email',
                    OwnerId = (ID) temp.Obj.get('CreatedById'),
                    WhatID = 'Lead'.equals(temp.ObjType)? null : (ID) temp.Obj.get('Id'),
                        Description = Description,
                    Subject = subject,
                    Feedback_NPS__c = 'Feedback'.equals(temp.ObjType) ? (String)temp.Obj.get('NPS_stars__c'):null
                ));
                }
                
            
            }
            
        }
                
        if(!previewEmails.isEmpty()){
            Messaging.SingleEmailMessage secondPreviewEmail = new Messaging.SingleEmailMessage();
            EmailsComplete.add(secondPreviewEmail);
            try {
                List<Messaging.SendEmailResult> previewResult = Messaging.sendEmail(EmailsComplete, true);
                previewResult.clear(); //bypass falso positivo pmd
            }
            catch (Exception e) {
                for(Messaging.SingleEmailMessage msg : previewEmails){
                    String templateDevName = TemplatesNameToDevName.get(msg.getTemplateName());
                    Automatic_Email_task__mdt config = CMMap.get(templateDevName);
                    EmailMessage msgToInsert = new EmailMessage();
                    msgToInsert.Subject                = msg.getSubject();
                    msgToInsert.Status                 = '3';
                    msgToInsert.ToAddress              = msg.getToAddresses().get(0);
                    msgToInsert.FromAddress                        = config.From_Email__c;
                    //;FromName               = msg.getFromName();
                    msgToInsert.HtmlBody               = msg.getHTMLBody();
                    msgToInsert.Incoming               = false;
                    msgToInsert.MessageDate            = DateTime.now();
                    msgToInsert.ParentId            = msg.getWhatId();
                       // ,HasAttachment       = true // not possible: Read-Only!
                    EmailMessagesToInsert.add(msgToInsert);
                    /*TaskToInsert.add(new Task(
                        RecordtypeId = RecTypeDevName.containsKey(config.RecordType__c)?RecTypeDevName.get(config.RecordType__c):RecTypeDevName.get(DefaultRecTypeName),
                        //WhoId = msg.getTargetObjectId(),
                        Type = config.Task_Type__c,
                        TaskSubType = 'Email',
                        OwnerId = UserInfo.getUserId(),
                        WhatID = msg.getWhatId(),
                        Description = msg.getHTMLBody().stripHtmlTags(),
                        Subject = config.Task_Subject__c
                    ));*/
                }
            }
        	}
        if(!EmailMessagesToInsert.isEmpty())
            insert EmailMessagesToInsert; // NOPMD  Fix CRUD
        insert TaskToInsert; // NOPMD  Fix CRUD
        	}
                
    /**
     * @description    metodo utilizzato per valorizzare il template
     * @param obj      
     * @param template 
     * @param config   
     * @return         `String`
     */
    private static String evaluate(SObject obj, String template,Automatic_Email_task__mdt config){
        //Setup -- Start
    	List<String> TemplateFields = String.isBlank(config.TemplateFields__c)? null : config.TemplateFields__c.split(';');
        List<String> ObjectFields = String.isBlank(config.Object_Field__c)? null : config.Object_Field__c.split(';');
        Map<String,String> TempFieldsToObjFields = new Map<String, String>();
        if(TemplateFields != null && ObjectFields != null && TemplateFields.size() == ObjectFields.size() )
        for(Integer i = 0; i<TemplateFields.size();i++){
            TempFieldsToObjFields.put(TemplateFields.get(i),ObjectFields.get(i));
        }
        String FinalTemplate = template;
        //Setup -- End
                
        for(String key : TempFieldsToObjFields.keySet()){
                
            	FinalTemplate = FinalTemplate.replace(key, obj.get(TempFieldsToObjFields.get(key)) == null ? '':(String)obj.get(TempFieldsToObjFields.get(key)));
        }
        return FinalTemplate;
    }
}
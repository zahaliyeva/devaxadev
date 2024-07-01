public with sharing class NewCommentAndAttachmentServer {
    
    public Map<String, String> UrlParameterMap;
    public string apexCaseId{get;set;}   
    public Boolean isConsole{set;get;}
    public String profileName {set;get;}
    public String userRole {set;get;}    
    
    public NewCommentAndAttachmentServer(ApexPages.StandardController stdController)
    {
        apexCaseId = ApexPages.currentPage().getParameters().get('id');    
        isConsole = false;
        UrlParameterMap = ApexPages.currentPage().getParameters();
        if(UrlParameterMap.containsKey('isConsole')){
            isConsole = (UrlParameterMap.get('isConsole')=='true')?false:true;           
        }
        //MOSCATELLI_M 25/10/2018: NMA Business -- START
        userRole    = '-';
        Id idProfile  = UserInfo.getProfileId();
        List<User> CurrentUser = [Select Profile.Name, UserRole.Name from User where id=:UserInfo.getUserId()  limit 1]; // NOPMD  Fix CRUD violation
        
        if(CurrentUser.size()>0)
        {
            profileName = CurrentUser[0].Profile.Name;
            
            if(String.isNotBlank(CurrentUser[0].UserRole.Name))
                userRole = CurrentUser[0].UserRole.Name;
        } 
        //MOSCATELLI_M 25/10/2018: NMA Business -- END      
    }
    
    public class ResponseDto { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Map<Object, Object> values { get; set; }
        @AuraEnabled public List<String> options {get;set;}
        public ResponseDto(Boolean isSuccess, String msg){
            this.isSuccess = isSuccess;
            this.message = msg;
            this.values = new Map<Object, Object>();
        }   
        
        public ResponseDto(){
            this.isSuccess = False;
            this.message = '';
            this.values = new Map<Object, Object>();
            
        }       
    }
    
    
    
    public class CheckErrorResult { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
        @AuraEnabled public Boolean show;
        @AuraEnabled public String message;
        public CheckErrorResult(){
            this.show = false;
            this.message = '';
        }   
    }
    
    @AuraEnabled
    public static ResponseDto deleteAttachments(List<String> attachmentIds)
    {
    	//OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- START
    	List<ContentVersion> conVerList = [SELECT Id, VersionData, ContentDocumentId, Title, ContentSize FROM ContentVersion WHERE Id IN:attachmentIds];
        List<String> contentDocLinkToDelete = new List<String>();
        for(ContentVersion conVer : conVerList)
        {
        	contentDocLinkToDelete.add(conVer.ContentDocumentId);
        }
        Database.delete(contentDocLinkToDelete);
        //Database.delete(attachmentIds);
        //OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- END
        ResponseDto serverResponse = new ResponseDto(true,'Attachments deleted');
        
        return serverResponse;     
    }

	// Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - START -->
    @AuraEnabled        
    public static List<String> getPickListValuesIntoList(String objectType, String selectedField){
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static String saveCommentAttachment(String cmt, String cCase, String rT, Integer numberOfAttachment, List<String> attachmentList, String OrgUrl, String Label, String profileName, String userRole,Boolean defectCheckbox, String fastPayment){ 
        return saveCommentAttachment(cmt, cCase, rT,  numberOfAttachment,  attachmentList, OrgUrl, Label,  profileName,userRole,defectCheckbox,null,fastPayment);
    }
    
    // Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - END -->																
    @AuraEnabled
    public static ResponseDto getMotivoTrasferimento(String caseId){
        Case c = [SELECT RecordType.DeveloperName from Case where Id = :caseId ]; // NOPMD  Fix CRUD violation
    	ResponseDto res = new ResponseDto();
        List<String> options = new List<String>();
        List<MotivoTrasferimentoProperty__mdt> customMetadataList = [Select Complete_Domain__c from MotivoTrasferimentoProperty__mdt where Record_Type__c = :c.RecordType.DeveloperName ];   // NOPMD  Fix CRUD violation 
        if(customMetadataList.isEmpty()){
            return res;
        }   
        for(String motivoDiTrasferimento: customMetadataList[0].Complete_Domain__c.split(';')){
      		options.add(motivoDiTrasferimento);
   		}
        res.options = options;
        return res;
    }


    @AuraEnabled
    //public static Storico_conversazioni__c saveCommentAttachment(String cmt, String cCase, String rT, Integer numberOfAttachment, List<String> attachmentList, String OrgUrl)
    public static String saveCommentAttachment(String cmt, String cCase, String rT, Integer numberOfAttachment, List<String> attachmentList, String OrgUrl, String Label, String profileName, String userRole, Boolean defectCheckbox,String motivoTrasferimento, String fastPayment)
    {
        
        //Case ca = [SELECT CaseNumber, Status, OwnerId, User__c FROM Case WHERE Id =: cCase];
        //Case ca = [SELECT CaseNumber, Status, OwnerId, User__c, RecordType.Name, Agency_Code__c FROM Case WHERE Id =: cCase]; //OAVERSANO 24/10/2018 : ICF Close The Loop 
        Case ca = [SELECT CaseNumber, LOB__c, Status, OwnerId, User__c, RecordType.Name, Agency_Code__c, PushNotification__c,Interazioni_Agente__c, ProfileNameOwner__c, QueueNameOwner__c, RoleNameOwner__c, supporto_mdc__c, Last_Advisor__c, Owner_HD1__c FROM Case WHERE Id =: cCase]; //OAVERSANO 11/01/2019 : Enhancement NMA Biz IV 
        
        if('SI'.equalsIgnoreCase(fastPayment)){
            ca.SubCategoryDetail__c = 'Fast Payment';
        }
        
        //OAVERSANO 10/12/2018 : modifica CaseStatus Storico Conversazioni -- START
        //MDANTONIO 02/04/2019 : storicizzazione valore “Preso in carico” - start
        //String oldCaseStatus = ca.Status;
        String oldCaseStatus = ca.Status.equals(AP_Constants.caseStatusAssigned) ? 'Preso in carico' : ca.Status;
        //MDANTONIO 02/04/2019 : storicizzazione valore “Preso in carico” - end
        //OAVERSANO 10/12/2018 : modifica CaseStatus Storico Conversazioni -- END
        //String profileName = '';//[Select Name from Profile WHERE Id =: idProfile LIMIT 1].Name;
        
        //MOSCATELLI_M 25/10/2018: NMA Business -- START
        /*
        String userRole    = '-';
        Id idProfile       = UserInfo.getProfileId();
        List<User> CurrentUser = [Select Profile.Name, UserRole.Name from User where id=:UserInfo.getUserId() limit 1]; 

        if(CurrentUser.size()>0)
        {
        profileName = CurrentUser[0].Profile.Name;

        if(String.isNotBlank(CurrentUser[0].UserRole.Name))
        userRole = CurrentUser[0].UserRole.Name;
        }
        */
        String destinatario;
        //MOSCATELLI_M 25/10/2018: NMA Business -- END
        String emTemplate = '';
        User toUser = new User();
        runQueryWOS queryRunner = new runQueryWOS();
        EmailTemplate etem;
        boolean sendIt = true;
        String Output  = 'OK';
        String HD1OwnerId='';
        String HD1OwnerName='';
        Boolean isOwnwerTarget = false; //OAVERSANO 20/09/2018 : Nuovo Modello di Assistenza
        String toQueueEmail; //OAVERSANO 20/09/2018 : Nuovo Modello di Assistenza
        List<CaseTeamMember> toTeamMembers = new List<CaseTeamMember>();//MOSCATELLI 11/02/2019: Lob Contabilità
		//Giorgio Bonifazi - Caring Angel Fase 2 - START
        String recordtypeName;
        List<Case> csList = [SELECT Id,  RecordType.DeveloperName FROM Case WHERE id =:cCase  LIMIT 1]; // NOPMD  Fix CRUD violation  
        recordTypeName = csList[0].RecordType.DeveloperName; 
        //Giorgio Bonifazi - Caring Angel Fase 2 - END												
		
        //OAVERSANO 11/10/2018 : Modello di Assistenza -- START
        List<bypass__c> skipValidations = [select Id, Name, SetupOwnerId, SetupOwner.Name, BypassTrigger__c, BypassValidationRules__c, BypassWorkflows__c from Bypass__c ]; // NOPMD  Fix CRUD violation
        system.debug('skipValidations: '+skipValidations);
        bypass__c skipValidation;
        for(bypass__c bp : skipvalidations)
        {
            if(bp.SetupOwnerId == UserInfo.getProfileId())
                skipValidation = bp;
        }
        //OAVERSANO 11/10/2018 : Modello di Assistenza -- END
        if (profileName.containsIgnoreCase('AAI - Vendite solo Assistenza') || profileName.containsIgnoreCase('AAI - Vendite Base') || profileName.containsIgnoreCase('AAI - Vendite Avanzato') || profileName.containsIgnoreCase('AAI - Vendite No Accordo Digitale'))
        {
            if(String.valueOf(ca.OwnerId).startsWith('00G')){
                destinatario = ModelloDiAssistenzaUtils.getDestinatario(ca.QueueNameOwner__c, ca.RoleNameOwner__c, ca.OwnerId);
            }
            else{
                destinatario = ModelloDiAssistenzaUtils.getDestinatario(ca.ProfileNameOwner__c, ca.RoleNameOwner__c, ca.OwnerId);
            }
            //OAVERSANO 11/10/2018 : Modello di Assistenza -- START
            if(skipValidation != null) {
                skipValidation.BypassValidationRules__c= true;
                upsert skipValidation; // NOPMD  Fix CRUD violation
            }
            //OAVERSANO 11/10/2018 : Modello di Assistenza -- END
            if (ca.Status.equalsIgnoreCase('Attesa Info Agente')) 
            {
                ca.Status = 'Info Agente ricevute'; 
            }
            //OAVERSANO 11/01/2019 : Enhancement NMA Biz IV -- START
            if(ca.PushNotification__c)
                ca.PushNotification__c = false;
            else
                ca.PushNotification__c = true;
            //OAVERSANO 11/01/2019 : Enhancement NMA Biz IV -- END
            //OAVERSANO 20/09/2018 : Nuovo Modello di Assistenza -- START
            //if(!ca.Status.equalsIgnoreCase('Open') && !ca.Status.equalsIgnoreCase('Aperto') ){
            sendIt = true;

            //MOSCATELLI 11/02/2019: Lob Contabilità -- START
            if(MPS_Code_Variables__c.getValues('Switch Notifica Storico Conversazione').Value__c =='true')
            {
                toTeamMembers = queryRunner.getCaseTeamMembers(ca);
            }
            //MOSCATELLI 11/02/2019: Lob Contabilità -- END

            if(String.valueOf(ca.OwnerId).startsWith('005'))
            {
                toUser = queryRunner.getUser(ca, true);
                isOwnwerTarget = false;
            }
            else
            {
                toQueueEmail = queryRunner.getQueueEmail(ca);
                isOwnwerTarget = true;               
            }
            
            //} else {
            //   sendIt = false;
            //}
            //OAVERSANO 20/09/2018 : Nuovo Modello di Assistenza -- END
            Modello_di_Assistenza__mdt mdAss = [SELECT Id, Email_Template__c // NOPMD  Fix CRUD violation
                                                FROM Modello_di_Assistenza__mdt 
                                                WHERE DeveloperName = 'TemplateComunicazioneAgente' 
                                                LIMIT 1];
            
            emTemplate = mdAss.Email_Template__c;               
            etem       = [SELECT Markup, Subject, HtmlValue, body // NOPMD  Fix CRUD violation
                          FROM EmailTemplate 
                          WHERE DeveloperName =: emTemplate ];  
            
        }
        else if (profileName.equalsIgnoreCase('SmartCenter AMF Advisor') || profileName.equalsIgnoreCase('SmartCenter AMF Manager') || profileName.equalsIgnoreCase('SmartCenter Motor Advisor') ||
                 profileName.equalsIgnoreCase('SmartCenter Motor Manager') || profileName.equalsIgnoreCase('SmartCenter Non Motor Advisor') || profileName.equalsIgnoreCase('SmartCenter Non Motor Manager') ||
                 profileName.equalsIgnoreCase('AAI - Supporto HD1') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1') || profileName.equalsIgnoreCase('AAI - Supporto HD1 BIZ') ||
                 profileName.equalsIgnoreCase('AAI - Supporto HD1 BIZ - Buon Lavoro') ||
                 //MOSCATELLI 11/02/2019: Lob Contabilità -- START
                 profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contabilità') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contenzioso') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contabilita'))
                 //MMOSCATELLI 11/02/2019: Lob Contabilità -- END
        {
        	//OAVERSANO 24/10/2018 : ICF Close The Loop -- START
            if(ca.RecordType.Name == AP_Constants.rtCaseCloseTheLoop)
                rT = 'Agente';
            //OAVERSANO 24/10/2018 : ICF Close The Loop -- END
            if (rT.equalsIgnoreCase('Agente')) 
            {
                destinatario = 'Agente';
            	//OAVERSANO 24/10/2018 : ICF Close The Loop -- START
                List<QueueSobject> AgencyQueue = new List<QueueSobject>();
                String coda = '';
                if(ca.RecordType.Name == AP_Constants.rtCaseCloseTheLoop && String.isNotBlank(ca.Agency_Code__c))
                {
                    String queueName = 'Coda_Agenzia_Case_'+ca.Agency_Code__c;
                    AgencyQueue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName =:queueName  LIMIT 1]; // NOPMD  Fix CRUD violation
                    if(!AgencyQueue.IsEmpty())
                    {
                        coda = AgencyQueue[0].Queue.Id;
                        ca.OwnerId = coda;
                        ca.Status = 'In gestione all\'Agenzia';
                    }
                    
                    sendIt = false;
                }
                else
                {
                
            	//OAVERSANO 24/10/2018 : ICF Close The Loop -- END
                    ca.Status = 'Attesa Info Agente';    
                    
                    sendIt = true;
                    
                    Modello_di_Assistenza__mdt mdAss = [SELECT Id, Email_Template__c // NOPMD  Fix CRUD violation
                                                        FROM Modello_di_Assistenza__mdt 
                                                        WHERE DeveloperName = 'TemplateComunicazioneDaHD1' 
                                                        LIMIT 1];
                    
                    emTemplate = mdAss.Email_Template__c;                           
                    etem       = [SELECT Markup, Subject, HtmlValue, body // NOPMD  Fix CRUD violation
                                  FROM EmailTemplate 
                                  WHERE DeveloperName =: emTemplate ];
                    
					if(recordTypeName != 'Assistenza_Applicativa'){ //Giorgio Bonifazi - Caring Angel Fase 2 																						 
                    toUser = queryRunner.getUser(ca, false);}  
                } //OAVERSANO 24/10/2018 : ICF Close The Loop
            }
            else if (rT.equalsIgnoreCase('Supporto')) 
            {
                sendIt    = false;
                //MOSCATELLI_M 25/10/2018: NMA Business -- START
                List<QueueSobject> HD1Queue = new List<QueueSobject>();
                List<CaseTeamMember> HD1Owner = new List<CaseTeamMember>();
                String HD1PreviousOwner='';
                String HD1PreviousOwnerName='';
                String queueName = 'HD1_IT';
                String coda = '';
                
                if(profileName.equalsIgnoreCase('AAI - Supporto HD1 BIZ') ||
                   profileName.equalsIgnoreCase('AAI - Supporto HD1 BIZ - Buon Lavoro'))
                {   
                    if(Label=='Supporto HD1 IT')
                    {
                        destinatario = 'Primo Livello IT';
                        HD1Owner = [Select  memberid,member.name from CaseTeamMember where parentid=:cCase and TeamRole.Name = 'HD1 IT'  Order by createddate desc LIMIT 1]; // NOPMD  Fix CRUD violation
                        HD1Queue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName =:queueName  LIMIT 1]; // NOPMD  Fix CRUD violation
                        ca.Status='Inoltrato ad IT';
                        
                        if(!HD1Owner.isEmpty())
                        {
                            coda = HD1Owner[0].memberid;
                        }                        
                        else if(!HD1Queue.IsEmpty())
                        {
                            coda = HD1Queue[0].Queue.Id;
                        }
                        ca.OwnerId = coda;
                    }
                    //MOSCATELLI 11/02/2019: Lob Contabilità -- START
                    else if(Label=='Supporto Contabilità')
                    {
                        destinatario = 'Primo Livello Contabilità';
                        ca.Status='Inoltrato a Contabilità';
                        HD1Owner = [Select  memberid,member.name from CaseTeamMember where parentid=:cCase and TeamRole.Name = 'HD1 Contabilita'  Order by createddate desc LIMIT 1]; // NOPMD  Fix CRUD violation
                        HD1Queue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName ='HD1_Contabilita'  LIMIT 1];   // NOPMD  Fix CRUD violation                 

                        if(!HD1Owner.isEmpty())
                        {
                            coda = HD1Owner[0].memberid;
                        }                        
                        else if(!HD1Queue.IsEmpty())
                        {
                            coda = HD1Queue[0].Queue.Id;
                        }
                        ca.OwnerId = coda;                    
                    }
                    else if(Label=='Supporto Contenzioso')
                    {
                        destinatario = 'Primo Livello Contenzioso';
                        ca.Status='Inoltrato a Contenzioso';
                        HD1Owner = [Select  memberid from CaseTeamMember where parentid=:cCase and TeamRole.Name = 'HD1 Contenzioso'  Order by createddate desc LIMIT 1]; // NOPMD  Fix CRUD violation                      
                        HD1Queue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName ='HD1_Contenzioso'  LIMIT 1];     // NOPMD  Fix CRUD violation                                  
 
                        if(!HD1Owner.isEmpty())
                        {
                            coda = HD1Owner[0].memberid;
                        }                        
                        else if(!HD1Queue.IsEmpty())
                        {
                            coda = HD1Queue[0].Queue.Id;
                        }
                        ca.OwnerId = coda;                   
                    }
                    //MOSCATELLI 11/02/2019: Lob Contabilità -- END
                    //VIZZINI_D 24/06/2019: Lob Modulo di Calcolo
                    else if(Label == 'Supporto Modulo di Calcolo'){
                        
                        destinatario = 'Supporto Modulo di Calcolo';
                        ca.Status = 'In gestione Specialista';
                        List<QueueSobject> HD2MdcQueue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName =:'HD2_Modulo_di_Calcolo'  LIMIT 1]; // NOPMD  Fix CRUD violation
                        ca.OwnerId = HD2MdcQueue[0].Queue.Id;
                    }
                    else{
                        ca.Status = 'In gestione Specialista';
                        destinatario = 'Secondo Livello Business';
                    }
                }
                else if(profileName.equalsIgnoreCase('AAI - Supporto HD1') ||
                        profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1'))
                {
                    if(Label=='Supporto HD1 BIZ')
                    {
                        destinatario = 'Primo Livello Business';
                        ca.Status='Inoltrato a Linea di Business';
                        
                        HD1Owner = [Select  memberid,member.name from CaseTeamMember where parentid=:cCase and TeamRole.Name = 'HD1 BIZ'  Order by createddate desc LIMIT 1]; // NOPMD  Fix CRUD violation                       
                        
                        if(!HD1Owner.IsEmpty())
                        {
                            HD1PreviousOwner = HD1Owner[0].memberid;
                            ca.OwnerId = HD1PreviousOwner;
                        }  
                    }
                    //MOSCATELLI 11/02/2019: Lob Contabilità -- START
                    else if(Label=='Supporto Contabilità')
                    {
                        destinatario = 'Primo Livello Contabilità';
                        ca.Status='Inoltrato a Contabilità';
                        if(userRole!='HD1 Contabilita') //OAVERSANO 09/05/2019 : NMA LOB Vita
                        	HD1Owner = [Select  memberid,member.name from CaseTeamMember where parentid=:cCase and TeamRole.Name = 'HD1 Contabilita'  Order by createddate desc LIMIT 1]; // NOPMD  Fix CRUD violation
                        HD1Queue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName ='HD1_Contabilita'  LIMIT 1];  // NOPMD  Fix CRUD violation                  

                        if(!HD1Owner.isEmpty())
                        {
                            coda = HD1Owner[0].memberid;
                        }                        
                        else if(!HD1Queue.IsEmpty())
                        {
                            coda = HD1Queue[0].Queue.Id;
                        }
                        ca.OwnerId = coda;                    
                    }
                    else if(Label=='Supporto Contenzioso')
                    {
                        destinatario = 'Primo Livello Contenzioso';
                        ca.Status='Inoltrato a Contenzioso';
                        HD1Owner = [Select  memberid from CaseTeamMember where parentid=:cCase and TeamRole.Name = 'HD1 Contenzioso'  Order by createddate desc LIMIT 1]; // NOPMD  Fix CRUD violation                       
                        HD1Queue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName ='HD1_Contenzioso'  LIMIT 1];       // NOPMD  Fix CRUD violation                                
 
                        if(!HD1Owner.isEmpty())
                        {
                            coda = HD1Owner[0].memberid;
                        }                        
                        else if(!HD1Queue.IsEmpty())
                        {
                            coda = HD1Queue[0].Queue.Id;
                        }
                        ca.OwnerId = coda; 
                    } 
                    else if((userRole=='HD1 Contabilita' || userRole=='HD1 Contenzioso') && Label=='Supporto HD1 IT')
                    {
                        destinatario = 'Primo Livello IT';
                        HD1Owner = [Select  memberid,member.name from CaseTeamMember where parentid=:cCase and TeamRole.Name = 'HD1 IT'  Order by createddate desc LIMIT 1]; // NOPMD  Fix CRUD violation
                        HD1Queue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName =:queueName  LIMIT 1]; // NOPMD  Fix CRUD violation
                        ca.Status='Inoltrato ad IT';
                        
                        if(!HD1Owner.isEmpty())
                        {
                            coda = HD1Owner[0].memberid;
                        }                        
                        else if(!HD1Queue.IsEmpty())
                        {
                            coda = HD1Queue[0].Queue.Id;
                        }
                        ca.OwnerId = coda;
                    }
                    //MOSCATELLI 11/02/2019: Lob Contabilità -- END
                    //VIZZINI_D 24/06/2019: Lob Modulo di Calcolo
                    else if(Label == 'Supporto Modulo di Calcolo'){
                        
                        destinatario = 'Supporto Modulo di Calcolo';
                        ca.Status = 'In gestione Specialista';
                        List<QueueSobject> HD2MdcQueue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName =:'HD2_Modulo_di_Calcolo'  LIMIT 1]; // NOPMD  Fix CRUD violation
                        ca.OwnerId = HD2MdcQueue[0].Queue.Id;
                    }                   
                    else{
                    	//OAVERSANO 09/05/2019 : NMA LOB Vita -- START
                    	if(ca.LOB__c!=null && ca.LOB__c.equalsIgnoreCase(AP_constants.caseLobVita) && (userRole=='HD1 Contabilita'))
                    		destinatario = 'Secondo Livello Business';
                		else
                        	destinatario = 'Secondo Livello IT';
                        //OAVERSANO 09/05/2019 : NMA LOB Vita -- END
                        ca.Status = 'In gestione Specialista';
                    }
                }
                //MOSCATELLI 11/02/2019: Lob Contabilità -- START
                else if(profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contabilità') ||
                        profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contabilita') ||
                        profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contenzioso'))
                {
                    if(Label=='Supporto HD1 BIZ')
                    {
                        destinatario = 'Primo Livello Business';
                        ca.Status='Inoltrato a Linea di Business';
                        
                        HD1Owner = [Select  memberid,member.name from CaseTeamMember where parentid=:cCase and TeamRole.Name = 'HD1 BIZ'  Order by createddate desc LIMIT 1]; // NOPMD  Fix CRUD violation                       
                        
                        if(!HD1Owner.IsEmpty())
                        {
                            HD1PreviousOwner = HD1Owner[0].memberid;
                            ca.OwnerId = HD1PreviousOwner;
                        }  
                    }  
                    else if(Label=='Supporto HD1 IT')
                    {
                        destinatario = 'Primo Livello IT';
                        HD1Owner = [Select  memberid,member.name from CaseTeamMember where parentid=:cCase and TeamRole.Name = 'HD1 IT'  Order by createddate desc LIMIT 1]; // NOPMD  Fix CRUD violation
                        HD1Queue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName =:queueName  LIMIT 1]; // NOPMD  Fix CRUD violation
                        ca.Status='Inoltrato ad IT';
                        
                        if(!HD1Owner.isEmpty())
                        {
                            coda = HD1Owner[0].memberid;
                        }                        
                        else if(!HD1Queue.IsEmpty())
                        {
                            coda = HD1Queue[0].Queue.Id;
                        }
                        ca.OwnerId = coda;
                    }
                    else if(Label=='Supporto Contabilità')
                    {
                        destinatario = 'Primo Livello Contabilità';
                        ca.Status='Inoltrato a Contabilità';
                        if(userRole!='HD1 Contabilita') //OAVERSANO 09/05/2019 : NMA LOB Vita
                        	HD1Owner = [Select  memberid,member.name from CaseTeamMember where parentid=:cCase and TeamRole.Name = 'HD1 Contabilita'  Order by createddate desc LIMIT 1]; // NOPMD  Fix CRUD violation
                        HD1Queue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName ='HD1_Contabilita'  LIMIT 1];    // NOPMD  Fix CRUD violation                

                        if(!HD1Owner.isEmpty())
                        {
                            coda = HD1Owner[0].memberid;
                        }                        
                        else if(!HD1Queue.IsEmpty())
                        {
                            coda = HD1Queue[0].Queue.Id;
                        }
                        ca.OwnerId = coda;                    
                    }
                    else if(Label=='Supporto Contenzioso')
                    {
                        destinatario = 'Primo Livello Contenzioso';
                        ca.Status='Inoltrato a Contenzioso';
                        HD1Owner = [Select  memberid from CaseTeamMember where parentid=:cCase and TeamRole.Name = 'HD1 Contenzioso'  Order by createddate desc LIMIT 1];  // NOPMD  Fix CRUD violation                     
                        HD1Queue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName ='HD1_Contenzioso'  LIMIT 1]; // NOPMD  Fix CRUD violation                                      
 
                        if(!HD1Owner.isEmpty())
                        {
                            coda = HD1Owner[0].memberid;
                        }                        
                        else if(!HD1Queue.IsEmpty())
                        {
                            coda = HD1Queue[0].Queue.Id;
                        }
                        ca.OwnerId = coda;                   
                    }  
                    //OAVERSANO 09/05/2019 : NMA LOB Vita -- START
                    //VIZZINI_D 24/06/2019: Lob Modulo di Calcolo
                    else if(Label == 'Supporto Modulo di Calcolo'){
                        
                        destinatario = 'Supporto Modulo di Calcolo';
                        ca.Status = 'In gestione Specialista';
                        List<QueueSobject> HD2MdcQueue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName =:'HD2_Modulo_di_Calcolo'  LIMIT 1]; // NOPMD  Fix CRUD violation
                        ca.OwnerId = HD2MdcQueue[0].Queue.Id;
                    }
                    else{
                    	if(ca.LOB__c.equalsIgnoreCase(AP_constants.caseLobVita))
                    		destinatario = 'Secondo Livello Business';
                		else
                        	destinatario = 'Secondo Livello IT';
                        ca.Status = 'In gestione Specialista';
                    } 
                    //OAVERSANO 09/05/2019 : NMA LOB Vita -- END                                                       
                }
                //MOSCATELLI 11/02/2019: Lob Contabilità -- END
                else if(!profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD2 BIZ') && !profileName.equalsIgnoreCase('AAI - Supporto HD2 BIZ')){
                    //MOSCATELLI_M 25/10/2018: NMA Business -- END
                    ca.Status = 'In gestione Specialista';
                    destinatario = '';
                }
            }                                    
        }
        else if (profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD2') ||profileName.equalsIgnoreCase('AAI - Supporto HD2') || profileName.equalsIgnoreCase('Technical Office') ||
                 profileName.equalsIgnoreCase('System Administrator') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD2 BIZ') || profileName.equalsIgnoreCase('AAI - Supporto HD2 BIZ'))
        {
            //MOSCATELLI_M 25/10/2018: NMA Business -- START
            if (rT.equalsIgnoreCase('Agente') && (profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD2 BIZ') || profileName.equalsIgnoreCase('AAI - Supporto HD2 BIZ'))) 
            {
                destinatario = 'Agente';
                ca.Status = 'Attesa Info Agente';    
                
                sendIt = true;
                
                Modello_di_Assistenza__mdt mdAss = [SELECT Id, Email_Template__c // NOPMD  Fix CRUD violation
                                                    FROM Modello_di_Assistenza__mdt 
                                                    WHERE DeveloperName = 'TemplateComunicazioneDaHD1' 
                                                    LIMIT 1];
                
                emTemplate = mdAss.Email_Template__c;                           
                etem       = [SELECT Markup, Subject, HtmlValue, body // NOPMD  Fix CRUD violation
                              FROM EmailTemplate 
                              WHERE DeveloperName =: emTemplate ];
                
                toUser = queryRunner.getUser(ca, false);                  
            }
            //MOSCATELLI_M 25/10/2018: NMA Business -- END
            else
            {
                //VIZZINI_D 04/07/2019: NMA - Lob Modulo di Calcolo - START
                MPS_Code_Variables__c mdc_axa_role_config = MPS_Code_Variables__c.getValues('MdC AXA');
                List<String> mdc_axa_roles = new List<String>();
                for(String role : mdc_axa_role_config.Value__c.split(';')){
                    mdc_axa_roles.add(role);
                }
                //VIZZINI_D 04/07/2019: NMA - Lob Modulo di Calcolo - END

                //VIZZINI_D 25/06/2019: NMA - Lob Modulo di Calcolo - START
                if(Label == 'Supporto Modulo di Calcolo'){
                    
                    destinatario = 'Supporto Modulo di Calcolo';
                    ca.Status = 'In gestione Specialista';

                    if(mdc_axa_roles.contains(userRole)){
                        List<CaseTeamMember> HD2_RGI_Owner = [Select  memberid, member.name from CaseTeamMember where parentid=:cCase and member.userRole.Name = 'RGI'  Order by createddate desc LIMIT 1]; // NOPMD  Fix CRUD violation
                        ca.OwnerId = HD2_RGI_Owner[0].memberid;

                        ca.Da_testare_Modulo_di_Calcolo__c = false;
                    }
                    else{
                        List<QueueSobject> HD2MdcQueue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName =:'HD2_Modulo_di_Calcolo'  LIMIT 1]; // NOPMD  Fix CRUD violation
                        ca.OwnerId = HD2MdcQueue[0].Queue.Id;
                    }
                }
                //VIZZINI_D 25/06/2019: NMA - Lob Modulo di Calcolo - END
                //VIZZINI_D 26/06/2019: NMA - Lob Modulo di Calcolo - START
                else if(Label == 'Supporto Modulo di Calcolo AXA'){
                    
                    destinatario = 'Supporto Modulo di Calcolo AXA';
                    ca.Status = 'In gestione specialistica Ufficio tecnico';

                    List<QueueSobject> HD2MdcAXAQueue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName =:'HD2_Modulo_di_Calcolo_AXA'  LIMIT 1]; // NOPMD  Fix CRUD violation
                    ca.OwnerId = HD2MdcAXAQueue[0].Queue.Id;
                    
                    //VIZZINI_D 08/07/2019: NMA - Lob Modulo di Calcolo - START
                    MPS_Code_Variables__c businessHoursDefault = MPS_Code_Variables__c.getValues('BusinessHours_Default');
                    String bizHoursID = businessHoursDefault.Value__c;
                    Integer alert= Integer.valueOf(MPS_Code_Variables__c.getValues('ModuloDiCalcolo_tempiInoltroCoda').Value__c);
                    ca.TECH_Inoltro_Coda_HD2_MdC_AXA__c = BusinessHours.addGMT(bizHoursID,System.now(),((alert)*60 * 60 * 1000L));
                    //VIZZINI_D 08/07/2019: NMA - Lob Modulo di Calcolo - END

                    ca.Da_testare_Modulo_di_Calcolo__c = true;
                    ca.Supporto_MdC__c = true;

                    ca.Defect_Mdc__c = defectCheckbox;
                }
                //VIZZINI_D 26/06/2019: NMA - Lob Modulo di Calcolo - END
                else{//VIZZINI_D 25/06/2019: NMA - Lob Modulo di Calcolo

                    //VIZZINI_D 27/06/2019: NMA - Lob Modulo di Calcolo - START
                    if(mdc_axa_roles.contains(userRole))
                        ca.Da_testare_Modulo_di_Calcolo__c = false;
                    //VIZZINI_D 27/06/2019: NMA - Lob Modulo di Calcolo - END

                    sendIt = true;
                    ca.Status = 'Risposta specialista';
                    //MOSCATELLI_M 25/10/2018: NMA Business -- START
                    //List<CaseTeamMember> HD1Owner = [Select  memberid,member.name from CaseTeamMember where parentid=:cCase and TeamRole.Name = 'HD1' Order by createddate desc LIMIT 1];
                    String HD1Type = '';

                    if(profileName.indexOf('HD2 BIZ')<>-1){
                        //OAVERSANO 09/05/2019 : NMA LOB Vita -- START
                        if(ca.LOB__c!= null && ca.LOB__c.equalsIgnoreCase(AP_constants.caseLobVita))
                        {
                            HD1Type = 'HD1 Contabilita';
                            destinatario = 'Primo Livello Business';
                        }
                        else
                        {
                            HD1Type = 'HD1 BIZ';
                            destinatario = 'Primo Livello Business';
                        }
                        //OAVERSANO 09/05/2019 : NMA LOB Vita -- END
                    }
                    else{
                        HD1Type = 'HD1 IT';
                        destinatario = 'Primo Livello IT';
                    }
                    
                    //VIZZINI_D 01/07/2019: NMA - Lob Modulo di Calcolo - START
                    List<CaseTeamMember> HD1Owner = new List<CaseTeamMember>();

                    if(mdc_axa_roles.contains(userRole)){
                        /*User last_hd1_Owner = [SELECT Id FROM User WHERE Name =: ca.Owner_HD1__c];
                        String lastHD1Id = last_hd1_Owner.Id;*/
                        String lastHD1Id = ca.Last_Advisor__c;
                        HD1Owner = [SELECT  memberid, member.name, TeamRole.Name FROM CaseTeamMember WHERE (parentid=:cCase AND memberid =: lastHD1Id)  LIMIT 1]; // NOPMD  Fix CRUD violation
                        if(!HD1Owner.isEmpty()){
                            if(HD1Owner[0].TeamRole.Name == 'HD1 IT')
                                destinatario = 'Primo Livello IT';
                            else if(HD1Owner[0].TeamRole.Name == 'HD1 Contabilita')
                                destinatario = 'Primo Livello Contabilità';
                            else if(HD1Owner[0].TeamRole.Name == 'HD1 Contenzioso')
                                destinatario = 'Primo Livello Contenzioso';
                            else
                                destinatario = 'Primo Livello Business';
                        }
                    }
                    else{ //VIZZINI_D 01/07/2019: NMA - Lob Modulo di Calcolo - END
                    	if(ca.supporto_mdc__c == true && userRole == 'RGI'){ //allow to assign cases to others HD1
                    		HD1Owner = [Select  memberid,member.name from CaseTeamMember where parentid=:cCase and TeamRole.Name like 'HD1%'  Order by lastModifieddate desc LIMIT 1]; // NOPMD  Fix CRUD violation      
                    	}else{
                        	HD1Owner = [Select  memberid,member.name from CaseTeamMember where parentid=:cCase and TeamRole.Name =:HD1Type  Order by createddate desc LIMIT 1];  // NOPMD  Fix CRUD violation   
                    	}  
                    }     
                    
                    //MOSCATELLI_M 25/10/2018: NMA Business -- END
                    if(!HD1Owner.isEmpty())
                    {
                        HD1OwnerId = HD1Owner[0].memberid;
                        HD1OwnerName = HD1Owner[0].member.name;
                        ca.OwnerId = HD1OwnerId;
                    }
                    //Id roleId = [SELECT UserRoleId FROM User WHERE Id =: UserInfo.getUserId()].UserRoleId;
                    //userRole  = [SELECT Name FROM UserRole WHERE Id =: roleId].Name;
                    
                    Modello_di_Assistenza__mdt mdAss = [SELECT Id, Email_Template__c // NOPMD  Fix CRUD violation
                                                        FROM Modello_di_Assistenza__mdt 
                                                        WHERE DeveloperName = 'TemplateComunicazioneDaHD2' 
                                                        LIMIT 1];
                    emTemplate = mdAss.Email_Template__c;
                    etem       = [SELECT Markup, Subject, HtmlValue, body // NOPMD  Fix CRUD violation
                                FROM EmailTemplate 
                                WHERE DeveloperName =: emTemplate ];        
                }//VIZZINI_D 25/06/2019: NMA - Lob Modulo di Calcolo  
            }
        }
        //OAVERSANO 17/10/2018 : Caring Angel -- START
        // Giorgio Bonifazi - Caring Angel FIX
        else if (profileName.equalsIgnoreCase('Caring Angel - Supporto HD1') || profileName.equalsIgnoreCase('Caring Angel - Supporto HD1 Supervisor')||profileName.equalsIgnoreCase('Caring Angel - Supervisor') )
        {
            sendIt = false;
            List<QueueSobject> HD2Queue = [SELECT Id, Queue.Name, Queue.Id FROM QueueSobject WHERE Queue.DeveloperName = 'HD2_Caring_Angel'  LIMIT 1]; // NOPMD  Fix CRUD violation
            if(!HD2Queue.isEmpty())
            {
                ca.Status = AP_Constants.caseStatusAssIILivello;
                ca.OwnerId = HD2Queue[0].Queue.Id;
            }
            rT = 'Supporto';
        }
        //OAVERSANO 17/10/2018 : Caring Angel -- END
        //OAVERSANO 19/09/2018 : Nuovo Modello di Assistenza -- START
        String profileAlias;
        //OAVERSANO 19/09/2018 : Nuovo Modello di Assistenza -- END
        if(profileName.contains('Vendite'))
        {
            profileAlias = 'Agente';
            userRole = '-';
        }            
        //else if(profileName.contains('HD1')) //OAVERSANO 24/10/2018 : ICF Close The Loop
        else if(profileName.contains('HD1') || profileName.contains('SmartCenter')) //OAVERSANO 24/10/2018 : ICF Close The Loop
            profileAlias = 'Primo Livello';
        else if(profileName.contains('HD2'))
            profileAlias = 'Secondo Livello';
        
        //MOSCATELLI_M 25/10/2018: NMA Business -- START
        String TechProfileName = '';
        
        if(profileName.contains('Vendite'))
            TechProfileName = 'Agente';
        else if(profileName.contains('HD1 BIZ'))
            TechProfileName = 'Primo Livello Business';
        //MOSCATELLI 11/02/2019: Lob Contabilità -- START
        //else if(!profileName.contains('HD1 BIZ') && profileName.contains('HD1'))
        else if(!profileName.contains('HD1 BIZ') && profileName.contains('HD1') && userRole!='HD1 Contabilita' && userRole!='HD1 Contenzioso')
        //MOSCATELLI 11/02/2019: Lob Contabilità -- END
            TechProfileName = 'Primo Livello IT';   
        else if(!profileName.contains('HD2 BIZ') && profileName.contains('HD2'))         
            TechProfileName = 'Secondo Livello IT';   
        else if(profileName.contains('HD2 BIZ'))
            TechProfileName = 'Secondo Livello Business';            
        //MOSCATELLI_M 25/10/2018: NMA Business -- END

        //MOSCATELLI 11/02/2019: Lob Contabilità -- START
        else if(profileName.contains('HD1 Contabilità') || userRole =='HD1 Contabilita')
            TechProfileName = 'Primo Livello Contabilità';
        else if(profileName.contains('HD1 Contenzioso') || userRole =='HD1 Contenzioso')
            TechProfileName = 'Primo Livello Contenzioso';
        //MOSCATELLI 11/02/2019: Lob Contabilità -- END
        
        String description = '';
        String attachmentnames ='';
        String commenttype='';
        
        if(attachmentList.size()>0)
        {
            for(String s: attachmentList)
            {
                if(String.isNotBlank(attachmentnames))
                    attachmentnames+=', '+s;
                else
                    attachmentnames = s;
            }
        }
        
        //system.debug(cmt.length());
        if(ca.RecordType.Name == AP_Constants.rtCaseCloseTheLoop)
        {
            if(cmt.length()>0){
                description= String.valueOf(cmt);
                system.debug('description - ENTER IF description: '+description);
            }

            commenttype='Supporto richiesto ad Agenzia';
        }
        else
        {
            if((Integer.valueOf(numberOfAttachment) > 0) && (cmt.length() > 0)){           
                //description = 'E\' stato inserito il seguente commento: ' + String.valueOf(cmt) +', e sono stati forniti i seguenti allegati: '+attachmentnames;
                description = String.valueOf(cmt);
                commenttype = 'Inserimento commento e allegato';
            } else if(cmt.length() != 0){
                //description = 'E\' stato inserito il seguente commento: ' + String.valueOf(cmt);
                description = String.valueOf(cmt);
                commenttype = 'Inserimento commento';

                //MOSCATELLI 11/02/2019: Lob Contabilità -- START
                Integer currentIntAgente = Integer.valueOf(ca.Interazioni_Agente__c);
                //MDANTONIO 08/04/2019: bug fix - start
                if(currentIntAgente == null){
                    currentIntAgente = 0;
                }
                //MDANTONIO 08/04/2019: bug fix - end

                if(oldCaseStatus != 'Attesa Info Agente' && TechProfileName == 'Agente')
                {
                    ca.Interazioni_Agente__c = currentIntAgente+1;
                }
                //MOSCATELLI 11/02/2019: Lob Contabilità -- END
                
                //system.debug('2');
            } else if ((Integer.valueOf(numberOfAttachment) > 0) && (!(cmt.length() > 0))) {
                description = 'Sono stati inseriti i seguenti nuovi allegati: '+attachmentnames;
                commenttype = 'Condivisione allegato';
                
                
            } else{
                description = 'Non sono stati inseriti commenti / allegati ';
                commenttype = '';

            }
        }
        
        //System.debug(' ===> description: ' + description);
        
        //System.debug(' ===> rT: ' + rT);
        String rTId = [SELECT Id FROM RecordType WHERE DeveloperName =: rT].Id;
        Storico_conversazioni__c sc = new Storico_conversazioni__c();
        //OAVERSANO 19/09/2018 : Nuovo Modello di Assistenza -- START
        //sc = new Storico_conversazioni__c( Description__c = description, Connected_case__c = cCase, CaseStatus__c = ca.Status, Type__c = commenttype, RecordTypeId = rTId, Profilo_utente__c = profileName, Ruolo_utente__c = userRole );
        //sc = new Storico_conversazioni__c( Description__c = description, Connected_case__c = cCase, CaseStatus__c = ca.Status, Type__c = commenttype, RecordTypeId = rTId, Profilo_utente__c = profileAlias, Ruolo_utente__c = userRole, Tech_Profilo_Utente__c = TechProfileName ); //OAVERSANO 10/12/2018 : modifica CaseStatus Storico Conversazioni
        //MDANTONIO 03/04/2019 : Tracciamento destinatario commento - start
        //sc = new Storico_conversazioni__c( Description__c = description, Connected_case__c = cCase, CaseStatus__c = oldCaseStatus, Type__c = commenttype, RecordTypeId = rTId, Profilo_utente__c = profileAlias, Ruolo_utente__c = userRole, Tech_Profilo_Utente__c = TechProfileName ); //OAVERSANO 10/12/2018 : modifica CaseStatus Storico Conversazioni
        //String destinatario = ModelloDiAssistenzaUtils.getDestinatario(profileName, userRole, ca.OwnerId);
		// Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - START -->																
        sc = new Storico_conversazioni__c( Description__c = description, Connected_case__c = cCase, CaseStatus__c = oldCaseStatus, Type__c = commenttype, RecordTypeId = rTId, Profilo_utente__c = profileAlias, Ruolo_utente__c = userRole, Tech_Profilo_Utente__c = TechProfileName, Destinatario_Commento__c = destinatario, /*Defect_Mdc__c = defectCheckbox,*/Motivo_trasferimento__c = motivoTrasferimento); //OAVERSANO 10/12/2018 : modifica CaseStatus Storico Conversazioni
		// Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - END -->															  
																		  
        //MDANTONIO 03/04/2019 : Tracciamento destinatario commento - end
        //OAVERSANO 19/09/2018 : Nuovo Modello di Assistenza -- END
        
        Boolean checkUpsert = false;
        Savepoint sp = Database.setSavepoint();
        try
        {         
            checkUpsert = true;  
            insert sc; // NOPMD  Fix CRUD violation
            update ca;
            //OAVERSANO 11/10/2018 : Modello di Assistenza -- START
            if (skipValidation!=null && (profileName.equalsIgnoreCase('AAI - Vendite solo Assistenza') || profileName.equalsIgnoreCase('AAI - Vendite Base') || profileName.equalsIgnoreCase('AAI - Vendite Avanzato') || profileName.equalsIgnoreCase('AAI - Vendite No Accordo Digitale')))
            {
                skipValidation.BypassValidationRules__c= false;
                update skipValidation; // NOPMD  Fix CRUD violation
            }
            //OAVERSANO 11/10/2018 : Modello di Assistenza -- END
        }
        catch(exception ex)
        {
            Output = ex.getmessage();
            checkUpsert = false;
            system.debug('errore: ' +ex.getmessage());
            Database.rollback(sp);
            
        }
        
        try
        {       
            system.debug('sendIt: '+sendIt+' checkUpsert : '+checkUpsert);
            if(sendIt && checkUpsert){
                
                String OrgEmail    = (MPS_Code_Variables__c.getAll()).get('ModelloAssistenzaOrgEmail') != null ? (MPS_Code_Variables__c.getAll()).get('ModelloAssistenzaOrgEmail').Value__c : null;
                String UrlNFE;
                List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String htmlBody = etem.HtmlValue;
                String htmlBody2 = htmlBody;//MOSCATELLI 11/02/2019: Lob Contabilità
                String subject = etem.Subject;
                String body    = etem.body;
                subject  = subject.replace('{!Case.CaseNumber}', ca.CaseNumber);
                subject  = subject.replace('{!Case.Status}', ca.Status);
                //OAVERSANO 20/09/2018 : Nuovo Modello di Assistenza -- START
                htmlBody = htmlBody.replace('{!Case.User__c}', (isOwnwerTarget?'':String.isBlank(HD1OwnerId)?toUser.Name:HD1OwnerName));
                body     = body.replace('{!Case.User__c}', (isOwnwerTarget?'':String.isBlank(HD1OwnerId)?toUser.Name:HD1OwnerName));
                //OAVERSANO 20/09/2018 : Nuovo Modello di Assistenza -- END
                htmlBody = htmlBody.replace('{!Case.CaseNumber}', ca.CaseNumber);    
                body     = body.replace('{!Case.CaseNumber}', ca.CaseNumber);
                htmlBody = htmlBody.replace('{!Case.Description}', description);    
                body     = body.replace('{!Case.Description}', description);
                
                /*String url = '';
if(Network.communitiesLanding() <> null) {
url = ((Network.communitiesLanding()).geturl()).replace('home/home.jsp',''+ca.Id);
} else {
String PartnerUrl = [Select BaseURL__c from User where id=:UserInfo.getUserId() limit 1].BaseURL__c;
url = (PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+''+ca.Id;
}*/ 
                
                String url = '';
                if (profileName.equalsIgnoreCase('AAI - Vendite solo Assistenza') || profileName.equalsIgnoreCase('AAI - Vendite Base') || profileName.equalsIgnoreCase('AAI - Vendite Avanzato') || profileName.equalsIgnoreCase('AAI - Vendite No Accordo Digitale'))
                {
                    // Mydomain
                    url = [SELECT OrgLink__c 
                           FROM Modello_di_Assistenza__mdt 
                           WHERE DeveloperName = 'Redirect'
                           LIMIT 1].OrgLink__c;
                    url = url + cCase;
                }
                else
                {
                    if (rT.equalsIgnoreCase('Supporto')) 
                    {
                        // Mydomain
                        url = [SELECT OrgLink__c 
                               FROM Modello_di_Assistenza__mdt 
                               WHERE DeveloperName = 'Redirect'
                               LIMIT 1].OrgLink__c;    
                        url = url + cCase;
                    }
                    else
                    {
                        // Community
                        url = [SELECT OrgLink__c 
                               FROM Modello_di_Assistenza__mdt 
                               WHERE DeveloperName = 'RedirectCommunity'
                               LIMIT 1].OrgLink__c;    
                        url = url + cCase;                         
                        
                        urlNFE =    [SELECT OrgLink__c 
                                    FROM Modello_di_Assistenza__mdt 
                                    WHERE DeveloperName = 'RedirectCommunityNFE'
                                    LIMIT 1].OrgLink__c + cCase;
                    }                    
                }


                if(htmlBody.contains('{!Case.Link1}')){
                    htmlBody = htmlBody.replace('{!Case.Link1}', url );
                    htmlBody = htmlBody.replace('{!Case.Link2}', urlNFE ); 
                    body = body.replace('{!Case.Link1}', url ); 
                    body = body.replace('{!Case.Link2}', urlNFE ); 
                }
                else{
                htmlBody = htmlBody.replace('{!Case.Link}', url);    
                body     = body.replace('{!Case.Link}', url);   
                } 
                
                email.setHtmlBody(htmlBody);
                email.setSubject(subject);
                //OAVERSANO 20/09/2018 : Nuovo Modello di Assistenza -- START
                system.debug('isOwnwerTarget: '+isOwnwerTarget+' toQueueEmail : '+toQueueEmail);

                email.saveAsActivity = false;
                
                //MOSCATELLI 11/02/2019: Lob Contabilità -- START
                if(String.isNotBlank(OrgEmail))
                    email.setOrgWideEmailAddressId(OrgEmail);
                //MOSCATELLI 11/02/2019: Lob Contabilità -- END
                
                if(isOwnwerTarget)
                {
                    List<String> toAddresses = new List<String>();
                    toAddresses.add(toQueueEmail);
                    email.setToAddresses(toAddresses);
                }
                else
                {
                    email.setTargetObjectId((String.isBlank(HD1OwnerId)?toUser.Id:HD1OwnerId));
                }
                //OAVERSANO 20/09/2018 : Nuovo Modello di Assistenza -- END
                
                //MOSCATELLI 11/02/2019: Lob Contabilità -- START
                /*email.saveAsActivity = false;
                
                if(String.isNotBlank(OrgEmail))
                    email.setOrgWideEmailAddressId(OrgEmail);*/
                //MOSCATELLI 11/02/2019: Lob Contabilità -- END
                
                listEmail.add(email);
                system.debug('##listEmail: '+listEmail);
                Messaging.SendEmailResult [] results = queryRunner.sendEmail(listEmail);
                
                for(Messaging.SendEmailResult re : results)
                {
                    if (re.success) {
                        System.debug('The email was sent successfully.');
                    } else {
                        System.debug('The email failed to send: ' + re.errors[0].message);
                    }
                }

               //MOSCATELLI 11/02/2019: Lob Contabilità -- START
                if(!toTeamMembers.isEmpty())
                {
                    for(CaseTeamMember u : toTeamMembers)
                    {
                        List<Messaging.SingleEmailMessage> listEmail2 = new List<Messaging.SingleEmailMessage>();
                        Messaging.SingleEmailMessage email2 = new Messaging.SingleEmailMessage();
                        String Html3 =htmlBody2;
                        email2.setSubject(subject);
                        email2.setTargetObjectId(u.Memberid);
                        Html3 = Html3.replace('{!Case.User__c}', u.Member.Name);
                        //OAVERSANO 19/02/2019
                     	Html3 = Html3.replace('{!Case.CaseNumber}', ca.CaseNumber);  
                     	Html3 = Html3.replace('{!Case.Description}', description);
                     	Html3 = Html3.replace('{!Case.Link}', url);    
                     	//OAVERSANO 19/02/2019
                        email2.setHtmlBody(Html3);
                        email2.setOrgWideEmailAddressId(OrgEmail);
                        email2.saveAsActivity = false;
                        listEmail2.add(email2);
                        Messaging.SendEmailResult [] results2 = queryRunner.sendEmail(listEmail2);
                     
                        for(Messaging.SendEmailResult re : results2)
                        {
                            if (re.success) {
                                System.debug('The email was sent successfully.');
                            } else {
                                System.debug('The email failed to send: ' + re.errors[0].message);
                            }
                        }                        
                    }
                } 
                //MOSCATELLI 11/02/2019: Lob Contabilità -- END                    
            }            
        }
        catch(exception ex)
        {
                ApplicationLogHelper.ERROR('NewCommentAndAttachmentServer', ex.getMessage(), ex.getStackTraceString());
            
            //Output = ex.getmessage();
        }
        return Output;
    }
    
    @AuraEnabled
    //public static boolean checkProfileSupportHD1()
    public static boolean checkProfileSupportHD1(String caseId) //OAVERSANO 24/10/2018 : ICF Close The Loop
    {
        Id id1 = UserInfo.getProfileId();
        String profileName = [Select Name from Profile WHERE Id =: id1  LIMIT 1].Name; // NOPMD  Fix CRUD violation
        //OAVERSANO 24/10/2018 : ICF Close The Loop -- START
        Boolean isCTL = false;
        if(String.isNotBlank(caseId))
        {
            List<Case> csList = [SELECT Id, RecordType.Name FROM Case WHERE id =:caseId LIMIT 1];
            if(!csList.isEmpty())
            {
                if(csList[0].RecordType.Name == AP_Constants.rtCaseCloseTheLoop)
                    isCTL = true;
            }
        }
        //OAVERSANO 24/10/2018 : ICF Close The Loop -- END
        //System.debug(' ===> profileName: ' + profileName);
        if (!isCTL
            &&
            (profileName.equalsIgnoreCase('SmartCenter AMF Advisor') || profileName.equalsIgnoreCase('SmartCenter AMF Manager') || profileName.equalsIgnoreCase('SmartCenter Motor Advisor') ||
             profileName.equalsIgnoreCase('SmartCenter Motor Manager') || profileName.equalsIgnoreCase('SmartCenter Non Motor Advisor') || profileName.equalsIgnoreCase('SmartCenter Non Motor Manager') ||
             profileName.equalsIgnoreCase('AAI - Supporto HD1') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1')))
        { 
            return true; 
        }
        
        return false;
    }
    
    
    @AuraEnabled
    public static boolean checkProfileHD2()
    {
        Id id1 = UserInfo.getProfileId();
        String profileName = [Select Name from Profile WHERE Id =: id1 LIMIT 1].Name;
        
        if (profileName.equalsIgnoreCase('Technical Office') || profileName.equalsIgnoreCase('AAI - Supporto HD2') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD2') ||
            //MOSCATELLI_M 25/10/2018: NMA Business -- START
            profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD2 BIZ') || profileName.equalsIgnoreCase('AAI - Supporto HD2 BIZ')) 
            //MOSCATELLI_M 25/10/2018: NMA Business -- END
        { 
            return true;
        }
        
        return false;
    }
    //Giorgio Bonifazi - START

    @AuraEnabled
    public static boolean checkCaringAngel(Id caseId)
    {
        String rtName = [Select RecordType.Name from case WHERE Id =: caseId].RecordType.Name;

        return rtName.containsIgnoreCase('Caring Angel');
    }
    
    @AuraEnabled
    public static boolean checkSmartCenter()
    {
        Id id1 = UserInfo.getProfileId();
        String profileName = [Select Name from Profile WHERE Id =: id1 LIMIT 1].Name;

        if(profileName.indexOf('SmartCenter') != -1){

            return true;
        }
            return false;
    }

    // Giorgio Bonifazi - END
    @AuraEnabled
    public static boolean verificaProfiloAgente()
    {
        Id id1 = UserInfo.getProfileId();
        String profileName = [Select Name from Profile WHERE Id =: id1 LIMIT 1].Name;
        
        if (profileName.equalsIgnoreCase('AAI - Vendite solo Assistenza') || profileName.equalsIgnoreCase('AAI - Vendite Base') || profileName.equalsIgnoreCase('AAI - Vendite Avanzato') || profileName.equalsIgnoreCase('AAI - Vendite No Accordo Digitale') || profileName.equalsIgnoreCase('NFE - AAI - Vendite solo Assistenza') || profileName.equalsIgnoreCase('NFE - AAI - Vendite Base') || profileName.equalsIgnoreCase('NFE - AAI - Vendite Avanzato'))
        { 
            return true;
        }
        
        return false;
    }
    
    
    @AuraEnabled
    //public static boolean checkError(String cCase)
    public static CheckErrorResult checkError(String cCase)
    {
        
        /*String status      = [SELECT Status FROM Case WHERE Id =: cCase LIMIT 1].Status;
Id id1             = UserInfo.getProfileId();
String profileName = [Select Name from Profile WHERE Id =: id1 LIMIT 1].Name;*/
        CheckErrorResult CheckErr = new CheckErrorResult();
        //OAVERSANO 24/10/2018 : ICF Close The Loop -- START
        //Case theconnectedCase      = [SELECT Status, OwnerId FROM Case WHERE Id =: cCase LIMIT 1];	
        Case theconnectedCase      = [SELECT Status, OwnerId, RecordType.Name, Agency_Code__c FROM Case WHERE Id =: cCase LIMIT 1];	
        Boolean isCTL = false;
        if(theconnectedCase.RecordType.Name == AP_Constants.rtCaseCloseTheLoop)
            isCTL = true;
        //OAVERSANO 24/10/2018 : ICF Close The Loop -- END
        string status = theconnectedCase.status;
        Id ownerid = theconnectedCase.OwnerId;
        Id id1             = UserInfo.getProfileId();
        Id userid = UserInfo.getUserId();
        //MOSCATELLI 11/02/2019: Lob Contabilità -- START
        //String profileName = [Select Name from Profile WHERE Id =: id1 LIMIT 1].Name; 
        String profileName='';
        String userRole='';
        User CurrentUsr = [Select Profile.Name,UserRole.Name from User WHERE Id =: userid  LIMIT 1]; // NOPMD  Fix CRUD violation
        profileName = CurrentUsr.Profile.Name;
        userRole = CurrentUsr.UserRole.Name; 
        //MOSCATELLI 11/02/2019: Lob Contabilità -- END
        
        if (profileName.equalsIgnoreCase('AAI - Vendite solo Assistenza') || profileName.equalsIgnoreCase('AAI - Vendite Base') || profileName.equalsIgnoreCase('AAI - Vendite Avanzato') || profileName.equalsIgnoreCase('AAI - Vendite No Accordo Digitale') || profileName.equalsIgnoreCase('NFE - AAI - Vendite solo Assistenza') || profileName.equalsIgnoreCase('NFE - AAI - Vendite Base') || profileName.equalsIgnoreCase('NFE - AAI - Vendite Avanzato'))
        { 
            if (status.equalsIgnoreCase('Risolto') || status.equalsIgnoreCase('Chiuso in autonomia') ||  
                status.equalsIgnoreCase('Risolto in autonomia dall\'Agente') || status.equalsIgnoreCase('Cancelled') ||
                status.equalsIgnoreCase('Closed') || status.equalsIgnoreCase('Soluzione proposta') /*|| status.equalsIgnoreCase('Open') || status.equalsIgnoreCase('Aperto')*/ /*|| 
status.equalsIgnoreCase('In gestione Specialista') || status.equalsIgnoreCase('Risposta Specialista'*/)
            {
                //return true;
                CheckErr.show = true;
                CheckErr.message='Attenzione! L\'attuale stato della richiesta non consente l\'inserimento di un nuovo commento / allegato';
                return CheckErr;
            }
        }
        
        else if (profileName.equalsIgnoreCase('SmartCenter AMF Advisor') || profileName.equalsIgnoreCase('SmartCenter AMF Manager') || profileName.equalsIgnoreCase('SmartCenter Motor Advisor') ||
                 profileName.equalsIgnoreCase('SmartCenter Motor Manager') || profileName.equalsIgnoreCase('SmartCenter Non Motor Advisor') || profileName.equalsIgnoreCase('SmartCenter Non Motor Manager') ||
                 profileName.equalsIgnoreCase('AAI - Supporto HD1') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1') ||
                 //MOSCATELLI_M 25/10/2018: NMA Business -- START
                 profileName.equalsIgnoreCase('AAI - Supporto HD1 BIZ') || profileName.equalsIgnoreCase('AAI - Supporto HD1 BIZ - Buon Lavoro') ||
                //MOSCATELLI_M 25/10/2018: NMA Business -- END

                //MOSCATELLI 11/02/2019: Lob Contabilità -- START
                profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contabilità') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contenzioso') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contabilita'))               
                //MOSCATELLI 11/02/2019: Lob Contabilità -- END
        {
            if(ownerid !=userid)
            {
                CheckErr.show = true;
                CheckErr.message='Attenzione ! E\' necessario prendere in carico la richiesta al fine di inserire un commento / allegato';
                return CheckErr;
            }
            //OAVERSANO 24/10/2018 : ICF Close The Loop -- START
            if(isCTL)
            {
                if (status.equalsIgnoreCase('Cancelled') || status.equalsIgnoreCase('Closed') || status.equalsIgnoreCase('Open') || status.equalsIgnoreCase('Aperto') || status.equalsIgnoreCase(AP_Constants.caseStatusGestioneAgente)) 
                {
                    //return true;
                    CheckErr.show = true;
                    CheckErr.message='Attenzione! L\'attuale stato della richiesta non consente l\'inserimento di un nuovo commento / allegato';
                    return CheckErr;
                } 
                if(String.isNotBlank(theconnectedCase.Agency_Code__c))
                {
                    String queueName = 'Coda_Agenzia_Case_'+theconnectedCase.Agency_Code__c;
                    List<QueueSobject> AgencyQueue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName =:queueName  LIMIT 1]; // NOPMD  Fix CRUD violation
                    if(AgencyQueue.IsEmpty())
                    {
                        CheckErr.show = true;
                        CheckErr.message='Attenzione ! Non è possibile inoltrare il Case  all\'agenzia in quanto la stessa non è nota.';
                        return CheckErr;
                    } 
                }
                else if(String.isBlank(theconnectedCase.Agency_Code__c))
                {
                    CheckErr.show = true;
                    CheckErr.message='Attenzione ! Non è possibile inoltrare il Case  all\'agenzia in quanto la stessa non è nota';
                    return CheckErr;
                }
            }    
            else
            {
                if (status.equalsIgnoreCase('Risolto') || status.equalsIgnoreCase('Chiuso in autonomia') || 
                    status.equalsIgnoreCase('Risolto in autonomia dall\'Agente') || status.equalsIgnoreCase('Cancelled') ||
                    status.equalsIgnoreCase('Closed') || status.equalsIgnoreCase('Open') || status.equalsIgnoreCase('Aperto') || status.equalsIgnoreCase('Soluzione proposta') || 
                    status.equalsIgnoreCase('Attesa Info Agente') ||
                    //MOSCATELLI_M 25/10/2018: NMA Business -- START

                    //MOSCATELLI 11/02/2019: Lob Contabilità -- START
                    /*(status.equalsIgnoreCase('Inoltrato ad IT') && (profileName.equalsIgnoreCase('AAI - Supporto HD1 BIZ') || profileName.equalsIgnoreCase('AAI - Supporto HD1 BIZ - Buon Lavoro'))) || 
                    (status.equalsIgnoreCase('Inoltrato a Linea di Business') && (profileName.equalsIgnoreCase('AAI - Supporto HD1') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1'))) ||*/
                    (status.equalsIgnoreCase('Inoltrato ad IT') && ((userRole =='HD1 Contenzioso') || (userRole =='HD1 Contabilita') || profileName.equalsIgnoreCase('AAI - Supporto HD1 BIZ') || profileName.equalsIgnoreCase('AAI - Supporto HD1 BIZ - Buon Lavoro') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contabilità') ||profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contabilita') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contenzioso'))) || 
                    (status.equalsIgnoreCase('Inoltrato a Linea di Business') && ((userRole =='HD1 Contenzioso') || (userRole =='HD1 Contabilita') || profileName.equalsIgnoreCase('AAI - Supporto HD1') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contabilità') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contabilita') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contenzioso'))) ||                    
                    (status.equalsIgnoreCase('Inoltrato a Contabilità') && ((userRole =='HD1 Contenzioso') || (profileName.equalsIgnoreCase('AAI - Supporto HD1') && (userRole !='HD1 Contabilita'))|| profileName.equalsIgnoreCase('AAI - Supporto HD1 BIZ') || profileName.equalsIgnoreCase('AAI - Supporto HD1 BIZ - Buon Lavoro') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contenzioso'))) || 
                    (status.equalsIgnoreCase('Inoltrato a Contenzioso') && ((userRole =='HD1 Contabilita') || (profileName.equalsIgnoreCase('AAI - Supporto HD1') && (userRole !='HD1 Contenzioso'))|| profileName.equalsIgnoreCase('AAI - Supporto HD1 BIZ') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contabilità') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD1 Contabilita')))                                       
                    //MOSCATELLI 11/02/2019: Lob Contabilità -- END

                    //MOSCATELLI_M 25/10/2018: NMA Business -- END
                   ) 
                {
                    //return true;
                    CheckErr.show = true;
                    CheckErr.message='Attenzione! L\'attuale stato della richiesta non consente l\'inserimento di un nuovo commento / allegato';
                    return CheckErr;
                }  
            }  
            //OAVERSANO 24/10/2018 : ICF Close The Loop -- END
        }
        
        else if (profileName.equalsIgnoreCase('Technical Office') || profileName.equalsIgnoreCase('AAI - Supporto HD2') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD2')  ||
                 //MOSCATELLI_M 25/10/2018: NMA Business -- START
                 profileName.equalsIgnoreCase('AAI - Supporto HD2 BIZ') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD2 BIZ'))
            //MOSCATELLI_M 25/10/2018: NMA Business -- END)
        {
            if(ownerid !=userid)
            {
                CheckErr.show = true;
                CheckErr.message='Attenzione ! E\' necessario prendere in carico la richiesta al fine di inserire un commento / allegato';
                return CheckErr;
            } 
            else if ((!status.equalsIgnoreCase('In gestione all\'HD3') && !status.equalsIgnoreCase('In gestione Specialista') && !status.equalsIgnoreCase('In gestione specialistica Ufficio tecnico'))) 
            {
                if(status.equalsIgnoreCase('Soluzione rifiutata') || status.equalsIgnoreCase(AP_Constants.caseStatusInfoAgenteRicevute) 
                //OAVERSANO 17/12/2018 : Enhancement NMA Biz -- START
                || status.equalsIgnoreCase(AP_Constants.caseStatusInoltratoIT) || status.equalsIgnoreCase(AP_Constants.caseStatusInoltratoBusiness)
                || status.equalsIgnoreCase(AP_Constants.caseStatusAssigned) || status.equalsIgnoreCase(AP_Constants.caseStatusAttesaInfoAgente)
                || status.equalsIgnoreCase('Preso in carico'))
                //OAVERSANO 17/12/2018 : Enhancement NMA Biz -- END
                {
                    if(!profileName.equalsIgnoreCase('AAI - Supporto HD2 BIZ') && !profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD2 BIZ'))
                    {
                        CheckErr.show = true;
                        CheckErr.message='Attenzione ! L\'attuale stato della richiesta non consente l\'inserimento di un nuovo commento / allegato';
                        return CheckErr;
                    }
                    else
                    {
                        CheckErr.show = false;
                        return CheckErr;
                    }
                }
                else
                {
                    CheckErr.show = true;
                    CheckErr.message='Attenzione! L\'attuale stato della richiesta non consente l\'inserimento di un nuovo commento / allegato';
                    return CheckErr;                    
                }
                //return true;
            }          
        }
        //OAVERSANO 17/10/2018 : Caring Angel -- START
        else if (profileName.equalsIgnoreCase('Caring Angel - Supporto HD1'))
        {
            if(ownerid != userid)
            {
                CheckErr.show = true;
                CheckErr.message='Attenzione ! E\' necessario prendere in carico la richiesta al fine di inserire un commento / allegato';
                return CheckErr;
            }    
            else if ((!status.equalsIgnoreCase(AP_Constants.caseStatusAssILivello))) 
            {
                CheckErr.show = true;
                CheckErr.message='Attenzione! L\'attuale stato della richiesta non consente l\'inserimento di un nuovo commento / allegato';
                return CheckErr;
            }          
        }
        //OAVERSANO 17/10/2018 : Caring Angel -- END
        else       
            CheckErr.show = false;
        
        return CheckErr;
        //return false;
    }
    
    @AuraEnabled
    public static String getOrgURL()
    {
        //String url = [SELECT OrgLink__c FROM Modello_di_Assistenza__mdt WHERE DeveloperName='Redirect'].OrgLink__c;
        String url = '';
        if(Network.communitiesLanding() <> null) {
            url = ((Network.communitiesLanding()).geturl()).replace('home/home.jsp','');
        } else {
            String PartnerUrl = [Select BaseURL__c from User where id=:UserInfo.getUserId() limit 1].BaseURL__c;
            url = (PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce');
        }
        return url;
    }
    
    public without sharing class runQueryWOS
    {
        public runQueryWOS()
        {
        }
        
        public User getUser (Case ca, boolean isOwner)
        {
            
            User u;
            if(isOwner)
            {
                u = [SELECT Name FROM User WHERE Id =: ca.OwnerId ]; // NOPMD  Fix CRUD violation
            } 
            else 
            {
                u = [SELECT Name FROM User WHERE Id =: ca.User__c ]; // NOPMD  Fix CRUD violation
            }
            
            return u;
            
        }
        //OAVERSANO 20/09/2018 : Nuovo Modello di Assistenza -- START
        public String getQueueEmail (Case ca)
        {
            
            String emailToReturn = '';
            List<Group> grp = [SELECT Id, Email, name FROM Group where Type = 'Queue' AND Id =: ca.OwnerId  LIMIT 1]; // NOPMD  Fix CRUD violation
            if(!grp.isEmpty())
            {
                emailToReturn = grp[0].Email;
            }
            return emailToReturn;
            
        }
        //OAVERSANO 20/09/2018 : Nuovo Modello di Assistenza -- END

        //MOSCATELLI 11/02/2019: Lob Contabilità -- START
        public List<CaseTeamMember> getCaseTeamMembers(Case ca)
        {
            List<CaseTeamMember> CaseTeamList = new List<CaseTeamMember>();

            for(CaseTeamMember Memb: [Select MemberId,Member.Name from CaseTeamMember where Parentid=:ca.Id and MemberId!=:ca.OwnerId ]) // NOPMD  Fix CRUD violation
            {
                CaseTeamList.add(Memb);
            }

            return CaseTeamList;
        }
        //MOSCATELLI 11/02/2019: Lob Contabilità -- END

        public Messaging.SendEmailResult[] sendEmail (List<Messaging.SingleEmailMessage> listEmail)
        {
            system.debug('sendEmail: '+listEmail);

            return Messaging.sendEmail(listEmail);
        }
    }
    
    //MOSCATELLI_M 25/10/2018: NMA Business -- START
    @AuraEnabled
    public static CurrentUser checkProfileHD2_lightning()
    {
        CurrentUser Cu = new CurrentUser();
        
        List<User> thisUser = [Select Profile.Name, UserRole.Name from User where id=:UserInfo.getUserId()  limit 1]; // NOPMD  Fix CRUD violation
        
        if(thisUser.size()>0)
        {
            Cu.UserProfile = thisUser[0].Profile.Name;
            
            if((Cu.UserProfile).indexOf('HD2')<>-1)
            {
                Cu.isHD2 = true;   

                if((Cu.UserProfile).equalsIgnoreCase('AAI - Supervisor Supporto HD2 BIZ') || (Cu.UserProfile).equalsIgnoreCase('AAI - Supporto HD2 BIZ'))
                {
                    //Cu.DefaultRt = 'Supporto';
                    Cu.isHD2BIz = true;               
                }                     
            }
            
            if(String.isNotBlank(thisUser[0].UserRole.Name))
                Cu.UserRole = thisUser[0].UserRole.Name;
        } 
        
        return Cu;
    }

    //VIZZINI_D 25/06/2019: NMA - Lob Modulo di Calcolo - START
    @AuraEnabled
    public static Boolean checkProfileRoleHD2_RGI(){
        
        Boolean result = false;
        CurrentUser cu = new CurrentUser();
        List<User> thisUser = [Select Profile.Name, UserRole.Name from User where id=:UserInfo.getUserId()  limit 1]; // NOPMD  Fix CRUD violation
        
        if(thisUser.size() > 0){
            
            cu.UserProfile = thisUser[0].Profile.Name;
            cu.UserRole = thisUser[0].UserRole.Name;
            
            MPS_Code_Variables__c hd2_rgi_role_config = MPS_Code_Variables__c.getValues('HD2 RGI');
            List<String> roles = new List<String>();
            for(String role : hd2_rgi_role_config.Value__c.split(';')){
                roles.add(role);
            }
            
            if((cu.UserProfile).indexOf('HD2')<>-1 && roles.contains(cu.UserRole))
                result = true;
        }

        return result;
    }
    
    @AuraEnabled
    public static Boolean checkProfileRoleHD2_MDCAXA(){
        
        Boolean result = false;
        CurrentUser cu = new CurrentUser();
        List<User> thisUser = [Select Profile.Name, UserRole.Name from User where id=:UserInfo.getUserId()  limit 1]; // NOPMD  Fix CRUD violation
        
        if(thisUser.size() > 0){
            
            cu.UserProfile = thisUser[0].Profile.Name;
            cu.UserRole = thisUser[0].UserRole.Name;
                        
            if((cu.UserProfile).indexOf('HD2')<>-1 && cu.UserRole == 'MdC AXA')
                result = true;
        }

        return result;
    }
    //VIZZINI_D 25/06/2019: NMA - Lob Modulo di Calcolo - END

    //VIZZINI_D 27/06/2019: NMA - Lob Modulo di Calcolo - START
    @AuraEnabled
    public static Boolean getDefectMdC(String idCase){
        
        Case c = [SELECT Defect_Mdc__c FROM Case WHERE Id =: idCase];
        return c.Defect_Mdc__c;
    }
    //VIZZINI_D 27/06/2019: NMA - Lob Modulo di Calcolo - END    
    
    public class CurrentUser 
    { 
        @AuraEnabled public String UserRole; 
        @AuraEnabled public String UserProfile;
        @AuraEnabled public Boolean isHD2BIz;     
        //@AuraEnabled public String DefaultRt;
        @AuraEnabled public Boolean isHD2;
        
        public CurrentUser()
        {
            this.UserRole = '';
            this.UserProfile = '';
            this.isHD2BIz = false;
            this.isHD2 = false;
            //this.DefaultRt = 'Agente';
        }   
    }
    //MOSCATELLI_M 25/10/2018: NMA Business -- END    
    
    //OAVERSANO 19/12/2018 : Enhancement NMA BIZ III -- START
    @AuraEnabled
    public static ResponseDto checkCaseRecordType(String caseId)  //OAVERSANO 09/05/2019 : NMA LOB Vita 
    {
    	ResponseDto response= new ResponseDto();
    	String recordTypeToReturn;
    	String caseLob;//OAVERSANO 09/05/2019 : NMA LOB Vita
        if(String.isNotBlank(caseId))
        {
            List<Case> csList = [SELECT Id, LOB__c, RecordType.Name FROM Case WHERE id =:caseId  LIMIT 1]; // NOPMD  Fix CRUD violation, OAVERSANO 09/05/2019 : NMA LOB Vita 
            if(!csList.isEmpty())
            {
                recordTypeToReturn = csList[0].RecordType.Name;
                caseLob = csList[0].LOB__c; //OAVERSANO 09/05/2019 : NMA LOB Vita 
            }
        }
        //OAVERSANO 09/05/2019 : NMA LOB Vita -- START
        response.values.put('recordTypeToReturn',recordTypeToReturn);
        response.values.put('LOB',caseLob);
        return response;
        //OAVERSANO 09/05/2019 : NMA LOB Vita -- END
    }
    //OAVERSANO 19/12/2018 : Enhancement NMA Biz III -- END
    //
    //d.pirelli 30/11/2019
 @AuraEnabled
    public static Map<String,Boolean> checkVisibilitiesButtonsSendSupport(String caseId, String userRole)  
    {
        Set<String> visibilitiesButtonSend1InvioASecondoLivello = new Set<String>{'Caring_Angel_Motor', 'HD1_IT','HD1_Contabilita','AXA_MPS_Buon_Lavoro','Axa_Assicurazioni', 'Caring_Angel_Property', 'GDPR'};

        Map<String,Boolean> mapVisibilities = new Map <String,Boolean>();
                                                                      
    	
        if(String.isNotBlank(caseId))
        {
            Case cs = [SELECT Complainant__c, RecordType.DeveloperName, Current_Owner_Queue__c,LOB__c, TECH_notAAI__c   FROM Case WHERE id =:caseId LIMIT 1]; 
            if(cs.Current_Owner_Queue__c!= null){              

                //set visibilities for button 'Invio a Secondo livello'
                if( !cs.Current_Owner_Queue__c.containsIgnoreCase('HD2_Biz') /*&& !cs.Current_Owner_Queue__c.containsIgnoreCase('Terze_Parti')*/)
                    mapVisibilities.put('buttonSend1', true);
                
                else
                    mapVisibilities.put('buttonSend1', false);
                
                //set visibilities for button 'Ritorna al primo livello'  
                if((cs.Current_Owner_Queue__c).containsIgnoreCase('Caring_Salute_HD2')||(cs.Current_Owner_Queue__c).containsIgnoreCase('HD2_Biz_') ||(cs.Current_Owner_Queue__c).containsIgnoreCase('HD2_BIZ_') || (cs.Current_Owner_Queue__c).containsIgnoreCase('HD2_Modulo_di_Calcolo') || (cs.Current_Owner_Queue__c).containsIgnoreCase('HD2_IT')|| (cs.Current_Owner_Queue__c).containsIgnoreCase('HD3_IT_DIGITAL') || (cs.Current_Owner_Queue__c).containsIgnoreCase('HD2_Instant_payment'))
                    mapVisibilities.put('buttonSend2', true);
                else
                    mapVisibilities.put('buttonSend2', false);
                
                //set visibilities for button 'Invia ad Altra Area'
                if(
                    (cs.Current_Owner_Queue__c).containsIgnoreCase('HD1_Biz_') || 
                    (cs.Current_Owner_Queue__c).containsIgnoreCase('HD1_IT') || 
                    (cs.Current_Owner_Queue__c).containsIgnoreCase('_Buon_Lavoro') || 
                    (cs.Current_Owner_Queue__c).containsIgnoreCase('HD1_Contabilita') || 
                    (cs.Current_Owner_Queue__c).containsIgnoreCase('HD1_Contenzioso')  ||
                    (
                        (cs.Current_Owner_Queue__c).containsIgnoreCase('HD3_Fornitore_Esterno') &&
                        cs.recordtype.DeveloperName.equals(AP_Constants.rtCaseAssistenzaAgenti)
                    )
                    )

                    mapVisibilities.put('buttonSend3', true);
                else
                    mapVisibilities.put('buttonSend3', false);
              
                //set visibilities for button Invia a Modulo di calcolo AXA 
                 if( (cs.Current_Owner_Queue__c).containsIgnoreCase('HD2') && userRole.equals('RGI')  )
                    mapVisibilities.put('buttonSend4', true);
                else
                    mapVisibilities.put('buttonSend4', false);             
                
                
                //set visibilities for button Invia a Modulo di calcolo  
                  if(((cs.Current_Owner_Queue__c).containsIgnoreCase('HD2_Modulo_di_Calcolo') && userRole.equals('MdC AXA') )  || (cs.Current_Owner_Queue__c).containsIgnoreCase('HD2_Biz') && !cs.TECH_notAAI__c) 
                    mapVisibilities.put('buttonSend5', true);
                else
                    mapVisibilities.put('buttonSend5', false);
               
               //set visibilities for button  Invia ad Agenzia
                if(
                    (cs.Current_Owner_Queue__c).containsIgnoreCase('Caring_Salute_HD1') ||
                    (cs.Current_Owner_Queue__c).containsIgnoreCase('HD1_Biz_') || 
                   (cs.Current_Owner_Queue__c).containsIgnoreCase('HD1_IT') || 
                   (cs.Current_Owner_Queue__c).containsIgnoreCase('_Buon_Lavoro') || 
                   (cs.Current_Owner_Queue__c).containsIgnoreCase('HD1_Contabilita') || 
                   (cs.Current_Owner_Queue__c).containsIgnoreCase('HD1_Contenzioso') || 
                   (cs.Current_Owner_Queue__c).containsIgnoreCase('GDPR')||
                  	(
                          ((cs.Current_Owner_Queue__c).containsIgnoreCase('HD2_Biz_') || 
                            (cs.Current_Owner_Queue__c).containsIgnoreCase('HD2_BIZ') || 
                            (cs.Current_Owner_Queue__c).containsIgnoreCase('HD3_Fornitore'))
                     && cs.recordtype.DeveloperName.equals(AP_Constants.rtCaseAssistenzaAgenti))||
                  (     
                        cs.recordtype.developername.equals(Ap_Constants.rtCaseCloseTheLoopDevName) && 
                        !cs.Current_Owner_Queue__c.containsIgnoreCase('HD2')) ||
                        (
                            cs.recordtype.developername.equals(Ap_Constants.rtCaseAAI) &&
                            (
                                cs.Current_Owner_Queue__c.containsIgnoreCase('Axa_Assicurazioni') ||
                                cs.Current_Owner_Queue__c.containsIgnoreCase('HD3_Fornitore_Esterno')
                            )
                        )
                  )
                    mapVisibilities.put('buttonSend6', true);
                else
                    mapVisibilities.put('buttonSend6', false);
                
                if(cs.RecordType.DeveloperName == AP_Constants.rtCaseCaringSalute && cs.Complainant__c != 'Agente' )
                     mapVisibilities.put('buttonSend6', false);

                if(!(cs.Current_Owner_Queue__c).contains('HD2_BIZ') && !(cs.Current_Owner_Queue__c).contains('Caring_Angel') && !(cs.Current_Owner_Queue__c).contains('Instant_payment'))
                    mapVisibilities.put('buttonSend7', true);
                else
                    mapVisibilities.put('buttonSend7', false);

                if((cs.Current_Owner_Queue__c).contains('HD2_IT'))
                    mapVisibilities.put('buttonSend8', true);
                else
                    mapVisibilities.put('buttonSend8', false);
                
                

                 
            }
        }
        return mapVisibilities;
        
    }
        
    

    
}
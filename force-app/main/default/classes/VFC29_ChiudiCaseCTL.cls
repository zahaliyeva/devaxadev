public class VFC29_ChiudiCaseCTL {
	private final Id cas;
	public Boolean jsDebug					{get;set;}
	public String solution					{get;set;}
	public String caseNumber				{get;set;}
	public String caseStatus				{get;set;}
    public Boolean caseisClosed             {get;set;}     
    public Boolean OwnerIsQueue             {get;set;}   
    
    public VFC29_ChiudiCaseCTL(ApexPages.StandardController stdController) {
        
        Id user_debug_id;
        try{
            user_debug_id = (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG') != null ? (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG').Value__c : null;
        } catch (Exception e) {
            user_debug_id = null;
        }
        
        if(user_debug_id != null && (user_debug_id  == UserInfo.getUserId())){
            jsDebug= true;
        } else {
            jsDebug=false;
        }
        cas=ApexPages.currentPage().getParameters().get('id');
        if(cas!=null){
        	Case c = [SELECT Id, Status, CaseNumber, Details_of_Solution__c,isClosed,OwnerId FROM Case WHERE ID =:cas LIMIT 1];
        	solution = (c.Details_of_Solution__c!=null)?c.Details_of_Solution__c:'';
        	caseNumber = (c.CaseNumber!=null)?c.CaseNumber:'';
        	caseStatus = (c.Status!=null)?c.Status:'';
            caseisClosed = c.isClosed;
            String CaseOwner = c.OwnerId;
            OwnerIsQueue = (CaseOwner.startsWith('00G'))?true:false;
        }
        
    }
    
    
    public without sharing class runQueryWOS {

        public runQueryWOS(){
        }

        public List<User> getUser (Case ca){
            //system.debug('@@ca: '+ca);
            List<User> uList = new List<User>();
            List<Id> idsToQuery = new List<Id>();
            if(String.isBlank(ca.Last_Advisor__c) && ca.Origin == AP_Constants.caseOriginsurveyRinnovo)
            {
            	List<Group> groups= [SELECT Id, DeveloperName, (SELECT Id, UserOrGroupId FROM GroupMembers) FROM Group where name = 'AAI - Acquisto e Rinnovo Advisor' ]; // NOPMD  Fix CRUD violation
            	if(!groups.isEmpty())
            	{
            		if(!groups[0].GroupMembers.isEmpty())
            		{
            			for(GroupMember grpMmb : groups[0].GroupMembers){
            				if((String.valueOf(grpMmb.UserOrGroupId)).startsWith('005'))
            					idsToQuery.add(grpMmb.UserOrGroupId);
            			}
            		}
            	}
            	if(!idsToQuery.isEmpty())
            	{
            		uList = [SELECT Id, Name, Email FROM User WHERE Id IN: idsToQuery ]; // NOPMD  Fix CRUD violation
            	}
            }
            else
            {
            	uList = [SELECT Id, Name, Email FROM User WHERE Id =: ca.Last_Advisor__c ]; // NOPMD  Fix CRUD violation
            }
            return uList;

        }

        public Messaging.SendEmailResult[] sendEmail (List<Messaging.SingleEmailMessage> listEmail){

            return Messaging.sendEmail(listEmail);

        }
        
        public String updateCase(String caseId, String value)
        {
        	String toReturn;
            AssignmentRule AR = new AssignmentRule();
            Database.DMLOptions dmlOpts = new Database.DMLOptions();

        	Case cs = [SELECT Id, Status, CaseNumber, User__c, User__r.Name, Details_of_Solution__c, Oggetto_Apertura_Case__c, Last_Advisor__c,
            					OwnerId, Owner.Name, TECH_LastHD1Queue__c FROM CASE WHERE Id =:caseId]; 
            //cs.TECH_eKomi_comment__c = value;
            //OAVERSANO 24/10/2018 : ICF Close The Loop -- START
            String rTId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agente'].Id;
        	Storico_conversazioni__c sc = new Storico_conversazioni__c();
        	sc = new Storico_conversazioni__c( Description__c = value, 
        										Connected_case__c = caseId, 
        										CaseStatus__c = cs.Status, 
        										Type__c = 'Attività di Close The Loop svolta dall\'agente', 
        										RecordTypeId = rTId, 
        										Profilo_utente__c = 'Agente' );
            cs.Status = AP_Constants.caseStatusInfoAgenteRicevuta;
			cs.Current_Owner_Queue__c = cs.TECH_LastHD1Queue__c;
            //OAVERSANO 27/11/2018 : ICF Close The Loop SWITCH FASI -- START
            String Step = (MPS_Code_Variables__c.getAll()).get('CloseTheLoopStep') != null ? (MPS_Code_Variables__c.getAll()).get('CloseTheLoopStep').Value__c : null;
            if(Step != null && Step == 'Fase1')
            {
                if(cs.Last_Advisor__c!=null)
                {
                    cs.OwnerId = cs.Last_Advisor__c;
                }
                else
                {                
                    AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true  limit 1]; // NOPMD  Fix CRUD violation
                    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;  
                    cs.setOptions(dmlOpts);    
                }
            }
           	try
            {
				Database.update(cs);
				insert sc; // NOPMD  Fix CRUD violation
				toReturn='OK';
           	}
           	catch (Exception ex)
           	{
                System.debug('There was an exception: ' + ex.getMessage());
                toReturn = 'KO|FallitoSi è verificato il seguente errore:\n'+ex.getMessage()+'\nContattare l\'amministratore di sistema.';
           	}
           	return toReturn;
        }

		public String closeCase(String caseId, String value, String status)
        {
        	String toReturn;
            AssignmentRule AR = new AssignmentRule();
            Database.DMLOptions dmlOpts = new Database.DMLOptions();

        	Case cs = [SELECT Id, Status, CaseNumber, User__c, User__r.Name, Details_of_Solution__c, Oggetto_Apertura_Case__c, Last_Advisor__c,
            					OwnerId, Owner.Name, Owner.Profile.Name, TECH_LastHD1Queue__c FROM CASE WHERE Id =:caseId];
            //cs.TECH_eKomi_comment__c = value;
            //OAVERSANO 24/10/2018 : ICF Close The Loop -- START
            String rTId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agente'].Id;
        	Storico_conversazioni__c sc = new Storico_conversazioni__c();
        	sc = new Storico_conversazioni__c( Description__c = value, 
        										Connected_case__c = caseId, 
        										CaseStatus__c = cs.Status, 
        										Type__c = 'Attività di Close The Loop svolta dall\'agente', 
        										RecordTypeId = rTId, 
        										Profilo_utente__c = 'Agente' );
			/*if(!cs.Owner.Profile.Name.startsWith('NFE')){
            cs.Status = AP_Constants.caseStatusInfoAgenteRicevuta;
			cs.Current_Owner_Queue__c = cs.TECH_LastHD1Queue__c;
            String Step = (MPS_Code_Variables__c.getAll()).get('CloseTheLoopStep') != null ? (MPS_Code_Variables__c.getAll()).get('CloseTheLoopStep').Value__c : null;
            if(Step != null && Step == 'Fase1')
            {
                if(cs.Last_Advisor__c!=null)
                {
                    cs.OwnerId = cs.Last_Advisor__c;
                }
                else
                {                
                    AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;  
                    cs.setOptions(dmlOpts);    
                }
            }
			}
            else{*/
				cs.Status = status;
                cs.TECH_eKomi_comment__c = value;
			//}
            //OAVERSANO 27/11/2018 : ICF Close The Loop SWITCH FASI -- START
            
           	try
            {
				Database.update(cs);
				insert sc; // NOPMD  Fix CRUD violation
				toReturn='OK';
           	}
           	catch (Exception ex)
           	{
                System.debug('There was an exception: ' + ex.getMessage());
                toReturn = 'KO|FallitoSi è verificato il seguente errore:\n'+ex.getMessage()+'\nContattare l\'amministratore di sistema.';
           	}
           	return toReturn;
        }
    }
    
    
    @AuraEnabled
    public static String UpdateCaseCTL(String caseId, String value) { 
        system.debug('UpdateCaseCTL');
        String toReturn;
        runQueryWOS queryWS = new runQueryWOS();
        if(String.isNotBlank(caseId) && String.isNotBlank(value))
        {
            
			Savepoint sp = Database.setSavepoint();
			toReturn = queryWS.updateCase(caseId, value);
			if(toReturn=='OK')
			{
				try{
	                String emTemplate = 'Avviso_chiusura_case_verso_Advisor_CTL';
	    			Case cs = [SELECT Id, CaseNumber, Origin, User__c, User__r.Name, Details_of_Solution__c, Oggetto_Apertura_Case__c,
	            					OwnerId, Owner.Name, Status, Last_Advisor__c, Last_Advisor__r.Email FROM CASE WHERE Id =:caseId];
	            	
	            	List<User> ToUserList = queryWS.getUser(cs);
	    			if(!ToUserList.isEmpty())
	    			{
	    				User ToUser = ToUserList[0];
	    				EmailTemplate etem = [SELECT Markup, Subject, HtmlValue, body // NOPMD  Fix CRUD violation
												FROM EmailTemplate 
												WHERE DeveloperName =:emTemplate ];
		   			 	List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
		        		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			            String htmlBody = etem.HtmlValue;
			            system.debug('htmlBody pre: '+htmlBody);
			            String subject = etem.Subject;
						String body = etem.body;
			            subject = subject.replace('{!Case.CaseNumber}',cs.CaseNumber);
			            subject = subject.replace('{!Case.Status}',((cs.Status==null)?'':string.valueof(cs.Status)));
			            htmlBody = htmlBody.replace('{!Case.CaseNumber}',cs.CaseNumber);
			            htmlBody = htmlBody.replace('{!Case.OwnerFullName}',((ToUser.Name==null)?'':string.valueof(ToUser.Name)));
			            htmlBody = htmlBody.replace('{!Case.Link}','https://test.salesforce.com/' +cs.Id );          
						body = body.replace('{!Case.CaseNumber}',cs.CaseNumber);
			            body = body.replace('{!Case.OwnerFullName}',((ToUser.Name==null)?'':string.valueof(ToUser.Name)));
			            body = body.replace('{!Case.Link}','https://test.salesforce.com/' +cs.Id );
			           	system.debug('htmlBody: '+htmlBody);
			           	email.setHtmlBody(htmlBody);
						email.setSubject(subject);
			            /*List<String> toAddresses = new List<String>();
			            toAddresses.add(cs.Last_Advisor__r.Email);	
			            email.setToAddresses(toAddresses);    */        
			            email.setTargetObjectId(ToUser.Id);
			            email.saveAsActivity = false;
			            listEmail.add(email);
		        		Messaging.SendEmailResult [] results = queryWS.sendEmail(listEmail);
		        		
		    			if (results[0].success) 
						{
						    System.debug('The email was sent successfully.');
						    toReturn = 'OK';
						} 
						else 
						{
						    System.debug('The email failed to send: ' + results[0].errors[0].message);
						    toReturn = 'KO|FallitoSi è verificato il seguente errore:\n'+results[0].errors[0].message+'\nContattare l\'amministratore di sistema.';
						    Database.rollback(sp);
						}
	    			}
	    			
	            } catch (Exception ex){
	                System.debug('There was an exception: ' + ex.getMessage());
	                toReturn = 'KO|FallitoSi è verificato il seguente errore:\n'+ex.getMessage()+'\nContattare l\'amministratore di sistema.';
	                Database.rollback(sp);
	            }
			}
        }
        else
        {
            toReturn =  'KO|FallitoSi è verificato un errore.\nContattare l\'amministratore di sistema.';
        }
        return toReturn;
    }

    @AuraEnabled
    public static String CloseCaseCTL(String caseId, String value, Boolean isUfficio) { 
        system.debug('UpdateCaseCTL');
        String toReturn;
        runQueryWOS queryWS = new runQueryWOS();
        if(String.isNotBlank(caseId) && String.isNotBlank(value))
        {
			System.debug(isUfficio);
            String status = isUfficio ? AP_Constants.caseStatusOutOfTime : AP_Constants.caseStatusClosed;
			Savepoint sp = Database.setSavepoint();
			toReturn = queryWS.closeCase(caseId, value, status);
			
        }
        else
        {
            toReturn =  'KO|FallitoSi è verificato un errore.\nContattare l\'amministratore di sistema.';
        }
        return toReturn;
    }

    @AuraEnabled
    public static Case getCase(String recordId){
        return [
            SELECT Id, Status, owner.name,category__c, ProfileNameOwner__c, ownerid
            FROM Case
            WHERE Id = :recordId
        ];
    }

	@AuraEnabled
    public static Boolean isRightCTL(String recordId, boolean isClose){
        Case c = [ // NOPMD  Fix CRUD violation
            SELECT Id, Status, RecordType.DeveloperName, category__c, Last_Advisor__c
            FROM Case
            WHERE Id = :recordId 
        ];
		//*-+ 23/02/2022 Change # 278 api name + label on Array 
		//*-+ 05/09/2022 aggiunto Sinistri check in for feedback 
		List<String> rightCategories = new List<String>{
		'Survey Rinnovi P&C AAI','Rinnovo Danni','Rinnovi Danni',
		'Survey Acquisto P&C AAI','Acquisto Danni', 
		'SINISTRI_CHECK_IN','Sinistri Check IN', 
		'Survey Acquisto Protezione Vita AAI','Acquisto Protezione Vita', 
		'Survey Rinnovi Protezione Vita AAI','Rinnovo Protezione Vita'};
		system.debug(c);
		return (
			AP_Constants.rtCaseCloseTheLoopDevName.equals(c.RecordType.DeveloperName) && 
			(
				rightCategories.contains(c.Category__c)
			)
			&& (isClose ? true : c.Last_Advisor__c == null)
		);
    }


}
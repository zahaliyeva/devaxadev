public class AP07CaseEmailAlert {
    /* 
----------------------------------------------------------------------
-- - Name          : AP07CaseEmailAlert
-- - Author        : Spoon Consulting
-- - Description   : Case Email Alert  
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 10-MAR-2015  HDU    1.0     Initial version (Notify task owner or case 
owner of email alert)
----------------------------------------------------------------------
***********************************************************************/
    public static string taskStatusPending = AP_Constants.taskStatusPending;
    public static string caseStatusPending = AP_Constants.caseStatusPending;
    public static string emailTemplateNew_Email_Received = AP_Constants.emailTemplateNew_Email_Received; 
    //CAPOBIANCO_A 30/03/2017 BUGFIX --- START
    //public static void notifyEmailAlert( set<Id> setCaseId ){

    public static Map<Id, Case> checkSenderDACAndNotifyEmailAlert(Map <Id,String> mapCaseIdwithFromAddressDac, Map<Id, Case> mapCase){
        List<Case> caseToUpdate = new List<Case>();
        Map<String, Id> listAgencyCode =  new Map<String, Id>();
        Map<String, List<User>> listUsers =  new Map<String, List<User>>();
        Map<String, Boolean> listNMA =  new Map<String, Boolean>();

        //Map<Id, Case> mapCase = new Map<Id, Case>([SELECT c.Owner.Email,OwnerId, c.Id, c.Status, c.CaseNumber, c.RecordType.DeveloperName, Owner.Profile.Name FROM Case c WHERE Id IN :mapCaseIdwithFromAddressDac.keyset()]);
        Modello_di_Assistenza__mdt agenziePilota = [SELECT Id, Pilota__c FROM Modello_di_Assistenza__mdt WHERE DeveloperName = 'AgenziePilota'];
        List<String> listAgenziePilota = agenziePilota.Pilota__c.split(';');
        
        List<User> users = [SELECT Id, Agency_Code__c, CommunityNickname, Email FROM User WHERE Email IN :mapCaseIdwithFromAddressDac.values() AND IsActive = true AND (Profile.Name = 'AAI - Vendite Avanzato' OR Profile.Name = 'AAI - Vendite Base')];
        for(User u : users){
          listAgencyCode.put(u.Agency_Code__c, null);
          if(listUsers.containsKey(u.Email)){
            List<User> lstUsr = listUsers.get(u.Email); 
            lstUsr.add(u);
            listUsers.put(u.Email, lstUsr);
          } else {
            List<User> lstUsr = new List<User>(); 
            lstUsr.add(u);
            listUsers.put(u.Email, lstUsr);
          }
        }

        system.debug('listUsers: ' + listUsers);

        List<Account> agencies = [SELECT Id, Agency_Code__c, Agency_Holder__c FROM Account WHERE RecordType.Name = 'Agency' AND Agency_Code__c IN :listAgencyCode.keyset()];
        for(Account acc : agencies){
          listAgencyCode.put(acc.Agency_Code__c, acc.Id);
        }

        for(Id idCase : mapCaseIdwithFromAddressDac.keyset()){
            Case c = mapCase.get(idCase);
            String email = mapCaseIdwithFromAddressDac.get(idCase);
            system.debug('email: ' + email);
            List<User> listUser = listUsers.get(email);
            system.debug('listUser: ' + listUser);

            c.LOB__c = 'Documento Anagrafica Consensi';
            c.Category__c = 'Informazioni su funzionalità recupero DAC su CRM';
            c.Complainant__c = 'Agente';
            c.OwnerId = MPS_Code_Variables__c.getValues('HD1 BIZ DAC Agenzie').Value__c;
            c.Priority = 'Medium';
            if(listUser == null || listUser.size() > 1){
              system.debug('email with more than 1 user');
              c.Status = 'Open';
              listNMA.put(email, false);
            } else {
              system.debug('email with only 1 user');
              User user = listUser.get(0);
              c.User__c = user.Id;
              c.Agency_Code__c = user.Agency_Code__C;
              c.Agenzia__c =  listAgencyCode.get(user.Agency_Code__C);
              if(listAgenziePilota.contains(user.Agency_Code__c)){
                c.Status = 'Chiusura Email';
                listNMA.put(email, true);
              } else {
                c.Status = 'Open';
                listNMA.put(email, false);
              }
            }
            caseToUpdate.add(c);
            //necessario???
            mapCase.put(idCase, c);
            //necessario???
        }

        sendNotifyEmailDac(mapCaseIdwithFromAddressDac, mapCase, listNMA);

        return new Map<Id, Case>(caseToUpdate);
    }

    public static void sendNotifyEmailDac(Map <Id,String> mapCaseIdwithFromAddressDac, Map<Id, Case> mapCase, Map<String, Boolean> listNMA){
        List<Messaging.SingleEmailMessage> listMails = new List<Messaging.SingleEmailMessage>();        

        String senderOrgId = Email_For_Notification_To_Advisor__c.getValues('DAC_AXA_Agenti').OrgId__c;
        EmailTemplate alertCaseOpened = [SELECT  OwnerId, Name, Id, DeveloperName, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'Avviso_apertura_case' LIMIT 1];
        EmailTemplate portaleAssistenza = [SELECT  OwnerId, Name, Id, DeveloperName, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'Avviso_necessit_utilizzo_del_Portale_Assistenza' LIMIT 1];

        for(Id idCase : mapCaseIdwithFromAddressDac.keyset()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String emailBody = '';
            String emailSubject = '';

            String email = mapCaseIdwithFromAddressDac.get(idCase);
            Case c = mapCase.get(idCase);

            System.debug(' ===> case: ' + c);
            Boolean isNma = listNMA.get(email);
            if(isNma){
              emailBody = portaleAssistenza.HtmlValue;
              emailSubject = portaleAssistenza.Subject;
              if(c.Oggetto_Apertura_Case__c != null){
                emailSubject = emailSubject.replace('{!Case.Oggetto_Apertura_Case__c}', c.Oggetto_Apertura_Case__c);
              } else {
                emailSubject = emailSubject.replace('{!Case.Oggetto_Apertura_Case__c}', '');
              }
              
            } else {
              emailBody = alertCaseOpened.HtmlValue;
              emailSubject = alertCaseOpened.Subject;
              if(c.Oggetto_Apertura_Case__c != null){
                emailSubject = emailSubject.replace('{!Case.Oggetto_Apertura_Case__c}', c.Oggetto_Apertura_Case__c);
              } else {
                emailSubject = emailSubject.replace('{!Case.Oggetto_Apertura_Case__c}', '');
              }
              emailSubject = emailSubject.replace('{!Case.TECHThreadId__c}', c.TECHThreadId__c);
              emailBody = emailBody.replace('{!Case.Oggetto_Apertura_Case__c}', c.Oggetto_Apertura_Case__c);
              emailBody = emailBody.replace('<![CDATA[', '');
              emailBody = emailBody.replace(']]>', '');
            }

            System.debug(' ===> destinatario: ' + c.User__c);
            if(senderOrgId != null) {          
              mail.setOrgWideEmailAddressId(senderOrgId);
            } else {
              system.debug('>>>### notifyEmailAlert - orgId : null for recordtype : ' + c.RecordType.DeveloperName);
            }
            if(c.User__c == null){
              mail.setToAddresses(new list<String> {email});
            } else {
              mail.setTargetObjectId(c.User__c);    
            }
            
            mail.setSaveAsActivity(false);
            mail.setSubject(emailSubject);
            mail.setHtmlBody(emailBody);
            listMails.add(mail);
        }

        Messaging.sendEmail(listMails);

    }

    public static void notifyEmailAlert(Map <Id,String> mapCaseIdwithToAddress )
    {
    //CAPOBIANCO_A 30/03/2017 BUGFIX --- END
        system.debug('>>> START AP07CaseEmailAlert - notifyEmailAlert <<<');
        Id orgId;
        Case caseRec;
        string emailBody='' ,emailSubject='',caseId='',emailRecipent='';
        Messaging.SingleEmailMessage mail;
        list<Messaging.SingleEmailMessage> listMails = new list<Messaging.SingleEmailMessage>();
        list<EmailTemplate> listEmailTemplate;
        map<string,Case> mapCaseIdRecipentEmailToCase = new map<string,Case>();
        map<string,id>  mapOrgWideEmailAddress = new map<string,id>();
        set<Id> setCaseId = mapCaseIdwithToAddress.keyset(); //CAPOBIANCO_A 30/03/2017 BUGFIX
        
        //OAVERSANO 07/03/2019 : CR ICF -- START
        Boolean sendNotificationToOwner = false;
        String emailTemplateNotificaAgente = '';
        List<String> RecordTypesWithDifferentTemplate = new List<String>();
        for(MPS_Code_Variables__c MPSCv: MPS_Code_Variables__c.getAll().values())
        {
            if((MPSCv.Name).contains('AP07CaseEmailAlert_sendAlertToOwner'))
            {
            	if(MPSCv.Value__c!=null && MPSCv.Value__c == 'true')
            	{
                	sendNotificationToOwner = true;
            	}
            }
            if((MPSCv.Name).contains('AP07CaseEmailAlert_templateNameAgente'))
            {
            	if(MPSCv.Value__c!=null)
            	{
                	emailTemplateNotificaAgente = MPSCv.Value__c;
            	}
            }
            if((MPSCv.Name).contains('AP07CaseEmailAlert_RecordTypeTemplate'))
            {
            	if(String.isNotBlank(MPSCv.Value__c))
          		{
                  	for(String s:MPSCv.Value__c.split(';'))
                  	{
                      	RecordTypesWithDifferentTemplate.add(s);
                  	}   
          		}
            }
        }
        //OAVERSANO 07/03/2019 : CR ICF -- END
        
        for (Case c : [ SELECT  c.Owner.email,ownerid, c.Id,c.Status,c.CaseNumber,c.RecordType.developername, owner.Profile.Name,  //OAVERSANO 07/03/2019 : CR ICF
                       (//MMOSCATELLI 16052016: Bugfix SPAM email--START
                           //SELECT     Owner.email
                           SELECT     Owner.email,ownerid
                           //MMOSCATELLI 16052016: Bugfix SPAM email--END
                           FROM       Tasks
                           //MOSCATELLI_M 04042016: Evo 52 -- START
                           //WHERE      Status = :taskStatusPending )
                           WHERE      Status = :taskStatusPending or Status = :AP_Constants.taskStatusInformationReceived)
                       //MOSCATELLI_M 04042016: Evo 52 -- END
                       FROM    Case c
                       WHERE   Id IN :setCaseId])
        {
                           //MOSCATELLI_M 27042016: Bugfix Evo 50 -- START
                           //if(c.Status == caseStatusPending && c.tasks.size() > 0){
                           if((c.Status == caseStatusPending || c.Status == AP_Constants.caseStatusInformationReceived) && c.tasks.size() > 0)
                           {
                               //MOSCATELLI_M 27042016: Bugfix Evo 50 -- END
                               for (Task t :c.tasks)
                               {
                                   //MMOSCATELLI 16052016: Bugfix SPAM email--START
                                   //mapCaseIdRecipentEmailToCase.put(c.id+'-break-'+t.Owner.email,c);
                                   mapCaseIdRecipentEmailToCase.put(c.id+'-break-'+t.ownerid,c);
                                   //MMOSCATELLI 16052016: Bugfix SPAM email--END
                               }//end of loop task
                           }
                           else if(string.valueof(c.ownerid).startsWith(AP_Constants.UserKeyPrefix))
                           {// send only if owner is User
                               //MMOSCATELLI 16052016: Bugfix SPAM email--START
                               //mapCaseIdRecipentEmailToCase.put(c.id+'-break-'+c.Owner.email,c);
                               mapCaseIdRecipentEmailToCase.put(c.id+'-break-'+c.ownerid,c);
                               //MMOSCATELLI 16052016: Bugfix SPAM email--END
                           }//end check case status 
                       }//end of loop case
        system.debug('>>>### notifyEmailAlert - mapCaseIdRecipentEmailToCase : '+mapCaseIdRecipentEmailToCase.size());
        //send mail 
        //OAVERSANO 07/03/2019 : CR ICF -- START
        List<String> listEmailTemplatesToQuery = new List<String>{emailTemplateNew_Email_Received, emailTemplateNotificaAgente};
        
        /*listEmailTemplate  =  new list<EmailTemplate>([ Select  e.OwnerId, e.Name, e.Id, e.DeveloperName,
                                                       e.HtmlValue, e.Subject
                                                       From    EmailTemplate e 
                                                       where   e.DeveloperName  = :emailTemplateNew_Email_Received]);*/
        listEmailTemplate  =  new list<EmailTemplate>([ Select  e.OwnerId, e.Name, e.Id, e.DeveloperName,
                                                       e.HtmlValue, e.Subject
                                                       From    EmailTemplate e 
                                                       where   e.DeveloperName  IN: listEmailTemplatesToQuery]);                                               
        //OAVERSANO 07/03/2019 : CR ICF -- END                                                       
        for( OrgWideEmailAddress org :[SELECT ID,DisplayName,Address 
                                       FROM OrgWideEmailAddress
                                       //MOSCATELLI_M 30062015 : EVO-12----START
                                       // WHERE DisplayName IN :new list<String>{system.label.OrgWideEmailDisplayNameMotor, system.label.OrgWideEmailDisplayNameNonMotor, system.label.OrgWideEmailDisplayName}]){
                                       
                                       //OAVERSANO 09/01/2019 : Agenzia diretta -- START
                                       //WHERE DisplayName IN :new list<String>{system.label.OrgWideEmailDisplayNameMotor, system.label.OrgWideEmailDisplayNameNonMotor, system.label.OrgWideEmailDisplayName, system.label.OrgWideEmailDisplayNameQuadra, system.label.OrgWideEmailDisplayNameAAI}])
                                       //OAVERSANO 15/01/2019 : Gestione Reclami -- START
                                       //WHERE DisplayName IN :new list<String>{system.label.OrgWideEmailDisplayNameAgenziaDipendenti, system.label.OrgWideEmailDisplayNameMotor, system.label.OrgWideEmailDisplayNameNonMotor, system.label.OrgWideEmailDisplayName, system.label.OrgWideEmailDisplayNameQuadra, system.label.OrgWideEmailDisplayNameAAI}])
                                       WHERE DisplayName IN :new list<String>{system.label.OrgWideEmailDisplayNameReclamo, system.label.OrgWideEmailDisplayNameAgenziaDipendenti, system.label.OrgWideEmailDisplayNameMotor, system.label.OrgWideEmailDisplayNameNonMotor, system.label.OrgWideEmailDisplayName, system.label.OrgWideEmailDisplayNameQuadra, system.label.OrgWideEmailDisplayNameAAI}])
                                       //OAVERSANO 15/01/2019 : Gestione Reclami -- END
                                       //OAVERSANO 09/01/2019 : Agenzia diretta -- END
                                       
        {	
                                           //MOSCATELLI_M 30062015 : EVO-12----END
                                           //CAPOBIANCO_A 30/03/2017 BUGFIX --- START
                                           //mapOrgWideEmailAddress.put(org.DisplayName,org.ID);
                                           mapOrgWideEmailAddress.put(org.Address,org.ID);
                                           //CAPOBIANCO_A 30/03/2017 BUGFIX --- END
                                       }//end of loop OrgWideEmailAddress
        
        system.debug('>>>### notifyEmailAlert - listEmailTemplate : '+listEmailTemplate.size());
        system.debug('>>>### notifyEmailAlert - mapOrgWideEmailAddress : '+mapOrgWideEmailAddress.size());                                                  
        //CAPOBIANCO_A 30/03/2017 BUGFIXING --- START
        Map<String,String> mapNameOrgId = new Map<String,String>();
        
        for(Email_For_Notification_To_Advisor__c listOrgId: Email_For_Notification_To_Advisor__c.getAll().values())
        {
            mapNameOrgId.put(listOrgId.Name, listOrgId.OrgId__c);
        }
        //CAPOBIANCO_A 30/03/2017 BUGFIXING --- END
        //OAVERSANO 07/03/2019 : CR ICF -- START
        Map<String,String> mapNameOrgIdAgent = new Map<String,String>();
        for(Email_For_Notification_To_Agents__c listOrgId: Email_For_Notification_To_Agents__c.getAll().values())
        {
            mapNameOrgIdAgent.put(listOrgId.Name, listOrgId.OrgId__c);
        }
        String urlSite = '';
        urlSite = [SELECT OrgLink__c 
                   FROM Modello_di_Assistenza__mdt 
                   WHERE DeveloperName = 'RedirectCommunity'
                   LIMIT 1].OrgLink__c;
       	//OAVERSANO 07/03/2019 : CR ICF -- END
        //if(listEmailTemplate.size() == 1)
        if(!listEmailTemplate.isEmpty())
        //OAVERSANO 07/03/2019 : CR ICF -- END
        {
            for (String caseIdRecipentEmail :mapCaseIdRecipentEmailToCase.keyset() )
            {
                system.debug('##emailRecipent'+caseIdRecipentEmail);//TEST
                emailRecipent=caseIdRecipentEmail.split('-break-')[1];
                
                caseRec = mapCaseIdRecipentEmailToCase.get(caseIdRecipentEmail); 
                
                //MOSCATELLI_M 30062015: EVO-12-----START
                //orgId = (caseRec.RecordType.developername == AP_Constants.rtCaseMotor)?mapOrgWideEmailAddress.get(system.label.OrgWideEmailDisplayNameMotor):((caseRec.RecordType.developername == AP_Constants.rtCaseNonMotor)?mapOrgWideEmailAddress.get(system.label.OrgWideEmailDisplayNameNonMotor):mapOrgWideEmailAddress.get(system.label.OrgWideEmailDisplayName));
                
                //CAPOBIANCO_A 30/03/2017 BUGFIXING --- START
                /*  if(caseRec.RecordType.developername == AP_Constants.rtCaseMotor)
                    orgId = mapOrgWideEmailAddress.get(system.label.OrgWideEmailDisplayNameMotor);
                else
                {
                    if(caseRec.RecordType.developername == AP_Constants.rtCaseNonMotor || caseRec.RecordType.developername == 'Close_the_loop')
                        orgId = mapOrgWideEmailAddress.get(system.label.OrgWideEmailDisplayNameNonMotor);
                    else
                    {
                        if(caseRec.RecordType.developername == AP_Constants.rtCaseQuadra)                       
                            orgId = mapOrgWideEmailAddress.get(system.label.OrgWideEmailDisplayNameQuadra);                      
                        else
                        {
                            if(caseRec.RecordType.developername == AP_Constants.rtCaseAAI)
                                orgId = mapOrgWideEmailAddress.get(system.label.OrgWideEmailDisplayNameAAI);
                            else
                                orgId = mapOrgWideEmailAddress.get(system.label.OrgWideEmailDisplayName);
                        }           
                    }
                }*/
                if(mapOrgWideEmailAddress.containsKey(mapCaseIdwithToAddress.get(caseRec.Id)))
                    orgId = mapOrgWideEmailAddress.get(mapCaseIdwithToAddress.get(caseRec.Id));
                else
                {
                	//OAVERSANO 07/03/2019 : CR ICF -- START
                	if((caseRec.owner.Profile.Name).indexOf('AAI - Vendite')<>-1  && caseRec.RecordType.developername == AP_Constants.rtCaseCloseTheLoopDeveloperName)
                	{
                		orgId = mapNameOrgIdAgent.get(AP_Constants.rtCaseCloseTheLoopDeveloperName);    
                	}
                	else
                	{
                	//OAVERSANO 07/03/2019 : CR ICF -- END
	                    if(caseRec.RecordType.developername == AP_Constants.rtCaseMotor)                    
	                        orgId = mapNameOrgId.get('Motor');                   
	                    else
	                    {
	                    	//OAVERSANO 09/01/2019 : Agenzia diretta -- START
	                    	if(caseRec.RecordType.developername == AP_Constants.rtCaseAgenziaDipendenti)                    
	                        	orgId = mapNameOrgId.get(AP_Constants.rtCaseAgenziaDipendenti);                   
		                    else
		                    {
	                    	//OAVERSANO 09/01/2019 : Agenzia diretta -- END
	                    		//OAVERSANO 04/04/2019 : DAC FASE II -- START
		                    	if(caseRec.RecordType.developername == AP_Constants.rtCaseDACAXAAgenzie)                    
		                        	orgId = mapNameOrgId.get(AP_Constants.rtCaseDACAXAAgenzie);                   
			                    else
			                    {
		                    	//OAVERSANO 04/04/2019 : DAC FASE II -- END
		                    		//OAVERSANO 17/06/2019 : ING -- START
			                    	if(caseRec.RecordType.developername == AP_Constants.rtCaseTerzeParti)                    
			                        	orgId = mapNameOrgId.get(AP_Constants.rtCaseTerzeParti);                   
				                    else
				                    {
			                    	//OAVERSANO 17/06/2019 : ING -- END
			                    		//OAVERSANO 15/01/2019 : Gestione Reclami -- START
				                    	if(caseRec.RecordType.developername == AP_Constants.rtCaseReclamo)                    
				                        	orgId = mapNameOrgId.get(AP_Constants.rtCaseReclamo);                   
					                    else
					                    {
				                    	//OAVERSANO 15/01/2019 : Gestione Reclami -- END
				                        //MOSCATELLI_M 09/04/2018: Apertura sinistri da email -- START
					                        if(caseRec.RecordType.developername == AP_Constants.rtCaseNonMotor || caseRec.RecordType.developername == 'Close_the_loop')
					                            orgId = mapNameOrgId.get('NonMotor');
					                        else
					                        {
		                                  //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
					                            //if(caseRec.RecordType.developername == AP_Constants.rtCaseQuadra || caseRec.RecordType.developername == AP_Constants.rtCaseAAI || caseRec.RecordType.developername == AP_Constants.rtCaseSinistro)                       
		                                  if(caseRec.RecordType.developername == AP_Constants.rtCaseQuadra || caseRec.RecordType.developername == AP_Constants.rtCaseAAI || caseRec.RecordType.developername == AP_Constants.rtCaseSinistro || caseRec.RecordType.developername == 'Sinistri_AAI')                       			                            
		                                  //MOSCATELLI_M 13/03/2019: Axa Assistance -- END    
		                                      orgId = mapNameOrgId.get('Axa_Assicurazioni');                    
					                            else
					                            {
					                              if(caseRec.RecordType.developername == AP_Constants.rtCaseAMF)
					                                  orgId = mapNameOrgId.get('AMPS_Financial');
					                              else
					                                orgId = mapOrgWideEmailAddress.get(system.label.OrgWideEmailDisplayName);                                
					                            }
					                            /*
					                            if(caseRec.RecordType.developername == AP_Constants.rtCaseQuadra)                       
					                                orgId = mapNameOrgId.get('Quadra');                    
					                            else
					                            {
					                                if(caseRec.RecordType.developername == AP_Constants.rtCaseAAI)
					                                    orgId = mapNameOrgId.get('Axa_Assicurazioni');
					                                else
					                                //CAPOBIANCO_A 24/08/2017 EVO 87: AMF -- START
					                                {
					                                    if(caseRec.RecordType.developername == AP_Constants.rtCaseAMF)
					                                        orgId = mapNameOrgId.get('AMPS_Financial');
					                                    else
					                                    orgId = mapOrgWideEmailAddress.get(system.label.OrgWideEmailDisplayName);
					                                }
					                                //CAPOBIANCO_A 24/08/2017 EVO 87: AMF -- END
					                            }
					                            */                            
					                            //MOSCATELLI_M 09/04/2018: Apertura sinistri da email -- END           
					                        }
					                    }//OAVERSANO 15/01/2019 : Gestione Reclami
				                    }//OAVERSANO 17/06/2019 : ING
			                    }//OAVERSANO 04/04/2019 : DAC Fase II 
		                    }//OAVERSANO 09/01/2019 : Agenzia diretta
	                    }
                	}//OAVERSANO 07/03/2019 : CR ICF
                }
                //CAPOBIANCO_A 30/03/2017 BUGFIXING --- END
                //MOSCATELLI_M 30062015: EVO-12-----END
                mail = new Messaging.SingleEmailMessage(); 
                //OAVERSANO 07/03/2019 : CR ICF -- START
                EmailTemplate emToAgent = new EmailTemplate();
                EmailTemplate emToAdvisor = new EmailTemplate();
                for(EmailTemplate emT : listEmailTemplate)
                	{
                		if(emT.DeveloperName == emailTemplateNotificaAgente)
                		{
                			emToAgent = emT;
                		}
                		else if(emT.DeveloperName == emailTemplateNew_Email_Received)
                		{
                			emToAdvisor = emT;
                		}
                	}  
                if(RecordTypesWithDifferentTemplate.contains(mapCaseIdRecipentEmailToCase.get(caseIdRecipentEmail).RecordType.DeveloperName) && (mapCaseIdRecipentEmailToCase.get(caseIdRecipentEmail).owner.Profile.Name).indexOf('AAI - Vendite')<>-1 )  
                {
                	emailBody = emToAgent.HtmlValue;
                	emailSubject = emToAgent.Subject;
                	emailBody = emailBody.replace('{!Case.Link}', urlSite+mapCaseIdRecipentEmailToCase.get(caseIdRecipentEmail).id );
                }  
                else
                {
                	emailBody = emToAdvisor.HtmlValue;
                	emailSubject = emToAdvisor.Subject;
                	emailBody = emailBody.replace('{!Case.Link}', System.Url.getSalesforceBaseUrl().toExternalForm()+'/'+mapCaseIdRecipentEmailToCase.get(caseIdRecipentEmail).id );
                }       
                /*
                emailBody = listEmailTemplate[0].HtmlValue;
                emailSubject = listEmailTemplate[0].Subject;
                */
                if(emailBody.indexOf('{!Case.CaseNumber}')<>-1)
                	emailBody = emailBody.replace('{!Case.CaseNumber}',mapCaseIdRecipentEmailToCase.get(caseIdRecipentEmail).CaseNumber );
                //OAVERSANO 07/03/2019 : CR ICF -- END
                emailSubject = emailSubject.replace(' {!Case.CaseNumber}',mapCaseIdRecipentEmailToCase.get(caseIdRecipentEmail).CaseNumber );
                
                    
                //MMOSCATELLI 16052016: Bugfix SPAM email--START
                //mail.setToAddresses(new String[] {emailRecipent});
                mail.setTargetObjectId(emailRecipent);
                mail.setSaveAsActivity(false);
                //MMOSCATELLI 16052016: Bugfix SPAM email--END
                if(orgId != null)
                {          
                	mail.setOrgWideEmailAddressId(orgId);
                }else
                {
                    system.debug('>>>### notifyEmailAlert - orgId : null for recordtype : '+caseRec.RecordType.developername);
                }
                mail.setSubject(emailSubject);
                mail.setHtmlBody(emailBody);
                
                if(  
                	(((mapCaseIdRecipentEmailToCase.get(caseIdRecipentEmail).owner.Profile.Name).indexOf('AAI - Vendite')<>-1) && sendNotificationToOwner)
                	||
                	((mapCaseIdRecipentEmailToCase.get(caseIdRecipentEmail).owner.Profile.Name).indexOf('AAI - Vendite')==-1 )
                	)
                {
                listMails.add( mail);
                }
                    
                }//end loop in map ownerid
                system.debug('>>>### notifyEmailAlert - listMails : '+listMails.size());
                Messaging.sendEmail(listMails);
            	
            }
            else
            {
                system.debug('>>>### notifyEmailAlert - sendmail Fail : missing template or organisation email <<< ');
            }//end of check email template
            system.debug('>>> END AP07CaseEmailAlert - notifyEmailAlert <<<');
        }//end of method

        //MOSCATELLI_M 07/09/2018: Modello assistenza -- START
        public static void notifyhd2(List <Case> CaseList)
        {
            string emailBody='' ,emailSubject='',caseId='',emailRecipent='';
            Messaging.SingleEmailMessage mail;
            list<Messaging.SingleEmailMessage> listMails = new list<Messaging.SingleEmailMessage>();
            list<EmailTemplate> listEmailTemplate;

            listEmailTemplate  =  new list<EmailTemplate>([ Select e.HtmlValue, e.Subject
                                                       From    EmailTemplate e 
                                                       where   e.DeveloperName  = :'Risposta_HD3']);
        

            String OrgWideEmail = [SELECT ID,DisplayName,Address FROM OrgWideEmailAddress WHERE DisplayName =:'Assistenza Agenti Axa Assicurazioni'].id;

            for(Case c: CaseList)
            {
                mail = new Messaging.SingleEmailMessage();              
                emailBody = listEmailTemplate[0].HtmlValue;
                emailSubject = listEmailTemplate[0].Subject;         
                emailBody = emailBody.replace('{!Case.Link}', System.Url.getSalesforceBaseUrl().toExternalForm()+'/'+c.id );
                emailSubject = emailSubject.replace(' {!Case.CaseNumber}',c.Casenumber);
                mail.setTargetObjectId(c.OwnerId);
                mail.setSaveAsActivity(false);        
                mail.setOrgWideEmailAddressId(OrgWideEmail);    
                mail.setSubject(emailSubject);
                mail.setHtmlBody(emailBody);                   
                listMails.add( mail);
                    
            }
                system.debug('>>>### notifyEmailAlert - listMails : '+listMails.size());

            if(listMails.size()>0)
            {
              try
              {
                Messaging.sendEmail(listMails);  
              }
              catch(exception e)
              {
                system.debug('@@error: '+e.getmessage());
              }
                                    
            }
        }
        //MOSCATELLI_M 07/09/2018: Modello assistenza -- END
    }//end of class
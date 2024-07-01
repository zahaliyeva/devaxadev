public with sharing class MobilityEmail extends MobilityAbstract{
	
	public class MobilityEmailException extends Exception {}
	public class MobilityEmailResponse extends MobilityResponse{
		@AuraEnabled public List<EmailTemplate> listTemplates;
		@AuraEnabled public List<Folder> listFolders;
	}

	@AuraEnabled
	public static MobilityEmailResponse getFolders(String keyword){
		DebugStart('MobilityEmail', 'getTemplates');

		MobilityEmailResponse response = new MobilityEmailResponse();

		try {

			String keywordToSearch = '%' + keyword.trim() + '%';

			List<AggregateResult> listResult = [
				SELECT Folder.DeveloperName DeveloperName
				FROM EmailTemplate
				WHERE Folder.DeveloperName LIKE :keywordToSearch
				GROUP BY Folder.DeveloperName
			];

			List<String> developerNames = new List<String>();

			for(AggregateResult result : listResult){
				String developerName = (String)result.get('DeveloperName');

				developerNames.add(developerName);
			}

			response.listFolders = [
				SELECT Id, Name
				FROM Folder
				WHERE Id IN :developerNames
			];

			response.isSuccess = true;
		} catch (MobilityEmailException ex) {
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}

	@AuraEnabled
	public static MobilityEmailResponse getTemplates(String keyword){
		DebugStart('MobilityEmail', 'getTemplates');

		MobilityEmailResponse response = new MobilityEmailResponse();

		try {

			String keywordToSearch = '%' + keyword.trim() + '%';

			response.listTemplates = [
				SELECT Id, Name
				FROM EmailTemplate
				WHERE Name LIKE :keywordToSearch
				LIMIT 10
			];

			response.isSuccess = true;
		} catch (MobilityEmailException ex) {
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}

	@AuraEnabled
	public static MobilityEmailResponse sendEmail(
		String fromAddress, 
		String nameFromAddress, 
		List<String> toAddress, 
		List<String> ccAddress, 
		String subject, 
		String body, 
		List<String> files,
		String targetId,
		String templateId
	) {
		DebugStart('MobilityEmail', 'getTemplates');
		boolean createTask = targetId.startsWith('00Q');
		MobilityEmailResponse response = new MobilityEmailResponse();
		Messaging.reserveSingleEmailCapacity(1);
        User currentUser = MobilityUserController.getCurrentUser();
		String emailText;
		try {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
					
			if(String.isNotBlank(templateId)){
				

				mail.setTargetObjectId(targetId);
				//mail.setWhatId(currentUser.Id);
				mail.setTemplateId(templateId);
				mail.setSaveAsActivity(false);
                if(createTask){
                   emailText = Messaging.renderStoredEmailTemplate(templateId, targetId, targetId).getHTMLBody().stripHtmlTags();
                }
                
			}else{
				mail.setHtmlBody(body);
				mail.setToAddresses(toAddress);
				mail.setSubject(subject);
                emailText = body;
			}

			mail.setCcAddresses(ccAddress);
			mail.setReplyTo(fromAddress);
			mail.setSenderDisplayName(nameFromAddress);
			mail.setEntityAttachments(files);
			Messaging.sendEmail(new List<messaging.SingleEmailMessage> {mail});
            if(createTask){
                List<TaskCreationIvass.PBInputs> inputList = new List<TaskCreationIvass.PBInputs>();
                TaskCreationIvass.PBInputs input = new TaskCreationIvass.PBInputs();
                input.templateApiName = 'LeadEmail';
                input.ObjType = 'Lead';
                input.Message = emailText;
                input.Subject = mail.getSubject();
                Lead temp = new Lead(ID = targetId,
                                     CreatedById = currentUser.Id);
                input.Obj = temp;
                inputList.add(input);

                    TaskCreationIvass.createTask(inputList);
                    
                    
                }
			response.isSuccess = true;
		} catch (MobilityEmailException ex) {
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}

}
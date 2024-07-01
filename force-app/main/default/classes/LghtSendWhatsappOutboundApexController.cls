public without sharing class LghtSendWhatsappOutboundApexController extends RLY_Behaviour{
	
	public class LghtSendWhatsappOutboundApexControllerException extends Exception {}

	public class LghtSendWhatsappOutboundApexControllerResponse extends LghtResponse {
		@AuraEnabled public Case caseData;
	}

	public class OutboundMessagingTemplate {
		@AuraEnabled public List<OutboundMessageTemplate__mdt> templatesConfig;
		@AuraEnabled public List<MessagingTemplate> templates;

	}

	@AuraEnabled 
	public static OutboundMessagingTemplate getMessagesTemplates(String channel) {
		OutboundMessagingTemplate res = new OutboundMessagingTemplate();
		res.templatesConfig = [SELECT Id, Label, TemplateName__c  FROM OutboundMessageTemplate__mdt WHERE Channel__c = :channel];
		res.templates = [SELECT Id, DeveloperName, Message, Description FROM MessagingTemplate] ;

		return res;
	}

	@AuraEnabled
	public static LghtSendWhatsappOutboundApexControllerResponse updateCase(Case caseData){
		DebugStart('LghtSendWhatsappOutboundApexControllerResponse', 'updateCase');
		LghtSendWhatsappOutboundApexControllerResponse response = new LghtSendWhatsappOutboundApexControllerResponse();

		try{
			update caseData;

			response.isSuccess = true;
		}catch(LghtSendWhatsappOutboundApexControllerException ex){
			Debug('Exception', ex.getStackTraceString());
			response.errorMessage = ex.getMessage();
		}catch(Exception ex){
			Debug('Exception', ex.getStackTraceString());
			response.errorMessage = ex.getMessage();
		}

		Debug('response', response);
		DebugEnd();
		return response;
	}
    
}
public without sharing class CreateTask {

	@InvocableMethod(label ='Insert Task')
	public static void insertTask(List<Case> cases){
		Map<Id,String> recordTypeCaseMap = RecordTypeUtility.getRecordTypeMap('Case');
		Map<Id,String> recordTypeTaskMap = RecordTypeUtility.getRecordTypeMap('Task');
		List<Task> tasks = new List<Task>();
		for(Case c: cases) {
			 Task t = new Task();
			 t.RecordTypeId = getTaskRecordType(recordTypeCaseMap.get(c.RecordTypeId), recordTypeTaskMap);
			 t.Type = 'Email Automatica';
			 t.TaskSubtype = 'Email';
			 t.OwnerId = c.CreatedById;
			 t.WhoId = c.ContactId;
			 t.Subject = 'Email Automatica';
             t.WhatId = c.Id;
             t.Description = getTaskDescription(c);
			 tasks.add(t);
		 }
		insert tasks;
	}

	private static Id getTaskRecordType(String recordTypeCaseDeveloperName, Map<Id,String> recordTypeTaskMap){
		Id recordTypeTaskIdGenerico = null;
			 for(Id recordTypeTaskId: recordTypeTaskMap.keySet()) {
				  String recordTypeTaskDeveloperName = recordTypeTaskMap.get(recordTypeTaskId);
				  if('Generico'.equals(recordTypeTaskDeveloperName)) {
					   recordTypeTaskIdGenerico = recordTypeTaskId;
				   }
				  if('Axa_Assicurazioni'.equals(recordTypeCaseDeveloperName)) {
					   return RecordTypeUtility.getRecordTypeIdByDeveloperName('Task', 'AXA_Assicurazioni_Task');
				   }
				  if('NonMotor'.equals(recordTypeCaseDeveloperName)) {
					   return RecordTypeUtility.getRecordTypeIdByDeveloperName('Task', 'Non_Motor_Task');
				   }
				  if(recordTypeTaskDeveloperName.equals(recordTypeCaseDeveloperName + '_Task')) {
					   return recordTypeTaskId;
				   }
			  }
		return recordTypeTaskIdGenerico;
	}

	private static String getTaskDescription(Case c){
		String emailTemplate; 
		if(('Richiesta codice sconto').equalsIgnoreCase(c.Category__c) || ('Richiesta codice sconto').equalsIgnoreCase(c.Subcategory__c)) {
			 emailTemplate = System.Label.Notifica_Cliente_Voucher;
			 emailTemplate = emailTemplate.replace('{!PolicyID__c}', c.PolicyId__c == null ? '' : c.PolicyID__c);
			 emailTemplate = emailTemplate.replace('{!Voucher__c}', c.Voucher__c == null ? '' : c.Voucher__c);
		 } else {
			if('Private Area and My Axa'.equalsIgnoreCase(c.LOB__c) || 'Privacy'.equalsIgnoreCase(c.LOB__c) || 'Auto'.equalsIgnoreCase(c.LOB__c)) {
				emailTemplate = System.Label.Notifica_Cliente;
			} else{
			    emailTemplate = System.Label.Notifica_Cliente_Documenti_Necessari;
			}
			emailTemplate = emailTemplate.replace('{!Case.CaseNumber}',c.CaseNumber == null ? '' : c.CaseNumber);
		    emailTemplate = emailTemplate.replace('{!Case.Description}', c.Description == null ? '' : c.Description);
		    emailTemplate = emailTemplate.replace('{!Case.Prodotto__c}', c.Prodotto__c == null ? '' : c.Prodotto__c);
			emailTemplate = emailTemplate.replace('{!Case.SuppliedEmail}', c.SuppliedEmail == null ? '' : c.SuppliedEmail);
			emailTemplate = emailTemplate.replace('{!Case.SuppliedPhone}', c.SuppliedPhone == null ? '' : c.SuppliedPhone);
		}
		return emailTemplate;
	}

}
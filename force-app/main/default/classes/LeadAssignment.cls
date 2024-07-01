/**
 * Intiative: Lead Management - Sprint 45
 * Class that contains the logic of the deduplication and Lead's assignment process
 *----------------------------------------------------------------------------------------------------------------------------
 * History Log
 *
 * Id: 001
 * description: Lead Management - Sprint 46: Set send email notification to TRUE to allow the email alerts of Flow Lead: Email
 * Notification Web
 * date: 12/07/2017
 * author: Juana Valenzuela
 */
public without sharing class LeadAssignment {
//BOVOLENTA_D 01/08/2017 Made the class without sharing as Internal user need to update assegnazioni and lead
	/**
	 * Initiative: Lead-Management Sprint 45: Class the wraps the list to identify Leads for assignment
	 * @author Juana Valenzuela
	 * @date 08/06/2017
	 * @param leadsList1,leadsList2: List of Leads populated as required according to the Lead Assignment process
	 */


	private static Set<String> canRedirect = new Set<String>();

	public class LeadsListsWrapper {
		public List<Lead> leadsList1 {get; set;}
		public List<Lead> leadsList2 {get; set;}

		public LeadsListsWrapper(List<Lead> leadsList1, List<Lead> leadsList2){
			this.leadsList1 = leadsList1;
			this.leadsList2 = leadsList2;
		}
	}
	public class LeadsMapsWrapper {
		public Map<Id,Lead> leadsMap1 {get; set;}
		public Map<Id,Lead> leadsMap2 {get; set;}
		public Map<Id,Lead> leadsMap3 {get; set;}

		public LeadsMapsWrapper(Map<Id,Lead> leadsMap1, Map<Id,Lead> leadsMap2, Map<Id,Lead> leadsMap3){
			this.leadsMap1 = leadsMap1;
			this.leadsMap2 = leadsMap2;
			this.leadsMap3 = leadsMap3;
		}
		public LeadsMapsWrapper(){
		}
	}
	public class ResponseDto { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
		public Boolean isSuccess { get; set; }
		public String message { get; set; }
		public Map<Object, Object> values { get; set; }
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

	private static void setCanRedirect(){
		List<AggregateResult> ActiveMembersQueue = [Select Group.Developername from GroupMember where Group.Type = 'Queue' AND Group.Developername like 'Coda_Agenzia%' AND (NOT Group.Developername Like 'Coda_Agenzia_Case_%') AND UserOrGroupId in (select id from user where IsActive = true and Profile.Name like '%AAI - Vendite%')  group by Group.DeveloperName]; // NOPMD  Fix CRUD violation
		for(AggregateResult gm : ActiveMembersQueue ){
			canRedirect.add(((String)gm.get('Developername')).substringAfter('Coda_Agenzia_'));
		}
	}

	/**
	 * Initiative: Lead-Management Sprint 45: Method that returns the map of Leads with and without phone number to be
	 * assigned to specific queue
	 * @author Juana Valenzuela
	 * @date 08/06/2017
	 * @param newLeadList: list of new Lead. Assumes that are present only Web Lead
	 */
	public static LeadsListsWrapper getLeadsWithoutWithPhone(List<Lead> newLeadsList){
		List<Lead> leadsWithoutPhone = new List<Lead>();
		List<Lead> leadsWithPhone = new List<Lead>();
		List<Lead> leadSitiAgentiList = new List<Lead>();
		Id leadWithoutPhoneQueue = UtilityClass.retrieveGroupId('Queue','Coda_Web_Lead_senza_telefono');
		for(Lead tempLead:newLeadsList) {
			 if(tempLead.Phone == null || tempLead.Phone == '') {
				  tempLead.OwnerId = leadWithoutPhoneQueue;
				  tempLead.TECH_Send_Email_Notification__c = false;
				  leadsWithoutPhone.add(tempLead);
			  }else{
				  leadsWithPhone.add(tempLead);
			  }
		 }
		LeadsListsWrapper leadsWithoutWithPhone = new LeadsListsWrapper(leadsWithoutPhone,leadsWithPhone);
		return leadsWithoutWithPhone;
	}

	//CAPOBIANCO_A 28/07/2017 - START - New logic for Visualizza quotazione Web Leads and Richiedi Appuntamento without agency Code
	public static LeadsListsWrapper getWebVisualizzaQuotazioneLeads(List<Lead> newLeadsList){
		List<Lead> leadsWeb = new List<Lead>();
		List<Lead> leadsNotWeb = new List<Lead>();
		Id leadVisualizzaQuotWebQueue = UtilityClass.retrieveGroupId('Queue','Coda_Lead_Visualizza_Quotazione');

		for(Lead tempLead:newLeadsList) {
			 if(tempLead.Dettaglio__c == 'Visualizza quotazione' && tempLead.TECH_Massively_uploaded_web_lead__c == false) {
				  tempLead.OwnerId = leadVisualizzaQuotWebQueue;
				  tempLead.TECH_Send_Email_Notification__c = false;
				  leadsWeb.add(tempLead);
			  }else{
				  leadsNotWeb.add(tempLead);
			  }
		 }
		LeadsListsWrapper leadsVisualizzaQuotazioneWeb = new LeadsListsWrapper(leadsWeb, leadsNotWeb);
		return leadsVisualizzaQuotazioneWeb;
	}

	public static LeadsListsWrapper getRichiediAppuntamento(List<Lead> newLeadsList){
		List<Lead> leadsWithCode = new List<Lead>();
		List<Lead> leadsWithoutCode = new List<Lead>();
		Id leadGenericQueue = UtilityClass.retrieveGroupId('Queue','AAI_Lead_Queue');

		for(Lead tempLead:newLeadsList) {
			 if(tempLead.Dettaglio__c == 'Richiedi appuntamento') {
				  tempLead.OwnerId = leadGenericQueue;
				  tempLead.TECH_Send_Email_Notification__c = false;
				  leadsWithoutCode.add(tempLead);
			  }else{
				  leadsWithCode.add(tempLead);
			  }
		 }
		LeadsListsWrapper leadsRichiediAppuntamentoWithoutCode = new LeadsListsWrapper(leadsWithoutCode, leadsWithCode);
		return leadsRichiediAppuntamentoWithoutCode;
	}
	//CAPOBIANCO_A 28/07/2017 - END

	//FM - 29/12/2017 Added to manage the new process Lead Management order - START

	public static LeadsListsWrapper getSalvaVisualizzaQuotazione(List<Lead> newLeadsList){
		List<Lead> SalvaVisualizza = new List<Lead>();
		List<Lead> Richiediappuntamento = new List<Lead>();
		//Id leadGenericQueue = UtilityClass.retrieveGroupId('Queue','AAI_Lead_Queue');

		for(Lead tempLead:newLeadsList) {
			 if(tempLead.Dettaglio__c == 'Salva quotazione' || tempLead.Dettaglio__c == 'Visualizza quotazione') {
				  //tempLead.OwnerId = leadGenericQueue;
				  //tempLead.TECH_Send_Email_Notification__c = false;
				  SalvaVisualizza.add(tempLead);
			  }else{
				  Richiediappuntamento.add(tempLead);
			  }
		 }
		LeadsListsWrapper leadSalvaVisualizzaRichiedi = new LeadsListsWrapper(SalvaVisualizza, Richiediappuntamento);
		return leadSalvaVisualizzaRichiedi;
	}

	//FM 29/12/1990 - END

	/**
	 * Initiative: Lead-Management Sprint 45: Method that returns the map of Leads without the leads that had been assigned
	 * @author Juana Valenzuela
	 * @date 08/06/2017
	 * @param leadsNotAssignedMap: Initial map of Leads before assignment
	 *        assignedLeadsList: Leads to remove fomr the map
	 * @return leadsNotAssignedMap: Original map without the Leads present in assignedLeadsList
	 */
	public static Map<Id,Lead> removeAssignedLeads(Map<Id,Lead> leadsNotAssignedMap, List<Lead> assignedLeadsList){
		for(Lead tempLead:assignedLeadsList)
			leadsNotAssignedMap.remove(tempLead.Id);
		return leadsNotAssignedMap;
	}

	public static LeadsListsWrapper getDuplicatedLeadsWithLeads(List<Lead> leadsForLeadDuplication){
		//If the Lead has the phone number, run Duplicate process
		//If "Dettaglio fonte Lead" (Dettaglio__c) is "Salva quotazione", run duplicate process on Lead
		Map<Id,Lead> leadsForDuplicateClients = new Map<Id,Lead>();
		List<Lead> leadsSalvaQuotazione = new List<Lead>();
		List<Lead> leadsWithError = new List<Lead>();
		List<Lead> leadsRichiediAppuntamento = new List<Lead>();
		String salvaQuotazione = UtilityClass.getPicklistValue(leadsForLeadDuplication.get(0),'Dettaglio__c').get('Salva quotazione');
		String visualizzaQuotazione = UtilityClass.getPicklistValue(leadsForLeadDuplication.get(0),'Dettaglio__c').get('Visualizza quotazione');
		String richiediAppuntamento = UtilityClass.getPicklistValue(leadsForLeadDuplication.get(0),'Dettaglio__c').get('Richiedi appuntamento');
		for(Lead tempLead:leadsForLeadDuplication) {
			 system.debug ('********tempLead'+tempLead);
			 leadsForDuplicateClients.put(tempLead.Id,tempLead);
			 if(tempLead.Dettaglio__c != null) { //Is expected not to happen because if not present, the default value is setted in the handler

				  if((tempLead.Dettaglio__c == salvaQuotazione || tempLead.Dettaglio__c == visualizzaQuotazione)  && tempLead.PostalCode != null && tempLead.PostalCode != '' &&
					 tempLead.Landing_Page__c != null && tempLead.Landing_Page__c != '')
					  leadsSalvaQuotazione.add(tempLead);
				  else if(tempLead.Landing_Page__c == null || tempLead.Landing_Page__c == '') {
					   tempLead.Azioni_intraprese_sul_Lead__c ='Il Lead non ha il valore di origine, necessario per il processo di deduplica';
					   leadsWithError.add(tempLead);
				   }else if (tempLead.Dettaglio__c == richiediAppuntamento   && tempLead.PostalCode != null && tempLead.PostalCode != '' &&
							 tempLead.Landing_Page__c != null && tempLead.Landing_Page__c != '')
				   {
					   leadsRichiediAppuntamento.add(tempLead);
				   }
			  }
		 }
		List<Lead> duplicatedLeadsList = assignDuplicatedLeads(leadsSalvaQuotazione).leadsMap2.values();
		LeadsMapsWrapper richiediAppuntamentoDeduplicationResults = assignDuplicatedLeads(leadsRichiediAppuntamento);
		List<Lead> oldDuplicatedLeadtoMove = richiediAppuntamentoDeduplicationResults.leadsMap1.values(); //BOVOLENTA_D 08012917 added to handle the richiedi appuntamento deduplication
		List<Lead> oldDuplicatedSQtoIgnore = richiediAppuntamentoDeduplicationResults.leadsMap3.values(); //SERGER_T added to handle the case when the RA is the same agency with SQ
		//List<Lead> newDuplicatedLeadtoMoveInGenericList = richiediAppuntamentoDeduplicationResults.leadsMap2.values(); //New leads to update
		//HANDLING OF OLD DUPLICATES - Move to queue and notify old owners
		if (oldDuplicatedLeadtoMove.size()>0) {
			 system.debug('+++++++Tugal: OLD LEADS --> ' + oldDuplicatedLeadtoMove);
			 Id leadRemovedWebQueue = UtilityClass.retrieveGroupId('Queue','Coda_lead_web_duplicati_ass_rimossa');
			 UtilityClass.reassignToUniqueNewOwnerAndNotifyOldOwner (oldDuplicatedLeadtoMove, leadRemovedWebQueue, 'Leads_Lead_deletion_notification_AAI', true, true);
		 }
		if (oldDuplicatedSQtoIgnore.size()>0) {
			 system.debug('+++++++Tugal: SQ LEADS --> ' + oldDuplicatedSQtoIgnore);
			 Id leadRemovedWebQueue = UtilityClass.retrieveGroupId('Queue','Coda_lead_web_duplicati_ass_rimossa');
			 UtilityClass.reassignToUniqueNewOwnerAndNotifyOldOwner (oldDuplicatedSQtoIgnore, leadRemovedWebQueue, 'Leads_Lead_deletion_notification_AAI', false, true);
		 }
		//END
		duplicatedLeadsList.addAll(leadsWithError);
		leadsForDuplicateClients = removeAssignedLeads(leadsForDuplicateClients,duplicatedLeadsList);
		LeadsListsWrapper leadsAfterLeadDuplication = new LeadsListsWrapper(duplicatedLeadsList,leadsForDuplicateClients.values());
		return leadsAfterLeadDuplication;
	}

	/**
	 * Initiative: Lead-Management Sprint 45: Method that identifies the duplicated Leads "Salva quotazione" and
	 * prepare them for assigning to the respective queue. duplicate Lead are identified considering only the Leads
	 * created during the last 7 days and with the same First Name, Last Name, CAP and "quotatore". Sets duplicated Leads
	 * "Salva quotazione" with the OwnerId set to the specific queue
	 * @author Juana Valenzuela
	 * @date 05/06/2017
	 * @param newLeadList: List of Lead "Salva quotazione" with CAP and Landing Page
	 * @return duplicatedLeadsMap: Map of the new Leads that were identified as duplicated Leads "Salva quotazione"
	 * BOVOLENTA_D 10/012018 Edited to handle Richiedi appuntamento deduplication and behaviour
	 */
	private static LeadsMapsWrapper assignDuplicatedLeads(List<Lead> newLeadList){
		LeadsMapsWrapper oldNewDuplicatedMaps = new LeadsMapsWrapper();
		Map<Id,Lead> duplicatedOldLeadsMap = new Map<Id,Lead>();
		Map<Id,Lead> duplicatedLeadsMap = new Map<Id,Lead>();
		Map<Id,Lead> SQtoRAsameAgency = new Map<Id,Lead>();
		String richiediAppuntamento = 'Richiedi appuntamento';
		List<Lead> existingLeadList = new List<Lead>();
		List<String> leadFirstNameList = new List<String>();
		List<String> leadLastNameList = new List<String>();
		List<String> leadPostalCodeList = new List<String>();
		List<String> leadLandingPageList = new List<String>();
		List<Id> leadQueuesNotSearchable = new List<Id>();


		Id duplicatedLeadsQueue = UtilityClass.retrieveGroupId('Queue','Coda_Lead_duplicati_Salva_quotazione');
		leadQueuesNotSearchable.add(duplicatedLeadsQueue);

		//CAPOBIANCO_A 20/07/2017 -- START
		Id genericLeadQueue = UtilityClass.retrieveGroupId('Queue','AAI_Lead_Queue');
		leadQueuesNotSearchable.add(genericLeadQueue);

		Id wrongContactLeadQueue = UtilityClass.retrieveGroupId('Queue','Coda_Lead_Contatto_Errato');
		leadQueuesNotSearchable.add(wrongContactLeadQueue);

		Id toBeProcessedLeadReassigned = UtilityClass.retrieveGroupId('Queue','Coda_Lead_Da_Processare_Riassegnate');
		leadQueuesNotSearchable.add(toBeProcessedLeadReassigned);

		Id doesNotAnswerLeadReassigned = UtilityClass.retrieveGroupId('Queue','Coda_Lead_Non_Risponde_Riassegnate');
		leadQueuesNotSearchable.add(doesNotAnswerLeadReassigned);

		Id leadsWithoutPhone = UtilityClass.retrieveGroupId('Queue','Coda_Web_Lead_senza_telefono');
		leadQueuesNotSearchable.add(leadsWithoutPhone);

		//CAPOBIANCO_A 28/07/2017 -- START - New logic for Visualizza quotazione Web Leads
		Id leadsVisualizzaQuotazioneWeb = UtilityClass.retrieveGroupId('Queue','Coda_Lead_Visualizza_Quotazione');
		leadQueuesNotSearchable.add(leadsVisualizzaQuotazioneWeb);
		//CAPOBIANCO_A 28/07/2017 -- END

		//BOVOLENTA_D 11082017 ADDING Unassigned SQ leads
		Id leadNotAssignedQueue = UtilityClass.retrieveGroupId('Queue','Coda_Lead_Salva_Quotazione_non_assegnati');
		leadQueuesNotSearchable.add(leadNotAssignedQueue);

		//BOVOLENTA_D 10012018 ADDING TO HANDLE REMOVED LEADS
		Id leadRemovedWebQueue = UtilityClass.retrieveGroupId('Queue','Coda_lead_web_duplicati_ass_rimossa');
		leadQueuesNotSearchable.add(leadRemovedWebQueue);

		//BOVOLENTA_D 12012018 ADDING TO HANDLE KO INTEGRATIONS
		Id leadKOIntegration = UtilityClass.retrieveGroupId('Queue','Coda_Lead_Non_Assegnati_Integrazione_KO');
		leadQueuesNotSearchable.add(leadKOIntegration);


		system.debug('#@# lead queues not searchable '+leadQueuesNotSearchable);

		//Leads which are massively uploaded need to be de-duplicated with leads created from the 7 days
		//before the quotation request date until today
		List<String> leadFirstNameListWithRequest = new List<String>();
		List<String> leadLastNameListWithRequest = new List<String>();
		List<String> leadPostalCodeListWithRequest = new List<String>();
		List<String> leadLandingPageListWithRequest = new List<String>();
		List<Lead> leadListWithQuotationRequestDate = new List<Lead>();
		List<Lead> leadListWithoutQuotationRequestDate = new List<Lead>();
		List<Lead> existingLeadsForLeadsWithRequestDate = new List<Lead>();
		Datetime minimumQuotationRequestDate = system.now();
		Datetime dateToQuery = system.now();

		//Splitting the list in 2 sublists, one containing the leads with a quotation request date and
		//the second one containing the leads without
		for(Lead tempLead:newLeadList) {
			 if(tempLead.Data_richesta_quotazione__c==null && tempLead.TECH_Massively_uploaded_web_lead__c == true)
			  {
				  leadListWithoutQuotationRequestDate.add(tempLead);
			  }
			 else
			  {
				  leadListWithQuotationRequestDate.add(tempLead);
			  }
		 }
		System.debug('*****leadListWithoutQuotationRequestDate: '+leadListWithoutQuotationRequestDate+' - leadListWithQuotationRequestDate: '+leadListWithQuotationRequestDate);
		//filling the Lists needed to perform the first query with the information about the first sublist
		for(Lead leadWithoutRequest: leadListWithoutQuotationRequestDate)
		 {
			 leadFirstNameList.add(leadWithoutRequest.FirstName);
			 leadLastNameList.add(leadWithoutRequest.LastName);
			 leadPostalCodeList.add(leadWithoutRequest.PostalCode);
			 leadLandingPageList.add(leadWithoutRequest.Landing_Page__c);
		 }

		//filling the Lists needed to perform the second query with the second sublist,
		//and setting the minimum quotation date
		for(Lead leadWithRequest: leadListWithQuotationRequestDate)
		 {
			 if(leadWithRequest.Data_richesta_quotazione__c < minimumQuotationRequestDate)
			  {
				  minimumQuotationRequestDate = leadWithRequest.Data_richesta_quotazione__c;
			  }
			 leadFirstNameListWithRequest.add(leadWithRequest.FirstName);
			 leadLastNameListWithRequest.add(leadWithRequest.LastName);
			 leadPostalCodeListWithRequest.add(leadWithRequest.PostalCode);
			 leadLandingPageListWithRequest.add(leadWithRequest.Landing_Page__c);
		 }

		//if the lead uploaded has a quotation request date older than 7 days,
		//set the minimum to 7 days
		if(minimumQuotationRequestDate <= system.today().addDays(-7))
		 {
			 minimumQuotationRequestDate = system.today().addDays(-7);
		 }

		Integer lastDaysForLeadDuplication = Integer.valueOf(LeadAssignmentConfiguration__c.getAll().get('Last n days for Lead duplication').DaysLimit__c);
		Integer lastDaysForLeadDuplicationWithRequest = Integer.valueOf(LeadAssignmentConfiguration__c.getAll().get('Last n days for duplication M upload').DaysLimit__c);
		String lastDaysNumber = String.valueOf(lastDaysForLeadDuplication);
		//retrieve the leads created up to 7 days before the minimum date
		dateToQuery = minimumQuotationRequestDate.addDays(-lastDaysForLeadDuplicationWithRequest);
		System.debug ('****dateToQuery: '+dateToQuery);
		/*BOVOLENTA_D 02082017 REMOVED as date comparison is wrong

        String dayToQuery = String.valueOf(dateToQuery.day());
        String monthToQuery = String.valueOf(dateToQuery.month());
        String yearToQuery = String.valueOf(dateToQuery.year());
        String stringDateToQuery = 'CALENDAR_YEAR(CreatedDate) = '+yearToQuery+' AND CALENDAR_MONTH(CreatedDate) >= '+monthToQuery+' AND DAY_IN_MONTH(CreatedDate) >= '+dayToQuery;
        System.debug ('#@#@ stringDateToQuery '+stringDateToQuery);
        System.debug('#@#@ Minimum date '+minimumQuotationRequestDate);
        System.debug('#@#@ Date to Query '+dateToQuery);*/

		String stringDateToQuery = ' CreatedDate > :dateToQuery ';
		List<String> leadSource = new list<String>();
		leadSource.add ('Web');
		String existingLeadsQuery = 'SELECT Id,LastName,FirstName,PostalCode,Landing_Page__c,Dettaglio__c,Status,OwnerId,Numero_quotazioni__c,Data_ultima_quotazione__c,Agency_Code__c FROM Lead WHERE LastName IN :leadLastNameList AND FirstName IN :leadFirstNameList AND CreatedDate = LAST_N_DAYS:' + lastDaysNumber +' AND Landing_Page__c IN :leadLandingPageList AND PostalCode IN :leadPostalCodeList AND OwnerID NOT IN :leadQueuesNotSearchable AND LeadSource IN :leadSource ';
		System.debug('#@#@ existing leads query: '+String.escapeSingleQuotes(existingLeadsQuery));
		System.debug('#@#@ existing leads query parameters: leadLastNameList - '+leadLastNameList+' - leadFirstNameList - '+leadLandingPageList+' - leadPostalCodeList - '+leadPostalCodeList+' - leadQueuesNotSearchable - '+leadQueuesNotSearchable);
		existingLeadList = Database.query(String.escapeSingleQuotes(existingLeadsQuery));
		System.debug('#@#@ existing leads '+existingLeadList);

		if(leadListWithQuotationRequestDate.size() != 0)
		 {
			 String existingLeadsForLeadsWithRequestDateQuery = 'SELECT Id,LastName,FirstName,PostalCode,Landing_Page__c,Dettaglio__c,Status,OwnerId,Numero_quotazioni__c,Data_ultima_quotazione__c,Agency_Code__c FROM Lead WHERE LastName IN :leadLastNameListWithRequest AND FirstName IN :leadFirstNameListWithRequest AND ' + stringDateToQuery +' AND Landing_Page__c IN :leadLandingPageListWithRequest AND PostalCode IN :leadPostalCodeListWithRequest AND OwnerID NOT IN: leadQueuesNotSearchable AND LeadSource IN :leadSource ';
			 existingLeadsForLeadsWithRequestDate = Database.query(String.escapeSingleQuotes(existingLeadsForLeadsWithRequestDateQuery));
			 System.debug('#@#@ existing leads query parameters: leadLastNameListWithRequest - '+leadLastNameListWithRequest+' - leadFirstNameListWithRequest - '+leadFirstNameListWithRequest+' - leadLandingPageListWithRequest '+leadLandingPageListWithRequest+' - leadPostalCodeListWithRequest - '+leadPostalCodeListWithRequest+' - leadQueuesNotSearchable - '+leadQueuesNotSearchable);

		 }
		System.debug('#@#@ existing leads for leads with request date '+existingLeadsForLeadsWithRequestDate);

		//Create map with the list of each "quotatore"
		Map<String,List<Lead> > mapQuotatoreLeadList = new Map<String,List<Lead> >();

		for(Lead temExistingLead:existingLeadList) {
			 if(mapQuotatoreLeadList.get(temExistingLead.Landing_Page__c)==null)
				 mapQuotatoreLeadList.put(temExistingLead.Landing_Page__c,new List<Lead>());
			 mapQuotatoreLeadList.get(temExistingLead.Landing_Page__c).add(temExistingLead);
		 }

		if(existingLeadsForLeadsWithRequestDate.size() != 0)
		 {
			 for(Lead temExistingLead2:existingLeadsForLeadsWithRequestDate) {
				  if(mapQuotatoreLeadList.get(temExistingLead2.Landing_Page__c)==null)
					  mapQuotatoreLeadList.put(temExistingLead2.Landing_Page__c,new List<Lead>());
				  mapQuotatoreLeadList.get(temExistingLead2.Landing_Page__c).add(temExistingLead2);
			  }
		 }

		system.debug('#@#@# map quotatore lead list '+mapQuotatoreLeadList);
		Set<Lead> oldLeadToHistoricize = new Set<Lead>(); //BOVOLENTA_D 10012018 US635
		Map <Id,Lead> oldLeadToHistoricizeMap = new Map<Id,Lead>();
		for(Lead tempLead:newLeadList) {
			 if(mapQuotatoreLeadList.keySet().contains(tempLead.Landing_Page__c))
			  {
				  List<Lead> quotatoreLeadList = mapQuotatoreLeadList.get(tempLead.Landing_Page__c);
				  Set<Lead> quotatoreLeadSet = new Set<Lead>();//BOVOLENTA_D 10012018 US635
				  quotatoreLeadSet.addAll (quotatoreLeadList);
				  for(Lead tempQuotatoreLead:quotatoreLeadSet) {
					   if(tempLead.Id != tempQuotatoreLead.Id && tempLead.LastName == tempQuotatoreLead.LastName &&
						  tempLead.FirstName == tempQuotatoreLead.FirstName && tempLead.PostalCode == tempQuotatoreLead.PostalCode) {
							if (tempLead.Dettaglio__c != richiediAppuntamento ) { //BOVOLENTA_D US648 Handling the Salva/Visualizza case
								 tempLead.OwnerId = duplicatedLeadsQueue;
								 tempLead.TECH_Send_Email_Notification__c = false;
								 duplicatedLeadsMap.put(tempLead.Id,tempLead);
								 //BOVOLENTA_D 10012018 US635
								 tempQuotatoreLead.Numero_quotazioni__c = tempQuotatoreLead.Numero_quotazioni__c+1;
								 tempQuotatoreLead.Data_ultima_quotazione__c = tempLead.Data_richesta_quotazione__c == null ? tempLead.CreatedDate : tempLead.Data_richesta_quotazione__c;
								 oldLeadToHistoricizeMap.put(tempQuotatoreLead.Id,tempQuotatoreLead);
								 //BOVOLENTA_D END 10012018 US635
							 }else if ( tempQuotatoreLead.Dettaglio__c != richiediAppuntamento && tempQuotatoreLead.Status == 'To be processed') //BOVOLENTA_D US648 Handling the Richiedi appuntamento where the old lead is Salva/Visualizza and not already changed
							 {
								 tempLead.Numero_quotazioni__c = tempQuotatoreLead.Numero_quotazioni__c+1;
								 tempLead.Data_richesta_quotazione__c = tempQuotatoreLead == null ? tempQuotatoreLead.CreatedDate : tempQuotatoreLead.Data_ultima_quotazione__c;
								 duplicatedLeadsMap.put(tempLead.Id,tempLead); //NEW LEADS
								 if(tempQuotatoreLead.Agency_Code__c == tempLead.Agency_Code__c)
									 SQtoRAsameAgency.put(tempQuotatoreLead.Id,tempQuotatoreLead); //OLD LEADS (duplicated with RA to the same agency)
								 else
									 duplicatedOldLeadsMap.put(tempQuotatoreLead.Id,tempQuotatoreLead); //OLD LEADS (other)
							 }
						}
				   }
			  }
			 //CAPOBIANCO_A 20/07/2017 SPRINT 46 -- END
		 }
		List<Lead> oldLeadToHistoricizeList = new list<Lead>(oldLeadToHistoricizeMap.values());
		Database.SaveResult[] srList = database.update (oldLeadToHistoricizeList,false); //BOVOLENTA_D 10012018 US635
		system.debug ('**********srList'+srList);
		oldNewDuplicatedMaps.leadsMap1 = duplicatedOldLeadsMap;
		oldNewDuplicatedMaps.leadsMap2 = duplicatedLeadsMap;
		oldNewDuplicatedMaps.leadsMap3 = SQtoRAsameAgency;
		return oldNewDuplicatedMaps;
	}

	/**
	 * Initiative: Lead-Management Sprint 45: Method that identifies the duplicated Leads with existing clients. The
	 * control is made according to the Fiscal ID or the PIVA if the info is present. The method identifies the Leads
	 * without duplicate, the Leads duplicated once and the Leads duplicated with more than one agency.
	 * @author Juana Valenzuela
	 * @date 06/06/2017
	 * @param newLeadList: List of Leads for duplication process with existing clients. Are excluded "Siti agenti"
	 */
	public static LeadsListsWrapper duplicationWithClients(List<Lead> newLeadList){
		//[03/07/17]JV - Start
		Id b2cClientRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'B2C_Client'].Id;
		Id b2bClientRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'B2B_Client'].Id;
		//Id b2cClientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId();
		//Id b2bClientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B Client').getRecordTypeId();
		//[03/07/17]JV - End
		system.debug('***JV record type Account: B2C - ' + b2cClientRecordTypeId + ' B2B - ' + b2bClientRecordTypeId);
		Map <String,List<Account> > accDuplicatedClientsMap = new Map<String,List<Account> >();
		List<Lead> leadsForClientDuplication = new List<Lead>();
		List<String> pivaList = new List<String>();
		List<String> fiscalCodeList = new List<String>();
		List<Lead> leadsForPolicyControl = new List<Lead>();
		//To assign according to Noovle service
		List<Lead> leadsNotDuplicatedWithClients = new List<Lead>();
		//To assign to exisisting client's agency
		List<Lead> leadsDuplicatedOnce = new List<Lead>();
		//To assign to predefined agency. Not included in the assignment process
		List<Lead> leadSitiAgentiList = new List<Lead>();
		List<Lead> assignedLeads = new List<Lead>();
		for(Lead tempLead:newLeadList) {
			 if(tempLead.AAI_Partita_IVA__c != null && tempLead.AAI_Partita_IVA__c != '') {
				  pivaList.add(tempLead.AAI_Partita_IVA__c);
				  leadsForClientDuplication.add(tempLead);
			  }else if(tempLead.Fiscal_ID__c != null && tempLead.Fiscal_ID__c != '') {
				  fiscalCodeList.add(tempLead.Fiscal_ID__c);
				  leadsForClientDuplication.add(tempLead);
			  }else{
				  //The Leads without PIVA or Fiscal Code are not included in duplication process
				  leadsNotDuplicatedWithClients.add(tempLead);
			  }
		 }
		system.debug('****JV - pivaList: ' + pivaList);
		system.debug('****JV - codice fiscale list: ' + fiscalCodeList);
		//Create map with duplicated clients list with key = PIVA or key = Fiscal Code. It assumes that PIVA and
		//Fiscal Code will never be the same

        Set<String> accountActiveState = AP_Constants.getActiveStatusAccount();

		for(Account tempAccount:[SELECT Id,AAI_Partita_IVA__c,AAI_Agency_Reference_Code__c,FirstName,LastName // NOPMD  Fix CRUD violation
								 FROM Account
								 WHERE RecordTypeId = :b2bClientRecordTypeId AND
													  AAI_Agency__r.Active__c = TRUE AND
																				State__c in :accountActiveState AND
																						   AAI_Agency__r.Accordo_Digitale__c = TRUE AND
																															   AAI_Partita_IVA__c IN :pivaList ]) {
			 if(accDuplicatedClientsMap.get(tempAccount.AAI_Partita_IVA__c) == null)
				 accDuplicatedClientsMap.put(tempAccount.AAI_Partita_IVA__c,new List<Account>());
			 accDuplicatedClientsMap.get(tempAccount.AAI_Partita_IVA__c).add(tempAccount);
		 }
		for(Account tempAccount:[SELECT Id,AAI_Agency_Reference_Code__c,AAI_Codice_Fiscale__c,FirstName,LastName // NOPMD  Fix CRUD violation
								 FROM Account
								 WHERE RecordTypeId=:b2cClientRecordTypeId AND
													 AAI_Agency__r.Active__c = TRUE AND
																			   State__c = :accountActiveState AND
																						  AAI_Agency__r.Accordo_Digitale__c = TRUE AND
																															   ( AAI_Codice_Fiscale__c IN :fiscalCodeList OR AAI_Partita_IVA__c IN :fiscalCodeList ) ]) {
			 if(accDuplicatedClientsMap.get(tempAccount.AAI_Codice_Fiscale__c) == null)
				 accDuplicatedClientsMap.put(tempAccount.AAI_Codice_Fiscale__c.tolowercase(),new List<Account>());
			 accDuplicatedClientsMap.get(tempAccount.AAI_Codice_Fiscale__c.tolowercase()).add(tempAccount);
		 }
		//Verify the dupplicated client for each Lead. Considers only Leads with PIVA or Fiscal Code
		for(Lead tempLead:leadsForClientDuplication) {
			 String mapKeyValue = '';
			 if(tempLead.AAI_Partita_IVA__c != null && tempLead.AAI_Partita_IVA__c != '')
				 mapKeyValue = tempLead.AAI_Partita_IVA__c;
			 else
				 mapKeyValue = tempLead.Fiscal_ID__c.tolowercase();
			 List<Account> listDuplicatedClients = accDuplicatedClientsMap.get(mapKeyValue);
			 if(listDuplicatedClients == null) {
				  //Not duplicated. Ready for calling the service Noovle
				  leadsNotDuplicatedWithClients.add(tempLead);
			  }else{
				  if(listDuplicatedClients.size() == 1) {
					   //Duplicated with only one client. Proceed with assignment to client's agency
					   if(listDuplicatedClients.get(0).AAI_Agency_Reference_Code__c != null && listDuplicatedClients.get(0).AAI_Agency_Reference_Code__c != '') {
							tempLead.Agency_Code__c = listDuplicatedClients.get(0).AAI_Agency_Reference_Code__c;
							//FM 10/01/2018 - addedd for Sprint 59 US-0643
							tempLead.TECH_duplicatedwithClient__c=true;
							tempLead.Ultima_data_di_riassegnazione__c = Datetime.now();
							if(tempLead.Numero_assegnazioni_eseguite__c == null)
								tempLead.Numero_assegnazioni_eseguite__c = 0;
							tempLead.Numero_assegnazioni_eseguite__c += 1;
							//Start - 001
							tempLead.TECH_Send_Email_Notification__c = true;
							//End - 001
							leadsDuplicatedOnce.add(tempLead);
							assignedLeads.add(tempLead);
							accDuplicatedClientsMap.remove(mapKeyValue);
						}else{
							//Start - 001
							tempLead.Azioni_intraprese_sul_Lead__c = 'Il cliente ' + listDuplicatedClients.get(0).FirstName + ' ' + listDuplicatedClients.get(0).LastName + ' con cui il Lead risulta duplicato, non ha il codice di agenzia';
							leadsDuplicatedOnce.add(tempLead);
							//End - 001
						}
				   }else{
					   //Duplicated with more than one client
					   Boolean sameAgency = true;
					   String agency = '';
					   if(listDuplicatedClients.get(0).AAI_Agency_Reference_Code__c != null && listDuplicatedClients.get(0).AAI_Agency_Reference_Code__c != '') {
							agency = listDuplicatedClients.get(0).AAI_Agency_Reference_Code__c;
							for(Account tempAccount:listDuplicatedClients) {
								 if(tempAccount.AAI_Agency_Reference_Code__c != agency)
									 sameAgency = false;
							 }
							//If all the duplicated clients are assigned to the same agency, assign the Lead
							if(sameAgency) {
								 tempLead.Agency_Code__c = agency;
								 //FM 10/01/2018 - addedd for Sprint 59 US-0643
								 tempLead.TECH_duplicatedwithClient__c=true;
								 tempLead.Ultima_data_di_riassegnazione__c = Datetime.now();
								 if(tempLead.Numero_assegnazioni_eseguite__c == null)
									 tempLead.Numero_assegnazioni_eseguite__c = 0;
								 tempLead.Numero_assegnazioni_eseguite__c += 1;
								 //Start - 001
								 tempLead.TECH_Send_Email_Notification__c = true;
								 //End - 001
								 assignedLeads.add(tempLead);
								 leadsDuplicatedOnce.add(tempLead);
								 accDuplicatedClientsMap.remove(mapKeyValue);
							 }
							//Proceed with control over insurance policies
							else{
								 leadsForPolicyControl.add(tempLead);
							 }
						}
					   //ELSE ERROR: THE CLIENT HASN'T HAVE AN AGENCY CODE
					   else{
							tempLead.Azioni_intraprese_sul_Lead__c = 'Il cliente con cui il Lead risulta duplicato non ha un numero di agenzia';
							//Start - 001
							leadsDuplicatedOnce.add(tempLead);
							//End - 001
						}
				   }
			  }
		 }
		system.debug('****JV - before policy control: ' + leadsForPolicyControl + ' ' + accDuplicatedClientsMap);
		if(leadsForPolicyControl.size()>0) {
			 Map<Id,Lead> assignedLeadsAfterPolicyControl = leadPolicyControl(leadsForPolicyControl,accDuplicatedClientsMap);
			 if(assignedLeadsAfterPolicyControl.size()>0)
				 assignedLeads.addAll(assignedLeadsAfterPolicyControl.values());
			 for(Lead tempLead:leadsForPolicyControl) {
				  if(assignedLeadsAfterPolicyControl.get(tempLead.Id) == null)
					  leadsNotDuplicatedWithClients.add(tempLead);
			  }
		 }
		system.debug('****JV - leadsDuplicatedOnce: ' + leadsDuplicatedOnce);
		system.debug('****JV - assignedLeads: ' + assignedLeads);
		LeadsListsWrapper leadsAfterClientDuplication = new LeadsListsWrapper(leadsNotDuplicatedWithClients,assignedLeads);
		return leadsAfterClientDuplication;
	}

	/**
	 * Initiative: Lead-Management Sprint 45: Method that gets the complete Leads assigned map
	 * @author Juana Valenzuela
	 * @date 19/06/2017
	 * @param newLeadList: List of Leads that are duplicated with exisiting clientss
	 *        accDuplicatedClientsMap: Map with the list of exisisting clients for each Lead. Doesn't include the Leads already assigned
	 * @return assignedLeadsMap: Map of Lead's Id and assigned Lead
	 */
	public static Map<Id,Lead> leadPolicyControl(List<Lead> newLeadList, Map<String,List<Account> > accDuplicatedClientsMap){
		Map<Id,Lead> assignedLeadsMap = new Map<Id,Lead>();
		Map<Id,List<InsurancePolicy__c> > clientInsurancePolicies = new Map<Id,List<InsurancePolicy__c> >();
		List<Id> duplicatedClientsId = new List<Id>();
		Id policyAutoRecTypeId = Schema.SObjectType.InsurancePolicy__c.getRecordTypeInfosByName().get('Auto').getRecordTypeId();
		Id policyNonAutoRecTypeId = Schema.SObjectType.InsurancePolicy__c.getRecordTypeInfosByName().get('Non Auto').getRecordTypeId();
		List<Id> policyRecordTypeList = new List<Id>();
		policyRecordTypeList.add(policyAutoRecTypeId);
		policyRecordTypeList.add(policyNonAutoRecTypeId);
		for(String tempLeadKey:accDuplicatedClientsMap.keySet()) {
			 List<Account> listDuplicatedClients = accDuplicatedClientsMap.get(tempLeadKey);
			 for(Account tempAccount:listDuplicatedClients) {
				  duplicatedClientsId.add(tempAccount.Id);
			  }
		 }
		system.debug('#@#@ duplicated clients id '+duplicatedClientsId);
		system.debug('#@#@ policy record type list '+policyRecordTypeList);

		//Create map of list of policies for each client
		for(InsurancePolicy__c tempPolicy:[SELECT CUID__c,Line__c,Sub_ASA__c,Status__c,RecordTypeId,Last_Premium_Paid__c // NOPMD  Fix CRUD violation
										   FROM InsurancePolicy__c
										   WHERE RecordTypeId IN :policyRecordTypeList AND
										   CUID__c IN :duplicatedClientsId AND
										   Status__c = 'ATTIVO' ]) {
			 if(clientInsurancePolicies.get(tempPolicy.CUID__c) == null)
				 clientInsurancePolicies.put(tempPolicy.CUID__c,new List<InsurancePolicy__c>());
			 clientInsurancePolicies.get(tempPolicy.CUID__c).add(tempPolicy);
		 }
		System.debug('#@#@# clientinsurancepolicies '+clientinsurancepolicies);

		assignedLeadsMap = getLeadAssignmentMap(newLeadList,clientInsurancePolicies,accDuplicatedClientsMap);
		return assignedLeadsMap;
	}

	/**
	 * Initiative: Lead-Management Sprint 45: Method that verifies the insurance policies associeted to each duplicated client
	 * in order to assign the Lead to the client with the greatest Last Premium Paid. The control is made based on the
	 * Leads's landing page and insurance policy type
	 * @author Juana Valenzuela
	 * @date 19/06/2017
	 * @param newLeadList: List of Leads that are duplicated with exisiting clients
	 *        clientInsurancePolicies: Map of the list of each client's insurance policies
	 *        accDuplicatedClientsMap: Map with the list of exisisting clients for each Lead. Doesn't include the Leads already assigned
	 * @return assignedLeads: Map of Lead's Id and assigned Lead
	 */
	public static Map<Id,Lead> getLeadAssignmentMap(List<Lead> newLeadList,Map<Id,List<InsurancePolicy__c> > clientInsurancePolicies,Map<String,List<Account> > accDuplicatedClientsMap){
		Map<Id,Lead> assignedLeads = new Map<Id,Lead>();
		Map<String,LeadAssignmentConfiguration__c> configurationMap = LeadAssignmentConfiguration__c.getAll();
		//CAPOBIANCO_A 05/10/2017 - Trova agente & Pagina Prodotto AXA Quotatore assignation -- START
		Map<String,LeadAssignmentConfiguration__c> mapProductToConfiguration = new Map <String,LeadAssignmentConfiguration__c>();
		for(String configurationName : configurationMap.keySet())
		 {
			 LeadAssignmentConfiguration__c configuration = configurationMap.get(configurationName);
			 if(String.isNotBlank(configuration.Prodotto__c))
			  {
				  mapProductToConfiguration.put(configuration.Prodotto__c, configuration);
			  }
		 }
		//CAPOBIANCO_A 05/10/2017 - Trova agente & Pagina Prodotto AXA Quotatore assignation -- END
		for(Lead tempLead:newLeadList) {
			 Account maxClient = new Account();
			 //[12/07/2017]JV - Start: Refactoring
			 String landingPage = tempLead.Landing_Page__c == 'Nuova protezione casa' ? 'Semplicemente casa' : tempLead.Landing_Page__c;
			 LeadAssignmentConfiguration__c config = configurationMap.get(landingPage);
			 //[12/07/2017]JV - End: Refactoring
			 //CAPOBIANCO_A 05/10/2017 - Trova agente & Pagina Prodotto AXA Quotatore assignation -- START
			 if(String.isNotBlank(tempLead.Prodotto__c))
			  {
				  if( mapProductToConfiguration.keySet().contains(tempLead.Prodotto__c)
					  && ((mapProductToConfiguration.get(tempLead.Prodotto__c).Name).contains(tempLead.Landing_Page__c)))
				   {
					   config = mapProductToConfiguration.get(tempLead.Prodotto__c);
				   }
			  }
			 //CAPOBIANCO_A 05/10/2017 - Trova agente & Pagina Prodotto AXA Quotatore assignation -- END
			 String mapKeyValue = '';
			 if(tempLead.AAI_Partita_IVA__c != null && tempLead.AAI_Partita_IVA__c != '')
				 mapKeyValue = tempLead.AAI_Partita_IVA__c;
			 else
				 mapKeyValue = tempLead.Fiscal_ID__c;
			 List<Account> listDuplicatedClients = accDuplicatedClientsMap.get(mapKeyValue);
			 Decimal maxClientAmount = 0;
			 Map<Account,ClientPolicyValuesWrapper> mapClientValues = new Map<Account,ClientPolicyValuesWrapper>();
			 for(Account tempAccount:listDuplicatedClients) {
				  ClientPolicyValuesWrapper clientPolicyValues = new ClientPolicyValuesWrapper();
				  if(clientInsurancePolicies.get(tempAccount.Id) != null && clientInsurancePolicies.get(tempAccount.Id).size()>0) {
					   List<InsurancePolicy__c> clientPolicies = clientInsurancePolicies.get(tempAccount.Id);
					   system.debug('****JV - clientPolicies: ' + clientPolicies);
					   Decimal totalPolicyPartialAmount = 0;
					   Decimal totalPolicylAmount = 0;
					   for(InsurancePolicy__c tempPolicy:clientPolicies) {
							totalPolicylAmount += tempPolicy.Last_Premium_Paid__c;
							if(config != null) {
								 if(config.ASA__c != null && config.Sub_ASA__c != null) {
									  if((tempPolicy.Line__c != null && Integer.valueOf(tempPolicy.Line__c) == Integer.valueOf(config.ASA__c)) &&
										 (tempPolicy.Sub_ASA__c != null && Integer.valueOf(tempPolicy.Sub_ASA__c) == Integer.valueOf(config.Sub_ASA__c))) {
										   totalPolicyPartialAmount += tempPolicy.Last_Premium_Paid__c;
									   }
								  }else if(config.ASA__c != null && config.Sub_ASA__c == null) {
									  if(tempPolicy.Line__c != null && Integer.valueOf(tempPolicy.Line__c) == Integer.valueOf(config.ASA__c))
										  totalPolicyPartialAmount += tempPolicy.Last_Premium_Paid__c;
								  }
							 }
						}
					   clientPolicyValues.partialValue = totalPolicyPartialAmount;
					   clientPolicyValues.totalValue = totalPolicylAmount;
					   mapClientValues.put(tempAccount,clientPolicyValues);

				   }else{
					   //Start - 001
					   system.debug('******* Cliente attivo duplicato senza polizze. Non dovrebbe mai entrare quà');
					   //End - 001
				   }
			  }
			 //Get max client value for the Lead
			 Decimal maxClientPartialAmount = 0;
			 Decimal maxClientTotalAmount = 0;
			 Account maxClient1 = new Account();
			 Account maxClient2 = new Account();
			 for(Account tempAccount:mapClientValues.keySet()) {
				  if(mapClientValues.get(tempAccount).partialValue > maxClientPartialAmount) {
					   maxClientPartialAmount = mapClientValues.get(tempAccount).partialValue;
					   maxClient1 = tempAccount;
				   }
				  if(mapClientValues.get(tempAccount).totalValue > maxClientTotalAmount) {
					   maxClientTotalAmount = mapClientValues.get(tempAccount).totalValue;
					   maxClient2 =  tempAccount;
				   }
			  }
			 if(config != null && maxClientPartialAmount > 0) {
				  maxClient = maxClient1;
			  }else{
				  maxClient = maxClient2;
			  }
			 String clientAgency = maxClient.AAI_Agency_Reference_Code__c;
			 tempLead.Agency_Code__c = clientAgency;
			 //FM 10/01/2018 - addedd for Sprint 59 US-0643
			 tempLead.TECH_duplicatedwithClient__c=true;
			 tempLead.Ultima_data_di_riassegnazione__c = Datetime.now();
			 if(tempLead.Numero_assegnazioni_eseguite__c == null)
				 tempLead.Numero_assegnazioni_eseguite__c = 0;
			 tempLead.Numero_assegnazioni_eseguite__c += 1;
			 //Start - 001
			 tempLead.TECH_Send_Email_Notification__c = true;
			 //End - 001
			 assignedLeads.put(tempLead.Id,tempLead);
		 }
		system.debug('****JV - assignedLeads: ' + assignedLeads);
		return assignedLeads;
	}

	/**
	 * Initiative: Lead-Management Sprint 45: Class the wraps the list to identify Leads for assignment
	 * @author Juana Valenzuela
	 * @date 20/06/2017
	 * @param partialValueMap,totalValueMap: Map of partial and total total values on client's policies sum
	 */
	public class ClientPolicyValuesWrapper {
		public Decimal partialValue {get; set;}
		public Decimal totalValue {get; set;}

		public ClientPolicyValuesWrapper(){
			partialValue = 0;
			totalValue = 0;
		}
	}

	/**
	 * Initiative: Lead-Management Sprint 45: Method that defines the quotatore which the ranking refers to.
	 * The method receives as input the Lead itself and returns the string containing the quotatore type.
	 * @author FMarchese
	 * @date 13/06/2017
	 * @param newLead: Lead for which the integration is required
	 * @return ranking: ranking parameter of the request
	 */
	public static String decodeRankingQuotatore(Lead newLead){
		Map<String,String> picklistAPILabelMap = new Map<String,String>();
		picklistAPILabelMap = UtilityClass.getPicklistValue(newLead,'Landing_Page__c');
		system.debug('++++++++PICKLISTMAPLABEL'+picklistAPILabelMap);
		String landingPage = picklistAPILabelMap.get(newLead.Landing_Page__c);

		//CAPOBIANCO_A 05/10/2017 - Trova agente & Pagina Prodotto AXA Quotatore assignation -- START
		Map<String,LeadAssignmentConfiguration__c> mapProductToConfiguration = new Map <String,LeadAssignmentConfiguration__c>();
		Map<String,LeadAssignmentConfiguration__c> configurationMap = LeadAssignmentConfiguration__c.getAll();
		for(String configurationName : configurationMap.keySet())
		 {
			 LeadAssignmentConfiguration__c configuration = configurationMap.get(configurationName);
			 if(String.isNotBlank(configuration.Prodotto__c))
			  {
				  mapProductToConfiguration.put(configuration.Prodotto__c, configuration);
			  }
		 }
		//CAPOBIANCO_A 05/10/2017 - Trova agente & Pagina Prodotto AXA Quotatore assignation -- END
		String ranking = '';
		//[12/07/2017]JV - Start: Refactoring
		landingPage = landingPage == 'Nuova protezione casa' ? 'Semplicemente casa' : landingPage;
		//CAPOBIANCO_A 05/10/2017 - Trova agente & Pagina Prodotto AXA Quotatore assignation -- START
		if(String.isNotBlank(newLead.Prodotto__c))
		 {
			 if(   mapProductToConfiguration.keySet().contains(newLead.Prodotto__c)
				   && (mapProductToConfiguration.get(newLead.Prodotto__c).Name).contains(newLead.Landing_Page__c))
			  {
				  ranking = mapProductToConfiguration.get(newLead.Prodotto__c).Ranking__c;
			  }
			 else
			  {
				  LeadAssignmentConfiguration__c mapLandingPageRanking = LeadAssignmentConfiguration__c.getValues(landingPage);
				  ranking = mapLandingPageRanking.Ranking__c;
			  }
		 }
		else
		 {
			 LeadAssignmentConfiguration__c mapLandingPageRanking = LeadAssignmentConfiguration__c.getValues(landingPage);
			 ranking = mapLandingPageRanking.Ranking__c;
		 }
		//CAPOBIANCO_A 05/10/2017 - Trova agente & Pagina Prodotto AXA Quotatore assignation -- END
		return ranking;
	}

	/**
	 * Initiative: Lead-Management Sprint 45: Method that creates Map with Lead infos in order to build request URL.
	 * The method receives as input the Lead itself and returns the map containing the Lead infos.
	 * @author FMarchese
	 * @date 13/06/2017
	 * @param newLead: Lead for which the integration is required
	 * @return leadparams: map with the parameters for the Noovle service request
	 */
	public static Map<string,string> prepareLeadtosendRequest(Lead newLead){
		String ranking = decoderankingquotatore(newLead);
		Map<string,string> leadparams = new Map<string,string>();
		String street = String.valueOf(newLead.street);
		String city = String.valueOf(newLead.city);
		String postalcode = String.valueOf(newLead.postalcode);
		String address = '';
		if (street!=null) {
			 address=address+street;
		 }
		if (postalcode!=null) {
			 address = address + ',' + postalcode;
		 }
		if (city!=null) {
			 address = address + ',' + city;
		 }
		//[04/07/17]JV - Start: Integration Test
		address = address.removeStart(',');
		address = address.removeEnd(',');
		//[04/07/17]JV - End
		system.debug('INDIRIZZO LEAD' +address);
		leadparams.put('address',address);
		leadparams.put('ranking',ranking);
		leadparams.put('encoding','UTF-8');
		leadparams.put('cache','true');
		return leadparams;
	}

	public static IE_Integration_Record__c PopulateIErecord_LeadAssignment(Lead newLead) {
		IE_Integration_Record__c theResult = new IE_Integration_Record__c();
		List<IE_Configuration__c> theConfig = [SELECT id,NameSpacePrefix1__c,NameSpacePrefix2__c,NameSpaceUri1__c,NameSpaceUri2__c, Endpoint__c, Certificate__c FROM IE_Configuration__c WHERE Name='Integration_LeadAssignment'  LIMIT 1]; // NOPMD  Fix CRUD violation
		Map<string,string> Leadparams = (Map<string,string>)prepareLeadtosendRequest(newLead);
		if (!theConfig.isempty()) {
			 theResult.IE_Configuration__c = theConfig[0].id;
		 }

		//Compiling the DevField with the JSON
		//JSONGenerator myGen= JSON.createGenerator(true);
		string url = '';
		url = theConfig[0].Endpoint__c +'?'+EncodingUtil.urlEncode('address','UTF-8')+'='+ EncodingUtil.urlEncode(Leadparams.get('address'),'UTF-8') + '&' +EncodingUtil.urlEncode('ranking','UTF-8') + '=' + EncodingUtil.urlEncode(Leadparams.get('ranking'),'UTF-8') + '&' + EncodingUtil.urlEncode('cache','UTF-8') + '=' +EncodingUtil.urlEncode(Leadparams.get('cache'),'UTF-8') + '&' + EncodingUtil.urlEncode('encoding','UTF-8') + '=' + EncodingUtil.urlEncode(Leadparams.get('encoding'),'UTF-8');
		system.debug('REQUEST URL'+url);


		string compiledrequest = url;
		system.debug ('urltosendrequest'+url);
		theResult.RequestBody__c = compiledrequest;
		theResult.URLRequest__c = compiledrequest;
		theResult.ScopeID__c = newLead.Id; //BOVOLENTA_D 02082017 added in order to find the requests having the lead

		return theResult;
	}

	public static ResponseDto sendRequest (Lead newLead){
		IE_Integration_Record__c myIR = new IE_Integration_Record__c();
		myIR = PopulateIErecord_LeadAssignment(newLead);
		IE_Engine myIE = new IE_Engine(myIR);
		ResponseDto res = new ResponseDto();

		try {
			 myIE.compileRequest();
		 } catch (exception e) {
			 String errorsStr = 'Si è verificato un errore nel compilare la richiesta verso Noovle';
			 system.debug('*********Eccezione e ='+e);
			 res = new ResponseDto(false, errorsStr);

			 return res;

		 }

		try {
			 myIE.sendRequest();
		 } catch (exception e) {

			 upsert myIR; // NOPMD  Fix CRUD violation

			 String errorsStr = 'Si è verificato un errore nell\'inviare la richiesta ranking verso Noovle';
			 res = new ResponseDto(false, errorsStr);

			 return res;

		 }

		try {
			 myIE.interpretResponse();
			 system.debug('**********json response'+myIE.JSONResponse);


			 res = manageResponse_LeadAssignment(myIE,newLead);


		 } catch (exception e) {
			 String errorsStr = 'Si è verificato un errore nella ricezione della risposta da Noovle';
			 res = new ResponseDto(false, errorsStr);

			 return res;
		 }



		return res;
	}

	public static ResponseDto manageResponse_LeadAssignment(IE_Engine IEInstance, Lead newLead){
		ResponseDto results = new ResponseDto();

		system.debug('+++++++++++Lead'+newLead);
		system.debug('****** IEInstance ='+IEInstance);
		LeadRankingResponse formattedResponse = mapResponse_LeadAssignment (IEInstance.JSONResponse);
		system.debug('****** formattedResponse ='+formattedResponse);

		if (formattedResponse == null)
		 {
			 results.isSuccess = False;
			 results.message = 'Errore risposta vuota';
			 return results;
		 }
		else if (formattedResponse.code != null)
		 {
			 if (formattedResponse.code.startsWithIgnoreCase('400'))
			  {
				  results.isSuccess = False;
				  results.message = 'Errore di sistema';
				  return results;
			  }
			 else if (formattedResponse.code.startsWithIgnoreCase('401'))
			  {
				  results.isSuccess = False;
				  results.message = 'Richiesta non autorizzata';
				  return results;
			  }
			 else if (formattedResponse.code.startsWithIgnoreCase('404'))
			  {
				  if (newLead.Dettaglio__c != 'Richiedi appuntamento')
				   { //BOVOLENTA_D if not richiedi I need an agency
					   results.isSuccess = False;
					   results.message = 'Dati richiesti non trovati';
				   }
				  else
				   { //BOVOLENTA_D 08032018 handling richiedi appuntamento
					   results.isSuccess = True;
					   handleNoDataFoundAppointment (newLead);
				   }

				  return results;
			  }
			 else if (formattedResponse.code.startsWithIgnoreCase('503'))
			  {
				  results.isSuccess = False;
				  results.message = 'Database connection error';
				  return results;
			  }
		 }

		//successo chiamata
		else if (formattedResponse.resultsNumber!=null && formattedResponse.resultsNumber!='')
		 {
			 system.debug ('******SUCCESS');
			 LeadAssignment_setResponse (formattedResponse, newLead);
			 results.isSuccess = True;
			 //results.values=RankingResponse.values;
		 }
		//errore chiamata
		else{
			 system.debug('****** ERROR');
			 results.isSuccess = False;
			 results.message = 'La chiamata verso Noovle ha avuto esito negativo. Riprovare o contattare l\'amministratore di sistema';
		 }



		return results;
	}

	public static void handleNoDataFoundAppointment (Lead newLead){
		String agencyCode = padAgency(newLead.Agency_Code__c);
		list<Account> agenciesAcc= [SELECT Id,Agency_Code__c,Name // NOPMD  Fix CRUD violation
									FROM Account
									WHERE RecordType.DeveloperName = 'Agency' AND
																	 Agency_Code__c = :agencyCode AND
																					  Active__c = TRUE ];
		if (agenciesAcc.size()>0)
		 {
			 newLead.Ultima_data_di_riassegnazione__c=System.now();
			 if(newLead.Numero_assegnazioni_eseguite__c == null)
				 newLead.Numero_assegnazioni_eseguite__c = 0;
			 newLead.Numero_assegnazioni_eseguite__c += 1;
			 newLead.TECH_Send_Email_Notification__c = TRUE;
			 newLead.Agenzie_per_riassegnazione__c = agencyCode+';';
			 newLead.Agenzie_per_riassegnazione_riordinata__c = agencyCode+';';
			 newLead.Agenzie_gia_assegnate__c = agencyCode+';';
			 Database.SaveResult SaveResult = database.update (newLead,false);
			 Set<Id> leadId = new Set<Id>();
			 leadId.add(newLead.Id);
			 LeadManagement.reassingLeadAAI(leadId);
		 }
		else
		 {
			 newLead.Azioni_intraprese_sul_Lead__c = 'Non sono state trovate agenzie disponibili per assegnazione (limite raggiunto o agenzie inattive) per il lead Richiedi appuntamento';
			 Id leadNotAssignedQueue = UtilityClass.retrieveGroupId('Queue','Coda_Lead_Salva_Quotazione_non_assegnati');
			 newLead.OwnerId = leadNotAssignedQueue;

		 }
	}

	public static LeadRankingResponse  mapResponse_LeadAssignment (String JSONResponse) {
		LeadRankingResponse emptyInstance = new LeadRankingResponse();
		Type typeInstance = Type.forName('LeadRankingResponse');
		LeadRankingResponse deserializeResults = (LeadRankingResponse)JSON.deserialize(JSONResponse, typeInstance);
		System.debug('***************deserialize() results = ' + deserializeResults);
		return deserializeResults;
	}

	public static void LeadAssignment_setResponse(LeadRankingResponse theResponse, Lead newLead){

		if(canRedirect.isEmpty()){
			setCanRedirect();
		}
		ResponseDto RankingResponse = new ResponseDto();
		String listaAgenzieAssegnazione = '';
		String listaAgenzieGiaAssegnate = ''; //CAPOBIANCO_A 12/07/2017 SPRINT 46
		String listaTipologieAgenzieAssegnazione = ''; //TORREGGIANI 05/07/2018 SPRINT 72
		String listaTipologieAgenzieGiaAssegnate = ''; //TORREGGIANI 05/07/2018 SPRINT 72
		Set<String> cleanedResult = new Set<String>();

		//if (newLead.Dettaglio__c == 'Richiedi appuntamento') {
			 //[04/07/2017]JV- Start: Integration Test
			 /*
			    if(!(String.isEmpty(newLead.Codice_Sub_Agenzia__c))){

			     ListaAgenzieAssegnazione=ListaAgenzieAssegnazione+newLead.Codice_Sub_Agenzia__c+';';
			    }
			  */
			 //[04/07/2017]JV- End
			 if (!(String.isEmpty(newLead.Agency_Code__c))) {
				  listaAgenzieAssegnazione = listaAgenzieAssegnazione + padAgency(newLead.Agency_Code__c)+';';
				  listaAgenzieGiaAssegnate = listaAgenzieGiaAssegnate + padAgency(newLead.Agency_Code__c)+';'; //CAPOBIANCO_A 12/07/2017 SPRINT 46
				  cleanedResult.add(padAgency(newLead.Agency_Code__c));
			  }
			 if (!(String.isEmpty(newLead.Codice_Sub_Agenzia__c))) {
				  //listaTipologieAgenzieAssegnazione = listaTipologieAgenzieAssegnazione + newLead.Codice_Sub_Agenzia__c.split('(?<=\\G......)')[1] +';';
				  listaTipologieAgenzieAssegnazione = listaTipologieAgenzieAssegnazione + newLead.Codice_Sub_Agenzia__c+';';
				  listaTipologieAgenzieGiaAssegnate = listaTipologieAgenzieGiaAssegnate + newLead.Codice_Sub_Agenzia__c+';';
			  } else {
				  listaTipologieAgenzieAssegnazione = listaTipologieAgenzieAssegnazione + '-'+';';
				  listaTipologieAgenzieGiaAssegnate = listaTipologieAgenzieGiaAssegnate + '-'+';';
			  }
		 //}
		//Verificare significato resultsNumber
		if(theResponse.resultsNumber!=null && theResponse.resultsNumber!='') {
			 System.debug(' ===> res: ' + theResponse.results);

			 for (LeadRankingResponse.cls_results res : theResponse.results) {
				  if(res.metadata.agency.agencyId!=null && res.metadata.agency.agencyId!='') {

					   String notNormalizedAgencyCode = res.metadata.agency.agencyId;

                       //CAPOBIANCO_A 21/07/2017 -- START
                       res.metadata.agency.agencyId = padAgency(res.metadata.agency.agencyId);

					   //TORREGGIANI 05/07/2018 -- START
					   System.debug(' ===> cleanedResult: ' + cleanedResult);
					   System.debug(' ===> PROVA');
					   System.debug(' ===> agencyId: ' + res.metadata.agency.agencyId);

					   if(cleanedResult.contains(res.metadata.agency.agencyId)) {
							continue;
						}
					   cleanedResult.add(res.metadata.agency.agencyId);
					   //TORREGGIANI 05/07/2018 -- END

					   if (padAgency(newLead.Agency_Code__c) != '' && padAgency(newLead.Agency_Code__c) != res.metadata.agency.agencyId) //BOVOLENTA_D 08092017
						{
							listaAgenzieAssegnazione = listaAgenzieAssegnazione + padAgency(res.metadata.agency.agencyId) + ';';
						}
					   //CAPOBIANCO_A 21/07/2017 -- END

					   //TORREGGIANI 05/07/2018 -- START
					   if(res.metadata.agency.venueType!=null && res.metadata.agency.venueType!='') {
							if(res.metadata.agency.venueType == 'S') {

								 String venueId = res.metadata.agency.venueId;
								 Integer venueIdLength = venueId.length();
								 Integer notNormalizedAgencyCodeLength = notNormalizedAgencyCode.length();
								 System.debug(' ===> ' + venueId.substring(notNormalizedAgencyCodeLength,venueIdLength));
								 venueId = venueId.substring(notNormalizedAgencyCodeLength,venueIdLength);

								 while(venueId.length()<6) {
									  venueId = '0' + venueId;
								  }

								 venueId = res.metadata.agency.agencyId + venueId;

								 listaTipologieAgenzieAssegnazione = listaTipologieAgenzieAssegnazione + venueId + ';';

							 } else {
								 listaTipologieAgenzieAssegnazione = listaTipologieAgenzieAssegnazione + '-' + ';';
							 }
						}
					   //TORREGGIANI 05/07/2018 -- END
				   }
			  }
			 System.debug(' ===> Terminato giro response Noovle');
			 System.debug('#@#@ agenzie per riassegnazione '+listaAgenzieAssegnazione);
			 System.debug('#@#@ tipologie per riassegnazione '+listaTipologieAgenzieAssegnazione);
			 newLead.Agenzie_per_riassegnazione__c = listaAgenzieAssegnazione;
			 newLead.Tipologie_per_riassegnazione__c = listaTipologieAgenzieAssegnazione;
			 System.debug('#@#@ agenzie per riassegnazione '+newLead.Agenzie_per_riassegnazione__c);
			 System.debug('#@#@ tipologie agenzie per riassegnazione '+newLead.Tipologie_per_riassegnazione__c);
			 System.debug('#@#@ tipologie agenzie gia assegnate'+listaAgenzieGiaAssegnate);
			 System.debug('#@#@ tipologie agenzie per riassegnazione gia assegnate'+listaTipologieAgenzieGiaAssegnate);
			 newLead.Agenzie_gia_assegnate__c = listaAgenzieGiaAssegnate; //CAPOBIANCO_A 12/07/2017 SPRINT 46
			 /*
			    newLead.Ultima_data_di_riassegnazione__c=System.now();
			    if(newLead.Numero_assegnazioni_eseguite__c == null)
			    newLead.Numero_assegnazioni_eseguite__c = 0;
			    newLead.Numero_assegnazioni_eseguite__c += 1;
			    system.debug('****JV - num assegnazioni: ' + newLead.Numero_assegnazioni_eseguite__c);
			  */
			 RankingResponse.values.put('Lead con ranking agenzie', newLead);
			 //Database.SaveResult SaveResult = database.update (newLead,false);
		 }
		//[04/07/17]JV - Start: Test integration
		Boolean isAgencyFound = LeadAssignmentRankingBased(newLead);
		if(!isAgencyFound) {
			 newLead.Azioni_intraprese_sul_Lead__c = 'Non sono state trovate agenzie disponibili per assegnazione (limite raggiunto o agenzie inattive)';
			 //BOVOLENTA_D 10082017 assegnazione dei lead non assegnati a coda dedicata
			 Id leadNotAssignedQueue = UtilityClass.retrieveGroupId('Queue','Coda_Lead_Salva_Quotazione_non_assegnati');
			 newLead.OwnerId = leadNotAssignedQueue;
			 //BOVOLENTA_D END
			 Database.SaveResult SaveResult = database.update (newLead,false);
		 }
		//LeadAssignmentRankingBased(newLead);
		//[04/07/17]JV - End
	}

	public static boolean LeadAssignmentRankingBased(Lead newLead) {
		System.debug('LeadAssignmentRankingBased ====> START');
		Set <String> codesList = new Set <String>();
		Set<Id> leadId = new Set<Id>();
		//[04/07/2017]JV - Start: Integration Test
		//List<Lead> theLead = new List<Lead>();
		//theLead.add(newLead);
		//[04/07/2017]JV - End
		leadId.add(newLead.Id);
		List<Account> agenciesList = new List<Account>();
		codesList.addAll(newLead.Agenzie_per_riassegnazione__c.split(';'));

		//[04/07/2017]JV - Start: Integration Test
		system.debug('*****JV - agenzie riassegnazione: ' + newLead.Agenzie_per_riassegnazione__c);
		Map<String,Account> agenciesMap = new Map<String,Account>();
		agenciesList = [SELECT Id,Agency_Code__c,Name // NOPMD  Fix CRUD violation
						FROM Account
						WHERE RecordType.DeveloperName = 'Agency' AND
														 Agency_Code__c IN: codesList AND
														 Active__c = TRUE ];
		//agenciesList = [SELECT Id,Agency_Code__c,Name FROM Account WHERE RecordType.DeveloperName = 'Agency' AND Agency_Code__c IN: CodesList];
		for(Account tempAgency:agenciesList) {
			 agenciesMap.put(tempAgency.Agency_Code__c,tempAgency);
		 }
		//[04/07/2017]JV - End
		system.debug('++++++++++++ agencies list'+ agenciesList);
		system.debug('++++++++++++ codes list'+ codesList);
		system.debug('++++++++++++ agencies map' +agenciesmap);

		//CAPOBIANCO_A 11/01/2018 SPRINT 59 -- START
		Boolean isAssigned = false;
		if (checkAssignmentLimits(agenciesList,newLead))
		 {
			 LeadManagement.reassingLeadAAI(leadId);
			 isAssigned = true;
		 }
		return isAssigned;
	}

	public static Map<Account,List<Assegnazioni__c> > getAssignmentList(List<Account> agencyAccountList, Lead newLead){
		system.debug('******THELEAD: '+newLead);
		system.debug('******THELEADID: '+newLead.Id);

		Map<Account,List<Assegnazioni__c> > mapAgencyToExistingAssignment = new Map<Account,List<Assegnazioni__c> >();

		//Setting the correct Assegnazioni's Record Type Id to be retrieved/created
		Id assignmentRecordTypeId = Id.valueOf(Assegnazioni_Configuration__c.getValues('Default').Record_Type_ID__c);
		if(newLead.Landing_Page__c != null)
		 {
			 String quotatoreLead = LeadAssignmentConfiguration__c.getValues(newLead.Landing_Page__c).Ranking__c;
			 if(String.isNotBlank(quotatoreLead))
			  {
				  String assRTIdString =  Assegnazioni_Configuration__c.getValues(quotatoreLead).Record_Type_ID__c;
				  if(String.isNotBlank(assRTIdString))
				   {
					   assignmentRecordTypeId = Id.valueOf(assRTIdString);
				   }
			  }
		 }

		//Extracting all the Assegnazioni of the selected Record Type Id of all the Agencies in the input list
		List<Id> agencyAccIdList = new list<Id>();
		for(Account tempAgency: agencyAccountList)
		 {
			 agencyAccIdList.add(tempAgency.Id);
		 }

		//BOVOLENTA_D 24012017 FIRST INSERT THE MISSING ASSIGNMENTS
		String todayQuery = 'SELECT Id, Account__c, Numero_Assegnazioni__c,CreatedDate FROM Assegnazioni__c WHERE Account__c IN :agencyAccIdList AND RecordTypeId = \''+assignmentRecordTypeId+'\' AND CreatedDate = TODAY';
		List<Assegnazioni__c> todayExistingAssignment = Database.query(todayQuery);
		Map<Id,List<Assegnazioni__c> > todayAssignmentMap = new Map<Id,List<Assegnazioni__c> >(); //Agency id to assegnazioni
		for(Assegnazioni__c tempAss: todayExistingAssignment)
		 {
			 List<Assegnazioni__c> tempList = todayAssignmentMap.get(tempAss.Account__c);
			 if (tempList!= null)
			  {
				  tempList.add(tempAss);
			  }
			 else
			  {
				  tempList = new List<Assegnazioni__c>();
				  tempList.add(tempAss);
			  }
			 todayAssignmentMap.put(tempAss.Account__c,tempList);
		 }
		List<Assegnazioni__c> newAssignmentToAdd = new List<Assegnazioni__c>();
		for(Account currentAgency: agencyAccountList)
		 {
			 List<Assegnazioni__c> tempList = todayAssignmentMap.get(currentAgency.Id);
			 if (tempList == null)
			  {
				  Assegnazioni__c agencyTodayAssignment = new Assegnazioni__c();
				  agencyTodayAssignment.RecordTypeId = assignmentRecordTypeId;
				  agencyTodayAssignment.Account__c = currentAgency.Id;
				  agencyTodayAssignment.Numero_Assegnazioni__c = 0;
				  newAssignmentToAdd.add(agencyTodayAssignment);
			  }
		 }
		if (newAssignmentToAdd.size()>0)  insert newAssignmentToAdd; // NOPMD  Fix CRUD violation

		//BOVOLENTA_D END PREPARE NEW ASSIGNMENTS

		List<Assegnazioni__c> allExistingAssignment = new List<Assegnazioni__c>();
		String query = '';
		query = 'SELECT Id, Account__c, Numero_Assegnazioni__c,CreatedDate FROM Assegnazioni__c WHERE Account__c IN :agencyAccIdList AND RecordTypeId = \''+assignmentRecordTypeId+'\' AND CreatedDate = THIS_WEEK   FOR UPDATE';
		system.debug('******** query'+ query );
		allExistingAssignment = Database.query(query);
		system.debug('******** allExistingAssignment'+ allExistingAssignment );

		//Populating a map that associates each agency to the list of its Assegnazioni
		for(Account currentAgency: agencyAccountList)
		 {
			 List<Assegnazioni__c> agencyExistingAssignment = new List<Assegnazioni__c>();
			 Assegnazioni__c agencyTodayAssignment = new Assegnazioni__c();
			 agencyTodayAssignment.RecordTypeId = assignmentRecordTypeId;

			 for(Assegnazioni__c tempAss: allExistingAssignment)
			  {
				  if(tempAss.Account__c == currentAgency.Id)
				   {
					   agencyExistingAssignment.add(tempAss);
				   }
			  }
			 /*BOVOLENTA_D REMOVED AS ASSIGNMENTS ARE ADDED BE4
			    //If the agency in scope has no Assegnazioni
			    if(agencyExistingAssignment.size() == 0)
			    {
			     system.debug('Agenzia senza record di assegnazione');
			     agencyTodayAssignment.Account__c = currentAgency.Id;
			     //agencyExistingAssignment.add(agencyTodayAssignment);
			    }
			    else //If the agency has existing Assegnazioni
			    {
			     Boolean foundToday = false;
			     //If there is an assegnazioni for the current day, do nothing
			     for(Assegnazioni__c singleAssignment : agencyExistingAssignment)
			     {
			         if ((singleAssignment.CreatedDate).date() == date.today()){
			             foundToday = true;
			         }
			     }
			     //Else create one
			     if (foundToday == false)
			     {
			         system.debug('Agenzia senza record di assegnazione di oggi');
			         agencyTodayAssignment.Account__c = currentAgency.Id;
			         //agencyExistingAssignment.add(agencyTodayAssignment);
			     }
			    }*/

			 mapAgencyToExistingAssignment.put(currentAgency,agencyExistingAssignment);
		 }

		return mapAgencyToExistingAssignment;
	}

	public static boolean checkAssignmentLimits(List<Account> agenciesList, Lead newLead){
		System.debug('checkAssignmentLimits ====> START');
		Map<Account,List<Assegnazioni__c> > mapAgencyExistingAssignment = new Map<Account,List<Assegnazioni__c> >();
		Map<String,Account> mapCodeToAgency = new Map<String,Account>();
		List<String> listAgenzieRiassegnazione = new List<String>();
		List<String> listTipologieAgenzieRiassegnazione = new List<String>(); //TORREGGIANI 05/07/2018 SPRINT 72
		Map<String, String> riordinamentoTipologie = new Map<String, String>(); //TORREGGIANI 05/07/2018 SPRINT 72

		for(Account a: agenciesList)
		 {
			 mapCodeToAgency.put(a.Agency_Code__c, a);
		 }

		for(String s:(newLead.Agenzie_per_riassegnazione__c).split(';'))
		 {
			 listAgenzieRiassegnazione.add(s);
		 }
		for(String s:(newLead.Tipologie_per_riassegnazione__c).split(';'))
		 {
			 listTipologieAgenzieRiassegnazione.add(s);
		 }

		System.debug('listAgenzieRiassegnazione ====> ' + listAgenzieRiassegnazione);

		for(Integer i = 0; i<listAgenzieRiassegnazione.size(); i++) {
			 try{
				  riordinamentoTipologie.put(listAgenzieRiassegnazione.get(i), listTipologieAgenzieRiassegnazione.get(i));
			  } catch(Exception ex) {
				  riordinamentoTipologie.put(listAgenzieRiassegnazione.get(i), '-');
			  }
		 }
		System.debug(' ===> riordinamentoTipologie: ' + riordinamentoTipologie);

		try{


			 //If the lead is "Richiedi appuntamento" no checks are required since it has to be immediately assigned to the first agency of its list
			 if(newLead.Dettaglio__c == 'Richiedi appuntamento')
			  {
				  List<String> agencyForReassignationList_RichiediApp = new List<String>();
				  List<String> subAgencyForReassignationList_RichiediApp = new List<String>();
				  agencyForReassignationList_RichiediApp.addAll(newLead.Agenzie_per_riassegnazione__c.split(';'));
				  subAgencyForReassignationList_RichiediApp.addAll(newLead.Tipologie_per_riassegnazione__c.split(';'));
				  boolean chosen = false;
				  for(integer i = 0; !chosen && i <  agencyForReassignationList_RichiediApp.size(); i++){
					  String agCode = agencyForReassignationList_RichiediApp.get(i);
					  if(canRedirect.contains(agCode)){
						  newLead.Agency_Code__c = padAgency(agCode);
						  chosen = true;
					  }
				  }
				  if(!chosen){
					newLead.Agency_Code__c = padAgency(agencyForReassignationList_RichiediApp.get(0));
				  }
				  
				  if(subAgencyForReassignationList_RichiediApp.get(0) == '-') {
					   newLead.Codice_Sub_Agenzia__c = '';
				   } else {
					   newLead.Codice_Sub_Agenzia__c = subAgencyForReassignationList_RichiediApp.get(0);
				   }
				  newLead.Ultima_data_di_riassegnazione__c=System.now();
				  if(newLead.Numero_assegnazioni_eseguite__c == null)
					  newLead.Numero_assegnazioni_eseguite__c = 0;
				  newLead.Numero_assegnazioni_eseguite__c += 1;
				  newLead.TECH_Send_Email_Notification__c = TRUE;

				  //updating the lead's field needed for the reassignation process
				  newLead.Agenzie_per_riassegnazione_riordinata__c = '';
				  newLead.Tipologie_per_riassegnazione_riordinata__c = '';
				  Set<String> agencyForReassignationSet_RichiediApp = new Set<String>();
				  agencyForReassignationSet_RichiediApp.addAll(newLead.Agenzie_per_riassegnazione__c.split(';'));
				  String agencyCodesToBePutLast = '';
				  for(String tempCode:agencyForReassignationSet_RichiediApp)
				   {
					   if(tempCode != newLead.Agency_Code__c)
						{
							System.debug(' ===> tempCode != newLead.Agency_Code__c)');
							agencyForReassignationSet_RichiediApp.remove(tempCode);
							if(canRedirect.contains(tempCode))
								agencyCodesToBePutLast = agencyCodesToBePutLast+tempCode+';';
						}
					   else
						{
							for(String tempCode2:agencyForReassignationSet_RichiediApp)
							 {
								if(canRedirect.contains(tempCode2)){
									newLead.Agenzie_per_riassegnazione_riordinata__c = newLead.Agenzie_per_riassegnazione_riordinata__c+tempCode2+';';
									newLead.Tipologie_per_riassegnazione_riordinata__c = newLead.Tipologie_per_riassegnazione_riordinata__c + riordinamentoTipologie.get(tempCode2) + ';';	
								}
								 
							 }
							newLead.Agenzie_per_riassegnazione_riordinata__c = newLead.Agenzie_per_riassegnazione_riordinata__c+agencyCodesToBePutLast;
							if(agencyCodesToBePutLast != '') {
								 newLead.Tipologie_per_riassegnazione_riordinata__c = newLead.Tipologie_per_riassegnazione_riordinata__c + riordinamentoTipologie.get(agencyCodesToBePutLast);
							 }
							break;
						}
				   }

				  Database.SaveResult SaveResult = database.update(newLead,false);
				  //if(!agenciesList[0].Active__c) return false; BOVOLENTA_D 19032018 READY FIX FOR LEADS in appointment @ inactive agencies

				  return true;
			  }

			 //Retrieving, for each Agency in the Lead's field Agenzie per riassegnazione, their existing week assignments
			 mapAgencyExistingAssignment = getAssignmentList(agenciesList,newLead);

			 //Retrieving the parameters needed to calculate the cycle of each agency
			 //First, the default values are set
			 Decimal limitAssignmentNumberToday = Assegnazioni_Configuration__c.getValues('Default').LimitAssignmentNumberToday__c;
			 Decimal limitAssignmentNumberWeek = Assegnazioni_Configuration__c.getValues('Default').LimitAssignmentNumberWeek__c;
			 Map<String,Assegnazioni__c> mapAgencyCodeToTodayAssegnazioni = new Map<String,Assegnazioni__c>(); //
			 Map<String,Integer> mapAgencyCodeToCycle = new Map<String,Integer>();
			 //Then the values correspondant to the Lead Landing Page, if any
			 if(newLead.Landing_Page__c != null)
			  {
				  String quotatoreLead = LeadAssignmentConfiguration__c.getValues(newLead.Landing_Page__c).Ranking__c;
				  if(String.isNotBlank(quotatoreLead))
				   {
					   limitAssignmentNumberToday = Assegnazioni_Configuration__c.getValues(quotatoreLead).LimitAssignmentNumberToday__c;
					   limitAssignmentNumberWeek = Assegnazioni_Configuration__c.getValues(quotatoreLead).LimitAssignmentNumberWeek__c;
				   }
			  }
			 //Now, for each agency, calcuting in which cycle they are in
			 system.debug('#@#@ LEAD NAME '+newLead);
			 system.debug('#@#@ AGENCIES LIST '+agenciesList);
			 system.debug('#@#@ mapAgencyExistingAssignment '+mapAgencyExistingAssignment);

			 //for(Account currentAgency: agenciesList)
			 for(String s: listAgenzieRiassegnazione)
			  {
				  if(mapCodeToAgency.keySet().contains(s) && canRedirect.contains(s))
				   {
					   Account currentAgency = mapCodeToAgency.get(s);
					   system.debug('#@#@ Current Agency '+currentAgency);
					   List<Assegnazioni__c> agExistingAssignment = mapAgencyExistingAssignment.get(currentAgency);
					   if(agExistingAssignment.size()>0)
						{
							system.debug('#@#@ agExistingAssignment '+agExistingAssignment);
							Assegnazioni__c agencyTodayAssignment = agExistingAssignment.get(agExistingAssignment.size()-1);
							system.debug('#@#@ agencyTodayAssignment '+agencyTodayAssignment);
							mapAgencyCodeToTodayAssegnazioni.put(padAgency(currentAgency.Agency_Code__c),agencyTodayAssignment);
							Decimal agencyAssignmentNumberToday = 0;
							Decimal agencyAssignmentNumberWeek = 0;

							if(agencyTodayAssignment.Numero_Assegnazioni__c == null)
							 {
								 agencyTodayAssignment.Numero_Assegnazioni__c = 0;
							 }
							agencyAssignmentNumberToday = agencyTodayAssignment.Numero_Assegnazioni__c;
							Integer agencyCycleNumberToday = (agencyAssignmentNumberToday/limitAssignmentNumberToday).intvalue();

							for(Integer j=0; j<agExistingAssignment.size(); j++)
							 {
								 if(agExistingAssignment.get(j).Numero_Assegnazioni__c == null)
								  {
									  agExistingAssignment.get(j).Numero_Assegnazioni__c = 0;
								  }
								 agencyAssignmentNumberWeek += agExistingAssignment.get(j).Numero_Assegnazioni__c;
							 }
							system.debug('#@#@ agencyAssignmentNumberToday '+agencyAssignmentNumberToday);
							system.debug('#@#@ limitAssignmentNumberToday '+limitAssignmentNumberToday);
							system.debug('#@#@ agencyAssignmentNumberWeek '+agencyAssignmentNumberWeek);
							system.debug('#@#@ limitAssignmentNumberWeek '+limitAssignmentNumberWeek);
							Integer agencyCycleNumberWeek = (agencyAssignmentNumberWeek/limitAssignmentNumberWeek).intvalue();

							Integer agencyCycle = agencyCycleNumberToday+agencyCycleNumberWeek;
							mapAgencyCodeToCycle.put(padAgency(currentAgency.Agency_Code__c),agencyCycle);
						}
				   }
			  }
			 system.debug('#@#@ mapAgencyCodeToCycle '+mapAgencyCodeToCycle);

			 //Getting the first agency that is in the lowest cycle
			 Integer lowestCycle = 2147483647;
			 String lowestCycleAgencyCode = '';
			 for(String tempAgencyCode:mapAgencyCodeToCycle.keyset())
			  {
				  if(mapAgencyCodeToCycle.get(tempAgencyCode)<lowestCycle)
				   {
					   lowestCycleAgencyCode = tempAgencyCode;
					   lowestCycle = mapAgencyCodeToCycle.get(tempAgencyCode);
				   }
			  }
			 system.debug('#@#@ lowestCycleAgencyCode '+lowestCycleAgencyCode);
			 //updating the lead's assignment fields
			 newLead.Agency_Code__c = padAgency(lowestCycleAgencyCode);
			 if(riordinamentoTipologie.get(lowestCycleAgencyCode) == '-') {
				  newLead.Codice_Sub_Agenzia__c = '';
			  } else {
				  newLead.Codice_Sub_Agenzia__c = riordinamentoTipologie.get(lowestCycleAgencyCode);
			  }
			 newLead.Ultima_data_di_riassegnazione__c=System.now();
			 if(newLead.Numero_assegnazioni_eseguite__c == null)
				 newLead.Numero_assegnazioni_eseguite__c = 0;
			 newLead.Numero_assegnazioni_eseguite__c += 1;
			 //Start - 001
			 newLead.TECH_Send_Email_Notification__c = TRUE;
			 //End - 001
			 //updating the lead's field needed for the reassignation process
			 newLead.Agenzie_per_riassegnazione_riordinata__c = '';
			 newLead.Tipologie_per_riassegnazione_riordinata__c = '';
			 Set<String> agencyForReassignationList = new Set<String>();
			 agencyForReassignationList.addAll(newLead.Agenzie_per_riassegnazione__c.split(';'));
			 String agencyCodesToBePutLast = '';
			 for(String tempCode:agencyForReassignationList)
			  {
					System.debug(' ===> tempCode: ' + tempCode);
					if(tempCode != newLead.Agency_Code__c )
					{
						System.debug(' ===> tempCode != newLead.Agency_Code__c)');
						agencyForReassignationList.remove(tempCode);
						if( canRedirect.contains(tempCode) )
							agencyCodesToBePutLast = agencyCodesToBePutLast+tempCode+';';
					}
					else
					{
						System.debug(' ===> tempCode == newLead.Agency_Code__c)');
						for(String tempCode2:agencyForReassignationList)
						{
							if(canRedirect.contains(tempCode2)){
								System.debug(' ===> for loop');
								newLead.Agenzie_per_riassegnazione_riordinata__c = newLead.Agenzie_per_riassegnazione_riordinata__c+tempCode2+';';
								System.debug(' ===> tempCode2: ' + tempCode2);
								newLead.Tipologie_per_riassegnazione_riordinata__c = newLead.Tipologie_per_riassegnazione_riordinata__c + riordinamentoTipologie.get(tempCode2) + ';';
								System.debug(' ===> riordinamentoTipologie: ' + riordinamentoTipologie.get(tempCode2));
							}
						}
						newLead.Agenzie_per_riassegnazione_riordinata__c = newLead.Agenzie_per_riassegnazione_riordinata__c+agencyCodesToBePutLast;
						System.debug(' ===> agencyCodesToBePutLast: ' + agencyCodesToBePutLast);
						if(agencyCodesToBePutLast != '') {
							for(String lastCode : agencyCodesToBePutLast.split(';')) {
									System.debug(' ===> riordinamentoTipologie: ' + riordinamentoTipologie.get(lastCode));
									newLead.Tipologie_per_riassegnazione_riordinata__c = newLead.Tipologie_per_riassegnazione_riordinata__c + riordinamentoTipologie.get(lastCode)+';';
								}
						}
						break;
					}
			  }
			  Database.SaveResult SaveResult;
			  if(newLead.Id != null){
				  SaveResult= database.update(newLead,false);
			 	
				  system.debug('*******leadUpdateResult '+SaveResult);
			  }
			  
			 if(newLead.Id == null || SaveResult != null && SaveResult.isSuccess())
			  {
				  Assegnazioni__c TodayAssignment = mapAgencyCodeToTodayAssegnazioni.get(lowestCycleAgencyCode);
				  TodayAssignment.Numero_Assegnazioni__c +=1;
				  Database.UpsertResult SaveResultToday = database.upsert(TodayAssignment,false);
				  //Relocking
				  String query2 = '';
				  query2 = 'SELECT Id FROM Assegnazioni__c WHERE Id = \''+TodayAssignment.Id+'\' FOR UPDATE';
				  system.debug('******** query'+ query2 );
				  Assegnazioni__c lockAssignment = Database.query(query2);
				  return true;
			  }
			 else
			  {
				  return false;
			  }
		 } 
		catch(Exception e)
		 {
			 return false;
		 }
	}
	//CAPOBIANCO_A 11/01/2018 SPRINT 59 -- END
 
	public static String padAgency(String agencyId){
		while(String.isNotBlank(agencyId) && agencyId.length() < 6) {
            agencyId ='0'+ agencyId;
         }
         return agencyId;
	}

}
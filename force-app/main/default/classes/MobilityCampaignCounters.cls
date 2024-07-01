public with sharing class MobilityCampaignCounters {
	@AuraEnabled public Decimal customersInTarget;
	@AuraEnabled public Decimal customersProcessed;
	@AuraEnabled public Decimal customersPriority;
	@AuraEnabled public Decimal customersPriorityProcessed;
	@AuraEnabled public Decimal opportunityCreated;
	@AuraEnabled public Decimal opportunityWon;
	@AuraEnabled public Decimal opportunityWonCustomerPriority;
	@AuraEnabled public Decimal opportunityOngoing;
	@AuraEnabled public Decimal opportunityWonRevenue;
	@AuraEnabled public Decimal opportunityOngoingRevenue;
	@AuraEnabled public Decimal deliveredEmailSMS;
	@AuraEnabled public Decimal customersInTargetWithEmailSMS;
	@AuraEnabled public Decimal undeliveredEmailSMS;
	@AuraEnabled public Decimal customersInTargetWithEmail;
	@AuraEnabled public Decimal customersOpenEmailContactRequest;
	@AuraEnabled public Decimal customersInTargetWithSMS;
	@AuraEnabled public Decimal customersOpenSMSContactRequest;
	@AuraEnabled public Decimal customersWithOpenEmailSMS;
	@AuraEnabled public Decimal customersPriorityEmail;
	@AuraEnabled public Decimal customersPrioritySMS;

	public MobilityCampaignCounters(String campaignId, String collaboratorId, String agencyCode) {
		this.retrieveCustomersProcessed(campaignId, collaboratorId, agencyCode);
		this.retrieveCustomersInTarget(campaignId, collaboratorId, agencyCode);
		this.retrieveCustomersPriority(campaignId, collaboratorId, agencyCode);
		this.retrieveCustomersPriorityProcessed(campaignId, collaboratorId, agencyCode);
		this.retrieveOpportunityCreated(campaignId, collaboratorId, agencyCode);
		this.retrieveOpportunityWon(campaignId, collaboratorId, agencyCode);
		this.retrieveOpportunityWonCustomerPriority(campaignId, collaboratorId, agencyCode);
		this.retrieveOpportunityOngoing(campaignId, collaboratorId, agencyCode);
		this.retrieveOpportunityWonRevenue(campaignId, collaboratorId, agencyCode);
		this.retrieveOpportunityOngoingRevenue(campaignId, collaboratorId, agencyCode);
		this.retrieveDeliveredEmailSMS(campaignId, collaboratorId, agencyCode);
		this.retrieveCustomersInTargetWithEmailSMS(campaignId, collaboratorId, agencyCode);
		this.retrieveUndeliveredEmailSMS(campaignId, collaboratorId, agencyCode);
		this.retrieveCustomersInTargetWithEmail(campaignId, collaboratorId, agencyCode);
		this.retrieveCustomersOpenEmailContactRequest(campaignId, collaboratorId, agencyCode);
		this.retrieveCustomersInTargetWithSMS(campaignId, collaboratorId, agencyCode);
		this.retrieveCustomersOpenSMSContactRequest(campaignId, collaboratorId, agencyCode);
		this.retrieveCustomersWithOpenEmailSMS(campaignId, collaboratorId, agencyCode);
		this.retrieveCustomersPriorityEmail(campaignId, collaboratorId, agencyCode);
		this.retrieveCustomersPrioritySMS(campaignId, collaboratorId, agencyCode);
	}

	public Decimal getValue(String query) {
		AggregateResult result = Database.query(query);
		if (result.get('countData') != null) {
			return (Decimal) result.get('countData');
		}
		return 0;
	}

	public String generateQuery(Set<String> fieldsSet, String sobjectName, Set<String> andCondition ){
		if(sobjectName == 'CampaignMember') andCondition.add(SObjectTable.whereField('Partner_Role_Visibility__c', 'true'));

		return SObjectTable.getTableQuery(fieldsSet, sobjectName, andCondition, null, null, null, null);
	}

	public void retrieveCustomersInTarget(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'CampaignMember';
		Set < String > andCondition = new Set < String > ();
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));

		if (string.isnotblank(agencyCode)) {
			andCondition.add(SObjectTable.whereField('Agency_Code__c', agencyCode));
		}

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('Owner__r.Id', collaboratorId));
		}

		this.customersInTarget = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveCustomersProcessed(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'CampaignMember';
		Set < String > andCondition = new Set < String > ();
		Set < Object > statusCondition = new Set < Object > {
			'Da assegnare',
			'Da contattare',
			'Da lavorare'
		};
		andCondition.add(SObjectTable.whereNotIn('Status', StatusCondition));
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));

		if (string.isnotblank(agencyCode)) {
			andCondition.add(SObjectTable.whereField('Agency_Code__c', agencyCode));
		}

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('Owner__r.Id', collaboratorId));
		}

		this.customersProcessed = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveCustomersPriority(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'CampaignMember';
		Set < String > andCondition = new Set < String > ();
		Set < Object > subStatusCondition = new Set < Object > {
			'Richiesta di contatto da Email',
			'Richiesta di contatto da SMS'
		};
		andCondition.add(SObjectTable.whereIn('Sottostato__c', subStatusCondition));
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));

		if (string.isnotblank(agencyCode)) {
			andCondition.add(SObjectTable.whereField('Agency_Code__c', agencyCode));
		}

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('Owner__r.Id', collaboratorId));
		}

		this.customersPriority = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveCustomersPriorityProcessed(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'CampaignMember';
		Set < String > andCondition = new Set < String > ();
		Set < Object > statusCondition = new Set < Object > {
			'Da assegnare',
			'Da contattare',
			'Da lavorare'
		};
		Set < Object > subStatusCondition = new Set < Object > {
			'Richiesta di contatto da Email',
			'Richiesta di contatto da SMS'
		};
		andCondition.add(SObjectTable.whereNotIn('Status', statusCondition));
		andCondition.add(SObjectTable.whereIn('Sottostato__c', subStatusCondition));
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));

		if (string.isnotblank(agencyCode)) {
			andCondition.add(SObjectTable.whereField('Agency_Code__c', agencyCode));
		}

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('Owner__r.Id', collaboratorId));
		}

		this.customersPriorityProcessed = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveOpportunityCreated(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'Opportunity';
		Set < String > andCondition = new Set < String > ();
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('CreatedById', collaboratorId));
		}

		this.opportunityCreated = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveOpportunityWon(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'Opportunity';
		Set < String > andCondition = new Set < String > ();
		andCondition.add(SObjectTable.whereField('StageName', 'Closed Won'));
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('CreatedById', collaboratorId));
		}

		this.opportunityWon = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveOpportunityWonCustomerPriority(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'Opportunity';
		Set < String > andCondition = new Set < String > ();
		andCondition.add(SObjectTable.whereField('StageName', 'Closed Won'));
		// TODO 432 - OpportunitaVinteClientiPrioritari - vedere query per Id IN (query)
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));
		andCondition.add(SObjectTable.whereField('Id', '!QUERYIN(SELECT Campaign_member_related_Opportunity__c FROM CampaignMember WHERE Sottostato__c IN (\'Richiesta di contatto da Email\',\'Richiesta di contatto da SMS\'))'));

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('CreatedById', collaboratorId));
		}

		this.opportunityWonCustomerPriority = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveOpportunityWonRevenue(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'SUM(Amount) countData'
		};
		String sobjectName = 'Opportunity';
		Set < String > andCondition = new Set < String > ();
		andCondition.add(SObjectTable.whereField('StageName', 'Closed Won'));
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('CreatedById', collaboratorId));
		}

		this.opportunityWonRevenue = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveOpportunityOngoing(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'Opportunity';
		Set < String > andCondition = new Set < String > ();
		Set < Object > stageCondition = new Set < Object > {
			'Open',
			'Proposal Made'
		};
		andCondition.add(SObjectTable.whereIn('StageName', stageCondition));
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('CreatedById', collaboratorId));
		}

		this.opportunityOngoing = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveOpportunityOngoingRevenue(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'SUM(Amount) countData'
		};
		String sobjectName = 'Opportunity';
		Set < String > andCondition = new Set < String > ();
		Set < Object > stageCondition = new Set < Object > {
			'Open',
			'Proposal Made'
		};
		andCondition.add(SObjectTable.whereIn('StageName', stageCondition));
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('CreatedById', collaboratorId));
		}

		this.opportunityOngoingRevenue = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveDeliveredEmailSMS(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'CampaignMember';
		Set < String > andCondition = new Set < String > ();
		Set < Object > subStatusCondition = new Set < Object > {
			'Inviata Email',
			'Inviato SMS',
			'Aperta Email',
			'Aperto SMS',
			'Richiesta di contatto da Email',
			'Richiesta di contatto da SMS',
			'SMS non recapitabile',
			'Email non recapitabile'
		};
		andCondition.add(SObjectTable.whereIn('Sottostato__c', subStatusCondition));
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));

		if (string.isnotblank(agencyCode)) {
			andCondition.add(SObjectTable.whereField('Agency_Code__c', agencyCode));
		}

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('Owner__r.Id', collaboratorId));
		}

		this.deliveredEmailSMS = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveCustomersInTargetWithEmailSMS(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'CampaignMember';
		Set < String > andCondition = new Set < String > ();
		Set < Object > subStatusCondition = new Set < Object > {
			'Inviata Email',
			'Inviato SMS',
			'Aperta Email',
			'Aperto SMS',
			'Richiesta di contatto da Email',
			'Richiesta di contatto da SMS',
			'SMS non recapitabile',
			'Email non recapitabile'
		};
		andCondition.add(SObjectTable.whereIn('Sottostato__c', subStatusCondition));
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));

		if (string.isnotblank(agencyCode)) {
			andCondition.add(SObjectTable.whereField('Agency_Code__c', agencyCode));
		}

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('Owner__r.Id', collaboratorId));
		}

		this.customersInTargetWithEmailSMS = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveUndeliveredEmailSMS(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'CampaignMember';
		Set < String > andCondition = new Set < String > ();
		// TODO 766 - EmailSMSNonRecapitabili - vedere query where x in y OR x in z
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));
		andCondition.add(SObjectTable.whereField('QUERY', '!QUERY((MobilePhone <> Null AND Sottostato__c = \'SMS non recapitabile\') OR (Email <> Null AND Sottostato__c = \'Email non recapitabile\'))'));

		if (string.isnotblank(agencyCode)) {
			andCondition.add(SObjectTable.whereField('Agency_Code__c', agencyCode));
		}

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('Owner__r.Id', collaboratorId));
		}

		this.undeliveredEmailSMS = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveCustomersInTargetWithEmail(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'CampaignMember';
		Set < String > andCondition = new Set < String > ();
		Set < Object > subStatusCondition = new Set < Object > {
			'Inviata Email',
			'Aperta Email',
			'Richiesta di contatto da Email'
		};
		andCondition.add(SObjectTable.whereField('Email', 'Null'));
		andCondition.add(SObjectTable.whereIn('Sottostato__c', subStatusCondition));
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));

		if (string.isnotblank(agencyCode)) {
			andCondition.add(SObjectTable.whereField('Agency_Code__c', agencyCode));
		}

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('Owner__r.Id', collaboratorId));
		}

		this.customersInTargetWithEmail = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveCustomersOpenEmailContactRequest(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'CampaignMember';
		Set < String > andCondition = new Set < String > ();
		Set < Object > subStatusCondition = new Set < Object > {
			'Aperta Email',
			'Richiesta di contatto da Email'
		};
		andCondition.add(SObjectTable.whereField('Email', 'Null'));
		andCondition.add(SObjectTable.whereIn('Sottostato__c', subStatusCondition));
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));

		if (string.isnotblank(agencyCode)) {
			andCondition.add(SObjectTable.whereField('Agency_Code__c', agencyCode));
		}

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('Owner__r.Id', collaboratorId));
		}

		this.customersOpenEmailContactRequest = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveCustomersInTargetWithSMS(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'CampaignMember';
		Set < String > andCondition = new Set < String > ();
		Set < Object > subStatusCondition = new Set < Object > {
			'Inviato SMS',
			'Aperto SMS',
			'Richiesta di contatto da SMS'
		};
		andCondition.add(SObjectTable.whereField('MobilePhone', 'Null'));
		andCondition.add(SObjectTable.whereIn('Sottostato__c', subStatusCondition));
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));

		if (string.isnotblank(agencyCode)) {
			andCondition.add(SObjectTable.whereField('Agency_Code__c', agencyCode));
		}

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('Owner__r.Id', collaboratorId));
		}

		this.customersInTargetWithSMS = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveCustomersOpenSMSContactRequest(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'CampaignMember';
		Set < String > andCondition = new Set < String > ();
		Set < Object > subStatusCondition = new Set < Object > {
			'Aperto SMS',
			'Richiesta di contatto da SMS'
		};
		andCondition.add(SObjectTable.whereField('MobilePhone', 'Null'));
		andCondition.add(SObjectTable.whereIn('Sottostato__c', subStatusCondition));
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));

		if (string.isnotblank(agencyCode)) {
			andCondition.add(SObjectTable.whereField('Agency_Code__c', agencyCode));
		}

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('Owner__r.Id', collaboratorId));
		}

		this.customersOpenSMSContactRequest = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveCustomersWithOpenEmailSMS(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'CampaignMember';
		Set < String > andCondition = new Set < String > ();
		// TODO 1035 - ClientiConEmailSMSAperti - vedere query where x in y OR x in z
		andCondition.add(SObjectTable.whereField('Sottostato__c', 'Inviato SMS, Aperto SMS, Richiesta di contatto da SMS'));
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));
		andCondition.add(SObjectTable.whereField('QUERY', '!QUERY((MobilePhone <> Null AND Sottostato__c = \'Aperto SMS\') OR (Email <> Null AND Sottostato__c = \'Aperta Email\'))'));

		if (string.isnotblank(agencyCode)) {
			andCondition.add(SObjectTable.whereField('Agency_Code__c', agencyCode));
		}

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('Owner__r.Id', collaboratorId));
		}

		this.customersWithOpenEmailSMS = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveCustomersPriorityEmail(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'CampaignMember';
		Set < String > andCondition = new Set < String > ();
		andCondition.add(SObjectTable.whereField('Email', 'Null'));
		andCondition.add(SObjectTable.whereField('Sottostato__c', 'Richiesta di contatto da Email'));
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));

		if (string.isnotblank(agencyCode)) {
			andCondition.add(SObjectTable.whereField('Agency_Code__c', agencyCode));
		}

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('Owner__r.Id', collaboratorId));
		}

		this.customersPriorityEmail = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}

	public void retrieveCustomersPrioritySMS(String campaignId, String collaboratorId, String agencyCode) {
		Set < String > fieldsSet = new Set < String > {
			'COUNT(Id) countData'
		};
		String sobjectName = 'CampaignMember';
		Set < String > andCondition = new Set < String > ();
		andCondition.add(SObjectTable.whereField('MobilePhone', 'Null'));
		andCondition.add(SObjectTable.whereField('Sottostato__c', 'Richiesta di contatto da SMS'));
		andCondition.add(SObjectTable.whereField('CampaignId', campaignId));

		if (string.isnotblank(agencyCode)) {
			andCondition.add(SObjectTable.whereField('Agency_Code__c', agencyCode));
		}

		if (string.isnotblank(collaboratorId)) {
			andCondition.add(SObjectTable.whereField('Owner__r.Id', collaboratorId));
		}

		this.customersPrioritySMS = this.getValue(this.generateQuery(fieldsSet, sobjectName, andCondition));
	}
}
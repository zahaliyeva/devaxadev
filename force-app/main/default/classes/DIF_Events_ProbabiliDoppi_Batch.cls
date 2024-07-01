global class DIF_Events_ProbabiliDoppi_Batch implements Database.Batchable<SObject>, Schedulable {

    public static final Integer MAX_SCOPE = 1;
    public List<String> agencyCode = new List<String>(); 
    public List<String> accountPerdenteIds;
    public AP_Constants.EventoDIF eventType = AP_Constants.EventoDIF.TRASFERIMENTO_TOTALE;
    private String query = 'SELECT Id, AAI_Agency_Reference_Code__c, NDG_Vincente__c, NDG__c, Fiscal_ID__c, Notes__c,' +
            ' AnnualRevenue, Website' +
            ' FROM Account ' +
            ' WHERE AAI_Agency_Reference_Code__c = :agencyCode AND NDG_Vincente__c != NULL AND NDG_Vincente__c != \'nd\'  AND RecordType.DeveloperName IN (\'B2C_Client\', \'B2B_Client\') AND Nodes__c != NULL ORDER BY LastModifiedDate DESC';

    //for testing single Account
    private String queryByAccountPerdenteId = 'SELECT Id, AAI_Agency_Reference_Code__c, NDG_Vincente__c, NDG__c, Fiscal_ID__c, Notes__c,' + 
            ' AnnualRevenue, Website' +
            ' FROM Account ' +
            ' WHERE NDG_Vincente__c != NULL AND NDG_Vincente__c != \'nd\'  AND RecordType.DeveloperName IN (\'B2C_Client\', \'B2B_Client\') AND Nodes__c != NULL AND Id =: accountPerdenteIds';

  
    global Iterable<SObject> start(Database.BatchableContext bc) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.start ' + ' agencyCode ' + agencyCode);
        System.debug('DIF_Events_ProbabiliDoppi_Batch.start ' + ' accountPerdenteId ' + accountPerdenteIds);
        if(accountPerdenteIds != null){
            return Database.getQueryLocator(queryByAccountPerdenteId);
        } 
        return Database.getQueryLocator(query);
    }

    global void execute(SchedulableContext sc) {
        DIF_Events_ProbabiliDoppi_Batch b = new DIF_Events_ProbabiliDoppi_Batch();
        Database.executeBatch(b, MAX_SCOPE);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope) { 
        System.debug('DIF_Events_ProbabiliDoppi_Batch.execute start');
        Map<String, Account> ndgVincentiAccountPerdentiMap = new Map<String, Account>();
        Map<Id, Account> accountPerdentiMap = new Map<Id, Account>(scope);
        List<Account> accountsToUpdate = new List<Account>();

        // associo l'NDG VINCENTE all'account con NDG PERDENTE
        for (Account accPerdente : scope) {
            ndgVincentiAccountPerdentiMap.put(accPerdente.NDG_Vincente__c, accPerdente);
        }

        // recupero gli account con NDG VINCENTE
        List<Account> accVincenti = [
                SELECT Id, NDG__c, AnnualRevenue, Website
                FROM Account
                WHERE NDG__c IN :ndgVincentiAccountPerdentiMap.keySet()
        ]; 
        System.debug('DIF_Events_ProbabiliDoppi_Batch.execute ' + ' Lista Account Perdenti (size)' + scope.size());
        System.debug('DIF_Events_ProbabiliDoppi_Batch.execute ' + ' Lista Account Vincenti (size)' + accVincenti.size());
        Map<String, Account> ndgAccountVincentiMap = new Map<String, Account>();
        Set<Id> accountIdSet = new Set<Id>(); 

        for (Account accVincente : accVincenti) {
            Account accPerdente = ndgVincentiAccountPerdentiMap.get(accVincente.NDG__c);
            // Verranno replicati i seguenti campi dal cliente doppio al cliente con NDG vincente (salvo essere già popolati su quest'ultimo):
            System.debug('DIF_Events_ProbabiliDoppi_Batch.execute ' + ' Copy fields of Account Perdente (NDG)' + accPerdente.NDG__c +' To Account Vincente (NDG) ' + accVincente.NDG__c);
            this.cloneFieldsFromOldToNew(accPerdente, accVincente);
            //Verrà sbiancato il campo nodi del cliente con NDG perdente
            // (TODO) e verrà rimossa la visibilità all'agenzia e allo Smart Cente
            accPerdente.Nodes__c = null;
            ndgAccountVincentiMap.put(accVincente.NDG__c, accVincente);
            if ( ! accountIdSet.contains( accPerdente.Id) ){
                accountsToUpdate.add(accPerdente);
                accountIdSet.add(accPerdente.Id);
            }
            
            if ( ! accountIdSet.contains( accPerdente.Id) ){
                accountsToUpdate.add(accVincente);
                accountIdSet.add(accVincente.Id);
            }
            
           
           
        }
		
        this.databaseUpdate(accountsToUpdate, 'Account');

        this.updateCommmunicationToCustomer(accountPerdentiMap, ndgAccountVincentiMap);
        this.updateStoricoChiamate(accountPerdentiMap, ndgAccountVincentiMap);
        this.updateLiveChatTranscript(accountPerdentiMap, ndgAccountVincentiMap);
        this.updateCompetitorContract(accountPerdentiMap, ndgAccountVincentiMap);
        this.updateCustomerEvent(accountPerdentiMap, ndgAccountVincentiMap);
        this.updateLifeEvent(accountPerdentiMap, ndgAccountVincentiMap);
        this.updateIndividualEmailResult(accountPerdentiMap, ndgAccountVincentiMap);
        this.updateMembroCampagna(accountPerdentiMap, ndgAccountVincentiMap);
        this.updateOpportunity(accountPerdentiMap, ndgAccountVincentiMap);
		// commentato su richiesta di Dario Boninsegni (AXA), la logica non è quella desiderata.
        //this.updateMembroDelNucleo(accountPerdentiMap, ndgAccountVincentiMap);
        this.updateFeedback(accountPerdentiMap, ndgAccountVincentiMap);
        this.updateTask(accountPerdentiMap, ndgAccountVincentiMap);
        this.updateEvent(accountPerdentiMap, ndgAccountVincentiMap);
        this.updateNoteAndAttachment(accountPerdentiMap, ndgAccountVincentiMap);

        //FOZDEN 16/07/2019: comunicazioni massive - start
        //this.updateDocuments(accountPerdentiMap, ndgAccountVincentiMap);
        this.updateMassiveCommunications(accountPerdentiMap, ndgAccountVincentiMap);
        //FOZDEN 16/07/2019: comunicazioni massive - end
        
        System.debug('DIF_Events_ProbabiliDoppi_Batch.execute end');
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateCommmunicationToCustomer finish start');
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateCommmunicationToCustomer finish end');
    }

    private void updateCommmunicationToCustomer(Map<Id, Account> accountPerdentiMap, Map<String, Account> ndgAccountVincentiMap) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateCommmunicationToCustomer start');
        List<Communications_to_customer__c> commToCustomersToUpsert = new List<Communications_to_customer__c>();

        List<Communications_to_customer__c> commToCustomers = [
                SELECT Id, AccountId__c, AccountId__r.NDG_Vincente__c, AccountId__r.NDG__c, Message__c, Mobile_Phone__c
                FROM Communications_to_customer__c
                WHERE AccountId__c IN :accountPerdentiMap.keySet() //sono sicuro di recuperare solo COMM TO CUSTOMER che hanno un ACCOUNT PERDENTE ASSOCIATO
        ];
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateCommmunicationToCustomer Communications_to_customer__c (size) Account Perdenti ' + commToCustomers.size());
 
        for (Communications_to_customer__c cc : commToCustomers) { 
            System.debug('DIF_Events_ProbabiliDoppi_Batch.updateCommmunicationToCustomer Account Perdente ' + cc.AccountId__c + ' - ' + cc.AccountId__r.NDG__c);
            if (ndgAccountVincentiMap.get(accountPerdentiMap.get(cc.AccountId__c).NDG_Vincente__c) != null) { 
                Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(cc.AccountId__c).NDG_Vincente__c);
                System.debug('DIF_Events_ProbabiliDoppi_Batch.updateCommmunicationToCustomer Account Vincente ' + accVincente.Id + ' - ' + accVincente.NDG__c);
                Communications_to_customer__c newCommToCust = cc.clone(false, true, true, true);

                Map<DIF_Utility_Log.DataLogs, String> log = DIF_Utility_Log.createMapForLog(eventType, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.AGENCY_CODE_NEW, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_OLD, cc.AccountId__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_NEW, accVincente.Id);
                log.put(DIF_Utility_Log.DataLogs.NDG_OLD, cc.AccountId__r.NDG__c);
                log.put(DIF_Utility_Log.DataLogs.NDG_NEW, accVincente.NDG__c);
                log.put(DIF_Utility_Log.DataLogs.RECORD_ID_OLD, cc.Id);

                newCommToCust.AccountId__c = accVincente.Id;
                DIF_Utility_Log.updateRecord(cc, Datetime.now(), log);
                DIF_Utility_Log.updateRecord(newCommToCust, Datetime.now(), log);
                commToCustomersToUpsert.add(cc);
                commToCustomersToUpsert.add(newCommToCust);
            } else { 
                System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateCommmunicationToCustomer ' + ' Cannot find Account Vincente con NDG ' + cc.AccountId__r.NDG_Vincente__c);
            }

        }
        if (commToCustomersToUpsert.size() > 0) {
            this.databaseUpsert(commToCustomersToUpsert, 'Communications_to_customer__c');
        }
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateCommmunicationToCustomer end');
    }

    private void updateStoricoChiamate(Map<Id, Account> accountPerdentiMap, Map<String, Account> ndgAccountVincentiMap) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateStoricoChiamate start');
        List<Storico_Chiamate__c> storicoChiamateToUpdate = new List<Storico_Chiamate__c>();

        List<Storico_Chiamate__c> storicoChiamate = [
                SELECT Id, Customer__c, Customer__r.Id, Customer__r.NDG__c, Customer__r.NDG_Vincente__c, Agente__c
                FROM Storico_Chiamate__c
                WHERE Customer__c IN :accountPerdentiMap.keySet()
        ];
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateStoricoChiamate Storico_Chiamate__c (size) Account Perdenti ' + storicoChiamate.size());

        for (Storico_Chiamate__c sc : storicoChiamate) {
            System.debug('DIF_Events_ProbabiliDoppi_Batch.updateStoricoChiamate Account Perdente ' + sc.Customer__r.Id + ' - ' + sc.Customer__r.NDG__c);
            if (ndgAccountVincentiMap.get(accountPerdentiMap.get(sc.Customer__c).NDG_Vincente__c) != null) {
                Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(sc.Customer__c).NDG_Vincente__c); 
                System.debug('DIF_Events_ProbabiliDoppi_Batch.updateStoricoChiamate Account Vincente ' + accVincente.Id + ' - ' + accVincente.NDG__c);
                Map<DIF_Utility_Log.DataLogs, String> log = DIF_Utility_Log.createMapForLog(eventType, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.AGENCY_CODE_NEW, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_OLD, sc.Customer__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_NEW, accVincente.Id);
                log.put(DIF_Utility_Log.DataLogs.NDG_OLD, sc.Customer__r.NDG__c);
                log.put(DIF_Utility_Log.DataLogs.NDG_NEW, accVincente.NDG__c);
                sc.Customer__c = accVincente.Id;
                DIF_Utility_Log.updateRecord(sc, Datetime.now(), log);
                storicoChiamateToUpdate.add(sc);
            } else {
                System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateStoricoChiamate ' + ' Cannot find Account Vincente con NDG ' + sc.Customer__r.NDG_Vincente__c);
            }
        } 
        if (storicoChiamateToUpdate.size() > 0) {
            this.databaseUpdate(storicoChiamateToUpdate, 'Storico_Chiamate__c');
        }
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateStoricoChiamate end');
    }

    private void updateLiveChatTranscript(Map<Id, Account> accountPerdentiMap, Map<String, Account> ndgAccountVincentiMap) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateLiveChatTranscript start');
        List<LiveChatTranscript> liveChatsToUpdate = new List<LiveChatTranscript>();
        List<LiveChatTranscript> liveChats = [
                SELECT Id, AccountId, Account.NDG__c, Account.NDG_Vincente__c
                FROM LiveChatTranscript
                WHERE AccountId IN :accountPerdentiMap.keySet()
        ];
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateLiveChatTranscript Storico_Chiamate__c (size) Account Perdenti ' + liveChats.size());
        for (LiveChatTranscript lc : liveChats) {
            System.debug('DIF_Events_ProbabiliDoppi_Batch.updateLiveChatTranscript Account Perdente ' + lc.AccountId + ' - ' + lc.Account.NDG__c);
            if (ndgAccountVincentiMap.get(accountPerdentiMap.get(lc.AccountId).NDG_Vincente__c) != null) {
                Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(lc.AccountId).NDG_Vincente__c);
                System.debug('DIF_Events_ProbabiliDoppi_Batch.updateLiveChatTranscript Account Vincente ' + accVincente.Id + ' - ' + accVincente.NDG__c);
                Map<DIF_Utility_Log.DataLogs, String> log = DIF_Utility_Log.createMapForLog(eventType, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.AGENCY_CODE_NEW, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_OLD, lc.AccountId);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_NEW, accVincente.Id);
                log.put(DIF_Utility_Log.DataLogs.NDG_OLD, lc.Account.NDG__c);
                log.put(DIF_Utility_Log.DataLogs.NDG_NEW, accVincente.NDG__c);
                lc.AccountId = accVincente.Id;
                DIF_Utility_Log.updateRecord(lc, Datetime.now(), log);
                liveChatsToUpdate.add(lc);
            } else {
                System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateLiveChatTranscript ' + ' Cannot find Account Vincente con NDG ' + lc.Account.NDG_Vincente__c);
            }
        }
        if (liveChatsToUpdate.size() > 0) {
            this.databaseUpdate(liveChatsToUpdate, 'LiveChatTranscript');
        }
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateLiveChatTranscript end');
    }

    private void updateCompetitorContract(Map<Id, Account> accountPerdentiMap, Map<String, Account> ndgAccountVincentiMap) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateCompetitorContract start');
        List<Competitor_Contract__c> compContractsToUpdate = new List<Competitor_Contract__c>();
        List<Competitor_Contract__c> compContracts = [
                SELECT Id, Account__c, Account__r.Id, Account__r.NDG__c, Account__r.NDG_Vincente__c
                FROM Competitor_Contract__c
                WHERE Account__c IN :accountPerdentiMap.keySet()
        ];
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateCompetitorContract Competitor_Contract__c (size) Account Perdenti ' + compContracts.size());
        for (Competitor_Contract__c cc : compContracts) {
            System.debug('DIF_Events_ProbabiliDoppi_Batch.updateCompetitorContract Account Perdente ' + cc.Account__r.Id + ' - ' + cc.Account__r.NDG__c);
            if (ndgAccountVincentiMap.get(accountPerdentiMap.get(cc.Account__c).NDG_Vincente__c) != null) {
                Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(cc.Account__c).NDG_Vincente__c);
                System.debug('DIF_Events_ProbabiliDoppi_Batch.updateCompetitorContract Account Vincente ' + accVincente.Id + ' - ' + accVincente.NDG__c);
                Map<DIF_Utility_Log.DataLogs, String> log = DIF_Utility_Log.createMapForLog(eventType, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.AGENCY_CODE_NEW, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_OLD, cc.Account__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_NEW, accVincente.Id);
                log.put(DIF_Utility_Log.DataLogs.NDG_OLD, cc.Account__r.NDG__c);
                log.put(DIF_Utility_Log.DataLogs.NDG_NEW, accVincente.NDG__c);
                cc.Account__c = accVincente.Id;
                DIF_Utility_Log.updateRecord(cc, Datetime.now(), log);
                compContractsToUpdate.add(cc);
            } else {
                System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateCompetitorContract ' + ' Cannot find Account Vincente con NDG ' + cc.Account__r.NDG_Vincente__c);
            }
        }
        if (compContractsToUpdate.size() > 0) {
            this.databaseUpdate(compContractsToUpdate, 'Competitor_Contract__c');
        }
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateCompetitorContract end');
    }

    private void updateCustomerEvent(Map<Id, Account> accountPerdentiMap, Map<String, Account> ndgAccountVincentiMap) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateCustomerEvent start');
        List<Customer_Event__c> customerEventsToUpsert = new List<Customer_Event__c>(); 

        List<Customer_Event__c> customerEvents = [
                SELECT Id, Account__c, Account__r.Id, Account__r.NDG__c, Account__r.NDG_Vincente__c
                FROM Customer_Event__c
                WHERE Account__c IN :accountPerdentiMap.keySet()
        ];
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateCustomerEvent Customer_Event__c (size) Account Perdenti ' + customerEvents.size());
        for (Customer_Event__c ce : customerEvents) {
            System.debug('DIF_Events_ProbabiliDoppi_Batch.updateCustomerEvent Account Perdente ' + ce.Account__r.Id + ' - ' + ce.Account__r.NDG__c);
            if (ndgAccountVincentiMap.get(accountPerdentiMap.get(ce.Account__c).NDG_Vincente__c) != null) {
                Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(ce.Account__c).NDG_Vincente__c);
                System.debug('DIF_Events_ProbabiliDoppi_Batch.updateCustomerEvent Account Vincente ' + accVincente.Id + ' - ' + accVincente.NDG__c);
               // Customer_Event__c newCe = ce.clone(false, true, true, true);
                Map<DIF_Utility_Log.DataLogs, String> log = DIF_Utility_Log.createMapForLog(eventType, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.AGENCY_CODE_NEW, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_OLD, ce.Account__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_NEW, accVincente.Id);
                log.put(DIF_Utility_Log.DataLogs.NDG_OLD, ce.Account__r.NDG__c);
                log.put(DIF_Utility_Log.DataLogs.NDG_NEW, accVincente.NDG__c);
                ce.Account__c = accVincente.Id;
                DIF_Utility_Log.updateRecord(ce, Datetime.now(), log);
               // DIF_Utility_Log.updateRecord(newCe, Datetime.now(), log);
                customerEventsToUpsert.add(ce);
               // customerEventsToUpsert.add(newCe);
            } else {
                System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateCustomerEvent ' + ' Cannot find Account Vincente con NDG ' + ce.Account__r.NDG_Vincente__c);
            }
        }
        if (customerEventsToUpsert.size() > 0) {
            this.databaseUpsert(customerEventsToUpsert, 'Customer_Event__c');
        }
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateCustomerEvent end');
    }

    private void updateLifeEvent(Map<Id, Account> accountPerdentiMap, Map<String, Account> ndgAccountVincentiMap) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateLifeEvent start');
        List<Life_event__c> lifeEventsToUpdate = new List<Life_event__c>();
        List<Life_event__c> lifeEvents = [
                SELECT Id, Account_name__c, Account_name__r.Id, Account_name__r.NDG__c, Account_name__r.NDG_Vincente__c
                FROM Life_event__c
                WHERE Account_name__c IN :accountPerdentiMap.keySet()
        ];
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateLifeEvent Life_event__c (size) Account Perdenti ' + lifeEvents.size());
        for (Life_event__c le : lifeEvents) {
            System.debug('DIF_Events_ProbabiliDoppi_Batch.updateLifeEvent Account Perdente ' + le.Account_name__r.Id + ' - ' + le.Account_name__r.NDG__c);
            if (ndgAccountVincentiMap.get(accountPerdentiMap.get(le.Account_name__c).NDG_Vincente__c) != null) {
                Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(le.Account_name__c).NDG_Vincente__c);
                System.debug('DIF_Events_ProbabiliDoppi_Batch.updateLifeEvent Account Vincente ' + accVincente.Id + ' - ' + accVincente.NDG__c);
                Map<DIF_Utility_Log.DataLogs, String> log = DIF_Utility_Log.createMapForLog(eventType, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.AGENCY_CODE_NEW, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_OLD, le.Account_name__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_NEW, accVincente.Id);
                log.put(DIF_Utility_Log.DataLogs.NDG_OLD, le.Account_name__r.NDG__c);
                log.put(DIF_Utility_Log.DataLogs.NDG_NEW, accVincente.NDG__c);
                le.Account_name__c = accVincente.Id;
                DIF_Utility_Log.updateRecord(le, Datetime.now(), log);
                lifeEventsToUpdate.add(le);
            } else {
                System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateLifeEvent ' + ' Cannot find Account Vincente con NDG ' + le.Account_name__r.NDG_Vincente__c);
            }
        }
        if (lifeEventsToUpdate.size() > 0) {
            this.databaseUpdate(lifeEventsToUpdate, 'Life_event__c');
        }
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateLifeEvent end');
    }

    private void updateIndividualEmailResult(Map<Id, Account> accountPerdentiMap, Map<String, Account> ndgAccountVincentiMap) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateIndividualEmailResult start');
        List<et4ae5__IndividualEmailResult__c> individualEmailsToUpdate = new List<et4ae5__IndividualEmailResult__c>();

        List<et4ae5__IndividualEmailResult__c> individualEmails = [
                SELECT Id, Account__c, Account__r.Id, Account__r.NDG__c, Account__r.NDG_Vincente__c, et4ae5__Contact__c
                FROM et4ae5__IndividualEmailResult__c
                WHERE Account__c IN :accountPerdentiMap.keySet()
        ];
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateIndividualEmailResult et4ae5__IndividualEmailResult__c (size) Account Perdenti ' + individualEmails.size());
        Map<String, Contact> ndgContactVincenti = new Map<String, Contact>();
        List<Contact> contactList = [SELECT Id, Account.NDG__c FROM Contact WHERE AccountId IN :ndgAccountVincentiMap.values()];
        for (Contact c : contactList) {
            ndgContactVincenti.put(c.Account.NDG__c, c);
        }
 
        for (et4ae5__IndividualEmailResult__c ie : individualEmails) {
            System.debug('DIF_Events_ProbabiliDoppi_Batch.updateIndividualEmailResult Account Perdente ' + ie.Account__r.Id + ' - ' + ie.Account__r.NDG__c);
            if (ndgAccountVincentiMap.get(accountPerdentiMap.get(ie.Account__c).NDG_Vincente__c) != null) {
                Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(ie.Account__c).NDG_Vincente__c);
                System.debug('DIF_Events_ProbabiliDoppi_Batch.updateIndividualEmailResult Account Vincente ' + accVincente.Id + ' - ' + accVincente.NDG__c);
                if (ndgContactVincenti.get(accVincente.NDG__c) != null) {
                    Map<DIF_Utility_Log.DataLogs, String> log = DIF_Utility_Log.createMapForLog(eventType, accVincente.AAI_Agency_Reference_Code__c);
                    log.put(DIF_Utility_Log.DataLogs.AGENCY_CODE_NEW, accVincente.AAI_Agency_Reference_Code__c);
                    log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_OLD, ie.Account__c);
                    log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_NEW, accVincente.Id);
                    log.put(DIF_Utility_Log.DataLogs.CONTACT_ID_OLD, ie.et4ae5__Contact__c);
                    log.put(DIF_Utility_Log.DataLogs.CONTACT_ID_NEW, ndgContactVincenti.get(accVincente.NDG__c).Id);
                    log.put(DIF_Utility_Log.DataLogs.NDG_OLD, ie.Account__r.NDG__c);
                    log.put(DIF_Utility_Log.DataLogs.NDG_NEW, accVincente.NDG__c);
                    ie.et4ae5__Contact__c = ndgContactVincenti.get(accVincente.NDG__c).Id;
                    DIF_Utility_Log.updateRecord(ie, Datetime.now(), log);
                    individualEmailsToUpdate.add(ie);
                } else {
                    System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateIndividualEmailResult ' + ' Cannot find Account Vincente (Contact) con NDG ' + ie.Account__r.NDG_Vincente__c);
                }
            } else {
                System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateIndividualEmailResult ' + ' Cannot find Account Vincente con NDG ' + ie.Account__r.NDG_Vincente__c);
            }
        }

        if (individualEmailsToUpdate.size() > 0) {
            this.databaseUpdate(individualEmailsToUpdate, 'IndividualEmailResult__c');
        }
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateIndividualEmailResult end');
    }

    private void updateFeedback(Map<Id, Account> accountPerdentiMap, Map<String, Account> ndgAccountVincentiMap) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateFeedback start');
        List<Feedback__c> feedbacksToUpdate = new List<Feedback__c>();
        List<Feedback__c> feedbacks = [
                SELECT Id, Account__c, Account__r.Id, Account__r.NDG__c, Account__r.NDG_Vincente__c
                FROM Feedback__c
                WHERE Account__c IN :accountPerdentiMap.keySet()
        ];
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateFeedback Feedback__c (size) Account Perdenti ' + feedbacks.size());
        for (Feedback__c fb : feedbacks) {
            System.debug('DIF_Events_ProbabiliDoppi_Batch.updateFeedback Account Perdente ' + fb.Account__r.Id + ' - ' + fb.Account__r.NDG__c);
            if (ndgAccountVincentiMap.get(accountPerdentiMap.get(fb.Account__c).NDG_Vincente__c) != null) {
                Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(fb.Account__c).NDG_Vincente__c);
                System.debug('DIF_Events_ProbabiliDoppi_Batch.updateFeedback Account Vincente ' + accVincente.Id + ' - ' + accVincente.NDG__c);
                Map<DIF_Utility_Log.DataLogs, String> log = DIF_Utility_Log.createMapForLog(eventType, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.AGENCY_CODE_NEW, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_OLD, fb.Account__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_NEW, accVincente.Id);
                log.put(DIF_Utility_Log.DataLogs.NDG_OLD, fb.Account__r.NDG__c);
                log.put(DIF_Utility_Log.DataLogs.NDG_NEW, accVincente.NDG__c);
                fb.Account__c = accVincente.Id;
                DIF_Utility_Log.updateRecord(fb, Datetime.now(), log);
                feedbacksToUpdate.add(fb);
            } else {
                System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateFeedback ' + ' Cannot find Account Vincente con NDG ' + fb.Account__r.NDG_Vincente__c);
            }
        }
        if (feedbacksToUpdate.size() > 0) {
            this.databaseUpdate(feedbacksToUpdate, 'Feedback__c');
        }
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateFeedback end');
    }

    private void updateTask(Map<Id, Account> accountPerdentiMap, Map<String, Account> ndgAccountVincentiMap) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateTask start');
        List<Task> tasksToUpdate = new List<Task>();
        List<Task> tasks = [
                SELECT Id, WhatId
                FROM Task
                WHERE WhatId IN :accountPerdentiMap.keySet()
        ];
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateTask Task (size) Account Perdenti ' + tasks.size());
        for (Task tk : tasks) {
            System.debug('DIF_Events_ProbabiliDoppi_Batch.updateTask Account Perdente ' + tk.WhatId);
            if (ndgAccountVincentiMap.get(accountPerdentiMap.get(tk.WhatId).NDG_Vincente__c) != null) {
                Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(tk.WhatId).NDG_Vincente__c);
                System.debug('DIF_Events_ProbabiliDoppi_Batch.updateTask Account Vincente ' + accVincente.Id + ' - ' + accVincente.NDG__c);
                Map<DIF_Utility_Log.DataLogs, String> log = DIF_Utility_Log.createMapForLog(eventType, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.AGENCY_CODE_NEW, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_OLD, tk.WhatId);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_NEW, accVincente.Id);
                log.put(DIF_Utility_Log.DataLogs.NDG_OLD, accountPerdentiMap.get(tk.WhatId).NDG__c); //NDG perdente
                log.put(DIF_Utility_Log.DataLogs.NDG_NEW, accVincente.NDG__c);
                tk.WhatId = accVincente.Id;
                DIF_Utility_Log.updateRecord(tk, Datetime.now(), log);
                tasksToUpdate.add(tk);
            } else {
                System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateTask ' + ' Cannot find Account Vincente con Id Perdente ' + tk.WhatId);
            }
        }
        if (tasksToUpdate.size() > 0) {
            this.databaseUpdate(tasksToUpdate, 'Task');
        }
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateTask end');
    }

    public void updateEvent(Map<Id, Account> accountPerdentiMap, Map<String, Account> ndgAccountVincentiMap) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateEvent start');
        List<Event> eventsToUpdate = new List<Event>();
        List<Event> events = [
                SELECT Id, WhatId
                FROM Event
                WHERE WhatId IN :accountPerdentiMap.keySet()
        ];
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateEvent Event (size) Account Perdenti ' + events.size());
        for (Event ev : events) {
            System.debug('DIF_Events_ProbabiliDoppi_Batch.updateEvent Account Perdente ' + ev.WhatId);
            if (ndgAccountVincentiMap.get(accountPerdentiMap.get(ev.WhatId).NDG_Vincente__c) != null) {
                Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(ev.WhatId).NDG_Vincente__c);
                System.debug('DIF_Events_ProbabiliDoppi_Batch.updateEvent Account Vincente ' + accVincente.Id + ' - ' + accVincente.NDG__c);
                Map<DIF_Utility_Log.DataLogs, String> log = DIF_Utility_Log.createMapForLog(eventType, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.AGENCY_CODE_NEW, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_OLD, ev.WhatId);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_NEW, accVincente.Id);
                log.put(DIF_Utility_Log.DataLogs.NDG_OLD, accountPerdentiMap.get(ev.WhatId).NDG__c); //NDG perdente
                log.put(DIF_Utility_Log.DataLogs.NDG_NEW, accVincente.NDG__c);
                ev.WhatId = accVincente.Id;
                DIF_Utility_Log.updateRecord(ev, Datetime.now(), log);
                eventsToUpdate.add(ev);
            } else {
                System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateEvent ' + ' Cannot find Account Vincente con Id Perdente ' + ev.WhatId);
            }
        }
        if (eventsToUpdate.size() > 0) {
            this.databaseUpdate(eventsToUpdate, 'Event');
        }
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateEvent end');
    }

    public void updateNoteAndAttachment(Map<Id, Account> accountPerdentiMap, Map<String, Account> ndgAccountVincentiMap) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateNoteAndAttachment start');
        List<Note> notesToInsert = new List<Note>();
        List<Note> notes = [
                SELECT Id, ParentId, Title
                FROM Note
                WHERE ParentId IN :accountPerdentiMap.keySet()
        ];
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateNoteAndAttachment Note (size) Account Perdenti ' + notes.size());
        for (Note nt : notes) {
            System.debug('DIF_Events_ProbabiliDoppi_Batch.updateNoteAndAttachment (Note) Account Perdente ' + nt.ParentId);
            if (ndgAccountVincentiMap.get(accountPerdentiMap.get(nt.ParentId).NDG_Vincente__c) != null) {
                Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(nt.ParentId).NDG_Vincente__c);
                System.debug('DIF_Events_ProbabiliDoppi_Batch.updateNoteAndAttachment (Note) Account Vincente ' + accVincente.Id + ' - ' + accVincente.NDG__c);
                Note newNote = nt.clone(false, true, true, true);
                newNote.ParentId = accVincente.Id;
                notesToInsert.add(newNote);
            } else {
                System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateTask (Note) ' + ' Cannot find Account Vincente con Id Perdente ' + nt.ParentId);
            }
        }
        if (notesToInsert.size() > 0) {
            this.databaseInsert(notesToInsert, 'Note');
        }

        List<Attachment> attachmentsToInsert = new List<Attachment>();
        List<Attachment> attachments = [
                SELECT Id, ParentId, Name, Body
                FROM Attachment
                WHERE ParentId IN :accountPerdentiMap.keySet()
        ];
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateNoteAndAttachment Attachment (size) Account Perdenti ' + attachments.size());
        for (Attachment att : attachments) {
            System.debug('DIF_Events_ProbabiliDoppi_Batch.updateNoteAndAttachment (Attachment) Account Perdente ' + att.ParentId);
            if (ndgAccountVincentiMap.get(accountPerdentiMap.get(att.ParentId).NDG_Vincente__c) != null) {
                Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(att.ParentId).NDG_Vincente__c);
                System.debug('DIF_Events_ProbabiliDoppi_Batch.updateNoteAndAttachment (Attachment) Account Vincente ' + accVincente.Id + ' - ' + accVincente.NDG__c);
                Attachment newAttachment = att.clone(false, true, true, true);
                newAttachment.ParentId = accVincente.Id;
                attachmentsToInsert.add(newAttachment);
            } else {
                System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateNoteAndAttachment (Attachment) ' + ' Cannot find Account Vincente con Id Perdente ' + att.ParentId);
            }
        }
        if (attachmentsToInsert.size() > 0) {
            this.databaseInsert(attachmentsToInsert, 'Attachment');
        }
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateNoteAndAttachment end');
    }

    private void updateOpportunity(Map<Id, Account> accountPerdentiMap, Map<String, Account> ndgAccountVincentiMap) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateOpportunity start');
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        List<Opportunity> opportunities = [
                SELECT Id, AccountId, Account.NDG__c, Account.NDG_Vincente__c
                FROM Opportunity
                WHERE AccountId IN :accountPerdentiMap.keySet()
        ];
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateOpportunity Opportunity (size) Account Perdenti ' + opportunities.size());
        for (Opportunity opp : opportunities) {
            System.debug('DIF_Events_ProbabiliDoppi_Batch.updateOpportunity Account Perdente ' + opp.AccountId + ' - ' + opp.Account.NDG__c);
            if (ndgAccountVincentiMap.get(accountPerdentiMap.get(opp.AccountId).NDG_Vincente__c) != null) {
                Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(opp.AccountId).NDG_Vincente__c);
                System.debug('DIF_Events_ProbabiliDoppi_Batch.updateOpportunity Account Vincente ' + accVincente.Id + ' - ' + accVincente.NDG__c);
                Map<DIF_Utility_Log.DataLogs, String> log = DIF_Utility_Log.createMapForLog(eventType, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.AGENCY_CODE_NEW, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_OLD, opp.AccountId);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_NEW, accVincente.Id);
                log.put(DIF_Utility_Log.DataLogs.NDG_OLD, opp.Account.NDG__c);
                log.put(DIF_Utility_Log.DataLogs.NDG_NEW, accVincente.NDG__c);
                opp.AccountId = accVincente.Id;
                DIF_Utility_Log.updateRecord(opp, Datetime.now(), log);
                opportunitiesToUpdate.add(opp);
            } else {
                System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateOpportunity ' + ' Cannot find Account Vincente con NDG ' + opp.Account.NDG_Vincente__c);
            }

        }
        if (opportunitiesToUpdate.size() > 0) {
            this.databaseUpdate(opportunitiesToUpdate, 'Opportunity');
        }
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateOpportunity end');
    }

	/* 
    private void updateMembroDelNucleo(Map<Id, Account> accountPerdentiMap, Map<String, Account> ndgAccountVincentiMap) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroDelNucleo start');
        List<Nucleo_di_appartenenza__c> nucleiToUpsert = new List<Nucleo_di_appartenenza__c>();
        List<Membro_del_nucleo__c> membriToUpsert = new List<Membro_del_nucleo__c>();
		Map<Id,Nucleo_di_appartenenza__c> perdenteVincenteNucleoMap = new Map<Id,Nucleo_di_appartenenza__c>();
        
        List<Nucleo_di_appartenenza__c> nuclei = new List<Nucleo_di_appartenenza__c>([
                SELECT Id, Referente_principale__c, Referente_principale__r.AAI_Agency_Reference_Code__c, Referente_principale__r.Id, Referente_principale__r.NDG__c, Referente_principale__r.NDG_Vincente__c, RecordTypeId
                FROM Nucleo_di_appartenenza__c
                WHERE Referente_principale__c IN :accountPerdentiMap.keySet()
        ]);
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroDelNucleo Nucleo_di_appartenenza__c (size) Account Perdenti ' + nuclei.size());
        for (Nucleo_di_appartenenza__c na : nuclei) {
            System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroDelNucleo (Nucleo di Appartenenza) Account Perdente ' + na.Referente_principale__r.Id + ' - ' + na.Referente_principale__r.NDG__c);
            if (ndgAccountVincentiMap.get(accountPerdentiMap.get(na.Referente_principale__c).NDG_Vincente__c) != null) {
                Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(na.Referente_principale__c).NDG_Vincente__c);
                System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroDelNucleo (Nucleo di Appartenenza) Account Vincente ' + accVincente.Id + ' - ' + accVincente.NDG__c);
                Nucleo_di_appartenenza__c newNucleo = na.clone(false, true, true, true);

                Map<DIF_Utility_Log.DataLogs, String> log = DIF_Utility_Log.createMapForLog(eventType, this.agencyCode);
                log.put(DIF_Utility_Log.DataLogs.AGENCY_CODE_NEW, na.Referente_principale__r.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_OLD, na.Referente_principale__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_NEW, accVincente.Id);
                log.put(DIF_Utility_Log.DataLogs.NDG_OLD, na.Referente_principale__r.NDG__c);
                log.put(DIF_Utility_Log.DataLogs.NDG_NEW, accVincente.NDG__c);
                newNucleo.Referente_principale__c = accVincente.Id;
                newNucleo.RecordTypeId = na.RecordTypeId;
                DIF_Utility_Log.updateRecord(na, Datetime.now(), log);
                DIF_Utility_Log.updateRecord(newNucleo, Datetime.now(), log);
                nucleiToUpsert.add(na);
                nucleiToUpsert.add(newNucleo);
                
                perdenteVincenteNucleoMap.put(na.Id,newNucleo);
            } else {
                System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateMembroDelNucleo (Nucleo di Appartenenza) ' + ' Cannot find Account Vincente con NDG ' + na.Referente_principale__r.NDG_Vincente__c);
            }
        }
		System.debug('Nuclei to upsert: '+nucleiToUpsert);
        if (nucleiToUpsert.size() > 0) {
            this.databaseUpsert(nucleiToUpsert, 'Nucleo_di_appartenenza__c');
        }
        
        List<Id> accountVincentiIds = new List<Id>();
        for(Account a : ndgAccountVincentiMap.values()){
            accountVincentiIds.add(a.Id);
        }

        List<Membro_del_nucleo__c> membri = [
                SELECT Id, Account_correlato__c, Account_correlato__r.AAI_Agency_Reference_Code__c, Account_correlato__r.Id, Account_correlato__r.NDG__c, Account_correlato__r.NDG_Vincente__c, Nucleo_di_appartenenza__c, RecordTypeId
                FROM Membro_del_nucleo__c
                WHERE Account_correlato__c IN :accountPerdentiMap.keySet() AND Account_correlato__c NOT IN :accountVincentiIds
        ];
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroDelNucleo Membro_del_nucleo__c (size) Account Perdenti ' + membri.size());
        for (Membro_del_nucleo__c mn : membri) { 
            System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroDelNucleo (Membro del Nucleo) Account Perdente ' + mn.Account_correlato__r.Id + ' - ' + mn.Account_correlato__r.NDG__c);
            if (ndgAccountVincentiMap.get(accountPerdentiMap.get(mn.Account_correlato__c).NDG_Vincente__c) != null) {
                Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(mn.Account_correlato__c).NDG_Vincente__c);
                System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroDelNucleo (Membro del Nucleo) Account Vincente ' + accVincente.Id + ' - ' + accVincente.NDG__c);
                Membro_del_nucleo__c newMembro = mn.clone(false, true, true, true);

                Map<DIF_Utility_Log.DataLogs, String> log = DIF_Utility_Log.createMapForLog(eventType, this.agencyCode);
                log.put(DIF_Utility_Log.DataLogs.AGENCY_CODE_NEW, accVincente.AAI_Agency_Reference_Code__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_OLD, mn.Account_correlato__c);
                log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_NEW, accVincente.Id);
                log.put(DIF_Utility_Log.DataLogs.NDG_OLD, mn.Account_correlato__r.NDG__c);
                log.put(DIF_Utility_Log.DataLogs.NDG_NEW, accVincente.NDG__c);
                newMembro.Account_correlato__c = accVincente.Id;
                newMembro.Nucleo_di_appartenenza__c = perdenteVincenteNucleoMap.get(mn.Nucleo_di_appartenenza__c).Id;
                newMembro.RecordTypeId = mn.RecordTypeId;
                DIF_Utility_Log.updateRecord(mn, Datetime.now(), log);
                membriToUpsert.add(mn);
                membriToUpsert.add(newMembro);
            } else {
                System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateMembroDelNucleo (Membro del Nucleo) ' + ' Cannot find Account Vincente con NDG ' + mn.Account_correlato__r.NDG_Vincente__c);
            }
        }
		System.debug('Membri to upsert: '+membriToUpsert);
        if (membriToUpsert.size() > 0) {
            this.databaseUpsert(membriToUpsert, 'Membro_del_Nucleo__c');
        }
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroDelNucleo end');
    }
	*/
    private void updateMembroCampagna(Map<Id, Account> accountPerdentiMap, Map<String, Account> ndgAccountVincentiMap) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroCampagna start');
        Map<String, Contact> ndgContactVincentiMap = new Map<String, Contact>();
        List<Id> contactIdPerdenti = new List<Id>();
        Set<CampaignMember> campaignMembersToUpsert = new Set<CampaignMember>();

        List<Contact> contacts = [
                SELECT Id, AccountId, Account.NDG__c, Account.NDG_Vincente__c
                FROM Contact
                WHERE AccountId IN :accountPerdentiMap.keySet() OR Account.NDG__c IN :ndgAccountVincentiMap.keySet()
        ];
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroCampagna Contact (size) Account Perdenti o Vincenti ' + contacts.size());
        List<Id> contactVincentiIds = new List<Id>();
        for (Contact c : contacts) {
            // Nota: Dato un Account Perdente quindi con NDG_Vincente != null, se l'Account Vincente ha anch'esso NDG_Vincente != null
            // viene considerato lui stesso un Account Perdente e quindi non viene fatto nessun trasferimento a livello di Campaign Member
            if (String.isNotBlank(c.Account.NDG_Vincente__c)) {
                contactIdPerdenti.add(c.Id);
            } else { 
                ndgContactVincentiMap.put(c.Account.NDG__c, c);
                contactVincentiIds.add(c.Id);
            }
        }
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroCampagna Contact (size) Account Perdenti ' + contactIdPerdenti.size());
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroCampagna Contact (size) Account Vincenti ' + contactVincentiIds.size());
        List<CampaignMember> campaignMembers = [
                SELECT Id, Campaign_Name__c, ContactId, Contact.AccountId, Contact.Account.NDG__c, Contact.Account.Id, Contact.Account.NDG_Vincente__c, CampaignId
                FROM CampaignMember
                WHERE ContactId IN :contactIdPerdenti
        ];
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroCampagna CampaignMember (size) Account Perdenti ' + campaignMembers.size());
        List<CampaignMember> campaignMembersVincenti = [
                SELECT Id, ContactId, Contact.AccountId, Contact.Account.NDG__c, Contact.Account.NDG_Vincente__c, CampaignId
                FROM CampaignMember
                WHERE ContactId IN :contactVincentiIds
        ];
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroCampagna CampaignMember (size) Account Vincenti ' + campaignMembersVincenti.size());
        
        Map<Id,List<Id>> campaignsVincentiMap = new Map<Id,List<Id>>();
        for(CampaignMember cmv : campaignMembersVincenti){
            campaignsVincentiMap.put(cmv.ContactId, new List<Id>());
        }
        for(CampaignMember cmv : campaignMembersVincenti){
            List<Id> campgnIdList = campaignsVincentiMap.get(cmv.ContactId);
            campgnIdList.add(cmv.CampaignId);
            campaignsVincentiMap.put(cmv.ContactId,campgnIdList);
        }

        List<Id> campaignsVincentiList = new List<Id>();
        for(Id i : campaignsVincentiMap.keySet()){
            campaignsVincentiList.addAll(campaignsVincentiMap.get(i));
        } 
        
        for (CampaignMember cm : campaignMembers) {
            System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroCampagna Campaign Member ' + cm.Id + ' - ' + cm.Campaign_Name__c);
            System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroCampagna Account Perdente ' + cm.Contact.Account.Id + ' - ' + cm.Contact.Account.NDG__c);
            if (accountPerdentiMap.get(cm.Contact.AccountId) != null && ndgAccountVincentiMap.get(accountPerdentiMap.get(cm.Contact.AccountId).NDG_Vincente__c) != null ) {
                Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(cm.Contact.AccountId).NDG_Vincente__c);
                System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroCampagna Account Vincente ' + accVincente.Id + ' - ' + accVincente.NDG__c);
                System.debug('Campaign Vincenti List contains Campaign already? ' + campaignsVincentiList.contains(cm.CampaignId));
                if (ndgContactVincentiMap.get(accVincente.NDG__c) != null && !campaignsVincentiList.contains(cm.CampaignId)) {
                    CampaignMember newCampaignMember = cm.clone(false,true,true,true);
                    Map<DIF_Utility_Log.DataLogs, String> log = DIF_Utility_Log.createMapForLog(eventType, accVincente.AAI_Agency_Reference_Code__c);
                    log.put(DIF_Utility_Log.DataLogs.AGENCY_CODE_NEW, accVincente.AAI_Agency_Reference_Code__c);
                    log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_OLD, cm.Contact.AccountId); 
                    log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_NEW, accVincente.Id);
                    log.put(DIF_Utility_Log.DataLogs.CONTACT_ID_OLD, cm.ContactId);
                    log.put(DIF_Utility_Log.DataLogs.CONTACT_ID_NEW, ndgContactVincentiMap.get(accVincente.NDG__c).Id);
                    log.put(DIF_Utility_Log.DataLogs.NDG_OLD, cm.Contact.Account.NDG__c);
                    log.put(DIF_Utility_Log.DataLogs.NDG_NEW, accVincente.NDG__c);
                    newCampaignMember.ContactId = ndgContactVincentiMap.get(accVincente.NDG__c).Id;
                    DIF_Utility_Log.updateRecord(cm, Datetime.now(), log);
                    campaignMembersToUpsert.add(cm);
                    campaignMembersToUpsert.add(newCampaignMember);
                } else {
                    if(ndgContactVincentiMap.get(accVincente.NDG__c) != null && contactVincentiIds.contains(String.valueOf(ndgContactVincentiMap.get(accVincente.NDG__c).Id)))
                    System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateMembroCampagna Campaign Member with ContactId '+ndgContactVincentiMap.get(accVincente.NDG__c).Id+' already member of Campaign '+cm.CampaignId);
                    else
                    	System.debug('===> ERROR on Campaign Member. Cannot find Contact related to an Account with NDG__c "' + accountPerdentiMap.get(cm.Contact.AccountId).NDG_Vincente__c + '".');
                }
            } else {
                if( accountPerdentiMap.get(cm.Contact.AccountId) != null)
                    System.debug(LoggingLevel.WARN, 'DIF_Events_ProbabiliDoppi_Batch.updateMembroCampagna ' + ' Cannot find Account Vincente con NDG ' + cm.Contact.Account.NDG_Vincente__c);
                else
                	System.debug('===> ERROR on Campaign Member. Cannot find an Account with NDG__c "' +cm.Contact.Id + '".');

            }
        }
        if (campaignMembersToUpsert.size() > 0) {
            List<CampaignMember> campaignMembersToUpsertList = new List<CampaignMember>();
            campaignMembersToUpsertList.addAll(campaignMembersToUpsert);
            this.databaseUpsert(campaignMembersToUpsertList, 'Campaign Member');
        }
        System.debug('DIF_Events_ProbabiliDoppi_Batch.updateMembroCampagna end');
    } 

    // TODO da CHIEDERE!
    // i campi della seguente query sono dei Booleani, come devono essere settati?
    // come facciamo a sapere qual è il valore da preservare?
    private void cloneFieldsFromOldToNew(Account oldAcc, Account newAcc) {
//newAcc.Age__c = oldAcc.Age__c --> non è scrivibile in quanto campo formula che calcola direttamente dal PersonBirthday
        if (String.isBlank(String.valueOf(newAcc.AnnualRevenue))) {
            newAcc.AnnualRevenue = oldAcc.AnnualRevenue;
        }
        if (String.isBlank(newAcc.Notes__c)) {
            newAcc.Notes__c = oldAcc.Notes__c;
        }
    }

    private void databaseUpsert(List<SObject> sobjectList, String sobjectType) {
        Database.UpsertResult[] urList = Database.upsert(sobjectList, true);
        for (Database.UpsertResult ur : urList) {
            if (ur.isSuccess()) {
                System.debug('===> ' + sobjectType.toUpperCase() + ' updated succesfully: ' + ur.getId());
            } else {
                System.debug('===> Error upserting ' + sobjectType.toUpperCase() + ' ' + ur.getId());
                for (Database.Error err : ur.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug(sobjectType.toUpperCase() + ' fields that affected this error: ' + err.getFields());
                }
            }
        }
    }

    private void databaseUpdate(List<SObject> sobjectList, String sobjectType) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.databaseUpdate start sObject: ' + sobjectType);
        Database.SaveResult[] srList = Database.update(sobjectList, true);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('DIF_Events_ProbabiliDoppi_Batch.databaseUpdate sObject: ' + sobjectType + ' Id: ' + sr.getId() + ' updated');
            } else {
                System.debug(LoggingLevel.WARN, 'WARNING DIF_Events_ProbabiliDoppi_Batch.databaseUpdate sObject: ' + sobjectType + ' Id: ' + sr.getId() + ' update failed');
                for (Database.Error err : sr.getErrors()) {
                    System.debug(LoggingLevel.WARN, 'ERROR detail ' + err.getStatusCode() + ' ' + err.getMessage() + ' ' + err.getFields());
                }
            }
        } 
        System.debug('DIF_Events_ProbabiliDoppi_Batch.databaseUpdate end sObject: ' + sobjectType);
    }

    private void databaseInsert(List<SObject> sobjectList, String sobjectType) {
        System.debug('DIF_Events_ProbabiliDoppi_Batch.databaseInsert start sObject: ' + sobjectType);
        Database.SaveResult[] srList = Database.insert(sobjectList, true);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('DIF_Events_ProbabiliDoppi_Batch.databaseInsert sObject: ' + sobjectType + ' Id: ' + sr.getId() + ' inserted');
            } else { 
                System.debug(LoggingLevel.WARN, 'WARNING DIF_Events_ProbabiliDoppi_Batch.databaseUpdate sObject: ' + sobjectType + ' Id: ' + sr.getId() + ' insert failed');
                for (Database.Error err : sr.getErrors()) {
                    System.debug(LoggingLevel.WARN, 'ERROR detail ' + err.getStatusCode() + ' ' + err.getMessage() + ' ' + err.getFields());
                }
            }
        }
        System.debug('DIF_Events_ProbabiliDoppi_Batch.databaseInsert end sObject: ' + sobjectType);
    }

    /*private void updateDocuments(Map<Id, Account> accountPerdentiMap, Map<String, Account> ndgAccountVincentiMap) {
        List<Document__c> documents = [
                SELECT Id, Account__c, Account__r.NDG__c 
                FROM Document__c 
                WHERE Account__c IN :accountPerdentiMap.keySet()
        ];
 
        if (!documents.isEmpty()) {

            for (Document__c doc : documents) {
                if (accountPerdentiMap.get(doc.Account__c) != null &&
                        ndgAccountVincentiMap.get(accountPerdentiMap.get(doc.Account__c).NDG_Vincente__c) != null) {
                    Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(doc.Account__c).NDG_Vincente__c);
                    Map<DIF_Utility_Log.DataLogs, String> log = DIF_Utility_Log.createMapForLog(eventType, accVincente.AAI_Agency_Reference_Code__c);
                    log.put(DIF_Utility_Log.DataLogs.AGENCY_CODE_NEW, accVincente.AAI_Agency_Reference_Code__c);
                    log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_OLD, doc.Account__c);
                    log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_NEW, accVincente.Id);
                    log.put(DIF_Utility_Log.DataLogs.NDG_OLD, doc.Account__r.NDG__c);
                    log.put(DIF_Utility_Log.DataLogs.NDG_NEW, accVincente.NDG__c);
                    doc.TECH_NDG__c = accVincente.NDG__c;
                    doc.TECH_CF_Piva__c = accVincente.Fiscal_ID__c;
                    doc.Account__c = accVincente.Id;
                }
            }

            this.databaseUpdate(documents, 'Document__c');
        }
    }*/

    private void updateMassiveCommunications(Map<Id, Account> accountPerdentiMap, Map<String, Account> ndgAccountVincentiMap) {
        List<Massive_Communication__c> communications = [
                SELECT Id, Account__c, Account__r.NDG__c
                FROM Massive_Communication__c
                WHERE Account__c IN :accountPerdentiMap.keySet()
        ];

        if (!communications.isEmpty()) {

            Set<Id> accountIds = new Set<Id>();
            for (Account a : ndgAccountVincentiMap.values()) {
                accountIds.add(a.Id);
            }

            Map<Id, Contact> contactByAccountId = new Map<Id, Contact>();
            List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds];
            for (Contact c : contacts) {
                contactByAccountId.put(c.AccountId, c);
            }
            


            for (Massive_Communication__c mc : communications) {
                if (accountPerdentiMap.get(mc.Account__c) != null &&
                        ndgAccountVincentiMap.get(accountPerdentiMap.get(mc.Account__c).NDG_Vincente__c) != null) {
                    Account accVincente = ndgAccountVincentiMap.get(accountPerdentiMap.get(mc.Account__c).NDG_Vincente__c);
                    Map<DIF_Utility_Log.DataLogs, String> log = DIF_Utility_Log.createMapForLog(eventType, accVincente.AAI_Agency_Reference_Code__c);
                    log.put(DIF_Utility_Log.DataLogs.AGENCY_CODE_NEW, accVincente.AAI_Agency_Reference_Code__c);
                    log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_OLD, mc.Account__c);
                    log.put(DIF_Utility_Log.DataLogs.ACCOUNT_ID_NEW, accVincente.Id);
                    log.put(DIF_Utility_Log.DataLogs.NDG_OLD, mc.Account__r.NDG__c);
                    log.put(DIF_Utility_Log.DataLogs.NDG_NEW, accVincente.NDG__c); 
                    mc.Account__c = accVincente.Id;
                    mc.TECH_CF_Piva__c = accVincente.Fiscal_ID__c;
                    mc.TECH_NDG__c = accVincente.NDG__c;
                }

                if (contactByAccountId.containsKey(mc.Account__c)) {
                    mc.Contact__c = contactByAccountId.get(mc.Account__c).Id;
                }
            }

            this.databaseUpdate(communications, 'Massive_Communication__c');
        }
    }
}
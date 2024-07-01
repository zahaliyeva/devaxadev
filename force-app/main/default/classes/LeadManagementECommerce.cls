/**
LeadManagementECommerce - Classe per la gestione del lead nel flusso eCommerce
CreatedBy - Nicolò Torreggiani 03/10/2018
*/
public without sharing class LeadManagementECommerce {
    
    private static final String RICHIEDI_APPUNTAMENTO = 'Richiedi appuntamento';
    
    private static Map<String, MappingASA__c> mapAsaSettings;
    private static Map<String, MappingSottoASA__c> mapSubAsaSettings;
    
    public static Boolean richiediAppuntamento(){
        return true;
    }
    
    public static WS_REST_eCommerce_Wrapper.DeduplicateObject deduplicateLead(List<WS_REST_eCommerce_Wrapper> request){
        
        System.debug(' ===> input request: ' + request);
        
        Boolean error500 = false;
        
        WS_REST_eCommerce_Wrapper.DeduplicateObject ret = new WS_REST_eCommerce_Wrapper.DeduplicateObject();
        WS_REST_eCommerce_Wrapper.Response response = new WS_REST_eCommerce_Wrapper.Response();
        List<Lead> retListLeads = new List<Lead>();
        
        Map<String,Integer> mappingStepNameStepNumber = new Map<String,Integer>();
        Map<String,Boolean> mappingStepNameisDispositiveAction = new Map<String,Boolean>();
        List <LeadECommerce_Setting__mdt> stepModelSettings = new List <LeadECommerce_Setting__mdt>();
        
        String leadIdStr = '';
        
        stepModelSettings = [SELECT Id, StepName__c, Step__c, isAzioneDispositiva__c FROM LeadECommerce_Setting__mdt WHERE DeveloperName LIKE '%Step%' ]; // NOPMD  Fix CRUD violation
        
        if(stepModelSettings == null){
            System.debug(' ===> Error retrieving step model custom metadata');
            response.UserId = request[0].Portals.SessionId;
            response.StatusCode = '500';
            response.StatusMessage = 'Internal Server Error - Error retrieving step model custom settings';
            response.Timestamp = System.now();
            error500 = true;
        }
        
        for(LeadECommerce_Setting__mdt ls: stepModelSettings){
            mappingStepNameStepNumber.put(ls.StepName__c.toLowerCase(),Integer.valueOf(ls.Step__c));
            mappingStepNameisDispositiveAction.put(ls.StepName__c.toLowerCase(),ls.isAzioneDispositiva__c);
        }
        
        System.debug('mappingStepNameStepNumber: ' + mappingStepNameStepNumber);
        System.debug('mappingStepNameisDispositiveAction: ' + mappingStepNameisDispositiveAction);
        
        //custom metedata che contiene l'intervallo temporale di deduplica dati
        Decimal deduplicationSettings = [SELECT Id, Deduplication_Period__c FROM LeadECommerce_Setting__mdt WHERE DeveloperName LIKE '%Deduplication%' LIMIT 1].Deduplication_Period__c;
        
        if(deduplicationSettings == null){
            System.debug(' ===> Error retrieving deduplication custom metadata');
            response.UserId = request[0].Portals.SessionId;
            response.StatusCode = '500';
            response.StatusMessage = 'Internal Server Error - Error retrieving step model custom settings';
            response.Timestamp = System.now();
            error500 = true;
        }
        
        //for(LeadECommerce_Setting__mdt ls: stepModelSettings){
        
        //		mappingStepNameStepNumber.put(ls.StepName__c.toLowerCase(),Integer.valueOf(ls.Step__c));
        //		mappingStepNameisDispositiveAction.put(ls.StepName__c.toLowerCase(),ls.isAzioneDispositiva__c);
        //}
        
        //System.debug('mappingStepNameStepNumber: ' + mappingStepNameStepNumber);
        //System.debug('mappingStepNameisDispositiveAction: ' + mappingStepNameisDispositiveAction);
        
        //***** SETUP LIMITI *****
        Id leadECommerceRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'eCommerce' AND SobjectType = 'Lead'].Id;
        if(leadECommerceRecordTypeId == null){
            System.debug(' ===> Error retrieving lead ecommerce record type');
            response.UserId = request[0].Portals.SessionId;
            response.StatusCode = '500';
            response.StatusMessage = 'Internal Server Error - Error retrieving lead ecommerce record type';
            response.Timestamp = System.now();
            error500 = true;
        }
        
        List<String> sessionIds = new List<String>();
        List<String> firstName = new List<String>();
        List<String> lastName = new List<String>();
        List<String> cap = new List<String>();
        List<String> email = new List<String>();
        List<String> productName = new List<String>();
        
        List<String> listLeadsFiscalCode = new List<String>();
        List<String> listLeadsCompany = new List<String>();
        List<String> listLeadsPIVA = new List<String>();
        List<String> listLeadsNameLastName = new List<String>();
        
        for(WS_REST_eCommerce_Wrapper req :  request){
            req.FirstName = req.FirstName == null? null : req.FirstName.trim();
            req.LastName = req.LastName == null ? null : req.LastName.trim();
            sessionIds.add(req.Portals.SessionId);
            firstName.add(req.FirstName);
            lastName.add(req.LastName);
            cap.add(req.PostalCode);
            email.add(req.Email);
            productName.add(req.Portals.ProductName);
            
            if(req.FiscalCode != null && req.FiscalCode != ''){
                listLeadsFiscalCode.add(req.FiscalCode);
            }
            else if(req.Company != null && req.Company != ''){
                listLeadsCompany.add(req.Company);
            }
            else if(req.VATNumber != null && req.VATNumber != ''){
                listLeadsPIVA.add(req.VATNumber);
            }
            else if(req.FirstName != null && req.FirstName != '' && req.LastName != null && req.LastName != ''){
                listLeadsNameLastName.add(req.FirstName + ' ' + req.LastName);
            }
        }
        
        Id quotationRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'eCommerce' AND SobjectType = 'Quotazione__c'].Id;
        if(quotationRecordTypeId == null){
            System.debug(' ===> Error retrieving quotation record type');
            response.UserId = request[0].Portals.SessionId;
            response.StatusCode = '500';
            response.StatusMessage = 'Internal Server Error - Error retrieving quotation record type';
            response.Timestamp = System.now();
            error500 = true;
        }
        
        List<Quotazione__c> allQuestionsFromSession = [SELECT Id, ID_Session__c, Lead__c, Lead_Step_Status__c FROM Quotazione__c WHERE ID_Session__c IN :sessionIds];
        System.debug(' ===> allQuestionsFromSession: ' + allQuestionsFromSession);
        Set<Id> leadIds = new Set<Id>();
        Map<String, Quotazione__c> quotationSessionMap = new Map<String, Quotazione__c>();
        Map<Id, Set<String>> quotationForLead = new Map<Id, Set<String>>();
        for(Quotazione__c q : allQuestionsFromSession){
            leadIds.add(q.Lead__c);
            quotationSessionMap.put(q.ID_Session__c, q);
        }
        
        List<Quotazione__c> allQuestionsFromSessionToLead = [SELECT Id, ID_Session__c, Lead__c, Lead_Step_Status__c FROM Quotazione__c WHERE Lead__c IN :leadIds];
        for(Quotazione__c q : allQuestionsFromSessionToLead){
            
            if(!quotationForLead.containsKey(q.Lead__c)){
                System.debug(' ===> New Lead__c');
                Set<String> sId = new Set<String>();
                sId.add(q.ID_Session__c);
                quotationForLead.put(q.Lead__c, sId);
            } else {
                System.debug(' ===> New Lead__c');
                Set<String> sId = quotationForLead.get(q.Lead__c);
                sId.add(q.ID_Session__c);
                quotationForLead.put(q.Lead__c, sId);
            }			
        }
        
        
        System.debug(' ===> lead ids: ' + leadIds);
        System.debug(' ===> listLeadsFiscalCode: ' + listLeadsFiscalCode);
        System.debug(' ===> listLeadsCompany: ' + listLeadsCompany);
        System.debug(' ===> listLeadsPIVA: ' + listLeadsPIVA);
        System.debug(' ===> listLeadsNameLastName: ' + listLeadsNameLastName);
        Map<Id, Lead> leadsFromQuotation = new Map<Id, Lead>([SELECT Id, Company, Phone, Email, Dettaglio__c, Agency_Code__c, Street, PostalCode, City, Landing_Page__c, State_Code_Fraud__c, Notes__c, CountryCode, StateCode, Lead_Birthdate__c, Fiscal_ID__c, AAI_Partita_IVA__c, Gender__c, Gi_cliente_AXA__c,  Gi_cliente_eCommerce__c, Birth_Place__c, Birth_State__c, TECH_NDG__c, TECH_Company__c, LeadSource, TECH_Send_Email_Notification__c, Convenzione__c, Provenienza_Campagne_Agenti__c, Codice_Sub_Agenzia__c, ID_Session__c, Commercial_Activity_Consensus__c, CIF_Privacy_2__c, CIF_Privacy_3__c, CIF_Privacy_4__c, CIF_Privacy_5__c, Numero_quotazioni__c FROM Lead WHERE Id IN :leadIds]);
        List<Lead> leadFromDeduplicationData = [SELECT Id, FirstName, LastName, CreatedDate, Numero_quotazioni__c, Company, Phone, Email, Dettaglio__c, Agency_Code__c, Street, PostalCode, Prodotto__c, City, Landing_Page__c, State_Code_Fraud__c, Notes__c, CountryCode, StateCode, Lead_Birthdate__c, Fiscal_ID__c, AAI_Partita_IVA__c, Gender__c, Gi_cliente_AXA__c,  Gi_cliente_eCommerce__c, Birth_Place__c, Birth_State__c, TECH_NDG__c, TECH_Company__c, LeadSource, TECH_Send_Email_Notification__c, Convenzione__c, Provenienza_Campagne_Agenti__c, Codice_Sub_Agenzia__c, ID_Session__c, Commercial_Activity_Consensus__c, CIF_Privacy_2__c, CIF_Privacy_3__c, CIF_Privacy_4__c, CIF_Privacy_5__c FROM Lead WHERE FirstName = :firstName AND LastName = :lastName AND PostalCode = :cap AND Email = :email AND Prodotto__c = :productName ORDER BY CreatedDate DESC];
        List<InsurancePolicy__c> policiesForDeduplication = new List<InsurancePolicy__c>();
        policiesForDeduplication = [SELECT Id, CUID__c, CUID__r.Id, CUID__r.AAI_Codice_fiscale__c, CUID__r.AAI_Partita_IVA__c, CUID__r.FirstName, CUID__r.LastName, CUID__r.Name, Income_Date__c // NOPMD  Fix CRUD violation
                                    FROM InsurancePolicy__c
                                    WHERE  (TECH_Company__c = 'AAI') AND
                                    (( CUID__r.AAI_Codice_Fiscale__c IN :listLeadsFiscalCode OR CUID__r.AAI_Partita_IVA__c IN :listLeadsFiscalCode  ) OR
                                     (CUID__r.Name IN :listLeadsNameLastName) OR
                                     (CUID__r.AAI_Partita_IVA__c IN :listLeadsPIVA)  OR
                                     (CUID__r.Name IN :listLeadsCompany)) ];
        
        Map<String,InsurancePolicy__c> mappingNamePolicies = new Map<String,InsurancePolicy__c>();								   
        Map<String,InsurancePolicy__c> mappingCFPolicies = new Map<String,InsurancePolicy__c>();
        Map<String,InsurancePolicy__c> mappingPIVAPolicies = new Map<String,InsurancePolicy__c>();
        Map<String,InsurancePolicy__c> mappingCompanyPolicies = new Map<String,InsurancePolicy__c>();
        
        for(InsurancePolicy__c polizza : policiesForDeduplication){
            if (polizza.Income_Date__c != null) {
                mappingCFPolicies.put(polizza.CUID__r.AAI_Codice_fiscale__c, polizza);
                if (polizza.CUID__r.Name != null) {
                    mappingNamePolicies.put(polizza.CUID__r.Name.toUpperCase(), polizza);
                    mappingCompanyPolicies.put(polizza.CUID__r.Name.toUpperCase(), polizza);
                }
                mappingPIVAPolicies.put(polizza.CUID__r.AAI_Partita_IVA__c, polizza);
            }
        }
        
        // ASA e SUB-ASA
        List<MappingASA__c> asaSettings = MappingASA__c.getAll().values();
        mapAsaSettings = new Map<String, MappingASA__c>();
        List<MappingSottoASA__c> subAsaSettings = MappingSottoASA__c.getAll().values();
        mapSubAsaSettings = new Map<String, MappingSottoASA__c>();
        for(MappingASA__c asa : asaSettings){
            mapAsaSettings.put(asa.ASA__c.toLowerCase(),asa);
        }
        for(MappingSottoASA__c subAsa : subAsaSettings){
            mapSubAsaSettings.put(subAsa.Sotto_ASA__c.toLowerCase(),subAsa);
        }
        //***** SETUP LIMITI *****
        
        List<Lead> leadToInsert = new List<Lead>();
        List<Quotazione__c> quotationToInsert = new List<Quotazione__c>();
        Map<Quotazione__c, Lead> mappingQuotationToInsertLead = new Map<Quotazione__c, Lead>();
        Map<Quotazione__c, Lead> mappingQuotationToUpdateLead = new Map<Quotazione__c, Lead>();
        List<Lead> leadToUpdate = new List<Lead>();
        List<Lead> leadToUpdateNQuotation = new List<Lead>();		
        List<Quotazione__c> quotationToUpdate = new List<Quotazione__c>();
        
        if(!error500){
            for(WS_REST_eCommerce_Wrapper req : request){
                WS_REST_eCommerce_Wrapper.Portals portals = req.Portals;
                WS_REST_eCommerce_Wrapper.Quotations quotations = req.Quotations;
                WS_REST_eCommerce_Wrapper.Consensus consensus = req.Consensus;
                WS_REST_eCommerce_Wrapper.GoodFactors[] goodFactors = quotations.GoodFactors;
                WS_REST_eCommerce_Wrapper.Warranties[] warranties = quotations.Warranties;
                
                DateTime quotationTimestamp = quotations.QuotationTimestamp;
                
                if(portals.AgencyCode != null){
                    while(portals.AgencyCode.length()<6){
                        portals.AgencyCode = '0' + portals.AgencyCode;
                    }
                }
                
                Boolean isCustomer = false;
                //INIZIO PROCESSO DEDUPLICA
                /** metti mappa **/
                System.debug(' ===> mappingCFPolicies: ' + mappingCFPolicies);
                System.debug(' ===> CF: ' + req.FiscalCode);				
                if(req.FiscalCode != null && mappingCFPolicies.containsKey(req.FiscalCode.toUpperCase())){
                    isCustomer = true;
                }
                System.debug(' ===> mappingNamePolicies: ' + mappingNamePolicies);
                System.debug(' ===> Name: ' + req.FirstName + ' ' + req.LastName);				
                String name = req.FirstName + ' ' + req.LastName;
                if(req.FirstName != null && req.LastName != null &&  req.FiscalCode == null && mappingNamePolicies.containsKey(name.toUpperCase())){
                    isCustomer = true;
                }
                System.debug(' ===> mappingCompanyPolicies: ' + mappingCompanyPolicies);
                System.debug(' ===> Company: ' + req.Company);				
                if(req.Company != null && mappingCompanyPolicies.containsKey(req.Company.toUpperCase())){
                    isCustomer = true;
                }
                System.debug(' ===> mappingPIVAPolicies: ' + mappingPIVAPolicies);
                System.debug(' ===> VAT number: ' + req.VATNumber);				
                if(req.VATNumber != null && mappingPIVAPolicies.containsKey(req.VATNumber)){
                    isCustomer = true;
                }
                /**
                if(req.AlreadyCustomer != null &&
                !isCustomer &&
                ('salva preventivo'.equalsIgnoreCase(portals.LeadStepStatus) || 'inizia pagamento'.equalsIgnoreCase(portals.LeadStepStatus))){
                isCustomer = req.AlreadyCustomer;
                }**/
                
                //Non ho trovato una quotazione CRM con stessi idSession
                if(!quotationSessionMap.containsKey(req.Portals.SessionId)){				
                    
                    if(checkDeduplicationData(req.FirstName, req.LastName, req.Company, req.PostalCode, req.Email, portals.ProductName)){
                        
                        System.debug(' ===> Deduplication data ok!');
                        
                        //Creo nuovo Lead con quotazione associata
                        Lead newLead = createNewLead(req, leadECommerceRecordTypeId, isCustomer);			
                        Quotazione__c newQuotation = createNewQuotation(req, quotationRecordTypeId);
                        
                        List<Lead> oldLeads = checkExistingLead(req.FirstName, req.LastName, req.PostalCode, req.Email, portals.ProductName, portals.LandingPage, leadFromDeduplicationData);
                        if(!oldLeads.isEmpty()){	
                            Lead oldLead = oldLeads[0];
                            System.debug(' ===> Lead esistente: ' + oldLead);
                            if(checkDaysBeetweenLeads(oldLead, deduplicationSettings)){
                                System.debug(' ===> Interno orizzonte di deduplica');
                                if(RICHIEDI_APPUNTAMENTO.equalsIgnoreCase(portals.LeadStepStatus)){
                                    System.debug(' ===> Request richiedi appuntamento');
                                    if(RICHIEDI_APPUNTAMENTO.equalsIgnoreCase(oldLead.Dettaglio__c)){	
                                        System.debug(' ===> Old lead richiedi appuntamento');
                                        leadToInsert.add(newLead);
                                        mappingQuotationToInsertLead.put(newQuotation, newLead);
                                    } else {
                                        if(mappingStepNameStepNumber.get((portals.LeadStepStatus).toLowerCase()) >= mappingStepNameStepNumber.get((oldLead.Dettaglio__c).toLowerCase())){
                                            System.debug(' ===> Old lead stato precedente');
                                            newQuotation.Lead__c = oldLead.Id;						
                                            oldLead = updateOldLead(oldLead, req, isCustomer);
                                            if(oldLead.Numero_quotazioni__c == null){									
                                                oldLead.Numero_quotazioni__c = 1;
                                            } else {
                                                oldLead.Numero_quotazioni__c = oldLead.Numero_quotazioni__c+1;
                                            }
                                            oldLead.Data_ultima_quotazione__c = quotationTimestamp;
                                            leadToUpdate.add(oldLead);
                                            mappingQuotationToInsertLead.put(newQuotation, oldLead);
                                        } else {
                                            System.debug(' ===> Old lead stato avanzato');
                                            leadToInsert.add(newLead);
                                            mappingQuotationToInsertLead.put(newQuotation, newLead);
                                        }
                                    }
                                } else {
                                    System.debug(' ===> Non richiedi appuntamento');
                                    // Lo stato della nuova quotazione non è "Richiedi Appuntamento"
                                    if(mappingStepNameStepNumber.get((portals.LeadStepStatus).toLowerCase()) >= mappingStepNameStepNumber.get((oldLead.Dettaglio__c).toLowerCase())){
                                        if(RICHIEDI_APPUNTAMENTO.equalsIgnoreCase(oldLead.Dettaglio__c)){									
                                            newLead.Numero_quotazioni__c = 1;
                                            leadToInsert.add(newLead);
                                            mappingQuotationToInsertLead.put(newQuotation, newLead);
                                        } else {				
                                            System.debug(' ===> Non richiedi appuntamento lo stato del lead "vecchio"');
                                            newQuotation.Lead__c = oldLead.Id;											
                                            oldLead = updateOldLead(oldLead, req, isCustomer);
                                            if(oldLead.Numero_quotazioni__c == null){									
                                                oldLead.Numero_quotazioni__c = 1;
                                            } else {
                                                oldLead.Numero_quotazioni__c = oldLead.Numero_quotazioni__c+1;
                                            }
                                            oldLead.Data_ultima_quotazione__c = quotationTimestamp;
                                            leadToUpdate.add(oldLead);
                                            mappingQuotationToInsertLead.put(newQuotation, oldLead);
                                        }
                                    } else {
                                        System.debug(' ===> Lo stato della nuova quotazione non è successivo a quello del Lead pre-esistente. Aggiungo nuova quotazione e mi fermo.');
                                        // Lo stato della nuova quotazione non è successivo a quello del Lead pre-esistente. Aggiungo nuova quotazione e mi fermo.
                                        newQuotation.Lead__c = oldLead.Id;
                                        if(oldLead.Numero_quotazioni__c == null){									
                                            oldLead.Numero_quotazioni__c = 1;
                                        } else {
                                            oldLead.Numero_quotazioni__c = oldLead.Numero_quotazioni__c+1;
                                        }
                                        if(portals.LeadStepStatus.equalsIgnoreCase('Salva preventivo') || 
                                           portals.LeadStepStatus.equalsIgnoreCase('KO finale banca')){
                                               oldLead.TECH_Send_Email_Notification__c = true;
                                           }
                                        leadToUpdateNQuotation.add(oldLead);
                                        mappingQuotationToInsertLead.put(newQuotation, oldLead);
                                    }
                                }					
                            } else {
                                System.debug(' ===> Il Lead è stato creato oltre l\'orizzonte di deduplica');
                                //Il Lead è stato creato oltre l'orizzonte di deduplica	
                                leadToInsert.add(newLead);
                                mappingQuotationToInsertLead.put(newQuotation, newLead);
                            }
                        } else {
                            System.debug(' ===> Non esiste nessun lead con la medesima chiave di deduplica');
                            //Non esiste nessun lead con la medesima chiave di deduplica	
                            leadToInsert.add(newLead);
                            mappingQuotationToInsertLead.put(newQuotation, newLead);
                        }
                    } else {
                        System.debug(' ===> Bad Request - No session Id found and mandatory lead\'s field missing');
                        response.UserId = request[0].Portals.SessionId;
                        response.LeadId = null;
                        response.StatusCode = '400';
                        response.StatusMessage = 'Bad Request - No session Id found and mandatory lead\'s field missing';
                        response.Timestamp = System.now();        
                        
                        ret.response = response;
                        ret.leads = retListLeads;
                        
                        return ret;
                    }
                } else {
                    
                    Quotazione__c quotation = quotationSessionMap.get(req.Portals.SessionId);
                    System.debug(' ====> quotation: ' + quotation);
                    String actualQuotationStep = quotation.Lead_Step_Status__c;
                    
                    //Aggiorno la quotazione relativa all'id di sessione
                    /**if('Visualizza quotazione'.equalsIgnoreCase(portals.LeadStepStatus) ||
                    'Salva quotazione'.equalsIgnoreCase(portals.LeadStepStatus) ||
                    'Richiedi appuntamento'.equalsIgnoreCase(portals.LeadStepStatus) ||
                    'Acquista'.equalsIgnoreCase(portals.LeadStepStatus) ||
                    'Salva preventivo'.equalsIgnoreCase(portals.LeadStepStatus)){
                    quotation = updateQuotation(quotation, req);
                    }**/
                    quotation = updateQuotation(quotation, req);
                    Lead oldLead = leadsFromQuotation.get(quotation.Lead__c);
                    
                    Set<String> uniqueSessionIdFromLeadId = quotationForLead.get(quotation.Lead__c);
                    System.debug(' ===> quotationForLead: ' + quotationForLead);
                    System.debug(' ===> uniqueSessionIdFromLeadId: ' + uniqueSessionIdFromLeadId);
                    
                    
                    if(uniqueSessionIdFromLeadId.size() == 1){
                        System.debug(' ===> old lead: ' + oldLead);
                        System.debug(' ===> portals: ' + portals);
                        System.debug(' ===> mappingStepNameisDispositiveAction: ' + mappingStepNameisDispositiveAction);
                        System.debug(' ===> mappingStepNameStepNumber: ' + mappingStepNameStepNumber);
                        System.debug(' ===> portals.LeadStepStatus: ' + portals.LeadStepStatus);
                        //Esiste una sola quotazione associata al lead
                        System.debug(' ===> mappingStepNameStepNumber.get(oldLead.Dettaglio__c) '+ mappingStepNameStepNumber.get((oldLead.Dettaglio__c).toLowerCase()));
                        System.debug(' ===> mappingStepNameisDispositiveAction.get(oldLead.Dettaglio__c) '+ mappingStepNameisDispositiveAction.get((oldLead.Dettaglio__c).toLowerCase()));
                        System.debug(' ===> mappingStepNameStepNumber.get(portals.LeadStepStatus) '+ mappingStepNameStepNumber.get((portals.LeadStepStatus).toLowerCase()));
                        System.debug(' ===> mappingStepNameStepNumber.get(oldLead.Dettaglio__c) '+ mappingStepNameStepNumber.get((oldLead.Dettaglio__c).toLowerCase()));
                        if((mappingStepNameisDispositiveAction.get((oldLead.Dettaglio__c).toLowerCase()) && (mappingStepNameStepNumber.get((portals.LeadStepStatus).toLowerCase()) >= mappingStepNameStepNumber.get((oldLead.Dettaglio__c).toLowerCase()))) ||
                           !mappingStepNameisDispositiveAction.get((oldLead.Dettaglio__c).toLowerCase())){
                               System.debug(' ===> Lo stato della nuova quotazione è successivo a quello del Lead pre-esistente e non è dispositivo.');
                               oldLead = updateOldLead(oldLead, req, isCustomer);
                               leadToUpdate.add(oldLead);
                               quotationToUpdate.add(quotation);
                           } else {
                               leadIdStr = oldLead.Id;
                           }
                    } else {					
                        
                        //Esistono più quotazioni associate al lead. Procedo con la deduplica a livello di step.
                        if(RICHIEDI_APPUNTAMENTO.equalsIgnoreCase(portals.LeadStepStatus)){
                            System.debug(' ===> Esistono più quotazioni associate al lead. Procedo con la deduplica a livello di step.');
                            //Lo step della nuova quotazione è Richiedi Appuntamento
                            if(RICHIEDI_APPUNTAMENTO.equalsIgnoreCase(oldLead.Dettaglio__c)){
                                System.debug(' ===> Lo step della nuova quotazione è Richiedi Appuntamento');
                                //Lo step della quotazione attualmente associata al Lead è Richiedi Appuntamento.
                                //Creo nuovo Lead con quotazione associata
                                Lead newLead = createNewLead(req, leadECommerceRecordTypeId, isCustomer);
                                oldLead.Numero_quotazioni__c = oldLead.Numero_quotazioni__c - 1;
                                leadToInsert.add(newLead);
                                leadToUpdate.add(oldLead);
                                mappingQuotationToUpdateLead.put(quotation, newLead);
                            } else {
                                System.debug(' ===> Lo step della quotazione attualmente associata al Lead non è Richiedi Appuntamento. Aggiorno semplcemente lo step del Lead.');
                                //Lo step della quotazione attualmente associata al Lead non è Richiedi Appuntamento. Aggiorno semplcemente lo step del Lead.
                                if(mappingStepNameStepNumber.get((portals.LeadStepStatus).toLowerCase()) >= mappingStepNameStepNumber.get((oldLead.Dettaglio__c).toLowerCase())){
                                    System.debug(' ===> Lo step associato alla nuova quotazione è successivo allo step del Lead pre-esistente.');
                                    //Lo step associato alla nuova quotazione è successivo allo step del Lead pre-esistente.
                                    System.debug(' ===> Lo stato della nuova quotazione è successivo a quello del Lead pre-esistente e non è dispositivo.');
                                    System.debug(' ===> old lead: ' + oldLead);
                                    System.debug(' ===> portals: ' + portals);
                                    oldLead.Data_ultima_quotazione__c = quotationTimestamp;
                                    oldLead = updateOldLead(oldLead, req, isCustomer);
                                    leadToUpdate.add(oldLead);
                                    quotationToUpdate.add(quotation);
                                } else {
                                    System.debug(' ===> Creo nuovo Lead con quotazione associata');
                                    //Creo nuovo Lead con quotazione associata
                                    Lead newLead = createNewLead(req, leadECommerceRecordTypeId, isCustomer);
                                    oldLead.Numero_quotazioni__c = oldLead.Numero_quotazioni__c - 1;
                                    leadToInsert.add(newLead);
                                    leadToUpdate.add(oldLead);
                                    mappingQuotationToUpdateLead.put(quotation, newLead);
                                }
                            }
                        } else {
                            System.debug(' ===> Lo step della nuova quotazione non è Richiedi Appuntamento');
                            System.debug(' ===> mappingStepNameStepNumber.get(portals.LeadStepStatus): ' + mappingStepNameStepNumber.get(portals.LeadStepStatus.toLowerCase()));
                            System.debug(' ===> oldLead: ' + oldLead);
                            System.debug(' ===> mappingStepNameStepNumber.get(oldLead.Dettaglio__c): ' + mappingStepNameStepNumber.get(oldLead.Dettaglio__c.toLowerCase()));
                            //Lo step della nuova quotazione non è Richiedi Appuntamento					
                            if(mappingStepNameStepNumber.get(portals.LeadStepStatus.toLowerCase()) >= mappingStepNameStepNumber.get(oldLead.Dettaglio__c.toLowerCase())){
                                System.debug(' ===> Lo step associato alla nuova quotazione è successivo allo step del Lead pre-esistente.');					
                                if(RICHIEDI_APPUNTAMENTO.equalsIgnoreCase(oldLead.Dettaglio__c)){
                                    System.debug(' ===> Creo nuovo Lead con quotazione associata');
                                    //Creo nuovo Lead con quotazione associata
                                    Lead newLead = createNewLead(req, leadECommerceRecordTypeId, isCustomer);
                                    oldLead.Numero_quotazioni__c = oldLead.Numero_quotazioni__c - 1;
                                    leadToInsert.add(newLead);
                                    leadToUpdate.add(oldLead);
                                    mappingQuotationToUpdateLead.put(quotation, newLead);
                                } else {
                                    System.debug(' ===> Lo step del lead non è "Richiedi appuntamento"');
                                    //Lo step del lead non è "Richiedi appuntamento"								
                                    System.debug(' ===> Lo stato della nuova quotazione è successivo a quello del Lead pre-esistente e non è dispositivo.');
                                    oldLead.Data_ultima_quotazione__c = quotationTimestamp;
                                    oldLead = updateOldLead(oldLead, req, isCustomer);
                                    leadToUpdate.add(oldLead);
                                    quotationToUpdate.add(quotation);
                                }
                            } else {
                                System.debug(' ===> portals.LeadStepStatus: ' + portals.LeadStepStatus);
                                //Esiste una sola quotazione associata al lead
                                System.debug(' ===> mappingStepNameisDispositiveAction.get(portals.LeadStepStatus) '+ mappingStepNameisDispositiveAction.get((portals.LeadStepStatus).toLowerCase()));
                                System.debug(' ===> mappingStepNameStepNumber.get(portals.LeadStepStatus) '+ mappingStepNameStepNumber.get((portals.LeadStepStatus).toLowerCase()));
                                System.debug(' ===> mappingStepNameStepNumber.get(oldLead.Dettaglio__c) '+ mappingStepNameStepNumber.get(actualQuotationStep.toLowerCase()));
                                if((mappingStepNameisDispositiveAction.get(actualQuotationStep.toLowerCase()) && (mappingStepNameStepNumber.get((portals.LeadStepStatus).toLowerCase()) >= mappingStepNameStepNumber.get(actualQuotationStep.toLowerCase()))) ||
                                   !mappingStepNameisDispositiveAction.get(actualQuotationStep.toLowerCase())){
                                       System.debug(' ===> Aggiorno solo la quotazione.');
                                       quotationToUpdate.add(quotation);
                                   } else {
                                       leadIdStr = oldLead.Id;
                                   }
                            }
                        }
                    }			
                }			
            }		
            System.debug('mappingQuotationToInsertLead: ' + mappingQuotationToInsertLead);
            System.debug('mappingQuotationToUpdateLead: ' + mappingQuotationToUpdateLead);
            
            try{
                // INSERT NEW LEAD
                if(!leadToInsert.isEmpty()){
                    System.debug(' ===> leadToInsert: ' + leadToInsert);
                    Database.SaveResult[] srListLeadIns = Database.insert(leadToInsert, false);
                    system.debug('srListLeadIns'+srListLeadIns);
                    if(!srListLeadIns[0].isSuccess()){
                        throw new WS_REST_Lead_eCommerce.WSRestECommerceException('Error insert lead');
                    }
                }
                
                // QUOTATION TO INSERT
                if(!mappingQuotationToInsertLead.isEmpty()){
                    quotationToInsert = new List<Quotazione__c>();
                    for(Quotazione__c q : mappingQuotationToInsertLead.keySet()){
                        q.Lead__c = mappingQuotationToInsertLead.get(q).Id;
                        quotationToInsert.add(q);
                    }
                    System.debug(' ===> quotationToInsert: ' + quotationToInsert);
                    Database.SaveResult[] srListQuotIns = Database.insert(quotationToInsert, false);
                    system.debug('srListQuotIns'+srListQuotIns);
                    if(!srListQuotIns[0].isSuccess()){
                        throw new WS_REST_Lead_eCommerce.WSRestECommerceException('Error insert quotation');
                    }
                }
                
                // LEAD TO UPDATE
                if(!leadToUpdate.isEmpty()){
                    System.debug(' ===> leadToUpdate: ' + leadToUpdate);
                    Database.SaveResult[] srListLeadUpd = Database.update(leadToUpdate, false);
                    system.debug('srListLeadUpd'+srListLeadUpd);
                    if(!srListLeadUpd[0].isSuccess()){
                        throw new WS_REST_Lead_eCommerce.WSRestECommerceException('Error update lead');
                    }
                }
                
                // LEAD TO UPDATE ONLY NUMBER OF QUOTATION
                if(!leadToUpdateNQuotation.isEmpty()){
                    System.debug(' ===> leadToUpdateNQuotation: ' + leadToUpdateNQuotation);
                    Database.SaveResult[] srListLeadNQuot = Database.update(leadToUpdateNQuotation, false);
                    system.debug('srListLeadUpd'+srListLeadNQuot);
                    if(!srListLeadNQuot[0].isSuccess()){
                        throw new WS_REST_Lead_eCommerce.WSRestECommerceException('Error update lead number quotation');
                    }
                }
                
                // QUOTATION TO UPDATE
                if(!quotationToUpdate.isEmpty()){
                    System.debug(' ===> quotationToUpdate: ' + quotationToUpdate);
                    Database.SaveResult[] srListQuotUpd = Database.update(quotationToUpdate, false);
                    system.debug('srListQuotUpd'+srListQuotUpd);
                    if(!srListQuotUpd[0].isSuccess()){
                        throw new WS_REST_Lead_eCommerce.WSRestECommerceException('Error update quotation');
                    }
                }
                
                // QUOTATION TO UPDATE NEW LEAD
                if(!mappingQuotationToUpdateLead.isEmpty()){
                    quotationToUpdate = new List<Quotazione__c>();
                    for(Quotazione__c q : mappingQuotationToUpdateLead.keySet()){
                        q.Lead__c = mappingQuotationToUpdateLead.get(q).Id;
                        quotationToUpdate.add(q);
                    }
                    System.debug(' ===> quotationToUpdate: ' + quotationToUpdate);
                    Database.SaveResult[] srListQuotUpd = Database.update(quotationToUpdate, false);
                    system.debug('srListQuotUpd'+srListQuotUpd);
                    if(!srListQuotUpd[0].isSuccess()){
                        throw new WS_REST_Lead_eCommerce.WSRestECommerceException('Error update quotation new lead');
                    }
                }
                
                //Logica da rivedere in caso un giorno si debba gestire una casistica con una lista di Lead e non un singolo Lead
                response.UserId = request[0].Portals.SessionId;
                if(!leadToInsert.isEmpty()){
                    response.LeadId = leadToInsert[0].Id;
                }
                if(!leadToUpdate.isEmpty()){
                    response.LeadId = leadToUpdate[0].Id;
                }
                if(leadToInsert.isEmpty() && leadToUpdate.isEmpty()){
                    if(!quotationToInsert.isEmpty()){
                        response.LeadId = quotationToInsert[0].Lead__c;
                        
                    } else if(!quotationToUpdate.isEmpty()){
                        response.LeadId = quotationToUpdate[0].Lead__c;
                    } else {
                        response.LeadId = leadIdStr;
                    }
                }
                response.StatusCode = '200';
                response.StatusMessage = 'OK';
                response.Timestamp = System.now();
            } catch(Exception ex){
                System.debug('Internal Server Error - ' + ex.getMessage() + ' line: ' + ex.getLineNumber());
                response.StatusCode = '500';
                response.StatusMessage = 'Internal Server Error - ' + ex.getMessage() + ' line: ' + ex.getLineNumber();
                response.Timestamp = System.now();
            }
        }
        
        retListLeads.addAll(leadToInsert);
        retListLeads.addAll(leadToUpdate);
        
        System.debug(' ===> leadToInsert: ' + leadToInsert);
        System.debug(' ===> leadToUpdate: ' + leadToUpdate);
        System.debug(' ===> retListLeads: ' + retListLeads);
        
        ret.response = response;
        ret.leads = retListLeads;
        
        System.debug(' ===> ret: ' + ret);
        
        return ret;
    }
    
    private static Lead updateOldLead(Lead oldLead, WS_REST_eCommerce_Wrapper data, Boolean isCustomer){
        
        //Personal
        if((oldLead.Company == null || oldLead.Company == '') && data.Company != null){
            oldLead.Company = data.Company;
        }
        if((oldLead.Phone == null || oldLead.Phone == '') && data.Phone != null){
            oldLead.Phone = data.Phone;
        }
        if((oldLead.Email == null || oldLead.Email == '') && data.Email != null){
            oldLead.Email = data.Email;
        }
        if((oldLead.PostalCode == null || oldLead.PostalCode == '') && data.PostalCode != null){
            oldLead.PostalCode = data.PostalCode;
        }
        if(oldLead.State_Code_Fraud__c == null && data.StateCodeFraud != null){
            oldLead.State_Code_Fraud__c = data.StateCodeFraud;
        }
        if((oldLead.Notes__c == null || oldLead.Notes__c == '') && data.Notes != null){
            oldLead.Notes__c = data.Notes;
        }
        if((oldLead.CountryCode == null || oldLead.CountryCode == '') && data.CountryCode != null){
            oldLead.CountryCode = data.CountryCode;
        }
        if((oldLead.StateCode == null || oldLead.StateCode == '') && data.StateCode != null){
            oldLead.StateCode = data.StateCode;
        }
        if((oldLead.City == null || oldLead.City == '') && data.City != null){
            oldLead.City = data.City;
        }
        if((oldLead.Street == null || oldLead.Street == '') && data.Street != null){
            oldLead.Street = data.Street;
        }
        if(oldLead.Lead_Birthdate__c == null && data.BirthDate != null){
            oldLead.Lead_Birthdate__c = data.BirthDate;
        }
        if((oldLead.Fiscal_ID__c == null || oldLead.Fiscal_ID__c == '') && data.FiscalCode != null){
            oldLead.Fiscal_ID__c = data.FiscalCode;
        }
        if((oldLead.AAI_Partita_IVA__c == null || oldLead.AAI_Partita_IVA__c == '') && data.VATNumber != null){
            oldLead.AAI_Partita_IVA__c = data.VATnumber;
        }
        if((oldLead.Gender__c == null || oldLead.Gender__c == '') && data.Gender != null){
            oldLead.Gender__c = data.Gender;
        }
        if(data.AlreadyCustomer != null && !oldLead.Gi_cliente_eCommerce__c){ 
            oldLead.Gi_cliente_eCommerce__c = data.AlreadyCustomer;			
        }		
        if((data.AlreadyCustomer != null && data.AlreadyCustomer)||isCustomer){
            oldLead.Gi_cliente_AXA__c = true;	
        }
        else{
            oldLead.Gi_cliente_AXA__c = false;                  
        }
        
        if((oldLead.Birth_Place__c == null || oldLead.Birth_Place__c == '') && data.BirthCity != null){
            oldLead.Birth_Place__c = data.BirthCity;
        }
        if((oldLead.Birth_State__c == null || oldLead.Birth_State__c == '') && data.BirthStateCode != null){
            oldLead.Birth_State__c = data.BirthStateCode;
        }
        if((oldLead.TECH_NDG__c == null || oldLead.TECH_NDG__c == '') && data.NDG != null){
            oldLead.TECH_NDG__c = data.NDG;
        }
        
        //Portal
        WS_REST_eCommerce_Wrapper.Portals portals = data.Portals;
        if((oldLead.TECH_Company__c == null || oldLead.TECH_Company__c == '') && portals.AXACompany != null){
            oldLead.TECH_Company__c = portals.AXACompany;
        }
        if((oldLead.LeadSource == null || oldLead.LeadSource == '') && portals.LeadSource != null){
            oldLead.LeadSource = portals.LeadSource;
        }
        if(portals.LeadStepStatus != null){
            oldLead.Dettaglio__c = portals.LeadStepStatus;
        }
        if(portals.LeadStepStatus.equalsIgnoreCase('Salva preventivo') || 
           portals.LeadStepStatus.equalsIgnoreCase('KO finale banca')){
               oldLead.TECH_Send_Email_Notification__c = true;
           }
        
        if((oldLead.Convenzione__c == null || oldLead.Convenzione__c == '') && portals.AgreementCode != null){
            oldLead.Convenzione__c = portals.AgreementCode;
        }
        if((oldLead.Provenienza_Campagne_agenti__c == null || oldLead.Provenienza_Campagne_agenti__c == '') && portals.AgencyCampaign != null){
            oldLead.Provenienza_Campagne_agenti__c = portals.AgencyCampaign;
        }
        if(portals.AgencyCode != null){
            oldLead.Agency_Code__c = portals.AgencyCode;
        }
        if(portals.SubAgencyCode != null){
            oldLead.Codice_Sub_Agenzia__c = portals.SubAgencyCode;
        }
        
        oldLead.ID_Session__c = portals.SessionId;
        
        //Consensus
        WS_REST_eCommerce_Wrapper.Consensus consensus = data.Consensus;
        if(consensus != null && consensus.CommercialActivityConsensus != null){
            oldLead.CIF_Privacy_2__c = consensus.CommercialActivityConsensus;
        }
        if(consensus != null && consensus.MarketResearchConsensus != null){
            oldLead.CIF_Privacy_3__c = consensus.MarketResearchConsensus;
        }
        if(consensus != null && consensus.PartnerActivityConsensus != null){
            oldLead.CIF_Privacy_4__c = consensus.PartnerActivityConsensus;
        }
        if(consensus != null && consensus.DigitalDocumentationConsensus != null){
            oldLead.CIF_Privacy_5__c = consensus.DigitalDocumentationConsensus;
        }
        if(consensus != null && consensus.LeadConsensus != null && ('Visualizza quotazione'.equalsIgnoreCase(portals.LeadStepStatus) ||
                                                                    'Salva quotazione'.equalsIgnoreCase(portals.LeadStepStatus) ||
                                                                    'Richiedi appuntamento'.equalsIgnoreCase(portals.LeadStepStatus) ||
                                                                    'Acquista'.equalsIgnoreCase(portals.LeadStepStatus) ||
                                                                    'Salva preventivo'.equalsIgnoreCase(portals.LeadStepStatus))){
                                                                        oldLead.Commercial_Activity_Consensus__c = consensus.LeadConsensus;
                                                                    }
        
        return oldLead;
    }
    
    private static Lead createNewLead(WS_REST_eCommerce_Wrapper data, Id leadECommerceRecordTypeId, Boolean isCustomer){
        Lead lead = new Lead();
        
        //Personal
        lead.FirstName = data.FirstName;
        lead.LastName = data.LastName;
        if(data.Company != null){
            lead.Company = data.Company;
        }
        lead.Phone = data.Phone;
        lead.Email = data.Email;
        lead.PostalCode = data.PostalCode;
        lead.State_Code_Fraud__c = data.StateCodeFraud;
        if(data.Notes != null){
            lead.Notes__c = data.Notes;
        }
        if(data.CountryCode != null){
            lead.CountryCode = data.CountryCode;
        }
        if(data.StateCode != null){
            lead.StateCode = data.StateCode;
        }
        if(data.City != null){
            lead.City = data.City;
        }
        if(data.Street != null){
            lead.Street = data.Street;
        }
        if(data.BirthDate != null){
            lead.Lead_Birthdate__c = data.BirthDate;
        }
        if(data.FiscalCode != null){
            lead.Fiscal_ID__c = data.FiscalCode;
        }
        if(data.VATNumber != null){
            lead.AAI_Partita_IVA__c = data.VATnumber;
        }
        if(data.Gender != null){
            lead.Gender__c = data.Gender;
        }
        if(data.AlreadyCustomer != null){
            lead.Gi_cliente_eCommerce__c = data.AlreadyCustomer;			
        }
        if((data.AlreadyCustomer != null && data.AlreadyCustomer)||isCustomer){
            lead.Gi_cliente_AXA__c = true;	
        }
        else{
            lead.Gi_cliente_AXA__c = false;                  
        }
        
        if(data.BirthCity != null){
            lead.Birth_Place__c = data.BirthCity;
        }
        if(data.BirthStateCode != null){
            lead.Birth_State__c = data.BirthStateCode;
        }
        if(data.NDG != null){
            lead.TECH_NDG__c = data.NDG;
        }
        
        //Portal
        WS_REST_eCommerce_Wrapper.Portals portals = data.Portals;
        lead.TECH_Company__c = portals.AXACompany;
        lead.LeadSource = portals.LeadSource;
        lead.Dettaglio__c = portals.LeadStepStatus;
        if(portals.LeadStepStatus.equalsIgnoreCase('Salva preventivo') || 
           portals.LeadStepStatus.equalsIgnoreCase('KO finale banca')){
               lead.TECH_Send_Email_Notification__c = true;
           }
        if(portals.AgreementCode != null){
            lead.Convenzione__c = portals.AgreementCode;
        }
        if(portals.AgencyCampaign != null){
            lead.Provenienza_Campagne_agenti__c = portals.AgencyCampaign;
        }
        if(portals.AgencyCode != null){
            lead.Agency_Code__c = portals.AgencyCode;
        }
        if(portals.SubAgencyCode != null){
            lead.Codice_Sub_Agenzia__c = portals.SubAgencyCode;
        }
        
        lead.ID_Session__c = portals.SessionId;
        lead.Landing_Page__c = portals.LandingPage;
        if(portals.isEcommerce){
            lead.RecordTypeId = leadECommerceRecordTypeId;
        }
        lead.Prodotto__c = portals.ProductName;
        if(portals.ASA != null){
            lead.ASA__c = portals.ASA;
            lead.ASA_Description__c = mapAsaSettings.get(portals.ASA.toLowerCase()).ASA_Description__c;
            lead.Codice_ASA__c = String.valueOf(mapAsaSettings.get(portals.ASA.toLowerCase()).Codice_ASA__c);
        }
        if(portals.SubASA != null){
            lead.Sotto_ASA__c = portals.SubASA;
            lead.Codice_Sotto_ASA__c = String.valueOf(mapSubAsaSettings.get(portals.SubASA.toLowerCase()).Codice_Sotto_ASA__c);
            lead.Sotto_ASA_Description__c = mapSubAsaSettings.get(portals.SubASA.toLowerCase()).Sotto_ASA_Description__c;
        }
        
        //Consensus
        WS_REST_eCommerce_Wrapper.Consensus consensus = data.Consensus;
        if(consensus.CommercialActivityConsensus != null){
            lead.CIF_Privacy_2__c = consensus.CommercialActivityConsensus;
        }
        if(consensus.MarketResearchConsensus != null){
            lead.CIF_Privacy_3__c = consensus.MarketResearchConsensus;
        }
        if(consensus.PartnerActivityConsensus != null){
            lead.CIF_Privacy_4__c = consensus.PartnerActivityConsensus;
        }
        if(consensus.DigitalDocumentationConsensus != null){
            lead.CIF_Privacy_5__c = consensus.DigitalDocumentationConsensus;
        }
        if(consensus.LeadConsensus != null){
            lead.Commercial_Activity_Consensus__c = consensus.LeadConsensus;
        }
        
        lead.Numero_quotazioni__c = 1;
        
        return lead;
    }
    
    private static Quotazione__c createNewQuotation(WS_REST_eCommerce_Wrapper data, Id quotationRecordTypeId){
        Quotazione__c quotation = new Quotazione__c();
        
        //Portal
        WS_REST_eCommerce_Wrapper.Portals portals = data.Portals;
        
        //String quotationTimestamp = data.Quotations.QuotationTimestamp.format('dd/MM/yyyy HH:mm:ss', 'Europe/London');
        String quotationTimestamp = data.Quotations.QuotationTimestamp.format('dd/MM/yyyy HH:mm:ss');
        quotation.Name = 'Quotazione del ' + quotationTimestamp;
        
        quotation.RecordTypeId = quotationRecordTypeId;
        
        quotation.ID_Session__c = portals.SessionId;
        quotation.Lead_Step_Status__c = portals.LeadStepStatus;
        quotation.Origin_Url__c = portals.OriginUrl;
        if(portals.Source != null){
            quotation.Source__c = portals.Source;
        }
        
        //Quotations
        WS_REST_eCommerce_Wrapper.Quotations quotations = data.Quotations;
        quotation.Quotation_Timestamp__c = quotations.QuotationTimestamp;
        quotation.Quotation_Date__c = quotations.QuotationDate;
        quotation.Codice_quotazione_DAOL__c = quotations.QuickQuoteCode;
        if(quotations.QuoteCode != null){
            quotation.Quotation_Code__c = quotations.QuoteCode;
        }
        if(quotations.ProposalCode != null){
            quotation.Proposal_Code__c = quotations.ProposalCode;
        }
        if(quotations.PolicyCode != null){
            quotation.Policy_Code__c = quotations.PolicyCode;
        }
        quotation.Premium__c = quotations.Premium;
        if(quotations.DiscountedPremium != null){
            quotation.Premio_scontato__c = quotations.DiscountedPremium;
        }
        if(quotations.Fractionation != null){
            quotation.Frazionamento__c = quotations.Fractionation;
        }
        if(quotations.PriceQuotationDueDate != null){
            quotation.Price_Quotation_DueDate__c = quotations.PriceQuotationDueDate;
        }
        if(quotations.PriceProposalDueDate != null){
            quotation.Price_Proposal_DueDate__c = quotations.PriceProposalDueDate;
        }
        if(quotations.PricePolicyDueDate != null){
            quotation.Price_Policy_DueDate__c = quotations.PricePolicyDueDate;
        }
        if(quotations.PaymentResult != null){
            quotation.Payment_Result__c = quotations.PaymentResult;
        } 
        if(quotations.LicensePlate != null){
            quotation.Targa__c = quotations.LicensePlate;
        }
        if(quotations.Recoverability != null){
            quotation.Recuperabilita_Quotazione__c = quotations.Recoverability;
        }
        if(quotations.PurchasableFromDate != null){
            quotation.Data_Acquistabilita__c = quotations.PurchasableFromDate;
        }
        
        //Good Factors
        WS_REST_eCommerce_Wrapper.GoodFactors[] goodFactors = quotations.GoodFactors;
        quotation.Good_Factors__c = JSON.serialize(goodFactors);
        
        
        //Warranties
        WS_REST_eCommerce_Wrapper.Warranties[] warranties = quotations.Warranties;
        quotation.Warranties__c = JSON.serialize(warranties);
        
        return quotation;
    }
    
    private static Quotazione__c updateQuotation(Quotazione__c quotation, WS_REST_eCommerce_Wrapper data){
        
        //Portal
        WS_REST_eCommerce_Wrapper.Portals portals = data.Portals;
        
        quotation.Lead_Step_Status__c = portals.LeadStepStatus;
        quotation.Origin_Url__c = portals.OriginUrl;
        if(portals.Source != null){
            quotation.Source__c = portals.Source;
        }
        
        //Quotations
        WS_REST_eCommerce_Wrapper.Quotations quotations = data.Quotations;
        //quotation.Quotation_Timestamp__c = quotations.QuotationTimestamp;
        if(quotations.QuotationDate != null){
            quotation.Quotation_Date__c = quotations.QuotationDate;
        }
        if(quotations.QuickQuoteCode != null && quotations.QuickQuoteCode != ''){
            quotation.Codice_quotazione_DAOL__c = quotations.QuickQuoteCode;
        }
        if(quotations.QuoteCode != null && quotations.QuoteCode != ''){
            quotation.Quotation_Code__c = quotations.QuoteCode;
        }
        if(quotations.ProposalCode != null && quotations.ProposalCode != ''){
            quotation.Proposal_Code__c = quotations.ProposalCode;
        }
        if(quotations.PolicyCode != null && quotations.PolicyCode != ''){
            quotation.Policy_Code__c = quotations.PolicyCode;
        }
        if(quotations.Premium != null){
            quotation.Premium__c = quotations.Premium;
        }
        if(quotations.DiscountedPremium != null){
            quotation.Premio_scontato__c = quotations.DiscountedPremium;
        }
        if(quotations.Fractionation != null && quotations.Fractionation != ''){
            quotation.Frazionamento__c = quotations.Fractionation;
        }
        if(quotations.PriceQuotationDueDate != null){
            quotation.Price_Quotation_DueDate__c = quotations.PriceQuotationDueDate;
        }
        if(quotations.PriceProposalDueDate != null){
            quotation.Price_Proposal_DueDate__c = quotations.PriceProposalDueDate;
        }
        if(quotations.PricePolicyDueDate != null){
            quotation.Price_Policy_DueDate__c = quotations.PricePolicyDueDate;
        }
        if(quotations.PaymentResult != null && quotations.PaymentResult != ''){
            quotation.Payment_Result__c = quotations.PaymentResult;
        }
        
        
        //Good Factors
        if(quotations.GoodFactors != null){
            WS_REST_eCommerce_Wrapper.GoodFactors[] goodFactors = quotations.GoodFactors;
            quotation.Good_Factors__c = JSON.serializePretty(goodFactors);
        }
        
        
        //Warranties
        if(quotations.Warranties != null){
            WS_REST_eCommerce_Wrapper.Warranties[] warranties = quotations.Warranties;
            quotation.Warranties__c = JSON.serializePretty(warranties);
        }
        
        return quotation;
    }
    
    /**
    * Metodo che verifica la presenza di tutti i dati necessari alla deduplica del lead.
    */
    private static Boolean checkDeduplicationData(String firstName, String lastName, String company, String cap, String email, String productName){
        //Se almeno uno dei parametri in ingresso al metodo è null o vuoto, allora non ci sono i parametri per effettuare la deduplica
        if(firstName == null || firstName == ''){
            return false;
        }
        if(lastName == null || lastName == ''){
            return false;
        }
        if(cap == null || cap == ''){
            return false;
        }
        if(email == null || email == ''){
            return false;
        }
        if(productName == null || productName == ''){
            return false;
        }
        return true;
    }
    
    /**
    * Metodo che verifica la presenza di un lead a DB con la stessa chiave di deduplica.
    */
    private static List<Lead> checkExistingLead(String firstName, String lastName, String cap, String email, String productName, String landingPage, List<Lead> leadFromDeduplicationData){
        //Se almeno uno dei parametri in ingresso al metodo è null o vuoto, allora non ci sono i parametri per effettuare la deduplica
        List<Lead> leads = new List<Lead>();
        for(Lead l : leadFromDeduplicationData){
            if(l.FirstName.equalsIgnoreCase(firstName) && l.LastName.equalsIgnoreCase(lastName) && l.PostalCode == cap && l.Email.equalsIgnoreCase(email) && l.Prodotto__c.equalsIgnoreCase(productName) && l.Landing_Page__c.equalsIgnoreCase(landingPage)){
                leads.add(l);
            }
        }
        return leads;
    }
    
    /**
    * Metodo che verifica l'orizzonte di deduplica tra due lead.
    */
    private static Boolean checkDaysBeetweenLeads(Lead oldLead, Decimal period){
        DateTime nowDateTime = System.now();
        DateTime oldLeadDateTime = oldLead.CreatedDate;
        Date nowDate = date.newinstance(nowDateTime.year(), nowDateTime.month(), nowDateTime.day());
        Date oldLeadDate = date.newinstance(oldLeadDateTime.year(), oldLeadDateTime.month(), oldLeadDateTime.day());
        Boolean ret = (oldLeadDate.daysBetween(nowDate) < period);
        return ret;
    }   
    
    //FMarchese_ECOMMERCE 10/10/2018 -- START 
    /***
    Data una lista di Lead Richiedi Appuntamento, il metodo esegue un check sulla provenienza dei Lead da Landing_Page__c Siti Agenti o da Campagna Agenzia, 
    uindi lo assegna all'agenzia presso cui il Lead ha richiesto appuntamento. Se il Lead non è Siti Agenti o Campagna Agenti, viene chiamato il servizio Noovle
    per recuperare la lista di agenzia su cui eseguire la riassegnazione
    */
    
    public static void checkAgentSiteAgencyCampaign (List<Lead> Leads){
        
        List<Lead> leadsAgencySiteAgencyCampaign = new List<Lead>();
        List<Lead> leadsNotAgencySiteAgencyCampaign = new List<Lead>();
        List<Lead> leadsWithAgencyCode = new List<Lead>();
        List<Lead> rListToUpdate = new List<Lead>();
        
        for(Lead l: Leads){
            
            if(String.isNotBlank(l.Agency_Code__c)){
                
                leadsWithAgencyCode.add(l);
                
                if(l.Landing_Page__c == 'Siti Agenti' || 
                   (l.Provenienza_Campagne_Agenti__c != null && l.Provenienza_Campagne_Agenti__c != '')){		
                       leadsAgencySiteAgencyCampaign.add(l);		
                   }else{			
                       leadsNotAgencySiteAgencyCampaign.add(l);		
                   }
                
            }
            else{
                leadsNotAgencySiteAgencyCampaign.add(l);	
            }
        }
        
        
        if(leadsAgencySiteAgencyCampaign.size()>0){
            
            //qui devo gestire l'assegnazione diretta (senza eseguire riassegnazione) all'agenzia comunicata sul Lead		
           
            String ThePrefix = 'Coda_Agenzia_';
            Id defaultGroup;
            Map<String,Id> theGroupMap = LeadManagement.LeadGroup (leadsWithAgencyCode);
            System.debug('+++++++++++++++ theGroupMap: '+theGroupMap);
            List<Group> groups = [SELECT id, name,developername FROM group WHERE type = 'Queue' AND DeveloperName = 'AAI_Lead_Queue' ]; // NOPMD  Fix CRUD violation
            Integer size = groups.size();
            
            if(size>0)
            {
                defaultGroup = groups[0].Id ;
            }

            for(Lead u: leadsAgencySiteAgencyCampaign){
                
                String currentQueue = ThePrefix+''+u.Agency_Code__c;
                Id QueueId = theGroupMap.containsKey(currentQueue) ? theGroupMap.get(currentQueue) : defaultGroup;
                System.debug('+++++++++++++++ QueueId: '+QueueId);
                u.ownerid = QueueId;
                u.Numero_assegnazioni_eseguite__c = 1;
                u.TECH_Send_Email_Notification__c = TRUE;
                rListToUpdate.add(u);
            }
            
            //Database.update(rListToUpdate,false);
            Database.SaveResult[] srList = Database.update(rListToUpdate, false);       
            
        }
        
        if(leadsNotAgencySiteAgencyCampaign.size()>0){
            
            //qui assegno il Lead all'agenzia segnalata dal cliente come prima agenzia, poi faccio chiamata a Noovle e aggiorno le agenzie per riassegnazione con quelle restituite da Noovle
            for(Lead tempLead: leadsNotAgencySiteAgencyCampaign){
                
                //da capire se chiamare invece il metodo secco LeadAssignment.ResponseDto results = LeadAssignment.sendRequest(singleLead);
                LeadRankingQueueable agenciesRankingforLead = new LeadRankingQueueable(tempLead);   
                if(!Test.isRunningTest())
                    Id agenciesRankingforLeadJobId = System.enqueueJob(agenciesRankingforLead);
            }    
        }       
    }

    public static void checkAgentSiteAgencyCampaignWithoutUpdate (List<Lead> Leads){
        
        List<Lead> leadsAgencySiteAgencyCampaign = new List<Lead>();
        List<Lead> leadsNotAgencySiteAgencyCampaign = new List<Lead>();
        List<Lead> leadsWithAgencyCode = new List<Lead>();
        List<Lead> rListToUpdate = new List<Lead>();
        
        for(Lead l: Leads){
            
            if(String.isNotBlank(l.Agency_Code__c)){
                
                leadsWithAgencyCode.add(l);
                
                if(l.Landing_Page__c == 'Siti Agenti' || 
                   (l.Provenienza_Campagne_Agenti__c != null && l.Provenienza_Campagne_Agenti__c != '')){		
                       leadsAgencySiteAgencyCampaign.add(l);		
                   }else{			
                       leadsNotAgencySiteAgencyCampaign.add(l);		
                   }
                
            }
            else{
                leadsNotAgencySiteAgencyCampaign.add(l);	
            }
        }
        
        
        if(leadsAgencySiteAgencyCampaign.size()>0){
            
            //qui devo gestire l'assegnazione diretta (senza eseguire riassegnazione) all'agenzia comunicata sul Lead		
           
            String ThePrefix = 'Coda_Agenzia_';
            Id defaultGroup;
            Map<String,Id> theGroupMap = LeadManagement.LeadGroup (leadsWithAgencyCode);
            System.debug('+++++++++++++++ theGroupMap: '+theGroupMap);
            List<Group> groups = [SELECT id, name,developername FROM group WHERE type = 'Queue' AND DeveloperName = 'AAI_Lead_Queue' ]; // NOPMD  Fix CRUD violation
            Integer size = groups.size();
            
            if(size>0)
            {
                defaultGroup = groups[0].Id ;
            }

            for(Lead u: leadsAgencySiteAgencyCampaign){
                
                String currentQueue = ThePrefix+''+u.Agency_Code__c;
                Id QueueId = theGroupMap.containsKey(currentQueue) ? theGroupMap.get(currentQueue) : defaultGroup;
                System.debug('+++++++++++++++ QueueId: '+QueueId);
                u.ownerid = QueueId;
                u.Numero_assegnazioni_eseguite__c = 1;
                u.TECH_Send_Email_Notification__c = TRUE;
                rListToUpdate.add(u);
            }
            
            //Database.update(rListToUpdate,false);
            //Database.SaveResult[] srList = Database.update(rListToUpdate, false);       
            
        }
        
        if(leadsNotAgencySiteAgencyCampaign.size()>0){
            
            //qui assegno il Lead all'agenzia segnalata dal cliente come prima agenzia, poi faccio chiamata a Noovle e aggiorno le agenzie per riassegnazione con quelle restituite da Noovle
            for(Lead tempLead: leadsNotAgencySiteAgencyCampaign){
                
                //da capire se chiamare invece il metodo secco LeadAssignment.ResponseDto results = LeadAssignment.sendRequest(singleLead);
                LeadRankingQueueable agenciesRankingforLead = new LeadRankingQueueable(tempLead);
                if(tempLead.Id==null)
                    leadToRank.add(tempLead);
                if(!Test.isRunningTest() && tempLead.Id != null)
                    Id agenciesRankingforLeadJobId = System.enqueueJob(agenciesRankingforLead);
            }    
        }       
    }

    private static List<Lead> leadToRank = new List<Lead>();

    public static boolean shouldUpdate(){
        return !leadToRank.isEmpty();
    }

    public static void updateLeadIds(List<Lead> leadsReq){
        for(integer i = 0; i < leadsReq.size(); i++){
            leadToRank.get(i).ID = leadsReq.get(i).Id;
            LeadRankingQueueable agenciesRankingforLead = new LeadRankingQueueable(leadToRank.get(i));
            Id agenciesRankingforLeadJobId = System.enqueueJob(agenciesRankingforLead);
        }
        
    }
    //FMarchese_ECOMMERCE 10/10/2018 -- END 
    
    
    //FMarchese_ECOMMERCE 17/10/2018 -- START 
/***
    Data una lista di Lead eCommerce recuperati dal Batch LeadECommerceClientDeduplication_Batch (Lead eCommerce creati fino a 30 giorni prima -Confido, NPC- o 60 giorni prima -quotatori Auto-)
    viene eseguita la deduplica su clienti sui quali sia stata creata una nuova polizza il giorno precedente.	 
    */
    /*
    //MDANTONIO 07/05/2019: fix per far funzionare il metodo su tutti i lead duplicati - start
    public static void matchLeadstoAccounts(List<Lead> theLeadsScope){

    Map<Id, Lead> leadsMap = new Map<Id, Lead>(theLeadsScope);

    Map<String,Lead> mapIdLeadWithFiscalCode = new Map<String,Lead>();
    Map<String,String> mapCFIdWithFiscalCode = new Map<String,String>();
    List<String> listLeadsFiscalCode = new List<String>();

    Map<String,Lead> mapIdLeadWithNameLastName= new Map<String,Lead>();
    Map<String,String> mapNameLastNameIdWithNameLastName = new Map<String,String>();
    List<String> listLeadsNameLastName = new List<String>();

    Map<String,Lead> mapIdLeadWithPIVA = new Map<String,Lead>();
    Map<String,String> mapPIVAIdWithPIVA = new Map<String,String>();
    List<String> listLeadsPIVA = new List<String>();

    Map<String,Lead> mapIdLeadWithCompany = new Map<String,Lead>();
    Map<String,String> mapCompanyIdWithCompany = new Map<String,String>();
    List<String> listLeadsCompany = new List<String>();

    for(Lead l: theLeadsScope){

    System.debug(' ==> lead: ' + l);

    if(l.Fiscal_ID__c != null && l.Fiscal_ID__c != ''){
    mapIdLeadWithFiscalCode.put(l.Id,l);
    mapCFIdWithFiscalCode.put(l.Fiscal_ID__c,l.Id);
    listLeadsFiscalCode.add(l.Fiscal_ID__c);
    }
    if(l.FirstName != null && l.FirstName != '' && l.LastName != null && l.LastName != ''){
    mapIdLeadWithNameLastName.put(l.Id,l);
    mapNameLastNameIdWithNameLastName.put((l.FirstName+' '+l.LastName).toUpperCase(),l.Id);
    listLeadsNameLastName.add(l.FirstName+' '+l.LastName);
    }
    if(l.AAI_Partita_IVA__c != null && l.AAI_Partita_IVA__c != ''){
    mapIdLeadWithPIVA.put(l.Id,l);
    mapPIVAIdWithPIVA.put(l.AAI_Partita_IVA__c,l.Id);
    listLeadsPIVA.add(l.AAI_Partita_IVA__c);
    }
    if(l.Company != null && l.Company != ''){
    mapIdLeadWithCompany.put(l.Id,l);
    mapCompanyIdWithCompany.put(l.Company.toUpperCase(),l.Id);
    listLeadsCompany.add(l.Company);
    }
    }


    List<InsurancePolicy__c> policiesForDeduplication = new List<InsurancePolicy__c>();

    policiesForDeduplication = [SELECT Id, CUID__c, CUID__r.Id, CUID__r.AAI_Codice_fiscale__c, CUID__r.AAI_Partita_IVA__c, CUID__r.FirstName, CUID__r.LastName, CUID__r.Name
    FROM InsurancePolicy__c
    WHERE ((CUID__r.AAI_Codice_fiscale__c IN :listLeadsFiscalCode) OR
    (CUID__r.Name IN :listLeadsNameLastName) OR
    (CUID__r.AAI_Partita_IVA__c IN :listLeadsPIVA) OR
    (CUID__r.Name IN :listLeadsCompany)) AND
    (TECH_Company__c = 'AAI') AND
    (CreatedDate = YESTERDAY)];


    system.debug('policiesForDeduplication'+policiesForDeduplication);

    Set<Lead> leadsFound = new Set<Lead>();
    List<Lead> leadsToUpdate = new List<Lead>();

    if(policiesForDeduplication.size()>0){

    for(InsurancePolicy__c policy : policiesForDeduplication){

    Lead leadWithCF = mapIdLeadWithFiscalCode.get(mapCFIdWithFiscalCode.get(policy.CUID__r.AAI_Codice_fiscale__c));

    if(leadWithCF != null)
    leadsFound.add(leadWithCF);

    Lead leadWithName = mapIdLeadWithNameLastName.get(mapNameLastNameIdWithNameLastName.get(policy.CUID__r.Name));

    if(leadWithName != null)
    leadsFound.add(leadWithName);

    Lead leadWithPIVA = mapIdLeadWithPIVA.get(mapPIVAIdWithPIVA.get(policy.CUID__r.AAI_Partita_IVA__c));

    if(leadWithPIVA != null)
    leadsFound.add(leadWithPIVA);

    Lead leadWithCompany = mapIdLeadWithCompany.get(mapCompanyIdWithCompany.get(policy.CUID__r.Name));

    if(leadWithCompany != null)
    leadsFound.add(leadWithCompany);

    }
    }

    if(leadsFound.size()>0){

    for(Lead l: leadsFound){

    l.Gi_cliente_AXA__c = true;

    leadsToUpdate.add(l);


    }
    }

    System.debug(' ===> leadsFound: ' + leadsFound);

    //Database.update(leadsToUpdate);
    Database.SaveResult[] srList = Database.update(leadsToUpdate, false);


    }
*/

    public static void matchLeadstoAccounts(List<Lead> theLeadsScope){
        
        Map<Id, Lead> leadsMap = new Map<Id, Lead>(theLeadsScope);
        Map<String,List<String>> mapLeadIdListWithKey = new Map<String,List<String>>();
        List<String> listLeadsFiscalCode = new List<String>();
        List<String> listLeadsNameLastName = new List<String>();
        List<String> listLeadsPIVA = new List<String>();
        List<String> listLeadsCompany = new List<String>();
        
        for(Lead l: theLeadsScope){
            
            System.debug(' ==> lead: ' + l);
            
            if(l.Fiscal_ID__c != null && l.Fiscal_ID__c != ''){
                List<String> ids = new List<String>();
                if(mapLeadIdListWithKey.containsKey(l.Fiscal_ID__c)){
                    ids = mapLeadIdListWithKey.get(l.Fiscal_ID__c);
                }
                ids.add(l.Id);
                mapLeadIdListWithKey.put(l.Fiscal_ID__c,ids);
                listLeadsFiscalCode.add(l.Fiscal_ID__c);
            }
            else if(l.AAI_Partita_IVA__c != null && l.AAI_Partita_IVA__c != ''){
                List<String> ids = new List<String>();
                if(mapLeadIdListWithKey.containsKey(l.AAI_Partita_IVA__c)){
                    ids = mapLeadIdListWithKey.get(l.AAI_Partita_IVA__c);
                }
                ids.add(l.Id);
                mapLeadIdListWithKey.put(l.AAI_Partita_IVA__c, ids);
                listLeadsPIVA.add(l.AAI_Partita_IVA__c);
            }
            else if(l.Company != null && l.Company != ''){
                List<String> ids = new List<String>();
                String company = l.Company.toUpperCase();
                if(mapLeadIdListWithKey.containsKey(company)){
                    ids = mapLeadIdListWithKey.get(company);
                }
                ids.add(l.Id);
                mapLeadIdListWithKey.put(company, ids);
                listLeadsCompany.add(l.Company);
            }
            else if(l.FirstName != null && l.FirstName != '' && l.LastName != null && l.LastName != ''){
                List<String> ids = new List<String>();
                String name = (l.FirstName+' '+l.LastName).toUpperCase();
                if(mapLeadIdListWithKey.containsKey(name)){
                    ids = mapLeadIdListWithKey.get(name);
                }
                ids.add(l.Id);
                mapLeadIdListWithKey.put(name, ids);
                listLeadsNameLastName.add(l.FirstName+' '+l.LastName);
            }
        }
        
        System.debug('===> listLeadsFiscalCode: ' + listLeadsFiscalCode);
        System.debug('===> listLeadsNameLastName: ' + listLeadsNameLastName);
        System.debug('===> listLeadsPIVA: ' + listLeadsPIVA);
        System.debug('===> listLeadsCompany: ' + listLeadsCompany);
        System.debug('===> mapLeadIdListWithKey: ' + mapLeadIdListWithKey);
        
        Policy_Create_Date__c mc = Policy_Create_Date__c.getValues('Creazione Polizza');
        Integer days = (mc != null && mc.Days__c != null) ? Integer.valueOf(mc.Days__c) : 10;
        Date timeRange = System.today() - days;
        
        List<InsurancePolicy__c> policiesForDeduplication = new List<InsurancePolicy__c>();
        
        policiesForDeduplication = [SELECT Id, CUID__c, CUID__r.Id, CUID__r.AAI_Codice_fiscale__c, CUID__r.AAI_Partita_IVA__c, CUID__r.FirstName, CUID__r.LastName, CUID__r.Name, Income_Date__c // NOPMD  Fix CRUD violation
                                    FROM InsurancePolicy__c
                                    WHERE (( CUID__r.AAI_Codice_Fiscale__c IN :listLeadsFiscalCode  OR CUID__r.AAI_Partita_IVA__c IN :listLeadsFiscalCode  ) OR
                                           (CUID__r.Name IN :listLeadsNameLastName) OR
                                           (CUID__r.AAI_Partita_IVA__c IN :listLeadsPIVA) OR
                                           (CUID__r.Name IN :listLeadsCompany)) AND
                                    (TECH_Company__c = 'AAI') AND
                                    (CreatedDate <= TODAY AND CreatedDate >= :timeRange) ];
        
        
        system.debug('policiesForDeduplication'+policiesForDeduplication);
        
        Set<Lead> leadsFound = new Set<Lead>();
        List<Lead> leadsToUpdate = new List<Lead>();
        
        if(policiesForDeduplication.size()>0){
            
            for(InsurancePolicy__c policy : policiesForDeduplication){
                
                if (policy.Income_Date__c != null) {
                    List<String> l = new List<String>();
                    if(mapLeadIdListWithKey.containsKey(policy.CUID__r.AAI_Codice_fiscale__c)){
                        System.debug('===> list CF: ' + mapLeadIdListWithKey.get(policy.CUID__r.AAI_Codice_fiscale__c));
                        l.addAll(mapLeadIdListWithKey.get(policy.CUID__r.AAI_Codice_fiscale__c));
                    }
                    if(mapLeadIdListWithKey.containsKey(policy.CUID__r.AAI_Partita_IVA__c)){
                        System.debug('===> list Name: ' + mapLeadIdListWithKey.get(policy.CUID__r.AAI_Partita_IVA__c));
                        l.addall(mapLeadIdListWithKey.get(policy.CUID__r.AAI_Partita_IVA__c));
                    }
                    if(mapLeadIdListWithKey.containsKey(policy.CUID__r.Name.toUpperCase())){
                        System.debug('===> list Name: ' + mapLeadIdListWithKey.get(policy.CUID__r.Name.toUpperCase()));
                        for(String s : mapLeadIdListWithKey.get(policy.CUID__r.Name.toUpperCase())){
                            if(String.isBlank(leadsMap.get(s).Fiscal_ID__c)){
                                l.add(s);
                            } 
                        }
                        //l.addall(mapLeadIdListWithKey.get(policy.CUID__r.Name.toUpperCase()));
                    }
                    
                    for(String s : l){
                        leadsFound.add(leadsMap.get(s));
                    }
                }
                
            }
        }
        
        System.debug('===> leadsFound.size(): ' + leadsFound.size());
        if(leadsFound.size()>0){
            
            for(Lead l: leadsFound){
                
                l.Gi_cliente_AXA__c = true;
                
                leadsToUpdate.add(l);
                
                
            }
        }
        
        System.debug('===> leadsToUpdate.size(): ' + leadsToUpdate.size());
        
        //Database.update(leadsToUpdate);
        Database.SaveResult[] srList = Database.update(leadsToUpdate, false);                
    }
    
    //FMarchese_ECOMMERCE 17/10/2018 -- END
    //MDANTONIO 07/05/2019: fix per far funzionare il metodo su tutti i lead duplicati - end
    
    public static IE_Integration_Record__c populateIEIntegrationRecordRequest(String request){
        
        IE_Integration_Record__c ret = new IE_Integration_Record__c();
        
        List<IE_Configuration__c> config = [SELECT id,NameSpacePrefix1__c,NameSpacePrefix2__c,NameSpaceUri1__c,NameSpaceUri2__c FROM IE_Configuration__c WHERE Name='Upsert_Lead_eCommerce' ]; // NOPMD  Fix CRUD violation
        if (!config.isempty()) {
            ret.IE_Configuration__c = config[0].id;
        }
        
        System.debug ('Request: ' + request.normalizeSpace());
        
        ret.DevField__c = request.normalizeSpace();
        ret.RequestBody__c = request.normalizeSpace();
        
        return ret;      
    }
    
    public static String createJsonResponse(String userId, String leadId, String statusCode, String statusMessage, Datetime timestamp){
        
        String ret = '';
        
        JSONGenerator generator = JSON.createGenerator(true);
        
        generator.writeStartObject();
        
        generator.writeStringField('UserId', ''+userId);
        generator.writeStringField('LeadId', ''+leadId);
        generator.writeStringField('StatusCode', ''+statusCode);
        generator.writeStringField('StatusMessage', ''+statusMessage);
        generator.writeStringField('Timestamp', ''+timestamp);
        
        generator.writeEndObject();
        
        ret = generator.getAsString().normalizeSpace();
        
        return ret;
    }
    
    public static void assignLeadtoProcessQueue(List<Lead> leads, List<String> defaultQueues){
        
        List<Group> allECommerceQueue = [Select Id, DeveloperName from group where type='Queue' and DeveloperName LIKE '%_EC' ]; // NOPMD  Fix CRUD violation
        Map<String, Group> mapGroup = new Map<String, Group>();
        for(Group g : allECommerceQueue){
            mapGroup.put(g.DeveloperName, g);
        }
        
        System.debug(' ===> allECommerceQueue: ' + allECommerceQueue);
        
        Map<String,String> mappingStepNameQueue = new Map<String,String>(); //for old logic
        List <LeadECommerce_Setting__mdt> stepModelSettings = new List <LeadECommerce_Setting__mdt>();
        stepModelSettings = [SELECT Id, StepName__c, Queue__c FROM LeadECommerce_Setting__mdt WHERE DeveloperName LIKE '%Step%' ]; // NOPMD  Fix CRUD violation
        for(LeadECommerce_Setting__mdt ls: stepModelSettings){
            mappingStepNameQueue.put(ls.StepName__c.toLowerCase(),ls.Queue__c);
        }
        System.debug(' ===> mappingStepNameQueue: ' + mappingStepNameQueue);
        String queueName;
        for(Integer i=0; i<leads.size(); i++){
            if(defaultQueues.isEmpty()) //if the list is empty the method was called from old logic
                queueName = mappingStepNameQueue.get(leads[i].Dettaglio__c.toLowerCase());
            else
                queueName=defaultQueues[i];
            System.debug(' ===> queueName: ' + queueName);
            if(mapGroup.containsKey(queueName)){
                System.debug(' ===> found queue: ' + queueName);
                leads[i].OwnerId = mapGroup.get(queueName).Id;
            }
        }
        
        Database.update(leads, false);        
    }
    
    public static void assignLeadtoAgencyQueue(List<Lead> queueAgencyleads, List<Boolean> isAssignedList){
        
        List<Lead> rListToUpdate = new List<Lead>();
        String codiceFiscale='';
        String partitaIVA='';
        String company='';

        List<String> names = new List<String>();
        List<String> CFs = new List<String>();
        List<String> PIva = new List<String>();
        
        Set<String> leadsAgencyCodes = new Set<String>();

        for (Lead l:queueAgencyleads){
            if (l.Agency_Code__c==null){ //cliente AXA
                if(l.Fiscal_ID__c!=null && String.isNotBlank(l.Fiscal_ID__c)){
                    codiceFiscale=l.Fiscal_ID__c;
                    CFs.add(codiceFiscale);
                } 
                if(l.AAI_Partita_IVA__c!=null && String.isNotBlank(l.AAI_Partita_IVA__c)){
                    partitaIVA=l.AAI_Partita_IVA__c;
                    PIva.add(partitaIVA);
                }
                if(l.Company!=null) {
                    company=l.Company.toUpperCase();
                    names.add(company);
                }
                
                if(l.Name != null){
                    names.add(l.Name);
                }
                else{
                    names.add(l.FirstName.toUpperCase()+' '+l.LastName.toUpperCase());
                }
                
                /*List<InsurancePolicy__c>RelatedAccount=[SELECT CUID__r.AAI_Agency_Reference_Code__c FROM InsurancePolicy__c
                WHERE  TECH_Company__c = 'AAI' AND
                (CUID__r.AAI_Codice_fiscale__c =:codiceFiscale OR
                 (CUID__r.FirstName=:l.FirstName.toUpperCase() AND
                    CUID__r.LastName=:l.LastName.toUpperCase()) OR
                CUID__r.AAI_Partita_IVA__c=:partitaIVA OR
                CUID__r.Name=:company) limit 1];
                if(RelatedAccount.size()>0)
                    l.Agency_Code__c=RelatedAccount[0].CUID__r.AAI_Agency_Reference_Code__c;*/
            }
            else leadsAgencyCodes.add(l.Agency_Code__c);
        }
        List<Account> accListByName = new List<Account>();
        List<Account> accListByCF = new List<Account>();
        List<Account> accListByPIva = new List<Account>();
        if(!names.isEmpty())
        	accListByName = [Select Name, AAI_Agency_Reference_Code__c from Account where name in: names ]; // NOPMD  Fix CRUD violation
        if(!CFs.isEmpty())
        	accListByCF = [Select AAI_Codice_fiscale__c, AAI_Agency_Reference_Code__c from Account where AAI_Codice_fiscale__c in: CFs ]; // NOPMD  Fix CRUD violation
        if(!PIva.isEmpty())
        	accListByPIva = [Select AAI_Partita_IVA__c, AAI_Agency_Reference_Code__c from Account where AAI_Partita_IVA__c in: PIva ]; // NOPMD  Fix CRUD violation
        
        Map<String, String> agencyCodesMap = new Map<String,String>();
        if(!accListByName.isEmpty()){
            for(Account a:accListByName)
                agencyCodesMap.put(a.Name.toUpperCase(),a.AAI_Agency_Reference_Code__c);
        }
        if(!accListByCF.isEmpty()){
            for(Account a:accListByCF)
                agencyCodesMap.put(a.AAI_Codice_fiscale__c,a.AAI_Agency_Reference_Code__c);
        }
        if(!accListByPIva.isEmpty()){
            for(Account a:accListByPIva)
                agencyCodesMap.put(a.AAI_Partita_IVA__c,a.AAI_Agency_Reference_Code__c);
        }
        
        //finding the related agencies
        Map<String,Account>agencyMap=new Map<String,Account>();
        List<Account>agencies=[select id,ispersonaccount,agency_code__c,mobilePhone__c,TECH_Company__c,name, Agency_email__c from account where recordtype.name='agency' and agency_code__c in: leadsAgencyCodes ]; // NOPMD  Fix CRUD violation
        for(Account agency:agencies)
            agencyMap.put(agency.Agency_Code__c,agency);

        String ThePrefix = 'Coda_Agenzia_';
        Id defaultGroup;
        Map<String,Id> theGroupMap = LeadManagement.LeadGroup(queueAgencyleads);
        System.debug('+++++++++++++++ theGroupMap: '+theGroupMap);
        List<Group> groups = [Select id, name,developername from group where type = 'Queue' and developername = 'AAI_Lead_Queue' ]; // NOPMD  Fix CRUD violation
        Integer size = groups.size();	        
        if(size>0){
            defaultGroup = groups[0].Id ;
        }	
        
        for(Integer i=0; i<queueAgencyleads.size(); i++){
            Lead l=queueAgencyleads[i];
            if(l.Agency_Code__c==null) l.Agency_Code__c=getAgencyCode(l,agencyCodesMap);
            Account agency=agencyMap.get(l.Agency_Code__c);
            String currentQueue = ThePrefix+''+l.Agency_Code__c;
            Id QueueId = theGroupMap.containsKey(currentQueue) ? theGroupMap.get(currentQueue) : defaultGroup;
            System.debug('+++++++++++++++ QueueId: '+QueueId);
            l.OwnerId = QueueId;
            l.Numero_assegnazioni_eseguite__c = 1;
            if(!isAssignedList.isEmpty() && isAssignedList[i]){ //if the action is "agenzia assegnata" the lead shouldn't be reassigned 
                l.Agenzie_gia_assegnate__c=l.Agenzie_gia_assegnate_complete__c=
                l.Agenzie_per_riassegnazione__c=l.Agenzie_per_riassegnazione_riordinata__c=null;
            }
            rListToUpdate.add(l);
            //send SMS to agent for Leads
            
            /*if(![select value__c from ListViewCustomFilters__mdt where filtername__c='Health' and value__c=:l.Prodotto__c].isEmpty()
                && SendSMSCmpController.validate(agency.MobilePhone__c)){
                    QueueableContextVariables.add(new RequestWrap(agency, l));
                
            }*/
        }
        
        /*if(!QueueableContextVariables.isEmpty()){
            System.enqueueJob(new queueableSendSms(QueueableContextVariables));
        }*/

        Database.update(rListToUpdate,false);             
    }
    
    public static String getAgencyCode(Lead l,Map<String,String> agencyCodesMap){
        if(l.Fiscal_ID__c != null && agencyCodesMap.containsKey(l.Fiscal_ID__c)){
            return agencyCodesMap.get(l.Fiscal_ID__c);
        }
        else if(l.AAI_Partita_IVA__c != null && agencyCodesMap.containsKey(l.AAI_Partita_IVA__c)){
            return agencyCodesMap.get(l.AAI_Partita_IVA__c);
        }
        else if(l.Name != null && agencyCodesMap.containsKey(l.Name)){
            return agencyCodesMap.get(l.Name);
        }
        else if(l.Name == null && agencyCodesMap.containsKey((l.FirstName!= null && l.LastName!= null)?l.FirstName.toUpperCase()+' '+l.LastName.toUpperCase():null)){
            return agencyCodesMap.get(l.FirstName.toUpperCase()+' '+l.LastName.toUpperCase());
        }
        else if(l.Company != null && agencyCodesMap.containsKey(l.Company.toUpperCase())){
            return agencyCodesMap.get(l.Company.toUpperCase());
        }
        else return null;
    }

    public static Boolean checkBadRequest(WS_REST_eCommerce_Wrapper request){
        
        if(request.Portals == null){
            System.debug('No Portals');
            return true;
        }
        if(request.Portals.AXACompany == null || request.Portals.AXACompany == ''){
            System.debug('No AXACompany');
            return true;
        }
        if(request.Portals.LeadSource == null || request.Portals.LeadSource == ''){
            System.debug('No LeadSource');
            return true;
        }
        if(request.Portals.LeadStepStatus == null || request.Portals.LeadStepStatus == ''){
            System.debug('No LeadStepStatus');
            return true;
        }
        if(request.Portals.SessionId == null || request.Portals.SessionId == ''){
            System.debug('No SesisonId');
            return true;
        }
        if(request.Portals.isEcommerce == null){
            System.debug('No isEcommerce');
            return true;
        }
        
        //GENDER PICKLIST
        Schema.DescribeFieldResult fieldResult = Lead.Gender__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Boolean notFound = true;
        System.debug(' ===> request.Gender: ' + request.Gender);
        for(Schema.PicklistEntry pickListVal : ple){	
            System.debug(' ===> pickListVal.getValue(): ' + pickListVal.getValue());
            if(pickListVal.getValue().equalsIgnoreCase(request.Gender) && notFound){
                System.debug(' ===> OK');
                notFound = false;
            }
        }     
        if(notFound && request.Gender != null){
            return true;
        }
        
        //AXA COMPANY PICKLIST
        fieldResult = Lead.TECH_Company__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        notFound = true;
        System.debug(' ===> request.Portals.AXACompany: ' + request.Portals.AXACompany);
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(' ===> pickListVal.getLabel(): ' + pickListVal.getLabel());
            if(pickListVal.getLabel().equalsIgnoreCase(request.Portals.AXACompany) && notFound){
                System.debug(' ===> OK');
                notFound = false;
            }
        }    
        if(notFound){
            return true;
        }
        
        //LEAD SOURCE PICKLIST
        fieldResult = Lead.LeadSource.getDescribe();
        ple = fieldResult.getPicklistValues();
        notFound = true;
        System.debug(' ===> request.Portals.LeadSource: ' + request.Portals.LeadSource);
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(' ===> pickListVal.getLabel(): ' + pickListVal.getLabel());
            if(pickListVal.getLabel().equalsIgnoreCase(request.Portals.LeadSource) && notFound){
                System.debug(' ===> OK');
                notFound = false;
            }
        } 	   
        if(notFound){
            return true;
        }
        
        //LEAD STEP STATUS PICKLIST
        fieldResult = Lead.Dettaglio__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        notFound = true;
        System.debug(' ===> request.Portals.LeadStepStatus: ' + request.Portals.LeadStepStatus);
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(' ===> pickListVal.getLabel(): ' + pickListVal.getLabel());
            if(pickListVal.getLabel().equalsIgnoreCase(request.Portals.LeadStepStatus) && notFound){
                System.debug(' ===> OK');
                notFound = false;
            }
        }    
        if(notFound){
            return true;
        }
        
        //AGENCY CAMPAIGN PICKLIST
        fieldResult = Lead.Provenienza_Campagne_Agenti__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        notFound = true;
        System.debug(' ===> request.Portals.AgencyCampaign: ' + request.Portals.AgencyCampaign);
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(' ===> pickListVal.getLabel(): ' + pickListVal.getLabel());
            if(pickListVal.getLabel().equalsIgnoreCase(request.Portals.AgencyCampaign) && notFound){
                System.debug(' ===> OK');
                notFound = false;
            }
        }    
        if(notFound && request.Portals.AgencyCampaign != null){
            return true;
        }
        
        //LANDING PAGE PICKLIST
        fieldResult = Lead.Landing_Page__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        notFound = true;
        System.debug(' ===> request.Portals.LandingPage: ' + request.Portals.LandingPage);
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(' ===> pickListVal.getLabel(): ' + pickListVal.getValue());
            if(pickListVal.getValue().equalsIgnoreCase(request.Portals.LandingPage) && notFound){
                System.debug(' ===> OK');
                notFound = false;
            }
        }    
        if(notFound && request.Portals.LandingPage != null){
            return true;
        }
        
        //ASA PICKLIST
        fieldResult = Lead.ASA__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        notFound = true;
        System.debug(' ===> request.Portals.ASA: ' + request.Portals.ASA);
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(' ===> pickListVal.getLabel(): ' + pickListVal.getLabel());
            if(pickListVal.getLabel().equalsIgnoreCase(request.Portals.ASA) && notFound){
                System.debug(' ===> OK');
                notFound = false;
            }
        }    
        if(notFound && request.Portals.ASA != null){
            return true;
        }
        
        //SUB ASA PICKLIST
        fieldResult = Lead.Sotto_ASA__c.getDescribe();
        ple = fieldResult.getPicklistValues();
        notFound = true;
        System.debug(' ===> request.Portals.SubASA: ' + request.Portals.SubASA);
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(' ===> pickListVal.getLabel(): ' + pickListVal.getLabel());
            if(pickListVal.getLabel().equalsIgnoreCase(request.Portals.SubASA) && notFound){
                System.debug(' ===> OK');
                notFound = false;
            }
        }    
        if(notFound && request.Portals.SubASA != null){
            return true;
        }
        
        if(request.Consensus != null){
            
            //COMMERCIAL ACTIVITY CONSENSUS PICKLIST
            fieldResult = Lead.CIF_Privacy_2__c.getDescribe();
            ple = fieldResult.getPicklistValues();
            notFound = true;
            System.debug(' ===> request.Consensus.CommercialActivityConsensus: ' + request.Consensus.CommercialActivityConsensus);
            for(Schema.PicklistEntry pickListVal : ple){
                System.debug(' ===> pickListVal.getLabel(): ' + pickListVal.getLabel());
                if((request.Consensus.CommercialActivityConsensus == '' || pickListVal.getLabel().equalsIgnoreCase(request.Consensus.CommercialActivityConsensus)) && notFound){
                    System.debug(' ===> OK');
                    notFound = false;
                }
            }    
            if(notFound && request.Consensus.CommercialActivityConsensus != null){
                return true;
            }
            
            //MARKET RESEARCH CONSENSUS PICKLIST
            fieldResult = Lead.CIF_Privacy_3__c.getDescribe();
            ple = fieldResult.getPicklistValues();
            notFound = true;
            System.debug(' ===> request.Consensus.MarketResearchConsensus: ' + request.Consensus.MarketResearchConsensus);
            for( Schema.PicklistEntry pickListVal : ple){
                System.debug(' ===> pickListVal.getLabel(): ' + pickListVal.getLabel());
                if((request.Consensus.MarketResearchConsensus == '' || pickListVal.getLabel().equalsIgnoreCase(request.Consensus.MarketResearchConsensus)) && notFound){
                    System.debug(' ===> OK');
                    notFound = false;
                }
            }    
            if(notFound && request.Consensus.MarketResearchConsensus != null){
                return true;
            }
            
            //PARTNER ACTIVITY CONSENSUS PICKLIST
            fieldResult = Lead.CIF_Privacy_4__c.getDescribe();
            ple = fieldResult.getPicklistValues();
            notFound = true;
            System.debug(' ===> request.Consensus.PartnerActivityConsensus: ' + request.Consensus.PartnerActivityConsensus);
            for( Schema.PicklistEntry pickListVal : ple){
                System.debug(' ===> pickListVal.getLabel(): ' + pickListVal.getLabel());
                if((request.Consensus.PartnerActivityConsensus == '' || pickListVal.getLabel().equalsIgnoreCase(request.Consensus.PartnerActivityConsensus)) && notFound){
                    System.debug(' ===> OK');
                    notFound = false;
                }
            }    
            if(notFound && request.Consensus.PartnerActivityConsensus != null){
                return true;
            }
            
            //DIGITAL DOCUMENTATION CONSENSUS PICKLIST
            fieldResult = Lead.CIF_Privacy_5__c.getDescribe();
            ple = fieldResult.getPicklistValues();
            notFound = true;
            System.debug(' ===> request.Consensus.DigitalDocumentationConsensus: ' + request.Consensus.DigitalDocumentationConsensus);
            for( Schema.PicklistEntry pickListVal : ple){
                System.debug(' ===> pickListVal.getLabel(): ' + pickListVal.getLabel());
                if((request.Consensus.DigitalDocumentationConsensus == '' || pickListVal.getLabel().equalsIgnoreCase(request.Consensus.DigitalDocumentationConsensus)) && notFound){
                    System.debug(' ===> OK');
                    notFound = false;
                }
            }    
            if(notFound && request.Consensus.DigitalDocumentationConsensus != null){
                return true;
            }
        }
        
        return false;       
    }
    public class RequestWrap {
            public Lead reqLead;
            public RequestWrap(Lead reqLead){
                this.reqLead = reqLead;
            }
    }

    public class queueableSendSms implements Queueable, Database.AllowsCallouts {
        
        
        List<RequestWrap> requestList;
        //List<Account> accountList;
        Set<String> leadsAgencyCodes = new Set<String>();
        public queueableSendSms(List<RequestWrap> requestList){
            this.requestList = requestList;
            
            for(RequestWrap r : requestList){
                if(r.reqLead != null && r.reqLead.Agency_Code__c != null){
                    leadsAgencyCodes.add(r.reqLead.Agency_Code__c);
                }
            }
        }

        public void execute(QueueableContext context){
            try{
                List<Account>agencies=[select id,ispersonaccount,agency_code__c,mobilePhone__c,TECH_Company__c,name, Agency_email__c from account where recordtype.name='agency' and agency_code__c in: leadsAgencyCodes];
                Map<String, Account> agencyMap = new Map<String, Account>();
                for(Account agency:agencies)
                    agencyMap.put(agency.Agency_Code__c,agency);

                for(RequestWrap req : this.requestList){
                    Account agency = agencyMap.get(req.reqLead.Agency_Code__c);
                    if(SendSMSCmpController.validate(agency.MobilePhone__c)){
                        SendSMSCmpController.MobileOutput mobileOut=SendSMSCmpController.ObtainMobileNumber(agency,agency.Agency_email__c);
                        SendSMSCmpController.ResponseWrapper responseWrap=SendSMSCmpController.sendParametricSMS(prepareRequest(req.reqLead, mobileOut, agency.MobilePhone__c));
                        System.debug(responseWrap.errorMessage);
                    }
                    
                }
            }
            catch(Exception ex){
                ApplicationLogHelper.ERROR('Invio SMS ECommerce', ex.getmessage(), ex.getStackTraceString());
            }
        }
        public SendSMSCmpController.SMSReqWrapper prepareRequest(Lead l, SendSMSCmpController.MobileOutput mobOut, String phone){
            SendSMSCmpController.SMSReqWrapper toRet = new SendSMSCmpController.SMSReqWrapper();
            toRet.mobileOutput = mobOut;
            toRet.template = 'Lead_Assign';
            toRet.phoneNumber = phone;
           
            String Type;
            Boolean reAssigned = l.Numero_assegnazioni_eseguite__c != 1;
            LeadAssignmentConfiguration__c conf = LeadAssignmentConfiguration__c.getValues('ToBeProcessedTimeLimitHours');
            string hours;
            if(conf != null){
                hours = conf.HoursLimit__c.intValue().format() + ' ore';
            }
            List<SMS_Products__mdt> prodList = [SELECT type__c FROM SMS_Products__mdt where label =: l.Prodotto__c];
            if(prodList != null && prodList.size() == 1) {
                type = prodList[0].Type__c;
            }

            toRet.attributeParams.put('Type', Type);
            toRet.attributeParams.put('reAssigned', reAssigned);
            toRet.attributeParams.put('hours', hours);
            toRet.attributeParams.put('URL', '' +  System.Label.MobilityLoginURL);
            return toRet;
        }
    }

    

    @InvocableMethod(label ='sendSMS on eCommerce')
    public static void sendSMSonECommerce(List<Lead> leads){
        List<RequestWrap> QueueableContextVariables = new List<RequestWrap>();
        List<SMS_Products__mdt> ProductsMD = [Select label from SMS_Products__mdt ]; // NOPMD  Fix CRUD violation
        List<String> Products = new List<String>();
        for(SMS_Products__mdt temp : ProductsMD){
            Products.add(temp.label);
        }

        if(!Products.isEmpty())
            for(Lead l : leads){
                if(Products.contains(l.Prodotto__c)){
                    QueueableContextVariables.add(new RequestWrap(l));
                }
            }
        

        if(!QueueableContextVariables.isEmpty()){
            System.enqueueJob(new queueableSendSms(QueueableContextVariables));
        }
    }
}
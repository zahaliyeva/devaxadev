/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         WS_REOL_Service_Management
Description:   Class that supports the CRM logics on the webservice exposed for REOL "WS_REOL_Service" (see corresponding class)
History
-17/05/2015   Davide Fabris - Created
----------------------------------------------------------------------------*/
public with sharing class WS_REOL_Service_Management {

    /*
CORE METHODS
VALIDATE for polizza and proposta inputs
INSERT/UPSERT for polizza/proposta
*/

    public static void validatePolizzaInput(WS_REOL_Service.REOL_Request_STATE currentState){
        system.debug('++++START validatePolizzaInput');
        validateCompulsoryFieldsPolizza(currentState);
        if (currentState.output.Result=='KO') {
            system.debug('+++++missing fields, returning KO');
            return;
        }
        
        validateObjectTypePolizza(currentState);
        if(currentState.output.Result=='KO') {
            system.debug('+++++Object Type not recognised, returning KO');
            return;
        }
        
        validateAgencyCode(currentState);
        if(currentState.output.Result=='KO') {
            system.debug('+++++Agency not present on the CRM, returning KO');
            return;
        }
        validateOpportunityRef(currentState);
        if(currentState.output.Result=='KO') {
            system.debug('+++++Opportunity not found returning KO');
            return;
        }
        
        validateAccount(currentState);
        if(currentState.output.Result=='KO') {
            system.debug('+++++NDG not present on the CRM for the given agency, returning KO');
            return;
        }
        
        validatePolizzaKey(currentState);
        if(currentState.output.Result=='KO') {
            system.debug('+++++Polizza already present, no update performed');
            return;
        }
        system.debug('++++END validatePolizzaInput');
    }
    
    public static void validatePropostaInput(WS_REOL_Service.REOL_Request_STATE currentState){
        system.debug('++++START validatePropostaInput');
        validateCompulsoryFieldsProposta(currentState);
        if (currentState.output.Result=='KO') {
            system.debug('+++++missing fields, returning KO');
            return;
        }
        
        validateObjectTypeProposta(currentState);
        if(currentState.output.Result=='KO') {
            system.debug('+++++Object Type not recognised, returning KO');
            return;
        }
        
        validateAgencyCode(currentState);
        if(currentState.output.Result=='KO') {
            system.debug('+++++Agency not present on the CRM, returning KO');
            return;
        }
        validateOpportunityRef(currentState);
        if(currentState.output.Result=='KO') {
            system.debug('+++++Opportunity not found returning KO');
            return;
        }
        
        validateAccount(currentState);
        if(currentState.output.Result=='KO') {
            system.debug('+++++NDG not present on the CRM for the given agency, returning KO');
            return;
        }
        system.debug('++++END validatePropostaInput');
    } 

    public static void upsertProposta(WS_REOL_Service.REOL_Request_STATE currentState){
        system.debug('++++START upsertProposta');
        PopulatePropostaInstance(currentState);
        if(currentState.output.Result=='KO') {
            system.debug('+++++could not populate the proposta instance');
            return;
        } else {
            UpsertProposta_wDML(currentState);
        }
        system.debug('++++END upsertProposta');
    }  

    public static void insertPolizza(WS_REOL_Service.REOL_Request_STATE currentState){
        system.debug('++++START insertPolizza');
        PopulatePolizzaInstance(currentState);
        if(currentState.output.Result=='KO') {
            system.debug('+++++could not populate the Polizza instance');
            return;
        }

        // Create a savepoint before the polizza is inserted so that you can roll back  in case the upserto fo the proposta with the ref fails
        Savepoint beforeInsertOfPoloizza = Database.setSavepoint();

        InsertPolizza_wDML(currentState);
        if(currentState.output.Result=='KO') {
            system.debug('+++++could not insert the new Polizza');
            return;
        }
        
        UpdatePropostaWithPolizzaRef(currentState); 
        if(currentState.output.Result=='KO') {
            system.debug('+++++could not update the proposta with the new Polizza ref');
            // Rollback to the previous null value
            Database.rollback(beforeInsertOfPoloizza);
            return;
        }
        
        //currentState.output.Message = 'InsertedPolizza';

        system.debug('++++END insertPolizza');
    }

    /*
    /////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    ////////////////UTILITY METHODS//////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
*/    
    public static void validateCompulsoryFieldsProposta(WS_REOL_Service.REOL_Request_STATE currentState){
        //List of compulsory fields:   --ID_proposta__c   --Codice_agenzia__c --Nodo__c --Contraente__c   --Ramo__c   --Opportunita__c   --Ultima_modifica__c   --ObjectType   --Codice_stato__c   --Stato__c. Should already be mandatory by ESB
        system.debug('++++START__validateCompulsoryFieldsProposta');
        system.debug('++++currentState.input'+currentState.input);
        if (currentState.input.IdProposta==null ||
                String.isempty(currentState.input.AgencyCode) ||
                String.isempty(currentState.input.Node) ||
                String.isempty(currentState.input.Branch) ||
                String.isempty(currentState.input.Holder) ||
                currentState.input.IdOpp==null ||
                String.isempty(currentState.input.LastModifiedBy) ||
                String.isempty(currentState.input.ObjectType) ||
                currentState.input.PropostaStatusCode==null ||
                String.isempty(currentState.input.NDG) ||
                String.isempty(currentState.input.PropostaStatusDesc) 
                ) {
            currentState.output.Message='Campi obbligatori PROPOSTA mancanti';
            currentState.output.Result='KO';
            currentState.output.ResultCode='T-0001';
        } else {//in order to proceed to the next step
            currentState.output.Result='OK';
            currentState.output.Message='All fields provided';
            currentState.output.ResultCode='In progress';
            
        }
        system.debug('++++END__validateCompulsoryFieldsProposta');        
    }
    
    public static void validateObjectTypeProposta(WS_REOL_Service.REOL_Request_STATE currentState){
        system.debug('++++START__validateObjectType');
        if (currentState.input.ObjectType!='PROPOSTA') {
            currentState.output.Message='Tipologia oggetto errata. Specificare PROPOSTA per lavorare su tale oggetto';
            currentState.output.Result='KO';
            currentState.output.ResultCode='T-0002';
        }else {//in order to proceed to the next step
            currentState.output.Result='OK';
            currentState.output.Message='Object type ok';
            currentState.output.ResultCode='In progress';
            
        }
        system.debug('++++END__validateObjectType');
    }
    
    public static void validateObjectTypePolizza(WS_REOL_Service.REOL_Request_STATE currentState){
        system.debug('++++START__validateObjectType');
        if (currentState.input.ObjectType!='POLIZZA') {
            currentState.output.Message='Tipologia oggetto errata. Specificare POLIZZA per lavorare su tale oggetto';
            currentState.output.Result='KO';
            currentState.output.ResultCode='T-0002';
        }else {//in order to proceed to the next step
            currentState.output.Result='OK';
            currentState.output.Message='Object type ok';
            currentState.output.ResultCode='In progress';
            
        }
        system.debug('++++END__validateObjectType');
    }

    public static void validateAgencyCode(WS_REOL_Service.REOL_Request_STATE currentState){
        system.debug('++++START__validateAgencyCode');
        //The id should already be checked by the scheam as it is exposed as SFDC Id
        string selectedAgencyCode = currentState.input.AgencyCode;//should already be checked by ESB, but the check is performed anyway

        if (String.isempty(selectedAgencyCode)) {
            currentState.output.Message='Codice agenzia non fornito';
            currentState.output.Result='KO';
            currentState.output.ResultCode='B-0001';
        } else {//Agency code provided
            system.debug('+++++input Agency code'+selectedAgencyCode);
            
            List<Account> selectedAgency = [SELECT id, RecordtypeId, recordtype.DeveloperName FROM Account WHERE Agency_Code__c=:selectedAgencyCode AND Active__c=true AND Recordtype.DeveloperName='Agency'];
            if(selectedAgency.isempty()) {
                currentState.output.Message='Agenzia non trovata per il codice --'+selectedAgencyCode+'--' ;
                currentState.output.Result='KO';
                currentState.output.ResultCode='B-0001';
            }else {//in order to proceed to the next step
                currentState.output.Result='OK';
                currentState.output.Message='Agency found';
                currentState.output.ResultCode='In progress';
            } 
        }
        system.debug('++++END__validateAgencyCode');
    }
    
    public static void validateOpportunityRef(WS_REOL_Service.REOL_Request_STATE currentState){
        system.debug('++++START__validatioOpportunityRef');
        //The id should already be checked by the scheam as it is exposed as SFDC Id
        Id selectedID=currentState.input.IdOpp;
        system.debug('+++++input Opp id'+selectedID);
        List<Opportunity> selectedOpp = [SELECT id, RecordtypeId, Recordtype.DeveloperName, Account.NDG__c, AccountId FROM Opportunity WHERE Id=:selectedID and Recordtype.DeveloperName IN ('Opportunita_AXA_Assicurazioni', 'No_Auto', 'Motor')]; //and Recordtype.DeveloperName='No_Auto']; FM dismissed since RT for Opportunities is now unique
        if(selectedOpp.isempty()) {
            currentState.output.Message='Opportunità non trovata con ID  --'+selectedID+'--';
            currentState.output.Result='KO';
            currentState.output.ResultCode='B-0002';
        } else {// I found the opportunity
            currentState.RelatedOpp = selectedOpp[0];
            //check if the proposta to add is already on SFDC, if so check if the opportunity selected is the same
            List<Proposta__c> ExistingProposte = [SELECT id, Opportunita__c,ID_proposta__c FROM Proposta__c WHERE Opportunita__c=:currentState.input.IdOpp OR ID_proposta__c=:currentState.input.IdProposta];
            system.debug('+++++ExistingProposte'+ExistingProposte);
            if(ExistingProposte.isempty()) {//Should be an insert 
                if (currentState.input.ObjectType=='POLIZZA') {
                    currentState.output.Message='Non è stata trovata alcuna Proposta (ID='+currentState.input.IdProposta+') associata alla Polizza specificata (ID='+currentState.input.IdPolizza+'). Impossibile procedere con la creazione della polizza';
                    currentState.output.Result='KO';
                    currentState.output.ResultCode='B-0006';
                } else {
                    currentState.output.Message='Opportunity OK';
                    currentState.output.Result='OK';
                    currentState.output.ResultCode='In progress';
                }
            } else { //update case
                if (ExistingProposte.size()>1) {//more than a proposta found. something went wrong. 
                    currentState.output.Message='Impossibile riconciliare la proposta (ID='+currentState.input.IdProposta+') con l\'Opportunità specificata (ID='+currentstate.RelatedOpp.Id+')';
                    currentState.output.Result='KO';
                    currentState.output.ResultCode='B-0003';
                } else { //found a single proposta
                    if ((ExistingProposte[0].ID_proposta__c ==currentState.input.IdProposta) && (ExistingProposte[0].Opportunita__c ==currentState.input.IdOpp)) {//mathc correct
                        currentState.p=ExistingProposte[0];
                        currentState.output.Message='Opportunity OK';
                        currentState.output.Result='OK';
                        currentState.output.ResultCode='In progress';
                    } else {
                        currentState.output.Message='Impossibile riconciliare la proposta (ID='+currentState.input.IdProposta+') con l\'Opportunità specificata (ID='+currentstate.RelatedOpp.Id+')';
                        currentState.output.Result='KO';
                        currentState.output.ResultCode='B-0003';
                    }
                }
            }
        }
        system.debug('++++'+currentState);
        system.debug('++++END__validatioOpportunityRef');
    }

    public static void validateAccount(WS_REOL_Service.REOL_Request_STATE currentState){
        system.debug('++++START__validateAccount');
        //The id should already be checked by the scheam as it is exposed as SFDC Id
        String selectedNDG=currentState.input.NDG;
        system.debug('+++++input selectedNDG'+selectedNDG);
        List<Account> selectedCustomer = [SELECT id, RecordtypeId, Recordtype.DeveloperName FROM Account WHERE NDG__c=:selectedNDG];
        if(selectedCustomer.isempty()) {
            currentState.output.Message='Nessun cliente trovato con l\'NDG secificato --'+selectedNDG+'--';
            currentState.output.Result='KO';
            currentState.output.ResultCode='B-0004';
            return;
        } else {
            //Must check alignment between the NDG on the proposta and the Account of the opportunity
            system.debug('+++++NDG on opportunity'+currentState.RelatedOpp.Account.NDG__c);
            system.debug('+++++NDG on call'+currentState.input.NDG);
            if (currentState.RelatedOpp.Account.NDG__c==currentState.input.NDG) {
                currentState.Holder=selectedCustomer[0];
                currentState.output.Message='Client OK';
                currentState.output.Result='OK';
                currentState.output.ResultCode='In progress';
            } else {
                currentState.output.Message='Cliente specificato non corrispondente all cliente legato all\'opportunità';
                currentState.output.Result='KO';
                currentState.output.ResultCode='B-0005';
            }

        } 
        system.debug('++++END__validateAccount');
    }

    public static void PopulatePropostaInstance(WS_REOL_Service.REOL_Request_STATE currentState) {
        system.debug('++++START__PopulatePropostaInstance');
        //from the available inputs (already checked) populates a proposta instance
        Proposta__c p = new Proposta__c();
        //ACT HERE TO CHANGE MAPPING
        try {
            p.Name=currentState.input.PropostaNum;
            p.ID_proposta__c=currentState.input.IdProposta;
            p.ID_Polizza__c=currentState.input.IdPolizza;
            p.Numero_Polizza__c=currentState.input.NumeroPolizza;
            p.Codice_agenzia__c=currentState.input.AgencyCode;
            p.Ramo__c=currentState.input.Branch;
            p.Contraente__c=currentState.input.Holder;
            p.Codice_sotto_ASA__c=String.ValueOf(currentState.input.SubAsaCode);//the number from REOL is converted in picklist string
            p.Sotto_ASA__c=currentState.input.SubAsaDesc;
            p.Nome_prodotto__c=currentState.input.ProductName;
            p.Codice_prodotto__c=currentState.input.ProductCode;
            p.Descrizione_prodotto__c=currentState.input.ProductDesc;
            p.Codice_convenzione__c=currentState.input.ConvenzioneCode;
            p.Convenzione__c=currentState.input.ConvenzioneDesc;
            p.Codice_frazionamento__c=currentState.input.FrazionamentoCode;
            p.Frazionamento__c=currentState.input.FrazionamentoDesc;
            p.Premio_lordo__c=currentState.input.Premium;
            p.NDG__c=currentState.input.NDG;
            p.Opportunita__c=currentState.input.IdOpp;
            p.Ultima_modifica__c=currentState.input.LastModifiedBy;
            p.Codice_stato__c=String.ValueOf(currentState.input.PropostaStatusCode);//the number from REOL is converted in picklist string
            p.Stato__c=currentState.input.PropostaStatusDesc;
            p.Data_effetto__c=currentState.input.DataEffetto;
            p.Data_scadenza__c=currentState.input.DataScadenza;
            p.Data_fine_validaita__c=currentState.input.DataFineValidita;
            //FM --- added for CRM DAOL 2.0 --- START
            p.Marca_veicolo__c=currentState.input.Marcaveicolo;
            p.Modello_veicolo__c=currentState.input.Modelloveicolo;
            p.Versione_veicolo__c=currentState.input.Versioneveicolo;
            p.Compensi__c=currentState.input.Compensi;
            p.Diritti__c=currentState.input.Diritti;
            p.Premio_totale_a_pagare__c=currentState.input.Premiototaleapagare;
            p.Targa_veicolo__c=currentState.input.Targaveicolo;
            p.Codice_ASA__c=String.ValueOf(currentState.input.AsaCode);
            //FM --- END
            
              //FM --- added for CRM DAOL 2.0 --- START
            Recordtype RTAuto = [SELECT ID from Recordtype where DeveloperName IN ('Auto')  AND SobjectType ='Proposta__c' LIMIT 1];
            Recordtype RTNonAuto = [SELECT ID from Recordtype where DeveloperName IN ('Non_Auto')  AND SobjectType ='Proposta__c' LIMIT 1];
            
            if(currentState.input.AsaCode == 1){
            p.RecordtypeId =RTAuto.id;
            }else{
            p.RecordtypeId =RTNonAuto.id;
            }
            //FM --- END
            currentState.p = p;
            
            //to go to the next step
            currentState.output.Message='Proposta Details OK';
            currentState.output.Result='OK';
            currentState.output.ResultCode='In progress';
        } catch (exception e) {
            currentState.output.Message='Errore durante la compilazione della proposta --'+e.getStackTraceString();
            currentState.output.Result='KO';
            currentState.output.ResultCode='T-0003';
        }
        system.debug('++++END__PopulatePropostaInstance');
    }

    public static void UpsertProposta_wDML(WS_REOL_Service.REOL_Request_STATE currentState) {
        system.debug('++++START__UpsertProposta');
        try {
            Schema.SObjectField pID = Proposta__c.Fields.ID_proposta__c; //the way SFDC recognise an external id
            
            //Populating the Opportunity in order to update the relevant fields
            
            Database.UpsertResult result = Database.upsert(currentState.p, pID, false);//false here is not necessary. If it was a list it would allow to insert the one with OKinfo and reject only the bad records
            if(result.isSuccess()){
                if (result.isCreated()){
                    system.debug('++++id inserted'+currentState.p.id);
                    currentState.output.Message = 'Proposta creata con successo --ID:' + result.getId()+'--'; 
                } else {
                    system.debug('++++id updated'+currentState.p.id);
                    currentState.output.Message = 'Proposta aggiornata con successo --ID:' + result.getId()+'--'; 
                }
                
                PopulateOppInstance(currentState);
                system.debug('+++++Updating the Opportunity'+currentState.RelatedOpp);
                update currentState.RelatedOpp;
                system.debug('+++++Opportunity updated');
                
                currentState.output.Result='OK';
                currentState.output.ResultCode='S-0000';
            } else {
                currentState.output.Message='Errore durante la lavorazione della proposta --'+result.getErrors();
                currentState.output.Result='KO';
                currentState.output.ResultCode='T-0004';            
            }
            
        } catch (exception e) {
            currentState.output.Message='Errore durante la lavorazione della proposta --'+e.getStackTraceString();
            currentState.output.Result='KO';
            currentState.output.ResultCode='T-0004';
        }
        system.debug('++++END__UpsertProposta');
    }
    
    public static void validateCompulsoryFieldsPolizza(WS_REOL_Service.REOL_Request_STATE currentState) {
        system.debug('++++START__validateCompulsoryFieldsPolizza');
        system.debug('++++currentState.input'+currentState.input);
        if (currentState.input.IdProposta==null ||
                String.isempty(currentState.input.IdPolizza) ||
                String.isempty(currentState.input.NumeroPolizza) ||
                String.isempty(currentState.input.AgencyCode) ||
                String.isempty(currentState.input.Node) ||
                String.isempty(currentState.input.Branch) ||
                String.isempty(currentState.input.Holder) ||
                // currentState.input.SubAsaCode == null ||
                // String.isempty(currentState.input.SubAsaDesc) ||
                String.isempty(currentState.input.ProductName) ||
                String.isempty(currentState.input.ProductCode) ||
                String.isempty(currentState.input.ProductDesc) ||
                String.isempty(currentState.input.FrazionamentoCode) ||
                String.isempty(currentState.input.FrazionamentoDesc) ||
                currentState.input.Premium==null ||
                currentState.input.IdOpp==null ||
                String.isempty(currentState.input.LastModifiedBy) ||
                String.isempty(currentState.input.ObjectType) ||
                currentState.input.PropostaStatusCode==null ||
                String.isempty(currentState.input.NDG) ||
                String.isempty(currentState.input.PropostaStatusDesc) ||
                currentState.input.DataEffetto==null ||
                currentState.input.DataScadenza==null ||
                currentState.input.DataFineValidita==null
                ) {
            currentState.output.Message='Campi obbligatori POLIZZA mancanti';
            currentState.output.Result='KO';
            currentState.output.ResultCode='T-0001';
        } else {//in order to proceed to the next step
            currentState.output.Result='OK';
            currentState.output.Message='All fields provided';
            currentState.output.ResultCode='In progress';
            
        }
        system.debug('++++END__validateCompulsoryFieldsPolizza');
    }
    
    public static void validatePolizzaKey(WS_REOL_Service.REOL_Request_STATE currentState) {
        system.debug('++++START__validatePolizzaKey');
        List<InsurancePolicy__c> ExistingPol = [SELECT Id,Policy_Key__c FROM InsurancePolicy__c WHERE Policy_Key__c=:currentState.input.IdPolizza];
        
        if(ExistingPol.isempty()) {//insert as expected
            currentState.output.Result='OK';
            currentState.output.Message='New Polizza';
            currentState.output.ResultCode='In progress';
        } else {
            currentState.output.Result='KO';
            currentState.output.Message='Una polizza con codice --'+ExistingPol[0].Policy_Key__c+'-- è già presente a sistema. Nessuna operazione compiuta sul CRM';
            currentState.output.ResultCode='B-0007';
        }
        system.debug('++++END__validatePolizzaKey');
    }
    
    public static void PopulatePolizzaInstance(WS_REOL_Service.REOL_Request_STATE currentState) {
        InsurancePolicy__c  RelatedPol = new InsurancePolicy__c();
        try {
            RelatedPol.Policy_Key__c=currentState.input.IdPolizza;
            RelatedPol.Name=currentState.input.NumeroPolizza;
            RelatedPol.Node__c=currentState.input.Node;
            RelatedPol.Sub_ASA__c=String.ValueOf(currentState.input.SubAsaCode);
            RelatedPol.Sub_ASA_Description__c=currentState.input.SubAsaDesc;
            RelatedPol.Product_Name__c=currentState.input.ProductName;
            RelatedPol.Product_Code__c=currentState.input.ProductCode;
            RelatedPol.Product_Description__c=currentState.input.ProductDesc;
            RelatedPol.Convention__c=currentState.input.ConvenzioneDesc;
            RelatedPol.Fractionation__c=currentState.input.FrazionamentoDesc;
            //RelatedPol.Status__c=currentState.input.PropostaStatusDesc;
            RelatedPol.Status__c='ATTIVO'; //defaulted to ATTIVO to already align with ODS
            RelatedPol.CCDATE__c=currentState.input.DataEffetto;
            RelatedPol.EXPIRY_DATE__c=currentState.input.DataScadenza;
            RelatedPol.CUID__c=currentState.Holder.Id;
            
            //FM --- added for CRM DAOL 2.0 --- START
            if (currentState.input.Marcaveicolo!='') RelatedPol.Marca_veicolo__c=currentState.input.Marcaveicolo;
            if (currentState.input.Modelloveicolo!='') RelatedPol.Modello_veicolo__c=currentState.input.Modelloveicolo;
            RelatedPol.Premio_totale_a_pagare__c=currentState.input.Premiototaleapagare;
            RelatedPol.Targa_veicolo__c=currentState.input.Targaveicolo;
            RelatedPol.Line__c=String.ValueOf(currentState.input.AsaCode);
            //FM --- END
            
            //FM --- added for CRM DAOL 2.0 --- START
            RelatedPol.TECH_Company__c='AAI';
            Recordtype RTAuto = [SELECT ID from Recordtype where DeveloperName IN ('B2C_Motor')  AND SobjectType ='InsurancePolicy__c' LIMIT 1];
            Recordtype RTNonAuto = [SELECT ID from Recordtype where DeveloperName IN ('B2C_No_Motor')  AND SobjectType ='InsurancePolicy__c' LIMIT 1];
            
            if(currentState.input.AsaCode == 1){
            RelatedPol.RecordtypeId =RTAuto.id;
            }else{
            RelatedPol.RecordtypeId =RTNonAuto.id;
            }
            //FM --- END
            

            
            currentState.RelatedPol = RelatedPol;
            //to go to the next step
            currentState.output.Message='Polizza Details OK';
            currentState.output.Result='OK';
            currentState.output.ResultCode='In progress';
        } catch (exception e) {
            currentState.output.Message='Errore durante la compilazione della Polizza --'+e.getStackTraceString();
            currentState.output.Result='KO';
            currentState.output.ResultCode='T-0003';
        }
    }
    
    public static void InsertPolizza_wDML(WS_REOL_Service.REOL_Request_STATE currentState) {
        try {
            system.debug('++++inserting'+currentState.RelatedPol);
            Database.SaveResult result = Database.insert(currentState.RelatedPol, false);
            if(result.isSuccess()){
                system.debug('++++id inserted'+currentState.RelatedPol.id);
                currentState.output.Message = 'Polizza creata con successo --ID:' + result.getId()+'--'; 
                currentState.output.Result='OK';
                currentState.output.ResultCode='S-0001';
            } else {
                currentState.output.Message='Errore durante la creazione della polizza --'+result.getErrors();
                currentState.output.Result='KO';
                currentState.output.ResultCode='T-0004';            
            }            
        } catch (exception e) {
            currentState.output.Message='Errore durante la creazione della polizza --'+e.getStackTraceString();
            currentState.output.Result='KO';
            currentState.output.ResultCode='T-0004';
        }
    }

    public static void PopulateOppInstance(WS_REOL_Service.REOL_Request_STATE currentState) {
        //Using the Opportunity already found
        Opportunity RelatedOpp = currentState.RelatedOpp;
            
            RelatedOpp.TECH_NumProposta__c = currentState.input.PropostaNum; //FM 23/01/2018 - added to populate the field TECH_NumProposta__c on Opportunity to build the 'Vai a proposta su DAOL' link
        
            RelatedOpp.BypassValidationRule__c=TRUE;//A.D. 29.11.2016 Disability Validation Rules
            
        if (currentState.input.PropostaStatusCode==500000||
             currentState.input.PropostaStatusCode==9900000) {
            RelatedOpp.StageName='Closed Lost';
        }
        
        if (currentState.input.PropostaStatusCode==1100000 ||
                currentState.input.PropostaStatusCode==1200000 ||
                currentState.input.PropostaStatusCode==1300000 ||
                currentState.input.PropostaStatusCode==00000 ||
                currentState.input.PropostaStatusCode==3000000 ||        
                currentState.input.PropostaStatusCode==3200000        
                ) {
            RelatedOpp.StageName='Closed Won';
        }
        
        if (currentState.input.PropostaStatusCode==1000001 ||
        currentState.input.PropostaStatusCode==100000
        ) { //must add the remaining states
            RelatedOpp.StageName='Proposal Made';
        }
        
        if (currentState.input.PropostaStatusCode==1000002 ||
                currentState.input.PropostaStatusCode==200000 ||
                currentState.input.PropostaStatusCode==300000 ||
                currentState.input.PropostaStatusCode==3000002 ||        
                currentState.input.PropostaStatusCode==400000 ||        
                currentState.input.PropostaStatusCode==3100000        
                ) {
            RelatedOpp.StageName='Open';
        }
        
        if (currentState.input.Premium>0) RelatedOpp.Amount=currentState.input.Premiototaleapagare;
        
        //FM --- added for CRM DAOL 2.0 --- START
        
        //RelatedOpp.Codice_Sotto_ASA__c=String.ValueOf(currentState.input.SubAsaCode);//SottoASACode is always 0 from WS
        //RelatedOpp.Sotto_ASA__c=currentState.input.SubAsaDesc;//SottoASADesc is always null from WS
        
        if (currentState.input.ASACode == 1)
        {    
            
            RelatedOpp.Codice_ASA__c=String.ValueOf(currentState.input.AsaCode);//ASACode is passed to Opportunity only if ASACode is 1
            MappingASA__c mapASA = [SELECT ASA__c, Codice_ASA__c, ASA_Description__c FROM MappingASA__c WHERE Codice_ASA__c=:currentState.input.AsaCode LIMIT 1].get(0);        
            RelatedOpp.ASA__c= mapASA.ASA__c; 
            RelatedOpp.ASA_Description__c=String.ValueOf(currentState.input.AsaCode)+' - '+mapASA.ASA__c;
            //RelatedOpp.TECH_IsPropostaAuto__c = true;
            //RelatedOpp.Sotto_ASA_Description__c=String.ValueOf(currentState.input.AsaCode)+'.'+String.ValueOf(currentState.input.SubAsaCode)+' '+currentState.input.SubAsaDesc;// 
        }
        
        RelatedOpp.Prodotto__c=currentState.input.ProductName;  
        
       //FM --- END
        
        currentState.RelatedOpp=RelatedOpp;
    }
    
    
    public static void UpdatePropostaWithPolizzaRef(WS_REOL_Service.REOL_Request_STATE currentState) {
        system.debug('++++updating'+currentstate.p);
        currentState.p.Polizza_corrispondente__c=currentState.RelatedPol.Id;
        

        try {
            update currentState.p;
        } catch (exception e) {
            currentState.output.Message='Errore durante la creazione relazione tra proposta e polizza --'+e.getStackTraceString();
            currentState.output.Result='KO';
            currentState.output.ResultCode='T-0011';
        }
    }
    
    

}
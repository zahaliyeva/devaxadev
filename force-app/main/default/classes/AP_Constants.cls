public class AP_Constants {
    

    /* CONSENSI VALUES */
    public static String CONSENSI_SI = 'Sì';
    public static String CONSENSI_NO = 'No';

    public static String FLAG_SI = 'Sì';
    public static String FLAG_NO = 'No';

    public static String TRANSITORYSETTING_FORCED_NEW = 'FORCED_NEW';
    public static String TRANSITORYSETTING_FORCED_OLD = 'FORCED_OLD';
    public static String TRANSITORYSETTING_FIELD_BASED = 'FIELD_BASED';
    public static String TRANSITORYSETTING_ACCOUNT_BASED = 'ACCOUNT_BASED';

    public static String SCHEDACLIENTE_TYPE_NEW = 'New';
    public static String SCHEDACLIENTE_TYPE_OLD = 'Old';


    public static String TECHCompany_AAI = 'AAI'; 
    public static String TECHCompany_ING = 'ING'; 
    public static String TECHCompany_RCI = 'RCI'; 
    public static String TECHCompany_AAIDefault = 'AAI Default';
    public static String ING_NODE = '001040';
    public static String RCI_NODE = '000729'; 
/***********************************************************************
* Email Template
************************************************************************/
    public static string emailTemplateNew_Email_Received = 'Email_di_notifica';
        
/***********************************************************************
* Business Hour
************************************************************************/
    public static integer dailyWorkingHours = 10;
    public static double numDaysSLA = 2.5;
    public static integer NumDaysCIMPAS  = 10;
    public static integer NumDaysNonCIMPAS = 10;


/***********************************************************************
* get profile id method 
************************************************************************/
    public static id getProfileAdminId(){
        return ([Select Id From Profile 
                Where name = 'Administrateur système' 
                    OR name = 'System Administrator'
                    OR name = 'Amministratore del sistema'
                    OR name = 'Systemadministrator'
                    OR name = 'Systemadministratör'
                    OR name = 'Administrador do sistema'
                    OR name = 'Systeembeheerder'
                    OR name = 'Systemadministrator'].Id);
    }
    
    //OAVERSANO 04/07/2018 Easy Azienda -- START
    public static id getProfileIdAAIVenditeAvanzato()
    {
        return ([Select Id From Profile 
                Where name = 'NFE - AAI - Vendite Avanzato'].Id);
    }
    //OAVERSANO 04/07/2018 Easy Azienda -- END
    
    //MDANTONIO 05/07/2019 micro evolutive portale agenti - start
    public static List<String> getAgencyProfilesId(){
        List<String> profilesId = new List<Id>();
        List<Profile> agencyProfiles = [SELECT Id FROM Profile WHERE Name LIKE 'AAI - Vendite%'];
        for(Profile p : agencyProfiles){
            profilesId.add(String.valueOf(p.Id));
        }
        return profilesId;
    }
    //MDANTONIO 05/07/2019 micro evolutive portale agenti - start

    public static Set<String> getActiveStatusAccount() {
        FilterValuesService filterValueService = new FilterValuesService('AccountValues');

        Set<String> accountActiveState = filterValueService.filterBySObject('Account').filterByField('State__c').filterByKey('Active').getValues();

        if(accountActiveState == null || accountActiveState.size() == 0 ) {
            accountActiveState = new Set<String>{'Active Client', 'ATTIVO'};
        }

        return accountActiveState;
    }
    
    
    

/***********************************************************************
* Feedback constants
************************************************************************/  
    /*sobject*/
        public static string sobjectFeedbk = 'Feedback__c';
        
    /*key prefix*/
        public static string FeedbkKeyPrefix = Schema.SObjectType.Feedback__c.getKeyPrefix();

    /*Recordtypes : all recordtype Developer name should be defined as rt<objectAbb><DeveloperName> */
        public static string rtGeneralFeedbk = 'GeneralFeedback';
        public static string rtComplaintFeeedback = 'Complaint_Feedback';
        public static string rtPhoneSurveyFeedback = 'PhoneSurvey';//MMOSCATELLI 22/07/2016: EVO 63
        public static string rtClaimSurveyFeedback = 'ClaimSurvey';//MMOSCATELLI 08/02/2017: Close the loop ICF
        public static string rtChatSurveyFeedback = 'ChatSurvey';//MOSCATELLI_M 16-03-2017: EVO 78
        public static string rtAcquistoSurveyFeedback = 'Acquisto Rinnovo';//MOSCATELLI_M 07/11/2018: CTL Acquisto
    /*FieldValue/PicklistValue Variable : all variable containing picklist value should be defined as <ObjetAbb><FieldName><Value>*/
		public static string TemplateInvioNotificaMPS = 'Email_di_notifica';
    //Ambi
        public static integer nbOfDaysbefore=7;
    /*Champ Generique: Champ à valeur unique <ObjetAbb><FieldName><Value> */    
        
    //MMOSCATELLI 22/07/2016: EVO 63 -- START
    /*Channel Origin*/
      public static String rtFeedbackFromEmail = 'Email';
      public static String rtFeedbackFromPhone = 'Phone';
      public static String rtFeedbackFromChat  = 'Chat';//MOSCATELLI_M 16-03-2017: EVO 78
      //MMOSCATELLI 08/02/2017: Close the loop ICF -- START
      public static String rtFeedbackFromClaimOpening = 'Apertura sinistro';
      public static String rtFeedbackFromClaimExamination = 'Perizia sinistro';
      public static String rtFeedbackFromClaimSettlement = 'Liquidazione sinistro';
      //MMOSCATELLI 08/02/2017: Close the loop ICF -- END    
    //MMOSCATELLI 22/07/2016: EVO 63 -- END
    
/***********************************************************************
* Case
************************************************************************/
    /*sobject*/
    public static string sobjectCas = 'Case';
    
    /*key prefix*/
        public static string CaseKeyPrefix = Schema.SObjectType.Case.getKeyPrefix();
    
    /*Recordtypes : all recordtype Developer name should be defined as rt<objectAbb><DeveloperName> */
    
    /*FieldValue/PicklistValue Variable : all variable containing picklist value should be defined as <ObjetAbb><FieldName><Value>*/
    public static string caseOriginCIMPAS = 'CIMPAS';
    public static string caseStatusOpen = 'Open';
    public static string caseStatusReopened = 'Reopened';
    public static string caseStatusAssigned = 'Assigned';
    public static string caseStatusPending = 'Pending'; 
    public static string caseStatusAllTasksClosed = 'All Tasks Closed';
    public static string caseStatusDelegated = 'Delegated';
    public static string caseStatusCancelled = 'Cancelled';
    public static string caseStatusClosed = 'Closed';
    public static string caseStatusOutOfTime = 'Out of time';//RANIELLO_V 26042016: EVO-52
    public static string caseStatusChiusuraEmail = 'Chiusura Email'; //SPINELLI_F 15112015: EVO-36
    public static string caseStatusInformationReceived = 'Information Received';//MOSCATELLI_M 14032016: EVO50
    //MOSCATELLI_M 06/03/2017: EVO 79 -- START
    public static string caseStatusAttivitaDispositive = 'Attività dispositive in attesa di verifica';
    public static string caseStatusVerificaAttDispositive = 'Verifica completamento attività dispositive';
    //MOSCATELLI_M 06/03/2017: EVO 79 -- END    
    //CAPOBIANCO_A 13/06/2017: EVO 85 -- START
    public static string caseStatusVerificaAttAntiRic = 'In attesa verifica antiriciclaggio';
    public static string caseStatusInfoAntiRicReceived = 'Informazioni antiriciclaggio ricevute';
    public static string caseStatusVerificaStatoAntiRic = 'Verifica stato antiriciclaggio';
    public static string caseStatusInviataRaccomandata = 'Inviata raccomandata QADV';
    //MOSCATELLI_M 02/05/2018: GDPR--START
    public static string caseStatusInAttesaDPO = 'In attesa verifica DPO';
    public static string caseStatusAttivitaDPOCompletate = 'Attività DPO concluse';
    //MOSCATELLI_M 02/05/2018: GDPR--END
    
    //OAVERSANO 10/07/2018: Close the loop ICF START
    public static string caseStatusSupportRequest = 'Support request';
    public static string caseStatusAfterSupportRequest = '2';
    //OAVERSANO 26/07/2018: Close the loop ICF START
    public static string caseStatusGestioneAgente = 'In gestione all’Agenzia';
    public static string caseStatusInfoAgenteRicevuta = 'Info Agenzia ricevuta';
    public static string caseStatusMancataGestioneAgente = 'Mancata gestione Agenzia';
    public static string caseStatusInoltratoAgenzia = 'Inoltrato all\'Agenzia';
    //OAVERSANO 26/07/2018: Close the loop ICF START
    //OAVERSANO 10/07/2018: Close the loop ICF END
    
    //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza START
    public static string caseStatusRisolto = 'Risolto';                                         //Chiusura
    public static string caseStatusSoluzioneRifiutata = 'Soluzione rifiutata';                  //HD1
    public static string caseStatusChiusoInAutonomia = 'Chiuso in autonomia';                   //Chiusura
    public static string caseStatusSoluzioneProposta = 'Soluzione proposta';                    //AGENT
    public static string caseStatusInfoAgenteRicevute = 'Info Agente ricevute';                 //HD1
    public static string caseStatusAttesaInfoAgente = 'Attesa Info Agente';                     //AGENT
    public static string caseStatusGestioneSpecialistica = 'In gestione Specialista';           //HD2
    public static string caseStatusRispostaSpecialista = 'Risposta Specialista';                //HD1
    public static string caseStatusRisoltoInAutonomia = 'Risolto in autonomia dall\'Agente';    //AGENT
    public static string caseStatusGestioneHD3 = 'In gestione all\'HD3';                        //HD3
    //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza END
    
    //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- START
    public static string caseStatusInoltratoIT = 'Inoltrato ad IT';
    public static string caseStatusInoltratoBusiness = 'Inoltrato a Linea di Business';
    //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- END  
    
    //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 -- START
    public static string caseStatusInoltratoContabilita = 'Inoltrato a Contabilità';
    public static string caseStatusInoltratoContenzioso = 'Inoltrato a Contenzioso';
    //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 -- END
    
    //OAVERSANO 15/10/2018 : Caring Angel -- START
    public static String caseStatusAssILivello = 'Assegnato I Livello';							//HD1
    public static String caseStatusAttesaRicontatto = 'In attesa ricontatto';					//cliente
    public static String caseStatusAttesaDocumento = 'In attesa Documento';						//cliente
    public static String caseStatusAssIILivello = 'Assegnato II Livello';						//HD2
    //OAVERSANO 15/10/2018 : Caring Angel -- END
    
    //OAVERSANO 15/01/2019 : Gestione Reclami -- START
    public static String caseStatusGestioneSuPeres = 'In gestione su Geres';
    //OAVERSANO 15/01/2019 : Gestione Reclami -- END

    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
    public static string caseInAttesa2ndInterno='In gestione back office Smart Center';
    public static string case2ndInternoCompletato='Completato da Back office Smart Center';    
    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END

    //CAPOBIANCO_A 13/06/2017: EVO 85 -- END
    public static string caseOriginEmail = 'Email';
    public static string caseOriginEmail2Case = 'Email.';
    public static string caseOriginPhone = 'Phone';
    public static string caseOriginBranchMain = 'BranchMain';
    public static string caseOriginAXAPlanet = 'AXA Planet';//MOSCATELLI_M 04/11/2016: EVO 67 - Webform AXA Planet
    public static string caseOriginClaim = 'Claim';//MMOSCATELLI 08/02/2017: Close the loop ICF
    public static string caseOrigineCommerce = 'e-Commerce';//MOSCATELLI 31/03/2017: Webform ConFido
    //MOSCATELLI_M 18/07/2017: Assistenza Social -- START
    public static string caseOrigineFB = 'Facebook';
    public static string caseOrigineTW = 'Twitter';
    //MOSCATELLI_M 18/07/2017: Assistenza Social -- END
    
    //OAVERSANO 26/09/2018 : ICF Close The Loop -- START
    public static string caseOriginsurveyRinnovo = 'Survey Rinnovo/Acquisto';
    //OAVERSANO 26/09/2018 : ICF Close The Loop -- END
    
    //OAVERSANO 12/12/2018 : Enhancement NMA Biz -- START
    public static string caseLobIT = 'IT';
    public static string caseLobAuto = 'Auto';
    public static string caseLobFamiglia = 'Famiglia';
    public static string caseLobSalute = 'Salute';
    //MDANTONIO 08/05/2019: LOB VITA - start
    public static string caseLobVita = 'Vita';
    //MDANTONIO 08/05/2019: LOB VITA - end
    //OAVERSANO 12/12/2018 : Enhancement NMA Biz -- END
    
    //picklist Complainant
    public static string caseComplainantInt = 'Intermediary';
    //picklist Status
    public static string caseStatusPendingStaff = 'Pending Staff';
    //field SLA
    public static integer caseSLASevenDays = 7;
    public static integer caseSLAFourteenDays= 14;
    
    /*Recordtypes : all recordtype Developer name should be defined as rt<objectAbb><DeveloperName> */
    public static string rtCaseMotor= 'Motor';
    public static string rtCaseNonMotor= 'NonMotor';
    public static string rtCaseQuadra= 'Quadra';//PETRECCHIA_M 10072015: EVO-12
    public static string rtCaseAAI= 'Axa_Assicurazioni';//MOSCATELLI_M 03072015: EVO-08
    public static string rtCaseFamilyProtect = 'Family_Protect';//MOSCATELLI_M 10102016: Family Protect
    public static string rtCaseCloseTheLoop = 'Close the loop';//MMOSCATELLI 08/02/2017: Close the loop ICF
    public static string rtCaseAMF= 'AMPS_Financial'; //ACAPOBIANCO 22/08/2017: AMF
    public static string rtCaseSinistro='Sinistri_Danni_Banca';//MOSCATELLI_M 09/04/2018: Apertura sinistri da email
    public static string rtCaseBuonLavoro='Buon_Lavoro';//MOSCATELLI_M 03/07/2018: Easy Azienda
    public static string rtCaseAssistenzaAgenti='Assistenza_Agenti'; //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza
    public static string rtCaseCaringSalute='AXA_Caring_Salute';
    public static string rtCaseCaringProperty='Caring_Angel_Property';
    public static string rtCaseDACAgenti='DAC_AXA_Agenti'; //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza
    public static String rtCaseCaringAngel = 'Caring_Angel'; //OAVERSANO 05/10/2018 : Caring Angel
    public static String rtCaseAgenziaDipendenti = 'Agenzia_dipendenti'; //OAVERSANO 09/01/2019 : Agenzia diretta
    public static String rtCaseReclamo = 'Reclamo'; //OAVERSANO 15/01/2019 : Gestione Reclami
	public static String rtCaseSinistriAAI = 'Sinistri_AAI'; //OAVERSANO 25/03/2019 : AXA Assistance
	public static string rtCaseDACAXAAgenzie= 'DAC_AXA_Agenti'; //OAVERSANO 03/04/2019 : DAC Fase II 
	public static string rtCaseTerzeParti= 'Terze_Parti'; //OAVERSANO 17/06/2019 : ING
	public static string rtCaseCloseTheLoopDevName = 'Close_the_loop';
    //MOSCATELLI_M 26/07/2016 -- START
    public static string rtCaseCustComp ='Customer';
    public static string rtCaseAgentComp ='Bank Agent';   
    //MOSCATELLI_M 26/07/2016 -- END
    public static string rtCaseProspComp = 'Prospect';//MOSCATELLI 31/03/2017: Webform ConFido
    public static String rtCallerIsAgente= 'Agente';//MOSCATELLI_M 03/07/2018: Easy Azienda
    public static String rtCallerIdDipendente = 'Dipendente'; //OAVERSANO 10/01/2019 : Agenzia diretta
    
/***********************************************************************
* Account constants
************************************************************************/  
    /*sobject*/
        public static string sobjectAcc = 'Account';
        
    /*key prefix*/
        public static string AccKeyPrefix = Schema.SObjectType.Account.getKeyPrefix();

    /*Recordtypes : all recordtype Developer name should be defined as rt<objectAbb><DeveloperName> */
        public static string rtAccIndividualClient = 'Client';
        public static string rtAccEmployee = 'Employee';
        public static string rtAccPersonAccount = 'PersonAccount';
        public static string rtAccCorporateClient = 'Business_Account';
        public static string rtAccIntermediary = 'Intermediary';
    //PETRECCHIA_M 01022016: EVO-18------------START
        public static string rtAccB2C = 'B2C_Client';
        public static string rtAccB2B = 'B2B_Client';
    //PETRECCHIA_M 01022016: EVO-18------------END
    
        public static string rtAccAAFB2C = 'AAF_B2C';//MOSCATELLI_M 07102016: Family Protect

        //MOSCATELLI_M 13/02/2018: Aggiornamento anagrafica gestori -- START
        public static string stAccActiveBank ='Active Bank Agent';
        public static string stAccInActiveBank ='Inactive Bank Agent';
        //MOSCATELLI_M 13/02/2018: Aggiornamento anagrafica gestori -- END         
        
    /*FieldValue/PicklistValue Variable : all variable containing picklist value should be defined as <ObjetAbb><FieldName><Value>*/

    /*Champ Generique: Champ à valeur unique <ObjetAbb><FieldName><Value> */
      
    /*FieldValue/PicklistValue Variable : all variable containing picklist value should be defined as <ObjetAbb><FieldName><Value>*/


/***********************************************************************
* Task constants
************************************************************************/  
    /*sobject*/
        public static string sobjectTask = 'Task';
        
    /*key prefix*/
        //public static string AccKeyPrefix = Shema.SObjectType.Account.getKeyPrefix();

    /*FieldValue/PicklistValue Variable : all variable containing picklist value should be defined as <ObjetAbb><FieldName><Value>*/
        public static string taskStatusClosed = 'Completed';
        public static string taskStatusOpen = 'Open';
        public static string taskStatusPending = 'Pending';
        public static string taskStatusInProgress = 'In progress';
        //public static string taskStatusOutOfTime = 'Out of time';// RANIELLO_V 26042016: EVO-52
        public static string taskStatusOutOfTime = 'Out of Time';
        public static string taskStatusInformationReceived = 'Information Received';// RANIELLO_V 27042016: EVO-52
    /*Recordtypes : all recordtype Developer name should be defined as rt<objectAbb><DeveloperName> */
        public static string rtTaskMotor= 'Motor_Task';
        public static string rtTaskNonMotor= 'Non_Motor_Task';
        public static string rtTaskQuadra= 'Quadra_Task';// PETRECCHIA_M 31082015: EVO-12
        public static string rtTaskAAI= 'AXA_Assicurazioni_Task';// MOSCATELLI_M 31082015: EVO-08
        public static string rtTaskCTL= 'Close_the_loop_Task';//MMOSCATELLI 08/02/2017: Close the loop ICF
        public static string rtTaskRetention = 'Retention_Task'; //CAPOBIANCO_A 16/05/2017 EVO 83: Retention
        public static string rtTaskAMF = 'AMPS_Financial_Task'; //CAPOBIANCO_A 22/08/2017 EVO 87: AMF
        public static string rtTaskSinistro='Sinistri_Danni_Task';//MOSCATELLI_M 09/04/2018: Apertura sinistri da email
        public static string rtTaskBuonLavoro='Buon_Lavoro_Task';//MOSCATELLI_M 03/07/2018: Easy Azienda
        public static string rtTaskAssistenzaAgenti='Assistenza_Agenti_Task';
        public static string rtTaskReclami = 'Reclami_Task';
        public static string rtTaskCaringAngel = 'Caring_Angel_Task';//OAVERSANO 07/12/2018 : Caring Angel
        public static string rtTaskAgenziaDipendenti = 'Agenzia_dipendenti_Task';//OAVERSANO 09/01/2019 : Agenzia diretta
        public static string rtTaskReclamo = 'Reclamo_Task';//OAVERSANO 15/01/2019 : Gestione Reclami
        public static string rtTaskSinistriAAI = 'Sinistri_AAI_Task'; //OAVERSANO 22/03/2019 : AXA Assistance
		public static string rtTaskDACAXAAgenzie= 'DAC_AXA_Agenti_Task'; //OAVERSANO 03/04/2019 : DAC Fase II 
       
    //OAVERSANO 10/07/2018: Close the loop ICF -- START 
    /*Tipo_Attivit__c : all value should be defined as Tipo_Attivit_<DeveloperName> */
        public static string Tipo_Attivit_Log_a_Call ='Log a Call';  
        public static string Tipo_Attivit_Task = 'Task';
        public static string Tipo_Attivit_Email = 'Email';
        public static string Tipo_Attivit_Log_a_Call_Red= 'Log a Call Red';
        public static string Tipo_Attivit_Email_Red= 'Email Red';
        public static string Tipo_Attivit_MyFox = 'MyFox';
        public static string Tipo_Attivit_BlueAss = 'BlueAss'; 
        public static string Tipo_Attivit_Retention_Yellow = 'Retention Yellow'; 
        public static string Tipo_Attivit_Retention_Red = 'Retention Red';
        public static string Tipo_Attivit_Retention_Green ='Retention Green';
        public static string Tipo_Attivit_AMF ='AMF';
        public static string Tipo_Attivit_Task_Interno ='Task Interno';             
    
    /*Type : all value should be defined as TypeTask<DeveloperName> */
        public static string TypeTaskSupportRequest ='Support Request';
            
    public static id rtTaskCTLId(){
        return ([Select Id From RecordType Where DeveloperName =:rtTaskCTL LIMIT 1].Id);
    }
    public static string rtCaseCloseTheLoopDeveloperName = 'Close_the_loop';
    
    public static string rtTaskMotorName= 'Motor Task';
    public static string rtTaskNonMotorName= 'Non-Motor Task';
    public static string rtTaskQuadraName= 'Quadra Task';
    public static string rtTaskAAIName= 'AXA Assicurazioni Task';
    public static string rtTaskCTLName= 'Close the loop Task';
    public static string rtTaskAMFName = 'AMPS Financial Task'; 
    public static string rtTaskSinistroName='Sinistri Danni Task';
    public static string rtTaskBuonLavoroName='Buon Lavoro Task';
    public static string rtTaskAssistenzaAgentiName= 'Assistenza Agenti';
    public static string rtTaskDACAXAAgenzieName= 'DAC AXA Agenti Task'; //OAVERSANO 03/04/2019 : DAC Fase II 
    
    public static string rtCaseMotorName= 'Motor';
    public static string rtCaseNonMotorName= 'Non Motor';
    public static string rtCaseQuadraname= 'Quadra';
    public static string rtCaseAAIName= 'Axa Assicurazioni';
    public static string rtCaseCloseTheLoopName = 'Close the loop';
    public static string rtCaseAMFName= 'AMPS Financial'; 
    public static string rtCaseSinistroName='Sinistri Danni Banca';
    public static string rtCaseBuonLavoroName='Buon Lavoro';
    public static string rtCaseAssistenzaAgentiName='Assistenza Agenti';

    public static id getRTTaskCTLId(String recordTypeCase){
        Map<String, String> RTTaskFromCase = new Map<String, String>{rtCaseCloseTheLoopName => rtTaskCTLName,
                                                                        rtCaseAMFName => rtTaskAMFName,
                                                                        rtCaseAAIName => rtTaskAAIName,
                                                                        rtCaseBuonLavoroName => rtTaskBuonLavoroName,
                                                                        rtCaseMotorName => rtTaskMotorName,
                                                                        rtCaseNonMotorName => rtTaskNonMotorName,
                                                                        rtCaseQuadraname => rtTaskQuadraName,
                                                                        rtCaseSinistroName => rtTaskSinistroName};
        if(RTTaskFromCase.get(recordTypeCase)!=null)
            return (Schema.SObjectType.Task.getRecordTypeInfosByName().get(RTTaskFromCase.get(recordTypeCase)).getRecordTypeId());
        else
            return null;
    }
    
    //OAVERSANO 10/07/2018: Close the loop ICF -- END   
    
    
/*OAVERSANO 09/07/2018: Close The Loop -- START*/
/***********************************************************************
* Lead constants
************************************************************************/  
    /*sobject*/
        public static string sobjectLead = 'Lead';
        
    /*LeadStatus*/
        public static String leadStatusDuplicate = 'Duplicated Lead';
        
    /*LeadQueue*/    
        public static String leadQueueWebDuplicati = 'Coda Lead Web Duplicati';

/*OAVERSANO 09/07/2018: Close The Loop -- END*/

/*OAVERSANO 24/07/2018: Nuovo Modello di Assistenza -- START*/
/***********************************************************************
* Storico Conversazioni constants
************************************************************************/  
    /*sobject*/
        public static string sobjectStoricoConversazioni = 'Storico_conversazioni__c';
        
    /*Storico_conversazioni__cStatus*/
        public static String stoConvTypeSoluzione = 'Soluzione proposta da HD';
        
    /*Storico_conversazioni__cRecordType*/
        public static String rtstoConvAgente = 'Agente';
        public static String rtstoConvSupporto = 'Supporto';


/***********************************************************************
* working Times constants
************************************************************************/  
    /*sobject*/
        public static string sobjectWorkingTimes = 'Working_Times__c';
        

        
    /*Storico_conversazioni__cRecordType*/
        public static String rtWorkTimCoda = 'Coda';
        public static String rtWorkTimUser = 'User';

/*OAVERSANO 24/07/2018: Nuovo Modello di Assistenza -- END*/
       
       
//MMOSCATELLI 03/05/2016: Evo 51 -- START
/***********************************************************************
* Insurance Policy constants
************************************************************************/  
    /*sobject*/
        public static string sobjectPolicy = 'InsurancePolicy__c';
        
    /*key prefix*/
        public static string PolicyKeyPrefix = Schema.SObjectType.InsurancePolicy__c.getKeyPrefix();

    /*FieldValue/PicklistValue Variable : all variable containing picklist value should be defined as <ObjetAbb><FieldName><Value>*/
        public static string PolicyTechCompanyAAI    = 'AAI';
        public static string PolicyTechCompanyMPS    = 'MPS';
        public static string PolicyTechCompanyQuadra = 'Quadra';
    /*Recordtypes : all recordtype Developer name should be defined as rt<objectAbb><DeveloperName> */
        public static string rtPolicyAuto    = 'B2C_Motor';
        public static string rtPolicyNonAuto = 'B2C_No_Motor';
        public static string rtPolicyGeneral = 'General_RecordType';
/***********************************************************************
* Claims constants
************************************************************************/  
    /*sobject*/
        public static string sobjectClaim = 'Claim__c';
        
    /*key prefix*/
        public static string ClaimKeyPrefix = Schema.SObjectType.Claim__c.getKeyPrefix();

    /*FieldValue/PicklistValue Variable : all variable containing picklist value should be defined as <ObjetAbb><FieldName><Value>*/
        public static string ClaimTechCompanyAAI    = 'AAI';
        public static string ClaimTechCompanyMPS    = 'MPS';
        public static string ClaimTechCompanyQuadra  = 'Quadra';
    /*Recordtypes : all recordtype Developer name should be defined as rt<objectAbb><DeveloperName> */
        public static string rtClaimsGeneral = 'Claim_Record_Type'; 
//MMOSCATELLI 03/05/2016: Evo 51 -- END   
/***********************************************************************
* User constants
************************************************************************/  
    /*sobject*/
        public static string sobjectUser = 'User';
        
    /*key prefix*/
        public static string UserKeyPrefix = Schema.SObjectType.User.getKeyPrefix();
        public static string QueueKeyPrefix = '00G';

    /*Recordtypes : all recordtype Developer name should be defined as rt<objectAbb><DeveloperName> */
        
    /*FieldValue/PicklistValue Variable : all variable containing picklist value should be defined as <ObjetAbb><FieldName><Value>*/

    /*Champ Generique: Champ à valeur unique <ObjetAbb><FieldName><Value> */
      
    /*FieldValue/PicklistValue Variable : all variable containing picklist value should be defined as <ObjetAbb><FieldName><Value>*/

    //MDANTONIO 19/02/2019: Eventi DIF -- START
    /***********************************************************************
    * Eventi DIF constants
    ************************************************************************/
    public enum EventoDIF {
        TRASFERIMENTO_TOTALE,
        SCORPORO_OLD_ATTIVA,
        SCORPORO_OLD_CESSATA
    }
    //MDANTONIO 19/02/2019: Eventi DIF -- END

/***********************************************************************
* Global Function
************************************************************************/

    public static boolean blockAttachmentInsert = true; 
    
    /*method to map corresponding record Type developper name to its respective record Type id*/
    public static map<String,Id> getDeveloperIdMap(String ObjecType){
    /*
     * Version : 1.0
     * Description : Generate a map that contains developer Name and id for a specific Sobject Type
     */     
        map <String,Id> developerIdMap = new map <String,Id>();
    
        //populating developerIdMap
        for(RecordType r : [select DeveloperName,Id
                                        from RecordType
                                        where SobjectType =: ObjecType ]){
            developerIdMap.put(r.DeveloperName,r.Id);
        }
        return developerIdMap;                  
    } 
    
    /*method to map corresponding record Type record id to its respective record Type developper name*/
    public static map<Id,String> getIdDeveloperMap(String ObjecType){
    /*
     * Version : 1.0
     * Description : Generate a map that contains id and developer Name for a specific Sobject Type
     */     
        map <Id,String> IdDeveloperMap = new map <Id,String>();
    
        //populating developerIdMap
        for(RecordType r : [select DeveloperName,Id
                                        from RecordType
                                        where SobjectType =: ObjecType ]){
            IdDeveloperMap.put(r.Id, r.DeveloperName);
        }
        return IdDeveloperMap;                  
    }  

/***********************************************************************
* Method to return a formatted query string with all the fields dynamically retrieved for the specified object 
************************************************************************/   
    /*    
    public static String formatQuery(String obj,String condition){
            
        Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe();
        Schema.SObjectType o = m.get(obj);
        list<Schema.SObjectField> fieldList = o.getDescribe().fields.getMap().values();
        
        String query = 'SELECT ';         
        for(Schema.SObjectField s : fieldList){
           //if(s.getDescribe().isUpdateable() || s.getDescribe().getName() == 'Name')
           query += s.getDescribe().getName() + ',';               
        } 
        query = query.removeEnd(','); 
        query += ' from ' + obj + ' where ' + condition + ' order by LastModifiedDate desc';
        
        system.debug('## query :' + query);
        
        return query;
        
    }   
    */
}
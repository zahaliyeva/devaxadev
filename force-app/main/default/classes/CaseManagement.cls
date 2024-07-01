/*------------------------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         CaseManagement
Description:   Apex class used to execute all the logics internal to the 
trigger related to the Case object

History

17/05/2018     Created 
-------------------------------------------------------------------------------------------*/
public class CaseManagement
{
    //OAVERSANO 27/07/2018: Nuovo Modello di Assistenza -- START    
    public static final String HD1Role = 'HD1';
    public static final String HD2Role = 'HD2';
    public static final String HD3Role = 'HD3';
    public static final String AgentRole = 'AGENT';
    //a.massarotti START
    private static Map<String,ID> MapCodaAgencyName = null;
    //a.massarotti END
    /*aggiunta code*/
    public static final String HD1QueueRole = 'Coda HD1';
    public static final String HD2QueueRole = 'Coda HD2';
    /*aggiunta code*/
    public static final String[] HDRoles = new String[]{'HD1','HD2'};
    public static final String AgentRoleTCR = 'Agente';//OAVERSANO 23/10/2018 : ICF Close The Loop
        public static final String[] ClosedStatusList = new String[]{AP_Constants.caseStatusChiusoInAutonomia, 
            AP_Constants.caseStatusRisoltoInAutonomia,
            AP_Constants.caseStatusClosed,
            AP_Constants.caseStatusOutOfTime,
            AP_Constants.caseStatusCancelled};
                @TestVisible private static Boolean runCaseManagementAfterUpdateFROMtest = false;
    //OAVERSANO 27/07/2018: Nuovo Modello di Assistenza -- END  
    public static List<Modello_di_Assistenza__mdt> mdAssListStatic = null; //BOVOLENTA_D 04042019 query reduction
    public static List<Caring_Angel__mdt> caringAngelList = null; //BOVOLENTA_D 04042019 query reduction
    public static List<Caring_Salute__mdt> caringSaluteList = null; //query reduction
    
    public class Outcome
    {
        public Set<Id> TaskToClose = new Set<id>();
        public Map<Id,Case> CasList = new Map<Id,Case>();
    }
    //BOVOLENTA_D 04042019 query reduction START
    //method to retrieve the correct values for the current custom setting
    public static List<SObject> retrieveCustomMetadataRecords (String metadataApiName, List<String> filters) 
    {
        //String metadataApiName = 'Modello_di_Assistenza__mdt';
        List<SObject> metadataSobjList = new List<SObject>();
        if(metadataApiName=='Modello_di_Assistenza__mdt' )
        {
            if( CaseManagement.mdAssListStatic == null)
            {
                mdAssListStatic= CaseManagement.metadataQueryHelper (metadataApiName);                
            }
            metadataSobjList = mdAssListStatic;
        }
        if(metadataApiName=='Caring_Angel__mdt')
        {
            if( CaseManagement.caringAngelList == null)
            {
                caringAngelList= CaseManagement.metadataQueryHelper (metadataApiName);
            }
            metadataSobjList = caringAngelList;
        }
        if(metadataApiName=='Caring_Salute__mdt')
        {
            if( CaseManagement.caringSaluteList == null)
            {
                caringSaluteList= CaseManagement.metadataQueryHelper (metadataApiName);
            }
            metadataSobjList = caringSaluteList;
        }
        if (filters.size()>0)
        {
            List<SObject> filteredMDT = new list<SObject>();
            //developerName - MDT Map
            Map<String,SObject> metaDataFilterMap = new Map<String,SObject>();
            for (SObject metaDataRecord :metadataSobjList)
            {
                metaDataFilterMap.put(''+metaDataRecord.get('DeveloperName'),metaDataRecord);
            }
            //filtering the results by developerName
            for (String developerNameValue :filters)
            {
                filteredMDT.add(metaDataFilterMap.get(developerNameValue));
            }
            return filteredMDT;
        }
        else
        {
            return metadataSobjList;
        }
    }
    public static List<SObject> metadataQueryHelper (String metadataApiName)
    {
        //DYNAMIC QUERY PART - RETRIEVE ALL FIELD FOR ALL RECORDS
        // Initialize setup variables
        String objectName = metadataApiName;  // modify as needed
        String query = 'SELECT ';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keySet()) {
             query += + s + ',';
        }
        query = query.removeEnd(',');
        system.debug('query'+query);
        // Add FROM statement
        query += ' FROM ' + objectName;
        List<SObject> sObjList = database.query(query);  
        return sObjList ;     
    }
    //BOVOLENTA_D 04042019 query reduction END

    
    //public static Outcome StatusModificationProcesses(List<String> CaseIdLst, List<Case> Cases, Map<String,Case> OldValues, String Entid, Map<String,Schema.RecordTypeInfo> MapCaseRecordType, String defaultHoursId, String GDPRHoursId, String EntGDPRId)
    //public static Outcome StatusModificationProcesses(List<String> CaseIdLst, List<Case> Cases, Map<String,Case> OldValues, String Entid, Map<String,Schema.RecordTypeInfo> MapCaseRecordType, String defaultHoursId, String GDPRHoursId, String EntGDPRId, Map<String,String> ownerIdProfileNameMap, Map<String,String> ownerIdRoleNameMap,Map<String,String> MapRecNameToDevelopername, Map<String,String> ownerIdNameMap)   //OAVERSANO 26/07/2018: Nuovo Modello di Assistenza
    public static Outcome StatusModificationProcesses(List<String> CaseIdLst, List<Case> Cases, Map<String,Case> OldValues, String Entid, Map<String,Schema.RecordTypeInfo> MapCaseRecordType, String defaultHoursId, String GDPRHoursId, String ICFAgentiHours, String EntGDPRId, String EntGDPRId2, String EntGDPRId3, String EntAssAgenti, String EntCaringAngel, String EntReclamo, Map<String,String> ownerIdProfileNameMap, Map<String,String> ownerIdRoleNameMap,Map<String,String> MapRecNameToDevelopername, Map<String,String> ownerIdNameMap)   //OAVERSANO 18/01/2019 : Gestione Reclami 
    {
        Outcome outc = new Outcome();
        
        if(CaseHandler.firstRunStatus)
        {
            system.debug('StatusModificationProcesses: START');
            
            String[] types = new String[]{'Case'}; 
                List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types);
            Set<String> SetCaseCatToCloseTask = new Set<String>();
            Map<String,Long_Term_Management_Alerts__c> LongTermManagementMap = new map<String,Long_Term_Management_Alerts__c>();
            Map<String,Amministrazione_Chiusura_Automatica_Case__c> CaseAutomaticClosureMap = new map<String,Amministrazione_Chiusura_Automatica_Case__c>();
            list<Case> listCaseAP01 = new list<Case>();
            list<Case> listCaseAP01SLA = new list<Case>();
            map<Id,String> mapCaseIdOldStatus = new map<Id,String>();
            Set<String> AttDispConfigSet = new Set<String>();
            Map<String,Decimal> MapAttDispToDaysNum = new Map<String,Decimal>();
            Set<Id> idListTaskToClose = new Set<Id>();
            List<Task> OpenTasksList = New List<Task>();
            String Error = ''; 
            Map<String,String> OpenTaskMap = new Map<String,String>();
            Set<String> stopStatusSet = new Set<String>();
            Set<String> closedStatusSet = new Set<String>();
            List<String> GDPRCategories = new List<String>();
          
            //OAVERSANO 18/01/2019 : Gestione Reclami -- START
            List<Case> CaseListAP01 = new List<Case>();
            Set<String> devNamerecordTypeRecalculateAP01Set = new Set<String>(); 
            if(MPS_Code_Variables__c.getValues('devRecordTypeToRecalculateAP01')!=null)
            {
                if(String.isNotBlank(MPS_Code_Variables__c.getValues('devRecordTypeToRecalculateAP01').value__c))
                {
                    for(String s:(MPS_Code_Variables__c.getValues('devRecordTypeToRecalculateAP01').value__c).split(';'))
                    {
                        devNamerecordTypeRecalculateAP01Set.add(s);                
                    }
                }
            }
            //OAVERSANO 18/01/2019 : Gestione Reclami -- END
            
            
            for(MPS_Code_Variables__c MPSCv: MPS_Code_Variables__c.getAll().values())
            {
                if((MPSCv.Name).contains('GDPR_Category'))
                    GDPRCategories.add(MPSCv.Value__c);
            }    
            
            for (Stop_Status__c stopStatus:[Select Name From Stop_Status__c where Object_Type__c = 'Case' ]) // NOPMD  Fix CRUD violation
            {
                stopStatusSet.add(stopStatus.Name);
            }
            
            for (CaseStatus status:[Select MasterLabel From CaseStatus where IsClosed=true ]) // NOPMD  Fix CRUD violation
            {
                closedStatusSet.add(status.MasterLabel);
            }
            
            for(Task t : [Select Id,WhatId FROM Task WHERE WhatId in:CaseIdLst AND IsClosed <> true AND HierarchyLevel1__c <> null])
            {
                OpenTasksList.add(t);
                OpenTaskMap.put(t.WhatId,t.Id);
            }
            
           
                        
            
            for(CaseCategoryToCloseTask__c category : CaseCategoryToCloseTask__c.getAll().values())
            {               
                SetCaseCatToCloseTask.add(category.Category__c+'|'+((category.SubCategory__c<>'' && category.SubCategory__c <> null)?category.SubCategory__c:'All'));
            }
            
            for(Configurazione_attivita_dispositive__c AttDispConfig: Configurazione_attivita_dispositive__c.getAll().values())
            {
                AttDispConfigSet.add(AttDispConfig.Category__c+'|'+AttDispConfig.SubCategory__c);
                MapAttDispToDaysNum.put(AttDispConfig.Category__c+'|'+AttDispConfig.SubCategory__c, AttDispConfig.Days_until_verification__c);
            }
            /*
            for(CaseCategoryToCloseTask__c category : CaseCategoryToCloseTask__c.getAll().values())
            {               
                SetCaseCatToCloseTask.add(category.Category__c+'|'+((category.SubCategory__c<>'' && category.SubCategory__c <> null)?category.SubCategory__c:'All'));
            }
            */
            for(Configurazione_SLA_Case__c Config : [SELECT Id,Case_Origin__c,Case_Record_Type__c,Category__c,Sub_Category__c,(SELECT Caller__c,Days_number_until_first_alert__c,Days_number_until_second_alert__c,Days_number_until_third_alert__c,Rule_Active__c FROM Long_Term_Management_Alerts__r where Rule_Active__c = true), (SELECT Caller__c,Days_number_until_automatic_closure__c,Days_number_until_first_alert__c FROM Amministrazione_Chiusura_Automatica_Case__r where Rule_Active__c = true) FROM Configurazione_SLA_Case__c where Rule_Active__c = true ]) // NOPMD  Fix CRUD violation
            {   
                List<Long_Term_Management_Alerts__c> LongTermManagementConf = new list<Long_Term_Management_Alerts__c>(Config.Long_Term_Management_Alerts__r);
                List<Amministrazione_Chiusura_Automatica_Case__c> AutomaticClosureManagementConf = new list<Amministrazione_Chiusura_Automatica_Case__c>(Config.Amministrazione_Chiusura_Automatica_Case__r);           
                
                if(!LongTermManagementConf.isEmpty())
                {
                    for(integer iconfAl=0;iconfAl<LongTermManagementConf.size();iconfAl++)
                    {
                        LongTermManagementMap.put(Config.Category__c+'-'+Config.Sub_Category__c+'-'+Config.Case_Origin__c+'-'+Config.Case_Record_Type__c+'-'+LongTermManagementConf[iconfAl].Caller__c, LongTermManagementConf[iconfAl]);
                    }
                }
                
                if(!AutomaticClosureManagementConf.isEmpty())
                {
                    for(integer iconfAc=0;iconfAc<AutomaticClosureManagementConf.size();iconfAc++)
                    {
                        CaseAutomaticClosureMap.put(Config.Category__c+'-'+Config.Sub_Category__c+'-'+Config.Case_Origin__c+'-'+Config.Case_Record_Type__c+'-'+AutomaticClosureManagementConf[iconfAc].Caller__c, AutomaticClosureManagementConf[iconfAc]);
                    }            
                }
            }           
            //OAVERSANO 15/10/2018 : Caring Angel -- START
            List<String> recTypeCAList = new List<String>();
            if(MPS_Code_Variables__c.getValues('RecordTypeCaringAngel')!=null)
            {
                if(String.isNotBlank(MPS_Code_Variables__c.getValues('RecordTypeCaringAngel').value__c))
                {
                    for(String s:(MPS_Code_Variables__c.getValues('RecordTypeCaringAngel').value__c).split(';'))
                    {
                        recTypeCAList.add(s);                
                    }
                }
            }
            List<Case> caseCAList = new List<Case>();
            for(Case cs:Cases){
                if(recTypeCAList.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(cs.RecordTypeId).getName())))
                {
                    caseCAList.add(cs);
                }
                
            }
            //OAVERSANO 15/10/2018 : Caring Angel -- END
            
            //OAVERSANO 19/03/2019 : AXA Assistance -- START
            List<String> recTypeSinistriList = new List<String>();
            if(MPS_Code_Variables__c.getValues('RecordTypeSinitri')!=null)
            {
                if(String.isNotBlank(MPS_Code_Variables__c.getValues('RecordTypeSinitri').value__c))
                {
                    for(String s:(MPS_Code_Variables__c.getValues('RecordTypeSinitri').value__c).split(';'))
                    {
                        recTypeSinistriList.add(s);                
                    }
                }
            }
            List<Case> caseSinistriList = new List<Case>();
            for(Case cs:Cases){
                if(recTypeSinistriList.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(cs.RecordTypeId).getName())))
                {
                    caseSinistriList.add(cs);
                }
                
            }
            Set<String> axaAssistanceProfileSet = new Set<String>();
            Set<String> axaAssistanceQueueSet = new Set<String>();
            Set<String> customerOperationProfileSet = new Set<String>();
            Set<String> customerOperationQueueSet = new Set<String>();
            Set<String> RecordTypeSinistriSet = new Set<String>();
            List<String> sinistriRemindersList = new List<String>();
            Decimal sollecitoAdvisorBH = 0;
            //OAVERSANO 19/03/2019 : AXA Assistance -- END
            
            //OAVERSANO 20/07/2018: Nuovo Modello di Assistenza -- START  
            //OAVERSANO 12/09/2018: Nuovo Modello di Assistenza -- START 
            List<String> recTypeList = new List<String>();
            if(MPS_Code_Variables__c.getValues('RecordTypeAssistenzaAgenti')!=null)
            {
                if(String.isNotBlank(MPS_Code_Variables__c.getValues('RecordTypeAssistenzaAgenti').value__c))
                {
                    for(String s:(MPS_Code_Variables__c.getValues('RecordTypeAssistenzaAgenti').value__c).split(';'))
                    {
                        recTypeList.add(s);                
                    }
                }
            }
            List<Case> caseList = new List<Case>();
            for(Case cs:Cases){
                if(recTypeList.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(cs.RecordTypeId).getName())))
                {
                    caseList.add(cs);
                }
                
            }
            Set<String> caseWithTaskCall = new Set<String>(); 
            Set<String> caseWithStoConv = new Set<String>();
            Set<String> AgentProfileSet = new Set<String>();
            Set<String> HD1ProfileSet = new Set<String>();
            Set<String> HD1QueueSet = new Set<String>();
            Set<String> HD2ProfileSet = new Set<String>();
            Set<String> HD2QueueSet = new Set<String>();
            Set<String> RecordTypeSet = new Set<String>();
            //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- START 
            Set<String> HD1BIZProfileSet = new Set<String>();
            Set<String> HD1BIZQueueSet = new Set<String>();
            Set<String> HD2BIZProfileSet = new Set<String>();
            Set<String> HD2BIZQueueSet = new Set<String>();
            //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- END 
            //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
            Set<String> HD1ContabilitaProfileSet = new Set<String>();
            Set<String> HD1ContabilitaQueueSet = new Set<String>();
            Set<String> HD1ContabilitaRoleSet = new Set<String>();
            Set<String> HD1ContenziosoProfileSet = new Set<String>();
            Set<String> HD1ContenziosoQueueSet = new Set<String>();
            Set<String> HD1ContenziosoRoleSet = new Set<String>();
            //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
            //MDANTONIO 08/05/2019: LOB VITA - start
            Map<String, String> categorySubcategoryToQueue = new Map<String, String>();
            //MDANTONIO 08/05/2019: LOB VITA - end
            //OAVERSANO 22/11/2018 : Nuovo Modello di Assistenza FIX ProcessBuilder -- START
            Decimal primoSollecito = 0;
            Decimal secondoSollecito = 0;
            Decimal terzoSollecito = 0;
            Decimal primoSollecitoSolPro = 0;
            //OAVERSANO 22/11/2018 : Nuovo Modello di Assistenza FIX ProcessBuilder -- END
            //OAVERSANO 12/12/2018 : Enhancement NMA Biz -- START
            Map<String,List<String>> memberQueuesListMap = new Map<String,List<String>>(); 
            List<String> queueNameSet = new List<String>();
            if(MPS_Code_Variables__c.getValues('NMABizSupportoCode')!=null) //custom setting used to store the name of the queues.
            {
                if(String.isNotBlank(MPS_Code_Variables__c.getValues('NMABizSupportoCode').value__c))
                {
                    for(String s:(MPS_Code_Variables__c.getValues('NMABizSupportoCode').value__c).split(';'))
                    {   
                        //MDANTONIO 08/05/2019: LOB VITA - start
                        //queueNameSet.add(s);     
                        queueNameSet.add('HD2 Biz ' + s);
                        //MDANTONIO 08/05/2019: LOB VITA - end
                    }
                }
            }
            String HD2BizAuto = '';
            String HD2BizFamiglia = '';
            String HD2BizSalute = '';
            //MDANTONIO 08/05/2019: LOB VITA - start
            String HD2BizVitaAssunzione = '';
            String HD2BizVitaContabilitaPrevidenza = '';
            String HD2BizVitaLiquidazioni = '';
            String HD2BizVitaPtfCollettive = '';
            String HD2BizVitaPtfIndividualiRispeProt = '';
            String HD2BizVitaPtfPrevidenza = '';
            String HD2BizVitaSinistriRispeProt = '';
            //MDANTONIO 08/05/2019: LOB VITA - end
            if(!queueNameSet.isEmpty())
            {
                HD2BizAuto = queueNameSet[0]; //HD2 Biz Auto
                HD2BizFamiglia = queueNameSet[1]; //HD2 Biz Famiglia
                HD2BizSalute = queueNameSet[2]; //HD2 Biz Salute
                //MDANTONIO 08/05/2019: LOB VITA - start
                HD2BizVitaAssunzione = queueNameSet[3]; //HD2 Biz Vita Assunzione
                HD2BizVitaContabilitaPrevidenza = queueNameSet[4]; //HD2 Biz Vita Contabilità Previdenza
                HD2BizVitaLiquidazioni = queueNameSet[5]; //HD2 Biz Vita Liquidazioni
                HD2BizVitaPtfCollettive = queueNameSet[6]; //HD2 Biz Vita Ptf Collettive
                HD2BizVitaPtfIndividualiRispeProt = queueNameSet[7]; //HD2 Biz Vita Ptf Individuali Risp e Prot
                HD2BizVitaPtfPrevidenza = queueNameSet[8]; //HD2 Biz Vita Ptf Previdenza
                HD2BizVitaSinistriRispeProt = queueNameSet[9]; //HD2 Biz Vita Sinistri Risp. e Prot.
                //MDANTONIO 08/05/2019: LOB VITA - end
            }
            Set<String> HD2BizAutoMember = new Set<String>();
            Set<String> HD2BizFamigliaMember = new Set<String>();
            Set<String> HD2BizSaluteMember = new Set<String>();
            //MDANTONIO 08/05/2019: LOB VITA - start
            Set<String> HD2BizVitaAssunzioneMember = new Set<String>();
            Set<String> HD2BizVitaContabilitaPrevidenzaMember = new Set<String>();
            Set<String> HD2BizVitaLiquidazioniMember = new Set<String>();
            Set<String> HD2BizVitaPtfCollettiveMember = new Set<String>();
            Set<String> HD2BizVitaPtfIndividualiRispeProtMember = new Set<String>();
            Set<String> HD2BizVitaPtfPrevidenzaMember = new Set<String>();
            Set<String> HD2BizVitaSinistriRispeProtMember = new Set<String>();
            //MDANTONIO 08/05/2019: LOB VITA - end
            //OAVERSANO 12/12/2018 : Enhancement NMA Biz -- END
            if(!caseList.isEmpty())
            {
                //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                /*Modello_di_Assistenza__mdt mdAss = [SELECT Id, DeveloperName,AgentProfile__c, CaseTriggerRecordType__c,
                                                    HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c,
                                                    HD1BIZProfile__c, HD1BIZQueue__c, HD2BIZProfile__c, HD2BIZQueue__c //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84
                                                    FROM Modello_di_Assistenza__mdt 
                                                    WHERE DeveloperName  = 'ProfileManagement'
                                                    LIMIT 1];*/
                
                //BOVOLENTA_D 04042019 query reduction START
                //MDANTONIO 08/05/2019: LOB VITA - start
                //List<String> filters = new list<String>{'ProfileManagement','HD1ContabilitaProfile','HD1ContabilitaRole','HD1ContabilitaQueue','HD1ContenziosoProfile','HD1ContenziosoRole','HD1ContenziosoQueue'};
                List<String> filters = new list<String>{'ProfileManagement','HD1ContabilitaProfile','HD1ContabilitaRole','HD1ContabilitaQueue','HD1ContenziosoProfile','HD1ContenziosoRole','HD1ContenziosoQueue','HD2BizVitaAssunzione','HD2BizVitaContabilitaPrevidenza','HD2BizVitaLiquidazioni01','HD2BizVitaLiquidazioni02','HD2BizVitaPtfCollettive','HD2BizVitaPtfIndividuali','HD2BizVitaPtfPrevidenza','HD2BizVitaSPR'};
                //MDANTONIO 08/05/2019: LOB VITA - end
                List<Modello_di_Assistenza__mdt> mdAssList =CaseManagement.retrieveCustomMetadataRecords('Modello_di_Assistenza__mdt',filters);
                /*List<Modello_di_Assistenza__mdt> mdAssList = [SELECT Id, DeveloperName,AgentProfile__c, CaseTriggerRecordType__c,
                                                    HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c,
                                                    HD1BIZProfile__c, HD1BIZQueue__c, HD2BIZProfile__c, HD2BIZQueue__c, Value__c
                                                    FROM Modello_di_Assistenza__mdt 
                                                    WHERE DeveloperName IN ('ProfileManagement','HD1ContabilitaProfile','HD1ContabilitaRole','HD1ContabilitaQueue','HD1ContenziosoProfile','HD1ContenziosoRole','HD1ContenziosoQueue')
                                                    ];
                //BOVOLENTA_D 04042019 query reduction END */
                if(!mdAssList.isEmpty())
                {
                    for(Modello_di_Assistenza__mdt mdAss: mdAssList)
                    {
                        if(mdAss.DeveloperName == 'ProfileManagement')
                        {
                            if(String.isNotBlank(mdAss.AgentProfile__c))
                                for(String s:mdAss.AgentProfile__c.split(';'))
                                AgentProfileSet.add(s);   
                            if(String.isNotBlank(mdAss.HD1Profile__c))
                                for(String s:mdAss.HD1Profile__c.split(';'))
                                HD1ProfileSet.add(s);   
                            if(String.isNotBlank(mdAss.HD1Queue__c))
                                for(String s:mdAss.HD1Queue__c.split(';'))
                                HD1QueueSet.add(s);   
                            if(String.isNotBlank(mdAss.HD2Profile__c))
                                for(String s:mdAss.HD2Profile__c.split(';'))
                                HD2ProfileSet.add(s);   
                            if(String.isNotBlank(mdAss.HD2Queue__c))
                                for(String s:mdAss.HD2Queue__c.split(';'))
                                HD2QueueSet.add(s);  
                            //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- START
                            if(String.isNotBlank(mdAss.HD1BIZProfile__c))
                                for(String s:mdAss.HD1BIZProfile__c.split(';'))
                                HD1BIZProfileSet.add(s);   
                            if(String.isNotBlank(mdAss.HD1BIZQueue__c))
                                for(String s:mdAss.HD1BIZQueue__c.split(';'))
                                HD1BIZQueueSet.add(s);   
                            if(String.isNotBlank(mdAss.HD2BIZProfile__c))
                                for(String s:mdAss.HD2BIZProfile__c.split(';'))
                                HD2BIZProfileSet.add(s);   
                            if(String.isNotBlank(mdAss.HD2BIZQueue__c))
                                for(String s:mdAss.HD2Queue__c.split(';'))
                                HD2BIZQueueSet.add(s);  
                            //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- END
                            if(String.isNotBlank(mdAss.CaseTriggerRecordType__c))
                                for(String s:mdAss.CaseTriggerRecordType__c.split(';'))
                                RecordTypeSet.add(s);  
                        }
                        else if(mdAss.DeveloperName == 'HD1ContabilitaProfile')
                        {
                            if(String.isNotBlank(mdAss.Value__c))
                            {
                                for(String s:mdAss.Value__c.split(';'))
                                {
                                    HD1ContabilitaProfileSet.add(s);  
                                }
                            }
                        }
                        else if(mdAss.DeveloperName == 'HD1ContabilitaRole')
                        {
                            if(String.isNotBlank(mdAss.Value__c))
                            {
                                for(String s:mdAss.Value__c.split(';'))
                                {
                                    HD1ContabilitaRoleSet.add(s);
                                }
                            }
                        }
                        else if(mdAss.DeveloperName == 'HD1ContenziosoProfile')
                        {
                            if(String.isNotBlank(mdAss.Value__c))
                            {
                                for(String s:mdAss.Value__c.split(';'))
                                {
                                    HD1ContenziosoProfileSet.add(s);
                                }
                            }
                        }
                        else if(mdAss.DeveloperName == 'HD1ContenziosoRole')
                        {
                            if(String.isNotBlank(mdAss.Value__c))
                            {
                                for(String s:mdAss.Value__c.split(';'))
                                {
                                    HD1ContenziosoRoleSet.add(s);
                                }
                            }
                        }
                        else if(mdAss.DeveloperName == 'HD1ContabilitaQueue')
                        {
                            if(String.isNotBlank(mdAss.Value__c))
                            {
                                for(String s:mdAss.Value__c.split(';'))
                                {
                                    HD1ContabilitaQueueSet.add(s);
                                }
                            }
                        }
                        else if(mdAss.DeveloperName == 'HD1ContenziosoQueue')
                        {
                            if(String.isNotBlank(mdAss.Value__c))
                            {
                                for(String s:mdAss.Value__c.split(';'))
                                {
                                    HD1ContenziosoQueueSet.add(s);
                                }
                            }
                        }
                        //MDANTONIO 08/05/2019: LOB VITA - start
                        else if(mdAss.DeveloperName == 'HD2BizVitaAssunzione' || mdAss.DeveloperName == 'HD2BizVitaContabilitaPrevidenza' || mdAss.DeveloperName == 'HD2BizVitaLiquidazioni01' || mdAss.DeveloperName == 'HD2BizVitaLiquidazioni02' || mdAss.DeveloperName == 'HD2BizVitaPtfCollettive' || mdAss.DeveloperName == 'HD2BizVitaPtfIndividuali' || mdAss.DeveloperName == 'HD2BizVitaPtfPrevidenza' || mdAss.DeveloperName == 'HD2BizVitaSPR'){
                            if(String.isNotBlank(mdAss.Value__c)){
                                if(mdAss.Sotto_categoria__c != null){
                                    categorySubcategoryToQueue.put(mdAss.Categoria__c + '_' + mdAss.Sotto_categoria__c, mdAss.Value__c);
                                }
                                else{
                                    categorySubcategoryToQueue.put(mdAss.Categoria__c, mdAss.Value__c);
                                }
                            }
                        }
                        //MDANTONIO 08/05/2019: LOB VITA - end
                    }      
                    //OAVERSANO 22/11/2018 : Nuovo Modello di Assistenza FIX ProcessBuilder -- START
                    List<String> remindersList = new List<String>();
                    if(MPS_Code_Variables__c.getValues('NMASollecitiAgenti')!=null)
                    {
                        if(String.isNotBlank(MPS_Code_Variables__c.getValues('NMASollecitiAgenti').value__c))
                        {
                            for(String s:(MPS_Code_Variables__c.getValues('NMASollecitiAgenti').value__c).split(';'))
                            {
                                remindersList.add(s);                
                            }
                        }
                    }
                    if(!remindersList.isEmpty())
                    {
                        primoSollecito = Decimal.valueOf(remindersList[0]);
                        secondoSollecito = Decimal.valueOf(remindersList[1]);
                        terzoSollecito = Decimal.valueOf(remindersList[2]);
                    }
                    List<String> remindersSolProList = new List<String>();
                    if(MPS_Code_Variables__c.getValues('NMASollecitiSoluzioneAgenti')!=null)
                    {
                        if(String.isNotBlank(MPS_Code_Variables__c.getValues('NMASollecitiSoluzioneAgenti').value__c))
                        {
                            for(String s:(MPS_Code_Variables__c.getValues('NMASollecitiSoluzioneAgenti').value__c).split(';'))
                            {
                                remindersSolProList.add(s);                
                            }
                        }
                    }
                    if(!remindersSolProList.isEmpty())
                    {
                        primoSollecitoSolPro = Decimal.valueOf(remindersSolProList[0]);
                    }
                    //OAVERSANO 22/11/2018 : Nuovo Modello di Assistenza FIX ProcessBuilder -- END
                }
                
                //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
                
                /*for(Task t : [SELECT Id, WhatId, Tipo_Attivit__c
                              FROM Task 
                              WHERE WhatId in:caseList 
                              AND Tipo_Attivit__c =: AP_Constants.Tipo_Attivit_Log_a_Call
                              AND What.RecordType.Name = :AP_Constants.rtTaskAssistenzaAgentiName ])
                {
                    caseWithTaskCall.add(t.WhatId);
                }*/
                
                //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza -- START
                
                //OAVERSANO 12/12/2018 : Enhancement NMA Biz -- START
                Map<String, String> queueidNameMap = new Map<String, String>();
                List<GroupMember> membershipQueueUser = [SELECT Id, Group.Id, Group.Name, UserOrGroupId FROM GroupMember WHERE Group.Name LIKE '%HD2%' AND Group.Type = 'Queue' ]; // NOPMD  Fix CRUD violation
                Map<String, List<String>> queueNameMemberMap = new Map<String, List<String>>();
                for(GroupMember grM : membershipQueueUser)
                {
                    queueidNameMap.put(grM.Group.Name, grM.Group.Id);
                    if(queueNameMemberMap.containsKey(grM.Group.Name))
                    {   
                        List<String> queueNameMemberList = queueNameMemberMap.get(grM.Group.Name);
                        queueNameMemberList.add(grM.UserOrGroupId);
                        queueNameMemberMap.put(grM.Group.Name, queueNameMemberList);
                    } 
                    else 
                    {
                        queueNameMemberMap.put(grM.Group.Name, new List<String> { grM.UserOrGroupId }); 
                    }
                }
                //system.debug('queueNameMemberMap: '+JSON.serializePretty(queueNameMemberMap));
                for(String queueName:queueNameMemberMap.keySet())
                {
                    if(queueName.equalsIgnoreCase(HD2BizAuto))
                    {
                        HD2BizAutoMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizAutoMember.add(queueidNameMap.get(queueName));
                    }
                    if(queueName.equalsIgnoreCase(HD2BizFamiglia))
                    {
                        HD2BizFamigliaMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizFamigliaMember.add(queueidNameMap.get(queueName));
                    }
                    //MDANTONIO 08/05/2019: LOB VITA - start
                    if(queueName.equalsIgnoreCase(HD2BizVitaAssunzione))
                    {
                        HD2BizVitaAssunzioneMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizVitaAssunzioneMember.add(queueidNameMap.get(queueName));
                    }
                    if(queueName.equalsIgnoreCase(HD2BizVitaContabilitaPrevidenza))
                    {
                        HD2BizVitaContabilitaPrevidenzaMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizVitaContabilitaPrevidenzaMember.add(queueidNameMap.get(queueName));
                    }
                    if(queueName.equalsIgnoreCase(HD2BizVitaLiquidazioni))
                    {
                        HD2BizVitaLiquidazioniMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizVitaLiquidazioniMember.add(queueidNameMap.get(queueName));
                    }
                    if(queueName.equalsIgnoreCase(HD2BizVitaPtfCollettive))
                    {
                        HD2BizVitaPtfCollettiveMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizVitaPtfCollettiveMember.add(queueidNameMap.get(queueName));
                    }
                    if(queueName.equalsIgnoreCase(HD2BizVitaPtfIndividualiRispeProt))
                    {
                        HD2BizVitaPtfIndividualiRispeProtMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizVitaPtfIndividualiRispeProtMember.add(queueidNameMap.get(queueName));
                    }
                    if(queueName.equalsIgnoreCase(HD2BizVitaPtfPrevidenza))
                    {
                        HD2BizVitaPtfPrevidenzaMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizVitaPtfPrevidenzaMember.add(queueidNameMap.get(queueName));
                    }
                    if(queueName.equalsIgnoreCase(HD2BizVitaSinistriRispeProt))
                    {
                        HD2BizVitaSinistriRispeProtMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizVitaSinistriRispeProtMember.add(queueidNameMap.get(queueName));
                    }
                    //MDANTONIO 08/05/2019: LOB VITA - end
                }
                //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- END
            }
            
            //OAVERSANO 12/09/2018: Nuovo Modello di Assistenza -- END 
            system.debug('CASES : '+Cases);
            //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza -- END
            
            //OAVERSANO 15/10/2018 : Caring Angel -- START
            if(!caseCAList.isEmpty())
            {
                //BOVOLENTA_D 04042019 query reduction START
                List<String> filters = new list<String>{'ProfileManagement'};
                List<Caring_Angel__mdt> caringAngelList =CaseManagement.retrieveCustomMetadataRecords('Caring_Angel__mdt',filters);
                Caring_Angel__mdt caringAngel;
                if(caringAngelList.size()>0)
                    caringAngel=caringAngelList[0];
                /*Caring_Angel__mdt caringAngel = [SELECT Id, DeveloperName, CaseTriggerRecordType__c,
                                                    HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c 
                                                    FROM Caring_Angel__mdt 
                                                    WHERE DeveloperName  = 'ProfileManagement'
                                                    LIMIT 1];
                //BOVOLENTA_D 04042019 query reduction END */

                if(caringAngel!=null)
                {
                    if(String.isNotBlank(caringAngel.HD1Profile__c))
                        for(String s:caringAngel.HD1Profile__c.split(';'))
                        HD1ProfileSet.add(s);   
                    if(String.isNotBlank(caringAngel.HD1Queue__c))
                        for(String s:caringAngel.HD1Queue__c.split(';'))
                        HD1QueueSet.add(s);   
                    if(String.isNotBlank(caringAngel.HD2Profile__c))
                        for(String s:caringAngel.HD2Profile__c.split(';'))
                        HD2ProfileSet.add(s);   
                    if(String.isNotBlank(caringAngel.HD2Queue__c))
                        for(String s:caringAngel.HD2Queue__c.split(';'))
                        HD2QueueSet.add(s);  
                    if(String.isNotBlank(caringAngel.CaseTriggerRecordType__c))
                        for(String s:caringAngel.CaseTriggerRecordType__c.split(';'))
                        RecordTypeSet.add(s);  
                }
            }
            //OAVERSANO 15/10/2018 : Caring Angel -- END
            
            //OAVERSANO 19/03/2019 : AXA Assistance -- START
            if(!caseSinistriList.isEmpty())
            {
                List<Assistenza_sinistri__mdt> assSinList = [SELECT Id, DeveloperName, Value__c // NOPMD  Fix CRUD violation
                                FROM Assistenza_sinistri__mdt 
                                WHERE DeveloperName LIKE 'claimProfileManagement%'
                                ];
                
                for(Assistenza_sinistri__mdt assSin : assSinList)
                {
                    if(assSin.DeveloperName == 'claimProfileManagementAAProfiles')
                    {
                        if(String.isNotBlank(assSin.Value__c))
                        {
                            for(String s:assSin.Value__c.split(';'))
                            {
                                axaAssistanceProfileSet.add(s); 
                            }  
                        }
                    }
                    else if(assSin.DeveloperName == 'claimProfileManagementAAQueues')
                    {
                        if(String.isNotBlank(assSin.Value__c))
                        {
                            for(String s:assSin.Value__c.split(';'))
                            {
                                axaAssistanceQueueSet.add(s); 
                            }
                        }
                    }
                    else if(assSin.DeveloperName == 'claimProfileManagementCOProfiles')
                    {
                        if(String.isNotBlank(assSin.Value__c))
                        {
                            for(String s:assSin.Value__c.split(';'))
                            {
                                customerOperationProfileSet.add(s); 
                            }
                        }
                    }
                    else if(assSin.DeveloperName == 'claimProfileManagementCOQueues')
                    {
                        if(String.isNotBlank(assSin.Value__c))
                        {
                            for(String s:assSin.Value__c.split(';'))
                            {
                                customerOperationQueueSet.add(s);  
                            }
                        }
                    }
                    else if(assSin.DeveloperName == 'claimProfileManagementRecordTypes')
                    {
                        if(String.isNotBlank(assSin.Value__c))
                        {
                            for(String s:assSin.Value__c.split(';'))
                            {
                                RecordTypeSinistriSet.add(s);
                            }
                        }
                    }
                    else if(assSin.DeveloperName == 'claimProfileManagementSollecito')
                    {
                        if(String.isNotBlank(assSin.Value__c))
                        {
                            for(String s:assSin.Value__c.split(';'))
                            {
                                sinistriRemindersList.add(s);
                            }
                        }
                    }
                }
            }
            if(!sinistriRemindersList.isEmpty())
            {
                sollecitoAdvisorBH = Decimal.valueOf(sinistriRemindersList[0]);
            }
            //OAVERSANO 19/03/2019 : AXA Assistance -- END
            
            Decimal PrimoSollecitoAgente = 0;
            Decimal SecondoSollecitoAgente = 0;
            Decimal TerzoSollecitoAgente = 0;
            Decimal PrimoSollecitoAgenzia = 0;
            Decimal SecondoSollecitoAgenzia = 0;
            List<String> remindersListAgente = new List<String>();
                    if(MPS_Code_Variables__c.getValues('Ivass41Solleciti')!=null)
                    {
                        if(String.isNotBlank(MPS_Code_Variables__c.getValues('Ivass41Solleciti').value__c))
                        {
                            for(String s:(MPS_Code_Variables__c.getValues('Ivass41Solleciti').value__c).split(';'))
                            {
                                remindersListAgente.add(s);                
                            }
                        }
                    }
                    if(!remindersListAgente.isEmpty())
                    {
                        PrimoSollecitoAgenzia = Decimal.valueOf(remindersListAgente[0]);
                        SecondoSollecitoAgenzia = Decimal.valueOf(remindersListAgente[1]);
                        primoSollecitoAgente = Decimal.valueOf(remindersListAgente[2]);
                        secondoSollecitoAgente = Decimal.valueOf(remindersListAgente[3]);
                        terzoSollecitoAgente = Decimal.valueOf(remindersListAgente[4]);
                    }
            
            for(Case c: Cases)
            {
                //OAVERSANO 21/08/2018: Nuovo Modello di Assistenza -- START
                //MASSAROTTI ANTONINO 30/11/2019 -- START
                
                if(MapCaseRecordType.containsKey(c.RecordTypeId) && MapCaseRecordType.get(c.RecordTypeId).getDeveloperName().equals(AP_Constants.rtCaseAAI)){
                    if((c.status == AP_Constants.caseStatusGestioneAgente || c.status == AP_Constants.caseStatusInformationReceived)){
                        system.debug('****Preso in carico');
                        c.TECH_Primo_Sollecito_Agenti__c = BusinessHours.addGMT(defaultHoursId,System.now(),((primoSollecitoAgente)*60 * 60 * 1000L).longValue());
                        c.TECH_Secondo_Sollecito_Agenti__c = BusinessHours.addGMT(defaultHoursId,System.now(),((secondoSollecitoAgente)*60 * 60 * 1000L).longValue());
                        c.TECH_Terzo_Sollecito_Agenti__c = BusinessHours.addGMT(defaultHoursId,System.now(),((terzoSollecitoAgente)*60 * 60 * 1000L).longValue());
                    	c.SollecitoPeriodico20ore__c = null;
                    }
                    else if (c.status == AP_Constants.caseStatusClosed){
                        system.debug('****Chiuso');
                        c.TECH_Primo_Sollecito_Agenti__c = null;
                        c.TECH_Secondo_Sollecito_Agenti__c = null;
                        c.TECH_Terzo_Sollecito_Agenti__c = null;
                        c.SollecitoPeriodico20ore__c = null;
                    }
                    else if(c.status == AP_Constants.caseStatusInoltratoAgenzia){
                        system.debug('****Inoltrato all\'Agenzia');
                        c.TECH_Primo_Sollecito_Agenti__c = BusinessHours.addGMT(defaultHoursId,System.now(),((PrimoSollecitoAgenzia)*60 * 60 * 1000L).longValue());
                        c.TECH_Secondo_Sollecito_Agenti__c = BusinessHours.addGMT(defaultHoursId,System.now(),((SecondoSollecitoAgenzia)*60 * 60 * 1000L).longValue());
                        c.SollecitoPeriodico20ore__c = null;
                    }
                }
                
                //MASSAROTTI ANTONINO 30/11/2019 -- START
                if(String.valueOf(c.OwnerId).startsWith('005')&&(String.valueOf(OldValues.get(c.Id).OwnerId)).startsWith('00G') 
                   && (
                       ( HD1ProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && HD1QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) && !HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(c.OwnerId)) && !HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(c.OwnerId))) //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991
                       ||
                       ( HD2ProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && HD2QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) )
                        //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- START
                        ||
                        ( HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && HD1BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) )
                        ||
                        ( HD2BIZProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && HD2BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) )
                        //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- END
                        //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                        || 
                        ( HD1ContabilitaProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && (HD1ContabilitaQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))) )
                        || 
                        ( HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(c.OwnerId)) && (HD1ContabilitaQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))) )
                        || 
                        ( HD1ContenziosoProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && (HD1ContenziosoQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))) )
                        || 
                        ( HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(c.OwnerId)) && (HD1ContenziosoQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))) )
                        //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
                        //OAVERSANO 19/03/2019 : AXA Assistance -- START
                        || 
                        ( axaAssistanceProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && (axaAssistanceQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))) )
                        || 
                        ( customerOperationProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && (customerOperationQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))) )
                        //OAVERSANO 19/03/2019 : AXA Assistance -- END
                   )
                   && ( RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                   //OAVERSANO 19/03/2019 : AXA Assistance -- START
                   ||
                   RecordTypeSinistriSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                   )
                   //OAVERSANO 19/03/2019 : AXA Assistance -- END
                  )
                {
                    c.OldOwnerIsQueue__c = true;
                }
                else
                {
                    c.OldOwnerIsQueue__c = false;  
                } 
                //OAVERSANO 21/08/2018: Nuovo Modello di Assistenza -- END 
                
                //OAVERSANO 25/03/2019 : AXA Assistance -- START
                if(RecordTypeSinistriSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                    &&
                    c.Status != OldValues.get(c.id).Status
                    )
                {
                    //OAVERSANO 05/07/2019 : Sito Impresa (validazione visura camerale) -- START
                    //if(c.Status == AP_Constants.caseStatusPending && sollecitoAdvisorBH!=null)
                    if(c.Status == AP_Constants.caseStatusPending && sollecitoAdvisorBH!=null && c.Requested_Documents__c == false)
                    //OAVERSANO 05/07/2019 : Sito Impresa (validazione visura camerale) -- END
                    {
                        c.TECH_Primo_Sollecito_Agenti__c = BusinessHours.addGMT(defaultHoursId,System.now(),((sollecitoAdvisorBH)*60 * 60 * 1000L).longValue());
                    }
                }
                //OAVERSANO 25/03/2019 : AXA Assistance -- START
                
                //OAVERSANO 22/11/2018 : Nuovo Modello di Assistenza FIX ProcessBuilder -- START
                if(RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                    &&
                    c.Status != OldValues.get(c.id).Status
                    )
                {
                    if(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()) != 'Axa_Assicurazioni'){
                    if(c.Status == AP_Constants.caseStatusAttesaInfoAgente && primoSollecito!=null && secondoSollecito!=null && terzoSollecito!=null)
                    {
                        c.TECH_Primo_Sollecito_Agenti__c = BusinessHours.addGMT(defaultHoursId,System.now(),((primoSollecito)*60 * 60 * 1000L).longValue());
                        c.TECH_Secondo_Sollecito_Agenti__c = BusinessHours.addGMT(defaultHoursId,System.now(),((secondoSollecito)*60 * 60 * 1000L).longValue());
                        c.TECH_Terzo_Sollecito_Agenti__c = BusinessHours.addGMT(defaultHoursId,System.now(),((terzoSollecito)*60 * 60 * 1000L).longValue());
                    }
                    else if(c.Status == AP_Constants.caseStatusSoluzioneProposta && primoSollecitoSolPro!=null)
                    {
                        c.TECH_Primo_Sollecito_Agenti__c = BusinessHours.addGMT(defaultHoursId,System.now(),((primoSollecitoSolPro)*60 * 60 * 1000L).longValue());
                        c.TECH_Secondo_Sollecito_Agenti__c = null;
                        c.TECH_Terzo_Sollecito_Agenti__c = null;
                    }
                    else
                    {
                        c.TECH_Primo_Sollecito_Agenti__c = null;
                        c.TECH_Secondo_Sollecito_Agenti__c = null;
                        c.TECH_Terzo_Sollecito_Agenti__c = null;
                    }
                    }
                    //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- START
                    if(c.Status == AP_Constants.caseStatusRisolto)
                    {
                        if((
                            //MDANTONIO 08/05/2019: LOB VITA - start
                            //(HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid))
                            (HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid) && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                            //MDANTONIO 08/05/2019: LOB VITA - end
                            ||
                            (HD2BizAutoMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobAuto)
                            )
                            )
                        {
                            c.Risolto_da_HD2_Biz_Auto__c = true;
                            c.Supporto_HD2_Biz_Auto__c = false;
                        }
                        if((
                            //MDANTONIO 08/05/2019: LOB VITA - start
                            //(!HD2BizAutoMember.contains(c.ownerid) && HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid))
                            (!HD2BizAutoMember.contains(c.ownerid) && HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid) && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                            //MDANTONIO 08/05/2019: LOB VITA - end
                            ||
                            (HD2BizFamigliaMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobFamiglia)
                            )
                            )
                        {
                            c.Risolto_da_HD2_Biz_Famiglia__c = true;
                            c.Supporto_HD2_Biz_Famiglia__c = false;
                        }
                        if((
                            //MDANTONIO 08/05/2019: LOB VITA - start
                            //(!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && HD2BizSaluteMember.contains(c.ownerid)) //controllare code nuove
                            (!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && HD2BizSaluteMember.contains(c.ownerid)  && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                            //MDANTONIO 08/05/2019: LOB VITA - end
                            ||
                            (HD2BizSaluteMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobSalute)
                            )
                            )
                        {
                            c.Risolto_da_HD2_Biz_Salute__c = true;
                            c.Supporto_HD2_Biz_Salute__c = false;
                        }
                        //MDANTONIO 09/05/2019: LOB VITA - start
                        if((
                            (!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid)  && HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                            ||
                            (HD2BizVitaAssunzioneMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobVita && (categorySubcategoryToQueue.containsKey(c.Category__c) && categorySubcategoryToQueue.get(c.Category__c).equalsIgnoreCase(HD2BizVitaAssunzione)))
                            )
                            )
                        {
                            c.Risolto_da_HD2_Biz_Vita_Assunzione__c = true;
                            c.Supporto_HD2_Biz_Vita_Assunzione__c = false;
                        }
                        if((
                            (!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid)  && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                            ||
                            (HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobVita && (categorySubcategoryToQueue.containsKey(c.Category__c) && categorySubcategoryToQueue.get(c.Category__c).equalsIgnoreCase(HD2BizVitaContabilitaPrevidenza)))
                            )
                            )
                        {
                            c.Risolto_da_HD2_Biz_Vita_Contabilita_Prev__c = true;
                            c.Supporto_HD2_Biz_Vita_Contabilita_Prev__c = false;
                        }
                        if((
                            (!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid)  && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                            ||
                            (HD2BizVitaLiquidazioniMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobVita && (categorySubcategoryToQueue.containsKey(c.Category__c + '_' + c.SubCategory__c) && categorySubcategoryToQueue.get(c.Category__c + '_' + c.SubCategory__c).equalsIgnoreCase(HD2BizVitaLiquidazioni)))
                            )
                            )
                        {
                            c.Risolto_da_HD2_Biz_Vita_Liquidazioni__c = true;
                            c.Supporto_HD2_Biz_Vita_Liquidazioni__c = false;
                        }
                        if((
                            (!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid)  && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                            ||
                            (HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobVita && (categorySubcategoryToQueue.containsKey(c.Category__c) && categorySubcategoryToQueue.get(c.Category__c).equalsIgnoreCase(HD2BizVitaPtfCollettive)))
                            )
                            )
                        {
                            c.Risolto_da_HD2_Biz_Vita_Ptf_Collettive__c = true;
                            c.Supporto_HD2_Biz_Vita_Ptf_Collettive__c = false;
                        }
                        if((
                            (!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid)  && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                            ||
                            (HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobVita && (categorySubcategoryToQueue.containsKey(c.Category__c) && categorySubcategoryToQueue.get(c.Category__c).equalsIgnoreCase(HD2BizVitaPtfIndividualiRispeProt)))
                            )
                            )
                        {
                            c.Risolto_da_HD2_Biz_Vita_Ptf_Ind_Risp_Pro__c = true;
                            c.Supporto_HD2_Biz_Vita_Ptf_Ind_Risp_Prot__c = false;
                        }
                        if((
                            (!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid)  && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                            ||
                            (HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobVita && (categorySubcategoryToQueue.containsKey(c.Category__c) && categorySubcategoryToQueue.get(c.Category__c).equalsIgnoreCase(HD2BizVitaPtfPrevidenza)))
                            )
                            )
                        {
                            c.Risolto_da_HD2_Biz_Vita_Ptf_Previdenza__c = true;
                            c.Supporto_HD2_Biz_Vita_Ptf_Previdenza__c = false;
                        }
                        if((
                            (!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid)  && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                            ||
                            (HD2BizVitaSinistriRispeProtMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobVita && (categorySubcategoryToQueue.containsKey(c.Category__c + '_' + c.SubCategory__c) && categorySubcategoryToQueue.get(c.Category__c + '_' + c.SubCategory__c).equalsIgnoreCase(HD2BizVitaSinistriRispeProt)))
                            )
                            )
                        {
                            c.Risolto_da_HD2_Biz_Vita_Sinis_Risp_e_Pro__c = true;
                            c.Supporto_HD2_Biz_Vita_Sinis_Risp_e_Prot__c = false;
                        }
                        //MDANTONIO 09/05/2019: LOB VITA - end

                    }
                    //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- END
                }
                //OAVERSANO 22/11/2018 : Nuovo Modello di Assistenza FIX ProcessBuilder -- END
                system.debug('c.Status: : : '+c.Status);
                
                if(closedStatusSet.contains(c.Status) && !OldValues.get(c.id).IsClosed)
                {   
                    c.Tasks_Age_in_Business_Hours__c = c.Time_With_Technicians__c;

                    //MOSCATELLI_M 23/01/2019: NMA Enhancement V— start
                    /*
                    //OAVERSANO 20/07/2018: Nuovo Modello di Assistenza -- START
                    system.debug('c.Phone_Call_Ids__c'+c.Phone_Call_Ids__c);
                    if(    (   (c.Origin == 'Chat' || c.Origin == 'Portale Assistenza') 
                                 && ( String.isNotBlank(c.Phone_Call_Ids__c) 
                                     || caseWithTaskCall.contains(c.Id) )
                                )
                            || 
                            (   c.Origin == 'Phone' 
                             && String.isNotBlank(c.Phone_Call_Ids__c)
                             && (c.Phone_Call_Ids__c.indexOf('|')>-1)
                            )
                            || 
                            (
                                c.Origin == 'Phone' && caseWithTaskCall.contains(c.Id) 
                            )
                           )
                    {
                        c.OCR__c = false;
                        c.Case_sollecitato__c = true;
                    }
                    */
                    //OAVERSANO 20/07/2018: Nuovo Modello di Assistenza -- END
                    //MOSCATELLI_M 23/01/2019: NMA Enhancement V— end
                }
                
                //MOSCATELLI_M 23/01/2019: NMA Enhancement V— end       
                
                else if(c.status == AP_Constants.caseStatusReopened)
                {
                    c.SLA_Technical_Offices__c                     = null;
                    c.All_Tasks_Close_Date__c                      = null;
                    c.Tasks_End_Date__c                            = null;
                    c.Oldest_Task_Creat_Date__c                    = null;
                    c.Tasks_Time_With_Technicians__c               = null;
                    c.Tasks_Age_in_Business_Hours__c               = null;
                    c.Time_With_Support__c                         = null;
                    c.Time_With_Customer__c                        = null;
                    c.Time_With_Agent__c                           = null; //OAVERSANO 23/10/2018 : ICF Close The Loop 
                    c.Time_With_Technicians__c                     = null;
                    c.Case_Age_In_Business_Hours__c                = null;
                    c.TotalNumHoursStatusPendingFromReopen__c      = null;
                    c.TotalNumHoursStatusDelegatedFromReopen__c    = null;
                    c.Current_Color_vs_SLA__c                      = '';
                    c.PendingDueToTaskDT__c                        = null;
                    c.Pending_due_to_Task_Start_Duration__c        = null;
                    c.Time_for_Applicative_activities__c           =null;
                    c.Applicative_activities_check_date__c         =null;
                    c.Anti_Laundering_check_date__c                =null; 
                    c.Invio_Raccomandata_QADV_DT__c                =null;
                    //MOSCATELLI_M 02/05/2018: GDPR--START
                    c.Data_ricezione_richiesta_DPO__c              =null;
                    c.Data_completamento_Task_DPO__c               =null;
                    c.Data_primo_Task_DPO__c                       =null;
                    c.Data_inizio_Pending_per_DPO__c               =null;
                    c.Durata_Pending_DPO__c                        =null;
                    c.Durata_lavorazione_DPO_in_business_hours__c  =null;
                    c.SLA_DPO__c                                   =null;
                    c.Data_Prevista_Fine_DPO__c                    = null;
                    c.Durata_lavorazione_uffici_tecnici__c         =null;
                    //MOSCATELLI_M 02/05/2018: GDPR--END
                    
                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                    c.Data_completamento_Task_interni__c           =null;
                    c.Data_primo_task_interno__c                   =null;
                    c.Data_inizio_Pending_per_Task_interno__c      =null;
                    c.Durata_Pending_per_Task_interno__c           =null;
                    c.Durata_lavorazione_task_interni__c           =null;
                    c.SLA_Task_interni__c                          =null;
                    c.Data_prevista_fine_task_interni__c           =null;                
                    //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                    
                    String EntitlementToUse = Entid;
                    String HoursToUse = defaultHoursId;
                    
                    if(GDPRCategories.contains(c.Category__c))
                    {
                        EntitlementToUse = EntGDPRId;
                        HoursToUse = GDPRHoursId;
                    }
                    
                    if(OldValues.get(c.id).SLAHours__c!=0 && OldValues.get(c.id).SLAHours__c!=null)
                        c.NextStatusDate__c = BusinessHours.addGMT(HoursToUse,System.now(),(OldValues.get(c.id).SLAHours__c*60 * 60 * 1000L).longValue());
                    
                    if(String.isBlank(OldValues.get(c.id).EntitlementId) && String.isNotBlank(c.Category__c) && (OldValues.get(c.id).SLAHours__c!=0 && OldValues.get(c.id).SLAHours__c!=null) && String.isNotBlank(EntitlementToUse))
                        c.EntitlementId = EntitlementToUse;
                    
                    else if(String.isNotBlank(OldValues.get(c.id).EntitlementId) && String.isBlank(c.Category__c))
                        c.EntitlementId = null;
                }                   
                //OAVERSANO 04/07/2019 : Sito Impresa (validazione visura camerale) -- START
                //else if(c.status == AP_Constants.caseStatusPending)
                else if(c.status == AP_Constants.caseStatusPending && c.Requested_Documents__c == false)
                //OAVERSANO 04/07/2019 : Sito Impresa (validazione visura camerale) -- END
                {           
                    if(OldValues.get(c.id).Status <> AP_Constants.caseStatusPending)
                    {                                                           
                        String NotClosedTasks = '';
                        
                        if(!GDPRCategories.contains(c.Category__c))
                        {
                            if(!OpenTaskMap.containsKey(c.Id))                                            
                            {                                                
                                if(c.First_Alert_Before_Closure_DT__c==null && c.Automatic_Closure_Execution_DT__c==null)
                                {
                                    //c.Automatic_Closure_Activation_DT__c = System.now(); //OAVERSANO 18/01/2019 : Gestione Reclami
                                    
                                    String CaseRecTyp    = MapCaseRecordType.get(c.RecordTypeId).getName();  
                                    String AllValues   = 'All';
                                    String SearchString1 = c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+CaseRecTyp+'-'+c.Complainant__c;
                                    String SearchString2 = c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+CaseRecTyp+'-'+c.Complainant__c;
                                    String SearchString3 = c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Complainant__c;   
                                    String SearchString4 = c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c; 
                                    
                                    if(CaseAutomaticClosureMap.containsKey(SearchString1))
                                    {
                                        c.Automatic_Closure_Activation_DT__c = System.now(); //OAVERSANO 18/01/2019 : Gestione Reclami
                                        Double DaysForFirstAlert    = CaseAutomaticClosureMap.get(SearchString1).Days_number_until_first_alert__c       -1;
                                        Double DaysForAutomaticClosure  = CaseAutomaticClosureMap.get(SearchString1).Days_number_until_automatic_closure__c -1;   
                                        
                                        c.First_Alert_Before_Closure_DT__c   = BusinessHours.addGMT(defaultHoursId,System.now(),((DaysForFirstAlert*10)*60 * 60 * 1000L).longValue());                        
                                        c.Automatic_Closure_Execution_DT__c   = BusinessHours.addGMT(defaultHoursId,System.now(),((DaysForAutomaticClosure*10)*60 * 60 * 1000L).longValue());                             
                                        
                                        system.debug('Elapses1: '+DaysForFirstAlert+', '+DaysForAutomaticClosure);
                                    }
                                    else if(CaseAutomaticClosureMap.containsKey(SearchString2))
                                    {
                                        c.Automatic_Closure_Activation_DT__c = System.now(); //OAVERSANO 18/01/2019 : Gestione Reclami
                                        Double DaysForFirstAlert    = CaseAutomaticClosureMap.get(SearchString2).Days_number_until_first_alert__c       -1;
                                        Double DaysForAutomaticClosure  = CaseAutomaticClosureMap.get(SearchString2).Days_number_until_automatic_closure__c -1;   
                                        
                                        c.First_Alert_Before_Closure_DT__c   = BusinessHours.addGMT(defaultHoursId,System.now(),((DaysForFirstAlert*10)*60 * 60 * 1000L).longValue());                        
                                        c.Automatic_Closure_Execution_DT__c   = BusinessHours.addGMT(defaultHoursId,System.now(),((DaysForAutomaticClosure*10)*60 * 60 * 1000L).longValue());
                                        
                                        system.debug('Elapses2: '+DaysForFirstAlert+', '+DaysForAutomaticClosure);                     
                                    }
                                    else if(CaseAutomaticClosureMap.containsKey(SearchString3))
                                    {
                                        c.Automatic_Closure_Activation_DT__c = System.now(); //OAVERSANO 18/01/2019 : Gestione Reclami
                                        Double DaysForFirstAlert    = CaseAutomaticClosureMap.get(SearchString3).Days_number_until_first_alert__c       -1;
                                        Double DaysForAutomaticClosure  = CaseAutomaticClosureMap.get(SearchString3).Days_number_until_automatic_closure__c -1;   
                                        
                                        c.First_Alert_Before_Closure_DT__c   = BusinessHours.addGMT(defaultHoursId,System.now(),((DaysForFirstAlert*10)*60 * 60 * 1000L).longValue());                        
                                        c.Automatic_Closure_Execution_DT__c   = BusinessHours.addGMT(defaultHoursId,System.now(),((DaysForAutomaticClosure*10)*60 * 60 * 1000L).longValue());
                                        
                                        system.debug('Elapses3: '+DaysForFirstAlert+', '+DaysForAutomaticClosure);                       
                                    }
                                    else if(CaseAutomaticClosureMap.containsKey(SearchString4))
                                    {
                                        c.Automatic_Closure_Activation_DT__c = System.now(); //OAVERSANO 18/01/2019 : Gestione Reclami
                                        Double DaysForFirstAlert    = CaseAutomaticClosureMap.get(SearchString4).Days_number_until_first_alert__c       -1;
                                        Double DaysForAutomaticClosure  = CaseAutomaticClosureMap.get(SearchString4).Days_number_until_automatic_closure__c -1;   
                                        
                                        c.First_Alert_Before_Closure_DT__c   = BusinessHours.addGMT(defaultHoursId,System.now(),((DaysForFirstAlert*10)*60 * 60 * 1000L).longValue());                        
                                        c.Automatic_Closure_Execution_DT__c   = BusinessHours.addGMT(defaultHoursId,System.now(),((DaysForAutomaticClosure*10)*60 * 60 * 1000L).longValue());
                                        
                                        system.debug('Elapses4: '+DaysForFirstAlert+', '+DaysForAutomaticClosure);                     
                                    }
                                }                                                       
                            }
                        }
                        //GDPR
                        else if(GDPRCategories.contains(c.Category__c) && c.NextStatusDate__c != null)
                        {
                            Integer MissingDays = (system.today()).daysBetween(Date.valueOf(c.NextStatusDate__c));
                            
                            if(MissingDays>=9)
                            {
                                c.Automatic_Closure_Activation_DT__c = System.now();
                                DateTime FirstAlert = BusinessHours.addGMT(GDPRHoursId,System.now(),(((Integer.valueof(MissingDays/3))*24)*60 * 60 * 1000L));
                                c.First_Alert_Before_Closure_DT__c =  FirstAlert;
                                c.Second_Alert_Before_Closure_DT__c = BusinessHours.addGMT(GDPRHoursId,FirstAlert,(((Integer.valueof(MissingDays/3))*24)*60 * 60 * 1000L));
                                c.Automatic_Closure_Execution_DT__c = c.NextStatusDate__c;
                            }
                            else if(MissingDays < 9 && MissingDays>5)
                            {
                                c.Automatic_Closure_Activation_DT__c = System.now();
                                c.Second_Alert_Before_Closure_DT__c = BusinessHours.addGMT(GDPRHoursId,System.now(),(((Integer.valueof(MissingDays/2))*24)*60 * 60 * 1000L));
                                c.Automatic_Closure_Execution_DT__c = c.NextStatusDate__c;
                            }
                            else if(MissingDays <= 5)
                            {
                                c.Automatic_Closure_Execution_DT__c = c.NextStatusDate__c;
                            }
                        }
                        //GDPR
                    }
                }                   
                else if(c.status == AP_Constants.caseStatusDelegated)
                {               
                    if(OldValues.get(c.id).Status <> AP_Constants.caseStatusDelegated)
                    {
                        if(c.First_Long_Term_Management_Alert_DT__c==null && c.Second_Long_Term_Management_Alert_DT__c==null && c.Third_Long_Term_Management_Alert_DT__c==null)
                        {
                            String BzHoursToUse = (GDPRCategories.contains(c.Category__c))?GDPRHoursId:defaultHoursId;
                            Integer DayHours = (GDPRCategories.contains(c.Category__c))?24:10;
                            
                            String CaseRecTyp    = MapCaseRecordType.get(c.RecordTypeId).getName();     
                            String AllValues   = 'All';
                            String SearchString1 = c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+CaseRecTyp+'-'+c.Complainant__c;
                            String SearchString2 = c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+CaseRecTyp+'-'+c.Complainant__c;
                            String SearchString3 = c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Complainant__c;   
                            String SearchString4 = c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c; 
                            
                            if(LongTermManagementMap.containsKey(SearchString1))
                            {
                                Double FirstElapse  = LongTermManagementMap.get(SearchString1).Days_number_until_first_alert__c  -1;
                                Double SecondElapse = LongTermManagementMap.get(SearchString1).Days_number_until_second_alert__c -1;
                                Double ThirdElapse  = LongTermManagementMap.get(SearchString1).Days_number_until_third_alert__c  -1;
                                
                                c.First_Long_Term_Management_Alert_DT__c   = BusinessHours.addGMT(BzHoursToUse,System.now(),((FirstElapse*DayHours)*60 * 60 * 1000L).longValue());                        
                                c.Second_Long_Term_Management_Alert_DT__c   = BusinessHours.addGMT(BzHoursToUse,System.now(),((SecondElapse*DayHours)*60 * 60 * 1000L).longValue());
                                c.Third_Long_Term_Management_Alert_DT__c   = BusinessHours.addGMT(BzHoursToUse,System.now(),((ThirdElapse*DayHours)*60 * 60 * 1000L).longValue());
                                c.Feedback_Provided_to_Customer__c     = false;
                                c.Inform_Customers_with_Alerts__c       = false;
                                
                                system.debug('Elapses1: '+FirstElapse+', '+SecondElapse+', '+ThirdElapse);
                            }
                            else if(LongTermManagementMap.containsKey(SearchString2))
                            {
                                Double FirstElapse  = LongTermManagementMap.get(SearchString2).Days_number_until_first_alert__c  -1;
                                Double SecondElapse = LongTermManagementMap.get(SearchString2).Days_number_until_second_alert__c -1;
                                Double ThirdElapse  = LongTermManagementMap.get(SearchString2).Days_number_until_third_alert__c  -1;
                                
                                c.First_Long_Term_Management_Alert_DT__c   = BusinessHours.addGMT(BzHoursToUse,System.now(),((FirstElapse*DayHours)*60 * 60 * 1000L).longValue());
                                c.Second_Long_Term_Management_Alert_DT__c   = BusinessHours.addGMT(BzHoursToUse,System.now(),((SecondElapse*DayHours)*60 * 60 * 1000L).longValue());
                                c.Third_Long_Term_Management_Alert_DT__c   = BusinessHours.addGMT(BzHoursToUse,System.now(),((ThirdElapse*DayHours)*60 * 60 * 1000L).longValue());
                                c.Feedback_Provided_to_Customer__c     = false;
                                c.Inform_Customers_with_Alerts__c       = false;                        
                                
                                system.debug('Elapses2: '+FirstElapse+', '+SecondElapse+', '+ThirdElapse);                        
                            }
                            else if(LongTermManagementMap.containsKey(SearchString3))
                            {
                                Double FirstElapse  = LongTermManagementMap.get(SearchString3).Days_number_until_first_alert__c  -1;
                                Double SecondElapse = LongTermManagementMap.get(SearchString3).Days_number_until_second_alert__c -1;
                                Double ThirdElapse  = LongTermManagementMap.get(SearchString3).Days_number_until_third_alert__c  -1;
                                
                                c.First_Long_Term_Management_Alert_DT__c   = BusinessHours.addGMT(BzHoursToUse,System.now(),((FirstElapse*DayHours)*60 * 60 * 1000L).longValue());
                                c.Second_Long_Term_Management_Alert_DT__c   = BusinessHours.addGMT(BzHoursToUse,System.now(),((SecondElapse*DayHours)*60 * 60 * 1000L).longValue());
                                c.Third_Long_Term_Management_Alert_DT__c   = BusinessHours.addGMT(BzHoursToUse,System.now(),((ThirdElapse*DayHours)*60 * 60 * 1000L).longValue());
                                c.Feedback_Provided_to_Customer__c     = false;
                                c.Inform_Customers_with_Alerts__c       = false;
                                
                                system.debug('Elapses3: '+FirstElapse+', '+SecondElapse+', '+ThirdElapse);                        
                            }
                            else if(LongTermManagementMap.containsKey(SearchString4))
                            {
                                Double FirstElapse  = LongTermManagementMap.get(SearchString4).Days_number_until_first_alert__c  -1;
                                Double SecondElapse = LongTermManagementMap.get(SearchString4).Days_number_until_second_alert__c -1;
                                Double ThirdElapse  = LongTermManagementMap.get(SearchString4).Days_number_until_third_alert__c  -1;
                                
                                c.First_Long_Term_Management_Alert_DT__c   = BusinessHours.addGMT(BzHoursToUse,System.now(),((FirstElapse*DayHours)*60 * 60 * 1000L).longValue());
                                c.Second_Long_Term_Management_Alert_DT__c   = BusinessHours.addGMT(BzHoursToUse,System.now(),((SecondElapse*DayHours)*60 * 60 * 1000L).longValue());
                                c.Third_Long_Term_Management_Alert_DT__c   = BusinessHours.addGMT(BzHoursToUse,System.now(),((ThirdElapse*DayHours)*60 * 60 * 1000L).longValue());
                                c.Feedback_Provided_to_Customer__c     = false;
                                c.Inform_Customers_with_Alerts__c       = false;
                                system.debug('Elapses4: '+FirstElapse+', '+SecondElapse+', '+ThirdElapse);                        
                            }
                        }
                    }
                }
                else if(c.Status == AP_Constants.caseStatusVerificaAttAntiRic)
                {
                    c.Svolta_Attivita_Antiriciclaggio__c = true;
                    if(c.Origine_Pratica_Documentale__c != 'MASS'){
                        c.Anti_Laundering_check_date__c = system.now();
                    }
                    
                }
                else if(c.Status == AP_Constants.caseStatusInviataRaccomandata)
                    c.Invio_Raccomandata_QADV_DT__c = system.now();
                
                else if(c.Status == AP_Constants.caseStatusAttivitaDispositive)
                {
                    if(String.isNotBlank(c.Category__c) && String.isNotBlank(c.SubCategory__c) && AttDispConfigSet.contains(c.Category__c+'|'+c.SubCategory__c))
                        c.Applicative_activities_check_date__c = BusinessHours.addGMT(defaultHoursId,System.now(),(((MapAttDispToDaysNum.get(c.Category__c+'|'+c.SubCategory__c)-1)*10)*60 * 60 * 1000L).longValue());                      
                    else
                    {
                        c.addError('Attenzione! Non è possibile modificare lo stato del Case al valore indicato con la categorizzazione utilizzata');
                        return outc;
                    }
                }
                //OAVERSANO 18/01/2019 : Gestione Reclami -- START
                else if(c.Status == AP_Constants.caseStatusInformationReceived && devNamerecordTypeRecalculateAP01Set.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName())))
                {
                    if(OldValues.get(c.id).Status <> AP_Constants.caseStatusInformationReceived)
                    { 
                        CaseListAP01.add(c);
                    }
                }
                //OAVERSANO 18/01/2019 : Gestione Reclami -- END
                
                //OAVERSANO 29/03/2019 : ICF CR2 -- START
                if(c.Status==AP_Constants.caseStatusInformationReceived && (ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)).indexOf('AAI - Vendite')<>-1 && MapCaseRecordType.get(c.RecordTypeId).getName() == AP_Constants.rtCaseCloseTheLoop)
                {
                    if(OldValues.get(c.id).Status <> AP_Constants.caseStatusInformationReceived)
                    { 
                        c = ServiceUtilsClass.setAgentICFAlerts(c,ICFAgentiHours);
                    }
                }  
                //OAVERSANO 29/02/2019 : ICF CR2 -- END
                
                if((c.IsClosed==true && OldValues.get(c.id).IsClosed==false) && (c.First_Long_Term_Management_Alert_DT__c!=null || c.Second_Long_Term_Management_Alert_DT__c!=null || c.Third_Long_Term_Management_Alert_DT__c!=null))
                {
                    c.First_Long_Term_Management_Alert_DT__c = null;
                    c.Second_Long_Term_Management_Alert_DT__c = null;
                    c.Third_Long_Term_Management_Alert_DT__c = null;
                    c.Inform_Customers_with_Alerts__c = false;
                }           
                
                if(OldValues.get(c.id).status == AP_Constants.caseStatusPending)
                {
                    if(OldValues.get(c.id).Automatic_Closure_Activation_DT__c != null)
                    {
                        c.Automatic_Closure_Activation_DT__c  =null;
                        c.First_Alert_Before_Closure_DT__c    =null;
                        c.Automatic_Closure_Execution_DT__c   =null;
                        c.Second_Alert_Before_Closure_DT__c   =null;
                    }                                    
                }
                else if(OldValues.get(c.id).status == AP_Constants.caseStatusAttivitaDispositive)
                    c.Applicative_activities_check_date__c = null;
                
               else if(OldValues.get(c.id).status == AP_Constants.caseStatusVerificaAttAntiRic)            
                    c.Anti_Laundering_check_date__c = null;
                
                else if(OldValues.get(c.id).status == AP_Constants.caseStatusInviataRaccomandata)
                    c.Invio_Raccomandata_QADV_DT__c = null;             
                
                if(SetCaseCatToCloseTask.contains(c.Category__c+'|'+c.SubCategory__c))
                {
                    if(c.Status == AP_Constants.caseStatusClosed
                       || c.Status == AP_Constants.caseStatusOutOfTime
                       || c.Status == AP_Constants.caseStatusCancelled)
                    {
                        for(Task t: OpenTasksList)
                        {
                            idListTaskToClose.add(t.Id);
                        }
                    }
                    outc.TaskToClose =  idListTaskToClose;                
                }
                else if(SetCaseCatToCloseTask.contains(c.Category__c+'|'+'All'))
                {
                    if(c.Status == AP_Constants.caseStatusClosed
                       || c.Status == AP_Constants.caseStatusOutOfTime
                       || c.Status == AP_Constants.caseStatusCancelled)
                    {
                        for(Task t: OpenTasksList)
                        {
                            idListTaskToClose.add(t.Id);
                        }
                    } 
                    
                    outc.TaskToClose =  idListTaskToClose;
                } 
                
                if(c.Last_Status_Change__c!=null && !OldValues.get(c.id).IsClosed)
                {
                    system.debug('##Inizio attività calcolo tempi di lavorazione');
                    
                    Double timeSinceLastStatus = BusinessHours.diff(defaultHoursId, c.Last_Status_Change__c, System.now())/3600000.0;
                    System.debug('@@timeSinceLastStatus: '+timeSinceLastStatus);
                    system.debug('OldValues.get(c.id).Status: '+OldValues.get(c.id).Status);
                    system.debug('stopStatusSet: '+stopStatusSet);
                    system.debug('MapCaseRecordType.get(c.RecordTypeId).getDeveloperName(): '+MapCaseRecordType.get(c.RecordTypeId).getDeveloperName());
                    system.debug('RecordTypeSet CA : '+RecordTypeSet);
                    //OAVERSANO 26/09/2018 : ICF Close The Loop -- START
                    /*if (stopStatusSet.contains(OldValues.get(c.id).Status) && !RecordTypeSet.contains(MapCaseRecordType.get(c.RecordTypeId).getDeveloperName()) && (OldValues.get(c.id).Status==AP_Constants.caseStatusPending || OldValues.get(c.id).Status==AP_Constants.caseStatusVerificaAttAntiRic || OldValues.get(c.id).Status==AP_Constants.caseStatusInviataRaccomandata || OldValues.get(c.id).Status==AP_Constants.caseStatusGestioneAgente ))
                    //if (stopStatusSet.contains(OldValues.get(c.id).Status) && !RecordTypeSet.contains(MapCaseRecordType.get(c.RecordTypeId).getDeveloperName()) && (OldValues.get(c.id).Status==AP_Constants.caseStatusPending || OldValues.get(c.id).Status==AP_Constants.caseStatusVerificaAttAntiRic || OldValues.get(c.id).Status==AP_Constants.caseStatusInviataRaccomandata )) 
                    //OAVERSANO 26/09/2018 : ICF Close The Loop -- END
                    {
                        //OAVERSANO 23/10/2018 : ICF Close The Loop -- START
                        if(OldValues.get(c.id).Status==AP_Constants.caseStatusGestioneAgente )
                        {
                            if(c.Time_With_Agent__c!=null)
                                c.Time_With_Agent__c += timeSinceLastStatus;
                            else
                                c.Time_With_Agent__c = timeSinceLastStatus;
                        }
                        else
                        {
                            if(c.Time_With_Customer__c!=null)
                                c.Time_With_Customer__c += timeSinceLastStatus;
                            else
                                c.Time_With_Customer__c = timeSinceLastStatus;
                        }
                        //OAVERSANO 23/10/2018 : ICF Close The Loop -- END
                    } 
                    //else if(stopStatusSet.contains(OldValues.get(c.id).Status) && (OldValues.get(c.id).Status==AP_Constants.caseStatusDelegated || OldValues.get(c.id).Status==AP_Constants.caseStatusInAttesaDPO))
                    else if(((OldValues.get(c.id).Status==AP_Constants.caseStatusDelegated || OldValues.get(c.id).Status == AP_Constants.caseStatusInAttesaDPO || OldValues.get(c.id).Status == AP_Constants.caseInAttesa2ndInterno) &&
                             (c.Status==AP_Constants.caseStatusPending || c.Status ==AP_Constants.caseStatusAttivitaDPOCompletate || c.Status == AP_Constants.caseStatusAllTasksClosed || c.Status == AP_Constants.case2ndInternoCompletato)) ||
                            ((OldValues.get(c.id).Oldest_Task_Creat_Date__c <> null || OldValues.get(c.id).Data_primo_Task_DPO__c <> null || OldValues.get(c.id).Data_primo_task_interno__c <> null) && OldValues.get(c.id).Status==AP_Constants.caseStatusInformationReceived && (c.Status==AP_Constants.caseStatusPending || c.Status ==AP_Constants.caseStatusAttivitaDPOCompletate || c.Status == AP_Constants.caseStatusAllTasksClosed || c.Status == AP_Constants.case2ndInternoCompletato)))
                    {
                        if(c.Time_With_Technicians__c !=null)
                            c.Time_With_Technicians__c += timeSinceLastStatus;
                        else
                            c.Time_With_Technicians__c = timeSinceLastStatus;
                    }     
                    else if(stopStatusSet.contains(OldValues.get(c.id).Status) && OldValues.get(c.id).Status==AP_Constants.caseStatusAttivitaDispositive)
                    {
                        if(c.Time_for_Applicative_activities__c !=null)
                            c.Time_for_Applicative_activities__c += timeSinceLastStatus;
                        else
                            c.Time_for_Applicative_activities__c = timeSinceLastStatus;
                    }
                    
                    //else if((!stopStatusSet.contains(OldValues.get(c.id).Status) && stopStatusSet.contains(c.Status) && !RecordTypeSet.contains(MapCaseRecordType.get(c.RecordTypeId).getDeveloperName()) ) || (!stopStatusSet.contains(OldValues.get(c.id).Status) && !stopStatusSet.contains(c.Status) && !RecordTypeSet.contains(MapCaseRecordType.get(c.RecordTypeId).getDeveloperName()) ))
                    else if((!stopStatusSet.contains(OldValues.get(c.id).Status) && stopStatusSet.contains(c.Status) && !RecordTypeSet.contains(MapCaseRecordType.get(c.RecordTypeId).getDeveloperName()) && !RecordTypeSinistriSet.contains(MapCaseRecordType.get(c.RecordTypeId).getDeveloperName()) ) || (!stopStatusSet.contains(OldValues.get(c.id).Status) && !stopStatusSet.contains(c.Status) && !RecordTypeSet.contains(MapCaseRecordType.get(c.RecordTypeId).getDeveloperName()) && !RecordTypeSinistriSet.contains(MapCaseRecordType.get(c.RecordTypeId).getDeveloperName()))) //OAVERSANO 19/03/2019 : AXA Assistance
                    {
                        //OAVERSANO 07/03/2019 : CR ICF -- START
                        if(OldValues.get(c.id).Status==AP_Constants.caseStatusInformationReceived && (ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)).indexOf('AAI - Vendite')<>-1 )
                        {
                            if(c.Time_With_Agent__c!=null)
                                c.Time_With_Agent__c += timeSinceLastStatus;
                            else
                                c.Time_With_Agent__c = timeSinceLastStatus;
                        }
                        else
                        {
                        //OAVERSANO 07/03/2019 : CR ICF -- END  
                            if(c.Time_With_Support__c!=null)
                                c.Time_With_Support__c += timeSinceLastStatus;
                            else
                                c.Time_With_Support__c = timeSinceLastStatus;
                            system.debug('#@#@#@#@c.Time_With_Support__c: '+c.Time_With_Support__c);
                        }//OAVERSANO 07/03/2019 : CR ICF   
                    }*/
                    
                    //OAVERSANO 12/09/2018: Nuovo Modello di Assistenza -- START 
                    if (closedStatusSet.contains(c.Status) && !RecordTypeSet.contains(MapCaseRecordType.get(c.RecordTypeId).getDeveloperName()))                 
                        c.Case_Age_In_Business_Hours__c = (c.Time_With_Customer__c==null?0:c.Time_With_Customer__c) +(c.Time_With_Support__c ==null?0:c.Time_With_Support__c) + (c.Time_With_Technicians__c==null?0:c.Time_With_Technicians__c) + (c.Time_for_Applicative_activities__c==null?0:c.Time_for_Applicative_activities__c);             
                    //OAVERSANO 12/09/2018: Nuovo Modello di Assistenza -- START 
                }
                c.Last_Status_Change__c = System.now();     
                
                system.debug('##Fine attività calcolo tempi di lavorazione');                           
                
                listCaseAP01.add(c);
                outc.CasList.put(c.id,c);
                mapCaseIdOldStatus.put(c.id,OldValues.get(c.id).status);                                
            }   
            
            if(listCaseAP01.size()>0)       
                AP01CaseCalculateDueDate.calculateCaseStatusTotalTime(listCaseAP01,mapCaseIdOldStatus,defaultHoursId);  
                
            //OAVERSANO 18/01/2019 : Gestione Reclami -- START
            if(!CaseListAP01.isEmpty())
            {
                AP01CaseCalculateDueDate.calculateDueDate(CaseListAP01,defaultHoursId,GDPRHoursId,EntGDPRId,Entid,EntGDPRId2,EntGDPRId3,EntAssAgenti,EntCaringAngel,EntReclamo,MapCaseRecordType,MapRecNameToDevelopername);
            }
            //OAVERSANO 18/01/2019 : Gestione Reclami -- END
        }
        
        return outc;
    }
    
    
    //public static Outcome CharacteristicsModificationProcesses(List<Case> Cases, Map<String,Case> OldValues, String Entid,Map<String,Account>MapCaseAccount, Map<String,String>MapAssociatedPolicies,Map<String,InsurancePolicy__c> MapInsertedPolicy, Id defaultHoursId,String GDPRHoursId,String EntGDPRId,String EntGDPRId2, String EntGDPRId3, Map<String,User> MapAAIAgent, Map<String,String> ownerIdProfileNameMap)
    //public static Outcome CharacteristicsModificationProcesses(List<Case> Cases, Map<String,Case> OldValues, String Entid,Map<String,Account>MapCaseAccount, Map<String,String>MapAssociatedPolicies,Map<String,InsurancePolicy__c> MapInsertedPolicy, Id defaultHoursId,String GDPRHoursId,String EntGDPRId,String EntGDPRId2, String EntGDPRId3, String EntAssAgenti, String EntCaringAngel, Map<String,User> MapAAIAgent, Map<String,String> ownerIdProfileNameMap, Map<String, Schema.RecordTypeInfo> MapCaseRecordType, Map<String,String> MapRecNameToDevelopername, Map<String,String> ownerIdNameMap,Map<String,String> MapAgencies) //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza
    //public static Outcome CharacteristicsModificationProcesses(List<Case> Cases, Map<String,Case> OldValues, String Entid,Map<String,Account>MapCaseAccount, Map<String,String>MapAssociatedPolicies,Map<String,InsurancePolicy__c> MapInsertedPolicy, Id defaultHoursId,String GDPRHoursId,String EntGDPRId,String EntGDPRId2, String EntGDPRId3, String EntAssAgenti, String EntCaringAngel, String EntReclamo, Map<String,User> MapAAIAgent, Map<String,String> ownerIdProfileNameMap, Map<String, Schema.RecordTypeInfo> MapCaseRecordType, Map<String,String> MapRecNameToDevelopername, Map<String,String> ownerIdNameMap,Map<String,String> MapAgencies) //OAVERSANO 18/01/2019 : Gestione Reclami
    public static Outcome CharacteristicsModificationProcesses(List<Case> Cases, Map<String,Case> OldValues, String Entid,Map<String,Account>MapCaseAccount, Map<String,String>MapAssociatedPolicies,Map<String,InsurancePolicy__c> MapInsertedPolicy, Id defaultHoursId,String GDPRHoursId,String EntGDPRId,String EntGDPRId2, String EntGDPRId3, String EntAssAgenti, String EntCaringAngel, String EntReclamo, Map<String,User> MapAAIAgent, Map<String,String> ownerIdProfileNameMap, Map<String,String> ownerIdRoleNameMap, Map<String, Schema.RecordTypeInfo> MapCaseRecordType, Map<String,String> MapRecNameToDevelopername, Map<String,String> ownerIdNameMap,Map<String,Account> MapAgencies, String ICFAgentiHours) //OAVERSANO 11/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991
    {
        Outcome outc = new Outcome();
        
        system.debug('firstRunChar'+CaseHandler.firstRunChar);
        
        if(CaseHandler.firstRunChar)
        {
            system.debug('CharacteristicsModificationProcesses: START');
            
            List<Case> CalculateSLAList = new List<Case>();
            Set<String>CaseAccountId= new Set<String>();
            Set<String> SMSInputsList = new Set<String>();
            List<Case> caselistAP06 = new list<Case>();
            List<Case> CaseToUpdate = new List<Case>();
            List<String> GDPRCategories = new List<String>();
            Set<String> DoNotCopyEmail = new Set<String>(); //OAVERSANO 03/08/2018 BUG Fix Fatiga
            
            for(MPS_Code_Variables__c MPSCv: MPS_Code_Variables__c.getAll().values())
            {
                if((MPSCv.Name).contains('GDPR_Category'))
                    GDPRCategories.add(MPSCv.Value__c);
                
            }    
            //OAVERSANO 03/08/2018 BUG Fix Fatiga -- START
            if(MPS_Code_Variables__c.getValues('DoNotCopyEmail')!=null)
            {
                if(String.isNotBlank(MPS_Code_Variables__c.getValues('DoNotCopyEmail').value__c))
                {
                    for(String s:(MPS_Code_Variables__c.getValues('DoNotCopyEmail').value__c).split(';'))
                    {
                        DoNotCopyEmail.add(s);                
                    }
                }
            }
            //OAVERSANO 03/08/2018 BUG Fix Fatiga -- END
            //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza -- START
            
            Set<String> AgentProfileSet = new Set<String>();
            Set<String> HD1ProfileSet = new Set<String>();
            Set<String> HD1QueueSet = new Set<String>();
            Set<String> HD2ProfileSet = new Set<String>();
            Set<String> HD2QueueSet = new Set<String>();
            Set<String> RecordTypeSet = new Set<String>();
            //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- START 
            Set<String> HD1BIZProfileSet = new Set<String>();
            Set<String> HD1BIZQueueSet = new Set<String>();
            Set<String> HD2BIZProfileSet = new Set<String>();
            Set<String> HD2BIZQueueSet = new Set<String>();
            Set<String> MdCQueueSet = new Set<String>();
            //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- END 
            //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- START
            Set<String> HD1PQSet = new Set<String>();
            Set<String> HD1BIZPQSet = new Set<String>();
            //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- END
            //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
            Set<String> HD1ContabilitaProfileSet = new Set<String>();
            Set<String> HD1ContabilitaQueueSet = new Set<String>();
            Set<String> HD1ContabilitaRoleSet = new Set<String>();
            Set<String> HD1ContenziosoProfileSet = new Set<String>();
            Set<String> HD1ContenziosoQueueSet = new Set<String>();
            Set<String> HD1ContenziosoRoleSet = new Set<String>();
            //MDANTONIO 08/05/2019: LOB VITA - start
            Map<String, String> categorySubcategoryToQueue = new Map<String, String>();
            //MDANTONIO 08/05/2019: LOB VITA - end
            /*Modello_di_Assistenza__mdt mdAss = [SELECT Id, DeveloperName,AgentProfile__c, CaseTriggerRecordType__c,
                                                HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c,
                                                HD1BIZProfile__c, HD1BIZQueue__c, HD2BIZProfile__c, HD2BIZQueue__c, Coda_MdC__c //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84
                                                FROM Modello_di_Assistenza__mdt 
                                                WHERE DeveloperName  = 'ProfileManagement'
                                                LIMIT 1];*/
            //BOVOLENTA_D 04042019 query reduction START
            //MDANTONIO 08/05/2019: LOB VITA - start
            //List<String> filters = new list<String>{'ProfileManagement','HD1ContabilitaProfile','HD1ContabilitaRole','HD1ContabilitaQueue','HD1ContenziosoProfile','HD1ContenziosoRole','HD1ContenziosoQueue'};
            List<String> filters = new list<String>{'ProfileManagement','HD1ContabilitaProfile','HD1ContabilitaRole','HD1ContabilitaQueue','HD1ContenziosoProfile','HD1ContenziosoRole','HD1ContenziosoQueue','HD2BizVitaAssunzione','HD2BizVitaContabilitaPrevidenza','HD2BizVitaLiquidazioni01','HD2BizVitaLiquidazioni02','HD2BizVitaPtfCollettive','HD2BizVitaPtfIndividuali','HD2BizVitaPtfPrevidenza','HD2BizVitaSPR'};
            //MDANTONIO 08/05/2019: LOB VITA - end
            List<Modello_di_Assistenza__mdt> mdAssList =CaseManagement.retrieveCustomMetadataRecords('Modello_di_Assistenza__mdt',filters);
            /*            List<Modello_di_Assistenza__mdt> mdAssList = [SELECT Id, DeveloperName,AgentProfile__c, CaseTriggerRecordType__c,
                                                HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c,
                                                HD1BIZProfile__c, HD1BIZQueue__c, HD2BIZProfile__c, HD2BIZQueue__c, Coda_MdC__c, Value__c
                                                FROM Modello_di_Assistenza__mdt 
                                                WHERE DeveloperName IN ('ProfileManagement','HD1ContabilitaProfile','HD1ContabilitaRole','HD1ContabilitaQueue','HD1ContenziosoProfile','HD1ContenziosoRole','HD1ContenziosoQueue')
                                                ];
            //BOVOLENTA_D 04042019 query reduction END */
            System.debug('===> mdAssList: ' + mdAssList);                                     

            if(!mdAssList.isEmpty())
            {
                for(Modello_di_Assistenza__mdt mdAss : mdAssList)
                {
                    System.debug('===> mdAss: ' + mdAss);
                    if(mdAss.DeveloperName == 'ProfileManagement')
                    {
                        if(String.isNotBlank(mdAss.AgentProfile__c))
                            for(String s:mdAss.AgentProfile__c.split(';'))
                            AgentProfileSet.add(s);   
                        if(String.isNotBlank(mdAss.HD1Profile__c))
                        {
                            for(String s:mdAss.HD1Profile__c.split(';'))
                            {
                                HD1PQSet.add(s);
                                HD1ProfileSet.add(s);   
                            }
                        }
                        if(String.isNotBlank(mdAss.HD1Queue__c))
                        {
                            for(String s:mdAss.HD1Queue__c.split(';'))
                            {
                                HD1PQSet.add(s);
                                HD1QueueSet.add(s);
                            }
                        }   
                        if(String.isNotBlank(mdAss.HD2Profile__c))
                            for(String s:mdAss.HD2Profile__c.split(';'))
                            HD2ProfileSet.add(s);   
                        if(String.isNotBlank(mdAss.HD2Queue__c))
                            for(String s:mdAss.HD2Queue__c.split(';'))
                            HD2QueueSet.add(s);  
                        //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- START
                        if(String.isNotBlank(mdAss.HD1BIZProfile__c))
                        {
                            for(String s:mdAss.HD1BIZProfile__c.split(';'))
                            {
                                HD1BIZProfileSet.add(s);  
                                HD1BIZPQSet.add(s);
                            }
                        } 
                        if(String.isNotBlank(mdAss.HD1BIZQueue__c))
                        {
                            for(String s:mdAss.HD1BIZQueue__c.split(';'))
                            {
                                HD1BIZQueueSet.add(s);   
                                HD1BIZPQSet.add(s);
                            }
                        }
                        if(String.isNotBlank(mdAss.HD2BIZProfile__c))
                            for(String s:mdAss.HD2BIZProfile__c.split(';'))
                            HD2BIZProfileSet.add(s);   
                        if(String.isNotBlank(mdAss.HD2BIZQueue__c))
                            for(String s:mdAss.HD2BIZQueue__c.split(';'))
                            HD2BIZQueueSet.add(s);  
                        if(String.isNotBlank(mdAss.Coda_MdC__c))
                        {
                            for(String s:mdAss.Coda_MdC__c.split(';'))
                            {
                                MdCQueueSet.add(s);  
                            }
                        } 
                        //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- END
                        if(String.isNotBlank(mdAss.CaseTriggerRecordType__c))
                            for(String s:mdAss.CaseTriggerRecordType__c.split(';'))
                            RecordTypeSet.add(s);  
                    }
                    else if(mdAss.DeveloperName == 'HD1ContabilitaProfile')
                    {
                        if(String.isNotBlank(mdAss.Value__c))
                        {
                            for(String s:mdAss.Value__c.split(';'))
                            {
                                HD1ContabilitaProfileSet.add(s);  
                            }
                        }
                    }
                    else if(mdAss.DeveloperName == 'HD1ContabilitaRole')
                    {
                        if(String.isNotBlank(mdAss.Value__c))
                        {
                            for(String s:mdAss.Value__c.split(';'))
                            {
                                HD1ContabilitaRoleSet.add(s);
                            }
                        }
                    }
                    else if(mdAss.DeveloperName == 'HD1ContenziosoProfile')
                    {
                        if(String.isNotBlank(mdAss.Value__c))
                        {
                            for(String s:mdAss.Value__c.split(';'))
                            {
                                HD1ContenziosoProfileSet.add(s);
                            }
                        }
                    }
                    else if(mdAss.DeveloperName == 'HD1ContenziosoRole')
                    {
                        if(String.isNotBlank(mdAss.Value__c))
                        {
                            for(String s:mdAss.Value__c.split(';'))
                            {
                                HD1ContenziosoRoleSet.add(s);
                            }
                        }
                    }
                    else if(mdAss.DeveloperName == 'HD1ContabilitaQueue')
                    {
                        if(String.isNotBlank(mdAss.Value__c))
                        {
                            for(String s:mdAss.Value__c.split(';'))
                            {
                                HD1ContabilitaQueueSet.add(s);
                            }
                        }
                    }
                    else if(mdAss.DeveloperName == 'HD1ContenziosoQueue')
                    {
                        if(String.isNotBlank(mdAss.Value__c))
                        {
                            for(String s:mdAss.Value__c.split(';'))
                            {
                                HD1ContenziosoQueueSet.add(s);
                            }
                        }
                    }
                    //MDANTONIO 08/05/2019: LOB VITA - start
                    else if(mdAss.DeveloperName == 'HD2BizVitaAssunzione' || mdAss.DeveloperName == 'HD2BizVitaContabilitaPrevidenza' || mdAss.DeveloperName == 'HD2BizVitaLiquidazioni01' || mdAss.DeveloperName == 'HD2BizVitaLiquidazioni02' || mdAss.DeveloperName == 'HD2BizVitaPtfCollettive' || mdAss.DeveloperName == 'HD2BizVitaPtfIndividuali' || mdAss.DeveloperName == 'HD2BizVitaPtfPrevidenza' || mdAss.DeveloperName == 'HD2BizVitaSPR'){
                        if(String.isNotBlank(mdAss.Value__c)){
                            if(mdAss.Sotto_categoria__c != null){
                                categorySubcategoryToQueue.put(mdAss.Categoria__c + '_' + mdAss.Sotto_categoria__c, mdAss.Value__c);
                            }
                            else{
                                categorySubcategoryToQueue.put(mdAss.Categoria__c, mdAss.Value__c);
                            }
                    }
                    }
                    //MDANTONIO 08/05/2019: LOB VITA - end
                }
                
            }
            //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
            
            //OAVERSANO 06/11/2018 : Nuovo M odello di Assistenza AXA MPS -Sprint 84 START
            Set<String> AgentProfileSetVR = new Set<String>();
            Set<String> HD1ProfileSetVR = new Set<String>();
            Set<String> HD1QueueSetVR = new Set<String>();
            Set<String> HD2ProfileSetVR = new Set<String>();
            Set<String> HD2QueueSetVR = new Set<String>();
            Set<String> RecordTypeSetVR = new Set<String>();
            Set<String> HD1BIZProfileSetVR = new Set<String>();
            Set<String> HD1BIZQueueSetVR = new Set<String>();
            Set<String> HD2BIZProfileSetVR = new Set<String>();
            Set<String> HD2BIZQueueSetVR = new Set<String>();
            Set<String> MdCQueueSetVR = new Set<String>();
            Set<String> HD1PQSetVR = new Set<String>();
            Set<String> HD1BIZPQSetVR = new Set<String>();
            //MOSCATELLI 11/02/2019: Lob Contabilità -- START
            Set<String> HD1ProfileContaSetVR = new Set<String>();
            Set<String> HD1ProfileContenzSetVR = new Set<String>();            
            //MOSCATELLI 11/02/2019: Lob Contabilità -- END

            //BOVOLENTA_D 04042019 query reduction START
            List<String> filtersMDT = new list<String>{'ProfileManagementValidation','ProfileManagementValidationContabilita','ProfileManagementValidationContenzioso'};
            List<Modello_di_Assistenza__mdt> mdAss =CaseManagement.retrieveCustomMetadataRecords('Modello_di_Assistenza__mdt', filtersMDT);
            /*List<Modello_di_Assistenza__mdt> mdAss = [SELECT Id, DeveloperName,AgentProfile__c, CaseTriggerRecordType__c,
                                                HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c,
                                                HD1BIZProfile__c, HD1BIZQueue__c, HD2BIZProfile__c, HD2BIZQueue__c, Coda_MdC__c ,Value__c
                                                FROM Modello_di_Assistenza__mdt 
                                               WHERE DeveloperName  like 'ProfileManagementValidation%'];
            //BOVOLENTA_D 04042019 query reduction END */              

            
            for(Modello_di_Assistenza__mdt mdAssVR :mdAss)
            {
                if(mdAssVR.DeveloperName=='ProfileManagementValidation')
                {
                    if(String.isNotBlank(mdAssVR.AgentProfile__c))
                        for(String s:mdAssVR.AgentProfile__c.split(';'))
                        AgentProfileSetVR.add(s);   
                    if(String.isNotBlank(mdAssVR.HD1Profile__c))
                    {
                        for(String s:mdAssVR.HD1Profile__c.split(';'))
                        {
                            HD1PQSetVR.add(s);
                            HD1ProfileSetVR.add(s);   
                        }
                    }
                    if(String.isNotBlank(mdAssVR.HD1Queue__c))
                    {
                        for(String s:mdAssVR.HD1Queue__c.split(';'))
                        {
                            HD1PQSetVR.add(s);
                            HD1QueueSetVR.add(s);
                        }
                    }   
                    if(String.isNotBlank(mdAssVR.HD2Profile__c))
                        for(String s:mdAssVR.HD2Profile__c.split(';'))
                        HD2ProfileSetVR.add(s);   
                    if(String.isNotBlank(mdAssVR.HD2Queue__c))
                        for(String s:mdAssVR.HD2Queue__c.split(';'))
                        HD2QueueSetVR.add(s);  
                    if(String.isNotBlank(mdAssVR.HD1BIZProfile__c))
                    {
                        for(String s:mdAssVR.HD1BIZProfile__c.split(';'))
                        {
                            HD1BIZProfileSetVR.add(s);  
                            HD1BIZPQSetVR.add(s);
                        }
                    } 
                    if(String.isNotBlank(mdAssVR.HD1BIZQueue__c))
                    {
                        for(String s:mdAssVR.HD1BIZQueue__c.split(';'))
                        {
                            HD1BIZQueueSetVR.add(s);   
                            HD1BIZPQSetVR.add(s);
                        }
                    }
                    if(String.isNotBlank(mdAssVR.HD2BIZProfile__c))
                        for(String s:mdAssVR.HD2BIZProfile__c.split(';'))
                        HD2BIZProfileSetVR.add(s);   
                    if(String.isNotBlank(mdAssVR.HD2BIZQueue__c))
                        for(String s:mdAssVR.HD2BIZQueue__c.split(';'))
                        HD2BIZQueueSetVR.add(s);  
                    if(String.isNotBlank(mdAssVR.Coda_MdC__c))
                    {
                        for(String s:mdAssVR.Coda_MdC__c.split(';'))
                        {
                            MdCQueueSetVR.add(s);  
                        }
                    } 
                    if(String.isNotBlank(mdAssVR.CaseTriggerRecordType__c))
                        for(String s:mdAssVR.CaseTriggerRecordType__c.split(';'))
                        RecordTypeSetVR.add(s);  
                }
                //MOSCATELLI 11/02/2019: Lob Contabilità -- START
                else if(mdAssVR.DeveloperName=='ProfileManagementValidationContabilita')
                {
                    for(String s: mdAssVR.Value__c.split(';'))
                    {
                        HD1ProfileContaSetVR.add(s);
                    }
                }
                else if(mdAssVR.DeveloperName=='ProfileManagementValidationContenzioso')
                {
                    for(String s: mdAssVR.Value__c.split(';'))
                    {
                        HD1ProfileContenzSetVR.add(s);
                    }                    
                }                
                //MOSCATELLI 11/02/2019: Lob Contabilità -- END
            }
            //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- END
            //OAVERSANO 15/10/2018 : Caring Angel -- START
            Set<String> RecordTypeSetCA = new Set<String>();
            //BOVOLENTA_D 04042019 query reduction START
            List<String> filtersCA = new list<String>{'ProfileManagement'};
            List<Caring_Angel__mdt> caringAngelList =CaseManagement.retrieveCustomMetadataRecords('Caring_Angel__mdt',filtersCA);
            Caring_Angel__mdt caringAngel;
            if(caringAngelList.size()>0)
                caringAngel=caringAngelList[0];
            /*Caring_Angel__mdt caringAngel = [SELECT Id, DeveloperName, CaseTriggerRecordType__c,
                                                HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c 
                                                FROM Caring_Angel__mdt 
                                                WHERE DeveloperName  = 'ProfileManagement'
                                                LIMIT 1];
            //BOVOLENTA_D 04042019 query reduction END */
            if(caringAngel!=null)
            {
                if(String.isNotBlank(caringAngel.HD1Profile__c))
                    for(String s:caringAngel.HD1Profile__c.split(';'))
                    HD1ProfileSet.add(s);   
                if(String.isNotBlank(caringAngel.HD1Queue__c))
                    for(String s:caringAngel.HD1Queue__c.split(';'))
                    HD1QueueSet.add(s);   
                if(String.isNotBlank(caringAngel.HD2Profile__c))
                    for(String s:caringAngel.HD2Profile__c.split(';'))
                    HD2ProfileSet.add(s);   
                if(String.isNotBlank(caringAngel.HD2Queue__c))
                    for(String s:caringAngel.HD2Queue__c.split(';'))
                    HD2QueueSet.add(s);  
                if(String.isNotBlank(caringAngel.CaseTriggerRecordType__c))
                    for(String s:caringAngel.CaseTriggerRecordType__c.split(';'))
                    RecordTypeSetCA.add(s);  
            }
            //OAVERSANO 15/10/2018 : Caring Angel -- END
            
            //OAVERSANO 19/03/2019 : AXA Assistance -- START
            List<String> recTypeSinistriList = new List<String>();
            if(MPS_Code_Variables__c.getValues('RecordTypeSinitri')!=null)
            {
                if(String.isNotBlank(MPS_Code_Variables__c.getValues('RecordTypeSinitri').value__c))
                {
                    for(String s:(MPS_Code_Variables__c.getValues('RecordTypeSinitri').value__c).split(';'))
                    {
                        recTypeSinistriList.add(s);                
                    }
                }
            }
            List<Case> caseSinistriList = new List<Case>();
            for(Case cs:Cases){
                if(recTypeSinistriList.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(cs.RecordTypeId).getName())))
                {
                    caseSinistriList.add(cs);
                }
                
            }
            Set<String> axaAssistanceProfileSet = new Set<String>();
            Set<String> axaAssistanceQueueSet = new Set<String>();
            Set<String> customerOperationProfileSet = new Set<String>();
            Set<String> customerOperationQueueSet = new Set<String>();
            Set<String> RecordTypeSinistriSet = new Set<String>();
            if(!caseSinistriList.isEmpty())
            {
                List<Assistenza_sinistri__mdt> assSinList = [SELECT Id, DeveloperName, Value__c // NOPMD  Fix CRUD violation
                                FROM Assistenza_sinistri__mdt 
                                WHERE DeveloperName LIKE 'claimProfileManagement%'
                                ];
                
                for(Assistenza_sinistri__mdt assSin : assSinList)
                {
                    if(assSin.DeveloperName == 'claimProfileManagementAAProfiles')
                    {
                        if(String.isNotBlank(assSin.Value__c))
                        {
                            for(String s:assSin.Value__c.split(';'))
                            {
                                axaAssistanceProfileSet.add(s); 
                            }  
                        }
                    }
                    else if(assSin.DeveloperName == 'claimProfileManagementAAQueues')
                    {
                        if(String.isNotBlank(assSin.Value__c))
                        {
                            for(String s:assSin.Value__c.split(';'))
                            {
                                axaAssistanceQueueSet.add(s); 
                            }
                        }
                    }
                    else if(assSin.DeveloperName == 'claimProfileManagementCOProfiles')
                    {
                        if(String.isNotBlank(assSin.Value__c))
                        {
                            for(String s:assSin.Value__c.split(';'))
                            {
                                customerOperationProfileSet.add(s); 
                            }
                        }
                    }
                    else if(assSin.DeveloperName == 'claimProfileManagementCOQueues')
                    {
                        if(String.isNotBlank(assSin.Value__c))
                        {
                            for(String s:assSin.Value__c.split(';'))
                            {
                                customerOperationQueueSet.add(s);  
                            }
                        }
                    }
                    else if(assSin.DeveloperName == 'claimProfileManagementRecordTypes')
                    {
                        if(String.isNotBlank(assSin.Value__c))
                        {
                            for(String s:assSin.Value__c.split(';'))
                            {
                                RecordTypeSinistriSet.add(s);
                            }
                        }
                    }
                }
            }
            //OAVERSANO 19/03/2019 : AXA Assistance -- END
            
            Set<String> preSpecialistManagementStatusSet = new Set<String>{AP_Constants.caseStatusAssigned,
                AP_Constants.caseStatusInfoAgenteRicevute,
                AP_Constants.caseStatusRispostaSpecialista};
                    //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza -- END
                    system.debug('@@agentprofileset: '+AgentProfileSet);
            system.debug('@@HD1ProfileSet: '+HD1ProfileSet);
            system.debug('@@HD1QueueSet: '+HD1QueueSet);
            system.debug('@@HD2ProfileSet: '+HD2ProfileSet);
            system.debug('@@RecordTypeSet: '+RecordTypeSet);
            //OAVERSANO 26/09/2018 : ICF Close The Loop -- START
            Set<String> ProfileSmartCenterSet = new Set<String>();
            /*if(MPS_Code_Variables__c.getValues('ProfileSmartCenter')!=null)
            {
                if(String.isNotBlank(MPS_Code_Variables__c.getValues('ProfileSmartCenter').value__c))
                {
                    for(String s:(MPS_Code_Variables__c.getValues('ProfileSmartCenter').value__c).split(';'))
                    {
                        ProfileSmartCenterSet.add(s);                
                    }
                }
            }   */
            List<MPS_Code_Utils__mdt> mpsList = [SELECT Id, DeveloperName, Value__c, High_Volume_Values__c // NOPMD  Fix CRUD violation
                            FROM MPS_Code_Utils__mdt 
                            WHERE DeveloperName LIKE '%CloseTheLoop%'
                            ];
            
            for(MPS_Code_Utils__mdt mps : mpsList)
            {
                if(mps.DeveloperName == 'CloseTheLoop_ProfileSmartCenter')
                {
                    if(String.isNotBlank(mps.High_Volume_Values__c))
                    {
                        for(String s:mps.High_Volume_Values__c.split(';'))
                        {
                            ProfileSmartCenterSet.add(s);
                        }  
                    }
                }
            }
            //OAVERSANO 26/09/2018 : ICF Close The Loop -- END
            //OAVERSANO 23/10/2018 : ICF Close The Loop -- START
            Map<String, String> caseIdOwnerIdMap = new Map<String, String>();
            List<Case> caseToProcessCTM = new List<Case>(); 
            //OAVERSANO 23/10/2018 : ICF Close The Loop -- END
            //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- START
            Set<String> membershipQueue = new Set<String>();
            Map<String, String> memberQueueMap = new Map<String, String>();
            //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- START
            Map<String,List<String>> memberQueuesListMap = new Map<String,List<String>>(); 
            List<String> queueNameSet = new List<String>();
            if(MPS_Code_Variables__c.getValues('NMABizSupportoCode')!=null) //custom setting used to store the name of the queues.
            {
                if(String.isNotBlank(MPS_Code_Variables__c.getValues('NMABizSupportoCode').value__c))
                {
                    for(String s:(MPS_Code_Variables__c.getValues('NMABizSupportoCode').value__c).split(';'))
                    {
                        //MDANTONIO 08/05/2019: LOB VITA - start
                        //queueNameSet.add(s);     
                        queueNameSet.add('HD2 Biz ' + s);
                        //MDANTONIO 08/05/2019: LOB VITA - end               
                    }
                }
            }
            String HD2BizAuto = '';
            String HD2BizFamiglia = '';
            String HD2BizSalute = '';
            //MDANTONIO 08/05/2019: LOB VITA - start
            String HD2BizVitaAssunzione = '';
            String HD2BizVitaContabilitaPrevidenza = '';
            String HD2BizVitaLiquidazioni = '';
            String HD2BizVitaPtfCollettive = '';
            String HD2BizVitaPtfIndividualiRispeProt = '';
            String HD2BizVitaPtfPrevidenza = '';
            String HD2BizVitaSinistriRispeProt = '';
            //MDANTONIO 08/05/2019: LOB VITA - end
            if(!queueNameSet.isEmpty())
            {
                HD2BizAuto = queueNameSet[0]; //HD2 Biz Auto
                HD2BizFamiglia = queueNameSet[1]; //HD2 Biz Famiglia
                HD2BizSalute = queueNameSet[2]; //HD2 Biz Salute
                //MDANTONIO 08/05/2019: LOB VITA - start
                HD2BizVitaAssunzione = queueNameSet[3]; //HD2 Biz Vita Assunzione
                HD2BizVitaContabilitaPrevidenza = queueNameSet[4]; //HD2 Biz Vita Contabilità Previdenza
                HD2BizVitaLiquidazioni = queueNameSet[5]; //HD2 Biz Vita Liquidazioni
                HD2BizVitaPtfCollettive = queueNameSet[6]; //HD2 Biz Vita Ptf Collettive
                HD2BizVitaPtfIndividualiRispeProt = queueNameSet[7]; //HD2 Biz Vita Ptf Individuali Risp e Prot
                HD2BizVitaPtfPrevidenza = queueNameSet[8]; //HD2 Biz Vita Ptf Previdenza
                HD2BizVitaSinistriRispeProt = queueNameSet[9]; //HD2 Biz Vita Sinistri Risp. e Prot.
                //MDANTONIO 08/05/2019: LOB VITA - end
            }
            Set<String> HD2BizAutoMember = new Set<String>();
            Set<String> HD2BizFamigliaMember = new Set<String>();
            Set<String> HD2BizSaluteMember = new Set<String>();
            //MDANTONIO 08/05/2019: LOB VITA - start
            Set<String> HD2BizVitaAssunzioneMember = new Set<String>();
            Set<String> HD2BizVitaContabilitaPrevidenzaMember = new Set<String>();
            Set<String> HD2BizVitaLiquidazioniMember = new Set<String>();
            Set<String> HD2BizVitaPtfCollettiveMember = new Set<String>();
            Set<String> HD2BizVitaPtfIndividualiRispeProtMember = new Set<String>();
            Set<String> HD2BizVitaPtfPrevidenzaMember = new Set<String>();
            Set<String> HD2BizVitaSinistriRispeProtMember = new Set<String>();
            //MDANTONIO 08/05/2019: LOB VITA - end
            List<Case> caseNMAList = new List<Case>();
            for(Case cs:Cases){
                if(RecordTypeSet.contains(Schema.SObjectType.Case.getRecordTypeInfosById().get(cs.RecordTypeId).getDeveloperName()))
                {
                    caseNMAList.add(cs);
                }
            }
            if( /*HD2BIZProfileSetVR.contains(ownerIdProfileNameMap.get(UserInfo.getUserId()))
                ||
                HD2ProfileSetVR.contains(ownerIdProfileNameMap.get(UserInfo.getUserId())) */
                !caseNMAList.isEmpty())
            {
            //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- END
                /*List<GroupMember> membership = [SELECT Group.Name FROM GroupMember WHERE UserOrGroupId =: UserInfo.getUserId() AND Group.Type = 'Queue'];
                if(!membership.isEmpty())
                {
                    for(GroupMember gr:membership)
                    {
                        membershipQueue.add(gr.Group.Name);
                    }
                }
                List<GroupMember> membershipUser = [SELECT Id, Group.Id, Group.Name, UserOrGroupId FROM GroupMember WHERE Group.Name IN: membershipQueue AND Group.Type = 'Queue'];
                if(!membershipUser.isEmpty())
                {
                    for(GroupMember gr:membershipUser)
                    {
                        memberQueueMap.put(gr.UserOrGroupId, gr.Group.Name);
                        memberQueueMap.put(gr.Group.Id, gr.Group.Name); 
                    }
                }*/
                /****/
                String UserLogged = UserInfo.getUserId();
                Map<String, String> queueidNameMap = new Map<String, String>();
                List<GroupMember> membershipQueueUser = [SELECT Id, Group.Id, Group.Name, UserOrGroupId FROM GroupMember WHERE Group.Name LIKE '%HD2%' AND Group.Type = 'Queue' ]; // NOPMD  Fix CRUD violation
                Map<String, List<String>> queueNameMemberMap = new Map<String, List<String>>();
                for(GroupMember grM : membershipQueueUser)
                {
                    queueidNameMap.put(grM.Group.Name, grM.Group.Id);
                    if(queueNameMemberMap.containsKey(grM.Group.Name))
                    {   
                        List<String> queueNameMemberList = queueNameMemberMap.get(grM.Group.Name);
                        queueNameMemberList.add(grM.UserOrGroupId);
                        queueNameMemberMap.put(grM.Group.Name, queueNameMemberList);
                    } 
                    else 
                    {
                        queueNameMemberMap.put(grM.Group.Name, new List<String> { grM.UserOrGroupId }); 
                    }
                }
                //system.debug('queueNameMemberMap: '+JSON.serializePretty(queueNameMemberMap));
                for(String queueName:queueNameMemberMap.keySet())
                {
                    if(queueNameMemberMap.get(queueName).contains(UserLogged))
                    {
                        //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- START  //users can be members of more than one Queue
                        /*membershipQueue.add(queueName);
                        memberQueueMap.put(queueidNameMap.get(queueName),queueName);
                        for(String idUser:queueNameMemberMap.get(queueName))
                        {
                            memberQueueMap.put(idUser, queueName);
                        }*/
                        membershipQueue.add(queueName);
                        memberQueuesListMap.put(queueidNameMap.get(queueName), new List<String> { queueName });
                        for(String idUser:queueNameMemberMap.get(queueName))
                        {
                            if(memberQueuesListMap.containsKey(idUser))
                            {   
                                List<String> queueNameMemberList = memberQueuesListMap.get(idUser);
                                queueNameMemberList.add(queueName);
                                memberQueuesListMap.put(idUser, queueNameMemberList);
                            } 
                            else 
                            {
                                memberQueuesListMap.put(idUser, new List<String> { queueName }); 
                            }
                        }
                        //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- END
                    }
                    //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- START
                    if(queueName.equalsIgnoreCase(HD2BizAuto))
                    {
                        HD2BizAutoMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizAutoMember.add(queueidNameMap.get(queueName));
                    }
                    if(queueName.equalsIgnoreCase(HD2BizFamiglia))
                    {
                        HD2BizFamigliaMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizFamigliaMember.add(queueidNameMap.get(queueName));
                    }
                    if(queueName.equalsIgnoreCase(HD2BizSalute))
                    {
                        HD2BizSaluteMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizSaluteMember.add(queueidNameMap.get(queueName));
                    }
                    //MDANTONIO 08/05/2019: LOB VITA - start
                    if(queueName.equalsIgnoreCase(HD2BizVitaAssunzione))
                    {
                        HD2BizVitaAssunzioneMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizVitaAssunzioneMember.add(queueidNameMap.get(queueName));
                    }
                    if(queueName.equalsIgnoreCase(HD2BizVitaContabilitaPrevidenza))
                    {
                        HD2BizVitaContabilitaPrevidenzaMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizVitaContabilitaPrevidenzaMember.add(queueidNameMap.get(queueName));
                    }
                    if(queueName.equalsIgnoreCase(HD2BizVitaLiquidazioni))
                    {
                        HD2BizVitaLiquidazioniMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizVitaLiquidazioniMember.add(queueidNameMap.get(queueName));
                    }
                    if(queueName.equalsIgnoreCase(HD2BizVitaPtfCollettive))
                    {
                        HD2BizVitaPtfCollettiveMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizVitaPtfCollettiveMember.add(queueidNameMap.get(queueName));
                    }
                    if(queueName.equalsIgnoreCase(HD2BizVitaPtfIndividualiRispeProt))
                    {
                        HD2BizVitaPtfIndividualiRispeProtMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizVitaPtfIndividualiRispeProtMember.add(queueidNameMap.get(queueName));
                    }
                    if(queueName.equalsIgnoreCase(HD2BizVitaPtfPrevidenza))
                    {
                        HD2BizVitaPtfPrevidenzaMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizVitaPtfPrevidenzaMember.add(queueidNameMap.get(queueName));
                    }
                    if(queueName.equalsIgnoreCase(HD2BizVitaSinistriRispeProt))
                    {
                        HD2BizVitaSinistriRispeProtMember.addAll(queueNameMemberMap.get(queueName));
                        HD2BizVitaSinistriRispeProtMember.add(queueidNameMap.get(queueName));
                    }
                    //MDANTONIO 08/05/2019: LOB VITA - end
                    //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- END
                }
                //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- START
                system.debug('memberQueuesListMap: '+memberQueuesListMap); 
                system.debug('HD2BizAutoMember: '+HD2BizAutoMember);
                system.debug('HD2BizFamigliaMember: '+HD2BizFamigliaMember);
                system.debug('HD2BizSaluteMember: '+HD2BizSaluteMember);
                //MDANTONIO 08/05/2019: LOB VITA - start
                system.debug('===> HD2BizVitaAssunzioneMember: ' + HD2BizVitaAssunzioneMember);
                system.debug('===> HD2BizVitaContabilitaPrevidenzaMember: ' + HD2BizVitaContabilitaPrevidenzaMember);
                system.debug('===> HD2BizVitaLiquidazioniMember: ' + HD2BizVitaLiquidazioniMember);
                system.debug('===> HD2BizVitaPtfCollettiveMember: ' + HD2BizVitaPtfCollettiveMember);
                system.debug('===> HD2BizVitaPtfIndividualiRispeProtMember: ' + HD2BizVitaPtfIndividualiRispeProtMember);
                system.debug('===> HD2BizVitaPtfPrevidenzaMember: ' + HD2BizVitaPtfPrevidenzaMember);
                system.debug('===> HD2BizVitaSinistriRispeProtMember: ' + HD2BizVitaSinistriRispeProtMember);
                //MDANTONIO 08/05/2019: LOB VITA - end
                //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- END
                system.debug('memberQueueMap: '+memberQueueMap);
                system.debug('membershipQueue: '+membershipQueue);
                /****/
                
                
            } 
            
            //OAVERSANO 08/04/2019 : DAC Fase II -- START 
            Set<String> recordTypeDAC = new Set<String>(); 
            if(MPS_Code_Variables__c.getValues('RecordTypeDACAXAAgenti')!=null)
            {
                if(String.isNotBlank(MPS_Code_Variables__c.getValues('RecordTypeDACAXAAgenti').value__c))
                {
                    for(String s:(MPS_Code_Variables__c.getValues('RecordTypeDACAXAAgenti').value__c).split(';'))
                    {
                        recordTypeDAC.add(s);                
                    }
                }
            }
            //OAVERSANO 08/04/2019 : DAC Fase II -- END
            //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0911 -- END 
            for(Case c : Cases)
            {     
                //OAVERSANO 21/08/2018: Nuovo Modello di Assistenza -- START  
                system.debug('c.OwnerId: '+c.OwnerId);
                system.debug('OldValues.get(c.Id).OwnerId: '+OldValues.get(c.Id).OwnerId);
                system.debug('ownerIdProfileNameMap.get(c.OwnerId): '+ownerIdProfileNameMap.get(c.OwnerId));
                system.debug('ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId): '+ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId));
                system.debug('MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId)): '+MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()));
                
                if(String.valueOf(c.OwnerId).startsWith('005')&&(String.valueOf(OldValues.get(c.Id).OwnerId)).startsWith('00G') 
                   && (
                       ( HD1ProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && HD1QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) && !HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(c.OwnerId)) && !HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(c.OwnerId))) //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991
                       ||
                       ( HD2ProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && HD2QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) )
                        //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- START
                        ||
                        ( HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && HD1BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) )
                        ||
                        ( HD2BIZProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && HD2BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) )
                        //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- END
                        //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                        || 
                        ( HD1ContabilitaProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && (HD1ContabilitaQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))) )
                        || 
                        ( HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(c.OwnerId)) && (HD1ContabilitaQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))) )
                        || 
                        ( HD1ContenziosoProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && (HD1ContenziosoQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))) )
                        || 
                        ( HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(c.OwnerId)) && (HD1ContenziosoQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))) )
                        //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
                        //OAVERSANO 19/03/2019 : AXA Assistance -- START
                        || 
                        ( axaAssistanceProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && (HD1ContenziosoQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))) )
                        || 
                        ( axaAssistanceProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && (HD1ContenziosoQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))) )
                        //OAVERSANO 19/03/2019 : AXA Assistance -- END
                   )
                   && (RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                        //OAVERSANO 15/10/2018 : Caring Angel -- START
                        ||
                        RecordTypeSetCA.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                        //OAVERSANO 19/03/2019 : AXA Assistance -- START
                        ||
                        RecordTypeSinistriSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                        //OAVERSANO 19/03/2019 : AXA Assistance -- END
                        )
                        //OAVERSANO 15/10/2018 : Caring Angel -- END
                  )
                {
                    c.OldOwnerIsQueue__c = true;
                }
                else
                {
                    c.OldOwnerIsQueue__c = false;  
                } 
                //OAVERSANO 16/09/2018 : Nuovo Modello di Assistenza -- START
                if(String.valueOf(c.OwnerId).startsWith('005')&&(String.valueOf(OldValues.get(c.Id).OwnerId)).startsWith('00G') 
                   && (
                       ( HD1ProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && HD1QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) && !HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(c.OwnerId)) && !HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(c.OwnerId))) //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991
                       ||
                       ( HD2ProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && HD2QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) )
                        //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- START
                        ||
                        ( HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && HD1BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) )
                        ||
                        ( HD2BIZProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && HD2BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) )
                        //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- END
                        //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                        || 
                        ( HD1ContabilitaProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && (HD1ContabilitaQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))) )
                        || 
                        ( HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(c.OwnerId)) && (HD1ContabilitaQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))) )
                        || 
                        ( HD1ContenziosoProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && (HD1ContenziosoQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))) )
                        || 
                        ( HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(c.OwnerId)) && (HD1ContenziosoQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))) )
                        //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
                   )
                   && RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                   && String.IsBlank(c.EntitlementId)
                   && String.IsNotBlank(EntAssAgenti)
                  )
                {
                    //OAVERSANO 19/09/2018 : Nuovo Modello di Assistenza -- START
                    if(MPS_Code_Variables__c.getValues('MilestoneTrackerVisible99H')!=null)
                    {
                        if(MPS_Code_Variables__c.getValues('MilestoneTrackerVisible99H').value__c == 'true')
                        {
                            c.EntitlementId = EntAssAgenti;
                        }
                        
                    }   
                    //OAVERSANO 19/09/2018 : Nuovo Modello di Assistenza -- END
                }
                //OAVERSANO 16/09/2018 : Nuovo Modello di Assistenza -- END
                //OAVERSANO 21/08/2018: Nuovo Modello di Assistenza -- END     
                if(c.Category__c <> OldValues.get(c.id).Category__c
                   || c.SubCategory__c <> OldValues.get(c.id).SubCategory__c
                   || c.Origin <> OldValues.get(c.id).Origin
                   //|| (c.AgentName__c <> OldValues.get(c.id).AgentName__c && String.isNotBlank(c.AgentName__c))
                   || (c.Prodotto__c <> OldValues.get(c.id).Prodotto__c && String.isNotBlank(c.Prodotto__c))
                   || (c.Distribution_Network__c <> OldValues.get(c.id).Distribution_Network__c && String.isNotBlank(c.Distribution_Network__c))
                   || (c.Data_ricezione_richiesta_DPO__c <> OldValues.get(c.id).Data_ricezione_richiesta_DPO__c)
                  )
                {
                    system.debug('data changed');
                    //c.EntitlementId=Entid;
                    if((c.Data_ricezione_richiesta_DPO__c <> OldValues.get(c.id).Data_ricezione_richiesta_DPO__c) && c.Data_ricezione_richiesta_DPO__c <> null)
                    {
                        if(!GDPRCategories.contains(c.Category__c))
                        {
                            c.addError('Attenzione! Non è possibile apportare modifiche al dato selezionato non essendo la richiesta in ambito GDPR');
                            return outc;
                        }
                        
                        c.SlaStartDate = c.Data_ricezione_richiesta_DPO__c;
                        c.StartDate_MilestoneTimer__c = c.SlaStartDate;
                    }
                    
                    if((c.Data_ricezione_richiesta_DPO__c <> OldValues.get(c.id).Data_ricezione_richiesta_DPO__c) && c.Data_ricezione_richiesta_DPO__c == null){
                        
                        c.SlaStartDate = c.CreatedDate;
                        c.StartDate_MilestoneTimer__c = c.SlaStartDate;
                    }
                    
                    c.EntitlementId =null;
                    c.Tempo_trascorso_in_DPO_in_BH__c = null;
                    CalculateSLAList.add(c);
                }
                
                if(String.isNotBlank(c.TECH_eKomi_comment__c) && (OldValues.get(c.id).TECH_eKomi_comment__c <> c.TECH_eKomi_comment__c))
                    c.TECH_eKomi_comment__c = (c.TECH_eKomi_comment__c).normalizeSpace();           
                
                //OAVERSANO 18/01/2019 : Gestione Reclami -- START
                if(String.isBlank(c.AccountId) && String.isNotBlank(c.SuppliedEmail) && !DoNotCopyEmail.contains(c.SuppliedEmail))
                {
                    c.Account_email__c = c.SuppliedEmail;
                }
                //OAVERSANO 18/01/2019 : Gestione Reclami -- END                
                
                if((c.AccountId <> OldValues.get(c.id).AccountId) 
                   && String.isNotBlank(c.AccountId) 
                   && MapCaseAccount.containsKey(c.AccountId))
                {
                    //MOSCATELLI_M 02/07/2018: Easy Azienda -- START
                    //if(String.IsBlank(c.AgentName__c) || String.IsBlank(c.Account_email__c))
                    if((String.IsBlank(c.AgentName__c) && String.IsBlank(c.User__c)) || String.IsBlank(c.Account_email__c))
                        //MOSCATELLI_M 02/07/2018: Easy Azienda -- END
                    {
                        c.Account_email__c='';
                        
                        //OAVERSANO 03/08/2018 BUG Fix FATIGA -- START
                        //if(String.isblank(c.SuppliedEmail))
                        if(String.isblank(c.SuppliedEmail) || DoNotCopyEmail.contains(c.SuppliedEmail))
                            //OAVERSANO 03/08/2018 BUG Fix FATIGA -- END
                        {
                            if(!(string.isBlank(MapCaseAccount.get(c.AccountId).Additional_Email__c)))
                                c.Account_email__c = MapCaseAccount.get(c.AccountId).Additional_Email__c;                   
                            
                            else if(MapCaseAccount.get(c.AccountId).RecordType.developername == AP_Constants.rtAccIndividualClient || MapCaseAccount.get(c.AccountId).RecordType.developername == AP_Constants.rtAccB2C || MapCaseAccount.get(c.AccountId).RecordType.developername == AP_Constants.rtAccIntermediary)
                            { 
                                if(String.isNotBlank(MapCaseAccount.get(c.AccountId).CIF_PersonEmail__c))
                                    c.Account_email__c = MapCaseAccount.get(c.AccountId).CIF_PersonEmail__c;
                                else if(String.isNotBlank(MapCaseAccount.get(c.AccountId).CIF_Work_email__c))
                                    c.Account_email__c = MapCaseAccount.get(c.AccountId).CIF_Work_email__c;                  
                                else if(!string.isBlank(MapCaseAccount.get(c.AccountId).PersonEmail))
                                    c.Account_email__c = MapCaseAccount.get(c.AccountId).PersonEmail;
                                else if(String.isNotBlank(MapCaseAccount.get(c.AccountId).Claim_PersonalEmail__c))
                                    c.Account_email__c = MapCaseAccount.get(c.AccountId).Claim_PersonalEmail__c;
                            }    
                            else if(MapCaseAccount.get(c.AccountId).RecordType.developername == AP_Constants.rtAccCorporateClient)
                            {
                                if(!(string.isBlank(MapCaseAccount.get(c.AccountId).Account_email__c)))
                                    c.Account_email__c = MapCaseAccount.get(c.AccountId).Account_email__c;
                                else if(String.isNotBlank(MapCaseAccount.get(c.AccountId).Claim_PersonalEmail__c))
                                    c.Account_email__c = MapCaseAccount.get(c.AccountId).Claim_PersonalEmail__c;
                            }      
                            else if(MapCaseAccount.get(c.AccountId).RecordType.developername == AP_Constants.rtAccB2B)
                            {
                                if(String.isNotBlank(MapCaseAccount.get(c.AccountId).CIF_PersonalEmail__c))
                                    c.Account_email__c = MapCaseAccount.get(c.AccountId).CIF_PersonalEmail__c;
                                else if(String.isNotBlank(MapCaseAccount.get(c.AccountId).CIF_Work_email__c))
                                    c.Account_email__c = MapCaseAccount.get(c.AccountId).CIF_Work_email__c;                         
                                else if(string.isNotBlank(MapCaseAccount.get(c.AccountId).Subject_email__c))
                                    c.Account_email__c = MapCaseAccount.get(c.AccountId).Subject_email__c; 
                                else if(String.isNotBlank(MapCaseAccount.get(c.AccountId).Claim_PersonalEmail__c))
                                    c.Account_email__c = MapCaseAccount.get(c.AccountId).Claim_PersonalEmail__c;
                            }                   
                        }
                        else
                            //OAVERSANO 03/08/2018 BUG Fix FATIGA -- START
                        {
                            if(!DoNotCopyEmail.contains(c.SuppliedEmail))
                                c.Account_email__c = c.SuppliedEmail;
                        }
                        //OAVERSANO 03/08/2018 BUG Fix FATIGA -- END    
                    }                          
                    
                    if(MapAssociatedPolicies.containsKey(c.AccountId))
                        c.LinkToPolicy__c = MapAssociatedPolicies.get(c.AccountId);
                    
                    if(String.isNotBlank(OldValues.get(c.id).AccountId))
                        c.LinkToPolicy__c= null;                
                }
                
                if((c.AgentName__c <> OldValues.get(c.id).AgentName__c) && String.isNotBlank(c.AgentName__c) && MapCaseAccount.containsKey(c.AgentName__c))
                {
                    c.Account_email__c='';
                    
                    //OAVERSANO 03/08/2018 BUG Fix FATIGA -- START
                    //if(String.isblank(c.SuppliedEmail))
                    if(String.isblank(c.SuppliedEmail) || DoNotCopyEmail.contains(c.SuppliedEmail))
                        //OAVERSANO 03/08/2018 BUG Fix FATIGA -- END
                    {
                        if(!(string.isBlank(MapCaseAccount.get(c.AgentName__c).Additional_Email__c)))
                            c.Account_email__c = MapCaseAccount.get(c.AgentName__c).Additional_Email__c;                    
                        
                        else if(MapCaseAccount.get(c.AgentName__c).RecordType.developername == AP_Constants.rtAccIntermediary)
                        { 
                            c.Account_email__c = MapCaseAccount.get(c.AgentName__c).PersonEmail;
                        }                       
                    }
                    else
                        //OAVERSANO 03/08/2018 BUG Fix FATIGA -- START
                    {
                        if(!DoNotCopyEmail.contains(c.SuppliedEmail))
                            c.Account_email__c = c.SuppliedEmail;
                    }
                    //OAVERSANO 03/08/2018 BUG Fix FATIGA -- END                                         
                } 
                
                //MOSCATELLI_M 02/07/2018: Easy Azienda -- START
                if((c.User__c <> OldValues.get(c.id).User__c) && String.isNotBlank(c.User__c) && MapAAIAgent.containsKey(c.User__c))
                {
                    c.Agency_Code__c = MapAAIAgent.get(c.User__c).Agency_Code__c;
                    c.Account_email__c='';
                    //c.Agenzia__c=MapAAIAgent.get(c.User__c).Contact.AccountId;//MOSCATELLI_M 02/07/2018: Easy Azienda -- START 

                    //OAVERSANO 03/08/2018 BUG Fix FATIGA -- START
                    //if(String.isblank(c.SuppliedEmail))
                    if(String.isblank(c.SuppliedEmail) || DoNotCopyEmail.contains(c.SuppliedEmail))
                        //OAVERSANO 03/08/2018 BUG Fix FATIGA -- END
                    {
                        c.Account_email__c = MapAAIAgent.get(c.User__c).Email;                                               
                    }
                    else
                        //OAVERSANO 03/08/2018 BUG Fix FATIGA -- START
                    {
                        if(!DoNotCopyEmail.contains(c.SuppliedEmail))
                            c.Account_email__c = c.SuppliedEmail;
                    }
                    //OAVERSANO 03/08/2018 BUG Fix FATIGA -- END    
                }

                //OAVERSANO 17/06/2019 fix codice agenzia -- START
                //if(String.isnotblank(c.Agency_Code__c) && (c.Agency_Code__c <> OldValues.get(c.id).Agency_Code__c)) 
                if( String.isnotblank(c.Agency_Code__c) && ( (c.Agency_Code__c <> OldValues.get(c.id).Agency_Code__c) || (c.Agenzia__c == null)) ) 
                //OAVERSANO 17/06/2019 fix codice agenzia -- END
                {
                    if(MapAgencies.containskey(c.Agency_Code__c)){
                        c.Agenzia__c = MapAgencies.get(c.Agency_Code__c).Id;
                        c.Agency_Email__c = MapAgencies.get(c.Agency_Code__c).Agency_Email__c;
                    }
                }
                //MOSCATELLI_M 02/07/2018: Easy Azienda -- END              
                
                if(string.isNotBlank(c.LinkToPolicy__c) && (c.LinkToPolicy__c <> OldValues.get(c.id).LinkToPolicy__c))
                {
                    if(MapInsertedPolicy.containsKey(c.LinkToPolicy__c) && c.AccountId<>MapInsertedPolicy.get(c.LinkToPolicy__c).CUID__c)
                        c.AccountId = MapInsertedPolicy.get(c.LinkToPolicy__c).CUID__c;                                                                  
                }           
                
                if(String.isNotBlank(c.AccountId) && (c.TECH_Automatic_Emails_Sent__c <> OldValues.get(c.id).TECH_Automatic_Emails_Sent__c) && String.isNotBlank(c.TECH_Automatic_Emails_Sent__c))
                {
                    if(String.isNotBlank(OldValues.get(c.id).TECH_Automatic_Emails_Sent__c))                
                        SMSInputsList.add(c.Id+'|'+c.AccountId+'|'+(String.valueOf(c.TECH_Automatic_Emails_Sent__c)).substringafterlast('|'));              
                    else                
                        SMSInputsList.add(c.Id+'|'+c.AccountId+'|'+String.valueOf(c.TECH_Automatic_Emails_Sent__c));                
                }
                
                if(c.Feedback_Provided_to_Customer__c == true)
                {
                    if(OldValues.get(c.id).Inform_Customers_with_Alerts__c == true)
                        c.Inform_Customers_with_Alerts__c = false;              
                    
                    Double NineDays = 9;
                    
                    String BZHoursToUse = (GDPRCategories.contains(c.Category__c))?GDPRHoursId:defaultHoursId;
                    Integer DayHours = (GDPRCategories.contains(c.Category__c))?24:10;
                    
                    if(c.Second_Long_Term_Management_Alert_DT__c != null)
                        c.Second_Long_Term_Management_Alert_DT__c = BusinessHours.addGMT(BZHoursToUse,System.now(),((NineDays*DayHours)*60 * 60 * 1000L).longValue());
                    
                    if(c.Third_Long_Term_Management_Alert_DT__c != null && c.Second_Long_Term_Management_Alert_DT__c == null)
                        c.Third_Long_Term_Management_Alert_DT__c = BusinessHours.addGMT(BZHoursToUse,System.now(),((NineDays*DayHours)*60 * 60 * 1000L).longValue());
                }
                
                if(c.ownerid <> OldValues.get(c.id).ownerid)
                {
                    //OAVERSANO 12/12/2018 : Enhancement NMA Biz -- START
                    if((
                        //MDANTONIO 08/05/2019: LOB VITA - start
                        //(HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid)
                        (HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid) && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                        //MDANTONIO 08/05/2019: LOB VITA - end
                        ||
                        (HD2BizAutoMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobAuto)
                        )
                        && c.Supporto_HD2_Biz_Auto__c != true)
                    {
                        c.Supporto_HD2_Biz_Auto__c = true;
                    }
                    if((
                        //MDANTONIO 08/05/2019: LOB VITA - start
                        //(!HD2BizAutoMember.contains(c.ownerid) && HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid)
                        (!HD2BizAutoMember.contains(c.ownerid) && HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid) && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                        //MDANTONIO 08/05/2019: LOB VITA - end
                        ||
                        (HD2BizFamigliaMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobFamiglia)
                        )
                        && c.Supporto_HD2_Biz_Famiglia__c != true)
                    {
                        c.Supporto_HD2_Biz_Famiglia__c = true;
                    }
                    if((
                        //MDANTONIO 08/05/2019: LOB VITA - start
                        //(!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && HD2BizSaluteMember.contains(c.ownerid)
                        (!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && HD2BizSaluteMember.contains(c.ownerid) && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                        //MDANTONIO 08/05/2019: LOB VITA - start
                        ||
                        (HD2BizSaluteMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobSalute)
                        )
                        && c.Supporto_HD2_Biz_Salute__c != true)
                    {
                        c.Supporto_HD2_Biz_Salute__c = true;
                    }
                    //OAVERSANO 12/12/2018 : Enhancement NMA Biz -- END
                    
                    //MDANTONIO 09/05/2019: LOB VITA - start
                    if((
                        (!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid)  && HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                        ||
                        (HD2BizVitaAssunzioneMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobVita && (categorySubcategoryToQueue.containsKey(c.Category__c) && categorySubcategoryToQueue.get(c.Category__c).equalsIgnoreCase(HD2BizVitaAssunzione)))
                        )
                        && !c.Supporto_HD2_Biz_Vita_Assunzione__c)
                    {
                        c.Supporto_HD2_Biz_Vita_Assunzione__c = true;
                    }
                    if((
                        (!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid)  && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                        ||
                        (HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobVita && (categorySubcategoryToQueue.containsKey(c.Category__c) && categorySubcategoryToQueue.get(c.Category__c).equalsIgnoreCase(HD2BizVitaContabilitaPrevidenza)))
                        )
                        && !c.Supporto_HD2_Biz_Vita_Contabilita_Prev__c)
                    {
                        c.Supporto_HD2_Biz_Vita_Contabilita_Prev__c = true;
                    }
                    if((
                        (!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid)  && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                        ||
                        (HD2BizVitaLiquidazioniMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobVita && (categorySubcategoryToQueue.containsKey(c.Category__c + '_' + c.SubCategory__c) && categorySubcategoryToQueue.get(c.Category__c + '_' + c.SubCategory__c).equalsIgnoreCase(HD2BizVitaLiquidazioni)))
                        )
                        && !c.Supporto_HD2_Biz_Vita_Liquidazioni__c)
                    {
                        c.Supporto_HD2_Biz_Vita_Liquidazioni__c = true;
                    }
                    if((
                        (!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid)  && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                        ||
                        (HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobVita && (categorySubcategoryToQueue.containsKey(c.Category__c) && categorySubcategoryToQueue.get(c.Category__c).equalsIgnoreCase(HD2BizVitaPtfCollettive)))
                        )
                        && !c.Supporto_HD2_Biz_Vita_Ptf_Collettive__c)
                    {
                        c.Supporto_HD2_Biz_Vita_Ptf_Collettive__c = true;
                    }
                    if((
                        (!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid)  && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                        ||
                        (HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobVita && (categorySubcategoryToQueue.containsKey(c.Category__c) && categorySubcategoryToQueue.get(c.Category__c).equalsIgnoreCase(HD2BizVitaPtfIndividualiRispeProt)))
                        )
                        && !c.Supporto_HD2_Biz_Vita_Ptf_Ind_Risp_Prot__c)
                    {
                        c.Supporto_HD2_Biz_Vita_Ptf_Ind_Risp_Prot__c = true;
                    }
                    if((
                        (!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid)  && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                        ||
                        (HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobVita && (categorySubcategoryToQueue.containsKey(c.Category__c) && categorySubcategoryToQueue.get(c.Category__c).equalsIgnoreCase(HD2BizVitaPtfPrevidenza)))
                        )
                        && !c.Supporto_HD2_Biz_Vita_Ptf_Previdenza__c)
                    {
                        c.Supporto_HD2_Biz_Vita_Ptf_Previdenza__c = true;
                    }
                    if((
                        (!HD2BizAutoMember.contains(c.ownerid) && !HD2BizFamigliaMember.contains(c.ownerid) && !HD2BizSaluteMember.contains(c.ownerid)  && !HD2BizVitaAssunzioneMember.contains(c.ownerid) && !HD2BizVitaContabilitaPrevidenzaMember.contains(c.ownerid) && !HD2BizVitaLiquidazioniMember.contains(c.ownerid) && !HD2BizVitaPtfCollettiveMember.contains(c.ownerid) && !HD2BizVitaPtfIndividualiRispeProtMember.contains(c.ownerid) && !HD2BizVitaPtfPrevidenzaMember.contains(c.ownerid) && HD2BizVitaSinistriRispeProtMember.contains(c.ownerid))
                        ||
                        (HD2BizVitaSinistriRispeProtMember.contains(c.ownerid) && c.LOB__c == AP_Constants.caseLobVita && (categorySubcategoryToQueue.containsKey(c.Category__c + '_' + c.SubCategory__c) && categorySubcategoryToQueue.get(c.Category__c + '_' + c.SubCategory__c).equalsIgnoreCase(HD2BizVitaSinistriRispeProt)))
                        )
                        && !c.Supporto_HD2_Biz_Vita_Sinis_Risp_e_Prot__c)
                    {
                        c.Supporto_HD2_Biz_Vita_Sinis_Risp_e_Prot__c = true;
                    }
                    //MDANTONIO 09/05/2019: LOB VITA - end
                    //
                    /*
                    if((HD1ProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) || HD1QueueSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) || HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) || HD1BIZQueueSet.contains(ownerIdProfileNameMap.get(c.OwnerId))) && RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName())))
                        c.Owner_HD1__c = ownerIdNameMap.get(c.OwnerId);*/
                    if((c.Lob__c == 'IT') && (HD1ProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) || HD1QueueSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) || HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) || HD1BIZQueueSet.contains(ownerIdProfileNameMap.get(c.OwnerId))) && RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName())))
                        c.Owner_HD1__c = ownerIdNameMap.get(c.OwnerId);
                    else if(c.Lob__c != 'IT' && RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName())) && ownerIdProfileNameMap.containskey(OldValues.get(c.Id).OwnerId))
                    {
                        //if(String.valueOf(c.OwnerId).startswith('005'))
                        if((ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)).indexOf('AAI - Vendite')<>-1)
                        {
                            c.Owner_HD1__c = ownerIdNameMap.get(c.OwnerId);
                        }
                        else if((ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)).indexOf('AAI - Vendite')==-1 && !(HD2QueueSet.contains(ownerIdProfileNameMap.get(c.OwnerId))) && !(HD2BIZQueueSet.contains(ownerIdProfileNameMap.get(c.OwnerId))))
                        {
                            c.Owner_HD1__c = ownerIdNameMap.get(c.OwnerId);
                        }
                    }
                    
                    //VIZZINI_D 02/07/2019: NMA - Lob Modulo di Calcolo - START
                    if(HD1ProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) || HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) && RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))){
                        
                        c.Last_Advisor__c = OldValues.get(c.Id).OwnerId;
                    }
                    //VIZZINI_D 02/07/2019: NMA - Lob Modulo di Calcolo - END

                    //
                    //OAVERSANO 26/09/2018 : ICF Close The Loop -- START
                    if((AgentProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) || (ownerIdProfileNameMap.get(c.OwnerId) != null && ownerIdProfileNameMap.get(c.OwnerId).contains('Coda Agenzia'))) && ProfileSmartCenterSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).ownerid)) && MapCaseRecordType.get(c.RecordTypeId).getName() == AP_Constants.rtCaseCloseTheLoop)
                    {
                        c.Last_Advisor__c = OldValues.get(c.id).ownerid;
                        c.CTL_da_agenzia__c = true;
                        //OAVERSANO 24/10/2018 : ICF Close The Loop -- START
                        c.Status = AP_Constants.caseStatusGestioneAgente;

                        c = ServiceUtilsClass.setAgentICFAlerts(c,ICFAgentiHours);//MMOSCATELLI 28/03/2019: ICF CR2

                        if(ownerIdProfileNameMap.get(c.OwnerId).contains('Coda Agenzia'))
                        {
                            c.Limite_Attivit_CTL_Agenti__c = c.TECH_Secondo_Sollecito_Agenti__c.format('dd/MM/yyyy HH:mm');
                        }
                        //OAVERSANO 24/10/2018 : ICF Close The Loop -- END                  
                    }
                    //OAVERSANO 26/09/2018 : ICF Close The Loop -- END
                    //OAVERSANO 23/10/2018 : ICF Close The Loop -- START
                    if(AgentProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && MapCaseRecordType.get(c.RecordTypeId).getName() == AP_Constants.rtCaseCloseTheLoop)
                    {
                        caseIdOwnerIdMap.put(c.Id,c.OwnerId);
                        caseToProcessCTM.add(c);
                    }
                    //OAVERSANO 23/10/2018 : ICF Close The Loop -- END
                    
                    
                    //OAVERSANO 02/10/2018 : Nuovo Modello di Assistenza -- START
                    system.debug('UserInfo.getUserId(): '+UserInfo.getUserId());
                    system.debug('ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId): '+HD1ProfileSet.contains(UserInfo.getUserId()));
                    system.debug('HD1QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)): '+HD1QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)));
                    system.debug('HD1QueueSet: '+HD1QueueSet);
                    system.debug('OldValues.get(c.Id).OwnerId: '+OldValues.get(c.Id).OwnerId);
                    //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0906 -- START
                    system.debug('c.OwnerId: '+UserInfo.getUserId());
                    system.debug('HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(UserInfo.getUserId())): '+HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(UserInfo.getUserId())));
                    system.debug('(HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))): '+!(HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))));
                    system.debug('(HD1BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))): '+(HD1BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))));
                    system.debug('OldValues.get(c.Id).OwnerId: '+OldValues.get(c.Id).OwnerId);
                    //HD1 Biz Validation Rule
                    if( HD1BIZProfileSetVR.contains(ownerIdProfileNameMap.get(UserInfo.getUserId()))
                        && RecordTypeSetVR.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                        && OldValues.get(c.Id).OwnerId != UserInfo.getUserId()                              
                        )
                    {
                        system.debug('HD1 Biz user');   
                        if( (!(HD1BIZPQSetVR.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)))  
                            && c.OwnerId == UserInfo.getUserId()
                            )
                            ||
                            ((HD1BIZPQSetVR.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)))   
                            && c.OwnerId != UserInfo.getUserId())
                            )
                        {
                            c.addError(Label.ChangeOwnerValidationMessageNMA);
                        }
                    }
                    //HD2 Biz Validation Rule
                    if( HD2BIZProfileSetVR.contains(ownerIdProfileNameMap.get(UserInfo.getUserId()))
                        && RecordTypeSetVR.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                        && OldValues.get(c.Id).OwnerId != UserInfo.getUserId()                              
                        )
                    {
                        system.debug('HD2 Biz user');   
                        system.debug('membershipQueue: '+membershipQueue);
                        //OAVERSANO 12/12/2018 : Enhancement NMA Biz -- START
                        /*if(( !(membershipQueue.contains(memberQueueMap.get(OldValues.get(c.Id).OwnerId)))
                            && (membershipQueue.contains(memberQueueMap.get(c.OwnerId)))
                            )
                            ||
                            ( (membershipQueue.contains(memberQueueMap.get(OldValues.get(c.Id).OwnerId)))
                            && !(membershipQueue.contains(memberQueueMap.get(c.OwnerId)))
                            )
                            )
                        {
                            c.addError(Label.ChangeOwnerValidationMessageNMA);
                        }*/
                        Boolean runVR = true;
                        for(String queuename : membershipQueue)
                        {
                            //check if the old owner and the new owner are members of the same queue
                            if((memberQueuesListMap.containsKey(String.valueOf(OldValues.get(c.Id).OwnerId)))
                                &&
                                (memberQueuesListMap.containsKey(String.valueOf(c.OwnerId)))
                                )
                                {
                                if(( (memberQueuesListMap.get(OldValues.get(c.Id).OwnerId)).contains(queuename)
                                    && (memberQueuesListMap.get(c.OwnerId)).contains(queuename)
                                    )
                                    )
                                {
                                    runVR = false;      
                                    break;
                                }
                            }
                        }
                        if(runVR)
                        {
                            c.addError(Label.ChangeOwnerValidationMessageNMA);
                        }
                        //OAVERSANO 12/12/2018 : Enhancement NMA Biz -- END
                    }
                    //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza AXA MPS -- Sprint 84 | US-0906 -- END
                    //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza AXA MPS -- ENHANCEMENT -- START
                    //HD1 Validation Rule
                    if( HD1ProfileSetVR.contains(ownerIdProfileNameMap.get(UserInfo.getUserId()))
                        && !HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(UserInfo.getUserId())) && !HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(UserInfo.getUserId())) //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                        && RecordTypeSetVR.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                        && OldValues.get(c.Id).OwnerId != UserInfo.getUserId()                              
                        )
                    {
                        system.debug('HD1 user');   
                        if( ((!(HD1PQSetVR.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))) ||
                            (HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(c.Id).OwnerId))|| HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(c.Id).OwnerId))))    
                            && c.OwnerId == UserInfo.getUserId()
                            )
                            ||
                            ((HD1PQSetVR.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)))  
                            && c.OwnerId != UserInfo.getUserId())
                            )
                        {
                            c.addError(Label.ChangeOwnerValidationMessageNMA);
                        }
                    }
                    //HD2 Validation Rule
                    if( HD2ProfileSetVR.contains(ownerIdProfileNameMap.get(UserInfo.getUserId()))
                        && RecordTypeSetVR.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                        && OldValues.get(c.Id).OwnerId != UserInfo.getUserId()   
                        )
                    {
                        system.debug('HD2 user');   
                        //system.debug('memberQueueMap: '+JSON.serializePretty(memberQueueMap));
                        system.debug('membershipQueue: '+membershipQueue);
                        //OAVERSANO 12/12/2018 : Enhancement NMA Biz -- START
                        /*if( ( !(membershipQueue.contains(memberQueueMap.get(OldValues.get(c.Id).OwnerId)))
                            && (membershipQueue.contains(memberQueueMap.get(c.OwnerId)))
                            )
                            ||
                            ( (membershipQueue.contains(memberQueueMap.get(OldValues.get(c.Id).OwnerId)))
                            && !(membershipQueue.contains(memberQueueMap.get(c.OwnerId)))
                            )
                            )
                        {
                            c.addError(Label.ChangeOwnerValidationMessageNMA);
                        }*/
                        Boolean runVR = true;
                        for(String queuename : membershipQueue)
                        {
                            //check if the old owner and the new owner are members of the same queue
                            if((memberQueuesListMap.containsKey(String.valueOf(OldValues.get(c.Id).OwnerId)))
                                &&
                                (memberQueuesListMap.containsKey(String.valueOf(c.OwnerId)))
                                )
                                {
                                if(( (memberQueuesListMap.get(OldValues.get(c.Id).OwnerId)).contains(queuename)
                                    && (memberQueuesListMap.get(c.OwnerId)).contains(queuename)
                                    )
                                    )
                                {
                                    runVR = false;
                                    break;
                                }
                            }
                        }
                        //OAVERSANO 05/07/2019 : NMA - Lob Modulo di Calcolo -- START
                        //if(runVR)
                        if(runVR
	                        && c.TECH_Soluzione_non_testata__c == false    
	                        && OldValues.get(c.Id).Da_testare_Modulo_di_Calcolo__c == true)    
                        //OAVERSANO 05/07/2019 : NMA - Lob Modulo di Calcolo -- END 
                        {
                            c.addError(Label.ChangeOwnerValidationMessageNMA);
                        }
                        //OAVERSANO 12/12/2018 : Enhancement NMA Biz -- END
                    }
                    //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza AXA MPS -- ENHANCEMENT -- END
                    //OAVERSANO 02/10/2018 : Nuovo Modello di Assistenza -- END

                    //MOSCATELLI 11/02/2019: Lob Contabilità -- START
                    if((HD1ProfileContaSetVR.contains(ownerIdProfileNameMap.get(UserInfo.getUserId())) ||
                        HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(UserInfo.getUserId())) ||
                        HD1ProfileContenzSetVR.contains(ownerIdProfileNameMap.get(UserInfo.getUserId())) ||
                        HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(UserInfo.getUserId()))) &&
                        RecordTypeSetVR.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName())) &&
                        OldValues.get(c.Id).OwnerId != UserInfo.getUserId()                              
                        )
                    {  
                        system.debug('HD1 Contabilità o HD1 Contenzioso');

                        if(c.OwnerId == UserInfo.getUserId() &&
                           (!String.ValueOf(OldValues.get(c.Id).OwnerId).startswith('00G') && (!HD1BIZProfileSetVR.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) &&
                                                                                              !HD1ProfileContaSetVR.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) &&
                                                                                              !HD1ProfileContenzSetVR.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) &&
                                                                                              !HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(c.Id).OwnerId)) &&
                                                                                              !HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(c.Id).OwnerId))) ||
                           (String.ValueOf(OldValues.get(c.Id).OwnerId).startswith('00G') && !HD1ProfileContaSetVR.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId)) &&
                                                                                             !HD1ProfileContenzSetVR.contains(ownerIdProfileNameMap.get(OldValues.get(c.Id).OwnerId))))) 
                        {
                            c.addError(Label.ChngOwnValidMsgNMAContabilita);                           
                        }               
                    }                                          
                    //MOSCATELLI 11/02/2019: Lob Contabilità -- END
                    
                    if( c.status <> AP_Constants.caseStatusOpen
                       && c.status <> AP_Constants.caseStatusChiusuraEmail
                       && String.ValueOf(c.ownerid).startswith(AP_Constants.QueueKeyPrefix)
                       && String.ValueOf(OldValues.get(c.id).ownerid).startswith(AP_Constants.UserKeyPrefix)     
                       && !RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))  //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza  US-0763           
                       //OAVERSANO 26/09/2018 : ICF Close The Loop -- START
                       && c.status <> AP_Constants.caseStatusInfoAgenteRicevuta
                       && c.status <> AP_Constants.caseStatusGestioneAgente
                       && c.status <> AP_Constants.caseStatusMancataGestioneAgente
                       && c.status <> AP_Constants.caseStatusGestioneSpecialistica
                       //OAVERSANO 26/09/2018 : ICF Close The Loop -- END
                       && !RecordTypeSetCA.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))  //OAVERSANO 15/10/2018 : Caring Angel 
                       //MMOSCATELLI 19032019:Axa Assistance — START
                       && !RecordTypeSinistriSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                       //MMOSCATELLI 19032019:Axa Assistance — END
					   && MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()) != AP_Constants.rtCaseCaringSalute
                       && MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()) != AP_Constants.rtCaseCaringProperty
                      )
                    {
                        c.status = AP_Constants.caseStatusOpen;
                    }
                    
                    //OAVERSANO 15/10/2018 : Caring Angel -- START
                    if(     (HD2QueueSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                             ||
                             HD2ProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                            )
                       && 
                       (
                        HD1ProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                        ||
                        HD2QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                        && (OldValues.get(c.id).Status) != AP_Constants.caseStatusAssIILivello
                       )
                       && RecordTypeSetCA.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                      )
                    {
                        c.status = AP_Constants.caseStatusAssIILivello;
                    }
                    if(     (HD1QueueSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                             ||
                             HD1ProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                            )
                       && 
                       (HD2QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                        ||
                        HD2ProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId)))
                       && RecordTypeSetCA.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                      )
                    {
                        c.status = AP_Constants.caseStatusAssILivello;
                    }
                    //OAVERSANO 15/10/2018 : Caring Angel -- END
                    
                    //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza -- START    US-0763 
                    if(     (HD2QueueSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                             ||
                             HD2ProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                            )
                       && HD1ProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                       /*&& preSpecialistManagementStatusSet.contains(c.Status)*/
                       && RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                      )
                    {
                        c.status = AP_Constants.caseStatusGestioneSpecialistica;
                        c.Supporto_HD2__c = true;
                    }
                    //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza -- END  US-0763
                    
                    //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza -- START    US-0764 
                    if(     (HD1QueueSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                             ||
                             HD1ProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                            )
                       && 
                       (HD2QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                        ||
                        HD2ProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId)))
                       /*&& c.Status == AP_Constants.caseStatusGestioneSpecialistica*/
                       && RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                      )
                    {
                        c.status = AP_Constants.caseStatusRispostaSpecialista;
                    }
                    //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- START 
                    if( MdCQueueSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                        && RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                      )
                    {
                        c.Supporto_MdC__c = true;
                    }
                    if(     (HD2BIZQueueSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                             ||
                             HD2BIZProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                            )
                        && 
                            (HD1BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId)))
                        && RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                      )
                    {
                        c.status = AP_Constants.caseStatusGestioneSpecialistica;
                        //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- START
                        //c.Supporto_HD2_Biz__c = true;     //field splitted into several fields.
                        //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- END
                    }
                    if(     (HD1BIZQueueSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                             ||
                             HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                            )
                        && 
                            (HD2BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD2BIZProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId)))
                        && RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                      )
                    {
                        c.status = AP_Constants.caseStatusRispostaSpecialista;
                    }
                    if(     (HD1QueueSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                            ||
                            (HD1ProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId)) && !HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(c.OwnerId)) && !HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(c.OwnerId)) )) //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991
                        && 
                            (HD1BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                            ||
                            HD1ContabilitaProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1ContabilitaQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1ContenziosoProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1ContenziosoQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(c.id).OwnerId))
                            //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
                            )
                        && RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                       && !recordTypeDAC.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                       
                      )
                    {
                        c.status = AP_Constants.caseStatusInoltratoIT;
                    }
                    if(     (HD1BIZQueueSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                             ||
                             HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                             )
                        && 
                            (HD1QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            ( HD1ProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId)) && !HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(c.id).OwnerId)) && !HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(c.id).OwnerId)) )
                            //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                            ||
                            HD1ContabilitaProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1ContabilitaQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1ContenziosoProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1ContenziosoQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(c.id).OwnerId))
                            //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
                            )
                        && RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                       && !recordTypeDAC.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                      )
                    {
                        c.status = AP_Constants.caseStatusInoltratoBusiness;
                    }
                    //OAVERSANO 25/10/2018 : Nuovo Modello di Assistenza AXA MPS - Sprint 84 -- END
                    //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                    if(     (HD1ContabilitaProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                             ||
                             HD1ContabilitaQueueSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                             ||
                             HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(c.OwnerId))
                             )
                        && 
                            (HD1QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            ( HD1ProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId)) && !HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(c.id).OwnerId)) && !HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(c.id).OwnerId)) )
                            //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                            ||
                            HD1BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1ContenziosoProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1ContenziosoQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(c.id).OwnerId))
                            //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
                            )
                        && RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                        && !ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId).contains('HD1 Biz Vita') // OAVERSANO 09/05/2019 : NMA LOB Vita
                      )
                    {
                        c.status = AP_Constants.caseStatusInoltratoContabilita;
                    }
                    if(     (HD1ContenziosoProfileSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                             ||
                             HD1ContenziosoQueueSet.contains(ownerIdProfileNameMap.get(c.OwnerId))
                             ||
                             HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(c.OwnerId))
                             )
                        && 
                            (HD1QueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            ( HD1ProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId)) && !HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(c.id).OwnerId)) && !HD1ContenziosoRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(c.id).OwnerId)) )
                            //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- START
                            ||
                            HD1BIZQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1BIZProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1ContabilitaProfileSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1ContabilitaQueueSet.contains(ownerIdProfileNameMap.get(OldValues.get(c.id).OwnerId))
                            ||
                            HD1ContabilitaRoleSet.contains(ownerIdRoleNameMap.get(OldValues.get(c.id).OwnerId))
                            //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END
                            )
                        && RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))
                      )
                    {
                        c.status = AP_Constants.caseStatusInoltratoContenzioso;
                    }
                    //OAVERSANO 12/02/2019 : Nuovo Modello di Assistenza AXA MPS - Sprint 92 | US-0991 -- END 
                }
                //OAVERSANO 23/07/2018: Nuovo Modello di Assistenza -- END  US-0764
                
                if (c.AccountId <> OldValues.get(c.id).AccountId
                    || c.AgentName__c <> OldValues.get(c.id).AgentName__c)
                {
                    caselistAP06.add(c);
                }
                
                if(c.Phone_Call_Ids__c <> OldValues.get(c.id).Phone_Call_Ids__c)
                {
                    if(c.SLAHours__c==0 || OldValues.get(c.id).SLAHours__c==null)               
                        c.EntitlementId = null;

                    //MOSCATELLI_M 23/01/2019: NMA Enhancement V— start
                    if(!c.Case_sollecitato__c)
                    {
                        //MMOSCATELLI 12/02/2019: Workaround per phonecallid vuoto --START
                        /*
                        if((String.isnotblank(OldValues.get(c.id).Phone_Call_Ids__c) && (c.Origin == 'Phone' && (c.Phone_Call_Ids__c.indexOf('|')>-1))) ||
                            (String.isblank(OldValues.get(c.id).Phone_Call_Ids__c) && (c.Origin == 'Chat' || c.Origin == 'Portale Assistenza')))
                        {
                            c.OCR__c = false;
                            c.Case_sollecitato__c = true;
                        }*/
                        if(String.isblank(OldValues.get(c.id).Phone_Call_Ids__c) && (c.Origin == 'Chat' || c.Origin == 'Portale Assistenza'))
                        {
                            c.OCR__c = false;
                            c.Case_sollecitato__c = true;
                        }
                        else if (String.isnotBlank(c.Phone_Call_Ids__c) && c.Origin == 'Phone')
                        {
                            if(String.isnotblank(OldValues.get(c.id).Phone_Call_Ids__c) && (c.Phone_Call_Ids__c.indexOf('|')>-1)) 
                            {
                                c.OCR__c = false;
                                c.Case_sollecitato__c = true;                                
                            }
                        }                       
                        //MMOSCATELLI 12/02/2019: Workaround per phonecallid vuoto --END
                    }
                    //MOSCATELLI_M 23/01/2019: NMA Enhancement V— end
                }

                //MOSCATELLI_M 23/01/2019: NMA Enhancement V— start
                if(c.Case_sollecitato__c <> OldValues.get(c.id).Case_sollecitato__c)
                {
                    if(c.Case_sollecitato__c)
                        c.OCR__c = false;
                }
                //MOSCATELLI_M 23/01/2019: NMA Enhancement V— end
                
                if(String.isNotBlank(c.Accountid))
                    c.Other_Email__c = c.Additional_Email__c;   
                
                if(c.All_Tasks_Close_Date__c!=null && (OldValues.get(c.Id).All_Tasks_Close_Date__c <> c.All_Tasks_Close_Date__c) && (c.Oldest_Task_Creat_Date__c <> null || c.statusreopened_date__c <> null))
                {
                    if(c.First_Long_Term_Management_Alert_DT__c!=null || c.Second_Long_Term_Management_Alert_DT__c!=null || c.Third_Long_Term_Management_Alert_DT__c!=null)
                    {
                        c.First_Long_Term_Management_Alert_DT__c = null;
                        c.Second_Long_Term_Management_Alert_DT__c = null;
                        c.Third_Long_Term_Management_Alert_DT__c = null;
                        c.Inform_Customers_with_Alerts__c = false;
                    }
                    system.debug('@@old:'+c.Oldest_Task_Creat_Date__c+' new:'+System.now());
                    
                    Double TaskAges = BusinessHours.diff(defaultHoursId, (c.Oldest_Task_Creat_Date__c <> null)?c.Oldest_Task_Creat_Date__c:c.statusreopened_date__c, System.now())/3600000.0;
                    Double TaskAgesnoPending = 0;
                    
                    TaskAgesnoPending = TaskAges - (c.Pending_due_to_Task_Start_Duration__c==null?0:c.Pending_due_to_Task_Start_Duration__c);
                    
                    system.debug('Tempi: '+TaskAges+', Pending: '+c.Pending_due_to_Task_Start_Duration__c);
                    
                    if(c.Durata_lavorazione_uffici_tecnici__c <> null)
                        c.Durata_lavorazione_uffici_tecnici__c= c.Durata_lavorazione_uffici_tecnici__c + TaskAgesnoPending;
                    else
                        c.Durata_lavorazione_uffici_tecnici__c =TaskAgesnoPending;
                    
                    c.Oldest_Task_Creat_Date__c = null;
                    c.Pending_due_to_Task_Start_Duration__c = null;
                }
                
                if(c.Data_completamento_Task_DPO__c!=null && (OldValues.get(c.Id).Data_completamento_Task_DPO__c <> c.Data_completamento_Task_DPO__c) && (c.Data_primo_Task_DPO__c <> null || c.statusreopened_date__c <> null))
                {
                    system.debug('@@old:'+c.Data_primo_Task_DPO__c+' new:'+System.now());
                    
                    Double TaskDPOAges = BusinessHours.diff(defaultHoursId, (c.Data_primo_Task_DPO__c <> null)?c.Data_primo_Task_DPO__c:c.statusreopened_date__c, System.now())/3600000.0;
                    Double TaskDPOAgesnoPending = 0;
                    
                    TaskDPOAgesnoPending = TaskDPOAges - (c.Durata_Pending_DPO__c==null?0:c.Durata_Pending_DPO__c);
                    
                    system.debug('Tempi: '+TaskDPOAges+', Pending: '+c.Durata_Pending_DPO__c);
                    
                    if(c.Durata_lavorazione_DPO_in_business_hours__c <> null)
                        c.Durata_lavorazione_DPO_in_business_hours__c= c.Durata_lavorazione_DPO_in_business_hours__c + TaskDPOAgesnoPending;
                    else
                        c.Durata_lavorazione_DPO_in_business_hours__c =TaskDPOAgesnoPending;
                    
                    c.Data_primo_Task_DPO__c = null;
                    c.Durata_Pending_DPO__c = null;
                }
                
                //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- START
                if(c.Data_completamento_Task_interni__c!=null && (OldValues.get(c.Id).Data_completamento_Task_interni__c <> c.Data_completamento_Task_interni__c) && (c.Data_primo_task_interno__c <> null || c.statusreopened_date__c <> null))
                {
                    system.debug('@@old:'+c.Data_primo_task_interno__c+' new:'+System.now());
                    
                    Double TaskInternoAges = BusinessHours.diff(defaultHoursId, (c.Data_primo_task_interno__c <> null)?c.Data_primo_task_interno__c:c.statusreopened_date__c, System.now())/3600000.0;
                    Double TaskInternogesnoPending = 0;
                    
                    TaskInternogesnoPending = TaskInternoAges - (c.Durata_Pending_per_Task_interno__c==null?0:c.Durata_Pending_per_Task_interno__c);
                    
                    system.debug('Tempi: '+TaskInternoAges+', Pending: '+c.Durata_Pending_per_Task_interno__c);
                    
                    if(c.Durata_lavorazione_task_interni__c <> null)
                        c.Durata_lavorazione_task_interni__c= c.Durata_lavorazione_task_interni__c + TaskInternogesnoPending;
                    else
                        c.Durata_lavorazione_task_interni__c =TaskInternogesnoPending;
                    
                    c.Data_primo_task_interno__c = null;
                    c.Durata_Pending_per_Task_interno__c = null;
                }
                //MOSCATELLI_M 07/06/2018: Inoltro Task Interni -- END
                
                outc.CasList.put(c.id,c);
            }
            
            //OAVERSANO 23/10/2018 : ICF Close The Loop -- START
            if(!caseToProcessCTM.isEmpty())
            {
                caseTeamManagement processCaseTeam = new caseTeamManagement();
                processCaseTeam.createCaseTeamMembers(caseToProcessCTM, caseIdOwnerIdMap);
            }
            //OAVERSANO 23/10/2018 : ICF Close The Loop -- END
            if(CalculateSLAList.size()>0)
            //OAVERSANO 18/01/2019 : Gestione Reclami -- START
            {
                //AP01CaseCalculateDueDate.calculateDueDate(CalculateSLAList,defaultHoursId,GDPRHoursId,EntGDPRId,Entid,EntGDPRId2,EntGDPRId3, EntAssAgenti, EntCaringAngel, MapCaseRecordType,MapRecNameToDevelopername);
                AP01CaseCalculateDueDate.calculateDueDate(CalculateSLAList,defaultHoursId,GDPRHoursId,EntGDPRId,Entid,EntGDPRId2,EntGDPRId3, EntAssAgenti, EntCaringAngel, EntReclamo, MapCaseRecordType,MapRecNameToDevelopername);
            }
            //OAVERSANO 18/01/2019 : Gestione Reclami -- END
            
            if (caselistAP06.size() > 0 )
            {
                AP06CaseUpdate.updateContact(caselistAP06, AP06CaseUpdate.CONST_ISUPDATE);
            }
            
            if(SMSInputsList.size()>0)        
                VFC17_SendSMS.AutomaticSMS(SMSInputsList);  
            
        }
        system.debug('end ## ');
        return outc;
    }
    private static void populateMapCodaAgencyName(){
        MapCodaAgencyName = new Map<String, ID>();
        for(Group temp:[SELECT ID, DEVELOPERNAME FROM GROUP WHERE TYPE = 'QUEUE' AND DEVELOPERNAME LIKE 'Coda_Agenzia_Case%' ]){ // NOPMD  Fix CRUD violation
            MapCodaAgencyName.put(temp.DeveloperName,temp.Id);
        } 
    }    
    //public static void SetInitialValues(List<Case> Cases, Id defaultHoursId, String GDPRHoursId, String EntId, String EntGDPRId, String EntGDPRId2, String EntGDPRId3, String EntAssAgenti, String EntCaringAngel, Map<String,User> MapAAIAgent,Map<String, Schema.RecordTypeInfo> MapCaseRecordType, Map<String,String> MapRecNameToDevelopername, Map<String,String> ownerIdNameMap, Map<String,String> ownerIdProfileNameMap,Map<String,String> MapAgencies)
    public static void SetInitialValues(List<Case> Cases, Id defaultHoursId, String GDPRHoursId, String EntId, String EntGDPRId, String EntGDPRId2, String EntGDPRId3, String EntAssAgenti, String EntCaringAngel, String EntReclamo, Map<String,User> MapAAIAgent,Map<String, Schema.RecordTypeInfo> MapCaseRecordType, Map<String,String> MapRecNameToDevelopername, Map<String,String> ownerIdNameMap, Map<String,String> ownerIdProfileNameMap,Map<String,Account> MapAgencies,Map<String,Account> MapCaseAccount) //OAVERSANO 28/01/2019 : Gestione Reclami 
    {
        
        String sollecitiIvas41 = MPS_Code_Variables__c.getValues('Ivass41Solleciti') != null ? MPS_Code_Variables__c.getValues('Ivass41Solleciti').value__c: null;
        Map<String, String> Junctions = new Map<String,String>();
        System.Debug('#### >>> Start of CaseBeforeInsert <<< run by ' + UserInfo.getName());
        Set<String> AgencySet = new Set<String>();
        Map<String,Categorizzazione_Email__c> MapConfigEmail = new map<String,Categorizzazione_Email__c>();
        List<Id> UpdatedCaseIdList = new list<Id>(); 
        Map<Id, String> recordTypeMap = RecordTypeUtility.getRecordTypeMap('Case');
        for(Categorizzazione_Email__c EmailConf:[Select Id,Email_Subject__c,Category__c, Sub_Category__c from Categorizzazione_Email__c ]) // NOPMD  Fix CRUD violation
        {
            MapConfigEmail.put((EmailConf.Email_Subject__c).toUpperCase(), EmailConf);
        }
        Map<String,String> lob_Queue_Map = new Map<String,String>();
            for(LobQueueCM__mdt temp: [select lob__c, Queue__c from LobQueueCM__mdt ]){ // NOPMD  Fix CRUD violation
                lob_Queue_Map.put(temp.Lob__c, temp.Queue__c);
           }
        for(Case c : Cases)
        {
            system.debug(c.origin);
            system.debug(c.SuppliedEmail);
            system.debug(c.AccountId);  
            
            //OAVERSANO 18/01/2019 : Gestione Reclami -- START
            Set<String> DoNotCopyEmail = new Set<String>(); 
            if(MPS_Code_Variables__c.getValues('DoNotCopyEmail')!=null)
            {
                if(String.isNotBlank(MPS_Code_Variables__c.getValues('DoNotCopyEmail').value__c))
                {
                    for(String s:(MPS_Code_Variables__c.getValues('DoNotCopyEmail').value__c).split(';'))
                    {
                        DoNotCopyEmail.add(s);                
                    }
                }
            }           
            //OAVERSANO 18/01/2019 : Gestione Reclami -- END
            
            c.Last_Status_Change__c = System.now();
            c.Time_With_Customer__c = 0;
            c.Time_With_Agent__c = 0; //OAVERSANO 23/10/2018 : ICF Close The Loop
            c.Time_With_Support__c = 0;
            c.Time_With_Technicians__c = 0;
            c.Time_for_Applicative_activities__c = 0;
            
            //OAVERSANO 03/08/2018: Nuovo Modello di Assistenza -- START
            c.Internal_Category__c = (String.isNotBlank(c.Category__c))?c.Category__c:'';
            c.Internal_SubCategory__c = (String.isNotBlank(c.SubCategory__c))?c.SubCategory__c:'';
            c.Internal_LOB__c = (String.isNotBlank(c.LOB__c))?c.LOB__c:'';
            if(String.isNotBlank(c.RecordTypeId) && MapCaseRecordType.get(c.RecordTypeId).getDeveloperName().equals(AP_Constants.rtCaseAAI)){
                c.Current_Owner_Queue__c = 'Axa_Assicurazioni';
            }
            if(String.isnotBlank(c.OwnerId) && ownerIdNameMap.containsKey(c.OwnerId) && String.isNotBlank(c.RecordTypeId) && MapCaseRecordType.get(c.RecordTypeId).getDeveloperName()==AP_Constants.rtCaseAssistenzaAgenti)
            {
                /*
                if(ownerIdProfileNameMap.get(c.OwnerId).contains('HD1'))
                    c.Owner_HD1__c = ownerIdNameMap.get(c.OwnerId);*/
                if(c.Lob__c == 'IT' && String.isNotBlank(c.Lob__c))
                {
                    if(ownerIdProfileNameMap.get(c.OwnerId).contains('HD1'))
                        c.Owner_HD1__c = ownerIdNameMap.get(c.OwnerId);
                }
                else if(c.Lob__c != 'IT' && String.isNotBlank(c.Lob__c))
                {
                    //if(String.valueOf(c.OwnerId).startswith('005'))
                    if((ownerIdProfileNameMap.get(c.OwnerId)).indexOf('AAI - Vendite')==-1)
                        c.Owner_HD1__c = ownerIdNameMap.get(c.OwnerId);
                }

                //VIZZINI_D 03/07/2019: NMA - Lob Modulo di Calcolo - START
                if(ownerIdProfileNameMap.get(c.OwnerId).contains('HD1') && String.valueOf(c.OwnerId).startsWith('005')){
                    
                    c.Last_Advisor__c = c.OwnerId;
                }
                //VIZZINI_D 03/07/2019: NMA - Lob Modulo di Calcolo - END

            }       
            //OAVERSANO 03/08/2018: Nuovo Modello di Assistenza -- END

          
          
          
            //18/12/2019 start
		
            for(LobQueueCM__mdt temp: [select lob__c, Queue__c from LobQueueCM__mdt ]){ // NOPMD  Fix CRUD violation
                lob_Queue_Map.put(temp.Lob__c, temp.Queue__c);
            }
			if (String.isNotBlank(c.RecordTypeId) && MapCaseRecordType.get(c.RecordTypeId).getDeveloperName()==AP_Constants.rtCaseCaringAngel){
                c.Current_Owner_Queue__c = c.TECH_LastHD1Queue__c = 'Caring_Angel_Motor'; 
            }
            if (String.isNotBlank(c.RecordTypeId) && MapCaseRecordType.get(c.RecordTypeId).getDeveloperName()==AP_Constants.rtCaseAAI){
                c.Current_Owner_Queue__c = c.TECH_LastHD1Queue__c = 'Axa_Assicurazioni';
            }
            else if (String.isNotBlank(c.RecordTypeId) && MapCaseRecordType.get(c.RecordTypeId).getDeveloperName()==AP_Constants.rtCaseCaringSalute){
                if(String.isNotBlank(c.SubCategory__c) && (c.SubCategory__c.equals('Cliente Corporate') || c.SubCategory__c.equals('Cliente Retail') || c.SubCategory__c.equals('Dipendente')) ){
                    c.Current_Owner_Queue__c = c.TECH_LastHD1Queue__c = lob_Queue_Map.get(c.SubCategory__c);
                    
                }else{
                    if(String.isNotBlank(c.Category__c) && (c.Category__c.equals('Strutture sanitarie'))){
                        c.Current_Owner_Queue__c =  c.TECH_LastHD1Queue__c = lob_Queue_Map.get(c.Category__c);                  
                    } 
                    else if (String.isNotBlank(c.OwnerId) ){
                        c.Current_Owner_Queue__c = c.TECH_LastHD1Queue__c = 'Caring_Salute_HD1';
                    }
                }
                if(String.isNotBlank(c.OwnerId) && String.ValueOf(c.OwnerId).startsWith('005'))
                    c.TECH_FirstHD1Agent__c = c.OwnerId;
                
            }
            else if (String.isNotBlank(c.RecordTypeId) && MapCaseRecordType.get(c.RecordTypeId).getDeveloperName()==AP_Constants.rtCaseCaringProperty){
                c.Current_Owner_Queue__c = c.TECH_LastHD1Queue__c = AP_Constants.rtCaseCaringProperty;
                if(String.isNotBlank(c.OwnerId) && String.ValueOf(c.OwnerId).startsWith('005'))
                    c.TECH_FirstHD1Agent__c = c.OwnerId;
            }
            else
            {
            if(String.isNotBlank(c.Lob__c) && MapCaseRecordType.get(c.RecordTypeId).getDeveloperName()==AP_Constants.rtCaseAssistenzaAgenti){
                if(lob_Queue_Map.containsKey(c.Lob__c)){
                    c.Current_Owner_Queue__c = lob_Queue_Map.get(c.Lob__c);
                    c.TECH_LastHD1Queue__c = lob_Queue_Map.get(c.Lob__c);
                }
                if(String.isNotBlank(c.OwnerId) && String.ValueOf(c.OwnerId).startsWith('005')){
                    c.TECH_FirstHD1Agent__c = c.OwnerId;
                }
            }
            }
            
            if(c.Current_Owner_Queue__c == null || String.isBlank(c.Current_Owner_Queue__c)){
                if(c.RecordTypeId != null && MapCaseRecordType.containsKey(c.RecordTypeId)){
                    c.Current_Owner_Queue__c = c.TECH_LastHD1Queue__c = MapCaseRecordType.get(c.RecordTypeId).getDeveloperName();
                }
            }
            //18/12/2019 end
            //OAVERSANO 18/01/2019 : Gestione Reclami -- START
            if(String.isBlank(c.AccountId) && String.isNotBlank(c.SuppliedEmail) && !DoNotCopyEmail.contains(c.SuppliedEmail))
            {
                c.Account_email__c = c.SuppliedEmail;
            }
            else if(String.isNotBlank(c.AccountId) && MapCaseAccount.containsKey(c.AccountId))
            {
                if((String.IsBlank(c.AgentName__c) && String.IsBlank(c.User__c)) || String.IsBlank(c.Account_email__c))
                {
                    c.Account_email__c='';

                    if(String.isblank(c.SuppliedEmail) || DoNotCopyEmail.contains(c.SuppliedEmail))
                    {
                        if(!(string.isBlank(MapCaseAccount.get(c.AccountId).Additional_Email__c)))
                            c.Account_email__c = MapCaseAccount.get(c.AccountId).Additional_Email__c;                   
                        
                        else if(MapCaseAccount.get(c.AccountId).RecordType.developername == AP_Constants.rtAccIndividualClient || MapCaseAccount.get(c.AccountId).RecordType.developername == AP_Constants.rtAccB2C || MapCaseAccount.get(c.AccountId).RecordType.developername == AP_Constants.rtAccIntermediary)
                        { 
                            if(String.isNotBlank(MapCaseAccount.get(c.AccountId).CIF_PersonEmail__c))
                                c.Account_email__c = MapCaseAccount.get(c.AccountId).CIF_PersonEmail__c;
                            else if(String.isNotBlank(MapCaseAccount.get(c.AccountId).CIF_Work_email__c))
                                c.Account_email__c = MapCaseAccount.get(c.AccountId).CIF_Work_email__c;                  
                            else if(!string.isBlank(MapCaseAccount.get(c.AccountId).PersonEmail))
                                c.Account_email__c = MapCaseAccount.get(c.AccountId).PersonEmail;
                            else if(String.isNotBlank(MapCaseAccount.get(c.AccountId).Claim_PersonalEmail__c))
                                c.Account_email__c = MapCaseAccount.get(c.AccountId).Claim_PersonalEmail__c;
                        }    
                        else if(MapCaseAccount.get(c.AccountId).RecordType.developername == AP_Constants.rtAccCorporateClient)
                        {
                            if(!(string.isBlank(MapCaseAccount.get(c.AccountId).Account_email__c)))
                                c.Account_email__c = MapCaseAccount.get(c.AccountId).Account_email__c;
                            else if(String.isNotBlank(MapCaseAccount.get(c.AccountId).Claim_PersonalEmail__c))
                                c.Account_email__c = MapCaseAccount.get(c.AccountId).Claim_PersonalEmail__c;
                        }      
                        else if(MapCaseAccount.get(c.AccountId).RecordType.developername == AP_Constants.rtAccB2B)
                        {
                            if(String.isNotBlank(MapCaseAccount.get(c.AccountId).CIF_PersonalEmail__c))
                                c.Account_email__c = MapCaseAccount.get(c.AccountId).CIF_PersonalEmail__c;
                            else if(String.isNotBlank(MapCaseAccount.get(c.AccountId).CIF_Work_email__c))
                                c.Account_email__c = MapCaseAccount.get(c.AccountId).CIF_Work_email__c;                         
                            else if(string.isNotBlank(MapCaseAccount.get(c.AccountId).Subject_email__c))
                                c.Account_email__c = MapCaseAccount.get(c.AccountId).Subject_email__c; 
                            else if(String.isNotBlank(MapCaseAccount.get(c.AccountId).Claim_PersonalEmail__c))
                                c.Account_email__c = MapCaseAccount.get(c.AccountId).Claim_PersonalEmail__c;
                        }                   
                    }
                    else
                    {
                        if(!DoNotCopyEmail.contains(c.SuppliedEmail))
                            c.Account_email__c = c.SuppliedEmail;
                    }
                }                                   
            }
            
            if(String.isNotBlank(c.AgentName__c) && MapCaseAccount.containsKey(c.AgentName__c))
            {
                c.Account_email__c='';
                
                if(String.isblank(c.SuppliedEmail) || DoNotCopyEmail.contains(c.SuppliedEmail))
                {
                    if(!(string.isBlank(MapCaseAccount.get(c.AgentName__c).Additional_Email__c)))
                        c.Account_email__c = MapCaseAccount.get(c.AgentName__c).Additional_Email__c;                    
                    
                    else if(MapCaseAccount.get(c.AgentName__c).RecordType.developername == AP_Constants.rtAccIntermediary)
                    { 
                        c.Account_email__c = MapCaseAccount.get(c.AgentName__c).PersonEmail;
                    }                       
                }
                else
                {
                    if(!DoNotCopyEmail.contains(c.SuppliedEmail))
                        c.Account_email__c = c.SuppliedEmail;
                }
            } 
            
            if(String.isNotBlank(c.User__c) && MapAAIAgent.containsKey(c.User__c))
            {
                c.Agency_Code__c = MapAAIAgent.get(c.User__c).Agency_Code__c;
                c.Account_email__c='';
				/*
				 * A.Massarotti start
				 */
                AgencySet.add(c.Agency_Code__c);
                /*
                 * A.Massarotti end
                 */
                if(String.isblank(c.SuppliedEmail) || DoNotCopyEmail.contains(c.SuppliedEmail))
                {
                    c.Account_email__c = MapAAIAgent.get(c.User__c).Email;                                               
                }
                else
                {
                    if(!DoNotCopyEmail.contains(c.SuppliedEmail))
                        c.Account_email__c = c.SuppliedEmail;
                }
            }
            //OAVERSANO 18/01/2019 : Gestione Reclami -- END              






/*            
            //MOSCATELLI_M 02/07/2018: Easy Azienda --START
            if(String.isNotBlank(c.User__c))
            {
                c.Account_email__c ='';
                //OAVERSANO 03/08/2018: Nuovo Modello di Assistenza -- START
                if(MapAAIAgent.containsKey(c.User__c))
                {
                    c.Account_email__c = MapAAIAgent.get(c.User__c).Email;
                    c.Agency_Code__c = MapAAIAgent.get(c.User__c).Agency_Code__c;
                   // c.Agenzia__c=MapAAIAgent.get(c.User__c).Contact.AccountId;//MOSCATELLI_M 02/07/2018: Easy Azienda -- START 
                }
                //OAVERSANO 03/08/2018: Nuovo Modello di Assistenza -- END
            }
            //MOSCATELLI_M 02/07/2018: Easy Azienda --END 
*/
            if(c.Agency_Code__c != null && String.isnotblank(c.Agency_Code__c))
            {	
                
                if(MapAgencies.containskey(c.Agency_Code__c) && MapAgencies.get(c.Agency_Code__c) != null){
                    c.Agenzia__c = MapAgencies.get(c.Agency_Code__c).Id;
                    c.Agency_Email__c = MapAgencies.get(c.Agency_Code__c).Agency_Email__c != null ? MapAgencies.get(c.Agency_Code__c).Agency_Email__c : null;
                }
            }
            
            if((c.Origin == AP_Constants.caseOriginEmail || c.Origin == AP_Constants.caseOriginEmail2Case) && String.isNotBlank(c.Subject) && MapConfigEmail.containsKey((c.Subject).toUpperCase()))
            {
                if(String.isBlank(c.Category__c) && String.isBlank(c.SubCategory__c))
                {
                    c.Category__c = MapConfigEmail.get((c.Subject).toUpperCase()).Category__c;
                    c.SubCategory__c = MapConfigEmail.get((c.Subject).toUpperCase()).Sub_Category__c;
                }
            }
            
            else if(c.Origin == AP_Constants.caseOrigineFB || c.Origin == AP_Constants.caseOrigineTW)
            {
                c.Complainant__c = AP_Constants.rtCaseCustComp;
                c.Distribution_Network__c = 'Axa Assicurazioni';
                c.Status = AP_Constants.caseStatusOpen;
            }
            
            if(PAD.canTrigger('AP02'))
            {
                if(c.Account.Name <> '')
                {
                    c.Other_Email__c = c.Additional_Email__c;
                }      
            }
            
            if(c.Data_ricezione_richiesta_DPO__c <> null){
                
                
                c.SlaStartDate = c.Data_ricezione_richiesta_DPO__c;
                c.StartDate_MilestoneTimer__c = c.SlaStartDate;
                
                system.debug('*****dentro if '+c.StartDate_MilestoneTimer__c);
                
            }else{
                
                c.SlaStartDate = c.CreatedDate;
                c.StartDate_MilestoneTimer__c = c.SlaStartDate;
            }  
        }
        if(PAD.canTrigger('AP01'))
        {
            //OAVERSANO 18/01/2019 : Gestione Reclami -- START
            //AP01CaseCalculateDueDate.calculateDueDate(Cases,defaultHoursId,GDPRHoursId,EntGDPRId,Entid,EntGDPRId2,EntGDPRId3,EntAssAgenti,EntCaringAngel,MapCaseRecordType,MapRecNameToDevelopername);
            AP01CaseCalculateDueDate.calculateDueDate(Cases,defaultHoursId,GDPRHoursId,EntGDPRId,Entid,EntGDPRId2,EntGDPRId3,EntAssAgenti,EntCaringAngel,EntReclamo,MapCaseRecordType,MapRecNameToDevelopername);
            //OAVERSANO 18/01/2019 : Gestione Reclami -- END
            AP01CaseCalculateDueDate.calculateCaseStatusTotalTime(Cases,new map<Id,String>(),defaultHoursId);
        }
        
        if(PAD.canTrigger('AP06'))
        {
            AP06CaseUpdate.updateContact(Cases, AP06CaseUpdate.CONST_ISNEW);
        }
        
        //A.Massarotti Start
        List<AnagraficaAssuntoreAgenzia__c> ListaAssuntoreAgenzia = [Select Agency_Code__c, Nome_Assuntore__r.Name, RecordType.DeveloperName from AnagraficaAssuntoreAgenzia__c where Agency_Code__c in :AgencySet ]; // NOPMD  Fix CRUD violation
        system.debug('AgencySet: ' + AgencySet);
        system.debug('QueryResult : ' + ListaAssuntoreAgenzia);
			if(AgencySet.size()>0)
        	{
            
                for(AnagraficaAssuntoreAgenzia__c a: ListaAssuntoreAgenzia){
                	Junctions.put(a.Agency_Code__c+(a.RecordType.DeveloperName.contains('Auto')?'A':'S'),a.Nome_Assuntore__r.Name );
                    system.debug('AnagraficaAssuntoreAgenzia: '+a.Agency_Code__c+' '+a.Nome_Assuntore__r.Name);
           		}
         		System.debug('Junction Map: '+Junctions);
        	}
            for(Case c : Cases){
               
                if(String.isNotBlank(c.RecordTypeId) && AP_Constants.rtCaseAAI.equalsIgnoreCase(MapCaseRecordType.get(c.RecordTypeId).getDeveloperName()) && 
                   (c.Flag_IVASS41__c || (c.Category__c!=null && 'Richiesta codice sconto'.equalsIgnoreCase(c.Category__c)) || 
                   c.Origin == 'PCC Area Preventivi' || c.Origin == 'My AXA Area Preventivi' )||
                   c.SubCategory__c != null && 'Problemi di pagamento per Mensilizzazione'.equalsIgnoreCase(c.SubCategory__c)){
                	if(MapCodaAgencyName==null){
                    	populateMapCodaAgencyName();
                	}
                        String[] solleciti 		= sollecitiIvas41.split(';');
                        Double primoSollecito 	= 0;
                        Double secondoSollecito = 0;
                        Double terzoSollecito = 0;
                        if(solleciti != null){
                            primoSollecito 		= Double.valueOf(solleciti[0]);
                            secondoSollecito 	= Double.valueOf(solleciti[1]);
                            terzoSollecito 		= Double.valueOf(solleciti[2]);
                        }
                        
                        c.TECH_Primo_Sollecito_Agenti__c = BusinessHours.addGMT(defaultHoursId,System.now(),((primoSollecito)*60 * 60 * 1000L).longValue());
                        c.TECH_Secondo_Sollecito_Agenti__c = BusinessHours.addGMT(defaultHoursId,System.now(),((secondoSollecito)*60 * 60 * 1000L).longValue());
                    	String temp = 'Coda_Agenzia_Case_'+c.Agency_Code__c;
                    	if(MapCodaAgencyName.get(temp) != null && String.isNotBlank(MapCodaAgencyName.get(temp))){
                        	c.OwnerId = MapCodaAgencyName.get(temp);
                    	}
                    
                }
                if(recordTypeMap.containsKey(c.RecordTypeId) && recordTypeMap.get(c.RecordTypeId) == 'Assistenza_Agenti'){
                    if(c.Agency_Code__c != null && String.IsNotBlank(c.Agency_Code__c)){
                        if(Junctions.containsKey(c.Agency_Code__c + 'A')){
                            c.Assuntore_Auto__c = Junctions.get(c.Agency_Code__c + 'A');
                        }
                        if(Junctions.containsKey(c.Agency_Code__c+'S')){
                         c.Assuntore_Salute__c = Junctions.get(c.Agency_Code__c + 'S');
                      }
                    }
                    system.debug('Agency: ' + c.Agency_Code__c);
                 }
        }
        system.debug(Junctions);
			//A.Massarotti End
        
        System.Debug('#### >>> End of CaseBeforeInsert <<<');       
    }
    
    public static void AfterInsertProcess(List<Case> Cases, Set<String> AccountIds,Map<String, Schema.RecordTypeInfo> MapCaseRecordType, Map<String,String> MapRecNameToDevelopername)
    {
        if(CaseHandler.AfterInsertNotDone)
        {
            System.Debug('## >>> Start of CaseAfterInsert <<< run by ' + UserInfo.getName());
            
            list<Case> listCase = new list<Case>(); 
            Set<String> setEmail = new set<String>(); 
            Set<String> setAccID = new set<String>(); 
            list<Case> listCaseToUpdate = new list<Case>();     
            Set<Id> AP13Cases = new Set<Id>();
            List<Storico_Chiamate__c> StoricocallList = new list <Storico_Chiamate__c>();
            Map<String, Apertura_automatica_Task__c> ConfigTaskApMap= new Map<String, Apertura_automatica_Task__c>();
            //List<Account_Case__c> AccountCaseList = new List<Account_Case__c>();//FM_ 9/05/2018 : GDPR
            Map<String,String> MapCaseAccount = new Map<String,String>();
            
            
            
            for(Account a: [Select Id,RecordType.Developername from Account where id in:AccountIds])
            {
                MapCaseAccount.put(a.id,a.RecordType.Developername);
            }
            
            List<String> GDPRCategories = new List<String>();
            
            for(MPS_Code_Variables__c MPSCv: MPS_Code_Variables__c.getAll().values())
            {
                if((MPSCv.Name).contains('GDPR_Category'))
                    GDPRCategories.add(MPSCv.Value__c);
            }       
            
            for(Apertura_automatica_Task__c AutoTask: [Select Id,Case_Origin__c,Case_Record_Type__c,Category__c,Sub_Category__c,Distribution_Network__c,Hierarchy_Level_1__c,Hierarchy_Level_2__c,Hierarchy_Level_3__c,Task_Subject__c,Technical_Office_Users_Ids__c from Apertura_automatica_Task__c where Rule_Active__c=:true ]) // NOPMD  Fix CRUD violation
            {
                ConfigTaskApMap.put(AutoTask.Case_Origin__c+'_'+AutoTask.Case_Record_Type__c+'_'+AutoTask.Category__c+'_'+AutoTask.Sub_Category__c, AutoTask);
            }
            system.debug('##ConfigTaskApMap: '+ConfigTaskApMap);
            
            //OAVERSANO 16/10/2018 : Caring Angel -- START 
            Set<String> RecordTypeSet = new Set<String>();
            //BOVOLENTA_D 04042019 query reduction START
            List<String> filters = new list<String>{'ProfileManagement'};
            List<Caring_Angel__mdt> caringAngelList =CaseManagement.retrieveCustomMetadataRecords('Caring_Angel__mdt',filters);
            Caring_Angel__mdt caringAngel;
            if(caringAngelList.size()>0)
                caringAngel=caringAngelList[0];
            /*Caring_Angel__mdt caringAngel = [SELECT Id, DeveloperName, CaseTriggerRecordType__c,
                                                HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c 
                                                FROM Caring_Angel__mdt 
                                                WHERE DeveloperName  = 'ProfileManagement'
                                                LIMIT 1];
            //BOVOLENTA_D 04042019 query reduction END */
            if(caringAngel!=null)
            {
                
                if(String.isNotBlank(caringAngel.CaseTriggerRecordType__c))
                {
                    for(String s:caringAngel.CaseTriggerRecordType__c.split(';'))
                    {
                        RecordTypeSet.add(s);  
                    }
                }   
            } 
            //OAVERSANO 16/10/2018 : Caring Angel -- END 
            
            for (Case c : Cases)
            {   
                //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- START
                Case ToBeUpdated = new Case(id=c.Id);
                Boolean isUpdated = false;
                //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- END

                if(c.Origin == 'Webform pubblico' || c.Origin == 'Webform privato')
                {
                    if(String.isNotBlank(c.Category__c))
                    {
                        if(GDPRCategories.contains(c.Category__c))
                        {
                            //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- START
                            //listCaseToUpdate.add(new Case(id=c.Id,Data_ricezione_richiesta_DPO__c = c.Createddate.date()));
                            ToBeUpdated.Data_ricezione_richiesta_DPO__c = c.Createddate.date();
                            isUpdated = true;
                            //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- END
                        }
                    }
                }
                
                if(PAD.canTrigger('AP04'))
                {
                    if((c.origin == AP_Constants.caseOriginEmail || c.origin == AP_Constants.caseOriginEmail2Case)
                       && c.SuppliedEmail != null)
                    {
                        listCase.add(c);
                        setEmail.add(c.SuppliedEmail);
                        
                        if(c.AccountId  <> null)
                        {
                            setAccID.add(c.AccountId);
                        }
                    } 
                }
                
                if(String.isNotBlank(c.Phone_Call_Ids__c))
                {
                    //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- START
                    ToBeUpdated.Phone_Call_Ids__c=((c.Phone_Call_Ids__c).contains('_')?(c.Phone_Call_Ids__c).substringbefore('_'):c.Phone_Call_Ids__c);
                    isUpdated = true;
                    //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- END

                    Storico_Chiamate__c Storicocall = new Storico_Chiamate__c();
                    
                    if(String.isNotBlank(c.AgentName__r.Id))
                    //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- START
                        //Storicocall = new Storico_Chiamate__c(Case__c=c.Id,Call_ID__c=c.Phone_Call_Ids__c,Customer__c = c.AgentName__c,Phone_Call_Time__c=system.now()); 
                        Storicocall = new Storico_Chiamate__c(Case__c=c.Id,
                                                            //Call_ID__c=c.Phone_Call_Ids__c,
                                                            Call_ID__c=(c.Phone_Call_Ids__c).contains('_')?(c.Phone_Call_Ids__c).substringbefore('_'):'',
                                                            Customer__c = c.AgentName__c,
                                                            Phone_Call_Time__c=system.now(),
                                                            CallDateTime__c=(c.Phone_Call_Ids__c).contains('_')?(c.Phone_Call_Ids__c).substringBetween('_'):'',
                                                            PhoneCallIDB__c=(c.Phone_Call_Ids__c).contains('_')?(c.Phone_Call_Ids__c).substringafterlast('_'):''); 
                    //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- END
                    else if(String.isNotBlank(c.AccountId))
                        //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- START
                        //Storicocall = new Storico_Chiamate__c(Case__c=c.Id,Call_ID__c=c.Phone_Call_Ids__c,Customer__c = c.AccountId,Phone_Call_Time__c=system.now());
                        Storicocall = new Storico_Chiamate__c(Case__c=c.Id,
                                                            //Call_ID__c=c.Phone_Call_Ids__c,
                                                            Call_ID__c=(c.Phone_Call_Ids__c).contains('_')?(c.Phone_Call_Ids__c).substringbefore('_'):'',
                                                            Customer__c = c.AccountId,
                                                            Phone_Call_Time__c=system.now(),
                                                            CallDateTime__c=(c.Phone_Call_Ids__c).contains('_')?(c.Phone_Call_Ids__c).substringBetween('_'):'',
                                                            PhoneCallIDB__c=(c.Phone_Call_Ids__c).contains('_')?(c.Phone_Call_Ids__c).substringafterlast('_'):'');
                        //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- END
                    //MOSCATELLI_M 02/07/2018: Easy Azienda -- START
                    else if(String.isNotBlank(c.User__c))
                        //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- START
                        //Storicocall = new Storico_Chiamate__c(Case__c=c.Id,Call_ID__c=c.Phone_Call_Ids__c,Agente__c = c.User__c,Phone_Call_Time__c=system.now());
                        Storicocall = new Storico_Chiamate__c(Case__c=c.Id,
                                                            //Call_ID__c=c.Phone_Call_Ids__c,
                                                            Call_ID__c=(c.Phone_Call_Ids__c).contains('_')?(c.Phone_Call_Ids__c).substringbefore('_'):'',                                
                                                            Agente__c = c.User__c,
                                                            Phone_Call_Time__c=system.now(),
                                                            CallDateTime__c=(c.Phone_Call_Ids__c).contains('_')?(c.Phone_Call_Ids__c).substringBetween('_'):'',
                                                            PhoneCallIDB__c=(c.Phone_Call_Ids__c).contains('_')?(c.Phone_Call_Ids__c).substringafterlast('_'):'');
                        //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- END
                    //MOSCATELLI_M 02/07/2018: Easy Azienda -- END
                    else
                        //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- START
                        //Storicocall = new Storico_Chiamate__c(Case__c=c.Id,Call_ID__c=c.Phone_Call_Ids__c,Phone_Call_Time__c=system.now());
                        Storicocall = new Storico_Chiamate__c(Case__c=c.Id,
                                                            //Call_ID__c=c.Phone_Call_Ids__c,
                                                            Call_ID__c=(c.Phone_Call_Ids__c).contains('_')?(c.Phone_Call_Ids__c).substringbefore('_'):'',
                                                            Phone_Call_Time__c=system.now(),
                                                            CallDateTime__c=(c.Phone_Call_Ids__c).contains('_')?(c.Phone_Call_Ids__c).substringBetween('_'):'',
                                                            PhoneCallIDB__c=(c.Phone_Call_Ids__c).contains('_')?(c.Phone_Call_Ids__c).substringafterlast('_'):'');
                        //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- END
                    
                    StoricocallList.add(Storicocall);
                }
                
                system.debug('#SerachKey: '+c.Origin+'_'+MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName())+'_'+c.Category__c+'_'+c.SubCategory__c);
                
                if(ConfigTaskApMap.size()>0 && ConfigTaskApMap.containsKey(c.Origin+'_'+MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName())+'_'+c.Category__c+'_'+c.SubCategory__c))
                {
                    AP13Cases.add(c.Id);       
                }
                
                //FM_ 9/05/2018 : GDPR - START
                /*if(String.isNotBlank(c.AccountId) && MapCaseAccount.containskey(c.AccountId))
                {
                    if((MapCaseAccount.get(c.AccountId) == 'B2C_Client' || MapCaseAccount.get(c.AccountId) == 'B2B_Client') && c.Origin != 'Contatto Marketing Cloud')   {
                        Account_Case__c accCase = new Account_Case__c (Case__c = c.Id, Account__c = c.AccountId);
                        System.debug(accCase);
                        AccountCaseList.add(accCase);                
                    }         
                        
                }*/
                //FM_ 9/05/2018 : GDPR - END
                
                
                if(c.Status == AP_Constants.caseStatusAssigned && RecordTypeSet.contains(Schema.SObjectType.Case.getRecordTypeInfosById().get(c.RecordTypeId).getDeveloperName()))
                {
                    //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- START
                    //listCaseToUpdate.add(new Case(id=c.Id, Status = AP_Constants.caseStatusAssILivello));
                    ToBeUpdated.Status = AP_Constants.caseStatusAssILivello;
                    isUpdated = true;
                    //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- END
                }

                //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- START
                if(isUpdated)
                    listCaseToUpdate.add(ToBeUpdated);
                //MOSCATELLI_M 01/03/2018: Accesso a registrazioni audio -- END
            }
            
            if(StoricocallList.size()>0)
                insert StoricocallList; // NOPMD  Fix CRUD violation
            
            if(listCase.size() > 0 )
            {
                AP04Email2Case.setAccount(listCase,setEmail,setAccID);
            }
            
            if(AP13Cases.size()>0)
                AP13_TaskAutomaticOpening.CreateTask(AP13Cases);
            
            /*if(AccountCaseList.size()>0)
                insert AccountCaseList;
            */
            if(listCaseToUpdate.size()>0)
                update listCaseToUpdate;
            
            System.Debug('## >>> END of CaseAfterInsert <<< run by ' + UserInfo.getName()); 
        }   
    }
    
    //public static void AfterUpdateProcess(List<Case> Cases, Map<String,Case> OldValues, Map<String,Account> MapCaseAccount, Map<String,String> MapRecNameToDevelopername)
    public static void AfterUpdateProcess(List<Case> Cases, Map<String,Case> OldValues, Map<String,Account> MapCaseAccount, Map<String,Schema.RecordTypeInfo> MapCaseRecordType, Map<String,String> MapRecNameToDevelopername, Map<String,String> ownerIdProfileNameMap, Map<String, String> ownerIdRoleNameMap)
    {
        system.debug('CaseHandler.AfterUpdateNotDone: '+CaseHandler.AfterUpdateNotDone);
        system.debug('runCaseManagementAfterUpdateFROMtest: '+runCaseManagementAfterUpdateFROMtest);
        if(CaseHandler.AfterUpdateNotDone || runCaseManagementAfterUpdateFROMtest)
        {
            runCaseManagementAfterUpdateFROMtest = false;
            System.Debug('## >>> START of CaseAfterUpdate <<< run by ' + UserInfo.getName());
            if(MapCaseAccount.size()>0)
            {
                LeadConversionManagement.ManageAccountCaseRecords(Cases, OldValues, MapCaseAccount);
            /*Account_Case__c.sObjectType.getDescribe().isCreateable();

            List<Account_Case__c> ListACToInsert = new List<Account_Case__c>();
            List<Account_Case__c> ListACToDelete = new List<Account_Case__c>();
            Map<Id,List<Account_Case__c>> MapCaseAC = new map<Id,List<Account_Case__c>>();
            List<Account_Case__c> ListExistentAccountCase = new List<Account_Case__c>();
            String OldVal ='';
            String NewVal = '';
            
            for(Account_Case__c ac : [SELECT Id, Account__c, Case__c FROM Account_Case__c where Case__c in: OldValues.keySet()])
            {
            NewVal = ac.Case__c;
            
            if((OldVal == NewVal) || String.isBlank(OldVal))
            {
            ListExistentAccountCase.add(ac);
            }
            else
            {
            MapCaseAC.put(OldVal,ListExistentAccountCase);
            ListExistentAccountCase.clear();
            ListExistentAccountCase.add(ac);
            }               
            
            OldVal = NewVal;
            }
            
            if(ListExistentAccountCase.size()>0 && MapCaseAC.size()==0)
            MapCaseAC.put(OldVal,ListExistentAccountCase);
            
            for(Case c : Cases)
            {
            if(MapCaseAccount.containskey(c.AccountId))
            {
            if(MapCaseAccount.get(c.AccountId).RecordType.developername == AP_Constants.rtAccB2C || MapCaseAccount.get(c.AccountId).RecordType.developername == AP_Constants.rtAccB2B)              
            {
            if(MapCaseAC.containsKey(c.id))
            ListACToDelete.addAll(MapCaseAC.get(c.id));
            
            ListACToInsert.add(new Account_Case__c (Case__c = c.Id, Account__c = c.AccountId));
            }    
            }                                   
            }
            
            if(ListACToDelete.size()>0)
            {
            Set<Account_Case__c> tempACDeleteSet = new Set<Account_Case__c>(ListACToDelete);
            ListACToDelete.clear();
            ListACToDelete.addAll(tempACDeleteSet);
            
            delete ListACToDelete;
            }
            
            if(ListACToInsert.size()>0)
            insert ListACToInsert;*/
            }
            
            /*   List<String> recTypeCSList = new List<String>();
            if(MPS_Code_Variables__c.getValues('RecordTypeCaringSalute')!=null)
            {
                if(String.isNotBlank(MPS_Code_Variables__c.getValues('RecordTypeCaringSalute').value__c))
                {
                    for(String s:(MPS_Code_Variables__c.getValues('RecordTypeCaringSalute').value__c).split(';'))
                    {
                        recTypeCSList.add(s);                
                    }
                }
            }
            List<Case> caseCSList = new List<Case>();
            system.debug('recTypeCSList: '+recTypeCSList);
            for(Case cs:Cases){
                system.debug('MapRecNameToDevelopername.get(MapCaseRecordType.get(cs.RecordTypeId).getName())): '+MapRecNameToDevelopername.get(MapCaseRecordType.get(cs.RecordTypeId).getName()));
                if(recTypeCSList.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(cs.RecordTypeId).getName())))
                {
                    caseCSList.add(cs);
                }
            }
            system.debug('caseCSList: '+caseCSList);
            if(!caseCSList.isEmpty())
            {
               CaringSaluteUtils.processCaseTeamAndCaseMilestone(caseCSList, OldValues, MapCaseRecordType, MapRecNameToDevelopername, ownerIdProfileNameMap, ownerIdRoleNameMap);
            } 
            */
            
            //OAVERSANO 19/07/2018: Nuovo Modello di Assistenza -- START   
            //OAVERSANO 15/10/2018 : Increase performance -- START
            List<String> recTypeList = new List<String>();
            if(MPS_Code_Variables__c.getValues('RecordTypeAssistenzaAgenti')!=null)
            {
                if(String.isNotBlank(MPS_Code_Variables__c.getValues('RecordTypeAssistenzaAgenti').value__c))
                {
                    for(String s:(MPS_Code_Variables__c.getValues('RecordTypeAssistenzaAgenti').value__c).split(';'))
                    {
                        recTypeList.add(s);                
                    }
                }
            }
            List<Case> caseList = new List<Case>();
            system.debug('recTypeList: '+recTypeList);
            for(Case cs:Cases){
                system.debug('MapRecNameToDevelopername.get(MapCaseRecordType.get(cs.RecordTypeId).getName())): '+MapRecNameToDevelopername.get(MapCaseRecordType.get(cs.RecordTypeId).getName()));
                if(recTypeList.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(cs.RecordTypeId).getName())) && cs.priority != 'DAC AXA Agenti')
                {
                    caseList.add(cs);
                }
            }
            system.debug('caseList: '+caseList);
            if(!Test.isRunningTest()){
                CaseTeamMemberManagement.processCaseTeam(Cases,ownerIdProfileNameMap,ownerIdRoleNameMap);
            	NewMilestoneTrackingManagement.processMilestoneandWorkingTime(Cases,OldValues, ownerIdProfileNameMap,ownerIdRoleNameMap);
            }
                //ModelloDiAssistenzaUtils.processCaseTeamAndCaseMilestone(Cases, OldValues, MapCaseAccount, MapCaseRecordType, MapRecNameToDevelopername, ownerIdProfileNameMap, ownerIdRoleNameMap);
            
            //OAVERSANO 15/10/2018 : Increase performance -- END
            //OAVERSANO 19/07/2018: Nuovo Modello di Assistenza -- END    
            //OAVERSANO 15/10/2018 : Caring Angel -- START
           /* List<String> recTypeCAList = new List<String>();
            if(MPS_Code_Variables__c.getValues('RecordTypeCaringAngel')!=null)
            {
                if(String.isNotBlank(MPS_Code_Variables__c.getValues('RecordTypeCaringAngel').value__c))
                {
                    for(String s:(MPS_Code_Variables__c.getValues('RecordTypeCaringAngel').value__c).split(';'))
                    {
                        recTypeCAList.add(s);                
                    }
                }
            }
            List<Case> caseCAList = new List<Case>();
            for(Case cs:Cases){
                if(recTypeCAList.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(cs.RecordTypeId).getName())))
                {
                    caseCAList.add(cs);
                }
                
            }
            if(!caseCAList.isEmpty())
            {
                CaringAngelUtils.processCaseTeamAndCaseMilestone(caseCAList, OldValues, MapCaseRecordType, MapRecNameToDevelopername, ownerIdProfileNameMap, ownerIdRoleNameMap);
            }
            //OAVERSANO 15/10/2018 : Caring Angel -- END
            
            //OAVERSANO 19/03/2019 : AXA Assistance -- START
            List<String> recTypeSinistriList = new List<String>();
            if(MPS_Code_Variables__c.getValues('RecordTypeSinitri')!=null)
            {
                if(String.isNotBlank(MPS_Code_Variables__c.getValues('RecordTypeSinitri').value__c))
                {
                    for(String s:(MPS_Code_Variables__c.getValues('RecordTypeSinitri').value__c).split(';'))
                    {
                        recTypeSinistriList.add(s);                
                    }
                }
            }
            List<Case> caseSinistriList = new List<Case>();
            for(Case cs:Cases){
            	system.debug(' cs.Status: '+ cs.Status);
            	system.debug(' OldValues.get(cs.Id).Status: '+ OldValues.get(cs.Id).Status);
            	system.debug(' cs.OwnerId: '+ cs.OwnerId);
            	system.debug(' OldValues.get(cs.Id).OwnerId: '+ OldValues.get(cs.Id).OwnerId);
                if(recTypeSinistriList.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(cs.RecordTypeId).getName())))
                {
                    if(( cs.Status != OldValues.get(cs.Id).Status)
                        ||
                        (cs.OwnerId != OldValues.get(cs.Id).OwnerId)
                        ||
                        SinistriUtils.runProcessTeamAndMilestone)
                    {
                        caseSinistriList.add(cs);
                    }
                }
                
            }
            if(!caseSinistriList.isEmpty())
            {
                SinistriUtils.processCaseTeamAndCaseMilestone(caseSinistriList, OldValues, MapCaseRecordType, MapRecNameToDevelopername, ownerIdProfileNameMap, ownerIdRoleNameMap);
            }*/
            //OAVERSANO 15/10/2018 : Caring Angel -- END
            
            System.Debug('## >>> END of CaseAfterUpdate <<< run by ' + UserInfo.getName());
        }
    }
    
    
    
    
    // FM_27/08/2018: Nuovo Modello di Assistenza --- START
    public static void ShareWithHD2Roles(List<Case> CasesList) {
        
        if(CaseHandler.AfterUpdateNotDone)
        {
            
            List<Id> CaseListId = new List<Id>();
            List<Id> CaseListCaringSaluteId = new List<Id>();
            List<CaseTeamMember> CaseTeamMembers = new List <CaseTeamMember>();
            Map<String,List<String>> CaseMemberUsersRole = new Map<String,List<String>>();
            Set<Id> UserRoleIds = new Set<Id>();
            //Set<String> RoleGroupsToShare = new Set<String>();
            List<CaseShare> AllCaseToShare = new List<CaseShare>();
            Map<String,String> MapUserRoleIdtoGroupId = new Map<String,String>();
            Map<String,List<String>> CaseGroupIds = new Map<String,List<String>>();
            List<String> GroupIds = new List<String>();
            //OAVERSANO 09/11/2018 : Nuovo Modello di Assistenza Biz -- START
            //Id AssistenzaAgentiRT = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Assistenza_Agenti' LIMIT 1].Id;
            Id AssistenzaAgentiRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Assistenza_Agenti').getRecordTypeId();
            Id CaringSaluteRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('AXA_Caring_Salute').getRecordTypeId();
            Id AxaAssicurazioniRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Axa_Assicurazioni').getRecordTypeId();
            //OAVERSANO 09/11/2018 : Nuovo Modello di Assistenza Biz -- END
            for (Case c: CasesList) {
                
                if (c.RecordTypeId == AssistenzaAgentiRT || c.RecordTypeId == AxaAssicurazioniRT) {
                    CaseListId.add(c.Id);
                }
                
                  if (c.RecordTypeId == CaringSaluteRT) {
                    CaseListCaringSaluteId.add(c.Id);
                }
            }
            
            
            CaseTeamMembers = [SELECT Id, Member.UserRoleId, ParentId FROM CaseTeamMember WHERE ParentId IN: CaseListId AND Member.Profile.Name = 'AAI - Supporto HD2' ]; // NOPMD  Fix CRUD violation
            
            for (CaseTeamMember ctm: CaseTeamMembers) {
                
                UserRoleIds.add(ctm.Member.UserRoleId);
                
                if (CaseMemberUsersRole.containsKey(ctm.ParentId)) {
                    CaseMemberUsersRole.get(ctm.ParentId).add(ctm.Member.UserRoleId);
                }else{
                    
                    CaseMemberUsersRole.put(ctm.ParentId, new List<String> {
                        ctm.Member.UserRoleId
                            });
                    
                }
                
            }
            
            
            //OAVERSANO 09/11/2018 : Nuovo Modello di Assistenza Biz -- START
            Set<String> HD2BIZProfileSet = new Set<String>();
            Set<String> HD2ProfileCaringSaluteSet = new Set<String>();
            if(!CasesList.isEmpty())
            {
             
                List<String> filters = new list<String>{'ProfileManagement'};
                List<Caring_Salute__mdt> mdCaringSaluteList =CaseManagement.retrieveCustomMetadataRecords('Caring_Salute__mdt',filters);
         
                Caring_Salute__mdt mdCaringSalute;
                if (mdCaringSaluteList.size()>0)
                    mdCaringSalute = mdCaringSaluteList[0];
                            

                if(mdCaringSalute!=null)
                {
                    if(String.isNotBlank(mdCaringSalute.HD2Profile__c))
                    {
                        for(String s:mdCaringSalute.HD2Profile__c.split(';'))
                        {
                            HD2ProfileCaringSaluteSet.add(s);
                        }
                    }   
                } 
            
            
                //BOVOLENTA_D 04042019 query reduction START
              
                List<Modello_di_Assistenza__mdt> mdAssList =CaseManagement.retrieveCustomMetadataRecords('Modello_di_Assistenza__mdt',filters);
                /*Modello_di_Assistenza__mdt mdAss = [SELECT Id, DeveloperName,AgentProfile__c, CaseTriggerRecordType__c,
                                                    HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c,
                                                    HD1BIZProfile__c, HD1BIZQueue__c, HD2BIZProfile__c, HD2BIZQueue__c
                                                    FROM Modello_di_Assistenza__mdt 
                                                    WHERE DeveloperName  = 'ProfileManagement'
                                                    LIMIT 1];*/
                Modello_di_Assistenza__mdt mdAss;
                if (mdAssList.size()>0)
                    mdAss = mdAssList[0];
                //BOVOLENTA_D 04042019 query reduction END                   

                if(mdAss!=null)
                {
                    if(String.isNotBlank(mdAss.HD2BIZProfile__c))
                    {
                        for(String s:mdAss.HD2BIZProfile__c.split(';'))
                        {
                            HD2BIZProfileSet.add(s);
                        }
                    }   
                } 
            }
            runQueryWOS runWOS = new runQueryWOS();
            //OAVERSANO 02/01/2019 : Fix Sharing HD2 IT -- START
            //runWOS.insertCaseShare(CasesList, CaseListId, HD2BIZProfileSet);
            runWOS.insertCaseShare(CasesList, CaseListId, HD2BIZProfileSet, 'Read', new Map<String,List<String>>());
            runWOS.insertCaseShare(CasesList, CaseListCaringSaluteId, HD2ProfileCaringSaluteSet, 'Edit', new Map<String,List<String>>());
            //OAVERSANO 02/01/2018 : Fix Sharing HD2 IT -- END
            //OAVERSANO 09/11/2018 : Nuovo Modello di Assistenza Biz -- END
            
            for (Group g: [SELECT Id, RelatedId FROM Group WHERE RelatedId IN: UserRoleIds AND Type = 'Role' ]) { // NOPMD  Fix CRUD violation
                
                MapUserRoleIdtoGroupId.put(g.RelatedId, g.Id);
            }
            
            
            for (string key: CaseMemberUsersRole.keySet()) {
                
                GroupIds.add(key);
                
                CaseGroupIds.put(key, new List<String>{});
                
                for (String value: CaseMemberUsersRole.get(key)) {
                    
                    string mygroup = MapUserRoleIdtoGroupId.get(value);
                    
                    CaseGroupIds.get(key).add(mygroup);
                    
                }
                
            }
            
            system.debug('GroupIds' + GroupIds);
            
            
            if (GroupIds != null && GroupIds.size()>0) {
                
                //OAVERSANO 02/01/2019 : Fix Sharing HD2 IT -- START
                /*for (string key: CaseGroupIds.keySet()) {
                    
                    
                    for (String value: CaseGroupIds.get(key)) {
                        
                        
                        CaseShare cs = new CaseShare();
                        cs.CaseId = key;
                        cs.UserOrGroupID = value;
                        cs.CaseAccessLevel = 'Edit'; //'None','Read','Edit','All'
                        cs.RowCause = 'Manual';
                        
                        AllCaseToShare.add(cs);
                        
                    }
                    
                    
                    
                }
                
                List<Database.SaveResult> SaveResult = Database.insert(AllCaseToShare, false);
                system.debug('*******************SaveResult' + SaveResult);
                */
                runWOS.insertCaseShare(CasesList, CaseListId, new Set<String>(), 'Edit', CaseGroupIds);
                //OAVERSANO 02/01/2018 : Fix Sharing HD2 IT -- END
                
            }
            
        }
    }
    
    //OAVERSANO 09/11/2018 : Nuovo Modello di Assistenza Biz -- START
    public without sharing class runQueryWOS
    {
        public runQueryWOS(){}
        
        //OAVERSANO 02/01/2019 : Fix Sharing HD2 IT -- START
        //public void insertCaseShare(List<Case> CasesList, List<Id> CaseListId, Set<String> HD2BIZProfileSet)
        public void insertCaseShare(List<Case> CasesList, List<Id> CaseListId, Set<String> HD2BIZProfileSet, String CaseAccessLevel, Map<String,List<String>> CaseGroupIds)
        //OAVERSANO 02/01/2019 : Fix Sharing HD2 IT -- END
        { 
            List<CaseShare> AllCaseToShare = new List<CaseShare>();
            Set<String> ToShareList = new Set<String>();
            //OAVERSANO 02/01/2019 : Fix Sharing HD2 IT -- START
            if(!HD2BIZProfileSet.isEmpty())
            {
            //OAVERSANO 02/01/2019 : Fix Sharing HD2 IT -- END
                List<User> ToShare = [SELECT Id, Name FROM User WHERE Profile.Name IN:HD2BIZProfileSet ]; // NOPMD  Fix CRUD violation
                for(User us:ToShare)
                {
                    ToShareList.add(us.Id);
                }
                for(Case c:CasesList)
                {
                    if(CaseListId.contains(c.Id))
                    {
                        for(String us:ToShareList)
                        {
                            CaseShare cs = new CaseShare();
                            cs.CaseId = c.Id;
                            cs.UserOrGroupID = us;
                            //OAVERSANO 02/01/2019 : Fix Sharing HD2 IT -- START
                            //cs.CaseAccessLevel = 'Read'; //'None','Read','Edit','All'
                            cs.CaseAccessLevel = CaseAccessLevel; //'None','Read','Edit','All'
                            //OAVERSANO 02/01/2019 : Fix Sharing HD2 IT -- END
                            cs.RowCause = 'Manual';
                            AllCaseToShare.add(cs);
                        }
                    }
                }
            //OAVERSANO 02/01/2019 : Fix Sharing HD2 IT -- START
            }   
            else if(!(CaseGroupIds.keySet()).isEmpty())
            {
                for (string key: CaseGroupIds.keySet()) 
                {
                    for (String value: CaseGroupIds.get(key)) 
                    {
                        CaseShare cs = new CaseShare();
                        cs.CaseId = key;
                        cs.UserOrGroupID = value;
                        cs.CaseAccessLevel = CaseAccessLevel; //'None','Read','Edit','All'
                        cs.RowCause = 'Manual';
                        
                        AllCaseToShare.add(cs);
                        
                    }
                }
            }
            //OAVERSANO 02/01/2019 : Fix Sharing HD2 IT -- END
            List<Database.SaveResult> SaveResult = Database.insert(AllCaseToShare, false);
            system.debug('*******************SaveResult' + SaveResult);
        }
        
    } 
    //OAVERSANO 09/11/2018 : Nuovo Modello di Assistenza Biz -- END
    //FM_27/08/2018: Nuovo Modello di Assistenza --- END
    
    //OAVERSANO 23/10/2018 : ICF Close The Loop -- START
    public without sharing class caseTeamManagement {

        public caseTeamManagement(){
        }

        public void createCaseTeamMembers(List<Case> cslist, Map<String, String> caseIdOwnerIdMap){
            system.debug('createCaseTeamMembers method');
            List<CaseTeamRole> caseTeamRoles = [SELECT Id, Name FROM CaseTeamRole WHERE Name =:AgentRoleTCR ];   // NOPMD  Fix CRUD violation
            Map<String,String> csTeamRoleNameIdMap = new Map<String, String>();
            for(CaseTeamRole csTR : caseTeamRoles)
            {
                csTeamRoleNameIdMap.put(csTR.name, csTR.Id);
            }
            List<Case> caseList = [SELECT Id, Status, CaseMilestone_StartDate__c, Owner.Profile.Name, // NOPMD  Fix CRUD violation
                  RecordType.DeveloperName, OwnerId, Owner.UserRole.Name, Tempo_in_gestione_HD3__c,
                  Time_With_Support__c, Time_With_Customer__c, Time_With_Technicians__c,
                  MilestoneFlag__c, isClosed, Durata_lavorazione_uffici_tecnici__c,
                  Owner.Name, CreatedById, CreatedBy.Profile.Name,
                  (SELECT id, StartDate, CompletionDate, IsCompleted
                  FROM CaseMilestones 
                  WHERE IsCompleted = false),
                  (SELECT MemberId, TeamRoleId, ParentId 
                  FROM TeamMembers)
                  FROM Case 
                  WHERE Id IN:cslist ];
            Map<Id, Set<String>> membersCaseMap = new Map<Id, Set<String>>();
            Set<CaseTeamMember> caseTeamMembersToAdd = new Set<CaseTeamMember>();
            for(Case cs:caseList)
            {
                if(!cs.TeamMembers.isEmpty())
                {
                    for(CaseTeamMember csTM:cs.TeamMembers)
                    {
                        if(membersCaseMap.containsKey(csTM.ParentId))
                        {
                            Set<String> caseTeamMemberList = membersCaseMap.get(csTM.ParentId);
                            caseTeamMemberList.add(csTM.MemberId);
                            membersCaseMap.put(csTM.ParentId, caseTeamMemberList);
                        } 
                        else 
                        {
                            membersCaseMap.put(csTM.ParentId, new Set<String> { csTM.MemberId }); 
                        }
                    }
                }  
            }
            for(Case cs:caseList)
            {
          
                
                if( membersCaseMap.containsKey(cs.Id) )
                {
                    system.debug('case with caseteam');
                    if(!(membersCaseMap.get(cs.Id).contains(caseIdOwnerIdMap.get(cs.Id)) ) )
                    {
                        system.debug('aggiunta nuovo membro Agente');
                        CaseTeamMember ctMember = new CaseTeamMember(ParentId = cs.Id,
                                      MemberId = caseIdOwnerIdMap.get(cs.Id),
                                      TeamRoleId = csTeamRoleNameIdMap.get(AgentRoleTCR)
                                      );
                        caseTeamMembersToAdd.add(ctMember);
                    }
                }
                else
                {
                    system.debug('inizializzazione membro Agente');
                    CaseTeamMember ctMember = new CaseTeamMember(ParentId = cs.Id,
                                      MemberId = caseIdOwnerIdMap.get(cs.Id),
                                      TeamRoleId = csTeamRoleNameIdMap.get(AgentRoleTCR)
                                      );
                    caseTeamMembersToAdd.add(ctMember);
                }
            }
            try
            {
                if(!caseTeamMembersToAdd.isEmpty())
                {
                    List<CaseTeamMember> CaseTeamMemberList = new List<CaseTeamMember>();
                    CaseTeamMemberList.addAll(caseTeamMembersToAdd);
                    insert CaseTeamMemberList;
                }
            }
            catch(Exception ex)
            {
                system.debug('Error : '+ex.getMessage());
            }
        }
    }
    //OAVERSANO 23/10/2018 : ICF Close The Loop -- END
    
}
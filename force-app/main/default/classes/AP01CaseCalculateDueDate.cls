public with sharing class AP01CaseCalculateDueDate {
/* 
----------------------------------------------------------------------
-- - Name          : AP01CaseCalculateDueDate
-- - Author        : Spoon Consulting
-- - Description   : Class to calculate DueDate and AcknowledgementDueDate
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 08-MAY-2013  YRA    1.0     Initial version
----------------------------------------------------------------------
***********************************************************************/
    //method to calculate DueDate and AcknowledgementDueDate
    //MOSCATELLI_M 17/11/2016:EVO 70 -- start
    //public static void calculateDueDate (list <Case> caseNewList)
    //OAVERSANO 18/01/2019 : Gestione Reclami -- START
    //public static void calculateDueDate (list <Case> caseNewList, Id defaultHours,String GDPRHoursId, String EntGDPRId, String Entid,String EntGDPRId2, String EntGDPRId3, String EntAssAgenti,String EntCaringAngel, Map<String, Schema.RecordTypeInfo> MapCaseRecordType, Map<String,String> MapRecNameToDevelopername)
    public static void calculateDueDate (list <Case> caseNewList, Id defaultHours,String GDPRHoursId, String EntGDPRId, String Entid,String EntGDPRId2, String EntGDPRId3, String EntAssAgenti,String EntCaringAngel, String EntReclamo, Map<String, Schema.RecordTypeInfo> MapCaseRecordType, Map<String,String> MapRecNameToDevelopername)
    //OAVERSANO 18/01/2019 : Gestione Reclami -- END
    //MOSCATELLI_M 17/11/2016:EVO 70 -- end
    {
        system.debug('## Start method AP01CaseCalculateDueDate.calculateDueDate '+ UserInfo.getName());
        
        Id bh;
        Boolean IsPrivate;//MOSCATELLI_M 10062016:EVO 61
        Boolean isVIPCustomer;//MOSCATELLI_M 17/11/2016:EVO 70  
        Decimal SLAmin;
        Decimal SLAmax;
        Decimal SLAmin2;
        Decimal SLAmax2;
        Decimal SLAmax3;
             
        
        //MOSCATELLI_M 09122015: EVO-24----START
        id EntitlementId;
        //List<entitlement> ListEnt = [SELECT Id from entitlement where status = 'Active'];//dismissed: FM_17/05/2018 : GDPR

        /*if(!ListEnt.isEmpty()) 
            Entid = ListEnt[0].id;*/                //dismissed: FM_17/05/2018 : GDPR
        //MOSCATELLI_M 09122015: EVO-24----END


        //FM_17/05/2018 : GDPR --- START
        //Map<String,Id> MapEntitlement = new map<String,Id>();
        //String Entitlement = MPS_Code_Variables__c.getAll().get('Entitlement').Value__c;
        //String EntitlementGDPR = MPS_Code_Variables__c.getAll().get('Entitlement GDPR').Value__c;
        //String CaseCategoryGDPR = MPS_Code_Variables__c.getAll().get('GDPR_Category_001').Value__c;

       /* for(Entitlement e: [SELECT Id,Name FROM Entitlement WHERE status = 'Active']){

            MapEntitlement.put(e.Name, e.Id);

        }

*/
        
        //OAVERSANO 01/08/2018: Nuovo Modello di Assistenza -- START
        Set<String> RecordTypeSet = new Set<String>();
        Modello_di_Assistenza__mdt mdAss = [SELECT Id, DeveloperName,AgentProfile__c, CaseTriggerRecordType__c,
                              HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c 
                              FROM Modello_di_Assistenza__mdt 
                              WHERE DeveloperName  = 'ProfileManagement'
                              LIMIT 1];
	    if(mdAss!=null)
	    {
	            if(String.isNotBlank(mdAss.CaseTriggerRecordType__c))
	                for(String s:mdAss.CaseTriggerRecordType__c.split(';'))
	                    RecordTypeSet.add(s);  
	    }
    
        //OAVERSANO 01/08/2018: Nuovo Modello di Assistenza -- END
        
        //OAVERSANO 16/10/2018 : Caring Angel -- START
        Set<String> RecordTypeSetCA = new Set<String>();
        Caring_Angel__mdt caringAngel = [SELECT Id, DeveloperName, CaseTriggerRecordType__c,
                            HD1Profile__c, HD1Queue__c, HD2Profile__c, HD2Queue__c 
                            FROM Caring_Angel__mdt 
                            WHERE DeveloperName  = 'ProfileManagement'
                            LIMIT 1];
	    if(caringAngel!=null)
	    {
	            if(String.isNotBlank(caringAngel.CaseTriggerRecordType__c))
	                for(String s:caringAngel.CaseTriggerRecordType__c.split(';'))
	                    RecordTypeSetCA.add(s);  
	    }
	    //OAVERSANO 16/10/2018 : Caring Angel -- END
	    //OAVERSANO 22/03/2019 : AXA Assistance -- START
	    Set<String> RecordTypeNameSetSinistri = new Set<String>();
        List<Assistenza_sinistri__mdt> assSinList = [SELECT Id, DeveloperName, Value__c
                            FROM Assistenza_sinistri__mdt 
                            WHERE DeveloperName LIKE 'claimProfileManagement%'
                            ];
            
        for(Assistenza_sinistri__mdt assSin : assSinList)
        {
      		if(assSin.DeveloperName == 'claimProfileManagementRecordTypes')
      		{
      			if(String.isNotBlank(assSin.Value__c))
              	{
                  	for(String s:assSin.Value__c.split(';'))
                  	{
                      	RecordTypeNameSetSinistri.add(s);
                  	}
              	}
      		}
        }
	    //OAVERSANO 22/03/2019 : AXA Assistance -- END

        List<String> GDPRCategories = new List<String>();

        for(MPS_Code_Variables__c MPSCv: MPS_Code_Variables__c.getAll().values())
            {
                if((MPSCv.Name).contains('GDPR_Category'))
                    GDPRCategories.add(MPSCv.Value__c);

                if((MPSCv.Name).contains('Entitlement GDPR')){

                    if((MPSCv.Name) =='Entitlement GDPR'){
                    SLAmin = MPSCv.SLAmin__c;
                    SLAmax = MPSCv.SLAmax__c;
                }


                    if((MPSCv.Name).contains('2')){
                    SLAmin2 = MPSCv.SLAmin__c;
                    SLAmax2 = MPSCv.SLAmax__c;
                }

                    if((MPSCv.Name).contains('3'))
                    SLAmax3 = MPSCv.SLAmax__c;
                }
            }   

        //FM_17/05/2018 : GDPR --- END
        
        //OAVERSANO 22/01/2019 : Gestione Reclami -- START
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
        //OAVERSANO 22/01/2019 : Gestione Reclami -- END
        
        
        //MOSCATELLI_M 09112015: EVO-23-----START
        List<Id> AccountId = new List<Id>();
        Map<Id,String> AccountServiceMap = new map<Id,String>();
        
        for(Case c :caseNewList)
        {
            if(String.isNotBlank(c.AccountId))
                AccountId.add(c.AccountId);
         //FM_17/05/2018 : GDPR --- START
            
              //OAVERSANO 01/08/2018: Nuovo Modello di Assistenza -- START
              if(RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName())))
              {
                EntitlementId = EntAssAgenti;
                if(c.BusinessHoursId!=null)
                {
                    bh = c.BusinessHoursId;
                }
                else
                {
                    
                    //bh = defaultHours.Id;
                    bh = defaultHours;
                }
                
              }
              	//OAVERSANO 16/10/2018 : Caring Angel -- START
              	else if(RecordTypeSetCA.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName())))
              	{
      				EntitlementId = EntCaringAngel;
            		if(c.BusinessHoursId!=null)
            		{
                		bh = c.BusinessHoursId;
                	}
                	else
                	{
                    	bh = defaultHours;
                	}
              	}
              	//OAVERSANO 16/10/2018 : Caring Angel -- END
              	//OAVERSANO 18/01/2019 : Gestione Reclami -- START
               //else if(GDPRCategories.contains(c.Category__c)
               else if(GDPRCategories.contains(c.Category__c) 
               ||
               devNamerecordTypeRecalculateAP01Set.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))){
               	//OAVERSANO 18/01/2019 : Gestione Reclami -- END
                 //if(GDPRCategories.contains(c.Category__c)){
                 //OAVERSANO 01/08/2018: Nuovo Modello di Assistenza -- END
        
                    //EntitlementId = EntGDPRId;
                    bh = GDPRHoursId; 

                }else{

                    EntitlementId = EntId;


            if(c.BusinessHoursId!=null)
            {
                bh = c.BusinessHoursId;
            }
            else
            {
                
                //bh = defaultHours.Id;
                bh = defaultHours;
            }

                }

        
        //FM_17/05/2018 : GDPR --- END

        system.debug('bh Id'+bh);

        }
        
        if(AccountId.size()>0)
        {
            for(Account a : [SELECT Id, Servizio__c FROM Account where id in :AccountId])
            {
                if(String.isNotBlank(a.Servizio__c))
                    AccountServiceMap.put(a.id, a.Servizio__c);
            }            
        }  
        
        String AccountService = '';
        //MOSCATELLI_M 09112015: EVO-23-----END
        
        //Get the default business hours
        //BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];
        system.debug('##defaultHours'+defaultHours);
        
        //MOSCATELLI_M 17/11/2016:EVO 70 -- START
        Set<String> VIPCharacteristicsSet = new Set<String>();
        
        for(VIPCustomersCharacteristics__c  VIPChar: VIPCustomersCharacteristics__c.getAll().values())
        {
            VIPCharacteristicsSet.add(VIPChar.Case_Category__c);
        }
        system.debug('##VIPCharacteristicsSet: '+VIPCharacteristicsSet);
        //MOSCATELLI_M 17/11/2016:EVO 70 -- END
        
        map<string,CaseSLA__c> mapCaseSLA = new map<string,CaseSLA__c>();
        
        for(CaseSLA__c CaseSLA : CaseSLA__c.getAll().values())
        {
            mapCaseSLA.put(CaseSLA.Category__c+'-'+CaseSLA.SubCategory__c,CaseSLA);
        }
        
        //MOSCATELLI_M 14012016: EVO-43----START
        
        //MOSCATELLI_M 17/11/2016:EVO 70 -- START
        /*
        Map<Id,RecordType> MapCasRecTyp = new map<Id,RecordType>([Select id, name from RecordType where SobjectType = 'Case']);

        */
       
        String[] types = new String[]{'Case'}; 
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types); 
        Map<String, Schema.RecordTypeInfo> MapCasRecTyp = new Map<String, Schema.RecordTypeInfo> ();
        
        for (Schema.RecordTypeInfo ri: results[0].getRecordTypeInfos()) 
        { 
            MapCasRecTyp.put(ri.getRecordTypeId(), ri);
        }
        system.debug('##MapCasRecTyp: '+MapCasRecTyp);
        //MOSCATELLI_M 17/11/2016:EVO 70 -- END
            
        //Creation of a map containing all the possible active configurations of SLA
        
        //MOSCATELLI_M 10062016:EVO 61 -- START
        //List<Configurazione_SLA_Case__c> ListCaseSLAConfigurations= [SELECT Case_Origin__c,Case_Record_Type__c,Category__c,SLA_for_MPS_One_Customers__c,SLA__c,Sub_Category__c FROM Configurazione_SLA_Case__c WHERE Rule_Active__c = true];
        //OAVERSANO 21/01/2019 : Gestione Reclami -- START
        //List<Configurazione_SLA_Case__c> ListCaseSLAConfigurations= [SELECT Case_Origin__c,Case_Record_Type__c,Category__c,SLA_for_MPS_One_Customers__c,SLA__c,SLA_for_Private_Customers__c,Sub_Category__c,Customer_Service_Type__c,Distribution_Network__c FROM Configurazione_SLA_Case__c WHERE Rule_Active__c = true];
        List<Configurazione_SLA_Case__c> ListCaseSLAConfigurations= [SELECT Case_Origin__c,Case_Record_Type__c,Category__c,SLA_for_MPS_One_Customers__c,SLA__c,SLA_for_Private_Customers__c,Sub_Category__c,Customer_Service_Type__c,Distribution_Network__c,Complainant__c FROM Configurazione_SLA_Case__c WHERE Rule_Active__c = true];
        //OAVERSANO 21/01/2019 : Gestione Reclami -- END
        
        Map<String,String> MapModelliServizio = new map<String,String>();
        
        for(Definizione_Modelli_di_Servizio__c ModServ:[Select Customer_Typology__c, Modello_di_Servizio__c from Definizione_Modelli_di_Servizio__c])
        {
            MapModelliServizio.put(ModServ.Modello_di_Servizio__c, ModServ.Customer_Typology__c);
        }
        //MOSCATELLI_M 10062016:EVO 61 -- END
        
        Map <String,Configurazione_SLA_Case__c> MapCaseSLAConfigurations = new map<string,Configurazione_SLA_Case__c>();
        
        for(integer iconf=0;iconf<ListCaseSLAConfigurations.size();iconf++)
        {
            //MOSCATELLI_M 10062016:EVO 61 -- START
            //MapCaseSLAConfigurations.put(ListCaseSLAConfigurations[iconf].Category__c+'-'+ListCaseSLAConfigurations[iconf].Sub_Category__c+'-'+ListCaseSLAConfigurations[iconf].Case_Origin__c+'-'+ListCaseSLAConfigurations[iconf].Case_Record_Type__c,ListCaseSLAConfigurations[iconf]);
            //OAVERSANO 21/01/2019 : Gestione Reclami -- START
            //MapCaseSLAConfigurations.put(ListCaseSLAConfigurations[iconf].Category__c+'-'+ListCaseSLAConfigurations[iconf].Sub_Category__c+'-'+ListCaseSLAConfigurations[iconf].Case_Origin__c+'-'+ListCaseSLAConfigurations[iconf].Case_Record_Type__c+'-'+ListCaseSLAConfigurations[iconf].Customer_Service_Type__c+'-'+ListCaseSLAConfigurations[iconf].Distribution_Network__c,ListCaseSLAConfigurations[iconf]);
            MapCaseSLAConfigurations.put(ListCaseSLAConfigurations[iconf].Category__c+'-'+ListCaseSLAConfigurations[iconf].Sub_Category__c+'-'+ListCaseSLAConfigurations[iconf].Case_Origin__c+'-'+ListCaseSLAConfigurations[iconf].Case_Record_Type__c+'-'+ListCaseSLAConfigurations[iconf].Customer_Service_Type__c+'-'+ListCaseSLAConfigurations[iconf].Distribution_Network__c+'-'+ListCaseSLAConfigurations[iconf].Complainant__c,ListCaseSLAConfigurations[iconf]);
            //OAVERSANO 21/01/2019 : Gestione Reclami -- END
            //MOSCATELLI_M 10062016:EVO 61 -- END
        }
        system.debug('MapCaseSLAConfigurations :'+MapCaseSLAConfigurations);
       //MOSCATELLI_M 14012016: EVO-43----END
        
        for(Case c:caseNewList)
        {
            system.debug('##########'+c.createddate);
            
            //MOSCATELLI_M 17/11/2016:EVO 70 -- START
            isVIPCustomer = false;
            
            if(String.isNotBlank(c.Category__c) || String.isNotBlank(c.Prodotto__c))
            {
                if(VIPCharacteristicsSet.contains(c.Category__c) || VIPCharacteristicsSet.contains(c.Prodotto__c))
                    isVIPCustomer = true;
            }
            //MOSCATELLI_M 17/11/2016:EVO 70 -- END
        
        //DISMISSED FM_17/05/2018 : GDPR --- START
        /*    if(c.BusinessHoursId!=null)
            {
                bh = c.BusinessHoursId;
            }
            else 
            {
                //MOSCATELLI_M 17/11/2016:EVO 70 -- START
                //bh = defaultHours.Id;
                bh = defaultHours;
                //MOSCATELLI_M 17/11/2016:EVO 70 -- END
            }*/

        //DISMISSED FM_17/05/2018 : GDPR --- END
            
            //MOSCATELLI_M 09112015: EVO-23-----START
            system.debug('id: '+c.AccountId);
            
            if(c.AccountId!=null)
            {   
                if(AccountServiceMap.containsKey(c.AccountId))
                    AccountService = AccountServiceMap.get(c.AccountId);            
               
                system.debug('Servizio: '+AccountService+'   '+'AccountId: '+c.AccountId);
            }
            //MOSCATELLI_M 09112015: EVO-23-----END
            
            //MOSCATELLI_M 14012016: EVO-43----START
            c.SLAHours__c = 0;
            c.SLATaskHours__c = (c.SLATaskHours__c==null)?0:c.SLATaskHours__c;
            datetime slaDate = (c.createddate==null)?system.now():c.createddate;            
            
            /*
            if(mapCaseSLA.containsKey(c.Category__c+'-'+c.SubCategory__c)){
              CaseSLA__c CaseSLA = mapCaseSLA.get(c.Category__c+'-'+c.SubCategory__c);
              //MOSCATELLI_M 23122015: EVO-24-----START
                //if((c.Origin == AP_Constants.caseOriginEmail || c.Origin == AP_Constants.caseOriginEmail2Case || c.Origin == AP_Constants.caseOriginBranchMain) && CaseSLA.EmailTotalHours__c <> null){
              if((c.Origin != AP_Constants.caseOriginPhone) && CaseSLA.EmailTotalHours__c <> null){
              //MOSCATELLI_M 23122015: EVO-24-----END
                  c.SLAHours__c = CaseSLA.EmailTotalHours__c;
                //c.CaseDueDate__c =  BusinessHours.addGMT(bh,slaDate,(c.SLAHours__c*60 * 60 * 1000L).longValue());
                  
              }
                  //MOSCATELLI_M 09112015: EVO-23-----START
                  //else if (c.Origin == AP_Constants.caseOriginPhone && CaseSLA.PhoneTotalHours__c <> null){
                    else if (c.Origin == AP_Constants.caseOriginPhone && (CaseSLA.PhoneTotalHours__c <> null || CaseSLA.Phone_ONE_total_hour__c <> null)){
                        if(AccountService != '' && AccountService == 'MPS One')
                        {

                            c.SLAHours__c = CaseSLA.Phone_ONE_total_hour__c;
                        }
                        else
                        {
                     
                            c.SLAHours__c = CaseSLA.PhoneTotalHours__c;
                        }
                  //MOSCATELLI_M 09112015: EVO-23-----END
              }
            }
            */
            
            string recname    = '';
            string AllValues  = 'All';
            string NullValue  = null;
            string MPSOneCust = 'MPS One';
            
            //MOSCATELLI_M 10062016:EVO 61 --START
            if(MapModelliServizio.containsKey(c.Customer_Service_Model__c))
                IsPrivate = (MapModelliServizio.get(c.Customer_Service_Model__c)== 'Private' ? true : false);
            else
                IsPrivate = false;            
            //MOSCATELLI_M 10062016:EVO 61 -- END
            
            if(MapCasRecTyp.containsKey(c.RecordTypeId))
                recname = (MapCasRecTyp.get(c.RecordTypeId)).getName();
            
            //OAVERSANO 21/01/2019 : Gestione Reclami -- START
            //system.debug('Type: '+c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c);
            system.debug('Type: '+c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c);
            //OAVERSANO 21/01/2019 : Gestione Reclami -- END 
            
            //FM_14/05/2018 -- GDPR : START
            system.debug('Data ricezione richiesta DPO'+c.Data_Ricezione_richiesta_DPO__c);

            if(GDPRCategories.contains(c.Category__c) && c.Data_Ricezione_richiesta_DPO__c != null){

                c.Tempo_trascorso_in_DPO_in_BH__c = Businesshours.diff(bh,c.Data_Ricezione_richiesta_DPO__c,slaDate)/3600000;
            }

            system.debug('Durata lavorazione DPO in BH'+c.Tempo_trascorso_in_DPO_in_BH__c);
            //FM_14/05/2018 -- GDPR : END

            //MOSCATELLI_M 10062016:EVO 61 -- START
            //if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname))
            if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;    
                else if(AccountService != '' && AccountService == MPSOneCust)
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname).SLA_for_MPS_One_Customers__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname).SLA__c
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            //else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname))
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname).SLA_for_MPS_One_Customers__c;  
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;              
                else
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname).SLA__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            //else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues))
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues).SLA_for_MPS_One_Customers__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;              
                else
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues).SLA__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            //else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues))
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues).SLA__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            //else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname))
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname).SLA_for_MPS_One_Customers__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname).SLA__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            //else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues))
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                 
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues).SLA_for_MPS_One_Customers__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues).SLA__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            //else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname))
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname).SLA_for_MPS_One_Customers__c;                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname).SLA__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            //else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues))
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                 
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues).SLA__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;    
                else if(AccountService != '' && AccountService == MPSOneCust)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;              
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;              
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                 
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                 
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            //MOSCATELLI_M 19122016:EVO 73 -- START
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA_for_Private_Customers__c;    
                else if(AccountService != '' && AccountService == MPSOneCust)                    
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA_for_Private_Customers__c;
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;              
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA_for_Private_Customers__c;
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;              
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                 
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                 
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA_for_Private_Customers__c;    
                else if(AccountService != '' && AccountService == MPSOneCust)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA_for_Private_Customers__c;
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;              
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA_for_Private_Customers__c;
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;              
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                 
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA_for_Private_Customers__c;                 
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Complainant__c).SLA__c;
            }  
            //OAVERSANO 21/01/2019 : Gestione Reclami -- START 
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_Private_Customers__c;    
                else if(AccountService != '' && AccountService == MPSOneCust)
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname).SLA_for_MPS_One_Customers__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname).SLA__c
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA__c;
            }
            //else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname))
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_Private_Customers__c;
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname).SLA_for_MPS_One_Customers__c;  
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_MPS_One_Customers__c;              
                else
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname).SLA__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA__c;
            }
            //else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues))
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_Private_Customers__c;
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues).SLA_for_MPS_One_Customers__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_MPS_One_Customers__c;              
                else
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues).SLA__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA__c;
            }
            //else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues))
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues).SLA__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA__c;
            }
            //else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname))
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname).SLA_for_MPS_One_Customers__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname).SLA__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA__c;
            }
            //else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues))
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_Private_Customers__c;                 
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues).SLA_for_MPS_One_Customers__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues).SLA__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA__c;
            }
            //else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname))
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname).SLA_for_MPS_One_Customers__c;                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname).SLA__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA__c;
            }
            //else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues))
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_Private_Customers__c;                 
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    //c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues).SLA__c;
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+c.Distribution_Network__c+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_Private_Customers__c;    
                else if(AccountService != '' && AccountService == MPSOneCust)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_Private_Customers__c;
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_MPS_One_Customers__c;              
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_Private_Customers__c;
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_MPS_One_Customers__c;              
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_Private_Customers__c;                 
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_Private_Customers__c;                 
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+AllValues).SLA__c;
            }
            //MOSCATELLI_M 19122016:EVO 73 -- START
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA_for_Private_Customers__c;    
                else if(AccountService != '' && AccountService == MPSOneCust)                    
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA_for_Private_Customers__c;
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;              
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA_for_Private_Customers__c;
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;              
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA_for_Private_Customers__c;                 
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA_for_Private_Customers__c;                 
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+c.Customer_Service_Model__c+'-'+AllValues+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA_for_Private_Customers__c;    
                else if(AccountService != '' && AccountService == MPSOneCust)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA_for_Private_Customers__c;
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;              
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA_for_Private_Customers__c;
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;              
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+c.SubCategory__c+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA_for_Private_Customers__c;                 
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+c.Origin+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA_for_Private_Customers__c;                
                else if(AccountService != '' && AccountService == MPSOneCust)                                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+recname+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA_for_Private_Customers__c;                 
                else if(AccountService != '' && AccountService == MPSOneCust)                
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+NullValue+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues+'-'+AllValues).SLA__c;
            } 
            else if(MapCaseSLAConfigurations.containsKey(c.Category__c+'-'+AllValues+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+AllValues+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;    
                else if(AccountService != '' && AccountService == MPSOneCust)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+AllValues+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(c.Category__c+'-'+AllValues+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            else if(MapCaseSLAConfigurations.containsKey(AllValues+'-'+AllValues+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    c.SLAHours__c = MapCaseSLAConfigurations.get(AllValues+'-'+AllValues+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_Private_Customers__c;    
                else if(AccountService != '' && AccountService == MPSOneCust)
                    c.SLAHours__c = MapCaseSLAConfigurations.get(AllValues+'-'+AllValues+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA_for_MPS_One_Customers__c;                
                else
                    c.SLAHours__c = MapCaseSLAConfigurations.get(AllValues+'-'+AllValues+'-'+c.Origin+'-'+recname+'-'+AllValues+'-'+c.Distribution_Network__c+'-'+c.Complainant__c).SLA__c;
            }
            //OAVERSANO 21/01/2019 : Gestione Reclami -- END
            //MOSCATELLI_M 19122016:EVO 73 -- END
            
            //MOSCATELLI_M 10062016:EVO 61 -- END 
            
            system.debug('SLA :'+c.SLAHours__c);
            //MOSCATELLI_M 14012016: EVO-43----END
            
            //OAVERSANO 31/08/2018: Nuovo Modello di Assistenza -- START
            if(MPS_Code_Variables__c.getValues('MilestoneTrackerVisible99H')!=null)
            {
                if(MPS_Code_Variables__c.getValues('MilestoneTrackerVisible99H').value__c == 'true')
                {
                    if(RecordTypeSet.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))&&c.SLAHours__c==0)
                    {
                        MPS_Code_Variables__c MDASLA = MPS_Code_Variables__c.getValues('ModelloDiAssistenzaSLADefault');
                        if(MDASLA!= null)
                        {
                            if(String.isNotBlank(MDASLA.Value__c))
                                c.SLAHours__c= Integer.valueOf(MDASLA.Value__c);
                        }
                        
                    }   
                }
            }
            
            //OAVERSANO 31/08/2018: Nuovo Modello di Assistenza -- END
            
            //OAVERSANO 16/10/2018 : Caring Angel -- START
            if(MPS_Code_Variables__c.getValues('CAMilestoneTrackerVisible99H')!=null)
            {
                if(MPS_Code_Variables__c.getValues('CAMilestoneTrackerVisible99H').value__c == 'true')
                {
                    if(RecordTypeSetCA.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName())) && c.SLAHours__c==0)
                    {
                        MPS_Code_Variables__c CASLA = MPS_Code_Variables__c.getValues('CaringAngelSLADefault');
                        if(CASLA!= null)
                        {
                            if(String.isNotBlank(CASLA.Value__c))
                                c.SLAHours__c= Integer.valueOf(CASLA.Value__c);
                        }
                        
                    }   
                }
            }
            //OAVERSANO 16/10/2018 : Caring Angel -- END
            
            //OAVERSANO 22/03/2019 : AXA Assistance -- START
            if(MPS_Code_Variables__c.getValues('SinistriMilestoneTrackerVisible99H')!=null)
            {
                if(MPS_Code_Variables__c.getValues('SinistriMilestoneTrackerVisible99H').value__c == 'true')
                {
                    if(RecordTypeNameSetSinistri.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName())) && c.SLAHours__c==0)
                    {
                        MPS_Code_Variables__c CASLA = MPS_Code_Variables__c.getValues('SinistriSLADefault');
                        if(CASLA!= null)
                        {
                            if(String.isNotBlank(CASLA.Value__c))
                                c.SLAHours__c= Integer.valueOf(CASLA.Value__c);
                        }
                        
                    }   
                }
            }
            //OAVERSANO 22/03/2019 : AXA Assistance -- END
            
            
            //FM_16/05/2018 : GDPR --- START
            c.TECH_SLAHours__c = c.SLAHours__c;
           //FM_16/05/2018 : GDPR --- END
                   
            system.debug('##############'+c.SLAHours__c + c.SLATaskHours__c);
            if(((c.SLAHours__c) >0))//
            {
              //MOSCATELLI_M 09122015: EVO-24-----START
                //decimal totalHours = c.SLAHours__c + c.SLATaskHours__c + ((c.TotalNumHoursStatusPending__c==null)?0:c.TotalNumHoursStatusPending__c);                           
                //c.CaseDueDate__c =  BusinessHours.addGMT(bh,slaDate,(totalHours*60 * 60 * 1000L).longValue());
                
                if(c.StatusReopened_Date__c==null)
                {
                    decimal totalHours = c.SLAHours__c + ((c.TotalNumHoursStatusPending__c==null)?0:c.TotalNumHoursStatusPending__c) +((c.TotalNumHoursStatusDelegated__c==null)?0:c.TotalNumHoursStatusDelegated__c);
                    
                    //FM_14/05/2018 -- GDPR : START
                    //OAVERSANO 17/01/2019 : Gestione Reclami -- START
                    //if (GDPRCategories.contains(c.Category__c)){ se open lo stato
                    if (GDPRCategories.contains(c.Category__c)
                    	|| 
                    	devNamerecordTypeRecalculateAP01Set.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName()))){
                    	
                       	system.debug('riduzione SLAHours__c per Reclami o per categorie GDPR');
                       	
                    	if(!GDPRCategories.contains(c.Category__c))
                    	{
                    		if(c.Data_creazione_richiesta_DMR__c != null && c.Status == AP_Constants.caseStatusOpen)
	                    	{
	                    		if(c.Data_creazione_richiesta_DMR__c<System.now().date())
                                {
                                    Integer daysToRemove = c.Data_creazione_richiesta_DMR__c.daysBetween(System.now().date()); //differenza in ore solari
                                    Integer hoursToRemove = daysToRemove*24;
                                    c.SLAHours__c = c.SLAHours__c - hoursToRemove;
                                }
	            			 	if(c.SLAHours__c < 0){
	
	                            	c.Current_Color_vs_SLA__c  = 'ROSSO';
	
	                        	}else if(c.SLAHours__c >0 && c.SLAHours__c < SLAmin){
	
	                            	c.Current_Color_vs_SLA__c = 'GIALLO';
	                        	}
	
		                        system.debug('TOTAL HOURS IS REDUCED'+c.SLAHours__c);
	                    	}
	                    	totalHours = c.SLAHours__c;
	                    	EntitlementId = EntReclamo; 
                    	}
                    	else
                    	{          
						//OAVERSANO 17/01/2019 : Gestione Reclami -- END
	                        if(c.Tempo_trascorso_in_DPO_in_BH__c != null){
							
		                        c.SLAHours__c = c.SLAHours__c - c.Tempo_trascorso_in_DPO_in_BH__c;
								
		                        if(c.SLAHours__c < 0){
		
		                            c.Current_Color_vs_SLA__c  = 'ROSSO';
		
		                        }else if(c.SLAHours__c >0 && c.SLAHours__c < SLAmin){
		
		                            c.Current_Color_vs_SLA__c = 'GIALLO';
		                        }
		
		                        
		                        totalHours = totalHours - c.Tempo_trascorso_in_DPO_in_BH__c;
		                        system.debug('TOTAL HOURS IS REDUCED'+c.SLAHours__c);
		                    }
                    	

                    if(c.SLAHours__c <= SLAmax && c.SLAHours__c >= SLAmin){

                               
                                EntitlementId = EntGDPRId;

                            }else if(c.SLAHours__c < SLAmax2 && c.SLAHours__c >= SLAmin2){

                                EntitlementId = EntGDPRId2;
                                if(c.SLAHours__c < SLAmax2)
                                c.Current_Color_vs_SLA__c = 'GIALLO';

                            }else if(c.SLAHours__c < SLAmax3){

                                EntitlementId = EntGDPRId3;
                                c.Current_Color_vs_SLA__c = 'GIALLO';
                            }
                }
                }//OAVERSANO 17/01/2019 : Gestione Reclami
                     //FM_14/05/2018 -- GDPR : END
                     system.debug('bh Id on calculate target date '+bh);
                    c.CaseDueDate__c =  BusinessHours.addGMT(bh,slaDate,(totalHours*60 * 60 * 1000L).longValue());
                    system.debug('CaseDueDate__c'+c.CaseDueDate__c);
                }
                else
                {
                    decimal totalHours = c.SLAHours__c + ((c.TotalNumHoursStatusPendingFromReopen__c==null)?0:c.TotalNumHoursStatusPendingFromReopen__c) +((c.TotalNumHoursStatusDelegatedFromReopen__c==null)?0:c.TotalNumHoursStatusDelegatedFromReopen__c);
                    c.CaseDueDate__c =  BusinessHours.addGMT(bh,c.StatusReopened_Date__c,(totalHours*60 * 60 * 1000L).longValue());
                }
                 //MOSCATELLI_M 09122015: EVO-24-----END
                
              c.NextStatusDate__c = c.CaseDueDate__c;
              c.DueDate__c = date.newinstance(c.CaseDueDate__c.year(),c.CaseDueDate__c.month(), c.CaseDueDate__c.day());
                
              //MOSCATELLI_M 09122015: EVO-24-----START
              system.debug('@@EntitlementId : '+EntitlementId +'@@c.EntitlementId : '+c.EntitlementId);

               if(c.EntitlementId == null && EntitlementId!=null)
               {
                  system.debug('Entid : '+EntitlementId);
                    c.EntitlementId = EntitlementId;
               }
               //MOSCATELLI_M 09122015: EVO-24-----END
               
               //OAVERSANO 18/01/2019 : Gestione Reclami -- START
               if(devNamerecordTypeRecalculateAP01Set.contains(MapRecNameToDevelopername.get(MapCaseRecordType.get(c.RecordTypeId).getName())))
               {
               		ServiceUtilsClass.calculateAlertDT(c, bh);
               }
               //OAVERSANO 18/01/2019 : Gestione Reclami -- END
            }
            else
            {
              c.CaseDueDate__c = null;
              c.NextStatusDate__c = null;
              c.DueDate__c =null;
            }
        }        
        //system.debug('##caseList.size()'+caseList.size());
        system.debug('## End method calculateDueDate '+ UserInfo.getName());
    }
    //MOSCATELLI_M 17/11/2016:EVO 70 -- start
    //public static void calculateCaseStatusTotalTime(list<Case> caseList, map<Id,String> mapCaseIdOldStatus)
    public static void calculateCaseStatusTotalTime(list<Case> caseList, map<Id,String> mapCaseIdOldStatus, Id defaultHours)
    //MOSCATELLI_M 17/11/2016:EVO 70 -- end
    {
        system.debug('## Start method AP01CaseCalculateDueDate - calculateCaseStatusTotalTime'+ UserInfo.getName());
        
        //variables
        String oldStatus;
        Decimal numHours;
        Id bh;

        List<String> GDPRCategories = new List<String>();

        for(MPS_Code_Variables__c MPSCv: MPS_Code_Variables__c.getAll().values())
            {
                if((MPSCv.Name).contains('GDPR_Category'))
                    GDPRCategories.add(MPSCv.Value__c);
            }  
        
        //OAVERSANO 18/01/2018 : Gestione Reclami -- START
        Map<String,String> MapRecIdToDevelopername = new Map<String,String>();
        String[] types = new String[]{'Case'}; 
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types); 
        for (Schema.RecordTypeInfo ri: results[0].getRecordTypeInfos()) 
        { 
            MapRecIdToDevelopername.put(ri.getRecordTypeId(), ri.getDeveloperName());  
        }
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
        //OAVERSANO 18/01/2018 : Gestione Reclami -- END
        
        
        //Get the default business hours
        //BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];
        system.debug('##defaultHours'+defaultHours);
        
        for (Case c: caseList)
        {
            if(c.BusinessHoursId!=null)
            {
                bh = c.BusinessHoursId;
            }
            else
            {
                //MOSCATELLI_M 17/11/2016:EVO 70 -- start
                //bh = defaultHours.Id;
                bh = defaultHours;
                //MOSCATELLI_M 17/11/2016:EVO 70 -- end
            }            
            
            /*
            c.NextStatusDate__c = null;
            if(mapCaseSLA.containsKey(c.Category__c+'-'+c.SubCategory__c)){
              CaseSLA__c CaseSLA = mapCaseSLA.get(c.Category__c+'-'+c.SubCategory__c);
              if(c.Origin == AP_Constants.caseOriginEmail){
                if(c.Status == AP_Constants.caseStatusOpen && CaseSLA.EmailOpen__c <> null){
                  c.NextStatusDate__c = BusinessHours.addGMT(bh,system.now(),integer.valueOf(CaseSLA.EmailOpen__c)*60 * 60 * 1000L);
                }
                else if(c.Status == AP_Constants.caseStatusAssigned && CaseSLA.EmailAssigned__c<>null){
                  c.NextStatusDate__c = BusinessHours.addGMT(bh,system.now(),integer.valueOf(CaseSLA.EmailAssigned__c)*60 * 60 * 1000L);
                }
                else if(c.Status == AP_Constants.caseStatusClosed && CaseSLA.EmailClosed__c<>null){
                  c.NextStatusDate__c = BusinessHours.addGMT(bh,system.now(),integer.valueOf(CaseSLA.EmailClosed__c)*60 * 60 * 1000L);
                }
                
                if(mapCaseIdOldStatus.size() == 0 && CaseSLA.EmailTotalHours__c <> null){
                  c.CaseDueDate__c = BusinessHours.addGMT(bh,system.now(),integer.valueOf(CaseSLA.EmailTotalHours__c)*60 * 60 * 1000L);
                }
              }
              else if (c.Origin == AP_Constants.caseOriginPhone){
                if(c.Status == AP_Constants.caseStatusAssigned && CaseSLA.PhoneAssigned__c<>null){
                  c.NextStatusDate__c = BusinessHours.addGMT(bh,system.now(),integer.valueOf(CaseSLA.PhoneAssigned__c)*60 * 60 * 1000L);
                }
                else if(c.Status == AP_Constants.caseStatusClosed && CaseSLA.PhoneClosed__c<>null){
                  c.NextStatusDate__c = BusinessHours.addGMT(bh,system.now(),integer.valueOf(CaseSLA.PhoneClosed__c)*60 * 60 * 1000L);
                }
                
                if(mapCaseIdOldStatus.size() == 0 && CaseSLA.PhoneTotalHours__c <> null){
                  c.CaseDueDate__c = BusinessHours.addGMT(bh,system.now(),integer.valueOf(CaseSLA.PhoneTotalHours__c)*60 * 60 * 1000L);
                }
              }
            }
            */
            if(mapCaseIdOldStatus.size() > 0)
            {
              // num hours spent
              oldStatus = mapCaseIdOldStatus.get(c.Id);
              system.debug('## oldStatus: '+ oldStatus);
              if (c.TECH_LastModifiedDateStatus__c != null){
                  numHours = (decimal)((BusinessHours.diff(bh, c.TECH_LastModifiedDateStatus__c, system.Now())));
                  numHours = (decimal)(numHours/(1000*60*60));
                  system.debug('## numHours: '+ numHours);
                  if (oldStatus == AP_Constants.caseStatusOpen)
                  {
                      c.TotalNumHoursStatusOpen__c = (c.TotalNumHoursStatusOpen__c==null?0:c.TotalNumHoursStatusOpen__c) + numHours;
                    system.debug('c.TotalNumHoursStatusOpen__c:'+c.TotalNumHoursStatusOpen__c);
                  }
                  else if (oldStatus == AP_Constants.caseStatusReopened)
                  {
                      c.TotalNumHoursStatusReopened__c = (c.TotalNumHoursStatusReopened__c==null?0:c.TotalNumHoursStatusReopened__c) + numHours;
                  }
                  else if (oldStatus == AP_Constants.caseStatusAssigned)
                  {
                      c.TotalNumHoursStatusAssigned__c = (c.TotalNumHoursStatusAssigned__c==null?0:c.TotalNumHoursStatusAssigned__c) + numHours;
                  }
                  else if (oldStatus == AP_Constants.caseStatusAllTasksClosed)
                  {
                      c.TotalNumHoursStatusAllTasksClosed__c = (c.TotalNumHoursStatusAllTasksClosed__c==null?0:c.TotalNumHoursStatusAllTasksClosed__c) + numHours;
                  }
                  else if (oldStatus == AP_Constants.caseStatusDelegated)
                  {
                      c.TotalNumHoursStatusDelegated__c = (c.TotalNumHoursStatusDelegated__c==null?0:c.TotalNumHoursStatusDelegated__c) + numHours;
                        c.TotalNumHoursStatusDelegatedFromReopen__c = (c.TotalNumHoursStatusDelegatedFromReopen__c==null?0:c.TotalNumHoursStatusDelegatedFromReopen__c) + numHours;//MOSCATELLI_M 09122015: EVO-24
                  }
                  else if (oldStatus == AP_Constants.caseStatusCancelled)
                  {
                      c.TotalNumHoursStatusCancelled__c = (c.TotalNumHoursStatusCancelled__c==null?0:c.TotalNumHoursStatusCancelled__c) + numHours;
                  }
                  else if (oldStatus == AP_Constants.caseStatusClosed)
                  {
                      c.TotalNumHoursStatusClosed__c = (c.TotalNumHoursStatusClosed__c==null?0:c.TotalNumHoursStatusClosed__c) + numHours;
                  }   
                  else if (oldStatus == AP_Constants.caseStatusPending)
                  {
                      c.TotalNumHoursStatusPending__c = (c.TotalNumHoursStatusPending__c==null?0:c.TotalNumHoursStatusPending__c) + numHours;
                      //MOSCATELLI_M 09122015: EVO-24-----START
                      /*
                        if(c.NextStatusDate__c <> null){
                        decimal totalHours = c.SLAHours__c + c.SLATaskHours__c + ((c.TotalNumHoursStatusPending__c==null)?0:c.TotalNumHoursStatusPending__c);
                        c.CaseDueDate__c =  BusinessHours.addGMT(bh,c.createddate,(totalHours*60 * 60 * 1000L).longValue());
                        c.NextStatusDate__c = c.CaseDueDate__c;
                        c.DueDate__c = date.newinstance(c.CaseDueDate__c.year(),c.CaseDueDate__c.month(), c.CaseDueDate__c.day());
                      }
            */
                        c.TotalNumHoursStatusPendingFromReopen__c = (c.TotalNumHoursStatusPendingFromReopen__c==null?0:c.TotalNumHoursStatusPendingFromReopen__c) + numHours;
                       //MOSCATELLI_M 09122015: EVO-24-----END                      
                  }             
              }
                //MOSCATELLI_M 09122015: EVO-24-----START
                //OAVERSANO 18/01/2019 : Gestione Reclami -- START
                //if(c.NextStatusDate__c <> null && !GDPRCategories.contains(c.Category__c))
                if(c.NextStatusDate__c <> null && !GDPRCategories.contains(c.Category__c) && !devNamerecordTypeRecalculateAP01Set.contains(MapRecIdToDevelopername.get(c.RecordTypeId)))
                //OAVERSANO 18/01/2019 : Gestione Reclami -- END
                {                                               
                    if(c.StatusReopened_Date__c==null)
                    {
                        decimal totalHours = ((c.SLAHours__c==null)?0:c.SLAHours__c) + ((c.TotalNumHoursStatusPending__c==null)?0:c.TotalNumHoursStatusPending__c) +((c.TotalNumHoursStatusDelegated__c==null)?0:c.TotalNumHoursStatusDelegated__c);
                        c.CaseDueDate__c =  BusinessHours.addGMT(bh,c.createddate,(totalHours*60 * 60 * 1000L).longValue());
                        system.debug('#totalHours: '+totalHours);
                    }                            
                    else
                    {
                        decimal totalHours = ((c.SLAHours__c==null)?0:c.SLAHours__c) + ((c.TotalNumHoursStatusPendingFromReopen__c==null)?0:c.TotalNumHoursStatusPendingFromReopen__c) +((c.TotalNumHoursStatusDelegatedFromReopen__c==null)?0:c.TotalNumHoursStatusDelegatedFromReopen__c);
                        c.CaseDueDate__c =  BusinessHours.addGMT(bh,c.StatusReopened_Date__c,(totalHours*60 * 60 * 1000L).longValue());
                        system.debug('#totalHours: '+totalHours);
                    }
                    c.NextStatusDate__c = c.CaseDueDate__c;
                    
                    c.DueDate__c = date.newinstance(c.CaseDueDate__c.year(),c.CaseDueDate__c.month(), c.CaseDueDate__c.day());                    
                }            
                 //MOSCATELLI_M 09122015: EVO-24-----END
            }  
            system.debug('## TECH_LastModifiedDateStatus__c: '+ system.Now());
            c.TECH_LastModifiedDateStatus__c = system.Now();    
            //calculate total turnaround time
            //c.Req_TTT__c = 0;
            //c.Req_TTT__c =  (c.TotalNumHoursStatus1__c==null?0:c.TotalNumHoursStatus1__c) + (c.TotalNumHoursStatus13__c==null?0:c.TotalNumHoursStatus13__c) + (c.TotalNumHoursStatus14__c==null?0:c.TotalNumHoursStatus14__c);
        }//end for loop case list*/
    }
}
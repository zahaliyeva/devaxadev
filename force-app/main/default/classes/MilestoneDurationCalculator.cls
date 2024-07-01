/*------------------------------------------------------------------------------------------
Author:        Orlando Aversano
Company:       Deloitte
Class:         MilestoneDurationCalculator
Description:   Apex class used to calculate the duration of the milestones.

History

06/08/2018     Created 
-------------------------------------------------------------------------------------------*/
global class MilestoneDurationCalculator implements Support.MilestoneTriggerTimeCalculator {   
    
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        
        Integer SLAToReturn = 0;
        Case c = [SELECT Id, RecordType.Name, Category__c, SubCategory__c, Origin,
              Customer_Service_Model__c, Distribution_Network__c, RecordType.DeveloperName
              FROM Case WHERE Id=:caseId];
        MilestoneType mt = [SELECT Name FROM MilestoneType WHERE Id=:milestoneTypeId];      
        List<Configurazione_SLA_Case__c> SLAConfList = [SELECT Id, Case_Origin__c, Case_Record_Type__c, Category__c, Sub_Category__c,
                                Distribution_Network__c, Customer_Service_Type__c, SLA__c,
                                (SELECT Id, User_Role__c, SLA__c 
                                FROM Configurazioni_SLA_Case_HD2__r)
                                FROM Configurazione_SLA_Case__c
                                WHERE Rule_Active__c = true
                                AND Case_Record_Type__c =: c.RecordType.Name
                                AND Category__c =: c.Category__c
                                AND Sub_Category__c =: c.SubCategory__c];
                                
        //OAVERSANO 16/10/2018 : Caring Angel -- START
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
    
        Configurazione_SLA_Case__c SLAConfFound;
        system.debug('SLAConfList: '+SLAConfList);
        if(!SLAConfList.isEmpty())
        {
          for(Configurazione_SLA_Case__c SLAConf: SLAConfList)
          {
            if(SLAConf.Case_Origin__c == c.Origin 
              && 
              SLAConf.Distribution_Network__c == c.Distribution_Network__c 
              && 
              SLAConf.Customer_Service_Type__c == c.Customer_Service_Model__c)
              {
                SLAConfFound = new Configurazione_SLA_Case__c();
                SLAConfFound = SLAConf;
              }
              else if(SLAConf.Case_Origin__c == c.Origin 
              && 
              SLAConf.Distribution_Network__c == c.Distribution_Network__c 
              && 
              SLAConf.Customer_Service_Type__c == 'All')
              {
                SLAConfFound = new Configurazione_SLA_Case__c();
                SLAConfFound = SLAConf;
              }
              else if(SLAConf.Case_Origin__c == c.Origin 
              && 
              SLAConf.Distribution_Network__c == 'All' 
              && 
              SLAConf.Customer_Service_Type__c == c.Customer_Service_Model__c)
              {
                SLAConfFound = new Configurazione_SLA_Case__c();
                SLAConfFound = SLAConf;
              }
              else if(SLAConf.Case_Origin__c == 'All'
              && 
              SLAConf.Distribution_Network__c == c.Distribution_Network__c
              && 
              SLAConf.Customer_Service_Type__c == c.Customer_Service_Model__c)
              {
                SLAConfFound = new Configurazione_SLA_Case__c();
                SLAConfFound = SLAConf;
              }
              else if(SLAConf.Case_Origin__c == 'All'
              && 
              SLAConf.Distribution_Network__c == 'All'
              && 
              SLAConf.Customer_Service_Type__c == c.Customer_Service_Model__c)
              {
                SLAConfFound = new Configurazione_SLA_Case__c();
                SLAConfFound = SLAConf;
              }
              else if(SLAConf.Case_Origin__c == 'All'
              && 
              SLAConf.Distribution_Network__c == c.Distribution_Network__c
              && 
              SLAConf.Customer_Service_Type__c == 'All')
              {
                SLAConfFound = new Configurazione_SLA_Case__c();
                SLAConfFound = SLAConf;
              }
              else if(SLAConf.Case_Origin__c == c.Origin
              && 
              SLAConf.Distribution_Network__c == 'All'
              && 
              SLAConf.Customer_Service_Type__c == 'All')
              {
                SLAConfFound = new Configurazione_SLA_Case__c();
                SLAConfFound = SLAConf;
              }
              else if(SLAConf.Case_Origin__c == 'All'
              && 
              SLAConf.Distribution_Network__c == 'All'
              && 
              SLAConf.Customer_Service_Type__c == 'All')
              {
                SLAConfFound = new Configurazione_SLA_Case__c();
                SLAConfFound = SLAConf;
              }
          }
        }
        system.debug('SLAConfFound: '+SLAConfFound);
        if (mt.Name != null && mt.Name.contains('HD1') && SLAConfFound!=null)
        {
          SLAToReturn = Integer.valueOf((SLAConfFound.SLA__c))*60;
        } 
        else if(mt.Name != null && mt.Name.contains('HD2') && SLAConfFound!=null)
        {
          if(!SLAConfFound.Configurazioni_SLA_Case_HD2__r.isEmpty())
          {
            for(Configurazione_SLA_Case_HD2__c SLAHD2 : SLAConfFound.Configurazioni_SLA_Case_HD2__r)
            {
              if(mt.Name.contains(SLAHD2.User_Role__c) && mt.Name.endsWith(SLAHD2.User_Role__c))
              {
                  system.debug('HD2 found');
                SLAToReturn = Integer.valueOf((SLAHD2.SLA__c))*60;
              }
            }
          }
        }
        if(SLAToReturn==0)
        {
        	
        	if(RecordTypeSet.contains(c.RecordType.DeveloperName))
            {
           		MPS_Code_Variables__c MDASLA = MPS_Code_Variables__c.getValues('ModelloDiAssistenzaSLADefault');
          		system.debug('MDASLA: '+MDASLA);
          		if(MDASLA!= null)
      			{
          			system.debug('SLAToReturnMDA :'+SLAToReturn );
            		if(String.isNotBlank(MDASLA.Value__c))
            		{
              			SLAToReturn = Integer.valueOf((MDASLA.Value__c))*60;
             			system.debug('SLAToReturnMDA :'+SLAToReturn );
            		}
      			}
            }
            else if(RecordTypeSetCA.contains(c.RecordType.DeveloperName))
            {
                MPS_Code_Variables__c CASLA = MPS_Code_Variables__c.getValues('CaringAngelSLADefault');
                system.debug('CASLA: '+CASLA);
                if(CASLA!= null)
                {
                	system.debug('SLAToReturnCA :'+SLAToReturn );
                    if(String.isNotBlank(CASLA.Value__c))
                    {
                        SLAToReturn = Integer.valueOf((CASLA.Value__c))*60;
             			system.debug('SLAToReturnCA :'+SLAToReturn );
                    }
                }   
            }
            //OAVERSANO 22/03/2019 : AXA Assistance -- START
            else if(RecordTypeNameSetSinistri.contains(c.RecordType.DeveloperName))
            {
                MPS_Code_Variables__c SinistriSLA = MPS_Code_Variables__c.getValues('SinistriSLADefault');
                system.debug('SinistriSLA: '+SinistriSLA);
                if(SinistriSLA!= null)
                {
                	system.debug('SLAToReturnSinistri:'+SLAToReturn );
                    if(String.isNotBlank(SinistriSLA.Value__c))
                    {
                        SLAToReturn = Integer.valueOf((SinistriSLA.Value__c))*60;
             			system.debug('SLAToReturnCA :'+SLAToReturn );
                    }
                }   
            }
         	//OAVERSANO 22/03/2019 : AXA Assistance -- END   
        }
        system.debug('SLAToReturn END:'+SLAToReturn );
        return SLAToReturn;
    }
    
}
public with sharing class MobilityWidgetsHomepage extends MobilityAbstract {
    public class MobilityCounters extends MobilityResponse{
        @AuraEnabled public MobilityCountsCampaign campaign;
        @AuraEnabled public MobilityCountsLead lead;
        @AuraEnabled public MobilityCountsFeedback feedback;
        @AuraEnabled public MobilityCountsAgenda event;
        @AuraEnabled public MobilityCountsTask task;
        @AuraEnabled public MobilityCountsSupport support;
    } 
    
    public class MobilityCountsCampaign extends MobilityResponse{
        @AuraEnabled public Integer clientsWithPriority = 0;
        @AuraEnabled public Integer campaignToWork = 0;
    }

	public class MobilityCountsLead extends MobilityResponse{
        @AuraEnabled public Integer leadsToWork = 0;
        //web
        @AuraEnabled public Integer leadsToWorkWebPriority = 0; 
        //salute
        @AuraEnabled public Integer leadsToWorkHealth = 0; 
    }

    public class MobilityCountsFeedback extends MobilityResponse{
        @AuraEnabled public Integer feedbacks_CTL = 0;
        @AuraEnabled public Integer richieste_PreVendita = 0;
        @AuraEnabled public Integer richieste_PostVendita = 0;
    }

    public class MobilityCountsAgenda extends MobilityResponse{
        @AuraEnabled public Integer events = 0;
    }

    public class MobilityCountsTask extends MobilityResponse{
        @AuraEnabled public Integer tasks = 0;
    }

    public class MobilityCountsSupport extends MobilityResponse{
        @AuraEnabled public Integer supports = 0;
    }

    ///IDCRM092 - Daniel Torchia START
    public class MobilityNDGData extends MobilityResponse{
        @AuraEnabled public String esito;
        @AuraEnabled public String descrizioneEsito;
        @AuraEnabled public String nomeSurvey;
        @AuraEnabled public String dataFeedback;
        @AuraEnabled public Decimal npsScore;
        @AuraEnabled public String coloreTesto;
        @AuraEnabled public String textAttribute;
    }
    //IDCRM092 - Daniel Torchia STOP
    
    @AuraEnabled
    public static MobilityCountsCampaign campaignCounters(){
        DebugStart('MobilityWidgetsHomepage', 'campaignCounters');

        MobilityCountsCampaign response = new MobilityCountsCampaign();
		list<CampaignMember> campaignToWorkFinal = new List<campaignMember>();
        list<campaignMember> clientsWithPriorityFinal = new List<campaignMember>();

        try{
    		User userCurrent = MobilityUserController.getCurrentUser();
            if(!userCurrent.Profile.Name.equalsIgnoreCase('NFE - AAI - Vendite Solo Assistenza')){
			List<Campaign> cList = [Select id from campaign where status = 'On-going' ]; // NOPMD  Fix CRUD violation
            List<campaignMember> clientsWithPriority = [ // NOPMD  Fix CRUD violation
                SELECT id,  Agency_Code__c
                FROM CampaignMember 
                WHERE Cliente_prioritario__c = true
                //AND Status IN ('Da contattare', 'Da ricontattare')
                AND Campaignid in :cList
                //AND Agency_Code__c = :userCurrent.Agency_Code__c
                AND Partner_Role_Visibility__c = true 
            ];

            for(CampaignMember c : clientsWithPriority){
                //if(c.Agency_Code__c == userCurrent.Agency_Code__c){
                    clientsWithPriorityFinal.add(c);
                //}
            }  
            
            response.campaignToWork = (Integer) cList.size();
            response.clientsWithPriority = (Integer) clientsWithPriorityFinal.size();

            response.isSuccess = true;
            }
            else{
                response.campaignToWork = 0;
                response.clientsWithPriority = 0;
    
                response.isSuccess = true;
            }
        }catch(Exception ex){
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }

    @AuraEnabled
    public static MobilityCountsLead leadCounters(){
        DebugStart('MobilityWidgetsHomepage', 'MobilityCountsLead');

        MobilityCountsLead response = new MobilityCountsLead();

        try{
            User userCurrent = MobilityUserController.getCurrentUser();
            if(!userCurrent.Profile.Name.equalsIgnoreCase('NFE - AAI - Vendite Solo Assistenza')){
                AggregateResult data = [ // NOPMD  Fix CRUD violation
                    SELECT Count(Id) CountData 
                    FROM Lead 
                    WHERE RecordType.DeveloperName IN('Lead_AXA_Assicurazioni', 'eCommerce', 'Lead_MPS', 'Outsource') 
                    AND Status IN('Appointment', 'Call again', 'To be Processed') 
                    AND IsConverted = false 
                ];

            response.leadsToWork = (Integer) data.get('CountData');
            
                data = [ // NOPMD  Fix CRUD violation
                    SELECT Count(Id) CountData 
                    FROM Lead 
                    WHERE RecordType.DeveloperName IN('Lead_AXA_Assicurazioni', 'eCommerce', 'Lead_MPS', 'Outsource') 
                    AND Status IN('Appointment', 'Call again', 'To be Processed') 
                    AND LeadSource = 'Web'
                    AND IsConverted = false 
                ];

                response.leadsToWorkWebPriority = (Integer) data.get('CountData');

                List<ListViewCustomFilters__mdt> metadataList = [SELECT Field__c, Value__c FROM ListViewCustomFilters__mdt WHERE FilterName__c = 'Health' and Field__c = 'Prodotto__c' ]; // NOPMD  Fix CRUD violation
                system.debug('Commento');
                Set<String> ProdottoList = new Set<String>();
                for(ListViewCustomFilters__mdt temp : metadataList){
                   ProdottoList.add(temp.Value__c);
                }
                data = [ // NOPMD  Fix CRUD violation
                    SELECT Count(Id) CountData 
                    FROM Lead 
                    WHERE RecordType.DeveloperName IN('Lead_AXA_Assicurazioni', 'eCommerce', 'Lead_MPS', 'Outsource') 
                    AND Status IN('Appointment', 'Call again', 'To be Processed') 
                    AND LeadSource = 'Web'
                    AND Prodotto__c in:ProdottoList
                    AND IsConverted = false 
                ];
                response.leadsToWorkHealth = (Integer) data.get('CountData');
            }
            else{
                response.leadsToWork = 0;
            }
            response.isSuccess = true;
        }catch(Exception ex){
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }

    @AuraEnabled
    public static MobilityCountsFeedback feedbackCounters(){
        DebugStart('MobilityWidgetsHomepage', 'MobilityCountsFeedback');

        MobilityCountsFeedback response = new MobilityCountsFeedback();

        try{
            AggregateResult data = [ // NOPMD  Fix CRUD violation
                SELECT Count(Id) countData
                FROM Case
                WHERE RecordType.DeveloperName = 'Close_the_loop'
                AND (Owner.Profile.Name like '%AAI - Vendite%' OR Owner.name like 'Coda Agenzia Case%')
                AND IsClosed = false 
            ];

            response.feedbacks_CTL = (Integer) data.get('CountData');

            data = [ // NOPMD  Fix CRUD violation
                SELECT Count(Id) countData
                FROM Case
                WHERE RecordType.DeveloperName = 'Axa_Assicurazioni'
                AND IsClosed = false
                AND (Owner.Profile.Name like '%AAI - Vendite%' OR Owner.name like 'Coda Agenzia Case%')
                AND (Category__c = 'Richiesta codice sconto' 
                    OR
                    Category__c = 'Preventivi' 
                    OR
                    SubCategory__c = 'Preventivi') 
            ];
            response.richieste_PreVendita = (Integer) data.get('CountData');

            // aggiornata 14/10/2021 categoria!=preventivi
            data = [ // NOPMD  Fix CRUD violation
                SELECT Count(Id) countData
                FROM Case
                WHERE RecordType.DeveloperName = 'Axa_Assicurazioni'
                AND IsClosed = false
                AND ( Category__c != 'Richiesta codice sconto' 
                AND   Category__c != 'Preventivi' ) 
                AND   SubCategory__c != 'Preventivi'
                AND (Owner.Profile.Name like '%AAI - Vendite%' OR Owner.name like 'Coda Agenzia Case%') 

            ];
            response.richieste_PostVendita = (Integer) data.get('CountData');
            response.isSuccess = true;
        }catch(Exception ex){
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }

    @AuraEnabled
    public static MobilityCountsAgenda eventCounters(){
        DebugStart('MobilityWidgetsHomepage', 'eventCounters');

        MobilityCountsAgenda response = new MobilityCountsAgenda();

        try{
            Datetime dateStart = Datetime.now();
		
            AggregateResult data = [ // NOPMD  Fix CRUD violation
                SELECT Count(id) CountData
                FROM Event
                WHERE (
                    StartDateTime >= :dateStart OR EndDateTime >= :dateStart
                ) 
            ];

            response.events = (Integer) data.get('CountData');
            response.isSuccess = true;
        }catch(Exception ex){
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }

    @AuraEnabled
    public static MobilityCountsTask taskCounters(){
        DebugStart('MobilityWidgetsHomepage', 'taskCounters');

        MobilityCountsTask response = new MobilityCountsTask();

        try{
            Date dateStart = Date.today();
		
            AggregateResult data = [ // NOPMD  Fix CRUD violation
                SELECT Count(Id) CountData
                FROM Task
                WHERE IsClosed = false
                AND ActivityDate >= :dateStart 
            ];

            response.tasks = (Integer) data.get('CountData');
            response.isSuccess = true;
        }catch(Exception ex){
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }

    @AuraEnabled
    public static MobilityCountsSupport supportCounters(){
        DebugStart('MobilityWidgetsHomepage', 'supportCounters');

        MobilityCountsSupport response = new MobilityCountsSupport();

        try{
            User currentUser = MobilityUserController.getCurrentUser();
		
            AggregateResult data = [ // NOPMD  Fix CRUD violation
                SELECT Count(Id) CountData 
                FROM Case 
                WHERE RecordType.DeveloperName in ('Assistenza_Agenti','AXA_Caring_Salute')
                AND Status IN ('Soluzione Proposta','Attesa info Agente') 
            ];

            response.supports = (Integer) data.get('CountData');
            response.isSuccess = true;
        }catch(Exception ex){
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }

    @AuraEnabled
    public static MobilityCounters getCounters(List<String> counters){
        DebugStart('MobilityWidgetsHomepage', 'getCounters');

        MobilityCounters response = new MobilityCounters();

        try{

            for(String counter : counters){
                if(counter == 'campaign'){
                    
                    response.campaign = MobilityWidgetsHomepage.campaignCounters();
                }else if(counter == 'lead'){
                    response.lead = MobilityWidgetsHomepage.leadCounters();
                }else if(counter == 'feedback'){
                    response.feedback = MobilityWidgetsHomepage.feedbackCounters();
                }else if(counter == 'event'){
                    response.event = MobilityWidgetsHomepage.eventCounters();
                }else if(counter == 'task'){
                    response.task = MobilityWidgetsHomepage.taskCounters();
                }else if(counter == 'support'){
                    response.support = MobilityWidgetsHomepage.supportCounters();
                }
            }
    
            response.isSuccess = true;
        }catch(Exception ex){
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }

    //IDCRM092 - Daniel Torchia START
    @AuraEnabled
    public static MobilityNDGData getNDGData(String ndg){
        DebugStart('MobilityWidgetsHomepage', 'getNDGData');
        system.debug('### MobilityWidgetsHomePage.getNDGData');
        MobilityNDGData response=new MobilityNDGData();
        try {
            if(isNDGPresent(ndg)){
                system.debug('### MobilityWidgetsHomePage.getNDGData isNDGPresent');
                Account accwithndg = [ // NOPMD  Fix CRUD violation
                SELECT Id, NDG__c ,Net_Promoter_Score_NPS__c ,NPS__c
                FROM Account
                WHERE NDG__c = :ndg
            ];
            system.debug('### MobilityWidgetsHomePage.getNDGData accwithndg: '+accwithndg);
           Feedback__c feedback= [ 
                SELECT Id, NPS__c,Survey_Origin__c, Account__c, createddate  FROM Feedback__c WHERE Account__c =: accwithndg.id and NPS__c=:accwithndg.NPS__c order by createddate desc limit 1
            ]; 
            system.debug('### MobilityWidgetsHomePage.getNDGData feedback: '+feedback);   
             if(accwithndg.NPS__c !=null){
                    
             response.npsScore =accwithndg.NPS__c ;
             response.nomeSurvey= feedback.Survey_Origin__c;
             response.dataFeedback = formatDate(feedback.createddate); 
               
                       
             if(Integer.valueOf(accwithndg.NPS__c)>=9)
                    {
                       response.coloreTesto ='green' ;
                       response.textAttribute ='PROMOTORE';
                    }
             else if(Integer.valueOf(accwithndg.NPS__c)>=7 && Integer.valueOf(accwithndg.NPS__c)<=8)
                    {
                       response.coloreTesto = 'orange';
                       response.textAttribute='PASSIVO'; 
                    }
             else
                    {
                       response.coloreTesto = 'red';
                       response.textAttribute= 'DETRATTORE' ;
                    }
                 }    
            }
            response.isSuccess = true;
            response.esito = '0';
            response.descrizioneEsito = 'Operazione completata con successo'; 
        }catch(Exception ex){
            response.errorMessage=ex.getMessage();
            system.debug('### MobilityWidgetsHomePage.getNDGData err: '+ex.getMessage());
        }
        Debug('response', response);
        DebugEnd();
        system.debug('### MobilityWidgetsHomePage.getNDGData response: '+response);
        return response;
    }

    @AuraEnabled
    public static boolean isNDGPresent(String ndg){
        system.debug('### MobilityWidgetsHomePage.isNDGPresent');
        Id accid=null;
        try {
            Account accwithndg = [ // NOPMD  Fix CRUD violation
                SELECT Id, NDG__c 
                FROM Account
                WHERE NDG__c = :ndg
            ];
            accid=accwithndg.id;
            system.debug('### MobilityWidgetsHomePage.isNDGPresent accwithndg: '+accwithndg);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return accid!=null?true:false;
    }


    @AuraEnabled
    public static String formatDate(DateTime inputDate) {
        return inputDate.format('dd/MM/yyyy');
    }
    //IDCRM092 - Daniel Torchia STOP
}
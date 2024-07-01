@RestResource(urlMapping='/WS_REST_Lead_eCommerce')
global without sharing class WS_REST_Lead_eCommerce{
    public class WSRestECommerceException extends Exception {}
    static WS_REST_eCommerce_Wrapper.Response response;
    static IE_Integration_Record__c myIR;
    static List<Lead> richiediAppuntamentoLeads =new List<Lead>();
    static List<Lead> queueProcessLeads = new List<Lead>();
    static List<String> defaultQueues = new List<String>();
    static List<Boolean> isAssignedList= new List<Boolean>();
    static List<Lead> queueAgencyLeads = new List<Lead>();
    static List<Lead> noovleRankingLeads = new List<Lead>();

    @HttpPut
    global static WS_REST_eCommerce_Wrapper.Response updateObject(){
        
        //initialisation
        response = new WS_REST_eCommerce_Wrapper.Response();
        WS_REST_eCommerce_Wrapper request = new WS_REST_eCommerce_Wrapper();
        Boolean notError = true;

        String jsonString = System.RestContext.request.requestBody.toString();        

        myIR = new IE_Integration_Record__c();
        myIR = LeadManagementECommerce.populateIEIntegrationRecordRequest(jsonString);

        try{
            request = (WS_REST_eCommerce_Wrapper)JSON.deserialize(jsonString, WS_REST_eCommerce_Wrapper.class);
        } catch(Exception ex){
            System.debug('Error while trying to deserialize the request: ' + ex.getMessage());
            response=createErrorResponse('400','Bad Request - '+ex.getMessage(),true);
            return response;            
            notError = false;
        }

        //bad request check & lead deduplication
        if(notError){            
            system.debug('this is my request'+request);
            List<WS_REST_eCommerce_Wrapper> requestList = new List<WS_REST_eCommerce_Wrapper>();
            requestList.add(request);
            Boolean isBadRequest = false;
            for(WS_REST_eCommerce_Wrapper req : requestList){
                if(!isBadRequest){
                    isBadRequest = LeadManagementECommerce.checkBadRequest(req);
                }
            }

            if(isBadRequest){
                response=createErrorResponse('400','Bad Request - Some mandatory data are missing or some input are wrong',true);
                return response;                
            }

            WS_REST_eCommerce_Wrapper.DeduplicateObject ret = new WS_REST_eCommerce_Wrapper.DeduplicateObject();
            try{                
                if(Test.isRunningTest() && request.LastName == 'ApexTest01'){
                    throw new WSRestECommerceException('Test 500 error');
                }
                ret = LeadManagementECommerce.deduplicateLead(requestList);
                system.debug('ret from request list '+ret);
            } catch(Exception ex){
                System.debug('Error while trying to deduplicate lead: ' + ex.getMessage());
                response=createErrorResponse('500','Internal Server Error - '+ex.getMessage()+' '+ ex.getCause()+' '+ ex.getLineNumber(),false);
                return response;
                notError = false;
            }

            //queue assignment & response

            if(notError){
                response = ret.response;
                ownerToQueueAssignmentManagement(ret);
            }

            myIR.ResponseBody__c = LeadManagementECommerce.createJsonResponse(response.UserId, response.LeadId, response.StatusCode, response.StatusMessage, response.Timestamp);
            myIR.Status__c = response.StatusMessage;
        }

        try{
            if(Test.isRunningTest() && request.FirstName == 'ApexTest01'){
                throw new WSRestECommerceException('Test insert error');
            }
            Database.insert(myIR, false);
        } catch(Exception ex){      
            System.debug('Error while trying to insert integration Record: ' + ex.getMessage());
            response=createErrorResponse('500','Internal Server Error - '+ex.getMessage(),false);
        }
        return response;
    }

    private static void ownerToQueueAssignmentManagement(WS_REST_eCommerce_Wrapper.DeduplicateObject ret){  
        //retrieve custom setting containing logic for the queue assignment
        List<QueueAssignmentLogicParameters__c> settings=QueueAssignmentLogicParameters__c.getall().values();
        System.debug(' ===> ret.leads: '+ret.leads);
        //for each lead: if step and product are contained in the custom setting, execute new logic, else old       
        for(Lead l : ret.leads){    
            QueueAssignmentLogicParameters__c setting=getQueueAssignmentLogicParameters(l.Dettaglio__c, l.Landing_Page__c, settings);            
            System.debug(' ===> step: '+l.Dettaglio__c);
            System.debug(' ===> prodotto: '+l.Landing_Page__c);
            System.debug(' ===> è cliente: '+l.Gi_cliente_eCommerce__c);
            System.debug(' ===> codice agente: '+l.Agency_code__c);
            if(setting!=null){
                ownerToQueueAssignment(setting,l);
            }
            else{
                System.debug('Custom setting not found,proceeding with old logic.');
                ownerToQueueAssignmentOld(l);
            }
        }
        if(!richiediAppuntamentoLeads.isEmpty()){
            LeadManagementECommerce.checkAgentSiteAgencyCampaign(richiediAppuntamentoLeads);    
        }
        if(!queueProcessLeads.isEmpty()){
            LeadManagementECommerce.assignLeadtoProcessQueue(queueProcessLeads,defaultQueues);
        }
        if(!queueAgencyLeads.isEmpty()){
            LeadManagementECommerce.assignLeadtoAgencyQueue(queueAgencyLeads,isAssignedList);
        }
        if(!noovleRankingLeads.isEmpty()){
            LeadManagementECommerce.checkAgentSiteAgencyCampaign(noovleRankingLeads);
        }
    }

    public static QueueAssignmentLogicParameters__c getQueueAssignmentLogicParameters(String dettaglio, String landingPage, List<QueueAssignmentLogicParameters__c> settings){
        for (QueueAssignmentLogicParameters__c setting : settings){
            if (setting.Dettaglio__c!=null && setting.Dettaglio__c.equalsIgnoreCase(dettaglio) &&
                setting.LandingPage__c!=null && setting.LandingPage__c.equalsIgnoreCase(landingPage)){
                return setting;
            }           
        }
        return null;
    }

    private static void ownerToQueueAssignment(QueueAssignmentLogicParameters__c setting,Lead l){
        String codaDefault='';
        if(setting.codaDefault__c!=null) codaDefault=setting.codaDefault__c;
        if(l.Gi_cliente_eCommerce__c || (!l.Gi_cliente_eCommerce__c && l.Gi_cliente_AXA__c)){            
            fromActionToQueueList(l,setting.ClienteAction__c, codaDefault);
        }
        /*else if(setting.MCEmailClickAction__c!=null && l.MarketingCloudEmailClick__c){
            fromActionToQueueList(l,setting.MCEmailClickAction__c, '');
        }*/
        else{
            fromActionToQueueList(l,setting.NotClienteAction__c, codaDefault);
        }
    }
    
    private static void fromActionToQueueList(Lead l, String queueTypeAction, String defaultQueue){
        System.debug(' ===> coda: '+queueTypeAction);
        switch on queueTypeAction{
            when 'AG di appartenenza'{
                queueAgencyLeads.add(l);
                isAssignedList.add(false);
            }
            when 'AG assegnata'{
                queueAgencyLeads.add(l);
                isAssignedList.add(true);
            }
            when 'AG scelta, riassegna'{
                richiediAppuntamentoLeads.add(l);
            }
            when 'AG Noovle, riassegna'{
                noovleRankingLeads.add(l);
            }
            when 'Coda default'{
                defaultQueues.add(defaultQueue);
                queueProcessLeads.add(l);
            }
            when else{
                throw new WSRestECommerceException('Il valore nel custom setting non corrisponde a una coda');
            }
        }
    }
    
    private static void ownerToQueueAssignmentOld(Lead l){
        switch on l.Dettaglio__c.toLowerCase(){
            when 'visualizza quotazione'{
                System.debug(' ===> Step Visualizza Quotazione');
                queueProcessLeads.add(l);
            }
            when 'salva quotazione'{ //entrerà in gioco con prodotto casa
                System.debug(' ===> Step Salva Quotazione');
                queueProcessLeads.add(l);
            }
            when 'richiedi appuntamento'{
                System.debug(' ===> Step Richiedi Appuntamento');
                richiediAppuntamentoLeads.add(l);
            }
            when 'acquista'{
                System.debug(' ===> Step Acquista');
                queueProcessLeads.add(l);
            }
            when 'salva preventivo'{
                System.debug(' ===> Step Salva Preventivo');
                if(l.Gi_cliente_eCommerce__c){
                    if(l.Agency_code__c != null || l.Agency_code__c != ''){
                        queueAgencyLeads.add(l);
                    }
                } else {
                    queueProcessLeads.add(l);
                }
            }
            when 'inizia pagamento'{
                System.debug(' ===> Step Inizia Pagamento');
                queueProcessLeads.add(l);
            }
            when 'ko pagamento'{
                System.debug(' ===> Step KO Pagamento');
                queueProcessLeads.add(l);
            }
            when 'ko finale banca'{
                System.debug(' ===> Step KO Finale Banca');
                if(l.Agency_code__c != null || l.Agency_code__c != ''){
                    queueAgencyLeads.add(l);
                }
            }
            when 'ok pagamento'{
                System.debug(' ===> Step OK Pagamento');
                if(l.Agency_code__c != null || l.Agency_code__c != ''){
                    queueAgencyLeads.add(l);
                }
            }
            when else{
                System.debug(' ===> ' + l.Dettaglio__c);
                System.debug(' ===> Lead perso con Id: ' + l.Id);
            }
        }
    }

    private static WS_REST_eCommerce_Wrapper.Response createErrorResponse(String status, String message, Boolean updateIR){
        response.UserId = '';
        response.LeadId = '';
        response.StatusCode = status;
        response.StatusMessage = message;
        response.Timestamp = System.now();
        if(updateIR){
            myIR.ResponseBody__c = LeadManagementECommerce.createJsonResponse(response.UserId, response.LeadId, response.StatusCode, response.StatusMessage, response.Timestamp);
            myIR.Status__c = response.StatusMessage;
        }
        return response;
    }
}
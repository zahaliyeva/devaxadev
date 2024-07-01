/**
 * @description
 * @author      
 * @since       
 */
public without sharing class BatchUpdateNodeSuperMessages implements Database.Batchable<sObject>, Database.Stateful {

    private String dateLastRun ;
    private Datetime dateLastRunDate ;
    private integer scopeSize ;
    public String  query ;
    private integer minutesRange ;
    public boolean isAutoSchedulable ;
    public boolean needInfoLogWrite ;
    String BATCH_NAME = 'BatchUpdateNodeSuperMessages';

    public BatchUpdateNodeSuperMessages(Datetime dateLastRun) {
                 
        try {
            this.dateLastRun = dateLastRun.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            this.dateLastRunDate = dateLastRun;
            BatchSetting__mdt batchSettings = [select DeveloperName,IsAutoSchedulable__c,MinutesRange__c,
                                                ScopeSize__c,Query__c,Need_Information_Log__c 
                                                from BatchSetting__mdt
                                                where DeveloperName = 'Run_Batch_UpdateNodeSuperMessages'];
            
            this.scopeSize =(integer) batchSettings.ScopeSize__c ;
            this.minutesRange = (integer) batchSettings.MinutesRange__c ;
            this.isAutoSchedulable = batchSettings.IsAutoSchedulable__c ;
            this.query = batchSettings.Query__c;
            this.needInfoLogWrite = batchSettings.Need_Information_Log__c ;

        }catch (Exception e){ 
            ApplicationLogHelper.ERROR('BatchUpdateNodeSuperMessages', e.getMessage(), e.getStackTraceString()); 
        }
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        Database.QueryLocator qlocator ;
        try {
            qlocator = Database.getQueryLocator(this.query);
        }catch (Exception e){ 
            ApplicationLogHelper.ERROR('BatchUpdateNodeSuperMessages', e.getMessage(), e.getStackTraceString()); 
        }
        return qlocator ;
    }
    public void execute(Database.BatchableContext BC, List<Node__c> scope){
        try{
                String OK_Complete_Push = '_OK_Complete_Push'; //OK - richiesta sia push che Email - effettuati sia push che email
                String OK_Complete_Email = '_OK_Complete_Email'; //OK - richiesta sia push che Email - effettuata solo email
                String OK_Email = '_OK_Email'; //OK - richiesta solo mail - effettuata solo mail
                String KO_Complete_OK_Push = '_KO_Complete_OK_Push'; //KO - richiesta sia push che email
                String KO_Complete = '_KO_Complete'; //KO - richiesta sia push che email
                String KO_Email = '_KO_Email'; //KO - richiesta solo email

                List<AggregateResult> listOfSumCTC = [Select count(id)suma, CreatedBy.Agency_Code__c, status__c, Invio_push__c, MC_Push_Sent__c from Communications_to_customer__c where Status__c in ('Sent', 'KO Digital Sending') and  (Send_Date__c >= Last_N_Days:10 )  and Campaign__c != null and Iniziativa_Marketing_Id__c != null and TECH_NeedBatchUpdateSuperMessage__c = true group by CreatedBy.Agency_Code__c, status__c, Invio_push__c, MC_Push_Sent__c]; 	
                String query = 'Select TECH_NeedBatchUpdateSuperMessage__c from Communications_to_customer__c where Status__c in (\'Sent\', \'KO Digital Sending\') and Campaign__c != null and Iniziativa_Marketing_Id__c != null and TECH_NeedBatchUpdateSuperMessage__c = true and (Send_Date__c >= Last_N_Days:10) '; 	
        
                Map<String,Integer> sentByAgenzie = new Map<String,Integer> ();
                for(AggregateResult ctcPivot: listOfSumCTC){
                    String key = String.valueOf(ctcPivot.get('Agency_Code__c'));
                    if('Sent'.equalsIgnoreCase((String)ctcPivot.get('status__c'))){
                        if( (Boolean)ctcPivot.get('Invio_push__c') && (Boolean) ctcPivot.get('MC_Push_Sent__c' )){
                            key += OK_Complete_Push;
                        }
                        else if( (Boolean) ctcPivot.get('Invio_push__c' )){
                            key += OK_Complete_Email;
                        }
                        else{
                            key += OK_Email;
                        }
                    }
                    else if('KO Digital Sending'.equalsIgnoreCase((String)ctcPivot.get('status__c'))){
                        if( (Boolean) ctcPivot.get('Invio_push__c')){
                            if((Boolean) ctcPivot.get('MC_Push_Sent__c' )){
                                key += KO_Complete_OK_Push;
                            }
                            else{
                                key += KO_Complete;
                            }
                            
                        }
                        else{
                            key += KO_Email;
                        }
                    }
                    if(sentByAgenzie.containsKey(key)){
                        Integer temp = sentByAgenzie.get(key) + (Integer) ctcPivot.get('suma');
                        sentByAgenzie.put(key, temp);
                    }
                    else{
                        sentByAgenzie.put(key, (Integer) ctcPivot.get('suma'));
                    }
                    
                    
                }
                if(!listOfSumCTC.isEmpty()){
                    for(Node__c nodePivot:scope){
                        if(nodePivot.superMessagesUtilizzati__c!=null && nodePivot.superMessagesPrenotati__c!= null){
                            String baseKey = nodePivot.Node_unique_code__c;
                            if(sentByAgenzie.containsKey(baseKey + OK_Complete_Push)){
                                Integer suma = sentByAgenzie.get(baseKey + OK_Complete_Push);
                                nodePivot.superMessagesUtilizzati__c += suma * 2;
                                nodePivot.superMessagesPrenotati__c -= suma * 2;
                            }
                            if(sentByAgenzie.containsKey(baseKey + OK_Complete_Email)){
                                Integer suma = sentByAgenzie.get(baseKey + OK_Complete_Email);
                                nodePivot.superMessagesUtilizzati__c += suma;
                                nodePivot.superMessagesPrenotati__c -= suma * 2;
                            }
                            if(sentByAgenzie.containsKey(baseKey + OK_Email)){
                                Integer suma = sentByAgenzie.get(baseKey + OK_Email);
                                nodePivot.superMessagesUtilizzati__c += suma;
                                nodePivot.superMessagesPrenotati__c -= suma;
                            }
                            if(sentByAgenzie.containsKey(baseKey + KO_Complete_OK_Push)){
                                Integer suma = sentByAgenzie.get(baseKey + KO_Complete);
                                nodePivot.superMessagesUtilizzati__c += suma;
                                nodePivot.superMessagesPrenotati__c -= suma * 2;
                            }
                            if(sentByAgenzie.containsKey(baseKey + KO_Complete)){
                                Integer suma = sentByAgenzie.get(baseKey + KO_Complete);
                                nodePivot.superMessagesPrenotati__c -= suma * 2;
                            }
                            if(sentByAgenzie.containsKey(baseKey + KO_Email)){
                                Integer suma = sentByAgenzie.get(baseKey + KO_Email);
                                nodePivot.superMessagesPrenotati__c -= suma;
                            }
                        }
                    }
                    NodeHandler.setDeactivateTrigger(true);
                    Database.update(scope,AccessLevel.SYSTEM_MODE);
                    //update all comunications on async
                    MobilityCampaignsByPushNotification.QueueableUpdateCommunicationsOnCampaign listForUpdateTechField =
                    new MobilityCampaignsByPushNotification.QueueableUpdateCommunicationsOnCampaign(query,'1000'); 
                    System.enqueueJob(listForUpdateTechField);    
                }
            }
            catch (Exception e){ 
                ApplicationLogHelper.ERROR('BatchUpdateNodeSuperMessages', e.getMessage(), e.getStackTraceString()); 
            }
    }
    public void finish(Database.BatchableContext BC){

        if(this.isAutoSchedulable && !Test.isRunningTest()) {
            System.scheduleBatch(new BatchUpdateNodeSuperMessages(this.dateLastRunDate), BATCH_NAME, 
                                this.minutesRange,this.scopeSize);
        } 
    }
}
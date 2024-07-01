global class BatchRunCampaignMember implements Database.Batchable<sObject>, Database.Stateful{
    private integer contTotalRecordsKO = 0;
          private integer contTotalRecordsRan = 0;
          private integer scopeSize ;
          public String  query ;
          private integer minutesRange ;
          private boolean isAutoSchedulable ;
          private boolean needInfoLogWrite ;
          String BATCH_NAME = 'Run Batch Campaign Member';
          String CampaignId_input;
      
public BatchRunCampaignMember (String CampaignId_input){
       try {
            BatchSetting__mdt batchSettings = [select DeveloperName,IsAutoSchedulable__c,MinutesRange__c,
                                                  ScopeSize__c,Query__c,Need_Information_Log__c 
                                                  from BatchSetting__mdt
                                                  where DeveloperName = 'Run_Batch_Campaign_Member'];
              
            this.scopeSize =(integer) batchSettings.ScopeSize__c ;
            this.minutesRange = (integer) batchSettings.MinutesRange__c ;
            this.isAutoSchedulable = batchSettings.IsAutoSchedulable__c ;
            this.query = batchSettings.Query__c + ' AND CampaignId =\''+CampaignId_input+'\'' ;
            this.needInfoLogWrite = batchSettings.Need_Information_Log__c ;
            this.CampaignId_input=CampaignId_input;
  
        }catch (Exception e){ 
          ApplicationLogHelper.ERROR('BatchRunCampaignMember', e.getMessage(), e.getStackTraceString()); 
        }
}
public BatchRunCampaignMember(){
}

global Database.QueryLocator start(Database.BatchableContext BC){
  
        Database.QueryLocator qlocator ;
        try {
            qlocator = Database.getQueryLocator(this.query);
        }catch (Exception e){ 
               ApplicationLogHelper.ERROR('BatchRunCampaignMember', e.getMessage(), e.getStackTraceString()); 
        }
        return qlocator ;
      }
      global void execute(Database.BatchableContext BC, List<CampaignMember> scope){
          System.debug('Scope= '+ scope);
          
    try{  
            
            AggregateResult[] users= [SELECT max(id)IDs,Main_Node__c,Count(name)nVolteM_Code, Max(Profile.Name)profilo from user where Main_Node__c!=null and IsActive=true and IsPortalEnabled = true group by Main_Node__c having count(Main_Node__c) = 1 and Max(Profile.Name) != 'NFE - AAI - Vendite solo Assistenza'];       
            Map<String,String>userschecked= new Map<String,String>();
            for(AggregateResult n:users){
                userschecked.put(String.valueOf(n.get('Main_Node__c')), String.valueOf(n.get('IDs')));
            }
            system.debug('userschecked = '+userschecked);

            list<CampaignMember>listaCmFinale= new list<CampaignMember>();
            for(CampaignMember cm: scope){ 
                cm.NeedAsyncBatchExecution__c = false;
                if(userschecked.containsKey(cm.Nodo_Omnia_produttore__c)){
                    cm.Owner__c=userschecked.get(cm.Nodo_Omnia_produttore__c);
                    cm.Status='Da lavorare';
                    listaCmFinale.add(cm);
                }else{
                    listaCmFinale.add(cm);
                }
            }
            system.debug('userschecked = '+userschecked);
            System.debug('listaCmFinale ='+listaCmFinale);
            System.debug('Scope= '+ scope);

            Database.SaveResult[] drList = Database.update(listaCmFinale,false); 
      
            integer contTempPerBatchOK = 0 ;
            integer contTempPerBatchKO = 0 ;
            List<ApplicationLogHelper.ErrorWrapper> Errors = new List<ApplicationLogHelper.ErrorWrapper>();
      
            for(Database.SaveResult result : drList) {
                if(result.isSuccess()){
                    system.debug('Aggilavorareornato-'+result.getId());
                    contTempPerBatchOK++;
                }       
                else {  
                    system.debug('Non Aggiornato-'+result.getId());
                    system.debug('Error Updating because --'+result.getErrors());
                    system.debug('Error Updating for --'+System.UserInfo.getName()+'-Profilo-'+System.UserInfo.getProfileId());
                    // sending error to ApplicationLog__c 
                    Errors.add(new ApplicationLogHelper.ErrorWrapper('Error Update BatchRunCampaignMember-'+result.getId(), result.getErrors().toString()));
                    contTempPerBatchKO++;
                }
            }

            system.debug('drList-'+drList);
            contTotalRecordsRan += contTempPerBatchOK ;
            contTotalRecordsKO  += contTempPerBatchKO ;
            if(!Errors.isEmpty())
                  ApplicationLogHelper.LogErrors('BatchRunCampaignMember', Errors);  
    }catch (Exception e){ 
               ApplicationLogHelper.ERROR('BatchRunCampaignMember', e.getMessage(), e.getStackTraceString()); 
    }
}
      
global void finish(Database.BatchableContext BC){
          //code here
        try {
              
        //Aggiornamento del campo Picklist Stato_Assegnazione_membri_campagna__c delle varie Campaign
        list<Campaign>listCampaign= [select id,name,Stato_Assegnazione_membri_campagna__c, CreatedDate,Unprocessed_CM_Count__c,  NumberOfContacts from Campaign where id =: this.CampaignId_input];
        System.debug('listCampaign= '+ listCampaign);
        
        for(Campaign lC:listCampaign)
              lC.Stato_Assegnazione_membri_campagna__c='Terminato';
        
        System.debug('listCampaign= '+ listCampaign);
        update listCampaign;
             
        System.debug('### Campaign Member Run Batch OK : '+ contTotalRecordsRan);
        System.debug('### Campaign Member Run Batch KO : '+ contTotalRecordsKO);
        if(needInfoLogWrite)
        ApplicationLogHelper.INFO('BatchRunCampaignMember', 'Batch BatchRunCampaignMember finish at: '+System.now(), 'Total OK : '+ contTotalRecordsRan+' '+
                                                                                          'Total KO : '+ contTotalRecordsKO );
  
        System.debug('FINISH -- Scheduling new Batch in-'+this.minutesRange+':min');
        if(this.isAutoSchedulable && !Test.isRunningTest()) {
            System.scheduleBatch(new BatchRunCampaignMember(), BATCH_NAME, 
                                      this.minutesRange,this.scopeSize);
        } 
        }catch (Exception e){ 
               ApplicationLogHelper.ERROR('BatchRunCampaignMember', e.getMessage(), e.getStackTraceString()); 
        } 
    }
}
global class CampaignSharing_Batch implements Database.Batchable<String>,Schedulable,Database.Stateful  {
    
    private final String objectShare = 'CampaignShare';   
    private final String parentId = 'CampaignId'; 
    private final String rowCause = 'Manual';
    private final String accessLevelName = 'CampaignAccessLevel';
    private final String accessLevelvalue = 'Read'; //'None','Read','Edit','All'
    private final String separatorOfGroups = ';';
    private final String fieldNameOfGroup ='Agencies_in_Target__c'; 
    private integer contTempPerBatchOK = 0 ;
    private boolean needInfoLogWrite = false ;
    private Integer batchSize = 200 ;// portarlo a cong metada custom
    private List<String> requestIdList = new List<String>(); //
    private boolean chainingCampaignSharing_Batch = true;// default true perche ... chaining 1 Campagna a volta
    private Campaign CampagnaInLavorazione = new Campaign ();
    private boolean fromAgency = false;

    public CampaignSharing_Batch(){
    try {
        //configuration mtd for scope size reasons and log
        BatchSetting__mdt batchSettings = [select DeveloperName,IsAutoSchedulable__c,MinutesRange__c,
                ScopeSize__c,Query__c,Need_Information_Log__c 
                from BatchSetting__mdt
                where DeveloperName = 'Run_Batch_Campaign_Sharing'];
        
        this.batchSize =(integer) batchSettings.ScopeSize__c ;
        this.needInfoLogWrite = batchSettings.Need_Information_Log__c ;

        List<Campaign> CampagnaInLavorazioneLista = new List<Campaign> ();
        //tutte quelle che hanno cambiato il campo Agencies_in_Target__c fatto nel trigger
        CampagnaInLavorazioneLista = [SELECT Id, Name, Nodes_tree__c,Agencies_in_Target__c from Campaign where TECH_CampagnaLavorata__c = 'Da Lavorare'  limit 1];

        if(!CampagnaInLavorazioneLista.isEmpty() && CampagnaInLavorazioneLista[0]!= null){
            this.CampagnaInLavorazione = CampagnaInLavorazioneLista[0];
            this.requestIdList = CampagnaInLavorazioneLista[0].Agencies_in_Target__c.split(separatorOfGroups) ;
            this.chainingCampaignSharing_Batch = true; // ci sono campagne da lavorare 1++
        }else {
            this.chainingCampaignSharing_Batch = false; // non ci sono campagne da lavorare
        }
        
    }catch (Exception e){ 
        ApplicationLogHelper.ERROR('CampaignSharing_Batch', 'Constructor: '+ e.getMessage(), e.getStackTraceString()); 
    }

    }

    public CampaignSharing_Batch(String campaignId){
        try {
            //configuration mtd for scope size reasons and log
            this.fromAgency = true;
            BatchSetting__mdt batchSettings = [select DeveloperName,IsAutoSchedulable__c,MinutesRange__c,
                    ScopeSize__c,Query__c,Need_Information_Log__c 
                    from BatchSetting__mdt
                    where DeveloperName = 'Run_Batch_Campaign_Sharing'];
            
            this.batchSize =(integer) batchSettings.ScopeSize__c ;
            this.needInfoLogWrite = batchSettings.Need_Information_Log__c ;

            List<Campaign> CampagnaInLavorazioneLista = new List<Campaign> ();
            //tutte quelle che hanno cambiato il campo Agencies_in_Target__c fatto nel trigger
            CampagnaInLavorazioneLista = [SELECT Id, Name, Nodes_tree__c,Agencies_in_Target__c from Campaign where Id=:campaignId limit 1];

            if(!CampagnaInLavorazioneLista.isEmpty() && CampagnaInLavorazioneLista[0]!= null){
                this.CampagnaInLavorazione = CampagnaInLavorazioneLista[0];
                this.requestIdList = CampagnaInLavorazioneLista[0].Agencies_in_Target__c.split(separatorOfGroups) ;
                this.chainingCampaignSharing_Batch = true; // ci sono campagne da lavorare 1++
            }else {
                this.chainingCampaignSharing_Batch = false; // non ci sono campagne da lavorare
            }
            
        }catch (Exception e){ 
            ApplicationLogHelper.ERROR('CampaignSharing_Batch', 'Constructor: '+ e.getMessage(), e.getStackTraceString()); 
        }

    }

    public Iterable<String> start(Database.BatchableContext BC){
    try {

        if(chainingCampaignSharing_Batch){// se ci sono campagne da lavorare ..al meno 1
            // cancellazione per che ??? perche MC condivide sempre con tutti ???
            List <CampaignShare> CsToDelete = [Select id from CampaignShare where UserOrGroupId in (Select id from group where developername = 'AllPartnerUsers') and CampaignId =:this.CampagnaInLavorazione.Id]; 
            // cancellare tutti records creati prima in caso di aggiornamento di togliere visibilita
            List <CampaignShare> shareToDeleteOlds = [select  Id, CampaignId, UserOrGroupId, CampaignAccessLevel, RowCause, LastModifiedDate, LastModifiedById, IsDeleted from CampaignShare where CampaignId =: this.CampagnaInLavorazione.Id and RowCause = 'Manual' and CampaignAccessLevel = 'Read' and LastModifiedById =: UserInfo.getUserId()]; 

            if(!CsToDelete.isEmpty())
                delete CsToDelete;

            if(!shareToDeleteOlds.isEmpty())
                delete shareToDeleteOlds;
        }
        }catch (Exception e){ 
            ApplicationLogHelper.ERROR('CampaignSharing_Batch', 'Method Start: '+ e.getMessage(), e.getStackTraceString()); 
        }

        List<String> scope = new List<String>();
        scope.addAll(this.requestIdList);
        return   scope;
        }

    global void execute(Database.BatchableContext BC, List<String> scope) {
        try {
            String lineToShareForBatchAgencytarget = '';
            for(String tempLine:scope ){
                lineToShareForBatchAgencytarget += tempLine+';';
            }

            this.CampagnaInLavorazione.Agencies_in_Target__c = lineToShareForBatchAgencytarget;

            Map <id,sObject> mapSObj = new Map <id,sObject> (new List<Campaign>{this.CampagnaInLavorazione});
            //V.02
            Map<Id,List<String>> mapShare2 = new Map<Id,List<String>>();
            
            for (Id theId : mapSObj.keySet()){   
                
                SObject so = mapSObj.get(theId);  
                String Initial = so.get('nodes_tree__c')+'';
                if(so.get(fieldNameOfGroup) != null)
                {
                    String s = so.get(fieldNameOfGroup)+'';
                    List<String> groups2 = s.split(';');
                    List<String> groups3 = new List<String>();
                    for (String giName : groups2){
                        groups3.add(Initial+''+giName);
                    }
                    mapShare2.put(theId, groups3);
                }
        
            }
        
            List<sObject> toShare = RecordSharing.getCurrentRecordShare(objectShare, parentId, rowCause, mapShare2, accessLevelName, accessLevelvalue);
            
            Map<String, SObject> MaptoInsert = new Map<String, SObject>();//new list<sObject>(newMinusOld); //list of group sharing to be actually inserted  
            for(SObject so : toShare){
                MapToInsert.put(so.get(parentId) + '' + so.get('userorgroupid'), so);
            }
            list<sObject> inShareMember = MapToInsert.values();
            this.contTempPerBatchOK += inShareMember.size();
            insert inShareMember;
        }catch (Exception e){ 
            ApplicationLogHelper.ERROR('CampaignSharing_Batch', 'Method execute: '+ e.getMessage(), e.getStackTraceString()); 
        }
    }

    global void finish(Database.BatchableContext BC){
        System.debug('Creati in totale records Share -'+this.contTempPerBatchOK + ' lavorata campagna id -' + this.CampagnaInLavorazione == null ? ' batch empty. Finish all Campaigns ':this.CampagnaInLavorazione.Id );
        try { // chainingCampaignSharing_Batch partire d nuovo in caso ci sono altri records
        Campaign tempForUpdate = new Campaign();
        if(this.CampagnaInLavorazione != null && this.CampagnaInLavorazione.Id != null){
            tempForUpdate.TECH_CampagnaLavorata__c = 'Lavorata';
            tempForUpdate.Id = this.CampagnaInLavorazione.Id;
            update tempForUpdate;
        }
        if(needInfoLogWrite)
         ApplicationLogHelper.INFO('CampaignSharing_Batch', 'Batch CampaignSharing finish at: '+System.now(), 'Total records CampaignShare : '+ contTempPerBatchOK);

        // ci sono ancora da lavorare ???
        if(chainingCampaignSharing_Batch && !this.fromAgency){
                CampaignSharing_Batch csb = new CampaignSharing_Batch();
                Database.executeBatch(csb, this.batchSize);
        } else {
                System.debug('Non ci sono piu Campagne da condividere, nessuna con TECH_CampagnaLavorata__c = "Da Lavorare" ');
            }
        }catch (Exception e){ 
            ApplicationLogHelper.ERROR('CampaignSharing_Batch', 'Method Finish: '+ e.getMessage(), e.getStackTraceString()); 
        }
    }

    global void execute(SchedulableContext sc) {
        CampaignSharing_Batch csb = new CampaignSharing_Batch();
        Database.executeBatch(csb, this.batchSize);
    }
    
}
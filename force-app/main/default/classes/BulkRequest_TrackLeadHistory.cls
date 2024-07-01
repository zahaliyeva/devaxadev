public without sharing class BulkRequest_TrackLeadHistory implements BulkRequestHandler{
    
    public List<Tracking_History_Lead__c> ListToInsert;
    public integer retries;

    public List<String> process(List<Sobject> scope){
        List<String> toRetErr =  new List<string>();
        try{

            if(ListToInsert != null && !ListToInsert.isEmpty()){
                try{
                    insert ListToInsert;
                    return new List<String>();
                }
                catch (DMLException ex){
                    try{
                        
                        if(ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') && this.retries < 2){
                            
                            insert prepareRequest(this.ListToInsert, true, this.retries);
                            
                        }
                            
                        else{
                            ApplicationLogHelper.ERROR('LeadTrackingManagement', ex.getMessage(), ex.getStackTraceString());
                            toRetErr.add(ex.getMessage());
                        }
                            
                        
                    }
                    catch(Exception e){
                        ApplicationLogHelper.ERROR('LeadTrackingManagement', ex.getMessage(), ex.getStackTraceString());
                        
                        toRetErr.add(ex.getMessage());
                        
                    }
                }
                catch(Exception ex){
                    ApplicationLogHelper.ERROR('LeadTrackingManagement', ex.getMessage(), ex.getStackTraceString());
                    
                    toRetErr.add(ex.getMessage());
                    
                }
            }
            
        } catch (Exception ex){
            
            toRetErr.add(ex.getMessage());
            
        }
        
        return toRetErr;
    }

    public static Bulk_Request__c prepareRequest(List<Tracking_History_Lead__c> ListToInsert, Boolean bypassAutoRun, Integer retries){
        BulkRequest_TrackLeadHistory req = new BulkRequest_TrackLeadHistory();
        req.ListToInsert = ListToInsert;
        req.retries = retries + (bypassAutoRun ? 1 : 0);
        Bulk_Request__c toRet = new Bulk_Request__c(BulkRequestHandler__c = 'BulkRequest_TrackLeadHistory');
        toRet.JsonInstance__c = Json.serialize(req);
        toRet.Query__c = 'Select Id From User LIMIT 1';
        toRet.Request_by__c = Userinfo.getUserId();
        toRet.Status__c='SUBMITTED';
        toRet.bypassAutoRun__c = bypassAutoRun;
        return toRet;
    }
    
    

}
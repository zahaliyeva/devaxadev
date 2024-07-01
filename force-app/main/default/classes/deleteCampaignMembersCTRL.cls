public class deleteCampaignMembersCTRL {
    public boolean jsDebug{get;set;}
    public string apexCampaignId{get;set;}
    
    public deleteCampaignMembersCTRL (ApexPages.StandardController stdController)
    {
        Id user_debug_id;
        try
        {
            user_debug_id = (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG') != null ? (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG').Value__c : null;
        }
        catch (Exception e)
        {
            user_debug_id = null;
        }
        if (user_debug_id != null && (user_debug_id  == UserInfo.getUserId()))
        {
            jsDebug= true;
        }
        else
        {
            jsDebug=false;
        }
        apexCampaignId=ApexPages.currentPage().getParameters().get('id');    
    }

    @AuraEnabled
    public static boolean userVisibilityCheck(){
        //put in a custom setting if needed
        String allowedProfile1 = 'System Administrator';
        String allowedProfile2 = 'AAI - Marketing Avanzato';
        String allowedProfile3 = 'Amministratore del sistema';
        String allowedProfile4 = 'MC Admin MFA';

        String UserId=UserInfo.GetUserId();
        User CurrentUser = new User();
        CurrentUser=[SELECT Id,CommunityNickname, Agency_code__c,Profile.Name,UserRole.Name,Nodes__c,Nodes_tree__c FROM User WHERE Id=:UserId Limit 1];
        String profiloCorrente = CurrentUser.Profile.Name;
        system.debug('######'+profiloCorrente );
        if(profiloCorrente.equals(allowedProfile1) ||  profiloCorrente.equals(allowedProfile3)         
            || profiloCorrente.equals(allowedProfile2) || profiloCorrente.equals(allowedProfile4))
           {
             return true;
        } else {
           return false;
        }
    }

    @AuraEnabled
    public static ResponseDto checkCampaign (String campaignId) {
        ResponseDto pageResponse = new ResponseDto();
        list<Campaign> campaignList = [SELECT Id,Name,Blacklist_end_date__c,Blacklist_available__c FROM Campaign WHERE Id = :campaignId];
        if (campaignList.size()>0)
        {
            if (campaignList.get(0).Blacklist_available__c == true){

                if (campaignList.get(0).Blacklist_end_date__c < Date.today()) 
                {
                    pageResponse.isSuccess = true;
                }
                else
                {
                    pageResponse.message = 'La data di termine lavorazione per la blacklist sulla campagna non è ancora stata superata';
                }
            }
            else
            {
                pageResponse.message = 'La campagna non risulta essere stata resa disponibile per la lavorazione blacklist';
            }
        }
        else
        {
            pageResponse.message = 'Nessuna campagna trovata';
        }

        return pageResponse;
    }    

   @AuraEnabled
    public static ResponseDto checkEligibility (String campaignId) {
        ResponseDto pageResponse = new ResponseDto();
        Boolean visibilityCheck = userVisibilityCheck();
        if (!visibilityCheck) 
        {
            pageResponse.message = 'Profilo non corretto';
            return pageResponse;
        }
        ResponseDto campaignCheck =  new ResponseDto();
        campaignCheck = checkCampaign (campaignId);
        if ( campaignCheck.isSuccess== false) return campaignCheck;
        else 
        {
            pageResponse.isSuccess = true;
            return pageResponse;
        }
    }

   @AuraEnabled
    public static ResponseDto startDeletion (String campaignId) {
        
        ResponseDto pageResponse = new ResponseDto();
        ResponseDto firstCheck = checkEligibility (campaignId);
        if (firstCheck.isSuccess== false) return firstCheck;
        deleteCampaignMembersBatch deletionBatch = new deleteCampaignMembersBatch(campaignId);
        ID batchprocessid = Database.executeBatch(deletionBatch);
        pageResponse.isSuccess = true;
        pageResponse.message = 'Id batch: '+batchprocessid;
        
        return pageResponse ;
    }        
        
    public class ResponseDto { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Map<Object, Object> values { get; set; }
        public ResponseDto(Boolean isSuccess, String msg){
            this.isSuccess = isSuccess;
            this.message = msg;
            this.values = new Map<Object, Object>();
            }   

        public ResponseDto(){
            this.isSuccess = False;
            this.message = '';
            this.values = new Map<Object, Object>();
            }       
    }
    
  
    
}
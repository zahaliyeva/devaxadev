public with sharing class agencyQueueManagerUtilities {
    public static boolean userVisibilityCheck(User CurrentUser){
        //put in a custom setting if needed
        String allowedProfile1 = 'System Administrator';
        String allowedProfile2 = 'AAI - Vendite Avanzato';
        String allowedProfile3 = 'Amministratore del sistema';
        String allowedProfile4 = 'NFE - AAI - Vendite Avanzato';
        String allowedProfile5 = 'AAI - Vendite solo Assistenza';
        String allowedRole1 = 'Responsabile';

        String profiloCorrente = CurrentUser.Profile.Name;
        String currentRole = CurrentUser.UserRole.Name;
        
        String mainAgencyNode = CurrentUser.Nodes_tree__c+CurrentUser.Agency_code__c;
       	Set<String> userNodeSet = new Set<String>();
       	if (CurrentUser.Nodes__c!= null && CurrentUser.Nodes__c != ''){  	
	   	    for(String uN : CurrentUser.Nodes__c.split(';')){
	            userNodeSet.add(uN);
	        }
       	}
        Boolean hasAgencyNode = false;
        if(userNodeSet.contains(mainAgencyNode)) hasAgencyNode = true;
        
        system.debug('######'+profiloCorrente );
        
        
        if((profiloCorrente.equals(allowedProfile1) ||  profiloCorrente.equals(allowedProfile3) ||  profiloCorrente.equals(allowedProfile4) ||  profiloCorrente.equals(allowedProfile5))
            ||
           (currentRole.contains(allowedRole1) && profiloCorrente.equals(allowedProfile2) && hasAgencyNode)
           ){
             return true;
        } else {
           return false;
        }
    }

    public static ResponseDto getAgencyUsers (String queueType) {
		ResponseDto pageResponse = new ResponseDto();	
		list<userInQueue> userList = new list<userInQueue> ();           

		String UserId=UserInfo.GetUserId();
		User CurrentUser = new User();
		CurrentUser=[SELECT Id,CommunityNickname, Agency_code__c,Profile.Name,UserRole.Name,Nodes__c,Nodes_tree__c FROM User WHERE Id=:UserId Limit 1];
		if (!agencyQueueManagerUtilities.userVisibilityCheck(CurrentUser))
		{
			pageResponse.message = 'Unauthorized user';
			return pageResponse;
		}
		AAI_Code_Variables__c defaultAdminAgency = AAI_Code_Variables__c.getValues('AdminAgencyCode');
		String agencyCode = '';
		if ((CurrentUser.Profile.Name == 'System Administrator') || (CurrentUser.Profile.Name == 'Amministratore del sistema')) agencyCode = defaultAdminAgency.Value__c;
		if(CurrentUser.Agency_code__c!= null && CurrentUser.Agency_code__c!= '') agencyCode = CurrentUser.Agency_code__c;
		system.debug ('*********agencyCode'+agencyCode);
		if(agencyCode != '')
		{
			
			String queueDevName ='';
			if (queueType== 'Lead') queueDevName = 'Coda_Agenzia_'+agencyCode;
			if (queueType== 'Case') queueDevName = 'Coda_Agenzia_Case_'+agencyCode;
			list<Group> currentQueue = [Select Id, DeveloperName from group where type='Queue' and DeveloperName  = :queueDevName ];
			if( currentQueue.size()>0)
			{
				List<GroupMember> currentGroupMembers = [Select Id, GroupId,Group.DeveloperName, UserOrGroupId from GroupMember where GroupId = :currentQueue[0].Id];
				if (currentGroupMembers.size()>0)
				{
					Map<Id,GroupMember> currentGMmap = new map <Id,GroupMember>();
					for (GroupMember gm :currentGroupMembers)
					{
						currentGMmap.put(gm.UserOrGroupId,gm);
					}
					//List<User> agencyUserList = [Select Id,UserName,CommunityNickname, Agency_code__c,Profile.Name,IsActive,	UserRole.Name,Email,FirstName,LastName,Nodes__c FROM User WHERE Agency_code__c = :agencyCode AND IsPortalEnabled = True];
					usersContainer theContainer = new usersContainer(agencyCode);
					List<User> agencyUserList= theContainer.agencyUserList;
					for (User singleUsr :agencyUserList)
					{
						GroupMember checkInQueue = new GroupMember();
						checkInQueue=currentGMmap.get(singleUsr.Id);
						Boolean isInQueue = false;
						if (checkInQueue!=null) isInQueue = true;
						userList.add(new userInQueue (isInQueue,singleUsr.Abilitazione_CTL__c,singleUsr.Abilitazione_IVASS41__c,singleUsr));
					}
					pageResponse.isSuccess = true;
					pageResponse.values.put ('userList',userList);
					pageResponse.values.put ('regExpValidator',FieldValidator.getListOfRegularExpressions());
				}
			
			}
			
		}



		return pageResponse ;
    }

    public static agencyQueueManagerUtilities.ResponseDto saveUpdateRequest (List<Boolean> isInQueue, List<User> userList,String queueType) {
    	list<User> usersToUpdate = new List<User>();
		agencyQueueManagerUtilities.ResponseDto pageResponse = new agencyQueueManagerUtilities.ResponseDto();
		Boolean oneActiveInQueue = false;
		List<String> toBeInQueueList = new List<String>();
		//for (userInQueue uiq :pageRequest)
		system.debug ('isInQueue.size() '+isInQueue.size());
		for (Integer i=0;i<isInQueue.size();i++)
		{
			if(isInQueue[i] == true )
			{
				toBeInQueueList.add(userList[i].Username);
				if ( userList[i].IsActive == true)
				{
					oneActiveInQueue = true;
				}
			}
		}
		String UserId=UserInfo.GetUserId();
		User CurrentUser = new User();
		CurrentUser=[SELECT Id,CommunityNickname, Agency_code__c,Profile.Name,UserRole.Name,Nodes__c FROM User WHERE Id=:UserId Limit 1];
		String agencyCode = userList[0].Agency_code__c ;
		if(CurrentUser.Agency_code__c!= null && CurrentUser.Agency_code__c!= '') agencyCode = CurrentUser.Agency_code__c;
        for(User temp : userList){
            usersToUpdate.add(new User(Id = temp.Id, abilitazione_CTL__c = temp.abilitazione_CTL__c, abilitazione_Ivass41__c = temp.abilitazione_Ivass41__c));
        }
        if(!SollecitoPeriodicoIvass41.UpdateUsers(usersToUpdate)){
            pageResponse.message = 'Non è stato possibile abilitare gli agenti alla lavorazione case';
            return pageResponse;
        }
		
		if (oneActiveInQueue == false)
		{
			pageResponse.message = 'Non è possibile lasciare la coda di agenzia senza utenti attivi nella stessa';
			//return pageResponse;
		}
		else
		{
			Bulk_Request__c bulkToInsert = PrepareBulkRequest(agencyCode,toBeInQueueList,queueType);
			Database.SaveResult insertResult = Database.insert (bulkToInsert,false);
			if (insertResult.isSuccess())
			{
				//SUCCESS, NAVIGATE BACK TO LEAD PAGE
				pageResponse.isSuccess = true;
			}
			else
			{
				String errorMsg = 'Si è verificato un errore nella richiesta di modifica della coda: ';
		        // Operation failed, so get all errors                
		        for(Database.Error err : insertResult.getErrors()) {
		                               
		            errorMsg= errorMsg +err.getStatusCode() + ': ' + err.getMessage();
		        }   
				pageResponse.message = errorMsg;
			}
		}
		
		
		
		return pageResponse ;
    }

	public static Bulk_Request__c PrepareBulkRequest(String agencyCode,List<String> userToPutInQueue,String queueType) {
		Bulk_Request__c newBR = new Bulk_Request__c();
		newBR.BulkRequestHandler__c ='BulkRequest_AgencyQueue';
		
		BulkRequest_AgencyQueue BR_instance = new BulkRequest_AgencyQueue();
		BR_instance.userNamesToAdd = userToPutInQueue;
		BR_instance.AgencyCode = agencyCode;
		BR_instance.queueType = queueType;
		BR_instance.DateRequest = DateTime.Now();
		newBR.Query__c = 'Select Id From User LIMIT 1';
		newBR.JsonInstance__c = JSON.serialize(BR_instance);
        newBR.Request_by__c = Userinfo.getUserId();
        newBR.Status__c='SUBMITTED';	
        
        return newBR;
		
	}  

	public class userInQueue { 
		@AuraEnabled public Boolean isInQueue { get; set; }
        @AuraEnabled public Boolean AbilitazioneIvass { get; set; }
        @AuraEnabled public Boolean AbilitazioneCTL { get; set; }
		@AuraEnabled public User singleUser { get; set; }
		public userInQueue (Boolean isInQueue,Boolean abilitazioneCTL, Boolean abilitazioneIvass, User singleUser){
            this.AbilitazioneIvass = abilitazioneIvass;
            this.AbilitazioneCTL = abilitazioneCTL;
			this.isInQueue = isInQueue;
			this.singleUser = singleUser;
		}        
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
	public without sharing class usersContainer {
		public list<User> agencyUserList;
		public usersContainer (String agencyCode) {
            
            //AM
			agencyUserList = [Select Id,UserName,abilitazione_IVASS41__c,abilitazione_CTL__c,CommunityNickname, Agency_code__c,Profile.Name,IsActive,	UserRole.Name,Email,FirstName,LastName,Nodes__c,Contact.Account.Destinatario_notifica_Feedback_Case__c, Contact.Account.MobilePhone__c FROM User WHERE Agency_code__c = :agencyCode AND IsPortalEnabled = True AND IsActive = True];
		}
	}

	public without sharing class UsersUtils {
		public List<Database.SaveResult> updateRecords(List<SObject> records, Boolean allOrNothing) {
			List<Database.SaveResult> updateResult = Database.update (records, allOrNothing);
			return updateResult;
		}
	}
}
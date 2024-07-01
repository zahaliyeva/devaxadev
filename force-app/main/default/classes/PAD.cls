public with sharing class PAD {
	public static final string bypassTrigger;
	public static boolean BypassValidationRule;
	
	private static final Set<String> requiredOnce=new Set<String>{'AP03a'};//List of Apex codes that should run only once. Add any code to the list
  	public static Set<String>hasRun=new Set<String>();//List of Apex code that has already been run. Keep this list empty.
  	
    static{
    	// a list is used in order to avoid the following exception 'List has no rows for assignment to SObject'
    	// this exception is fired when a license manager user try to update a record
    	List<User> users = new List<User>([Select ByPassAT__c, ByPassVR__c from User where Id =:UserInfo.getUserId() limit 1]);
    	if(users.size()>0){
    		System.Debug('## >>> PAD constructor :BEGIN <<< run by ' + UserInfo.getName());
      		bypassTrigger = ';' + users[0].ByPassAT__c + ';';
      		BypassValidationRule = users[0].ByPassVR__c;
      		System.Debug('## >>> PAD constructor : END <<<');
    	}else{
    		bypassTrigger = null;
    		BypassValidationRule = false;
    	}
    	
    	System.Debug('## bypassTrigger'+ bypassTrigger);
    }
    
    
  	public static boolean canTrigger(string ApexName){ //If no bypass
  		if(requiredOnce.contains(ApexName)){//If it should run Once
			if(hasRun.contains(ApexName))return false;//Already run, should not run
			  	hasRun.add(ApexName);//Never run, can run only if not bypassed
		}
  		if(bypassTrigger != null){
  			return(bypassTrigger.indexOf(';'+ApexName+';')==-1);	
  		}
  		else{
  			// when the string 'bypassTrigger' is null
  			// a false is returned, so that no trigger process is applied on the updated record
  			return false;
  		}
  	}
  	
  	  
}
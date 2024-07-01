public virtual class RLY_Behaviour {
	public static final String STATUS_INIT 		= 'Init';
	public static final String STATUS_ACTIVE 	= 'Active';
	public static final String STATUS_DEACTIVE 	= 'Deactive';

	public static String prefix = '*** AXA *** ';

	private static List<String> listDebug = new List<String>();
	private static List<String> methodsStartedDebug = new List<String>();
	private static String currentClassDebug;
	private static String currentMethodDebug;
    private static Map<String, Integer> lastLimits = RLY_Behaviour.getLimits();
	private static String statusLog = RLY_Behaviour.STATUS_INIT;

    private static Map<String, String> lastHash = new Map<String, String>();

    public static Boolean isActive(){
    	if(RLY_Behaviour.statusLog == RLY_Behaviour.STATUS_INIT){
    		Boolean active = RLY_LogSettings__c.getInstance(UserInfo.getUserId()).Enabled__c;

    		RLY_Behaviour.statusLog = (active) ? RLY_Behaviour.STATUS_ACTIVE : RLY_Behaviour.STATUS_DEACTIVE;

    		return active;
    	}

    	return (RLY_Behaviour.statusLog == RLY_Behaviour.STATUS_ACTIVE);
    }
    
	public static Void Debug(Object msg){
		Debug(null, msg); 
	}

	public static Void Debug(String title, Object msg){
		String debugMessage = null;
		if (RLY_Behaviour.isActive() && String.isNotBlank(title)) debugMessage = prefix + currentClassDebug + '.' + currentMethodDebug + ': '+ title + ': ' + msg;
		else if (RLY_Behaviour.isActive()) debugMessage = prefix+ currentClassDebug + '.' + currentMethodDebug + ': ' + msg;

		if(debugMessage != null){
			listDebug.add(debugMessage);
			System.debug(debugMessage);
		}
	}

	public static String getLog(){
		return String.join(listDebug, '\n');
	}

	public static Void DebugObject(String title, Object msg){
		Debug(title + ': ' + msg);
	}

	public static Void DebugJson(String title, Object msg){
		if(msg != null){
			Debug(title + ': ' + JSON.serialize(msg));
		}else{
			Debug(title + ': Null');
		}
	}

	public static Void DebugHash(String title, Object msg){
		if (!RLY_Behaviour.isActive()) return;
		if(msg == null){
			Debug(title + ': hash >> Null');
			return;
		}

		String jsonString = JSON.serialize(msg);
		Blob targetBlob = Blob.valueOf(jsonString);
		String hash = EncodingUtil.convertToHex( Crypto.generateDigest('MD5', targetBlob) );

		String lastHash = RLY_Behaviour.lastHash.get(title);

		if(lastHash != null){
			if(hash != lastHash){
				Debug(title + ': hash >> (Changed!) ' + hash);
			}else{
				Debug(title + ': hash >> (Not Changed!) ' + hash);
			}
		}else{
			Debug(title + ': hash >> ' + hash);
		}

		RLY_Behaviour.lastHash.put(title, hash);
	}

	public static Void DebugList(String title, List<Object> listDebug){
		if(listDebug == null){
			Debug(title + ': Null');
			return;
		}
		
		Debug(title + ': size=' + listDebug.size());
		Debug(title + ': ' + listDebug);
	}

	public static Void DebugStart(String className, String methodName){
		incrementIndex(className, methodName);
		Debug('START');
		DebugPosition();
	}

	public static Void DebugEnd(){
		if (!RLY_Behaviour.isActive()) return;
		
		DebugPosition();
		Debug('END');
		decrementIndex();
	}

	public static Void DebugPosition(){
		String mapClass = String.join((Iterable<String>)methodsStartedDebug, ' >> ');
		Debug(String.format('>>> {0}', new String[]{mapClass}));
	}

	public static Void DebugBreak(){
		System.debug(prefix + '++++++++++++++++++ ' + currentClassDebug + ' ++++++++++++++++++');
	}

	public static Void DebugLimits(){
		DebugLimits(true, new List<String>());
	}

	public static Void DebugLimits(Boolean selectAll){
		DebugLimits(selectAll, new List<String>());
	}

	public static Void DebugLimits(String selectLimit){
		DebugLimits(false, new List<String>{selectLimit});
	}

	public static Void DebugLimits(List<String> selectedLimits){
		DebugLimits(false, selectedLimits);
	}

	public static Void DebugLimits(Boolean selectAll, List<String> selectedLimits){
		if (!RLY_Behaviour.isActive()) return;

		if(selectAll) DebugBreak();
		
		Map<String, Integer> limitsMap = RLY_Behaviour.getLimits();
		
		if(!selectAll){
		    for(String limitName : selectedLimits){
		    	DebugLimit(limitsMap, limitName);
            } 
		}else{
		    for(String limitName : limitsMap.keySet()){
		       DebugLimit(limitsMap, limitName);
		    }
		}
		
	    for(String limitName : limitsMap.keySet()){
	        Integer limitValue = limitsMap.get(limitName);
	        lastLimits.put(limitName, limitValue);
	    }
        
		if(selectAll) DebugBreak();
	}

	private static Void DebugLimit(Map<String, Integer> limitsMap, String limitName){
		Integer limitValue = limitsMap.get(limitName);
		Integer deltaValue = limitValue - RLY_Behaviour.lastLimits.get(limitName);

		Debug(limitName, limitsMap.get(limitName) + ' (+' + deltaValue + ')');
	}
	
	private static Map<String, Integer> getLimits(){
	    Map<String, Integer> mapLimits = new Map<String, Integer>();

        mapLimits.put('AggregateQueries', 			Limits.getAggregateQueries());
        mapLimits.put('LimitAggregateQueries', 		Limits.getLimitAggregateQueries());
        mapLimits.put('AsyncCalls', 				Limits.getAsyncCalls());
        mapLimits.put('LimitAsyncCalls', 			Limits.getLimitAsyncCalls());
        mapLimits.put('Callouts', 					Limits.getCallouts());
        mapLimits.put('LimitCallouts', 				Limits.getLimitCallouts());
        mapLimits.put('CpuTime', 					Limits.getCpuTime());
        mapLimits.put('LimitCpuTime', 				Limits.getLimitCpuTime());
        mapLimits.put('DMLRows', 					Limits.getDMLRows());
        mapLimits.put('LimitDMLRows', 				Limits.getLimitDMLRows());
        mapLimits.put('DMLStatements', 				Limits.getDMLStatements());
        mapLimits.put('LimitDMLStatements', 		Limits.getLimitDMLStatements());
        mapLimits.put('EmailInvocations', 			Limits.getEmailInvocations());
        mapLimits.put('LimitEmailInvocations', 		Limits.getLimitEmailInvocations());
        mapLimits.put('FindSimilarCalls', 			Limits.getFindSimilarCalls());
        mapLimits.put('LimitFindSimilarCalls', 		Limits.getLimitFindSimilarCalls());
        mapLimits.put('FutureCalls', 				Limits.getFutureCalls());
        mapLimits.put('LimitFutureCalls', 			Limits.getLimitFutureCalls());
        mapLimits.put('HeapSize', 					Limits.getHeapSize());
        mapLimits.put('LimitHeapSize', 				Limits.getLimitHeapSize());
        mapLimits.put('MobilePushApexCalls', 		Limits.getMobilePushApexCalls());
        mapLimits.put('LimitMobilePushApexCalls', 	Limits.getLimitMobilePushApexCalls());
        mapLimits.put('Queries', 					Limits.getQueries());
        mapLimits.put('LimitQueries', 				Limits.getLimitQueries());
        mapLimits.put('QueryLocatorRows', 			Limits.getQueryLocatorRows());
        mapLimits.put('LimitQueryLocatorRows', 		Limits.getLimitQueryLocatorRows());
        mapLimits.put('QueryRows', 					Limits.getQueryRows());
        mapLimits.put('LimitQueryRows', 			Limits.getLimitQueryRows());
        mapLimits.put('QueueableJobs', 				Limits.getQueueableJobs());
        mapLimits.put('LimitQueueableJobs', 		Limits.getLimitQueueableJobs());
        mapLimits.put('RunAs', 						Limits.getRunAs());
        mapLimits.put('LimitRunAs', 				Limits.getLimitRunAs());
        mapLimits.put('SavepointRollbacks', 		Limits.getSavepointRollbacks());
        mapLimits.put('LimitSavepointRollbacks', 	Limits.getLimitSavepointRollbacks());
        mapLimits.put('Savepoints', 				Limits.getSavepoints());
        mapLimits.put('LimitSavepoints', 			Limits.getLimitSavepoints());
        mapLimits.put('SoslQueries', 				Limits.getSoslQueries());
        mapLimits.put('LimitSoslQueries', 			Limits.getLimitSoslQueries());
        
        return mapLimits;
	}

	private static void incrementIndex(String className, String methodName){
		methodsStartedDebug.add(className + '.' + methodName);
		updateData();
	}

	private static void decrementIndex(){
		methodsStartedDebug.remove(methodsStartedDebug.size()-1);
		updateData();
	}

	private static void updateData(){
		if(methodsStartedDebug.size() == 0){
			currentClassDebug = '';
			currentMethodDebug = '';
		}else{
			String keyString = methodsStartedDebug.get(methodsStartedDebug.size()-1);
			String[] explodeString = keyString.split('\\.');
			currentClassDebug = explodeString[0];
			currentMethodDebug = explodeString[1];
		}
	}
}
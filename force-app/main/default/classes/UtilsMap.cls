public without sharing class UtilsMap {
	
	public static Map<String, SObject> getMapFromListByUniqueKey(List<SObject> listObj, String uniqueKey) {
		if(listObj == null || listObj.size() == 0) {
			return new Map<String, SObject>();
		}

		Map<String, SObject> newMap = new Map<String, SObject>();

		for(SObject obj : listObj) {
			String objKey = obj != null && obj.get(uniqueKey) != null ? (String) obj.get(uniqueKey) : null;
            newMap.put(objKey, obj);
		}
		
		return newMap;
	}

	public static Map<String, List<SObject>> getMapFromList(List<SObject> listObj, String key) {
		if(listObj == null || listObj.size() == 0) {
			return new Map<String, List<SObject>>();
		}

		Map<String, List<SObject>> newMap = new Map<String, List<SObject>>();

		for(SObject obj : listObj) {
			String objKey = obj != null && obj.get(key) != null ? (String) obj.get(key) : null;
            if(newMap.get(objKey) != null) {
                newMap.get(objKey).add(obj);
            } else {
                newMap.put(objKey, new List<SObject>{obj});
            }
		}
		
		return newMap;
	}

	public static Map<Id, List<SObject>> getIdMapFromList(List<SObject> listObj, String key) {
		if(listObj == null || listObj.size() == 0) {
			return new Map<Id, List<SObject>>();
		}

		Map<Id, List<SObject>> newMap = new Map<Id, List<SObject>>();

		for(SObject obj : listObj) {
			Id objKey = obj != null && obj.get(key) != null ? (Id) obj.get(key) : null;
            if(newMap.get(objKey) != null) {
                newMap.get(objKey).add(obj);
            } else {
                newMap.put(objKey, new List<SObject>{obj});
            }
		}
		
		return newMap;
	}

	public static Set<String> getValueSetFromSObjectList(List<SObject> listObj, String fieldName) {
		if(listObj == null || listObj.size() == 0) {
			return new Set<String>();
		}

		Set<String> newSet = new Set<String>();
		for(SObject obj : listObj) {
			String value = obj != null && obj.get(fieldName) != null ? (String) obj.get(fieldName) : null;
			if(String.isNotBlank(value)) {
				newSet.add(value);
			}
		}

		return newSet;
	}

	public static Set<Id> getIdSetFromSObjectList(List<SObject> listObj, String fieldName) {
		if(listObj == null || listObj.size() == 0) {
			return new Set<Id>();
		}

		Set<Id> newSet = new Set<Id>();
		for(SObject obj : listObj) {
			Id value = obj != null && obj.get(fieldName) != null ? (Id) obj.get(fieldName) : null;
			if(String.isNotBlank(value)) {
				newSet.add(value);
			}
		}

		return newSet;
	}

	public static Map<String, Object> putAllIfNotPresent(Map<String, Object> source, Map<String, Object> destination) {
		source.keySet().removeAll(destination.keySet());
		destination.putAll(source);
		return destination;
	}

	

}
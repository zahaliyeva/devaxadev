public with sharing class TelephoneWithPrefixService {

    public static String defaultPrefix = '';

    public static Map<String, TelephoneWithPrefix> getTelephoneWithPrefixMapForTelephoneFields(Set<String> fields, SObject sobj) {
        TelephoneWithPrefixAdapter adapter = new TelephoneWithPrefixAdapter();
        Map<String, Object> fieldsToValue = sobj.getPopulatedFieldsAsMap();

        for(String field : fields) {
            if(fieldsToValue.get(field) != null) {
                adapter.addTelephoneNumber(field, (String) sobj.get(field));
            }
        }

        return adapter.getTelephoneWithPrefixByKeys();
    }

    public static Map<String, TelephoneWithPrefix> getChangedTelephoneWithPrefix(Map<String, TelephoneWithPrefix> oldValues, Map<String, TelephoneWithPrefix> newValues) {
        Map<String, TelephoneWithPrefix> changedTelephoneWithPrefix = new Map<String, TelephoneWithPrefix>();
        if(newValues != null) {
            for(String telephoneWithPrefixKey : newValues.keySet()) {
                if( (oldValues?.get(telephoneWithPrefixKey) == null && String.isNotBlank(newValues.get(telephoneWithPrefixKey).telephoneNumber)) || oldValues?.get(telephoneWithPrefixKey) != newValues.get(telephoneWithPrefixKey)) {
                    changedTelephoneWithPrefix.put(telephoneWithPrefixKey, newValues.get(telephoneWithPrefixKey));
                }
            }
        }
        return changedTelephoneWithPrefix;
    }

     public static Map<String, TelephoneWithPrefix> setDefaultPrefixIfNull(Map<String, TelephoneWithPrefix> telephoneWithPrefixes) {
        for(String twpKey : telephoneWithPrefixes.keySet()) {
            
            if(checkIfPrefixIsNull(telephoneWithPrefixes.get(twpKey).prefix)) {
                telephoneWithPrefixes.put(twpKey, new TelephoneWithPrefix(defaultPrefix,telephoneWithPrefixes.get(twpKey).telephoneNumber));
            }
        }

        return telephoneWithPrefixes;
    }

    public static Boolean checkIfPrefixIsNull(String prefix) {
        return String.isBlank(prefix) || prefix == 'null' || prefix == 'undefined';
    }

    public static String getValidPrefix(String prefix) {
        return checkIfPrefixIsNull(prefix) ? defaultPrefix : prefix;
    }

    
}
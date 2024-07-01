public without sharing class FilterValuesService {
    private Map<Id, FilterValues__c> filterValues = new Map<Id, FilterValues__c>();
    private Map<Id, FilterValues__c> filterValuesFiltered = new Map<Id, FilterValues__c>();

    private Map<String, Set<Id>> sObjectsToSetID = new Map<String, Set<Id>>();
    private Map<String, Set<Id>> fieldsToSetID = new Map<String, Set<Id>>();
    private Map<String, Set<Id>> keysToSetID = new Map<String, Set<Id>>();

    public FilterValuesService(String category) {
        this.filterValues = new Map<Id, FilterValues__c>([SELECT Id, Category__c, SObject__c, Field__c, Key__c, Value__c FROM FilterValues__c WHERE Category__c = :category]);
        this.filterValuesFiltered = this.filterValues.deepClone();

        for(FilterValues__c filterValue : this.filterValues.values()) {
            setSObjectSet(filterValue);
            setFieldsSet(filterValue);
            setKeysSet(filterValue);
        }

    }

    public FilterValuesService reset() {
        this.filterValuesFiltered = this.filterValues.deepClone();
        return this;
    }

    public FilterValuesService filterBySObject(Set<String> sObjects) {
        Set<Id> idToRetain = new Set<Id>();
        for(String sObj : sObjects) {
            if(sObjectsToSetID != null && sObjectsToSetID.get(sObj) != null) { 
                idToRetain.addAll(sObjectsToSetID.get(sObj));
            }
        }
        filterValuesFiltered.keySet().retainAll(idToRetain);
        return this;
    }

    public FilterValuesService filterByField(Set<String> fields) {
        Set<Id> idToRetain = new Set<Id>();
        for(String field : fields) {
            if(fieldsToSetID != null && fieldsToSetID.get(field) != null) {
                idToRetain.addAll(fieldsToSetID.get(field));
            }
        }
        filterValuesFiltered.keySet().retainAll(idToRetain);
        return this;
    }

    public FilterValuesService filterByKey(Set<String> keys) {
        Set<Id> idToRetain = new Set<Id>();
        for(String key : keys) {
            if(keysToSetID != null && keysToSetID.get(key) != null) {
                idToRetain.addAll(keysToSetID.get(key));
            }
        }
        filterValuesFiltered.keySet().retainAll(idToRetain);
        return this;
    }


    public FilterValuesService filterBySObject(String sObj) {
        return filterBySObject(new Set<String>{sObj});
    }

    public FilterValuesService filterByField(String field) {
        return filterByField(new Set<String>{field});
    }

    public FilterValuesService filterByKey(String key) {
        return filterByKey(new Set<String>{key});
    }

    public String getValueByKey(String key) {
        for( FilterValues__c filterValue : filterValuesFiltered.values()) {
            if(filterValue.Key__c == key) {
                return filterValue.Value__c;
            }
        }
        return null;
    }


    public Set<String> getValues() {
        if(filterValuesFiltered == null || filterValuesFiltered.size() == 0) {
            return new Set<String>();
        }
        return UtilsMap.getValueSetFromSObjectList(filterValuesFiltered.values(), 'Value__c');
    }

    public Set<String> getValuesAndReset() {
        Set<String> res = new Set<String>();
        if(filterValuesFiltered == null || filterValuesFiltered.size() == 0) {
            return res;
        }
        res = UtilsMap.getValueSetFromSObjectList(filterValuesFiltered.values(), 'Value__c');

        reset();

        return res;
    }






    private void setSObjectSet(FilterValues__c filterValue) {
        if(filterValue.SObject__c != null) {
            if(sObjectsToSetID.get(filterValue.SObject__c) != null ) {
                sObjectsToSetID.get(filterValue.SObject__c).add(filterValue.Id);
            } else {
                sObjectsToSetID.put(filterValue.SObject__c, new Set<Id>{filterValue.Id});
            }
        }
    }

    private void setFieldsSet(FilterValues__c filterValue) {
        if(filterValue.Field__c != null) {
            if(fieldsToSetID.get(filterValue.Field__c) != null ) {
                fieldsToSetID.get(filterValue.Field__c).add(filterValue.Id);
            } else {
                fieldsToSetID.put(filterValue.Field__c, new Set<Id>{filterValue.Id});
            }
        }
    }

    private void setKeysSet(FilterValues__c filterValue) {
        if(filterValue.Key__c != null) {
            if(keysToSetID.get(filterValue.Key__c) != null ) {
                keysToSetID.get(filterValue.Key__c).add(filterValue.Id);
            } else {
                keysToSetID.put(filterValue.Key__c, new Set<Id>{filterValue.Id});
            }
        }
    }
}
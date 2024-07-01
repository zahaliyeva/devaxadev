public with sharing class TelephoneWithPrefixAdapter {

    private Map<String, TelephoneWithPrefix> telephoneWithPrefixByKeys = new Map<String, TelephoneWithPrefix>();
    private Map<String, String> telephoneNumberByKeys = new Map<String, String>();

    private List<String> prefixList = new List<String>(TelephoneNumberPrefix__c.getAll().keySet());
    
    
    /**********  Constructors ***********/
    public TelephoneWithPrefixAdapter() {

    }  
    
    public TelephoneWithPrefixAdapter(Map<String, String> telephoneNumberByKeys) {
        addTelephoneNumber(telephoneNumberByKeys);
    }  

    public TelephoneWithPrefixAdapter(String key, String telephoneNumber) {
        addTelephoneNumber(key, telephoneNumber);
    }

    public TelephoneWithPrefixAdapter(Map<String, TelephoneWithPrefix> telephoneWithPrefixByKeys) {
        addTelephoneWithPrefix(telephoneWithPrefixByKeys);
    }

    public TelephoneWithPrefixAdapter(String key, TelephoneWithPrefix telephoneWithPrefix) {
        addTelephoneWithPrefix(key, telephoneWithPrefix);
    }



    /********** GETTERS  *************************/

    public Map<String, TelephoneWithPrefix> getTelephoneWithPrefixByKeys () {
        return this.telephoneWithPrefixByKeys;
    }

    public TelephoneWithPrefix getTelephoneWithPrefix(String key) {
        return this.telephoneWithPrefixByKeys.get(key);
    }

    public Map<String, String> getTelephoneNumberByKeys () {
        return this.telephoneNumberByKeys;
    }

    public String getTelephoneNumber(String key) {
        return this.telephoneNumberByKeys.get(key);
    }


    /**********  Add Telephone to Maps ***********/

    public TelephoneWithPrefixAdapter addTelephoneNumber(String key, String telephoneNumber) {
        TelephoneWithPrefix telephoneWithPrefix = convertTelephoneNumberToTelephoneWithPrefix(telephoneNumber);
        telephoneWithPrefixByKeys.put(key, telephoneWithPrefix);
        telephoneNumberByKeys.put(key, telephoneNumber);
        return this;
    }

    public TelephoneWithPrefixAdapter addTelephoneNumber(Map<String, String> telephoneNumberByKeys) {
        for(String key : telephoneNumberByKeys.keySet()) {
            addTelephoneNumber(key, telephoneNumberByKeys.get(key));
        }
        return this;
    }

   public TelephoneWithPrefixAdapter addTelephoneWithPrefix(Map<String, TelephoneWithPrefix> telephoneWithPrefixByKeys) {
        for(String key : telephoneWithPrefixByKeys.keySet()) {
            addTelephoneWithPrefix(key, telephoneWithPrefixByKeys.get(key));
        }
        return this;
    }

    public TelephoneWithPrefixAdapter addTelephoneWithPrefix(String key, TelephoneWithPrefix telephoneWithPrefix) {
        telephoneWithPrefixByKeys.put(key, telephoneWithPrefix);
        telephoneNumberByKeys.put(key, convertTelephoneWithPrefixToTelephoneNumber(telephoneWithPrefix));
        return this;
    }



    /**********  Convertion Methods ***********/

    private TelephoneWithPrefix convertTelephoneNumberToTelephoneWithPrefix(String telephoneNumber) {
        
        if(String.isNotBlank(telephoneNumber)) {
            for(String prefix : prefixList ) {
                if(telephoneNumber?.startsWithIgnoreCase(prefix)) {
                    return new TelephoneWithPrefix(prefix, telephoneNumber.substringAfter(prefix));
                }
            }
        }

        return new TelephoneWithPrefix(TelephoneWithPrefixService.defaultPrefix, telephoneNumber);
    }

    private String convertTelephoneWithPrefixToTelephoneNumber(TelephoneWithPrefix telephoneWithPrefix) {
        return telephoneWithPrefix.prefix + telephoneWithPrefix.telephoneNumber;
    }  
    
}
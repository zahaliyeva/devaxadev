public with sharing class TelephoneWithPrefix {
    public String prefix = '';
    public String telephoneNumber = '';
    

    public TelephoneWithPrefix(String prefix, String telephoneNumber) {
        this.prefix = String.isNotBlank(prefix) ? prefix : '';
        this.telephoneNumber = String.isNotBlank(telephoneNumber) ? telephoneNumber : '';
    }

    public Boolean equals(Object toComp) {
        if( toComp instanceof TelephoneWithPrefix) {
            TelephoneWithPrefix toCompare = (TelephoneWithPrefix) toComp;
            return this.prefix == toCompare.prefix && this.telephoneNumber == toCompare.telephoneNumber;
        }
        return false;
    }

    public String getPrefix() {
        return TelephoneWithPrefixService.getValidPrefix(prefix);
    }
}
public class FieldValidator {

    public static Boolean validateFieldValue(String qualifiedApiName, String fieldValue) {
        //System.debug('$$$ - qualifiedApiName: ' + qualifiedApiName);
        //System.debug('$$$ - emailAddress: ' + fieldValue);
        
        Boolean isValid = false;
        List<Field_Validator_Setting__mdt> settings =  [
            SELECT Id, 
            	QualifiedApiName, 
            	Active__c, 
            	RegEx__c 
            FROM Field_Validator_Setting__mdt 
            WHERE QualifiedApiName = :qualifiedApiName
            AND Active__c = true 
            LIMIT 1
        ];
        
        if (!settings.isEmpty()) {
            String regEx = settings.get(0).RegEx__c;
            isValid = Pattern.matches(regEx, fieldValue);
            //System.debug('$$$ - isValid: ' + isValid);
        } else {
            isValid = true;
        }
        
        return isValid;
    }
    
    public static List<Field_Validator_Setting__mdt> getListOfRegularExpressions() {
        
        List<Field_Validator_Setting__mdt> settings =  [
            SELECT //Id, 
            	QualifiedApiName, 
            	//Active__c, 
            	RegEx__c 
            FROM Field_Validator_Setting__mdt 
            WHERE Active__c = true 
        ];
		
        return settings;
    }
    
}
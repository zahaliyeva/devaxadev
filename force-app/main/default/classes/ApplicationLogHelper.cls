public class ApplicationLogHelper {

    public static void ERROR(String apexClass,  String errorMessage, String errorDetail){
        ApplicationLog__c log = new ApplicationLog__c(Type__c = 'Error', ApexClass__c = apexClass);
        log.Message__c = trimTo(errorMessage, 255);
        log.CompleteMessage__c = trimTo(errorMessage,131072);
		log.Detail__c = trimTo(errorDetail,131072);
        Database.SaveResult result = Database.insert(log, false, AccessLevel.SYSTEM_MODE);
        if (!result.isSuccess()) {
            System.debug('ApplicationLog ERROR, l\'inserimento del record di tracciamento errore è fallito');
        }
    }

    public static void INFO(String apexClass, String errorMessage, String errorDetail){
        ApplicationLog__c log = new ApplicationLog__c(Type__c = 'Info', ApexClass__c = apexClass);
        log.Message__c = trimTo(errorMessage, 255);
        log.CompleteMessage__c = trimTo(errorMessage,131072);
		log.Detail__c = trimTo(errorDetail,131072);
        Database.SaveResult result = Database.insert(log, false, AccessLevel.SYSTEM_MODE);
        if (!result.isSuccess()) {
            System.debug('ApplicationLog ERROR, l\'inserimento del record di tracciamento errore è fallito');
        }
    }


    private static String trimTo(String stringToTrim, Integer maxSize){
		if(stringToTrim != null && stringToTrim.length() > maxSize ) {
			 stringToTrim = stringToTrim.substring(0, maxSize);
		 }
		return stringToTrim;
	}
    
    public static void LogErrors(String apexClass, List<ErrorWrapper> Errors){
        List<ApplicationLog__c> Logs = new List<ApplicationLog__c>();

        for(ErrorWrapper e : Errors){

            ApplicationLog__c log = new ApplicationLog__c(Type__c = 'Error', ApexClass__c = apexClass);
            log.Message__c = trimTo(e.getErrorMessage(), 255);
            log.Detail__c = trimTo(e.getErrorDetail(),131072);
            log.CompleteMessage__c = trimTo(e.getErrorMessage(),131072);
            Logs.add(log);

		}
        Database.SaveResult[] results = Database.insert(Logs, false, AccessLevel.SYSTEM_MODE);
        for (Database.SaveResult r: results) {
        if (!r.isSuccess()) {
            System.debug('ApplicationLog ERROR, l\'inserimento del record di tracciamento errore è fallito');
            }
        }
    }

    public class ErrorWrapper{
        private String errorMessage;
        private String errorDetail;
        public ErrorWrapper(String errorMessage, String errorDetail){
            this.errorMessage = errorMessage;
            this.errorDetail = errorDetail;
        }
        public String getErrorMessage(){
            return errorMessage;
        }

        public String getErrorDetail(){
            return errorDetail;
        }

    }
}
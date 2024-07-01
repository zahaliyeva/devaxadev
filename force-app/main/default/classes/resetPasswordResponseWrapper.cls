public without sharing class resetPasswordResponseWrapper {
    
    public List<EmailWrapper> emailList;
    public String ExceptionMessage;
    public String status;
    public String detail;
    public String code; 

    public String errorCode;
    public String errorMessage;
    public String errorDetail;
  
    
    public class EmailWrapper {
        @AuraEnabled public String email;
    }
}
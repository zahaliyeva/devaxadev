public without sharing class resetPasswordRequestWrapper {
    
    Public String personId;
    Public String Email;

    public resetPasswordRequestWrapper(String personId){
        this.personId = personId;
    }

    public resetPasswordRequestWrapper(String personId, String Email){
        this.personId = personId;
        this.Email = Email;
    }
}
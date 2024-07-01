/**************************************************************************************
Apex Trigger Name: User_Language_Update 
Version     : 1.0 
Created Date    : 18 NOV 2013
Function    : This Trigger is used to update the User Language custom field based on the value from standard language field.
Modification Log :
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Santhosh Kumar              11/18/2013              Original Version
*************************************************************************************/

trigger User_Language_Update on User (before insert, before update) {
    if(Trigger.isUpdate){
        for (User usr: Trigger.new) {
            //picks up the old value of the Sector field
            User oldUsr = Trigger.oldMap.get(usr.ID);
            //compare the old and new value of the sector field
            if(usr.LanguageLocaleKey != oldUsr.LanguageLocaleKey){
                if(usr.LanguageLocaleKey == 'en_US'){
                    usr.User_Language__c = 'English';
                }
                else if(usr.LanguageLocaleKey == 'fr'){
                    usr.User_Language__c = 'French';
                }
                else if (usr.LanguageLocaleKey == 'nl_NL'){
                    usr.User_Language__c = 'Dutch';
                }
                 else if (usr.LanguageLocaleKey == 'it'){
                    usr.User_Language__c = 'Italian';
                }
                else {
                    usr.User_Language__c = usr.LanguageLocaleKey;
                }
            }
        }
    }
    
    if(Trigger.isInsert){
        for (User usr: Trigger.new) {
                if(usr.LanguageLocaleKey == 'en_US'){
                    usr.User_Language__c = 'English';
                }
                else if(usr.LanguageLocaleKey == 'fr'){
                    usr.User_Language__c = 'French';
                }
                else if (usr.LanguageLocaleKey == 'nl_NL'){
                    usr.User_Language__c = 'Dutch';
                }
                else if (usr.LanguageLocaleKey == 'it'){
                    usr.User_Language__c = 'Italian';
                }
                else {
                    usr.User_Language__c = usr.LanguageLocaleKey;
                }
        }
    }
}
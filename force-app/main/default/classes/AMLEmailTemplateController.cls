/** 
* @author	Reply
* @date	07/2023
* @description costruzione oggetti per il component
*/
public with sharing class AMLEmailTemplateController {

 /**
 * @description variabile utilizata cercare gli oggetti nelle query
 */
    public static id caseId{get;set;} 
    
    /** 
    * @return Case
    * @description var utilizzata nel component
    */   
    public Case getThisCase(){    
        Case ThisCase = [SELECT id, suppliedEmail, Contact.Name FROM Case WHERE id =:caseId WITH SECURITY_ENFORCED LIMIT 1];
        return ThisCase;
    }
    
}
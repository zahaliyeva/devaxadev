/** 
* @author	Reply
* @date	04/2023
* @description costruzione oggetti per il component
*/
public with sharing class QAdVEmailTemplateController {

 /**
 * @description variabile utilizata cercare gli oggetti nelle query
 */
    public static id caseId{get;set;} 
	
    /** 
    * @return DocumentAccount__c
    * @description var utilizzata nel component
    */    
    public DocumentAccount__c getDocumentAccountRichiedente(){    
            DocumentAccount__c DocumentAccountRichiedente = [SELECT Name, Digital_Link__c, FirstName__c, SurnameCompanyName__c FROM DocumentAccount__c WHERE CaseId__c =: caseId AND Role__c INCLUDES ('Richiedente') WITH SYSTEM_MODE LIMIT 1];
        return DocumentAccountRichiedente;
    }
    
    /** 
    * @return List<DocumentAccount__c>
    * @description var utilizzata nel component
    */   
    public List<DocumentAccount__c> getDocumentAccounts(){     
        List<DocumentAccount__c> DocumentAccounts = [SELECT Name, Digital_Link__c, FirstName__c, SurnameCompanyName__c, (select id, toLabel(Document_Type__c), toLabel(SelfStatus__c), RejectComment__c, DocumentAccountId__c, DocumentAccountId__r.id  from Document_Checklist_Items__r)  FROM DocumentAccount__c WHERE CaseId__c=: caseId  AND Role__c INCLUDES ('Soggetto') WITH SYSTEM_MODE];
        return DocumentAccounts;
    }
    
    /** 
    * @return Case
    * @description var utilizzata nel component
    */   
    public Case getThisCase(){    
        Case ThisCase = [SELECT id, suppliedEmail, toLabel(Tipo_Operazione__c), NumeroPolizza__c, NumeroPolizzaFiglia__c FROM Case WHERE id =:caseId WITH SYSTEM_MODE LIMIT 1];
        return ThisCase;
    }
    
    /*public List<DocumentChecklistItem__c> getDCItemList(){
        List<DocumentChecklistItem__c> DCItemList = [SELECT id, toLabel(Document_Type__c), toLabel(SelfStatus__c), RejectComment__c, DocumentAccountId__c, DocumentAccountId__r.id   FROM DocumentChecklistItem__c WHERE CaseId__c =: caseId];
        return DCItemList;
    }*/

    
    

}
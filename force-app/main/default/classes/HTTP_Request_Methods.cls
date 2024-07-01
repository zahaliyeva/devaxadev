/** 
* @author	Deloitte
* @date	Unknown
* @description GaranzieView.Page controller on integration call out
*/
@SuppressWarnings('PMD.ApexCRUDViolation')// WITH SYSTEM_MODE accepted
public with sharing class HTTP_Request_Methods {
    /**
     * @description getInsurancePolicy GaranzieView.Page 
     * @return queriedInsurance_Policy polizza selezionata nel vista garanzie
     */
    public static InsurancePolicy__c getInsurancePolicy(){
    string apexInsurance_PolicyId = ApexPages.currentPage().getParameters().get('id');
    InsurancePolicy__c queriedInsurance_Policy = [SELECT id, PolicyID__c, CUID__r.RecordType.DeveloperName, CUID__r.RecordType.Name, CUID__r.AAI_Codice_fiscale__c, CUID__r.AAI_Partita_IVA__c, CUID__r.Fiscal_ID__c, CUID__r.Partita_IVA__c 
        FROM InsurancePolicy__c 
        where id = :apexInsurance_PolicyId WITH SYSTEM_MODE limit 1];
    system.debug( System.LoggingLevel.DEBUG ,'*******queriedInsurance_Policy for VFP - '+queriedInsurance_Policy);    
    return  queriedInsurance_Policy;
        
    }
    
}
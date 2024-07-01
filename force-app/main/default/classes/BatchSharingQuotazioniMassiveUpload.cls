/*------------------------------------------------------------------------
Author:        Francesca Marchese
Company:       Deloitte
Class:         BatchSharingQuotazioniMassiveUpload
Description:   This batch's purpose is to calculate quotazioni's sharing after 
               massively uploading of Web Lead

History

11/01/2018     Created - F.M.
----------------------------------------------------------------------------*/

global class BatchSharingQuotazioniMassiveUpload implements Database.Batchable<sObject>//, 
{


    // query
    public List<Id> ListIdLeads;
    public List<Id> IdLeads; 
    public string query;
    
    global BatchSharingQuotazioniMassiveUpload (List<Id> IdLeads)

    {
       ListIdLeads = IdLeads;
       system.debug('****************ListIdLeads'+ListIdLeads);
       query = 'SELECT Id, Agency_Code__c, Lead__c FROM Quotazione__c WHERE Lead__c IN :ListIdLeads';
    }

    //global BatchSharingQuotazioniMassiveUpload(List<sObject> IdLeads) {}

   global Database.QueryLocator start(Database.BatchableContext BC) 
        
    {        
        return Database.getQueryLocator(query);        
    } 

    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    
    {    
          system.debug('**************************SCOPE:QUOTAZIONI'+scope);
        if(scope.size()>0){
            QuotationManagement.ShareWithFullAgency(scope); 
        }
    }
 

    global void finish(Database.BatchableContext BC) {}
    
 }
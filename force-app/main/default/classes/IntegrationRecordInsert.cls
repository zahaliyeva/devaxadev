/*----------------------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         IntegrationRecordInsert
Description:   Apex class used to allow the creation of new logs into the 
               object IE_Integration_Record__c in case of multiple concurrent callouts 

History

16/11/2017     Created - Marco Moscatelli.
-----------------------------------------------------------------------------------------*/
@RestResource(urlMapping='/InsertIR/*')
global without sharing class IntegrationRecordInsert
{
    @HttpPost
    global static void create()
    {
        System.RestRequest req = RestContext.request;

        String IERecord = req.requestBody.toString();

        system.debug('##IERecord: '+IERecord);

        IE_Integration_Record__c IErec = (IE_Integration_Record__c)JSON.deserialize(IERecord, IE_Integration_Record__c.class);

        insert IErec;

        system.debug('##IErec: '+IErec);
    }
}
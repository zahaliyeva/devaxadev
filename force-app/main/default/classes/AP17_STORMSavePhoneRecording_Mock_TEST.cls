/*----------------------------------------------------------------------------------
Author:        Moscatelli Marco
Company:       Deloitte
Class:         AP17_STORMSavePhoneRecording_Mock_TEST
Description:   Class which simulates the response of the webservice exposed 
               by STORM that is used to archive or delete a specific call recording 


History
01/03/2018    Moscatelli Marco: created
-----------------------------------------------------------------------------------*/
@isTest
public without sharing class AP17_STORMSavePhoneRecording_Mock_TEST implements HttpCalloutMock 
{
    public String TestCase;

    public HTTPResponse respond(HTTPRequest req)
    {

        // Create a fake response.
        HttpResponse res = new HttpResponse();
        // Set response values 
        string myJSON = '';
        
        if (TestCase == 'test_one') 
        {
            myJSON = '{"Key":"2221313","CallDateTime":"2018-02-14 10:21:02","Save":"true"}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(myJSON); 
            res.setStatusCode(200);
        }
        else if (TestCase=='test_two')
        {
            myJSON = '{"error":"errorews"}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(myJSON); 
            res.setStatusCode(300);
       }
        // return response.
        return res;
    }

}
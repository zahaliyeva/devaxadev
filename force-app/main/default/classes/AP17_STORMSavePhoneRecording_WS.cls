/*------------------------------------------------------------------------------------------------
Author:        Moscatelli Marco
Company:       Deloitte
Class:         AP17_STORMSavePhoneRecording_WS
Description:   Class used to request STORM to archive or delete a specific call recording

History
15/02/2018    Moscatelli Marco: created
--------------------------------------------------------------------------------------------------*/
global class AP17_STORMSavePhoneRecording_WS
{
	webservice static Boolean SaveRecording(String ChiamataID, String TOSave)
	{ /* PURE IT COMMENTO METODI
        String ChiamataTime;
        String ChiamataUniqueID;
        Storico_Chiamate__c ChiamataRecord;
        IE_Configuration__c myConfig;
        string path;
        string certificateName;
        Boolean SuccededUpdate = true;
        String jsonS='';
        String Key ='';

        ChiamataRecord = [SELECT Call_ID__c,CallDateTime__c,PhoneCallIDB__c FROM Storico_Chiamate__c WHERE Id =: ChiamataID LIMIT 1];
        ChiamataTime = ChiamataRecord.CallDateTime__c;
        //ChiamataUniqueID = ChiamataRecord.Call_ID__c;
        ChiamataUniqueID = ChiamataRecord.PhoneCallIDB__c;
        //OAVERSANO 21/12/2018 : FIX -- START
        //Key = [SELECT Value__c FROM AAI_Code_Variables__c WHERE Name = 'STORMRecSaving_AuthKEY' limit 1].Value__c;
        List<AAI_Code_Variables__c> aaicode = [SELECT Value__c FROM AAI_Code_Variables__c WHERE Name = 'STORMRecSaving_AuthKEY' limit 1];
        if(!aaicode.isEmpty())
        {
            Key = aaicode[0].Value__c;
        }
       
        //myConfig = [SELECT Id,EndPoint__c, Certificate__c,Insert_IR_WS__c,log_records_flag__c FROM IE_Configuration__c WHERE Name ='STORM Save Recording' limit 1 ]  ;
  		List<IE_Configuration__c> confList = [SELECT Id,EndPoint__c, Certificate__c,Insert_IR_WS__c,log_records_flag__c FROM IE_Configuration__c WHERE Name ='STORM Save Recording' limit 1 ];
        if(!confList.isEmpty())
        {
            myConfig = confList[0];
        }
        
            
        if(myConfig!=null)
        {
            path = myConfig.Endpoint__c;
            certificateName = myConfig.Certificate__c;
    
            if(String.isBlank(Key)||
               String.isBlank(ChiamataUniqueID)||
               String.isBlank(ChiamataTime))
            {
                SuccededUpdate = false;
            }
            else
            {
                JSONGenerator gen = JSON.createGenerator(true); 
                gen.writeStartObject();
                gen.writeStringField('Key',Key);
                gen.writeStringField('CallID',ChiamataUniqueID);
                gen.writeStringField('Save',TOSave); 
                gen.writeStringField('CallDateTime',ChiamataTime);
                gen.writeEndObject(); 
    
                jsonS = gen.getAsString();
    
                SuccededUpdate = makeRequest(path,jsonS,certificateName,myConfig,ChiamataID,TOSave);	
            }
        } //OAVERSANO 21/12/2018 : FIX -- END
        return SuccededUpdate;
        PURE IT COMMENT CLOSURE*/
        return null;
	}

    global static Boolean makeRequest(String url, String body, String certificateName, IE_Configuration__c myConfig, String ChiamataID, String TOSave) 
    {/* PURE IT COMMENTO METODI
        String errorString;
    	IE_Integration_Record__c IR = new IE_Integration_Record__c(IE_Configuration__c=myConfig.Id);
        HttpResponse response = new HttpResponse();
        response = null;
        HttpRequest req = new HttpRequest();
        Boolean SuccededUpdate = true; 
        String PartnerUrl;
  
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader ('Content-Type', 'application/json');
        req.setHeader('Connection','Keep-Alive');
        req.setTimeout(2 * 60 * 1000);
        req.setBody(body);
        system.debug('+++++myReq'+req);
        IR.RequestBody__c=body.normalizeSpace();

        try
        {
            PartnerUrl = [SELECT Value__c FROM AAI_Code_Variables__c WHERE Name = 'AccountEdit_IRSavingLink' limit 1].Value__c;
        }
        catch(exception e)
        {
            system.debug('#Error: '+e);
        }  

        if(!Test.isRunningTest() && String.isNotBlank(certificateName))
        { 
            req.setClientCertificateName(certificateName);
        }
        
        try
        {
            Http http = new Http();
            response = http.send(req);
            IR.Status__c = response.getStatus();
            IR.ResponseBody__c=response.getBody().normalizeSpace();

            if(response.getStatusCode() != 200)
            {
	            JSONParser parser = JSON.createParser(response.getBody());

	            while (parser.nextToken() != null)
	            {
                    system.debug('#parser: '+parser.getText());

	            	if(parser.getText()=='Message')
                    {
                        parser.nextToken();
                        errorString = parser.getText();
                        IR.ErrorMessage__c=errorString;
                    }
	            }
                SuccededUpdate = false;       		
        	}
            else
            {
                Storico_Chiamate__c ChiamataToUpd = new Storico_Chiamate__c(Id=ChiamataID,Call_Historicised__c=(TOSave=='true')?true:false);
                update ChiamataToUpd;
            }
           
            System.debug('response: ' + response);
            System.debug('body: ' + response.getBody());
        
            if(myConfig.log_records_flag__c)
            {
                if(myConfig.Insert_IR_WS__c)
                {
                    String IRtoString = Json.serializePretty(IR);
                    HttpRequest reqIR = new HttpRequest();
                    Http HTTPtoRequest= new Http();
                    reqIR.setMethod('POST');
                    reqIR.setHeader('content-type', 'text/html');

                    String urlIR='';

                    system.debug((Network.communitiesLanding()).geturl());


                    if(Network.communitiesLanding() <> null)
                    {
                        urlIR = ((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/apexrest/InsertIR');
                    }
                    else
                    {
                        urlIR = (PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'services/apexrest/InsertIR';
                    }  

                    system.debug('Response URL'  +urlIR);   
                    reqIR.setEndpoint(urlIR);
                    reqIR.setbody(IRtoString);   
                    reqIR.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
                   
                    if(!Test.isRunningTest())
                        HTTPResponse resp = HTTPtoRequest.send(reqIR);
                }
                else
                    insert IR;
            }  
        } 

		catch(System.CalloutException e)
		{
            system.debug ('---exception '+e);
            IR.Status__c='FAILED';
            IR.ErrorMessage__c= e.getStackTraceString();
            SuccededUpdate = false;

            if(myConfig.log_records_flag__c)
            {
                if(myConfig.Insert_IR_WS__c)
                {            
                    String IRtoString = Json.serializePretty(IR);
                    HttpRequest reqIR = new HttpRequest();
                    Http HTTPtoRequest= new Http();
                    reqIR.setMethod('POST');
                    reqIR.setHeader('content-type', 'text/html');
                    system.debug('##URL: '+System.URL.getSalesforceBaseUrl());
                    
                    String urlIR = '';

                    if(Network.communitiesLanding() <> null)
                    {
                        urlIR = ((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/apexrest/InsertIR');
                    }
                    else
                    {
                        urlIR =(PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'services/apexrest/InsertIR';
                    } 
                    system.debug('Response URL'  +urlIR);   
                    reqIR.setEndpoint(urlIR);
                    reqIR.setbody(IRtoString);   
                    reqIR.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
                    
                    if(!Test.isRunningTest())
                        HTTPResponse resp = HTTPtoRequest.send(reqIR);
                }
                else
                    insert IR;
            }
        }       
        return SuccededUpdate; PURE IT COMMENT CLOSURE */ return null;
    }	
}
/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         IE_Engine
Description:   The actual IntegrationEngine
    Based on the objects
    -IE_CR2PH_junction__c
    -IE_Configuration__c
    -IE_Integration_Record__c
    -IE_Placeholder__c
    Performs the following
    +Compiles a request
    +send a request
    +Compile the response onto a JSON string
History
 -30/12/2015   Davide Fabris - Created
 -13/12/2016   Davide Fabris - Included Named Credentials and http methods
 -------------------------------------------------------------------------------------------------------------------------
* Id 003
 * Initiative Lead Management Sprint 45: Manage REST callout
 * date: 19/06/2017
 * author: Francesca Marchese
----------------------------------------------------------------------------*/

public without sharing class IE_Engine{
//The Attributes
    public IE_Integration_Record__c IR; //The instance of the single integration
    public List<IE_Placeholder__c> PHs;  //The involved placeholders
    public IE_Configuration__c CR;      //The corresponding configuration
    public List<IE_CR2PH_junction__c> JRs;//The junctionRecords between the config and the placeholders
    public List<ID> scopeIDs;             //The list of IDs to be used as source of the integration
    public String CompiledXML;          //the XML compiled to be set as body of the http request
    public String TemplateRequest;   //the Template fetched from the Configuration record
// the attributes used when compiling and receiving the response
    public HttpRequest myReq;           
    public HTTPResponse RawResponse;

    //MOSCATELLI_M 29/01/2018: Bugfix ---START 
    //public String PartnerUrl = [Select BaseURL__c from User where id=:UserInfo.getUserId() limit 1].BaseURL__c;
    public String PartnerUrl='';
    //MOSCATELLI_M 29/01/2018: Bugfix ---END
    
//the JSON object obtained from the XML response. for each tag  the corresponding values are stored
    public string JSONResponse;
    //)public Map<String,list<String>> mapResponse;
    
// the compiler  this is just the interface, must be populated with actual implementation
    private IE_RequestCompiler ReqCompiler; 
    
// the response parser  this is just the interface, must be populated with actual implementation
    private IE_ResponseParser  RespParser; 

//to throw exception if the compiler is not found
    public class NameException extends Exception{} //to throw NameExceptions
    
//////////////////////////////THE METHODS /////////////////////////////////////////77
//Constructor that given the Integration record retrieves all the consequent objects    
    public IE_Engine(IE_Integration_Record__c IRinput) {
        system.debug('+++++STARTCONSTRUCTOR+++++');
        this.IR=IRinput;
        system.debug('+++++The Integration Record--->'+this.IR);
        
        //Sorting out the scopeIDs
        this.scopeIDs = new List<Id>();
        if (!String.isempty(IRinput.ScopeID__c)) {
            for (String thisIDstring: IRinput.ScopeID__c.split(';')) {
                scopeIDs.add(Id.valueOf(thisIDstring));
            }
        }
        system.debug('+++++The scopeIDs --->'+this.scopeIDs);

        //Sorting out the configuration
        this.CR = [SELECT Id, Name, Request_compiler__c,Response_parser__c,Type__c,Certificate__c,EndPoint__c,NameSpacePrefix1__c,NameSpacePrefix2__c,NameSpacePrefix3__c,NameSpaceUri1__c,NameSpaceUri2__c,NameSpaceUri3__c,HTTPMethod__c,Named_Credential_Name__c,Named_Credential_Path__c, log_records_flag__c,Timeout__c,Insert_IR_WS__c from IE_Configuration__c where Id=:IR.IE_Configuration__c limit 1];
        system.debug('+++++The configuration --->'+this.CR);

        //Sorting out the compiler
        try {
            this.ReqCompiler = (IE_RequestCompiler)Type.forName(CR.Request_compiler__c).newInstance();
            system.debug('++++++ REQUEST COMPILER SET');
        } catch (exception e) {
            system.debug('++++++Could not find the REQUEST COMPILER-->'+CR.Request_compiler__c);
            throw new NameException(CR.Request_compiler__c);
        }

        //MOSCATELLI_M 29/01/2018: Bugfix ---START
        try
        {
            PartnerUrl = [SELECT Value__c FROM AAI_Code_Variables__c WHERE Name = 'AccountEdit_IRSavingLink' limit 1].Value__c;
        }
        catch(exception e)
        {
            system.debug('#Error: '+e);
        }        
        //MOSCATELLI_M 29/01/2018: Bugfix ---END
        
        //Sorting out the parser
        try {
            this.RespParser = (IE_ResponseParser)Type.forName(CR.Response_parser__c).newInstance();
            system.debug('++++++RESPONSE PARSER SET');
        } catch (exception e) {
            system.debug('++++++Could not find the RESPONSE PARSER-->'+CR.Response_parser__c);
            throw new NameException(CR.Response_parser__c);
        }

        //Sorting out the junction objects 
        this.JRs = [SELECT id,IE_Configuration__c,IE_Placeholder__c, IE_Placeholder__r.key__c,ExpV_External__c,ExpV_SFDC__c,Is_Nillable__c,Tag__c, Type__c, SObject_Type__c, FieldToUse__c  from IE_CR2PH_junction__c where IE_Configuration__c=:IR.IE_Configuration__c];
        system.debug('+++++The junction --->'+this.JRs);

        //Sorting out the Placeholders
        //Getting the list of PH ids
        List<Id> allPHids = new list<Id>();
        for (IE_CR2PH_junction__c thisJR :JRs) {
            allPHids.add(thisJR.IE_Placeholder__c);
        }
        this.PHs = [SELECT id,Sobject__c,FieldToUse__c,Key__c from IE_Placeholder__c where id in:allPHids];
        system.debug('+++++The Placeholders --->'+this.PHs);
        system.debug('+++++ENDCONSTRUCTOR+++++');
    }
    
///////// CORE METHODS ////////
    public void compileRequest() {
        //Here the method in the actual implementation is used, refer to the corresponding classes (CR.Request_compiler__c)
        this.CompiledXML = ReqCompiler.compileRequest(IR,  CR,  PHs,  JRs);
    }
    
    public void sendRequest(){
        if (this.CR.Type__c.tolowercase()=='webservice') {
            sendWebserviceRequest(this.CR.log_records_flag__c);
        } 
        //003 - Start
        if (this.CR.Type__c.tolowercase()=='webservice_rest')
        {
            sendWebserviceRequest_REST(this.CR.log_records_flag__c);
        }
        //003 - End
        //TO DO sort out outher integrations types
    }
    
    //OAVERSANO 27/09/2018 : Caring Angel -- START 
    public void sendRequest(Map<String,String> headerAttributes){
    	if(headerAttributes.keySet().IsEmpty())
    		this.sendRequest();
		else
    	{
	        if (this.CR.Type__c.tolowercase()=='webservice') {
	            sendWebserviceRequest(this.CR.log_records_flag__c);
	        } 
	        if (this.CR.Type__c.tolowercase()=='webservice_rest')
	        {
	            sendWebserviceRequest_REST(this.CR.log_records_flag__c, headerAttributes);
	        }
	        //TO DO sort out outher integrations types
    	}
    }
    //OAVERSANO 27/09/2018 : Caring Angel -- END 
    
    public void interpretResponse(){
        //Here the method in the actual implementation is used, refer to the corresponding classes (CR.Request_compiler__c)
        system.debug('+++++'+RawResponse.getbody());
        this.JSONResponse = RespParser.ParseResponse(IR,  CR,  PHs,  JRs, RawResponse.getbody());
    }

///////////////////SUPPORT METHODS ////////////////////////////
    
    public void sendWebserviceRequest(boolean InsertIR) {
        //preparing the request
        HttpRequest myReq = new HttpRequest(); 
        
        //Set HTTPRequest 
        String HTTPMethod = String.isempty(this.CR.HTTPMethod__c) ? 'POST' : this.CR.HTTPMethod__c;
        myReq.setMethod(HTTPMethod);       
        
        //Set HTTPRequest header properties
        myReq.setHeader('Content-type', 'text/xml;charset=UTF-8');
        myReq.setHeader('SOAPAction','""');
        //myReq.setEndpoint(this.CR.EndPoint__c); moved 13/12 to include named credentials
        //myReq.setHeader('Content-Length','2089');
        //myReq.setHeader('Host','axaitalia.my.salesforce.com');
        myReq.setHeader('Connection','Keep-Alive');
        if( this.CR.Timeout__c!= null && this.CR.Timeout__c>0 && this.CR.Timeout__c <120000)
        {
            Integer toInt = Integer.valueOf(this.CR.Timeout__c);
            myReq.setTimeout(toInt);
        }
        
        //D.F. 13/12/2016 Added Named Credentials
        if(!String.isempty(this.CR.Named_Credential_Name__c)) { 
            String NamedCredentialPath = this.CR.Named_Credential_Path__c == null ? '' : this.CR.Named_Credential_Path__c;
            system.debug('++calling++-->'+'callout:'+this.CR.Named_Credential_Name__c+'/'+NamedCredentialPath);
            myReq.setEndpoint('callout:'+this.CR.Named_Credential_Name__c+'/'+NamedCredentialPath);
        } else {
            myReq.setEndpoint(this.CR.EndPoint__c);
            if (!String.isempty(this.CR.Certificate__c)) {
                myReq.setClientCertificateName(this.CR.Certificate__c);
            }
        }
        
        /*     
        String username = '';
        String password = '';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +
        EncodingUtil.base64Encode(headerValue);
        myReq.setHeader('Authorization', authorizationHeader);
        myReq.setEndpoint('https://axa-api.sandsiv.com/import/');
        */

        //Set the HTTPRequest body  
        //string thebody = this.CompiledXML.normalizeSpace();
        //String encoded = EncodingUtil.urlEncode(thebody, 'UTF-8');
        //myReq.setBody(encoded); 

        myReq.setBody(this.CompiledXML.normalizeSpace()); 
        system.debug('+++++myReq'+myReq);   
        system.debug('+++++myReq.getbody()'+myReq.getbody());   
        
        this.IR.RequestBody__c=this.CompiledXML.normalizeSpace();
        //preprare for sending request
        Http http = new Http();
        try {
        //Execute web service call here  
        System.debug('++++++++Start to excute web service call');                     
        this.RawResponse = http.send(myReq);
        System.debug('++++++++Finish to excute web service call');               
    
        //Helpful debug messages
        System.debug('++++++++BODY'+RawResponse.getBody());
        this.IR.ResponseBody__c = getResponseBody(RawResponse.getBody()); // FOZDEN 23/07/2019: Comunicazioni massive
        
        //aggiornato 4XX per esg non passa piu il getStatus OK or KO
        System.debug('++++++++STATUS_CODE:'+RawResponse.getStatusCode());
        this.IR.Status__c = String.valueOf(RawResponse.getStatusCode());

        if(InsertIR){
            //MOSCATELLI_M 15/11/2017: Elimina DAC -- START
            //insert IR;
            if(this.CR.Insert_IR_WS__c && !isAdmin())
            {
                String IRtoString = Json.serializePretty(this.IR);
                HttpRequest req = new HttpRequest();
                Http HTTPtoRequest= new Http();
                req.setMethod('POST');
                req.setHeader('content-type', 'text/html');
                //system.debug('##URL: '+Network.communitiesLanding());
                String url = '';
                if(Network.communitiesLanding() <> null)
                {
                    url = ((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/apexrest/InsertIR');
                }
                else
                {
                    //url ='https://'+((System.URL.getSalesforceBaseUrl().getHost()).replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/apexrest/InsertIR';
                    url = (PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'services/apexrest/InsertIR';
                }                 
                system.debug('Response URL'  +url);   
                req.setEndpoint(url);
                req.setbody(IRtoString);   
                req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
                HTTPResponse resp = HTTPtoRequest.send(req);
            }
            else
                insert IR;            
            //MOSCATELLI_M 15/11/2017: Elimina DAC -- END
        }
        system.debug('inserted IR++++++++++++++++++'+ IR.Id);

        } catch(System.CalloutException e) {
            system.debug ('---exception '+e);
            this.IR.Status__c='FAILED';
            this.IR.ErrorMessage__c= e.getStackTraceString();
            //MOSCATELLI_M 15/11/2017: Elimina DAC -- START
            //insert this.IR;
            if(this.CR.Insert_IR_WS__c && !isAdmin())
            {            
                String IRtoString = Json.serializePretty(this.IR);
                HttpRequest req = new HttpRequest();
                Http HTTPtoRequest= new Http();
                req.setMethod('POST');
                req.setHeader('content-type', 'text/html');
                system.debug('##URL: '+System.URL.getSalesforceBaseUrl());
                String url = '';
                if(Network.communitiesLanding() <> null)
                {
                    url = ((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/apexrest/InsertIR');
                }
                else
                {
                   // url ='https://'+((System.URL.getSalesforceBaseUrl().getHost()).replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/apexrest/InsertIR';
                    url = (PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'services/apexrest/InsertIR';
                } 
                system.debug('Response URL'  +url);   
                req.setEndpoint(url);
                req.setbody(IRtoString);   
                req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
                HTTPResponse resp = HTTPtoRequest.send(req);
            }
            else
                insert this.IR;
            //MOSCATELLI_M 15/11/2017: Elimina DAC -- END

            //Exception handling goes here....
            //For now i thorw a bad exception-->TO DO add status to Engine
            integer n= 0/0;
        }
    }
    
    //003 - Start
    public void sendWebserviceRequest_REST(boolean InsertIR) {
        //preparing the request
        HttpRequest myReq = new HttpRequest();  
        
        //Set HTTPRequest 
        String HTTPMethod = String.isempty(this.CR.HTTPMethod__c) ? 'POST' : this.CR.HTTPMethod__c;
        myReq.setMethod(HTTPMethod);       
        
        //Set HTTPRequest header properties: cambiare header 
        myReq.setHeader('Accept','application/json'); 
        myReq.setHeader('Content-type', 'application/json;charset=UTF-8');
       
        myReq.setHeader('Connection','Keep-Alive');
        if( this.CR.Timeout__c!= null && this.CR.Timeout__c>0 && this.CR.Timeout__c <120000)
        {
            Integer toInt = Integer.valueOf(this.CR.Timeout__c);
            myReq.setTimeout(toInt);
        }

        this.IR.RequestBody__c=this.CompiledXML.normalizeSpace();
        
        if(this.CR.Name != 'CIF_Integration_PartyService_Insert' && this.CR.Name != 'CIF_Integration_PartyService_Edit'){
        this.IR.URLRequest__c=this.CompiledXML.normalizeSpace();
        }
        
        if(this.CR.Name == 'ICF_Sales'){


            if(this.CR.EndPoint__c.contains('mockbin'))
            {
                myReq.setEndpoint(this.CR.EndPoint__c);
            }
            else{

            myReq.setEndpoint(this.CompiledXML.normalizeSpace());
            }
        }else{
            //myReq.setEndpoint(this.CR.EndPoint__c);    
        }
        if (!String.isempty(this.CR.Certificate__c)) {
                myReq.setClientCertificateName(this.CR.Certificate__c);
        }    
        
        if(HTTPMethod == 'POST' || HTTPMethod == 'PUT'){
            System.debug('Called a ' + HTTPMethod + ' method');
            myReq.setBody(this.CompiledXML.normalizeSpace()); 
            myReq.setEndpoint(this.CR.EndPoint__c);  
        }else
        {
            myReq.setEndpoint(this.CompiledXML.normalizeSpace());
        }
        if(this.CR.EndPoint__c.contains('mockbin'))
        {
            myReq.setEndpoint(this.CR.EndPoint__c);
        }
        //system.debug('+++++myReq'+myReq);   
        //system.debug('+++++myReq.getbody()'+myReq.getbody());   
        
        //preprare for sending request
        Http http = new Http();
        try {
        //Execute web service call here  
        System.debug('++++++++Start to excute web service call');                     
        this.RawResponse = http.send(myReq);
        System.debug('++++++++Finish to excute web service call');               
    
        //Helpful debug messages
        System.debug('++++++++BODY'+RawResponse.getBody());
        this.IR.ResponseBody__c = getResponseBody(RawResponse.getBody()); // FOZDEN 23/07/2019: Comunicazioni massive

        //aggiornato 4XX per esg non passa piu il getStatus OK or KO
        System.debug('++++++++STATUS_CODE:'+RawResponse.getStatusCode());
        this.IR.Status__c = String.valueOf(RawResponse.getStatusCode());

        if(InsertIR){
            //MOSCATELLI_M 15/11/2017: Elimina DAC -- START
            //insert IR;
            if(this.CR.Insert_IR_WS__c && !isAdmin() && !isServiziPublicProfile())
            {  
                String IRtoString = Json.serializePretty(this.IR);
                HttpRequest req = new HttpRequest();
                Http HTTPtoRequest= new Http();
                req.setMethod('POST');
                req.setHeader('content-type', 'text/html');
                String url = '';
                /*if(Network.communitiesLanding() <> null)
                {
                    //url = ((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/apexrest/InsertIR').replace('/tabs/', '/');
                    url = (PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/apexrest/InsertIR';
                }
                else
                {*/
                    url = (PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'services/apexrest/InsertIR';
                    //url ='https://'+((System.URL.getSalesforceBaseUrl().getHost()).replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/apexrest/InsertIR';
                //} 
                system.debug('Response URL'  +url);   
                req.setEndpoint(url);
                req.setbody(IRtoString);   
                req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
                HTTPResponse resp = HTTPtoRequest.send(req);
            }
            else
                insert IR;           
            //MOSCATELLI_M 15/11/2017: Elimina DAC -- END
        }
        system.debug('inserted IR++++++++++++++++++'+ IR.Id);
        
        } catch(System.CalloutException e) {
            system.debug ('---exception '+e);
            this.IR.Status__c='FAILED';
            this.IR.ErrorMessage__c= e.getMessage() + '\n' + e.getStackTraceString();

            //MOSCATELLI_M 15/11/2017: Elimina DAC -- START
            //insert this.IR;
            if(this.CR.Insert_IR_WS__c && !isAdmin())
            { 
                String IRtoString = Json.serializePretty(this.IR);
                HttpRequest req = new HttpRequest();
                Http HTTPtoRequest= new Http();
                req.setMethod('POST');
                req.setHeader('content-type', 'text/html');
                String url = '';
                if(Network.communitiesLanding() <> null)
                {
                    url = ((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/apexrest/InsertIR');
                }
                else
                {
                    url = (PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'services/apexrest/InsertIR';
                    //url ='https://'+((System.URL.getSalesforceBaseUrl().getHost()).replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/apexrest/InsertIR';
                } 
                system.debug('Response URL'  +url);   
                req.setEndpoint(url);
                req.setbody(IRtoString);   
                req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
                HTTPResponse resp = HTTPtoRequest.send(req);
            }
            else
                insert this.IR;          
            //MOSCATELLI_M 15/11/2017: Elimina DAC -- END

            //Exception handling goes here....
            //For now i thorw a bad exception-->TO DO add status to Engine
            integer n= 0/0;
        }
    }
    //003 - End
    
    
    //OAVERSANO 27/09/2018 : Caring Angel -- START
    public void sendWebserviceRequest_REST(boolean InsertIR, Map<String,String> headerAttributes) {
        
        //preparing the request
        HttpRequest myReq = new HttpRequest();  
        
        //Set HTTPRequest 
        String HTTPMethod = String.isempty(this.CR.HTTPMethod__c) ? 'POST' : this.CR.HTTPMethod__c;
        myReq.setMethod(HTTPMethod);       
        
        //Set HTTPRequest header properties: cambiare header 
        /*myReq.setHeader('Accept','application/json');  
        myReq.setHeader('Content-type', 'application/json;charset=UTF-8');
       
        myReq.setHeader('Connection','Keep-Alive');*/ //IMP: ATTRIBUTI DA PASSARE IN CLASSE CHIAMANTE
        for(String attr : headerAttributes.keySet())
        {
        	myReq.setHeader(attr,headerAttributes.get(attr));
        }
        if( this.CR.Timeout__c!= null && this.CR.Timeout__c>0 && this.CR.Timeout__c <120000)
        {
            Integer toInt = Integer.valueOf(this.CR.Timeout__c);
            myReq.setTimeout(toInt);
        }

        this.IR.RequestBody__c=this.CompiledXML.normalizeSpace();
        
        if (!String.isempty(this.CR.Certificate__c)) {
            myReq.setClientCertificateName(this.CR.Certificate__c);
        }
        
        if(HTTPMethod == 'POST' || HTTPMethod == 'PUT'){
            System.debug('Called a ' + HTTPMethod + ' method');
            myReq.setBody(this.CompiledXML.normalizeSpace());
            if(this.CR.Name == 'SetConsensoProfilazione'){
            myReq.setEndpoint(this.IR.URLRequest__c);
            }else{
            myReq.setEndpoint(this.CR.EndPoint__c);
            } 
        }else
        {
            myReq.setEndpoint(this.CompiledXML.normalizeSpace());
        }
        
        //system.debug('+++++myReq'+myReq);   
        //system.debug('+++++myReq.getbody()'+myReq.getbody());   
        
        //preprare for sending request
        Http http = new Http();
        try {
	        //Execute web service call here  
	        System.debug('++++++++Start to excute web service call'); 
            System.debug('Endpoint ' + myReq.getEndpoint() + '  Body: ' + myReq.getBody());                  
	        this.RawResponse = http.send(myReq);
	        System.debug('++++++++Finish to excute web service call');               
	    
	        //Helpful debug messages
	        System.debug('++++++++BODY'+RawResponse.getBody());
            this.IR.ResponseBody__c = getResponseBody(RawResponse.getBody()); // FOZDEN 23/07/2019: Comunicazioni massive
	        
            //aggiornato 4XX per esg non passa piu il getStatus OK or KO
            System.debug('++++++++STATUS_CODE:'+RawResponse.getStatusCode());
            this.IR.Status__c = String.valueOf(RawResponse.getStatusCode());

	        if(this.CR.Insert_IR_WS__c /*&& !isAdmin()*/)
            { 
                String IRtoString = Json.serializePretty(this.IR);
                HttpRequest req = new HttpRequest();
                Http HTTPtoRequest= new Http();
                req.setMethod('POST');
                req.setHeader('content-type', 'text/html');
                String url = '';
                if(!isAdmin()){
                    if(Network.communitiesLanding() <> null)
                    {
                        url = ((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/apexrest/InsertIR');
                    }
                    else
                    {
                        url = (PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'services/apexrest/InsertIR';
                        //url ='https://'+((System.URL.getSalesforceBaseUrl().getHost()).replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/apexrest/InsertIR';
                    } 
                }
                else{
                    url = System.URL.getSalesforceBaseUrl().toExternalForm().replace('visualforce','my.salesforce').replace('--c.','.') + '/services/apexrest/InsertIR';
                }
                system.debug('Response URL'  +url);   
                req.setEndpoint(url);
                req.setbody(IRtoString);   
                req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
                HTTPResponse resp = HTTPtoRequest.send(req);
            }
            else
                insert this.IR;
	        system.debug('inserted IR++++++++++++++++++'+ IR.Id);
        
        } catch(System.CalloutException e) {
            system.debug ('---exception '+e);
            this.IR.Status__c='FAILED';
            this.IR.ErrorMessage__c= e.getMessage() + '\n' + e.getStackTraceString();

            if(this.CR.Insert_IR_WS__c )
            { 
                String IRtoString = Json.serializePretty(this.IR);
                HttpRequest req = new HttpRequest();
                Http HTTPtoRequest= new Http();
                req.setMethod('POST');
                req.setHeader('content-type', 'text/html');
                String url = '';
                if(Network.communitiesLanding() <> null)
                {
                    url = ((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/apexrest/InsertIR');
                }
                else
                {
                    url = (PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'services/apexrest/InsertIR';
                    //url ='https://'+((System.URL.getSalesforceBaseUrl().getHost()).replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/apexrest/InsertIR';
                } 
                system.debug('Response URL'  +url);   
                req.setEndpoint(url);
                req.setbody(IRtoString);   
                req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
                HTTPResponse resp = HTTPtoRequest.send(req);
            }
            else
                insert this.IR;      

            //Exception handling goes here....
            //For now i thorw a bad exception-->TO DO add status to Engine
            integer n= 0/0;
        }
    }
    //OAVERSANO 27/09/2018 : Caring Angel -- END

    public static String getValueOfField(SObject so, String fi)
    {
        if (fi == null || fi == '') return '';
        String ret = '';
        String[] fiArr = fi.split('\\.');
        system.debug('+++++++++++++fiArr'+fiArr);
        Integer sizefiArr = fiArr.size();
        //system.debug('+++++++++++++sizefiArr '+sizefiArr );
        
        Object oLev0 = null;
        Object oLev1 = null;
        Object oLev2 = null;
        Object oLev3 = null;
        Object oLev4 = null;
        Object oLev5 = null;

        
        if (sizefiArr==1)
        {
            oLev0 = so.get(fiArr[0]);
            
            if (oLev0 != null)
            {
                ret = so.get(fiArr[0])+'';
            } else ret='';
        }
        else if (sizefiArr==2)
        {
            oLev0 = so.getSobject(fiArr[0]);
            oLev1 = oLev0 != null ? so.getSobject(fiArr[0]).get(fiArr[1]) : null; 
            
            if (oLev0 != null && oLev1 != null)
            {
                ret = so.getSobject(fiArr[0]).get(fiArr[1])+'';
            } else ret='';
        }      
        else if (sizefiArr==3)
        {
            oLev0 = so.getSobject(fiArr[0]);
            oLev1 = oLev0 != null ? so.getSobject(fiArr[0]).getSobject(fiArr[1]) : null;
            oLev2 = oLev1 != null ? so.getSobject(fiArr[0]).getSobject(fiArr[1]).get(fiArr[2]) : null;
            
            if (oLev0 != null && oLev1 != null && oLev2 != null)
            {
                ret = so.getSobject(fiArr[0]).getSobject(fiArr[1]).get(fiArr[2])+'';
            } else ret='';
        }
        else if (sizefiArr==4)
        {
        
            oLev0 = so.getSobject(fiArr[0]);
            oLev1 = oLev0 != null ? so.getSobject(fiArr[0]).getSobject(fiArr[1]) : null;
            oLev2 = oLev1 != null ? so.getSobject(fiArr[0]).getSobject(fiArr[1]).getSobject(fiArr[2]) : null;
            oLev3 = oLev2 != null ? so.getSobject(fiArr[0]).getSobject(fiArr[1]).getSobject(fiArr[2]).get(fiArr[3]) : null;
            
            if (oLev0 != null && oLev1 != null && oLev2 != null && oLev3 != null)
            {
                ret = so.getSobject(fiArr[0]).getSobject(fiArr[1]).getSobject(fiArr[2]).get(fiArr[3])+'';
            } else ret='';
        }
        else if (sizefiArr==5)
        {
            oLev0 = so.getSobject(fiArr[0]);
            oLev1 = oLev0 != null ? so.getSobject(fiArr[0]).getSobject(fiArr[1]) : null;
            oLev2 = oLev1 != null ? so.getSobject(fiArr[0]).getSobject(fiArr[1]).getSobject(fiArr[2]) : null;
            oLev3 = oLev2 != null ? so.getSobject(fiArr[0]).getSobject(fiArr[1]).getSobject(fiArr[2]).getSobject(fiArr[3]) : null;
            oLev4 = oLev3 != null ? so.getSobject(fiArr[0]).getSobject(fiArr[1]).getSobject(fiArr[2]).getSobject(fiArr[3]).get(fiArr[4]) : null;
            if (oLev0 != null && oLev1 != null && oLev2 != null && oLev3 != null && oLev4 != null)
            {
                ret = so.getSobject(fiArr[0]).getSobject(fiArr[1]).getSobject(fiArr[2]).getSobject(fiArr[3]).get(fiArr[4])+'';
            } else ret='';
        }
        
        else if (sizefiArr==6)
        {
            oLev0 = so.getSobject(fiArr[0]);
            oLev1 = oLev0 != null ? so.getSobject(fiArr[0]).getSobject(fiArr[1]) : null;
            oLev2 = oLev1 != null ? so.getSobject(fiArr[0]).getSobject(fiArr[1]).getSobject(fiArr[2]) : null;
            oLev3 = oLev2 != null ? so.getSobject(fiArr[0]).getSobject(fiArr[1]).getSobject(fiArr[2]).getSobject(fiArr[3]) : null;
            oLev4 = oLev3 != null ? so.getSobject(fiArr[0]).getSobject(fiArr[1]).getSobject(fiArr[2]).getSobject(fiArr[3]).getSobject(fiArr[4]) : null;
            oLev5 = oLev4 != null ? so.getSobject(fiArr[0]).getSobject(fiArr[1]).getSobject(fiArr[2]).getSobject(fiArr[3]).getSobject(fiArr[4]).get(fiArr[5]) : null;
            
            if (oLev0 != null && oLev1 != null && oLev2 != null && oLev3 != null && oLev4 != null && oLev5 != null)
            {
                ret = so.getSobject(fiArr[0]).getSobject(fiArr[1]).getSobject(fiArr[2]).getSobject(fiArr[3]).getSobject(fiArr[4]).get(fiArr[5])+'';
            } else ret='';
        } 
             
        //system.debug('+++++++++++++++ret'+ret);
        return ret+'';
 
    }

    // FOZDEN 23/07/2019: Comunicazioni massive
    private static String getResponseBody(String responseBody) {
        Integer maxLength = Schema.SObjectType.IE_Integration_Record__c.fields.ResponseBody__c.getLength();
        System.debug('DBG - Max length: ' + maxLength);
        if (String.isNotBlank(responseBody)) {
            responseBody = responseBody.normalizeSpace();
            if (responseBody.length() >= maxLength) {
                responseBody = responseBody.substring(0, maxLength);
            }
        }

        System.debug('DBG - Response Body: ' + responseBody);
        return responseBody;

    }
    
    private static Boolean isAdmin(){
        List<String> ADMIN_PROFILES = new List<String>{
            'MC Admin MFA',
            'Admin (MFA)',
            'System Administrator',
            'Amministratore del sistema'
        };
        return ADMIN_PROFILES.contains([SELECT Name from Profile where Id = :UserInfo.getProfileId()].Name);
    }
    
    private static Boolean isServiziPublicProfile(){
        List<String> ADMIN_PROFILES = new List<String>{
            'Servizi Profile'
        };
        return ADMIN_PROFILES.contains([SELECT Name from Profile where Id = :UserInfo.getProfileId()].Name);
    }
}
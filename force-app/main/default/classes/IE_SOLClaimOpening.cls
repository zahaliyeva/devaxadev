/*------------------------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         IE_SOLClaimOpening
Description:   Apex class used to execute all the logics internal to the 
rest Callout related to Caring Angel

History

4/10/2018     Created 
-------------------------------------------------------------------------------------------*/
public class IE_SOLClaimOpening 
{
	
    public class ResponseDto 
    { 
        public Boolean isSuccess;
        public String message;
        public Map<Object, Object> values;

        public ResponseDto(Boolean isSuccess, String msg)
        {
            this.isSuccess = isSuccess;
            this.message = msg;
            this.values = new Map<Object, Object>();
        }   
        public ResponseDto(){
            this.isSuccess = False;
            this.message = '';
            this.values = new Map<Object, Object>();
        }       
    }

	public static ResponseDto SOLCreateNewClaim(Questionario_CA__c theQuestionnaire, String caseId)
	{
		IE_Integration_Record__c myIR = new IE_Integration_Record__c();
        myIR=IE_SOLClaimOpening_Helper.PopulateIErecord_CreateClaim(theQuestionnaire,caseId); 
        
        IE_Engine myIE = new IE_Engine(myIR);
        ResponseDto res = new ResponseDto();
        
        Map<String,String> headerAttributes = new Map<String,String>();
		//OAVERSANO 14/12/2018 : Caring Angel Host FIX -- START
		for(Caring_Angel__mdt Ca: [Select Key__c, Value__c,DeveloperName from Caring_Angel__mdt])
        {
            if(Ca.DeveloperName.contains('HeaderAttributesIE_SOL_ClaimOpening'))
                headerAttributes.put(Ca.Key__c,Ca.Value__c);
        }
	    /*    
        headerAttributes.put('Accept-Encoding','gzip,deflate');
        headerAttributes.put('Content-Type','application/json'); //headerAttributes.put('Content-type','application/json');
        headerAttributes.put('Content-Length','207'); //headerAttributes.put('Content-Length','248');
        headerAttributes.put('Host','esg-pp.axa-medla.com'); //headerAttributes.put('Host','precol.axa-assicurazioni-it.intraxa');
        headerAttributes.put('Connection','Keep-Alive');
        headerAttributes.put('User-Agent','Apache-HttpClient/4.1.1 (java 1.5)');   */     
		//OAVERSANO 14/12/2018 : Caring Angel Host FIX -- END
        
		try
		{
            myIE.compileRequest();
        } 
        catch (exception e) 
        {
            String errorsStr = 'Attenzione ! Si è verificato un errore nel compilare la richiesta verso ESG';
            system.debug('*********Eccezione e ='+e);
            res = new ResponseDto(false, errorsStr);
            return res;
        }

        try 
        {
            myIE.sendRequest(headerAttributes);
        } 
        catch (exception e) 
        {
            system.debug('#Error: '+e.getMessage());
            upsert myIR;
            String errorsStr = 'Attenzione ! Si è verificato un errore nell\'inviare la richiesta verso ESG';
            res = new ResponseDto(false, errorsStr);

            return res;     
        }
        
        try 
        {
            myIE.interpretResponse();
            system.debug('**********json response'+myIE.JSONResponse);
            res = IE_SOLClaimOpening_Helper.manageResponse(myIE); 

        } 
        catch (exception e) 
        {
            String errorsStr = 'Si è verificato un errore nella ricezione della risposta da CIF'+e.getmessage();
            res = new ResponseDto(false, errorsStr);

            return res;
        }
        
        return res;
	}
}
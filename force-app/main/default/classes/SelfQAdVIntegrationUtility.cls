/** 
* @author	Reply
* @date	04/2023
* @description Utility for SelfQAdV Integration
*/
public with sharing class SelfQAdVIntegrationUtility {
    
    private static IE_Configuration__c confToUpdate;
    
/** 
* @return	Map with Token
* @description get Auth Token
*/
    public static String getAuthToken() {
        
        String accessToken = '';        
        String configurationName = 'Auth0_Get_Token';
        
        List<IE_Configuration__c> confList = [
            SELECT Id, NameSpacePrefix1__c, NameSpacePrefix2__c, NameSpaceUri1__c, ClientId__c, Client_Secret__c,
            NameSpaceUri2__c, Type__c, EndPoint__c, Certificate__c, Timeout__c,
            Name, Insert_IR_WS__c, HTTPMethod__c, Silva_Access_Token__c, Silva_Token_Expiration_DateTime__c
            FROM IE_Configuration__c
            WHERE Name = :configurationName
            WITH SYSTEM_MODE
        ];
        
        if(confList.size()>0){
            
            IE_Configuration__c conf = confList.get(0);
            accessToken = conf.Silva_Access_Token__c;
            if(isTokenExpired(conf) == true){
                try{
                    HttpRequest request = new HttpRequest();                
                    request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    String body =
                        'client_id=' +
                        EncodingUtil.urlEncode(conf.ClientId__c, 'UTF-8') +
                        '&client_secret=' +
                        EncodingUtil.urlEncode(conf.Client_Secret__c, 'UTF-8') +
                        '&grant_type=client_credentials' +
                        '&scope=' +
                        EncodingUtil.urlEncode('urn:axa:it:scopes:user_registration.write urn:axa:it:scopes:document.read_only', 'UTF-8');
                    request.setBody(body);
                    request.setEndpoint(conf.EndPoint__c);
                    request.setMethod('POST');
                    Http call = new Http();
                    HttpResponse response = call.send(request);
                    if(response.getStatusCode() != 200){
                        throw new GetTokenException('Get Access Token Error');
                    }
                    String respString = response.getBody();
                    Map<string, String> responseMap = (Map<string, String>) JSON.deserialize(respString, Map<String, String>.class);
                    accessToken = String.valueOf(responseMap.get('access_token'));
                    conf.Silva_Access_Token__c = accessToken;
                    conf.Silva_Token_Expiration_DateTime__c = System.now().addHours(1);      
                    confToUpdate = conf;
                } catch (Exception e){
                    throw new GetTokenException(e);
                }
            }
        }
        return accessToken;
    }
    
    /** 
* @param	conf configuration
* @return	boolean, token is expired or not 
* @description check if token is expired
*/
    public static boolean isTokenExpired(IE_Configuration__c conf) {
        boolean isExpired = false;
        if (System.now() > conf.Silva_Token_Expiration_DateTime__c || conf.Silva_Access_Token__c == null || conf.Silva_Access_Token__c == '' || conf.Silva_Token_Expiration_DateTime__c == null) {
            isExpired = true;
        }
        return isExpired;
    }
    
/** 
* @description update configuration
*/
    public static void finalize(){
        if(confToUpdate != null){
            update confToUpdate;
        }
    }

/** 
* @author	Reply
* @date	04/2023
* @description exception class
*/
    public class GetTokenException extends Exception{}
    
    
}
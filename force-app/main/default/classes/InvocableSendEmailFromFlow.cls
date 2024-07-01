public without sharing class InvocableSendEmailFromFlow{

    @InvocableMethod (Label = 'Send Email from FLOW' description = 'send email on CODE, reason dinamic fields')
    public static List <String> execute (List<Requests> requestList) {
        List <String> responseWrapper = new List <String>();
        Messaging.SendEmailResult [] results = new Messaging.SendEmailResult[1] ;
        List <Messaging.SendEmailResult []> resultsList = new List<Messaging.SendEmailResult[]>() ;

        List<String> ListTemplateDeveloperName = new List<String>();
        Map<String,EmailTemplate> MapTemplatesDevnameIds = new Map<String,EmailTemplate>();
        List<String> ListOrgWideEmailAddress_Name = new List<String>();
        Map<String,String> MapListOrgWideEmailAddress_Names = new Map<String,String>();
        List<String> ListAgencyCode = new List<String>();
        Map<String,String> MapAgencyCodes = new Map<String,String>();

    try{

        if(!requestList.isEmpty()){
            for(Requests tempRequest:requestList){    //for bulking add after deploy *-+ 05-12-2022   
                ListTemplateDeveloperName.add(tempRequest.templateDeveloperName);
                ListOrgWideEmailAddress_Name.add(tempRequest.OrgWideEmailAddress_Name);
                ListAgencyCode.add(tempRequest.AgencyCodeCase != null ? tempRequest.AgencyCodeCase : 'vuoto nel Case ');
            }
    
            List<EmailTemplate> emailTemplate = [Select Subject,Body,HtmlValue,DeveloperName From EmailTemplate where DeveloperName in: ListTemplateDeveloperName] ;
            for(EmailTemplate template_pivot: emailTemplate)
                MapTemplatesDevnameIds.put(template_pivot.DeveloperName, template_pivot);

            List<OrgWideEmailAddress> emailSenderAddress = [select Id,DisplayName, Address from OrgWideEmailAddress where DisplayName in: ListOrgWideEmailAddress_Name ];
            for(OrgWideEmailAddress orgMail_pivot:emailSenderAddress)
                MapListOrgWideEmailAddress_Names.put(orgMail_pivot.DisplayName, orgMail_pivot.Id);
            
            List<Node__c> Agencyholder = [select Agency_holder__c,Node_unique_code__c from Node__c where Node_unique_code__c in:ListAgencyCode ];
            for(Node__c node_pivot: Agencyholder)
                MapAgencyCodes.put(node_pivot.Node_unique_code__c, node_pivot.Agency_holder__c);

            for(Requests tempRequest:requestList){    //for bulking    
                Requests temp = tempRequest;
                String PathOfDevelop = temp.PathOfDevelop;
                String templateDeveloperName = temp.templateDeveloperName;
                String OrgWideEmailAddress_Name = temp.OrgWideEmailAddress_Name;
                String AgencyCode = temp.AgencyCodeCase != null ? temp.AgencyCodeCase : 'vuoto nel Case ';

                //Create a path for others future develops
                if('Portale Cauzioni'.equalsIgnoreCase(PathOfDevelop) && MapTemplatesDevnameIds.containsKey(templateDeveloperName) && MapListOrgWideEmailAddress_Names.containsKey(OrgWideEmailAddress_Name) ){
                    //Description ca not be null control on flow 
                    String caseDescription = temp.CaseDesc;
                    String AccountName = temp.AccountName;
                    String Subject = temp.Subject != null ? temp.Subject : 'vuoto nel Case ';
                    String CaseEmail = temp.CaseEmail != null ? temp.CaseEmail : 'vuoto nel Case ';
                    String AgencyholderFrom = MapAgencyCodes.containsKey(AgencyCode) ? MapAgencyCodes.get(AgencyCode):'Nome agenzia vuoto nel Nodo '+AgencyCode;
                    results = replacePlaceholders(caseDescription,AccountName, Subject,AgencyholderFrom,MapListOrgWideEmailAddress_Names.get(OrgWideEmailAddress_Name),CaseEmail, MapTemplatesDevnameIds.get(templateDeveloperName));
    
                    resultsList.add(results);
                }else {
                    //other paths on future
                }     
            }
        }//ne if empty

    }catch(exception ex) {
            ApplicationLogHelper.ERROR('InvocableSendEmailFromFlow','InvocableMethod on FLOW ligt: '+ ex.getmessage(), ex.getStackTraceString());
            system.debug('Error: '+ex.getMessage());
            responseWrapper.add(ex.getMessage()+ex.getStackTraceString());
            return responseWrapper;
        }
        if(!resultsList.isEmpty()){
            for(Messaging.SendEmailResult [] ArraySendEmailTemp:resultsList ){
                if(ArraySendEmailTemp[0] != null)
                    responseWrapper.add(String.valueOf(ArraySendEmailTemp[0].isSuccess()));
            }
        }
        else 
            responseWrapper.add('results email sends is Empty');

        return responseWrapper ;    
    }

    public static Map<String, String> getKey_ValuesFromJson(String StringJson){
        Map<String, String> valuesMap = new Map<String, String>();
        for(Object obj : (List<Object>)JSON.deserializeUntyped(StringJson)){
            //convert values to map
            Map<String, Object> data = (Map<String, Object>)obj;
            valuesMap.put((String)data.get('key'),String.valueOf(data.get('value')) );
         }
         return valuesMap;
    }
    public static Messaging.SendEmailResult [] replacePlaceholders(String caseDescription,String AccountName,String Subject,String agencyHolder,String  OrgEmail,String CaseEmail , EmailTemplate etem){
        
        List<Messaging.SingleEmailMessage> listEmailToSend = new List<Messaging.SingleEmailMessage>() ;
        Messaging.SendEmailResult [] results = new Messaging.SendEmailResult [1];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Map<String, String> valuesMap = getKey_ValuesFromJson(caseDescription);

        String htmlBody = etem.HtmlValue;
        String body    = etem.body;

        htmlBody = htmlBody.replaceAll('#NomeAgenzia', agencyHolder);
        body     = body.replaceAll('#NomeAgenzia', agencyHolder);

        htmlBody = htmlBody.replaceAll('#NomeCliente', String.isNotBlank(AccountName)? AccountName:' Cliente non trovato, Controllare Account asociato al Case.' );
        body     = body.replaceAll('#NomeCliente', String.isNotBlank(AccountName)? AccountName:' Cliente non trovato, Controllare Account asociato al Case.' );

        htmlBody = htmlBody.replaceAll('#numeroProposta', valuesMap.get('Numero proposta')!= null ? valuesMap.get('Numero proposta'):'nullo');
        body     = body.replaceAll('#numeroProposta', valuesMap.get('Numero proposta')!= null ? valuesMap.get('Numero proposta'):'nullo');

        htmlBody = htmlBody.replaceAll('#tipologiaProposta',valuesMap.get('Tipologia proposta')!= null ? valuesMap.get('Tipologia proposta'):'nullo');
        body     = body.replaceAll('#tipologiaProposta', valuesMap.get('Tipologia proposta')!= null ? valuesMap.get('Tipologia proposta'):'nullo');

        htmlBody = htmlBody.replaceAll('#beneficiario', valuesMap.get('nome e cognome del beneficiario')!= null ?valuesMap.get('nome e cognome del beneficiario'):'nullo');
        body     = body.replaceAll('#beneficiario', valuesMap.get('nome e cognome del beneficiario')!= null ? valuesMap.get('nome e cognome del beneficiario'):'nullo');

        htmlBody = htmlBody.replaceAll('#importoGarantito', valuesMap.get('importo garantito')!= null ? valuesMap.get('importo garantito'):'nullo');
        body     = body.replaceAll('#importoGarantito', valuesMap.get('importo garantito')!= null ? valuesMap.get('importo garantito'):'nullo');

        if(valuesMap.get('data effetto')!= null){
            htmlBody = htmlBody.replaceAll('#DataKey', 'Data effetto');
            htmlBody = htmlBody.replaceAll('#dataValue', valuesMap.get('data effetto'));
            body     = body.replaceAll('#DataKey', 'Data effetto');
            body     = body.replaceAll('#dataValue', valuesMap.get('data effetto'));
        }else if (valuesMap.get('data presentazione')!= null){
            htmlBody = htmlBody.replaceAll('#DataKey', 'Data presentazione');
            htmlBody = htmlBody.replaceAll('#dataValue', valuesMap.get('data presentazione'));
            body     = body.replaceAll('#DataKey', 'Data presentazione');
            body     = body.replaceAll('#dataValue', valuesMap.get('data presentazione'));
        }else {
            htmlBody = htmlBody.replaceAll('#DataKey', 'Data'); //#dataValue
            htmlBody = htmlBody.replaceAll('#dataValue', 'Non Presente');
            body     = body.replaceAll('#DataKey', 'Data');
            body     = body.replaceAll('#dataValue', 'Non Presente');
        }

        //errore del template se utilizo a codice non riconoce il XML end ]]> 
        htmlBody = htmlBody.replaceFirst(']]>', ' ');
        body     = body.replaceAll(']]>', ' ');

        system.debug('%%%% mail -- '+htmlBody);

        email.setHtmlBody(htmlBody);
        email.setPlainTextBody(body);
        email.setSubject(Subject);
        email.setUseSignature(true);
        email.setOrgWideEmailAddressId(OrgEmail);
        email.setToAddresses(new List<String>{CaseEmail});

        if(email!= null)
        listEmailToSend.add(email);
  
        if(!listEmailToSend.isEmpty()){
            results = Messaging.sendEmail(listEmailToSend,false);
        }

        return results;
    }
    public class Requests {
        @InvocableVariable(label='Path' description='Path on Apex class for enter on IF-ELSE' required=true)
        public String PathOfDevelop; // version 1 only have - Portale Cauzioni on CASESWITCH
        @InvocableVariable(label='templateDeveloperName' description='Developer Name Email classic template' required=true)
        public String templateDeveloperName;
        @InvocableVariable(label='OrgWideEmailAddress Display Name' description='Field DisplayName of OrgWideEmailAddress ' required=true )
        public String OrgWideEmailAddress_Name;
        @InvocableVariable(label='Case Description' description='Field Case.Description on JSON format' )
        public String CaseDesc;
        @InvocableVariable(label='Oggetto apertura case del Case' description='Oggetto apertura case del Case' )
        public String Subject;
        @InvocableVariable(label='Email Case' description='SuppliedEmail' )
        public String CaseEmail;
        @InvocableVariable(label='Agency code' description='agency code input from case' )
        public String AgencyCodeCase;
        @InvocableVariable(label='Account Name' description='Account associato' )
        public String AccountName;
        }


  }
public without sharing class LM_Reassignment_Email_CTRL {

	public Id relatedToLeadId {get;set;}
    public Lead theLead {get;set;}
    public String InfoBanner {get;set;}

	public LM_Reassignment_Email_CTRL() {
		
	}

	public String getReassignmentString(){
        
    
        List<Lead> theLeads = [SELECT Id,FirstName,LastName,Codice_Sub_Agenzia__c FROM Lead WHERE Id = :relatedToLeadId LIMIT 1];
        InfoBanner = '';
 
        if (theLeads.size() >0){
            Lead theLead=theLeads[0];
              
            //List <String> InfoBanner = new List<String>();
            
            if (theLead.Codice_Sub_Agenzia__c != '' && theLead.Codice_Sub_Agenzia__c != null){
            
                //List<Document>  imgid = [select id, name, body from Document where name = 'sconto_NPC' LIMIT 1]; 
                
                InfoBanner = '<b>Ti suggeriamo di contattare il lead tramite la sede secondaria ' + theLead.Codice_Sub_Agenzia__c + ' per prossimità territoriale</b>!';
                //InfoBanner = System.URL.getSalesforceBaseUrl().toExternalForm().replace('https','http')+'/servlet/servlet.ImageServer?id='+imgid[0].id+'&oid='+UserInfo.getOrganizationId();
                
            }
            
            return InfoBanner;
        } else {
            
            String ErrorInfo = '';
            ErrorInfo = 'Nessun Lead di riferimento trovato';
           
            return ErrorInfo;
        }
    
    }

}
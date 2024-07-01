public with sharing class LightningCaseRequiredDocumentsController {
  
    public class Response extends LghtResponse{	
        @AuraEnabled public boolean showSendEmailButton = false; 
        @AuraEnabled public List<RetrieveDocW> docResults;         
    }
    
    /*Wrapper class*/
    public class RetrieveDocW{
        @AuraEnabled public boolean selected;
        @AuraEnabled public string docName;
        
        public RetrieveDocW(){
            selected = false;
            docName = '';     
        }
    
    }
    @AuraEnabled
    public static Response initCmp(String idCase){
        system.debug('LightningCaseRequiredDocumentsController.initCmp START');

        Response result = new Response();
       
        try {
            Case c = LghtCaseManageController.getCase(idCase);
            List<String> requiredDocs = new List<String>();
            List<RetrieveDocW> docResults = new List<RetrieveDocW>();
            result.docResults = new List<RetrieveDocW>();

            if(!(c.RecordType.DeveloperName == AP_Constants.rtCaseSinistro || c.RecordType.DeveloperName == AP_Constants.rtCaseSinistriAAI) && c.IsClosed==false)
            result.showSendEmailButton= true;
          
            if(c.RequiredDocumentList__c <> null) requiredDocs = c.RequiredDocumentList__c.split('\n');

            List<String> docNames = new List<String>();
            List<String> docTemp = new List<String>();

             //loop in all values  
            if(c.SubCategory__c !=  ''){
            for(RequiredDocuments__c csDocs:RequiredDocuments__c.getall().values()){
                if(c.SubCategory__c == csDocs.SubCategory__c){
                                      
                    if(csDocs.RequiredDocuments1__c!=null && csDocs.RequiredDocuments1__c.contains(',')){                        
                        docNames.addAll(csDocs.RequiredDocuments1__c.split(','));
                    }
                    else{
                        if(csDocs.RequiredDocuments1__c!=null) 
                           docNames.add(csDocs.RequiredDocuments1__c);
                    }
                    
                    if(csDocs.RequiredDocuments2__c!=null && csDocs.RequiredDocuments2__c.contains(',')){
                        docNames.addAll(csDocs.RequiredDocuments2__c.split(','));
                    }
                    else{
                        if(csDocs.RequiredDocuments2__c!=null) docNames.add(csDocs.RequiredDocuments2__c);
                    }
                }//end if
            }//end for
        }
            system.debug('LightningCaseRequiredDocumentsController.initCmp docNames:'+docNames);
            
            RetrieveDocW docRecW; 

            system.debug('LightningCaseRequiredDocumentsController.initCmp requiredDocs: '+requiredDocs);
            
             //add docName in wrapper list
            for(string s:docNames){
                docRecW = new RetrieveDocW();
                docRecW.docName = s;
                system.debug('LightningCaseRequiredDocumentsController.initCmp s: '+s);
                for(String reqDoc :requiredDocs){
                    system.debug('LightningCaseRequiredDocumentsController.initCmp reqDoc: '+reqDoc);
                    if (reqDoc.trim() == s.trim()){
                        docRecW.selected = true;
                        continue;
                    }
                }
                
                system.debug('LightningCaseRequiredDocumentsController.initCmp docRecW.selected: '+docRecW.selected);
                docResults.add(docRecW);
                
            }//end for

          //  put('docResults', JSON.serialize(docResults));
            result.docResults.addAll(docResults);
            system.debug('LightningCaseRequiredDocumentsController.initCmp docResults :'+ result.docResults);

            result.isSuccess = true;
        } catch (Exception ex) {
            result.errorMessage = ex.getMessage(); 
            system.debug('LightningCaseRequiredDocumentsController.initCmp Error '+ ex.getMessage());           
           
        }
        system.debug('LightningCaseRequiredDocumentsController.initCmp END');
        return  result; 

    }

    @AuraEnabled
    public static Response sendEmail(String idCase, Object params){
        system.debug('LightningCaseRequiredDocumentsController.sendEmail START');    

        List <RetrieveDocW> docResults  = new List <RetrieveDocW> ();
        docResults = (List<RetrieveDocW>) System.JSON.deserialize( System.JSON.serialize(params), List<RetrieveDocW>.class);
        system.debug('LightningCaseRequiredDocumentsController.sendEmail docResults:' + docResults);

        Response result = new Response();
        
        Case  caseRec =  LghtCaseManageController.getCase(idCase);
        try {
            String missingDocs='';
            caseRec.RequiredDocumentList__c = '';
            integer i = 0;
            
            for(RetrieveDocW doc: docResults){
                if(doc.selected == true){
                    caseRec.RequiredDocumentList__c = caseRec.RequiredDocumentList__c + doc.docName +'\n'; 
                }else{
                    i++;
                    missingDocs += i+'. '+doc.docName +'<br/>'; 
                    caseRec.status = AP_Constants.caseStatusPending;
                }
            }
            update caseRec;

            if(missingDocs != '') {
                VFC07_CaseRequiredDocuments instance = new VFC07_CaseRequiredDocuments();
                instance.caseRec= caseRec;
                instance.sendMail(missingDocs.removeEnd('\n'));
            }
            
        } catch (Exception ex) {        
            result.errorMessage = ex.getMessage(); 
            system.debug('LightningCaseRequiredDocumentsController.sendEmail Error '+ ex.getMessage());           
        }
        system.debug('LightningCaseRequiredDocumentsController.sendEmail END');
        return  result;       
        
    }
}
public without sharing class SelfQAdV_Utility {

    public class Request {
        @InvocableVariable(
            label = 'Document Checklist Item Record Id'
            description = 'The id of the Document Checklist Item record to clean'
            required = true
        )
        public String DCIRecordId;
    }

    @InvocableMethod (Label = 'Clear Old Files')
    public static void cleanDCI(List<Request> req){
        List<String> DCI_Ids = new List<String>();
        List<ContentDocumentLink> queueableInput = new List<ContentDocumentLink>();
        for(Request rq : req){
            DCI_Ids.add(rq.DCIRecordId);
        }

        List<DocumentChecklistItem__c> docList = [Select Id, (Select ContentDocument.Id, LinkedEntityId from ContentDocumentLinks order by ContentDocument.CreatedDate desc)  FROM DocumentChecklistItem__c where id in: DCI_Ids ];
        for(DocumentChecklistItem__c dci : docList){
            if(dci.ContentDocumentLinks.size() > 1){
                List<ContentDocumentLink> links = dci.ContentDocumentLinks;
                links.remove(0);
                queueableInput.addAll(links);
            }
        }

        if(!queueableInput.isEmpty()){

            CleanOldFiles job = new CleanOldFiles(queueableInput);
            System.enqueueJob(job);
        }

    } 


    public class CleanOldFiles implements Queueable{

        private List<ContentDocumentLink> IdsList;

        public CleanOldFiles(List<ContentDocumentLink> input){
            this.IdsList = input;
        }

        public void execute(QueueableContext context) {

            List<ContentDocument> docToDelete = new List<ContentDocument>();
            for(ContentDocumentLink cdl : IdsList){
                docToDelete.add(cdl.ContentDocument);
            }

            try{
                delete docToDelete;
            }
            catch(Exception ex){

                String DocumentIds = '';
                for(ContentDocumentLink cdl : IdsList){
                    DocumentIds += cdl.LinkedEntityId + '; ';
                }
                ApplicationLogHelper.ERROR('SelfQAdV_Utility', 'Errore nella pulizia dei file inerenti i document checklist item', DocumentIds);
            }

        }

        

    }

}
@isTest
public class MobilityDocumentsTest {
    static testMethod void testDocument() {
        
        Document doc = new Document(FolderId = UserInfo.getUserId() ,Name='mySampleFile', Body = Blob.ValueOf('Hello World'));
    	insert doc;
        String myBase64String = EncodingUtil.base64Encode(Blob.valueof('UTF-8'));
     
        Map<String,List< Object>> Map1 = new Map<String,List< Object>>();
        List<String> Lista = new List<String>();
        
		Test.startTest();
		MobilityDocuments.getFilesList(doc.Id);
        MobilityDocuments.deleteContentDocuments(Lista);
        MobilityDocuments.uploadFile(doc.Id, myBase64String, 'Titolo');
        MobilityDocuments.getUploadFilePage(doc.Id, 10,0,6,10,20);
        Test.stopTest();
    }

}
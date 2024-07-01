@isTest
public class FileUploadController_TEST {
    
    @testSetup static void setup() {//preparing test database
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        Case myCase = new Case();
        insert(myCase);
        
    }
    
    static testmethod void TEST_FileUpload() {
        
        Case myCase = [SELECT Id FROM Case LIMIT 1];
        
        Id parentId = myCase.Id;
        String fileName = 'TestFile.CSV';
        String base64Data = '';
        String contentType = 'Text';
        String fileId = '';
        
        //OAVERSANO 03/01/2019 : Enhancement NMA Biz III -- START
        //fileId = FileUploadController.saveChunk(parentId,fileName,base64Data,contentType,fileId);
        //fileId = FileUploadController.saveChunk(parentId,fileName,base64Data,contentType,fileId,'AllUsers');
        //OAVERSANO 03/01/2019 : Enhancement NMA Biz III -- END
        
        base64Data = 'This is a test file created for testing purposes of the class FileUploadController';
		
		//OAVERSANO 03/01/2019 : Enhancement NMA Biz III -- START        
        //FileUploadController.saveChunk(parentId,fileName,base64Data,contentType,fileId);
        Id fileIdReturned = FileUploadController.saveChunk(parentId,fileName,base64Data,contentType,fileId,'AllUsers');
        FileUploadController.appendToFile(fileIdReturned, base64Data);
        //OAVERSANO 03/01/2019 : Enhancement NMA Biz III -- END
        
        FileUploadController.checkAttachments(parentId, fileName, 0);
        
        FileUploadController.delAttachment(fileId);
    }
}
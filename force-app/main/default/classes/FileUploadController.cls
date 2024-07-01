public with sharing class FileUploadController {
    
    @AuraEnabled
    //OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- START
    //public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId, String fileVisibility) {
    //OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- END
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        if (fileId == '') {
        	//OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- START
            //fileId = saveTheFile(parentId, fileName, base64Data, contentType);
            fileId = saveTheFile(parentId, fileName, base64Data, contentType, fileVisibility);
            //OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- END
        } else {
            appendToFile(fileId, base64Data);
        }
 
        return Id.valueOf(fileId);
    }
 	
 	//OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- START
    //public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
	public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType, String fileVisibility) {
    //OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- END
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 		//OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- START
        /*Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
 
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
 
        insert oAttachment;
 
        return oAttachment.Id;*/
        ContentVersion conVer = new ContentVersion();
		//conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
		conVer.PathOnClient = fileName; // The files name, extension is very important here which will help the file in preview.
		conVer.Title = fileName; // Display name of the files
		conVer.VersionData = EncodingUtil.base64Decode(base64Data); // converting your binary string to Blob
		conVer.IsMajorVersion = false; //so that can be updated later on
		insert conVer;
		
		List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId =: conVer.Id];
		//create ContentDocumentLink  record for that object
		ContentDocumentLink cdl = New ContentDocumentLink(LinkedEntityId = parentId,
															ContentDocumentId = documents[0].Id, 
															shareType = 'I',
															Visibility = fileVisibility);
		documents[0].Description = 'Allegato inserito da Storico Conversazioni';
		update documents;
		insert cdl;
		return conVer.Id;
		//OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- END
    }
 
    @TestVisible
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 		//OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- START
        /*Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
 
        String existingBody = EncodingUtil.base64Encode(a.Body);
 
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
 
        update a;*/
        List<ContentVersion> conVerList = [SELECT Id, VersionData FROM ContentVersion WHERE Id=: fileId];
        if(!conVerList.IsEmpty())
        {
            String existingBody = EncodingUtil.base64Encode(conVerList[0].VersionData);
            conVerList[0].VersionData = EncodingUtil.base64Decode(existingBody + base64Data);
            update conVerList[0];
        }
        //OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- START
    }

    //new//
    public class checkAttachmentResults
    {
        @AuraEnabled public Boolean AlreadyAttached;
        @AuraEnabled public Decimal ReachedSize;

        public checkAttachmentResults()
        {
            this.AlreadyAttached = false;
            this.ReachedSize = 0;
        }
    }

    @AuraEnabled
    public static checkAttachmentResults checkAttachments(String CaseId, String FileName, Decimal FileSize)
    {
        Decimal ReachedSizeBytes = 0;//reached dimension in bytes

        checkAttachmentResults Car = new checkAttachmentResults();
		//OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- START
        /*for(Attachment att:[Select Name,BodyLength from Attachment where parentid=:CaseId])
        {
            ReachedSizeBytes+=att.BodyLength;

            if(att.BodyLength == FileSize && att.Name == FileName)
                Car.AlreadyAttached = true;
        }*/
        if(String.IsNotBlank(CaseId))
        {
	        for(ContentDocumentLink conDocLink:[SELECT Id, ContentDocument.LatestPublishedVersionId,
	        								ContentDocument.LatestPublishedVersion.Title,
	        								ContentDocument.LatestPublishedVersion.ContentSize
	        								FROM ContentDocumentLink WHERE LinkedEntityId =: CaseId])
	        {
	            if(conDocLink.ContentDocument!=null)
	            {
	            	if(conDocLink.ContentDocument.LatestPublishedVersionId!=null)
	            	{
	            		ReachedSizeBytes+=conDocLink.ContentDocument.LatestPublishedVersion.ContentSize;
	            		if(conDocLink.ContentDocument.LatestPublishedVersion.ContentSize == FileSize 
	            			&& 
	        				conDocLink.ContentDocument.LatestPublishedVersion.Title == FileName)
	                		Car.AlreadyAttached = true;
	            	}
	            }
	            
	
	            
	        }
        }
		//OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- END
        Car.ReachedSize = ReachedSizeBytes;    

        return Car;
    }
    //new//
    @AuraEnabled
    public static boolean delAttachment(String attachId)
    {
    	//OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- START
        /*Attachment a = [SELECT Id, Name FROM Attachment 
                        WHERE Id =: attachId LIMIT 1]; 
        try
        {           
            delete a;                
        }*/
        List<ContentVersion> conVerList = [SELECT Id, VersionData, ContentDocumentId, Title, ContentSize FROM ContentVersion WHERE Id=:attachId];
        if(!conVerList.isEmpty())
        {
            ContentDocument contDoc = new ContentDocument(Id = conVerList[0].ContentDocumentId);
            try
            {           
                delete contDoc;                
            }
            //OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- END
            catch(exception ex)
            {
                return false;
            } 
        }
        
        return true;
    }
}
({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,     //Chunk Max size 750Kb 
    
    uploadHelper: function(component, event) {
        // start/show the loading spinner   
        component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        console.log (component.find("fileId"));
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            var sizeInMb = Math.round(file.size/1048576 * 100) / 100;
            //OAVERSANO 17/12/2018 : Enhancement NMA Biz -- START
        	component.set("v.showFileAttached",false);
        	//OAVERSANO 17/12/2018 : Enhancement NMA Biz -- END
            component.set("v.fileName", 'Attenzione, la dimensione massima consentita è di 4.5 MB \n' + ' Il file selezionato è ' + sizeInMb+' MB');
            return;
        }
 
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
 
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents);
        });
        objFileReader.readAsDataURL(file);
       // debugger;
    },
 
    uploadProcess: function(component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
 
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },
 
 
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        //OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- START
        var Visibility;
        var shareToAllUsers = component.get("v.shareToAllUsers");
        console.log("shareToAllUsers : ",shareToAllUsers);
        if(shareToAllUsers)
        {
        	Visibility = "AllUsers";
        }
        else
        {
        	Visibility = "InternalUsers";
        }
        //OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- END
        action.setParams({
            parentId: component.get("v.parentId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId,
            fileVisibility: Visibility //OAVERSANO 17/12/2018 : Enhancement NMA Biz III 
        });
 
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            attachId = response.getReturnValue();

            var state = response.getState();
            console.log('Visibility = '+Visibility);
            console.log('state = '+state);
            if (state === "SUCCESS") {
                var attachmentList = component.get ("v.attachmentList");
                if (attachmentList.indexOf(attachId) != -1){//already present
                }else
                {
                    attachmentList.push(attachId);
                }
                var fileName = component.get("v.fileName");
                var attachmentListFileNames = component.get("v.attachmentListFileNames");
                if (attachmentListFileNames.indexOf(fileName)!= -1){}
                else if (fileName!="Nessun file selezionato")
                {
                    attachmentListFileNames.push(fileName);                                    
                    ////
                    
                    var myEvent = component.getEvent("uploadaction");
                    myEvent.setParams({"param": attachmentListFileNames});
                    myEvent.fire();
                    //                    
                }
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start position is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                	//OAVERSANO 17/12/2018 : Enhancement NMA Biz -- START
	            	component.set("v.showFileAttached",false);
	            	//OAVERSANO 17/12/2018 : Enhancement NMA Biz -- END	
                    component.set("v.fileName","Nessun file selezionato");
                    component.find("fileId").set('v.files', null);
                    console.log('File allegato con successo');
                    component.set("v.showLoadingSpinner", false);
                    component.set("v.attachmentList",attachmentList);
                    component.set("v.attachmentListFileNames", attachmentListFileNames);
                    this.checkShareToAllFlag(component); //OAVERSANO 17/12/2018 : Enhancement NMA Biz III
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                console.log("From server: " + JSON.stringify(response));
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    //new
    verifyReachedSize : function(component,event,helper)
    {
        var action = component.get("c.checkAttachments");
        var fileInput = component.find("fileId").get("v.files");
        var file = fileInput[0].size;
        console.log('@@file: '+file);
        
        action.setParams({
            CaseId: component.get("v.parentId"),
            FileName: component.get("v.fileName"),
            FileSize: file});
        
        action.setCallback(this, function(response) 
        {
        var state = response.getState();
        
            if(state == "SUCCESS")
            {
                var MAX = 26214400;
                console.log('@@reached: '+response.getReturnValue());
                 var reachedsize = response.getReturnValue().ReachedSize;
                var alreadyattached = response.getReturnValue().AlreadyAttached;
                
                if(alreadyattached)
                {
                	//OAVERSANO 17/12/2018 : Enhancement NMA Biz -- START
	            	component.set("v.showFileAttached",false);
	            	//OAVERSANO 17/12/2018 : Enhancement NMA Biz -- END
                    component.set("v.fileName", 'Attenzione, il file selezionato è già stato allegato alla richiesta');
            		component.set("v.isNewAttachment",false);
                    return;
                }
                else 
                {
                    var currentfilesizeInMb = Math.round(file/1048576 * 100) / 100;
                    var reachedinbyte = Math.round(reachedsize/1048576 * 100) / 100;
                    var remaining = MAX - reachedsize;
                    var remainingMB = Math.round(remaining/1048576 * 100) / 100;
                    
                    console.log('@currentfilesizeInMb: '+currentfilesizeInMb);
                    console.log('@reachedinbyte: '+reachedinbyte);
                    console.log('@remaining: '+remaining);
                    console.log('@remaininginMbyte: '+remainingMB);
                    
                    if(file> remaining)
                    {
                    	//OAVERSANO 17/12/2018 : Enhancement NMA Biz -- START
		            	component.set("v.showFileAttached",false);
		            	//OAVERSANO 17/12/2018 : Enhancement NMA Biz -- END
                        component.set("v.fileName", 'Attenzione, il file selezionato ha dimensione pari a '+currentfilesizeInMb+' MB, mentre è possibile associare alla richiesta solamente altri '+remainingMB+' MB');
                    	component.set("v.isNewAttachment",false);
                    }
                }  
            }
            else if(state=="ERROR")
            {
                var errors = response.getError();
                console.log('@@ERROR: '+errors); 
            }        
        });
        $A.enqueueAction(action);    
    },
    //new
    deleteAttachment : function(attachmentId) {
        
    },
    
    //OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- START
    checkShareToAllFlag : function(component, event, helper)
    {
    	console.log("checkShareToAllFlag method");
    	var stoConvRT = component.get("v.stoConvRT");
    	if(stoConvRT.indexOf("Agente")>-1)
    	{
    		component.set("v.shareToAllUsers", true);
    	}
    	else
    	{
    		component.set("v.shareToAllUsers", false);
    	}
    }
})
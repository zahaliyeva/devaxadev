({
    doInit: function(component, event, helper) { 
        var attachments = component.get("v.attachmentListFileNames");
        if (attachments.length == 0)
        {
            component.set("v.showAttachmentList", false);   
        }          
        else
        {
            component.set("v.showAttachmentList", true);   
        }
        //OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- START
        helper.checkShareToAllFlag(component);
        console.log("parentId : ",component.get("v.parentId"));
        //OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- END
    },
    doSave: function(component, event, helper) {
        if (component.get("v.parentId")!= "" && component.find("fileId").get("v.files")!=null)
            // if(component.find("fileId").get("v.files")!=null)
        {
            console.log('d: '+component.find("fileId").get("v.files").length);
            if (component.find("fileId").get("v.files").length > 0 && component.get("v.isNewAttachment")) {
                console.log('Upload Helper');
                helper.uploadHelper(component, event);
                component.set("v.isNewAttachment",false);
            } else {
            	//OAVERSANO 17/12/2018 : Enhancement NMA Biz -- START
            	component.set("v.showFileAttached",false);
            	//OAVERSANO 17/12/2018 : Enhancement NMA Biz -- END
                component.set("v.fileName","Selezionare un file prima di premere il pulsante 'Allega'");
            }
            
        }
        else
        {
        	//OAVERSANO 17/12/2018 : Enhancement NMA Biz -- START
        	component.set("v.showFileAttached",false);
        	//OAVERSANO 17/12/2018 : Enhancement NMA Biz -- END
        	component.set("v.fileName","Selezionare un file prima di premere il pulsante 'Allega'");
        }
            
        
    },
    
    handleFilesChange: function(component, event, helper) {
    	//OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- START
		component.set("v.showFileAttached",false);
		//OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- END
        var fileName = 'Nessun file selezionato';
        component.set("v.isNewAttachment",false);
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            component.set("v.isNewAttachment",true);
        }
        component.set("v.fileName", fileName);
        //OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- START
    	component.set("v.showFileAttached",true);
    	//OAVERSANO 17/12/2018 : Enhancement NMA Biz III -- END
        //helper.verifyReachedSize(component,event,helper);
        
        var action = component.get("c.checkAttachments");
        var fileInput = component.find("fileId").get("v.files");
        //OAVERSANO 20/12/2018 : Enhancement NMA Biz III -- START
        if(fileInput[0])
        {
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
        } //OAVERSANO 20/12/2018 : Enhancement NMA Biz III -- END
        $A.enqueueAction(action);        
    },
    
    handleChangeList: function(component, event, helper) {
        var list = component.get("v.attachmentList");
        if (typeof list!= undefined && list != null && list != "")
        {
            component.set ("v.showAttachmentList",true);
        }
    },
    
    doCancel: function(component, event, helper) {
        //console.log('SOURCE VALUE:' + event.getSource().get('v.value'));
        var attachments    = component.get("v.attachmentListFileNames");
        var attachmentList = component.get("v.attachmentList");
        //console.log('ATTACHMENTS:' + attachments);
        console.log('ATTACHMENTLIST:',attachmentList);
        var index = attachments.indexOf(event.getSource().get('v.value'));
        //helper.deleteAttachment(attachmentList[index]);
        var attachmentId = attachmentList[index];
        //console.log('ATTACHMENTID:' + attachmentId);
        component.set("v.showLoadingSpinner", true);
        var action = component.get("c.delAttachment");
        action.setParams({"attachId" : attachmentId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (component.get("v.jsDebug")) {
                    console.log('Success state');
                    console.log('Data:' + JSON.stringify(response.getReturnValue()));
                }
                attachments.splice(index, 1);
                attachmentList.splice(index, 1);
                component.set("v.attachmentListFileNames", attachments);
                component.set("v.attachmentList", attachmentList);
                if (attachments.length == 0)
                {
                    component.set("v.showAttachmentList", false);   
                }
            }
            else if (state === "INCOMPLETE") {
                if (component.get("v.jsDebug"))
                    console.log('Incomplete state');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            if (component.get("v.jsDebug"))
                                console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        if (component.get("v.jsDebug"))
                            console.log("Unknown error");
                    }
                }
            component.set("v.showLoadingSpinner", false);
        });  
        $A.enqueueAction(action); 
    }
})
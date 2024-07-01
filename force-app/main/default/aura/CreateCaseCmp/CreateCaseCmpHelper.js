({
    DefineSelectableLob : function(component)
    {
        var apexFunc = component.get("c.SetPicklistInitialValues");
        //var rectyp = {"RecordType":value};
        //apexFunc.setParams(rectyp);
        component.set("v.VisualizeButtons","false");
        var inputsel = component.find("LobSelection");
        apexFunc.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {  
                var Lista_lob = response.getReturnValue().Lob;
                component.set("v.Cpick",response.getReturnValue());
                
                component.set("v.ChatorganizationId",response.getReturnValue().OrgId);
                component.set("v.NewCase.User__c",response.getReturnValue().AgentId);
                component.set("v.NewCase.Agency_Code__c",response.getReturnValue().AgentInfos.Agency_Code__c);
                component.set("v.AgentName",response.getReturnValue().AgentInfos.Name+', Agenzia '+response.getReturnValue().AgentInfos.Agency_Code__c);                
                component.set("v.Theme",response.getReturnValue().Theme);
                component.set("v.Chatendpoint",response.getReturnValue().Chat_Endpoint);
                component.set("v.ChatdeploymentUrl",response.getReturnValue().Chat_deploymentUrl);
                component.set("v.ChatdeploymentId",response.getReturnValue().Chat_deploymentId);
                
                console.log(component.get("v.Cpick"));
                component.set("v.LobValueMappingList",response.getReturnValue().Lob_Cat_subCat_details);
                var opts=[];
                /* 
                for(var i=0;i< response.getReturnValue().length;i++){
                    opts.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
                }
                inputsel.set("v.options", opts);*/
                opts.push({"class": "optionClass", label: "--Selezionare Area--", value: ""});
                for(var i=0;i< Lista_lob.length;i++){
                    console.log(Lista_lob[i]);
                    opts.push({"class": "optionClass", label: Lista_lob[i], value: Lista_lob[i]});
                }
                inputsel.set("v.options", opts);
                
                
                
                
                //component.set("v.Lista_Lob", response.getReturnValue().LobList);  
                console.log('ritorno: '+response.getReturnValue().Lob);
            }
            else {
                //if (component.get("v.jsDebug")) console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(apexFunc);        
        
    },
    
    DefineCategories : function(component) 
    {
        var apexFunc = component.get("c.ChangeDisplayedCategories")
        console.log(component.get("v.NewCase.LOB__c"));
        apexFunc.setParams({
            "Selected_Lob": component.get("v.NewCase.LOB__c"),
            "Cpick" : JSON.stringify(component.get("v.Cpick"))
        });
        component.set("v.VisualizeButtons","false");
        console.log('@@component.find("CategorySelection"): '+component.find("CategorySelection"));
        
        apexFunc.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {  
                component.set("v.Cpick",response.getReturnValue());
                var opts=[];
                console.log(response.getReturnValue());
                var showError = response.getReturnValue().ShowTTP8Error;
                console.log('error: '+showError);
                component.set("v.ShowTTP8Error",showError);
                
                if(showError==false)
                {
                    
                    this.CategoriesSectionVisibility(component);
                    console.log('in show Error false');
                    var inputsel = component.find("CategorySelection");
                    var inputsubsel = component.find("Sub-CategorySelection");
                    var subopts = [];
                    subopts.push({"class": "optionClass", label: "--Selezionare Sotto Categoria--", value: ""});
                    inputsubsel.set("v.options", subopts);
                    var Categories = response.getReturnValue().Category;
                    opts.push({"class": "optionClass", label: "--Selezionare Categoria--", value: ""});
                    console.log('inputsel: ',inputsel);
                    console.log('Categories: ',Categories);
                    for(var i=0;i< Categories.length;i++){
                        opts.push({"class": "optionClass", label: Categories[i], value: Categories[i]});
                    }
                    inputsel.set("v.options", opts);
                    console.log('end show error false');
                }
                else
                {
                    component.set('v.ShowModal',true);
                    component.set("v.ShowCategoriesSection",false);
                }
                
            }
            else {
                //if (component.get("v.jsDebug")) console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(apexFunc);  
    },
    
    DefineSub_Categories : function(component) 
    {
        var apexFunc = component.get("c.ChangeDisplayedSub_Categories")
        console.log(component.get("v.NewCase.LOB__c"));
        component.set("v.VisualizeButtons","false");
        apexFunc.setParams({
            "Selected_Lob": component.get("v.NewCase.LOB__c"),
            "Selected_Category": component.get("v.NewCase.Category__c"),
            "Cpick" : JSON.stringify(component.get("v.Cpick"))
        });
        //var inputsel = component.find("Sub-CategorySelection");        
        apexFunc.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {  
                component.set("v.Cpick",response.getReturnValue());
                var SubCategories = response.getReturnValue().SubCategory;
                console.log('@@CaseType: '+response.getReturnValue().CaseType);
                component.set("v.NewCase.RecordTypeId",response.getReturnValue().CaseType);
                console.log('@@SubCategories: '+SubCategories+ '@@DisableSubCat: '+response.getReturnValue().DisableSubCat);
                component.set("v.DisableSubcategory",response.getReturnValue().DisableSubCat);
                var inputsel = component.find("Sub-CategorySelection");
                var opts=[];
                opts.push({"class": "optionClass", label: "--Selezionare Sotto Categoria--", value: ""});
                for(var i=0;i< SubCategories.length;i++){
                    opts.push({"class": "optionClass", label: SubCategories[i], value: SubCategories[i]});
                }
                inputsel.set("v.options", opts);
                
                if(response.getReturnValue().DisableSubCat)
                {
                    
                    component.set("v.NewCase.SubCategory__c","");
                    var apexFunc2 = component.get("c.SelectChatButtonId");
                    apexFunc2.setParams({
                        "Selected_Lob": component.get("v.NewCase.LOB__c"),
                        "Selected_Category": component.get("v.NewCase.Category__c"),
                        "Selected_SubCategory": "null",
                        "Cpick" : JSON.stringify(component.get("v.Cpick"))
                    });    
                    
                    apexFunc2.setCallback(this, function(response){
                        var state = response.getState();
                        if (component.isValid() && state === "SUCCESS") {  
                            component.set("v.ChatButtonId",response.getReturnValue().ButtonId);
                            component.set("v.VisualizeButtons","true");
                            console.log('@@ChatButtonId: '+response.getReturnValue().ButtonId);
                            let Category = (component.get("v.NewCase.Category__c")) != null ? component.get("v.NewCase.Category__c") : '';
                            let SubCategory = (component.get("v.NewCase.SubCategory__c")) != null ? component.get("v.NewCase.SubCategory__c") : '';
                            let Lob = (component.get("v.NewCase.LOB__c")) != null ? component.get("v.NewCase.LOB__c") : '';
                            var myEvent = component.getEvent("SendCategoryToFAQCmpEvent");
                            myEvent.setParams({"Category": Category,
                                               "SubCategory" : SubCategory,
                                               "Lob" : Lob});
                            myEvent.fire();
                        }
                        else {
                            //if (component.get("v.jsDebug")) console.log("Failed with state: " + state);
                        }
                    });                    
                    $A.enqueueAction(apexFunc2);
                }                
            }
            else {
                //if (component.get("v.jsDebug")) console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(apexFunc);  
    },
    
    SelectChatButton : function(component) 
    {   
        this.checkRTforCaringSalute(component);
        console.log('SelectChatButton');
        let Category = (component.get("v.NewCase.Category__c")) != null ? component.get("v.NewCase.Category__c") : '';
        let SubCategory = (component.get("v.NewCase.SubCategory__c")) != null ? component.get("v.NewCase.SubCategory__c") : '';
        let Lob = (component.get("v.NewCase.LOB__c")) != null ? component.get("v.NewCase.LOB__c") : '';
        var myEvent = component.getEvent("SendCategoryToFAQCmpEvent");
        myEvent.setParams({"Category": Category,
                           "SubCategory" : SubCategory,
                           "Lob" : Lob});
        myEvent.fire();
        var apexFunc = component.get("c.SelectChatButtonId")
        apexFunc.setParams({
            "Selected_Lob": component.get("v.NewCase.LOB__c"),
            "Selected_Category": component.get("v.NewCase.Category__c"),
            "Selected_SubCategory": component.get("v.NewCase.SubCategory__c"),
            "Cpick" : JSON.stringify(component.get("v.Cpick"))
        });
        
        apexFunc.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {  
            //OAVERSANO 24/01/2019 : NMA Fix Mobile -- START
            	if(response.getReturnValue())
            	{
            		if(response.getReturnValue().ButtonId!=null)
            		{
		                component.set("v.ChatButtonId",response.getReturnValue().ButtonId);
		                component.set("v.VisualizeButtons","true");
		                console.log('@@ChatButtonId: '+response.getReturnValue().ButtonId);
		                console.log('@@Case: ',component.get("v.NewCase"));
	                }
                }
            }
            //OAVERSANO 24/01/2019 : NMA Fix Mobile -- END
            else {
                //if (component.get("v.jsDebug")) console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(apexFunc);  
    },
    CategoriesSectionVisibility : function(component)
    {
        console.log("CategoriesSectionVisibility");
        component.set("v.ShowCategoriesSection",true);
    },
    fireEventLayout: function(component, event, helper)
    {
        let Category = (component.get("v.NewCase.Category__c")) != null ? component.get("v.NewCase.Category__c") : '';
        let SubCategory = (component.get("v.NewCase.SubCategory__c")) != null ? component.get("v.NewCase.SubCategory__c") : '';
        let Lob = (component.get("v.NewCase.LOB__c")) != null ? component.get("v.NewCase.LOB__c") : '';
        var myEvent = component.getEvent("SendCategoryToFAQCmpEvent");
        myEvent.setParams({"Category": Category,
                           "SubCategory" : SubCategory,
                           "Lob" : Lob});
        myEvent.fire();	
    },
    CreateAction : function (component,event,helper)
    {
        var apexFunc = component.get("c.CreateCase");
        var self=this;
        var cat = component.get("v.NewCase.Category__c");
        var object = component.get("v.NewCase.Subject");
        var description = component.get("v.NewCase.Description");
        var trattativeLM = component.get("v.ShowTrattativeLM");
        var nomeSocieta = component.get("v.NewCase.Nome_Societa__c");
        var pIva = component.get("v.NewCase.P_Iva__c");
        var broker = component.get("v.NewCase.Broker_Coinvolto__c");
        
        //  console.log('case: '+component.get("v.NewCase.InsurancePolicy__c"));
        
        
        if((cat && object && description && !trattativeLM) || (cat && object && description && trattativeLM && nomeSocieta && pIva && broker)  )
        {
            apexFunc.setParams({
                "NewCase": component.get("v.NewCase")
            });
            console.log('set'+JSON.stringify(component.get("v.NewCase")));
            apexFunc.setCallback(this, function(response){
                var state = response.getState();
                component.set("v.DisableCreateCase",false);
                if (component.isValid() && state === "SUCCESS") 
                { 
                    console.log('success');
                    var Results = response.getReturnValue()
                    var CaseId= Results.CaseId;
                    var ResultStatus = Results.ResultStatus;
                    var ResultMsg= Results.ResultMsg;
                    
                    if(ResultStatus=="OK")
                    {
                        console.log(component.get("v.Attachments").length);
                        
                        var attachments = component.get("v.Attachments");
                        console.log('attl: '+attachments.length);
                        
                        if(attachments.length>0)
                        {
                            component.get("v.IsAttachmentInsert",true);
                            
                            this.InsertAttachments(component,CaseId);
                        }
                        else
                            component.set("v.CaseIsCreated",true); 
                        //component.set("v.CaseIsCreated",true); 
                    }
                    else
                    {
                        component.set("v.BlockCreation",true);
                        component.set("v.ShowErrorMsg",true);
                        if($A.get("$Browser.isIOS"))
                    		component.set("v.displayCaseForm", "display: none;"); //OAVERSANO 29/01/2019 : NMA Fix Mobile
                        component.set("v.ErrorMsg","L'invio della richiesta non è andato a buon fine a causa del seguente errore: \n"+ResultMsg+".\n\nRiprova più tardi, se il problema persiste contattaci telefonicamente");
                        return;                        
                    }
                }
                else 
                {
                    var errors = response.getError();
                    
                    if (errors) 
                    {
                        if (errors[0] && errors[0].message) 
                        {
                            console.log("Error message: " + errors[0].message);
                        }
                    }
                    
                    component.set("v.BlockCreation",true);
                    component.set("v.ShowErrorMsg",true);
                    if($A.get("$Browser.isIOS"))
                		component.set("v.displayCaseForm", "display: none;"); //OAVERSANO 29/01/2019 : NMA Fix Mobile
                    component.set("v.ErrorMsg","L'invio della richiesta non è andato a buon fine a causa del seguente errore:\n"+errors[0].message+".\n\nSi prega di contattare l'amministratore di sistema.");                    
                    return;
                    console.log("Failed with state: " + state);
                }
            });
            $A.enqueueAction(apexFunc);
        }
        else
        {
            console.log('missing');
            component.set("v.BlockCreation",false);
            component.set("v.ShowErrorMsg",true);
            if($A.get("$Browser.isIOS"))
            	component.set("v.displayCaseForm", "display: none;"); //OAVERSANO 29/01/2019 : NMA Fix Mobile
            component.set("v.ErrorMsg","Attenzione ! Per inoltrare una nuova richiesta compilare tutti i campi obbligatori indicati dal carattere *");
            return;
        }
    },
    
    MAX_FILE_SIZE: 4500000,
    MAX_SUM_FILE_SIZE: 10485760, //Max file dimension 10 MB,
    CHUNK_SIZE: 750000,
    
    uploadHelper: function(component, event) {
    	try{ //OAVERSANO 25/01/2019 : NMA Fix Mobile -- START
        // start/show the loading spinner   
        component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        var reached_dimension = component.get("v.ReachedDimesion");
        console.log(reached_dimension);
        var fileInput = component.find("fileId").get("v.files");
        console.log (component.find("fileId"));
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        
        var fileName = file.name;
        var attachmentList = component.get("v.attachmentListFileNames");
        console.log('@attachmentList '+attachmentList);
        
        if(!component.get("v.newfileadded"))
        {
            component.set("v.fileName", 'Nessun file selezionato');
            component.set("v.showLoadingSpinner", false);
            return;
        }
        
        if (attachmentList.indexOf(fileName) != -1)
        {
            component.set("v.fileName", 'Attenzione, il file selezionato è già stato inserito');
            component.set("v.showLoadingSpinner", false);
            return;
            
        }             
        
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            console.log('1');
            component.set("v.showLoadingSpinner", false);
            var sizeInMb = Math.round(file.size/1048576 * 100) / 100;
            component.set("v.fileName", 'Attenzione, la dimensione massima consentita per il singolo allegato è pari a 4.5 MB.\n' + ' Il file selezionato ha dimensione ' + sizeInMb+' MB');
            return;
        }
        else if((reached_dimension + file.size) > self.MAX_SUM_FILE_SIZE)
        {
            console.log(reached_dimension+'____'+file.size);
            component.set("v.showLoadingSpinner", false);
            var RemainingsizeInMb = Math.round((self.MAX_SUM_FILE_SIZE-reached_dimension)/1048576 * 100) / 100;
            var sizeInMb = Math.round((file.size)/1048576 * 100) / 100;
            component.set("v.fileName", 'Attenzione, la dimensione massima consentita per l\'insieme degli allegati è pari a 10 MB. \n' + ' Il file selezionato ha dimensione ' + sizeInMb+' MB mentre possono essere ancora inseriti solo '+RemainingsizeInMb+' MB');
            return;                                
        }
  /*      
        var fileName = file.name;
        var attachmentList = component.get("v.attachmentListFileNames");
        console.log('@attachmentList '+attachmentList);
        
        if (attachmentList.indexOf(fileName) != -1)
        {
            component.set("v.fileName", 'Attenzione, il file selezionato è già stato inserito');
            component.set("v.showLoadingSpinner", false);
            return;
            
        }*/
        
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            //console.log("@@fileContents: "+fileContents);
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            
            self.addfileProcess(component, file, fileContents);
        });
        
        objFileReader.readAsDataURL(file);
        //OAVERSANO 25/01/2019 : NMA Fix Mobile -- START
        }
        catch(e)
        {
        	alert(e);
        }
        //OAVERSANO 25/01/2019 : NMA Fix Mobile -- END
    },
    
    addfileProcess: function(component, file, fileContents)
    {
        console.log('@@addfileProcess');
        console.log(file);
        //console.log(fileContents);
        console.log('@dimension: '+component.get("v.ReachedDimesion"));
        var dimension = component.get("v.ReachedDimesion");
        console.log('@dimension: '+dimension);
        dimension = dimension + file.size;
        component.set("v.ReachedDimesion",dimension);
        console.log('@dimension_1: '+component.get("v.ReachedDimesion"));
        var att = component.get("v.Attachments");
        console.log('te: '+JSON.stringify(file));
        var attbody = component.get("v.Bodymap");
        //att.push(file.name+'VFC26'+file.type);
        att.push(file);
        console.log('##att: '+att);
        //attbody[file.name]=encodeURIComponent(fileContents);
        attbody[file.name]=fileContents;
        component.set("v.Attachments",att);  
        component.set("v.Bodymap",attbody);  
        
        var fileName = file.name;
        var attachmentList = component.get("v.attachmentListFileNames");
        console.log('@attachmentList '+attachmentList);
        
        if (attachmentList.indexOf(fileName) != -1){//already present
            console.log('3');
        }else if (fileName!="Nessun file selezionato")
        {
            console.log('4');
            attachmentList.push(fileName);
            component.set("v.attachmentListFileNames",attachmentList);
            component.set("v.newfileadded",false);
        }
        // update the start position with end postion
        console.log('5');
        console.log('sono qui');
        
        component.set("v.fileName","Nessun file selezionato");
        component.find("fileId").set('v.files', null);
        console.log('File allegato con successo');
        component.set("v.showLoadingSpinner", false);         
    },
    InsertAttachments : function (component,caseid)
    {
        var att = component.get("v.Attachments");
        var attbody = component.get("v.Bodymap");
        component.set("v.AttachmentNumber",att.length);
        
        for(var i=0;i<att.length;i++)
        { 
            console.log('for');
            var file = att[i];
            console.log('file: '+file.name);
            var fileContents = attbody[file.name];
            var startPosition = 0;
            var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);  
            var attachId='';
            this.uploadInChunk(component, caseid,file, fileContents, startPosition, endPosition, '');            
        }
    },
    uploadInChunk: function(component, caseid,file, fileContents, startPosition, endPosition, attachId) {
        console.log(caseid+'__'+file.name+'__'+'___'+startPosition+'___'+endPosition);
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        action.setParams({
            parentId: caseid,
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
        });
        
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start position is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, caseid,file, fileContents, startPosition, endPosition, attachId);
                }
                else
                {
                    var num= component.get("v.AttachmentNumber");
                    console.log('@num: '+num);
                    num--;
                    component.set("v.AttachmentNumber",num);
                    console.log('@num1: '+num)
                    if(0==num)
                    {
                        console.log('end!!');
                        component.set("v.CaseIsCreated",true); 
                    }
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
    } ,
    checkRTforCaringSalute: function(component){
    if(component.get("v.NewCase.LOB__c")=='Sinistri Salute'){
     var action = component.get("c.getCaringSaluteRT");
      
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
             component.set("v.NewCase.RecordTypeId",response.getReturnValue());
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
    }

   }
})
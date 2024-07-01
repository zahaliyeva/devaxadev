({
	doInit : function(component, event, helper){
        let caseId = component.get('v.CaseId');
        console.log('caseId: ', caseId);
       
        if(caseId==null || caseId =="")
        {
        	component.set("v.errorFromServer",true);
        	component.set("v.errorDetails","Blank value...");
        }
        else
        {
        	component.set("v.isLoading",true);
        	component.set("v.emptySolution",false);
	        var action = component.get("c.GetCaseInfo");
	        action.setParams({ "caseId" : caseId});
	
	        action.setCallback(this, function(response) {
	            var state = response.getState();
	            if (state === "SUCCESS") {
	               let result = response.getReturnValue();
	                console.log('result: ',result);
                    console.log('Callback --> SUCCESS');
                    component.set("v.currentCase", result);
                    if(result!=null){
	                    if(result.OwnerId!=null)
	                    {
	                    	if(result.OwnerId.startsWith("00G"))
	                    	{
	                    		component.set("v.OwnerIsQueue",true);
	                    	}
	                    	else
	                    	{
	                    		component.set("v.OwnerIsQueue",false);
	                    	}
	                    }
	                }
	                else
	                {
	                	console.log("Unknown error");
	                    component.set("v.errorFromServer",true);
                		component.set("v.errorDetails","Error: Case not found");
                		component.set("v.CaseId","");
	                }
	                component.set("v.isLoading",false);
	            }
	            else if (state === "INCOMPLETE") {
	            }
	            else if (state === "ERROR") {
	            
	            	component.set("v.isLoading",false);
	                var errors = response.getError();
	                if (errors) {
	                    if (errors[0] && errors[0].message) {
	                    	componens.set("v.errorFromServer",true);
	                        console.log("Error message: " + 
	                                 errors[0].message);
	                                 component.set("v.errorDetails",errors[0].message)
	                    }
	                } else {
	                    console.log("Unknown error");
	                    component.set("v.WrongSolution","Unknown error");
	                }
	            }
	        });
	        $A.enqueueAction(action);
	    }
	},
	
	handleModalConfirmFunctionEvent : function(component, event, helper){
		console.log('UpdateSolution');
		//OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- START
		var buttonValue = event.getParam("buttonValue");
		if(buttonValue == 'cancel')
		{
			console.log("buttonValue : ",buttonValue);
			//OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- START
			var attachmentList = component.get("v.attachmentList");
			console.log("attachmentList : ",attachmentList);
			helper.deleteAttachments(component, attachmentList);
			//OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- END
		}
		else
		{
			component.set("v.showAttachmentBox", false); 
		//OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- END
	        let value = component.get('v.solutionDetails');
	        let caseId = component.get('v.CaseId');
	        console.log('value: ', value);
	       
	        if(value==null || value =="")
	        {
	        	component.set("v.emptySolution",true);
	        }
	        else
	        {
	        	component.set("v.isLoading",true);
	        	component.set("v.emptySolution",false);
		        var action = component.get("c.UpdateSolutionDetail");
		        action.setParams({ "caseId" : caseId,
		                          "value" :	value});
		
		        action.setCallback(this, function(response) {
		            var state = response.getState();
		            if (state === "SUCCESS") {
		               let result = response.getReturnValue();
		                console.log('result: ',result);
		                if( result == 'OK')
		                {
							console.log('Callback --> SUCCESS');
							if(component.get("v.lghtMode")!= true)
							window.location.href =  '/lightning/r/Case/'+component.get("v.CaseId")+'/view';
						  else{
							  component.set("v.isLoading",false);
							  var p = component.get("v.parent");						
							  p.doCloseModal();
							  $A.get('e.force:refreshView').fire();
						  }
		                }
		                else if(result.indexOf('KO|Fallito')>-1)
		                {
		                	component.set("v.isLoading",false);
		                    console.log(result.substring('KO|Fallito'.length,result.lenght));
		                    component.set("v.errorFromServer",true);
		                    component.set("v.errorDetails",result.substring('KO|Fallito'.length,result.lenght));
		                    
		                }
		                else
		                {
		                	console.log('errore');
		                	component.set("v.isLoading",false);
		                	component.set("v.errorFromServer",true);
		                	component.set("v.errorDetails",result.substring('KO|Fallito'.length,result.lenght));
		                }
		            }
		            else if (state === "INCOMPLETE") {
		            }
		            else if (state === "ERROR") {
		            
		            	component.set("v.isLoading",false);
		                var errors = response.getError();
		                if (errors) {
		                    if (errors[0] && errors[0].message) {
		                    	componens.set("v.errorFromServer",true);
		                        console.log("Error message: " + 
		                                 errors[0].message);
		                                 component.set("v.errorDetails",errors[0].message)
		                    }
		                } else {
		                    console.log("Unknown error");
		                    component.set("v.WrongSolution","Unknown error");
		                }
		            }
		        });
		        $A.enqueueAction(action);
	        }	//OAVERSANO 18/12/2018 : Enhancement NMA Biz III 
	    }
	},
    //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza ENHANCEMENT -- START
    countCharacters: function(component,event,helper){
        let value =  event.getSource().get("v.value");
        let charactersN = value.length;
        component.set("v.remainingCharacters",1000-charactersN);
    },
    //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza ENHANCEMENT -- END
    //OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- START
    openAddAttachment: function(component,event,helper){
        component.set("v.showAttachmentBox", true);
    },
    closeAddAttachment: function(component,event,helper){
        component.set("v.showAttachmentBox", false);
    }
    //OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- END
})
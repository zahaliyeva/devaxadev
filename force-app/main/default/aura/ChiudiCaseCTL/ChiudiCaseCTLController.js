({
	doInit: function(component, event, helper) {
        //console.log("@@caseId: "+component.get("v.caseId"));
        //OAVERSANO 07/03/2019 : CR ICF -- START
        var pathName = window.location.pathname;
        var agencyIndex = pathName.indexOf("agenzie");
        var myURL = "https://"+window.location.hostname;
        if (agencyIndex!= -1)
        {
        	myURL = myURL+"/agenzie";
        }
        myURL = myURL+"/";
        //OAVERSANO 07/03/2019 : CR ICF -- END
        if(component.get("v.caseId"))
        {
            console.log(component.get("v.caseId"));
        }
        else
        {
            window.open(myURL+component.get("v.caseId"), "_self");//OAVERSANO 07/03/2019 : CR ICF 
        }
      
    },
    Cancel: function(component, event, helper) {
    	//OAVERSANO 07/03/2019 : CR ICF -- START
    	var pathName = window.location.pathname;
        var agencyIndex = pathName.indexOf("agenzie");
        var myURL = "https://"+window.location.hostname;
        if (agencyIndex!= -1)
        {
        	myURL = myURL+"/agenzie";
        }
        myURL = myURL+"/";
    	window.open(myURL+component.get("v.caseId"), "_self");
    	//OAVERSANO 07/03/2019 : CR ICF -- START
    },
    UpdateCase: function(component, event, helper) {
    	console.log('UpdateCase');
        let value = component.get('v.commentoCTL');
        let caseId = component.get('v.caseId');
        console.log('value: ', value);
        //OAVERSANO 07/03/2019 : CR ICF -- START
        var pathName = window.location.pathname;
        var agencyIndex = pathName.indexOf("agenzie");
        var myURL = "https://"+window.location.hostname;
        if (agencyIndex!= -1)
        {
        	myURL = myURL+"/agenzie";
        }
        myURL = myURL+"/";
        //OAVERSANO 07/03/2019 : CR ICF -- END
        if(value==null || value =="")
        {
        	component.set("v.emptySolution",true);
        }
        else
        {
        	component.set("v.isLoading",true);
        	component.set("v.emptySolution",false);
	        var action = component.get("c.UpdateCaseCTL");
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
	                    window.open(myURL+component.get("v.caseId"), "_self");//OAVERSANO 07/03/2019 : CR ICF 
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
	                    	component.set("v.errorFromServer",true);
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
	}
})
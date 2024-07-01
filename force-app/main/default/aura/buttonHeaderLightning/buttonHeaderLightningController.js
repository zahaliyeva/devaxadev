({
	doInit : function(component, event, helper){
		console.log('INIT');
		var attributes = { CaseId : component.get("v.recordId")};
		console.log('attributes before: ',attributes);
		component.set("v.attributes",attributes);
		//OAVERSANO 12/11/2018 : Nuovo Modello di Assistenza -- START
		var attributesNCA = { CaseId : component.get("v.recordId")};
		component.set("v.attributesNCA",attributesNCA);
		//OAVERSANO 12/11/2018 : Nuovo Modello di Assistenza -- END
		var obj = component.get("v.attributes");
		//Object.keys(obj).forEach(key => console.log(obj[key]));
		
		//OAVERSANO 18/10/2018 : Caring Angel -- START
		var action = component.get("c.buttonVisible");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	let result = response.getReturnValue();
	            
	            if(result)
	            {
	            	console.log('result buttonVisible: ',result);
	            	console.log('Callback --> SUCCESS');
	            	
		            if(result.ProponiSoluzione!=null)
		                component.set("v.ShowProponiSoluzione", result.ProponiSoluzione); 
		            if(result.NewCommentAndAttachment!=null)
		                component.set("v.ShowNewCommentAndAttachment", result.NewCommentAndAttachment);
		            if(result.ChiudiCase!=null)
						component.set("v.ShowChiudiCase", result.ChiudiCase);
					//Giorgio Bonifazi Bug FIX 512 -- START
					if(result.SendSMS!=null)
					component.set("v.ShowSendSMS", result.SendSMS);
					//Giorgio Bonifazi Bug FIX 512 -- END
		            //OAVERSANO 12/11/2018 : Nuovo Modello di Assistenza -- START
		            var attributesNCA = component.get("v.attributesNCA");
		            if(result.isHD2Biz)
		            {
		            	
		            	//VIZZINI_D 25/06/2019: NMA - Lob Modulo di Calcolo - START
						//attributesNCA["buttonLabel"] = "Invia commento/allegato ad HD1 o all’Agente";
						attributesNCA["buttonLabel"] = "Inserisci nuovo commento/allegato";
						//VIZZINI_D 25/06/2019: NMA - Lob Modulo di Calcolo - END
		            }
		            else
		            {
						//VIZZINI_D 25/06/2019: NMA - Lob Modulo di Calcolo - START
						//attributesNCA["buttonLabel"] = "Invia commento e case ad HD1";
						attributesNCA["buttonLabel"] = "Inserisci nuovo commento/allegato";
						//VIZZINI_D 25/06/2019: NMA - Lob Modulo di Calcolo - END
		            }
		            component.set("v.showAllButton", true);
		            //OAVERSANO 12/11/2018 : Nuovo Modello di Assistenza -- END
                }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                component.set("v.showAllButton", true);
            }
        });
        
        
        $A.enqueueAction(action);
        //OAVERSANO 18/10/2018 : Caring Angel -- END
	},
	//OAVERSANO 14/01/2019 : Enhancement NMA IV -- START
	stampaPagina : function(component, event, helper)
	{
		let prefix = $A.get("$Label.c.SiteDomain");
		var vfUrl = prefix+'/apex/PrintableView?id='+component.get("v.recordId")+'&plName=Assistenza Agenti_HD2_PrintableView';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": vfUrl
        });
        urlEvent.fire();
	}
	//OAVERSANO 14/01/2019 : Enhancement NMA IV -- END
})
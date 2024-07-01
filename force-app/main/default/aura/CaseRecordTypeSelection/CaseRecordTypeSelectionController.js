({
    doInit : function(component, event, helper) {
        helper.retrieveTypes(component,event,helper);		
    },
    
    ConfirmSelection : function(component,event,helper){
    	//OAVERSANO 21/03/2019 : AXA Assistance -- START
    	let parentCmp =  component.get("v.parentCmp");
    	console.log("parentCmp: "+parentCmp);
    	if(parentCmp!=null && parentCmp == "GetAllClaims") {
    		var compEvents = component.getEvent("RTClaimsEvent");
    		console.log("RTidClaims: "+component.get("v.SelectedRTid"));
    		compEvents.setParams({ "RTid" : component.get("v.SelectedRTid") });
    		compEvents.fire();

        } else {
	        var compEvents = component.getEvent("RTEvent");
	        console.log("RTid: "+component.get("v.SelectedRTid"));
	        compEvents.setParams({ "RTid" : component.get("v.SelectedRTid") });

            // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II -- START
	        if(parentCmp === 'NewLightningCase') {
	            compEvents.setParams({ "isCaseRapido" : true }); // gestione Case Rapido
            }
            // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II -- END
	        
	        compEvents.fire();
        }	
        //OAVERSANO 21/03/2019 : AXA Assistance -- END
    },
    onChange : function(component,event,helper){
        var dynamicCmp = component.find("InputSelectDynamic");
        console.log(dynamicCmp);
        component.set("v.SelectedRTid",dynamicCmp.get("v.value"));
        
        if(dynamicCmp.get("v.value"))
        	component.set("v.isSelected",true);
        else
            component.set("v.isSelected",false);
    }
})
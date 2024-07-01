({
    doInit: function(component, event, helper) {
        console.log("@@caseId: "+component.get("v.caseId"));
        //OAVERSANO 16/10/2018 : Fix Instant Feedback -- START
        let source = component.get("v.source");
        console.log("@@source: "+component.get("v.source"));
        if(source!=null && source == "email")
        {
            console.log("instantFeedback from email");
           	helper.checkEmailFeedback(component, event, helper);
        }
        else if(component.get("v.caseId"))
        //if(component.get("v.caseId"))
        //OAVERSANO 16/10/2018 : Fix Instant Feedback -- END
        { 
            helper.checkError(component, event, helper);
        }
        else
        {
            if(component.get("v.UserTheme") == "Theme4t")
            {
            	//OAVERSANO 28/01/2019 : NMA Fix Mobile -- START
            	//sforce.one.back(true);
            	if(typeof sforce != 'undefined' && sforce.one!= undefined )
            		sforce.one.back(true);
        		else
                    window.close();
            	//OAVERSANO 28/01/2019 : NMA Fix Mobile -- END
            }
            else
                window.close();
        }
      //  helper.feedbackConfiguration(component, event, helper);
		//helper.checkError(component, event, helper);	       
       // helper.getOrgURL(component, event, helper);
    }, 
    cancelBtn : function(component, event, helper) { 
        helper.cancelBtn(component);
    },
    clickCreate: function(component, event, helper) {
        helper.clickCreate(component, event, helper);
    },
    CloseMissingInputsModal: function(component,event,helper){
        helper.closeMissingInputsModal(component);
    },    
    closeFeedback : function(component,event,helper){
        helper.closeFeedback(component,event,helper);
    },
  
 // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    },
    //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza ENHANCEMENT -- START
    countCharacters: function(component,event,helper){
        let value =  event.getSource().get("v.value");
        let charactersN = value.length;
        component.set("v.remainingCharacters",1000-charactersN);
    },
    //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza ENHANCEMENT -- END  
})
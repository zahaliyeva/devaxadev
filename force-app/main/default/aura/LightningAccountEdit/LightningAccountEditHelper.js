({
    setVariabledFromPageReference : function(component) {
        let pageReference = component.get("v.pageReference");
        console.log('state: ' + pageReference.state);
        if(pageReference && pageReference.state.c__recordId){
            component.set("v.recordId", pageReference.state.c__recordId);
        }
        if(pageReference && pageReference.state.c__CaseId){
            component.set("v.CaseId", pageReference.state.c__CaseId);
        }
        if(pageReference && pageReference.state.c__retUrl){
            component.set("v.retUrl", pageReference.state.c__retUrl);
        }
        if(pageReference && pageReference.state.c__CampMemberId){
            component.set("v.CampMemberId", pageReference.state.c__CampMemberId);
        }
        if(pageReference && pageReference.state.c__CampaignId){
            component.set("v.CampaignId", pageReference.state.c__CampaignId);
        }
        if(pageReference && pageReference.state.c__PhoneCallId){
            component.set("v.PhoneCallId", pageReference.state.c__PhoneCallId.split("_")[0]);
        }
    },

    getData : function(component) {
        var action = component.get("c.getData");
        action.setParams({ 
            recordId : component.get("v.recordId"),
            callId : component.get("v.PhoneCallId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                this.setGetDataResponseData(component, response.getReturnValue());
                console.log('show aai: ' + component.get("v.showAAIEdit"));
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
            }
        });

        $A.enqueueAction(action);
    },

     setGetDataResponseData : function(component, responseData) {
         component.set("v.showAAIEdit", responseData.showAAIEdit);
         component.set("v.userIsAdvisor", responseData.userIsAdvisor);
         component.set("v.jsDebug", responseData.jsDebug);
         component.set("v.MPSEnrichment", responseData.MPSEnrichment);
         let caseId = component.get("v.CaseId");
         if( !caseId && responseData.foundCaseId ) {
            component.set("v.CaseId", responseData.foundCaseId);
         }
         component.set("v.screenWidth",  (window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth));
         
     }
})
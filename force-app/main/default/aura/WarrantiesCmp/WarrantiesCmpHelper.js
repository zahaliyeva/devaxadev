({
    startSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
        console.log("SPINNER START");
    },
    stopSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, 'slds-hide');
        console.log("SPINNER STOP");
    },
	setDataTable : function(component) {

        this.startSpinner(component);
		var action = component.get("c.getDataComplete");
		action.setParams({"recordId" : component.get('v.recordId')});
		action.setCallback(this, function(response1) {
            
            var state1 = response1.getState();
            if (state1 === "SUCCESS") {
                console.log('Success state');
                console.log('Data:' + JSON.stringify(response1.getReturnValue()));

                var resp = response1.getReturnValue();
                console.log('Data: ');
                console.log(resp);
				component.set('v.data', resp.slice(0,3));
                if(resp.length > 3){
                    component.set('v.enableFullList', true);
                } else {
                    component.set('v.enableFullList', false);
                }
            }
            else if (state1 === "INCOMPLETE") {
                console.log('Incomplete state');
            }
            else if (state1 === "ERROR") {
                var errors = response1.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            this.stopSpinner(component);
        });  
        $A.enqueueAction(action);
	},

    navigateTo : function(component){
      var pathName = window.location.pathname;
      var agencyIndex = pathName.indexOf("agenzie");
      var pathCrm = pathName.includes("crm");
      var url ;
      if (agencyIndex!= -1)
      {
          url = "https://" + window.location.hostname + "/apex/WarrantiesCompletePage?scontrolCaching=1&id=" + component.get('v.recordId');
      } else if (pathCrm) {    
          url = "/crm/s/garanzie?recordId=" + component.get('v.recordId');
      } 
          else{
               url = "https://" + window.location.hostname + "/apex/WarrantiesCompletePage?id=" + component.get('v.recordId');
          }
        console.log(url);

        window.open(url, "_parent", "resizable=no,top=200,left=500,width=500,height=200");
    }
})
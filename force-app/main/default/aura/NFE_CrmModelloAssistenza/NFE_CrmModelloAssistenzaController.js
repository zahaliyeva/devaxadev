({
  Initialize: function(component, event, helper) {
    helper.retrievePageVal(component);
  },

  createNewCase: function (component, event, helper) {

    if (component.get("v.jsDebug")) console.log("inside redirect");
    var pathName = window.location.pathname;
    var agencyIndex = pathName.indexOf("agenzie");
    var myURL = "https://"+window.location.hostname; 
    if (agencyIndex!= -1)
    {
      myURL = myURL+"/agenzie";
    }

  },

  gotoPreviousPage: function (component, event, helper){
    window.history.back();
  }
})
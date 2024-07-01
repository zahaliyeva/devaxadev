({

    getData : function(component) {

      var action = component.get("c.getAccountData");

      action.setParams({ 
          recordId : component.get("v.recordId"),
      });
      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              this.setGetDataResponseData(component, response.getReturnValue());
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
    /*component.set("v.FirstName", responseData.FirstName);
    component.set("v.LastName", responseData.LastName);  */
      component.set("v.Name", responseData.Name);
  },
  
  startSpinner: function (cmp) {
    var spinner = cmp.find("mySpinner");
    $A.util.removeClass(spinner, 'slds-hide');
  },

  stopSpinner: function (cmp) {
    var spinner = cmp.find("mySpinner");
    $A.util.addClass(spinner, 'slds-hide');
  }, 

  showToast : function(message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Success!",
        "message": message,
        "type" : "success"
    });
    toastEvent.fire();
  },
  redirectpage : function (component){
    if (component.get("v.jsDebug")) console.log("inside redirect");
      var pathName = window.location.pathname;
      var agencyIndex = pathName.indexOf("agenzie");
      var id  = component.get("v.recordId");
      
      var myURL = "https://"+window.location.hostname;
      if (agencyIndex!= -1)
      {
        myURL = myURL+"/agenzie";
      }
      myURL = myURL+"/"+id;
      if (component.get("v.jsDebug")) console.log("********"+myURL);
      window.location.href = myURL;
     // window.location.href = myURL;
  /*
      var sObjectEvent = $A.get("e.force:navigateToSObject");
      sObjectEvent.setParams({
          "recordId": component.get("v.currentAccount.Id"),
          "slideDevName": 'related'
      })
      sObjectEvent.fire();*/
  
   },   

})
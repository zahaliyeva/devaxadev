({
    helperMethod : function() {
        
    },
    startSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
    },
    stopSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, 'slds-hide');
    },
    redirectpage : function (component){
        if (component.get("v.jsDebug")) console.log("inside redirect");
        var pathName = window.location.pathname;
        var agencyIndex = pathName.indexOf("agenzie");
        var myURL = "https://"+window.location.hostname;
        var campaignId = component.get("v.recordId");
        if (agencyIndex!= -1)
        {
            myURL = myURL+"/agenzie";
        }
        myURL = myURL+"/"+campaignId;
        if (component.get("v.jsDebug")) console.log("********"+myURL);
        if (component.get("v.jsDebug")) console.log ("*****sforce.one "+sforce.one);
        if ( (typeof sforce.one != 'undefined') && (sforce.one != null) )
        {
            //sforce.one.navigateToSObject(campaignId);
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": campaignId,
              "slideDevName": "detail"
            });
            navEvt.fire();
           /* var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/00Q/o"
            });
            urlEvent.fire();*/
        }
        else
        {	
            window.location.href = myURL;
        }
        // window.location.href = myURL;
        /*
      var sObjectEvent = $A.get("e.force:navigateToSObject");
      sObjectEvent.setParams({
          "recordId": component.get("v.currentAccount.Id"),
          "slideDevName": 'related'
      })
      sObjectEvent.fire();*/
        
    },
    setError: function (component,title,message)
    {
        component.set("v.isError",true);
        component.set("v.errorTitle",title);
        component.set("v.errorMsg",message);
    }
})
({
    helperMethod : function() {
        
    },
    startSpinner: function (cmp) {
        cmp.set("v.toggleSpinner", true);  
        //var spinner = cmp.find("mySpinner");
        //$A.util.removeClass(spinner, 'slds-hide');
    },
    stopSpinner: function (cmp) {
        cmp.set("v.toggleSpinner", false);  
        //var spinner = cmp.find("mySpinner");
        //$A.util.addClass(spinner, 'slds-hide');
    },
    redirectpage : function (component){
        //MOBILITY - START
        
        const isMobility = component.get('v.isMobility');
        if(isMobility){
            const queueType  = component.get("v.queueType"); 
            if(queueType === 'Case'){
                window.location.href = '/crm/s/case/Case/Default';   
            }
            return;
        }
        
        //MOBILITY - END

        if (component.get("v.jsDebug")) console.log("inside redirect");
        var pathName = window.location.pathname;
        var agencyIndex = pathName.indexOf("agenzie");
        var myURL = "https://"+window.location.hostname;
        if (agencyIndex!= -1)
        {
            myURL = myURL+"/agenzie";
        }
        var endUrl = '';
        var queueType  = component.get("v.queueType"); 
        if (queueType =='Lead') endUrl=  '/00Q/o';
        if (queueType =='Case') endUrl=  '/apex/VFP_CaseListCustom';
        myURL = myURL+endUrl;
        console.log("********"+myURL);
        if (component.get("v.jsDebug")) console.log ("*****sforce.one "+sforce.one);


        if ( (typeof sforce.one != 'undefined') && (sforce.one != null) )
        {
            //sforce.one.navigateToSObject(id);
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": endUrl
            });
            urlEvent.fire();
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
    },
    validateMail : function(component, email) {        
           
        var emailFilter = new RegExp(component.get("v.patternEmail"));
        if (typeof  email == "undefined" || email == "") {
            return true;
        }else{  
            return emailFilter.test(email);
        } 
     }
 
})
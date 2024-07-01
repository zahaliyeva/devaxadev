({


     Initialize: function(component, event, helper) {
     helper.retrievePageVal(component);

      var ProfileName = component.get("ProfileName");
      var UserMainNode = component.get("UserMainNode");
      var screenwidth = component.get("screenwidth");
      console.log('Profile e Main Node'+ProfileName+' '+UserMainNode);
      console.log('screenwidth'+screenwidth);
      var CodiceAgenzia = component.get('v.CodiceAgenzia'); 
      console.log('CodiceAgenzia'+CodiceAgenzia);

     },

    createNewCase: function (component, event, helper) {

	
      if (component.get("v.jsDebug")) console.log("inside redirect");
      var pathName = window.location.pathname;
      var agencyIndex = pathName.indexOf("agenzie");
      var pathCrm = pathName.includes("crm");
      var myURL = "https://"+window.location.hostname;
      if (agencyIndex!= -1)
      {
          myURL = myURL+"/agenzie/apex/VFP26_AgentCreateCaseLightning";
      } else if (pathCrm) {    
             myURL = myURL+"/crm/s/assistenza-nuovo-caso-new";
      } else {
      	  myURL = myURL+'/apex/VFP26_AgentCreateCaseLightning';
      }
      if (component.get("v.jsDebug")) console.log("********"+myURL);
      if (component.get("v.jsDebug")) console.log ("*****sforce.one "+sforce.one);
      if ((typeof sforce != 'undefined') && (typeof sforce.one != 'undefined') && (sforce.one != null) )
      {
        sforce.one.navigateToURL(myURL);
      }
      else
      {
        //window.open(myURL); //open New Case page in a new tab of the browser
        window.location.href = myURL; //open New Case page in the same tab of ModelloAssistenza
      }
   },

  gotoPreviousPage: function (component, event, helper){

    
      window.history.back();

    }

 
 }



   

})
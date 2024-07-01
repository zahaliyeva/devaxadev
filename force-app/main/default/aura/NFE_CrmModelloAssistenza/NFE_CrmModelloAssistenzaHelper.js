({

  retrievePageVal: function(component,event,helper){
    var retrPVal = component.get("c.getPageValues");
    var arrayOfMapKeys = [];

    retrPVal.setCallback(this, function(a) {

      var ObtainedMap = a.getReturnValue();


      for (var singlekey in ObtainedMap)
      {
        arrayOfMapKeys.push(singlekey);
      }
      console.log('keys: '+arrayOfMapKeys);
      for(var i=0;i<arrayOfMapKeys.length;i++)
      {
        var key = arrayOfMapKeys[i];

        if(key.split("|")[0] == "isStandardUser")
        {
          console.log('Dentro isStandardUser'+ObtainedMap[key]);

          if(ObtainedMap[key]=="true")
            component.set("v.StdUsr",true);
          else
            component.set("v.StdUsr",false);
        }
        else if(key.split("|")[0] == "UserAgency")
        {
          console.log('Dentro UserAgency');

          component.set("v.CodiceAgenzia",ObtainedMap[key]);


        }
        else if(key.split("|")[0] == "UserRole")
        {
          console.log('Dentro UserRole: '+ObtainedMap[key]);
          component.set("v.UserRole",ObtainedMap[key]);
        }
        else if(key.split("|")[0] == "UserProfile")
        {
          console.log('Dentro UserProfile: '+ObtainedMap[key]);

          component.set("v.UserProfile",ObtainedMap[key]);
        }
        else if(key.split("|")[0] == "UserId")
        {
          console.log('Dentro UserId: '+ObtainedMap[key]);

          /*var UserType = component.get("v.UserRole");

          UserType = UserType.toLowerCase();

          if(UserType.includes("responsabile") == false && component.get("v.StdUsr")==false){
              console.log('type');
              component.set("v.CollaboratoreId",ObtainedMap[key]);
          }*/
          component.set("v.UserId",ObtainedMap[key]);
        }
        else if(key.split("|")[0] == "UserName")
        {
          console.log('Dentro UserName: '+ObtainedMap[key]);

          component.set("v.UserName",ObtainedMap[key]);
        }
        else if(key.split("|")[0] == "isPilotaAgency")
        {
          var Profile = component.get("v.UserProfile");
          console.log('Dentro isPilotaAgency: '+ObtainedMap[key]);

          component.set("v.isPilota",ObtainedMap[key]);
          if(Profile == 'System Administrator' || Profile == 'Amministratore del sistema'){
            component.set("v.isPilota",'true');
          }
        }

        component.set("v.isPilota",'true');
      }



    });
    $A.enqueueAction(retrPVal);


  }


})
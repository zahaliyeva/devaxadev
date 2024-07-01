({
    retrieveTypes : function(component,event,helper) {
        var action = component.get("c.getSelectableTypes");
        
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               var opts = [];
                               
                               if (state === "SUCCESS")
                               {
                                   var result = response.getReturnValue();
                                   //opts.push({"class": "optionClass", label: "--Nessun valore selezionato--", value: ""});

                                   for(var key in result)
                                   {                                       
                                    console.log(result[key]);
   
                                    if(key!="Principale")
                                    	opts.push({"class": "optionClass", label: key, value: result[key]});
                                   }
                                   if(result!=null)
                                   {
                                       console.log('SelectedRTid selected: '+result["Sinistri Danni Banca"]);
                                       component.set("v.SelectedRTid",result["Sinistri Danni Banca"]);
                                   	component.set("v.isSelected",true);
                                   }
                                   console.log("Types: ",opts);
                                   
                                   component.find("InputSelectDynamic").set("v.options", opts);
                                   
                                   if(result)
                                   {
                                       console.log('##Result: ',result);
                                       component.set("v.ShowRTSelection",true);
                                   }
                               }
                               else if (state === "INCOMPLETE")
                               {
                               }
                                   else if (state === "ERROR")
                                   {
                                       
                                   }
                           });
        $A.enqueueAction(action);        
    }
})
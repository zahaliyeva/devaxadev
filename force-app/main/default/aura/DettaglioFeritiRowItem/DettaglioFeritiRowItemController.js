({
    doInit : function(component, event, helper) {     
        helper.getListOfRegularExpressions(component); //set validator Expr   
    }
    ,
    AddNewRow : function(component, event, helper){
       // fire the AddNewRowEvt Lightning Event
        component.getEvent("AddRowEvt").fire();    
    },
    
    removeRow : function(component, event, helper){       
     // fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute      
       component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    },

    toggle : function (component, event, helper) {
        var sel = component.find("mySelect");
        var nav = sel.get("v.value");
    }
  
})
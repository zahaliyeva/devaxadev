({
 
    // function call on component Load
    doInit: function(component, event, helper) {
        // create a Default RowItem on first time Component Load
        // by call this helper function  
       if (component.get("v.testimoniFeritiList").length==0)
        helper.createObjectData(component, event);
    },
 
    // function for save the Records
    Save: function(component, event, helper) {
	
    },
 
    // function for create new object Row in Contact List
    addNewRow: function(component, event, helper) {
        // call the comman "createObjectData" helper method for add new Object Row to List  
        helper.createObjectData(component, event);
    },
 
    // function for delete the row
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        var index = event.getParam("indexVar");
        // get the all List (testimoniFeritiList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.testimoniFeritiList");
        AllRowsList.splice(index, 1);
        // set the testimoniFeritiList after remove selected row element  
        component.set("v.testimoniFeritiList", AllRowsList);        
    },
})
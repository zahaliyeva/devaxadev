({
    doInit : function(component, event, helper) {
        helper.init(component, event, helper);
    },
     
    getSelectedRow: function (component, event, helper) {   
        helper.getRow(component, event,helper);   
    },
   
    goToOpportunity: function (component, event, helper) {
        helper.gotToDetail(component, event,helper, component.get("v.opportunityInfo").Id);
    },
    
     goToProposta: function (component, event, helper) {
        helper.gotToDetail(component, event,helper, component.get("v.PropostaCreated").Id);
    },
    
    goToConfirm: function (component, event, helper) {
        if (component.get("v.selectedRowsCodiceProposta") != null && component.get("v.selectedRowsCodiceProposta")!= ' ' )        
        helper.confirm(component, event,helper);
        else
         helper.showToast(component,'Error!','Selezionare una proposta','error');
    },
    
})
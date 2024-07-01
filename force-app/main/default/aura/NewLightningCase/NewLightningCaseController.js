({
    doInit : function(component, event, helper)
    {
        console.log('NewCaringAngelCase_START');
        component.set("v.page",1);
        helper.checkShowRT(component,event,helper);//MOSCATELLI_M 13/03/2019: Axa Assistance
    },
    
    searchCustomers: function (component, event, helper) 
    {
        var page = component.get("v.page");
        var recordToDisplay = component.get("v.recordToDisplay");
        component.set("v.ErrorSearchCustomer","");
        component.set("v.ShowCustomerTable",false);
        component.set("v.ShowCaseTable",false);
        component.set("v.CasesAreFound",false);
        //Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - START -->
        component.set("v.ShowButtonNoAnagrafica",false);
        //Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - END -->
        component.set("v.CasesFoundMap","{}");
        component.set("v.dataCases","{}");
        
        helper.fetchData(component, page,recordToDisplay);
    },
    viewClaims: function(component,event,helper)
    {
        console.log('##evento: ',event.target.id);
        
        component.set("v.SelectedFiscal",""+event.target.id);
        component.set("v.SelectedAccountId",""+event.target.name);
        
        if(event.target.id)
            component.set("v.OpenClaim",true);
        
        var row = event.target.parentElement.parentElement.parentElement;
        var row_type = 'ClientiRows';
        helper.highlightRow(component, event, helper, row,row_type);
        
        var cmpTarget = component.find('modale');
        var cmpBack = component.find('background');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    },
    closeClaimModal: function(component,event,helper)
    {
        var cmpTarget = component.find('modale');
        var cmpBack = component.find('background');
        component.set("v.OpenClaim",false);
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.removeClass(cmpBack, 'slds-backdrop--open');    	
    },
    viewCases: function(component,event,helper)
    {
        console.log('##evento: ',event.target.id);
        component.set("v.ErrorSearchCase","");
        component.set("v.ShowCaseTable",false);
        
        
        component.set("v.SelectedAccountId",""+event.target.id);
        helper.findCases(component,event,helper);
        
        var row = event.target.parentElement.parentElement.parentElement;
        var row_type = 'ClientiRows';
        helper.highlightRow(component, event, helper, row,row_type);
    },
    openCasePage: function(component,event,helper)
    {
        component.set("v.SelectedCaseId",""+event.target.id);
        component.set("v.SelectedCaseNumber",""+event.target.name);
        console.log("##SelectedCaseId: "+event.target.id);
        console.log("##SelectedCaseNumber: "+event.target.name);
        var row = event.target.parentElement.parentElement.parentElement;
        var row_type = 'CaseRows';
        helper.highlightRow(component, event, helper, row,row_type);
        helper.ViewCase(component,event,helper);
        
    },
    navigate: function(component, event, helper) {
        var page = component.get("v.page") || 1;
        var direction = event.getSource().get("v.label");
        
        page = direction === "Indietro" ? (page - 1) : (page + 1);
        var recordToDisplay = component.get("v.recordToDisplay");
        helper.Nextcustomerpage(component, page, recordToDisplay);
        
    },
    
    navigateCase: function(component, event, helper) {
        var page = component.get("v.pageCase") || 1;
        var direction = event.getSource().get("v.label");
        
        page = direction === "Indietro" ? (page - 1) : (page + 1);
        var recordToDisplay = component.get("v.recordToDisplay");
        helper.Nextcasepage(component, page, recordToDisplay);
        
    },
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){
        component.set("v.Spinner", false);
    },
    CreateNewCase : function(component,event,helper){
        console.log('##evento: ',event.target.id);
        component.set("v.SelectedAccountId",""+event.target.id);
        helper.CreateCase(component,event,helper);       
    },
    //Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - START -->
    CreateNewCaseNoAnagrafica : function(component,event,helper){
        console.log('##evento: ',event.target.id);
        helper.CreateCaseNoAnagrafica(component,event,helper);
    //Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - END -->
    },
    CreateCaseRT : function(component,event,helper)
    {
        component.set("v.SelectedAccountId",""+event.target.id);
        component.set("v.CaseWithRT",true);
    },
    chiudiToast : function(component, event, helper) 
    {
        /*
        component.set("v.messageToast", "");
        component.set("v.typeToast", "");
        component.set("v.showToast",false);*/
        
        var myEvent = $A.get("e.c:tabclosing");
        myEvent.setParams({"data":'Close_NewCase_page',
                           "recordid":'',
                           "Url":''});
        myEvent.fire(); 
    },
    handleRTEvent: function(component,event,helper)
    {
        console.log("parent");
        var RTID = event.getParam("RTid");
        console.log("SelectedCaseType: "+RTID);
        component.set("v.SelectedCaseType",RTID);

        if(event.getParam("isCaseRapido")) { // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II
            component.set("v.showCaseRapidoModal", false);
            helper.createCaseRapido(component, event, helper);

        } else {
            component.set("v.CaseWithRT",false);
            helper.CreateCase(component,event,helper);
        }
    },
    //MOSCATELLI_M 13/03/2019: Axa Assistance-START
    resetFilters: function(component,event,helper)
    {
        component.set("v.CustomerName","");
        component.set("v.CustomerSurname","");
        component.set("v.CustomerBirthDate","");
        component.set("v.FiscalId","");
        component.set("v.Plate","");
        component.set("v.Policy","");
		component.set("v.CustomerIVA",""); 
        component.set("v.ShowCustomerTable",false);
        component.set("v.ClienteIsFound",false);
        //Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - START -->
        component.set("v.ShowButtonNoAnagrafica",false);
        //Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - END -->
    },
    //MOSCATELLI_M 13/03/2019: Axa Assistance-END

    // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II -- START
    showCaseRapidoModal: function(component, event, helper) {
        component.set("v.showCaseRapidoModal",true);
    },

    closeCaseRapidoModal: function(component, event, helper) {
        component.set("v.showCaseRapidoModal",false);
    },

    closeCaseWithRT: function(component, event, helper) {
        component.set("v.CaseWithRT", false);
    }
    // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II -- END
})
({
    doInit : function(component, event, helper) {
        debugger; 
        if(!component.set("v.SelectedCaseType")){
            let selectedCaseType = component.get("v.pageReference").state.c__SelectedCaseType;
            component.set("v.SelectedCaseType", selectedCaseType);
            console.log('Set Attribute SelectedCaseType', selectedCaseType);
            helper.setCaseRecordTypeDeveloperName(component, helper);
        }
        if(!component.set("v.SelectedCaseTypeName")){ 
            let selectedCaseTypeName = component.get("v.pageReference").state.c__SelectedCaseTypeName;
            component.set("v.SelectedCaseTypeName", selectedCaseTypeName);
            console.log('Set Attribute SelectedCaseTypeName', selectedCaseTypeName);
        }
        if(!component.set("v.CaseNewAction")){
            let caseNewAction = component.get("v.pageReference").state.c__CaseNewAction;
            component.set("v.CaseNewAction", caseNewAction);
            console.log('Set Attribute CaseNewAction', caseNewAction);
        }
        if(!component.set("v.FormType")){
            let formType = component.get("v.pageReference").state.c__FormType;
            component.set("v.FormType", formType);
            console.log('Set Attribute FormType', formType);
        }
        if(!component.set("v.VoiceCall")){
            let VoiceCall = component.get("v.pageReference").state.TECH_Voice_Call__c;
            component.set("v.VoiceCall", VoiceCall);
            console.log('Set Attribute VoiceCall', VoiceCall);
        }
        component.set("v.page",1); 
        component.set('v.visibilitiesCallback', (componentName, visibility)=>{
			helper.setVisibilities(component, componentName, visibility)
        });
    },
    creaCaseSenzaAnagrafica : function(component,event,helper){
        helper.creaCaseSenzaAnagrafica(component,event,helper);
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
        helper.setFocusedTabAttributes(component, 'Nuovo Case', "utility:case");
        helper.fetchData(component, page,recordToDisplay);
    },
    viewClaims: function(component,event,helper)
    {
        console.log('##evento: ',event.target.id);
        
        component.set("v.SelectedFiscal",""+event.target.id);
        component.set("v.SelectedAccountId",""+event.target.name);
        
        if(event.target.id){
            //vecchia modale per Caring Angel (migrato a lightning quindi property non utilizzata)
            component.set("v.OpenClaim",true);
            //nuova modale  (forzo la visibilità come se avesse GetAllClaims a true nel metadato CaseVisibilities)
            helper.setVisibilities(component, 'GetAllClaims', true);
        }
        
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
    createNewCase : function(component,event,helper){
        console.log('##evento: ',event.target.id);
        component.set("v.SelectedAccountId",""+event.target.id);
        helper.createCase(component,event,helper);       
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
        helper.navigateToObject(component, event.target.id);
        
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
        helper.showSpinner(component);
    },
    hideSpinner : function(component,event,helper){
        helper.hideSpinner(component);
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
    onCreateCaseRapido: function(component,event,helper){
        helper.handleCreateCaseRapido(component, event, helper);
    },
    handleRTEvent: function(component,event,helper)
    {
        console.log("parent");
        var RTID = event.getParam("RTid");
        console.log("SelectedCaseType: "+RTID);
        component.set("v.SelectedCaseType",RTID);

        if(event.getParam("isCaseRapido")) { // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II
            component.set("v.showCaseRapidoModal", false);
            helper.handleCreateCaseRapido(component, event, helper);

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
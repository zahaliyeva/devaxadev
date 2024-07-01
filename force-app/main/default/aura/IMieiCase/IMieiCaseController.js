({
    
    initializeComponent : function(component, event, helper) {
        if ((typeof sforce != 'undefined') && (typeof sforce.one != 'undefined') && (sforce.one != null) ){
            component.set('v.isMobile',true);
        }else{
            component.set('v.isMobile',false);
        }
        //component.set('v.isMobile',true); test Mobile behaviour on desktop
        component.set("v.Title",'RICHIESTE DI AGENZIA');
        component.set("v.SObjectName",'Case');
        //MOSCATELLI_M 25/10/2018: NMA Business - START
        //component.set("v.FieldNames",['CaseNumber','User__r.Name','Origin','Oggetto_Apertura_Case__c','Category__c','Status','CreatedDate','ClosedDate','E2E_Age_in_BH_Text__c','Time_with_Customer_Text__c','LOB__c']);
        //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- START
        //component.set("v.FieldNames",['CaseNumber','User__r.Name','Origin','Oggetto_Apertura_Case__c','Category__c','Status','CreatedDate','ClosedDate','E2E_Age_in_BH_Text__c','Time_with_Customer_Text__c','LOB__c','Description']);
        component.set("v.FieldNames",['CaseNumber','User__r.Name','Origin','LOB__c','Category__c','Oggetto_Apertura_Case__c','Status','CreatedDate','ClosedDate','E2E_Age_in_BH_Text__c','Time_with_Customer_Text__c','Description']);
        //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- END
        //MOSCATELLI_M 25/10/2018: NMA Business - END
        component.set("v.ReferenceFields",['CaseNumber']);
        //component.set("v.FieldLabels",['','','','','','','','Durata lavorazione','']);
        component.set('v.PrivateMatchCriteria', component.get('v.MatchCriteria'));
        component.set('v.SelectedRecordsMap', new Map());
        helper.goSetClosedStatusSearch(component);//MOSCATELLI_M 25/10/2018: NMA Business
        console.log('@@MatchCriteria: '+component.get('v.PrivateMatchCriteria'));
        helper.retrievePageVal(component);
        helper.initializePageSizeSelectList(component);
        helper.initializeColumnMetaData(component);
        
        
        //helper.fetchPicklistValues(component, 'LOB__c', 'Category__c');
        
        
    },
    
    
    updateMatchCriteria : function(component, event, helper) {
        component.set('v.PrivateMatchCriteria', event.getParam('value'));
        helper.retrieveTotalRecords(component);
        helper.retrieveRecords(component, true);
    },
    
    selectRecord : function(component, event, helper){
        helper.switchRow(component, parseInt(event.srcElement.dataset.id), event.srcElement.checked);
    },
    
    selectAllRecords : function(component, event, helper){
        helper.switchAllRows(component, event.srcElement.checked);
    },
    
    changeSort : function(component, event, helper){
        let clicked_element = event.srcElement;
        let sort_field = clicked_element.dataset.id;
        let current_sort_field = component.get('v.SortByField');
        let sort_order = component.get('v.SortOrder');
        if(sort_field === current_sort_field){
            if(sort_order === 'ASC'){
                sort_order = 'DESC';
            } else {
                sort_order = 'ASC';
            }
        } else {
            current_sort_field = sort_field;
            sort_order = 'DESC';
        }
        component.set('v.PageNumber', 1);
        component.set('v.SortByField', current_sort_field);
        component.set('v.SortOrder', sort_order);
        helper.retrieveRecords(component, false);
    },
    
    firstPage : function(component, event, helper) {
        let has_previous = component.get('v.HasPrevious');
        if(has_previous){
            component.set('v.PageNumber', 1);
            helper.updateTableRows(component);
        }
    },
    
    previousPage : function(component, event, helper) {
        let has_previous = component.get('v.HasPrevious');
        if(has_previous){
            let page_number = component.get('v.PageNumber');
            page_number = page_number - 1;
            component.set('v.PageNumber', page_number);
            helper.updateTableRows(component);
        }
    },
    
    nextPage : function(component, event, helper) {
        let has_next = component.get('v.HasNext');
        if(has_next){
            let page_number = component.get('v.PageNumber');
            page_number = page_number + 1;
            component.set('v.PageNumber', page_number);
            helper.updateTableRows(component);
        }
    },
    
    lastPage : function(component, event, helper) {
        let has_next = component.get('v.HasNext');
        if(has_next){
            let page_number = component.get('v.PageTotal');
            component.set('v.PageNumber', page_number);
            helper.updateTableRows(component);
        }
    },
    
    changePageSize : function(component, event, helper) {
        component.set('v.PageNumber', 1);
        component.set('v.PageSize', component.find('pageSizeInput').get('v.value'));
        helper.updateTableRows(component);
    },
    
    navigateToSObject : function (component, event, helper) {
        
        if (component.get("v.jsDebug")) console.log("inside redirect");
        var record_id = event.currentTarget.id;
        console.log('record_id'+record_id);
        var pathName = window.location.pathname;
        var agencyIndex = pathName.indexOf("agenzie");
        var pathCrm = pathName.includes("crm");
        var myURL = "https://"+window.location.hostname;
        if (agencyIndex!= -1)
        {
            myURL = myURL+"/agenzie/"+record_id;
        } else if (pathCrm) {    
          myURL = myURL+"/crm/s/case/"+record_id+"/detail";
        } else {
      	  myURL = myURL+"/"+record_id;
        }
        if (component.get("v.jsDebug")) console.log("********"+myURL);
        //if (component.get("v.jsDebug")) console.log ("*****sforce.one "+sforce.one);
        if ((typeof sforce != 'undefined') && (typeof sforce.one != 'undefined') && (sforce.one != null) )
        {
            sforce.one.navigateToSObject(record_id);
        }
        else
        {
            window.open(myURL);
        }
    },
    
    InitFilters: function(component, event, helper)
    {   
        
        helper.InitializeCollFilter(component,event,helper);
        helper.fillstatus(component);
        helper.filllob(component);
        helper.fillcategory(component);
        
        
    },
    
    SetCollaboratore : function(component, event, helper) {
        helper.goSetCollaboratore(component);
    },
    
    ApplyFilters: function(component,event,helper){
        helper.retrieveRecords(component, true);
        
    },
    
    SetStato : function(component, event, helper) {
        helper.goSetStato(component);
        
    },
    
    SetLOB : function(component, event, helper) {
        helper.goSetLOB(component);
        
    },
    
    SetCategory : function(component, event, helper) {
        helper.goSetCategory(component);
        
    },
    
    SetObject : function(component, event, helper) {
        helper.goSetObject(component);
    },
    
    SetTarga : function(component, event, helper) {
        helper.goSetTarga(component);
    },
    
    ApplyFilters: function(component,event,helper){
        helper.retrieveRecords(component, true);
        
    },
    
    resetValues : function(component,event,helper){
        
        component.set("v.CollaboratoreId","");  
        component.find("inputList_collaboratori").set("v.value","");  
        component.find("inputStatus").set("v.value",null);
        component.find("inputLOB").set("v.value",null);
        component.find("inputcategory").set("v.value",null);
        component.find("inputText_Oggetto").set("v.value",null);
        component.find("inputText_Targa").set("v.value","");
        component.set("v.Stato","");
        component.set("v.LOB","");
        //component.set("v.PrivateMatchCriteria","RecordType.DeveloperName = 'Assistenza_Agenti' and Status NOT IN ('Attesa Info Agente','Soluzione proposta')");
        component.set("v.PrivateMatchCriteria","RecordType.DeveloperName = 'Assistenza_Agenti'");
        component.set("v.Categoria","");
        component.set("v.Oggetto","");
        component.set("v.Targa","");
        //MOSCATELLI_M 25/10/2018: NMA Business - START
        component.set("v.Numero_Case","");
        component.set("v.Descrizione_Case","");
        component.find("inputText_NumeroCase").set("v.value",null);
        component.find("inputText_DescrizioneRichiesta").set("v.value",""); 
        helper.goSetClosedStatusSearch(component);
        //MOSCATELLI_M 25/10/2018: NMA Business - END
        helper.fillcategory(component);
        helper.retrieveRecords(component, true);
        component.set("v.isDependentDisable",true);
    },
    //MOSCATELLI_M 25/10/2018: NMA Business - START
        SetCaseNumber : function(component, event, helper) {
        helper.goSetCaseNumber(component);
    },
        SetCaseDescription : function(component, event, helper) {
        helper.goSetCaseDescription(component);
    },
    
    SetClosedStatusSearch: function(component, event, helper) {
        helper.goSetClosedStatusSearch(component);      
    }
    //MOSCATELLI_M 25/10/2018: NMA Business - END 
})
({

    initializeComponent : function(component, event, helper) {
        if ((typeof sforce != 'undefined') && (typeof sforce.one != 'undefined') && (sforce.one != null) ){
            component.set('v.isMobile',true);
        }else{
            component.set('v.isMobile',false);
        }
        var UserId = component.get("v.UserId");
        console.log('UserId an'+UserId);
    	component.set("v.Title",'AZIONI A MIO CARICO');
    	component.set("v.SObjectName",'Case');
    	//OAVERSANO 19/02/2019 : NMA FIX Mobile II -- START
    	//component.set("v.FieldNames",['CaseNumber','User__r.Name','Origin','Oggetto_Apertura_Case__c','Status','CreatedDate','Data_soluzione_proposta__c']);
    	component.set("v.FieldNames",['CaseNumber','User__r.Name','Origin','LOB__c','Category__c','Oggetto_Apertura_Case__c','Status','CreatedDate','Data_soluzione_proposta__c']);
    	//OAVERSANO 19/02/2019 : NMA FIX Mobile II -- END
    	component.set("v.ReferenceFields",['CaseNumber']);
    	//component.set("v.FieldLabels",['CaseNumber','Account.Name','Origin','Oggetto_Apertura_Case__c','Status','CreatedDate','ClosedDate']);
        component.set('v.PrivateMatchCriteria', component.get('v.MatchCriteria')+ " and User__c ="+"'"+UserId+"'");
        console.log('PrivateMatchCriteria'+component.get('v.PrivateMatchCriteria'));
        component.set('v.SelectedRecordsMap', new Map());
        //helper.retrievePageVal(component);
        helper.initializePageSizeSelectList(component);
        helper.initializeColumnMetaData(component);
        

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
   }

   })
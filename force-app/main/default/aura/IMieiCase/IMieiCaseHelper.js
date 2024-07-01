({
    
    initializePageSizeSelectList : function(component) {
        let page_size = component.get('v.PageSize');
        let available_page_sizes = component.get('v.AvailablePageSizes');
        let options = [];
        for(let option in available_page_sizes){
            options.push({
                value: available_page_sizes[option],
                label: available_page_sizes[option],
                selected: (available_page_sizes[option] === page_size)
            });
        }
        var pageSizeInput = component.find('pageSizeInput');
        if(pageSizeInput != undefined && pageSizeInput != null){
            pageSizeInput.set('v.options', options);
        }
    },
    
    initializeColumnMetaData : function(component) {
        let action = component.get("c.getColumnMetadata");
        action.setParams({
            sobject_name: component.get('v.SObjectName'),
            field_names: component.get('v.FieldNames'),
            field_labels: component.get('v.FieldLabels'),
            sortable_field_names: component.get('v.SortableFieldNames'),
            reference_fields: component.get('v.ReferenceFields'),
            override_field_type: component.get('v.OverrideFieldType')
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){
                let column_metadata_wrapper = JSON.parse(response.getReturnValue());
                if(column_metadata_wrapper.error_message){
                    this.handleErrorMessage(component, column_metadata_wrapper.error_message);
                } else {
                    let field_names = component.get('v.FieldNames');
                    var UserProfile = component.get('v.UserProfile');
                    //console.log('field_names'+field_names);
                    let selection_column = component.get('v.SelectionColumn');
                    let table_columns = [];
                    if(selection_column){
                        table_columns.push({
                            is_selection_column: true
                        });
                    }
                    for(let i = 0; i < field_names.length; i++){
                        if(field_names[i]!='Description')//MOSCATELLI_M 25/10/2018: NMA Business
                        {
                            if( field_names[i]!='LOB__c' && field_names[i]!='User__r.Name' && field_names[i]!='Origin' && field_names[i]!='Oggetto_Apertura_Case__c' && field_names[i]!='CaseNumber'){ //&& field_names[i]!='E2E_Age_in_BH_Text__c' field_names[i]!='Category__c' &&
                                table_columns.push({
                                    is_selection_column: false,
                                    field_name: field_names[i],
                                    field_api_name: column_metadata_wrapper.column_metadata[field_names[i]].field_api_name,
                                    field_label: column_metadata_wrapper.column_metadata[field_names[i]].field_label,
                                    field_type: column_metadata_wrapper.column_metadata[field_names[i]].field_type,
                                    field_override_type: column_metadata_wrapper.column_metadata[field_names[i]].field_override_type,
                                    field_is_reference: column_metadata_wrapper.column_metadata[field_names[i]].field_is_reference,
                                    field_is_sortable: column_metadata_wrapper.column_metadata[field_names[i]].field_is_sortable
                                });
                            }
                            if(field_names[i]=='User__r.Name'){
                                if(UserProfile == 'AAI - Vendite Avanzato' || UserProfile == 'AAI - Vendite Base' || UserProfile == 'AAI - Vendite No Accordo Digitale' || UserProfile == 'AAI - Vendite solo Assistenza'){
                                    table_columns.push({
                                        is_selection_column: false,
                                        field_name: field_names[i],
                                        field_api_name: column_metadata_wrapper.column_metadata[field_names[i]].field_api_name,
                                        field_label: 'Richiedente',
                                        field_type: column_metadata_wrapper.column_metadata[field_names[i]].field_type,
                                        field_override_type: column_metadata_wrapper.column_metadata[field_names[i]].field_override_type,
                                        field_is_reference: column_metadata_wrapper.column_metadata[field_names[i]].field_is_reference,
                                        field_is_sortable: column_metadata_wrapper.column_metadata[field_names[i]].field_is_sortable
                                    });
                                }else{
                                    table_columns.push({
                                        is_selection_column: false,
                                        field_name: field_names[i],
                                        field_api_name: column_metadata_wrapper.column_metadata[field_names[i]].field_api_name,
                                        field_label: column_metadata_wrapper.column_metadata[field_names[i]].field_label,
                                        field_type: column_metadata_wrapper.column_metadata[field_names[i]].field_type,
                                        field_override_type: column_metadata_wrapper.column_metadata[field_names[i]].field_override_type,
                                        field_is_reference: column_metadata_wrapper.column_metadata[field_names[i]].field_is_reference,
                                        field_is_sortable: column_metadata_wrapper.column_metadata[field_names[i]].field_is_sortable
                                    });
                                    
                                }
                            }
                            if(field_names[i]=='Origin'){
                                if(UserProfile == 'AAI - Vendite Avanzato' || UserProfile == 'AAI - Vendite Base' || UserProfile == 'AAI - Vendite No Accordo Digitale' || UserProfile == 'AAI - Vendite solo Assistenza'){
                                    table_columns.push({
                                        is_selection_column: false,
                                        field_name: field_names[i],
                                        field_api_name: column_metadata_wrapper.column_metadata[field_names[i]].field_api_name,
                                        field_label: 'Canale',
                                        field_type: column_metadata_wrapper.column_metadata[field_names[i]].field_type,
                                        field_override_type: column_metadata_wrapper.column_metadata[field_names[i]].field_override_type,
                                        field_is_reference: column_metadata_wrapper.column_metadata[field_names[i]].field_is_reference,
                                        field_is_sortable: column_metadata_wrapper.column_metadata[field_names[i]].field_is_sortable
                                    });
                                }else{
                                    table_columns.push({
                                        is_selection_column: false,
                                        field_name: field_names[i],
                                        field_api_name: column_metadata_wrapper.column_metadata[field_names[i]].field_api_name,
                                        field_label: column_metadata_wrapper.column_metadata[field_names[i]].field_label,
                                        field_type: column_metadata_wrapper.column_metadata[field_names[i]].field_type,
                                        field_override_type: column_metadata_wrapper.column_metadata[field_names[i]].field_override_type,
                                        field_is_reference: column_metadata_wrapper.column_metadata[field_names[i]].field_is_reference,
                                        field_is_sortable: column_metadata_wrapper.column_metadata[field_names[i]].field_is_sortable
                                    });
                                    
                                }
                            }
                            if(field_names[i]=='Oggetto_Apertura_Case__c'){
                                if(UserProfile == 'AAI - Vendite Avanzato' || UserProfile == 'AAI - Vendite Base' || UserProfile == 'AAI - Vendite No Accordo Digitale' || UserProfile == 'AAI - Vendite solo Assistenza'){
                                    table_columns.push({
                                        is_selection_column: false,
                                        field_name: field_names[i],
                                        field_api_name: column_metadata_wrapper.column_metadata[field_names[i]].field_api_name,
                                        field_label: 'Oggetto',
                                        field_type: column_metadata_wrapper.column_metadata[field_names[i]].field_type,
                                        field_override_type: column_metadata_wrapper.column_metadata[field_names[i]].field_override_type,
                                        field_is_reference: column_metadata_wrapper.column_metadata[field_names[i]].field_is_reference,
                                        field_is_sortable: column_metadata_wrapper.column_metadata[field_names[i]].field_is_sortable
                                    });
                                }else{
                                    table_columns.push({
                                        is_selection_column: false,
                                        field_name: field_names[i],
                                        field_api_name: column_metadata_wrapper.column_metadata[field_names[i]].field_api_name,
                                        field_label: column_metadata_wrapper.column_metadata[field_names[i]].field_label,
                                        field_type: column_metadata_wrapper.column_metadata[field_names[i]].field_type,
                                        field_override_type: column_metadata_wrapper.column_metadata[field_names[i]].field_override_type,
                                        field_is_reference: column_metadata_wrapper.column_metadata[field_names[i]].field_is_reference,
                                        field_is_sortable: column_metadata_wrapper.column_metadata[field_names[i]].field_is_sortable
                                    });
                                    
                                }
                            }
                            if(field_names[i]=='CaseNumber'){
                                if(UserProfile == 'AAI - Vendite Avanzato' || UserProfile == 'AAI - Vendite Base' || UserProfile == 'AAI - Vendite No Accordo Digitale' || UserProfile == 'AAI - Vendite solo Assistenza'){
                                    table_columns.push({
                                        is_selection_column: false,
                                        field_name: field_names[i],
                                        field_api_name: column_metadata_wrapper.column_metadata[field_names[i]].field_api_name,
                                        field_label: 'Numero richiesta',
                                        field_type: column_metadata_wrapper.column_metadata[field_names[i]].field_type,
                                        field_override_type: column_metadata_wrapper.column_metadata[field_names[i]].field_override_type,
                                        field_is_reference: column_metadata_wrapper.column_metadata[field_names[i]].field_is_reference,
                                        field_is_sortable: column_metadata_wrapper.column_metadata[field_names[i]].field_is_sortable
                                    });
                                }else{
                                    table_columns.push({
                                        is_selection_column: false,
                                        field_name: field_names[i],
                                        field_api_name: column_metadata_wrapper.column_metadata[field_names[i]].field_api_name,
                                        field_label: column_metadata_wrapper.column_metadata[field_names[i]].field_label,
                                        field_type: column_metadata_wrapper.column_metadata[field_names[i]].field_type,
                                        field_override_type: column_metadata_wrapper.column_metadata[field_names[i]].field_override_type,
                                        field_is_reference: column_metadata_wrapper.column_metadata[field_names[i]].field_is_reference,
                                        field_is_sortable: column_metadata_wrapper.column_metadata[field_names[i]].field_is_sortable
                                    });
                                    
                                }
                            }
                            //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- START
                            if(field_names[i]=='LOB__c'){
                                if(UserProfile == 'AAI - Vendite Avanzato' || UserProfile == 'AAI - Vendite Base' || UserProfile == 'AAI - Vendite No Accordo Digitale' || UserProfile == 'AAI - Vendite solo Assistenza'){
                                    table_columns.push({
                                        is_selection_column: false,
                                        field_name: field_names[i],
                                        field_api_name: column_metadata_wrapper.column_metadata[field_names[i]].field_api_name,
                                        field_label: 'Area',
                                        field_type: column_metadata_wrapper.column_metadata[field_names[i]].field_type,
                                        field_override_type: column_metadata_wrapper.column_metadata[field_names[i]].field_override_type,
                                        field_is_reference: column_metadata_wrapper.column_metadata[field_names[i]].field_is_reference,
                                        field_is_sortable: column_metadata_wrapper.column_metadata[field_names[i]].field_is_sortable
                                    });
                                }else{
                                    table_columns.push({
                                        is_selection_column: false,
                                        field_name: field_names[i],
                                        field_api_name: column_metadata_wrapper.column_metadata[field_names[i]].field_api_name,
                                        field_label: column_metadata_wrapper.column_metadata[field_names[i]].field_label,
                                        field_type: column_metadata_wrapper.column_metadata[field_names[i]].field_type,
                                        field_override_type: column_metadata_wrapper.column_metadata[field_names[i]].field_override_type,
                                        field_is_reference: column_metadata_wrapper.column_metadata[field_names[i]].field_is_reference,
                                        field_is_sortable: column_metadata_wrapper.column_metadata[field_names[i]].field_is_sortable
                                    });
                                }
                            }
                            //OAVERSANO 11/12/2018 : Enhancement NMA Biz -- END
                        }
                    }
                    component.set('v.ColumnMetadata', column_metadata_wrapper.column_metadata);
                    //OAVERSANO 03/12/2018 : FIX IE11 -- START
                    console.log('table_columns.length: ',table_columns.length);
                    if(component.get("v.SelectionColumn"))
                        component.set("v.TableColumnsSize",table_columns.length+1);
                    else
                        component.set("v.TableColumnsSize",table_columns.length);
                    //OAVERSANO 03/12/2018 : FIX IE11 -- END
                    component.set('v.TableColumns', table_columns);
                    this.retrieveTotalRecords(component);
                    this.retrieveRecords(component, true);
                }
            } else if(state === 'ERROR'){
                this.handleErrorMessage(component, response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    retrieveTotalRecords : function(component){
        let action = component.get('c.getTotalRecords');
        action.setParams({
            sobject_name: component.get('v.SObjectName'),
            match_criteria: component.get('v.PrivateMatchCriteria')
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){
                let total_records = parseInt(response.getReturnValue());
                component.set('v.TotalRecords', total_records);
            } else if(state === 'ERROR'){
                this.handleErrorMessage(component, response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    retrieveRecords : function(component, criteria_have_changed){
        this.startSpinner(component); 
        console.log('retrieveRecords query: '+component.get('v.PrivateMatchCriteria'));
        let action = component.get('c.getRecords');
        action.setParams({
            sobject_name: component.get('v.SObjectName'),
            field_names: component.get('v.FieldNames'),
            match_criteria: component.get('v.PrivateMatchCriteria'),
            sort_by_field: component.get('v.SortByField'),
            sort_order: component.get('v.SortOrder'),
            //MOSCATELLI_M 25/10/2018: NMA Business - START
            CaseDescription: component.get("v.Descrizione_Case")
            //MOSCATELLI_M 25/10/2018: NMA Business - END
        });
        action.setCallback(this, function(response){
            this.stopSpinner(component); 
            let state = response.getState();
            if(state === 'SUCCESS'){
                let sobject_wrapper = JSON.parse(response.getReturnValue());
                console.log('myobjects returned'+JSON.stringify(JSON.parse(response.getReturnValue()), null, 4));
                console.log('sobject_wrapper.error_message: '+sobject_wrapper.error_message);
                if(sobject_wrapper.error_message){
                    this.handleErrorMessage(component, sobject_wrapper.error_message);
                } else {
                    console.log('sobject_wrapper.sobjects.length: '+sobject_wrapper.sobjects.length);
                    let preserve_selected_records = component.get('v.PreserveSelectedRecords');
                    component.set('v.AllRecords', sobject_wrapper.sobjects);
                    component.set('v.TotalRecordsLoaded', sobject_wrapper.sobjects.length);
                    console.log('TotalRecordsLoaded: '+component.get('v.TotalRecordsLoaded'));
                    if(!preserve_selected_records && criteria_have_changed){
                        component.set('v.SelectedRecordsMap', new Map());
                        component.set('v.AllRecordsSelected', false);
                        this.updateSelectedRecords(component);
                    }
                    component.set('v.PageNumber', 1);
                    this.updateTableRows(component);
                }
            } else if(state === 'ERROR'){
                this.handleErrorMessage(component, response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    updateTableRows : function(component) {
        this.updatePagination(component);
        let all_records = component.get('v.AllRecords');
        let table_rows = [];
        if(all_records.length){
            let first_record_on_page = component.get('v.FirstRecordOnPage');
            let last_record_on_page = component.get('v.LastRecordOnPage');
            let table_columns = component.get('v.TableColumns');
            let selected_records_map = component.get('v.SelectedRecordsMap');
            for(let i = first_record_on_page-1; i < last_record_on_page; i++){
                let row = [];
                for(let j = 0; j < table_columns.length; j++){
                    if(table_columns[j].is_selection_column){
                        row.push({
                            is_selection_column: true,
                            is_checked: selected_records_map.has(all_records[i].Id)
                        });
                    } else {
                        let fields = table_columns[j].field_api_name.split('.');
                        //console.log('fields'+fields);
                        let value;
                        let reference;
                        if(fields.length > 1){
                            let record = all_records[i];
                            for(let k = 0; k < fields.length-1; k++){
                                record = record[fields[k]];
                            }
                            if(typeof(record) !== 'undefined'){
                                value = record[fields[fields.length-1]];
                                reference = record.Id;
                            }
                        } else {
                            value = all_records[i][table_columns[j].field_api_name]; //here
                            //console.log('value'+value);
                            //console.log('field_label'+ all_records[i][table_columns[j].field_label]);
                            reference = all_records[i].Id;
                        }
                        if(table_columns[j].field_type === 'PERCENT'){
                            value = (value != null) ? (value * 100) : 0
                        }
                        if(table_columns[j].field_override_type != undefined && table_columns[j].field_override_type != table_columns[j].field_type){
                            switch(table_columns[j].field_override_type){
                                case 'BOOLEAN':{
                                    if(table_columns[j].field_type === 'CURRENCY'
                                       || table_columns[j].field_type === 'DOUBLE'
                                       || table_columns[j].field_type === 'INTEGER'
                                       || table_columns[j].field_type === 'PERCENT'){
                                        value = (value != undefined && value != 0);
                                    } else {
                                        value = (value != undefined);
                                    }
                                    break;
                                }
                                case 'CURRENCY':{
                                    if(table_columns[j].field_type !== 'DOUBLE' && table_columns[j].field_type !== 'INTEGER'){
                                        value = undefined;
                                    }
                                    break;
                                }
                                case 'DATE':{
                                    if(table_columns[j].field_type !== 'DATETIME'){
                                        value = undefined;
                                    }
                                    break;
                                }
                                case 'DATETIME':{
                                    if(table_columns[j].field_type !== 'DATE'){
                                        value = undefined;
                                    }
                                    break;
                                }
                                case 'DOUBLE':{
                                    if(table_columns[j].field_type === 'BOOLEAN'){
                                        value = value ? 1.0 : 0.0;
                                    } else if(table_columns[j].field_type !== 'CURRENCY' && table_columns[j].field_type !== 'INTEGER' && table_columns[j].field_type !== 'PERCENT'){
                                        value = undefined;
                                    }
                                    break;
                                }
                                case 'INTEGER':{
                                    if(table_columns[j].field_type === 'BOOLEAN'){
                                        value = value ? 1 : 0;
                                    } else if((table_columns[j].field_type === 'CURRENCY' || table_columns[j].field_type === 'DOUBLE' || table_columns[j].field_type === 'PERCENT') && value != undefined){
                                        value = parseInt(value);
                                    } else {
                                        value = undefined;
                                    }
                                    break;
                                }
                                case 'PERCENT':{
                                    if(table_columns[j].field_type === 'DOUBLE' || table_columns[j].field_type === 'INTEGER'){
                                        if(value == undefined){
                                            value = 0;
                                        }
                                    } else {
                                        value = undefined;
                                    }
                                    break;
                                }
                                case 'STRING':{
                                    if(value != undefined){
                                        value = value.toString();
                                    }
                                    break;
                                }
                            }
                        }
                        row.push({
                            is_selection_column: false,
                            field_type: table_columns[j].field_override_type ? table_columns[j].field_override_type : table_columns[j].field_type,
                            reference: table_columns[j].field_is_reference ? reference : null,
                            value: value,
                            field_label: table_columns[j].field_label
                        });
                    }
                }
                table_rows.push(row);
            }
        }
        component.set('v.TableRows', table_rows);
    },
    
    updatePagination : function(component) {
        let page_number = component.get('v.PageNumber');
        let page_size = component.get('v.PageSize');
        let total_records = component.get('v.TotalRecordsLoaded');
        
        let pages_total = Math.ceil(total_records / page_size);
        
        let first_record_on_page = (total_records > 0) ? (((page_number - 1) * page_size) + 1) : 0;
        let last_record_on_page;
        if((page_number * page_size) > total_records){
            last_record_on_page = total_records;
        } else {
            last_record_on_page = (page_number * page_size);
        }
        
        let has_previous = page_number > 1;
        let has_next = page_number < pages_total;
        
        component.set('v.PageTotal', pages_total);
        component.set('v.FirstRecordOnPage', first_record_on_page);
        component.set('v.LastRecordOnPage', last_record_on_page);
        component.set('v.HasPrevious', has_previous);
        component.set('v.HasNext', has_next);
        
        var isMobile = component.get('v.isMobile');
        if(!isMobile){
            component.find('firstButton').set('v.disabled', (!has_previous));
            component.find('lastButton').set('v.disabled', (!has_next));
        }
        component.find('previousButton').set('v.disabled', (!has_previous));
        component.find('nextButton').set('v.disabled', (!has_next));
    },
    
    switchRow : function(component, index, is_checked){
        let all_records = component.get('v.AllRecords');
        let first_record_on_page = component.get('v.FirstRecordOnPage');
        let selected_records_map = component.get('v.SelectedRecordsMap');
        let index_on_page = (first_record_on_page + index - 1);
        if(index_on_page <= all_records.length){
            all_records[index_on_page].is_checked = is_checked;
            if(is_checked){
                selected_records_map.set(all_records[index_on_page].Id, all_records[index_on_page]);
            } else {
                selected_records_map.delete(all_records[index_on_page].Id);
                component.set('v.AllRecordsSelected', false);
            }
        }
        this.updateSelectedRecords(component);
    },
    
    switchAllRows : function(component, is_checked){
        let all_records = component.get('v.AllRecords');
        let selected_records_map = component.get('v.SelectedRecordsMap');
        if(is_checked){
            for(let i = 0; i < all_records.length; i++){
                all_records[i].is_checked = true;
                selected_records_map.set(all_records[i].Id, all_records[i]);
            }
        } else {
            for(let i = 0; i < all_records.length; i++){
                all_records[i].is_checked = false;
                selected_records_map.delete(all_records[i].Id);
            }
        }
        component.set('v.AllRecordsSelected', is_checked);
        this.updateTableRows(component);
        this.updateSelectedRecords(component);
    },
    
    updateSelectedRecords : function(component){
        let selected_records_map = component.get('v.SelectedRecordsMap');
        component.set('v.SelectedRecords', Array.from(selected_records_map.values()));
    },
    
    handleErrorMessage : function(component, message){
        let action = $A.get('e.force:showToast');
        action.setParams({
            title: 'DynamicTable Component Error',
            message: message,
            type: 'error'
        });
        action.fire();
        component.set('v.ErrorMessage', message);
    },
    
    fillstatus: function(component, event, helper) {
        var actStatus = component.get("c.getgCaseStatusPicklist");
        //MOSCATELLI_M 25/10/2018: NMA Business -- START
        actStatus.setParams({
            showClosed: component.get("v.ViewClosedCase")
        });
        //MOSCATELLI_M 25/10/2018: NMA Business -- END
        
        var inputsel = component.find("inputStatus");
        var opts=[];
        actStatus.setCallback(this, function(a) {
            opts.push({"class": "optionClass", label:"-- Stato --", value: null});
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});                
            } 
            
            inputsel.set("v.options", opts);
            
            //MOSCATELLI_M 25/10/2018: NMA Business -- START
            if(component.get("v.Stato"))
                component.find("inputStatus").set("v.value",component.get("v.Stato"));
            //MOSCATELLI_M 25/10/2018: NMA Business -- END
            
        });
        $A.enqueueAction(actStatus);
    },
    
    filllob: function(component, event, helper) {
        
        var inputsel = component.find("inputLOB");
        var opts=[];
        
        opts.push({"class": "optionClass", label: "-- Area --", value: null , selected: true});
        
        //MOSCATELLI_M 25/10/2018: NMA Business -- START
        /* opts.push({"class": "optionClass", label: "IT", value: "IT" });

        inputsel.set("v.options", opts);*/
        var actLOB = component.get("c.getgCaseLOBPicklist");
        
        actLOB.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});                
            } 
            
            inputsel.set("v.options", opts);
            
        });
        $A.enqueueAction(actLOB);
        //MOSCATELLI_M 25/10/2018: NMA Business -- START
    },
    
    fillcategory: function(component, event, helper) {
        
        var selectedLob = component.find("inputLOB").get("v.value");
        if (selectedLob!="" && selectedLob!=null)
        {
            var actcat = component.get("c.getgCaseCategoryPicklist");
            
            var inputsel = component.find("inputcategory");
            var opts=[];
            
            actcat.setParams({
                LOB: selectedLob
            });
            actcat.setCallback(this, function(a) {
                opts.push({"class": "optionClass", label:"-- Categoria --", value: null});
                for(var i=0;i< a.getReturnValue().length;i++){
                    opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
                    
                } 
                
                inputsel.set("v.options", opts);
                
            });
            $A.enqueueAction(actcat);
        }
        else
        {
            var inputsel = component.find("inputcategory");
            var opts=[];
            opts.push({"class": "optionClass", label: "-- Categoria --", value: null , selected: true});
            inputsel.set("v.options", opts);
        } 
        
        /* var actcategory = component.get("c.getgCaseCategoryPicklist");
        
        var inputsel = component.find("inputcategory");
        var opts=[];
       actcategory.setCallback(this, function(a) {
           opts.push({"class": "optionClass", label:"-- Categoria --", value: null});
           for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
                
           } 
             
            inputsel.set("v.options", opts);
            
        });
          $A.enqueueAction(actcategory);*/
    },
    
    retrievePageVal: function(component,event,helper){
        var retrPVal = component.get("c.getPageValues");
        var arrayOfMapKeys = [];
        
        retrPVal.setCallback(this, function(a) {
            
            var ObtainedMap = a.getReturnValue();
            
            
            for (var singlekey in ObtainedMap) 
            {
                arrayOfMapKeys.push(singlekey);
            }            
            //console.log('keys: '+arrayOfMapKeys);
            for(var i=0;i<arrayOfMapKeys.length;i++)
            {
                var key = arrayOfMapKeys[i];
                
                if(key.split("|")[0] == "isStandardUser")
                {
                    //console.log('Dentro isStandardUser'+ObtainedMap[key]);
                    
                    if(ObtainedMap[key]=="true")
                        component.set("v.StdUsr",true);
                    else
                        component.set("v.StdUsr",false);
                }
                else if(key.split("|")[0] == "UserAgency")
                {
                    //console.log('Dentro UserAgency');
                    
                    component.set("v.CodiceAgenzia",ObtainedMap[key]);
                }
                    else if(key.split("|")[0] == "UserRole")
                    {  
                        //console.log('Dentro UserRole: '+ObtainedMap[key]);
                        component.set("v.UserRole",ObtainedMap[key]);
                    } 
                        else if(key.split("|")[0] == "UserProfile")
                        {
                            //console.log('Dentro UserProfile: '+ObtainedMap[key]);
                            
                            component.set("v.UserProfile",ObtainedMap[key]);
                        }
                            else if(key.split("|")[0] == "UserId")
                            {
                                //console.log('Dentro UserId: '+ObtainedMap[key]);
                                
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
                                    //console.log('Dentro UserName: '+ObtainedMap[key]);
                                    
                                    component.set("v.UserName",ObtainedMap[key]);
                                }
                
                //console.log('test: '+component.get("v.UserRole"));
                
            }
            
            
            
        });
        $A.enqueueAction(retrPVal);  
        
        
    },
    
    InitializeCollFilter: function(component, event, helper) {
        var actPwoc = component.get("c.getCollaboratori");
        var inputList_collaboratori = component.find("inputList_collaboratori");
        var opts_List_collaboratori=[];
        //console.log('getCollaboratori!!!');
        
        //console.log('CodiceAgenzia'+component.get('v.CodiceAgenzia'));
        
        
        actPwoc.setParams({
            
            "CodiceAgenzia":component.get('v.CodiceAgenzia')
            
            
        });
        
        actPwoc.setCallback(this, function(a) {
            
            //var UserRole = component.get('v.UserRole');
            //if(!UserRole.includes('Utente Partner')){
            opts_List_collaboratori.push({"class": "optionClass",  value: "", label:"-- Agenzia --"});
            //var IsPartnerUser = component.get("v.IsPartnerUser");
            //}
            
            
            //console.log('coll:'+ JSON.stringify(a.getReturnValue(), null, 4)); 
            
            for(var i=0;i< a.getReturnValue().length;i++){
                opts_List_collaboratori.push({"class": "optionClass", label: a.getReturnValue()[i].User__r.Name, value: a.getReturnValue()[i].User__r.Id});
                //console.log('dentro for'+a.getReturnValue()[i].User__r.Name+a.getReturnValue()[i].User__r.Id);
            } 
            //inputList_collaboratori.set("v.options", opts_List_collaboratori);
            component.set("v.CollList",opts_List_collaboratori);
            
            
        });
        $A.enqueueAction(actPwoc);
        
    },
    
    goSetCollaboratore: function (component){
        
        var selected = component.find("inputList_collaboratori").get("v.value");
        var oldselected = component.get("v.CollaboratoreId");
        if(selected.includes('\''));
        selected = selected.replace('\'','\\'+'\'');
        //console.log('selected: '+selected);
        //console.log('oldselected'+oldselected);
        component.set("v.CollaboratoreId", selected);
        var PrivateMatchCriteria = component.get("v.PrivateMatchCriteria");
        if(selected!=null && selected!=undefined && selected != ''){        
            
            //console.log('PrivateMatchCriteria'+PrivateMatchCriteria);
            if(PrivateMatchCriteria != '' && PrivateMatchCriteria != null && PrivateMatchCriteria != undefined){
                if(PrivateMatchCriteria.includes('User__r.Id')){
                    //console.log('before'+'User__r.Id ='+'\''+oldselected.trim()+'\'');
                    //console.log('after'+'User__r.Id ='+'\''+selected.trim()+'\'');
                    var newPMC = PrivateMatchCriteria.replace(oldselected.trim(),selected.trim());
                    //console.log("PrivateMatchCriteria after replace"+ newPMC);
                    component.set("v.PrivateMatchCriteria",newPMC);
                }else{
                    PrivateMatchCriteria = PrivateMatchCriteria + ' and User__r.Id ='+'\''+selected.trim()+'\'';
                    component.set("v.PrivateMatchCriteria",PrivateMatchCriteria);
                }
            }
            else{
                //console.log('devo passare da qui');
                PrivateMatchCriteria = 'User__r.Id ='+'\''+selected.trim()+'\''; 
                component.set("v.PrivateMatchCriteria",PrivateMatchCriteria);  
            }
            
        }else{
            //console.log('confronto'+'User__r.Id ='+'\''+oldselected.trim()+'\' and');
            //console.log('PrivateMatchCriteria'+PrivateMatchCriteria);
            if(PrivateMatchCriteria != '' && PrivateMatchCriteria != null){
                if(PrivateMatchCriteria.includes('and User__r.Id')){
                    var newPMC2 = PrivateMatchCriteria.replace('and User__r.Id ='+'\''+oldselected.trim()+'\'','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    //console.log('newPMC2'+newPMC2);
                }else if(PrivateMatchCriteria.includes('User__r.Id ='+'\''+oldselected.trim()+'\' and')){
                    //console.log('here');
                    var newPMC2 = PrivateMatchCriteria.replace('User__r.Id ='+'\''+oldselected.trim()+'\' and','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    //console.log('newPMC2'+newPMC2);
                    
                    
                }else if(PrivateMatchCriteria.includes('User__r.Id')){
                    
                    var newPMC2 = PrivateMatchCriteria.replace ('User__r.Id ='+'\''+oldselected.trim()+'\'','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    //console.log('newPMC2'+newPMC2);
                    
                    
                }
                
            }
            
        }
    },
    
    goSetStato : function(component){
        var selected = component.find("inputStatus").get("v.value");
        var oldselected = component.get("v.Stato");
        if(selected.includes('\''));
        selected = selected.replace('\'','\\'+'\'');
        //console.log('selected: '+selected);
        //console.log('oldselected'+oldselected);
        component.set("v.Stato", selected);
        var PrivateMatchCriteria = component.get("v.PrivateMatchCriteria");
        if(selected!=null && selected!=undefined && selected != ''){        
            
            //console.log('PrivateMatchCriteria'+PrivateMatchCriteria);
            if(PrivateMatchCriteria != '' && PrivateMatchCriteria != null && PrivateMatchCriteria != undefined){
                if(PrivateMatchCriteria.includes('Status =')){
                    //console.log('before'+'Status ='+'\''+oldselected.trim()+'\'');
                    //console.log('after'+'Status ='+'\''+selected.trim()+'\'');
                    var newPMC = PrivateMatchCriteria.replace(oldselected.trim(),selected.trim());
                    //console.log("PrivateMatchCriteria after replace"+ newPMC);
                    component.set("v.PrivateMatchCriteria",newPMC);
                }else{
                    PrivateMatchCriteria = PrivateMatchCriteria + ' and Status ='+'\''+selected.trim()+'\'';
                    component.set("v.PrivateMatchCriteria",PrivateMatchCriteria);
                    //console.log('MY PRIVATE MATCH'+PrivateMatchCriteria);
                }
            }
            else{
                //console.log('devo passare da qui');
                PrivateMatchCriteria = 'Status ='+'\''+selected.trim()+'\''; 
                component.set("v.PrivateMatchCriteria",PrivateMatchCriteria);  
            }
            
        }else{
            if(PrivateMatchCriteria != '' && PrivateMatchCriteria != null){
                //console.log('sono qui');
                if(PrivateMatchCriteria.includes('and Status =')){
                    var newPMC2 = PrivateMatchCriteria.replace('and Status ='+'\''+oldselected.trim()+'\'','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    console.log('newPMC2 - '+newPMC2);
                }else if(PrivateMatchCriteria.includes('Status ='+'\''+oldselected.trim()+'\' and')){
                    console.log('here');
                    var newPMC2 = PrivateMatchCriteria.replace('Status ='+'\''+oldselected.trim()+'\' and','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    console.log('newPMC2 + '+newPMC2);
                    
                    
                }else if(PrivateMatchCriteria.includes('Status =')){
                    
                    var newPMC2 = PrivateMatchCriteria.replace('Status ='+'\''+oldselected.trim()+'\'','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    console.log('newPMC2 : '+newPMC2);
                    
                    
                }
                
            }
            
        }
    },
    
    goSetLOB:function(component){
        var selected = component.find("inputLOB").get("v.value");
        var oldselected = component.get("v.LOB");
        if(selected.includes('\''));
        selected = selected.replace('\'','\\'+'\'');
        //console.log('selected: '+selected);
        //console.log('oldselected'+oldselected);
        component.set("v.LOB", selected);
        var PrivateMatchCriteria = component.get("v.PrivateMatchCriteria");
        if(selected!=null && selected!=undefined && selected != ''){        
            component.set("v.isDependentDisable",false);
            //console.log('PrivateMatchCriteria'+PrivateMatchCriteria);
            if(PrivateMatchCriteria != '' && PrivateMatchCriteria != null && PrivateMatchCriteria != undefined){
                if(PrivateMatchCriteria.includes('LOB__c')){
                    //console.log('before'+'LOB__c ='+'\''+oldselected.trim()+'\'');
                    //console.log('after'+'LOB__c ='+'\''+selected.trim()+'\'');
                    var newPMC = PrivateMatchCriteria.replace(oldselected.trim(),selected.trim());
                    //console.log("PrivateMatchCriteria after replace"+ newPMC);
                    component.set("v.PrivateMatchCriteria",newPMC);
                }else{
                    PrivateMatchCriteria = PrivateMatchCriteria + ' and LOB__c ='+'\''+selected.trim()+'\'';
                    component.set("v.PrivateMatchCriteria",PrivateMatchCriteria);
                }
            }
            else{
                //console.log('devo passare da qui');
                PrivateMatchCriteria = 'LOB__c ='+'\''+selected.trim()+'\''; 
                component.set("v.PrivateMatchCriteria",PrivateMatchCriteria);  
            }
            
        }else{
            component.set("v.isDependentDisable",true);
            if(PrivateMatchCriteria != '' && PrivateMatchCriteria != null){
                //console.log('sono qui');
                if(PrivateMatchCriteria.includes('and LOB__c')){
                    var newPMC2 = PrivateMatchCriteria.replace('and LOB__c ='+'\''+oldselected.trim()+'\'','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    //console.log('newPMC2'+newPMC2);
                }else if(PrivateMatchCriteria.includes('LOB__c ='+'\''+oldselected.trim()+'\' and')){
                    //console.log('here');
                    var newPMC2 = PrivateMatchCriteria.replace('LOB__c ='+'\''+oldselected.trim()+'\' and','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    //console.log('newPMC2'+newPMC2);
                    
                    
                }else if(PrivateMatchCriteria.includes('LOB__c')){
                    
                    var newPMC2 = PrivateMatchCriteria.replace('LOB__c ='+'\''+oldselected.trim()+'\'','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    //console.log('newPMC2'+newPMC2);
                    
                    
                }
                
            }
            
        }
        this.fillcategory(component);
    },
    
    goSetCategory:function(component){
        var selected = component.find("inputcategory").get("v.value");
        var oldselected = component.get("v.Categoria");
        if(selected.includes('\''));
        selected = selected.replace('\'','\\'+'\'');
        //console.log('selected: '+selected);
        //console.log('oldselected'+oldselected);
        component.set("v.Categoria", selected);
        var PrivateMatchCriteria = component.get("v.PrivateMatchCriteria");
        if(selected!=null && selected!=undefined && selected != ''){        
            
            //console.log('PrivateMatchCriteria'+PrivateMatchCriteria);
            if(PrivateMatchCriteria != '' && PrivateMatchCriteria != null && PrivateMatchCriteria != undefined){
                if(PrivateMatchCriteria.includes('Category__c')){
                    //console.log('before'+'Category__c ='+'\''+oldselected.trim()+'\'');
                    //console.log('after'+'Category__c ='+'\''+selected.trim()+'\'');
                    var newPMC = PrivateMatchCriteria.replace(oldselected.trim(),selected.trim());
                    //console.log("PrivateMatchCriteria after replace"+ newPMC);
                    component.set("v.PrivateMatchCriteria",newPMC);
                }else{
                    PrivateMatchCriteria = PrivateMatchCriteria + ' and Category__c ='+'\''+selected.trim()+'\'';
                    component.set("v.PrivateMatchCriteria",PrivateMatchCriteria);
                }
            }
            else{
                //console.log('devo passare da qui');
                PrivateMatchCriteria = 'Category__c ='+'\''+selected.trim()+'\''; 
                component.set("v.PrivateMatchCriteria",PrivateMatchCriteria);  
            }
            
        }else{
            if(PrivateMatchCriteria != '' && PrivateMatchCriteria != null){
                //console.log('sono qui');
                if(PrivateMatchCriteria.includes('and Category__c')){
                    var newPMC2 = PrivateMatchCriteria.replace('and Category__c ='+'\''+oldselected.trim()+'\'','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    //console.log('newPMC2'+newPMC2);
                }else if(PrivateMatchCriteria.includes('Category__c ='+'\''+oldselected.trim()+'\' and')){
                    //console.log('here');
                    var newPMC2 = PrivateMatchCriteria.replace('Category__c ='+'\''+oldselected.trim()+'\' and','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    //console.log('newPMC2'+newPMC2);
                    
                    
                }else if(PrivateMatchCriteria.includes('Category__c')){
                    
                    var newPMC2 = PrivateMatchCriteria.replace('Category__c ='+'\''+oldselected.trim()+'\'','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    //console.log('newPMC2'+newPMC2);
                    
                }
                
            }
            
        }
    },
    
    goSetObject:function(component){
        var selected = component.find("inputText_Oggetto").get("v.value");
        var oldselected = component.get("v.Oggetto");
        if(selected.includes('\''));
        selected = selected.replace('\'','\\'+'\'');
        //console.log('selected: '+selected);
        //console.log('oldselected'+oldselected);
        component.set("v.Oggetto", selected);
        var PrivateMatchCriteria = component.get("v.PrivateMatchCriteria");
        if(selected!=null && selected!=undefined && selected != ''){        
            
            //console.log('PrivateMatchCriteria'+PrivateMatchCriteria);
            if(PrivateMatchCriteria != '' && PrivateMatchCriteria != null && PrivateMatchCriteria != undefined){
                if(PrivateMatchCriteria.includes('Oggetto_Apertura_Case__c')){
                    console.log('before'+'Oggetto_Apertura_Case__c ='+'\''+oldselected.trim()+'\'');
                    console.log('after'+'Oggetto_Apertura_Case__c ='+'\''+selected.trim()+'\'');
                    var newPMC = PrivateMatchCriteria.replace('Oggetto_Apertura_Case__c LIKE \'%' + oldselected + '%\'', 'Oggetto_Apertura_Case__c LIKE \'%' + selected + '%\'');
                    //console.log("PrivateMatchCriteria after replace"+ newPMC);
                    component.set("v.PrivateMatchCriteria",newPMC);
                }else{
                    //PrivateMatchCriteria = PrivateMatchCriteria + ' and Oggetto_Apertura_Case__c ='+'\''+''+selected.trim()+'\'';
                    PrivateMatchCriteria = PrivateMatchCriteria + ' and Oggetto_Apertura_Case__c LIKE \'%' + selected + '%\'';
                    component.set("v.PrivateMatchCriteria",PrivateMatchCriteria);
                }
            }
            else{
                //console.log('devo passare da qui');
                //console.log('this is the string'+selected.trim());
                //PrivateMatchCriteria = 'Oggetto_Apertura_Case__c ='+'\''+''+selected.trim()+'\''; 
                PrivateMatchCriteria = 'Oggetto_Apertura_Case__c LIKE \'%' + selected + '%\''; 
                component.set("v.PrivateMatchCriteria",PrivateMatchCriteria);  
            }
            
        }else{
            if(PrivateMatchCriteria != '' && PrivateMatchCriteria != null){
                //console.log('sono qui');
                if(PrivateMatchCriteria.includes('and Oggetto_Apertura_Case__c')){
                    //var newPMC2 = PrivateMatchCriteria.replace('and Oggetto_Apertura_Case__c ='+'\''+''+oldselected.trim()+'\'','');
                    var newPMC2 = PrivateMatchCriteria.replace('and Oggetto_Apertura_Case__c LIKE \'%' + oldselected + '%\'','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    //console.log('newPMC2'+newPMC2);
                }else if(PrivateMatchCriteria.includes('Oggetto_Apertura_Case__c LIKE \'%' + oldselected + '%\' and')){
                    //console.log('here');
                    var newPMC2 = PrivateMatchCriteria.replace('Oggetto_Apertura_Case__c LIKE \'%' + oldselected + '%\' and','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    //console.log('newPMC2'+newPMC2);
                    
                    
                }else if(PrivateMatchCriteria.includes('Oggetto_Apertura_Case__c')){
                    
                    var newPMC2 = PrivateMatchCriteria.replace('Oggetto_Apertura_Case__c LIKE \'%' + oldselected + '%\'','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    //console.log('newPMC2'+newPMC2);
                    
                }
                
            }
        }
    },
    
    goSetTarga:function(component){
        var selected = component.find("inputText_Targa").get("v.value");
        var oldselected = component.get("v.Targa");
        if(selected.includes('\''));
        selected = selected.replace('\'','\\'+'\'');
        //console.log('selected: '+selected);
        //console.log('oldselected'+oldselected);
        component.set("v.Targa", selected);
        var PrivateMatchCriteria = component.get("v.PrivateMatchCriteria");
        if(selected!=null && selected!=undefined && selected != ''){        
            
            //console.log('PrivateMatchCriteria'+PrivateMatchCriteria);
            if(PrivateMatchCriteria != '' && PrivateMatchCriteria != null && PrivateMatchCriteria != undefined){
                if(PrivateMatchCriteria.includes('Targa__c')){
                    console.log('before'+'Targa__c ='+'\''+oldselected.trim()+'\'');
                    console.log('after'+'Targa__c ='+'\''+selected.trim()+'\'');
                    var newPMC = PrivateMatchCriteria.replace('Targa__c LIKE \'%' + oldselected + '%\'', 'Targa__c LIKE \'%' + selected + '%\'');
                    //console.log("PrivateMatchCriteria after replace"+ newPMC);
                    component.set("v.PrivateMatchCriteria",newPMC);
                }else{
                    //PrivateMatchCriteria = PrivateMatchCriteria + ' and Targa__c ='+'\''+''+selected.trim()+'\'';
                    PrivateMatchCriteria = PrivateMatchCriteria + ' and Targa__c LIKE \'%' + selected + '%\'';
                    component.set("v.PrivateMatchCriteria",PrivateMatchCriteria);
                }
            }
            else{
                //console.log('devo passare da qui');
                //console.log('this is the string'+selected.trim());
                //PrivateMatchCriteria = 'Targa__c ='+'\''+''+selected.trim()+'\''; 
                PrivateMatchCriteria = 'Targa__c LIKE \'%' + selected + '%\''; 
                component.set("v.PrivateMatchCriteria",PrivateMatchCriteria);  
            }
            
        }else{
            if(PrivateMatchCriteria != '' && PrivateMatchCriteria != null){
                //console.log('sono qui');
                if(PrivateMatchCriteria.includes('and Targa__c')){
                    //var newPMC2 = PrivateMatchCriteria.replace('and Targa__c ='+'\''+''+oldselected.trim()+'\'','');
                    var newPMC2 = PrivateMatchCriteria.replace('and Targa__c LIKE \'%' + oldselected + '%\'','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    //console.log('newPMC2'+newPMC2);
                }else if(PrivateMatchCriteria.includes('Targa__c LIKE \'%' + oldselected + '%\' and')){
                    //console.log('here');
                    var newPMC2 = PrivateMatchCriteria.replace('Targa__c LIKE \'%' + oldselected + '%\' and','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    //console.log('newPMC2'+newPMC2);
                    
                    
                }else if(PrivateMatchCriteria.includes('Targa__c')){
                    
                    var newPMC2 = PrivateMatchCriteria.replace('Targa__c LIKE \'%' + oldselected + '%\'','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                    //console.log('newPMC2'+newPMC2);
                    
                }
                
            }
        }
    },
    
    startSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide slds-is-relative');
    },          
    stopSpinner: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, 'slds-hide');
    }, 
    //MOSCATELLI_M 25/10/2018: NMA Business - START
    goSetCaseNumber:function(component){
        var selected = component.find("inputText_NumeroCase").get("v.value");
        var oldselected = component.get("v.Targa");
        if(selected.includes('\''));
        selected = selected.replace('\'','\\'+'\'');
        component.set("v.Numero_Case", selected);
        var PrivateMatchCriteria = component.get("v.PrivateMatchCriteria");
        if(selected!=null && selected!=undefined && selected != '')
        {        
            if(PrivateMatchCriteria != '' && PrivateMatchCriteria != null && PrivateMatchCriteria != undefined){
                if(PrivateMatchCriteria.includes('CaseNumber')){
                    console.log('before'+'CaseNumber ='+'\''+oldselected.trim()+'\'');
                    console.log('after'+'CaseNumber ='+'\''+selected.trim()+'\'');
                    var newPMC = PrivateMatchCriteria.replace('CaseNumber LIKE \'%' + oldselected + '%\'', 'CaseNumber LIKE \'%' + selected + '%\'');
                    console.log("PrivateMatchCriteria after replace CaseNumber"+ newPMC);
                    component.set("v.PrivateMatchCriteria",newPMC);
                }else{
                    PrivateMatchCriteria = PrivateMatchCriteria + ' and CaseNumber LIKE \'%' + selected + '%\'';
                    component.set("v.PrivateMatchCriteria",PrivateMatchCriteria);
                }
            }
            else{ 
                PrivateMatchCriteria = 'Targa__c LIKE \'%' + selected + '%\''; 
                component.set("v.PrivateMatchCriteria",PrivateMatchCriteria);  
            }
            
        }else{
            if(PrivateMatchCriteria != '' && PrivateMatchCriteria != null){
                if(PrivateMatchCriteria.includes('and CaseNumber')){
                    var newPMC2 = PrivateMatchCriteria.replace('and CaseNumber LIKE \'%' + oldselected + '%\'','');
                    component.set("v.PrivateMatchCriteria",newPMC2);
                }else if(PrivateMatchCriteria.includes('CaseNumber LIKE \'%' + oldselected + '%\' and')){
                    var newPMC2 = PrivateMatchCriteria.replace('CaseNumber LIKE \'%' + oldselected + '%\' and','');
                    component.set("v.PrivateMatchCriteria",newPMC2);                                      
                }else if(PrivateMatchCriteria.includes('CaseNumber')){                    
                    var newPMC2 = PrivateMatchCriteria.replace('CaseNumber LIKE \'%' + oldselected + '%\'','');
                    component.set("v.PrivateMatchCriteria",newPMC2);                    
                }
                
            }
        }
    },
    goSetCaseDescription:function(component){
        var selected = component.find("inputText_DescrizioneRichiesta").get("v.value");
        var oldselected = component.get("v.Descrizione_Case");
        if(selected.includes('\''));
        selected = selected.replace('\'','\\'+'\'');
        component.set("v.Descrizione_Case", selected);
    },
    
    goSetClosedStatusSearch:function(component){
        var selected = component.find("inputText_ClosedStatusSearch").get("v.value");
        console.log("@@goSetClosedStatusSearch: "+selected);
        var oldselected = component.get("v.ViewClosedCase");
        var currentStatus = component.get("v.Stato");
        
        if(selected!=null)
            component.set("v.ViewClosedCase", selected);
        
        console.log('Old criteria : '+component.get("v.PrivateMatchCriteria"));
        var PrivateMatchCriteria = component.get("v.PrivateMatchCriteria");
        var ClosedStatusesFilter = component.get('v.ClosedStatusesFilter');
        
        if(!ClosedStatusesFilter)
        {
            console.log('@@ClosedStatusesFilter definition');
            var action = component.get("c.FilterClosedCases");
            action.setCallback(this, function(response){
                let state = response.getState();
                if(state === 'SUCCESS'){
                    console.log('Stat filter: '+response.getReturnValue());
                    component.set("v.ClosedStatusesFilter", response.getReturnValue());
                    component.set("v.PrivateMatchCriteria",PrivateMatchCriteria + component.get('v.ClosedStatusesFilter'));
                } else if(state === 'ERROR'){
                    this.handleErrorMessage(component, response.getError());
                }
            });
            $A.enqueueAction(action);
        }
        console.log('@@ClosedStatusesFilter: '+component.get('v.ClosedStatusesFilter'));
        
        if((oldselected!=selected))
        {
            console.log('oldselected <> selected');
            
            if(!selected)
            {
                console.log('selected is false');
                
                if(component.get("v.Stato"))
                {
                    if(component.get('v.ClosedStatusesFilter').indexOf(currentStatus)!=-1)
                    {
                        component.find("inputStatus").set("v.value",null);
                        component.set("v.Stato","");
                        
                        if(PrivateMatchCriteria.includes('and Status =')){
                            var newPMC2 = PrivateMatchCriteria.replace('and Status ='+'\''+currentStatus.trim()+'\'','');
                            component.set("v.PrivateMatchCriteria",newPMC2);
                            console.log('newPMC2 - '+newPMC2);
                        }else if(PrivateMatchCriteria.includes('Status ='+'\''+currentStatus.trim()+'\' and')){
                            console.log('here');
                            var newPMC2 = PrivateMatchCriteria.replace('Status ='+'\''+currentStatus.trim()+'\' and','');
                            component.set("v.PrivateMatchCriteria",newPMC2);
                            console.log('newPMC2 + '+newPMC2);
                            
                            
                        }else if(PrivateMatchCriteria.includes('Status =')){                           
                            var newPMC2 = PrivateMatchCriteria.replace('Status ='+'\''+currentStatus.trim()+'\'','');
                            component.set("v.PrivateMatchCriteria",newPMC2);
                            console.log('newPMC2 : '+newPMC2);
                        }      
                        
                        component.set("v.PrivateMatchCriteria",component.get("v.PrivateMatchCriteria")+component.get('v.ClosedStatusesFilter'));
                    }
                }
                else
                {
                    if(PrivateMatchCriteria.indexOf(component.get('v.ClosedStatusesFilter'))==-1)
                        component.set("v.PrivateMatchCriteria",PrivateMatchCriteria + component.get('v.ClosedStatusesFilter'));
                }
            }  
            else
            {
                console.log('selected is true');
                
                if(PrivateMatchCriteria.indexOf(component.get('v.ClosedStatusesFilter'))!=-1)
                    component.set("v.PrivateMatchCriteria",PrivateMatchCriteria.replace(component.get('v.ClosedStatusesFilter'),''));                
            }            
        }
        else
        {
            if(!component.get("v.ViewClosedCase"))
            {
                if(PrivateMatchCriteria.indexOf(component.get('v.ClosedStatusesFilter'))==-1)
                    component.set("v.PrivateMatchCriteria",PrivateMatchCriteria + component.get('v.ClosedStatusesFilter'));
            }
            else
            {
                if(PrivateMatchCriteria.indexOf(component.get('v.ClosedStatusesFilter'))!=-1)
                    component.set("v.PrivateMatchCriteria",PrivateMatchCriteria.replace(component.get('v.ClosedStatusesFilter'),''));   
            }
        }
        console.log('New criteria : '+ component.get("v.PrivateMatchCriteria"));
        
        this.fillstatus(component);            
        this.retrieveRecords(component, true);
        this.retrieveTotalRecords(component);
    } 
    //MOSCATELLI_M 25/10/2018: NMA Business - END       
})
({
    
    initData: function (cmp,  event, numberOfRecords, conditions) {
        console.log(conditions);
        conditions = conditions + (cmp.get("v.ClosedToo") == true? "":" AND isClosed=false");
        cmp.set("v.conditions", conditions);
        console.log(conditions);
       cmp.set('v.isLoading', true);
         var action = cmp.get("c.initRecords");
         action.setParams({
             ObjectName : cmp.get("v.objectName"),
             fieldNamesStr : cmp.get("v.fieldsString"),
             Orderby : cmp.get("v.sortedBy"),
             OrderDir : cmp.get("v.sortedDirection"),
             whereCondition: conditions
         });
		 action.setCallback(this, function(response) {
            cmp.set('v.isLoading', false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var site = response.getReturnValue().CRMURL;
                console.log(window.location.href);
                console.log(site);
                if(window.location.href.includes(site)){
                    console.log("sono qui");
                    cmp.set("v.RenderGestioneCodaCase", false);
                    cmp.set("v.RedirectToObject", site);
                }
                

                else{
                    cmp.set("v.RedirectToObject", window.location.href);
                }
                
                console.log(response.getReturnValue().ldwList);
                
              //  cmp.set("v.columns", response.getReturnValue().ldwList);
                this.formatColumns(response.getReturnValue().ldwList,cmp);
             //   cmp.set("v.data", response.getReturnValue().sobList);
                this.formatData(response.getReturnValue().sobList,  cmp);
                cmp.set("v.fieldsList", response.getReturnValue().fieldsList);
                cmp.set('v.totalNumberOfRows', response.getReturnValue().totalCount);
                cmp.set('v.loadMoreStatus', '');
                event.getSource().set("v.isLoading", false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    getCondintions : function (cmp){
        var label =   cmp.get('v.LabelSelect');

        var Canale= cmp.get('v.AreaSelect');
        
        
        var objectFilters =   cmp.get('v.objectFilters');
        var ingressoFilters = cmp.get('v.ingressoFilters');

        var conditionsDefault = objectFilters.filter(function(element) {
            return element.Label === label;
        });

        console.log("conditions 1");

        var ingressoDefault = ingressoFilters.filter(function(element) {
            return element.Label === Canale;
        });

        console.log("conditions 2");
        
        var conditions = '';

        if (conditionsDefault[0].Conditions__c != '' && typeof  conditionsDefault[0].Conditions__c != 'undefined')
          conditions=conditionsDefault[0].Conditions__c;
        /*if(ingressoDefault != null && typeof  ingressoDefault != 'undefined' && typeof  ingressoDefault[0].Conditions__c != 'undefined' && ingressoDefault[0].Conditions__c != '')
            conditions+=' '+ingressoDefault[0].Conditions__c;*/
        if(ingressoDefault){
            if(ingressoDefault.length != 0){
                if(typeof  ingressoDefault[0].Conditions__c != 'undefined' && ingressoDefault[0].Conditions__c != ''){
                    conditions+=' '+ingressoDefault[0].Conditions__c;
                }
            }
        }
       
            console.log(conditions);
        cmp.set('v.conditions', conditions);
           
        return conditions;
   
    },
    doSearchHandler : function (cmp, event, helper){
      
        var label =   cmp.get('v.LabelSelect');

        if(label != ''){
      
            var conditions = this.getCondintions(cmp);           
            this.initData(cmp, event, cmp.get("v.data").length,conditions);
               
        }
        
    },

    retrieveFilter: function (cmp, event, helper){
    var action = cmp.get("c.getFilter");   

    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
        var filtersList = response.getReturnValue().TipologiaFilters;
        var ingressoList = response.getReturnValue().CanaleIngressoFilters;
        var listLabel = new Array();
        var listArea = new Array();
        var AreaSelect = '';
		var InitFilter = cmp.get("v.FilterParam");

        cmp.set("v.objectFilters",filtersList);
        cmp.set("v.ingressoFilters", ingressoList);
        filtersList.forEach(element => {
            listLabel.push(element.Label);  
            if(InitFilter != ""){
                if(element.DeveloperName === InitFilter){
                	cmp.set('v.LabelSelect', element.Label);
                    console.log(element);
                    if(typeof element.Ingresso_Default__c != 'undefined' && element.Ingresso_Default__c != ''){
                        AreaSelect = element.Ingresso_Default__c;
                        console.log("Ciaooo");
                    }
                        
                }
        	}
            else if(element.Default__c){            
                cmp.set('v.LabelSelect', element.Label);        
            }
        });

        console.log(AreaSelect);

        ingressoList.forEach(element => {
            listArea.push(element.Label);
            if(AreaSelect != ''){
                if(element.DeveloperName === AreaSelect){
                    
                    cmp.set("v.AreaSelect", element.Label);
                }
            }
            else{
                if(element.Default__c)
                    cmp.set("v.AreaSelect", element.Label);
            }
        });
    
        cmp.set('v.AreaFilters',listArea);
        cmp.set('v.LabelFilters',listLabel);
        this.doSearchHandler(cmp,event, helper);
 
        }
        else if (state === "ERROR") {
            var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    console.log("Error message: " + 
                             errors[0].message);
                }
            } else {
                console.log("Unknown error");
            }
        }
    });
    $A.enqueueAction(action);
    },      
    

    fetchData: function (cmp,  event, numberOfRecords) {
       
         var conditions = cmp.get('v.conditions');
         var data = cmp.get("v.data");
         var dataSize = cmp.get("v.data").length;
         var lastId = data[dataSize - 1].Id;
        console.log('--lastId----'+lastId);
         var action = cmp.get("c.getsObjectRecords");
         action.setParams({
         	ObjectName : cmp.get("v.objectName"),
            fieldNameSet : cmp.get("v.fieldsList"),
            LimitSize : 50,
            recId : lastId,
            Orderby : cmp.get("v.sortedBy"),
            OrderDir : cmp.set("v.sortedDirection"),
            whereCondition: conditions

         });
		 action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // console.log('*data leght' + cmp.get('v.data').length);
                // console.log('*tot row'+cmp.get('v.totalNumberOfRows'));
                if (cmp.get('v.data').length >= cmp.get('v.totalNumberOfRows')) {
                    cmp.set('v.enableInfiniteLoading', false);
                    cmp.set('v.loadMoreStatus', '');
                } else {
                    var currentData = cmp.get('v.data');
                    var newData = currentData.concat(response.getReturnValue());
                    this.formatData(newData, cmp);
                
                    cmp.set('v.loadMoreStatus', '');
                }
                event.getSource().set("v.isLoading", false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    
    formatData: function (data, component) {
      
          var records =data;
            
          records.forEach(function(record){
              var Redirect = component.get("v.RedirectToObject");
            record.linkName = Redirect.split('apex')[0] +record.Id;

            if (record.Account) record.AccountName = record.Account.Name;
            if (record.Owner) record.OwnerName = record.Owner.Name;
  
        });
        component.set("v.data", records);

    },

    formatColumns: function (data, component) {
        var records = data;
            
        records.forEach(function(record){     
            
            if(record.type=='datetime'){          
            record.type='date';            
            record.typeAttributes= {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: false
              };
        }
       
        if(record.fieldName=='CaseNumber'){          
            record.type='url';
            record.fieldName= 'linkName', 
            record.typeAttributes= {label: { fieldName: 'CaseNumber' },value:{fieldName: 'linkName'}, target: '_blank'};
        }

        });

     

        records = records.filter(function (e) {
            return e.type !='id' && e.type !='reference' ;
        });

        component.set("v.columns", records);

    }
    


  });
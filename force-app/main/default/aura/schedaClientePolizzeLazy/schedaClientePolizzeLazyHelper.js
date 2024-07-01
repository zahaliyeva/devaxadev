({
    onGetRecords : function(component) {
        var action = component.get("c.getRecords");
        let accountId = component.get('v.accountId');
        let asaJson = component.get("v.asaJson");
        let schedaClientePolizzaType = component.get("v.schedaClientePolizzaType");
        action.setParams({
            "id" : accountId,
            "asaJson": asaJson,
            "limits": component.get("v.limits"),
            "schedaClientePolizzaType" : schedaClientePolizzaType
        });
        action.setCallback(this, function(response) {     
           var state = response.getState();
            if (state === "SUCCESS" ) {
                component.set("v.data",response.getReturnValue());
                component.set("v.limits", component.get("v.limits") + 10);
                console.log('Limits on Get Records', component.get("v.limits") );
            } else if (state === "ERROR") {
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
    onSetColumnsAndQuickactions: function(component){
        component.set('v.columns',[
            {label:'Polizza numero', fieldName:'policyId', type:'url', hideDefaultActions: true, typeAttributes: {
                    label: { fieldName: 'name' }
                } 
            },
            {label: 'Nome Prodotto', fieldName:'productName', type:'text',sortable: true, hideDefaultActions: true},
            {label: 'Stato polizza', fieldName:'status', type:'text', sortable: true, hideDefaultActions: true},
            {label: 'Data Effetto', fieldName:'dataEffetto', type:'date', sortable: true, hideDefaultActions: true,  typeAttributes: {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric'}
            },
            {label: 'Data Scadenza', fieldName:'dataScadenza', type:'date', sortable: true, hideDefaultActions: true, typeAttributes: {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric'}
            },
            {label: 'Premio Totale Polizza lordo', fieldName:'PremioTotalePolizza', type:'currency' ,sortable: true, hideDefaultActions: true },
            {label: 'Premio totale a pagare annuo lordo', fieldName:'PremiototalePagareAnnuo', type:'currency' ,sortable: true, hideDefaultActions: true },
            {label: 'Ultimo premio pagato lordo', fieldName:'UltimoPremioPagatoLordo', type:'currency' ,sortable: true, hideDefaultActions: true },
            {label: 'Ultimo premio aggiuntivo lordo pagato', fieldName:'UltimoPremioAggiuntivoLordoPagato', type:'currency' ,sortable: true, hideDefaultActions: true },
            {label: 'Ultimo premio lordo pagato pianificato', fieldName:'UltimoPremioLordoPagatoPianificato', type:'currency' ,sortable: true, hideDefaultActions: true }
        ]);
    },
   onGetCount : function(component) {
        var action = component.get("c.getCount");
        let accountId = component.get('v.accountId');
        let asaJson = component.get("v.asaJson");
        let schedaClientePolizzaType = component.get("v.schedaClientePolizzaType");
        action.setParams({
            "id" : accountId,
            "asaJson": asaJson,
            "schedaClientePolizzaType" : schedaClientePolizzaType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                component.set("v.count", resultData);
            }
        });
        $A.enqueueAction(action);
    },
    setFocusedTabLabel : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: component.get('v.title')
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: component.get('v.iconName')
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    },
          // Used to sort the 'Age' column
          sortBy: function(field, reverse, primer) {
            var key = primer
                ? function(x) {
                      return primer(x[field]);
                  }
                : function(x) {
                      return x[field];
                  };
    
            return function(a, b) {
                a = key(a);
                b = key(b);
                return reverse * ((a > b) - (b > a));
            };
        },

        handleSort: function( component, event) {
            var sortedBy = event.getParam('fieldName');
            var sortDirection = event.getParam('sortDirection');
    
            var cloneData = component.get('v.data').slice(0);
            cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
            
             component.set('v.data', cloneData);
             component.set('v.sortDirection', sortDirection);
             component.set('v.sortedBy', sortedBy);
        }
})
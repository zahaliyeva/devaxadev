({
    helperMethod : function(component) {
        var action = component.get("c.loadClaims");
        action.setParams({ 
            accountId : component.get("v.account.Id"),
            limite : component.get("v.limits")
        });
        if(component.get("v.account.Id")!=null){
            action.setCallback(this, function(response) {
                component.set('v.loading', true);
                var state = response.getState();
                if (state === "SUCCESS") {  
                    this.parseResponse(component, response.getReturnValue());
                    component.set('v.loading', false);
                }
                else if (state === "INCOMPLETE") {
                    console.log("incomplete state");
                    component.set('v.loading', false);
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
                    component.set('v.loading', false);
                }
            });
            $A.enqueueAction(action);
        }else{
            component.set('v.titolo','Ricaricare Visualizza Tutto da scheda cliente...');  
        }
    },
    parseResponse: function(component, returnValue){
        var records =  returnValue.listaOut;
        var count =  returnValue.counter;
        records.forEach((element) => element['URL'] = '/lightning/r/Account/' + element['Id'] + '/view');
        component.set("v.vClaims", records);
        component.set("v.count", count);

    },
    onVisualizzaTutto: function(component) {
        if(component.get('v.account')!=null){
            var navService = component.find("navService");
            var pageReference = {
                "type": "standard__component",
                "attributes": {  
                    "componentName": "c__schedaClienteSinistri"
                }, 
                "state": {
                    'c__account': component.get('v.account'),
                    'c__visualizzaTutto': false,
                    'c__styleIni': 'height: 400px',
                    'c__limite': 10
                }
            };
            navService.navigate(pageReference);
        }else{
            component.set('v.titolo','Ricaricare Visualizza Tutto da scheda cliente...');
        }
    },
    onSetColumnsAndQuickactions: function(component){
        component.set('v.columns',[
            {label: 'Numero Sinistro', fieldName: 'URL', type: 'url',hideDefaultActions: true,
             typeAttributes: {
                label: { fieldName: 'Name' },
                title: { fieldName: 'Name' }
            }},
            {label: 'Numero sinistro completo', fieldName:'cnum_Claim__c', type:'text' ,sortable: true,hideDefaultActions: true},
            {label: 'Tipologia', fieldName:'Claim_Type__c', type:'text',hideDefaultActions: true, sortable: true  },
            {label: 'Descrizione evento sinistro', fieldName:'cdesc_evento__c', type:'text',sortable: true, hideDefaultActions: true },
            {label: 'Ramo', fieldName:'Ramo__c', type:'text',hideDefaultActions: true, sortable: true },
            {label: 'Stato', fieldName:'Status__c', type:'text',hideDefaultActions: true, sortable: true  },
            {label: 'Descrizione esito sinistro', fieldName:'cdesc_esito_sinistro__c',hideDefaultActions: true,sortable: true, type:'text'  },
            {label: 'Numero polizza', fieldName:'Policy_Code__c',hideDefaultActions: true,sortable: true, type:'text'  },
            {label: 'Data denuncia sinistro', fieldName:'ddenuncia__c', type:'date'  ,sortable: true, hideDefaultActions: true, typeAttributes: {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric'
            }},
            {label: 'Data apertura sinistro', fieldName:'Opening_Date__c', type:'date'  ,sortable: true, hideDefaultActions: true, typeAttributes: {
                    day: '2-digit',
                    month: '2-digit',
                    year: 'numeric'
            }},
            {label: 'Data chiusura sinistro', fieldName:'Closing_Date__c', type:'date'  ,sortable: true, hideDefaultActions: true, typeAttributes: {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric'
            }},

            {label: 'Importo rimborso lordo', fieldName:'Reimboursment__c', type:'currency' ,sortable: true,hideDefaultActions: true },
            {label: 'Data rimborso', fieldName:'Reimboursment_Date__c', type:'date'  ,sortable: true,hideDefaultActions: true, typeAttributes: {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric'
            }},
            {
                type: "button",
                fixedWidth: 150,
                typeAttributes: {
                    label: 'Visualizza su SOL',
                    title: 'Visualizza su SOL',
                    name: 'viewSol',
                    value: 'viewSol',
                    variant: 'brand'
                }
            }
        ]);
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
    
            var cloneData = component.get('v.vClaims').slice(0);
            cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
            
             component.set('v.vClaims', cloneData);
             component.set('v.sortDirection', sortDirection);
             component.set('v.sortedBy', sortedBy);
        }
})
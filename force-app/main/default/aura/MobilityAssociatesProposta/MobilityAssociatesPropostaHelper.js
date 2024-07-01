({
    init : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Codice Proposta', fieldName: 'CodiceProposta', type: 'text'} ,
            {label: 'Data Scadenza',  fieldName: 'dataScadenza', type: 'text'}, 
            {label: 'Data Effetto', fieldName: 'DataEffetto', type: 'text'}, 
            {label: 'Data Fine Validità', fieldName: 'dataFineValidita', type: 'text'}, 
            {label: 'Prodotto', fieldName: 'Prodotto', type: 'text'},
            {label: 'Sott-Asa', fieldName: 'SubAsa', type: 'text'},
            {label: 'Stato', fieldName: 'Stato', type: 'text'},
            {label: 'Ultima Modifica', fieldName: 'UltimaModifica', type: 'text'}
            
        ]);
        
        this.getUserInfo(component, event, helper);
    },
    
    getUserInfo : function(component, event, helper) {
        var action = component.get("c.getUserInfo");
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if(   response.getReturnValue().Profile.Name !='NFE - AAI - Vendite Avanzato'
                   && response.getReturnValue().Profile.Name !='NFE - AAI - Vendite Base'                
                   && response.getReturnValue().Profile.Name !='System Administrator'
                   && response.getReturnValue().Profile.Name !='Amministratore del sistema'){
                    component.set("v.showError",true);
                    component.set("v.ErrorMsg",'Non si dispone dei permessi necessari per eseguire l\'operazione');
                } else{           
                    // component.set("v.userInfo", response.getReturnValue());  
                    this.getOpportunityInfo(component, event, helper);
                }
                
            }
        });
        $A.enqueueAction(action);  
        
    },
    
    getOpportunityInfo : function(component, event, helper) {
        var url_string = window.location.href;
        var url = new URL(url_string);
        var recordId = url.searchParams.get("recordId");
        
        var action = component.get("c.getOpportunityInfo");
        action.setParams({ oppId : recordId });
        
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if(  response.getReturnValue().Numero_proposte__c >= 1){
                    component.set("v.showError",true);
                    component.set("v.ErrorMsg",'Risulta essere già presente una proposta per questa opportunità. Per creare una nuova proposta è necessario creare una nuova opportunità');
                } else{           
                    component.set("v.opportunityInfo", response.getReturnValue());  
                    this.getListFromREOL(component, event, helper);
                }
                
            }
        });
        $A.enqueueAction(action);  
    },
    
    getListFromREOL: function(component, event, helper) {
        
        var action = component.get("c.getListFromREOL");
        action.setParams({ scopeOpp : component.get("v.opportunityInfo") });
        
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                
                resp.forEach(function(entry) {
                    entry.Prodotto= entry.ProdCode+' - '+entry.ProdName;
                    entry.UltimaModifica = entry.LastModBy+' - '+entry.LastModDate;    
                });
                
                component.set("v.ProposteList", resp );            
                component.set("v.showTable", true);  
            }else{
                    component.set("v.showError",true);
                    component.set("v.ErrorMsg", response.getError()[0].message);  
            }
        });
        $A.enqueueAction(action);  
    },
    
    
    confirm: function(component, event, helper) {
        console.log('component.get("v.opportunityInfo").Id '+ component.get("v.opportunityInfo").Id + component.get("v.selectedRowsCodiceProposta"));
        var action = component.get("c.confirm");
        action.setParams({ oppId : component.get("v.opportunityInfo").Id, CodiceProposta: component.get("v.selectedRowsCodiceProposta") });
        
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();         
        
                component.set("v.PropostaCreated", resp );            
                component.set("v.showTable", false);
                component.set("v.displaySuccess", true);
            }else{
                    component.set("v.showError",true);
                    component.set("v.ErrorMsg", response.getError()[0].message);  
            }
        });
        $A.enqueueAction(action);  
    },
    getRow: function (component, event, helper) {
     
        let lines = component.find('PropostaTable').getSelectedRows();
        var line = JSON.stringify(lines );
        console.log('**', line);
        var stringify = JSON.parse(line);
         for (var i = 0; i < stringify.length; i++) {          
            component.set("v.selectedRowsCodiceProposta", stringify[i]['CodiceProposta']);
           }         
     
       },
    
    gotToDetail: function (component, event, helper, objId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": objId
        });
        navEvt.fire();
    }  ,
    
     showToast : function (component, title, message, type){
     var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					title: title,
					message: message,
					duration:' 3000',
					type: type,
				});
				toastEvent.fire();
   }

})
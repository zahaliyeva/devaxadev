({
    init : function(component, event, helper) {
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
                    let title="Error!";
                    let msg="Non si dispone dei permessi necessari per eseguire l\'operazione";
                    this.showToast(component, event, helper, title, msg, "error");
                    $A.get("e.force:closeQuickAction").fire();
                } else{           
                    component.set("v.userInfo", response.getReturnValue());  
                    this.getOpportunityInfo(component, event, helper);
                }
                
            }
        });
        $A.enqueueAction(action);
        
        
    },
    
    getOpportunityInfo : function(component, event, helper) {
        
        var action = component.get("c.getOpportunityInfo");
        action.setParams({ oppId : component.get("v.recordId") });
        
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if(  response.getReturnValue().Numero_proposte__c >= 1){
                    let title="Error!"
                    let msg="Risulta essere già presente una proposta per questa opportunità. Per creare una nuova proposta è necessario creare una nuova opportunità";
                    this.showToast(component, event, helper, title, msg, "error") ;
                    $A.get("e.force:closeQuickAction").fire();
                } else{           
                    component.set("v.opportunityInfo", response.getReturnValue());  
                    this.goToUrl(component, event, helper);
                }
                
            }
        });
        $A.enqueueAction(action);  
    },
    
    goToUrl : function(component, event, helper) {
        
        var OppId = component.get("v.opportunityInfo").Id;
        var OppName = component.get("v.opportunityInfo").Name;
        var NumOfProposte = component.get("v.opportunityInfo").Numero_proposte__c;
        var Agencycode =  component.get("v.userInfo").Agency_Code__c;
        var MyriamUsername= component.get("v.userInfo").CommunityNickname;
        var NDG = component.get("v.opportunityInfo").Account.NDG__c;
        
               
        var TargetURL='ServletSalesForce?RGICommand=NewProp&utente='+MyriamUsername+'&codiceAgenzia='+Agencycode+'&codiceNDG='+NDG+'&keySFDC='+OppId+'&descSFDC='+OppName;
        console.log('TargetURL: '+TargetURL);
        var daolUrl;
        
        var action = component.get("c.getCreaPropostaDaolUrl");
              
        action.setCallback(this, function(response){
                daolUrl=response.getReturnValue();   
                console.log('daolUrl: '+daolUrl);
                try{
                    window.open(daolUrl+TargetURL, "_blank");
                }catch(e) {
                    let title="An Error has Occured. Error: ";            
                    this.showToast(component, event, helper, title, e, "error") ;                  
                }finally{
                    $A.get("e.force:closeQuickAction").fire();
                }
            });
        $A.enqueueAction(action);  
     
    },
    
    showToast : function(component, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
    
    
})
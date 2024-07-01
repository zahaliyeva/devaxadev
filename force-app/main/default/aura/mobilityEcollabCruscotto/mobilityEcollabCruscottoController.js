({
 
    Init:function(cmp, evt, help){
        //puo fare o vedere il Ecollab?
        var action = cmp.get("c.InitRecords");
        action.setCallback(this, function(response) {
            var state = response.getState();
            let result = response.getReturnValue();
            if (state === "SUCCESS") {
                    cmp.set("v.iniziativaScelta",{IniziativaName:'Iniziativa NON ATTIVA'}); // default value is DAC 
                    cmp.set("v.targetScelta",result.targetScelta);// default value is DAC 
                    cmp.set("v.dashboardId",result.dashboardId);// default value Ecollab
                    cmp.set("v.dashboardIdOld",result.dashboardId);
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        cmp.set("v.iniziativaScelta",{IniziativaName:'Iniziativa NON ATTIVA'}); // default value is DAC 
                        cmp.set("v.targetScelta",null);// default value is DAC 
                        cmp.set("v.dashboardId",null);// default value Ecollab
                    }
                }
            }
        });
        $A.enqueueAction(action);
        var tipologiaScelta = {
            "Name":"Amm_Con_Invio",
            "Type__c":"Amministrativa",
            "With_Message__c":true
        }
        cmp.set("v.tipologiaScelta",tipologiaScelta);
 
        window.addEventListener("message", function(event) {
            if(event.data.id === 'dashboardEvent'){
                cmp.set("v.ready", false);
                if(cmp.get("v.dashboardIdOld") != event.data.target.dashboardId){
                    cmp.set("v.isCliccable", true);
                }else{
                    cmp.set("v.isCliccable", false);
                }
                cmp.set("v.dashboardId",event.data.target.dashboardId);
                
                cmp.set("v.ready", true);
                return;
            }

            // Verifica l'origine
            if (event.origin !== window.location.protocol + "//"+ window.location.hostname) return
 
            // Fai qualcosa con il messaggio
            var req = event.data;
 
            if(req.Action === 'REQUEST_VALUES'){
            var response = {
                "Action":"SEND_VALUES",
                "values": {
                    "tipologiaScelta":cmp.get("v.tipologiaScelta"),
                    "iniziativaScelta":cmp.get("v.iniziativaScelta"),
                    "targetScelta":cmp.get("v.targetScelta")
                }
            };
                event.source.postMessage(response,  window.location.protocol + "//"+ window.location.hostname)
            }
            else if(req.action === 'NAVIGATETO'){
 
            
                if(req.id !== 'mobilityEcollabCruscotto'){
                    req.id = 'mobilityEcollabCruscotto'
                    window.parent.postMessage(req, '*');
                }
 
                
            }
        }, false);

 
        var hook = {action:"HOOK_REQUEST",id:"mobilityEcollabCruscotto"};
        window.parent.postMessage(hook,'*');
 
    },
 
    resetDashboard: function(cmp,evt){
        cmp.set("v.ready", false);
        cmp.set("v.dashboardId",evt.Ep);
        
        cmp.set("v.isCliccable", false);
        cmp.set("v.ready", true);
    },
 
    closePostMessage : function(component, event, helper) {
        var hook = {"id":"mobilityEcollabCruscotto", "action":"NAVIGATETO","target":{"name":"homepage","label":"Homepage","action":"homepageCallback","parent":null,"active":false,"params":{}}};
        window.parent.postMessage(hook,'*');
    }
})
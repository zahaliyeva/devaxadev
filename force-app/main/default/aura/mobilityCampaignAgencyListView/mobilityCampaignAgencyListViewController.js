({

    
    doInit : function(component, event, helper) {
        // Aggiungi un listener per gli eventi "message"


        window.addEventListener("message", function(event) {
            // Verifica l'origine
            if (event.origin !== "https://axaitalia--develop1.sandbox.my.site.com/") return;

            // Fai qualcosa con il messaggio
            console.log("Received message from LWC: " + event.data);
        }, false);
    },

    iframeLoaded : function(component, event, helper) {
        
    },


handleSelectionChanged: function(component, event, helper) {
    var params = event.getParams();
    var payload = params.payload;
    if (payload) {
        var step = payload.step;
        var data = payload.data;
        console.log("Selection payload: ", JSON.parse(JSON.stringify(payload)));
        if(step === 'Dashboard_Page_1'){
            window.scrollTo(0,0)
            let selectedPage = data[0];
            if(!selectedPage.Contains_Dashboard__c){
                component.set("v.showDash", false);
                component.set("v.navigationHeight", 950);
                console.log("nascondo la dashboard");
                component.set("v.previousPage", selectedPage.Page_Id__c);
            }
        }
        if(step === 'Dashoard_Tipologia_1'){
            let selectedTipologia = data[0];
            component.set("v.tipologiaScelta", selectedTipologia);
            if(!selectedTipologia.With_Message__c){
                component.set("v.iniziativaScelta", null);
            }
        }
        else if(step === 'lens_3'){ //selezione messaggio
            let messaggio = data[0];
            component.set("v.iniziativaScelta", messaggio);
        }
        else if(step.includes('Selezione_Target')){ //selezione messaggio
            let target = data[0];
            if(target){
                component.set("v.showDash", true);
                component.set("v.dashboardId", target.DashboardId);
                component.set("v.navigationHeight", 300);
                component.set("v.targetScelta", target);
            }
            else{
                component.set("v.showDash", false);
                component.set("v.navigationHeight", 950);
                console.log("nascondo la dashboard");
            }
            
        }
    }
},

showDash : function(component, event, helper) {
    component.set("v.show", true);
},

handleEvent : function(component, event, helper){
    
    let eventType = event.getParam("Action");

    if(eventType === 'set'){

        component.set('v.'+event.getParam("Type"), event.getParam('record'));
        console.log('record: ', JSON.parse(JSON.stringify(event.getParam('record'))));
        localStorage[event.getParam("Type")] = event.getParam('record');
    }

    else if(eventType === 'openDash'){
        
        component.set("v.showDash", true);
        component.set("v.dashboardId", event.getParam("recordId"));
        component.set("v.previousPage", event.getParam("pageId"));
        component.set("v.navigationHeight", 300);
        

        console.log(component.get("v.filter"))
    }

    else if(eventType === 'pageOpening'){
        console.log(event.getParam("hasDash"))
        let hasDash = event.getParam("hasDash");
        if(hasDash === "false"){
            component.set("v.showDash", false);
            component.set("v.dashboardId", null);
            component.set("v.navigationHeight", 1500);
        }
    }

    
},

Init:function(cmp, evt, help){
    console.log(JSON.stringify(cmp.get("v.params")))
    localStorage.setItem("test", "test");
    var action = cmp.get("c.isAllowed");
        action.setCallback(this, function(response) {

            var state = response.getState();
            console.log("State: ", state);
            console.log("response: ", response.getReturnValue());
            if (state === "SUCCESS") {
                cmp.set("v.isAllowed", response.getReturnValue());
            }

        });
        $A.enqueueAction(action);

    window.customFunction = (test) => {
        return {'test':test}
    }
    window.addEventListener("message", function(event) {
        // Verifica l'origine
        if (event.origin !== window.location.protocol + "//"+ window.location.hostname) return

        // Fai qualcosa con il messaggio
        console.log("Received message from LWC: ", event.data);
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
        else if(req.action === 'NAVIGATETO' && req.id !== 'mobilityPushHomepage'){
            console.log("postMessage");
            req.id = 'mobilityPushHomepage'
            window.parent.postMessage(req, '*');
        }
        //let lwcWindow = component.find("asset-"+component.get("v.dashboardId")).getElement().contentWindow;
        //cmp.set('v.handlerIframe',  event.currentTarget);
        //event.currentTarget.postMessage("Hello from Aura Component!", "https://axaitalia--develop1.sandbox.my.site.com");
    }, false);

    var hook = {action:"HOOK_REQUEST",id:"mobilityPushHomepage"};
    window.parent.postMessage(hook,'*');

    //
    //cmp.get('v.handlerIframe').postMessage("Hello from Aura Component!", "https://axaitalia--develop1.sandbox.my.site.com");
},

changePage: function(component, evt, help){
    var pageId = component.get("v.previousPage");
    var developerName = "Push_Notification_Dashboard_Navigazione";

    var evt = $A.get("e.wave:pageChange");
    var params = {
        devName: developerName,
        pageid: pageId
    };
    evt.setParams(params);
    evt.fire();
},

openDashboard: function(cmp, evt, help){
    cmp.set("v.showDash", true);
    cmp.set("v.dashboardId", "0FK0E0000008YOXWA2");
},

back: function(cmp,evt,help){
    var nav = cmp.find("navigation");
    nav.setState(
        {
            "pageId": cmp.get("v.previousPage")
        }
    )
}
})
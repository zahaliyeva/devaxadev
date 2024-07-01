({
    init : function(component, event, helper) {
        
        function liveAgentStart(){
            //timeout to initiate liveAgent
            window.setTimeout(
                $A.getCallback(function() {
                    if (component.isValid()) {
                        var data = {};
                        data.LA_chatServerURL =component.get("v.endpoint");
                        data.LA_deploymentId =component.get("v.deploymentId");
                        data.organizationId =component.get("v.organizationId");
                        data.chatButtontId =component.get("v.chatButtontId");
                        data.userSessionData =component.get("v.userSessionData");
                        if (component.get("v.NewCase") != null){
                            data.Agentid =component.get("v.NewCase").User__c;
                            data.Category=component.get("v.NewCase").Category__c;
                            data.SubCategory=component.get("v.NewCase").SubCategory__c;
                            data.Subject=component.get("v.NewCase").Subject;
                            data.Description=component.get("v.NewCase").Description;
                            data.Lob=component.get("v.NewCase").LOB__c;
                            data.RecType=component.get("v.NewCase").RecordTypeId;
                            data.Cliente=component.get("v.NewCase").AccountId;
                            data.Targa=component.get("v.NewCase").Targa__c;
                            data.Polizza=component.get("v.NewCase").InsurancePolicy__c;
                            data.AgencyCode=component.get("v.NewCase").Agency_Code__c
                        }
                        function initLiveAgent (data){
                            var self = this;
                            self.data = data;
                            console.log('data: ',data);
                            console.log('if:'+typeof liveagent+'___'+document.getElementById('btONline'));
                            if ((typeof liveagent == "object") && (document.getElementById('btONline') != null )){
                                console.log('CTRL  init live agent');
                                clearInterval(interV);
                                                            
                                helper.bindLiveAgent(component,data);
                            }else{
                                console.log('CTRL  timeout to init live agent');
                            }
                        }
                        //setInterval to initiate liveAgent when liveagent object
                        // is available
                        interV = setInterval(initLiveAgent,500,data);
                    }else{
                        console.log('CTRL  component is not valid');
                    }
                }), 100
            );
        }
        
        var isValid = helper.validateComponent(component);
        component.set("v.isInvalidInput", !isValid);
        if ( isValid){
            
            liveAgentStart();
            
            
            var chatBtn = component.get("v.chatButtontId")+'';
            //adding liveAgent buttons wo global array
            if (!window._laq) { window._laq = []; }
            window._laq.push(function(){
                liveagent.showWhenOnline(
                    (function (chatBtn) {
                        return chatBtn;
                    })(chatBtn)
                    , document.getElementById('btONline'));
                liveagent.showWhenOffline(
                    (function (chatBtn) {
                        return chatBtn;
                    })(chatBtn)
                    , document.getElementById('btOFFline'));
            });
        }
    },
    
    startChat : function(component, event, helper) {
        //liveagent.startChat(component.get("v.chatButtontId"));              
        var myEvent = component.getEvent("LiveChatButtonPressEvent");
        myEvent.setParams({"IsPressed": true});
        myEvent.fire();
        component.set("v.IsPressed",true);
        liveagent.startChat(component.get("v.chatButtontId"));
        
        var onlineBtn = document.getElementById('btONline');
        var btPressed = document.getElementById('btPressed');
        
        $A.util.removeClass(btPressed, "toggle");
        $A.util.addClass(onlineBtn, "toggle");     
    },
    executeSetValues : function(component, event,helper){
        console.log('@@executeSetValues@@');
        var params = event.getParam("arguments");
        
        component.set("v.NewCase.Subject",params.Subject);
        component.set("v.NewCase.Description",params.Description);
        component.set("v.NewCase.Targa__c",params.Targa);
        component.set("v.NewCase.AccountId",params.Cliente);
        component.set("v.NewCase.InsurancePolicy__c",params.Polizza);
        console.log('@Cliente@: ',params.Cliente);
        /*     
        var data = {};
        var self = this;
        data.LA_chatServerURL =component.get("v.endpoint");
        data.LA_deploymentId =component.get("v.deploymentId");
        data.organizationId =component.get("v.organizationId");
        data.chatButtontId =component.get("v.chatButtontId");
        data.userSessionData =component.get("v.userSessionData");
        if (component.get("v.NewCase") != null){
            data.Agentid =component.get("v.NewCase").User__c;
            data.Category=component.get("v.NewCase").Category__c;
            data.SubCategory=component.get("v.NewCase").SubCategory__c;
            data.Subject=component.get("v.NewCase").Subject;
            data.Description=component.get("v.NewCase").Description;
            data.Lob=component.get("v.NewCase").LOB__c;
            data.RecType=component.get("v.NewCase").RecordTypeId;
            data.Cliente=component.get("v.NewCase").AccountId;
            data.Targa=component.get("v.NewCase").Targa__c;
            data.Polizza=component.get("v.NewCase").InsurancePolicy__c;        
        }
if(data.Subject!=undefined)
                {
                	liveagent.addCustomDetail('Oggetto', data.Subject,false);
                }
            	else
                {
					liveagent.addCustomDetail('Oggetto', '',false);	                    
                }
            
            	if(data.Description!=undefined)
                {
                	liveagent.addCustomDetail('Descrizione', data.Description,false);
                }
            	else
                {
					liveagent.addCustomDetail('Descrizione', '',false);	                    
                } 
            
            	if(data.Cliente!=undefined)
                {
                    liveagent.addCustomDetail('Cliente', data.Cliente,false);
                }
            	else
                {
                    liveagent.addCustomDetail('Cliente', '',false);
                }
            
            	if(data.Targa!=undefined)
                {
                    liveagent.addCustomDetail('Targa', data.Targa,false);
                }
            	else
                {
                    liveagent.addCustomDetail('Targa', '',false);
                }
            
            	if(data.Polizza!=undefined)
                {
                    liveagent.addCustomDetail('Polizza', data.Polizza,false);
                }
            	else
                {
                    liveagent.addCustomDetail('Polizza', '',false);
                } */
    }
})
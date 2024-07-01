({
    helperMethod : function(component) {
        
    },
    
    validateComponent : function(component) {
        var valid = true;
        
        if (component.isValid()) {
            valid =  ( component.get("v.chatButtontId") != undefined && component.get("v.chatButtontId") != '')
            || ( component.get("v.endpoint") != undefined && component.get("v.endpoint") != '')
            || ( component.get("v.deploymentId") != undefined && component.get("v.deploymentId") != '')
            || ( component.get("v.deploymentUrl") != undefined && component.get("v.deploymentUrl") != '')
            || ( component.get("v.organizationId") != undefined && component.get("v.organizationId") != '') ;
        }
        return valid;
    },
    bindLiveAgent : function (component,data){
        //custom handler for online/offline update
        function updateLiveAgentButton(component) {
            
            console.log('agent online: '+component.get("v.isLiveAgentOnline"));
            
            if (component.isValid()) {
                var onlineBtn = document.getElementById('btONline');//component.find("btONline");
                var offlineBtn = document.getElementById('btOFFline');//component.find("btOFFline");
                var btInitial = document.getElementById('btInitial');
                
                if( (  typeof onlineBtn != "undefined"  ) &&
                   (  typeof offlineBtn != "undefined"  )){
                    
                    if ( component.get("v.isLiveAgentOnline")== true){
                        $A.util.removeClass(onlineBtn, "toggle");
                        $A.util.addClass(offlineBtn, "toggle");
                        $A.util.addClass(btInitial, "toggle");
                        
                    }else{                       
                        $A.util.removeClass(offlineBtn, "toggle");
                        $A.util.addClass(onlineBtn, "toggle");
                        $A.util.addClass(btInitial, "toggle");
                    }
                }
            }
        }
        
        component.set("v.isLiveAgentOnline",false);
        var chatBtn    = data.chatButtontId;
        console.log('@@chatBtn: '+chatBtn);
        liveagent.addButtonEventHandler(chatBtn, function(e) {
            console.log(e);
            if (e == liveagent.BUTTON_EVENT.BUTTON_AVAILABLE) {
                component.set("v.isLiveAgentOnline",true);
            } else if (e == liveagent.BUTTON_EVENT.BUTTON_UNAVAILABLE) {
                component.set("v.isLiveAgentOnline",false);
            }
            if (component.get("v.previousIsLiveAgentOnline") == null){
                component.set("v.previousIsLiveAgentOnline",false);
            }else {
                component.set("v.previousIsLiveAgentOnline",component.get("v.isLiveAgentOnline"));
            }
            
            
            updateLiveAgentButton(component);
        });
        
        if (data.userSessionData){
             
                console.log("dentro");
                liveagent.addCustomDetail('Case Origin', 'Chat',false);
                liveagent.addCustomDetail('Case Status', 'Assigned', false);
                liveagent.addCustomDetail('Chiamante', 'Agente',false);
            
            	if(data.Subject!=undefined)
                {
                	liveagent.addCustomDetail('Oggetto', data.Subject);
                }
            	else
                {
					liveagent.addCustomDetail('Oggetto', '');	                    
                }
            
            	if(data.Description!=undefined)
                {
                	liveagent.addCustomDetail('Descrizione', data.Description);
                }
            	else
                {
					liveagent.addCustomDetail('Descrizione', '',false);	                    
                } 
            
            	if(data.Cliente!=undefined)
                {
                    liveagent.addCustomDetail('Cliente', data.Cliente);
                }
            	else
                {
                    liveagent.addCustomDetail('Cliente', '',false);
                }
            
            	if(data.Targa!=undefined)
                {
                    liveagent.addCustomDetail('Targa', data.Targa);
                }
            	else
                {
                    liveagent.addCustomDetail('Targa', '',false);
                }
            
            	if(data.Polizza!=undefined)
                {
                    liveagent.addCustomDetail('Polizza', data.Polizza);
                }
            	else
                {
                    liveagent.addCustomDetail('Polizza', '',false);
                }               
            
                liveagent.addCustomDetail('Lob', data.Lob);
                liveagent.addCustomDetail('Categoria', data.Category);
                liveagent.addCustomDetail('SottoCategoria', data.SubCategory);
                liveagent.addCustomDetail('TipoCase', data.RecType);
                liveagent.addCustomDetail('Distribution','Axa Assicurazioni');
                liveagent.addCustomDetail('Agente',data.Agentid);
            	liveagent.addCustomDetail('Agenzia',data.AgencyCode);
				liveagent.findOrCreate('Case').map('Agency_Code__c','Agenzia',false,false,true).map('Internal_LOB__c','Lob',false,false,true).map('Internal_Category__c','Categoria',false,false,true).map('Internal_SubCategory__c','SottoCategoria',false,false,true).map('InsurancePolicy__c','Polizza',false,false,true).map('AccountId','Cliente',false,false,true).map('Targa__c','Targa',false,false,true).map('Description','Descrizione',false,false,true).map('LOB__c','Lob',false,false,true).map('Distribution_Network__c','Distribution',false,false,true).map('Oggetto_Apertura_Case__c','Oggetto',false,false,true).map('Category__c','Categoria',false,false,true).map('SubCategory__c','SottoCategoria',false,false,true).map('RecordTypeId','TipoCase',false,false,true).map('Complainant__c','Chiamante',false,false,true).map('Status', 'Case Status', false, false, true).map('Origin', 'Case Origin', false, false, true).map('User__c', 'Agente', false, false, true).showOnCreate().saveToTranscript('CaseId');
            	//set the visitor's name to the value of the contact's first and last name
            	liveagent.setChatWindowHeight(538);
				liveagent.setChatWindowWidth(490);
            	console.log(component.get("v.AgentName"));
                liveagent.setName(component.get("v.AgentName"));
            
        }        
        liveagent.init( data.LA_chatServerURL, data.LA_deploymentId,  data.organizationId);
    }
})
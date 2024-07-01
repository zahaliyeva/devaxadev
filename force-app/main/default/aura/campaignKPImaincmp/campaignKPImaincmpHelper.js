({
    onHandleClick : function(component, event, helper) 
    {
        
        console.log('NoClientsinTarget'+component.get('v.NoClientsinTarget'));
        
        if(component.get("v.NoClientsinTarget") ==false){
            console.log('CampaignId'+component.get('v.CampaignId'));
            console.log('CollaboratoreId'+component.get('v.CollaboratoreId'));
            console.log('CodiceAgenzia'+component.get('v.CodiceAgenzia'));
            console.log('PartnerUrl'+component.get('v.PartnerUrl'));
            console.log('AgencyList'+component.get('v.AgencyList'));
            console.log('SessionId'+component.get('v.SessionId'));
            
            //Get the variable of Controller (Apex) Class
            
            //var myCampaign = component.get('c.getCampaign');
            //component.set("v.CampaignId", '70125000000Rwvi');
            
            // Get the action of Controller (Apex) Class
            
            var action = component.get('c.ClientiInTarget');
            var action2 = component.get('c.ClientiLavorati');
            var action3 = component.get('c.ClientiPrioritari');
            var action4 = component.get('c.ClientiPrioritariLavorati');
            var action5 = component.get('c.OpportunitaCreate');
            var action6 = component.get('c.OpportunitaVinte');
            var action7 = component.get('c.ClientiConEmailSMSInTarget');
            var action8 = component.get('c.EmailSMSNonRecapitabili');
            var action9 = component.get('c.ClientiConEmailInTarget');
            var action10 = component.get('c.ClientiEmailApertaRichiestaContatto');
            var action11 = component.get('c.ClientiConSMSInTarget');
            var action12 = component.get('c.ClientiSMSApertoRichiestaContatto');
            var action13 = component.get('c.ClientiConEmailSMSAperti');
            var action14 = component.get('c.OpportunitaVinteClientiPrioritari');
            var action15 = component.get('c.RevenueOpportunitaVinte');
            var action16 = component.get('c.OpportunitaIncorso');
            var action17 = component.get('c.RevenueOpportunitaInCorso');
            var action18 = component.get('c.ClientiPrioritariEmail');
            var action19 = component.get('c.ClientiPrioritariSMS');
            var action20 = component.get('c.EmailSMSrecapitati');
            var QueryCalls = component.get("v.QueryCalls");
            
            for (var i = 0; i < QueryCalls.length; i++)
            {
                if (i == 19) { break; }
                
                else
                {QueryCalls[i] = 0;}
            }
            if(true){
                console.log('###2'+component.get('v.AgencyList'));
                
                action.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                // set the callback which will return the response from apex
                action.setCallback(this, function(response){
                    console.log('re: '+response);
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        console.log(responseValue);
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);
                        component.set("v.ClientiInTarget", responseData.records[0].expr0);
                        component.set("v.NoClientsinTarget",false);
                        if(responseData.records[0].expr0 == 0){
                            
                            component.set("v.NoClientsinTarget",true);
                        }
                        QueryCalls[0]=1;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20)  
                            {this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action);
            }
            
            if(true){
                action2.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action2.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);
                        component.set("v.ClientiLavorati",responseData.records[0].expr0);
                        QueryCalls[1]=2;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20)  
                            {this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action2);
            }
            
            if(true){
                // set the callback which will return the response from apex
                action3.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action3.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);
                        component.set("v.ClientiPrioritari",responseData.records[0].expr0);
                        QueryCalls[2]=3;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20)  
                            {this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action3);    
            }
            
            if(true){
                // set the callback which will return the response from apex
                action4.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action4.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);   
                        component.set("v.ClientiPrioritariLavorati",responseData.records[0].expr0);
                        QueryCalls[3]=4;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20) 
                            {this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action4);    
            }
            
            if(true){
                // set the callback which will return the response from apex
                action5.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action5.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);
                        component.set("v.TrattativeCreate",responseData.records[0].expr0);
                        QueryCalls[4]=5;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20) 
                            {this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action5); 
            }
            
            if(true){
                // set the callback which will return the response from apex
                action6.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action6.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);   
                        component.set("v.TrattativeVinte",responseData.records[0].expr0);
                        QueryCalls[5]=6;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20)  
                            {this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action6);
            }
            
            if(true){
                // set the callback which will return the response from apex
                action7.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action7.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);  
                        component.set("v.ClientiConEmailSMSInTarget",responseData.records[0].expr0);
                        QueryCalls[6]=7;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20)  
                            {this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action7);
            }
            
            if(true){
                // set the callback which will return the response from apex
                action8.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action8.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);
                        component.set("v.EmailSMSNonRecapitabili",responseData.records[0].expr0);
                        QueryCalls[7]=8;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20)  
                            {this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action8);
            }
            
            if(true){
                // set the callback which will return the response from apex
                action9.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action9.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);
                        component.set("v.ClientiConEmailInTarget",responseData.records[0].expr0);
                        QueryCalls[8]=9;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20) 
                            {this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action9);
            }
            
            if(true){
                // set the callback which will return the response from apex
                action10.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action10.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0); 
                        component.set("v.ClientiEmailApertaRichiestaContatto",responseData.records[0].expr0);
                        QueryCalls[9]=10;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20) 
                            {this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action10);
            }
            
            if(true){
                // set the callback which will return the response from apex
                action11.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action11.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);
                        component.set("v.ClientiConSMSInTarget",responseData.records[0].expr0);
                        QueryCalls[10]=11;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20)  
                            {this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action11);
            }
            
            if(true){
                // set the callback which will return the response from apex
                action12.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action12.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0); 
                        component.set("v.ClientiSMSApertoRichiestaContatto",responseData.records[0].expr0);
                        QueryCalls[11]=12;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20)  
                            {this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action12);
            }
            
            if(true){
                // set the callback which will return the response from apex
                action13.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action13.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);
                        component.set("v.ClientiConEmailSMSAperti",responseData.records[0].expr0);
                        QueryCalls[12]=13;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20) 
                            {this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action13);
            }
            
            if(true){
                // set the callback which will return the response from apex
                action14.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action14.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);
                        component.set("v.TrattativeVinteClientiPrioritari",responseData.records[0].expr0);
                        QueryCalls[13]=14;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20) 
                            {this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action14);
            }
            
            if(true){
                // set the callback which will return the response from apex
                action15.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action15.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);
                        if(responseData.records[0].expr0 != null){
                            component.set("v.RevenueTrattativeVinte",responseData.records[0].expr0);
                        }else{
                            component.set("v.RevenueTrattativeVinte",0);
                        }
                        QueryCalls[14]=15;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20)  
                            {this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action15);
            }
            
            if(true){
                // set the callback which will return the response from apex
                action16.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action16.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);
                        component.set("v.TrattativeIncorso",responseData.records[0].expr0);
                        QueryCalls[15]=16;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20) 
                            {this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action16);
            }
            
            if(true){
                // set the callback which will return the response from apex
                action17.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action17.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);
                        if(responseData.records[0].expr0 != null){
                            component.set("v.RevenueTrattativeInCorso",responseData.records[0].expr0);
                        }else{
                            component.set("v.RevenueTrattativeInCorso",0);
                        }
                        console.log(component.get("v.RevenueTrattativeInCorso"));
                        QueryCalls[16]=17;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20)  
                            { this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action17);
            }
            
            if(true){
                // set the callback which will return the response from apex
                action18.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action18.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);
                        component.set("v.ClientiPrioritariEmail",responseData.records[0].expr0);
                        
                        console.log(component.get("v.ClientiPrioritariEmail"));
                        QueryCalls[17]=18;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20) 
                            { this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action18);
            }
            
            if(true){
                // set the callback which will return the response from apex
                action19.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action19.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);
                        component.set("v.ClientiPrioritariSMS",responseData.records[0].expr0);
                        
                        console.log(component.get("v.ClientiPrioritariSMS"));
                        QueryCalls[18]=19;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20)  
                            { this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action19);
            }
            
            if(true){
                // set the callback which will return the response from apex
                action20.setParams({
                    "CampaignId":component.get('v.CampaignId'),
                    "CollaboratoreId":component.get('v.CollaboratoreId'),
                    "CodiceAgenzia":component.get('v.CodiceAgenzia'),
                    "PartnerUrl":component.get('v.PartnerUrl'),
                    "SessionId":component.get('v.SessionId'),
                    "AgencyList":component.get('v.AgencyList')
                });
                action20.setCallback(this, function(response){
                    helper.stopSpinner(component);
                    // get the state
                    var state = response.getState();
                    if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        //alert(responseData);
                        console.log(responseData.records[0].expr0);
                        component.set("v.EmailSMSrecapitati",responseData.records[0].expr0);
                        
                        console.log(component.get("v.EmailSMSrecapitati"));
                        QueryCalls[19]=20;
                        component.set("v.QueryCalls",QueryCalls);
                        for (var i = 0; i < QueryCalls.length; i++)
                        {
                            if (QueryCalls[i] == 0) { break; }
                            
                            if (i==19 && QueryCalls[i] == 20) 
                            { this.calculatePercentage(component,event,helper);}
                        }
                    } else if( state === 'INCOMPLETE'){
                        console.log("User is offline, device doesn't support drafts.");
                    } else if( state === 'ERROR'){
                        console.log('Problem saving record, error: ' +
                                    JSON.stringify(response.getError()));
                    } else{
                        console.log('Unknown problem, state: ' + state +
                                    ', error: ' + JSON.stringify(response.getError()));
                    }
                });
                // send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action20);
            }
            
        }},
    
    
    InitializeFilters: function(component, event, helper) {
        var actPwoc = component.get("c.getCollaboratori");
        var inputList_collaboratori = component.find("inputList_collaboratori");
        var opts_List_collaboratori=[];
        console.log('getCollaboratori!!!');
        console.log('CampaignId'+component.get('v.CampaignId'));
        console.log('CodiceAgenzia'+component.get('v.CodiceAgenzia'));
        console.log('UserRole'+component.get('v.UserRole'));
        
        actPwoc.setParams({
            "CampaignId":component.get('v.CampaignId'),
            "CodiceAgenzia":component.get('v.CodiceAgenzia'),
            "UserRole":component.get('v.UserRole')
            
        });
        
        actPwoc.setCallback(this, function(a) {
            
            var UserRole = component.get('v.UserRole');
            if(!UserRole.includes('Utente Partner')){
                opts_List_collaboratori.push({"class": "optionClass",  value: "", label:"-- Agenzia --"});
                var IsPartnerUser = component.get("v.IsPartnerUser");
            }
            
            
            console.log('coll:'+ JSON.stringify(a.getReturnValue(), null, 4)); 
            
            for(var i=0;i< a.getReturnValue().length;i++){
                opts_List_collaboratori.push({"class": "optionClass", label: a.getReturnValue()[i].Owner__r.Name, value: a.getReturnValue()[i].Owner__r.Id});
                console.log('dentro for'+a.getReturnValue()[i].Owner__r.Name+a.getReturnValue()[i].Owner__r.Id);
            } 
            //inputList_collaboratori.set("v.options", opts_List_collaboratori);
            component.set("v.CollList",opts_List_collaboratori);
            
            
        });
        $A.enqueueAction(actPwoc);
        
    },
    
    
    InitializeAgFilters: function(component, event, helper) {
        var AgVal = component.get("c.getAgencyValues");
        var inputList_AreaMgr = component.find("inputList_AreaMgr");
        var inputList_SalesMgr = component.find("inputList_SalesMgr");
        var inputList_Agencies = component.find("inputList_Agencies");
        var opts_List_AreaMgr=[];
        var opts_List_SalesMgr=[];
        var opts_List_Agencies=[];
        var arrayOfMapKeys = [];
        var opts_Single_AreaMgr=[];
        var opts_Single_SalesMgr=[];
        
        
        var AreaManagerList=[];
        var SalesManagerList=[];
        
        
        AgVal.setCallback(this, function(a) {
            opts_List_AreaMgr.push({"class": "optionClass",  value: "", label:"-- AM --"});
            opts_List_SalesMgr.push({"class": "optionClass",  value: "", label:"-- SM --"});
            opts_List_Agencies.push({"class": "optionClass",  value: "", label:"-- Codice agenzia --"});
            
            var IsPartnerUser = component.get("v.IsPartnerUser");
            var UserName = component.get('v.UserName');
        	var UserRole = component.get('v.UserRole');
            
            var ObtainedMap = a.getReturnValue();
            var MapAMtoSM = [];
            
            console.log('returned AM, SM, agency'+JSON.stringify(a.getReturnValue(),null,4));
            
            for (var singlekey in ObtainedMap) 
            {
                arrayOfMapKeys.push(singlekey);
            }            
            
            
            for(var i=0;i<arrayOfMapKeys.length;i++)
            {
                var key = arrayOfMapKeys[i];
                
                if(key.split("|")[0] == "Area")
                {
                    
                    opts_List_AreaMgr.push({"class": "optionClass", label: ObtainedMap[key], value: ObtainedMap[key]});    
                    AreaManagerList.push(ObtainedMap[key]);
                }
                else if(key.split("|")[0] == "Sales")
                {
                    opts_List_SalesMgr.push({"class": "optionClass", label: ObtainedMap[key], value: ObtainedMap[key]});
                    SalesManagerList.push(ObtainedMap[key]);
                }
                    else if(key.split("|")[0] == "Agency")
                    {
                        opts_List_Agencies.push({"class": "optionClass", label: key.split("|")[1], value: ObtainedMap[key]});                    
                    }
                        else if(key.split("|")[0] == "Map")
                        {
                            MapAMtoSM.push(ObtainedMap[key]);  
                        }
            }
            

            //inputList_AreaMgr.set("v.options", opts_List_AreaMgr);
            //inputList_SalesMgr.set("v.options", opts_List_SalesMgr);
            //inputList_Agencies.set("v.options", opts_List_Agencies); 
            
       /*var arraylength =  AreaManagerList.length;
           console.log('UserName'+UserName); 
           for (var i = 0; i < arraylength; i++) {
           		console.log('Areamanager!'+AreaManagerList[i]);
               if(AreaManagerList[i] == UserName ){
                   console.log('DENTRO IF!');
                   opts_Single_AreaMgr.push({"class": "optionClass", label: AreaManagerList[i], value: AreaManagerList[i]});
                   component.find("inputList_AreaMgr").set("v.value",AreaManagerList[i]);
                   break;
               }     
           
           }    
             helper.onHandleClick(component, event,helper);
             helper.stopSpinner(component); */
             
            console.log('opts_List_AreaMgr before sorting'+JSON.stringify(opts_List_AreaMgr,null,4));
            console.log('opts_List_SalesMgr before sorting'+JSON.stringify(opts_List_SalesMgr,null,4));
            opts_List_AreaMgr.sort(function(a, b){
                  if(a.label < b.label) { return -1; }
                  if(a.label > b.label) { return 1; }
                  return 0;
            });
            opts_List_SalesMgr.sort(function(a, b){
                  if(a.label < b.label) { return -1; }
                  if(a.label > b.label) { return 1; }
                  return 0;
            });
            opts_List_Agencies.sort(function(a, b){
                  if(a.label < b.label) { return -1; }
                  if(a.label > b.label) { return 1; }
                  return 0;
            });
            console.log('opts_List_AreaMgr AFTER sorting'+JSON.stringify(opts_List_AreaMgr,null,4));
            console.log('opts_List_SalesMgr AFTER sorting'+JSON.stringify(opts_List_SalesMgr,null,4));
            
   	 	    component.set("v.AreaManagerList",AreaManagerList);
            component.set("v.SalesManagerList",SalesManagerList);
            
         	component.set("v.AreaList",opts_List_AreaMgr);
            component.set("v.SalesList",opts_List_SalesMgr);
            component.set("v.AgenciesList",opts_List_Agencies);
            component.set("v.MapAMtoSM",MapAMtoSM);
            console.log("MapAMtoSM: "+MapAMtoSM);
            
            
            
        });
        $A.enqueueAction(AgVal);
    },
    
    FindAgencies: function(component, event, helper) {
        var getAg = component.get('c.getAgencyCodes'); 
        component.set('v.NoClientsinTarget',false);
        console.log('AREA MANAGER'+component.get('v.AreaManagerID'));
        console.log('sales MANAGER'+component.get('v.SalesManagerID'));            
        if(true){
            getAg.setParams({
                "AM":component.get('v.AreaManagerID'),
                "SM":component.get('v.SalesManagerID'),
                "CodiceAgenzia":component.get('v.CodiceAgenzia')
            });
            // set the callback which will return the response from apex
            getAg.setCallback(this, function(response){
                // get the state
                var state = response.getState();
                if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid())
                {
                    // get the response
                    var responseValue = response.getReturnValue();
                    console.log(responseValue);
                    
                    // component.set('v.AgencyList',response.getReturnValue());
                    //console.log('###1'+component.get('v.AgencyList'));
                    
                    component.set("v.NoClientsinTarget",false);
                    
                    var lung = response.getReturnValue();
                    console.log(JSON.stringify(response.getReturnValue(), null, 4));   
                    component.set('v.AgencyList',response.getReturnValue()); 
                    
                    if(lung.length>0)
                    {
                        component.set('v.NoClientsinTarget',false);
                        helper.onHandleClick(component, event, helper);
                        
                    }
                    else
                    {   
                        
                        component.set('v.NoClientsinTarget',true); 
                        this.resetKPI(component,event,helper);
                        
                        
                        
                    }
                    
                }
            });
            $A.enqueueAction(getAg);
        }               
    },
    
    calculatePercentage : function(component, event, helper) {
        
        
        this.startSpinner(component);
        var ClientiInTarget = component.get("v.ClientiInTarget");
        var ClientiLavorati = component.get("v.ClientiLavorati");
        var ClientiPrioritari = component.get("v.ClientiPrioritari");
        var ClientiPrioritariLavorati = component.get("v.ClientiPrioritariLavorati");
        var TrattativeVinteClientiPrioritari = component.get("v.TrattativeVinteClientiPrioritari");
        var TrattativeVinte = component.get("v.TrattativeVinte");
        var TrattativeCreate = component.get("v.TrattativeCreate");
        var EmailSMSNonRecapitabili = component.get("v.EmailSMSNonRecapitabili");
        var ClientiConEmailSMSInTarget = component.get("v.ClientiConEmailSMSInTarget");
        var ClientiEmailApertaRichiestaContatto = component.get("v.ClientiEmailApertaRichiestaContatto");
        var ClientiConEmailInTarget = component.get("v.ClientiConEmailInTarget");
        var ClientiSMSApertoRichiestaContatto = component.get("v.ClientiSMSApertoRichiestaContatto");
        var ClientiConSMSInTarget = component.get("v.ClientiConSMSInTarget");
        var RevenueTrattativeVinte = component.get("v.RevenueTrattativeVinte");
        var RevenueTrattativeInCorso = component.get("v.RevenueTrattativeInCorso");
        var ClientiPrioritariEmail = component.get("v.ClientiPrioritariEmail");
        var ClientiPrioritariSMS = component.get("v.ClientiPrioritariSMS");
        var EmailSMSrecapitati = component.get("v.EmailSMSrecapitati");
        
        var perClientiLavorati = ClientiLavorati/ClientiInTarget;
        perClientiLavorati = this.checkOnResult(perClientiLavorati);
        component.set("v.perClientiLavorati",perClientiLavorati);
        
        var perTrattativeVinteClientiTarget = TrattativeVinte/ClientiInTarget;
        perTrattativeVinteClientiTarget = this.checkOnResult(perTrattativeVinteClientiTarget);
        component.set("v.perTrattativeVinteClientiTarget",perTrattativeVinteClientiTarget);
        
        var perTrattativeCreateClientiLavorati = TrattativeCreate/ClientiLavorati;
        perTrattativeCreateClientiLavorati = this.checkOnResult(perTrattativeCreateClientiLavorati);
        component.set("v.perTrattativeCreateClientiLavorati",perTrattativeCreateClientiLavorati);
        
        var perTrattativeVinteClientiLavorati = TrattativeVinte/ClientiLavorati;
        perTrattativeVinteClientiLavorati = this.checkOnResult(perTrattativeVinteClientiLavorati);
        component.set("v.perTrattativeVinteClientiLavorati",perTrattativeVinteClientiLavorati);
        
        var perClientiPLavoratiClientiPrioritari = ClientiPrioritariLavorati/ClientiPrioritari;
        perClientiPLavoratiClientiPrioritari = this.checkOnResult(perClientiPLavoratiClientiPrioritari);
        component.set("v.perClientiPLavoratiClientiPrioritari",perClientiPLavoratiClientiPrioritari);
        
        var perTrattativeVinteClientiPrioritari = TrattativeVinteClientiPrioritari/ClientiPrioritari;
        perTrattativeVinteClientiPrioritari = this.checkOnResult(perTrattativeVinteClientiPrioritari);
        component.set("v.perTrattativeVinteClientiPrioritari",perTrattativeVinteClientiPrioritari);
        
        var perEmailSMSNonRecapitabiliClientiEmailSMSTarget = EmailSMSNonRecapitabili/ClientiConEmailSMSInTarget;
        perEmailSMSNonRecapitabiliClientiEmailSMSTarget = this.checkOnResult(perEmailSMSNonRecapitabiliClientiEmailSMSTarget);
        component.set("v.perEmailSMSNonRecapitabiliClientiEmailSMSTarget",perEmailSMSNonRecapitabiliClientiEmailSMSTarget);
        
        var perClientiPrioritari = ClientiPrioritari/EmailSMSrecapitati;
        perClientiPrioritari = this.checkOnResult(perClientiPrioritari);
        component.set("v.perClientiPrioritari", perClientiPrioritari);
        
        var perEmailApertaRichiestaricontatto = ClientiEmailApertaRichiestaContatto/ClientiConEmailInTarget;
        perEmailApertaRichiestaricontatto = this.checkOnResult(perEmailApertaRichiestaricontatto);
        component.set("v.perEmailApertaRichiestaricontatto",perEmailApertaRichiestaricontatto);
        
        var perClientiPrioritariconEmail = ClientiPrioritariEmail/ClientiEmailApertaRichiestaContatto;
        perClientiPrioritariconEmail = this.checkOnResult(perClientiPrioritariconEmail);
        component.set("v.perClientiPrioritariconEmail",perClientiPrioritariconEmail);
        
        var perSMSApertoRichiestaricontatto = ClientiSMSApertoRichiestaContatto/ClientiConSMSInTarget;
        perSMSApertoRichiestaricontatto = this.checkOnResult(perSMSApertoRichiestaricontatto);
        component.set("v.perSMSApertoRichiestaricontatto",perSMSApertoRichiestaricontatto);
        
        var perClientiPrioritariconSMS = ClientiPrioritariSMS/ClientiSMSApertoRichiestaContatto;
        perClientiPrioritariconSMS = this.checkOnResult(perClientiPrioritariconSMS);
        component.set("v.perClientiPrioritariconSMS",perClientiPrioritariconSMS);
        
        RevenueTrattativeVinte = this.checkOnResult(RevenueTrattativeVinte);
        RevenueTrattativeInCorso = this.checkOnResult(RevenueTrattativeInCorso);
        
        
        this.stopSpinner(component);
        
    },
    
    checkOnResult : function(result){
        
        
        
        if (!isNaN(result) && result != 'Infinity' && result != null){
            console.log(result+' is a number');
            return result;
        }else{
            console.log('NAN');
            return 0;
        }
    },
    
    
    retrievePageVal : function(component,event, helper){
        var retrPVal = component.get("c.getPageValues");
        var arrayOfMapKeys = [];
        
        retrPVal.setCallback(this, function(a) {
            
            var ObtainedMap = a.getReturnValue();
            
            
            for (var singlekey in ObtainedMap) 
            {
                arrayOfMapKeys.push(singlekey);
            }            
            console.log('keys: '+arrayOfMapKeys);
            for(var i=0;i<arrayOfMapKeys.length;i++)
            {
                var key = arrayOfMapKeys[i];
                
                if(key.split("|")[0] == "sessionId")
                {
                    console.log('Dentro session:'+ObtainedMap[key]);
                    
                    component.set("v.SessionId",ObtainedMap[key]);
                }
                else if(key.split("|")[0] == "isStandardUser")
                {
                    console.log('Dentro isStandardUser'+ObtainedMap[key]);
                    
                    if(ObtainedMap[key]=="true")
                        component.set("v.StdUsr",true);
                    else
                        component.set("v.StdUsr",false);
                }
                    else if(key.split("|")[0] == "UserAgency")
                    {
                        console.log('Dentro UserAgency');
                        
                        component.set("v.CodiceAgenzia",ObtainedMap[key]);
                    }
                        else if(key.split("|")[0] == "UserRole")
                        {  
                            console.log('Dentro UserRole: '+ObtainedMap[key]);
                            component.set("v.UserRole",ObtainedMap[key]);
                        } 
                            else if(key.split("|")[0] == "UserProfile")
                            {
                                console.log('Dentro UserProfile: '+ObtainedMap[key]);
                                
                                component.set("v.UserProfile",ObtainedMap[key]);
                            }
                                else if(key.split("|")[0] == "PartnerUrl")
                                {
                                    console.log('Dentro PartnerUrl: '+ObtainedMap[key]);
                                    
                                    component.set("v.PartnerUrl",ObtainedMap[key]);
                                }
                                    else if(key.split("|")[0] == "UserId")
                                    {
                                        console.log('Dentro UserId: '+ObtainedMap[key]);
                                        
                                        var UserType = component.get("v.UserRole");
                                        
                                        UserType = UserType.toLowerCase();
                                        
                                        if(UserType.includes("responsabile") == false && component.get("v.StdUsr")==false){
                                            console.log('type');
                                            component.set("v.CollaboratoreId",ObtainedMap[key]);
                                        }
                                        component.set("v.UserId",ObtainedMap[key]);
                                    }
                					else if(key.split("|")[0] == "UserName")
                                {
                                    console.log('Dentro UserName: '+ObtainedMap[key]);
                                    
                                    component.set("v.UserName",ObtainedMap[key]);
                                }
                
                console.log('test: '+component.get("v.UserRole"));
                
            }
            
            var UserProfile = component.get("v.UserProfile");
            var CampType = component.get("v.CampType");
            
            if(CampType == 'Marketing_campaign'){
                if(UserProfile == 'AAI - Vendite Avanzato' || UserProfile == 'AAI - Vendite Base'){
                    
                    component.set("v.IsPartnerUser",true);
                    console.log('IsPartnerUser'+component.get("v.IsPartnerUser"));
                    console.log('Profile'+component.get("v.UserProfile"));
                    
                }else{
                    
                    component.set("v.IsPartnerUser",false);
                    console.log('IsPartnerUser'+component.get("v.IsPartnerUser"));
                    console.log('Profile'+component.get("v.UserProfile"));
                }
            }else if (CampType == 'Agency_campaign' || CampType == 'Informative_Campaign'){
                
                component.set("v.IsPartnerUser", true);
            }
                       
            this.setFiltersToShow(component,event,helper);
            
            
        });
        $A.enqueueAction(retrPVal);        
    },
    
    setFiltersToShow: function(component, event, helper) {
        
        var UserProfile = component.get("v.UserProfile");
        var CampType = component.get("v.CampType");
        var IsPartnerUser = component.get("v.IsPartnerUser");
        
        
        if(IsPartnerUser == true){
            
            console.log('dentro if'+IsPartnerUser);
            component.set("v.ShowCollFilter",true);
            component.set("v.ShowDirFilter",false);
            
            
            
        }else{
            console.log('dentro else');
            component.set("v.ShowCollFilter",false);
            component.set("v.ShowDirFilter",true);
            
        }
    },
    
    startSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, 'slds-hide');
    },
    
    
    stopSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, 'slds-hide');
    },
    
    resetKPI: function (component, event, helper){
        
        component.set("v.ClientiInTarget",0);  
        component.set("v.ClientiLavorati",0);
        component.set("v.ClientiPrioritari",0);
        component.set("v.ClientiPrioritariLavorati",0);
        component.set("v.TrattativeCreate",0);
        component.set("v.TrattativeVinte",0);
        component.set("v.ClientiConEmailSMSInTarget",0);
        component.set("v.EmailSMSNonRecapitabili",0);
        component.set("v.ClientiConEmailInTarget",0);
        component.set("v.ClientiEmailApertaRichiestaContatto",0);
        component.set("v.ClientiConSMSInTarget",0);
        component.set("v.ClientiSMSApertoRichiestaContatto",0);
        component.set("v.ClientiConEmailSMSAperti",0);
        component.set("v.perClientiLavorati",0);
        component.set("v.perTrattativeVinteClientiTarget",0);
        component.set("v.perTrattativeCreateClientiLavorati",0);
        component.set("v.perTrattativeVinteClientiLavorati",0);
        component.set("v.perClientiPLavoratiClientiPrioritari",0);
        component.set("v.perTrattativeVinteClientiPrioritari",0);
        component.set("v.perEmailSMSNonRecapitabiliClientiEmailSMSTarget",0);
        component.set("v.perClientiPrioritari",0);
        component.set("v.perEmailApertaRichiestaricontatto",0);
        component.set("v.perClientiPrioritariconEmail",0);
        component.set("v.perSMSApertoRichiestaricontatto",0);
        component.set("v.perClientiPrioritariconSMS",0);
        component.set("v.TrattativeVinteClientiPrioritari",0);
        component.set("v.RevenueTrattativeVinte",0);
        component.set("v.TrattativeIncorso",0);
        component.set("v.RevenueTrattativeInCorso",0);
        component.set("v.ClientiPrioritariEmail",0);
        component.set("v.ClientiPrioritariSMS",0);
        component.set("v.EmailSMSrecapitati",0);
        helper.stopSpinner(component);
        
    },

    dynamicSort: function (property) {
    var sortOrder = 1;
    if(property[0] === "-") {
        sortOrder = -1;
        property = property.substr(1);
    }
    return function (a,b) {
        var result = (a[property] < b[property]) ? -1 : (a[property] > b[property]) ? 1 : 0;
        return result * sortOrder;
    }
}
    
})
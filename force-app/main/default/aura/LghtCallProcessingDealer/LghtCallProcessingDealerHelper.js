({
    init : function (component, helper){
        const action = component.get('c.initDealer');
        
		const params = component.get('v.urlParameter');
        let AgentCode = params.Agentcode;
        
		action.setParams({
			params:params
		});

		action.setCallback(this, (response)=>{
			const state = response.getState();
			console.log('state', state);

			component.set('v.spinner', false);
			switch(state){
				case 'SUCCESS':
					const result = response.getReturnValue();
					helper.normalizeSearch(result.caseList);
					component.set('v.listCase', result.caseList);
                    component.set('v.recordType', result.recordType);
                    component.set('v.visibilitiesCallback', (componentName, visibility)=>{
                        helper.setVisibilities(component, componentName, visibility)
                    });
                    helper.applyUrlParameter(component, helper);
					break;
				case 'ERROR':
                    
					break;
			}
		})

		$A.enqueueAction(action);
    },
    onFind : function (component, helper){
        const action = component.get('c.searchCaseByPartnerCode');
        //const params = component.get('v.urlParameter');

        
        let InputCode = component.find('InputCode').get('v.value');
        let recordtype = component.get('v.recordType');
        //let caseRecordType = component.get('v.urlParameter').RecordType;


        /**
         * firstNameSearch: component.find('InputFirstName').get('v.value'),
            lastNameSearch: component.find('InputLastName').get('v.value'),
            matricolaSearch: component.find('InputMatricola').get('v.value')
         */
        
        
    
		action.setParams({
            PartnerCode:InputCode,
            rt:recordtype
		});

		action.setCallback(this, (response)=>{
			const state = response.getState();
			console.log('state', state);

			component.set('v.spinner', false);
			switch(state){
				case 'SUCCESS':
					const result = response.getReturnValue();
					helper.normalizeSearch(result);
                    console.log(result);
					component.set('v.listCase', result);
                    component.set('v.visibilitiesCallback', (componentName, visibility)=>{
                        helper.setVisibilities(component, componentName, visibility)
                    });
					break;
				case 'ERROR':
					break;
			}
		})

		$A.enqueueAction(action);
    },
    redirectToGestore: function(component, event){
        const myEvent = $A.get("e.c:lghtRedirectNew");
        myEvent.setParams({
            action: 'detail-case',
            recordId: event.target.dataset.caseId
        });
        myEvent.fire(); 
    },
    getAccount : function(component, accountId){
    	const listAccount = component.get('v.listAccount');

    	const findAccount = listAccount.filter((data)=>{
    		return data.account.Id === accountId;
    	});

    	if(findAccount.length === 1){
    		return findAccount[0];
    	}

    	return null;
    },
    applyUrlParameter : function(component, helper){
       const urlParameter = component.get('v.urlParameter');
   
       const caseData = {
        Partner_Code__c: urlParameter.Agentcode       
       }

       console.log('caseData', caseData);
       component.set('v.caseData', caseData);

       
    
       //helper.searchAccount(component);
   },
    setVisibilities : function(component, componentName, visibility) {
       let actualVisibilities = component.get('v.visibilities');
       if(!actualVisibilities) actualVisibilities = {};
       
       actualVisibilities[componentName] = !!visibility;
       component.set('v.visibilities', actualVisibilities);
       
   },
  
    searchAccountAgent : function(component, helper){
       component.set('v.spinner', true);

       const action = component.get('c.searchAgent');
       const params = component.get('v.urlParameter');
       const accountData = component.get('v.accountData');
   
       const searchContext = {
           searchAgencyName	    : accountData.FirstName,
           searchAgencyLastname	: accountData.LastName,
           searchAgencyCode		: accountData.Agency_Code__c,
           searchAgentCommunityId	: accountData.Matricola__c    	
       };

       console.log('params', params);
       console.log('accountData', accountData);
       console.log('searchContext', searchContext);

       action.setParams({
           params,
           searchContext
       });

       action.setCallback(this, (response)=>{
           const state = response.getState();
           console.log('state', state);

           component.set('v.spinner', false);
           switch(state){
               case 'SUCCESS':
                   const result = response.getReturnValue();
                   console.log(result);
             
                    helper.normalizeSearch(result);

                   component.set('v.showNewCase', result.listResult.length === 0);    				
                   component.set('v.listCase', []);
                   var agentList = result.listResult;
                   if(agentList.length > 0){
                    agentList.forEach(function(item) {                   
                    item.Agenzia= result.AgentToAgencyMap[item.user.Id].Name;
                    item.AgenziaAttiva= result.AgentToAgencyMap[item.user.Id].Active__c;
                    item.AgenziaId= result.AgentToAgencyMap[item.user.Id].Id;
                   });                  
                   } 
                   component.set('v.listAgent', agentList );
                   break;
               case 'ERROR':
                   break;
           }
       })

       $A.enqueueAction(action);
   },
    initAgency : function (component, helper){
       const action = component.get('c.initAgency');
       const params = component.get('v.urlParameter');


       action.setParams({
           params
       });

       action.setCallback(this, (response)=>{
           const state = response.getState();
           console.log('state', state);

           component.set('v.spinner', false);
           switch(state){
               case 'SUCCESS':
                   const result = response.getReturnValue();
                   console.log('result', result);
                   helper.normalizeSearch(result);

                   component.set('v.recordType', result.recordType);
                   component.set('v.recordTypeCase', result.recordTypeCase);
                   component.set('v.listCategory', result.listCategory);
                   component.set('v.listSubCategory', result.listSubCategory);
           
                   component.set('v.showNewCase', result.listResult.length === 0);    				
                   component.set('v.listCase', []);
                   var agentList = result.listResult;
                   if(agentList.length > 0){
                    agentList.forEach(function(item) {                   
                    item.Agenzia= result.AgentToAgencyMap[item.user.Id].Name;
                    item.AgenziaAttiva= result.AgentToAgencyMap[item.user.Id].Active__c;
                    item.AgenziaId= result.AgentToAgencyMap[item.user.Id].Id;
                   });             
                   } 
                   component.set('v.listAgent', agentList );

                   helper.applyUrlParameter(component, helper);
           
           
                   break;
               case 'ERROR':
                   break;
           }
       })

       $A.enqueueAction(action);
           
       },    
    normalizeSearch: function(result){
       
        
           for(let caseIndex in result){
               const caseData = result[caseIndex];
               
               const createdDate = new Date(caseData.CreatedDate);

               let day = createdDate.getDate();
               if(day < 10) day = `0${day}`;

               let month = createdDate.getMonth() + 1;
               if(month < 10) month = `0${month}`;

               let year = createdDate.getFullYear();

               let hour = createdDate.getHours();
               if(hour < 10) hour = `0${hour}`;

               let minute = createdDate.getMinutes();
               if(minute < 10) minute = `0${minute}`;

               let second = createdDate.getSeconds();
               if(second < 10) second = `0${second}`;

               caseData.CreatedDateString = `${day}/${month}/${year} ${hour}:${minute}:${second}`;
           }
       
   },     
    getAccountAgency : function(component, accountId){
       const listAccount = component.get('v.listAgent');

       const findAccount = listAccount.filter((data)=>{
           return data.user.Id === accountId;
       });
       
       if(findAccount.length === 1){           
           return findAccount[0];
       }

       return null;
   },    
    createCase: function(component, helper){
       component.set('v.spinner', true);

       const action = component.get('c.createCase');
       const params = component.get('v.urlParameter');

       action.setParams({
           params
       });

       action.setCallback(this, (response)=>{
           const state = response.getState();
           console.log('state', state);

           component.set('v.spinner', false);
           switch(state){
               case 'SUCCESS':
                   const result = response.getReturnValue();
                   console.log(result);

                   helper.redirectToCase(component, result.caseData);
                   break;
               case 'ERROR':
                   break;
           }
       })

       $A.enqueueAction(action);
   },
    redirectToCase: function(component, caseData){
       const myEvent = $A.get("e.c:lghtRedirectNew");

       console.log("caseData", caseData);

       myEvent.setParams({
           action: 'detail-case',
           recordId: caseData.Id
       });
       
       myEvent.fire(); 
   },
   redirectToCaseNew: function(component, event, params){
       const myEvent = $A.get("e.c:lghtRedirectNew");

       const recordType = component.get('v.recordType');
       
       debugger;

       myEvent.setParams({
           action: 'new-case',
           recordTypeId: recordType.Id,
           params
       });
          
       myEvent.fire(); 
   }
})
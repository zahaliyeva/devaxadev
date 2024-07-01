({
    initGestori : function (component, helper){
        const action = component.get('c.initGestori');
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
					helper.normalizeSearch(result);
					component.set('v.recordType', result.recordType);
					component.set('v.recordTypeCase', result.recordTypeCase);
					component.set('v.listCategory', result.listCategory);
					component.set('v.listSubCategory', result.listSubCategory);
					component.set('v.showNewCase', result.listResult.length === 0);
					component.set('v.listAccount', result.listResult);
					component.set('v.listCase', []);
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
    onFindGestori : function (component, helper){
        const action = component.get('c.searchGestori');
        //const params = component.get('v.urlParameter');

        let firstNameSearch = component.find('InputFirstName').get('v.value');
        let lastNameSearch = component.find('InputLastName').get('v.value');
        let matricolaSearch = component.find('InputMatricola').get('v.value');
        let phoneSearch = component.find('InputPhone').get('v.value');
        let caseRecordType = component.get('v.urlParameter').RecordType;


        /**
         * firstNameSearch: component.find('InputFirstName').get('v.value'),
            lastNameSearch: component.find('InputLastName').get('v.value'),
            matricolaSearch: component.find('InputMatricola').get('v.value')
         */
        
        const params = {
            'firstNameSearch': firstNameSearch,
            'lastNameSearch': lastNameSearch,
            'matricolaSearch': matricolaSearch,
            'phoneSearch': phoneSearch,
            'RecordType': caseRecordType
        }
    
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
					helper.normalizeSearch(result);
					component.set('v.recordType', result.recordType);
					component.set('v.recordTypeCase', result.recordTypeCase);
					component.set('v.listCategory', result.listCategory);
					component.set('v.listSubCategory', result.listSubCategory);
					component.set('v.showNewCase', result.listResult.length === 0);
					component.set('v.listAccount', result.listResult);
					component.set('v.listCase', []);
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
            action: 'detail-gestore',
            recordId: event.target.dataset.accountId
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
   
       const accountData = {
           FirstName: urlParameter.Agentfirstn,
           LastName: urlParameter.Agentlastn,
           Matricola__c: urlParameter.Agentcode,
           Phone__c: urlParameter.Phone	 	          
       }

       console.log('accountData', accountData);
       component.set('v.accountData', accountData);

       component.find('InputFirstName').set('v.value', accountData.FirstName);
       component.find('InputLastName').set('v.value', accountData.LastName);
       component.find('InputMatricola').set('v.value', accountData.Matricola__c);   
       component.find('InputPhone').set('v.value',  urlParameter.Phone);      
    
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
       for(let index in result.listResult){
           const context = result.listResult[index];
        
           for(let caseIndex in context.cases){
               const caseData = context.cases[caseIndex];
               
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
   redirectToCaseNew: function(component, params){
       const myEvent = $A.get("e.c:lghtRedirectNew");

       const recordType = component.get('v.recordTypeCase');
       const accountData = component.get('v.accountData');

       debugger;

       myEvent.setParams({
           action: 'new-case',
           recordTypeId: recordType.Id,
           params
       });
          
       myEvent.fire(); 
   }
})
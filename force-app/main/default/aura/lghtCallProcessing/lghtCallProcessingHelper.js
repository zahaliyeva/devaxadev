({
	applyUrlParameter : function(component, helper){
		const urlParameter = component.get('v.urlParameter');       
      
            const accountData = {
			FirstName: urlParameter.Custfirstn,
			LastName: urlParameter.Custlastn,
			Fiscal_ID__c: urlParameter.Fiscalcode,
			InsurancePolicy: urlParameter.PolicyId,
            Partita_IVA__c: urlParameter.Partitaiva,
		}

		console.log('accountData', accountData);
		component.set('v.accountData', accountData);

		component.find('InputFirstName').set('v.value', accountData.FirstName);
		component.find('InputLastName').set('v.value', accountData.LastName);
		component.find('InputFiscalId').set('v.value', accountData.Fiscal_ID__c);
        component.find('InputPiva').set('v.value', accountData.Partita_IVA__c);

      
		
		//helper.searchAccount(component);
	},
    setVisibilities : function(component, componentName, visibility) {
		let actualVisibilities = component.get('v.visibilities');
		if(!actualVisibilities) actualVisibilities = {};
		
		actualVisibilities[componentName] = !!visibility;
		component.set('v.visibilities', actualVisibilities);
    	
    },
    searchAccount : function(component, helper){
    	component.set('v.spinner', true);

    	const action = component.get('c.search');
    	const params = component.get('v.urlParameter');
    	const accountData = component.get('v.accountData');
    
    	const searchContext = {
    		searchFirstName			: accountData.FirstName,
    		searchLastName			: accountData.LastName,
    		searchDateOfBirth		: accountData.PersonBirthdate,
    		searchFiscalId			: accountData.Fiscal_ID__c,
    		searchPartitaIVA		: accountData.Partita_IVA__c,
    		policyNumber			: accountData.InsurancePolicy
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
    				component.set('v.listAccount', result.listResult);
    				component.set('v.listCase', []);
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
            const account = context.account;

            account.origin = ((account.RecordType.Name === 'Individual' || account.RecordType.Name === 'Corporate') && account.TECH_Company__c !== 'AMF') ? $A.get("{!$Label.c.VFP06_AMPSCustomer}") : ''
            debugger;
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

		debugger;

		myEvent.setParams({
            action: 'new-case',
			recordTypeId: recordType.Id,
			params
		});
	   	
	    myEvent.fire(); 
    }
})
({
	onInit : function(component, event, helper){
       
		const action = component.get('c.init');
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

					helper.applyUrlParameter(component, helper);
					break;
				case 'ERROR':
					break;
			}
		})

		$A.enqueueAction(action);
        
      
        
		component.set('v.visibilitiesCallback', (componentName, visibility)=>{
			helper.setVisibilities(component, componentName, visibility)
		});


	},
	onChange : function(component, event, helper) {
		let accountData = component.get('v.accountData');
		if(!accountData) accountData = {};

		let name, value;

		if(!event.target){
			const source = event.getSource();
			console.log('source', source)

			name = source.get('v.fieldName');
			value = source.get('v.value');

		}else{
			name = event.target.name;
			value = event.target.value;
		}

		accountData[name] = value;

		component.set('v.accountData', accountData);
	},
	onFind : function(component, event, helper){
		event.preventDefault();
        const params = component.get('v.urlParameter');
 
    		helper.searchAccount(component, helper);
         
	},
	onSelectCustomer: function(component, event, helper){
		const accountId = event.target.dataset.accountId;
		const context = helper.getAccount(component, accountId);

		if(context){
			component.set('v.listCase', context.cases);
		}
	},
    
	onViewClaims: function(component, event, helper){
		const accountId = event.target.dataset.accountId;
		const context = helper.getAccount(component, accountId);

		if(context){
			component.set('v.selectAccount', context.account);
			helper.setVisibilities(component, 'GetAllClaims', true);
		}
	},
	onNewCase: function(component, event, helper){
		helper.createCase(component, helper);
	},
	onGoToCase: function(component, event, helper){
		const caseId = event.target.dataset.caseId;
		const caseNumber = event.target.dataset.caseId;

		helper.redirectToCase(component, {
			Id: caseId,
			CaseNumber: caseNumber
		})
	},
	onChangeCategory: function(component, event, helper){
		const name = event.target.name;
		const value = event.target.value;

		let categoryContext = component.get('v.categoryContext');
		if(!categoryContext) categoryContext = {};

		categoryContext[name] = value;

		component.set('v.categoryContext', categoryContext);

	},
	onShowCategoryForm: function(component, event, helper){
		component.set('v.showCategoryForm', true);
	},
	onCloseCategoryForm: function(component, event, helper){
		component.set('v.showCategoryForm', false);
	},
	onRedirectNewCase: function(component, event, helper){
		event.preventDefault();

		const accountId = event.target.dataset.accountId;
		
		const sendParams = {
			Origin: 'Phone',
			Complainant__c: urlParameter.Caller,
			LOB__c: urlParameter.LOB,
			Status: "Preso in carico",
			AccountId: accountId,
			Category__c:urlParameter.Category,
			SubCategory__c:urlParameter.Subcategory,
			Phone_Call_Ids__c:urlParameter.PhonecallID+"_"+urlParameter.CallDateTime+'_'+urlParameter.PhoneCallIDB
		}

		helper.redirectToCaseNew(component, sendParams)
	}
})
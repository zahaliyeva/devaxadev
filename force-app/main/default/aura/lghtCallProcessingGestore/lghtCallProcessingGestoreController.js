({
	onInit : function(component, event, helper){
        helper.initGestori(component, helper);        
	},
	onFind : function(component, event, helper){
		event.preventDefault();
        helper.onFindGestori(component, helper);
	},	
	onViewGestore: function(component, event, helper){
		helper.redirectToGestore(component, event, helper);
	},
	onSelectCustomer: function(component, event, helper){
		const accountId = event.target.dataset.accountId;
		const context = helper.getAccount(component, accountId);

		if(context){
			component.set('v.listCase', context.cases);
		}
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
			AgentName__c: accountId,
			Category__c:urlParameter.Category,
			SubCategory__c:urlParameter.Subcategory,
			Phone_Call_Ids__c:urlParameter.PhonecallID+"_"+urlParameter.CallDateTime+'_'+urlParameter.PhoneCallIDB
		}

		helper.redirectToCaseNew(component, sendParams)
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
    onSelectCustomerAgency: function(component, event, helper){
		const accountId = event.target.dataset.accountId;
		const context = helper.getAccountAgency(component, accountId);
        console.log('* '+ component.get('v.listCase'));

		if(context){
			component.set('v.listCase', context.cases);
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
	}
})
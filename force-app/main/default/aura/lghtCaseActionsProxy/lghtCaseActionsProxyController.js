({
	doInit: function(component, event, helper){
		component.set('v.visibilitiesCallback', (componentName, visibily)=>{
			if(componentName){
				let actualVisibilities = component.get('v.visibilities');
				if(!actualVisibilities) actualVisibilities = {};
				
				actualVisibilities[componentName] = !!visibily;
				component.set('v.visibilities', actualVisibilities);
			}
		});
	},
	handlerInit: function(component, event){
		console.log('handlerInit');

		const caseData = event.getParam('caseData');
		const ownerIsQueue = event.getParam('ownerIsQueue');
		
		if(caseData) component.set('v.case', caseData);

		component.set('v.ownerIsQueue', ownerIsQueue);

	},
	handleCloseTab: function(component, event) {
		console.log('handleCloseTab');
		const workspaceAPI = component.find("workspace");
		
		let focusedTabId;
		let closeCallback = event.getParam('callback');

		workspaceAPI.getFocusedTabInfo().then((response)=>{
			focusedTabId = response.tabId;

			if(!closeCallback) return Promise.resolve();

			return closeCallback();
		}).then(()=>{
			setTimeout(()=>{
				workspaceAPI.closeTab({tabId: focusedTabId});
			}, 500)
		}).catch(function(error) {
			console.log(error);
		});
	},
	handlerRefresh: function(component, event){
		console.log('handlerRefresh');
		$A.get('e.force:refreshView').fire();
	},
	handlerVisibilies: function(component, event, helper){
		console.log('handlerVisibilies');

		const componentName = event.getParam('componentName');
		const componentVisibility = event.getParam('visibily');

		if(componentName){
			let actualVisibilities = component.get('v.visibilities');
			if(!actualVisibilities) actualVisibilities = {};
			
			actualVisibilities[componentName] = !!componentVisibility;
			component.set('v.visibilities', actualVisibilities);
		}
	},
	handlerQuickAction: function(component, event){
		console.log('handlerQuickAction');

		const actionName = event.getParam('actionName');
		const actionAPI = component.find("quickActionAPI");
		const params = {actionName};

		actionAPI.selectAction(params).then(function(result) {
			// Action selected; show data and set field values
			console.log(result);
		}).catch(function(e) {
			if (e.errors) {
				// If the specified action isn't found on the page, 
				// show an error message in the my component 
				console.log(e.errors);
			}
		});
	},
	handlerSetActionFieldValues: function(component, event){
		console.log('handlerSetActionFieldValues');

		const actionName = event.getParam('actionName');
		const actionCallback = event.getParam('actionCallback');
		const actionAPI = component.find("quickActionAPI");
		const params = {actionName};

		actionAPI.setActionFieldValues(params).then((result)=>{
            if(actionCallback) actionCallback(result);
        }).catch((e) => {
        	console.log(e);
		})

	},
	onTest: function(component, event){
		console.log('onSelect')
		const actionAPI = component.find("quickActionAPI");
		const fields = {
			FromToAddress: {value:'j.sanchez@reply.it'}
		};

        const args = {
        	actionName: "Case.LghtSendEmail", 
        	targetFields: fields
        };

        actionAPI.getAvailableActionFields({actionName:'Case.LghtSendEmail'}).then((result)=>{
            console.log('send', result);
            return actionAPI.setActionFieldValues(args);
        }).then((result)=>{
            console.log('send', result);
        }).catch((e) => {
        	console.log(e);
		})
	}
})
({
	doInit : function(component, event, helper) {
		let postmessage = component.get('v.postMessage');
		let params = component.get('v.params');

		postmessage('javascriptIntegration', (data)=>{
			console.log('controller', data);
			component.set('v.message', data.txt);
		})
		window.parent.postMessage({action: 'HOOK_REQUEST', "name": 'javascriptIntegration', "id": params.id}, '*');

	},
	onClick: function(component, event, helper) {
		window.parent.postMessage({action: 'DEBUG',txt: 'Hello by Salesforce :) ' + new Date().getTime()}, '*');
	}
})
({
	doInit : function(component, event, helper) {
		console.log('doInit');

		let action = component.get("c.getAssistanceUser");
		//action.setParams();
		action.setCallback(this, function(response){
			console.log(response.getReturnValue());
			let result = response.getReturnValue();
			component.set('v.ProfileName',result.currentUser.Profile.Name);
			component.set('v.UserMainNode',result.currentUser.Main_Node__c);
			component.set('v.show','true');
		});
		$A.enqueueAction(action);
	}
})
({
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
	handlerCancel: function(component, event){
		const dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();

	},
	handlerRefresh: function(component, event){
		console.log('handlerRefresh');
		$A.get('e.force:refreshView').fire();
	}
})
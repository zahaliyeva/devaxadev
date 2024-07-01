({
	redirect: function(cmp, actionName, staticRes, path) {
        const action = cmp.get(actionName);
        action.setCallback(this, $A.getCallback(function (response){
			const state = response.getState();
            if(state == 'SUCCESS'){
				const res = response.getReturnValue();
                if (path && window.location.href.indexOf(path) !== -1) {
                    const idvalue = window.location.href.substring(window.location.href.indexOf(path) + path.length, 
                                                                   window.location.href.indexOf(path) + path.length + 18);
                	window.location.href = res + '/' + idvalue;
                } else {
                    
                }
            } else if(state == 'ERROR'){
               	window.location.href = staticRes;
                if (path && window.location.href.indexOf(path) !== -1) {
                    const idvalue = window.location.href.substring(window.location.href.indexOf(path) + path.length, 
                                                                   window.location.href.indexOf(path) + path.length + 18);
                	window.location.href = staticRes + '/' + idvalue;
                } else {
                    
                }
            }
		}));
        $A.enqueueAction(action);
    },
    redirectNotFound: function(){
        const currentPath = window.location.href;

        const notAvailablePaths = [
            '/crm/s/account/',
            '/crm/s/contact/',
            '/crm/s/lead/',
            '/crm/s/campaign/',
            '/crm/s/feed/',
            '/crm/s/profile/',
            '/crm/s/insurancepolicy/',
        ];
        
        let contain = false;
        for(let index in notAvailablePaths){
            const pathCheck = notAvailablePaths[index];
        
            if(currentPath.includes(pathCheck)){
                contain = true;
                break;
            }
        }
        
        if(contain) window.location.href = `/crm/s/mobility-not-found`;
        
        return contain;
    }
})
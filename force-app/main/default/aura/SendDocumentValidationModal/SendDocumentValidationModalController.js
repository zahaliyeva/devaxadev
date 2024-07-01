({
    onClose : function(component, event, helper) {
    	const visibilities = component.get('v.visibilities');

    	if(visibilities) visibilities('SendDocumentValidationComponent', false);
    }
})
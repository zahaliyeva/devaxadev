({
    onModifica: function(component){
        let recordId = component.get("v.wrapper.account.Id");
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'edit',
                recordId: recordId
                
            }
        };
        navService.navigate(pageReference);
    },
    
    manageCompanyNameClass: function(component){
        let cmpTarget = component.get("v.wrapper.companyName");
        let divToAddClass = component.find('companyNameClass');
        if(typeof cmpTarget !== 'undefined' && typeof divToAddClass !== 'undefined'){
            if(cmpTarget == 'AXA Assicurazioni'){
                $A.util.addClass(divToAddClass , 'badge-axa-blue');
            } else if(cmpTarget === 'AXA MPS'){
                $A.util.addClass(divToAddClass , 'badge-axa-red');
            } else if(cmpTarget === 'Quadra'){
                $A.util.addClass(divToAddClass , 'badge-axa-blue');
            } else if(cmpTarget === 'ING'){
                $A.util.addClass(divToAddClass , 'badge-axa-orange');
            } else if(cmpTarget === 'RCI'){
                $A.util.addClass(divToAddClass , 'badge-axa-orange-rci');
            } else if(cmpTarget === 'AMF'){
                $A.util.addClass(divToAddClass , 'badge-axa-red');
            } else if(cmpTarget === 'AAF'){
                $A.util.addClass(divToAddClass , 'badge-axa-blue');
            }         
        }
    }
})
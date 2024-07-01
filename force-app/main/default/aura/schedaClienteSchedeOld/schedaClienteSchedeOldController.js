({
    onTabClick : function(component, event, helper) {
        console.log(event.currentTarget.dataset.id);
        let dataId = event.currentTarget.dataset.id;
        let index = dataId.split('-')[1]; 
        let selectedTab = component.find(event.currentTarget.dataset.id);
        for (let i = 1; i <= 5; i++) {
            if(i == index){ 
                $A.util.addClass(selectedTab, 'slds-is-active'); 
                $A.util.addClass(component.find('tabcontent-'+i), 'slds-show');
                $A.util.removeClass(component.find('tabcontent-'+i), 'slds-hide');
            } else {
                $A.util.removeClass(component.find('tab-' + i), 'slds-is-active');
                $A.util.removeClass(component.find('tabcontent-'+i), 'slds-show');
                $A.util.addClass(component.find('tabcontent-'+i), 'slds-hide');
            }
        } 
    }
})
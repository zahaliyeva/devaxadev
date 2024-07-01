({
    doInit: function (component, event, helper) {
        console.log('DO INIT 1');
        let numberOfRows;
        let recordId;
        let pageReference = component.get("v.pageReference");
        if(pageReference){
            numberOfRows = pageReference.state.c__numberOfRows;
            recordId = pageReference.state.c__recordId;
            component.set("v.hasIconSVG", pageReference.state.c__hasIconSVG);
        } else {
            numberOfRows = component.get('v.numberOfRows');
            recordId = component.get('v.recordId');
        }
        if (numberOfRows === 0) {
            component.set('v.fullListView', true);
        }  
        component.set("v.numberOfRows", numberOfRows);;
        component.set("v.recordId", recordId);
        var listOfIds = [];
        listOfIds.push(recordId);
        helper.getRecords(component, listOfIds, numberOfRows);
    },
    onFilterRecords: function(component, event, helper){
        helper.getRecords(component, [component.get('v.recordId')], component.get('v.numberOfRows'), component.get('v.filtroTipologia'));
    },
    navigateToSObject: function (component, event, helper) {
        if('Visualizza documento' == event.target.title){ 
            let id = event.target.id.split('=')[1];
            var workspaceAPI = component.find("workspace");
            workspaceAPI.openTab({
                url: '/apex/VFP34_GetFilenetDocument?id=' + id,
                focus: true
            }).catch((error)=>{
                open('/apex/VFP34_GetFilenetDocument?id=' + id, "_blank");
            });  
        } else {
            var recordId = event.target.id;
            if(recordId){
                var navService = component.find("navService");
                var pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: recordId,
                        "actionName": "view"
                    }
                };
                navService.navigate(pageReference);
            }
            
        }
    },
    navigateToFullList: function (component, event, helper) {
        //non serve
    },
    backNavigation: function (component, event, helper) {
        window.history.back();
    },
    lockMobileIteration: function (component, event, helper) {
        component.set('v.lockMobileIteration', !component.get('v.lockMobileIteration'));
    },
    myRender: function (component, event, helper) {
        if (!component.get('v.loading') && !component.get('v.flagRender') && component.get('v.lockMobileIteration') && component.get('v.platformSource') === 'Theme4t'
            && component.get('v.listOfSObjects') != null && component.get('v.listOfSObjects').length) {
            // console.log(component.getConcreteComponent().getElements());

            for (var j = 0; j < component.getConcreteComponent().getElements().length; j++) {
                if(component.getConcreteComponent().getElements()[j].className.includes('mobile')){
                    var indexHTMLdom = j;
                }
            }

            var totalHeight = 0;
            if (component.getConcreteComponent().getElements()[indexHTMLdom].children.namedItem('bottom-link') != null) {
                totalHeight = component.getConcreteComponent().getElements()[indexHTMLdom].children.namedItem('bottom-link').offsetHeight;
            }
            var itemsToShow = 0;
            var liElementHeight;

            for (var i = 0; i < component.get('v.listOfSObjects').length && i < component.get('v.limitMobileIteration'); i++) {
                liElementHeight = component.getConcreteComponent().getElements()[indexHTMLdom].children.namedItem('ul-list').children.item(i).offsetHeight;
                totalHeight += liElementHeight;
                // console.log('List n. ' + (i + 1) + ' ' + liElementHeight);
                // console.log('Total Height: ' + totalHeight);
                if (totalHeight < component.get('v.componentHeight') - 10) { // the -10 (pixels) assures to stay within the total height of the component
                    itemsToShow++;
                } else {
                    i = component.get('v.listOfSObjects').length;
                }
            }
            component.set('v.limitMobileIteration', itemsToShow);
            component.set('v.flagRender', true);
        }
    }
})
;
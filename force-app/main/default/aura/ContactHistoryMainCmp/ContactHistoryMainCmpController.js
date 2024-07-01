({
    doInit: function (component, event, helper) {
        console.log('DO INIT 1');
        var numberOfRows = component.get('v.numberOfRows');
        if (numberOfRows === 0) {
            component.set('v.fullListView', true);
        }
        var recordId = component.get('v.recordId');
        var listOfIds = [];
        listOfIds.push(recordId);

        var action = component.get('c.getHistoryItemWrappers');

        action.setParams({
            ids: listOfIds,
            limitResult: '' + numberOfRows
        });

        action.setCallback(this, function (response) {
            component.set('v.loading', true);
            var state = response.getState();
            if (state === 'SUCCESS') {
                if (response.getReturnValue().isSuccess) {
                    component.set('v.listOfSObjects', response.getReturnValue().values.ContactHistoryList);
                    component.set('v.sizeFullListOfSObjects', response.getReturnValue().values.ContactHistoryFullListSize);
                    component.set('v.recordFieldName', response.getReturnValue().values.RecordFieldName);
                    component.set('v.platformSource', response.getReturnValue().values.PlatformSource);
                    //console.table(component.get('v.listOfSObjects')); // console.table NON FUNZIONA IN WINDOWS EXPLORER
                } else {
                    //gestire errore
                    component.set('v.errorMessageResult', response.getReturnValue().message);
                }
                component.set('v.loading', false);
            }
            else if (state === 'INCOMPLETE') {
                console.log('Incomplete state');
                component.set('v.loading', false);
            }
            else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' + errors[0].message);
                    }
                } else {
                    console.log('Unkown error');
                }
                component.set('v.loading', false);
            }
        });
        $A.enqueueAction(action);
    },
    navigateToSObject: function (component, event, helper) {
        var recordId = event.target.id;

        if (recordId !== null && recordId !== '') {
            var pathName = window.location.pathname;
            var myURL = "https://" + window.location.hostname;

            var agencyIndex = pathName.indexOf("agenzie");
            if (agencyIndex !== -1) {
                myURL = myURL + "/agenzie";
            }

            var endURL = '/' + recordId;
            myURL = myURL + endURL;
            //console.log("********" + myURL);
            helper.navigateToUrl(myURL, recordId);
        }
    },
    navigateToFullList: function (component, event, helper) {
        var pathName = window.location.pathname;
        var myURL = "https://" + window.location.hostname;
        var endURL;
        var agencyIndex = pathName.indexOf("agenzie");
        if (agencyIndex !== -1) {
            myURL = myURL + "/agenzie";
        }
        var recordId = 'id=' + component.get('v.recordId');

        var numberOfRows = 'numberOfRows=' + '0';

        if (component.get('v.recordId').startsWith('001') || component.get('v.recordId').startsWith('003')) {
            endURL = '/apex/ContactHistoryAccount?' + recordId + '&' + numberOfRows;
        } else if (component.get('v.recordId').startsWith('00Q')) {
            endURL = '/apex/ContactHistoryLead?' + recordId + '&' + numberOfRows;
        }

        myURL = myURL + endURL;
        // console.log("********" + myURL);
        helper.navigateToUrl(myURL);

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
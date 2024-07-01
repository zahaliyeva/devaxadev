({
    doInit: function (component, event, helper) {

        var numberOfRows = component.get('v.numberOfRows');
        var recordId = component.get('v.recordId');
        var listOfIds = [];
        listOfIds.push(recordId);

        var action = component.get('c.getHistoryItemWrappers');

        action.setParams({
            ids: listOfIds,
            limitResult: '' + component.get('v.numberOfRows')
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.listOfSObjects', response.getReturnValue());
                console.table(component.get('v.listOfSObjects'));
            }
            else if (state === 'INCOMPLETE') {
                console.log('Incomplete state')
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
            }
        });
        $A.enqueueAction(action);
    },
    navigateToSObject: function (component, event, helper) {
        var recordId = event.target.id;
        var pathName = window.location.pathname;
        var myURL = "https://" + window.location.hostname;

        var agencyIndex = pathName.indexOf("agenzie");
        if (agencyIndex !== -1) {
            myURL = myURL + "/agenzie";
        }

        var endURL = '/' + recordId;
        myURL = myURL + endURL;
        console.log("********" + myURL);

        helper.navigateToUrl(myURL, endURL);

    },
    navigateToFullList: function (component, event, helper) {
        var pathName = window.location.pathname;
        var myURL = "https://" + window.location.hostname;
        var agencyIndex = pathName.indexOf("agenzie");
        if (agencyIndex !== -1) {
            myURL = myURL + "/agenzie";
        }
        var recordId = 'id=' + component.get('v.recordId');
        var numberOfRows = 'numberOfRows=' + '0';
        var endURL = '/apex/ContactHistoryAccount?' + recordId + '&' + numberOfRows;

        myURL = myURL + endURL;
        console.log("********" + myURL);

        helper.navigateToUrl(myURL, endURL);


    }
});
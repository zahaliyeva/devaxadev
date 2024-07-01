({
    navigateToUrl: function (myURL, recordId) {
        //checking if request come from mobile app
        if ((typeof sforce.one !== 'undefined') && sforce && (sforce.one !== null)) {

            //FOZDEN 17/07/2019: comunicazioni massive - start
            var re15 = new RegExp("^[a-zA-Z0-9]{15}$");
            var re18 = new RegExp("^[a-zA-Z0-9]{18}$");

            var recordIdCheck = re15.test(recordId) || re18.test(recordId);

            if (recordId != null && recordIdCheck) { //FOZDEN 17/07/2019: comunicazioni massive - end
                sforce.one.navigateToSObject(recordId);
            } else {
                sforce.one.navigateToURL(myURL);
            }
        }
        else { 
            // request come from Desktop App
            window.open(myURL);
        }
    },
    getRecords: function(component, listOfIds, numberOfRows, filtroTipologia){
        component.set('v.loading', true);
        var action = component.get('c.getHistoryItemWrappers');

        action.setParams({
            ids: listOfIds,
            limitResult: '' + numberOfRows,
            filtroTipologia: filtroTipologia,
        });

        action.setCallback(this, function (response) {
            component.set('v.loading', false);
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
                    component.getEvent("StoricoContattiError").fire();
                }
                if(!filtroTipologia && component.get('v.listOfSObjects').length == 0){
                    component.getEvent("StoricoContattiError").fire();
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
    }
});
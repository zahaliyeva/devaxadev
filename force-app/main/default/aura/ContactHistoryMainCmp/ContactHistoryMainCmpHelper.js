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
        else { // request come from Desktop App
            window.open(myURL);
        }
    }
});
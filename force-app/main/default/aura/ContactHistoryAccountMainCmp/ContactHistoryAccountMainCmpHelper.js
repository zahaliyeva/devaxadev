({
    navigateToUrl: function (myURL, endURL) {
		//checking if request come from mobile app
        if ((typeof sforce.one !== 'undefined') && (sforce.one !== null)) {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": endURL
            });
            urlEvent.fire();
        }
        else { // request come from Desktop App
            console.log('This');
            window.open(myURL);
        }
    }
});
({
    showToastStandard : function(title,type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": msg,
            'mode': 'dismissible'
        });
        toastEvent.fire();
    },
})
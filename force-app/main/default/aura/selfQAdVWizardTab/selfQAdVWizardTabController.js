({
    Init : function(cmp, event, helper) {

        let workspaceAPI = cmp.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response){}).then(function(subtabId){
            //let focusedTabId = response.tabId;
            workspaceAPI
                .setTabLabel({
                    tabId: subtabId,
                    label: "QAdV Wizard"
                })
                .then(function (response) {
                    workspaceAPI.setTabIcon({
                        icon: "standard:apps",
                    });
                })
        });

        var myPageRef = cmp.get("v.pageReference");
        var recordId = myPageRef.state.c__recordId;
        var caseData = myPageRef.state.c__caseData;
        var caseRecordTypeId = myPageRef.state.c__caseRecordTypeId;
        cmp.set("v.recordId", recordId);
        cmp.set("v.caseData", caseData);
        cmp.set("v.caseRecordTypeId", caseRecordTypeId);
    },

    closeTab: function(cmp,event,helpet){

        var workspaceAPI = cmp.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },
})
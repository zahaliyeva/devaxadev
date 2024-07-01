({
  doInit: function(component, event, helper) {
    const action = component.get("c.getToAddress");
    action.setParams({ "caseId" : component.get("v.recordId") });
    action.setCallback(this, function(response) {
      const state = response.getState();
      if (state === "SUCCESS") {
        const result = response.getReturnValue();
        if (component.get("v.toAddresses") !== null && component.get("v.toAddresses") !== '') {
          component.set("v.toAddresses", component.get("v.toAddresses") + ',' + result);
        } else {
          component.set("v.toAddresses", result);
        }
      } else if (state === "ERROR") {
        const errors = response.getError();
        if (errors) {

        }
      }
    });
    $A.enqueueAction(action);
  }
});
({
  doInit: function (component, event, helper) {
    helper.getCaseValues(component, event, helper); //DARIO

    var action = component.get("c.showModalOnRitornoHD1");

    var params = { caseId: component.get("v.caseId") };
    action.setParams(params);

    action.setCallback(this, function (response) {
      var result = response.getReturnValue();
      console.log(result);
      if (!result) {
        var a = component.get("c.saveQueue");
        component.set("v.showModal", false);
        $A.enqueueAction(a);
      }
      else{
        component.set("v.showModal", true);
      }
    });
    $A.enqueueAction(action);
  },

  closeModal: function (component, event, helper) {
    let visibilities = component.get("v.visibilities");
    if (visibilities) {
      visibilities("NewCommentAndAttachmentLightning", false);
    }
    // when a component is dynamically created in lightning, we use destroy() method to destroy it.
    component.destroy();
  },

  saveQueue: function (component, event, helper) {
    if (
      component.get("v.cmt") == null ||
      component.get("v.cmt") == undefined ||
      component.get("v.cmt") == ""
    ) {
      helper.showToast(
        component,
        event,
        helper,
        "error",
        "Attenzione ! Inserire un commento prima di inoltrare il case."
      );
      return;
    } else if(component.get("v.showModal") && (component.get("v.tagRichiesta") == null ||  component.get("v.tagRichiesta") == "")){
      helper.showToast(
        component,
        event,
        helper,
        "error",
        "Attenzione ! Inserire il tag richiesta prima di inoltrare il case."
      );
      return;
    } else if(component.get("v.showModal") && !component.get("v.tagRNeedSilva").includes(component.get("v.tagRichiesta")) && (component.get("v.tipologiaTicketSilva") == null && component.get("v.nomeApplicazioneSilva") == null)){
      helper.showToast(
        component,
        event,
        helper,
        "error",
        "Attenzione ! Compilare i campi Nome Applicazione e Tipologia Ticket Silva attraverso il pulsante Compila Ticket Silva."
      );
      return;
    } 
	if(component.get("v.showModal"))
    	helper.startSpinnerModal(component);
    else
        helper.startSpinner(component);
    var attachmentList = component.get("v.attachmentList");
    //DARIO
    var action2 = component.get("c.UpdateTagRichiesta");
    var params2 = {
      CaseId: component.get("v.caseId"),
      selectedValue: component.get("v.tagRichiesta")
    }
    action2.setParams(params2);
    //DARIO
    $A.enqueueAction(action2);

    var action = component.get("c.NewsaveCommentAttachment");
    var params = {
      cCase: component.get("v.caseId"),
      cmt: component.get("v.cmt"),
      rT: component.get("v.rT"),
      numberOfAttachment: attachmentList.length,
      attachmentList: component.get("v.attachmentList"),
      OrgUrl: component.get("v.OrgUrl"),
      Label: component.get("v.Label"),
      profileName: component.get("v.profileName"),
      userRole: component.get("v.userRole"),
      defectCheckbox: component.get("v.defect_MdC"),
      motivoTrasferimento: component.get("v.motivoTrasferimento"),
      selectedValue: component.get("v.selectedValue"),
      selectedLabel: component.get("v.selectedLabel"),
      OwnerId: component.get("v.sendToOwenerId"),
    };

    action.setParams(params);
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log("state --> " + state);

      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("Success state");
        //console.log('Data:' + JSON.stringify(response.getReturnValue()));
        var result = response.getReturnValue();

        if (result != "OK") {
          console.log("output ==> " + result);
          helper.stopSpinner(component);
            helper.stopSpinnerModal(component);
          component.set("v.isOpen", true);
          component.set("v.isOpenModal", true);
          component.set("v.MandatoryInputsMissing", true);
          component.set(
            "v.error",
            "Attenzione, non è stato possibile procedere con l'operazione richiesta. Riprova più tardi, se il problema persiste contattaci telefonicamente"
          );
        } else {
          location.reload();
          //window.location.href =  '/lightning/r/Case/'+component.get("v.CaseId")+'/view';
        }
      } else if (state === "INCOMPLETE") {
        helper.stopSpinner(component);
        helper.stopSpinnerModal(component);
        component.set("v.isOpen", true);
        component.set("v.isOpenModal", true);
        if (component.get("v.jsDebug")) console.log("Incomplete state");
      } else if (state === "ERROR") {
        helper.stopSpinner(component);
            helper.stopSpinnerModal(component);
        component.set("v.isOpen", true);
        component.set("v.isOpenModal", true);
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            if (component.get("v.jsDebug"))
              console.log("Error message: " + errors[0].message);
          }
        } else {
          if (component.get("v.jsDebug")) console.log("Unknown error");
        }
      }
      helper.stopSpinner(component);
            helper.stopSpinnerModal(component);
      let visibilities = component.get("v.visibilities");
        if (visibilities) {
        visibilities("NewCommentAndAttachmentLightning", false);
        }
    });
    $A.enqueueAction(action);
  },
});
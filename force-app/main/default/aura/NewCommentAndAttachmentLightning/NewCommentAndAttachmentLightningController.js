({
    doInit: function(component, event, helper) { 
        helper.checkError(component);
        helper.checkshowSupportHD1(component);
        helper.checkProfileHD2(component);
        helper.getOrgURL(component);
        helper.checkCaringAngel(component, event, helper); //Giorgio Bonifazi 
       	helper.getPicklist(component, event, helper);
        
        //VIZZINI_D 25/06/2019: NMA - Lob Modulo di Calcolo
        helper.checkProfileHD2_RGI(component);
        helper.checkProfileHD2_MDCAXA(component);
        //VIZZINI_D 27/06/2019: NMA - Lob Modulo di Calcolo
        helper.getDefectMdC(component);
    },
   openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
      //OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- START  //delete Attachments missing.
      var attachmentList = component.get("v.attachmentList");
      if (attachmentList.length != 0)
      {
    	  helper.deleteAttachments(component, attachmentList);      
      }
      //OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- END

	   let visibilities = component.get('v.visibilities');
       if(visibilities){
           visibilities('NewCommentAndAttachmentLightning', false);
       }
   },
 
   likenClose: function(component, event, helper) {
      // Display alert message on the click on the "Like and Close" button from Model Footer 
      // and set set the "isOpen" attribute to "False for close the model Box.
      alert('thanks for like Us :)');
      component.set("v.isOpen", false);
   },
    cancelBtn : function (component, event, helper) {
        helper.cancelBtn(component);
    },
    toggle : function (component, event, helper) {
        var sel = component.find("mySelect");
        var nav = sel.get("v.value");
        console.log('@@nav: '+nav+ "@RT: "+ component.get("v.toggleRecordType"));

        if (nav == "Agente") 
        {     
            component.set("v.toggleRecordType", "Agente");
            component.set("v.SelectedOption",nav);
        }
        else if(nav.indexOf("Supporto")!=-1)
        {
            component.set("v.toggleRecordType", "Supporto");
            component.set("v.SelectedOption",nav);

            //VIZZINI_D 25/06/2019: NMA - Lob Modulo di Calcolo - START
            if(nav == 'Supporto Modulo di Calcolo'){
                component.set("v.SupportType", "Supporto Modulo di Calcolo");
                component.set("v.isSupportoMdcAXA", "false");
            }
            else if(nav == 'Supporto Modulo di Calcolo AXA'){
                component.set("v.SupportType", "Supporto Modulo di Calcolo AXA");
                component.set("v.isSupportoMdcAXA", "true");
            }
            else{
                component.set("v.SupportType", "Supporto");
                component.set("v.isSupportoMdcAXA", "false");
            }
            console.log("SupportType: "+component.get("v.SupportType"));
            //VIZZINI_D 25/06/2019: NMA - Lob Modulo di Calcolo - END
        }
        console.log("Option: "+component.get("v.SelectedOption")+ " @RT: "+component.get("v.toggleRecordType"));

    },
    //VIZZINI_D 26/06/2019: NMA - Lob Modulo di Calcolo - START
    setDefectMdC : function (component, event, helper) {
        
        var checkbox = component.find("defect_MdC");
        var value = checkbox.get('v.checked');
        component.set("v.defect_MdC", value);
    },
    //Giorgio Bonifazi - Caring Angel Fase 2 - START
    undoError : function(component,event,helper){

        var motivo = component.get("v.selectedValue");
        if(motivo != "Altro"){ 
        component.set("v.MandatoryInputsMissing", false);}
    //Giorgio Bonifazi - Caring Angel Fase 2 - END
    },					
    //VIZZINI_D 26/06/2019: NMA - Lob Modulo di Calcolo - END
    handleModalConfirmFunctionEvent : function(component, event, helper) {
        helper.clickCreate(component);
    },
    CloseMissingInputsModal: function(component,event,helper){
        helper.closeMissingInputsModal(component);
    },    
    closeComment : function(component,event,helper){
        helper.closeComment(component,event,helper);
    },
    updateattachmentlst : function(component,event,helper){
        var value = event.getParam("param");
        component.set("v.attachmentnamelist",value);
        console.log("Received component event with param = "+ value);
    },
    openAddAttachment: function(component,event,helper){
        component.set("v.showAttachmentBox", true);
    },
    closeAddAttachment: function(component,event,helper){
        component.set("v.showAttachmentBox", false);
    },
    navigateToCmp : function(component, event, helper) {
        let motivoDiTrasferimento = component.get("v.selectedValue");
        let commento =component.get("v.comment");
        if((!motivoDiTrasferimento || motivoDiTrasferimento == 'Altro') && (!commento || !commento.trim())){
            helper.showToastStandard(component, event, helper, 'Error','error', 'Attenzione ! Inserire un commento prima di inoltrare il case.');
            return;
        }    
        let whichButton = event.getSource().getLocalId();
        console.log("BOTTONE",whichButton);
        if(whichButton=='buttonSend1')    
		helper.showComponentInModal(component, event, helper,'c:InvioASecondoLivello');
        
        if(whichButton=='buttonSend2')  
		helper.showComponentInModal(component, event, helper,'c:RitornaAlPrimoLivello');
        
        if(whichButton=='buttonSend3')  
		helper.showComponentInModal(component, event, helper,'c:InviaAdAltraArea');
        

        if(whichButton=='buttonSend4')  
        helper.showComponentInModal(component, event, helper,'c:InviaModuloCalcoloAXA');
        

        if(whichButton=='buttonSend5')  
        helper.showComponentInModal(component, event, helper,'c:InviaModuloCalcolo');

        if(whichButton=='buttonSend6')  
        helper.showComponentInModal(component, event, helper,'c:InviaAgenziaLightning');
        
        if(whichButton=='buttonSend7')  
        helper.showComponentInModal(component, event, helper,'c:InvioAHD3');

        if(whichButton=='buttonSend8')  
        helper.showComponentInModal(component, event, helper,'c:CompilaTicketSilva');
        
	},
    chiudiToast : function(component, event, helper){
        component.set("v.showToast", false);
	}
})
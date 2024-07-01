({
    doInit: function(component, event, helper) { 
        helper.checkError(component);
		helper.checkshowSupportHD1Biz(component);//MOSCATELLI_M 25/10/2018: NMA Business
        helper.checkshowSupportHD1(component);
        helper.checkProfileHD2(component);
        helper.checkProfileAgent(component);
        helper.getOrgURL(component);  
        helper.checkCaseRecordTypeServer(component, event, helper); //OAVERSANO 19/12/2018 : Enhancement NMA Biz III 
        helper.getPicklistValues(component, event , helper); //Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2
        helper.checkCaringAngel(component, event, helper); //Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2
        helper.checkVisibilitiesButtons(component, event, helper); //d.pirelli for automatica owner case
        helper.checkSmartCenterProfile(component, event, helper);
        var pageReference = component.get("v.pageReference"); //Giorgio Bonifazi : Caring Angel fase 2
        																									
    },
    cancelBtn : function (component, event, helper) {
        helper.cancelBtn(component);
    },
    toggle : function (component, event, helper) {
        var sel = component.find("mySelect");
        var nav = sel.get("v.value");
        console.log('@@nav: '+nav);
        component.set("v.SupportType",nav.toString());
        console.log(component.get("v.SupportType"));
        if (nav == "Agente") 
        {     
            component.set("v.toggleRecordType", "Agente");
        }
        //MOSCATELLI_M 25/10/2018: NMA Business -- START
        //if(nav =="Supporto")
        else if(nav.indexOf("Supporto")!=-1)
        //MOSCATELLI_M 25/10/2018: NMA Business -- END
        {
            component.set("v.toggleRecordType", "Supporto");
        }
    },
	//Giorgio Bonifazi - Caring Angel Fase 2 - START
    undoError : function(component,event,helper){

        var motivo = component.get("v.selectedValue");
        if(motivo != "Altro"){
        component.set("v.MandatoryInputsMissing", false);}
    //Giorgio Bonifazi - Caring Angel Fase 2 - END
    },										
    clickCreate : function(component, event, helper) {
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
    },
    openAddAttachment: function(component,event,helper){
        component.set("v.showAttachmentBox", true);
    },
    closeAddAttachment: function(component,event,helper){
        component.set("v.showAttachmentBox", false);
    },
    //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza ENHANCEMENT -- START
    countCharacters: function(component,event,helper){
        let value =  event.getSource().get("v.value");
        let charactersN = value.length;
        component.set("v.remainingCharacters",1000-charactersN);
    },
  
    //OAVERSANO 30/10/2018 : Nuovo Modello di Assistenza ENHANCEMENT -- END
   
    // d.pirelli send automatic case start
    navigateToCmp : function(component, event, helper) {
        //Dynamic creation of lightningModalChild component and appending its markup in a div
        
     
        var comm           = component.get("v.comment");
        
        var attachmentList = component.get("v.attachmentList");
		// Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - START -->
        var motivo = component.get("v.selectedValue");

        if(component.get("v.showCaringAngel")){
        if ((comm.length == 0  && motivo == "Altro")||(comm.length == 0 && motivo == "" && attachmentList.length ==0 )){
            component.set("v.error", 'Attenzione! Non è stato inserito alcun commento / allegato');
            component.set("v.MandatoryInputsMissing", true);}
        }
        else{
        let whichButton = event.getSource().getLocalId();
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
        helper.showComponentInModal(component, event, helper,'c:InviaAgenzia');
        
        }
	}
})
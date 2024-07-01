({
    handleShowModal : function (component, event, helper) {
	    var modalBody;
	    var modalFooter;
	    var attributes = component.get("v.attributes");
	    //per passare gli attributi utilizzare questo formato : { 	parametro1 : "valore1",
	    //															parametro2 : "valore2"	}
		//Object.keys(attributes).forEach(key => console.log('attributes passed: ',attributes[key]));
		//OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- START  
		var newComponents = [];
		newComponents.push(["aura:html", {
            "tag": "div"
        }]);
        newComponents.push(["aura:html", {
            "tag": "h1",
            "body": component.get("v.HeaderTitle"),
            "HTMLAttributes": {
                "title": component.get("v.HeaderTitle"),
                "class": "slds-truncate"                
            }
        }]);
        newComponents.push(["lightning:buttonIcon", {
            "iconName": "utility:close",
            "alternativeText": "close",
            "variant": "bare-inverse",
            "class": "slds-modal__close",
            "onclick": component.getReference("c.handleCancel")
        }]);
        
        $A.createComponents(newComponents,		// header rebuilt
	        function (components, status, errorMessage) {
	            if (status === "SUCCESS") {
	                var pageBody = component.get("v.body");
	                var button = components[2];
                    var h1= components[1];
                    var div = components[0];
                    var divBody = div.get("v.body");
                    divBody.push(h1);
                    div.set("v.body", divBody);
                    var divBody = div.get("v.body");
                    divBody.push(button);
                    div.set("v.body", divBody);
                    pageBody.push(div);
	                component.set("v.body", pageBody);
	            }
	            else 
	            {
	                console.log("Failed to create list components.");
	            }
	        }
	    );
        //OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- END

	    $A.createComponents([
		        [component.get("v.modalContentBody"), attributes],
		        ["c:ModalFooterLightning",{ "ConfirmButton" : component.get("v.ConfirmFooterButton"),
		        							"CancelButton" : component.get("v.CancelFooterButton")}]
		    ],
		    function(components, status){
		        if (status === "SUCCESS") {
		            modalBody = components[0];
		            modalFooter = components[1];
		            component.find('overlayLib').showCustomModal({
		               //OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- START
		               //header: component.get("v.HeaderTitle"),
		               header: component.get("v.body"),
		               //OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- END
		               body: modalBody, 
		               footer: modalFooter,
		               //OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- START
		               //showCloseButton: true,
		               showCloseButton: false, //header rebuilt
		               //OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- END
		               cssClass: "",
		               closeCallback: function() {
		                   //alert('You closed the alert!');
		               }
		           })
		        }
		    }
	    );
    },
    //OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- START
    handleCancel : function(component, event, helper) {
    	var myEvent = $A.get("e.c:ModalConfirmFunctionEvent");
    	myEvent.setParams({"buttonValue": "cancel"});
        myEvent.fire();
    }
    //OAVERSANO 18/12/2018 : Enhancement NMA Biz III -- END
})
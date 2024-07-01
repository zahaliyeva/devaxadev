({
    starClick : function(component, event, helper) {
        var colorOn = component.get("v.colorOn"); 
        var colorOff = component.get("v.colorOff"); 
        var el = event.target;
        //OAVERSANO 04/03/2019 : NMA Enhancement VII -- START
        //var rating = 0;
        if(el.tagName == "path")
        {
        	var rating = 0;
	        while (el) {
	            rating++;
		        el.style.fill = colorOn;
				el = el.previousElementSibling;    		        
	        }
	        el = event.target.nextElementSibling;
	        while (el) {
		        el.style.fill = colorOff;
				el = el.nextElementSibling;    		        
	        }
	        console.log('rating:',rating);
	        component.set("v.rating", rating);
	        var myEvent = component.getEvent("change");
	        myEvent.setParams({"rating": rating});
	        myEvent.fire();
        } 
        //OAVERSANO 04/03/2019 : NMA Enhancement VII -- END

	},
    mouseOver : function(component, event, helper) {
        var rating = component.get("v.rating", rating);
        if (parseInt(rating, 10) == 0) 
        {
            var colorOn = component.get("v.colorOn"); 
            var colorOff = component.get("v.colorOff"); 
            var el = event.target;
            //OAVERSANO 04/03/2019 : NMA Enhancement VII -- START
	        if(el.tagName == "path")
	        {
	            while (el) {
		            el.style.fill = colorOn;
				    el = el.previousElementSibling;    		        
	            }
	            el = event.target.nextElementSibling;
	            while (el) {
		            el.style.fill = colorOff;
				    el = el.nextElementSibling;    		        
	            }
            }
            //OAVERSANO 04/03/2019 : NMA Enhancement VII -- END
        }
    },
    mouseOut : function(component, event, helper) {
        var rating = component.get("v.rating", rating);
        if (parseInt(rating, 10) == 0) 
        {
            var colorOff = component.get("v.colorOff"); 
            var el = event.target;
            //OAVERSANO 04/03/2019 : NMA Enhancement VII -- START
	        if(el.tagName == "path")
	        {
	            while (el) {
		            el.style.fill = colorOff;
			   	    el = el.previousElementSibling;    		        
	            }
	            el = event.target.nextElementSibling;
	            while (el) {
		            el.style.fill = colorOff;
				    el = el.nextElementSibling;    		        
	            }
	        }
            //OAVERSANO 04/03/2019 : NMA Enhancement VII -- END
        }
    }
})
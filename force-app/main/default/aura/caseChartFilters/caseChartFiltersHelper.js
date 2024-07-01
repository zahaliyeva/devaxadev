({
    populateYearFilter : function (component){
		var baseDate =  new Date("September 01, 2017 00:00:00");
		var currentDate = new Date();
	    var dateArray = [];
	    var i = 0;
	    dateArray.push({"class": "optionClass", label: "Tutti", value: "None" , selected: true});
	    while (baseDate.getFullYear() <= currentDate.getFullYear()) {
	        dateArray.push({"class": "optionClass", label: baseDate.getFullYear(), value: baseDate.getFullYear()});
	        baseDate.setFullYear(baseDate.getFullYear() + 1);
	        i++;
	    }
	    component.set('v.yearOptions', dateArray);
    },
    populateMonthFilter : function (component){
    	var selectedYear = component.get("v.selectedYear");
    	//console.log(" selectedYear: "+selectedYear);
    	if (selectedYear!="None" && selectedYear!=""){
			var baseDate =  new Date(selectedYear,0,1);
			var currentDate = new Date();
		    var dateArray = [];
		    var i = 0;
		    dateArray.push({"class": "optionClass", label: "Tutti", value: "None" , selected: true});
		    while ((baseDate <= currentDate)&& ( selectedYear == baseDate.getFullYear()) ){
		    	var month = this.getMonthByIndex(baseDate.getMonth());
		        dateArray.push({"class": "optionClass", label: month, value: baseDate.getMonth()});
		        baseDate.setMonth(baseDate.getMonth() + 1);
		        i++;
		    }

			//console.log('numero cicli: '+i);

		    component.set('v.monthOptions', dateArray);
		    component.set('v.monthDisabled', false);
		    component.set("v.selectedMonth", "None");

    	} else {
    		var dateArray = [];
		    dateArray.push({"class": "optionClass", label: "Tutti", value: "None" , selected: true});
		    component.set('v.monthOptions', dateArray);
		    component.set('v.monthDisabled', true);
		    component.set("v.selectedMonth", "None");
    	}
    }, 
    populateWeekFilter : function (component){
    	var selectedYear = component.get("v.selectedYear");
    	var selectedMonth = component.get("v.selectedMonth");
    	//console.log(" selectedMonth: "+selectedMonth);
    	if (selectedMonth!="None" && selectedMonth!= "" && selectedYear!="None" && selectedYear!="")
    	{
			var baseDate =  new Date(selectedYear,selectedMonth,1);
			//console.log(' settimana baseDate: '+baseDate);
			var currentDate = new Date();
		    var dateArray = [];
		    var i = 0;
		    dateArray.push({"class": "optionClass", label: "Tutte", value: "None" , selected: true});
		    while ((baseDate <= currentDate)&& (baseDate.getMonth()== selectedMonth ) ){
		    	var dayOfTheWeek = baseDate.getDay();
		    	if (dayOfTheWeek==1)
		    	{
		        	dateArray.push({"class": "optionClass", label: baseDate.getDate(), value: baseDate.getDate()});
		        }
		        baseDate.setDate(baseDate.getDate() + 1);
		        i++;
		    }

			//console.log('numero cicli settimana: '+i);

		    component.set('v.weekOptions', dateArray);
		    component.set('v.weekDisabled', false);
		    component.set('v.selectedWeek','None');
    	}
    	else
    	{
    		var dateArray = [];
		    dateArray.push({"class": "optionClass", label: "Tutte", value: "None" , selected: true});
		    component.set('v.weekOptions', dateArray);
		    component.set('v.weekDisabled', true);
		    component.set('v.selectedWeek','None');
    	}
    },       
    populateLobFilter : function (component){	    

		var LobArray = [];
	    LobArray.push({"class": "optionClass", label: "Tutte", value: "None" , selected: true});
		//MOSCATELLI_M 25/10/2018: NMA Business -- START
		/*
        LobArray.push({"class": "optionClass", label: "IT", value: "IT" });
		component.set('v.lobOptions', LobArray);*/
		
		var action = component.get("c.getLob");

	    action.setCallback(this, function(response) {

	    	var state = response.getState();
	   		console.log ('state: '+state);
	        if (state === "SUCCESS") {
	            console.log("Response " + JSON.stringify(response.getReturnValue(), null, 4));
	            var reportResultData = response.getReturnValue();
	            //var isCallSuccess = response.getReturnValue()["isSuccess"];
	            
	            //var LobArray = [];
	    		//LobArray.push({"class": "optionClass", label: "Tutte", value: "None" , selected: true});

	           // if (isCallSuccess)
	        //    {                       
	                for(var i=0; i < (reportResultData.length); i++){
                        console.log("reportResultData[i]: "+reportResultData[i]);
	                    LobArray.push({"class": "optionClass", label: ''+reportResultData[i], value: ''+reportResultData[i] });
	                }                    
	       //     }

	    		component.set('v.lobOptions', LobArray);
	            
	        } else if (state === "ERROR") {
	            var errors = response.getError();
	            if (errors) {
	                if (errors[0] && errors[0].message) {
	                    console.log("Error message on createReport: " +
	                                errors[0].message);
	                }
	            } else {
	                console.log("Unknown error");
	            }
	        }
	    });
	    $A.enqueueAction(action);
	    //MOSCATELLI_M 25/10/2018: NMA Business -- END
    },
    populateCategoryFilter: function (component)
    {
    	var selectedLob = component.get("v.selectedLob");
    	//console.log("selectedLob: " + selectedLob);
    	if (selectedLob!="None" && selectedLob!=""){

    		var action = component.get("c.getCategory");
    		action.setParams({ "lob": selectedLob });

    		action.setCallback(this, function(response) {

		    	var state = response.getState();
		   		//console.log ('state: '+state);
		        if (state === "SUCCESS") {
		            //console.log("Response " + JSON.stringify(response.getReturnValue(), null, 4));
		            var reportResultData = response.getReturnValue();
		            //var isCallSuccess = response.getReturnValue()["isSuccess"];
		            
		            var categoryArray = [];
		    		categoryArray.push({"class": "optionClass", label: "Tutte", value: "None" , selected: true});

		            if (reportResultData.length != 0)
		            {                       
		                for(var i=0; i < (reportResultData.length); i++){
		                    categoryArray.push({"class": "optionClass", label: ''+reportResultData[i], value: ''+reportResultData[i] });
		                }                 
			    		component.set('v.categoryOptions', categoryArray);
			    		component.set('v.categoryDisabled', false);   
		            } else {
		            	component.set('v.categoryOptions', categoryArray);
    					component.set('v.categoryDisabled', true);
		            }

		            
		        } else if (state === "ERROR") {
		            var errors = response.getError();
		            //console.log("Errore");
		            //console.log(errors);
		            if (errors) {
		                if (errors[0] && errors[0].message) {
		                    /*console.log("Error message on createReport: " +
		                                errors[0].message);*/
		                }
		            } else {
		                //console.log("Unknown error");
		            }
		        }
		    });
		    $A.enqueueAction(action);
    	} else {
    		var categoryArray = [];
		    categoryArray.push({"class": "optionClass", label: "Tutte", value: "None" , selected: true});
		    component.set('v.categoryOptions', categoryArray);
		    component.set('v.categoryDisabled', true);
    	}    	
    },
    populateSubCategoryFilter: function (component)
    {
    	var selectedCategory = component.get("v.selectedCategory");
    	//console.log(' ===> selectedCategory');
    	var selectedLob = component.get("v.selectedLob");
    	//console.log("selectedLob: " + selectedLob);
    	//console.log(selectedLob);
            
    	if (selectedCategory!="None" && selectedCategory!="" && selectedLob!="None" && selectedLob!="")
    	{		
    		//console.log(' ===> selectedCategory');
    		var action = component.get("c.getSubCategory");
            
            //MOSCATELLI_M 25/10/2018: NMA Business -- START
    		//action.setParams({ "category": selectedCategory });
            action.setParams({ "category": selectedCategory, "Lob": selectedLob });
			//MOSCATELLI_M 25/10/2018: NMA Business -- END
			
    		action.setCallback(this, function(response) {

		    	var state = response.getState();
		   		//console.log ('state: '+state);
		        if (state === "SUCCESS") {
		            //console.log("Response " + JSON.stringify(response.getReturnValue(), null, 4));
		            var reportResultData = response.getReturnValue();
		            //var isCallSuccess = response.getReturnValue()["isSuccess"];
		            
		            var subCategoryArray = [];
		    		subCategoryArray.push({"class": "optionClass", label: "Tutte", value: "None" , selected: true});

		            if (reportResultData.length != 0)
		            {                       
		                for(var i=0; i < (reportResultData.length); i++){
		                    subCategoryArray.push({"class": "optionClass", label: ''+reportResultData[i], value: ''+reportResultData[i] });
		                }                 
			    		component.set('v.subCategoryOptions', subCategoryArray);
	    				component.set('v.subCategoryDisabled', false);  
		            } else {
		            	component.set('v.subCategoryOptions', subCategoryArray);
	    				component.set('v.subCategoryDisabled', true);  
		            }

		            
		        } else if (state === "ERROR") {
		            var errors = response.getError();
		            //console.log("Errore");
		            //console.log(errors);
		            if (errors) {
		                if (errors[0] && errors[0].message) {
		                 /*   console.log("Error message on createReport: " +
		                                errors[0].message);*/
		                }
		            } else {
		              //  console.log("Unknown error");
		            }
		        }
		    });
		    $A.enqueueAction(action);
    	}
    	else
    	{
    		var subCategoryArray = [];
    	//	console.log('None');
		    subCategoryArray.push({"class": "optionClass", label: "Tutte", value: "None" , selected: true});
		    component.set('v.subCategoryOptions', subCategoryArray);
		    component.set('v.subCategoryDisabled', true);
    	}  	
    },
    populateOwnershipFilter: function (component)
	{
		var ownershipArray = [];
		ownershipArray.push({"class": "optionClass", label: "Le mie richieste", value: "CurrentUser" , selected: true});
	    ownershipArray.push({"class": "optionClass", label: "Tutte le richieste di agenzia", value: "None" });
	    component.set('v.ownershipOptions', ownershipArray);
    },
    getMonthByIndex: function (index){
    	var monthArray = ['Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno', 'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'];
    	return monthArray[index];
    }
})
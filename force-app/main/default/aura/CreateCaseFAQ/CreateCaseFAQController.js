({
	onInit : function(component, event, helper)
	{
		let varToSearch = component.get('v.valueToSearch');
		helper.getKnowledge(component, event, helper, varToSearch);
		
	},
	
	searchKnowledge : function(component, event, helper)
	{
        console.log('ricerco..');
		
		let varToSearch = event.target.value;
		let valueSuggested = component.get("v.valueSuggested");
		component.set("v.valueToSearch",varToSearch);
		var Category = component.get("v.categoryToFilter");
		//console.log('varToSearch: ',varToSearch);
		var orderBy = component.get("v.orderBy");
		if(varToSearch!= null)
		{
			if(varToSearch.length >= 2)
			{
				helper.getKnowledge(component, event, helper, varToSearch, orderBy, Category);
			}
			else if(varToSearch.length == 0)
			{
				helper.getKnowledge(component, event, helper, valueSuggested, orderBy, Category);
			}
		}
		var menuItems = component.find("menuItems");
		//OAVERSANO 24/01/2019 : NMA Fix Mobile -- START
		/*if(menuItems != undefined)
		{
			menuItems.forEach(function (menuItem) {
	            if (menuItem.get("v.checked")) {
	                menuItem.set("v.checked", false);
	            }
	        });
        }*/
        //OAVERSANO 24/01/2019 : NMA Fix Mobile -- END
	},
	
	goToKnowledge : function(component, event, helper)
	{
		let knowledgeId = event.currentTarget.getAttribute("id");
		let knowledgeUrlName = event.currentTarget.getAttribute("data-UrlName");
		console.log('knowledgeId: '+knowledgeId);
		let linkKnowledge;
		if(window.location.href.indexOf('/agenzie/')>-1)
			// LB.
//			linkKnowledge = window.location.href.substring(0,window.location.href.indexOf('.com/')+5)+'agenzie/articles/FAQ/'+knowledgeUrlName;
			linkKnowledge = window.location.href.substring(0,window.location.href.indexOf('.com/')+5)+'agenzie/articles/Knowledge/'+knowledgeUrlName;
		else
			linkKnowledge = window.location.href.substring(0,window.location.href.indexOf('.com/')+5)+'/knowledge/publishing/articlePreview.apexp?id='+knowledgeId+'&popup=true&pubstatus=o&preview=true';
		window.open(linkKnowledge, '_blank');
	},
	
	orderResults : function(component, event, helper)
	{
		var selectedMenuItemValue = event.getParam("value");
		var varToSearch = component.get("v.valueToSearch"); 
		if(varToSearch==null || varToSearch =="")
			varToSearch = component.get("v.valueSuggested"); 
		var orderBy = selectedMenuItemValue;
        var menuItems = component.find("menuItems");
        menuItems.forEach(function (menuItem) {
            if (menuItem.get("v.checked")) {
                menuItem.set("v.checked", false);
            }
            if (menuItem.get("v.value") === selectedMenuItemValue) {
                menuItem.set("v.checked", true);
            }
        });
        //OAVERSANO 25/01/2019 : NMA Fix Mobile -- START
        //helper.getKnowledge(component, event, helper, varToSearch, orderBy);
        var Category = component.get("v.categoryToFilter");
        helper.getKnowledge(component, event, helper, varToSearch, orderBy, Category);
        //OAVERSANO 25/01/2019 : NMA Fix Mobile -- END
	},
    
    executeQuery : function(component, event, helper)
    {
        var params = event.getParam('arguments');
        var Category = params.Category;
        var SubCategory = params.SubCategory;
        var Lob = params.Lob;
        console.log('executeQuery .. Category: '+ Category);
        console.log('executeQuery .. SubCategory: '+ SubCategory);
        console.log('executeQuery .. Lob: '+ Lob);
        //let varToSearch = Category + ' ' + SubCategory;
        //let varToSearch = Category + ' ' + '.';
        let orderBy = component.get("v.orderBy");
        //MOSCATELLI_M 25/10/2018: NMA Business -- START
        //component.set("v.categoryToFilter",Category);
        if(Lob=="IT")
        {
            if(SubCategory)
            {
                component.set("v.categoryToFilter",Lob+'_'+Category+'_'+SubCategory);
                Category = Lob+'_'+Category+'_'+SubCategory;
            }
            else
            {
                component.set("v.categoryToFilter",Lob+'_'+Category);
                Category = Lob+'_'+Category;                    
            }
        }
        else
        {
            component.set("v.categoryToFilter",Lob+'_'+Category);
            Category = Lob+'_'+Category;            
        }
        //MOSCATELLI_M 25/10/2018: NMA Business -- END
        
        //component.set("v.valueToSearch",varToSearch);
        //component.set("v.valueSuggested",varToSearch);
        helper.getKnowledge(component, event, helper, '', orderBy, Category);
		component.set('v.valueToSearch',"");
    },

	handleShowModal : function(component, event, helper)
	{
		const idx = event.target.id;
		document.getElementById('div-'+idx).style.display = 'block';
	},

	handleHideModal : function(component, event, helper)
	{
		const idx = event.target.id;
		document.getElementById('div-'+idx).style.display = 'none';
	}
})
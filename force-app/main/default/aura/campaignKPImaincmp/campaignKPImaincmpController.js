({
    doHandleClick : function(component, event, helper) {
        helper.startSpinner(component);
        helper.onHandleClick(component, event, helper);        
    }, 
    
    
    InitFilters: function(component, event, helper)
    {   
       
        helper.startSpinner(component);
        helper.InitializeFilters(component, event, helper);
        helper.InitializeAgFilters(component, event, helper);
        helper.onHandleClick(component, event, helper);
        //helper.setFiltersToShow(component, event, helper);
        
        
    },
    SetCollaboratore : function(component, event, helper) {
        var selected = component.find("inputList_collaboratori").get("v.value");
        console.log('selected: '+selected);
        component.set("v.CollaboratoreId", selected);
        helper.startSpinner(component);
        helper.onHandleClick(component, event, helper);
    },
    SetAreaMgr : function(component, event, helper) {
        var selected = component.find("inputList_AreaMgr").get("v.value");
        console.log('selected: '+selected);
        component.set("v.AreaManagerID", selected);
        if(selected != ""){
        	component.set("v.isSetAreaManager",true);
            component.set("v.isSetSalesManager",false);
            component.find("inputList_SalesMgr").set("v.value","");
            component.find("inputList_Agencies").set("v.value","");          
        	component.set("v.SalesManagerID","");
			component.set("v.CodiceAgenzia","");
        }else{
            component.set("v.AreaManagerID", "");
        	component.set("v.SalesManagerID","");
			component.set("v.CodiceAgenzia","");
            component.set("v.isSetAreaManager",false);
            component.set("v.isSetSalesManager",false);
            component.find("inputList_SalesMgr").set("v.value","");
            component.find("inputList_Agencies").set("v.value","");
           
        }
        
        ////
        var AMtoSMmap = component.get("v.MapAMtoSM");
        var SalesMap = [];
        var AgencyMap = [];
        var Sales = [];
        var Agency=[];
        Sales.push({"class": "optionClass",  value: "", label:"-- SM --"});
        Agency.push({"class": "optionClass",  value: "", label:"-- Codice agenzia --"});
        

        console.log('AM::'+selected);
        for(var i=0;i<AMtoSMmap.length;i++)
        {
            console.log('!!!!'+AMtoSMmap[i].split("_")[0]);
if(selected){
            if(AMtoSMmap[i].split("_")[0] == selected)
            {   
                var SalesMgr = AMtoSMmap[i].split("_")[1];
                var AgencyCode = AMtoSMmap[i].split("_")[2];
                console.log(AgencyCode);
                SalesMap[SalesMgr]=SalesMgr;
                AgencyMap[AgencyCode]=AgencyCode.split("-")[0];
                    
                console.log('found');
            
        }
}
            else
            {
                var SalesMgr = AMtoSMmap[i].split("_")[1];
                var AgencyCode = AMtoSMmap[i].split("_")[2];
                console.log(AgencyCode);
                SalesMap[SalesMgr]=SalesMgr;
                AgencyMap[AgencyCode]=AgencyCode.split("-")[0];
                    
                console.log('found');                
            }

        }
                    for(var singlekey in SalesMap)
            {
                console.log('key'+singlekey);
                Sales.push({"class": "optionClass", label: singlekey, value: singlekey});
            }
            for(var singlekey in AgencyMap)
            {
                console.log('key'+singlekey);
                Agency.push({"class": "optionClass", label: singlekey, value: AgencyMap[singlekey]});
            }
        
        console.log('!SALES: '+SalesMap);
        component.set("v.SalesList",Sales);
        component.set("v.AgenciesList",Agency);
      

        /////
    },
    SetSalesMgr : function(component, event, helper) {
        var selected = component.find("inputList_SalesMgr").get("v.value");
        console.log('selected SM: '+selected);
        component.set("v.SalesManagerID", selected);
        if(selected != ""){
        component.set("v.isSetSalesManager",true);
        component.set("v.CodiceAgenzia","");
        }else{
            
        	component.set("v.SalesManagerID","");
			component.set("v.CodiceAgenzia","");
            component.find("inputList_SalesMgr").set("v.value","");
            component.find("inputList_Agencies").set("v.value","");
            component.set("v.isSetSalesManager",false);
            
            
        }
        
        
        ////
        
        var AMtoSMmap = component.get("v.MapAMtoSM");

        var AgencyMap = [];
        var Agency=[];
        
        Agency.push({"class": "optionClass",  value: "", label:"-- Codice agenzia --"});
        var selectedAM = component.get("v.AreaManagerID");
        
    
        for(var i=0;i<AMtoSMmap.length;i++)
        {
            console.log('!!!!'+AMtoSMmap[i].split("_")[0]);

            var selvalues = selectedAM+'_'+selected;

            console.log('SM::'+selvalues);
            if(selected){
            if((AMtoSMmap[i].split("_")[0]+'_'+AMtoSMmap[i].split("_")[1]) == selvalues)
            {   
                var AgencyCode = AMtoSMmap[i].split("_")[2];
                console.log(AgencyCode);
                AgencyMap[AgencyCode]=AgencyCode.split("-")[0];
                    
                console.log('found');
            
        }
            }
            else
            {
                if(AMtoSMmap[i].split("_")[0] == selectedAM){
                var AgencyCode = AMtoSMmap[i].split("_")[2];
                console.log(AgencyCode);
                AgencyMap[AgencyCode]=AgencyCode.split("-")[0];
                    
                console.log('found');  
                    }
            }
        }

            for(var singlekey in AgencyMap)
            {
                console.log('key'+singlekey);
                Agency.push({"class": "optionClass", label: singlekey, value: AgencyMap[singlekey]});
            }
        
     
        component.set("v.AgenciesList",Agency);
        
        /////        
        
        
    },
    SetAgency : function(component, event, helper) {
        var selected = component.find("inputList_Agencies").get("v.value");
        console.log('selected: '+selected);
        component.set("v.CodiceAgenzia", selected);
    } ,
    findagency : function(component, event, helper) {
        helper.startSpinner(component);
        helper.FindAgencies(component, event, helper);
        
        
    } ,
    itemsChange : function (component,event,helper){
        console.log ('VALORE TRATTATIVE'+ component.get("v.RevenueTrattativeInCorso"));
    },
    
    resetValues : function(component,event,helper){
       	
        helper.startSpinner(component);
        var ShowCollFilter = component.get("v.ShowCollFilter");
        var ShowDirFilter = component.get("v.ShowDirFilter");
        
        component.set("v.NoClientsinTarget",false);
        
        if(ShowCollFilter){
        component.set("v.CollaboratoreId","");  
        component.find("inputList_collaboratori").set("v.value","");
        }    
        if(ShowDirFilter){    
        component.set("v.AreaManagerID", "");
        component.set("v.SalesManagerID","");
		component.set("v.CodiceAgenzia","");
        component.set("v.AgencyList",[]);
        component.set("v.isSetAreaManager",false);
        component.set("v.isSetSalesManager",false);
       	helper.InitializeAgFilters(component,event,helper);
        component.find("inputList_AreaMgr").set("v.value","");
        component.find("inputList_SalesMgr").set("v.value","");
        component.find("inputList_Agencies").set("v.value","");
        }
        
        helper.onHandleClick(component, event, helper);
    },
    

    retrievePageValues : function(component,event,helper){
        var getURL = window.location.toString(); //You get the whole decoded URL of the page.
        component.set("v.getURL",getURL);
        console.log("myurl IS"+getURL);
        if(getURL.includes('lightning.force') || getURL.includes('agenzie/apex'))
                                    {component.set("v.isMobile",true);}
        helper.retrievePageVal(component,event,helper);
        
    }

    
    
})
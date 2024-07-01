({
    init: function (cmp, event, helper) {
        var url = window.location.href;
        
        console.log(url);
        if(url.includes("?")){
            console.log(1);
            var temp = url.split("?")[1];
            console.log(2);
            var params = temp.split("&");
            console.log(3);
            for(var i = 0; i< params.length; i++){
                var param = params[i].split("=");
                if(param[0] === "filter"){
                    cmp.set("v.FilterParam",param[1]);
                }
            }
        }
        
          
		cmp.set('v.gestioneCodaCaseURL', window.location.href.split('apex')[0] +'apex/agencyCaseQueueManager');
        helper.retrieveFilter(cmp, event,helper);   
        
        var workspaceAPI = cmp.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
           cmp.set('v.isConsole',response); 
        })
        .catch(function(error) {
            console.log(error);
        });

    },
    setFilters:  function (cmp, event, helper) {

        var objectFilters = cmp.get("v.objectFilters");
        var ingressoFilters = cmp.get("v.ingressoFilters");
        var label =   cmp.get('v.LabelSelect');
        var conditionsDefault = objectFilters.filter(function(element) {
            return element.Label === label;
        });
        console.log(2);
        var IngressoSelected;
        if(conditionsDefault){
            if(conditionsDefault.length != 0){
                var ingresso = conditionsDefault[0].Ingresso_Default__c;
                if(ingresso){
                    IngressoSelected = ingressoFilters.filter((element) => {
                        return element.DeveloperName === ingresso;
                    })
                }
                else{
                    IngressoSelected = ingressoFilters.filter((element) => {
                        return element.Default__c;
                    })
                }
            }  
        }
        console.log(3);
        if(IngressoSelected)
	        cmp.set('v.AreaSelect',IngressoSelected[0].Label);
        else
            cmp.set('v.AreaSelect','');

	cmp.set('v.conditions','');
      

    }, 
    
    doSearch: function (cmp, event, helper){
        cmp.set('v.conditions', '');
        helper.doSearchHandler( cmp, event, helper);
    },


    resetRows: function (cmp, event, helper) {
        cmp.set('v.data', []);
        helper.initData(cmp, event, cmp.get("v.data").length);
    },
    
    loadMoreData: function (cmp, event, helper) {
        var rowsToLoad = cmp.get('v.rowsToLoad');
        event.getSource().set("v.isLoading", true);
        cmp.set('v.loadMoreStatus', 'Loading');
        helper.fetchData(cmp, event, cmp.get("v.data").length);
    },
    
 

})
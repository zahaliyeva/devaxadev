({
    doInit: function(component, event, helper) {
    var url_string = window.location.href;
    var url = new URL(url_string);
    var recordId = url.searchParams.get("recordId");
    console.log(recordId); 
    component.set('v.id', recordId );     
    },
    
})
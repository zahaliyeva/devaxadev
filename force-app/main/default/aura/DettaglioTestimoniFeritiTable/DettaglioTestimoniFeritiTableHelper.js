({
    createObjectData: function(component, event) {
        // get the testimoniFeritiList from component and add(push) New Object to List
        var RowItemList = component.get("v.testimoniFeritiList");
        RowItemList.push({
            'sobjectType': 'Testimone_Ferito__c',
			'Nome__c': '',
			'Cognome__c': '',			
			'Telefono__c':''
           
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.testimoniFeritiList", RowItemList);	
        console.log("LISTA" ,component.get("v.testimoniFeritiList"));	
    },
    // helper function for check if first Name is not null/blank on save  
    validateRequired: function(component, event) {
       /* var isValid = true;
        var allTestimoniFeritiRows = component.get("v.testimoniFeritiList");
        for (var indexVar = 0; indexVar < allTestimoniFeritiRows.length; indexVar++) {
            if (allTestimoniFeritiRows[indexVar].Nome__c == '' || allTestimoniFeritiRows[indexVar].Cognome__c ) {
                isValid = false;
                alert('Nome Cognome Can\'t be Blank on Row Number ' + (indexVar + 1));
            }
        }
        return isValid;*/
    },
})
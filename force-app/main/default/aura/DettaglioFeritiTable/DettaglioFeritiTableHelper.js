({
    createObjectData: function(component, event) {
        // get the contactList from component and add(push) New Object to List  
        var RowItemList = component.get("v.testimoniFeritiList");
        RowItemList.push({
            'sobjectType': 'Testimone_Ferito__c',
			'Nome__c': '',
			'Cognome__c': '',
			'Data_Di_Nascita__c': '',
			'Luogo_Di_Nascita__c':'',
			'Indirizzo_Residenza__c':'',
			'CAP_Residenza__c':'',
			'Citt_Residenza__c':'',
			'Email__c':'',
			'Telefono__c':'',
			'Veicolo__c':''
           
        });
        // set the updated list to attribute (contactList) again    
		component.set("v.testimoniFeritiList", RowItemList);
		console.log(' compo **',  component.get("v.testimoniFeritiList"));
    },
    // helper function for check if first Name is not null/blank on save  
    validateRequired: function(component, event) {
       /* var isValid = true;
        var allFeritiRows = component.get("v.feritiList");
        for (var indexVar = 0; indexVar < allFeritiRows.length; indexVar++) {
            if (allFeritiRows[indexVar].FirstName == '') {
                isValid = false;
                alert('First Name Can\'t be Blank on Row Number ' + (indexVar + 1));
            }
        }
        return isValid;*/
    },
})
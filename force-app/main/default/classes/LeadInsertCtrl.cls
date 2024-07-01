public class LeadInsertCtrl {
    
    public Lead LeadToInsert {get;set;}
    public boolean showMessage {get;set;}
    public string pageMessage {get;set;}
    public string LeadId {get;set;}
    
    public LeadInsertCtrl(ApexPages.StandardController mycontroller) {
        // Constructor
        LeadToInsert = new Lead();
    }
    
    
    public List<SelectOption> getASAList() {
        // Populates the ASA picklist
        
        list<selectoption> options = new list<selectoption>();   
        options.add(new SelectOption('0', '--Nessuno--'));

        Schema.DescribeFieldResult fieldResult = Lead.ASA_Description__c.getDescribe();
        list<Schema.PicklistEntry> values = fieldResult.getPickListValues();               
        for (Schema.PicklistEntry a : values)
            options.add(new SelectOption(a.getLabel(), a.getValue()));
        
        return options;
    }
    
    
    public pageReference SaveLead() {
        // When Save button is pressed to insert a Lead
        
        showMessage = false;
        pageMessage = '';
        
        // Validations
        Boolean noName = true;
        Boolean noCompany = true;
        Boolean noPhone = true;
        Boolean noEmail = true;
        Boolean errEmail = false;
        Boolean isEmpty = false;
        Boolean isOK = false;
        
        
        // Required Fields Control
        String err = 'Compilare almeno uno tra i campi';
        String err1 = 'Nome e Cognome o Ragione Sociale';
        String err2 = 'Telefono o Email';
        String err3 = 'Attenzione: l\'indirizzo email inserito non è scritto in forma corretta';
        String err4 = 'Compilare tutti i campi obbligatori:';
        
        
        String errmsg1 = '';
        String errmsg2 = '';
        String errmsg3 = '';
        String errmsg4 = '';
        
        if(LeadToInsert.FirstName != '' || LeadToInsert.LastName != '')
            noName = false;
        if(LeadToInsert.Company != '')
      noCompany = false;
        if(LeadToInsert.Phone != '')
            noPhone = false;
        if(LeadToInsert.Email != '')
            noEmail = false;
        
        boolean isFirstError = true;
        
        if(noName && noCompany){
            isFirstError = false; 
            errMsg1 = err + ' - ' +err1;
            pageMessage = pagemessage+' '+errMsg1;
            isEmpty = true;
            }
        
        if(noPhone && noEmail){
            if(isFirstError){
            isFirstError = false; 
            errMsg2 = err + ' - ' +err2;
            pageMessage= pageMessage+' '+errMsg2;
            isEmpty = true;
            }else{
            errMsg2 = ' - ' + err2;
            pageMessage= pageMessage+' '+errMsg2;
            isEmpty = true;
            }
            
            }
            
        
        if(!noEmail && !validateFields('email', LeadToInsert.Email)){ 
            if(isFirstError){
            isFirstError = false;
            errMsg3 = err3;
            pageMessage = pageMessage+' '+errMsg3;
            isEmpty = true;
            }else{
            pageMessage = '<br/>'+ pageMessage;  
            errMsg3 = err3;
            pageMessage = pageMessage+' '+errMsg3;
            isEmpty = true;
            }
            }
            

    
        boolean First = true;
        
        if(!noName && LeadToInsert.FirstName == '' && noCompany){
            First=false;
            errMsg4 = err4;
            errMsg4 += ' - Nome';
            
            isEmpty = true;
        
        }
        
        if(!noName && LeadToInsert.LastName == '' && noCompany){
            if(First){
            First=false;
            errMsg4 = err4;
            errMsg4 += ' - Cognome';
            isEmpty = true;
            }else{
            errMsg4 += ' - Cognome';
            isEmpty = true;
            }
    
        
        }
        
        if(LeadToInsert.ASA_Description__c == '0'){
        if(First){
            First=false;
            errMsg4 = err4;
            errMsg4 += ' - ASA';
            isEmpty = true;
            }else{
            errMsg4 += ' - ASA';
            isEmpty = true;
            
        
        }
        }
        
        
        if(noName && !noCompany)
            LeadToInsert.LastName = LeadToInsert.Company;
        
        if(isEmpty == false)
                isOK = true;
            else{
                if(isFirstError)
                pageMessage = pageMessage + errMsg4;
                else
                pageMessage = pageMessage +'<br/>'+ errMsg4;
                }
        
        
        
        if(pageMessage != '')
            showMessage = true;
        
        
        if(isOK) {
            try {
                insert LeadToInsert;
                LeadId = LeadToInsert.Id;
                return null;
            }
            
            catch (Exception e) {
                pageMessage = e.getMessage();
                showMessage = true;
                return null;
            }
        }
        
        else
            return null;            
        
    }

    
    public pageReference AddFields() {
        
        SaveLead();
        if(!showMessage) {
            PageReference acctPage = new PageReference('/apex/EditLeadLDS');
            acctPage.getParameters().put('id',LeadToInsert.Id);
          return acctPage;
        }
        else
            return null;
        
    }
    
    
    public boolean validateFields(string tipo, string valore){
        
        boolean valido = false;
        string regexFilter;
        
        if (tipo=='email'){
            regexFilter='^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        }
        else if (tipo =='phone'){
            regexFilter ='^[0-9]{0,20}$';
        }
        else if (tipo=='prefix'){
            regexFilter='^[0-9+]{0,4}$';
        }
        
        Pattern MyPattern = Pattern.compile(regexFilter);
        Matcher MyMatcher = MyPattern.matcher(valore);
        
        if (MyMatcher.matches()){
            valido = true;
        }
        
        return valido;
        
    }
    
}
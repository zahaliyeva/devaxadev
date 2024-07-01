/**
* Intiative: Lead Management - Sprint 44
* Controller of the Edit Lead page
*/
global with sharing class EditLeadLDSCtrl  {
    private ApexPages.StandardController mycontroller;
    public String pageMessage {get;set;}
    public Boolean showMessage {get;set;}
    public Lead leadToUpdate {get;set;}
    public Lead oldLead {get;set;}
    public Id leadToUpdateId {get;set;}
    public Id recordtypeEmployees {get;set;}
    public Id recordtypeAuto {get;set;}
    public Id recordtypeNonAuto {get;set;} 
    public Id recordtypePrevidenza {get;set;}
    public Id recordtypeProtezione {get;set;}
    public Id recordtypeRisparmio {get;set;}
    public Id recordtypeGenericoTask {get;set;}
    public Id recordtypeAAIEvent {get;set;}
    public Id recordtypeAXAAssicurazioni {get;set;}

    public boolean showForeignAddress {get;set;}
    public boolean showNormalizedAddresses {get;set;}
    public String errorMessage {get;set;} 
    public Boolean showError {get;set;}
    public Boolean showAlert {get;set;}
    public long ore {get;set;}
    public long minuti {get;set;}
    public id businessHour1 {get;set;}
    public id businessHour2 {get;set;}
    public decimal time1 {get;set;}
    public decimal time2 {get;set;}
    public decimal time3 {get;set;}
    public string giacenza {get;set;}
    public Double LeadExistanceHours {get;set;}
    public Id BHoursBefore;
    public Id BHoursAfter;
    public Boolean isUpdated {get;set;}
    public String DefaultLookup{get;set;}
    public Id sysAdminProfileId; //CAPOBIANCO_A 26/07/2017
    public Boolean isDuplicated {get;set;} //FM 27/12/2017
        
    private ApexPages.StandardController controller;
    public String alertMessage {get;set;}
    public String valueButton1 {get;set;}
    public String valueButton2 {get;set;}
    public Boolean showAlertStato {get;set;}
    public Boolean showOption2 {get;set;}
    public Boolean showErrorStato {get;set;}
    public String returnUrl {get;set;}
    public String errorMessageStato {get;set;}
    private Map<String,String> alertMap = new Map<String,String>();
    public  String LookupIds {get;set;}
    public String taskOrEvent {get;set;}
   
    public Boolean showSubStatus {get;set;}
    
    public EditLeadLDSCtrl(ApexPages.StandardController mycontroller){
        oldLead = new Lead();
        this.mycontroller = mycontroller;
        leadToUpdate = (Lead)mycontroller.getRecord();
        leadToUpdateId = leadToUpdate.Id;
        oldLead = leadToUpdate.clone();
        system.debug('****JV - lead to update: ' + leadToUpdate);
        system.debug('****JV - lead record type Id: ' + leadToUpdate.recordtypeid);
        Map<String,String> leadRecordTypeMap = RecordTypeUtility.getRecordTypeMapDeveloperNameId('Lead');
        recordtypeEmployees = leadRecordTypeMap.get('Employees_Benefit');
        recordtypeAuto = leadRecordTypeMap.get('Motor');
        recordtypeNonAuto = leadRecordTypeMap.get('No_Motor');
        recordtypePrevidenza = leadRecordTypeMap.get('Previdenza');
        recordtypeProtezione = leadRecordTypeMap.get('Protezione');  
        recordtypeRisparmio = leadRecordTypeMap.get('Risparmio');
        recordtypeGenericoTask = RecordTypeUtility.getRecordTypeIdOnDeveloperName('Generico');
        recordtypeAAIEvent = RecordTypeUtility.getRecordTypeIdOnDeveloperName('AAI_Event');
        recordtypeAXAAssicurazioni = RecordTypeUtility.getRecordTypeIdOnDeveloperName('Lead_AXA_Assicurazioni');


        //[07/07/2017]JV - Start: Refactoring
        /*
        Id 
        Id 
        */
        /*
        recordtypeAuto = [SELECT Id,name FROM RecordType WHERE Name = 'Auto' AND SobjectType = 'Lead'].Id;
        recordtypeEmployees = [SELECT Id FROM RecordType WHERE Name = 'Employees Benefit' AND SobjectType = 'Lead'].id;
        recordtypeNonAuto = [SELECT Id,name FROM RecordType WHERE Name = 'Non Auto' AND SobjectType = 'Lead'].Id;
        recordtypePrevidenza = [SELECT Id,name FROM RecordType WHERE Name = 'Previdenza' AND SobjectType = 'Lead'].Id;
        recordtypeProtezione = [SELECT Id,name FROM RecordType WHERE Name = 'Protezione' AND SobjectType = 'Lead'].Id;
        recordtypeRisparmio = [SELECT Id,name FROM RecordType WHERE Name = 'Risparmio' AND SobjectType = 'Lead'].Id;   
        recordtypeAAIEvent = [Select Id From RecordType where sObjectType='Event' and Name='AAI - Event'].Id;
        recordtypeGenericoTask = [Select Id From RecordType where sObjectType='Task' and Name='Generico'].Id;
        */
        //[07/07/2017]JV - End
        isUpdated = false;
        LookupIds = '';
        DefaultLookup = '';
        BHoursBefore = [SELECT id FROM BusinessHours WHERE Name = 'AAI_Agency_BeforeLunch'].Id;
        BHoursAfter = [SELECT id FROM BusinessHours WHERE Name = 'AAI_Agency_AfterLunch'].Id;
        sysAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Amministratore del sistema' LIMIT 1].Id; //CAPOBIANCO_A 26/07/2017

        Lead LeadToUpdLst = [SELECT Ultima_data_di_riassegnazione__c,Contact_Date__c, Account_referente__r.Name 
                              FROM Lead 
                              WHERE Id =: leadToUpdate.Id];
        DefaultLookup = LeadToUpdLst.Account_referente__r.Name;
        if(LeadToUpdLst.Ultima_data_di_riassegnazione__c<>null){
            if(LeadToUpdLst.Contact_Date__c<>null){
                Double HoursBefore = BusinessHours.diff(BHoursBefore,LeadToUpdLst.Ultima_data_di_riassegnazione__c , LeadToUpdLst.Contact_Date__c)/3600000.0;          
                Double HoursAfter = BusinessHours.diff(BHoursAfter,LeadToUpdLst.Ultima_data_di_riassegnazione__c , LeadToUpdLst.Contact_Date__c)/3600000.0;                  
                LeadExistanceHours = HoursBefore+HoursAfter;
            }
            else{
                Double HoursBefore = BusinessHours.diff(BHoursBefore,LeadToUpdLst.Ultima_data_di_riassegnazione__c , System.today())/3600000.0;          
                Double HoursAfter = BusinessHours.diff(BHoursAfter,LeadToUpdLst.Ultima_data_di_riassegnazione__c , System.today())/3600000.0;         
                LeadExistanceHours = HoursBefore+HoursAfter;        
            }
        }
        system.debug('****Business Hours 1: ' + businessHour1 + '*****Business Hours 2: ' + businessHour2);
        errorMessage = '';
        showAlert = false; 
        this.controller = controller;
        String alertWrongContactInfo = 'È stato selezionato come stato del Lead "Contatto errato". Se si desidera proseguire con l\'operazione scegliere "Conferma" e il Lead verrà assegnato ad AXA, altrimenti scegliere "Annulla" per assegnare uno stato diverso';
        String alertDuplicatedLead = 'Il Lead non risulta duplicato come indicato nella selezione dello stato. Verrà reindirizzato alla pagina di modifica del Lead dove sarà possibile scegliere uno stato adeguato';
        String alertCallAgain = 'Non risultano presenti operazioni collegate al Lead, pertanto non è possibile scegliere lo stato "Da ricontattare". Scegliere "Crea l\'operazione" se si desidera creare una operazione per il Lead, altrimenti scegliere "Torna alla pagina di modifica" per assegnare uno stato diverso';
        String alertAppointment = 'Non risultano presenti eventi collegati al Lead, pertanto non è possibile scegliere lo stato "Appuntamento". Scegliere "Crea l\'evento" se si desidera creare un evento per il Lead, altrimenti scegliere "Torna alla pagina di modifica" per assegnare uno stato diverso'; 
        String alertStartingStatusDuplicated = 'Non è possibile effettuare alcuna modifica su un Lead il cui stato è \"Lead duplicato\"'; //CAPOBIANCO_A 26/07/2017
        String alertDuplicatingDupicatedLead = 'Con questa operazione confermi che nel CRM è già presente un lead o cliente con le stesse informazioni. Confermando l’operazione questo lead non sarà più utilizzabile mentre resterà disponibile il lead originario/cliente sul quale sarà possibile effettuare qualsiasi operazione'; //FM 27/12/2017
        String alertToBeProcessed = 'Sono stati modificati alcuni dati del lead. Per salvare le modifiche è necessario cambiare anche lo stato del lead. Per modificare lo stato torna alla pagina di modifica, altrimenti le modifiche andranno perse';
        alertMap.put('Wrong contact information',alertWrongContactInfo);
        alertMap.put('Duplicated Lead',alertDuplicatedLead);
        alertMap.put('Call again',alertCallAgain);
        alertMap.put('Appointment',alertAppointment);
        alertMap.put('Starting Status Duplicated',alertStartingStatusDuplicated); //CAPOBIANCO_A 26/07/2017
        alertMap.put('Duplicating duplicated Lead', alertDuplicatingDupicatedLead); //FM 27/12/2017
        alertMap.put('Change Status',alertToBeProcessed); //SERGER 03/01/2018
        showAlertStato = false; 
        showOption2 = true;
        showErrorStato = false;
        errorMessageStato = '';

        //CAPOBIANCO_A 26/07/2017 -- START
        if(sysAdminProfileId != null)
        {
          if(oldLead.Status == 'Duplicated Lead' && UserInfo.getProfileId() != sysAdminProfileId)
          {
            alertMessage = alertMap.get('Starting Status Duplicated');
            showAlertStato = true;
            valueButton1 = 'Torna alla pagina di dettaglio del Lead';
            showOption2 = false;
          }
        }
        //CAPOBIANCO_A 26/07/2017 -- END

    } 
    
    /**
    * Method that manages the rules for saving a Lead according to the Lead Status
    * @author: Juana Valenzuela
    * @date: 17/05/2017
    * @return PageReference according to the alert control
    */
    //CAPOBIANCO_A 24/05/2017 -- BUGFIX START
    public PageReference saveComplete(){
        
        system.debug('*****LeadToUpdate: ' + leadToUpdate);
        
        
        showError=false;
        if(String.isNotBlank(LookupIds))
            leadToUpdate.Account_referente__c = LookupIds;
        else
            leadToUpdate.Account_referente__c = null; 
        system.debug('#@#: '+leadToUpdate.Account_referente__c+ ' ||'+LookupIds);
        errorMessage='';      
        system.debug('***JV:LeadStatus- ' + leadToUpdate.Status);
        showAlertStato = false;
        //CAPOBIANCO_A 20/07/2017 -- START
        /*if(oldLead.Status == 'Duplicated Lead')
        {
        alertMessage = alertMap.get('Old Status Duplicated');
        showAlertStato = true;
        valueButton1 = 'Torna alla pagina di modifica';
        showOption2 = false;
        }
        //CAPOBIANCO_A 20/07/2017 -- END
        else
        {*/
        alertMessage = alertMap.get(leadToUpdate.Status);
        if(leadToUpdate.Status == 'Wrong contact information'){
            system.debug('***JV:IN contatto errato');
            //ALERT CONFERMA SALVATAGGIO-ANNULLA
            valueButton1 = 'Conferma';
            valueButton2 = 'Annulla';
            showOption2 = true;
            showAlertStato = true;
        }else if(leadToUpdate.Status == 'Duplicated lead'){
            system.debug('***JV:IN Lead duplicato');
            //VERIFICA DUPLICATI (BANDIERINA)
            isDuplicated = LeadManagement.verifyDuplicateLead(leadToUpdate);
            if(!isDuplicated){
                system.debug('***JV non duplicated message: ' + alertMessage);
                valueButton1 = 'Torna alla pagina di modifica';
                showOption2 = false;
                showAlertStato = true;    
            } else
            {//FM 27/12/2017
                alertMessage = alertMap.get('Duplicating duplicated Lead');
                system.debug('***FM duplicated message: ' + alertMessage);
                valueButton1 = 'Conferma';
                valueButton2 = 'Annulla'; 
                showOption2 = true; 
                showAlertStato = true;
                //leadtoUpdate.byPass_ValidationRule__c = true;
                //BOVOLENTA_D ASSIGN TO CURRENT USER IF QUEUE LEAD
                leadToUpdate = verifyAndAssignToCurrentUser(leadToUpdate);
            }                 
        }else if(leadToUpdate.Status == 'Call again' || leadToUpdate.Status == 'Appointment'){
            system.debug('***JV:IN Da ricontattare');
            //VERIFICA DEI TASK SUL LEAD
            Boolean hasActivities = verifyLeadHasActivities(leadToUpdate);
            //IF NON TASKS - ALERT CREA TASK-TORNA ALLA PAGINA DI MODIFICA
            if(!hasActivities){         
                showOption2 = true;
                showAlertStato = true;
                valueButton1 = leadToUpdate.Status == 'Call again'?'Crea l\'operazione':'Crea l\'evento';
                valueButton2 = 'Torna alla pagina di modifica';
            }
        }else if(leadToUpdate.Status == 'To be processed' && leadToUpdate.LeadSource == 'Web'){
            // Tugal Serger: US-0641
            alertMessage = alertMap.get('Change Status');
            showOption2 = true;
            showAlertStato = true;
            valueButton1 = 'Torna alla pagina di modifica';
            valueButton2 = 'Annulla ed esci';
        }else{
            showAlertStato = false;
        }      
        //} 
        system.debug('***JV show alert: ' + showAlertStato);     
        if(!showAlertStato){
            
            Id CurrentUserId = UserInfo.getuserid();
            List <UserRecordAccess> AccessList = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =: CurrentUserId AND RecordId =: leadToUpdateId];
            Boolean hasAccess = AccessList.get(0).HasEditAccess;
                
            system.debug('*****AccessList ' + AccessList);
            system.debug('*****CurrentUser ' + CurrentUserId);
            
            if(hasAccess) {
            	system.debug('*****USER HAS ACCESS ' + hasAccess);
                Database.SaveResult SaveResult = Database.update (leadToUpdate,false);
                if(SaveResult.isSuccess()){ 
                    String leadPrefix = Lead.sObjectType.getDescribe().getKeyPrefix();
                    returnUrl = '/'+leadToUpdate.Id;
                    PageReference retPage = new PageReference(returnURL);
                    return retPage;
                }
                else{
                    String stringErrors = 'Si sono verificati i seguenti errori: ';
                    for(Database.Error err : SaveResult.getErrors()){
                        stringErrors = stringErrors+'<br/>';
                        stringErrors = stringErrors+err.getMessage();   
                    }
                    System.debug('#@#@# DEBUG ERRORSTR '+stringErrors);
                    showError=true;
                    errorMessage = stringErrors; 
                    return null;                             
                }
            }
            else {
                system.debug('*****USER DOES NOT HAVE ACCESS ' + hasAccess);
                String stringErrors = 'Il lead può essere modificato solo dal titolare';
                showError=true;
                errorMessage = stringErrors;
                return null;
            }
                
        }
        return null;
    }
    
    public PageReference cancelBottom(){
        returnUrl = '/'+leadToUpdate.Id;
        PageReference retPage = new PageReference(returnURL);
        return retPage;
    }
    //CAPOBIANCO_A 24/05/2017 -- BUGFIX END   
    
    //[07/07/2017]JV - Start: Refactoring
    /*
public List<SelectOption> getsalutationList(){
list<selectoption> options = new list<selectoption>();   
options.add(new SelectOption('', '--Nessuno--'));      
try {               
Schema.DescribeFieldResult fieldResult = account.salutation.getDescribe();
list<schema.picklistentry> values = fieldResult.getPickListValues();               
for (Schema.PicklistEntry a : values) {     
if(a.getLabel() != 'Sig.ra')
options.add(new SelectOption(a.getLabel(), a.getValue()));
}           

}catch (Exception e){             
pageMessage = e.getmessage();
showMessage=true;
return null;        
//ApexPages.addMessages(e);             
}

return options; 
}
*/
    
    /*
public List<SelectOption> getgenderList(){
List<SelectOption> options = new List<SelectOption>();

Schema.DescribeFieldResult fieldResult = Schema.Lead.Gender__c.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
options.add(new SelectOption('', '--Nessuno--'));     
for( Schema.PicklistEntry f : ple)
{
options.add(new SelectOption(f.getLabel(), f.getValue()));
}       
return options;
}

public List<SelectOption> getstatocivileList(){
List<SelectOption> options = new List<SelectOption>();

Schema.DescribeFieldResult fieldResult = Schema.Lead.Stato_Civile__c.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
options.add(new SelectOption('', '--Nessuno--'));     
for( Schema.PicklistEntry f : ple)
{
options.add(new SelectOption(f.getLabel(), f.getValue()));
}       
return options;
}
*/
    
    /*
public List<SelectOption> getfigliList(){
List<SelectOption> options = new List<SelectOption>();

Schema.DescribeFieldResult fieldResult = Schema.Lead.Figli__c.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
options.add(new SelectOption('', '--Nessuno--'));     
for( Schema.PicklistEntry f : ple)
{
options.add(new SelectOption(f.getLabel(), f.getValue()));
}       
return options;
}
*/
    
    /*
public List<SelectOption> getfonteList(){
List<SelectOption> options = new List<SelectOption>();

Schema.DescribeFieldResult fieldResult = Schema.Lead.Dettaglio__c.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
options.add(new SelectOption('', '--Nessuno--'));     
for( Schema.PicklistEntry f : ple)
{
options.add(new SelectOption(f.getLabel(), f.getValue()));
}       
return options;
}
*/
    
    
    /*
    public List<SelectOption> getsourceList(){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Schema.Lead.LeadSource.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        options.add(new SelectOption('','--None--'));
        
        for( Schema.PicklistEntry f : ple)
        {
            if(f.getValue() != 'Web')
                options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
	*/
    //[07/07/2017]JV - End

    public List<SelectOption> gethourList(){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Schema.Lead.Available_Hours__C.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '--Nessuno--'));     
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<SelectOption> getorigineList(){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Schema.Lead.Landing_Page__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '--Nessuno--'));     
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    /*public List<SelectOption> getcountryList(){
List<SelectOption> options = new List<SelectOption>();

Schema.DescribeFieldResult fieldResult = Schema.Lead.Landing_Page__c .getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
options.add(new SelectOption('', '--Nessuno--'));     

for( Schema.PicklistEntry f : ple)
{
options.add(new SelectOption(f.getLabel(), f.getValue()));
}       
return options;
}

*/
    public List<SelectOption> getprovnascitaList(){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Schema.Lead.Provincia_di_nascita__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '--Nessuno--'));     
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    public List<SelectOption> getlineList(){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Schema.Lead.Line__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<SelectOption> getmotivoList(){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Schema.Lead.Motivo_di_contatto__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '--Nessuno--'));      
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    public List<SelectOption> getanimalList(){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Schema.Lead.Tipologia_animale__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '--Nessuno--'));      
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<SelectOption> getetanimalList(){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Schema.Lead.Et_animale__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '--Nessuno--'));      
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<SelectOption> getbusinessList(){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Schema.Lead.Tipologia_di_Business__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '--Nessuno--'));      
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<SelectOption> getprofessionList(){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Schema.Lead.Tipologia_Professione__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '--Nessuno--'));      
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public List<SelectOption> getCountryList(){
        list<selectoption> options = new list<selectoption>();   
        options.add(new SelectOption('', '--Nessuno--'));      
        try {          
            
            Schema.DescribeFieldResult fieldResult = Schema.Lead.CountryCode.getDescribe();
            
            list<schema.picklistentry> values = fieldResult.getPickListValues();               
            for (Schema.PicklistEntry a : values) {                  
                options.add(new SelectOption(a.getLabel(), a.getLabel()));
            }
        }catch (Exception e){             
            pageMessage = e.getmessage();
            showMessage=true;
            return null;        
        }
        return options; 
    }
    
    public pagereference changeCountry(){
        system.debug('sono entrata nel metodo');
        if(leadToUpdate.CountryCode != 'Italy' && leadToUpdate.CountryCode != 'IT' ){
            showForeignAddress = true;
            showNormalizedAddresses = false;
        }
        else{
            showForeignAddress =false;
        }
        
        return null;
    }

    public List<SelectOption> getStateList(){
        list<selectoption> options = new list<selectoption>();   
        options.add(new SelectOption('', 'Seleziona Provincia'));      
        try {          
            
            Schema.DescribeFieldResult fieldResult = Schema.Lead.StateCode.getDescribe();
            
            list<schema.picklistentry> values = fieldResult.getPickListValues();               
            for (Schema.PicklistEntry a : values) {                  
                options.add(new SelectOption(a.getLabel(), a.getLabel()));
            }           
        }catch (Exception e){             
            pageMessage = e.getmessage();
            showMessage=true;
            return null;        
            //ApexPages.addMessages(e);             
        }
        return options; 
    }
    
    /*Metodo che indica l'azione da interpredere al cliccare il primo pulsante dell'alert in base allo stato*/
    public PageReference actionOption1(){
        try{
            String leadPrefix = Lead.sObjectType.getDescribe().getKeyPrefix();  
            taskOrEvent='';
            //CAPOBIANCO_A 20/07/2017 -- START
            if(oldLead.Status == 'Duplicated Lead')
            {
                returnUrl = '/'+leadToUpdate.Id;
                PageReference retPage = new PageReference(returnURL);
                return retPage ;
            }
            //CAPOBIANCO_A 20/07/2017 -- END
            else
            {
                //STATUS = WRONG CONTACT INFORMATION
                if(leadToUpdate.Status == 'Wrong contact information'){         
                    system.debug('***JV: Contatto errato');
                    Id axaQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Group.DeveloperName = 'Coda_Lead_Contatto_Errato'].Id;            
                    leadToUpdate.TECH_Send_Email_Notification__c = false;
                    leadToUpdate.OwnerId = axaQueue;
                    
                    if(String.isNotBlank(LookupIds))
                        leadToUpdate.Account_referente__c = LookupIds;
                    else
                        leadToUpdate.Account_referente__c = null; 
                    Database.SaveResult SaveResult = Database.update (leadToUpdate,false);
                    if(SaveResult.isSuccess()){ 
                        returnUrl = '/'+leadPrefix+'/o';
                        PageReference retPage = new PageReference(returnURL);
                        return retPage ;
                    }else{
                        showAlertStato = false;
                        String stringErrors = 'Si sono verificati i seguenti errori: ';
                        for(Database.Error err : SaveResult.getErrors()){
                            stringErrors = stringErrors+'<br/>';
                            stringErrors = stringErrors+err.getMessage();   
                        }
                        System.debug('#@#@# DEBUG ERRORSTR '+stringErrors);
                        showError = true;
                        errorMessage = stringErrors; 
                        return null;                             
                    }
                    return null;                     
                }
                //STATUS = DUPLICATED LEAD
                else if(leadToUpdate.Status == 'Duplicated lead'){
                    if(!isDuplicated){
                        showAlertStato = false;
                        showErrorStato = false;
                        return null;
                    }else{ //FM 27/12/2017
                        showAlertStato = false;
                        showErrorStato = false;
                        system.debug('********Save the Lead*********');
                        Database.SaveResult SaveResult = Database.update(leadToUpdate,false);
                        if(SaveResult.isSuccess()){ 
                            returnUrl = '/'+leadPrefix+'/o';
                            PageReference retPage = new PageReference(returnURL);
                            return retPage ;
                        }else{
                            showAlertStato = false;
                            String stringErrors = 'Si sono verificati i seguenti errori: ';
                            for(Database.Error err : SaveResult.getErrors()){
                                stringErrors = stringErrors+'<br/>';
                                stringErrors = stringErrors+err.getMessage();   
                            }
                            System.debug('#@#@# DEBUG ERRORSTR '+stringErrors);
                            showError = true;
                            errorMessage = stringErrors; 
                            return null;                             
                        }
                    }
                    return null;   
                    
                }
                //STATUS = CALL AGAIN
                else if(leadToUpdate.Status == 'Call again'){
                    if(String.isNotBlank(LookupIds))
                        leadToUpdate.Account_referente__c = LookupIds;
                    else
                        leadToUpdate.Account_referente__c = null; 
                    leadToUpdate.Status = oldLead.Status;
                    Database.SaveResult SaveResult = Database.update (leadToUpdate,false);
                    if(SaveResult.isSuccess()){
                        taskOrEvent = 'Task'; 
                        return null;
                    }else{
                        showAlertStato=false;
                        String stringErrors = 'Prima di poter creare un\' attività associata, è necessario correggere i seguenti errori:';
                        for(Database.Error err : SaveResult.getErrors()){
                            stringErrors = stringErrors+'<br/>';
                            stringErrors = stringErrors+err.getMessage();   
                        }
                        showError = true;
                        errorMessage = stringErrors; 
                        return null;                             
                    }
                }
                //STATUS = APPOINTMENT
                else if(leadToUpdate.Status == 'Appointment'){
                    if(String.isNotBlank(LookupIds))
                        leadToUpdate.Account_referente__c = LookupIds;
                    else
                        leadToUpdate.Account_referente__c = null; 
                    leadToUpdate.Status = oldLead.Status;
                    Database.SaveResult SaveResult = Database.update (leadToUpdate,false);
                    if(SaveResult.isSuccess()){
                        taskOrEvent = 'Event'; 
                        return null;
                    }else{
                        showAlertStato = false;
                        String stringErrors = 'Prima di poter creare un evento associato, è necessario correggere i seguenti errori:';
                        for(Database.Error err : SaveResult.getErrors()){
                            stringErrors = stringErrors+'<br/>';
                            stringErrors = stringErrors+err.getMessage();   
                        }
                        showError = true;
                        errorMessage = stringErrors; 
                        return null;                             
                    }
                }
                //STATUS = TO BE PROCESSED
                else if(leadToUpdate.Status == 'To Be Processed'){
                    showAlertStato = false;
                    showErrorStato = false;
                    return null;
                }
                else{
                    if(String.isNotBlank(LookupIds))
                        leadToUpdate.Account_referente__c = LookupIds;
                    else
                        leadToUpdate.Account_referente__c = null; 
                    Database.SaveResult SaveResult = Database.update (leadToUpdate,false);
                    if(SaveResult.isSuccess()){ 
                        return null;
                    }
                    else{
                        String stringErrors = 'Si sono verificati i seguenti errori: ';
                        for(Database.Error err : SaveResult.getErrors()){
                            stringErrors = stringErrors+'<br/>';
                            stringErrors = stringErrors+err.getMessage();   
                        }
                        System.debug('#@#@# DEBUG ERRORSTR '+stringErrors);
                        showError = true;
                        errorMessage = stringErrors; 
                        return null;                             
                    }
                }
            }
            return null;       
        }catch(Exception e){
            showAlertStato = false;
            showErrorStato = true;
            errorMessageStato = 'Si è verificato un errore con l\'assegnazione del Lead. Le chiediamo il favore di contattare l\'IT per supporto';
            return null;
        }
    }
    
    /*Metodo che indica l'azione da interpredere al cliccare il secondo pulsante dell'alert in base allo stato*/
    public PageReference actionOption2(){
        if(leadToUpdate.Status == 'Wrong contact information' || leadToUpdate.Status == 'Call again' || leadToUpdate.Status == 'Appointment' || leadToUpdate.Status == 'Duplicated Lead'){
            showAlertStato = false;
            showErrorStato = false;
            return null;    
        }
        //STATUS = TO BE PROCESSED
        else if(leadToUpdate.Status == 'To Be Processed'){
            showAlertStato = false;
            showErrorStato = false;
            PageReference LeadPage = new PageReference('/' + leadToUpdate.ID);
            return LeadPage;
        }
        return null;
    }
    
    /*[16/05/2017]JV: Initiative: Lead-Management
    * Method that verifies if the Lead has at least one Task (Status = Da ricontattare) or Event (Status = Appuntamento) 
    * filtering by RecordType "Generico" and AAI-Event respectively
    * @updatedLead: Lead for which has been changed the Status
    * @return TRUE if the Lead has activities, FALSE otherwise
    */
    public Boolean verifyLeadHasActivities(Lead updatedLead){
        Boolean hasActivities = true;
        Id CurrentUserId = UserInfo.getuserid();
        User CurrentUser = [SELECT Id, Agency_Code__c FROM User WHERE Id =:CurrentUserId limit 1];       
        //Lead status = Da rincontattare: Verify Tasks
        if(updatedLead.Status == 'Call again'){
            Id taskGenericoRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Generico'].Id;
            Integer leadTaskNumber = [SELECT count() FROM Task WHERE RecordTypeId = :taskGenericoRecordTypeId AND Who.Id = :updatedLead.Id AND CreatedBy.Agency_Code__c =: updatedLead.Agency_Code__c]; //CAPOBIANCO_A BUGFIX 28/09 Added the check on the agency codes
            if(leadTaskNumber == 0)
                hasActivities = false;  
        }
        //Lead status = Appuntamento: Verify Events
        else if(updatedLead.Status == 'Appointment'){
            Id aaiEventRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'AAI_Event'].Id;
            Integer leadEventNumber = [SELECT count() FROM Event WHERE RecordTypeId = :aaiEventRecordTypeId AND Who.Id = :updatedLead.Id AND CreatedBy.Agency_Code__c =: updatedLead.Agency_Code__c]; //CAPOBIANCO_A BUGFIX 28/09 Added the check on the agency codes
            if(leadEventNumber == 0)
                hasActivities = false;
        }
        return hasActivities;
    }

    public lead verifyAndAssignToCurrentUser (Lead a){
      Id CurrentUserId = UserInfo.getuserid();
      User CurrentUser = [SELECT Id, Name, Profile.Name FROM User WHERE Id =:CurrentUserId limit 1];

      Lead queriedLead = [SELECT Id,TECH_Company__c FROM Lead WHERE Id=:a.id ];

      //boolean needreassignment = false;
      boolean isCurrentUserAgent = false;
      if ((CurrentUser.Profile.Name == 'AAI - Vendite Avanzato') || (CurrentUser.Profile.Name == 'AAI - Vendite Base')) {
         isCurrentUserAgent = true;
      }
      //remove the a.TECH_Company__c=='AAI' check if not sure on complete lead population
      if(queriedLead.TECH_Company__c=='AAI' && isCurrentUserAgent && String.valueOf(a.OwnerId).left(3) == '00G'  ) {//Assign to current user if it is from agency and lead is still in queue // && (a.Custom_Lead_Owner__c!= null && String.valueOf(a.Custom_Lead_Owner__c).left(3) == '00G')
        
        //reassigning to user 
        a.OwnerId=CurrentUserId;
        a.TECH_Send_Email_Notification__c=true; // inverted logic from false to true DUE TO ERROR
      }
      system.debug('+++++++++++lead: '+a);
      system.debug('+++++++++++lead company '+a.TECH_Company__c);

      return a;
    }

    public void selectSubStatus(){
        if(leadToUpdate.Status == 'Not interested')
            showSubStatus = true;
        else {
            leadToUpdate.Sottostato_del_Lead__c = null;
            showSubStatus = false;
        }
            
    }
    
    public void hideSubStatus(){
        if(LeadToUpdate.Sottostato_del_Lead__c != '' && LeadToUpdate.Sottostato_del_Lead__c != NULL)
            showSubStatus = false;
    }
    
    public pageReference saveSottoStato(){
        string SS = Apexpages.currentPage().getParameters().get('mySottoStato');
        leadToUpdate.Sottostato_del_Lead__c = SS;
        return null;
    }
    
    public List<SelectOption> getSottostatoList(){
        list<selectoption> options = new list<selectoption>();
        
        Schema.DescribeFieldResult fieldResult = Schema.Lead.Sottostato_del_lead__c.getDescribe();
        
        list<schema.picklistentry> values = fieldResult.getPickListValues();               
        for (Schema.PicklistEntry a : values)
            options.add(new SelectOption(a.getLabel(), a.getValue()));
        system.debug('PICKLIST: ' + options);
        return options;
    }
    
//////////////////////////


    @RemoteAction
    global static List<Account> queryContacts(String keyword) {
        List<Account> AccountList = new List<Account>();
        if (keyword != null && keyword.trim() != '') {
            keyword = '%' + keyword + '%';
            AccountList = [Select Id, FirstName, LastName,Name from Account where recordtype.Name in ('B2B Client','B2C Client') and Name like :keyword limit 5];
        }
        return AccountList;
    }

    public PageReference theMethod()
    {
       //leadToUpdate.Account_referente__c = LookupIds; 
        
        system.debug('****theMethod: '+LookupIds);
        return null;
    }

///////////////////////////
}
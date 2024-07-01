public class EnhancedLeadViewCTRL{
        
        public string URLBASE {set; get;}
        public Lead lead {get;set;}
        public User currentUser {get;set;}
        
        public String leadConosciutoChoice {get;set;}
        public String conversionType;
        public String ConvertedStatusValue {get;set;}
        
        public String selectedAccountID {get;set;} //A.D. 06.12.2016
        
        //public Boolean showMissingFields {get;set;}

        public String DuplicatedAccountIDValue{get;set;}
        public List<SelectOption> DuplicatedAccountPicklistValues {get;set;}
        public PageReference accountLink {get;set;}

        public Account selectedAccount {get;set;}
        public List<Account> listAccounts {get;set;}
        public map <Id, Account> duplicatedAccountMap {get;set;}
        public map <Id, Lead> duplicatedLeadMap {get;set;} 
        public id newAccountId {get;set;}   
        
        public Boolean sectionShown {get;set;}
        public Boolean leadConversionShown {get;set;}
        public Boolean showStandardLeadPage {get;set;}
        public Boolean showCustomLeadConvertPage {get;set;}
        public Boolean isLeadDuplicatedWithAccount {get;set;}
        public Boolean isLeadDuplicatedWithLead {get;set;}
        public boolean showWSresult {get;set;}
        public boolean showDebug {get;set;}
        public string DebugString {get;set;}
        public Boolean displayPopUpLead {get;set;}
        public Boolean displayPopUpResults {get;set;}
        public Boolean displayPopUpConvertedLead {get;set;}
        public Boolean displayPopUpConvertedLeadNew {get;set;}
        public Boolean displayPopUpGiuridico {get;set;}
        public Boolean displayPopUpCIFOnly {get;set;}
        public Boolean displayPopUpNoAccess {get;set;}
        public boolean displayPoPupGeneralError {get;set;}
        public Boolean displayPopUpMisalignment {get;set;}
        public Boolean displayNewRelationButton {get;set;}
      //  public Boolean displayBusinessExistingFields {get;set;}
        public string ErrorMsg {get;set;}
        public string ErrorMsgConversionType {get;set;}
        //public boolean displayPopupSuccess {get;set;}


        
        public string SelectedNDG {get;set;}
        public List<soggettoCIF> WS_Results {get;set;}
        public List<soggettoCIF> WS_Results_EXISTING {get;set;}
        public List<soggettoCIF> WS_Results_CIFONLY {get;set;}
        public List<soggettoCIF> WS_Results_NOACCESS {get;set;}
        public List<soggettoCIF> WS_Results_PG {get;set;} 
        public soggettoCIF selectedSoggettoCIF {get;set;}

        
        // objects for CIF call
        public CIF_WebServiceManagement_IE myCIFcall;
        public CIF_WebServiceManagement_IE.esitoCheckSetInfo thisLeadCheck;
        public CIF_WebServiceManagement_IE.CIF_Response CIF_response;
        public List<CIF_WebServiceManagement_IE.CIF_record> CIF_records;
        //RT Ids
        public id b2bAccountRecordTypeId;
        public id b2bcontactRecordTypeId; 

        public string accountDestName {get;set;}
        public Boolean skipAlignmentCheck;
        //Start - 001
        public Boolean displayPopUpLeadDuplicato {get;set;}
        //End - 001
        
        // The extension constructor initializes the private member
        // variable acct by using the getRecord method from the standard
        // controller. 
        public EnhancedLeadViewCTRL(ApexPages.StandardController stdController) {
            system.debug('++++++++++++++++ INIZIO COSTRUTTORE');
            accountDestName = '<Nessun cliente corrispondente individuato>';
           // displayBusinessExistingFields = false;
            String tempURL= System.URL.getCurrentRequestUrl().toExternalForm();
            URLBASE = tempURL.SPLIT('/apex/',-1).get(0);
            getRtId();
            CIF_records =new List<CIF_WebServiceManagement_IE.CIF_record>();
            this.lead = [select id,
                                AAI_Partita_IVA__c,
                                Agency_Code__c,
                                Company,
                                Fiscal_ID__c,
                                Email,
                                Deduplication_Required__c,
                                FirstName,
                                LastName,
                                Recordtypeid,
                                recordtype.DeveloperName,
                                Birth_Place__c,
                                Gender__c,
                                street,City,state,
                                Provincia_di_nascita__c,
                                Lead_Birthdate__c,
                                Nominee_Birthdate__c,
                                stateCode,
                                TECH_CIF_Status__c,
                                TECH_Lead_Processed__c,
                                OwnerId,
                                Phone,
                                TECH_DeduplicationKey__c,
                                Account_referente__c,
                                //Start - 001                                
                                Status                                
                                //End - 001
                                from lead where id = :stdController.getRecord().id];
            accountDestName = ''+this.lead.FirstName+' '+this.lead.LastName;
            this.currentUser = [select id, profileid, profile.Name from User where id = :userinfo.getUserId()];
            
            //Start - 001                        
            if(this.lead.Status == 'Duplicated Lead'){
                this.displayPopUpLeadDuplicato = true;
                this.displayPopUpLead = false;
            }else{            
            //End - 001
            //Caricamento della lista di Account con cui il Lead risulta duplicato
    //        duplicatedAccountMap = new map <Id, Account> ([SELECT Id, Name, FirstName, LastName, NDG__c, PersonMailingStreet, PersonMailingCity, PersonMobilePhone, Phone, PersonBirthdate,RecordTypeId,MobilePhone__c,BillingCity,BillingStreet FROM Account WHERE AAI_Agency_Reference_Code__c = :this.lead.Agency_Code__c AND ((FirstName = :this.lead.FirstName AND LastName = :this.lead.LastName)OR(Name = :this.lead.Company))]);
            duplicatedAccountMap = new map <Id, Account> ([SELECT Id, Name, FirstName, LastName, Salutation, NDG__c, PersonMailingStreet, PersonMailingCity, PersonMobilePhone, Phone, PersonBirthdate,RecordTypeId,MobilePhone__c,BillingCity,BillingStreet FROM Account WHERE AAI_Agency_Reference_Code__c = :this.lead.Agency_Code__c AND TECH_DeduplicationKey__c = :this.lead.TECH_DeduplicationKey__c]);

            if (duplicatedAccountMap.isEmpty()){
                this.isLeadDuplicatedWithAccount = false;
            } else {
                    //Id b2cAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Client').getRecordTypeId(); //AND RecordTypeId = :b2cAccountRecordTypeId 
                    //listAccounts = [SELECT Id, Name, FirstName, LastName, NDG__c, PersonMailingStreet, PersonMailingCity, PersonMobilePhone, Phone, PersonBirthdate,RecordTypeId,MobilePhone__c,BillingCity,BillingStreet FROM Account WHERE AAI_Agency_Reference_Code__c = :this.lead.Agency_Code__c AND ((FirstName = :this.lead.FirstName AND LastName = :this.lead.LastName)OR(Name = :this.lead.Company))];
                    listAccounts = [SELECT Id, Name, FirstName, LastName, Salutation, NDG__c, PersonMailingStreet, PersonMailingCity, PersonMobilePhone, Phone, PersonBirthdate,RecordTypeId,MobilePhone__c,BillingCity,BillingStreet FROM Account WHERE AAI_Agency_Reference_Code__c = :this.lead.Agency_Code__c AND TECH_DeduplicationKey__c = :this.lead.TECH_DeduplicationKey__c];
                    this.isLeadDuplicatedWithAccount = true;
                //    leadConosciutoChoice = '1'; add check on the deduplication flag
                    accountDestName = listAccounts[0].Name;
                   /* Id b2bAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B Client').getRecordTypeId();
                    listAccounts = [SELECT Id, Name, FirstName, LastName, NDG__c, PersonMailingStreet, PersonMailingCity, PersonMobilePhone, Phone, PersonBirthdate,RecordTypeId,MobilePhone__c FROM Account WHERE (AAI_Agency_Reference_Code__c = :this.lead.Agency_Code__c) AND RecordTypeId = :b2bAccountRecordTypeId AND ((FirstName = :this.lead.FirstName AND LastName = :this.lead.LastName)OR(Name = :this.lead.Company))];
                    displayBusinessExistingFields = true;*/
                    setDuplicatedAccountPicklistValues();      
                    
                    system.debug('++%++1setAccountLink -- selectedAccount.Id='+selectedAccount.Id);
    
                    setAccountLink(selectedAccount.Id);
                }    
                
                //Caricamento della lista di Lead con cui il Lead risulta duplicato
        //        duplicatedLeadMap = new map <Id, Lead> ([SELECT Id, FirstName, LastName FROM Lead WHERE Agency_Code__c = :this.lead.Agency_Code__c AND FirstName = :this.lead.FirstName AND LastName = :this.lead.LastName AND IsConverted=false]);
                duplicatedLeadMap = new map <Id, Lead> ([SELECT Id, FirstName, LastName FROM Lead WHERE Agency_Code__c = :this.lead.Agency_Code__c AND TECH_DeduplicationKey__c = :this.lead.TECH_DeduplicationKey__c AND IsConverted=false]);
    
                //Esclusione del Lead dalla lista dei suoi duplicati
                duplicatedLeadMap.remove(this.lead.Id);
                
                if (duplicatedLeadMap.isEmpty()){
                    this.isLeadDuplicatedWithLead = false;
                } else {
                    this.isLeadDuplicatedWithLead = true;
                    this.displayPopUpLead = true;
                //    leadConosciutoChoice = '2';
                }
            //Start - 001            
            }
            //End - 001  
            
            //Flag controlling the visibility of the LeadMenu section
            //ShowConversionTab is a variable (contained in the page URL) set by the knownLead button .
            
            
            userVisibilityCheck();
            this.showCustomLeadConvertPage = false;
        //    this.displayPopUpLead=false;
            this.showStandardLeadPage=true;
            this.displayPopUpConvertedLead=false;
            this.displayPopUpConvertedLeadNew=false;
            displayPopUpMisalignment=false;
            sectionShown=true;
            this.displayNewRelationButton = false;

            showDebug=false;
            skipAlignmentCheck = false;
     
            DebugString = '++++++Pagina inizializzata++++++';
            DebugString += '+++++LEAD+++++';
            DebugString += JSON.serializePretty(lead);
            
            DebugString += '+++++User+++++';
            DebugString += JSON.serializePretty(currentUser );

        }


        public void getRtId(){
                 
              if(b2bAccountRecordTypeId == null){
                  b2bAccountRecordTypeId = [Select id from RecordType where sObjectType = 'Account' and developerName ='B2B_Client' ].id;
              }      
              if(b2bcontactRecordTypeId == null){
                  b2bcontactRecordTypeId = [Select id from RecordType where sObjectType = 'Contact' and developerName ='B2B_Contacts' ].id;
              }
        }   
        public PageReference closeProcess (){
            system.debug('+++++++++ inizio closeProcess');
            //Not used anymore, now see TECH_CIF_Status
            // Lead tmp = new Lead( id = lead.id, TECH_CIFIntegration__c = false);
            // update tmp;
            showWSresult=false;
            //showMissingFields=false;
            showStandardLeadPage=true;
            sectionShown = false;
            showCustomLeadConvertPage=false;
            closePopupLead();
            
            system.debug('+++++++++ fine closeProcess');
            return null;
        } 

        public pagereference choiceHandler() {
            if (this.leadConosciutoChoice=='1'){
                
                this.showCustomLeadConvertPage=true;
                this.showStandardLeadPage=false;
                this.SectionShown=false;
                
            } else if (this.leadConosciutoChoice=='2'){
                this.displayPopUpLead = true;
                
            } else if (this.leadConosciutoChoice=='3'){
                conversionType = 'Physical';
                ErrorMsgconversionType = 'Persona Fisica';
                pageReference page = alignmentAndConversion();
                return page;
                

            } else if (this.leadConosciutoChoice=='4'){
                conversionType = 'Company';
                ErrorMsgconversionType = 'Persona Giuridica';
                pageReference page = alignmentAndConversion();
                return page;
            }
            return null;

        }
        public pageReference alignmentAndConversion(){ //call the checkalignments and start the conversion helper
            ErrorMsg = '';
            if (!skipAlignmentCheck)
            {
                ErrorMsg = checkLeadAlignment(conversionType);
            }
            system.debug('%%%%%%%%%%%%%%%% ErrorMsg='+ErrorMsg);
            if (ErrorMsg == ''){
                //CIF 20/12/2016 - Go To AccountSearch
                if (conversionHelper()==true){
                    system.debug('%%%%%%%%%%%%%%%% ErrorMsg='+ErrorMsg);
                    String isB2C = conversionType == 'Physical' ? 'true' : 'false';
                    string URLaddress = '/apex/AccountSearch?LeadID='+lead.id+'&isB2C='+isB2C; 
                    pageReference page = new pageReference (URLaddress);
                    page.setRedirect(true);
                    system.debug('%%%%%%%%%%%%%%%% page='+page);
                    closePopupLead();
                    system.debug('%%%%%%%%%%%%%%%% quiii');
                    return page;
                }
                else{
                    this.sectionShown=false;
                    closePopupLead();
                    return null;
                }
            }else{
                this.sectionShown=false;
                closePopupLead();
                displayPopUpMisalignment = true;
                return null;
               // this.showStandardLeadPage=false;                 
            }        
        }
        public pagereference forceConversion(){ //start the conversion helper without checking the data alignment
            displayPopUpMisalignment = false;
            //conversionHelper();
            skipAlignmentCheck = true;
            pageReference page = alignmentAndConversion();
            return page;
        }
        public boolean conversionHelper(){ //handle the infosetcheck call and start the cif call
            checkLeadInfoSet(conversionType);
            
            //Check User access
            Id CurrentUserId = UserInfo.getuserid();
            List <UserRecordAccess> AccessList = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =: CurrentUserId AND RecordId =: lead.Id];
            Boolean hasAccess = AccessList.get(0).HasEditAccess;
            if(hasAccess) {
                
                if (!thisLeadCheck.isSetComplete){
                    
                    this.showWSresult=false;
                    //this.showMissingFields=false;
                    this.showStandardLeadPage=true;
                    closeProcess();
                    
                    for (string thisField_Missing: thisLeadCheck.missing_Fields.keyset()) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,thisLeadCheck.missing_Fields.get(thisField_Missing)));
                    }
                    return false;
                } else {
                    this.sectionShown=false;
                    this.showStandardLeadPage=false;
                    closePopupLead();
                    //makeCIFcall();
                    return true;
                }
            }
            
            else {
                this.showWSresult=false;
                this.showStandardLeadPage=true;
                closeProcess();
                
                system.debug('*****USER DOES NOT HAVE ACCESS ' + hasAccess);
                String stringErrors = 'Il lead può essere modificato solo dal titolare';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,stringErrors));
                
                return false;
            }
            
        }
        public String checkLeadAlignment(String type) { //check if the information set can hint a mistake
                String error ='';
                
                if (type == 'Physical')  {
                    if (lead.AAI_Partita_IVA__c!= null){
                        error = error+' Partita IVA';
                    }
                    if (lead.Company!= null){
                        error = error+' Ragione sociale';
                    }
                } else if (type == 'Company')
                {
                    if (lead.Fiscal_ID__c!= null){
                        error = error+' Codice fiscale';
                    }
                }
                return error;
        }
       
        public Void userVisibilityCheck (){
            String allowedProfile1 = 'System Administrator';
            String allowedProfile2 = 'AAI - Vendite Avanzato';
            String allowedProfile3 = 'AAI - Vendite Base';
            String allowedProfile4 = 'Amministratore del sistema';
            String profiloCorrente = currentUser.profile.name;
            String showConversionTab= ApexPages.currentPage().getParameters().get('showConversionTab');
            
            if(profiloCorrente.equals(allowedProfile1) ||
               profiloCorrente.equals(allowedProfile2) ||
               profiloCorrente.equals(allowedProfile3) ||
               profiloCorrente.equals(allowedProfile4)){
                this.leadConversionShown= true;
            } else {
                this.leadConversionShown= false;
            }
            
        }
        
        public void convertToExisting() {//Conversion to existing account returned by CIF
        /*    system.debug('++++did we get the NDG?'+SelectedNDG);
            getselected();//populating the selected CIF

            system.debug('++++converting to existing account found on CIF AND CRM');
            //displayPopUpResults=false; //Closing table of CIF resuts
            system.debug('++++the lead before CIF call'+this.lead);
            system.debug('++++check workflow'+this.lead.TECH_Lead_Processed__c);
            //Update the TECH_Lead_Processed__c field in order to remove the lead from the Time-Based Workflow
            if (this.lead.TECH_Lead_Processed__c==false){
                this.lead.TECH_Lead_Processed__c=true;
                system.debug('++++the fields to update'+this.lead.TECH_Lead_Processed__c);
            }
            //In this case there is no need to trace the CIF call on the Account, as it was already existing
            //this.lead.TECH_CIFIntegration__c=true;//Not used anymore, see TECH_CIF_stauts__c
            if (this.lead.ownerid != userinfo.getUserId())
            {
                this.lead.ownerid = userinfo.getUserId();
            }
            update this.lead;
     
            system.debug('+++converting THE LEAD:   '+this.lead+'to the ACCOIUNT:    '+this.selectedSoggettoCIF.correspondingAccount);

            convertLeadIntoExistingAccount(lead, 'Duplicated Lead', this.selectedSoggettoCIF.correspondingAccount);
            system.debug('+++++OPENIG popup success'+this.displayPopUpConvertedLead);
            this.displayPopUpConvertedLead = true;
            checkRelationship();
            system.debug('+++++OPENIG popup success'+this.displayPopUpConvertedLead); */
        }
        
        public void ConvertToNew() {//Conversion to new account 
        /*    
            system.debug('++++did we get the NDG?'+SelectedNDG);
            getselected();//populating the selected CIF

            //displayPopUpResults=false; //Closing table of CIF resuts
            system.debug('++++the lead before CIF call'+this.lead);
            system.debug('++++check workflow'+this.lead.TECH_Lead_Processed__c);
            //Update the TECH_Lead_Processed__c field in order to remove the lead from the Time-Based Workflow
            if (this.lead.TECH_Lead_Processed__c==false){
                this.lead.TECH_Lead_Processed__c=true;
                system.debug('++++the fields to update'+this.lead.TECH_Lead_Processed__c);
            }
           
            if (this.lead.ownerid != userinfo.getUserId())
            {
                this.lead.ownerid = userinfo.getUserId();
            }
            update this.lead;
            leadUpdatefromCif();
            
            system.debug('+++converting THE LEAD:   '+this.lead);

           newAccountId = convertLeadIntoNewAccount(lead, 'Interested');
           
           //invoking future method to sort Account Owner and visibility
           list<Id> AccId = new list<Id>();
           AccId.add(newAccountId);
          
           this.displayPopUpConvertedLeadNew = true;
           checkRelationship();
           system.debug('+++++OPENIG popup success'+this.displayPopUpConvertedLeadNew);
           */
        }
        
        public void leadUpdatefromCif (){
        /*    
            system.debug('++++the lead updated from CIF'+this.selectedSoggettoCIF.UpdatedLead);
            lead tempLeadForUpdate = this.selectedSoggettoCIF.UpdatedLead;
            tempLeadForUpdate.Id = this.lead.id;
            system.debug('++++++the lead I am updating'+tempLeadForUpdate);
            if (tempLeadForUpdate.FirstName==null) {
                tempLeadForUpdate.FirstName=this.lead.FirstName;
            }
            
            if (tempLeadForUpdate.LastName==null) {
                tempLeadForUpdate.LastName=this.lead.LastName;
            }
            
            tempLeadForUpdate.TECH_Lead_Processed__c=true;
            system.debug('+++++'+selectedSoggettoCIF.AccessLevel);
            tempLeadForUpdate.TECH_CIF_Status__c=selectedSoggettoCIF.AccessLevel;
            //Already fixed outside this metod
            //tempLeadForUpdate.TECH_CIFIntegration__c=true;

            update tempLeadForUpdate; */

        }    
        
        public PageReference customLeadConversion(){//Conversion when CIF is not called and the user wants to convert to an existing ccount
            //Update the TECH_Lead_Processed__c field in order to remove the lead from the Time-Based Workflow
            /*
            this.lead.TECH_Lead_Processed__c=true;
            if (this.lead.ownerid != userinfo.getUserId())
            {
                this.lead.ownerid = userinfo.getUserId();
            }
            update this.lead;
            
            //A.D. 06.12.2016 <start>
                for (Account this_N_Item : listAccounts) {
                if (this_N_Item.Id==selectedAccountID) {
                    selectedAccount = this_N_Item;
                    }
            }
            //A.D. 06.12.2016 <end>
            
            convertLeadIntoExistingAccount(lead, 'Duplicated Lead', selectedAccount);
           // setAccountLink(selectedAccount.Id);//ADDED DB
            PageReference pageRef = new PageReference('/'+selectedAccount.Id);
            pageRef.setRedirect(true);
            
            return pageRef;
            */
            return null;
            
        }
        
        //Retrieve the ConvertedStatusLead values 
        public List<SelectOption> getConvertedLeadStatus() {
            List<SelectOption> options = new List<SelectOption>(); 
            
            for(sObject obj : [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true order by MasterLabel]) {
              String italianLabel;
                if ((String)obj.get('MasterLabel')=='Interested'){
                    italianLabel='Interessato';                
                }  else if ((String)obj.get('MasterLabel')=='Duplicated Lead'){
                    italianLabel='Lead duplicato';
                } else {
                    italianLabel=(String)obj.get('MasterLabel');
                }
              options.add( new SelectOption((String)obj.get('MasterLabel'), italianLabel));
          }
            
            return options;
        }
        
        //Definition of the Picklist with Duplicated Accounts 
         public void setDuplicatedAccountPicklistValues() {
            List<SelectOption> duplicatedAccounts = new List<SelectOption>();
            
            for (Integer i = 0; i < duplicatedAccountMap.size(); i++){
                String accountID = duplicatedAccountMap.values().get(i).Id;
                String accountName = duplicatedAccountMap.values().get(i).FirstName + ' '+ duplicatedAccountMap.values().get(i).LastName ;
                duplicatedAccounts.add( new SelectOption(accountID, accountName));
                if(i==0){
                    this.selectedAccount = duplicatedAccountMap.values().get(i);
                }            
            }        

            this.DuplicatedAccountPicklistValues=duplicatedAccounts;

        }    

                
        public void changeSelectedAccount(){
            /*
            this.selectedAccount=duplicatedAccountMap.get(this.DuplicatedAccountIDValue);
            system.debug('++%++2 setAccountLink');
            setAccountLink(selectedAccount.Id);
            */
        }
        
        
        public void setAccountLink(String accountID){

            String targetURL;
            
            String currentURL = URL.getCurrentRequestUrl().toExternalForm();
            if (currentURL.contains('agenzie')){
                targetURL = URL.getSalesforceBaseUrl().toExternalForm() + '/agenzie/' + accountID;
            } else {
                targetURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + accountID;
            }
                
            PageReference pageRef = new PageReference(targetURL);
            pageRef.setRedirect(true);
            
            system.debug('+++++++ targetURL - pageRef'+ ' '+ targetURL + ' '+ pageRef);
            
            this.accountLink = pageRef;
            
            system.debug(' ++%++accountID= '+ accountID);
            
        }
        
        public PageReference gotToExistingAccount(){
            /*
            system.debug('+++calculation redirect to existing account');
            system.debug('++++'+this.selectedSoggettoCIF.correspondingAccount);
            Sobject sobj = (sobject)  this.selectedSoggettoCIF.correspondingAccount;
            system.debug('+++thesobject to use'+ sobj);
            return  new Pagereference('/'+sobj.id);
            */
            return null;
        }
        
        public PageReference getAccountLink(){
            //Parte di codice corretta, da decommentare appena risolta la issue redirect
            //return this.accountLink;
            PageReference newocp = new PageReference('https://axaitalia.my.site.com/agenzie/0018E0000056N6xQAE');
            newocp.setRedirect(true);
        return newocp;
            
        }

        public void closePopupLead(){
            this.displayPopUpLead = false;
        }
        public void closePopupResults(){
            this.displayPopUpResults = false;
        }
        public void closePopUpConvertedLead(){
            this.displayPopUpConvertedLead=false;
        }
        public void closePopUpGiuridico(){
            this.displayPopUpGiuridico=false;
        }
        public void closePopUpCIFOnly(){
            this.displayPopUpCIFOnly=false;
        }
        public void closePopUpNoAccess(){
            this.displayPopUpNoAccess=false;
        }
        
        
        
        public void saveLeadOnly(){
        update lead;
        }
        
        public void SaveAndSubmit(){
        update lead;
        
        }        
        public void checkLeadInfoSet(String type) {

    //            myCIFcall = new CIF_WebServiceManagement_IE();
                if (type == 'Physical'){
                    myCIFcall = new CIF_WebServiceManagement_IE('CIF_Integration');
                    thisLeadCheck = myCIFcall.checkSetInfoPhysical(lead);
                } else if (type == 'Company')
                {
                    myCIFcall = new CIF_WebServiceManagement_IE('CIF_Integration_PG');
                    thisLeadCheck = myCIFcall.checkSetInfoCompany(lead);
                }
                DebugString ='+++++checkSetInfo+++++';
                DebugString += JSON.serializePretty(thisLeadCheck);

                system.debug('+++++++thisLeadCheck - isSetComplete'+thisLeadCheck.isSetComplete);
                system.debug('+++++++thisLeadCheck - missing_Fields'+ thisLeadCheck.missing_Fields.keyset());
                system.debug('+++++++thisLeadCheck - missing_Fields'+ thisLeadCheck.missing_Fields.values());
        }
        public void makeCIFcall(){
        /*
            CIF_Response = myCIFcall.MakeCIFcall(thisLeadCheck );
            system.debug('+++++'+CIF_response);
            ErrorMsg = CIF_response.EsitoLavorazione + '-' + CIF_response.Error;
            
            if (CIF_Response.EsitoLavorazione=='A000'){
                handle_0_NDG_returned(CIF_response);
                this.displayPopUpResults=false; //directly to the page for handling WS result    
                return;
            } else if  (CIF_Response.EsitoLavorazione=='A001'){
            //Creare logica per gestire la risposta CIF 0NDG --> No popup con la tabella risultati, ma messaggio avvenuta creazione account,... 
                handle_N_NDG_returned(CIF_response);//this populates the table
                this.displayPopUpResults=true; //directly to the page for handling WS result    with N NDG
                return;
            } else {
                this.displayPoPupGeneralError=true;
            }
        */
        }
        
        public void handle_0_NDG_returned(CIF_WebServiceManagement_IE.CIF_response CIF_response) {
            /*
            system.debug('++++converting to new account JUST created on CIF ');

            //Here the user does not have to input anything, the same as calling  ConvertToNew
            // first  I must populate the list of returned record with the single one
            //the list of records from the WS
            CIF_records.clear();
            CIF_records.addAll(CIF_response.returnedRecords); 
            
            //The list of records in the page
            this.WS_Results= new list<soggettoCIF>();
            this.WS_Results.clear();
            //Adding the single one returned by CIF
            SoggettoCIF thisSoggettoCIf=new SoggettoCIF(CIF_records.get(0) );
            this.WS_Results.add(thisSoggettoCIf);
            
            //I automatically select the only returned
            SelectedNDG=thisSoggettoCIf.NDG;
           
           //now it is the same as calling
           ConvertToNew();*/
        }
        
        public void handle_N_NDG_returned(CIF_WebServiceManagement_IE.CIF_response CIF_response) {
           /* CIF_records.clear();
            CIF_records.addAll(CIF_response.returnedRecords); 
                this.WS_Results= new list<soggettoCIF>();

                this.WS_Results.clear();
                this.WS_Results_CIFONLY = new list<soggettoCIF>();
                this.WS_Results_NOACCESS = new list<soggettoCIF>();
                this.WS_Results_EXISTING = new list<soggettoCIF>();
               // this.WS_Results_PG = new list<soggettoCIF>(); deprecated

                for (CIF_WebServiceManagement_IE.CIF_record thisrecord : CIF_records) {
                    SoggettoCIF thisSoggettoCIf=new SoggettoCIF(thisrecord );
                    this.WS_Results.add(thisSoggettoCIf);
                    if (thisrecord.type == 'NOACCESS')
                        this.WS_Results_NOACCESS.add(new SoggettoCIF(thisrecord ));
                    if (thisrecord.type == 'CIFONLY')
                        this.WS_Results_CIFONLY.add(new SoggettoCIF(thisrecord ));
                    if (thisrecord.type == 'EXISTING')
                        this.WS_Results_EXISTING.add(new SoggettoCIF(thisrecord ));     
                  //  }
                }
            */
        }


        public pagereference fromDuplicatedLeadtoCIFresultsPhysical(){
           // checkLeadInfoSet('Physical');
            conversionType = 'Physical';
            ErrorMsgconversionType = 'Persona Fisica';
            return alignmentAndConversion();
            
        }

        public pagereference fromDuplicatedLeadtoCIFresultsCompany(){
            conversionType = 'Company';
            ErrorMsgconversionType = 'Persona Giuridica';
            return alignmentAndConversion();           
        }    
        
        public void  getSelected() {
            /*
            System.debug('======Inside the Get Function====== the NDG is' +SelectedNDG);
            if (String.isempty(SelectedNDG)){
                SelectedNDG=ApexPages.currentPage().getParameters().get('selNDG');
            }
            for (soggettoCIF thisrecord : WS_Results) {
                if (thisrecord.NDG==SelectedNDG) {
                    thisrecord.isSelected=true;
                    this.selectedSoggettoCIF=thisrecord;
                } else {
                    thisrecord.isSelected=false;
                }
            }
            System.debug('======set this selectedSoggettoCIF====== the NDG is' +selectedSoggettoCIF);
            */
        }
        
        
        public void convertLeadIntoExistingAccount(Lead inputLead, String convertedLeadStatus, Account targetAccount){
            /*
            Database.LeadConvert lc = new Database.LeadConvert();
            //Bugfix to avoid issues on conversion with validation rule on account name changes
            inputLead.salutation = targetAccount.salutation;
            update inputLead;

            //Set Lead ID
            lc.setLeadId(inputLead.id);  
                        
            //Set Converted Lead Status
            lc.setConvertedStatus(convertedLeadStatus);
            
            //Set Account on which the lead shall be converted
            lc.setAccountId(targetAccount.Id); 
            System.debug('**********b2bAccountRecordTypeId '+b2bAccountRecordTypeId ); 
          //  String contactQuery = 'SELECT id FROM Contact WHERE AccountId = \''+targetAccount.Id+'\' AND (FirstName = \''+inputLead.FirstName+'\' AND LastName = \''+inputLead.LastName+'\') AND (Email =\''+inputLead.Email+'\' OR Phone =\''+inputLead.Phone+'\') LIMIT 1';     
            list<Contact> targetContact = [SELECT id FROM Contact WHERE AccountId = :targetAccount.Id AND (FirstName = :inputLead.FirstName AND LastName = :inputLead.LastName) AND (Email =:inputLead.Email OR Phone =:inputLead.Phone) LIMIT 1] ;
            if (targetContact.isEmpty() == false)
            {
                lc.setContactId(targetContact[0].id); 
            }
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
            System.debug('**********lcr.isSuccess()'+lcr.isSuccess());


            */
        }
        public id convertLeadIntoNewAccount(Lead inputLead, String convertedLeadStatus){
            /*
            try
            {
            Database.LeadConvert lc = new Database.LeadConvert();
            //Set Lead ID
            lc.setLeadId(inputLead.id);  
                        
            //Set Converted Lead Status
            lc.setConvertedStatus(convertedLeadStatus);
          
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
            Id accountId = lcr.getAccountId();

            shareAccount(accountId); 
            System.debug('+++++++++++accountId '+accountId );
            return accountId;
            }
            catch (Exception e)
            {
                ErrorMsg='Attenzione, si è verificato un disallineamento tra CIF e CRM. Riprovare domani.';
                System.debug('+++++++++++eccezione!'+e);
                return null;
            }
            */
            return null;
        }

        public static void shareAccount(Id accountId)
        {
            /*
            Set<Id> setSobjToFutureSharing= new Set<Id>();
            setSobjToFutureSharing.add(accountId);
            String objectShare = 'AccountShare';  
            String parentId = 'accountid';
            String rawCause = 'Manual'; 
            String accessLevelName = 'AccountAccessLevel';
            String accessLevelvalue = 'Edit'; //'None','Read','Edit','All'
            String accessLevelvalueAgency = 'Read'; //'None','Read','Edit','All'

            String separatorOfGroups= ';';
            String fieldNameOfGroup ='Nodes__c';
            String sObjectTypeFuture = 'Account';
            
            shareRecordBasedOnFieldAlternative(setSobjToFutureSharing, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups, sObjectTypeFuture);
            */
          
        }
        public static void shareRecordBasedOnFieldAlternative(Set<Id> triggernewSet, String objectShare, String parentId, String rawCause, String accessLevelName, String accessLevelvalue, String fieldNameOfGroup, String separatorFieldNameOfGroup,  String sObjectTypeFuture)
        {   
            //copy querying nodes__c instead of main node
            /*
            List<SObject> triggerNewList = Database.Query('select id, nodes_tree__c,Nodes__c from ' + sObjectTypeFuture + ' where id in :triggernewSet '); 
            Map<Id,SObject> triggerNewMap = new Map<Id,SObject>();
            for (SObject s : triggerNewList)
            {
                triggerNewMap.put(s.id, s);
                
                
            }
            system.debug('++++++++++triggerNewMap FUTURE'+triggerNewMap);
            RecordSharing.shareRecordBasedOnField(triggerNewMap, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorFieldNameOfGroup);
            */
        }
        public void checkRelationship(){
           /* if( this.lead.Account_referente__c != null)
            {
                displayNewRelationButton = true;
            }*/
        }    
        
        public class soggettoCIF {
            //Attributes to display on the page
            public String NDG {get;set;}//got it 
            public Account CorrespondingAccount {get;set;}//got it 
            public Lead UpdatedLead {get;set;}//got it 
            public boolean isSelected {get;set;}
            public String Address {get;set;}
            public String AddressBirth {get;set;}
            public date BirthDate {get;set;}
            public string LastEdit {get;set;}//*got it
            public String tipoSoggetto {get;set;}// got it 
            public String AzioneDesc {get;set;}
            public String AccessLevel {get;set;}//got it 
            public set<String> Nodes {get;set;}//got it 
            public String Name {get;set;}//got it 
            
            /*
            public soggettoCIF(CIF_WebServiceManagement_IE.CIF_record input) {

                this.NDG=input.NDG;
                this.Name =input.Name;
                this.LastEdit =input.LastEdit;
                this.AccessLevel= input.type;
                this.tipoSoggetto=input.tiposoggetto;
                this.Nodes=input.Nodes;

      
                
                
                this.isSelected=false;
                
                this.CorrespondingAccount=input.CorrespondingAccount;
                this.UpdatedLead=input.UpdatedLead;
                //Using current FN and LN if not passed from CIF
                
                if(string.isempty(input.UpdatedLead.FirstName)){
                    this.UpdatedLead.FirstName=null;
                }
                
                if(string.isempty(input.UpdatedLead.LastName)){
                    this.UpdatedLead.FirstName=null;
                }
                
                Object datiIndirizzoObj = JSONUtility.getObject(input.rawCIFrecord,'datiIndirizzo').get(0); 
                system.debug('++++++++++++datiIndirizzoObj '+datiIndirizzoObj );
                this.Address='';
                if (datiIndirizzoObj != null){
                   String Indirizzo = String.isempty(JSONUtility.getField(datiIndirizzoObj ,'indirizzo').get(0)) ? '' : JSONUtility.getField(datiIndirizzoObj ,'indirizzo').get(0);
                    
                    String Localita = String.isempty(JSONUtility.getField(datiIndirizzoObj ,'localita').get(0)) ? '' : JSONUtility.getField(datiIndirizzoObj ,'localita').get(0);
                    
                    String Provincia = String.isempty(JSONUtility.getField(datiIndirizzoObj ,'provincia').get(0)) ? '' : JSONUtility.getField(datiIndirizzoObj ,'provincia').get(0);
                    
                    this.Address=''+Indirizzo+' '+Localita+' '+Provincia;
                }
                map<string,object> rawCIFrecordMAP = (map<string,Object>) input.rawCIFrecord;
                
                Object rawSoggettoFisicoObj = JSONUtility.getObject(input.rawCIFrecord,'soggettoFisico').get(0); 
                this.AddressBirth = '';
                this.BirthDate = null;
                if (rawSoggettoFisicoObj !=null) {
                    String localitaNascita= String.isempty(JSONUtility.getField(rawSoggettoFisicoObj ,'localitaNascita').get(0)) ? '' : JSONUtility.getField(rawSoggettoFisicoObj ,'localitaNascita').get(0);
                    String provinciaNascita= String.isempty(JSONUtility.getField(rawSoggettoFisicoObj ,'provinciaNascita').get(0)) ? '' : JSONUtility.getField(rawSoggettoFisicoObj ,'provinciaNascita').get(0);
                    this.AddressBirth = localitaNascita+provinciaNascita;

                    if (JSONUtility.getField(rawSoggettoFisicoObj ,'dataNascita').get(0) !=null)
                    {
                        this.BirthDate = Date.valueof(JSONUtility.getField(rawSoggettoFisicoObj ,'dataNascita').get(0));
                        
                    }else {
                        this.BirthDate=null;
                    }

                }

                if (input.type=='NOACCESS') {
                    this.AzioneDesc = 'Cliente non visibile';
                } else {
                    if (input.type=='CIFONLY') {
                        this.AzioneDesc = 'Procedi importando l\'anagrafica esistente in CIF sul CRM';
                    } else if (input.type=='EXISTING') {
                        this.AzioneDesc = 'Converti/associa lead a cliente esistente e crea opportunità'; 
                    }
                }
                
            }
            */
        }
        
     }
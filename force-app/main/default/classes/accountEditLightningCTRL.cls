public without sharing class accountEditLightningCTRL {
  //public string profiloCorrente {get;set}
  public boolean showCustomEdit {get;set;}
  public string apexAccountId{get;set;}
  public boolean isPersonAcc{get;set;}
  public boolean jsDebug{get;set;}
  public boolean SmCenEnrAvail{get;set;}//MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1
  public String FoundcaseID{get;set;}//MOSCATELLI_M 12/04/2018: Enhancement Data Enrichment contatti
  public Static Set<String> telephoneFields = new Set<String> {
    'CIF_Work_phone__c',
    'CIF_Phone__c',
    'CIF_PersonMobilePhone__c',
    'CIF_MobilePhone__c',
    'Fax'
};

  public class GetAccountDTO {
    @AuraEnabled
    public Account currentAccount;
    @AuraEnabled
    public String telephoneWithPrefix;
  }

  public class FindModifiedFieldsGroupedDTO {
    public Map<String, BOOLEAN> fieldstatus = new Map<String, BOOLEAN>();
    public Map<String, TelephoneWithPrefix> changedTelephoneFields = new Map<String, TelephoneWithPrefix>();
  }


/*
  public accountEditLightningCTRL (ApexPages.StandardController stdController) {          
       Id user_debug_id;
       SmCenEnrAvail=false;//MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1
       
       try{
           user_debug_id = (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG') != null ? (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG').Value__c : null;
       }
       catch (Exception e)
       {
           user_debug_id = null;
       }
       if (user_debug_id != null && (user_debug_id  == UserInfo.getUserId()))
       {
           jsDebug= true;
       }
       else
       {
           jsDebug=false;
       }
       apexAccountId=ApexPages.currentPage().getParameters().get('id');

       //MOSCATELLI_M 12/04/2018: Enhancement Data Enrichment contatti -- START
       String CallID = ApexPages.currentPage().getParameters().get('PhoneCallId');

       FoundcaseID = '';

       if(String.isNotBlank(CallID))
       {
          CallID = CallID.split('_')[0];
          system.debug('CallID: '+CallID);

          Set<String> SetSC= new Set<String>();
          List<String> ListSC= new List<String>();
          
          for(Storico_Chiamate__c c : [Select Case__c from Storico_Chiamate__c where Call_ID__c =:CallID])
          {
            SetSC.add(c.Case__c);
          }

          if(SetSC.size()==1)
          {
            ListSC.addAll(SetSC);
            FoundcaseID = ListSC[0];
          }
       }
        
       //MOSCATELLI_M 12/04/2018: Enhancement Data Enrichment contatti -- END
       
       //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- START
       //Account queriedAccount = [SELECT isPersonAccount,RecordType.DeveloperName FROM Account where id = :apexAccountId limit 1];
       Account queriedAccount = [SELECT isPersonAccount,RecordType.DeveloperName,AAI_Partita_IVA__c,AAI_Codice_fiscale__c FROM Account where id = :apexAccountId limit 1];

       SmCenEnrAvail = SmartCenterEnrichmentAvailability(queriedAccount);
       //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- END

       isPersonAcc = queriedAccount.isPersonAccount;

       //Custom edit page only for B2C and B2B clients
       if (queriedAccount.RecordType.DeveloperName=='B2C_Client' || queriedAccount.RecordType.DeveloperName=='B2B_Client')
       {
          showCustomEdit = true;
       }
       else
       {
          showCustomEdit = false;
       }
  
  }*/
  public static boolean userVisibilityCheck(){
      List<String> avaiablesProfiles = new List<String>{
          'System Administrator',
          'AAI - Vendite Avanzato',
          'AAI - Vendite Base',
          'NFE - AAI - Vendite Avanzato',
          'NFE - AAI - Vendite Base',
          'Amministratore del sistema',
          'SmartCenter Motor Advisor',
          'SmartCenter Motor Manager',
          'SmartCenter Non Motor Advisor',
          'SmartCenter Non Motor Manager',
          'SmartCenter Motor Advisor - Lightning',
          'SmartCenter Motor Manager - Lightning',
          'SmartCenter Non Motor Advisor - Lightning',
          'SmartCenter Non Motor Manager - Lightning',
          'AXA MPS Business Admin',
          'AAI - Supporto HD1 BIZ - Lightning',
          'AAI - Supervisor Supporto HD1 BIZ - Lightning'
          
      };
      String profiloCorrente = [SELECT name from Profile where id = :UserInfo.getProfileId()].get(0).name;
      
      system.debug('######'+profiloCorrente );
      
      return avaiablesProfiles.contains(profiloCorrente);
  }

    @AuraEnabled
    public static Map<String, String>  getUserInfos() { 
      String UserId = UserInfo.GetUserId();
      User CurrentUser = new User();
      Boolean isDAOLAgency = true; 
      CurrentUser = [SELECT CommunityNickname, Agency_code__c, Profile.Name, Username FROM User WHERE Id=:UserId Limit 1]; // NOPMD  Fix CRUD violation
      AAI_Code_Variables__c linkdaol = [SELECT Value__c FROM AAI_Code_Variables__c WHERE Name='AccountEdit_Folderlink' LIMIT 1].get(0);  
      if(CurrentUser.Profile.Name == 'AAI - Vendite Avanzato' || CurrentUser.Profile.Name == 'AAI - Vendite Base'){
          Account AgencyAccount = [SELECT DAOL_2_0__c FROM Account WHERE Recordtype.Developername = 'Agency' AND Agency_Code__c =: CurrentUser.Agency_code__c AND Active__c=true  LIMIT 1].get(0); 
          isDAOLAgency = AgencyAccount.DAOL_2_0__c;
      }     
      Map<String, String> userinfomap = new Map<String,String>();
        
        string nickname = CurrentUser.CommunityNickname;
        string agency_code = CurrentUser.Agency_code__c;
        string link_daol = String.valueOf(linkdaol.Value__c);
        string username = CurrentUser.Username;
        String profile = CurrentUser.Profile.Name;

        userinfomap.put('nickname', nickname);
        userinfomap.put('agency_code', agency_code); 
        userinfomap.put('link_daol', link_daol);
        userinfomap.put('isDAOLAgency',String.valueOf(isDAOLAgency));
        userinfomap.put('username',username);
        userinfomap.put('profile',profile);

        system.debug('userinfomap'+userinfomap);

        return userinfomap;
    }

  
   @AuraEnabled
     public static List<String> getgender() {
     List<String> gender = new List<String>();
    
    Schema.DescribeFieldResult fieldResult = Account.Gender__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
     
      for (Schema.PicklistEntry f: ple) {
        gender.add(f.getLabel());
     
     }  

      return gender;
   }
  
  @AuraEnabled
    public static List<String> getstatus() {
    List<String> status= new List<String>();
    
    Schema.DescribeFieldResult field_status_Result = Account.CIF_Marital_Status__c.getDescribe();
    List<Schema.PicklistEntry> ple_status = field_status_Result.getPicklistValues();
     
    for (Schema.PicklistEntry f_status: ple_status) {
    status.add(f_status.getLabel());
     
     }  

    return status;
   } 
     
    public static Account dataconversion( Account deAccount) {
        if (deAccount.CIF_Marital_Status__c==null)
        System.debug ('*****deAccount.CIF_Marital_Status__c is null');
        else System.debug ('*****deAccount.CIF_Marital_Status__c is NOT null');
        string selected_status = deAccount.CIF_Marital_Status__c;
        
            if (selected_status == 'Coniugato/a'){
                deAccount.CIF_Marital_Status_code__c = '1';
            }  
            else if (selected_status == 'Celibe/Nubile'){
                deAccount.CIF_Marital_Status_code__c = '2';
            }   
            else if (selected_status == 'Divorziato/a'){
                deAccount.CIF_Marital_Status_code__c = '3';
            }  
            else if (selected_status == 'Vedovo/a'){
                deAccount.CIF_Marital_Status_code__c = '4';
            } 
            else if (selected_status == 'Separato/a'){
                deAccount.CIF_Marital_Status_code__c = '5';
            } 
            else if (selected_status == 'Non noto/a'){
                deAccount.CIF_Marital_Status_code__c = '6';
            } 
            else if (selected_status == 'Convivente'){
                deAccount.CIF_Marital_Status_code__c = '7';
            } 
            else if (selected_status == null || selected_status==''){
                deAccount.CIF_Marital_Status_code__c = ''; //null;
            } 
        
        
    return deAccount;
   }    

  @AuraEnabled
  public static List<String> getjob() {
  List<String> jobs = new List<String>();
    
      Schema.DescribeFieldResult fieldResult = Account.CIF_Job__c.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
     
      for (Schema.PicklistEntry f: ple) {
         jobs.add(f.getLabel());
      }    
      
      system.debug('***joblist'+jobs);
      return jobs;       
  }                 

  public class picklistPair { 
      @AuraEnabled public String label { get; set; }
      @AuraEnabled public String value { get; set; }
      public picklistPair(String label, String value){
          this.label = label;
          this.value = value;
      }
  }
/** PURE IT Commento per rimuovere referenza di una classe commentata
  @AuraEnabled
  public static ResponseDto getCountries() {

    AddressNormalize_UtilityClass.ResponseDto requestOutcome = new AddressNormalize_UtilityClass.ResponseDto(true, '');
    
    requestOutcome = AddressNormalize_UtilityClass.getStatiList();
    system.debug('******requestOutcomeCountries'+requestOutcome);
    ResponseDto requestCountries = new ResponseDto();
    requestCountries.isSuccess = requestOutcome.isSuccess;
    requestCountries.message = requestOutcome.message;
    //requestCountries.values = requestOutcome.values;
    
    //put the values in an array
    if (requestOutcome.isSuccess){
        List<picklistPair> valueList = new List<picklistPair>();
        for(Object s : requestOutcome.values.keySet()){
            valueList.add(new picklistPair(String.valueof(s), String.valueof(requestOutcome.values.get(s))));
        }
        requestCountries.values.put('picklistValues',valueList);
    }
    system.debug('******requestOutcomeCountries'+requestCountries);
    return requestCountries;       
  }

  @AuraEnabled
  public static ResponseDto getProvinces() {

    AddressNormalize_UtilityClass.ResponseDto requestOutcome = new AddressNormalize_UtilityClass.ResponseDto(true, '');
    
    requestOutcome = AddressNormalize_UtilityClass.getProvinceList();
    ResponseDto requestProvince = new ResponseDto();
    requestProvince.isSuccess = requestOutcome.isSuccess;
    requestProvince.message = requestOutcome.message;
    //requestCountries.values = requestOutcome.values;
    
    //put the values in an array
    if (requestOutcome.isSuccess){
        List<picklistPair> valueList = new List<picklistPair>();
        for(Object s : requestOutcome.values.keyset()){
            valueList.add(new picklistPair(String.valueof(requestOutcome.values.get(s)), String.valueof(requestOutcome.values.get(s))));
        }
        requestProvince.values.put('picklistValues',valueList);
    }
    system.debug('******requestProvince'+requestProvince);
    return requestProvince;       
  } 

  @AuraEnabled
  public static ResponseDto getCities(String currentProvince) {

    AddressNormalize_UtilityClass.ResponseDto requestOutcome = new AddressNormalize_UtilityClass.ResponseDto(true, '');
    
    requestOutcome = AddressNormalize_UtilityClass.getComuniList(currentProvince);
    ResponseDto requestCities = new ResponseDto();
    requestCities.isSuccess = requestOutcome.isSuccess;
    requestCities.message = requestOutcome.message;
    //requestCountries.values = requestOutcome.values;
    
    //put the values in an array
    if (requestOutcome.isSuccess){
        List<picklistPair> valueList = new List<picklistPair>();
        for(Object s : requestOutcome.values.keyset()){
            valueList.add(new picklistPair(String.valueof(requestOutcome.values.get(s)), String.valueof(requestOutcome.values.get(s))));
        }
        requestCities.values.put('picklistValues',valueList);
    }
    system.debug('******requestCities'+requestCities);
    return requestCities;       
  }       
  PURE IT */ 

/****/
  @AuraEnabled
  public static Lead getLead(String StringLeadId) {         
  Lead selectedLead = new Lead();
  String query = '';
  query = 'SELECT FirstName, LastName, Company, Email, Phone, Fiscal_ID__c, AAI_Partita_IVA__c, Gender__c, toLabel(Stato_civile__c), Figli__c,Account_referente__c,Id,City,Country,State,Street,PostalCode,TECH_Lead_Processed__c  FROM Lead where id = \''+StringLeadId+'\' limit 1';             
      system.debug('********query'+query );
      selectedLead = Database.query( query );                    
      system.debug('********selectedLead'+selectedLead );
      system.debug('********'+StringLeadId); 
      return selectedLead; 
      
  } 
/****/ 

  
  public static List<InsurancePolicy__c> getActiveLifePolicies(String accountId) {         
    List<InsurancePolicy__c> policies = null;
    String query = '';
    query = 'SELECT CUID__c,Id,Line__c,Status__c FROM InsurancePolicy__c WHERE CUID__c =  \''+accountId+'\' and Line__c =\'8\' and Status__c in (\'ATTIVO\',\'ATTIVA\')';             
    policies = Database.query( query );                    
    return policies; 
      
  }           

 @AuraEnabled
  public static GetAccountDTO getAccount(String StringAccountId) {
     
      // Check to make sure all fields are accessible to this user
      String[] fieldsToCheck = new String[] {
          'Id', 'Name', 'FirstName', 'LastName', 'PersonBirthdate', 
          'AnnualRevenue','CIF_Privacy_1__c'
      };
      
      Map<String,Schema.SObjectField> fieldDescribeTokens = 
          Schema.SObjectType.Account.fields.getMap();
     
      for(String field : fieldsToCheck) {
          if( ! fieldDescribeTokens.get(field).getDescribe().isAccessible()) {
              throw new System.NoAccessException();
              return null;
          }
      }
       
      
      system.debug('********'+StringAccountId);
      //describe calls can be used but are language dependant as they only return the record type label
      Boolean isPersonAccount = [SELECT isPersonAccount 
              FROM Account where id = :StringAccountId limit 1].isPersonAccount;
      Account selectedAccount = new Account();
      //List<String> fieldNames = calculateFields('Account');
      String query = '';

      if (isPersonAccount)
      { //person account

          query = 'SELECT isPersonAccount,CIF_Id_Contatto_Fax__c,CIF_Id_Contatto_PersonEmail__c,CIF_Id_Contatto_PersonMobilePhone__c,CIF_Id_Contatto_Phone__c,CIF_Id_Contatto_WorkEmail__c,CIF_Id_Contatto_WorkPhone__c,CIF_Job_code__c, CIF_Marital_Status_code__c,Id,Segment__c, NDG__c ,  Salutation,FirstName, LastName , PersonBirthdate, Place_of_birth__c,AnnualRevenue, Gender__c, CIF_Marital_Status__c, Age__c, Nodes__C, AAI_Agency_Reference_Code__c, RecordTypeId, State__c, CIF_Job__c, AAI_Codice_fiscale__c, CIF_Phone__c, CIF_PersonMobilePhone__c, Fax, CIF_Work_phone__c, CIF_PersonEmail__c, CIF_Work_email__c, CIF_Propaga_OMNIA_Phone__c, CIF_Propaga_OMNIA_PersonMobilePhone__c,CIF_Propaga_OMNIA_Fax__c,CIF_Propaga_OMNIA_Work_Phone__c,CIF_Propaga_OMNIA_PersonEmail__c,CIF_Propaga_OMNIA_Work_Email__c,Client_Index__c, Client_Index_Image__c, First_policy_subscription_date__c, First_expiration_date__c, Assurbanking__c, Codice_canale_commerciale__c, Data_inizio_assurbanking__c, Descrizione_canale_commerciale__c ,PersonMailingCity, PersonMailingPostalCode, PersonMailingState, PersonMailingStreet, PersonMailingCountry, WebSite,Promotional_privacy__c, Special_privacy__c, Third_party_transfer_privacy__c, Industrial_privacy__c, Market_research_privacy__c,CIF_PersonalEmail__c, CIF_MobilePhone__c,RecordType.Name,CIF_MobilePhone_IntPrefix__c, CIF_PersonMobilePhone_IntPrefix__c, CIF_Phone_IntPrefix__c, CIF_Work_phone_IntPrefix__c , Fax_IntPrefix__c,CIF_Privacy_1__c,CIF_Privacy_2__c,CIF_Privacy_3__c,CIF_Privacy_4__c,CIF_Privacy_5__c,CIF_Privacy_7__c,CIF_Number__c,CIF_Expiry_date__c,CIF_Mail_contact__c,Additional_Email__c,NPS__c'//Giorgio Bonifazi 06/09/2019
             +',BlackList_Abitazione__c,BlackList_Auto__c,BlackList_Aziende__c,BlackList_Commerciale__c,BlackList_Infortuni__c,BlackList_Malattia__c,BlackList_Protection__c,BlackList_Rinnovo__c,BlackList_Saving__c,BlackList_Servizio__c,Ultima_modifica_blacklist__c '
     +',CIF_Propaga_OMNIA_Mobile_Phone__c,CIF_Propaga_OMNIA_Personal_Email__c, CIF_Privacy_8__c,Comunicazioni_informative__c, CIF_OTP_Phone_contact__c, Flag_Opposizione_Tel_Princ__c, Motivo_opposizione_Tel_Princ__c, Flag_Opposizione_Tel_Cell_B2C__c, Motivo_opposizione_Tel_Cell_B2C__c, Flag_Opposizione_Fax__c, Motivo_opposizione_Fax__c, Flag_Opposizione_Tel_Uff__c, Motivo_opposizione_Tel_Uff__c, Flag_Opposizione_Email_Pers_B2C__c, Motivo_opposizione_Email_Pers_B2C__c, Flag_Opposizione_Email_Uff__c, Motivo_opposizione_Email_Uff__c '
             +'FROM Account where id = \''+StringAccountId+'\' limit 1';          
      }
      else
      { //business account, Name is updatable
        query = 'SELECT isPersonAccount,CIF_Id_Contatto_MobilePhone__c,CIF_Id_Contatto_PersonalEmail__c,CIF_Id_Contatto_Fax__c,CIF_Id_Contatto_Phone__c,CIF_Id_Contatto_WorkEmail__c,CIF_Id_Contatto_WorkPhone__c,Id, Name, NDG__c, AAI_Partita_IVA__c, Nodes__c, AAI_Agency_Reference_Code__c, AnnualRevenue, ParentId,RecordTypeId, State__c, CIF_Phone__c,CIF_MobilePhone__c, Fax, CIF_Work_phone__c, CIF_PersonalEmail__c, CIF_Work_email__c,CIF_Propaga_OMNIA_Phone__c,CIF_Propaga_OMNIA_Mobile_Phone__c,CIF_Propaga_OMNIA_Fax__c,CIF_Propaga_OMNIA_Work_Phone__c,CIF_Propaga_OMNIA_Personal_Email__c, CIF_Propaga_OMNIA_Work_Email__c, BillingStreet, BillingPostalCode,BillingCountry, BillingCity, BillingState, Promotional_privacy__c , Special_privacy__c , Third_party_transfer_privacy__c, Industrial_privacy__c, Market_research_privacy__c,CIF_Job__c,CIF_PersonMobilePhone__c,CIF_PersonEmail__c,CIF_Marital_Status__c,RecordType.Name,CIF_MobilePhone_IntPrefix__c, CIF_PersonMobilePhone_IntPrefix__c, CIF_Phone_IntPrefix__c, CIF_Work_phone_IntPrefix__c , Fax_IntPrefix__c,Client_Index__c,CIF_Privacy_1__c,CIF_Privacy_2__c,CIF_Privacy_3__c,CIF_Privacy_4__c,CIF_Privacy_5__c,CIF_Privacy_7__c,CIF_Number__c,CIF_Expiry_date__c,CIF_Mail_contact__c ' 
          +',BlackList_Abitazione__c,BlackList_Auto__c,BlackList_Aziende__c,BlackList_Commerciale__c,BlackList_Infortuni__c,BlackList_Malattia__c,BlackList_Protection__c,BlackList_Rinnovo__c,BlackList_Saving__c,BlackList_Servizio__c,Ultima_modifica_blacklist__c,Additional_Email__c '
          +',CIF_Propaga_OMNIA_PersonMobilePhone__c,CIF_Propaga_OMNIA_PersonEmail__c, CIF_Privacy_8__c, Comunicazioni_informative__c, CIF_OTP_Phone_contact__c, Flag_Opposizione_Tel_Princ__c, Motivo_opposizione_Tel_Princ__c, Flag_Opposizione_Tel_Cell_B2B__c, Motivo_opposizione_Tel_Cell_B2B__c, Flag_Opposizione_Fax__c, Motivo_opposizione_Fax__c, Flag_Opposizione_Tel_Uff__c, Motivo_opposizione_Tel_Uff__c, Flag_Opposizione_Email_Pers_B2B__c, Motivo_opposizione_Email_Pers_B2B__c, Flag_Opposizione_Email_Uff__c, Motivo_opposizione_Email_Uff__c '
  +'FROM Account WHERE id = \''+StringAccountId+'\' limit 1'; 
      }
      
      
      
      system.debug('********query'+query );
      selectedAccount = Database.query( query );
      system.debug('********selectedAccount'+selectedAccount );

      GetAccountDTO getAccountDTO = new GetAccountDTO();
      getAccountDTO.currentAccount = selectedAccount;
      getAccountDTO.telephoneWithPrefix = JSON.serialize(TelephoneWithPrefixService.getTelephoneWithPrefixMapForTelephoneFields(telephoneFields, selectedAccount));
      System.debug('### getAccountDTO.telephoneWithPrefix: ' + getAccountDTO.telephoneWithPrefix);

      return getAccountDTO ;
  }

  //FM_ 02/05/2018 : GDPR - START
 @AuraEnabled
  public static Boolean getCaseCategory(String CaseId) {
                 
      
      system.debug('********'+CaseId);


      Case myCase = new Case(); 
      Boolean isGDPRCase = false;

      List<String> GDPRCategories = new List<String>();

      for(MPS_Code_Variables__c MPSCv: MPS_Code_Variables__c.getAll().values())
      {
        if((MPSCv.Name).contains('GDPR_Category'))
          GDPRCategories.add(MPSCv.Value__c);
      }

      if(!String.isBlank(CaseId)){

      String CaseCategory = ''; 
      String query = '';

      query = 'SELECT Category__c '
          +'FROM Case WHERE Id = \''+CaseId+'\' limit 1'; 

      system.debug('******** query'+ query );
      myCase = Database.query( query );

      if(!String.isBlank(myCase.Category__c)){

      CaseCategory = myCase.Category__c;
      system.debug('********CaseCategory'+CaseCategory );

      
      
      if (GDPRCategories.contains(CaseCategory)){
          isGDPRCase = true;
              }else{
          isGDPRCase = false;      
              }
            }

    }
      return isGDPRCase;
  }
//FM_ 02/05/2018 : GDPR - END
  
  

  @AuraEnabled
  public static ResponseDto getTaskDAOL(String accountKey) {
    system.debug('++++getTaskDAOL input'+accountKey);

    SearchTaskDAOL.ResponseDto requestOutcome = new SearchTaskDAOL.ResponseDto(true, '');
    
    requestOutcome = SearchTaskDAOL.getTaskResponse(accountKey);
    ResponseDto requestOpenTask = new ResponseDto();
    requestOpenTask.isSuccess = requestOutcome.isSuccess;
    requestOpenTask.message = requestOutcome.message;
    //requestCountries.values = requestOutcome.values;
    
    //put the values in an array
    if (requestOutcome.isSuccess == true){
        
        requestOpenTask.values = requestOutcome.values;
    }
    system.debug('******requestOutcomeOpenTask'+requestOpenTask);
    return requestOpenTask;       
  } 
 


  public static void convertLeadOnAccount (Lead sourceLead, Account destinationAccount)
  {
      //Update the TECH_Lead_Processed__c field in order to remove the lead from the Time-Based Workflow
      if (sourceLead.TECH_Lead_Processed__c==false){
          sourceLead.TECH_Lead_Processed__c=true;
      }
      if (sourceLead.ownerid != userinfo.getUserId())
      {
          sourceLead.ownerid = userinfo.getUserId();
      }
      //Bugfix to avoid issues on conversion with validation rule on account name changes
      //sourceLead.salutation = destinationAccount.salutation;
      update sourceLead;

      system.debug('+++converting THE LEAD:   '+sourceLead+' on the ACCOUNT:    '+destinationAccount);

      //ResponseDto outcome = convertLeadIntoExistingAccount(sourceLead, 'Duplicated Lead', destinationAccount);
      LeadConversionQueueable leadConversion = new LeadConversionQueueable(sourceLead,'Duplicated Lead',destinationAccount,destinationAccount.Id);
      System.enqueueJob(leadConversion);
      LeadConversionManagement.handleLeadConversionOnCase(sourceLead,destinationAccount);
      //checkRelationship();
      //return outcome;

  }

  public static ResponseDto updateAccount(Account accountToSave, String campMember, String campaign, Boolean AvoidEnrich,String Phonecallid, Boolean MPSEnrichment,String CaseId) {
    
    String telephoneWithPrefixJson = JSON.serialize(TelephoneWithPrefixService.getTelephoneWithPrefixMapForTelephoneFields(telephoneFields, accountToSave));
    return updateAccount(accountToSave, telephoneWithPrefixJson, campMember, campaign, AvoidEnrich, Phonecallid,  MPSEnrichment, CaseId);
  }


  @AuraEnabled
  public static ResponseDto updateAccount(Account accountToSave, String telephoneWithPrefixJson, String campMember, String campaign, Boolean AvoidEnrich,String Phonecallid, Boolean MPSEnrichment,String CaseId) {
  //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- END
  system.debug('##Enrichment: '+campMember+' '+campaign+' '+accountToSave.Recordtype.Name+' '+AvoidEnrich+' phoneid: '+Phonecallid+' CaseId: '+CaseId);
  Map<String, TelephoneWithPrefix> telephoneWithPrefixMap = (Map<String, TelephoneWithPrefix>) JSON.deserialize(telephoneWithPrefixJson, Map<String, TelephoneWithPrefix>.Class);
  
  telephoneWithPrefixMap = TelephoneWithPrefixService.setDefaultPrefixIfNull(telephoneWithPrefixMap);
  //MOSCATELLI_M 31/07/2017: Data Enrichment--END    
      // check if profile is allowed 
      system.debug('+++++++++++++++++++++++++accountToSave'+accountToSave);
      //system.debug('##CampMemberId: '+CampMemberId);//MOSCATELLI_M 24/07/2017: Data Enrichment


      //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement--START
      List<CampaignMember> CampMemberList = new List <CampaignMember>();

      if(String.isBlank(campaign) && String.isBlank(campMember))
      {
          CampMemberList = [SELECT Id,CampaignId FROM CampaignMember where Contact.Account.Id =: AccountToSave.Id and Campaign.Recordtype.Developername = 'Data_Enrichment_Campaign' and Campaign.StartDate<=:System.Today() and Campaign.EndDate>=:System.Today() Limit 1];
          
          if(CampMemberList.size()>0)
          {
            campaign = CampMemberList[0].CampaignId;
            campMember = CampMemberList[0].Id;
          }
      }
      //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement--END
      
      if (!userVisibilityCheck()){
          ResponseDto res = new ResponseDto(false, 'User is not allowed to perform this action'); //Check if message needs to be updated
          return res;
      }
      else{
      
          //check if integration fields have changed
          
          //accountToSave = dataconversion(accountToSave);
          //added to populate the blacklist date
          //accountToSave = addBlackListDate(accountToSave);
          system.debug('********accountToSave'+accountToSave);
          
          //method to rollback contacts
          ResponseDto rollbackResponse = rollbackUnerasableFields (accountToSave);
          if (rollbackResponse.isSuccess == false)
          {
            //send to the page the account updated with the rollbacks
            return rollbackResponse;
          }

          accountToSave = setNullVoidFields (accountToSave);

          findModifiedFieldsGroupedDTO modifiedFieldsGrouped = findModifiedFieldsGrouped( accountToSave, telephoneWithPrefixMap );
          Map<String, BOOLEAN> editedFieldsMap = modifiedFieldsGrouped.fieldstatus;
          Map<String, TelephoneWithPrefix> changedTelephoneFields = modifiedFieldsGrouped.changedTelephoneFields;

          //MOSCATELLI_M 31/07/2017: Data Enrichment--START
          AccountEnrichmentUtility.DefineOutputs DOut = new AccountEnrichmentUtility.DefineOutputs();

          ResponseDto resEnrich = new ResponseDto(true, ''); //Check if message needs to be updated

          if(String.isNotBlank(campaign) && String.isNotBlank(campMember))
          {
            DOut = AccountEnrichmentUtility.CheckEnrichment(campaign, accountToSave, campMember);
            
            system.debug('#DOut: '+DOut);

            resEnrich.values.put('isEmail', DOut.UpdatedEmail);
            resEnrich.values.put('isPhone', DOut.UpdatedPhone);
            resEnrich.values.put('isConsensus', DOut.UpdatedConsensus);
            resEnrich.values.put('isOther', DOut.UpdatedOthers);
            resEnrich.values.put('List', DOut.ListFields);
            resEnrich.values.put('RelevantField', DOut.ListRelevantFields);//MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement                  
            
            if(String.isNotBlank(DOut.ErrorMsg) && !AvoidEnrich)
            {
                resEnrich.values.put('ModalMsg', DOut.ErrorMsg);
                return resEnrich;
            }
          }
          //MOSCATELLI_M 31/07/2017: Data Enrichment--END

        

          
          //set the default for the prefix values, if needed

          //accountToSave = setDefaultPrefixes (accountToSave, editedFieldsMap);
          Boolean integrationRequired = false;
          
          //check if there is an active LIFE (ASA 8) policy
          List<InsurancePolicy__c> policiesList = getActiveLifePolicies(accountToSave.Id);
   

          ResponseDto requestOutcome = new ResponseDto(true, '');
          
          for (String fieldName : editedFieldsMap.keySet()){
              if (editedFieldsMap.get(fieldName) == true )
              {
                if(fieldName != 'Comunicazioni_informative__c')
                  integrationRequired = true;
              }
          }

          if (integrationRequired == true)
          {
              //call CIF
              system.debug('********integrationRequired '+integrationRequired);
              system.debug('********editedFieldsMap = '+editedFieldsMap);
              requestOutcome = sendRequest (accountToSave,editedFieldsMap, changedTelephoneFields);//qui viene modificato accountToSave
          }
              system.debug('******** requestOutcome='+requestOutcome);
              system.debug('+++++detailDAC'+requestOutcome.values.get('esitoChiamataDAC'));
        
          //MOSCATELLI_M 15/11/2017: Elimina DAC -- START
          ResponseDto res = new ResponseDto(true, '');
          res = EvaluateResponseforUpdate (requestOutcome,accountToSave,DOut,AvoidEnrich,campaign,campMember);
          system.debug('##res: '+res.message);

          if(!res.isSuccess)
          {
            if(res.message=='Errore di integrazione con CIF - Necessario compilare tutte le privacy')
            {
              ResponseDto resResent = new ResponseDto(true, '');

              resResent = ResendRequestToCIF(accountToSave,editedFieldsMap, changedTelephoneFields, DOut,AvoidEnrich,campaign,campMember);

              res = resResent;                    
            }
          }

          //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- START
          String IdFoundCas ='';

          //MOSCATELLI_M 12/04/2018: Enhancement Data Enrichment contatti -- START
          //if(String.isNotBlank(Phonecallid) && res.isSuccess && MPSEnrichment)
          if((String.isNotBlank(Phonecallid) || String.isNotBlank(CaseId)) && res.isSuccess && MPSEnrichment)
          //MOSCATELLI_M 12/04/2018: Enhancement Data Enrichment contatti -- END
          { 
            IdFoundCas = TraceContactEnrichment(Phonecallid,editedFieldsMap,CaseId);                  
            //MOSCATELLI_M 12/04/2018: Enhancement Data Enrichment contatti -- END
          }

          if(res.isSuccess && MPSEnrichment)
            SendNotification(IdFoundCas,editedFieldsMap,accountToSave);


          //MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- END

          return res;
      }
          
   }


  //CHECK MODIFICHE con campi a due a due
 public static FindModifiedFieldsGroupedDTO findModifiedFieldsGrouped( Account accountToSave, Map<String, TelephoneWithPrefix> telephoneWithPrefixMap ) {
     Account OUTACCOUNT = [SELECT CIF_Privacy_1__c,CIF_Privacy_2__c,CIF_Privacy_3__c,CIF_Privacy_4__c,CIF_Privacy_5__c,CIF_Privacy_7__c,CIF_Mail_contact__c,CIF_Privacy_8__c,CIF_OTP_Phone_contact__c, 
     CIF_MobilePhone_IntPrefix__c,CIF_PersonMobilePhone_IntPrefix__c,CIF_Phone_IntPrefix__c,CIF_Work_phone_IntPrefix__c,Fax_IntPrefix__c,Fax,CIF_Job_code__c, CIF_Marital_Status_code__c, CIF_Work_phone__c,CIF_Work_email__c,CIF_PersonalEmail__c ,CIF_Job__c,CIF_Phone__c,CIF_PersonMobilePhone__c,CIF_MobilePhone__c,CIF_PersonEmail__c,CIF_Marital_Status__c, CIF_Number__c, CIF_Expiry_date__c,
     CIF_Propaga_OMNIA_Work_Email__c,CIF_Propaga_OMNIA_Fax__c,CIF_Propaga_OMNIA_Personal_Email__c,CIF_Propaga_OMNIA_PersonEmail__c,CIF_Propaga_OMNIA_PersonMobilePhone__c,CIF_Propaga_OMNIA_Mobile_Phone__c,CIF_Propaga_OMNIA_Phone__c,CIF_Propaga_OMNIA_Work_Phone__c,
     CIF_Id_Contatto_Fax__c,CIF_Id_Contatto_MobilePhone__c,CIF_Id_Contatto_PersonalEmail__c,CIF_Id_Contatto_PersonEmail__c,CIF_Id_Contatto_PersonMobilePhone__c,CIF_Id_Contatto_Phone__c,CIF_Id_Contatto_WorkEmail__c,CIF_Id_Contatto_WorkPhone__c, 
     Flag_Opposizione_Tel_Princ__c, Motivo_opposizione_Tel_Princ__c, Flag_Opposizione_Tel_Cell_B2C__c,Motivo_opposizione_Tel_Cell_B2C__c, Flag_Opposizione_Tel_Cell_B2B__c,Motivo_opposizione_Tel_Cell_B2B__c, Flag_Opposizione_Fax__c, Motivo_opposizione_Fax__c, Flag_Opposizione_Tel_Uff__c, Motivo_opposizione_Tel_Uff__c, Flag_Opposizione_Email_Pers_B2C__c,Motivo_opposizione_Email_Pers_B2C__c, Flag_Opposizione_Email_Pers_B2B__c, Motivo_opposizione_Email_Pers_B2B__c, Flag_Opposizione_Email_Uff__c, Motivo_opposizione_Email_Uff__c 
     FROM Account WHERE Id = :accountToSave.Id];
     List<String> editablefieldsSingle = new List<String> {'CIF_Job_code__c','CIF_Marital_Status_code__c','CIF_Work_email__c','CIF_PersonalEmail__c','CIF_Job__c','CIF_PersonEmail__c','CIF_Marital_Status__c', 'CIF_Propaga_OMNIA_Work_Email__c', 'CIF_Propaga_OMNIA_Fax__c', 'CIF_Propaga_OMNIA_Personal_Email__c', 'CIF_Propaga_OMNIA_PersonEmail__c', 'CIF_Propaga_OMNIA_PersonMobilePhone__c', 'CIF_Propaga_OMNIA_Mobile_Phone__c', 'CIF_Propaga_OMNIA_Phone__c', 'CIF_Propaga_OMNIA_Work_Phone__c'}; //,'CIF_Work_email__c','CIF_PersonalEmail__c ','CIF_Job__c','CIF_Phone','CIF_PersonMobilePhone__c','CIF_MobilePhone__c','CIF_PersonEmail__c','CIF_Marital_Status__c'
     editablefieldsSingle.add('CIF_Privacy_1__c');        // ,'CIF_Propaga_OMNIA_Work_Email__c','CIF_Propaga_OMNIA_Fax__c','CIF_Propaga_OMNIA_Personal_Email__c','CIF_Propaga_OMNIA_Personal_Email__c','CIF_Propaga_OMNIA_PersonEmail__c','CIF_Propaga_OMNIA_PersonMobilePhone__c','CIF_Propaga_OMNIA_Mobile_Phone__c','CIF_Propaga_OMNIA_Phone__c','CIF_Propaga_OMNIA_Work_Phone__c'
     editablefieldsSingle.add('CIF_Privacy_2__c');
     editablefieldsSingle.add('CIF_Privacy_3__c');
     editablefieldsSingle.add('CIF_Privacy_4__c');
     editablefieldsSingle.add('CIF_Privacy_5__c');
     editablefieldsSingle.add('CIF_Privacy_7__c');
     editablefieldsSingle.add('CIF_Mail_contact__c');
     editablefieldsSingle.add('CIF_Privacy_8__c');
     editablefieldsSingle.add('CIF_OTP_Phone_contact__c');
     editablefieldsSingle.add('Flag_Opposizione_Tel_Princ__c');        // ,'CIF_Propaga_OMNIA_Work_Email__c','CIF_Propaga_OMNIA_Fax__c','CIF_Propaga_OMNIA_Personal_Email__c','CIF_Propaga_OMNIA_Personal_Email__c','CIF_Propaga_OMNIA_PersonEmail__c','CIF_Propaga_OMNIA_PersonMobilePhone__c','CIF_Propaga_OMNIA_Mobile_Phone__c','CIF_Propaga_OMNIA_Phone__c','CIF_Propaga_OMNIA_Work_Phone__c'
     editablefieldsSingle.add('Flag_Opposizione_Tel_Cell_B2C__c');
     editablefieldsSingle.add('Flag_Opposizione_Tel_Cell_B2B__c');
     editablefieldsSingle.add('Flag_Opposizione_Fax__c');
     editablefieldsSingle.add('Flag_Opposizione_Tel_Uff__c');
     editablefieldsSingle.add('Flag_Opposizione_Email_Pers_B2C__c');
     editablefieldsSingle.add('Flag_Opposizione_Email_Pers_B2B__c');
     editablefieldsSingle.add('Flag_Opposizione_Email_Uff__c');
     editablefieldsSingle.add('Motivo_opposizione_Tel_Princ__c');
     editablefieldsSingle.add('Motivo_opposizione_Tel_Cell_B2C__c');
     editablefieldsSingle.add('Motivo_opposizione_Tel_Cell_B2B__c');
     editablefieldsSingle.add('Motivo_opposizione_Fax__c');
     editablefieldsSingle.add('Motivo_opposizione_Tel_Uff__c');
     editablefieldsSingle.add('Motivo_opposizione_Email_Pers_B2C__c');
     editablefieldsSingle.add('Motivo_opposizione_Email_Pers_B2B__c');
     editablefieldsSingle.add('Motivo_opposizione_Email_Uff__c');

     Map<String, BOOLEAN> fieldstatus =  new  Map<String, BOOLEAN>(); 

     Boolean isPreDAC = false;
    
     for (integer i=0; i<editablefieldsSingle.size(); i++){
         
         string index = editablefieldsSingle.get(i);
         system.debug('*******index ' + index);
         system.debug('*****OUTACCOUNT.get(index)'+OUTACCOUNT.get(index));
         system.debug('*****accountToSave.get(index)'+accountToSave.get(index));
        if ( OUTACCOUNT.get(index) != accountToSave.get(index)){
          system.debug('### index changed: ' + index);
              fieldstatus.put(index, true);    

              if(index == 'CIF_Privacy_8__c' && (OUTACCOUNT.get(index) == '' || OUTACCOUNT.get(index) == null || OUTACCOUNT.get(index) == 'undefined')){

                isPreDAC = true; 
              }


         }
       else{
              fieldstatus.put(index, false);   
         }
         
    }

    if(fieldstatus.get('CIF_Mail_contact__c') == true){

      fieldstatus.put('CIF_Privacy_5__c',true);
    }
    if(fieldstatus.get('CIF_OTP_Phone_contact__c') == true){

      fieldstatus.put('CIF_Privacy_8__c',true);
    }
    if(fieldstatus.get('CIF_Privacy_8__c') == true){

      fieldstatus.put('CIF_OTP_Phone_contact__c',true);
    }

    if(isPreDAC){

      fieldstatus.put('CIF_Privacy_5__c',true);
      fieldstatus.put('CIF_Privacy_7__c',true);
      if(OUTACCOUNT.CIF_Privacy_5__c == 'Sì')
        fieldstatus.put('CIF_Mail_contact__c',true);
    }

    /*for (integer i=0; i<editablefieldsPaired.size(); i++){
         
         string index = editablefieldsPaired.get(i);
         String indexPrefix = index.removeEndIgnoreCase('__c');
         indexPrefix = indexPrefix+'_IntPrefix__c';
         system.debug('*******index ' + index);
         system.debug('*****OUTACCOUNT.get(index)'+OUTACCOUNT.get(index));
         system.debug('*****accountToSave.get(index)'+accountToSave.get(index));
        if ((OUTACCOUNT.get(index) != accountToSave.get(index))|| (OUTACCOUNT.get(indexPrefix) != accountToSave.get(indexPrefix)) ){
              fieldstatus.put(index, true);

         }
       else{
              fieldstatus.put(index, false);   
         }
         
    }    */
       Map<String, TelephoneWithPrefix> oldTelephoneValues = TelephoneWithPrefixService.getTelephoneWithPrefixMapForTelephoneFields(telephoneFields, OUTACCOUNT);
       Map<String, TelephoneWithPrefix> changedTelephoneFields = TelephoneWithPrefixService.getChangedTelephoneWithPrefix(oldTelephoneValues, telephoneWithPrefixMap);

       for(String changedTelephoneField : changedTelephoneFields.keySet()) {
        fieldstatus.put(changedTelephoneField, true);
       }

       FindModifiedFieldsGroupedDTO result = new FindModifiedFieldsGroupedDTO();
       result.fieldstatus = fieldstatus;
       result.changedTelephoneFields = changedTelephoneFields;

       system.debug('*******map' + fieldstatus);  
       return result;
  } 


//rollback contacts and Propaga Omnia flag to the initial condition as contacts cant be deleted from CRM
 public static ResponseDto rollbackUnerasableFields ( Account accountToSave ) {
      Account OLDACCOUNT = [SELECT IsPersonAccount,CIF_MobilePhone_IntPrefix__c,CIF_PersonMobilePhone_IntPrefix__c,CIF_Phone_IntPrefix__c,CIF_Work_phone_IntPrefix__c,Fax_IntPrefix__c,Fax,CIF_Job_code__c, CIF_Marital_Status_code__c, CIF_Work_phone__c,CIF_Work_email__c,CIF_PersonalEmail__c ,CIF_Job__c,CIF_Phone__c,CIF_PersonMobilePhone__c,CIF_MobilePhone__c,CIF_PersonEmail__c,CIF_Marital_Status__c, 
                                    CIF_Propaga_OMNIA_Work_Email__c,CIF_Propaga_OMNIA_Fax__c,CIF_Propaga_OMNIA_Personal_Email__c,CIF_Propaga_OMNIA_PersonEmail__c,CIF_Propaga_OMNIA_PersonMobilePhone__c,CIF_Propaga_OMNIA_Mobile_Phone__c,CIF_Propaga_OMNIA_Phone__c,CIF_Propaga_OMNIA_Work_Phone__c
                            FROM Account WHERE Id = :accountToSave.Id];
      List<String> rollbackFields = new List<String> {
          'CIF_MobilePhone_IntPrefix__c',
              'CIF_PersonMobilePhone_IntPrefix__c',
              'CIF_Phone_IntPrefix__c',
              'CIF_Work_phone_IntPrefix__c',
              'Fax_IntPrefix__c',
              'CIF_Work_phone__c',
              'CIF_Work_email__c',
              'CIF_PersonalEmail__c',
              'CIF_Phone__c',
              'CIF_PersonMobilePhone__c',
              'CIF_MobilePhone__c',
              'CIF_PersonEmail__c',
              'Fax'
              }; //,'CIF_Work_email__c','CIF_PersonalEmail__c ','CIF_Job__c','CIF_Phone','CIF_PersonMobilePhone__c','CIF_MobilePhone__c','CIF_PersonEmail__c','CIF_Marital_Status__c'
      List<String> rollbackflagOmnia = new List<String> {
          'CIF_Propaga_OMNIA_Work_Email__c',
              'CIF_Propaga_OMNIA_Fax__c',
              'CIF_Propaga_OMNIA_Personal_Email__c',
              'CIF_Propaga_OMNIA_PersonEmail__c',
              'CIF_Propaga_OMNIA_PersonMobilePhone__c',
              'CIF_Propaga_OMNIA_Mobile_Phone__c',
              'CIF_Propaga_OMNIA_Phone__c',
              'CIF_Propaga_OMNIA_Work_Phone__c'
              };
      ResponseDto res = new ResponseDto(true, '');
      List<String> rollbackedFields = new List<String>();  
      Map<String,String> coupledfields = new Map<String,String>();
      coupledfields.put('CIF_Phone__c','CIF_Propaga_OMNIA_Phone__c');
      coupledfields.put('CIF_Phone_IntPrefix__c','CIF_Propaga_OMNIA_Phone__c');
      coupledfields.put('CIF_MobilePhone__c','CIF_Propaga_OMNIA_Mobile_Phone__c');
      coupledfields.put('CIF_MobilePhone_IntPrefix__c','CIF_Propaga_OMNIA_Mobile_Phone__c');            
      coupledfields.put('CIF_PersonMobilePhone__c','CIF_Propaga_OMNIA_PersonMobilePhone__c');
      coupledfields.put('CIF_PersonMobilePhone_IntPrefix__c','CIF_Propaga_OMNIA_PersonMobilePhone__c');
      coupledfields.put('Fax','CIF_Propaga_OMNIA_Fax__c');
      coupledfields.put('Fax_IntPrefix__c','CIF_Propaga_OMNIA_Fax__c');
      coupledfields.put('CIF_Work_phone__c','CIF_Propaga_OMNIA_Work_Phone__c');
      coupledfields.put('CIF_Work_phone_IntPrefix__c','CIF_Propaga_OMNIA_Work_Phone__c');
      coupledfields.put('CIF_PersonEmail__c','CIF_Propaga_OMNIA_PersonEmail__c');
      coupledfields.put('CIF_PersonalEmail__c','CIF_Propaga_OMNIA_Personal_Email__c');
      coupledfields.put('CIF_Work_email__c','CIF_Propaga_OMNIA_Work_Email__c');

    
     for (integer i=0; i<rollbackFields.size(); i++){

         string index = rollbackFields.get(i);
         system.debug('*******index ' + index);
         system.debug('*****OLDACCOUNT.get(index)'+OLDACCOUNT.get(index));
         system.debug('*****accountToSave.get(index)'+accountToSave.get(index));

        if ((OLDACCOUNT.get(index) != null && OLDACCOUNT.get(index) != '') && (accountToSave.get(index) == null || accountToSave.get(index) =='') ){
              accountToSave.put(index, OLDACCOUNT.get(index));
              system.debug('**********INDEX'+index);
              system.debug('++++++++++campo propaga omnia'+ coupledfields.get(index));
              system.debug('++++++++++valore campo propaga omnia'+OLDACCOUNT.get(coupledfields.get(index)));
              if (coupledfields.get(index) != null){
              accountToSave.put(coupledfields.get(index), OLDACCOUNT.get(coupledfields.get(index)));
              }
              res.isSuccess = false; 
              rollbackedFields.add (index);
             system.debug('*******index ' + index+' has been rolled back');
         }
         
    }

    



    if (res.isSuccess == false)
    {
      res.message = 'I campi dei recapiti non possono essere cancellati dal CRM e sono stati ripristinati al valore iniziale ';

    /*  res.message = 'I seguenti campi non possono essere cancellati dal CRM e sono stati ripristinati al valore iniziale: ';
      for (String rollField :rollbackedFields)
      {
        res.message = res.message+rollField+',';
      }
      res.message = res.message.removeEnd(',');*/
      res.message = res.message + '\nPremere nuovamente salva per confermare le altre modifiche al cliente';

      res.values.put('RollbackedAccount',accountToSave);
    }
    return res;
  } 

  //method to set blank sting fields to null
  public static account setNullVoidFields (Account accountFromPage)
  {
    List<String> editablefields = new List<String> {
        'CIF_MobilePhone_IntPrefix__c',
            'CIF_PersonMobilePhone_IntPrefix__c',
            'CIF_Phone_IntPrefix__c',
            'CIF_Work_phone_IntPrefix__c',
            'Fax_IntPrefix__c',
            'CIF_Job_code__c',
            'CIF_Marital_Status_code__c',
            'CIF_Work_phone__c',
            'CIF_Work_email__c',
            'CIF_PersonalEmail__c',
            'CIF_Job__c',
            'CIF_Phone__c',
            'CIF_PersonMobilePhone__c',
            'CIF_MobilePhone__c',
            'CIF_PersonEmail__c',
            'CIF_Marital_Status__c',
            'Fax',
            'CIF_Privacy_1__c',
            'CIF_Privacy_2__c',
            'CIF_Privacy_3__c',
            'CIF_Privacy_4__c',
            'CIF_Privacy_5__c',
            'CIF_Privacy_7__c',
            'CIF_Mail_contact__c',
            'CIF_Privacy_8__c',
            'CIF_OTP_Phone_contact__c',
            'CIF_Number__c',
            'CIF_Id_Contatto_Fax__c',
            'CIF_Id_Contatto_MobilePhone__c', 
            'CIF_Id_Contatto_PersonalEmail__c', 
            'CIF_Id_Contatto_PersonEmail__c', 
            'CIF_Id_Contatto_PersonMobilePhone__c', 
            'CIF_Id_Contatto_Phone__c', 
            'CIF_Id_Contatto_WorkEmail__c', 
            'CIF_Id_Contatto_WorkPhone__c',
            'Motivo_opposizione_Tel_Princ__c',
            'Motivo_opposizione_Tel_Cell_B2C__c',
            'Motivo_opposizione_Tel_Cell_B2B__c',
            'Motivo_opposizione_Fax__c',
            'Motivo_opposizione_Tel_Uff__c',
            'Motivo_opposizione_Email_Pers_B2B__c',
            'Motivo_opposizione_Email_Pers_B2C__c',
            'Motivo_opposizione_Email_Uff__c'
            };
     for (integer i=0; i<editablefields.size(); i++){
      string index = editablefields.get(i);
         
        if (accountFromPage.get(index) == '' ){
              accountFromPage.put(index, null);     
         }

    }

    return  accountFromPage;


  }

  //method to set the default values for international prefixes if the corresponding phone has been set
  public static account setDefaultPrefixes (Account accountToUpdate, Map<String,BOOLEAN> ModifiedFields)
  {
    List<String> phoneFields = new List<String> {
        'CIF_Work_phone__c',
            'CIF_Phone__c',
            'CIF_PersonMobilePhone__c',
            'CIF_MobilePhone__c','Fax'
            };
    for (integer i=0; i<phoneFields.size(); i++){
      String index = phoneFields.get(i);
      String indexPrefix = index.removeEndIgnoreCase('__c');
      indexPrefix = indexPrefix+'_IntPrefix__c';
      System.debug('******index to default: '+index+' fieldvalue: '+accountToUpdate.get(index));
      if (ModifiedFields.get(index)==true && ((accountToUpdate.get(indexPrefix) == null) || (accountToUpdate.get(indexPrefix) == '')))
      {
        accountToUpdate.put(indexPrefix, '+39');
        System.debug('******indexPrefix defaulted: '+indexPrefix+' fieldvalue: '+accountToUpdate.get(indexPrefix));
      }

    }
    System.debug('******acccountWithDefaultPrefixes'+accountToUpdate);
    return  accountToUpdate;
  }


 public static Account addBlackListDate( Account accountToSave ) {
     Account OUTACCOUNT = [SELECT BlackList_Abitazione__c,BlackList_Auto__c,BlackList_Aziende__c,BlackList_Infortuni__c,BlackList_Malattia__c,BlackList_Protection__c,BlackList_Saving__c,BlackList_Rinnovo__c,BlackList_Commerciale__c,BlackList_Servizio__c,Ultima_modifica_blacklist__c FROM Account WHERE Id = :accountToSave.Id];
     List<String> editablefieldsSingle = new List<String> {
         'BlackList_Abitazione__c',
             'BlackList_Auto__c',
             'BlackList_Aziende__c',
             'BlackList_Infortuni__c',
             'BlackList_Malattia__c',
             'BlackList_Protection__c',
             'BlackList_Saving__c',
             'BlackList_Rinnovo__c',
             'BlackList_Commerciale__c',
             'BlackList_Servizio__c'
             }; 
     

     Boolean hasBlacklistChanged = false;
    
     for (integer i=0; i<editablefieldsSingle.size(); i++){
         
         string index = editablefieldsSingle.get(i);
         system.debug('*******index ' + index);
         system.debug('*****OUTACCOUNT.get(index)'+OUTACCOUNT.get(index));
         system.debug('*****accountToSave.get(index)'+accountToSave.get(index));
        if (OUTACCOUNT.get(index) != accountToSave.get(index) ){
          hasBlacklistChanged = true;
        }
         
      } 
     if (hasBlacklistChanged == true )
     {
        accountToSave.Ultima_modifica_blacklist__c = Datetime.now();
     }


      return accountToSave;
  }


  public class ResponseDto { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
      @AuraEnabled public Boolean isSuccess { get; set; }
      @AuraEnabled public String message { get; set; }
      @AuraEnabled public Map<Object, Object> values { get; set; }
      public ResponseDto(Boolean isSuccess, String msg){
          this.isSuccess = isSuccess;
          this.message = msg;
          this.values = new Map<Object, Object>();
          }   

      public ResponseDto(){
          this.isSuccess = False;
          this.message = '';
          this.values = new Map<Object, Object>();
          }       
  }



  public static ResponseDto sendRequest (Account theNewAccount, Map<String,Boolean> editedFieldsMap, Map<String, TelephoneWithPrefix> changedTelephoneFields){
      Map<String,String> userinfo;
      Boolean isOneClick = editedFieldsMap.containsKey('One Click')? editedFieldsMap.get('One Click'):false;
      Boolean isUnsub = editedFieldsMap.containsKey('isFromUnsub')? editedFieldsMap.get('isFromUnsub'):false;
      String value = (AAI_Code_Variables__c.getAll()).get('DeactivateUnsubAndOneClickIntegration')?.value__c;
      Boolean stopIntegration = Boolean.valueOf(String.isNotBlank(value)? value:'false');

      if(editedFieldsMap.containsKey('isFromUnsub')){
        userinfo = UnsubMainCTRL.getUserInfos();
      }
      else
        userinfo = getUserInfos();
      system.debug('userinfo'+userinfo);

      IE_Integration_Record__c myIR = new IE_Integration_Record__c();
      myIR = CIF_Communication_Helper.PopulateIErecord(theNewAccount, editedFieldsMap,userinfo,changedTelephoneFields);
      IE_Engine myIE = new IE_Engine(myIR);
      ResponseDto res = new ResponseDto();
      
      try {
          myIE.compileRequest();
      } catch (exception e) {
          String errorsStr = 'Si è verificato un errore nel compilare la richiesta di aggiornamento verso CIF';
          system.debug('*********Eccezione e ='+e);
          res = new ResponseDto(false, errorsStr);

          return res;

      }

      try {
        if(stopIntegration && (isOneClick || isUnsub)){
          myIR.ResponseBody__c = 'Servizio bloccato per Unsubscribe e One Click';
          upsert myIR; // NOPMD  Fix CRUD violation
          res = new ResponseDto(true, '');
          return res;
        }
        else {
          myIE.sendRequest();
        }
      } catch (exception e) {
          upsert myIR; // NOPMD  Fix CRUD violation
          String errorsStr = 'Si è verificato un errore nell\'inviare la richiesta di aggiornamento verso CIF';
          res = new ResponseDto(false, errorsStr);

          return res;
          
      }
      
      try {
          myIE.interpretResponse();
          system.debug('**********json response'+myIE.JSONResponse);


          system.debug('*********theNewAccount pre = '+theNewAccount);

          res = CIF_Communication_Helper.manageEditResponse(myIE,theNewAccount, editedFieldsMap); 
          
          system.debug('*********theNewAccount Post = '+theNewAccount);

      } catch (exception e) {
          String errorsStr = 'Si è verificato un errore nella ricezione della risposta da CIF';
          res = new ResponseDto(false, errorsStr);

          return res;
      }
      
    

      return res;
      

  }

//MOSCATELLI_M 15/11/2017: Elimina DAC -- START
public static ResponseDto ResendRequestToCIF(Account accountToSave, Map<String,Boolean> editedFieldsMap,Map<String, TelephoneWithPrefix> changedTelephoneFields, AccountEnrichmentUtility.DefineOutputs DOut, Boolean AvoidEnrich, String campaign, String campMember)
{
  ResponseDto requestOutcome = new ResponseDto(true, '');
  ResponseDto res = new ResponseDto(true, '');
/*
  if(Test.isRunningTest())
  {
    Test.setMock(HttpCalloutMock.class, new AccountEditResponseB2B_Mock_Test ());       
  }
*/
  system.debug('********editedFieldsMap = '+editedFieldsMap);
  editedFieldsMap.put('CIF_Privacy_1__c',true);
  editedFieldsMap.put('CIF_Privacy_2__c',true);
  editedFieldsMap.put('CIF_Privacy_3__c',true);
  editedFieldsMap.put('CIF_Privacy_4__c',true);
  editedFieldsMap.put('CIF_Privacy_5__c',true);
  editedFieldsMap.put('CIF_Privacy_7__c',true);
  editedFieldsMap.put('CIF_Privacy_8__c',true);

  if(accountToSave.CIF_Privacy_5__c == 'Sì')
    editedFieldsMap.put('CIF_Mail_contact__c',true);

  system.debug('********editedFieldsMap = '+editedFieldsMap);
  requestOutcome = sendRequest (accountToSave,editedFieldsMap, changedTelephoneFields);

  system.debug('******** requestOutcome='+requestOutcome);
  system.debug('+++++detailDAC'+requestOutcome.values.get('esitoChiamataDAC'));

  res = EvaluateResponseforUpdate (requestOutcome,accountToSave,DOut,AvoidEnrich,campaign,campMember);

  return res;
}

public static ResponseDto EvaluateResponseforUpdate (ResponseDto requestOutcome,Account accountToSave,AccountEnrichmentUtility.DefineOutputs DOut, Boolean AvoidEnrich, String campaign, String campMember)
{
  if (requestOutcome.isSuccess)
  {
    system.debug('******** requestOutcome in IsSuccess - accountToSave='+accountToSave);
    system.debug('******** acc returned by CIF returnedCIFAccount='+ requestOutcome.values.get('returnedCIFAccount'));


    Database.SaveResult SaveResult = database.update (accountToSave,false);


    system.debug('********SaveResult='+SaveResult );
    
    if (SaveResult.isSuccess())
    { 
      system.debug('##DOut2: '+DOut);
      
      if((String.isBlank(DOut.ErrorMsg) || AvoidEnrich) && String.isNotBlank(campaign) && String.isNotBlank(campMember))
        AccountEnrichmentUtility.UpdateMember(DOut.UpdatedEmail,DOut.UpdatedPhone,DOut.UpdatedConsensus,DOut.UpdatedOthers,campMember);

      ResponseDto res = new ResponseDto(true, '');
      res.values.put('AccountID', SaveResult.getId());
      system.debug('+++++detailDAC'+requestOutcome.values.get('esitoChiamataDAC'));
      res.values.put('esitoChiamataDAC', requestOutcome.values.get('esitoChiamataDAC'));
      return res;
    }
    else
    {
      system.debug ('********saveresult error flow');
      String errorsStr = 'Si sono verificati i seguenti errori: ';
            
      for(Database.Error err : SaveResult.getErrors())
      {
        errorsStr = errorsStr+'\n';
        errorsStr = errorsStr+err.getStatusCode() + ': ' + err.getMessage();
        errorsStr = errorsStr+' Campi con questo errore: ' + err.getFields();
        System.debug(errorsStr); 
      }


      ResponseDto res = new ResponseDto(false, errorsStr);
      return res;
    }
  } 
  else
  {
    String errorsStr = requestOutcome.message;
    ResponseDto res = new ResponseDto(false, errorsStr);
    system.debug('*******in errore - res='+res);          
    return res;
  }        
}


public static String TraceContactEnrichment(String PhoneCallId, Map<String,Boolean>editedFieldsMap,String ProvidedCaseId)
{
  List<Storico_Chiamate__c> StoricoList = new list<Storico_Chiamate__c>();
  String CaseId='';

  if(String.isNotBlank(ProvidedCaseId))
    CaseId = ProvidedCaseId;
  StoricoList = [Select Id,Case__c from Storico_Chiamate__c where Call_ID__c =:PhoneCallId];

  Boolean PhoneCanged = false;
  Boolean EmailChanged = false;
  Boolean AddressChanged = false;
  Boolean Privacy1Changed = false;
  Boolean Privacy2Changed = false;
  Boolean Privacy3Changed = false;
  Boolean Privacy4Changed = false;
  Boolean Privacy5Changed = false;
  Boolean Privacy7Changed = false;

  system.debug('####editedFieldsMap: '+editedFieldsMap);

  if(StoricoList.size()==1 || String.isNotBlank(CaseId))       
  {
    if(String.isBlank(CaseId))
      CaseId = (String.isNotBlank(StoricoList[0].Case__c))?StoricoList[0].Case__c:'';

    if(editedFieldsMap.get('CIF_Phone__c') || 
      editedFieldsMap.get('CIF_PersonMobilePhone__c') ||
      editedFieldsMap.get('CIF_Work_phone__c') ||
      editedFieldsMap.get('CIF_MobilePhone__c'))
    {
      PhoneCanged = true;
    }

    if(editedFieldsMap.get('CIF_PersonEmail__c') || 
      editedFieldsMap.get('CIF_Work_email__c') ||
      editedFieldsMap.get('CIF_PersonalEmail__c'))
    {
      EmailChanged = true;
    }
    

    //FM_24/05/2018 : GDPR -- START
     if(editedFieldsMap.get('CIF_Privacy_1__c'))
        Privacy1Changed = true;

     if(editedFieldsMap.get('CIF_Privacy_2__c'))
        Privacy2Changed = true;

     if(editedFieldsMap.get('CIF_Privacy_3__c'))
        Privacy3Changed = true;

     if(editedFieldsMap.get('CIF_Privacy_4__c'))
        Privacy4Changed = true;

     if(editedFieldsMap.get('CIF_Privacy_5__c'))
        Privacy5Changed = true;

     if(editedFieldsMap.get('CIF_Privacy_7__c'))
        Privacy7Changed = true;



    if(PhoneCanged || 
      EmailChanged || 
      AddressChanged || 
      Privacy1Changed ||
      Privacy2Changed ||
      Privacy3Changed ||
      Privacy4Changed ||
      Privacy5Changed ||
      Privacy7Changed )

    {
      Case c = new Case(Id=CaseId,
                        Data_Enrichment_Performed__c=true,
                        Email_Modified__c=EmailChanged,
                        Phone_Modified__c=PhoneCanged,
                        Address_Modified__c=AddressChanged,
                        Privacy1_Modified__c=Privacy1Changed,
                        Privacy2_Modified__c=Privacy2Changed, 
                        Privacy3_Modified__c=Privacy3Changed,
                        Privacy4_Modified__c=Privacy4Changed,
                        Privacy5_Modified__c=Privacy5Changed,
                        Privacy7_Modified__c=Privacy7Changed);
       //FM_24/05/2018 : GDPR -- END
      //MOSCATELLI_M 12/04/2018: Enhancement Data Enrichment contatti -- START
      if(StoricoList.size()==1)
      {
        Storico_Chiamate__c sc = new Storico_Chiamate__c(Id=StoricoList[0].Id,Email_Modified__c=EmailChanged,Phone_Modified__c=PhoneCanged,Address_Modified__c=AddressChanged);          
      
        try
        {
          update sc; // NOPMD  Fix CRUD violation
        }
        catch(exception ex)
        {
          system.debug('##Errore sc: '+ex);
        }
      }
      //MOSCATELLI_M 12/04/2018: Enhancement Data Enrichment contatti -- END

      try
      {
        update c;
      }
      catch(exception ex)
      {
        system.debug('##Errore c: '+ex);
      }            
    }
  }

  return CaseId;
} 


public static boolean SmartCenterEnrichmentAvailability (Account queriedAccount)
{
  Boolean enabled = false;

  String SmartProfile1 = 'SmartCenter Motor Advisor';
  String SmartProfile2 = 'SmartCenter Motor Manager';
  String SmartProfile3 = 'SmartCenter Non Motor Advisor';
  String SmartProfile4 = 'SmartCenter Non Motor Manager'; 
  String SmartProfile5 = 'AXA MPS Business Admin';
  String SysAdmProfile = 'System Administrator';

  if(Test.isRunningTest())
    SmartProfile5 = 'System Administrator';          

  List<Account> AccList = new List<Account>();

  String profiloCorrente = [SELECT name from Profile where id = :UserInfo.getProfileId()].get(0).name;

  if(profiloCorrente.equals(SmartProfile1)||
     profiloCorrente.equals(SmartProfile2)||
     profiloCorrente.equals(SmartProfile3)||
     profiloCorrente.equals(SmartProfile4)||
     profiloCorrente.equals(SmartProfile5)||
     profiloCorrente.equals(SysAdmProfile) )
  {         
    if(queriedAccount.RecordType.DeveloperName=='B2C_Client' || queriedAccount.RecordType.DeveloperName=='B2B_Client')
    {
      if(String.isNotBlank(queriedAccount.AAI_Partita_IVA__c) || String.isNotBlank(queriedAccount.AAI_Codice_fiscale__c))
      {
        system.debug('##Q: '+queriedAccount.AAI_Partita_IVA__c+'______'+queriedAccount.AAI_Codice_fiscale__c);

        String partitaIva = queriedAccount.AAI_Partita_IVA__c;
        String codiceFiscale = queriedAccount.AAI_Codice_fiscale__c;

        String querystr = 'Select Id from Account where ';

        if(String.isNotBlank(partitaIva))
        {
          querystr+=' AAI_Partita_IVA__c= :partitaIva OR Partita_IVA__c = :partitaIva limit 2';
        }
        else if(String.isNotBlank(codiceFiscale))
        {
          querystr+=' AAI_Codice_fiscale__c = :codiceFiscale OR AAI_Partita_IVA__c = :codiceFiscale OR Fiscal_ID__c = :codiceFiscale OR Partita_IVA__c = :codiceFiscale limit 2';
        }

        system.debug('##querystr: '+querystr); 

        AccList = Database.query(querystr);

        system.debug('##AccList: '+AccList);

        if(AccList.size()==1)
          enabled = true;
      }
    }
  }
  return enabled;
}

public static void SendNotification(String IdFoundCas,Map<String,Boolean>editedFieldsMap,Account accountToSave)
{
  Map<string,Id> mapAccountRT = AP_Constants.getDeveloperIdMap('Account');
  List<String> AddressesLst = new List<String>();  
  Boolean isUserLst = false;
  String SenderID = [Select id from OrgWideEmailAddress where DisplayName='Servizio Clienti AXA Assicurazioni' limit 1].Id;

  AddressesLst = RetrieveAddresses(accountToSave.AAI_Agency_Reference_Code__c);

  system.debug('##AddressesList: '+AddressesLst);

  if(AddressesLst.size()>0)
  {
    for(String s : AddressesLst)
    {
      if(String.valueOf(s).left(3)=='005')
      {
        isUserLst = true;
        break;
      }
    }

    try
    {       
      EmailTemplate etem = new EmailTemplate();
      String ModifiedContacts='';
      String TypeOfMod='';
      String ModifiedPrivacy = '';
      String AddressRequested='';

      if(accountToSave.RecordTypeId==mapAccountRT.get('B2C_Client'))
      {
        if(editedFieldsMap.get('CIF_Phone__c') || editedFieldsMap.get('CIF_PersonMobilePhone__c') || editedFieldsMap.get('CIF_Work_phone__c'))
        {           
          if(editedFieldsMap.get('CIF_Phone__c') && String.isNotBlank(accountToSave.CIF_Phone__c))
            ModifiedContacts='<br/>- Il nuovo numero di telefono principale è: '+accountToSave.CIF_Phone__c+'<br/>';
          if(editedFieldsMap.get('CIF_PersonMobilePhone__c') && String.isNotBlank(accountToSave.CIF_PersonMobilePhone__c))
            ModifiedContacts+='<br/>- Il nuovo numero di telefono cellulare é: '+accountToSave.CIF_PersonMobilePhone__c+'<br/>';
          if(editedFieldsMap.get('CIF_Work_phone__c') && String.isNotBlank(accountToSave.CIF_Work_phone__c))
            ModifiedContacts+='<br/>- Il nuovo numero del telefono dell\'ufficio è: '+accountToSave.CIF_Work_phone__c+'<br/>';              

            TypeOfMod='contatto telefonico';
        }

        if(editedFieldsMap.get('CIF_PersonEmail__c') || editedFieldsMap.get('CIF_Work_email__c'))
        {
          if(editedFieldsMap.get('CIF_PersonEmail__c') && String.isNotBlank(accountToSave.CIF_PersonEmail__c))
            ModifiedContacts+='<br/>- La nuova email é: '+accountToSave.CIF_PersonEmail__c+'<br/>';
          if(editedFieldsMap.get('CIF_Work_email__c') && String.isNotBlank(accountToSave.CIF_Work_email__c))
            ModifiedContacts+='<br/>- La nuova email dell\'ufficio è: '+accountToSave.CIF_Work_email__c+'<br/>';              

            if(String.isNotBlank(TypeOfMod))
              TypeOfMod+=' / email';
            else
              TypeOfMod='contatto email';                
        }
      }
      else if(accountToSave.RecordTypeId==mapAccountRT.get('B2B_Client'))
      {
        if(editedFieldsMap.get('CIF_Phone__c') || editedFieldsMap.get('CIF_MobilePhone__c') || editedFieldsMap.get('CIF_Work_phone__c'))
        {  
          if(editedFieldsMap.get('CIF_Phone__c') && String.isNotBlank(accountToSave.CIF_Phone__c))
            ModifiedContacts='<br/>- Il nuovo numero di telefono principale è: '+accountToSave.CIF_Phone__c+'<br/>';
          if(editedFieldsMap.get('CIF_MobilePhone__c') && String.isNotBlank(accountToSave.CIF_MobilePhone__c))
            ModifiedContacts+='<br/>- Il nuovo numero di telefono cellulare é: '+accountToSave.CIF_MobilePhone__c+'<br/>';
          if(editedFieldsMap.get('CIF_Work_phone__c') && String.isNotBlank(accountToSave.CIF_Work_phone__c))
            ModifiedContacts+='<br/>- Il nuovo numero del telefono dell\'ufficio è: '+accountToSave.CIF_Work_phone__c+'<br/>';              

            TypeOfMod='contatto telefonico';
        }

        if(editedFieldsMap.get('CIF_PersonalEmail__c') || editedFieldsMap.get('CIF_Work_email__c'))
        {
          if(editedFieldsMap.get('CIF_PersonalEmail__c') && String.isNotBlank(accountToSave.CIF_PersonalEmail__c))
            ModifiedContacts+='<br/>- La nuova email é: '+accountToSave.CIF_PersonalEmail__c+'<br/>';
          if(editedFieldsMap.get('CIF_Work_phone__c') && String.isNotBlank(accountToSave.CIF_Work_email__c))
            ModifiedContacts+='<br/>- La nuova email dell\'ufficio è: '+accountToSave.CIF_Work_email__c+'<br/>';              

            if(String.isNotBlank(TypeOfMod))
              TypeOfMod+=' / email';
            else
              TypeOfMod='contatto email';                
        }            
      }

      //FM_24/05/2018 : GDPR -- START
      if(editedFieldsMap.get('CIF_Privacy_1__c') ||
         editedFieldsMap.get('CIF_Privacy_2__c') ||
         editedFieldsMap.get('CIF_Privacy_3__c') || 
         editedFieldsMap.get('CIF_Privacy_4__c') ||
         editedFieldsMap.get('CIF_Privacy_5__c') ||
         editedFieldsMap.get('CIF_Privacy_7__c') ||
         editedFieldsMap.get('CIF_Mail_contact__c')){


        if(editedFieldsMap.get('CIF_Privacy_1__c') && String.isNotBlank(accountToSave.CIF_Privacy_1__c))
            ModifiedPrivacy+='<br/>- Il nuovo valore del consenso \'Trattamento dei dati personali\' é: '+accountToSave.CIF_Privacy_1__c+'<br/>';
        if(editedFieldsMap.get('CIF_Privacy_2__c') && String.isNotBlank(accountToSave.CIF_Privacy_2__c))
            ModifiedPrivacy+='<br/>- Il nuovo valore del consenso \'Attività promozionali e di vendita\' é: '+accountToSave.CIF_Privacy_2__c+'<br/>';
        if(editedFieldsMap.get('CIF_Privacy_3__c') && String.isNotBlank(accountToSave.CIF_Privacy_3__c))
            ModifiedPrivacy+='<br/>- Il nuovo valore del consenso \'Ricerche di mercato\' é: '+accountToSave.CIF_Privacy_3__c+'<br/>';
        if(editedFieldsMap.get('CIF_Privacy_4__c') && String.isNotBlank(accountToSave.CIF_Privacy_4__c))
            ModifiedPrivacy+='<br/>- Il nuovo valore del consenso \'Att promoz-vendita-ric merc di partner\' é: '+accountToSave.CIF_Privacy_4__c+'<br/>';
        if(editedFieldsMap.get('CIF_Privacy_5__c') && String.isNotBlank(accountToSave.CIF_Privacy_5__c))
            ModifiedPrivacy+='<br/>- Il nuovo valore del consenso \'Invio documentazione in formato digitale\' é: '+accountToSave.CIF_Privacy_5__c+'<br/>';
        if(editedFieldsMap.get('CIF_Mail_contact__c') && String.isNotBlank(accountToSave.CIF_Mail_contact__c))
            ModifiedPrivacy+='<br/>- La nuova email legata al consenso \'Invio documentazione in formato digitale\' é: '+accountToSave.CIF_Mail_contact__c+'<br/>';
        if(editedFieldsMap.get('CIF_Privacy_7__c') && String.isNotBlank(accountToSave.CIF_Privacy_7__c))
            ModifiedPrivacy+='<br/>- Il nuovo valore del consenso \'Utilizzo della firma grafometrica\' é: '+accountToSave.CIF_Privacy_7__c+'<br/>';
     

        if(String.isNotBlank(TypeOfMod))
              TypeOfMod+=' e consenso';
            else
              TypeOfMod='consenso';

      }

      if(String.isNotBlank(TypeOfMod) && (String.isNotBlank(ModifiedContacts) || (String.isNotBlank(ModifiedPrivacy))))
      {
        etem = [Select e.Subject,e.Markup,e.HtmlValue, body From EmailTemplate e where DeveloperName ='Notifica_agenzia']; // NOPMD  Fix CRUD violation

        list<Messaging.SingleEmailMessage> listEmail = new list<Messaging.SingleEmailMessage>();
        
        String htmlBody = etem.HtmlValue;
        String Sub = etem.Subject;
        
        Sub      = Sub.replace('{!Account.Name}',accountToSave.FirstName+' '+accountToSave.LastName);
        htmlBody = htmlBody.replace('{!Account.Name}',accountToSave.FirstName+' '+accountToSave.LastName);
        htmlBody = htmlBody.replace('#contatto',TypeOfMod);
        htmlBody = htmlBody.replace('#contenuti',ModifiedContacts+ModifiedPrivacy);
        htmlBody = htmlBody.replace('#indirizzo',AddressRequested);
        htmlBody = htmlBody.replace('{!Account.Link}',URL.getSalesforceBaseUrl().toExternalForm() + '/' +accountToSave.Id );

        if(!isUserLst)
        {
          Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
          email.setSubject(Sub);
          email.setHtmlBody(htmlBody);
          email.saveAsActivity = false;            
          email.setToAddresses(AddressesLst);
          email.setOrgWideEmailAddressId(SenderID);
          listEmail.add(email);            
        }
        else
        {
          for(String s:AddressesLst)
          {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject(Sub);
            email.setHtmlBody(htmlBody);
            email.saveAsActivity = false;            
            email.setTargetObjectId(s);
            email.setOrgWideEmailAddressId(SenderID);
            listEmail.add(email);  
          }
        }
        
        system.debug('@@listEmail: '+listEmail);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(listEmail);
      }
    }
    catch(exception ex)
    {
      system.debug('##Exception sendNot: '+ex);
    }
  }
}

public static List<String> RetrieveAddresses(String AgencyCode)
{
  List<String> AddressesList = new List<String>();
  List<Account> ActiveAgency = new List<Account>();
  List<String> AgentsIDs = new List<String>();
  String CustomEmail = '';
  String QueueName = '';

  if(String.isNotBlank(AgencyCode))
  {
    QueueName = 'Coda_Agenzia_'+AgencyCode;

    ActiveAgency = [Select Id, Agency_email__c from Account where Agency_Code__c=:AgencyCode and Active__c=true]; // NOPMD  Fix CRUD violation

    if(ActiveAgency.size()>0 && ActiveAgency.size()==1)
    {
      for(GroupMember GM : [SELECT GroupId,Id,SystemModstamp,UserOrGroupId,group.developername FROM GroupMember where group.developername =:QueueName ]) // NOPMD  Fix CRUD violation
      {
        if(String.valueOf(GM.UserOrGroupId).left(3)=='005')
          AgentsIDs.add(GM.UserOrGroupId);
      }

      if(AgentsIDs.size()>0)
      {
        for(User Agent : [SELECT id,email FROM User where isactive = true and id in :AgentsIDs]) // NOPMD  Fix CRUD violation
        {
          AddressesList.add(Agent.id);
        }
      }
      else
      {
        CustomEmail ='AG'+AgencyCode.right(4)+'@AXA-AGENZIE.IT';

        AddressesList.add(CustomEmail);              
      }
    }
    else
    {
      CustomEmail ='AG'+AgencyCode.right(4)+'@AXA-AGENZIE.IT';

      AddressesList.add(CustomEmail);
    }
  }

  return AddressesList;
}
//MOSCATELLI_M 29/11/2017: Data enrichment SmartCenter Fase 1 -- END

//ANASTASI_S 19072019: Email and Phone Validation -----START
/*
@AuraEnabled
public static Boolean validateField(String regExName, String fieldValue) {
 return FieldValidator.validateFieldValue(regExName, fieldValue); 
} 
*/
@AuraEnabled
public static List<Field_Validator_Setting__mdt> getListOfRegularExpressions() {
 return FieldValidator.getListOfRegularExpressions(); 
}
//ANASTASI_S 19072019: Email and Phone Validation -----END

@AuraEnabled
public static Bypass_Warning__c getHiearchySettings(){   
   return Bypass_Warning__c.getInstance();
}


 
}
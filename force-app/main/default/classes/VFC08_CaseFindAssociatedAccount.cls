public with sharing class VFC08_CaseFindAssociatedAccount {
    public class LghtCaseFindAssociateException extends Exception {}
    
    private final Case cas;
    public boolean isAgent{set;get;}
    public boolean isCorporate{set;get;}
    public boolean transactionStatus{set;get;}
    public String transactionError{set;get;}
    public boolean overwriteEmail{set;get;}
    public Account customer{set;get;}
    public Account selectedCustomer{set;get;}
    public Account selectedCorporateCustomer{set;get;}
    public list<Account> listCustomerResult{set;get;}
    public map<String,Id> mapAccountRecordtype = AP_Constants.getDeveloperIdMap( AP_Constants.sobjectAcc );
    public string rtAccIndividualId = mapAccountRecordtype.get(AP_Constants.rtAccIndividualClient);
    public string rtAccIntemediaryId = mapAccountRecordtype.get(AP_Constants.rtAccIntermediary);
    public string rtAccCorporateId = mapAccountRecordtype.get(AP_Constants.rtAccCorporateClient);
    
    //MOSCATELLI_M 07102016: Family Protect -- START
    public String rtAccAAFB2CId = mapAccountRecordtype.get(AP_Constants.rtAccAAFB2C);
    public Boolean FamilyProtectUser = false;
    //MOSCATELLI_M 07102016: Family Protect -- END
    
    //SPINELLI_F 02022016: EVO-18----START
    public string rtAccountB2CId = mapAccountRecordtype.get(AP_Constants.rtAccB2C);
    public string rtAccountB2BId = mapAccountRecordtype.get(AP_Constants.rtAccB2B);
    public map<String,Id> mapCaseRecordtype = AP_Constants.getDeveloperIdMap( AP_Constants.sobjectCas );
    public boolean AIISelected {set;get;}
    //SPINELLI_F 02022016: EVO-18----END 
    
    public Map<String, String> UrlParameterMap;
    
    //Added by YRA:
    public integer selectedCustomerVal{set;get;}
    public boolean isNew{set;get;}
    
    public VFC08_CaseFindAssociatedAccount(Case caseObject){
        this.cas = caseObject;
    }
    
    public VFC08_CaseFindAssociatedAccount(ApexPages.StandardController stdController) {
        System.debug('>>> START VFC08_CaseFindAssociatedAccount constructor <<<');
        this.cas = (Case)stdController.getRecord();
        isAgent = false;
        isCorporate = false;
        isNew =false;
        
        transactionStatus = false;
        overwriteEmail = false;
        transactionError = 'firstLoad';
        customer = new Account();
        selectedCustomer = new Account(); 
        selectedCorporateCustomer = new Account(recordtypeid=rtAccCorporateId);
        Set<String> DoNotCopyEmail = new Set<String>(); //OAVERSANO 03/08/2018 BUG Fix Fatiga
        //OAVERSANO 03/08/2018 BUG Fix Fatiga -- START
        if(MPS_Code_Variables__c.getValues('DoNotCopyEmail')!=null)
        {
            if(String.isNotBlank(MPS_Code_Variables__c.getValues('DoNotCopyEmail').value__c))
            {
                for(String s:(MPS_Code_Variables__c.getValues('DoNotCopyEmail').value__c).split(';'))
                {
                    DoNotCopyEmail.add(s);                
                }
            }
        }
        //if(string.isNotBlank(cas.SuppliedEmail))
        if(string.isNotBlank(cas.SuppliedEmail) && !DoNotCopyEmail.contains(cas.SuppliedEmail))
        {
        //OAVERSANO 03/08/2018 BUG Fix Fatiga -- END
            selectedCustomer.PersonEmail = cas.SuppliedEmail;
            selectedCorporateCustomer.Account_email__c =  cas.SuppliedEmail;
        }
        listCustomerResult = new list<Account>();
        UrlParameterMap = ApexPages.currentPage().getParameters();
        
        //MOSCATELLI_M 07102016: Family Protect -- START
        if(UrlParameterMap.containsKey('CaseRecordType'))
        {
            if(UrlParameterMap.get('CaseRecordType') == AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas).get(AP_Constants.rtCaseAAI))
                FamilyProtectUser = true;
        }
    //MOSCATELLI_M 07102016: Family Protect -- END
        
        if(!UrlParameterMap.containsKey('type')){
            isAgent = true;
            selectedCustomer.recordtypeid = rtAccIntemediaryId;
        }else if(UrlParameterMap.get('type') == 'customer'){
            isAgent = false;
            selectedCustomer.recordtypeid = rtAccIndividualId;
        }
        System.debug('>>> END VFC08_CaseFindAssociatedAccount constructor <<<');
    }
    public Pagereference searchCustomer(){
        System.debug('>>> START VFC08_CaseFindAssociatedAccount searchCustomer <<<');
        //end of check null
        System.debug('### VFC08_CaseFindAssociatedAccount customer.FirstName : '+customer.FirstName);
        System.debug('### VFC08_CaseFindAssociatedAccount customer.LastName : '+customer.LastName);
        System.debug('### VFC08_CaseFindAssociatedAccount customer.Birth_Date__c : '+customer.PersonBirthdate);
        
        //init
        isCorporate = false;
        listCustomerResult = new list<Account>();
        isNew=false;
        
        if(String.IsBlank(customer.FirstName) 
            && String.IsBlank(customer.LastName) 
            && String.IsBlank(customer.Matricola__c) 
            && String.IsBlank(customer.Fiscal_ID__c) 
            && String.IsBlank(customer.Name)
            && String.IsBlank(customer.Partita_IVA__c)
            && customer.PersonBirthdate == null)
        {
            if(ApexPages.currentPage() != null){
                Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,system.label.VFP08_FillSearch);
                Apexpages.addmessage(msg);
            }else{
                throw new LghtCaseFindAssociateException(system.label.VFP08_FillSearch);
            }
            transactionError = 'firstLoad';
            return null; 
        }
        else if(customer.PersonBirthdate !=  null && customer.PersonBirthdate > System.today() ){
            if(ApexPages.currentPage() != null){
                Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,system.label.VFP08_BirthDate);
                Apexpages.addmessage(msg);
            }else{
                throw new LghtCaseFindAssociateException(system.label.VFP08_BirthDate);
            }
            return null;
        }   
        
        //SPINELLI_F 03022016: EVO-18----START
        /*String soql = 'SELECT   id, name, TECH_Flag__c, personemail, Partita_IVA__c, Account_email__c, phone, LastName, IsPersonAccount,firstname,Fiscal_ID__c,Matricola__c '+ 
                        'FROM   Account '; */
        //CAPOBIANCO_A 30/08/2017 EVO 87 : Added the extraction of TECH_Company__c
        
        //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
        /*
        String soql = 'SELECT   id, name, TECH_Flag__c, AAI_Codice_fiscale__c, AAI_Partita_IVA__c, RecordType.Name, RecordType.Developername, Additional_Email__c, personemail, Partita_IVA__c, Account_email__c, phone, LastName, IsPersonAccount,firstname,Fiscal_ID__c,Matricola__c,Codice_Fiscale_AAF__c,TECH_Company__c '+ 
                        'FROM   Account ';
        */
        String query = 'id where ';
        String toFind = '';
        //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END

        ////SPINELLI_F 03022016: EVO-18----END
       
        /* if (!isAgent){
            if(String.IsNotBlank(customer.Name)||String.IsNotBlank(customer.Partita_IVA__c)){
                soql += 'WHERE  ispersonAccount = false  ';
                soql += 'AND recordtypeId = :rtAccCorporateId ';//MMOSCATELLI 17082015: Query bugfixing
                isCorporate = true;
            }
            else{
                soql += 'WHERE  recordtypeId = :rtAccIndividualId ';
            }
        }else{
            soql += 'WHERE  recordtypeId = :rtAccIntemediaryId ';
            
        } */
        
        //SPINELLI_F 03022016: EVO-18-----START
        if (!isAgent)
            {if(String.IsNotBlank(customer.Name)||String.IsNotBlank(customer.Partita_IVA__c)){
               
                //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
                //soql += 'WHERE  (recordtypeId = :rtAccountB2BId OR recordtypeId = :rtAccCorporateId)';
                query+= ' (recordtypeId = '+'\''+(rtAccountB2BId).escapeJava()+'\''+' OR recordtypeId = '+'\''+(rtAccCorporateId).escapeJava()+'\''+')';
                //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END
                
                //MOSCATELLI_M 18022016: EVO-18-----START
                /*
               if(String.IsNotBlank(customer.FirstName)){
                    soql += ' AND firstname like \'%'+(customer.FirstName).escapeJava()+'%\' ';
                    }
                if(String.IsNotBlank(customer.LastName) ){
                    soql += ' AND LastName like \'%'+(customer.LastName).escapeJava()+'%\' ';
                    }
                */
                //MOSCATELLI_M 18022016: EVO-18-----END
                
                if(String.IsNotBlank(customer.Name) ){
                    //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
                    //soql += ' AND name like \'%'+(customer.name).escapeJava()+'%\' ';
                    String name =(customer.name).escapeJava();

                    if(name.contains('\''))
                        name = name.replace('\'','\\'+'\''); 
                    
                    toFind = name;
                    query+= ' AND name like '+'\'%'+name+'%\'';
                    //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END
                    }
               /* if(customer.PersonBirthdate !=  null){
                    date birthdate =customer.PersonBirthdate;
                    soql += ' AND PersonBirthdate = :birthdate ';
                    }*/
              /*  if(String.IsNotBlank(customer.Fiscal_ID__c)){
                    soql += ' AND (AAI_Codice_fiscale__c = \''+(customer.Fiscal_ID__c).escapeJava()+'\' ';
                    soql += ' OR Fiscal_ID__c = \''+(customer.Fiscal_ID__c).escapeJava()+'\' )';
                    }*/
                if(String.IsNotBlank(customer.Partita_IVA__c)){
                   //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
                   /*
                   soql += ' AND (AAI_Partita_IVA__c = \''+(customer.Partita_IVA__c).escapeJava()+'\' ';
                   soql += ' OR Partita_IVA__c = \''+(customer.Partita_IVA__c).escapeJava()+'\' )';
                   */
                   if(String.isNotBlank(toFind))
                        toFind+=' AND '+(customer.Partita_IVA__c).escapeJava();
                   else
                        toFind = (customer.Partita_IVA__c).escapeJava();

                   query+= ' AND (AAI_Partita_IVA__c = \''+(customer.Partita_IVA__c).escapeJava()+'\' OR Partita_IVA__c = \''+(customer.Partita_IVA__c).escapeJava()+'\' )';
                   //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END
                    }
                
                //MOSCATELLI_M 18022016: EVO-18-----START
                /*
                 if(customer.PersonBirthdate !=  null){
                 date birthdate =customer.PersonBirthdate;
                 soql += ' AND PersonBirthdate = :birthdate';
                    }
                */
                //MOSCATELLI_M 18022016: EVO-18-----END
                
                //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
                /*
                soql += 'AND ispersonAccount = false  ';
                soql += ' limit 100';
                */
                query+= ' AND IsPersonAccount = false limit 100';
                //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END
                System.debug('### VFC08_CaseFindAssociatedAccount soql : '+query);
                isCorporate = true;
                } 
                
                else                
                  
                {   
                    //MOSCATELLI_M 07102016: Family Protect -- START
                    //soql += 'WHERE  (recordtypeId = :rtAccountB2CId OR recordtypeId = :rtAccIndividualId)';
                    if(FamilyProtectUser)
                    //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
                      //soql += 'WHERE  (recordtypeId = :rtAccountB2CId OR recordtypeId = :rtAccIndividualId OR recordtypeId = :rtAccAAFB2CId)';
                         query+= ' (recordtypeId = '+'\''+(rtAccountB2CId).escapeJava()+'\''+' OR recordtypeId = '+'\''+(rtAccIndividualId).escapeJava()+'\''+' OR recordtypeId = '+'\''+(rtAccAAFB2CId).escapeJava()+'\''+')';
                    //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END
                    else
                    //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
                        //soql += 'WHERE  (recordtypeId = :rtAccountB2CId OR recordtypeId = :rtAccIndividualId)';
                        query+= ' (recordtypeId = '+'\''+(rtAccountB2CId).escapeJava()+'\''+' OR recordtypeId = '+'\''+(rtAccIndividualId).escapeJava()+'\''+')';
                    //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END

                    //MOSCATELLI_M 07102016: Family Protect -- END
                    if(String.IsNotBlank(customer.FirstName)){
                        //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
                        //soql += ' AND firstname like \'%'+(customer.FirstName).escapeJava()+'%\' ';
                        String firstName = (customer.FirstName).escapeJava();

                        if(firstName.contains('\''))
                            firstName = firstName.replace('\'','\\'+'\'');

                        query+=' AND firstname like \'%'+firstName+'%\' ';
                        toFind = firstName;
                        //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END
                        }
                    if(String.IsNotBlank(customer.LastName) ){
                        //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
                        //soql += ' AND LastName like \'%'+(customer.LastName).escapeJava()+'%\' ';
                        String LastName = (customer.LastName).escapeJava();

                        if(LastName.contains('\''))
                            LastName = LastName.replace('\'','\\'+'\'');

                        if(String.isNotBlank(toFind))
                            toFind+= ' AND '+LastName;
                        else
                            toFind= LastName;

                        query+=' AND LastName like \'%'+LastName+'%\' ';
                        //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END
                        }
                 
                 //MOSCATELLI_M 18022016: EVO-18-----START
                 /*
                    if(String.IsNotBlank(customer.Name) ){
                        soql += ' AND name like \'%'+(customer.name).escapeJava()+'%\' ';
                        }
                */
                 //MOSCATELLI_M 18022016: EVO-18-----END
                   
                   //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START 
                   /*
                    if(customer.PersonBirthdate !=  null){
                        date birthdate =customer.PersonBirthdate;
                        soql += ' AND PersonBirthdate = :birthdate ';
                        }
                    */
                   
                    if(String.IsNotBlank(customer.Fiscal_ID__c)){
                        /*
                        soql += ' AND (AAI_Codice_fiscale__c = \''+(customer.Fiscal_ID__c).escapeJava()+'\' ';
                        //MOSCATELLI_M 07102016: Family Protect -- START
                        soql += ' OR Fiscal_ID__c = \''+(customer.Fiscal_ID__c).escapeJava()+'\' ';
                        soql += ' OR Codice_Fiscale_AAF__c = \''+(customer.Fiscal_ID__c).escapeJava()+'\' )';
                        */
                        //MOSCATELLI_M 07102016: Family Protect -- END
                        String fiscalId = (customer.Fiscal_ID__c).escapeJava();

                        query+=' AND (AAI_Codice_fiscale__c = :fiscalId OR Fiscal_ID__c = :fiscalId OR Codice_Fiscale_AAF__c = :fiscalId OR AAI_Partita_IVA__c = :fiscalId OR Partita_IVA__c = :fiscalId )';
                        
                        if(String.isNotBlank(toFind))
                            toFind+= ' AND '+(customer.Fiscal_ID__c).escapeJava();
                        else
                            toFind= (customer.Fiscal_ID__c).escapeJava();                        
                        }
                   /* if(String.IsNotBlank(customer.Partita_IVA__c)){
                    soql += ' AND (AAI_Partita_IVA__c = \''+(customer.Partita_IVA__c).escapeJava()+'\' ';
                    soql += ' OR Partita_IVA__c = \''+(customer.Partita_IVA__c).escapeJava()+'\' )';
                       }*/
                    //soql += ' limit 100';
                    query+= ' limit 100';
                    //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END
                    System.debug('### VFC08_CaseFindAssociatedAccount soql : '+query);
                    }}
        else{
            //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
            //soql += 'WHERE  recordtypeId = :rtAccIntemediaryId ';
            query+= ' recordtypeId = '+'\''+(rtAccIntemediaryId).escapeJava()+'\'';

             if(String.IsNotBlank(customer.FirstName)){
                //soql += ' AND firstname like \'%'+(customer.FirstName).escapeJava()+'%\' ';//MMOSCATELLI 17082015: Query bugfixing adding escapeJava method
                String firstname = (customer.FirstName).escapeJava();

                if(firstname.contains('\''))
                    firstname = firstname.replace('\'','\\'+'\'');

                query+= ' AND firstname like \'%'+firstname+'%\' ';
                toFind = firstname;
                }
            if(String.IsNotBlank(customer.LastName) ){
                //soql += ' AND LastName like \'%'+(customer.LastName).escapeJava()+'%\' ';//MMOSCATELLI 17082015: Query bugfixing adding escapeJava method
                String LastName = (customer.LastName).escapeJava();

                if(LastName.contains('\''))
                    LastName = LastName.replace('\'','\\'+'\'');

                query+= ' AND LastName like \'%'+LastName+'%\' ';

                if(String.isNotBlank(toFind))
                    toFind += ' AND '+LastName;
                else
                    toFind = LastName;               
                }
            
            //MOSCATELLI_M 18022016: EVO-18-----START
            /*
            if(String.IsNotBlank(customer.Name) ){
                soql += ' AND name like \'%'+(customer.name).escapeJava()+'%\' ';//MMOSCATELLI 17082015: Query bugfixing adding escapeJava method
                }            
            */
            //MOSCATELLI_M 18022016: EVO-18-----END
            
            if(String.IsNotBlank(customer.Matricola__c)){
                //soql += ' AND Matricola__c = \''+(customer.Matricola__c).escapeJava()+'\' ';//MMOSCATELLI 17082015: Query bugfixing adding escapeJava method
                query+= ' AND Matricola__c = \''+(customer.Matricola__c).escapeJava()+'\' ';

                if(String.isNotBlank(toFind))
                    toFind += ' AND '+(customer.Matricola__c).escapeJava();
                else
                    toFind = (customer.Matricola__c).escapeJava();               
                }            
            }
            //soql += ' limit 100';
            //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END

            System.debug('### VFC08_CaseFindAssociatedAccount query : '+query); 
            System.debug('### VFC08_CaseFindAssociatedAccount toFind : '+toFind);      
        //SPINELLI_F 03022016: EVO-18----END        
        
     /*  if(String.IsNotBlank(customer.FirstName)){
            soql += ' AND firstname like \'%'+(customer.FirstName).escapeJava()+'%\' ';//MMOSCATELLI 17082015: Query bugfixing adding escapeJava method
        }
        if(String.IsNotBlank(customer.LastName) ){
            soql += ' AND LastName like \'%'+(customer.LastName).escapeJava()+'%\' ';//MMOSCATELLI 17082015: Query bugfixing adding escapeJava method
        }
        if(String.IsNotBlank(customer.Name) ){
            soql += ' AND name like \'%'+(customer.name).escapeJava()+'%\' ';//MMOSCATELLI 17082015: Query bugfixing adding escapeJava method
        }
        if(customer.PersonBirthdate !=  null && !isAgent){
            date birthdate =customer.PersonBirthdate;
            soql += ' AND PersonBirthdate = :birthdate ';
        }
        if(String.IsNotBlank(customer.Matricola__c) && isAgent){
            soql += ' AND Matricola__c = \''+(customer.Matricola__c).escapeJava()+'\' ';//MMOSCATELLI 17082015: Query bugfixing adding escapeJava method
        }
        if(String.IsNotBlank(customer.Fiscal_ID__c) && !isAgent){
            soql += ' AND Fiscal_ID__c = \''+(customer.Fiscal_ID__c).escapeJava()+'\' ';//MMOSCATELLI 17082015: Query bugfixing adding escapeJava method
        }
        if(String.IsNotBlank(customer.Partita_IVA__c) && !isAgent){
            soql += ' AND Partita_IVA__c = \''+(customer.Partita_IVA__c).escapeJava()+'\' ';
        }
        soql += ' limit 100';
        System.debug('### VFC08_CaseFindAssociatedAccount soql : '+soql);
        //listCustomerResult = (List<Account>)Database.query(soql); */

        String [] SpecialChar = new String[]{'&#124;', '&','|','!','{','}','[',']','(',')','^','~', '*', ':','"','+','-'};

        for(String s: SpecialChar)
        {
            if(toFind.contains(s))
            {
                toFind= toFind.replace(s,'\\'+s);
                system.debug('\\'+s);
            }
        }
        
         //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- START
         String searchs ='FIND {'+toFind+'} IN ALL FIELDS RETURNING ACCOUNT('+query+')'; 
         system.debug('@@searchs: '+searchs);

         List<List<SObject>> ListAccounts = search.query(searchs);
         List<Account> ListAccountsQuery = new list<Account>();
         ListAccountsQuery = ((List<Account>)ListAccounts[0]);       
        //for(Account acc:Database.query(soql)){
            //MOSCATELLI_M 13/02/2018: Aggiornamento gestori -- START
            //for(Account acc: [Select id, name, TECH_Flag__c, AAI_Codice_fiscale__c, AAI_Partita_IVA__c, RecordType.Name, RecordType.Developername, Additional_Email__c, personemail, Partita_IVA__c, Account_email__c, phone, LastName, IsPersonAccount,firstname,Fiscal_ID__c,Matricola__c,Codice_Fiscale_AAF__c,TECH_Company__c from Account where id in:ListAccountsQuery])
            for(Account acc: [Select id, name, TECH_Flag__c, AAI_Codice_fiscale__c, AAI_Partita_IVA__c, RecordType.Name, RecordType.Developername, Additional_Email__c, personemail, Partita_IVA__c, Account_email__c, phone, LastName, IsPersonAccount,firstname,Fiscal_ID__c,Matricola__c,Codice_Fiscale_AAF__c,TECH_Company__c,State__c, AAI_Agency_Reference_Code__c , Agency_Code__c from Account where id in:ListAccountsQuery])            
            //MOSCATELLI_M 13/02/2018: Aggiornamento gestori -- END
            {
            //MOSCATELLI 10/01/2018: Velocizzazione ricerca cliente -- END
            acc.Tech_Flag__c = false;
            //system.debug('####:'+cas.SuppliedEmail);
            //MOSCATELLI_M 16072015: CR10-----START
            /*
            if(string.isNotBlank(cas.SuppliedEmail)){
                system.debug('####:'+cas.SuppliedEmail);
                acc.Tech_Flag__c = true;
            }
*/
            //MOSCATELLI_M 16072015: CR10-----END
            listCustomerResult.add(acc);
        }
        
        System.debug('### listCustomerResult: '+listCustomerResult);
        
        //corporate
        selectedCorporateCustomer.Name= customer.Name;
        selectedCorporateCustomer.Partita_IVA__c= customer.Partita_IVA__c;
            
        //Agent
        selectedCustomer.FirstName = customer.FirstName;
        selectedCustomer.LastName = customer.LastName;
        selectedCustomer.Fiscal_ID__c = customer.Fiscal_ID__c;
        selectedCustomer.PersonBirthdate = customer.PersonBirthdate;
        selectedCustomer.Matricola__c = customer.Matricola__c;
        
        System.debug('### isCorporate: '+isCorporate);
        System.debug('### isAgent : '+isAgent);
      
        transactionError = system.label.VFP08_Successful;
        System.debug('>>> END VFC08_CaseFindAssociatedAccount searchCustomer <<<');
        return null;
    }// end of method
    
    public void asociateCustomerToCase() {
        System.debug('>>> START VFC08_CaseFindAssociatedAccount asociateCustomerToCase <<<');
        System.debug('### VFC08_CaseFindAssociatedAccount customer : '+ selectedCustomer);
        System.debug('### VFC08_CaseFindAssociatedAccount overwriteEmail : '+ overwriteEmail);
        System.debug('### VFC08_CaseFindAssociatedAccount list : '+listCustomerResult);
        System.debug('### selectedCustomerId : '+selectedCustomer.id);
        System.debug('### selectedCustomerVal : '+selectedCustomerVal); 
        Set<String> DoNotCopyEmail = new Set<String>(); //OAVERSANO 03/08/2018 BUG Fix Fatiga
        //OAVERSANO 03/08/2018 BUG Fix Fatiga -- START
        if(MPS_Code_Variables__c.getValues('DoNotCopyEmail')!=null)
        {
            if(String.isNotBlank(MPS_Code_Variables__c.getValues('DoNotCopyEmail').value__c))
            {
                for(String s:(MPS_Code_Variables__c.getValues('DoNotCopyEmail').value__c).split(';'))
                {
                    DoNotCopyEmail.add(s);                
                }
            }
        }
        //OAVERSANO 03/08/2018 BUG Fix Fatiga -- END
        try{
            //update new Account(id = selectedCustomer.id, PersonEmail= cas.SuppliedEmail);
            //update selectedCustomer;
            /*Account acc = new Account(id = selectedCustomer.id);*/
            Account acc = new Account();
            if(listCustomerResult.size() > 0){
                system.debug('SelectedResult:'+listCustomerResult[selectedCustomerVal]);
                acc.Id = listCustomerResult[selectedCustomerVal].Id;                
            }else if(selectedCustomer != null && selectedCustomer.id != null){
                acc.Id = selectedCustomer.id;
            }
            overwriteEmail = false;

             //FM_ 10/05/2018 : GDPR - START
            boolean isMPSAccount = false; 

            List<Account_Case__c> ExistentAC = new List<Account_Case__c>();
            ExistentAC = [SELECT Id,Account__c,Case__c FROM Account_Case__c WHERE Case__c =: cas.id];

            String AccountRT = [SELECT Id,RecordType.Name FROM Account WHERE Id=:acc.Id].RecordType.Name;

            system.debug('is AAI Account?'+AccountRT);

            if(AccountRT == 'B2C Client' || AccountRT == 'B2B Client' ){

                isMPSAccount = false;
            }else{
                isMPSAccount = true;
            }

            system.debug('isMPSAccount'+isMPSAccount);

             //FM_ 10/05/2018 : GDPR - END
             
            /*
            for(Account accselected:listCustomerResult){
                if(accselected.id == acc.id && accselected.TECH_FLAG__c){
                    overwriteEmail=true;
                }
            }*/
            if(listCustomerResult.size() > 0 && listCustomerResult[selectedCustomerVal].TECH_FLAG__c){
                overwriteEmail=true;
            }else if(selectedCustomer != null && selectedCustomer.TECH_FLAG__c){
                overwriteEmail=true;
            }
            
            system.debug('overwriteEmail:'+overwriteEmail);
            system.debug('isCorporate:'+isCorporate);
            
           /* if(overwriteEmail){
                if(isCorporate){
                    acc.Account_Email__c = cas.SuppliedEmail;
                }
                else{
                    acc.personemail = cas.SuppliedEmail;
                }
                update acc;
            }*/
            
              //SPINELLI_F 08022016: EVO-18----START
              if(overwriteEmail && !isAgent){
                //MOSCATELLI_M 12042016: EVO 46 -- START
                /*
                if(isCorporate)
                { if(!AIISelected)
                    {acc.Account_Email__c = cas.SuppliedEmail;}
                    else
                    {acc.Additional_Email__c = cas.SuppliedEmail;}
                }
                else{
                if(!AIISelected)
                {acc.personemail = cas.SuppliedEmail;}
                else
                {acc.Additional_Email__c = cas.SuppliedEmail;}
                }
         */
                //OAVERSANO 03/08/2018 BUG Fix FATIGA -- START
                if(!DoNotCopyEmail.contains(cas.SuppliedEmail))
                    acc.Additional_Email__c = cas.SuppliedEmail; 
                //OAVERSANO 03/08/2018 BUG Fix FATIGA -- START
                //MOSCATELLI_M 12042016: EVO 46 -- END
                update acc;
              }
              //SPINELLI_F 08022016: EVO-18----END
            
            System.debug('### VFC08_CaseFindAssociatedAccount customer : updated' );
            if( !isAgent )
                update new Case (id=cas.id , accountId =acc.id  );
            else
                update new Case (id=cas.id , AgentName__c =acc.id  );
            
            System.debug('### VFC08_CaseFindAssociatedAccount Case : updated');
            
            transactionStatus = true;
            transactionError = 'success';        
            
            System.debug('### VFC08_CaseFindAssociatedAccount transactionStatus : '+transactionStatus );
            System.debug('### VFC08_CaseFindAssociatedAccount transactionError : '+transactionError );
        }catch(Exception e){
            transactionStatus = false;
            transactionError = e.getmessage();
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
        System.debug('>>> END VFC08_CaseFindAssociatedAccount asociateCustomerToCase <<<');
    }//end of method
    
    public Pagereference newCustomer(){
        System.debug('>>> START method newCustomer  <<<');
        
        isNew=true;
        return null;
    }
    public Pagereference saveCustomer(){
        System.debug('>>> START method saveCustomer  <<<');
        /*
        if(String.IsBlank(selectedCustomer.LastName)){
            Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,system.label.VFP08_LastName);
            Apexpages.addmessage(msg);
            return null;
        }     
        */  
        try {
            /*
            if(!isAgent){
                selectedCustomer.recordtypeId = rtAccIndividualId;
            }else{
                selectedCustomer.recordtypeId = rtAccIntemediaryId;
            }    
            */     
            Account newAccount;
            system.debug('isCorporate:'+isCorporate);
            if(isCorporate){
                selectedCorporateCustomer.Fiscal_ID__c = selectedCorporateCustomer.Partita_IVA__c;
                newAccount = selectedCorporateCustomer;
                system.debug('newAccount');
            } 
            else{
                newAccount = selectedCustomer;
                system.debug('newAccount');
            }
            system.debug('newAccount:'+newAccount);
            insert newAccount;
            
            if(!isAgent){
                update new Case(id = cas.id, accountid =newAccount.id);
            }else{
                update new Case(id = cas.id, AgentName__c =newAccount.id);
            }           
            
            if(ApexPages.currentPage() != null){
                Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,system.label.VFP08_Successful);
                Apexpages.addmessage(msg);
            }
            
            transactionStatus = true;
            transactionError = system.label.VFP08_Successful;
        }catch( Exception e){
            if(ApexPages.currentPage() != null){
                Apexpages.addmessages( e);                
            }else{
                System.debug('Exception' + e.getStackTraceString());
                throw new LghtCaseFindAssociateException(e.getMessage());
            }
        }
        return null;
    }      
}//end of class
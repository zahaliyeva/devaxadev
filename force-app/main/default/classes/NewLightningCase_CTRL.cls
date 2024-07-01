/*------------------------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         NewLightningCase_CTRL
Description:   Apex class used to execute all the logics internal to the
Lightning component NewCaseLightning related to Caring Angel

History

16/11/2018     Created
-------------------------------------------------------------------------------------------*/
public with sharing class NewLightningCase_CTRL
{
    public class FoundCustomers
    {
        @AuraEnabled public String Nome;
        @AuraEnabled public String Fiscale;
        @AuraEnabled public String Company;
        @AuraEnabled public String Id;
        @AuraEnabled public String PolicyId;
        @AuraEnabled public String AccountEmail;
        @AuraEnabled public String Targa;
        @AuraEnabled public String Agenzia;

        public FoundCustomers()
        {
            this.Nome = '';
            this.Fiscale = '';
            this.Company = '';
            this.Id='';
            this.PolicyId='';
            this.AccountEmail='';
            this.Targa='';
            this.Agenzia='';
        }
    }

    public class FoundList
    {
        @AuraEnabled public List<FoundCustomers> Founds;
        @AuraEnabled public Map<String,FoundCustomers> MapIdToFounds;

        public FoundList()
        {
            this.Founds = new List<FoundCustomers>();
            this.MapIdToFounds = new Map<String,FoundCustomers>();
        }
    }

    @AuraEnabled
    public static string setCaseRecordTypeDeveloperName(String caseRecordTypeId){
      return RecordTypeUtility.getDeveloperNameById('Case', caseRecordTypeId);
    }

    //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
    @AuraEnabled
    public static Boolean checkRTSelection()
    {
        String CurrentUserProfile = [Select Name from Profile where id=:Userinfo.getProfileId()].Name;

        MPS_Code_Utils__mdt McU = [Select Key__c,Value__c from MPS_Code_Utils__mdt where DeveloperName='QuestionarioRecordTypeSelection' limit 1];

        if(McU.Value__c =='true' && McU.Key__c.contains(CurrentUserProfile))
            return true;
        else
                return false;
    }
    //MOSCATELLI_M 13/03/2019: Axa Assistance -- END

    @AuraEnabled
    //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
    //public static FoundList SearchCustomers(String Name,String Lastname,String Policy, String Plate,String FiscalId, String BirthDate)
    // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II
    public static FoundList SearchCustomers(String Name, String Lastname, String Policy, String Plate, String FiscalId, String BirthDate, String IVA, String CustomerType, String ClaimNumber)
    //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
    {
        FoundList FcL = new FoundList();

        String queryAcc = 'id where RecordType.name in (\'Individual\',\'Corporate\',\'B2B Client\',\'B2C Client\',\'AAF_B2C\')';
        String queryPol = 'id where CUID__r.RecordType.name in (\'Individual\',\'Corporate\',\'B2B Client\',\'B2C Client\',\'AAF_B2C\')';
        // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II
        String querySin = 'Id WHERE Account__r.RecordType.Name IN (\'Individual\',\'Corporate\',\'B2B Client\',\'B2C Client\',\'AAF_B2C\')';
        String toFind = '';

        String MPSCompany = MPS_Code_Variables__c.getValues('TECH Company MPS').Value__c;
        String QuadraCompany = MPS_Code_Variables__c.getValues('TECH Company Quadra').Value__c;

        // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II -- START
        if (String.isNotBlank(ClaimNumber)) {

            ClaimNumber = ClaimNumber.replace('\'', '\\' + '\'');

            toFind = ClaimNumber;

            querySin += ' AND Name =' + '\'' + ClaimNumber + '\'';

            if (String.isNotBlank(Name)) {
                Name = Name.escapeJava();

                if (Name.contains('\'')) {
                    Name = Name.replace('\'', '\\' + '\'');
                }

                if (CustomerType == 'fisica') {
                    querySin += ' AND Account__r.FirstName =' + '\'' + Name + '\'';
                } else {
                    querySin += ' AND Account__r.Name =' + '\'' + Name + '\'';
                }
            }

            if (String.isNotBlank(Lastname)) {

                if (Lastname.contains('\'')) {
                    Lastname = Lastname.replace('\'', '\\' + '\'');
                }

                querySin += ' AND Account__r.LastName =' + '\'' + Lastname + '\'';
            }

            if (String.isNotBlank(FiscalId)) {
                FiscalId = FiscalId.escapeJava();
                querySin += ' AND (Account__r.Fiscal_ID__c = :FiscalId  OR Account__r.AAI_Codice_fiscale__c = :FiscalId OR  Account__r.AAI_Partita_IVA__c = :FiscalId OR Account__r.Partita_IVA__c = :FiscalId OR Account__r.Codice_Fiscale_AAF__c = :FiscalId) ';
            }

            if (String.isNotBlank(IVA)) {
                IVA = IVA.escapeJava();
                querySin += ' AND (Account__r.Partita_IVA__c =' + '\'' + IVA + '\' OR Account__r.AAI_Partita_IVA__c =' + '\'' + IVA + '\')';
                
            }

            if (String.isNotBlank(BirthDate)) {
                querySin += ' AND Account__r.PersonBirthdate =' + BirthDate;
            }

            if (String.isNotBlank(Policy)) {
                querySin += ' AND Polizza__r.Name =' + '\'' + Policy + '\'';
            }

            if (String.isNotBlank(Plate)) {
                querySin += ' AND Polizza__r.Targa_veicolo__c =' + '\'' + Plate + '\'';
            }

            String [] SpecialChar = new String[]{
                    '&#124;', '&', '|', '!', '{', '}', '[', ']', '(', ')', '^', '~', '*', ':', '"', '+', '-'
            };

            for (String s : SpecialChar) {
                if (toFind.contains(s)) {
                    toFind = toFind.replace(s, '\\' + s);
                }
            }

            String searchs = 'FIND {' + toFind + '} IN ALL FIELDS RETURNING Claim__c(' + querySin + ')';
            System.debug('##searchs: ' + searchs);
            List<List<SObject>> ListClaims = Search.query(searchs);
            List<Claim__c> claims = (List<Claim__c>) ListClaims[0];

            for (Claim__c c : [
                    SELECT Id, Account__c, Account__r.Name, Account__r.Fiscal_ID__c, Account__r.AAI_Codice_fiscale__c,
                            Account__r.CIF_PersonEmail__c, Account__r.CIF_Personalemail__c, Account__r.PersonEmail,
                            Account__r.Account_email__c, Account__r.TECH_Company__c, Account__r.RecordType.Name,
                            Account__r.AAI_Agency__r.Name, Account__r.Partita_IVA__c, Account__r.AAI_Partita_IVA__c,
                            Account__r.Flag_Fonte_QUADRA__c
                    FROM Claim__c
                    WHERE Id IN:claims
            ]) {
                FoundCustomers Fc = new FoundCustomers();
                Fc.Id = c.Account__c;
                Fc.Nome = c.Account__r.Name;
                Fc.Agenzia = c.Account__r.AAI_Agency__r.Name;

                if (CustomerType == 'fisica') {
                    if (String.isNotBlank(c.Account__r.Fiscal_ID__c))
                        Fc.Fiscale = c.Account__r.Fiscal_ID__c; 
                    else if (String.isNotBlank(c.Account__r.AAI_Codice_fiscale__c))
                        Fc.Fiscale = c.Account__r.AAI_Codice_fiscale__c; 
                    else if (String.isNotBlank(c.Account__r.Partita_IVA__c))
                        Fc.Fiscale = c.Account__r.Partita_IVA__c; 
                    else if (String.isNotBlank(c.Account__r.AAI_Partita_IVA__c))
                        Fc.Fiscale = c.Account__r.AAI_Partita_IVA__c; 
                    else
                        Fc.Fiscale = '';
                } else {
                    if (String.isNotBlank(c.Account__r.Partita_IVA__c))
                        Fc.Fiscale = c.Account__r.Partita_IVA__c; 
                    else if (String.isNotBlank(c.Account__r.AAI_Partita_IVA__c))
                        Fc.Fiscale = c.Account__r.AAI_Partita_IVA__c; 
                    else
                        Fc.Fiscale = '';
                }

                if (c.Account__r.TECH_Company__c == 'AAI')
                    Fc.Company = 'Cliente Axa Assicurazioni'; 
                else if (c.Account__r.TECH_Company__c == 'AMF')
                    Fc.Company = 'Cliente AXA MPS Financial'; 
                else if(c.Account__r.Flag_Fonte_QUADRA__c == AP_Constants.FLAG_SI)
					          Fc.Company = 'Cliente Quadra Assicurazioni';
                else if (String.isBlank(c.Account__r.TECH_Company__c) || (c.Account__r.TECH_Company__c == 'MPS') || MPSCompany.contains(c.Account__r.TECH_Company__c))
                    Fc.Company = 'Cliente AXA MPS'; 
                else if ((c.Account__r.TECH_Company__c == 'Quadra') || QuadraCompany.contains(c.Account__r.TECH_Company__c))
                    Fc.Company = 'Cliente Quadra Assicurazioni';

                if (c.Account__r.RecordType.Name == 'Individual' || c.Account__r.RecordType.Name == 'B2C Client') {
                    Fc.AccountEmail = (c.Account__r.RecordType.Name == 'Individual') ? c.Account__r.PersonEmail : c.Account__r.CIF_PersonEmail__c;
                } else if (c.Account__r.RecordType.Name == 'Corporate' || c.Account__r.RecordType.Name == 'B2B Client') {
                    Fc.AccountEmail = (c.Account__r.RecordType.Name == 'Corporate') ? c.Account__r.Account_email__c : c.Account__r.CIF_Personalemail__c;
                }

                FcL.Founds.add(Fc);
                FcL.MapIdToFounds.put(Fc.Id, Fc);
            }

            // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II -- END

        } else if (String.isBlank(Policy) && String.isBlank(Plate)) {

            if (String.isNotBlank(Name)) {
        Name = Name.escapeJava();

        if(Name.contains('\''))
                  Name = Name.replace('\'','\\'+'\'');

              toFind = Name;
        
        //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
        if(CustomerType=='fisica')
          queryAcc += ' and firstname ='+'\''+Name+'\'';
        else
          queryAcc += ' and name ='+'\''+Name+'\'';
        //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
      }

      if(String.isNotBlank(Lastname))
      {
        //Lastname = Lastname.escapeJava();

        if(Lastname.contains('\''))
                  Lastname = Lastname.replace('\'','\\'+'\'');

              if(String.isBlank(toFind))
                toFind = Lastname;
              else
                toFind = toFind+' AND '+Lastname;
        
        queryAcc += ' and lastname ='+'\''+Lastname+'\'';
      }

      if(String.isNotBlank(FiscalId))
      {
              FiscalId = FiscalId.escapeJava();
              queryAcc += ' AND (Fiscal_ID__c = :FiscalId  OR AAI_Codice_fiscale__c = :FiscalId OR  AAI_Partita_IVA__c = :FiscalId OR Partita_IVA__c = :FiscalId OR Codice_Fiscale_AAF__c = :FiscalId) ';
              
              if(String.isBlank(toFind))
                  toFind = FiscalId; 
              else
                  toFind = toFind+' AND '+FiscalId;   
      }

      //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
      if(String.isNotBlank(IVA))
      {
              IVA = IVA.escapeJava();
              queryAcc += ' AND (Partita_IVA__c ='+'\''+IVA+'\' OR AAI_Partita_IVA__c ='+'\''+IVA+'\')';
              
              if(String.isBlank(toFind))
                  toFind = IVA; 
              else
                  toFind = toFind+' AND '+IVA;   
      }      
      //MOSCATELLI_M 13/03/2019: Axa Assistance -- END

      if(String.isNotBlank(BirthDate))
        queryAcc += 'AND PersonBirthdate ='+BirthDate;  

          String [] SpecialChar = new String[]{'&#124;', '&','|','!','{','}','[',']','(',')','^','~', '*', ':','"','+','-'};

          for(String s: SpecialChar)
          {
              if(toFind.contains(s))
              {
                  toFind= toFind.replace(s,'\\'+s);
                  system.debug('\\'+s);
              }
          }

          String searchs ='FIND {'+toFind+'} IN ALL FIELDS RETURNING ACCOUNT('+queryAcc+')'; 
          system.debug('##searchs: '+searchs);
          List<List<SObject>> ListAccounts = search.query(searchs);
          system.debug('ListAccounts: '+ListAccounts);
          
          List<Account> ListAccountsQuery = new list<Account>();
          ListAccountsQuery = ((List<Account>)ListAccounts[0]);

      for (Account client : [Select Name, Flag_Fonte_QUADRA__c, Fiscal_id__c, AAI_Codice_fiscale__c,CIF_PersonEmail__c,CIF_Personalemail__c,Personemail, Account_Email__c,tech_company__c,RecordType.Name,AAI_Agency__r.Name,Partita_IVA__c,AAI_Partita_IVA__c from Account where id in:ListAccountsQuery]) 
          {
            FoundCustomers Fc= new FoundCustomers();
            Fc.Id = client.Id;
            Fc.Nome = client.Name;

            if(CustomerType=='fisica')
            {
              if(String.isNotBlank(client.Fiscal_id__c))
                Fc.Fiscale = client.Fiscal_id__c;
              else if(String.isNotBlank(client.AAI_Codice_fiscale__c))
                Fc.Fiscale = client.AAI_Codice_fiscale__c;
              else if (String.isNotBlank(client.Partita_IVA__c))
                Fc.Fiscale = client.Partita_IVA__c; 
              else if (String.isNotBlank(client.AAI_Partita_IVA__c))
                Fc.Fiscale = client.AAI_Partita_IVA__c; 
              else
                Fc.Fiscale='';
            }
            else
            {
              if(String.isNotBlank(client.Partita_IVA__c))
                Fc.Fiscale = client.Partita_IVA__c;
              else if(String.isNotBlank(client.AAI_Partita_IVA__c))
                Fc.Fiscale = client.AAI_Partita_IVA__c;
              else
                Fc.Fiscale='';    
            }        
        
        if(client.tech_company__c == 'AAI')
          Fc.Company = 'Cliente Axa Assicurazioni';
        else if(client.tech_company__c == 'AMF')
          Fc.Company = 'Cliente AXA MPS Financial';
        else if(client.Flag_Fonte_QUADRA__c == AP_Constants.FLAG_SI)
          Fc.Company = 'Cliente Quadra Assicurazioni';
        else if(String.isBlank(client.tech_company__c) || (client.tech_company__c == 'MPS') || MPSCompany.contains(client.tech_company__c))
          Fc.Company = 'Cliente AXA MPS';
        else if((client.tech_company__c == 'Quadra') || QuadraCompany.contains(client.tech_company__c))
          Fc.Company = 'Cliente Quadra Assicurazioni';

        if(client.RecordType.Name == 'Individual' || client.RecordType.Name == 'B2C Client')
            {
              Fc.AccountEmail = (client.RecordType.Name == 'Individual')?client.Personemail:client.CIF_PersonEmail__c;
            }
            else if(client.RecordType.Name == 'Corporate' || client.RecordType.Name == 'B2B Client')
            {
              Fc.AccountEmail = (client.RecordType.Name == 'Corporate')?client.Account_Email__c:client.CIF_Personalemail__c;
            }

            Fc.Agenzia = client.AAI_Agency__r.Name;
            
            FcL.Founds.add(Fc);
            FcL.MapIdToFounds.put(Fc.Id,Fc);  
          }
        }
        else
        {
          if(String.isNotBlank(Policy))
          {
            Policy = Policy.replace('\'','\\'+'\'');

            if(Policy.contains('\''))
                Policy = Policy.replace('\'','\\'+'\'');
            
            toFind = Policy;

            queryPol += ' and Name ='+'\''+Policy+'\'';
          }

      if(String.isNotBlank(Name))
      {
        Name = Name.escapeJava();

        if(Name.contains('\''))
           Name = Name.replace('\'','\\'+'\'');

          /*    if(String.isBlank(toFind))
                toFind = Name;
              else
                toFind = toFind+' AND '+Name;*/
        if(CustomerType=='fisica')
          queryPol += ' and CUID__r.firstname ='+'\''+Name+'\'';
        else
          queryPol += ' and CUID__r.name ='+'\''+Name+'\'';
      }

      if(String.isNotBlank(Lastname))
      {
        //Lastname = Lastname.escapeJava();

        if(Lastname.contains('\''))
                  Lastname = Lastname.replace('\'','\\'+'\'');

            /*  if(String.isBlank(toFind))
                toFind = Lastname;
              else
                toFind = toFind+' AND '+Lastname;*/
        
        queryPol += ' and CUID__r.lastname ='+'\''+Lastname+'\'';
      }

      if(String.isNotBlank(FiscalId))
      {
              FiscalId = FiscalId.escapeJava();
              queryPol += ' AND (CUID__r.Fiscal_ID__c = :FiscalId  OR CUID__r.AAI_Codice_fiscale__c = :FiscalId OR  CUID__r.AAI_Partita_IVA__c = :FiscalId OR CUID__r.Partita_IVA__c = :FiscalId OR CUID__r.Codice_Fiscale_AAF__c = :FiscalId) ';
              
           /*   if(String.isBlank(toFind))
                  toFind = FiscalId; 
              else
                  toFind = toFind+' AND '+FiscalId;   */
      }

      if(String.isNotBlank(IVA))
      {
          IVA = IVA.escapeJava(); 
          queryPol += ' AND (CUID__r.Partita_IVA__c ='+'\''+IVA+'\' OR CUID__r.AAI_Partita_IVA__c ='+'\''+IVA+'\')';
      }

      if(String.isNotBlank(Plate))
      {
        Plate = Plate.escapeJava();
        queryPol += ' and Targa_veicolo__c ='+'\''+Plate+'\'';
        
        if(String.isBlank(toFind))
            toFind = Plate; 
        else
            toFind = toFind+' AND '+Plate;   
      }

      if(String.isNotBlank(BirthDate))
        queryPol += 'AND CUID__r.PersonBirthdate ='+BirthDate;  

          String [] SpecialChar = new String[]{'&#124;', '&','|','!','{','}','[',']','(',')','^','~', '*', ':','"','+','-'};

          for(String s: SpecialChar)
          {
              if(toFind.contains(s))
              {
                  toFind= toFind.replace(s,'\\'+s);
                  system.debug('\\'+s);
              }
          }

          String searchs ='FIND {'+toFind+'} IN ALL FIELDS RETURNING InsurancePolicy__c('+queryPol+')'; 
          system.debug('##searchs: '+searchs);
          List<List<SObject>> ListPolicies = search.query(searchs);

          List<InsurancePolicy__c> ListPoliciesQuery = new list<InsurancePolicy__c>();
          ListPoliciesQuery = ((List<InsurancePolicy__c>)ListPolicies[0]);

      for (InsurancePolicy__c policies : [Select Id,CUID__r.Id,CUID__r.Name,CUID__r.Flag_Fonte_QUADRA__c, CUID__r.Fiscal_id__c, CUID__r.AAI_Codice_fiscale__c, CUID__r.tech_company__c, CUID__r.Account_Email__c,CUID__r.Personemail,CUID__r.CIF_PersonEmail__c,CUID__r.CIF_Personalemail__c,CUID__r.RecordType.Name,Targa_veicolo__c,CUID__r.AAI_Agency__r.Name, CUID__r.AAI_Partita_IVA__c,CUID__r.Partita_IVA__c from InsurancePolicy__c where id in:ListPoliciesQuery]) 
          {
            FoundCustomers Fc= new FoundCustomers();
            Fc.Id = policies.CUID__r.Id;
            Fc.Nome = policies.CUID__r.Name;
            Fc.Agenzia = policies.CUID__r.AAI_Agency__r.Name;

            if(String.isNotBlank(policies.Targa_veicolo__c) && (policies.Targa_veicolo__c == Plate))
              Fc.Targa = policies.Targa_veicolo__c;

            if(CustomerType=='fisica')
            {
              if(String.isNotBlank(policies.CUID__r.Fiscal_id__c))
                Fc.Fiscale = policies.CUID__r.Fiscal_id__c;
              else if(String.isNotBlank(policies.CUID__r.AAI_Codice_fiscale__c))
                Fc.Fiscale = policies.CUID__r.AAI_Codice_fiscale__c;
              else if (String.isNotBlank(policies.CUID__r.Partita_IVA__c))
                Fc.Fiscale = policies.CUID__r.Partita_IVA__c; 
              else if (String.isNotBlank(policies.CUID__r.AAI_Partita_IVA__c))
                Fc.Fiscale = policies.CUID__r.AAI_Partita_IVA__c; 
              else
                Fc.Fiscale='';
            }
            else
            {
              if(String.isNotBlank(policies.CUID__r.Partita_IVA__c))
                Fc.Fiscale = policies.CUID__r.Partita_IVA__c;
              else if(String.isNotBlank(policies.CUID__r.AAI_Partita_IVA__c))
                Fc.Fiscale = policies.CUID__r.AAI_Partita_IVA__c;
              else
                Fc.Fiscale='';
            }
        
        if(policies.CUID__r.tech_company__c == 'AAI')
          Fc.Company = 'Cliente Axa Assicurazioni';
        else if(policies.CUID__r.tech_company__c == 'AMF')
          Fc.Company = 'Cliente AXA MPS Financial';
        else if(policies.CUID__r.Flag_Fonte_QUADRA__c == AP_Constants.FLAG_SI)
          Fc.Company = 'Cliente Quadra Assicurazioni';
        else if(String.isBlank(policies.CUID__r.tech_company__c) || (policies.CUID__r.tech_company__c == 'MPS') || MPSCompany.contains(policies.CUID__r.tech_company__c))
          Fc.Company = 'Cliente AXA MPS';
        else if((policies.CUID__r.tech_company__c == 'Quadra') || QuadraCompany.contains(policies.CUID__r.tech_company__c))
          Fc.Company = 'Cliente Quadra Assicurazioni';

        if(policies.CUID__r.RecordType.Name == 'Individual' || policies.CUID__r.RecordType.Name == 'B2C Client')
            {
              Fc.AccountEmail = (policies.CUID__r.RecordType.Name == 'Individual')?policies.CUID__r.Personemail:policies.CUID__r.CIF_PersonEmail__c;
            }
            else if(policies.CUID__r.RecordType.Name == 'Corporate' || policies.CUID__r.RecordType.Name == 'B2B Client')
            {
              Fc.AccountEmail = (policies.CUID__r.RecordType.Name == 'Corporate')?policies.CUID__r.Account_Email__c:policies.CUID__r.CIF_Personalemail__c;
            }
            
        Fc.PolicyId = policies.id;              

            FcL.Founds.add(Fc);
            FcL.MapIdToFounds.put(Fc.Id,Fc);  
          }          
        }
        return FcL;
  }

  @AuraEnabled
  //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
  //public static List<Case> SearchCases(String AccountId)
  public static List<Case> SearchCases(String AccountId, String FormType){
    return SearchCases(AccountId, FormType, null);
  }

  @AuraEnabled
  //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
  //public static List<Case> SearchCases(String AccountId)
  public static List<Case> SearchCases(String AccountId, String FormType, String recordTypeDeveloperName){
  //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
  
    //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
    //String queryCase = 'Select Id, CaseNumber,format(createddate) creazione, Oggetto_apertura_case__c,toLabel(Origin) from Case where recordtype.name =\'Caring Angel\' and AccountId=\''+AccountId+'\' and isclosed = false';
    // Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - START -->
    String queryCase = 'Select Id, CaseNumber,format(createddate) creazione, Oggetto_apertura_case__c,Status,toLabel(Origin) from Case where AccountId=\''+AccountId+'\' and isclosed = false';
    // Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - END -->
    if('Caring_Angel_Property'.equals(recordTypeDeveloperName)){
      queryCase+=' and recordtype.DeveloperName = ' + '\'' + recordTypeDeveloperName + '\'';
    } else if(FormType=='Sinistri')
      queryCase+=' and recordtype.name in (\'Caring Angel\',\'Sinistri Danni Banca\',\'Sinistri AAI\')';
    else
      queryCase+=' and recordtype.name =\'Caring Angel\'';

    queryCase+=' order by createddate desc';
    //MOSCATELLI_M 13/03/2019: Axa Assistance -- END

    List<Case> CaseList = new List<Case>();
    
    for(Case c: Database.query(queryCase))
    {
      CaseList.add(c);
    }

    return CaseList;
  }

  public class NewCaseOutput
  {
    @AuraEnabled public Boolean isSuccess;
    @AuraEnabled public String Msg;
    @AuraEnabled public String CsId;
    @AuraEnabled public String CsNumber;

    public NewCaseOutput()
    {
      this.isSuccess = false;
      this.Msg = '';
      this.CsId='';
      this.CsNumber='';
    }      
  }

  @AuraEnabled
  public static NewCaseOutput generateNewCase(String Id,String AccountEmail, String PolicyId, String Targa, String CaseRT, String VoiceCall)
  {
    NewCaseOutput NcO = new NewCaseOutput();
	
	//OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
	String LOBSinitri = '';
	String CategoryOpening = '';
	if(MPS_Code_Variables__c.getValues('prepopulatedLOBSinistri')!=null)
    {
        if(String.isNotBlank(MPS_Code_Variables__c.getValues('prepopulatedLOBSinistri').value__c))
        {
            LOBSinitri = MPS_Code_Variables__c.getValues('prepopulatedLOBSinistri').value__c;
        }
    }
    if(MPS_Code_Variables__c.getValues('prepopulatedCategoryOpening')!=null)
    {
        if(String.isNotBlank(MPS_Code_Variables__c.getValues('prepopulatedCategoryOpening').value__c))
        {
            CategoryOpening = MPS_Code_Variables__c.getValues('prepopulatedCategoryOpening').value__c;
        }
    }
    List<String> recordTypeSinistri = new List<String>();
    if(MPS_Code_Variables__c.getValues('RecordTypeSinistriLabel')!=null)
    {
        if(String.isNotBlank(MPS_Code_Variables__c.getValues('RecordTypeSinistriLabel').value__c))
        {
            for(String s:(MPS_Code_Variables__c.getValues('RecordTypeSinistriLabel').value__c).split(';'))
            {
                recordTypeSinistri.add(s);                
            }
        }
    }
	//OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
	
    Case ca = new Case();
    
    ca.AccountId = Id;
    ca.Origin = AP_Constants.caseOriginPhone;
    ca.Complainant__c = 'Customer';

    //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
    String CurrentUserProfile = [Select Name from Profile where id=:Userinfo.getProfileId()].Name;
    // caring property
    String recordTypeDeveloperName = '';
    if(CaseRT != null && String.isNotBlank(CaseRT))
      recordTypeDeveloperName= RecordTypeUtility.getDeveloperNameById('Case', CaseRT);
    if(!String.isBlank(CaseRT) && 'Caring_Angel_Property'.equalsIgnoreCase(recordTypeDeveloperName)){
      ca.RecordTypeId = CaseRT;
      ca.Lob__c='Casa e Famiglia';
      ca.Category__c = 'Sinistro Caring Angel Property';
      ca.SubCategory__c='Denuncia sinistro';
    } else if( (!String.isBlank(CaseRT) && 'Caring_Angel'.equalsIgnoreCase(recordTypeDeveloperName)) || (String.isBlank(CaseRT) && CurrentUserProfile.indexOf('Caring') <> -1)) {
      ca.RecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseCaringAngel).getRecordTypeId(); 
      ca.Lob__c='Motor';
      ca.Category__c='Sinistro Caring Angel';
      ca.SubCategory__c='Denuncia sinistro';    
    }
    else if(String.isBlank(CaseRT) && CurrentUserProfile== 'AXA Assistance')
    {
      ca.RecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseSinistro).getRecordTypeId(); 
      //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
      SinistriUtils.runProcessTeamAndMilestone = true;
      ca.Lob__c= (String.isNotBlank(LOBSinitri))?LOBSinitri:'';
      ca.Category__c= (String.isNotBlank(CategoryOpening))?CategoryOpening:'';
      //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
    }
    else
    {
		ca.RecordTypeId = CaseRT;
	    //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
	    if(recordTypeSinistri.contains(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(CaseRT).getName()))
	    {
	    	SinistriUtils.runProcessTeamAndMilestone = true;
      		ca.Lob__c= (String.isNotBlank(LOBSinitri))?LOBSinitri:'';
	      	ca.Category__c= (String.isNotBlank(CategoryOpening))?CategoryOpening:'';
	    }
	    //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
    }
    //MOSCATELLI_M 13/03/2019: Axa Assistance -- END

    ca.Status = AP_Constants.caseStatusAssigned;

    if(String.isNotBlank(AccountEmail))
      ca.Account_Email__c = AccountEmail;

    if(String.isNotBlank(PolicyId))
      ca.LinkToPolicy__c = PolicyId;

    if(String.isNotBlank(Targa))
      ca.Targa__c = Targa;

    if(String.isNotBlank(VoiceCall))
      ca.TECH_Voice_Call__c = VoiceCall;

    try
        {
            List<Case> caseToInsertList = new List<Case>();
            caseToInsertList.add(ca);

            Database.SaveResult[] srList = Database.insert(caseToInsertList, false);

            for (Database.SaveResult sr : srList) 
            {
                if (sr.isSuccess()) 
                {
                  Case cb = [Select Id,Casenumber from Case where id=:sr.getId() limit 1];
                    NcO.CsId = cb.Id;
                    NcO.CsNumber = cb.Casenumber;
                    NcO.isSuccess=true;
                }
                else
                {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                    
                  NcO.Msg = 'La funzionalità non è al momento disponibile. Contatta l\'Amministratore di sistema';
                  NcO.isSuccess=false;
                }
            }      
    }
    catch(exception ex)
    {
      system.debug(ex);
          NcO.Msg = 'La funzionalità non è al momento disponibile. Contatta l\'Amministratore di sistema';
          NcO.isSuccess=false;      
    }

    return NcO;
  }
  // Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - START -->
  @AuraEnabled
  public static NewCaseOutput generateNewCaseNoAnagrafica(String CaseRT)
  {
    System.debug('*** generateNewCaseNoAnagrafica START');
    NewCaseOutput NcO = new NewCaseOutput();
    
    //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
    String LOBSinitri = '';
    String CategoryOpening = '';
    if(MPS_Code_Variables__c.getValues('prepopulatedLOBSinistri')!=null)
    {
        if(String.isNotBlank(MPS_Code_Variables__c.getValues('prepopulatedLOBSinistri').value__c))
        {
            LOBSinitri = MPS_Code_Variables__c.getValues('prepopulatedLOBSinistri').value__c;
        }
    }
    if(MPS_Code_Variables__c.getValues('prepopulatedCategoryOpening')!=null)
    {
        if(String.isNotBlank(MPS_Code_Variables__c.getValues('prepopulatedCategoryOpening').value__c))
        {
            CategoryOpening = MPS_Code_Variables__c.getValues('prepopulatedCategoryOpening').value__c;
        }
    }
    List<String> recordTypeSinistri = new List<String>();
    if(MPS_Code_Variables__c.getValues('RecordTypeSinistriLabel')!=null)
    {
        if(String.isNotBlank(MPS_Code_Variables__c.getValues('RecordTypeSinistriLabel').value__c))
        {
            for(String s:(MPS_Code_Variables__c.getValues('RecordTypeSinistriLabel').value__c).split(';'))
            {
                recordTypeSinistri.add(s);                
            }
        }
    }
    //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
    
    Case ca = new Case();
    
    

    //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
    String CurrentUserProfile = [Select Name from Profile where id=:Userinfo.getProfileId()].Name;

    if(String.isBlank(CaseRT) && CurrentUserProfile.indexOf('Caring')<>-1)
    {
      String rType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseCaringAngel).getRecordTypeId(); 
      System.debug('*** RECORD TYPE: '+rType);
      ca.RecordTypeId =  rType; 
      ca.Lob__c='Motor';
      ca.Category__c='Sinistro Caring Angel';
      ca.SubCategory__c='Denuncia sinistro';    
    }
    else if(String.isBlank(CaseRT) && CurrentUserProfile== 'AXA Assistance')
    {
      ca.RecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(AP_Constants.rtCaseSinistro).getRecordTypeId(); 
      //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
      SinistriUtils.runProcessTeamAndMilestone = true;
      ca.Lob__c= (String.isNotBlank(LOBSinitri))?LOBSinitri:'';
      ca.Category__c= (String.isNotBlank(CategoryOpening))?CategoryOpening:'';
      //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
    }
    else
    {
        ca.RecordTypeId = CaseRT;
        //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
        if(recordTypeSinistri.contains(Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(CaseRT).getName()))
        {
            SinistriUtils.runProcessTeamAndMilestone = true;
            ca.Lob__c= (String.isNotBlank(LOBSinitri))?LOBSinitri:'';
            ca.Category__c= (String.isNotBlank(CategoryOpening))?CategoryOpening:'';
        }
        //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
    }
    //MOSCATELLI_M 13/03/2019: Axa Assistance -- END

    ca.Status = AP_Constants.caseStatusAssigned;

    
    try
        {   
            List<Case> caseToInsertList = new List<Case>();
            caseToInsertList.add(ca);
            System.debug('###ca ' + ca);
        
            Database.SaveResult[] srList = Database.insert(caseToInsertList, false);

            for (Database.SaveResult sr : srList) 
            {
                if (sr.isSuccess()) 
                {
                  Case cb = [Select Id,Casenumber from Case where id=:sr.getId() limit 1];
                    NcO.CsId = cb.Id;
                    NcO.CsNumber = cb.Casenumber;
                    NcO.isSuccess=true;
                }
                else
                {
                  NcO.Msg = 'La funzionalità non è al momento disponibile. Contatta l\'Amministratore di sistema';
                  NcO.isSuccess=false;
                }
            }   
            
            System.debug('** BEFORE INSERT CASE');
            insert ca;
            System.debug('** AFTER INSERT CASE: '+ca);
            Case cb = [Select Id,Casenumber from Case where id=:ca.Id limit 1];
            NcO.CsId = cb.Id;
            NcO.CsNumber = cb.Casenumber;
            NcO.isSuccess=true;
            System.debug('** NCO: '+NcO);
    }
    catch(exception ex)
    {
      system.debug(ex);
          NcO.Msg = 'La funzionalità non è al momento disponibile. Contatta l\'Amministratore di sistema';
          NcO.isSuccess=false;      
    }

    return NcO;
  }
  // Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - END -->

    // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II
    /**
     * Return Map<FieldName, Value> of default values of "Case rapido"
     *
     * @return response
     */
    @AuraEnabled
    public static Map<Object, Object> getCaseRapidoPrepopulatedFields() {
        Map<Object, Object> response = new Map<Object, Object>();

        String LOB = '';
        String category = '';
        if (MPS_Code_Variables__c.getValues('prepopulatedLOBCaseRapido') != null &&
                String.isNotBlank(MPS_Code_Variables__c.getValues('prepopulatedLOBCaseRapido').Value__c)) {
            LOB = MPS_Code_Variables__c.getValues('prepopulatedLOBCaseRapido').Value__c;
        }

        if (MPS_Code_Variables__c.getValues('prepopulatedCategoryCaseRapido') != null &&
                String.isNotBlank(MPS_Code_Variables__c.getValues('prepopulatedCategoryCaseRapido').Value__c)) {
            category = MPS_Code_Variables__c.getValues('prepopulatedCategoryCaseRapido').Value__c;
        }

        response.put('LOB__c', LOB);
        response.put('Category__c', category);

        return response;
    }

    @AuraEnabled
    public static String createCaseRapido(String recordTypeId) {
      Map<Object, Object> response = NewLightningCase_CTRL.getCaseRapidoPrepopulatedFields();
      Case c = new Case();
      c.Status = 'Closed';
      c.Origin = 'Phone';
      c.LOB__c = (String) response.get('LOB__c');
      c.Category__c = (String) response.get('Category__c');
      c.RecordTypeId = recordTypeId;
      insert c;
      return c.Id;
    }

}
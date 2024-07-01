global class AP02WebToCaseWS
{
    /* 
----------------------------------------------------------------------
-- - Name          : AP02WebToCaseWS
-- - Author        : Spoon Consulting
-- - Description   : 
--
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
--              SC     1.0     Initial version
-- 23-FEB-2015  YRA    1.1     Updated version
----------------------------------------------------------------------
***********************************************************************/
    
    webService static string createCase(Case caseInfo, list<Attachment> listAttachment)
    {
        system.debug('#####Caseinfo Inputs: '+caseInfo);
        list<Attachment> listInsertAttachment = new list<Attachment>();
        map<String,Id> case_developerIdMap = new map <String,Id>();
        case_developerIdMap = AP_Constants.getDeveloperIdMap(AP_Constants.sobjectCas);
        system.debug('case_developerIdMap:'+case_developerIdMap);
        map<String,Id> queueMap = new map<String,Id>();
        
        Map<String,String> MapRecTypAccFound = new map<String,String>();
        
        //SPINELLI_F 14122015: EVO-39-----START
        integer Duplicate=0;     
        //SPINELLI_F 14122015: EVO-39-----END
        
        //MOSCATELLI_M 05082015: EVO-08-----START
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        //MOSCATELLI_M 05082015: EVO-08-----END
        
        //MOSCATELLI_M 17082015: Query bugfixing-----START
        id rtAccountIndividual = AP_Constants.getDeveloperIdMap( AP_Constants.sobjectAcc ).get( AP_Constants.rtAccIndividualClient );
        id rtAccountIntermediary = AP_Constants.getDeveloperIdMap( AP_Constants.sobjectAcc ).get( 'Intermediary');
        id rtAccountAgency = AP_Constants.getDeveloperIdMap( AP_Constants.sobjectAcc ).get( AP_Constants.rtAccCorporateClient);
        //MOSCATELLI_M 17082015: Query bugfixing-----END
        
        //PETRECCHIA_M 01022016: EVO-18-----START
        id rtAccountB2C = AP_Constants.getDeveloperIdMap( AP_Constants.sobjectAcc ).get( AP_Constants.rtAccB2C); 
        id rtAccountB2B = AP_Constants.getDeveloperIdMap( AP_Constants.sobjectAcc ).get( AP_Constants.rtAccB2B);
        //PETRECCHIA_M 01022016: EVO-18-----END
        
        //MOSCATELLI_M 10102016: Family Protect -- START
        id rtAccountAAF = AP_Constants.getDeveloperIdMap( AP_Constants.sobjectAcc).get( AP_Constants.rtAccAAFB2C);
        id rtCaseAAF = AP_Constants.getDeveloperIdMap( AP_Constants.sobjectCas).get( AP_Constants.rtCaseFamilyProtect);
        //MOSCATELLI_M 10102016: Family Protect -- END
        
        //MOSCATELLI_M 20042016: EVO 51 -- START
        id policyaccount;
        Map<String,Id> CaseRecTypMap = new map<String,Id>();
        
        for(RecordType rec : [Select Id,Name From RecordType Where SobjectType = 'Case'])
        {
            CaseRecTypMap.put(rec.Name, rec.Id);
        }        
        //MOSCATELLI_M 20042016: EVO 51 -- END
        
        try
        {
            Account fiscal;
            Account employee;
            contact con;
            /*
if(caseinfo.Fiscal_ID__c<>null){
fiscal= new Account(Fiscal_ID__c = caseinfo.AccountID__c);
caseInfo.Account = fiscal;
}


if(caseinfo.AgentId__c<>null){
employee= new Account(Matricola__c = caseinfo.AgentId__c);
caseInfo.AgentName__r = employee;
}
*/
            
            //PETRECCHIA_M 01022016: EVO-18-----START
            /*
if(string.isNotBlank(caseinfo.AgentId__c) || string.isNotBlank(caseinfo.AccountID__c)){
for(Account acc:[select id,Matricola__c,Fiscal_ID__c
from Account
where (RecordTypeId =: rtAccountIndividual //MOSCATELLI_M 17082015: Query bugfixing
or RecordTypeId =: rtAccountIntermediary //MOSCATELLI_M 17082015: Query bugfixing
or RecordTypeId =: rtAccountAgency) //MOSCATELLI_M 17082015: Query bugfixing
and ((Matricola__c=:caseinfo.AgentId__c
and Matricola__c <> null)
or (Fiscal_ID__c=:caseinfo.AccountID__c
and Fiscal_ID__c <> null))
order by lastmodifieddate asc]){                                                       
if(string.isNotBlank(caseinfo.AgentId__c) && acc.Matricola__c == caseinfo.AgentId__c){
caseInfo.AgentName__c = acc.id;
}
else if(string.isNotBlank(caseinfo.AccountID__c) && acc.Fiscal_ID__c == caseinfo.AccountID__c){
caseInfo.Accountid = acc.id;
}
}
}     
*/                
            //Intermediary to Case
            //MOSCATELLI_M 04/11/2016: EVO 67 - Webform AXA Planet -- START
            /*            
if (string.isNotBlank(caseinfo.AgentId__c)){
List<Account> agenteacc = [Select Matricola__c,id,RecordTypeId FROM Account where RecordTypeId =: rtAccountIntermediary and Matricola__c =: caseinfo.AgentId__c];
Map<String,Account> agente = new map <String,Account> (); 
for(Account a : agenteacc){ 
agente.put(a.Matricola__c,a);
}
for(Account acc : agente.values()){    
if(string.isNotBlank(caseinfo.AgentId__c) && acc.Matricola__c == caseinfo.AgentId__c){
caseInfo.AgentName__c = acc.id;
}
}
}
*/
            if (string.isNotBlank(caseinfo.AgentId__c))
            {                   
                List <Account> AgentList = [Select Matricola__c,id,RecordTypeId FROM Account where RecordTypeId =: rtAccountIntermediary and Matricola__c =: caseinfo.AgentId__c];
                
                if(AgentList.size()>0)
                    caseInfo.AgentName__c = AgentList[0].id;                    
            }            
            //MOSCATELLI_M 04/11/2016: EVO 67 - Webform AXA Planet -- END
            //PETRECCHIA_M 01022016: EVO-18-----END
            
            if(string.isNotBlank(caseinfo.PolicyID__c))
            {
                //MOSCATELLI_M 20042016: EVO 51 -- START
                /*
list<InsurancePolicy__c> listPolicy= new list<InsurancePolicy__c>([select id 
from InsurancePolicy__c
where Name = :caseinfo.PolicyID__c]);
*/
                
                String PolCompany = 'MPS';
                MPS_Code_Variables__c mapMPSTECHCompany = MPS_Code_Variables__c.getValues('TECH Company MPS');
                MPS_Code_Variables__c mapQuadraTECHCompany = MPS_Code_Variables__c.getValues('TECH Company Quadra');
                String CaseType = caseInfo.RecordTypeID;
                list<InsurancePolicy__c> listPolicy= new list<InsurancePolicy__c>();
                list<InsurancePolicyAAF__c> listPolicyAAF= new list<InsurancePolicyAAF__c>();//MOSCATELLI_M 10102016: Family Protect
                system.debug('##RecordTypeID :'+caseInfo.RecordTypeID);

                List<String> listMPSTECHCompany = new List<String>();
                List<String> listQuadraTECHCompany = new List<String>();
                listMPSTECHCompany = mapMPSTECHCompany.Value__c.split(';');
                listQuadraTECHCompany = mapQuadraTECHCompany.Value__c.split(';');
                
                if(Test.isRunningTest())
                {
                    if(caseInfo.RecordTypeID == AP_Constants.getDeveloperIdMap( AP_Constants.sobjectCas).get( AP_Constants.rtCaseAAI))
                        CaseType = 'Axa Assicurazioni';
                    else if(caseInfo.RecordTypeID == AP_Constants.getDeveloperIdMap( AP_Constants.sobjectCas).get( AP_Constants.rtCaseQuadra))
                        CaseType = 'Quadra';    
                }
                
                if(CaseType !='')
                {
                    if(CaseType =='Axa Assicurazioni')
                        PolCompany = 'AAI';
                    else if(CaseType =='Quadra')
                        PolCompany = 'Quadra';
                }                
                system.debug('##PolCompany : '+PolCompany);
                
                if(PolCompany!='MPS')
                {

                    if(PolCompany=='AAI'){

                    listPolicy = ([select id, CUID__c 
                                   from InsurancePolicy__c
                                   where Name = :caseinfo.PolicyID__c and TECH_Company__c =:PolCompany ]);
                    }
                    else if(PolCompany=='Quadra'){

                        listPolicy = ([select id, CUID__c 
                                   from InsurancePolicy__c
                                   where Name = :caseinfo.PolicyID__c and (TECH_Company__c =:PolCompany or TECH_Company__c IN:listQuadraTECHCompany)]);


                    }
                    
                    //MOSCATELLI_M 10102016: Family Protect -- START
                    listPolicyAAF = ([select id,Subscriber_national_identifier__c from InsurancePolicyAAF__c where Name=:caseinfo.PolicyID__c]);
                    //MOSCATELLI_M 10102016: Family Protect -- END                    
                }
                else
                {
                    listPolicy =  ([select id, CUID__c 
                                    from InsurancePolicy__c
                                    where Name = :caseinfo.PolicyID__c and (TECH_Company__c =:PolCompany or TECH_Company__c='' or TECH_Company__c IN:listMPSTECHCompany)]);                  
                }              
                //MOSCATELLI_M 20042016: EVO 51 -- END
                
                if(listPolicy.size() == 1)
                {                                                                 
                    caseInfo.LinkToPolicy__c = listPolicy[0].id;
                    
                    //MOSCATELLI_M 20042016: EVO 51 -- START
                    if(string.isNotBlank(listPolicy[0].CUID__c))
                        policyaccount = listPolicy[0].CUID__c;
                    //MOSCATELLI_M 20042016: EVO 51 -- END
                }
                
                //MOSCATELLI_M 10102016: Family Protect -- START
                if(listPolicyAAF.size()==1 && String.isBlank(policyaccount))
                {
                    caseInfo.Insurance_Policy_AAF__c = listPolicyAAF[0].Id;
                    
                    if(string.isNotBlank(listPolicyAAF[0].Subscriber_national_identifier__c))
                    {
                        policyaccount = listPolicyAAF[0].Subscriber_national_identifier__c;
                    }
                }
                //MOSCATELLI_M 10102016: Family Protect -- END
            }   
            system.debug('Matricola:' +caseinfo.AgentId__c); //Agent's Matricola
            
            //Updated YRA : 23/02/15 - retrieve salesforce category from custom setting
            Map<String,CaseCategory__c> mapCaseCategories = CaseCategory__c.getAll();
            system.debug('mapCaseCategories:'+mapCaseCategories);
            List<MPS_Code_Utils__mdt> mpsCodes = [SELECT Id, DeveloperName, Value__c FROM MPS_Code_Utils__mdt WHERE DeveloperName = 'CategorieSinistriBranchMain'];
            List<String> categorieSinistri = new List<String>();
            for(MPS_Code_Utils__mdt mpsco : mpsCodes)
            {
                if(mpsco.DeveloperName == 'CategorieSinistriBranchMain')
                {
                    if(String.isNotBlank(mpsco.Value__c))
                    {
                        for(String s:mpsco.Value__c.split(';'))
                        {
                            categorieSinistri.add(s);
                        }   
                    }
                }
            }
            //loop in cs && assign salesforce category
            for (CaseCategory__c cc:mapCaseCategories.values())
            {
                //OAVERSANO 30/05/2019 : fix mapping -- START
                if(categorieSinistri.contains(cc.CategoryBranchMain__c))
                {
                    if(cc.CategoryBranchMain__c == caseInfo.Category__c && cc.Sub_Category_Branch_Main__c == caseInfo.SubCategory__c)
                    {
                        system.debug('transcoding');
                        caseInfo.Category__c = cc.CategorySaleforce__c;
                        
                        caseInfo.SubCategory__c = cc.Sub_Category_Saleforce__c;
                        
                        if(String.isNotBlank(cc.LOB__c))
                            caseInfo.LOB__c = cc.LOB__c;
    
                        if(String.isNotBlank(cc.Record_Type__c))
                            caseInfo.RecordTypeId = CaseRecTypMap.get(cc.Record_Type__c);
                    }
                }
                //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- START
                
                else
                //OAVERSANO 17/05/2019 : AXA Assistance Enhancement Fase I -- END
                {
                    if(cc.CategoryBranchMain__c == caseInfo.Category__c)
                    {
                        system.debug('transcoding');
                        caseInfo.Category__c = cc.CategorySaleforce__c;
                        
                        
                        //MOSCATELLI_M 09/04/2018: Apertura sinistri da email -- START
                        if(String.isNotBlank(cc.LOB__c))
                            caseInfo.LOB__c = cc.LOB__c;
    
                        if(String.isNotBlank(cc.Record_Type__c))
                            caseInfo.RecordTypeId = CaseRecTypMap.get(cc.Record_Type__c);
                    }
                }//end if
                //OAVERSANO 30/05/2019 : fix mapping -- END
            }//end loop
            
            //Updated YRA: 05/03/2015 - the category contains the string "auto" then it is a Motor record type
            for(Group g:[Select Id,Name,DeveloperName 
                         From Group                         
                         Where Type = 'Queue'
                         and (DeveloperName = 'Motor' or DeveloperName='NonMotor' or DeveloperName='Axa_Assicurazioni' or DeveloperName='Quadra')]){//MOSCATELLI_M 05082015: EVO-08                        
                             queueMap.put(g.DeveloperName,g.id);
                         }
            system.debug('queueMap:'+queueMap);            
            system.debug('INFORMAZIONI:'+caseInfo);
            
            //MOSCATELLI_M 05082015: EVO-08-----START            
            if(String.ISNOTBLANK(caseInfo.Category__c))
            {                
                if(String.ISNOTBLANK(caseInfo.RecordTypeID))
                {
                    //MMOSCATELLI 17/02/2016: Evo18--START
                    //RecordType CaseRecTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name =: caseInfo.RecordTypeID];
                    //system.debug('RecordType not void: '+caseInfo.RecordTypeID+' RecordTypeID: '+CaseRecTypeId.Id);
                    // caseInfo.RecordTypeId = CaseRecTypeId.Id;                      
                    
                    //MOSCATELLI_M 02052016: Bugfix Evo 18 -- START
                    //List<RecordType> CaseRecTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name =: caseInfo.RecordTypeID];
                    
                    if(CaseRecTypMap.containsKey(caseInfo.RecordTypeID))
                        caseInfo.RecordTypeId = CaseRecTypMap.get(caseInfo.RecordTypeID);                    
                    /*
if(!CaseRecTypeId.isEmpty())                    
caseInfo.RecordTypeId = CaseRecTypeId[0].id;
*/
                    //MMOSCATELLI 17/02/2016: Evo18--END
                    //MOSCATELLI_M 02052016: Bugfix Evo 18 -- END               
                }
                else
                {                    
                    if( caseInfo.Category__c.tolowercase().Contains('auto'))
                    {
                        caseInfo.RecordTypeId = case_developerIdMap.get(AP_Constants.rtCaseMotor);
                        //caseInfo.OwnerId = queueMap.get(AP_Constants.rtCaseMotor);
                    }
                    else
                    {
                        caseInfo.RecordTypeId = case_developerIdMap.get(AP_Constants.rtCaseNonMotor);
                        //caseInfo.OwnerId = queueMap.get(AP_Constants.rtCaseNonMotor);
                    }
                }
            }
            //PETRECCHIA_M 01022016: EVO-18-----START
            
            system.debug('TIPORECORD: '+caseInfo.RecordTypeID+' Origin: '+caseInfo.Origin+' '+'AccountId:'+caseinfo.AccountID__c);
            
            //MOSCATELLI 31/03/2017: Webform ConFido -- START
            if(String.isNotBlank(caseInfo.AccountId__c))
            {
                List<List<SObject>> ListAccounts=[FIND :caseInfo.AccountId__c IN ALL FIELDS RETURNING Account(ID,recordtype.developername where (Fiscal_ID__c=:caseInfo.AccountId__c  or Partita_IVA__c=:caseInfo.AccountId__c or AAI_Partita_IVA__c=:caseInfo.AccountId__c or AAI_Codice_fiscale__c=:caseInfo.AccountId__c or Codice_Fiscale_AAF__c=:caseInfo.AccountId__c))];
                
                List<Account> ListAccountsQuery = new list<Account>();
                
                List<Account> AccList = ((List<Account>)ListAccounts[0]);
                
                Set<String> AlreadyFoundKey = new Set<String>();
                Set<String> NewKey = new Set<String>();
                
                for(Account a :AccList)
                {
                    if(!NewKey.contains(a.recordtype.developername))
                    {
                        NewKey.add(a.recordtype.developername);
                        MapRecTypAccFound.put(a.recordtype.developername, a.Id);
                    }                      
                    else
            AlreadyFoundKey.add(a.recordtype.developername);                    
                }
                
                if(AlreadyFoundKey.size()>0)
                {
                    for(String s:AlreadyFoundKey)
                    {
                        if(MapRecTypAccFound.containsKey(s))
                           MapRecTypAccFound.remove(s);   
                    }                    
                } 
                system.debug('####MapRecTypAccFound: '+MapRecTypAccFound);
            }                        
           //MOSCATELLI 31/03/2017: Webform ConFido -- END
           
            if(caseInfo.RecordTypeId == case_developerIdMap.get(AP_Constants.rtCaseAAI) && (caseInfo.Origin<>AP_Constants.caseOriginBranchMain) && (caseInfo.Origin<>AP_Constants.caseOriginAXAPlanet) && string.isNotBlank(caseinfo.AccountID__c))
            {                 
                //B2C Account and AAI case Record Type 
                //List<Account> B2Cacc = [Select  AAI_Codice_fiscale__c,Fiscal_ID__c, ID, RecordTypeId from Account where RecordTypeId =: rtAccountB2C and AAI_Codice_fiscale__c=:caseinfo.AccountID__c limit 1];                
                
                if(MapRecTypAccFound.containsKey(Ap_Constants.rtAccB2C))
                { 
                    Account acc = new Account(id = MapRecTypAccFound.get(Ap_Constants.rtAccB2C));
                    acc.Additional_Email__c=caseInfo.SuppliedEmail;
                    caseInfo.Accountid=MapRecTypAccFound.get(Ap_Constants.rtAccB2C);
                    //MOSCATELLI 31/03/2017: Webform ConFido -- START
                    if(caseInfo.Origin == Ap_Constants.caseOrigineCommerce)
                    {
                        if(String.isNotBlank(caseinfo.SuppliedPhone))
                        {
                            acc.Additional_Phone__c = caseinfo.SuppliedPhone;
                            caseInfo.Complainant__c = Ap_Constants.rtCaseCustComp;
                        }
                    }
                    //MOSCATELLI 31/03/2017: Webform ConFido -- END
                    update acc; 
                }
                else
                {                     
                    //Individual Account and AAI case Record Type 
                    //List<Account> individuoacc = [Select Fiscal_ID__c, ID, RecordTypeId from Account where RecordTypeId =: rtAccountIndividual and Fiscal_ID__c=:caseinfo.AccountID__c limit 1];
                    
                    if(MapRecTypAccFound.containskey(Ap_Constants.rtAccIndividualClient))
                    {
                        caseInfo.Accountid=MapRecTypAccFound.get(Ap_Constants.rtAccIndividualClient);
                        
                        if(String.isNotBlank(caseInfo.SuppliedEmail))
                        {
                            Account acc = new Account(id = MapRecTypAccFound.get(Ap_Constants.rtAccIndividualClient));
                            acc.Additional_Email__c=caseInfo.SuppliedEmail;
                            //MOSCATELLI 31/03/2017: Webform ConFido -- START
                            if(caseInfo.Origin == Ap_Constants.caseOrigineCommerce)
                            {
                                if(String.isNotBlank(caseinfo.SuppliedPhone))
                                {
                                    acc.Additional_Phone__c = caseinfo.SuppliedPhone;
                                    caseInfo.Complainant__c = Ap_Constants.rtCaseCustComp;
                                }
                            }
                            //MOSCATELLI 31/03/2017: Webform ConFido -- END
                            update acc;                             
                        }
                    }                                                                                                                          
                    else
                    {
                        //B2B Account and AAI case Record Type 
                        //List<Account> B2Bacc = [Select  AAI_Partita_IVA__c,AAI_Codice_fiscale__c,Fiscal_ID__c, ID, RecordTypeId from Account where RecordTypeId =: rtAccountB2B and AAI_Partita_IVA__c =:caseinfo.AccountID__c limit 1];
                        
                        if(MapRecTypAccFound.containskey(Ap_Constants.rtAccB2B))
                        {
                            Account acc = new Account(id = MapRecTypAccFound.get(Ap_Constants.rtAccB2B));
                            acc.Additional_Email__c=caseInfo.SuppliedEmail;
                            caseInfo.Accountid=MapRecTypAccFound.get(Ap_Constants.rtAccB2B);
                            //MOSCATELLI 31/03/2017: Webform ConFido -- START
                            if(caseInfo.Origin == Ap_Constants.caseOrigineCommerce)
                            {
                                if(String.isNotBlank(caseinfo.SuppliedPhone))
                                {
                                    acc.Additional_Phone__c = caseinfo.SuppliedPhone;
                                    caseInfo.Complainant__c = Ap_Constants.rtCaseCustComp;
                                }
                            }
                            //MOSCATELLI 31/03/2017: Webform ConFido -- END
                            update acc;
                        }
                        else
                        {
                            //Corporate Account and AAI case Record Type 
                            //List<Account> Corpacc = [Select  AAI_Partita_IVA__c,AAI_Codice_fiscale__c,Fiscal_ID__c, ID, Partita_IVA__c, RecordTypeId from Account where RecordTypeId =: rtAccountAgency and Partita_IVA__c=:caseinfo.AccountID__c limit 1];
                            
                            if(MapRecTypAccFound.containskey(Ap_Constants.rtAccCorporateClient))
                            {
                                caseInfo.Accountid=MapRecTypAccFound.get(Ap_Constants.rtAccCorporateClient);
                                
                                if(String.isNotBlank(caseInfo.SuppliedEmail))
                                {
                                    Account acc = new Account(id = MapRecTypAccFound.get(Ap_Constants.rtAccCorporateClient));
                                    acc.Additional_Email__c=caseInfo.SuppliedEmail;
                                    //MOSCATELLI 31/03/2017: Webform ConFido -- START
                                    if(caseInfo.Origin == Ap_Constants.caseOrigineCommerce)
                                    {
                                        if(String.isNotBlank(caseinfo.SuppliedPhone))
                                        {
                                            acc.Additional_Phone__c = caseinfo.SuppliedPhone;
                                            caseInfo.Complainant__c = Ap_Constants.rtCaseCustComp;
                                        }
                                    }
                                    //MOSCATELLI 31/03/2017: Webform ConFido -- END
                                    update acc;                             
                                }
                            }
                            //MOSCATELLI_M 10102016: Family Protect -- START
                            else
                            {
                                //List<Account> FamilyProtectList = [Select Codice_Fiscale_AAF__c , ID from Account where RecordTypeId =: rtAccountAAF and Codice_Fiscale_AAF__c=:caseinfo.AccountID__c limit 1];                
                                
                                if(MapRecTypAccFound.containskey(Ap_Constants.rtAccAAFB2C))
                                { 
                                    Account acc = new Account(id = MapRecTypAccFound.get(Ap_Constants.rtAccAAFB2C));
                                    acc.Additional_Email__c=caseInfo.SuppliedEmail;
                                    caseInfo.Accountid=MapRecTypAccFound.get(Ap_Constants.rtAccAAFB2C);
                                    update acc; 
                                }                                
                            }
                            //MOSCATELLI_M 10102016: Family Protect -- END
                        }
                    }
                }
            }  
            //Individual and Corporate Account not AAI case Record Type 
            else if(caseInfo.RecordTypeId <> case_developerIdMap.get(AP_Constants.rtCaseAAI)&&string.isNotBlank(caseinfo.AccountID__c) && (caseInfo.Origin<>AP_Constants.caseOriginAXAPlanet))
            {
                //List<Account> individuoacc = [Select Fiscal_ID__c, ID, RecordTypeId from Account where RecordTypeId =: rtAccountIndividual and Fiscal_ID__c=:caseinfo.AccountID__c limit 1];
                //List<Account> Corpacc = [Select  AAI_Partita_IVA__c,AAI_Codice_fiscale__c,Fiscal_ID__c, ID, Partita_IVA__c, RecordTypeId from Account where RecordTypeId =: rtAccountAgency and Partita_IVA__c=:caseinfo.AccountID__c limit 1];
                
                if(MapRecTypAccFound.containskey(Ap_Constants.rtAccIndividualClient))
                {
                    caseInfo.Accountid=MapRecTypAccFound.get(Ap_Constants.rtAccIndividualClient);
                    
                    if(String.isNotBlank(caseInfo.SuppliedEmail))
                    {
                        Account acc = new Account(id = MapRecTypAccFound.get(Ap_Constants.rtAccIndividualClient));
                        acc.Additional_Email__c=caseInfo.SuppliedEmail;
                        update acc;                             
                    }                    
                }
                else if(MapRecTypAccFound.containskey(Ap_Constants.rtAccCorporateClient))
                {
                    caseInfo.Accountid=MapRecTypAccFound.get(Ap_Constants.rtAccCorporateClient);
                    
                    if(String.isNotBlank(caseInfo.SuppliedEmail))
                    {
                        Account acc = new Account(id = MapRecTypAccFound.get(Ap_Constants.rtAccCorporateClient));
                        acc.Additional_Email__c=caseInfo.SuppliedEmail;
                        update acc;                             
                    }                             
                }                                       
            }
            //PETRECCHIA_M 01022016: EVO-18-----END
            //MOSCATELLI_M 04/11/2016: EVO 67 - Webform AXA Planet -- START
            else if(string.isNotBlank(caseinfo.AccountID__c) && (caseInfo.Origin==AP_Constants.caseOriginAXAPlanet))
            {
                /*
                List<List<SObject>> ListAccounts=[FIND :caseinfo.AccountID__c IN ALL FIELDS RETURNING Account(ID,recordtype.developername where (Fiscal_ID__c=:caseinfo.AccountID__c  or Partita_IVA__c=:caseinfo.AccountID__c or AAI_Partita_IVA__c=:caseinfo.AccountID__c or AAI_Codice_fiscale__c=:caseinfo.AccountID__c or Codice_Fiscale_AAF__c=:caseinfo.AccountID__c))];
                
                List<Account> ListAccountsQuery = new list<Account>();
                
                List<Account> AccList = ((List<Account>)ListAccounts[0]);
        */
                
                if(MapRecTypAccFound.size()==1)
                {
                    for(String s:MapRecTypAccFound.keySet())
                    {
                      caseInfo.Accountid = MapRecTypAccFound.get(s);     
                    }             
                }                                    
            }
            //MOSCATELLI_M 04/11/2016: EVO 67 - Webform AXA Planet -- END
            
            //MOSCATELLI_M 20042016: EVO 51---START
            else if (string.isNotBlank(policyaccount) && string.isBlank(caseinfo.AccountID__c))
            {
                caseInfo.Accountid = policyaccount;
            }            
            
            if(String.isNotBlank(caseInfo.Accountid) && String.isNotBlank(caseinfo.PolicyID__c))
            {
                List<InsurancePolicy__c> PolicyId = [select id from InsurancePolicy__c where Name = :caseinfo.PolicyID__c and CUID__c =: caseInfo.Accountid];
                
                if(!PolicyId.isEmpty() && PolicyId.size()==1)
                    caseInfo.LinkToPolicy__c = PolicyId[0].Id;
                //MOSCATELLI_M 10102016: Family Protect -- START
                else
                {
                    List<InsurancePolicyAAF__c> PolicyAAFid = ([select id from InsurancePolicyAAF__c where Name=:caseinfo.PolicyID__c and Subscriber_national_identifier__c=:caseInfo.Accountid]);
                    
                    if(!PolicyAAFid.isEmpty() && PolicyAAFid.size()==1)
                        caseInfo.Insurance_Policy_AAF__c = PolicyAAFid[0].Id;                       
                }
                //MOSCATELLI_M 10102016: Family Protect -- END
            }
            else if(String.isNotBlank(caseInfo.Accountid) && String.isBlank(caseinfo.PolicyID__c))
            {
                List<InsurancePolicy__c> PolicyId = [select id from InsurancePolicy__c where CUID__c =: caseInfo.Accountid];
                
                if(!PolicyId.isEmpty() && PolicyId.size()==1)
                    caseInfo.LinkToPolicy__c = PolicyId[0].Id;
                
                //MOSCATELLI_M 10102016: Family Protect -- START
                else
                {
                    List<InsurancePolicyAAF__c> PolicyAAFid = ([select id from InsurancePolicyAAF__c where Subscriber_national_identifier__c=:caseInfo.Accountid]);
                    
                    if(!PolicyAAFid.isEmpty() && PolicyAAFid.size()==1)
                        caseInfo.Insurance_Policy_AAF__c = PolicyAAFid[0].Id;                       
                }
                //MOSCATELLI_M 10102016: Family Protect -- END                
            }               
            //MOSCATELLI_M 20042016: EVO 51---END
            
            //MOSCATELLI 31/03/2017: Webform ConFido -- START
            if(caseInfo.Origin == Ap_Constants.caseOrigineCommerce)
            {
                if(String.isBlank(caseInfo.AccountId))
                {
                    caseInfo.Complainant__c = Ap_Constants.rtCaseProspComp;
                    caseInfo.Description= caseInfo.Description+'\n'+'\n'+caseInfo.Oggetto_Apertura_Case__c;
                    caseInfo.Oggetto_Apertura_Case__c ='';
                }
                else
                    caseInfo.Oggetto_Apertura_Case__c ='';
            }
            //MOSCATELLI 31/03/2017: Webform ConFido -- END
            
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;                               
            caseinfo.setOptions(dmlOpts);
            //MOSCATELLI_M 05082015: EVO-08-----END               
            
            //SPINELLI_F 14122015: EVO-39-----START
            
            //MOSCATELLI 31/03/2017: Webform ConFido -- START
            //if(caseInfo.Origin<>AP_Constants.caseOriginAXAPlanet)//MOSCATELLI_M 04/11/2016: EVO 67 - Webform AXA Planet
            if(caseInfo.Origin<>AP_Constants.caseOriginAXAPlanet && caseInfo.Origin<>AP_Constants.caseOrigineCommerce)
             //MOSCATELLI 31/03/2017: Webform ConFido -- END
            {
                list<CASE> ListaCasi = new list <CASE> ([SELECT id, Category__c,CreatedDate,Origin,RecordTypeId,SubCategoryDetail__c,SubCategory__c,SuppliedEmail,Subject,LinkToPolicy__c
                                                         FROM Case
                                                         WHERE Category__c =: caseInfo.Category__c
                                                         AND RecordTypeId=: caseInfo.RecordTypeId
                                                         AND Origin=:caseInfo.Origin 
                                                         AND SubCategory__c=: caseInfo.SubCategory__c
                                                         AND SuppliedEmail =: caseInfo.SuppliedEmail
                                                         //MOSCATELLI 02092016: Bugfix--START
                                                         //AND Subject =:caseInfo.Subject
                                                         AND Oggetto_Apertura_Case__c =:caseInfo.Subject
                                                         //MOSCATELLI 02092016: Bugfix--END
                                                         AND LinkToPolicy__c=:caseInfo.LinkToPolicy__c
                                                         AND CreatedDate > :Datetime.now().addMinutes(-5)
                                                         //MOSCATELLI 02092016: Bugfix--START
                                                         AND (AccountId =:caseInfo.Accountid OR AccountId =:caseInfo.AgentName__c)
                                                         AND AgentName__c=: caseInfo.AgentName__c
                                                         //MOSCATELLI_M 10102016: Family Protect -- START
                                                         AND Recordtypeid !=:rtCaseAAF]
                                                        //MOSCATELLI_M 10102016: Family Protect -- END
                                                        //MOSCATELLI 02092016: Bugfix--END
                                                       );
                
                system.debug('ListaCasi:' +ListaCasi);
                
                list<Attachment> ListaAllegati = new list <Attachment> ([SELECT Body,BodyLength,ContentType,Name,ParentId FROM Attachment where ParentId in : ListaCasi ]); 
                system.debug('ListaAllegati:' +ListaAllegati); // available attachments
                
                If (ListaCasi.size()>0)
                {
                    for(Attachment attach : listAttachment)
                    {
                        for(Attachment ListaAllegat :ListaAllegati)
                        {
                            system.debug('Attachments1:' +listAttachment); 
                            if((attach.Name==ListaAllegat.Name))
                            {
                                Duplicate=Duplicate+1;
                            }
                        }
                        if(Duplicate<>0)
                        {
                            return 'allegato già presente';
                        } 
                        for(Case cas : ListaCasi)
                        {
                            attach.ParentId=cas.Id;
                            listInsertAttachment.add(attach);
                            system.debug('Attachments2:' +listInsertAttachment);
                            if(listInsertAttachment.size()>0)
                            {
                                insert listInsertAttachment;
                            }
                        }
                    }
                    return 'case già presente';
                } //case not created            
                //SPINELLI_F 14122015: EVO-39-----END
            }//MOSCATELLI_M 04/11/2016: EVO 67 - Webform AXA Planet     
            insert caseinfo;
            system.debug('caseinfo:' +caseinfo);                                                       
            system.debug('listAttachment:' +listAttachment);
            for(Attachment attach : listAttachment)
            {
                system.debug('attach.Body:' +attach.Body);
                if(attach.Body<>null)
                {
                    attach.ParentId=caseinfo.id;
                    listInsertAttachment.add(attach);
                }
            }
            
            if(listInsertAttachment.size()>0)
            {
                insert listInsertAttachment;
            }
            return 'ID of created case: '+ caseInfo.id;
        }
        catch(exception ex)
        {
            return 'ERROR: '+ ex.getmessage();
        }
    }
}
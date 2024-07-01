@istest
public with sharing class ModelloAssistenzaCtrl_TEST {
    
    
    @testSetup static void setup() {
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
        ServiceUtilsClass.populateCustomSettingsForTests();
        //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
        
        Id CaseAssistenzaAgentiRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND RecordType.DeveloperName = 'Assistenza_Agenti' LIMIT 1].Id;
        
        //Create agency user
        Profile pvendite = [SELECT Id FROM Profile WHERE Name = 'NFE - AAI - Vendite Avanzato'];     
        Id pVen = pvendite.Id;   
        UserRole role = [SELECT Id FROM UserRole where name = 'Assistenza Agenti - HD2'];//OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz
        Id pRol = role.Id;
        Profile psupp = [SELECT Id FROM Profile WHERE Name = 'AAI - Supporto HD2'];
        Id phd2 = psupp.Id;
        Profile pdigital = [SELECT Id FROM Profile WHERE Name ='AAI - Digital Avanzato'];
        Id pdig = pdigital.Id;
        
        Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
        id contact_agency = UtilityClass.getRTid(rtypes, 'Contact', 'Agency_Contact');
        id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');
        id account_B2C = UtilityClass.getRTid(rtypes, 'Account', 'B2C_Client');
        id account_B2B = UtilityClass.getRTid(rtypes, 'Account', 'B2B_Client');
        
        //Create Partner User
        Account agencyAccount = new Account(Name = 'Agency Test Account',
                                            RecordTypeId = account_agency,
                                            Agency_Code__c = '006345',
                                            Active__c = true,
                                            DAOL_2_0__c = true);
        insert agencyAccount;
        
        Contact agencyContact = new Contact(LastName = 'Agency Test Contact',
                                            RecordtypeId = contact_agency,
                                            AccountId = agencyAccount.Id);
        insert agencyContact;
        
        
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {            
            User usr1=new User(FirstName='Marzia',
                               LastName = 'Rossi', 
                               Alias = 'mro666', 
                               Email = 'mrosskmans@deloitte.com', 
                               Username = 'mrosskm11@axa.com.masterdev', 
                               CommunityNickname = 'MarziRo', 
                               LanguageLocaleKey = 'en_US',
                               TimeZoneSidKey='Europe/Rome',
                               Agency_Code__c = '000828',
                               Nodes__c = 'DIF_000828',
                               Main_Node__c = '000828',
                               Profileid = pVen,
                               LocaleSidKey='en_US',
                               EmailEncodingKey='ISO-8859-1',
                               IsActive = true,
                               //   UserRoleId=pRol,
                               ContactId = agencyContact.Id
                              );
            insert usr1;
            
            User usr2=new User(FirstName='Marzia',
                               LastName = 'Boccherini', 
                               Alias = 'mro667', 
                               Email = 'mrosskmans@deloitte.com', 
                               Username = 'mrosskm22@axa.com.masterdev', 
                               CommunityNickname = 'MarziBo', 
                               LanguageLocaleKey = 'en_US',
                               TimeZoneSidKey='Europe/Rome',
                               //Agency_Code__c = '000828',
                               //Nodes__c = 'DIF_000828',
                               Profileid = phd2,
                               LocaleSidKey='en_US',
                               EmailEncodingKey='ISO-8859-1',
                               IsActive = true,
                               UserRoleId=pRol
                               //ContactId = agencyContact.Id
                              );
            insert usr2;
            
            
            User usr3=new User(FirstName='Marzia',
                               LastName = 'Polli', 
                               Alias = 'mro668', 
                               Email = 'mrosskmans@deloitte.com', 
                               Username = 'mrosskm33@axa.com.masterdev', 
                               CommunityNickname = 'MarziPo', 
                               LanguageLocaleKey = 'en_US',
                               TimeZoneSidKey='Europe/Rome',
                               //Agency_Code__c = '000828',
                               //Nodes__c = 'DIF_000828',
                               Profileid = pdig,
                               LocaleSidKey='en_US',
                               EmailEncodingKey='ISO-8859-1',
                               IsActive = true
                               //UserRoleId=pRol
                               //ContactId = agencyContact.Id
                              );
            insert usr3;
            
            List <AAI_Code_Variables__c> listCV = new List<AAI_Code_Variables__c>();
            AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
            AAI_Code_Variables__c acv2 = new AAI_Code_Variables__c(Name='JS_USER_DEBUG', Value__c=UserInfo.getUserId());
            listCV.add(acv);
            listCV.add(acv2);
            insert listCV;
            
            Case c = new Case(User__c = usr1.Id,RecordTypeId = CaseAssistenzaAgentiRT, LOB__c = 'IT', Category__c = 'SINISTRI', SubCategory__c = 'Apertura Sinistri');
            insert c;	
            
            
            
            
        }
        
        
    }
    
    
    static testmethod void TEST_Vistapersonale_SystemAdmin(){
        
        
        test.startTest();
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            
            String sobject_name = 'Case';  
            List<String> field_names = new List<String>{'CaseNumber','User__r.Name','Origin','Oggetto_Apertura_Case__c','Status','CreatedDate','ClosedDate','E2E_Age_in_BH_Text__c','Time_with_Customer_Text__c','Category__c','LOB__c'};
                List<String> field_labels = new List<String>{'Numero','Richiedente','Origine','Oggetto','Stato','Creazione','Chiusura','Lavorazione','Agenti'};
                    List<String> sortable_field_names = new List<String>{'CaseNumber','User__r.Name','Origin','Oggetto_Apertura_Case__c','Status','CreatedDate','ClosedDate','E2E_Age_in_BH_Text__c','Time_with_Customer_Text__c'};
                        List<String> reference_fields = new List<String>{'CaseNumber'};
                            List<String> override_field_type  = new List<String>();
            String match_criteria = 'RecordType.DeveloperName = \'Assistenza_Agenti\' and Status NOT IN (\'Attesa Info Agente\',\'Soluzione proposta\') AND Origin = \'Front end Agenti\'';
            String sort_by_field = 'CreatedDate';
            String sort_order = 'DESC';
            String lob = 'IT';
            String codice_agenzia = '000828';
            
            
            PageReference acctPage = new PageReference('/apex/' + 'ModelloAssistenza');
            acctPage.setRedirect(true);
            
            system.debug('**sortable_field_names**'+sortable_field_names);
            
            String ColumnMetadata = ModelloAssistenzaCtrl.getColumnMetadata(sobject_name, field_names, field_labels, sortable_field_names,reference_fields,override_field_type);
            Integer TotalRecords = ModelloAssistenzaCtrl.getTotalRecords(sobject_name, match_criteria);
            String Records = ModelloAssistenzaCtrl.getRecords(sobject_name, field_names, match_criteria, sort_by_field, sort_order,'description');//OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz
            List<String> PicklistStatus = ModelloAssistenzaCtrl.getgCaseStatusPicklist(true);//OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz
            List<String> PicklistLOB = ModelloAssistenzaCtrl.getgCaseLOBPicklist();
            List<String> PiklistCategory = ModelloAssistenzaCtrl.getgCaseCategoryPicklist(lob);
            Map<String, String> PageValues = ModelloAssistenzaCtrl.getPageValues();
            List<Case> Collaboratori = ModelloAssistenzaCtrl.getCollaboratori(codice_agenzia); 
        }
        
        
        
        
        test.stopTest();
        
        
        
    }
    
    static testmethod void TEST_Vistapersonale_Agente(){
        
        test.startTest();
        
        User Agente = [SELECT Id FROM User WHERE Username = 'mrosskm11@axa.com.masterdev' AND isActive = true LIMIT 1];
        User HD2 = [SELECT Id FROM User WHERE Username = 'mrosskm22@axa.com.masterdev' AND isActive = true LIMIT 1];
        Id TeamRoleId = [SELECT Id FROM CaseTeamRole WHERE Name = 'HD2 IT' LIMIT 1].Id;//OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz
        Id CaseAssistenzaAgentiRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND RecordType.DeveloperName = 'Assistenza_Agenti' LIMIT 1].Id;
        
        System.runAs(Agente){
            
            String sobject_name = 'Case';  
            List<String> field_names = new List<String>{'CaseNumber','User__r.Name','Origin','Oggetto_Apertura_Case__c','Status','CreatedDate','ClosedDate','E2E_Age_in_BH_Text__c','Time_with_Customer_Text__c','Category__c','LOB__c'};
                List<String> field_labels = new List<String>();
            List<String> sortable_field_names = new List<String>();
            List<String> reference_fields = new List<String>{'CaseNumber'};
                List<String> override_field_type  = new List<String>();
            String match_criteria = 'RecordType.DeveloperName = \'Assistenza_Agenti\' and Status NOT IN (\'Attesa Info Agente\',\'Soluzione proposta\') AND Origin = \'Front end Agenti\'';
            String sort_by_field = 'CreatedDate';
            String sort_order = 'ASC';
            String lob = 'IT';
            String codice_agenzia = '000828';
            
            
            PageReference acctPage = new PageReference('/apex/' + 'ModelloAssistenza');
            acctPage.setRedirect(true);
            
            String ColumnMetadata = ModelloAssistenzaCtrl.getColumnMetadata(sobject_name, field_names, field_labels, sortable_field_names,reference_fields,override_field_type);
            Integer TotalRecords = ModelloAssistenzaCtrl.getTotalRecords(sobject_name, match_criteria);
            String Records = ModelloAssistenzaCtrl.getRecords(sobject_name, field_names, match_criteria, sort_by_field, sort_order,'description');//OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz
            List<String> PicklistStatus = ModelloAssistenzaCtrl.getgCaseStatusPicklist(true);//OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz
            List<String> PicklistLOB = ModelloAssistenzaCtrl.getgCaseLOBPicklist();
            List<String> PiklistCategory = ModelloAssistenzaCtrl.getgCaseCategoryPicklist(lob);
            Map<String, String> PageValues = ModelloAssistenzaCtrl.getPageValues();
            List<Case> Collaboratori = ModelloAssistenzaCtrl.getCollaboratori(codice_agenzia); 
            
            
            Case c = new Case(User__c = Agente.Id,RecordTypeId = CaseAssistenzaAgentiRT, LOB__c = 'IT', Category__c = 'SINISTRI', SubCategory__c = 'Apertura Sinistri');
            insert c;
            
            ApexPages.StandardController sc = new ApexPages.standardController(c);
            
            ModelloAssistenzaCtrl controller = new ModelloAssistenzaCtrl(sc);
            
            
            
        }
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            
            Case c = [SELECT Id FROM Case WHERE LOB__c = 'IT' AND Category__c = 'SINISTRI' LIMIT 1];
            List<CaseTeamMember> CTM = new List<CaseTeamMember>();
            CaseTeamMember ctm1 = new CaseTeamMember (MemberId = HD2.Id, ParentId = c.Id, TeamRoleId = TeamRoleId);
            CTM.add(ctm1);
            insert CTM;
            
            c.OwnerId = HD2.Id;
            update c;
            
            
        }
        
        
        
        test.stopTest();
        
    }
    
    static testmethod void TEST_Vistapersonale_SystemDigital(){
        
        
        test.startTest();
        
        User Digital = [SELECT Id FROM User WHERE Username = 'mrosskm33@axa.com.masterdev' AND isActive = true LIMIT 1];
        
        System.runAs(Digital)
        {
            
            String sobject_name = 'Case';  
            List<String> field_names = new List<String>{'CaseNumber','User__r.Name','Origin','Oggetto_Apertura_Case__c','Status','CreatedDate','ClosedDate','E2E_Age_in_BH_Text__c','Time_with_Customer_Text__c','Category__c','LOB__c'};
                List<String> field_labels = new List<String>{'Numero','Richiedente','Origine','Oggetto','Stato','Creazione','Chiusura','Lavorazione','Agenti'};
                    List<String> sortable_field_names = new List<String>{'CaseNumber','User__r.Name','Origin','Oggetto_Apertura_Case__c','Status','CreatedDate','ClosedDate','E2E_Age_in_BH_Text__c','Time_with_Customer_Text__c','Category__c','LOB__c'};
                        List<String> reference_fields = new List<String>{'CaseNumber'};
                            List<String> override_field_type  = new List<String>{'CaseNumber','User__r.Name','Origin','Oggetto_Apertura_Case__c','Status','CreatedDate','ClosedDate','E2E_Age_in_BH_Text__c','Time_with_Customer_Text__c','Category__c','LOB__c'};
                                String match_criteria = 'RecordType.DeveloperName = \'Assistenza_Agenti\' and Status NOT IN (\'Attesa Info Agente\',\'Soluzione proposta\') AND Origin = \'Front end Agenti\'';
            String sort_by_field = 'CreatedDate';
            String sort_order = 'DESC';
            String lob = 'IT';
            String codice_agenzia = '000828';
            
            
            PageReference acctPage = new PageReference('/apex/' + 'ModelloAssistenza');
            acctPage.setRedirect(true);
            
            String ColumnMetadata = ModelloAssistenzaCtrl.getColumnMetadata(sobject_name, field_names, field_labels, sortable_field_names,reference_fields,override_field_type);
            Integer TotalRecords = ModelloAssistenzaCtrl.getTotalRecords(sobject_name, match_criteria);
            String Records = ModelloAssistenzaCtrl.getRecords(sobject_name, field_names, match_criteria, sort_by_field, sort_order,'description');//OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz
            List<String> PicklistStatus = ModelloAssistenzaCtrl.getgCaseStatusPicklist(true);//OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz
            List<String> PicklistStatus2 = ModelloAssistenzaCtrl.getgCaseStatusPicklist(false);//OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz
            String closedCase = ModelloAssistenzaCtrl.FilterClosedCases();//OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz
            List<String> PicklistLOB = ModelloAssistenzaCtrl.getgCaseLOBPicklist();
            List<String> PiklistCategory = ModelloAssistenzaCtrl.getgCaseCategoryPicklist(lob);
            Map<String, String> PageValues = ModelloAssistenzaCtrl.getPageValues();
            List<Case> Collaboratori = ModelloAssistenzaCtrl.getCollaboratori(codice_agenzia); 
        }
        
        
        
        
        test.stopTest();
        
        
        
    }
    
    
}
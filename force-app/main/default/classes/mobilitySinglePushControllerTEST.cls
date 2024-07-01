@isTest
public class mobilitySinglePushControllerTEST {

    @testSetup
    static void createData(){
        
        RecordType rtB2B = [select id, name from RecordType where SobjectType = 'Account' AND Name = 'B2B Client'];
        
        Account TestEnrichAcc2 = new Account(RecordTypeId=rtB2B.Id,Name='EnrichmentB2B',AAI_Partita_IVA__c='03946280165',NDG__c ='0008280000001548', AAI_Agency_Reference_Code__c='006345');
		insert TestEnrichAcc2;

        Contact c = new Contact();
        c.FirstName = 'Mario';
        c.AccountId = TestEnrichAcc2.Id;
        c.LastName = 'Rossi';
        insert c;
        Contact co = [SELECT id FROM Contact LIMIT 1];
        
        TestEnrichAcc2.Contact_Master_Id__c = c.Id;
        update TestEnrichAcc2;

        Account agency = new Account();
        agency.Name = 'Test Single Push';
        agency.MobilePhone__c = '1234';
        agency.Agency_email__c = 'd.venanzi@reply.it';
        agency.Agency_Holder__c = 'Test';
        agency.CIF_Number__c = '12345';
        agency.Contact_Master_id__c = co.id;
        agency.Email_Master_AAI__c = 'd.venanzi@reply.it';
        agency.Mobile_Master_AAI__c = '1234';
        insert agency;
        Account agency1 = [SELECT id FROM Account WHERE CIF_Number__c = '12345'];
        
         
        
        RecordType rt = [select id, name from RecordType where SobjectType = 'Account' AND Name = 'B2C Client'];
        Account a = new Account();
        a.recordtypeId = rt.id;
        a.NDG__c = '0016220000149960';
        a.LastName = 'PushController';
        a.CIF_Document_type__c = 'Patente di guida';
        a.CIF_Number__c = '1234';
        a.Contact_Master_id__c = co.id;
        a.Email_Master_AAI__c = 'd.venanzi@reply.it';
        a.Mobile_Master_AAI__c = '1234';
        a.Agency_Code__c = agency1.id;
        insert a;

        Iniziative_Marketing__c im = new Iniziative_Marketing__c();
            im.Name = 'Temp AAI TEXT temp';
            im.Communication_code__c = 'Temp AAI TEXT temp2';
            im.Attiva__c = false ;
            im.Tipologia_Campagna__c = 'Commerciale';
            im.Eligibile_per_Compagnia__c = 'AAI';
            im.Canale__c = 'Email';
            im.Titolo__c ='Gentile %%Nome%% ';
            im.Sottotitolo__c = '%%MC_inizio%% Dal %%chiusoDal%% al %%chiusoAl%% %%MC_fine%%';
            im.Contenuto__c = '%%MC_inizio%% Dal %%chiusoDal%% al %%chiusoAl%% %%MC_fine%%';
            im.Short_Message__c = '%%MC_inizio%% Dal %%chiusoDal%% al %%chiusoAl%% %%MC_fine%%';
            im.Message__c = '%%MC_inizio%% Dal %%chiusoDal%% al %%chiusoAl%% %%MC_fine%%';
            im.Testo_CTA__c = '';
            im.is_scheduled_type__c = true;
            im.is_closure_type__c = true;
            im.URL_CTA__c = 'html';
            im.Invio_push__c = true;
            im.Tipo_notifica_su_Centro_Notifiche__c = 'Messaggio importante';
            im.Tipologia_Campagna__c = 'Amministrativa';
            im.Descrizione_dell_iniziativa__c = 'DESC';

        insert im;

        Iniziative_Marketing__c im1 = new Iniziative_Marketing__c();
            im1.Name = 'Temp AAI TEXT temp';
            im1.Communication_code__c = 'code1';
            im1.Attiva__c = false ;
            im1.Tipologia_Campagna__c = 'Commerciale';
            im1.Eligibile_per_Compagnia__c = 'AAI';
            im1.Canale__c = 'Email';
            im1.Titolo__c ='Gentile %%Nome%% ';
            im1.Sottotitolo__c = '%%MC_inizio%% Dal %%chiusoDal%% al %%chiusoAl%% %%MC_fine%%';
            im1.Contenuto__c = '%%MC_inizio%% Dal %%chiusoDal%% al %%chiusoAl%% %%MC_fine%%';
            im1.Short_Message__c = '%%MC_inizio%% Dal %%chiusoDal%% al %%chiusoAl%% %%MC_fine%%';
            im1.Message__c = '%%MC_inizio%% Dal %%chiusoDal%% al %%chiusoAl%% %%MC_fine%%';
            im1.Testo_CTA__c = '';
            im1.is_scheduled_type__c = true;
            im1.is_closure_type__c = true;
            im1.URL_CTA__c = 'html';
            im1.Invio_push__c = true;
            im1.Tipo_notifica_su_Centro_Notifiche__c = 'Messaggio importante';
            im1.Tipologia_Campagna__c = 'Amministrativa';
            im1.Descrizione_dell_iniziativa__c = 'DESC';
            im1.Base_Giuridica__c = 'Commerciale';
            im1.Categoria_Prodotto__c = 'Malattia';

        insert im1;

        BlackListAccountReprocessingBatch_TEST.setup();
    }
    
    @isTest
    static void executeTestOk(){
        String codeJson = 'ncyv+S+dp8YEwfij1FWx+31VkYSL7SDqq2jesMxcnC9/uA1EsGfTonOfR2kPyqiwqRhKoeAKYKF5C8+Fy28rTMdbkJ42F78w1DsrR+jWVfVOAqAg4A9KFwNXFBh7m6ML3/b43Y/jogiaBCfvmkOqVG4gu9WC7LoZu2IhIxuCytXM28njID/T5wKpKFdwOhJWvVdSdMXznQ86YUeLqsPw3PvB1RkLXzVkhYUKTi8FVYXisQPC+USfKMDwUhErSftpVZb40duxc+8MbHJiMbyKXRH9Fc8VBUKfYQTosJoIim3BNdRs0q9DIrDK7xN+UW+lkAL30nt0Mrn+LijbW9US1tv9WwGltkTSvRe1Wu3SJESQ+aFLs9wkWa1vHb+dygvF+L6v16VNUfm0fh+CVlozb0RiAYDgmuCx2ODfppPNzS2fmAZKTqqKkPHkBb/i+g++ZSMVpx7jrpIZ9CmdT8yMfhjp5YN6x8sI/Nzbe0GBs+X6DKfpLwZV+eJ+j1q4adXPgXm94bS6LC8tN/Q9UDZJjWRl/YXzJ4PMk2blwkFyIIyEYf3qKLRJtIJwKRTtHRiwLAX8lSDcP41qIn1ohzue2cAN0ej7zYcXSIbuNryMmNYeLc8ZwDIHZ7TmD2WcyH/MEhYnxE4oPmSrzFHmdv/2ll3+W4EXrY0r/vcXsaCOPDkwfm8r+SqquSsp+OsIusmbt49F9rCjhnptRDTV+uW6pR8DCfQmfIUXLpMJM+EqL2RE1XxKhtbkpTbWpjWkeqXsu44Q65W48WrwtR+47yF8MLwP//oBVs4bkPWgSY2OzzHi/Y6yleF2g2Up33xPJ/r7F325LRSNHaRj4IkTt222cCkczZRbqOiq3beiDawfXehAl2waN4EKaKo9MrD+9Gwi4G0k60ezbciO5pZn1t3WwvJgrMmPKezE/zX5fBAb/W2V7CjPRVI23qsWTBLgHgL0Idb7rnL9AXxm6e/Dcst7r0e41NZ10LMJFPjxXHlvq4YWJV0pO0DpgeTCSClu5vAqeuPgLmsQc+tz3oascofofc+GXM839pNGOO9j2WuKJbTIJznAqIMZu0EF3/Pt6cFyVzNCg+is2kfvlgCPaqGXPnQB8I8E71XRwyvTEnIXJiQAXebATHF2wNCcwA1+FB1DDzrodMeEd5WubFrDoW/UlzJMVkho2iqY9YHEp99Jv93Q2jT1GNPgtOk4faf5rXIin4SKz7jTHFki0LQD+YBP3AwWLjJlul23c0FlMeV2V25ibMcuy6UnA/v/a6S12Vlz1nkHpwqT/oq/QY1G5b2Ex1YI0u98jVv6TezIeWT3k7GHZQeKkDSdNK+3bpj/y+Q5';
        Iniziative_Marketing__c im = [SELECT id FROM Iniziative_Marketing__c LIMIT 1];
         RecordType rtB2B = [select id, name from RecordType where SobjectType = 'Account' AND Name = 'B2B Client'];
        Account a = [SELECT id,Name,Ccod_Produttore__c, NDG__c, CIF_Number__c, CIF_Document_Type__c, AAI_Agency__r.Agency_Code__c, Contact_Master_Id__c, Email_Master_AAI__c, Mobile_Master_AAI__c, Agency_Code__c, AAI_Agency__r.Agency_Holder__c, AAI_Agency__r.Name,AAI_Agency__r.Phone,AAI_Agency__r.Agency_email__c,AAI_Agency__r.MobilePhone__c,(Select id from Contacts order by createdDate desc limit 1), PersonContactId ,RecordTypeId FROM Account WHERE RecordTypeId !=: rtB2B.Id LIMIT 1];
        Account a2 = [SELECT id,Name,Ccod_Produttore__c, NDG__c, CIF_Number__c, CIF_Document_Type__c, AAI_Agency__r.Agency_Code__c, Contact_Master_Id__c, Email_Master_AAI__c, Mobile_Master_AAI__c, Agency_Code__c, AAI_Agency__r.Agency_Holder__c, AAI_Agency__r.Name,AAI_Agency__r.Phone,AAI_Agency__r.Agency_email__c,AAI_Agency__r.MobilePhone__c,(Select id from Contacts order by createdDate desc limit 1), PersonContactId,RecordTypeId FROM Account WHERE RecordTypeId =: rtB2B.Id LIMIT 1];
       
        a2.Contact_Master_Id__c = null;
        update a2;
        
        
        
        Test.startTest();
        mobilitySinglePushController.init(codeJson);
        mobilitySinglePushController.createCommunicationsingle(a, im.id,null,null);
        a.Contact_Master_Id__c = null;
        update a;
        mobilitySinglePushController.createCommunicationsingle(a, im.id,null,null);
        mobilitySinglePushController.createCommunicationsingle(a2, im.id,null,null);

        //Name fields non return on query , exception cover
        Account a1 = [SELECT id, Contact_Master_Id__c, PersonContactId,Email_Master_AAI__c, Mobile_Master_AAI__c, Agency_Code__c, AAI_Agency__r.Agency_Holder__c, AAI_Agency__r.Name,AAI_Agency__r.Phone,AAI_Agency__r.Agency_email__c,AAI_Agency__r.MobilePhone__c,(Select id from Contacts order by createdDate desc limit 1) FROM Account LIMIT 1];
        mobilitySinglePushController.init(codeJson);
        mobilitySinglePushController.createCommunicationsingle(a1, im.id,null,null);
        Test.stopTest();

        System.assert(mobilitySinglePushController.init(codeJson) != null);
        }
    @isTest
    static void executeTestNoMatchAccount(){
        String codeJson = 'ncyv+S+dp8YEwfij1FWx+31VkYSL7SDqq2jesMxcnC9/uA1EsGfTonOfR2kPyqiwqRhKoeAKYKF5C8+Fy28rTMdbkJ42F78w1DsrR+jWVfVOAqAg4A9KFwNXFBh7m6ML3/b43Y/jogiaBCfvmkOqVG4gu9WC7LoZu2IhIxuCytXM28njID/T5wKpKFdwOhJWvVdSdMXznQ86YUeLqsPw3PvB1RkLXzVkhYUKTi8FVYXisQPC+USfKMDwUhErSftpVZb40duxc+8MbHJiMbyKXRH9Fc8VBUKfYQTosJoIim3BNdRs0q9DIrDK7xN+UW+lkAL30nt0Mrn+LijbW9US1tv9WwGltkTSvRe1Wu3SJESQ+aFLs9wkWa1vHb+dygvF+L6v16VNUfm0fh+CVlozb0RiAYDgmuCx2ODfppPNzS2fmAZKTqqKkPHkBb/i+g++ZSMVpx7jrpIZ9CmdT8yMfhjp5YN6x8sI/Nzbe0GBs+X6DKfpLwZV+eJ+j1q4adXPgXm94bS6LC8tN/Q9UDZJjWRl/YXzJ4PMk2blwkFyIIyEYf3qKLRJtIJwKRTtHRiwLAX8lSDcP41qIn1ohzue2cAN0ej7zYcXSIbuNryMmNYeLc8ZwDIHZ7TmD2WcyH/MEhYnxE4oPmSrzFHmdv/2ll3+W4EXrY0r/vcXsaCOPDkwfm8r+SqquSsp+OsIusmbt49F9rCjhnptRDTV+uW6pR8DCfQmfIUXLpMJM+EqL2RE1XxKhtbkpTbWpjWkeqXsu44Q65W48WrwtR+47yF8MLwP//oBVs4bkPWgSY2OzzHi/Y6yleF2g2Up33xPJ/r7F325LRSNHaRj4IkTt222cCkczZRbqOiq3beiDawfXehAl2waN4EKaKo9MrD+9Gwi4G0k60ezbciO5pZn1t3WwvJgrMmPKezE/zX5fBAb/W2V7CjPRVI23qsWTBLgHgL0Idb7rnL9AXxm6e/Dcst7r0e41NZ10LMJFPjxXHlvq4YWJV0pO0DpgeTCSClu5vAqeuPgLmsQc+tz3oascofofc+GXM839pNGOO9j2WuKJbTIJznAqIMZu0EF3/Pt6cFyVzNCg+is2kfvlgCPaqGXPnQB8I8E71XRwyvTEnIXJiQAXebATHF2wNCcwA1+FB1DDzrodMeEd5WubFrDoW/UlzJMVkho2iqY9YHEp99Jv93Q2jT1GNPgtOk4faf5rXIin4SKz7jTHFki0LQD+YBP3AwWLjJlul23c0FlMeV2V25ibMcuy6UnA/v/a6S12Vlz1nkHpwqT/oq/QY1G5b2Ex1YI0u98jVv6TezIeWT3k7GHZQeKkDSdNK+3bpj/y+Q5';
        Test.startTest();
         RecordType rtB2B = [select id, name from RecordType where SobjectType = 'Account' AND Name = 'B2B Client'];
        
        Account a = [SELECT id, NDG__c, CIF_Number__c, CIF_Document_Type__c, Contact_Master_Id__c, Email_Master_AAI__c, Mobile_Master_AAI__c, Agency_Code__c, AAI_Agency__r.Agency_Holder__c, AAI_Agency__r.Name,AAI_Agency__r.Phone,AAI_Agency__r.Agency_email__c,AAI_Agency__r.MobilePhone__c FROM Account LIMIT 1];
        a.NDG__c = 'abcde';
        update a;
        mobilitySinglePushController.init(codeJson);
        mobilitySinglePushController.InitSingoloEcollaboration('0016220000149960');
        Test.stopTest();
        System.assert(mobilitySinglePushController.init(codeJson) != null);
    }
    @isTest
    static void executeTestNoNDG(){
        Test.startTest();
        mobilitySinglePushController.init('1234');
        Test.stopTest();
        System.assert(mobilitySinglePushController.init('1234') != null);

    }
    @isTest
    static void executeAnotherUser(){
        List<user> userForTesting = [SELECT id, name, profile.name FROM user WHERE profile.name not in ('NFE - AAI - Vendite Avanzato','System Administrator') and profile.name != null LIMIT 1];
        System.runAs(userForTesting[0]){
            test.startTest();
            mobilitySinglePushController.init('1234');
            test.stopTest();
        }
        System.assert(mobilitySinglePushController.init('1234') != null);
    }
    @isTest
    public static void filterByFatique_blacklist(){
        List <Iniziative_Marketing__c> iniziativa = [Select 
        id,Name, URL_Immagine__c, URL_CTA__c, Titolo__c, Sottotitolo__c,
        Short_Message__c,Nome_Messaggio__c,Descrizione_Messaggio__c,Message__c,
         Testo_CTA__c, Communication_code__c, Versione__c, Eligibile_per_Compagnia__c,Base_Giuridica__c,
         TECH_URL_template_MC__c,Contenuto__c,Visibilita_nel_centro_notifiche__c,Invio_push__c,
         Tipologia_Campagna__c,Tipo_notifica_su_Centro_Notifiche__c,Canale__c, Descrizione_dell_iniziativa__c,
         Entita_SFDC_di_riferimento__c,Categoria_Prodotto__c, Sottotipologia_Campagna__c 
         from Iniziative_Marketing__c where Communication_code__c = 'code1' limit 1];
        
         RecordType rtB2C = [select id, name from RecordType where SobjectType = 'Account' AND Name = 'B2C Client'];

        List<Account> AccountCliente = [Select id,PersonContactId,Name,Email_ListView__c,Codice_fiscale_ListView__c,Agency_Code__c, AAI_Agency__r.Agency_Holder__c,     // NOPMD  Fix CRUD violation
        AAI_Agency__r.Name,AAI_Agency__r.Phone,AAI_Agency__r.Agency_email__c,AAI_Agency__r.MobilePhone__c,Contact_Master_Id__c,AAI_Agency__r.Agency_Code__c,
        Additional_Phone__c ,MobilePhone__c,Mobile_Master_AAI__c,Email_Master_AAI__c,CIF_Number__c,CIF_Document_type__c,
        Flag_registrazione_area_privata__c,Comunicazioni_informative__c, RecordTypeId, RecordType.DeveloperName,
        BlackList_Abitazione__c,BlackList_Auto__c,BlackList_Aziende__c,BlackList_Broker__c,BlackList_Commerciale__c,
        BlackList_Infortuni__c,BlackList_Malattia__c,Blacklist_Processi__c,BlackList_Protection__c,BlackList_Rinnovo__c,
        BlackList_Saving__c,BlackList_Servizio__c  from Account WHERE RecordTypeId =: rtB2C.Id];
        
         RecordType rtB2B = [select id, name from RecordType where SobjectType = 'Account' AND Name = 'B2B Client'];
        
        List<Account> AccountCliente2 = [Select id,PersonContactId,Name,Email_ListView__c,Codice_fiscale_ListView__c,Agency_Code__c, AAI_Agency__r.Agency_Holder__c,     // NOPMD  Fix CRUD violation
        AAI_Agency__r.Name,AAI_Agency__r.Phone,AAI_Agency__r.Agency_email__c,AAI_Agency__r.MobilePhone__c,Contact_Master_Id__c,AAI_Agency__r.Agency_Code__c,
        Additional_Phone__c ,MobilePhone__c,Mobile_Master_AAI__c,Email_Master_AAI__c,CIF_Number__c,CIF_Document_type__c,
        Flag_registrazione_area_privata__c,Comunicazioni_informative__c, RecordTypeId, RecordType.DeveloperName,
        BlackList_Abitazione__c,BlackList_Auto__c,BlackList_Aziende__c,BlackList_Broker__c,BlackList_Commerciale__c,
        BlackList_Infortuni__c,BlackList_Malattia__c,Blacklist_Processi__c,BlackList_Protection__c,BlackList_Rinnovo__c, (Select id from Contacts order by createdDate desc limit 1),
        BlackList_Saving__c,BlackList_Servizio__c  from Account WHERE recordtypeid =: rtB2B.Id ];

        mobilitySinglePushController.responseWrapper temp1 = new  mobilitySinglePushController.responseWrapper();
        mobilitySinglePushController.responseWrapper temp2 = new  mobilitySinglePushController.responseWrapper();
        mobilitySinglePushController.responseWrapper temp3 = new  mobilitySinglePushController.responseWrapper();
        
        System.debug('isAccount empty?: '+AccountCliente.isEmpty());
        
        if(!iniziativa.isEmpty() && !AccountCliente.isEmpty()){
            temp1 = mobilitySinglePushController.filterByFatique(iniziativa[0], AccountCliente[0]);
            temp2 = mobilitySinglePushController.filterByBlacklist(iniziativa[0], AccountCliente[0]);
            temp3 = mobilitySinglePushController.filterByFatique(iniziativa[0], AccountCliente2[0]);
        }
        System.assert(temp1 != null);
        System.assert(temp2 != null);
    }

    @isTest
    public static void BatchUpdateNodeSuperMessagesTEMP(){
        BatchUpdateNodeSuperMessages Batchtemp = new BatchUpdateNodeSuperMessages(System.now());
        database.executeBatch(Batchtemp);
    }
}
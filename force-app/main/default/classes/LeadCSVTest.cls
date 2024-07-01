@isTest
private class LeadCSVTest{
    
    static testMethod void nonAutoValidation(){
    
        Document d = new Document(Name = 'Template Caricamento Massivo Lead RAMI ELEMENTARI', 
                                  Body=Blob.valueOf('test'), 
                                  Type = 'csv',
                                  FolderId = UserInfo.getUserId());
        
        insert d;
        
        MappingProvince__c sp = new MappingProvince__c(Name = 'Test', ProvinciaExternalKey__c='MI', SFDCexpected__c='Milano');
        insert sp;
        
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv; 
        Test.startTest();
        RecordType RT = [SELECT DeveloperName,Id,SobjectType FROM RecordType where sobjecttype = 'Account' and DeveloperName = 'Agency'];
    
        Account ag =new Account(Name ='Test',Account_email__c ='test@test.test',Agency_Code__c ='000111',Agency_Holder__c ='test',TECH_Company__c ='AAI',Active__c=true,RecordTypeId = rt.id);
        insert ag;
        
        Set<String> allAgencies = new Set<String>();
        allAgencies.add('000111');
        
        Group g =new Group (Type = 'Queue',Name = 'Coda_Agenzia_000111',DeveloperName = 'Coda_Agenzia_000111');
        insert g;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
         {
            QueueSObject q = new QueueSObject(SobjectType='Lead', QueueId=g.Id);
            insert q;
            GroupMember gm = new groupMember (GroupId= g.Id, UserOrGroupId = UserInfo.getUserId());
            insert gm; 
        }
                                         
       // list<GroupMember>  recipientPersonsG=[SELECT  GroupId,Id,SystemModstamp,UserOrGroupId,group.developername FROM GroupMember where group.developername in :setQueue ];    
    
        String myFile = 
        
LeadCSVLoaderCtr.TIPI_RAMI_ELEMENTARI_AGGIUNTA + '\r\n' + LeadCSVLoaderCtr.DESCRIZIONE_RE_AGGIUNTA 
+'\r\nTestNome;TestCog;111;test@test.it;T123456789012345;m;111;Nessuna;Nessuna;1/1/1800;9 - 11;vero;falso;Famiglia;Milano;MI;20060;Via Dante;;;;11/01/1991 21.00;'
+'\r\n;TestCog;112;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1801;;vero;falso;Famiglia;Milano;MI;20061;Via Dante;;;;;Salva quotazione'
+'\r\nTestNome;;113;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1802;;vero;falso;Famiglia;Milano;MI;20062;Via Dante;;;;;'
+'\r\nTestNome;TestCog;;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1803;;vero;falso;Famiglia;Milano;MI;20063;Via Dante;;;;12/12/1010 20.10;'
+'\r\nTestNome;TestCog;115;;T123456789012345;m;;Nessuna;Nessuna;1/1/1804;;vero;falso;Famiglia;Milano;MI;20064;Via Dante;;;;;'
+'\r\nTestNome;TestCog;116;Wrong;T123456789012345;m;;Nessuna;Nessuna;1/1/1805;;vero;falso;Famiglia;Milano;MI;20065;Via Dante;;;;;'
+'\r\nTestNome;TestCog;117;test@test.it;Wrong;m;;Nessuna;Nessuna;1/1/1806;;vero;falso;Famiglia;Milano;MI;20066;Via Dante;;;;;'
+'\r\nTestNome;TestCog;118;test@test.it;T123456789012345;Wrong;;Nessuna;Nessuna;1/1/1807;;vero;falso;Famiglia;Milano;MI;20067;Via Dante;;;;;'
+'\r\nTestNome;TestCog;119;test@test.it;T123456789012345;m;Wrong;Nessuna;Nessuna;1/1/1808;;vero;falso;Famiglia;Milano;MI;20068;Via Dante;;;;;'
+'\r\nTestNome;TestCog;120;test@test.it;T123456789012345;m;;Nessuna;Nessuna;Wrong;;vero;falso;Famiglia;Milano;MI;20069;Via Dante;;;;;'
+'\r\nTestNome;TestCog;121;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1810;Wrong;vero;falso;Famiglia;Milano;MI;20070;Via Dante;;;;;'
+'\r\nTestNome;TestCog;122;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1811;;Wrong;falso;Famiglia;Milano;MI;20071;Via Dante;;;;;'
+'\r\nTestNome;TestCog;123;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1812;;vero;Wrong;Famiglia;Milano;MI;20072;Via Dante;;;;;'
+'\r\nTestNome;TestCog;124;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1813;;vero;falso;Wrong;Milano;MI;20073;Via Dante;;;;;'
+'\r\nTestNome;TestCog;125;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1814;;vero;falso;Famiglia;Milano;Wrong;20074;Via Dante;;;;;'
+'\r\nTestNome;TestCog;126;test@test.it;T123456789012345;m;000111;Nessuna;Nessuna;1/1/1815;;vero;falso;Famiglia;Milano;MI;Wrong;Via Dante;;;;;'+
'\r\nGiulio;Verme;92938223;email@email.com;MUTRGS91A47E281L;Maschio;000111;;;;;;;;;;;;;;;;';
        
        LeadCSVLoaderCtr l = new LeadCSVLoaderCtr();
        l.file_nome = 'Test.csv';
        
    
        l.file_contenuto = Blob.valueOf(myFile);
        l.nonAuto();
        l.validaFile();
        l.importa();
        Boolean flag = true;
        
     /*   String myFile2 = 
        
        LeadCSVLoaderCtr.TIPI_NON_AUTO + '\r\n' + LeadCSVLoaderCtr.DESCRIZIONE_NON_AUTO +
        
        '\r\nGiulio;Verme;92938223;email@email.com;MUTRGS91A47E281L;Maschio;000111;;;;;;;;;;;';

        l.file_contenuto = Blob.valueOf(myFile2);
        System.debug('******l.file_contenuto '+l.file_contenuto);
        l.nonAuto();
        
        l.validaFile();*/
      //  l.importa(); 
        
        List<Lead> res = [SELECT Email, FirstName, Gender__c, Lead_Birthdate__c, LeadSource, Phone FROM Lead WHERE FirstName like '%Test%'];
    /*    System.debug('+++++ Pre controllo');
        
        if(res.size()!=1) flag = false;
        System.debug('+++++ Size ' + flag);
        if(res[0].Email != 'test@test.it') flag = false;
        System.debug('+++++ Email '  + flag);
        if(res[0].FirstName != 'TestNome') flag = false;
        System.debug('+++++ Name ' + flag);
        if(res[0].Gender__c != 'Maschio') flag = false;
        System.debug('+++++ Maschio ' + flag);
        if(res[0].Phone !='111') flag = false;
        System.debug('+++++ Phone ' + flag);
        if( res[0].Lead_Birthdate__c.format() != Date.newInstance(1800, 1, 1).format()) flag = false;
        System.debug('+++++ Data ' + flag);
        
        System.debug('+++++ Post controllo ' + flag);
        System.assertEquals(true, flag); */
        
    }
   
    static testMethod void autoValidation(){
        Document d = new Document(Name = 'Template Caricamento Massivo Lead AUTO', 
                                  Body=Blob.valueOf('test'), 
                                  Type = 'csv',
                                  FolderId = UserInfo.getUserId());
        
        insert d;
        
        MappingProvince__c sp = new MappingProvince__c(Name = 'Test', ProvinciaExternalKey__c='MI', SFDCexpected__c='Milano');
        insert sp;
        
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv; 
        Test.startTest();
        RecordType RT = [SELECT DeveloperName,Id,SobjectType FROM RecordType where sobjecttype = 'Account' and DeveloperName = 'Agency'];
    
        Account ag =new Account(Name ='Test',Account_email__c ='test@test.test',Agency_Code__c ='000111',Agency_Holder__c ='test',TECH_Company__c ='AAI',Active__c=true,RecordTypeId = rt.id);
        insert ag;
        
        Set<String> allAgencies = new Set<String>();
        allAgencies.add('000111');
        
        Group g =new Group (Type = 'Queue',Name = 'Coda_Agenzia_000111',DeveloperName = 'Coda_Agenzia_000111');
        insert g;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
         {
            QueueSObject q = new QueueSObject(SobjectType='Lead', QueueId=g.Id);
            insert q;
            GroupMember gm = new groupMember (GroupId= g.Id, UserOrGroupId = UserInfo.getUserId());
            insert gm; 
        }
            
    
        String myFile = 
        
LeadCSVLoaderCtr.TIPI_AUTO + '\r\n' + LeadCSVLoaderCtr.DESCRIZIONE_AUTO 

+'\r\n;TestCog;112;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1801;vero;;1;1;1;1;1;1;;;;1;1;1;1;4;2;1/1/1801;CU 81;Test;T2;Benzina;;;'
+'\r\nTestNome;;113;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1802;vero;;1;1;1;1;1;1;;;;1;1;1;1;4;2;1/1/1802;CU 82;Test;T3;Benzina;;;'
+'\r\nTestNome;TestCog;;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1803;vero;;1;1;1;1;1;1;;;;1;1;1;1;4;2;1/1/1803;CU 83;Test;T4;Benzina;;;'
+'\r\nTestNome;TestCog;115;;T123456789012345;;Nessuna;Nessuna;01/01/1804;vero;;1;1;1;1;1;1;;;;1;1;1;1;4;2;1/1/1804;CU 84;Test;T5;Benzina;;;'
+'\r\nTestNome;TestCog;116;Wrong;T123456789012345;;Nessuna;Nessuna;01/01/1805;vero;;1;1;1;1;1;1;;;;1;1;1;1;4;2;1/1/1805;CU 85;Test;T6;Benzina;;;'
+'\r\nTestNome;TestCog;117;test@test.it;Wrong;;Nessuna;Nessuna;01/01/1806;vero;;1;1;1;1;1;1;;;;1;1;1;1;4;2;1/1/1806;CU 86;Test;T7;Benzina;;;'
+'\r\nTestNome;TestCog;118;test@test.it;T123456789012345;Wrong;Nessuna;Nessuna;01/01/1807;vero;falso;1;1;1;1;1;1;;;;1;1;1;1;4;2;1/1/1807;CU 87;Test;T8;Benzina;;;'
+'\r\nTestNome;TestCog;119;test@test.it;T123456789012345;;Nessuna;Nessuna;Wrong;vero;;1;1;1;1;1;1;;;;1;1;1;1;4;2;1/1/1808;CU 88;Test;T9;Benzina;;;'
+'\r\nTestNome;TestCog;120;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1809;Wrong;;1;1;1;1;1;1;;;;1;1;1;1;4;2;1/1/1809;CU 89;Test;T10;Benzina;;;'
+'\r\nTestNome;TestCog;121;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1810;vero;Wrong;1;1;1;1;1;1;;;;1;1;1;1;4;2;1/1/1810;CU 90;Test;T11;Benzina;;;'
+'\r\nTestNome;TestCog;122;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1811;vero;;Wrong;1;1;1;1;1;;;;1;1;1;1;4;2;1/1/1811;CU 91;Test;T12;Benzina;;;'
+'\r\nTestNome;TestCog;123;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1812;vero;;1;Wrong;1;1;1;1;;;;1;1;1;1;4;2;1/1/1812;CU 92;Test;T13;Benzina;;;'
+'\r\nTestNome;TestCog;124;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1813;vero;;1;1;Wrong;1;1;1;;;;1;1;1;1;4;2;1/1/1813;CU 93;Test;T14;Benzina;;;'
+'\r\nTestNome;TestCog;125;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1814;vero;;1;1;1;Wrong;1;1;;;;1;1;1;1;4;2;1/1/1814;CU 94;Test;T15;Benzina;;;'
+'\r\nTestNome;TestCog;126;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1815;vero;;1;1;1;1;Wrong;1;;;;1;1;1;1;4;2;1/1/1815;CU 95;Test;T16;Benzina;;;'
+'\r\nTestNome;TestCog;127;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1816;vero;;1;1;1;1;1;Wrong;;;;1;1;1;1;4;2;1/1/1816;CU 96;Test;T17;Benzina;;;'
+'\r\nTestNome;TestCog;128;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1817;vero;;1;1;1;1;1;1;;;;Wrong;1;1;1;4;2;1/1/1817;CU 97;Test;T18;Benzina;;;'
+'\r\nTestNome;TestCog;129;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1818;vero;;1;1;1;1;1;1;;;;1;Wrong;1;1;4;2;1/1/1818;CU 98;Test;T19;Benzina;;;'
+'\r\nTestNome;TestCog;130;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1819;vero;;1;1;1;1;1;1;;;;1;1;Wrong;1;4;2;1/1/1819;CU 99;Test;T20;Benzina;;;'
+'\r\nTestNome;TestCog;131;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1820;vero;;1;1;1;1;1;1;;;;1;1;1;Wrong;4;2;1/1/1820;CU 100;Test;T21;Benzina;;;'
+'\r\nTestNome;TestCog;132;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1821;vero;;1;1;1;1;1;1;;;;1;1;1;1;Wrong;2;1/1/1821;CU 101;Test;T22;Benzina;;;'
+'\r\nTestNome;TestCog;133;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1822;vero;;1;1;1;1;1;1;;;;1;1;1;1;4;Wrong;1/1/1822;CU 102;Test;T23;Benzina;;;'
+'\r\nTestNome;TestCog;134;test@test.it;T123456789012345;;Nessuna;Nessuna;01/01/1823;vero;;1;1;1;1;1;1;;;;1;1;1;1;4;2;Wrong;CU 103;Test;T24;Benzina;;;'
+'\r\nTestNome;TestCog;135;test@test.it;T123456789012345;000111;Nessuna;Nessuna;01/01/1824;vero;;1;1;1;1;1;1;;;;1;1;1;1;4;2;1/1/1824;Wrong;Test;T25;Benzina;;;'
+'\r\nEnrico;Brizzi;72134353;email@email.com;a123456789012345;000828;lista test;;;;;;;;;;;;;;;;;;;;;;;;;;12345678901;testragionesociale'
+'\r\nTestNome;TestCog;111;test@test.it;T123456789012345;000111;Nessuna;Nessuna;01/01/1800;vero;auto;1;1;1;1;1;1;;;;1;1;1;1;4;2;1/1/1800;CU 80;Test;T1;Benzina;;';
        
        LeadCSVLoaderCtr l = new LeadCSVLoaderCtr();
        l.file_nome = 'Test.csv';
        l.file_contenuto = Blob.valueOf(myFile);
        l.auto();
        l.validaFile();
        l.importa();
        Boolean flag = true; 
        
        /*String myFile2 = 
        
        LeadCSVLoaderCtr.TIPI_AUTO + '\r\n' + LeadCSVLoaderCtr.DESCRIZIONE_AUTO +
        '\r\n'+'TestNome;TestCog;135;test@test.it;T123456789012345;000111;Nessuna;Nessuna;01/01/1924;vero;;1;1;1;1;1;1;;;;1;1;1;1;4;2;1/1/1824;Wrong;Test;T25;Benzina'
        +'\r\n'+' TestNome;TestCog;135;test@test.it;T123456789012345;000111;Nessuna;Nessuna;01/01/1924;vero;;1;1;1;1;1;1;;;;1;1;1;1;4;2;1/1/1824;Wrong;Test;T25;Benzina'
        +'\r\n'+' TestNome;TestCog;135;test@test.it;T123456789012345;000111;Nessuna;Nessuna;01/01/1924;vero;;1;1;1;1;1;1;;;;1;1;1;1;4;2;1/1/1824;Wrong;Test;T25;Benzina';
        l.file_contenuto = Blob.valueOf(myFile2);
        l.auto();
        l.validaFile();
        l.importa(); 
        
   //     List<Lead> res = [SELECT Email, FirstName, Nominee_Birthdate__c, Phone FROM Lead WHERE FirstName like '%Test%'];
   //     System.debug('+++++ Pre controllo');
        
     /*   if(res.size()!=1) flag = false;
        System.debug('+++++ Size ' + flag);
        if(res[0].Email != 'test@test.it') flag = false;
        System.debug('+++++ Email '  + flag);
        if(res[0].FirstName != 'TestNome') flag = false;
        System.debug('+++++ Name ' + flag);
        if(res[0].Phone !='111') flag = false;
        System.debug('+++++ Phone ' + flag);
        if( res[0].Nominee_Birthdate__c.format() != Date.newInstance(1800, 1, 1).format()) flag = false;
        System.debug('+++++ Data ' + flag);
        
        System.debug('+++++ Post controllo ' + flag);
        l.nuovocaricamento();
        l.cancel();
        l.uscita();
        System.assertEquals(true, flag);*/
        
    }
    static testmethod void annullamenti(){
    
            LeadCSVLoaderCtr l = new LeadCSVLoaderCtr();
        l.file_nome = 'Test.csv';
        Pagereference pr1 = l.cancel();
        Pagereference pr2 = l.nuovoCaricamento();
        Pagereference pr3 = l.uscita();
        
    }
    static testMethod void previdenzaValidation(){
    
        Document d = new Document(Name = 'Template Caricamento Massivo Lead PREVIDENZA', 
                                  Body=Blob.valueOf('test'), 
                                  Type = 'csv',
                                  FolderId = UserInfo.getUserId());
        
        insert d;
        
        MappingProvince__c sp = new MappingProvince__c(Name = 'Test', ProvinciaExternalKey__c='MI', SFDCexpected__c='Milano');
        insert sp;
        
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv; 
        Test.startTest();
        RecordType RT = [SELECT DeveloperName,Id,SobjectType FROM RecordType where sobjecttype = 'Account' and DeveloperName = 'Agency'];
    
        Account ag =new Account(Name ='Test',Account_email__c ='test@test.test',Agency_Code__c ='000111',Agency_Holder__c ='test',TECH_Company__c ='AAI',Active__c=true,RecordTypeId = rt.id);
        insert ag;
        
        Set<String> allAgencies = new Set<String>();
        allAgencies.add('000111');
        
        Group g =new Group (Type = 'Queue',Name = 'Coda_Agenzia_000111',DeveloperName = 'Coda_Agenzia_000111');
        insert g;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
         {
            QueueSObject q = new QueueSObject(SobjectType='Lead', QueueId=g.Id);
            insert q;
            GroupMember gm = new groupMember (GroupId= g.Id, UserOrGroupId = UserInfo.getUserId());
            insert gm; 
        }
                                         
       // list<GroupMember>  recipientPersonsG=[SELECT  GroupId,Id,SystemModstamp,UserOrGroupId,group.developername FROM GroupMember where group.developername in :setQueue ];    
    
        String myFile = 
        
LeadCSVLoaderCtr.TIPI_RAMI_ELEMENTARI + '\r\n' + LeadCSVLoaderCtr.DESCRIZIONE_RE_PREVIDENZA
+'\r\nTestNome;TestCog;111;test@test.it;T123456789012345;m;111;Nessuna;Nessuna;1/1/1800;9 - 11;vero;falso;Famiglia;Milano;MI;20060;Via Dante;;;'
+'\r\n;TestCog;112;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1801;;vero;falso;Famiglia;Milano;MI;20061;Via Dante;;;'
+'\r\nTestNome;;113;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1802;;vero;falso;Famiglia;Milano;MI;20062;Via Dante;;;'
+'\r\nTestNome;TestCog;;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1803;;vero;falso;Famiglia;Milano;MI;20063;Via Dante;;;'
+'\r\nTestNome;TestCog;115;;T123456789012345;m;;Nessuna;Nessuna;1/1/1804;;vero;falso;Famiglia;Milano;MI;20064;Via Dante;;;'
+'\r\nTestNome;TestCog;116;Wrong;T123456789012345;m;;Nessuna;Nessuna;1/1/1805;;vero;falso;Famiglia;Milano;MI;20065;Via Dante;;;'
+'\r\nTestNome;TestCog;117;test@test.it;Wrong;m;;Nessuna;Nessuna;1/1/1806;;vero;falso;Famiglia;Milano;MI;20066;Via Dante;;;'
+'\r\nTestNome;TestCog;118;test@test.it;T123456789012345;Wrong;;Nessuna;Nessuna;1/1/1807;;vero;falso;Famiglia;Milano;MI;20067;Via Dante;;;'
+'\r\nTestNome;TestCog;119;test@test.it;T123456789012345;m;Wrong;Nessuna;Nessuna;1/1/1808;;vero;falso;Famiglia;Milano;MI;20068;Via Dante;;;'
+'\r\nTestNome;TestCog;120;test@test.it;T123456789012345;m;;Nessuna;Nessuna;Wrong;;vero;falso;Famiglia;Milano;MI;20069;Via Dante;;;'
+'\r\nTestNome;TestCog;121;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1810;Wrong;vero;falso;Famiglia;Milano;MI;20070;Via Dante;;;'
+'\r\nTestNome;TestCog;122;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1811;;Wrong;falso;Famiglia;Milano;MI;20071;Via Dante;;;'
+'\r\nTestNome;TestCog;123;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1812;;vero;Wrong;Famiglia;Milano;MI;20072;Via Dante;;;'
+'\r\nTestNome;TestCog;124;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1813;;vero;falso;Wrong;Milano;MI;20073;Via Dante;;;'
+'\r\nTestNome;TestCog;125;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1814;;vero;falso;Famiglia;Milano;Wrong;20074;Via Dante;;;'
+'\r\nTestNome;TestCog;126;test@test.it;T123456789012345;m;000111;Nessuna;Nessuna;1/1/1815;;vero;falso;Famiglia;Milano;MI;Wrong;Via Dante;;;'+
'\r\nGiulio;Verme;92938223;email@email.com;MUTRGS91A47E281L;Maschio;000111;;;;;;;;;;;;;;';
        
        LeadCSVLoaderCtr l = new LeadCSVLoaderCtr();
        l.file_nome = 'Test.csv';
        
    
        l.file_contenuto = Blob.valueOf(myFile);
        l.previdenza();
        l.validaFile();
        l.importa();
        Boolean flag = true;
        
     /*   String myFile2 = 
        
        LeadCSVLoaderCtr.TIPI_NON_AUTO + '\r\n' + LeadCSVLoaderCtr.DESCRIZIONE_NON_AUTO +
        
        '\r\nGiulio;Verme;92938223;email@email.com;MUTRGS91A47E281L;Maschio;000111;;;;;;;;;;;';

        l.file_contenuto = Blob.valueOf(myFile2);
        System.debug('******l.file_contenuto '+l.file_contenuto);
        l.nonAuto();
        
        l.validaFile();*/
      //  l.importa(); 
        
        List<Lead> res = [SELECT Email, FirstName, Gender__c, Lead_Birthdate__c, LeadSource, Phone FROM Lead WHERE FirstName like '%Test%'];
    /*    System.debug('+++++ Pre controllo');
        
        if(res.size()!=1) flag = false;
        System.debug('+++++ Size ' + flag);
        if(res[0].Email != 'test@test.it') flag = false;
        System.debug('+++++ Email '  + flag);
        if(res[0].FirstName != 'TestNome') flag = false;
        System.debug('+++++ Name ' + flag);
        if(res[0].Gender__c != 'Maschio') flag = false;
        System.debug('+++++ Maschio ' + flag);
        if(res[0].Phone !='111') flag = false;
        System.debug('+++++ Phone ' + flag);
        if( res[0].Lead_Birthdate__c.format() != Date.newInstance(1800, 1, 1).format()) flag = false;
        System.debug('+++++ Data ' + flag);
        
        System.debug('+++++ Post controllo ' + flag);
        System.assertEquals(true, flag); */
        
    }

  static testMethod void protezioneValidation(){
    
        Document d = new Document(Name = 'Template Caricamento Massivo Lead PROTEZIONE', 
                                  Body=Blob.valueOf('test'), 
                                  Type = 'csv',
                                  FolderId = UserInfo.getUserId());
        
        insert d;
        
        MappingProvince__c sp = new MappingProvince__c(Name = 'Test', ProvinciaExternalKey__c='MI', SFDCexpected__c='Milano');
        insert sp;
        
        AAI_Code_Variables__c acv = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        insert acv; 
        Test.startTest();
        RecordType RT = [SELECT DeveloperName,Id,SobjectType FROM RecordType where sobjecttype = 'Account' and DeveloperName = 'Agency'];
    
        Account ag =new Account(Name ='Test',Account_email__c ='test@test.test',Agency_Code__c ='000111',Agency_Holder__c ='test',TECH_Company__c ='AAI',Active__c=true,RecordTypeId = rt.id);
        insert ag;
        
        Set<String> allAgencies = new Set<String>();
        allAgencies.add('000111');
        
        Group g =new Group (Type = 'Queue',Name = 'Coda_Agenzia_000111',DeveloperName = 'Coda_Agenzia_000111');
        insert g;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
         {
            QueueSObject q = new QueueSObject(SobjectType='Lead', QueueId=g.Id);
            insert q;
            GroupMember gm = new groupMember (GroupId= g.Id, UserOrGroupId = UserInfo.getUserId());
            insert gm; 
        }
                                         
       // list<GroupMember>  recipientPersonsG=[SELECT  GroupId,Id,SystemModstamp,UserOrGroupId,group.developername FROM GroupMember where group.developername in :setQueue ];    
    
        String myFile = 
        
LeadCSVLoaderCtr.TIPI_RAMI_ELEMENTARI + '\r\n' + LeadCSVLoaderCtr.DESCRIZIONE_RE_PROTEZIONE
+'\r\nTestNome;TestCog;111;test@test.it;T123456789012345;m;111;Nessuna;Nessuna;1/1/1800;9 - 11;vero;falso;Famiglia;Milano;MI;20060;Via Dante;;;'
+'\r\n;TestCog;112;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1801;;vero;falso;Famiglia;Milano;MI;20061;Via Dante;;;'
+'\r\nTestNome;;113;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1802;;vero;falso;Famiglia;Milano;MI;20062;Via Dante;;;'
+'\r\nTestNome;TestCog;;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1803;;vero;falso;Famiglia;Milano;MI;20063;Via Dante;;;'
+'\r\nTestNome;TestCog;115;;T123456789012345;m;;Nessuna;Nessuna;1/1/1804;;vero;falso;Famiglia;Milano;MI;20064;Via Dante;;;'
+'\r\nTestNome;TestCog;116;Wrong;T123456789012345;m;;Nessuna;Nessuna;1/1/1805;;vero;falso;Famiglia;Milano;MI;20065;Via Dante;;;'
+'\r\nTestNome;TestCog;117;test@test.it;Wrong;m;;Nessuna;Nessuna;1/1/1806;;vero;falso;Famiglia;Milano;MI;20066;Via Dante;;;'
+'\r\nTestNome;TestCog;118;test@test.it;T123456789012345;Wrong;;Nessuna;Nessuna;1/1/1807;;vero;falso;Famiglia;Milano;MI;20067;Via Dante;;;'
+'\r\nTestNome;TestCog;119;test@test.it;T123456789012345;m;Wrong;Nessuna;Nessuna;1/1/1808;;vero;falso;Famiglia;Milano;MI;20068;Via Dante;;;'
+'\r\nTestNome;TestCog;120;test@test.it;T123456789012345;m;;Nessuna;Nessuna;Wrong;;vero;falso;Famiglia;Milano;MI;20069;Via Dante;;;'
+'\r\nTestNome;TestCog;121;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1810;Wrong;vero;falso;Famiglia;Milano;MI;20070;Via Dante;;;'
+'\r\nTestNome;TestCog;122;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1811;;Wrong;falso;Famiglia;Milano;MI;20071;Via Dante;;;'
+'\r\nTestNome;TestCog;123;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1812;;vero;Wrong;Famiglia;Milano;MI;20072;Via Dante;;;'
+'\r\nTestNome;TestCog;124;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1813;;vero;falso;Wrong;Milano;MI;20073;Via Dante;;;'
+'\r\nTestNome;TestCog;125;test@test.it;T123456789012345;m;;Nessuna;Nessuna;1/1/1814;;vero;falso;Famiglia;Milano;Wrong;20074;Via Dante;;;'
+'\r\nTestNome;TestCog;126;test@test.it;T123456789012345;m;000111;Nessuna;Nessuna;1/1/1815;;vero;falso;Famiglia;Milano;MI;Wrong;Via Dante;;;'+
'\r\nGiulio;Verme;92938223;email@email.com;MUTRGS91A47E281L;Maschio;000111;;;;;;;;;;;;;;';
        
        LeadCSVLoaderCtr l = new LeadCSVLoaderCtr();
        l.file_nome = 'Test.csv';
        
    
        l.file_contenuto = Blob.valueOf(myFile);
        l.protezione();
        l.validaFile();
        l.importa();
        Boolean flag = true;
        
     /*   String myFile2 = 
        
        LeadCSVLoaderCtr.TIPI_NON_AUTO + '\r\n' + LeadCSVLoaderCtr.DESCRIZIONE_NON_AUTO +
        
        '\r\nGiulio;Verme;92938223;email@email.com;MUTRGS91A47E281L;Maschio;000111;;;;;;;;;;;';

        l.file_contenuto = Blob.valueOf(myFile2);
        System.debug('******l.file_contenuto '+l.file_contenuto);
        l.nonAuto();
        
        l.validaFile();*/
      //  l.importa(); 
        
        List<Lead> res = [SELECT Email, FirstName, Gender__c, Lead_Birthdate__c, LeadSource, Phone FROM Lead WHERE FirstName like '%Test%'];
    /*    System.debug('+++++ Pre controllo');
        
        if(res.size()!=1) flag = false;
        System.debug('+++++ Size ' + flag);
        if(res[0].Email != 'test@test.it') flag = false;
        System.debug('+++++ Email '  + flag);
        if(res[0].FirstName != 'TestNome') flag = false;
        System.debug('+++++ Name ' + flag);
        if(res[0].Gender__c != 'Maschio') flag = false;
        System.debug('+++++ Maschio ' + flag);
        if(res[0].Phone !='111') flag = false;
        System.debug('+++++ Phone ' + flag);
        if( res[0].Lead_Birthdate__c.format() != Date.newInstance(1800, 1, 1).format()) flag = false;
        System.debug('+++++ Data ' + flag);
        
        System.debug('+++++ Post controllo ' + flag);
        System.assertEquals(true, flag); */
        
    }

}
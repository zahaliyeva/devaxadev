@isTest
public  class SendCaseAutomaticQueueController_TEST {
    @testSetup static void setup(){
        // AGENT
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name = 'NFE - AAI - Vendite Base'];
        Profile p;
        Id pAgent;
        if (profiles.size() > 0)
        {
            p      = profiles[0];
            pAgent = p.Id;
        }
        
        MPS_Code_Variables__c Mcv = new MPS_Code_Variables__c(Name='Switch Notifica Storico Conversazione',Value__c='true');
        insert Mcv;
        
        
        Account acct = new Account(Name = 'SFDC Account 1',
                                    AAI_Agency_Reference_Code__c = 'Test',
                                  	Agency_Email__c = 'test@test.com',
                                    Agency_Code__c = 'Test');
        insert acct;
        Id accId     = acct.Id;
        
        Contact con = new Contact(FirstName = 'Joe',
                                  LastName  = 'Smith',
                                  Phone     = '415.555.1212',
                                  AccountId = accId);
        insert con;
        Id conId = con.Id;
        
        User newAgent = new User(Username                     = 'agente@axa.test.com',
                                 LastName                     = 'testuser',
                                 LanguageLocaleKey            = 'it',
                                 FirstName                    = 'test',
                                 Email                        = 'test@test.com', 
                                 Alias                        = 'test',
                                 TimeZoneSidKey               = 'Europe/Dublin',
                                 LocaleSidKey                 = 'it_IT',
                                 EmailEncodingKey             = 'UTF-8',
                                 ProfileId                    = pAgent,
                                 ContactId                    = conId,
                                 UserPermissionsKnowledgeUser = true);
        insert newAgent;
        
        // SUPPORT
        List<Profile> profiles2 = [SELECT Id, Name FROM Profile WHERE Name in  ('AAI - Supporto HD1 - Lightning','AAI - Supporto HD1 BIZ - Lightning','AAI - Supervisor Supporto HD1 Contabilità - Lightning','AAI - Supervisor Supporto HD1 Contabilita - Lightning','AAI - Supporto HD2')];
        Profile p2;
        Id pSupport;
        
        Id pSupportBiz;
        Id pSupportContabSuper;
        
        Id pHd2;
        
        for(Profile ps:profiles2)
        {
            if(ps.Name =='AAI - Supporto HD1 - Lightning')
            {
                pSupport  = ps.Id;
            }
            else if(ps.Name =='AAI - Supervisor Supporto HD1 Contabilità - Lightning' || ps.Name =='AAI - Supervisor Supporto HD1 Contabilita - Lightning')
            {
                pSupportContabSuper = ps.Id;
            }
            
            else if(ps.Name == 'AAI - Supporto HD2'){
                pHd2 = ps.Id;
            }
            
            else 
            {
                pSupportBiz = ps.id;
            }
        }
        
        
        Account acct2 = new Account(Name = 'SFDC Account support');
        insert acct2;
        Id accId2     = acct2.Id;
        
        Contact con2 = new Contact(FirstName = 'Joe',
                                   LastName  = 'Smi',
                                   Phone     = '415.555.9082',
                                   AccountId = accId2);
        insert con2;
        Id conId2 = con2.Id;
        
        User newSupport = new User(Username                     = 'supporto@axa.test.com',
                                   LastName                     = 'testuser2',
                                   LanguageLocaleKey            = 'it',
                                   FirstName                    = 'test2',
                                   Email                        = 'test2@test.com', 
                                   Alias                        = 'test2',
                                   TimeZoneSidKey               = 'Europe/Dublin',
                                   LocaleSidKey                 = 'it_IT',
                                   EmailEncodingKey             = 'UTF-8',
                                   ProfileId                    = pSupport,
                                   UserPermissionsKnowledgeUser = true);
        insert newSupport;
        
        
        List<User> ContContenzSupportUsr = new List<User>();
        List<UserRole> ContContenzRoles = [Select Id from UserRole where Name in ('HD1 Contabilita','HD1 Contenzioso','Interni','MdC AXA','RGI') order by Name asc];
        
        User newContabilitaSupport = new User(Username          = 'supporto3@axa.test.com',
                                              LastName                     = 'testuser',
                                              LanguageLocaleKey            = 'it',
                                              FirstName                    = 'test',
                                              Email                        = 'test@test.com', 
                                              Alias                        = 'test',
                                              TimeZoneSidKey               = 'Europe/Dublin',
                                              LocaleSidKey                 = 'it_IT',
                                              EmailEncodingKey             = 'UTF-8',
                                              ProfileId                    = pSupport,
                                              UserRoleId                   = ContContenzRoles[0].Id,
                                              UserPermissionsKnowledgeUser = true);
        
        ContContenzSupportUsr.add(newContabilitaSupport);
        
        User newContenziosoSupport = new User(Username          = 'supporto4@axa.test.com',
                                              LastName                     = 'testuser',
                                              LanguageLocaleKey            = 'it',
                                              FirstName                    = 'test',
                                              Email                        = 'tes2@test.com', 
                                              Alias                        = 'test',
                                              TimeZoneSidKey               = 'Europe/Dublin',
                                              LocaleSidKey                 = 'it_IT',
                                              EmailEncodingKey             = 'UTF-8',
                                              ProfileId                    = pSupport,
                                              UserRoleId                   = ContContenzRoles[1].Id,
                                              UserPermissionsKnowledgeUser = true);   
        
        ContContenzSupportUsr.add(newContenziosoSupport);
        
        User newHD1BIZSupport  = new User(Username              = 'supportobiz@axa.test.com',
                                          LastName                     = 'testuser',
                                          LanguageLocaleKey            = 'it',
                                          FirstName                    = 'test',
                                          Email                        = 'tes2@test.com', 
                                          Alias                        = 'test',
                                          TimeZoneSidKey               = 'Europe/Dublin',
                                          LocaleSidKey                 = 'it_IT',
                                          EmailEncodingKey             = 'UTF-8',
                                          ProfileId                    = pSupportBiz);   
        
        ContContenzSupportUsr.add(newHD1BIZSupport);
        
        
        User newHD1ContabSupportSuperv  = new User(Username     = 'supportcontabSuperv@axa.test.com',
                                                   LastName                     = 'testuser',
                                                   LanguageLocaleKey            = 'it',
                                                   FirstName                    = 'test',
                                                   Email                        = 'tes2@test.com', 
                                                   Alias                        = 'test',
                                                   TimeZoneSidKey               = 'Europe/Dublin',
                                                   LocaleSidKey                 = 'it_IT',
                                                   EmailEncodingKey             = 'UTF-8',
                                                   ProfileId                    = pSupportContabSuper);   
        
        ContContenzSupportUsr.add(newHD1ContabSupportSuperv);
        
        
        User newMdCAXASupport = new User(Username          = 'supporto5@axa.test.com',
                                         LastName                     = 'testuser',
                                         LanguageLocaleKey            = 'it',
                                         FirstName                    = 'test',
                                         Email                        = 'tes2@test.com', 
                                         Alias                        = 'test',
                                         TimeZoneSidKey               = 'Europe/Dublin',
                                         LocaleSidKey                 = 'it_IT',
                                         EmailEncodingKey             = 'UTF-8',
                                         ProfileId                    = pHd2,
                                         UserRoleId                   = ContContenzRoles[3].Id,
                                         UserPermissionsKnowledgeUser = true);   
        
        ContContenzSupportUsr.add(newMdCAXASupport);
        
        User newRGISupport = new User(Username          = 'supporto6@axa.test.com',
                                      LastName                     = 'testuser',
                                      LanguageLocaleKey            = 'it',
                                      FirstName                    = 'test',
                                      Email                        = 'tes2@test.com', 
                                      Alias                        = 'test',
                                      TimeZoneSidKey               = 'Europe/Dublin',
                                      LocaleSidKey                 = 'it_IT',
                                      EmailEncodingKey             = 'UTF-8',
                                      ProfileId                    = pHd2,
                                      UserRoleId                   = ContContenzRoles[4].Id,
                                      UserPermissionsKnowledgeUser = true);   
        
        ContContenzSupportUsr.add(newRGISupport);
        
        User agentHD2 = new User(Username                     = 'hd2agent@axa.test.com',
                                 LastName                     = 'testuser22',
                                 LanguageLocaleKey            = 'it',
                                 FirstName                    = 'test22',
                                 Email                        = 'test22@test.com', 
                                 Alias                        = 'test22',
                                 TimeZoneSidKey               = 'Europe/Dublin',
                                 LocaleSidKey                 = 'it_IT',
                                 EmailEncodingKey             = 'UTF-8',
                                 ProfileId                    = pHd2,
                                 UserRoleId                   = ContContenzRoles[2].Id,
                                 UserPermissionsKnowledgeUser = true);
        ContContenzSupportUsr.add(agentHD2);
        
        List<Case> CaseList = new List<Case>();
        
        ID RectypeId = RecordTypeUtility.getRecordTypeIdByDeveloperName('Case', 'Assistenza_Agenti');
        
        List<Case> caseToInsert = new List<Case>();
        Case caseObj1 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Attesa Info Agente',
                                 Origin    = 'Portale Assistenza',
                                 OwnerId   = newAgent.Id,
                                 User__c   = newAgent.Id,
                                 Current_Owner_Queue__c = '',
                                 LOB__c = 'IT',
                                 Category__c ='AUTO',
                                 SubCategory__c ='Consultazioni',
                                 RecordtypeId = RectypeId
                                );
        caseToInsert.add(caseObj1);
        
        Case caseObj2 = new Case(ContactId = conId2,
                                 AccountId = accId2,
                                 Status    = 'Assigned',
                                 Origin    = 'Portale Assistenza',
                                 OwnerId   = newSupport.Id,
                                 User__c   = newSupport.Id,
                                 Current_Owner_Queue__c ='HD1_IT',
                                 LOB__c = 'Contabilità Danni',
                                 Category__c ='Foglio Cassa',
                                 RecordtypeId = RectypeId);
        caseToInsert.add(caseObj2);
        
        Case caseObj4 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Risolto',
                                 Origin    = 'Portale Assistenza',
                                 OwnerId   = newSupport.Id,
                                 User__c   = newAgent.Id,
                                 Current_Owner_Queue__c = 'HD2_Biz_Auto',
                                 LOB__c = 'Vita',
                                 Category__c = 'Test',
                                 RecordtypeId = RectypeId);
        caseToInsert.add(caseObj4);
        
        
        Case defectCase = new Case(ContactId = conId2,
                                   AccountId = accId2,
                                   Status    = 'Assigned',
                                   Origin    = 'Portale Assistenza',
                                   OwnerId   = newSupport.Id,
                                   User__c   = newSupport.Id,
                                   Defect_Mdc__c = true,
                                   Current_Owner_Queue__c = 'HD2_Modulo_di_Calcolo_AXA',
                                   LOB__c = 'Vita',
                                   Category__c = 'Test',
                                   RecordtypeId = RectypeId);
        caseToInsert.add(defectCase);
        
        
        insert caseToInsert;
        
        //QueueName
        Group g1 = new Group(Name='HD2 Biz Vita Ptf Previdenza', type='Queue');
        insert g1;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
        }
        
        Group g2 = new Group(Name='EFNOL Assistance', type='Queue');
        insert g2;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject q2 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q2;
        }
        
        //QueueDevName
        Group g3 = new Group(Name ='HD2 Biz Vita Ptf Previdenza', type='Queue');
        insert g3;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject q3 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q3;
        }
        
        Group g4 = new Group(Name= 'HD2 IT', type='Queue');
        insert g4;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject q4 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q4;
        }
        
        
        GroupMember member = new GroupMember();
        member.UserOrGroupId = newSupport.Id;
        member.GroupId = g3.Id;
        
        GroupMember member2 = new GroupMember();
        member2.UserOrGroupId = newAgent.Id;
        member2.GroupId = g2.Id;
        
        
        
        
        list<Mapping_Automatic_Owner_NMA__c> listMapping = new list<Mapping_Automatic_Owner_NMA__c>();
        Mapping_Automatic_Owner_NMA__C map1 = new  Mapping_Automatic_Owner_NMA__C(Coda_di_Destinazione__c = 'EFNOL Assistance',
                                                                                  LOB__c = 'IT',
                                                                                  Category__c ='AUTO',
                                                                                  Sub_Category__c ='Consultazioni',RecordType__c = 'Assistenza_Agenti');
        
        listMapping.add(map1);
        
        
        Mapping_Automatic_Owner_NMA__C map2 = new  Mapping_Automatic_Owner_NMA__C(Coda_di_Destinazione__c = 'HD2 Biz Vita Ptf Previdenza',
                                                                                  LOB__c = 'Contabilità Danni',
                                                                                  Category__c ='Foglio Cassa',RecordType__c = 'Assistenza_Agenti');
        
        listMapping.add(map2);
        
        Mapping_Automatic_Owner_NMA__C map3 = new  Mapping_Automatic_Owner_NMA__C(Coda_di_Destinazione__c = 'HD2 Biz Vita Assunzione',
                                                                                  LOB__c = 'Vita', Recordtype__c = 'Assistenza_Agenti', Category__c ='Test');
        
        
        listMapping.add(map3);
        
        insert listMapping;
        
        EmailTemplate t = new EmailTemplate();
        t.DeveloperName = 'ComunicazioneDaHD1';
        t.Subject       = 'Case: {!Case.CaseNumber}, Stato: {!Case.Status}';
        t.HtmlValue     = '<html><body>{!Case.User__c}, {!Case.CaseNumber}, {!Case.Link}, {!Case.Description}</body></html>';
        t.body          = '{!Case.User__c}, {!Case.CaseNumber}, {!Case.Link}, {!Case.Description}';
        t.name          = 'ComunicazioneDaHD1';
        t.templatetype  = 'custom';
        t.folderid      = UserInfo.getUserId();
        
        String encodedContentsString = System.currentPageReference().getParameters().get('fileContents');
        
        Attachment attachment = new Attachment();
        attachment.Body       = Blob.valueOf('CiAgICAgPHhzZDpwYXR0ZXJuIHZhbHVlPSJbYS16QS1aMC05XXsxOH0iLz4KICAgIDwveHNkOnJlc3RyaWN0aW9uPgogICA8L3hzZDpzaW1wbGVUeXBlPgogICA8eHNkOmNvbXBsZXhUeXBlIG5hbWU9IlNlcnZpY2VSZXN1bHQiPgogICAgPHhzZDpzZXF1ZW5jZT4KICAgICA8eHNkOmVsZW1lbnQgbmFtZT0iTWVzc2FnZSIgbWluT2NjdXJzPSIwIiB0eXBlPSJ4c2Q6c3RyaW5nIiBuaWxsYWJsZT0idHJ1ZSIvPgogICAgIDx4c2Q6ZWxlbWVudCBuYW1lPSJSZXN1bHQiIG1pbk9jY3Vycz0iMCIgdHlwZT0ieHNkOnN0cmluZyIgbmlsbGFibGU9InRydWUiLz4KICAgICA8eHNkOmVsZW1lbnQgbmFtZT0iVXNlckQiIG1pbk9jY3Vycz0iMCIgdHlwZT0idG5zOlVzZXJEZXRhaWxzSW5wdXQiIG5pbGxhYmxlPSJ0cnVlIi8');
        attachment.Name       = String.valueOf('test.txt');
        attachment.ParentId   = conId; 
        attachment.OwnerId    = newAgent.Id;
        insert attachment;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            //insert t; 
            insert ContContenzSupportUsr;
        }
        
        
        
        
        
        insert new MPS_Code_Variables__c(Name = 'HD2 RGI', value__c = 'RGI;');
        insert new MPS_Code_Variables__c(Name = 'MdC AXA', value__c = 'MdC AXA;');
        insert new MPS_Code_Variables__c(Name = 'BusinessHours_Default', value__c = '01m24000000Gxf5AAC');
        insert new MPS_Code_Variables__c(Name = 'ModuloDiCalcolo_tempiInoltroCoda', value__c = '1');
        
        
        
        
    }
    
    @isTest
    static  void testmethod01(){
        
        test.startTest();
        list<Case> listCase = [SELECT Id, LOB__c, Category__c, SubCategory__c FROM Case LIMIT 4];
        SendCaseAutomaticQueueController.getOwnerIdForSendAutomaticHD1IT(listCase[0].Id);
        SendCaseAutomaticQueueController.getOwnerIdForSendAutomatic(listCase[0].Id,'Claims Trasformation');
        SendCaseAutomaticQueueController.getOptionsValuesInvioAHD3(listCase[0].Id);
        SendCaseAutomaticQueueController.getOptionsValuesForTicketSilva(listCase[0].Id);
        SendCaseAutomaticQueueController.getOwnerIdForSendAutomaticCaring('Claims Trasformation');
        SendCaseAutomaticQueueController.skipMappingAutomaticOwnerNMAConfiguration(listCase[0].Id);
        SendCaseAutomaticQueueController.InvioAHD3(listCase[0].Id,'ciao',date.today(),'ciao2', 'Test');
        
        test.stopTest();
    }
    
    @isTest
    static  void testmethod02(){
        
        test.startTest();
        list<Case> listCase = [SELECT Id, LOB__c, Category__c, SubCategory__c FROM Case LIMIT 4];
        SendCaseAutomaticQueueController.getOwnerIdForSendAutomaticHD1Contabilita(listCase[0].Id);
        
        test.stopTest();
    }
    
    @isTest
    static  void testmethod03(){
        
        test.startTest();
        list<Case> listCase = [SELECT Id, LOB__c, Category__c, SubCategory__c FROM Case LIMIT 4];
        SendCaseAutomaticQueueController.getOwnerIdForSendManualHD1IT(listCase[0].Id);
        
        test.stopTest();
    }
    
    @isTest
    static  void testmethod04(){
        
        test.startTest();
        list<Group> listGroup = [SELECT Name FROM Group WHERE Type ='Queue' limit 4];
        SendCaseAutomaticQueueController.getOwnerQueueIdFromName(listGroup[0].Name);
        
        test.stopTest();
    }
    
    @isTest
    static  void testmethod05(){
        
        test.startTest();
        list<Group> listGroup = [SELECT DeveloperName FROM Group WHERE Type ='Queue' limit 4];
        SendCaseAutomaticQueueController.getOwnerQueueIdFromDevName(listGroup[0].DeveloperName);
        
        test.stopTest();
    }
    
    @isTest
    static  void testmethod06(){
        
        test.startTest();
        list<Case> listCase = [SELECT Id FROM Case LIMIT 4];
        SendCaseAutomaticQueueController.getOptionsValuesInvioASecondoLivello(listCase[0].Id);
        
        test.stopTest();
    }
    
    @isTest
    static  void testmethod07(){
        
        test.startTest();
        list<Case> listCase = [SELECT Id FROM Case LIMIT 4];
        SendCaseAutomaticQueueController.getOptionsValuesInviaAdAltraArea(listCase[0].Id);
        
        test.stopTest();
    }
    
    @isTest
    static  void testmethod08() 
    {
        
        test.startTest();
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        System.runAs(agent)
        {
            
            String comm    = 'Commento di prova';
            String ident   = caseobj[0].Id;
            
            String output  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident, 'Agente', 1, attachmentList, '','label','NFE - AAI - Vendite Base','',false,'','','','');  
        }
        
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id; 
            
            attachmentList.clear();
            String output2 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Agente', 0, attachmentList, '','label','AAI - Supporto HD1','',false,'','','','');
            
        }
        
        test.stopTest();   
        
    }
    
    @isTest
    static  void testmethod09(){
        
        Case defectCase = [SELECT Id FROM Case WHERE Defect_Mdc__c = true LIMIT 1];
        
        test.startTest();
        
        Boolean isDefectCase = SendCaseAutomaticQueueController.getDefectMdC(defectCase.Id);
        
        test.stopTest();
    }
    @isTest
    static  void testmethod10(){
        
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        
        test.startTest();
        
        User supportRGI = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto6@axa.test.com' AND isActive = true LIMIT 1];   
        CaseTeamRole Ctr = [Select id from CaseTeamRole where Name='HD2 IT'];
        
        Case cas = new Case(
            Status    = 'In gestione Specialista',
            Origin    = 'Chat',
            OwnerId   = supportRGI.id,
            RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        insert cas;
        
        List<CaseTeamMember> ctms = new List<CaseTeamMember>();
        CaseTeamMember ctm_rgi = new CaseTeamMember(MemberId=supportRGI.id,parentid=cas.id,TeamRoleid=Ctr.id);
        ctms.add(ctm_rgi);
        
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        
        
        
        String comm    = 'Commento di prova';
        
    }
    @isTest
    static  void testmethod11(){
        
        User profileHd2 = [SELECT Id, ProfileId FROM User WHERE Username = 'hd2agent@axa.test.com' AND isActive = true LIMIT 1];
        
        test.startTest();
        
        boolean isHd2 = SendCaseAutomaticQueueController.checkProfileHD2();
        
        test.stopTest();
        
    }
    @isTest
    static void testmethod12(){
        
        test.startTest();
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        
        
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id;
            Id ownerId = support.id;
            attachmentList.clear();
            String output2 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto HD1 IT','AAI - Supporto HD1','',false,'','HD1_Biz_Vita','Vita',ownerId);
            String output3 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto HD1 IT','AAI - Supporto HD1','',false,'','HD1_Contabilita','Contabilità Vita',ownerId);
            String outputt  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,ident1, 'Supporto', 1, attachmentList, '','Supporto HD1 IT','Supporto HD1 IT','',false,'','HD1_IT','IT',ownerId);
        }
        
        test.stopTest();   
        
    } 
    @isTest
    static void testmethod13(){
        
        test.startTest();
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        
        
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id;
            Id ownerId = support.id;
            attachmentList.clear();
            String output4 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto HD1 IT','AAI - Supporto HD1','',false,'','HD1_Contabilita','Contabilità Danni',ownerId);
            String output5 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto HD1 IT','AAI - Supporto HD1','',false,'','HD1_Contenzioso','Contenzioso',ownerId);
            
        }
        
        test.stopTest();   
        
    }
    @isTest
    static void testmethod14(){
        
        test.startTest();
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        
        
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id;
            Id ownerId = support.id;
            attachmentList.clear();
            String output6 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto HD1 IT','AAI - Supporto HD1','',false,'','HD1_Biz_Famiglia','Famiglia',ownerId);
            String output7 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto HD1 IT','AAI - Supporto HD1','',false,'','HD1_Biz_Salute','Salute',ownerId);
            
        }
        
        test.stopTest();   
        
    }
    @isTest
    static void testmethod16(){
        
        test.startTest();
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        
        
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id;
            Id ownerId = support.id;
            attachmentList.clear();
            String output8 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto HD1 IT','AAI - Supporto HD1','',false,'','HD1_Biz_Auto','Auto',ownerId);
            String output9 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto HD1 IT','AAI - Supporto HD1','',false,'','HD1_Biz_Commercial_line','Commercial line',ownerId);
        }
        
        test.stopTest();   
        
    }
    @isTest
    static void testmethod17(){
        
        test.startTest();
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        
        
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id;
            Id ownerId = support.id;
            attachmentList.clear();
            String output10 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Contabilità','AAI - Supporto HD1','',false,'','HD1_Biz_Vita','Vita',ownerId);
            String output11 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Contabilità','AAI - Supporto HD1','',false,'','HD1_Contabilita','Contabilità Vita',ownerId);
            
        }
        
        test.stopTest();   
        
    }
    @isTest
    static void testmethod18(){
        
        test.startTest();
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        
        
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id;
            Id ownerId = support.id;
            attachmentList.clear();
            String output12  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,ident1, 'Supporto', 1, attachmentList, '','Supporto Contabilità','AAI - Supporto HD1','',false,'','HD1_IT','IT',ownerId);            
            String output13 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Contabilità','AAI - Supporto HD1','',false,'','HD1_Contabilita','Contabilità Danni',ownerId);
            
        }
        
        test.stopTest();   
        
    }
    @isTest
    static void testmethod19(){
        
        test.startTest();
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        
        
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id;
            Id ownerId = support.id;
            attachmentList.clear();
            String output14 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Contabilità','AAI - Supporto HD1','',false,'','HD1_Contenzioso','Contenzioso',ownerId);
            String output15 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Contabilità','AAI - Supporto HD1','',false,'','HD1_Biz_Famiglia','Famiglia',ownerId);
            String output16 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Contabilità','AAI - Supporto HD1','',false,'','HD1_Biz_Salute','Salute',ownerId);
            
        }
        
        test.stopTest();   
        
    }
    @isTest
    static void testmethod20(){
        
        test.startTest();
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        
        
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id;
            Id ownerId = support.id;
            attachmentList.clear();
            String output17 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Contenzioso','AAI - Supporto HD1','',false,'','HD1_Biz_Vita','Vita',ownerId);
            String output18 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Contenzioso','AAI - Supporto HD1','',false,'','HD1_Contabilita','Contabilità Vita',ownerId);
            String output19  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,ident1, 'Supporto', 1, attachmentList, '','Supporto Contenzioso','AAI - Supporto HD1','',false,'','HD1_IT','IT',ownerId);            
            
        }
        
        test.stopTest();   
        
    }
    @isTest
    static void testmethod21(){
        
        test.startTest();
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        
        
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id;
            Id ownerId = support.id;
            attachmentList.clear();
            String output20 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Contenzioso','AAI - Supporto HD1','',false,'','HD1_Contabilita','Contabilità Danni',ownerId);
            String output21 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Contenzioso','AAI - Supporto HD1','',false,'','HD1_Contenzioso','Contenzioso',ownerId);
            String output22 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Contenzioso','AAI - Supporto HD1','',false,'','HD1_Biz_Famiglia','Famiglia',ownerId);
            
        }
        
        test.stopTest();   
        
    }
    @isTest
    static void testmethod22(){
        
        test.startTest();
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        
        
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id;
            Id ownerId = support.id;
            attachmentList.clear();
            String output24 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Modulo di Calcolo','AAI - Supporto HD1','',false,'','HD1_Biz_Vita','Vita',ownerId);
            String output25 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Modulo di Calcolo','AAI - Supporto HD1','',false,'','HD1_Contabilita','Contabilità Vita',ownerId);
            String output26  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,ident1, 'Supporto', 1, attachmentList, '','Supporto Modulo di Calcolo','AAI - Supporto HD1','',false,'','HD1_IT','IT',ownerId);            
            
        }
        
        test.stopTest();   
        
    }
    @isTest
    static void testmethod23(){
        
        test.startTest();
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        
        
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id;
            Id ownerId = support.id;
            attachmentList.clear();
            String output27 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Modulo di Calcolo','AAI - Supporto HD1','',false,'','HD1_Contabilita','Contabilità Danni',ownerId);
            String output28 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Modulo di Calcolo','AAI - Supporto HD1','',false,'','HD1_Contenzioso','Contenzioso',ownerId);
            String output29 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Modulo di Calcolo','AAI - Supporto HD1','',false,'','HD1_Biz_Famiglia','Famiglia',ownerId);
            
        }
        
        test.stopTest();   
        
    }
    @isTest
    static void testmethod24(){
        
        test.startTest();
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        
        
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id;
            Id ownerId = support.id;
            attachmentList.clear();
            String output31 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto HD1 BIZ','AAI - Supporto HD1','',false,'','HD1_Biz_Vita','Vita',ownerId);
            String output32 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto HD1 BIZ','AAI - Supporto HD1','',false,'','HD1_Contabilita','Contabilità Vita',ownerId);
            String output33  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,ident1, 'Supporto', 1, attachmentList, '','Supporto HD1 BIZ','AAI - Supporto HD1','',false,'','HD1_IT','IT',ownerId);            
            
        }
        
        test.stopTest();   
        
    }
    @isTest
    static void testmethod25(){
        
        test.startTest();
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id;
            Id ownerId = support.id;
            attachmentList.clear();
            String output34 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto HD1 BIZ','AAI - Supporto HD1','',false,'','HD1_Contabilita','Contabilità Danni',ownerId);
            String output35 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto HD1 BIZ','AAI - Supporto HD1','',false,'','HD1_Contenzioso','Contenzioso',ownerId);
            String output36 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto HD1 BIZ','AAI - Supporto HD1','',false,'','HD1_Biz_Famiglia','Famiglia',ownerId);
            
        }
        
        test.stopTest();   
        
    }
    @isTest
    static void testmethod26(){
        
        test.startTest();
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        
        
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id;
            Id ownerId = support.id;
            attachmentList.clear();
            String output30 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Modulo di Calcolo','AAI - Supporto HD1','',false,'','HD1_Biz_Salute','Salute',ownerId);
            String output23 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Contenzioso','AAI - Supporto HD1','',false,'','HD1_Biz_Salute','Salute',ownerId);
            String output37 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto HD1 BIZ','AAI - Supporto HD1','',false,'','HD1_Biz_Salute','Salute',ownerId);
            
        }
        
        test.stopTest();   
        
    }
    
    @isTest
    static void testmethod27(){
        test.startTest();
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id;
            Id ownerId = support.id;
            attachmentList.clear();
            String output31 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, '','Supporto Modulo di Calcolo','AAI - Supporto HD1','',false,'','HD1_Biz_Vita','Vita',ownerId);
        }
        test.stopTest();     
    }
    
    @isTest
    static void testmethod28(){
        test.startTest();
        Case cs = new Case();
        insert cs;
        SendCaseAutomaticQueueController.showModalOnRitornoHD1(cs.Id);
        test.stopTest();
    }
    
    @isTest
    static void testmethod29(){
        test.startTest();
        Case cs = new Case();
        cs.Current_Owner_Queue__c = 'Test';
        insert cs;
        Case cs2 = new Case();
        insert cs2;
        String idCs2 = String.ValueOf(cs2.Id);
        SendCaseAutomaticQueueController.CompilaTicketSilva(cs.Id, idCs2, 'Incident');
        test.stopTest();     
    }
    
    @isTest
    static void testmethod30(){
        test.startTest();
        Case cs = new Case();
        cs.Current_Owner_Queue__c = 'Test';
        insert cs;
        SendCaseAutomaticQueueController.UpdateTagRichiesta(cs.Id, 'Terze Parti');
        test.stopTest();     
    }
    
    @isTest
    static void testmethod31(){
        test.startTest();
        Case cs = new Case();
        insert cs;
        SendCaseAutomaticQueueController.getCaseFields(cs.Id);
        test.stopTest();
    }
    
    @isTest
    static void testmethod32(){
        test.startTest();
        Case cs = new Case();
        insert cs;
        SendCaseAutomaticQueueController.getCaseValues(cs.Id);
        test.stopTest();
    }
    
    @isTest
    static void testmethod33(){
        
        test.startTest();
        RecordType rT = [select id from recordtype where name = 'AXA Caring Salute' LIMIT 1];
        User newAgent = [SELECT id from User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User newSupport = [SELECT id from User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        String conId = [SELECT id from Contact LIMIT 1].Id;
        String accId = [SELECT id from Account LIMIT 1].Id;
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        Case cs = new Case(ContactId = conId,
                           AccountId = accId,
                           Status    = 'Risolto',
                           Origin    = 'Portale Assistenza',
                           OwnerId   = newSupport.Id,
                           User__c   = newAgent.Id,
                           Current_Owner_Queue__c = 'HD1',
                           LOB__c = 'Vita',
                           Category__c = 'Test',
                           RecordtypeId = rT.Id,
                           Agency_Code__c = 'Test');
        insert cs;
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        
        
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            Id ownerId = support.id;
            attachmentList.clear();
            String output2 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, cs.id, 'Supporto', 0, attachmentList, '','Supporto HD1 IT','AAI - Supporto HD1','',false,'','HD1_Biz_Vita','Vita',ownerId);
            RecordType rT2 = [select id from recordtype where name = 'Caring Angel' LIMIT 1];
            cs.RecordTypeId = rT2.Id;
            update cs;
            String output3 = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm, cs.id, 'Supporto', 0, attachmentList, '','Supporto HD1 IT','AAI - Supporto HD1','',false,'In attesa info da cliente/rete','HD1_Contabilita','Contabilità Vita',ownerId);
            String output4  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,cs.id, 'Supporto', 1, attachmentList, '','Supporto HD1 IT','Supporto HD1 IT','',false,'','HD1_IT','IT',ownerId);
        }
        
        test.stopTest();   
        
    } 
    
    @isTest
    static void testmethod34(){
        
        test.startTest();
        RecordType rT = [select id from recordtype where name = 'AXA Caring Salute' LIMIT 1];
        User newAgent = [SELECT id from User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User newSupport = [SELECT id from User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Contact con = [SELECT id from Contact LIMIT 1];
        Account acc = [SELECT id,Agency_Email__c,AAI_Agency_Reference_Code__c from Account WHERE Name = 'SFDC Account 1' LIMIT 1];
        System.debug('@@@Account -> '+ acc);
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        Case cs = new Case(Contact = con,
                           Account = acc,
                           ContactId = con.Id,
                           AccountId = acc.Id,
                           Status    = 'Risolto',
                           Origin    = 'Portale Assistenza',
                           OwnerId   = newSupport.Id,
                           User__c   = newAgent.Id,
                           Current_Owner_Queue__c = 'HD1',
                           LOB__c = 'Vita',
                           Category__c = 'Test',
                           RecordtypeId = rT.Id,
                           Agency_Code__c = 'Test');
        insert cs;
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        
        
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            Id ownerId = support.id;
            attachmentList.clear();
            RecordType rT3 = [select id from recordtype where name = 'Axa Assicurazioni' LIMIT 1];
            cs.RecordTypeId = rT3.Id;
            update cs;
            String output5  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,cs.id, 'Supporto', 1, attachmentList, '','Supporto HD1 IT','Supporto HD1 IT','',false,'','HD1_IT','IT',ownerId);
            System.debug('@@@cs -> ' +cs.Account.Agency_Email__c + '   @@@ cs -> ' + cs.Account.AAI_Agency_Reference_Code__c);
            String output6  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,cs.id, 'Agente', 1, attachmentList, '','Supporto HD1 IT','Supporto HD1 IT','',false,'','HD1_IT','IT',ownerId);
            RecordType rT4 = [select id from recordtype where name = 'Close the loop' LIMIT 1];
            cs.RecordTypeId = rT4.Id;
            update cs;
            String output7  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,cs.id, 'Agente', 1, attachmentList, '','Supporto HD1 IT','Supporto HD1 IT','',false,'','HD1_IT','IT',ownerId);
        }
        
        test.stopTest();   
        
    } 
    
    @isTest
    static void testmethod35(){
        test.startTest();
        RecordType rT = [select id from recordtype where name = 'AMPS Financial' LIMIT 1];
        User newAgent = [SELECT id from User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User newSupport = [SELECT id from User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Contact con = [SELECT id from Contact LIMIT 1];
        Account acc = [SELECT id,Agency_Email__c,AAI_Agency_Reference_Code__c from Account WHERE Name = 'SFDC Account 1' LIMIT 1];
        System.debug('@@@Account -> '+ acc);
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        Case cs = new Case(Contact = con,
                           Account = acc,
                           ContactId = con.Id,
                           AccountId = acc.Id,
                           Status    = 'Risolto',
                           Origin    = 'Portale Assistenza',
                           OwnerId   = newSupport.Id,
                           User__c   = newAgent.Id,
                           Current_Owner_Queue__c = 'HD1',
                           LOB__c = 'Vita',
                           Category__c = 'Test',
                           RecordtypeId = rT.Id,
                           Agency_Code__c = 'Test');
        insert cs;
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            Id ownerId = support.id;
            attachmentList.clear();
            String output5  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,cs.id, 'Supporto', 1, attachmentList, '','Supporto HD1 IT','Supporto HD1 IT','',false,'','HD1_IT_AAI_VITA_LOL','VITA',ownerId);
            String output6  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,cs.id, 'Supporto', 1, attachmentList, '','Supporto HD1 IT','Supporto HD1 IT','',false,'','HD2_Modulo_di_Calcolo','VITA',ownerId);
        	String output7  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,cs.id, 'Supporto', 1, attachmentList, '','Supporto HD1 IT','Supporto HD1 IT','',false,'','Biz','VITA',ownerId);
        }
        test.stopTest();   
    }
    
    @isTest
    static void testmethod36(){
      
        RecordType rT = [select id from recordtype where name = 'AMPS Financial' LIMIT 1];
        User newAgent = [SELECT id from User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User newSupport = [SELECT id from User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Contact con = [SELECT id from Contact LIMIT 1];
        Account acc = [SELECT id,Agency_Email__c,AAI_Agency_Reference_Code__c from Account WHERE Name = 'SFDC Account 1' LIMIT 1];
        System.debug('@@@Account -> '+ acc);
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        Case cs = new Case(Contact = con,
                           Account = acc,
                           ContactId = con.Id,
                           AccountId = acc.Id,
                           Status    = 'Open',
                           Origin    = 'Portale Assistenza',
                           OwnerId   = newSupport.Id,
                           User__c   = newAgent.Id,
                           Current_Owner_Queue__c = 'HD2',
                           LOB__c = 'Vita',
                           Category__c = 'Test',
                           RecordtypeId = rT.Id,
                           Agency_Code__c = 'Test');
        insert cs;
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            Id ownerId = support.id;
            attachmentList.clear();
              test.startTest();
            String output5  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,cs.id, 'Agente', 1, attachmentList, '','Supporto Modulo di Calcolo','AAI - Supervisor Supporto HD2 BIZ','',false,'','HD1_IT_AAI_VITA_LOL','VITA',ownerId);
        	String output6  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,cs.id, 'Supporto', 1, attachmentList, '','Supporto Modulo di Calcolo','AAI - Supervisor Supporto HD2 BIZ','',false,'','HD1_IT_AAI_VITA_LOL','VITA',ownerId);
            String output7  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,cs.id, 'Supporto', 1, attachmentList, '','Supporto Modulo di Calcolo AXA','AAI - Supervisor Supporto HD2 BIZ','',false,'','HD1_IT_AAI_VITA_LOL','VITA',ownerId);
        	 test.stopTest();
        }
          
    }
    
    @isTest
    static void testmethod37(){
        
        RecordType rT = [select id from recordtype where name = 'AMPS Financial' LIMIT 1];
        User newAgent = [SELECT id from User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User newSupport = [SELECT id from User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Contact con = [SELECT id from Contact LIMIT 1];
        Account acc = [SELECT id,Agency_Email__c,AAI_Agency_Reference_Code__c from Account WHERE Name = 'SFDC Account 1' LIMIT 1];
        System.debug('@@@Account -> '+ acc);
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        Case cs = new Case(Contact = con,
                           Account = acc,
                           ContactId = con.Id,
                           AccountId = acc.Id,
                           Status    = 'Open',
                           Origin    = 'Portale Assistenza',
                           OwnerId   = newSupport.Id,
                           User__c   = newAgent.Id,
                           Current_Owner_Queue__c = 'HD2',
                           LOB__c = 'Vita',
                           Category__c = 'Test',
                           RecordtypeId = rT.Id,
                           Agency_Code__c = 'Test',
                           Last_Advisor__c = agent.Id,
                           supporto_mdc__c = true);
        insert cs;
        CaseTeamRole Ctr = [Select id,Name from CaseTeamRole where Name='HD1 IT'];
        CaseTeamMember cstm = new CaseTeamMember(ParentId = cs.Id,memberid = agent.Id, TeamRole = Ctr, TeamRoleId = Ctr.Id);
        insert cstm;
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            Id ownerId = support.id;
            attachmentList.clear();
            test.startTest();
            String output1  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,cs.id, 'Supporto', 1, attachmentList, '','Test','HD2 BIZ','MdC AXA',false,'','','VITA',ownerId);
            String output2  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,cs.id, 'Supporto', 1, attachmentList, '','Test','HD2 BIZ','RGI',false,'','','VITA',ownerId);
            String output3  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,cs.id, 'Supporto', 1, attachmentList, '','Test','HD2 BIZ','Test',false,'','','VITA',ownerId);
            test.stopTest();
        }
           
    }
    
    @isTest
    static void testmethod38(){
        test.startTest();
        RecordType rT = [select id from recordtype where name = 'Close the loop' LIMIT 1];
        User newAgent = [SELECT id from User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User newSupport = [SELECT id from User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Contact con = [SELECT id from Contact LIMIT 1];
        Account acc = [SELECT id,Agency_Email__c,AAI_Agency_Reference_Code__c from Account WHERE Name = 'SFDC Account 1' LIMIT 1];
        System.debug('@@@Account -> '+ acc);
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        Case cs = new Case(Contact = con,
                           Account = acc,
                           ContactId = con.Id,
                           AccountId = acc.Id,
                           Status    = 'Open',
                           Origin    = 'Portale Assistenza',
                           OwnerId   = newSupport.Id,
                           User__c   = newAgent.Id,
                           Current_Owner_Queue__c = 'HD2',
                           LOB__c = 'Vita',
                           Category__c = 'Test',
                           RecordtypeId = rT.Id,
                           Agency_Code__c = 'Test',
                           Last_Advisor__c = agent.Id,
                           supporto_mdc__c = true);
        insert cs;
        CaseTeamRole Ctr = [Select id,Name from CaseTeamRole where Name='HD1 IT'];
        CaseTeamMember cstm = new CaseTeamMember(ParentId = cs.Id,memberid = agent.Id, TeamRole = Ctr, TeamRoleId = Ctr.Id);
        insert cstm;
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            Id ownerId = support.id;
            attachmentList.clear();
            String output1  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,cs.id, 'Supporto', 1, attachmentList, '','Test','HD2 BIZ','MdC AXA',false,'','','VITA',ownerId);
        }
        test.stopTest();   
    }
    
    @isTest
    static void testmethod39(){
        test.startTest();
        RecordType rT = [select id from recordtype where name = 'Close the loop' LIMIT 1];
        User newAgent = [SELECT id from User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User newSupport = [SELECT id from User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Contact con = [SELECT id from Contact LIMIT 1];
        Account acc = [SELECT id,Agency_Email__c,AAI_Agency_Reference_Code__c from Account WHERE Name = 'SFDC Account 1' LIMIT 1];
        System.debug('@@@Account -> '+ acc);
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        List<Case> caseobj = [SELECT Id FROM Case LIMIT 3];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        Case cs = new Case(Contact = con,
                           Account = acc,
                           ContactId = con.Id,
                           AccountId = acc.Id,
                           Status    = 'Open',
                           Origin    = 'Portale Assistenza',
                           OwnerId   = newSupport.Id,
                           User__c   = newAgent.Id,
                           Current_Owner_Queue__c = 'HD2',
                           LOB__c = 'Vita',
                           Category__c = 'Test',
                           RecordtypeId = rT.Id,
                           Agency_Code__c = 'Test',
                           Last_Advisor__c = agent.Id,
                           supporto_mdc__c = true);
        insert cs;
        CaseTeamRole Ctr = [Select id,Name from CaseTeamRole where Name='HD1 IT'];
        CaseTeamMember cstm = new CaseTeamMember(ParentId = cs.Id,memberid = agent.Id, TeamRole = Ctr, TeamRoleId = Ctr.Id);
        insert cstm;
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            Id ownerId = support.id;
            attachmentList.clear();
            String output2  = SendCaseAutomaticQueueController.NewsaveCommentAttachment(comm,cs.id, 'Agente', 1, attachmentList, '','Test','HD2 BIZ','RGI',false,'','','VITA',ownerId);
        }
        test.stopTest();   
    }
}
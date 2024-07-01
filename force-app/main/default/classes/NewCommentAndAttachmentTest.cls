@isTest
public class NewCommentAndAttachmentTest {
    
    @testSetup static void setup() 
    {
        // AGENT
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name = 'NFE - AAI - Vendite Base'];
        Profile p;
        Id pAgent;
        if (profiles.size() > 0)
        {
            p      = profiles[0];
            pAgent = p.Id;
        }
        //MOSCATELLI 11/02/2019: Lob Contabilità -- START 
        MPS_Code_Variables__c Mcv = new MPS_Code_Variables__c(Name='Switch Notifica Storico Conversazione',Value__c='true');
        insert Mcv;
        //MOSCATELLI 11/02/2019: Lob Contabilità -- END

        Account acct = new Account(Name = 'SFDC Account 1');
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
        List<Profile> profiles2 = [SELECT Id, Name FROM Profile WHERE Name in  ('AAI - Supporto HD1 - Lightning','AAI - Supporto HD1 BIZ - Lightning','AAI - Supervisor Supporto HD1 Contabilità - Lightning','AAI - Supporto HD2', 'AAI - Supervisor Supporto HD1 Contabilita - Lightning')];
        Profile p2;
        Id pSupport;
        //MOSCATELLI 11/02/2019: Lob Contabilità -- START
        Id pSupportBiz;
        Id pSupportContabSuper;
        //VIZZINI 08/07/2018 Modulo di Calcolo
        Id pHd2;
        /*
        if (profiles2.size() > 0)
        {
            p2       = profiles2[0];
            pSupport = p2.Id;
        }
        */
        for(Profile ps:profiles2)
        {
            if(ps.Name =='AAI - Supporto HD1 - Lightning')
            {
                pSupport  = ps.Id;
            }
            else if(ps.Name =='AAI - Supervisor Supporto HD1 Contabilità - Lightning' ||ps.Name =='AAI - Supervisor Supporto HD1 Contabilita - Lightning' )
            {
                pSupportContabSuper = ps.Id;
            }
            //VIZZINI 08/07/2019 Modulo di Calcolo START
            else if(ps.Name == 'AAI - Supporto HD2'){
                pHd2 = ps.Id;
            }
            //VIZZINI 08/07/2019 Modulo di Calcolo END
            else 
            {
                pSupportBiz = ps.id;
            }
        }
        //MOSCATELLI 11/02/2019: Lob Contabilità -- END
        
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

        //MOSCATELLI 11/02/2019: Lob Contabilità -- START 
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

        //VIZZINI 08/07/2019 Modulo di Calcolo START
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
        //VIZZINI 08/07/2019 Modulo di Calcolo END

        List<Case> CaseList = new List<Case>();
        //MOSCATELLI 11/02/2019: Lob Contabilità -- END
        
        
        List<Case> caseToInsert = new List<Case>();//OAVERSANO 27/03/2019 : AXA Assistance
        Case caseObj1 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Attesa Info Agente',
                                 Origin    = 'Portale Assistenza',
                                 OwnerId   = newAgent.Id,
                                 User__c   = newAgent.Id);
        caseToInsert.add(caseObj1);//OAVERSANO 27/03/2019 : AXA Assistance
        
        Case caseObj2 = new Case(ContactId = conId2,
                                 AccountId = accId2,
                                 Status    = 'Assigned',
                                 Origin    = 'Portale Assistenza',
                                 OwnerId   = newSupport.Id,
                                 User__c   = newSupport.Id);
        caseToInsert.add(caseObj2);//OAVERSANO 27/03/2019 : AXA Assistance
        
        Case caseObj4 = new Case(ContactId = conId,
                                 AccountId = accId,
                                 Status    = 'Risolto',
                                 Origin    = 'Portale Assistenza',
                                 OwnerId   = newSupport.Id,
                                 User__c   = newAgent.Id);
        caseToInsert.add(caseObj4);

        //VIZZINI_D 27/06/2019: NMA - Lob Modulo di Calcolo - START
        Case defectCase = new Case(ContactId = conId2,
                                   AccountId = accId2,
                                   Status    = 'Assigned',
                                   Origin    = 'Portale Assistenza',
                                   OwnerId   = newSupport.Id,
                                   User__c   = newSupport.Id,
                                   Defect_Mdc__c = true);
        caseToInsert.add(defectCase);
        //VIZZINI_D 27/06/2019: NMA - Lob Modulo di Calcolo - END

        insert caseToInsert;//OAVERSANO 27/03/2019 : AXA Assistance
        
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
            insert t; 
            insert ContContenzSupportUsr;//MOSCATELLI 11/02/2019: Lob Contabilità
        }

        //VIZZINI_D 27/06/2019: NMA - Lob Modulo di Calcolo - START
        insert new MPS_Code_Variables__c(Name = 'HD2 RGI', value__c = 'RGI;');
        insert new MPS_Code_Variables__c(Name = 'MdC AXA', value__c = 'MdC AXA;');
        insert new MPS_Code_Variables__c(Name = 'BusinessHours_Default', value__c = '01m24000000Gxf5AAC');
        insert new MPS_Code_Variables__c(Name = 'ModuloDiCalcolo_tempiInoltroCoda', value__c = '1');
        //VIZZINI_D 27/06/2019: NMA - Lob Modulo di Calcolo - END
    
    }
    
    static testMethod void NewCommentAndAttachment() 
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
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
        
        
        
        System.runAs(agent)
        {
            NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
            
            String comm    = 'Commento di prova';
            String ident   = caseobj[0].Id;
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            String output  = NewCommentAndAttachmentServer.saveCommentAttachment(comm, ident, 'Agente', 1, attachmentList, url,'label','NFE - AAI - Vendite Base','',false, '');
            
            NewCommentAndAttachmentServer.CheckErrorResult check3 = NewCommentAndAttachmentServer.checkError(ident); 
        }
        
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id; 
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            attachmentList.clear();
            String output2 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, ident1, 'Agente', 0, attachmentList, url,'label','AAI - Supporto HD1','',false, '');
            
            Boolean check1 = NewCommentAndAttachmentServer.checkProfileSupportHD1(ident0);
            Boolean check2 = NewCommentAndAttachmentServer.checkProfileHD2();
            NewCommentAndAttachmentServer.CheckErrorResult check3 = NewCommentAndAttachmentServer.checkError(ident1);
            //String output3 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, url);
            
            /*Boolean check4 = NewCommentAndAttachmentServer.checkError(ident1);
            Boolean check5 = NewCommentAndAttachmentServer.checkError(ident2); */
        }
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            NewCommentAndAttachmentServer.ResponseDto r = NewCommentAndAttachmentServer.deleteAttachments(attachmentIds);
        }
        caseobj[0].RecordTypeId = RecordTypeUtility.getRecordTypeIdByDeveloperName('Case', 'Caring_Angel');
        update caseobj[0];
        NewCommentAndAttachmentServer.getMotivoTrasferimento(caseobj[0].Id);

        test.stopTest();   
          
    } 
   //OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz -- START
    static testMethod void NewCommentAndAttachment2() 
    {
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
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
        
        test.startTest();
        
        System.runAs(agent)
        {
            NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
            
            String comm    = 'Commento di prova';
            String ident   = caseobj[0].Id;
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            String output  = NewCommentAndAttachmentServer.saveCommentAttachment(comm, ident, 'Supporto', 1, attachmentList, url,'label','AAI - Supporto HD2 BIZ','Interni',false, '');
            
            NewCommentAndAttachmentServer.CheckErrorResult check3 = NewCommentAndAttachmentServer.checkError(ident); 
        }
           
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id; 
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            attachmentList.clear();
            String output2 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, url,'Supporto HD1 IT','AAI - Supporto HD1','',false, '');
            String output3 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, url,'Supporto HD1 BIZ','AAI - Supporto HD1','',false, '');
			
            /*
            //VIZZINI_D 05/07/2019: NMA - Lob Modulo di Calcolo - START
            String output4 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, url,'Supporto Modulo di Calcolo','AAI - Supporto HD1','',false, '');
            //VIZZINI_D 05/05/2019: NMA - Lob Modulo di Calcolo - END
            */

            Boolean check1 = NewCommentAndAttachmentServer.checkProfileSupportHD1(ident0);
            Boolean check2 = NewCommentAndAttachmentServer.checkProfileHD2();
            //NewCommentAndAttachmentServer.CheckErrorResult check3 = NewCommentAndAttachmentServer.checkError(ident1);
            //String output3 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, url);
            
            /*Boolean check4 = NewCommentAndAttachmentServer.checkError(ident1);
            Boolean check5 = NewCommentAndAttachmentServer.checkError(ident2); */
        }
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            NewCommentAndAttachmentServer.ResponseDto r = NewCommentAndAttachmentServer.deleteAttachments(attachmentIds);
        }

        test.stopTest();  
    } 
    static testMethod void NewCommentAndAttachment3() 
    {
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
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
        
        test.startTest();
        System.runAs(support)
        {
            String comm    = 'Commento di prova';
            String ident0  = caseobj[0].Id;
            String ident1  = caseobj[1].Id; 
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            attachmentList.clear();
           
			String output4 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, url,'Supporto HD2 IT','AAI - Supervisor Supporto HD2','',false, '');
            String output5 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, ident1, 'Supporto', 0, attachmentList, url,'Supporto HD2 IT','Caring Angel - Supporto HD1','',false, '');

            Boolean check1 = NewCommentAndAttachmentServer.checkProfileSupportHD1(ident0);
            Boolean check2 = NewCommentAndAttachmentServer.checkProfileHD2();
            Boolean check4 = NewCommentAndAttachmentServer.verificaProfiloAgente();
        }
        System.runAs(agent)
        {
            NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
            
            String comm    = 'Commento di prova';
            String ident   = caseobj[0].Id;
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            String output  = NewCommentAndAttachmentServer.saveCommentAttachment(comm, ident, 'Supporto', 1, attachmentList, url,'Supporto HD1 IT','AAI - Supporto HD1 BIZ','Interni',false, '');
            
            //VIZZINI_D 05/07/2019: NMA - Lob Modulo di Calcolo - START
            // String output2 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, ident, 'Supporto', 1, attachmentList, url,'Supporto Modulo di Calcolo','AAI - Supporto HD1 BIZ','Interni',false, '');
            //VIZZINI_D 05/05/2019: NMA - Lob Modulo di Calcolo - END

            //NewCommentAndAttachmentServer.CheckErrorResult check3 = NewCommentAndAttachmentServer.checkError(ident); 
        }
           
        
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            NewCommentAndAttachmentServer.ResponseDto r = NewCommentAndAttachmentServer.deleteAttachments(attachmentIds);
        }
        
        test.stopTest();  
    } 
    
    static testMethod void NewCommentAndAttachment4() 
    {
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Case caseobj = [SELECT Id, OwnerId FROM Case where status ='Risolto'];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
        CaseShare cs = new CaseShare();
        cs.CaseId = caseobj.Id;
        cs.UserOrGroupID = agent.Id;
        cs.CaseAccessLevel = 'Edit';
        cs.RowCause = 'Manual';
        insert cs;
        test.startTest();
        
        System.runAs(agent)
        {
            NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
            
            String comm    = 'Commento di prova';
            String ident   = caseobj.Id;
            NewCommentAndAttachmentServer.CheckErrorResult check3 = NewCommentAndAttachmentServer.checkError(ident); 
        }
           
        System.runAs(support)
        {
            String ident0  = caseobj.Id;
            NewCommentAndAttachmentServer.CurrentUser check2 = NewCommentAndAttachmentServer.checkProfileHD2_lightning();
            NewCommentAndAttachmentServer.CheckErrorResult check4 = NewCommentAndAttachmentServer.checkError(ident0); 
        }
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            String ident0  = caseobj.Id;
            NewCommentAndAttachmentServer.CurrentUser check2 = NewCommentAndAttachmentServer.checkProfileHD2_lightning();
            NewCommentAndAttachmentServer.CheckErrorResult check4 = NewCommentAndAttachmentServer.checkError(ident0); 
            NewCommentAndAttachmentServer.runQueryWOS qer = new NewCommentAndAttachmentServer.runQueryWOS();
            qer.getQueueEmail(caseobj);
        }
        
        test.stopTest();  
    } 
    
     static testMethod void NewCommentAndAttachment5() 
    {
        List<Profile> profiles2 = [SELECT Id, Name FROM Profile WHERE Name = 'AAI - Supporto HD2'];
         User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        Profile p2;
        Id pSupport;
        if (profiles2.size() > 0)
        {
            p2       = profiles2[0];
            pSupport = p2.Id;
        } 

        User newSupport = new User(Username                     = 'supporto2@axa.test.com',
                                   LastName                     = 'testuser22',
                                   LanguageLocaleKey            = 'it',
                                   FirstName                    = 'test22',
                                   Email                        = 'test22@test.com', 
                                   Alias                        = 'test22',
                                   TimeZoneSidKey               = 'Europe/Dublin',
                                   LocaleSidKey                 = 'it_IT',
                                   EmailEncodingKey             = 'UTF-8',
                                   ProfileId                    = pSupport,
                                   UserPermissionsKnowledgeUser = true);
        insert newSupport;
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact currentCnt = [SELECT Id FROM Contact LIMIT 1];
        Case caseobj = [SELECT Id, OwnerId FROM Case where status ='Risolto'];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
        
        test.startTest();
        Case caseObj4 = new Case(ContactId = currentCnt.Id,
                                 AccountId = currentAcc.Id,
                                 Status    = 'Risolto',
                                 Origin    = 'Portale Assistenza',
                                 OwnerId   = newSupport.Id,
                                 User__c   = agent.Id);
        insert caseObj4; 
        
        System.runAs(newSupport)
        {
            
            String ident0  = caseObj4.Id;
            NewCommentAndAttachmentServer.CurrentUser check2 = NewCommentAndAttachmentServer.checkProfileHD2_lightning();
            NewCommentAndAttachmentServer.CheckErrorResult check4 = NewCommentAndAttachmentServer.checkError(ident0); 
        }
        
        test.stopTest();  
    } 
    //OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz -- END
    
    //OAVERSANO 27/11/2018 : ICF Close The Loop -- START
    static testMethod void NewCommentAndAttachment6() 
    {
        List<Profile> profiles2 = [SELECT Id, Name FROM Profile WHERE Name = 'SmartCenter AMF Advisor - Lightning'];
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];
        Profile p2;
        Id pSupport;
        if (profiles2.size() > 0)
        {
            p2       = profiles2[0];
            pSupport = p2.Id;
        } 

        User newSupport = new User(Username                     = 'supporto2@axa.test.com',
                                   LastName                     = 'testuser22',
                                   LanguageLocaleKey            = 'it',
                                   FirstName                    = 'test22',
                                   Email                        = 'test22@test.com', 
                                   Alias                        = 'test22',
                                   TimeZoneSidKey               = 'Europe/Dublin',
                                   LocaleSidKey                 = 'it_IT',
                                   EmailEncodingKey             = 'UTF-8',
                                   ProfileId                    = pSupport,
                                   UserPermissionsKnowledgeUser = true);
        insert newSupport;
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        Contact currentCnt = [SELECT Id FROM Contact LIMIT 1];
        Case caseobj = [SELECT Id, OwnerId FROM Case where status ='Risolto'];
        Id aId             = [SELECT Id FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Id;
        String aName       = [SELECT Name FROM Attachment WHERE Name = 'test.txt' LIMIT 1].Name;
        List<String> attachmentIds  = new List<String>();
        List<String> attachmentList = new List<String>();
        attachmentIds.add(aId);
        attachmentList.add(aName);
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
        
        test.startTest();
        Case caseObj4 = new Case(ContactId = currentCnt.Id,
                                 AccountId = currentAcc.Id,
                                 Status    = 'Risolto',
                                 Origin    = 'Portale Assistenza',
                                 OwnerId   = newSupport.Id,
                                 Agency_Code__c = '00828',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Close the loop').getRecordTypeId());
        insert caseObj4; 
        
        System.runAs(newSupport)
        {
            
            String ident0  = caseObj4.Id;
            NewCommentAndAttachmentServer.CurrentUser check2 = NewCommentAndAttachmentServer.checkProfileHD2_lightning();
            NewCommentAndAttachmentServer.CheckErrorResult check4 = NewCommentAndAttachmentServer.checkError(ident0); 
            String output5 = NewCommentAndAttachmentServer.saveCommentAttachment('mm', ident0, 'Supporto', 0, attachmentList, 'mm','Agente','NFE - AAI - Vendite Avanzato','',false, '');
        }
        
        test.stopTest();  
    } 
    //OAVERSANO 27/11/2018 : ICF Close The Loop -- END




    //MOSCATELLI 11/02/2019: Lob Contabilità -- START 
    static testMethod void NewCommentAndAttachment7() 
    {
        User supportConta       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto3@axa.test.com' LIMIT 1];
        
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        User agent = [Select id from User where UserName = 'agente@axa.test.com'];

        List<String> attachmentList = new List<String>();
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
        
        test.startTest();
        Case cas = new Case( Status    = 'Assigned',
                             Origin    = 'Chat',
                             OwnerId   = supportConta.Id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        insert cas;       
        
        System.runAs(supportConta)
        {
            NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
            
            String comm    = 'Commento di prova';
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            String output  = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto Contenzioso','AAI - Supporto HD1','HD1 Contabilita',false, '');
        }    
        
        test.stopTest();  
    } 

    static testMethod void NewCommentAndAttachment8() 
    {
        User supportConenz      = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto4@axa.test.com' LIMIT 1];      
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        User agent = [Select id from User where UserName = 'agente@axa.test.com'];

        List<String> attachmentList = new List<String>();
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
        
        test.startTest();
        Case cas = new Case(AccountId = currentAcc.id,
                             Status    = 'Assigned',
                             Origin    = 'Chat',
                             OwnerId   = supportConenz.Id,
                             User__c   = agent.Id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        insert cas;        
           
        System.runAs(supportConenz)
        {
            NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
            
            String comm    = 'Commento di prova';
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            String output2 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto Contabilità','AAI - Supporto HD1','HD1 Contenzioso',false, '');
        }
        
        test.stopTest();  
    }

    static testMethod void NewCommentAndAttachment9() 
    {
        User supportConenz      = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto4@axa.test.com' LIMIT 1];      
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        User agent = [Select id from User where UserName = 'agente@axa.test.com'];

        List<String> attachmentList = new List<String>();
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
        
        test.startTest();
        Case cas = new Case(AccountId = currentAcc.id,
                             Status    = 'Assigned',
                             Origin    = 'Chat',
                             OwnerId   = supportConenz.Id,
                             User__c   = agent.Id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        insert cas;        
           
        System.runAs(supportConenz)
        {
            NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
            
            String comm    = 'Commento di prova';
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            String output2 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto HD1 IT','AAI - Supporto HD1','HD1 Contenzioso',false, '');
        }
        
        test.stopTest();  
    }

    static testMethod void NewCommentAndAttachment10() 
    {
        User supportConenz      = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto4@axa.test.com' LIMIT 1];      
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        User agent = [Select id from User where UserName = 'agente@axa.test.com'];

        List<String> attachmentList = new List<String>();
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
        
        test.startTest();
        Case cas = new Case(AccountId = currentAcc.id,
                             Status    = 'Assigned',
                             Origin    = 'Chat',
                             OwnerId   = supportConenz.Id,
                             User__c   = agent.Id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        insert cas;        
           
        System.runAs(supportConenz)
        {
            NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
            
            String comm    = 'Commento di prova';
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            String output2 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto HD1 BIZ','AAI - Supporto HD1','HD1 Contenzioso',false, '');
        }
        
        test.stopTest();  
    }      
   

    static testMethod void NewCommentAndAttachment11() 
    {
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        User agent = [Select id from User where UserName = 'agente@axa.test.com'];

        List<String> attachmentList = new List<String>();
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
        
        test.startTest();
        Case cas = new Case(AccountId = currentAcc.id,
                             Status    = 'Assigned',
                             Origin    = 'Chat',
                             OwnerId   = support.id,
                             User__c   = agent.Id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        insert cas;        
           
        System.runAs(support)
        {
            NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
            
            String comm    = 'Commento di prova';
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            String output2 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto Contabilità','AAI - Supporto HD1','HD1',false, '');
        }
        
        test.stopTest();  
    } 

    static testMethod void NewCommentAndAttachment12() 
    {
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        User agent = [Select id from User where UserName = 'agente@axa.test.com'];

        List<String> attachmentList = new List<String>();
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
        
        test.startTest();
        Case cas = new Case(AccountId = currentAcc.id,
                             Status    = 'Assigned',
                             Origin    = 'Chat',
                             OwnerId   = support.id,
                             User__c   = agent.Id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        insert cas;        
           
        System.runAs(support)
        {
            NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
            
            String comm    = 'Commento di prova';
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            String output2 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto Contenzioso','AAI - Supporto HD1','HD1',false, '');
        }
        
        test.stopTest();  
    }


    static testMethod void NewCommentAndAttachment13() 
    {
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supportobiz@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        User agent = [Select id from User where UserName = 'agente@axa.test.com'];

        List<String> attachmentList = new List<String>();
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
        
        test.startTest();
        Case cas = new Case(AccountId = currentAcc.id,
                             Status    = 'Assigned',
                             Origin    = 'Chat',
                             OwnerId   = support.id,
                             User__c   = agent.Id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        insert cas;        
           
        System.runAs(support)
        {
            NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
            
            String comm    = 'Commento di prova';
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            String output2 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto Contabilità','AAI - Supporto HD1','HD1',false, '');
        }
        
        test.stopTest();  
    } 

    static testMethod void NewCommentAndAttachment14() 
    {
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supportobiz@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        User agent = [Select id from User where UserName = 'agente@axa.test.com'];

        List<String> attachmentList = new List<String>();
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
        
        test.startTest();
        Case cas = new Case(AccountId = currentAcc.id,
                             Status    = 'Assigned',
                             Origin    = 'Chat',
                             OwnerId   = support.id,
                             User__c   = agent.Id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        insert cas;        
           
        System.runAs(support)
        {
            NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
            
            String comm    = 'Commento di prova';
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            String output2 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto Contenzioso','AAI - Supporto HD1 BIZ','HD1 BIZ',false, '');
        }
        
        test.stopTest();  
    } 

    static testMethod void NewCommentAndAttachment15() 
    {
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supportobiz@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        User agent = [Select id from User where UserName = 'agente@axa.test.com'];

        List<String> attachmentList = new List<String>();
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
        
        test.startTest();
        Case cas = new Case(AccountId = currentAcc.id,
                             Status    = 'Assigned',
                             Origin    = 'Chat',
                             OwnerId   = support.id,
                             User__c   = agent.Id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        insert cas;        
           
        System.runAs(support)
        {
            NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
            
            String comm    = 'Commento di prova';
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            String output2 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto Contabilità','AAI - Supporto HD1 BIZ','HD1 BIZ',false, '');
        }
        
        test.stopTest();  
    }      

    static testMethod void NewCommentAndAttachment16() 
    {
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supportobiz@axa.test.com' LIMIT 1];
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];        
        User supportConenz = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto4@axa.test.com' LIMIT 1];      
        CaseTeamRole Ctr = [Select id from CaseTeamRole where Name='HD1 Contenzioso'];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];

        List<String> attachmentList = new List<String>();
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
        
        test.startTest();
        Case cas = new Case(
                             Status    = 'Assigned',
                             Origin    = 'Chat',
                             OwnerId   = support.id,
                             User__c   = agent.Id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        insert cas;

        CaseTeamMember Ctm = new CaseTeamMember(MemberId=supportConenz.id,parentid=cas.id,TeamRoleid=Ctr.id); 
        insert Ctm;       
           

        NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
        
        String comm    = 'Commento di prova';
        String url     = NewCommentAndAttachmentServer.getOrgURL();
        String output2 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Agente', 0, attachmentList, url,'','NFE - AAI - Vendite Base','',false, '');
        
        
        test.stopTest();  
    }       

    static testMethod void NewCommentAndAttachment17() 
    {
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supportcontabSuperv@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];        

        List<String> attachmentList = new List<String>();
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
         test.startTest();
		Case cas = new Case(
                             Status    = 'Assigned',
                             Origin    = 'Chat',
                             OwnerId   = support.id,
                             User__c   = agent.Id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        insert cas;        

        NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
        
        String comm    = 'Commento di prova';
        String url     = NewCommentAndAttachmentServer.getOrgURL();
        String output2 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto HD1 IT','AAI - Supervisor Supporto HD1 Contabilità','Assistenza Agenti - HD1',false, '');
                
        //String output3 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto HD1 BIZ','AAI - Supervisor Supporto HD1 Contabilità','Assistenza Agenti - HD1',false, '');
        
        //VIZZINI_D 05/07/2019: NMA - Lob Modulo di Calcolo - START
        //String output4 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto Modulo di Calcolo','AAI - Supervisor Supporto HD1 Contabilità','Assistenza Agenti - HD1',false, '');
        //VIZZINI_D 05/05/2019: NMA - Lob Modulo di Calcolo - END

        test.stopTest();  
    }
    
     static testMethod void NewCommentAndAttachment17bis() 
    {
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supportcontabSuperv@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];        

        List<String> attachmentList = new List<String>();
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
         
		Case cas = new Case(
                             Status    = 'Assigned',
                             Origin    = 'Chat',
                             OwnerId   = support.id,
                             User__c   = agent.Id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        insert cas;        

        NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
        
        String comm    = 'Commento di prova';
        String url     = NewCommentAndAttachmentServer.getOrgURL();
        test.startTest();
       // String output2 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto HD1 IT','AAI - Supervisor Supporto HD1 Contabilità','Assistenza Agenti - HD1',false, '');
                
        String output3 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto HD1 BIZ','AAI - Supervisor Supporto HD1 Contabilità','Assistenza Agenti - HD1',false, '');
        
        //VIZZINI_D 05/07/2019: NMA - Lob Modulo di Calcolo - START
        String output4 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto Modulo di Calcolo','AAI - Supervisor Supporto HD1 Contabilità','Assistenza Agenti - HD1',false, '');
        //VIZZINI_D 05/05/2019: NMA - Lob Modulo di Calcolo - END

        test.stopTest();  
    }

    static testMethod void NewCommentAndAttachment18() 
    {
        User support       = [SELECT Id, ProfileId FROM User WHERE Username = 'supportcontabSuperv@axa.test.com' LIMIT 1];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        User agent         = [SELECT Id, ProfileId FROM User WHERE Username = 'agente@axa.test.com' LIMIT 1];        

        List<String> attachmentList = new List<String>();
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();
        
        test.startTest();
        Case cas = new Case(
                             Status    = 'Assigned',
                             Origin    = 'Chat',
                             OwnerId   = support.id,
                             User__c   = agent.Id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        insert cas;        

        NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
        
        String comm    = 'Commento di prova';
        String url     = NewCommentAndAttachmentServer.getOrgURL();
        String output4 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto Contabilità','AAI - Supervisor Supporto HD1 Contabilità','Assistenza Agenti - HD1',false, '');
        String output5 = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto Contenzioso','AAI - Supervisor Supporto HD1 Contabilità','Assistenza Agenti - HD1',false, '');
        
        test.stopTest();  
    }                  
    //MOSCATELLI 11/02/2019: Lob Contabilità -- END

    //VIZZINI_D 05/07/2019: NMA - Lob Modulo di Calcolo - START
    static testMethod void NewCommentAndAttachment19(){
        
        //User rgi = [SELECT Id, Name FROM User WHERE UserRole.Name = 'RGI' AND isActive = true LIMIT 1];
        //User reply = [SELECT Id, Name FROM User WHERE UserRole.Name = 'Reply' AND isActive = true LIMIT 1];

        test.startTest();

        //System.runAs(rgi){
            Boolean isRgi = NewCommentAndAttachmentServer.checkProfileRoleHD2_RGI();
           // System.assertEquals(true,isRgi);
        //}

        //System.runAs(reply){
            Boolean isReply = NewCommentAndAttachmentServer.checkProfileRoleHD2_RGI();
           // System.assertEquals(false,isReply);
        //}

        test.stopTest();
    }

    static testMethod void NewCommentAndAttachment20(){

        Case defectCase = [SELECT Id FROM Case WHERE Defect_Mdc__c = true LIMIT 1];
         
        test.startTest();
        
        Boolean isDefectCase = NewCommentAndAttachmentServer.getDefectMdC(defectCase.Id);
        //System.assertEquals(true,isDefectCase);

        test.stopTest();
    }
    //VIZZINI_D 05/07/2019: NMA - Lob Modulo di Calcolo - END

    //VIZZINI_D 08/07/2019: NMA - Lob Modulo di Calcolo - START
    static testMethod void NewCommentAndAttachment21(){
        
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

        //System.runAs(supportRGI)
        //{
            NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
            
            String comm    = 'Commento di prova';
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            String output  = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto Modulo di Calcolo AXA','AAI - Supporto HD2','RGI',false, '');
            
       // }

    }

    static testMethod void NewCommentAndAttachment22(){
        
        

        User support = [SELECT Id, ProfileId FROM User WHERE Username = 'supportobiz@axa.test.com' AND isActive = true LIMIT 1];
        User support_it = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' AND isActive = true LIMIT 1];        
        User supportMdCAXA = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto5@axa.test.com' AND isActive = true LIMIT 1];  
        User supportRGI = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto6@axa.test.com' AND isActive = true LIMIT 1];      
        CaseTeamRole Ctr = [Select id from CaseTeamRole where Name='HD2 IT'];
        CaseTeamRole Ctr_biz = [Select id from CaseTeamRole where Name='HD1 BIZ'];
        CaseTeamRole Ctr_it = [Select id from CaseTeamRole where Name='HD1 IT'];
        Account currentAcc = [SELECT Id FROM Account LIMIT 1];

        List<String> attachmentList = new List<String>();
        
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);
        
        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();

        List<Case> testCases = new List<Case>();
        Case cas = new Case(
                             Status    = 'In gestione specialistica Ufficio tecnico',
                             Origin    = 'Chat',
                             OwnerId   = supportMdCAXA.id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        testCases.add(cas);
        Case cas2 = new Case(
                             Status    = 'In gestione specialistica Ufficio tecnico',
                             Origin    = 'Chat',
                             OwnerId   = supportMdCAXA.id,
                             Last_Advisor__c = support.Id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        testCases.add(cas2);
        Case cas3 = new Case(
                             Status    = 'In gestione specialistica Ufficio tecnico',
                             Origin    = 'Chat',
                             OwnerId   = supportMdCAXA.id,
                             Last_Advisor__c = support_it.Id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        testCases.add(cas3);
        insert testCases;

        List<CaseTeamMember> ctms = new List<CaseTeamMember>();

        CaseTeamMember ctm_hd1_biz_2 = new CaseTeamMember(MemberId=support.id,parentid=cas2.id,TeamRoleid=Ctr_biz.id);
        ctms.add(ctm_hd1_biz_2);
        CaseTeamMember ctm_rgi_2 = new CaseTeamMember(MemberId=supportRGI.id,parentid=cas2.id,TeamRoleid=Ctr.id);
        ctms.add(ctm_rgi_2); 
        CaseTeamMember ctm_mdc_axa_2 = new CaseTeamMember(MemberId=supportMdCAXA.id,parentid=cas2.id,TeamRoleid=Ctr.id);
        ctms.add(ctm_mdc_axa_2); 

        CaseTeamMember ctm_hd1_it_3 = new CaseTeamMember(MemberId=support_it.id,parentid=cas3.id,TeamRoleid=Ctr_it.id);
        ctms.add(ctm_hd1_it_3);
        CaseTeamMember ctm_rgi_3 = new CaseTeamMember(MemberId=supportRGI.id,parentid=cas3.id,TeamRoleid=Ctr.id);
        ctms.add(ctm_rgi_3); 
        CaseTeamMember ctm_mdc_axa_3 = new CaseTeamMember(MemberId=supportMdCAXA.id,parentid=cas3.id,TeamRoleid=Ctr.id);
        ctms.add(ctm_mdc_axa_3); 
        
        CaseTeamMember ctm_rgi = new CaseTeamMember(MemberId=supportRGI.id,parentid=cas.id,TeamRoleid=Ctr.id);
        ctms.add(ctm_rgi); 
        CaseTeamMember ctm_mdc_axa = new CaseTeamMember(MemberId=supportMdCAXA.id,parentid=cas.id,TeamRoleid=Ctr.id);
        ctms.add(ctm_mdc_axa); 
        insert ctms;       
           
        test.startTest();

       // System.runAs(supportMdCAXA){

            NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
            
            String comm    = 'Commento di prova';
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            
            String output  = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Agente', 0, attachmentList, url,'Supporto Modulo di Calcolo','AAI - Supporto HD2','MdC AXA',false, '');
            String outpu2  = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas2.id, 'Agente', 0, attachmentList, url,'Supporto HD1','AAI - Supporto HD2','MdC AXA',false, '');
            String outpu3  = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas3.id, 'Agente', 0, attachmentList, url,'Supporto HD1','AAI - Supporto HD2','MdC AXA',false, '');
            
        //}

        test.stopTest(); 
    }

    static testMethod void NewCommentAndAttachment23(){

        List<String> attachmentList = new List<String>();

        User support_it = [SELECT Id, ProfileId FROM User WHERE Username = 'supporto@axa.test.com' AND isActive = true LIMIT 1];
        User agentHD2 = [SELECT Id, ProfileId FROM User WHERE Username = 'hd2agent@axa.test.com' AND isActive = true LIMIT 1];

        List<Case> testCases = new List<Case>();
        Case cas = new Case(
                             Status    = 'Assigned',
                             Origin    = 'Chat',
                             OwnerId   = support_it.id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        testCases.add(cas);
        Case cas2 = new Case(
                             Status    = 'Assigned',
                             Origin    = 'Phone',
                             OwnerId   = agentHD2.id,
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        testCases.add(cas2);
        insert testCases;

        Account currentAcc = [SELECT Id FROM Account LIMIT 1];
        ApexPages.StandardController stcctrl = new ApexPages.StandardController(currentAcc);

        NewCommentAndAttachmentServer.ResponseDto rdtoexample = new NewCommentAndAttachmentServer.ResponseDto();

         test.startTest();

       /* System.runAs(support_it){
            
            NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
            
            String comm    = 'Commento di prova';
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            
            String output  = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas.id, 'Supporto', 0, attachmentList, url,'Supporto Modulo di Calcolo','AAI - Supporto HD1','HD1',false, '');
            
       }

        System.runAs(agentHD2){
            
            NewCommentAndAttachmentServer testClass = new NewCommentAndAttachmentServer(stcctrl);
            
            String comm    = 'Commento di prova';
            String url     = NewCommentAndAttachmentServer.getOrgURL();
            
            String output  = NewCommentAndAttachmentServer.saveCommentAttachment(comm, cas2.id, 'Agente', 0, attachmentList, url,'Supporto Modulo di Calcolo','AAI - Supporto HD2','Interni',false, '');
            
        }*/

        test.stopTest();
    }
    
     static testMethod void NewCommentAndAttachment24(){
         
        Case cas = new Case(
                             Status    = 'Assigned',
                             Origin    = 'Chat',
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        insert cas;
        Case c = [SELECT ID, Status, Origin FROM Case WHERE Status = 'Assigned' AND Origin = 'Chat' LIMIT 1];
        Test.startTest();
        NewCommentAndAttachmentServer.checkVisibilitiesButtonsSendSupport(c.Id, 'GTI');
                  
     }
    //VIZZINI_D 08/07/2019: NMA - Lob Modulo di Calcolo - END    
         static testMethod void NewCommentAndAttachment25(){
         
        Case cas = new Case(
                             Status    = 'Assigned',
                             Origin    = 'Chat',
            				 Current_Owner_Queue__c = 'HD1_Instant_payment',
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        insert cas;
        Case c = [SELECT ID, Status, Origin FROM Case WHERE Current_Owner_Queue__c = 'HD1_Instant_payment' AND Status = 'Assigned' AND Origin = 'Chat' LIMIT 1];
        Test.startTest();
        NewCommentAndAttachmentServer.checkVisibilitiesButtonsSendSupport(c.Id, 'GTI');
                  
     }
    
             static testMethod void NewCommentAndAttachment26(){
         
        Case cas = new Case(
                             Status    = 'Assigned',
                             Origin    = 'Chat',
            				 Current_Owner_Queue__c = 'HD2_Instant_payment',
                             RecordTypeId = (Ap_Constants.getDeveloperIdMap('Case')).get('Assistenza_Agenti'));
        insert cas;
        Case c = [SELECT ID, Status, Origin FROM Case WHERE Current_Owner_Queue__c = 'HD2_Instant_payment' AND Status = 'Assigned' AND Origin = 'Chat' LIMIT 1];
        Test.startTest();
        NewCommentAndAttachmentServer.checkVisibilitiesButtonsSendSupport(c.Id, 'GTI');
                  
     }
    
        static testMethod void NewCommentAndAttachment27() 
    {
       // Specify the object type and field you want to test
       String objectType = 'Case';
       String selectedField = 'Concordato__c';
       // Create a test case record with the required fields
       Case testCase = new Case(Concordato__c = 'SI'); 
       insert testCase;
       Test.startTest();
       // Call the method you want to test
       List<String> pickListValues = NewCommentAndAttachmentServer.getPickListValuesIntoList(objectType, selectedField);
       // Add assertions based on your expected picklist values
       System.assertNotEquals(0, pickListValues.size(), 'Picklist values should not be empty for ' + selectedField);
       // Add assertions to cover specific picklist values
       System.assertEquals('SI', pickListValues[0], 'First picklist value does not match');
       // Add more assertions for additional picklist values
       Test.stopTest();
    } 

        static testMethod void NewCommentAndAttachment28() 
    {    
           Test.startTest();
       // Create a test user with the desired profile and role
       Profile testProfile = [SELECT Id FROM Profile WHERE Name LIKE '%HD2%' LIMIT 1]; 
       UserRole testRole = [SELECT Id FROM UserRole WHERE Name = 'MdC AXA' LIMIT 1]; 
       User testUser = new User(
           ProfileId = testProfile.Id,
           UserRoleId = testRole.Id,
           Username = 'username_test@axa.test.com',
           LastName = 'testuser',
           LanguageLocaleKey = 'it',
           FirstName = 'test',
           Email = 'test@test.com', 
           Alias = 'test',
           TimeZoneSidKey = 'Europe/Dublin',
           LocaleSidKey = 'it_IT',
           EmailEncodingKey = 'UTF-8'
       );
       insert testUser;
       System.runAs(testUser) {
           // Method da testare
           Boolean result = NewCommentAndAttachmentServer.checkProfileRoleHD2_MDCAXA();
          
           System.assertEquals(true, result, 'User should have HD2 profile and MdC AXA role');
           Test.stopTest();
       }
        
        
    }      

}
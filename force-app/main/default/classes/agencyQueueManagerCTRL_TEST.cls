@isTest
public class agencyQueueManagerCTRL_TEST {

  @testSetup static void setup()
    {
      //Retrieving informations about profiles and roles
        list<Profile> profiles = [SELECT Id,Name FROM Profile WHERE Name in ('NFE - AAI - Vendite Avanzato','System Administrator','NFE - AAI - Vendite Base') ]; 
        Profile pvenditeA;
        Profile sadmin;
        Profile pvenditeB;

        for (Profile p :profiles){
            if (p.Name=='NFE - AAI - Vendite Avanzato')
            {
                pvenditeA=p;
            }
            else if (p.Name=='System Administrator')
            {
                sadmin=p;
            }
            else if (p.Name=='NFE - AAI - Vendite Base')
            {
                pvenditeB=p;
            }
        }
        Id pVenA = pvenditeA.Id;
        Id pVenB = pvenditeB.Id; 
        Id pSadmin =  sadmin.Id;

        UserRole roleA = [SELECT Id FROM UserRole where Name = 'AXA Assicurazioni'];
        UserRole roleB = [SELECT Id FROM UserRole WHERE Name = 'BERGAMO Responsabile Partner'  LIMIT 1];
        UserRole roleC = [SELECT Id FROM UserRole WHERE Name = 'BERGAMO Utente Partner' LIMIT 1];
        system.debug('-------------'+roleB);
        Id pRolA = roleA.Id;
        Id pRolB = roleB.Id;
        Id pRolC = roleC.Id;

        //Creating the Admin user
        User userAdmin = new User(Username = 'adminagencyq@axa.test.com',
                            LastName = 'testuser',
                            LanguageLocaleKey = 'en_US',
                            FirstName = 'test',
                            Email = 'test@test.com',
                            Alias = 'test',
                            TimeZoneSidKey = 'Europe/Dublin',
                            LocaleSidKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            ProfileId = pSadmin,
                            UserRoleId = pRolA,
                            UserPermissionsKnowledgeUser=true);
        insert userAdmin;

        System.runAs(userAdmin)
        {
          //Retrieving Record Types for Contacts and Accounts
          Map<string,Map<string,string>> rtypes = UtilityClass.fetchAllRTypes();
          id contact_agency = UtilityClass.getRTid(rtypes, 'Contact', 'Agency_Contact');
          id account_agency = UtilityClass.getRTid(rtypes, 'Account', 'Agency');

          //Creating the Agency Accounts with the relative Contacts
          List<Account> agencyList = new List<Account>
          {
              new Account(
                          RecordTypeId = account_agency,
                          Agency_Code__c = '999999',
                          Active__c = true,
                          Accordo_Digitale__c = true,
                          Name = 'AGENZIA PROVA'
                          )  
          };

          insert agencyList;
          agencyList[0].isPartner =true;
          update agencyList;
              
          List<Contact> contactList = new List<Contact> 
          {          
              
               new Contact(LastName = 'Agency Test Contact 1',
                           RecordtypeId = contact_agency,
                           AccountId = agencyList[0].Id
                           ),

               new Contact(LastName = 'Agency Test Contact 2',
                           RecordtypeId = contact_agency,
                           AccountId = agencyList[0].Id
                           )
          };

          insert contactList;

          //Creating the Agency users
          list<User> usrToIn = new list<User>
          {
        new User(FirstName='Marzia',
                      LastName = 'Rossi', 
                      Alias = 'mro666', 
                      Email = 'mrosskmans@deloitte.com', 
                      Username = 'agency1User828@axa.com.masterdev3', 
                      CommunityNickname = 'MarziRo', 
                      LanguageLocaleKey = 'en_US',
                      TimeZoneSidKey='Europe/Rome',
                      Agency_Code__c = '999999',
                      Nodes__c = 'DIF_999999',
                      Profileid = pVenA,
                     // userRoleId =pRolB,
                      LocaleSidKey='en_US',
                      EmailEncodingKey='ISO-8859-1',
                      ContactId = contactList[0].Id
                      ),

        new User(FirstName='Rossia',
                      LastName = 'Marzi', 
                      Alias = 'mro667', 
                      Email = 'mrosskmans@deloitte.com', 
                      Username = 'agency2User828@axa.com.masterdev3', 
                      CommunityNickname = 'RoMarzi', 
                      LanguageLocaleKey = 'en_US',
                      TimeZoneSidKey='Europe/Rome',
                      Agency_Code__c = '999999',
                      Nodes__c = 'DIF_999999',
                      Profileid = pVenB,
                      //userRoleId =pRolc,
                      LocaleSidKey='en_US',
                      EmailEncodingKey='ISO-8859-1',
                      ContactId = contactList[1].Id
                      )
      };
          
          insert usrToIn;
           UserRole roleAfter = [SELECT Id FROM UserRole WHERE Name = 'AGENZIA PROVA Responsabile Partner' order by ID desc LIMIT 1];
          usrToIn[0].userRoleId = roleAfter.Id;
          update usrToIn;
          system.debug ('********usrToIn'+usrToIn[0]);

        //Insert custom settings
        List<AAI_Code_Variables__c> customSetting = new List<AAI_Code_Variables__c>
        {
          new AAI_Code_Variables__c(Name= 'AdminAgencyCode', Value__c = '999999'),
        new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId())
      };

      insert customSetting;

          Apex_Schedulation_Manager__c ASM_CS= new Apex_Schedulation_Manager__c(Name='BulkRequestManager',
                                              Autoschedule__c=true,
                                              Expression__c='',
                                              Frequency__c=1,
                                              Scope__c=200,
                                              Send_Log__c=false
                                            );      
          insert ASM_CS;

            Group queue999999 = new Group(Name = 'Coda Agenzia 999999',
                                            DeveloperName = 'Coda_Agenzia_999999',
                                            Type = 'Queue'
                                            ); 
            insert queue999999;

            GroupMember g1 = new GroupMember(GroupId = queue999999.Id,
                                            UserOrGroupId = usrToIn[0].Id);
            insert g1;

            GroupMember g2 = new GroupMember(GroupId = queue999999.Id,
                                            UserOrGroupId = usrToIn[1].Id);
            insert g2;
      }
    }


    //Failure because of missing permissions
    @isTest static void test_method_1()
    {
      User agencyBaseUser = [SELECT Id, Profile.Name, UserRole.Name, Nodes_tree__c, Agency_code__c, Nodes__c FROM User WHERE Username = 'agency2User828@axa.com.masterdev3'];
      System.runAs(agencyBaseUser)
        {
          agencyQueueManagerUtilities.ResponseDto outcome = agencyQueueManagerCTRL.getAgencyUsers('Lead');
          System.assertEquals(outcome.message, 'Unauthorized user');
        }
    }

    //Success
    @isTest static void test_method_2()
    {
      User agencyUser = [SELECT Id, Profile.Name, UserRole.Name, Nodes_tree__c, Agency_code__c, Nodes__c FROM User WHERE Username = 'agency1User828@axa.com.masterdev3'];
      User adminUser = [SELECT Id, Profile.Name, UserRole.Name, Nodes_tree__c, Agency_code__c, Nodes__c FROM User WHERE Username = 'adminagencyq@axa.test.com'];
      system.debug('******agencyUser'+agencyUser);
      UserRole roleA = [SELECT Id,Name FROM UserRole where Id = :agencyUser.UserRoleId];
      system.debug('******roleA '+roleA );
      String queueName = 'Coda Agenzia '+agencyUser.Agency_Code__c;
      Id queueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: queueName LIMIT 1].Id;

      List<Boolean> checkList = new List<Boolean>();
      Boolean check1 = true;
      Boolean check2 = false;
      checkList.add(check1);
      checkList.add(check2);
      List<User> listUser = new List<User>();
      Integer queueSize;

        List<GroupMember> queueUsers = [SELECT Id,UserOrGroupId FROM GroupMember WHERE GroupId =: queueId];
        queueSize = queueUsers.size();
      
        System.runAs(agencyUser)
        {
            Test.startTest();

          agencyQueueManagerCTRL ctrl = new agencyQueueManagerCTRL();
          
          agencyQueueManagerUtilities.ResponseDto outcome = agencyQueueManagerCTRL.getAgencyUsers('Lead');
          System.assertEquals(outcome.isSuccess, true);
          
          if(outcome.isSuccess){

          List<agencyQueueManagerUtilities.userInQueue> userList = (List<agencyQueueManagerUtilities.userInQueue>)outcome.values.get('userList');
          System.assertEquals(userList.size(), 2);

          For(agencyQueueManagerUtilities.userInQueue u: userList)
          {
            listUser.add(u.singleUser);
          }
          agencyQueueManagerCTRL.saveUpdateRequest(checkList,listUser,'Lead');
            String s = [SELECT JsonInstance__c FROM Bulk_Request__c LIMIT 1].JsonInstance__c;
            String s1 = [SELECT JsonInstance__c FROM Bulk_Request__c LIMIT 1].JsonInstance__c;
        }

        System.runAs(adminUser)
        {    
            BulkRequestManager TheB = new BulkRequestManager();
            Database.ExecuteBatch(TheB);
            Test.stopTest();

            List<GroupMember> queueUsersNew = [SELECT Id,UserOrGroupId FROM GroupMember WHERE GroupId =: queueId];
            System.assertEquals(queueUsersNew.size(), 1);
        }
        
        }
    }
    @isTest static void test_method_3(){
        User agencyBaseUser = [SELECT Id, Profile.Name, UserRole.Name, Nodes_tree__c, Agency_code__c, Nodes__c FROM User WHERE Username = 'agency1User828@axa.com.masterdev3'];
      System.runAs(agencyBaseUser)
        {
          agencyQueueManagerCTRL.setOfficialAgencyEmail('test.test@test.it');          
        }
        agencyQueueManagerCTRL.setOfficialAgencyEmail('err');
    }
}
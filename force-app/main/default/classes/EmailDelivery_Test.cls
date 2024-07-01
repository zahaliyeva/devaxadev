@istest
public class EmailDelivery_Test {


    @testSetup static void setup() {

    //insert B2C_Account
    Contact TheClient = new Contact();
    TheClient.LastName = 'Cooper';
    TheClient.FirstName = 'Sheldon';
    TheClient.Email = 'scooper@invalid.id';

    insert TheClient;

    Contact TheClient2 = new Contact();
    TheClient2.LastName = 'Parker';
    TheClient2.FirstName = 'Peter';
    TheClient2.Email = 'scooperv2@invalid.id';
    insert TheClient2;

    //User
    User userAdmin = new User(Username = 'testclassNewActivityLead@test.com',
    LastName = 'testuser',
    LanguageLocaleKey = 'en_US',
    FirstName = 'test',
    Email = 'test@test.com',
    Alias = 'test',
    TimeZoneSidKey = 'Europe/Dublin',
    LocaleSidKey = 'en_US',
    EmailEncodingKey = 'UTF-8',
    ProfileId = AP_Constants.getProfileAdminId()
    );

    insert userAdmin;

    System.runAs(new User(Id=UserInfo.getUserId()))
        {
            Group g = new Group(DeveloperName='Coda_Agenzia_006345',Name='Coda_Agenzia_006345',Type='Queue');
            insert g;
        
            //User u = [Select id from user where username ='testclassNewActivityLead@test.com'];
        
            GroupMember gm = new GroupMember(GroupId=g.Id,UserOrGroupId=userAdmin.id);
            insert gm;    
        }

    }

    @istest
    public static void method1(){

        User u = [Select id from user where username ='testclassNewActivityLead@test.com'];
        List<SObject> accountsList = [Select id, Name from Contact limit 2];
        List<Group> groupIds = [select id from Group where DeveloperName = 'Coda_Agenzia_006345' limit 1];

        String type = '';
        List<SObject> targets = new List<SObject>();
        targets.add(u);
        targets.addAll(accountsList);

        String SenderDisplayName = 'SenderDisplayName';
        String ReplyToEmail = 'ReplyToEmail';
        Boolean saveAsActivity = true;
        Boolean notifyErrors = true;
        Integer transactionLimit = 10;
        //TYPE = 'TEMPLATE'
        EmailTemplate et = [Select id,name from EmailTemplate where templateType != 'visualforce' limit 1];
        //TYPE = 'HTML'
        String attach_name = 'attach_name';

        String attach_content = 'attach_content';
        String subject = 'subject';
        String mailContent = 'mailContent';

        EmailDelivery EmailDeliveryTemp = new EmailDelivery(type,targets,SenderDisplayName,ReplyToEmail,saveAsActivity,
        notifyErrors,transactionLimit,et,attach_name,attach_content,subject,mailContent);


        Set<Id> groupIdsSet = new Set<Id>();
        
        for(Group temp :groupIds)
            groupIdsSet.add(temp.id);

        EmailDelivery.sendMailTemplated(accountsList[0],'SpiderMan','iroman@mail.invalid',true,true,et);
        EmailDelivery.sendMailTemplatedList(accountsList,'SpiderMan','iroman@mail.invalid',true,true,et);

        EmailDelivery.sendMailHtml(accountsList[0],'SpiderMan','iroman@mail.invalid',true,true,'attach_name','b','c','d');
        EmailDelivery.sendMailHtmlList(accountsList,'SpiderMan','iroman@mail.invalid',true,true,'attach_name','b','c','d');
        
        EmailDelivery.getUsersIdThatBelongsToGroup(groupIdsSet);
        EmailDelivery.getUsersThatBelongsToGroup(groupIdsSet);

        Test.startTest();
        ID jobID =  System.enqueueJob(EmailDeliveryTemp);
         //= System.enqueueJob(updater);
         Test.stopTest();   

    }

}
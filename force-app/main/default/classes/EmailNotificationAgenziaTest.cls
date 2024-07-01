@isTest
public class EmailNotificationAgenziaTest {
	@testSetup 
    static void setup() {
        EmailTemplate e = new EmailTemplate (Isactive= true,developerName = 'test', FolderId =  UserInfo.getUserId(), TemplateType= 'Text', Name = 'test'); 
        insert e;
        Group g = new Group(Name = 'test', email = 'test.test@test.invalid.com', DoesSendEmailToMembers=true, type = 'Queue');
        insert g;
        
   }
    
    static testMethod void method_1() {
         
   		test.startTest();
     Account acc = new Account (FirstName='testName', LastName='testLastName', Destinatario_notifica_Feedback_Case__c='test@test.it;test2@test2.invalid');
        insert acc; 
   
		List<Group> queue = [Select id, email from Group where name = 'test'];
        Case ca = new Case (ownerID = queue[0].Id,Agenzia__c = acc.id);
        
        EmailNotificationAgenzia.PBInputs requestI = new  EmailNotificationAgenzia.PBInputs();
        requestI.caseObj = ca;
        requestI.templateApiName='test';
        requestI.GroupMail = queue[0].email;
        List <EmailNotificationAgenzia.PBInputs> request = new List <EmailNotificationAgenzia.PBInputs> ();
        request.add(requestI);
        request.add(requestI);//for bulking add after deploy *-+ 05-12-2022 
        request.add(requestI);//for bulking add after deploy *-+ 05-12-2022 
        
        EmailNotificationAgenzia.SendEmailNotification(request);
        test.stopTest();
    }

}
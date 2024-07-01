@IsTest
public class MobilityEmailTest {
@isTest
static void testMobilityEmail() {

	List<String> to = new List<String>();
	List<String> cc = new List<String>();
	List<String> files = new List<String>();

    Lead temp = new Lead ();
    temp.FirstName = 'Sheeldon';
    temp.LastName = 'Cooper';
    insert temp;

	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	Id TemplateId = mail.getTemplateId();
    
    to.add('test@test.invalid');
    
    Test.startTest();
    
    MobilityEmail.getFolders('123');
    MobilityEmail.getTemplates('123');
    MobilityEmail.sendEmail('test@test.invalid','TEST',to,cc,'TEST','TEST',files,temp.id,TemplateId);
    
    Test.stopTest();
    
	}
}
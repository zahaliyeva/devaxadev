@isTest
public class InviaADestNotificaFeedbackCase_TEST {
   @testSetup static void setup() {
        EmailTemplate e = new EmailTemplate (Isactive= true,developerName = 'test', FolderId =  UserInfo.getUserId(), TemplateType= 'Text', Name = 'test'); 
        insert e;   
   }
    static testMethod void method_1() {
    
        
        Account acc = new Account (FirstName='testName', LastName='testLastName', Destinatario_notifica_Feedback_Case__c='test@test.it;test2@test2.invalid');
        insert acc; 
     
        Case ca = new Case (Agenzia__c = acc.id);
  
        InviaADestNotificaFeedbackCase.PBInputs requestI = new  InviaADestNotificaFeedbackCase.PBInputs();
        requestI.caseObj = ca;
        requestI.templateApiName='test';
        List <InviaADestNotificaFeedbackCase.PBInputs> request = new List <InviaADestNotificaFeedbackCase.PBInputs> ();
        request.add(requestI);
        request.add(requestI);//for bulking add after deploy *-+ 05-12-2022 
        request.add(requestI);//for bulking add after deploy *-+ 05-12-2022 
        
        InviaADestNotificaFeedbackCase.SendEmailNotification(request);
        
    }

}
@isTest
public class LghtCaseCommunicationsControllerTest {
    @testSetup private static void createData(){
        ID BusinessHoursDefault = [SELECT id FROM businesshours WHERE isDefault = TRUE LIMIT 1].id;
        List<MPS_Code_Variables__c> listCustomSetting = new List<MPS_Code_Variables__c>();
        listCustomSetting.add(new MPS_Code_Variables__c(Name = 'BusinessHours_Default', Value__c = BusinessHoursDefault));
        insert listCustomSetting;
        Case cCase = new Case(Status = 'Open', Phone_Call_Ids__c='', Origin='Portale Assistenza', Category__c='ATR', SubCategory__c='', recordtypeid =  [SELECT id from RecordType WHERE DeveloperName = 'Assistenza_Agenti'].Id);
        insert cCase;
        String rTId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agente'].Id; 
        Storico_conversazioni__c sc = new Storico_conversazioni__c ( Description__c = 'descrizione', Connected_case__c = cCase.Id, CaseStatus__c = 'Chiuso in autonomia', Type__c = 'Annullamento richiesta', RecordTypeId = rTId, Profilo_utente__c = 'Agente', Ruolo_utente__c = '-' );
        insert sc;
        
        EmailMessage em =  new EmailMessage(Subject ='Test Incoming1',
                                            Status ='1',
                                            TextBody= 'Messaggio test 1',
                                            MessageDate= Date.today()-1,
                                            Incoming = true,
                                            FromAddress = 'Receiver1@test1.it',
                                            ParentID=cCase.id
                                           );
        
        insert em;
        
        LiveChatVisitor chatVisitor = new LiveChatVisitor();
        insert chatVisitor;
        
        Account acc = new Account(Name = 'myAccountTest');
        insert acc;
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(AccountId = acc.Id,
                                                                       LiveChatVisitorId = chatVisitor.Id,
                                                                       CaseId = cCase.Id);
        insert liveChatTranscript;

        
        Storico_Chiamate__c st = new Storico_Chiamate__c(Call_ID__c='89078', Case__c = cCase.Id);
        insert st;
        
        Communications_to_customer__c comm1 = new Communications_to_customer__c(DIF_Event_Timestamp__c = System.now(),
                                                                                AccountId__c = acc.Id,
                                                                                Message__c = 'Test Message 1',
                                                                                CaseId__c = cCase.id,
                                                                                Mobile_Phone__c = '123456789');
        insert comm1;
        
    }
    
    @isTest static void test() {
        Test.startTest();
        Case cCase = [SELECT id FROM Case LIMIT 1];
        LghtCaseCommunicationsController.getCommunications(cCase.id);
        Test.stopTest();          
    }
}
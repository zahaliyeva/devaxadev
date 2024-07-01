@IsTest
public class emailAttachmentReassignerTest {

        @TestSetup
        static void makeData(){
            ServiceUtilsClass.populateCustomSettingsForTests();
        } 

        @isTest
        public static void attachmentTester() {
            
            //MOSCATELLI_M 29042016:EVO 51--START
            Account acc = new Account(FirstName='Test',LastName='AccountT');
            insert acc;
            String caseRecordTypeId = RecordTypeUtility.getRecordTypeIdByDeveloperName('Case', 'Assistenza_Agenti');
            Case c = new Case(
                Complainant__c='Customer',
                Status = 'Open',
                AccountId = acc.Id,
                Category__c='Duplicati polizza di risparmio',
                RecordTypeId = caseRecordTypeId,
                Origin    = 'Email');
            insert c;
            
            EmailMessage em = new EmailMessage();
            em.parentId = c.id;
            em.MessageDate = Date.today();
            em.FromAddress = 'test@from.com';
            em.ToAddress = 'test@to.com';
            em.Subject = 'test subject';
            em.TextBody = 'heres a text body.';
            em.Incoming = true;
            insert em;
                    
        
            Attachment a = new Attachment();
            a.name = 'test.csv';
            a.body = blob.valueof('attachment body');
            a.parentid = em.id;
            insert a;   
            
            List<Attachment> attachments = [Select Id From Attachment Where parentId = :c.id];
            
            System.assert(attachments.size() == 1, 'Wrong number of attachments (( ' + attachments.size() );
        }   
    }
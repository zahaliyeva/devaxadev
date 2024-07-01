/**
 * Created by francesco on 2019-07-11.
 */

global class MassiveCommunicationBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful {

    private integer contTotalRecordsKO = 0;
        private integer contTotalRecordsRan = 0;
        private integer scopeSize ;
        private String  query ;
        private integer minutesRange ;
        private boolean isAutoSchedulable ;
        private boolean needInfoLogWrite ;
        String BATCH_NAME = 'MassiveCommunicationBatch';
        private datetime inizio;
        private datetime fine;
        private long tempoBatch;
        private integer divTemporale;
        private datetime newSchedule;
        private integer minutesNeed;
        private integer DailyStart;
        private integer DailyEnd;

    

    private Long processed;
    private Long successed;
    private Long failed;
    private Long missingContact;
    private Boolean errorEnabled;
    private List<String> errors;
    //public Integer batchSize = 200;
    public Boolean notificationEnabled = true;
    /*

    SELECT Id, Account__c, Contact__c, Status__c FROM Massive_Communication__c WHERE Type__c = Digital AND Status__c = Draft;
    public String query = 'SELECT Id, Account__c, Contact__c, Status__c' +
            ' FROM Massive_Communication__c' +
            ' WHERE Type__c = \'Digital\'' +
            ' AND Status__c = \'Draft\'';
*/
    global MassiveCommunicationBatch() {
        this.processed = 0;
        this.successed = 0;
        this.failed = 0;
        this.missingContact = 0;
        this.errorEnabled = false;
        this.errors = new List<String>();
        this.inizio = DateTime.now();
        this.queryMdt();
        
       

    }
    private void queryMdt(){
        BatchSetting__mdt batchSettings = [select DeveloperName,IsAutoSchedulable__c,MinutesRange__c,
        ScopeSize__c,Query__c,Need_Information_Log__c, Daily_Hour_Start__c, Daily_Hour_End__c
        from BatchSetting__mdt
        where DeveloperName = 'Run_Massive_Batch'];

        integer tempStart = (integer) (batchSettings.Daily_Hour_Start__c != null? batchSettings.Daily_Hour_Start__c:9);
        integer tempEnd = (integer) (batchSettings.Daily_Hour_End__c != null? batchSettings.Daily_Hour_End__c:21);
        if(tempStart >= 0 && tempStart <= 23){
            this.DailyStart = tempStart;
        }
        if(tempEnd >= 0 && tempEnd <= 23){
            this.DailyEnd = tempEnd;
        }
        this.scopeSize =(integer) batchSettings.ScopeSize__c ;
        this.minutesRange = (integer) batchSettings.MinutesRange__c ;
        this.isAutoSchedulable = batchSettings.IsAutoSchedulable__c ;
        this.query = batchSettings.Query__c ;
        this.needInfoLogWrite = batchSettings.Need_Information_Log__c ;
    }

    global MassiveCommunicationBatch(Boolean errorEnabled) {
        this.processed = 0;
        this.successed = 0;
        this.failed = 0;
        this.missingContact = 0;
        this.errorEnabled = errorEnabled;
        this.inizio = DateTime.now();
        this.errors = new List<String>();
        this.queryMdt();

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('DBG - Query: ' + query);
        return Database.getQueryLocator(query);
         //date time inizio


    }

    global void execute(Database.BatchableContext bc, List<Massive_Communication__c> scope) {
        this.updateMassiveCommunication(scope);
    }

    global void execute(SchedulableContext SC) {
        System.abortJob(SC.getTriggerId());
        MassiveCommunicationBatch mcb = new MassiveCommunicationBatch(true);
        Database.executeBatch(mcb, this.scopeSize);
    }

    global void finish(Database.BatchableContext bc) {
        long longNeed;
        fine = datetime.NOW();
        tempoBatch = fine.getTime()  - inizio.getTime();
        integer tempoBatchinMinutes = (integer) tempoBatch /60000;
                    System.debug('minuti fine ' + fine.time());
                    System.debug('minuti inizio' + inizio.time());
                    System.debug('TempoBatch ' + tempoBatch);
        
                divTemporale = (tempoBatchinMinutes / minutesRange) + 1;
                System.debug('divTemporale ' + divTemporale);
        
                newSchedule = inizio.addMinutes(divTemporale * minutesRange);
                /*    System.debug('newSchedule' + newSchedule);
                longNeed = (newSchedule.getTime()  - inizio.getTime());
                minutesNeed = integer.valueof(longNeed / 60000);
                minutesNeed = minutesNeed ;*/

                if ((newSchedule.day() == inizio.day()+1 && newSchedule.hour() < this.DailyStart)||
                    (((newSchedule.hour() == this.DailyEnd && newSchedule.minute() > 00) ||(newSchedule.hour() > this.DailyEnd))  
                     && newSchedule.day() ==inizio.day())){
                    newSchedule = datetime.newInstance(inizio.date()+1, time.newInstance(this.DailyStart,0,0,0));
                    /*longNeed = (newSchedule.getTime()  - inizio.getTime());
                	minutesNeed = integer.valueof(longNeed / 60000);
                    minutesNeed = minutesNeed +2+540;
                    System.debug('longNeed' + longNeed);
                    System.debug('minutesNeed ' + minutesNeed);*/
                    
                    /*inizio = inizio.addDays(1);
                    newSchedule = datetime.newInstance(inizio.date(), time.newInstance(9,0,0,0));
                    System.debug('newSchedule' + newSchedule);*/
                }
                

                
                if(this.isAutoSchedulable && !Test.isRunningTest()) {
                    System.schedule(BATCH_NAME, this.getCron(newSchedule), new MassiveCommunicationBatch(true));
                } 
    

        if (notificationEnabled) {
            //Long send = this.processed+ this.successed+ this.failed+ this.missingContact;
            Long send =  this.failed+ this.missingContact;

            if(send != 0)
                notifyResult();
        }
    }

    private void updateMassiveCommunication(List<Massive_Communication__c> communications) {
        
        Set<Id> accountIds = new Set<Id>();
        for (Massive_Communication__c mc : communications) {
            accountIds.add(mc.Account__c);
        }

        Map<Id, Contact> contactByAccountId = new Map<Id, Contact>();
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds];
        for (Contact c : contacts) {
            contactByAccountId.put(c.AccountId, c);
        }

        for (Massive_Communication__c mc : communications) {
            this.processed++;
            if (contactByAccountId.containsKey(mc.Account__c)) {
                mc.Contact__c = contactByAccountId.get(mc.Account__c).Id;
                mc.Status__c = 'Ready';
                mc.TECH_Status_Update_Date__c = System.now();

            } else {
                this.missingContact++; // matching Contact not found
                if (errorEnabled) {
                    mc.Status__c = 'KO digital sending';
                    mc.TECH_Status_Update_Date__c = System.now();
					mc.Send_Error_Detail__c = 'mancata associazione contatto cliente su SFDC';
                }
            }
        }

        Database.SaveResult[] results = Database.update(communications, false);
        Integer i = 0;
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                this.successed++;

            } else {
                this.failed++;
                for (Database.Error error : sr.getErrors()) {
                    String message = 'Record Id: ' + communications[i].Id +
                            ' - Error: ' + error.getStatusCode() +
                            ' - ' + error.getMessage() +
                            ' - Fields: ' + error.getFields();
                    this.errors.add(message);
                }
            }

            i++;
        }

    }

    private String getCron(DateTime next_schedule){
        
        String min = String.valueOf(next_schedule.minute());
        String hh = String.valueOf(next_schedule.hour());
        String dd = String.valueOf(next_schedule.day());
        String mm = String.valueOf(next_schedule.month());
        String yy = String.valueOf(next_schedule.year());
             
        return '0 ' + min + ' ' + hh + ' ' + dd + ' ' + mm + ' ? ' + yy;
    }

    private void notifyResult() {

        List<String> destinations = new List<String>();
        EmailTemplate template = null;

        List<EmailTemplate> templates = [
                SELECT Id, Subject, HtmlValue, Body
                FROM EmailTemplate
                WHERE DeveloperName = 'MassiveCommunicationBatchNotification'
        ];
        if (templates != null && !templates.isEmpty()) {
            template = templates[0];
        }

        String userId = UserInfo.getUserId();
        destinations.add(userId);
        /*
        List<User> admin = [SELECT Id FROM User WHERE Username IN :Label.Massive_Communication_Batch_Recipient.split(',') OR Username LIKE 'deloitte.admin@italy%'];
        if (admin.size() > 0) {
            destinations.add(admin[0].Id);
        }*/
        AAI_Code_Variables__c acv = AAI_Code_Variables__c.getValues('MassiveCommunicationBatchAddresses');

        if (acv != null && String.isNotBlank(acv.Value__c)) {
            List<String> tempAddresses = acv.Value__c.split(';');
            Set<String> addresses = new Set<String>(tempAddresses);
            addresses.remove(null);

            if (!addresses.isEmpty()) {
                destinations.addAll(addresses);
            }
        }

        String errorsString = '';
        if (!errors.isEmpty()) {
            for (String s : errors) {
                errorsString += '- ' + s + '<br/>';
            }
        }

        Map<String, String> fieldToValue = new Map<String, String>();
        fieldToValue.put('{!processed}', String.valueOf(this.processed));
        fieldToValue.put('{!successed}', String.valueOf(this.successed));
        String contacts = String.valueOf(this.missingContact);
        if(this.missingContact > 0 && !errorEnabled) {
            contacts += ' (da riprocessare alla successiva esecuzione)';
        }
        fieldToValue.put('{!missingContact}', contacts);
        fieldToValue.put('{!failed}', String.valueOf(this.failed));
        fieldToValue.put('{!errors}', errorsString);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (template != null) {
            mail = UtilityClass.prepareEmailTemplate(template, fieldToValue);
        } else {
            mail.setSubject('subject');
            mail.setHtmlBody('htmlbody');
        } 
        mail.setToAddresses(destinations);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        mail.setUseSignature(false);

        try {
            if (!Test.isRunningTest()) {
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                        mail
                });
            }

        } catch (Exception e) {
            System.debug('DBG - Exception: ' + e.getMessage() + ' - ' + e.getStackTraceString());
        }
    }
}
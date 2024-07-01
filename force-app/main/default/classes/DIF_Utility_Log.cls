public with sharing class DIF_Utility_Log {

    public static final String ERROR = 'ERROR';
    public static final String WARNING = 'WARNING';
    public static final String OK = 'OK';
    public enum DataLogs {
        TIMESTAMP,
        EVENTO_DIF,
        AGENCY_CODE_NEW,
        AGENCY_CODE_OLD,
        NDG_NEW,
        NDG_OLD,
        OWNER_ID_NEW,
        OWNER_ID_OLD,
        RECORD_ID_NEW,
        RECORD_ID_OLD,
        PARENT_ID_NEW,
        PARENT_ID_OLD,
        POLICY_ID_NEW,
        POLICY_ID_OLD,
        NUCLEO_ID_NEW,
        NUCLEO_ID_OLD,
        CONTACT_ID_NEW,
        CONTACT_ID_OLD,
        LEAD_ID_NEW,
        LEAD_ID_OLD,
        CAMPAIGN_ID_NEW,
        CAMPAIGN_ID_OLD,
        ACCOUNT_ID_NEW,
        ACCOUNT_ID_OLD,
        WHO_ID_NEW,
        WHO_ID_OLD,
        WHAT_ID_NEW,
        WHAT_ID_OLD
    }

    public static Map<DataLogs, String> createMapForLog(Ap_Constants.EventoDIF eventType, String oldAgencyCode) {
        Map<DataLogs, String> retMap = new Map<DataLogs, String>();
        List<DataLogs> dlValues = DataLogs.values();
        for (DataLogs dl : dlValues) {
            retMap.put(dl, '');
        }
        retMap.put(DIF_Utility_Log.DataLogs.EVENTO_DIF, eventType.name());
        retMap.put(DIF_Utility_Log.DataLogs.AGENCY_CODE_OLD, oldAgencyCode);
        return retMap;
    }

    public static Map<DataLogs, String> createMapForLog() {
        Map<DataLogs, String> retMap = new Map<DataLogs, String>();
        List<DataLogs> dlValues = DataLogs.values();
        for (DataLogs dl : dlValues) {
            retMap.put(dl, '');
        }
        return retMap;
    }

    public static SObject updateRecord(SObject obj, Datetime now, Map<DataLogs, String> description) {
        obj.put('DIF_Event_Timestamp__c', now);
        description.put(DataLogs.TIMESTAMP, String.valueOfGmt(now));
        //TODO: e se il campo è già popolato con campi che non verrebbero sovrascritti?
        if(String.isEmpty((String)obj.get('DIF_Event_Log__c'))){
            obj.put('DIF_Event_Log__c', convertMapToCsvString(description));
        }
        else{
            String log = (String)obj.get('DIF_Event_Log__c') + '\n';
            log += convertMapToCsvString(description);
            obj.put('DIF_Event_Log__c', log);
        }
        return obj;
    }

    public static String createRecord(Datetime eventCreationTime, String level, String description) {
        return '"' + eventCreationTime.format('YYYY-MM-dd_HH-mm') + '","' + level + '","' + description + '"\n';
    }

    public static void sendEmail(String objectAnalyzed, String subjectEmail, String csvFile, Integer countERROR, Integer countWARNING, Integer countOK) {

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<String> usersEmails = new List<String>();

        List<DIF_events_log_users__c > settingsList = new List<DIF_events_log_users__c >(); //custom settings table
        settingsList = DIF_events_log_users__c.getAll().Values();
        for(DIF_events_log_users__c item : settingsList){
            usersEmails.add(item.Email_address__c);
        }
        List<String> toAddresses = new List<String>();
        toAddresses.add(UserInfo.getUserEmail());
        toAddresses.addAll(usersEmails);
        email.setToAddresses(toAddresses);
        email.setSubject(subjectEmail);
        String emailBody = '';
        if (countERROR > 0) {
            emailBody = 'Buongiorno,\n\n' +
                    'vi informiamo che il processo di quality check sull’oggetto ' + objectAnalyzed + ' è terminato con errori:\n' +
                    'Record analizzati correttamente:  ' + countOK + '\n' +
                    'Record con warning: ' + countWARNING + '\n' +
                    'Record in errore:  ' + countERROR + '\n\n' +
                    'Cordiali saluti,\n' +
                    'Team AXA CRM\n';
        } else if (countWARNING > 0) {
            emailBody = 'Buongiorno,\n\n' +
                    'vi informiamo che il processo di quality check sull’oggetto ' + objectAnalyzed + ' è terminato senza errori, ma con delle segnalazioni di warning:\n' +
                    'Record analizzati correttamente:  ' + countOK + '\n' +
                    'Record con warning: ' + countWARNING + '\n' +
                    'Record in errore:  ' + countERROR + '\n\n' +
                    'Cordiali saluti,\n' +
                    'Team AXA CRM\n';
        } else { //countERROR == 0 && countWARNING == 0
            emailBody = 'Buongiorno,\n\n' +
                    'vi informiamo che il processo di quality check sull’oggetto ' + objectAnalyzed + ' è terminato senza errori:\n' +
                    'Record analizzati correttamente:  ' + countOK + '\n' +
                    'Record con warning: ' + countWARNING + '\n' +
                    'Record in errore:  ' + countERROR + '\n\n' +
                    'Cordiali saluti,\n' +
                    'Team AXA CRM\n';
        }

        System.debug('===> Email body: ' + emailBody);
        System.debug('===> To addresses: ' + toAddresses);

        //Preparazione allegato
        List<Messaging.EmailFileAttachment> attachmentList = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        String csvFilename = Datetime.now().format('YYYY-MM-dd_HH-mm') + '_' + objectAnalyzed + '_Quality_Check.csv';
        Blob csvBlob = Blob.valueOf(csvFile);
        attachment.setFileName(csvFilename);
        attachment.setBody(csvBlob);
        attachmentList.add(attachment);
        email.setFileAttachments(attachmentList);
        email.setPlainTextBody(emailBody);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                email
        });

    }

    public static String createHeader() {
        return 'Datetime,Status,Description\n';
    }

    private static String convertMapToCsvString(Map<DataLogs, String> mapToCsv) {
        String retCsv = '';

        List<DataLogs> dlValues = DataLogs.values();
        for (DataLogs dl : dlValues) {
            if (retCsv == '') {
                retCsv = '"' + mapToCsv.get(dl) + '"';
            } else {
                retCsv = retCsv + ',"' + mapToCsv.get(dl) + '"';
            }
        }

        return retCsv;
    }

    public static Map<DataLogs, String> convertCsvStringToMap(String csvToMap) {
        Map<DataLogs, String> mapResult = createMapForLog();
        List<String> csvValues = csvToMap.split(',');
        System.debug('===> csvValues.size(): ' + csvValues.size());
        for (Integer i = 0; i < DataLogs.values().size(); i++) {
            String value = csvValues[i];
            if(value.contains('&quot;')){
                value = value.replaceAll('&quot;','"');
            }
            mapResult.put(DataLogs.values()[i], value.replace('"', ''));
        }
        return mapResult;
    }
}
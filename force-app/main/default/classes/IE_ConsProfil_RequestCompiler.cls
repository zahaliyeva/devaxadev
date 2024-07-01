public class IE_ConsProfil_RequestCompiler {
        public static String buildRequestBody(String user, String privacyStatus, Datetime lastModifiedDate) {
            Map<String, Object> requestBodyMap = new Map<String, Object>();
            requestBodyMap.put('privacy-detail', new Map<String, Object>{
                'privacy-status' => privacyStatus,
                'privacy-contact-detail' => user,
                'privacy-type' => 'PROFILING_ACTIVITIES'
            });
            requestBodyMap.put('channel', 'ONECLICKSUBMISSION');
            String currentDateTime = lastModifiedDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            requestBodyMap.put('update-time-stamp', currentDateTime);
            String requestBodyJSON = JSON.serialize(requestBodyMap);
            System.debug(requestBodyJSON);
            return requestBodyJSON;
        }
     }
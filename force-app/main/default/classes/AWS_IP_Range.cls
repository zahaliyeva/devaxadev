global class AWS_IP_Range implements Schedulable, Database.AllowsCallouts{
        public class Prefix {
            public String ip_prefix;
            public String region;
            public String service;
            public String network_border_group;
            public String name;
            public Boolean isNew;
        }
        
        
    	
        public static void parseJSON() {
            AWS_IP_Ranges_Check_Settings__c setting = AWS_IP_Ranges_Check_Settings__c.getInstance();
            Boolean check_syncToken = setting.Check_syncToken__c;
            Boolean inviamail = setting.Invia_Mail__c;
            Boolean fromfile = setting.FromFile__c;
            String endpoint = setting.Endpoint__c;
            List<String> destinatariList;
            String header = 'Data estrazione, ip_prefix, region, service, network_border_group\n';
            String csvData = ''; 
            
            
            if(inviamail==true){
                String destinatariString = setting.Destinatari_Email__c;
                destinatariList = new List<String>(destinatariString.split(';'));
                for(String destinatario : destinatariList) {
                    destinatario = destinatario.trim();
                }
            }
            integer newCount = 0;
            integer foundCount = 0;
            String jsonbody;
            if(fromfile == false){
                Http httpProtocol = new Http();
                HttpRequest request = new HttpRequest();
                
                request.setEndPoint(endpoint);
                request.setMethod('GET');
                
                HttpResponse response = httpProtocol.send(request);
                jsonbody = response.getBody();
            }else{
                try{
                    ID workspaceId = [SELECT Id FROM ContentWorkspace WHERE Name = 'AWS IP Range'][0].Id;
                    ContentVersion filetoparse = [SELECT VersionData FROM ContentVersion WHERE ContentDocument.ParentId = :workspaceId];
                    jsonbody = filetoparse.VersionData.toString();
                }catch(Exception e){
                    System.debug('Errore durante la query sul file da parsare: '+ e.getMessage());
                }
            }
            
            List<IP_Range__c> old_prefixes = new  List<IP_Range__c>();
            List<new_prefixes__c> old_padre = new List<new_prefixes__c>();
            
            try{
                old_prefixes = [
                    SELECT Id, Name, ip_prefix__c, trovato__c, isNew__c, region__c, service__c, network_border_group__c
                    FROM IP_Range__c
                    WHERE AWS_IP_Range__r.actual__c = true
                ];
                old_padre = [
                    SELECT id, syncToken__c, actual__c
                    FROM new_prefixes__c 
                    WHERE actual__c = true];
                
                
                if(old_padre.isEmpty()){
                    new_prefixes__c np = new new_prefixes__c(Name = 'Pilota', actual__c = true);
                    old_padre.add(np);
                    insert old_padre;
                    System.debug(old_padre);    
                }
                
            } catch(Exception e){
                System.debug(e.getMessage());
                
            }
            
            System.debug(old_padre);
            Id old_Idlookup = old_padre[0].Id;
            String old_synctoken = old_padre[0].syncToken__c;
            ContentDocumentLink old_CsvContentDocument = new ContentDocumentLink();
            ContentDocumentLink old_JsonContentDocument = new ContentDocumentLink();
            ContentVersion csvFiles = new ContentVersion();
            Id old_CsvContentDocumentId;
            Id old_JsonContentDocumentId;
            try{
                old_CsvContentDocument = [SELECT ContentDocumentId, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId = :old_Idlookup AND ContentDocument.FileType = 'CSV' ];
                old_CsvContentDocumentId = old_CsvContentDocument.ContentDocumentId;
            }catch(Exception e){
                System.debug(e.getLineNumber());
                
            }
            try{
                old_JsonContentDocument = [SELECT ContentDocumentId, ContentDocument.FileType FROM ContentDocumentLink WHERE LinkedEntityId = :old_Idlookup AND ContentDocument.FileType = 'JSON' ];
                old_JsonContentDocumentId = old_JsonContentDocument.ContentDocumentId;        
            }catch(Exception e){
                System.debug(e.getLineNumber());
                
            }
            
            try{
                csvFiles = [
                    SELECT id, VersionData
                    FROM ContentVersion
                    WHERE ContentDocumentId = :old_CsvContentDocumentId AND IsLatest = true
                ];
                
            }catch(Exception e){
                System.debug(e.getLineNumber());
                csvFiles.VersionData = Blob.valueOf(header);
                System.debug(csvFiles.VersionData);
                System.debug(csvFiles);
                
                
                
            }
            
            
            
            
            
            List<Prefix> new_prefixes = new List<Prefix>();
            System.debug('Ecco json:' + jsonbody);
            Map<String, Object> parsedJSON = (Map<String, Object>) JSON.deserializeUntyped(jsonbody);
            System.debug(parsedJSON);
            String syncToken = (String) parsedJSON.get('syncToken');
            String createdDate = (String) parsedJSON.get('createdDate');
            if((check_syncToken == true && syncToken != old_syncToken) || (check_syncToken == false)){
                new_prefixes__c new_ipPadre = new new_prefixes__c();
                new_ipPadre.syncToken__c = syncToken;
                new_ipPadre.Name = syncToken;        
                new_ipPadre.actual__c = null;
                
                new_ipPadre.actual__c = true;
                insert new_ipPadre;        
                
                Id Idlookup = new_ipPadre.Id;
                
                
                
                
                List<Object> prefixObjects = (List<Object>) parsedJSON.get('prefixes');
                integer i = 1;
                for (Object prefixObject : prefixObjects) {
                    Map<String, Object> prefixMap = (Map<String, Object>) prefixObject;
                    String region = (String) prefixMap.get('region');
                    String service = (String) prefixMap.get('service');
                    
                    if ((region == 'GLOBAL' && service == 'AMAZON_CONNECT') || (region == 'eu-central-1' && service == 'AMAZON_CONNECT')) {
                        Prefix prefix = new Prefix();
                        prefix.ip_prefix = (String) prefixMap.get('ip_prefix');
                        prefix.region = region;
                        prefix.service = service;
                        prefix.isNew = false;
                        prefix.network_border_group = (String) prefixMap.get('network_border_group');
                        prefix.name = 'IP ' + region + ' v' + i;
                        
                        new_prefixes.add(prefix);
                        i++;
                    }
                    
                }
                
                
                
                
                
                // Verifica se ciascun ip_prefix in new_prefixes è già presente in old_prefixes
                for (Prefix newPrefix : new_prefixes) {
                    Boolean found = false;
                    for (IP_Range__c oldPrefix : old_prefixes) {
                        if ((oldPrefix.ip_prefix__c == newPrefix.ip_prefix) && (oldPrefix.service__c == newPrefix.service) && (oldPrefix.region__c == newPrefix.region )) {
                            found = true;
                            foundCount++;
                            oldPrefix.trovato__c = true;
                            break;
                        }
                    }
                    
                    // Valorizza new__c a true per l'ip_prefix corrente
                    if (!found) {
                        newCount++;
                        newPrefix.isNew = true;
                    }
                }
                
                
                
                
                
                //Create a csv
                ContentVersion att = new ContentVersion();
                ContentVersion att2 = new ContentVersion();
                try{
                    
                    if(csvFiles!= null){
                        System.debug(csvFiles.VersionData);
                        csvData += csvFiles.VersionData.toString(); 
                        for(Prefix prefix : new_prefixes){
                            
                            csvData += DateTime.now() + ',' + prefix.ip_prefix + ',' + prefix.region + ',' + prefix.service + ',' + prefix.network_border_group + '\n';
                        }}else{
                            for(Prefix prefix : new_prefixes){
                                csvData = header + prefix.name + ',' + prefix.ip_prefix + ',' + prefix.region + ',' + prefix.service + ',' + prefix.network_border_group + '\n';
                            }
                        }
                    
                    
                    
                    
                    
                    att.FirstPublishLocationId = Idlookup;
                    att.Title = 'AWS_IP_Ranges.csv';
                    att.PathOnClient = 'AWS_IP_Ranges.csv';
                    att.VersionData = Blob.valueOf(csvData);
                    insert att;
                    
                    delete [SELECT Id FROM ContentDocument WHERE Id = :old_CsvContentDocumentId ];   
                    delete [SELECT Id FROM ContentDocument WHERE Id = :old_JsonContentDocumentId ];            
                    
                    //Create a JSON
                    
                    att2.FirstPublishLocationId = Idlookup;
                    att2.Title = 'AWS_IP_Ranges.json';
                    att2.PathOnClient = 'AWS_IP_Ranges.json';
                    att2.VersionData = Blob.valueOf(jsonbody);
                    insert att2;
                }catch(Exception e){
                    System.debug(e.getLineNumber());
                }
                
                // Save the prefixes to the custom object "IP_Range_c".
                List<IP_Range__c> ipRanges = new List<IP_Range__c>();
                for (Prefix prefix : new_prefixes) {            
                    IP_Range__c ipRange = new IP_Range__c();
                    ipRange.ip_prefix__c = prefix.ip_prefix;
                    ipRange.region__c = prefix.region;
                    ipRange.service__c = prefix.service;
                    ipRange.network_border_group__c = prefix.network_border_group;
                    ipRange.data__c = date.today();
                    ipRange.Name = prefix.name;
                    ipRange.isNew__c = prefix.isNew;
                    ipRange.AWS_IP_Range__c = IdLookup;
                    ipRanges.add(ipRange);
                    
                    
                }
                
                insert ipRanges;
                
                
                
                List<IP_Range__c> old_ipRanges = new List<IP_Range__c>(old_prefixes);
                for (IP_Range__c ipRange : old_ipRanges) {
                    ipRange.data__c = date.today();
                }
                update old_ipRanges;
                
                List<new_prefixes__c> old_ipPadre = new List<new_prefixes__c >(old_padre);
                for (new_prefixes__c ipPadre : old_ipPadre) {
                    ipPadre.actual__c = false;
                }
                update old_ipPadre;
                
                new_prefixes__c ipCancellati = new new_prefixes__c();
                ipCancellati = [SELECT Id, syncToken__c, actual__c, Ip_Cancellati__c, Ip_Nuovi__c
                                FROM new_prefixes__c 
                                WHERE actual__c = true];
                Integer IPDeleted = old_ipRanges.size() - foundCount;
                ipCancellati.Ip_Cancellati__c =  IPDeleted;
                ipCancellati.Ip_Nuovi__c = newCount;
                update ipCancellati;
                
                String TableDel = 'Name\tip_prefix\tregion\tservice\tnetwork_border_group\n';
                for(IP_Range__c prefix : old_prefixes){
                    if(prefix.trovato__c == false){
                        TableDel += prefix.name + '\t' + prefix.ip_prefix__c + '\t' + prefix.region__c + '\t' + prefix.service__c + '\t' + prefix.network_border_group__c + '\n';
                    }
                }
                String TableNew = 'Name\tip_prefix\tregion\tservice\tnetwork_border_group\n';
                for(IP_Range__c prefix : ipRanges){
                    if(prefix.isNew__c == true){
                        TableNew += prefix.name + '\t' + prefix.ip_prefix__c + '\t' + prefix.region__c + '\t' + prefix.service__c + '\t' + prefix.network_border_group__c + '\n';
                    }
                }        
                if(inviamail == true){
                    if(newCount != 0 || IPDeleted != 0 ){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(destinatariList);
                        mail.setSubject('IMPORTANTE: AWS IP Range Changed');
                        mail.setPlainTextBody('Sono cambiati gli IP range. Sono stati inseriti ' + newCount + 'nuovi IP Range e ne sono stati cancellati ' + IPDeleted + '.\n\n\nIP Cancellati:\n' + TableDel + '.\n\n\nIP Nuovi:\n' + TableNew + '\n\n\nPer maggiori dettagli consultare file csv in allegato.\n\nBuona giornata.' );
                        
                        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                        attachment.setFileName(att.Title);
                        attachment.setBody(att.VersionData);
                        Messaging.EmailFileAttachment attachment2 = new Messaging.EmailFileAttachment();
                        attachment2.setFileName(att2.Title);
                        attachment2.setBody(att2.VersionData);
                        
                        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment,attachment2});
                        Messaging.SendEmailResult [] result = Messaging.sendEmail( new Messaging.SingleEmailMessage[] {mail});
                    }
                }
            }
            
        }
    

        global void execute(SchedulableContext sc){
            chiamaMetedoAsincrono();
        }
    
    @Future(Callout=true)
    global static void chiamaMetedoAsincrono(){
        parseJSON();
    }
    	
    @InvocableMethod
    global static void chiamaMetedoSincrono(){
        parseJSON();
    }
}
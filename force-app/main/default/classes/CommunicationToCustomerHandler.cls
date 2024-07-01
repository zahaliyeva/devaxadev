public class CommunicationToCustomerHandler implements ITrigger {

    public final ID migrazioniProcesDigitalRecordTypeId = Schema.SObjectType.Communications_to_customer__c.getRecordTypeInfosByDeveloperName().get('Migrazione_Processi_Digital').getRecordTypeId();
    public final ID pianoEditorialRecordTypeId = Schema.SObjectType.Communications_to_customer__c.getRecordTypeInfosByDeveloperName().get('Piano_Editoriale').getRecordTypeId();  
    public final ID standarComRecordTypeId = Schema.SObjectType.Communications_to_customer__c.getRecordTypeInfosByDeveloperName().get('Standard_Communication').getRecordTypeId();
    public final ID outSourceRecordTypeId = Schema.SObjectType.Communications_to_customer__c.getRecordTypeInfosByDeveloperName().get('Outsource_Communication').getRecordTypeId();  
    public static boolean DeactivateTrigger = false;

    public CommunicationToCustomerHandler() {
    }
    public void bulkBefore(){}  

    public void bulkAfter(){} 

    public void beforeInsert(SObject so){}
    
    public void beforeInsert(List<SObject> soList){

        System.debug('before insert trigger com2cust');

        List<Communications_to_customer__c> listCommToCustomer = soList;
        Set<String> accountRelated = new Set<String> ();
        Set<String> iniziativeRelatedCode = new Set<String> ();

        //19-07-2022 *-+ PushNotif. csettings, for switch On/Off push notification for Process "OLD" like Rt:Standard_Communication and
        //MENSILIZZAZIONE, REMOTEPAYMENT, RINNOVI, RINNOVI AAI, RINNOVI NON AAI, AREA PREVENTIVI, SERVICE 2 SELL *sclussi('Consenso Stop Carta')
        boolean DeactivatePushNotificationForOldProcess = (AAI_Code_Variables__c.getAll()).get('PushNotification_Use_Iniz_Template') != null 
                                        ? (AAI_Code_Variables__c.getAll()).get('PushNotification_Use_Iniz_Template').Value__c=='true' : false;
       
                                        
        for(Communications_to_customer__c communicationTemp : listCommToCustomer ){
            if( communicationTemp.RecordTypeId == migrazioniProcesDigitalRecordTypeId
            || (communicationTemp.RecordTypeId == standarComRecordTypeId  &&  DeactivatePushNotificationForOldProcess)         
            ){
                if(communicationTemp.Process__c!= 'Consenso Stop Carta' && communicationTemp.Process__c!= 'SERVICE 2 SELL'){
                // process esclussi per AF
                    accountRelated.add(communicationTemp.AccountId__c);
                    iniziativeRelatedCode.add(communicationTemp.Communication_Code__c);
                }
            }
        }

    try {
            
        if(!accountRelated.isEmpty()){
            Map<id,Iniziative_Marketing__c> iniziativeRelatedToComunication = new Map<id,Iniziative_Marketing__c> ([Select id,Name, URL_Immagine__c, URL_CTA__c, Titolo__c, Sottotitolo__c, Short_Message__c,
                            Message__c, Testo_CTA__c, Communication_code__c, Versione__c, Eligibile_per_Compagnia__c,Contenuto__c,Visibilita_nel_centro_notifiche__c,Invio_push__c,Tipo_notifica_su_Centro_Notifiche__c,  
                            Canale__c, Descrizione_dell_iniziativa__c 
                            from Iniziative_Marketing__c 
                            where Communication_code__c in :iniziativeRelatedCode and Attiva__c = true ]);

            Map<id,Account> accountRelatedToComunication = new Map<id,Account> ([Select id,Name,Email_ListView__c,Codice_fiscale_ListView__c,Agency_Code__c, AAI_Agency__r.Agency_Holder__c, 
                            AAI_Agency__r.Name,AAI_Agency__r.Phone,AAI_Agency__r.Agency_email__c,AAI_Agency__r.MobilePhone__c,Contact_Master_Id__c,AAI_Agency__r.Agency_Code__c,
                            Additional_Phone__c ,MobilePhone__c,Mobile_Master_AAI__c,Email_Master_AAI__c,CIF_Number__c,CIF_Document_type__c 
                            from Account 
                            where id in :accountRelated ]);

                            
            if(!accountRelatedToComunication.isEmpty()){
                for(Communications_to_customer__c communicationTemp : listCommToCustomer ){
                    Account accForNotification = accountRelatedToComunication.get(communicationTemp.AccountId__c);

                    //aggiunto DeactivatePushNotificationForOldProcess come interruttore ON/OFF per 
                    //(OLD values of Process__c)-MENSILIZZAZIONE, REMOTEPAYMENT, RINNOVI, RINNOVI AAI, RINNOVI NON AAI, AREA PREVENTIVI *all RT-standar
                    if((communicationTemp.RecordTypeId == standarComRecordTypeId &&  DeactivatePushNotificationForOldProcess)
                    ){

                      if(!iniziativeRelatedToComunication.isEmpty())
                        for(Iniziative_Marketing__c iniMarketingTemp : iniziativeRelatedToComunication.values()){
                        
                            if(iniMarketingTemp.Communication_code__c == communicationTemp.Communication_Code__c ){
                                // da aggiungere i campi dinamici
                                communicationTemp.Titolo__c = dinamicFieldsTemplate(iniMarketingTemp.Titolo__c, communicationTemp.Insurance_Contract_Number__c, accForNotification, communicationTemp);
                                communicationTemp.Sottotitolo__c = dinamicFieldsTemplate(iniMarketingTemp.Sottotitolo__c, communicationTemp.Insurance_Contract_Number__c, accForNotification, communicationTemp);
                                communicationTemp.Message_Push_Notification__c = dinamicFieldsTemplate(iniMarketingTemp.Contenuto__c, communicationTemp.Insurance_Contract_Number__c, accForNotification, communicationTemp);
                                communicationTemp.Short_Message__c = dinamicFieldsTemplate(iniMarketingTemp.Short_Message__c, communicationTemp.Insurance_Contract_Number__c, accForNotification, communicationTemp);                 
                                communicationTemp.Message__c = dinamicFieldsTemplate(iniMarketingTemp.Message__c, communicationTemp.Insurance_Contract_Number__c, accForNotification, communicationTemp);                 
                                
                                communicationTemp.Testo_CTA__c = iniMarketingTemp.Testo_CTA__c;
                                communicationTemp.URL_CTA__c = iniMarketingTemp.URL_CTA__c;
                                communicationTemp.URL_Immagine__c = iniMarketingTemp.URL_Immagine__c;
                                communicationTemp.Visibilita_nel_centro_notifiche__c = iniMarketingTemp.Visibilita_nel_centro_notifiche__c;
                                communicationTemp.Invio_push__c = iniMarketingTemp.Invio_push__c;
                                communicationTemp.Tipo_notifica_su_Centro_Notifiche__c = iniMarketingTemp.Tipo_notifica_su_Centro_Notifiche__c;
                                communicationTemp.Notification_Typology__c = iniMarketingTemp.Canale__c;
                                String descrip = String.valueOf(iniMarketingTemp.Descrizione_dell_iniziativa__c);
                                communicationTemp.Communication_Description__c = descrip.length()>254 ? descrip.abbreviate(255): descrip;

                                communicationTemp.Iniziativa_Marketing_Id__c = iniMarketingTemp.id ;
                            break; 
                            }          
                        }//end for loop list iniziativaMarketing

                    }else if(communicationTemp.RecordTypeId == migrazioniProcesDigitalRecordTypeId){
                        //logica solo per Migrazione
                    }

                    //per tutti RT nuovi o vecchi il contacMaster va aggiornato
                    if(accForNotification != null)
                        if(accForNotification.Contact_Master_Id__c != null){
                            communicationTemp.Contact_Master_Id__c = accForNotification.Contact_Master_Id__c;
                    }

                }//end for loop comm2cust
            }//end if list empty
        }
    
        } catch (Exception ex ) {
            ApplicationLogHelper.ERROR('CommunicationToCustomerHandler', ex.getmessage(), ex.getStackTraceString());
        }
     
    }  
    
    public void beforeUpdate(SObject oldSo, SObject so){}  
   
    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList){}
    
    public void beforeDelete(SObject so){} 
    
    public void beforeDelete(List<SObject> soList){}

    public void afterInsert(SObject so){ }

    public void afterInsert(List<SObject> soList){}

    public void afterUpdate(SObject oldSo, SObject so){}

    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList){} 

    public void afterDelete(SObject so){} 
    
    public void afterUndelete(SObject so){} 
    
    public void afterDelete(List<SObject> soList){}  

    public void afterUndelete(List<SObject> soList){}         

    public void andFinally(){}  

    public String dinamicFieldsTemplate(String line, String InsuranceContractNumber ,Account cliente, Communications_to_customer__c commBeforeInsert){

       //trovare una forma di usare i Metadata custom per fare questo metodo senza tanto codice 
        Map<String,String> Wildcards = new Map<String,String>();

        String wordFill = '';
        String Nome = cliente.Name;
        //String Phone = String.isBlank(cliente.Mobile_Master_AAI__c )? ' ' :cliente.Additional_Phone__c ;// controllare altri numeri d telefono
        String MobilePhone =String.isBlank(cliente.Mobile_Master_AAI__c )? ' ' :cliente.Mobile_Master_AAI__c ;// controllare altri numeri d telefono
        String Email = String.isBlank(cliente.Email_Master_AAI__c )? ' ' :cliente.Email_Master_AAI__c ;
        String CifNumberDoc = String.isBlank(cliente.CIF_Number__c )? ' ' :cliente.CIF_Number__c ;
        String documentType = String.isBlank(cliente.CIF_Document_type__c )? ' ' :cliente.CIF_Document_type__c ;
        String NumeroPoliza =   String.isBlank(InsuranceContractNumber)? '':InsuranceContractNumber;

        String AgencyHolder = String.isBlank(cliente.AAI_Agency__r.Agency_Holder__c)? ' ' :cliente.AAI_Agency__r.Agency_Holder__c; 
        String AgencyCode = String.isBlank(cliente.AAI_Agency__r.Agency_Code__c)? ' ' :cliente.AAI_Agency__r.Agency_Code__c; 
        String AgencyName = String.isBlank(cliente.AAI_Agency__r.Name)? ' ' :cliente.AAI_Agency__r.Name; 
        String AgencyEmail = String.isBlank(cliente.AAI_Agency__r.Agency_email__c)? ' ' :cliente.AAI_Agency__r.Agency_email__c; 
        String AgencyPhone = String.isBlank(cliente.AAI_Agency__r.MobilePhone__c)? ' ' :cliente.AAI_Agency__r.MobilePhone__c;

        String NumeroSinistro = String.isBlank(commBeforeInsert.Numero_Sinistro__c)? ' ' :commBeforeInsert.Numero_Sinistro__c;
        
        if(line != null){
            wordFill = line.replaceAll('%%Nome%%', Nome); 
           // wordFill = wordFill.replaceAll('%%Phone%%', Phone);
            wordFill = wordFill.replaceAll('%%MobilePhone%%', MobilePhone);
            wordFill = wordFill.replaceAll('%%Email%%', Email);
            wordFill = wordFill.replaceAll('%%NumeroDocumento%%', CifNumberDoc);
            wordFill = wordFill.replaceAll('%%TipoDocumento%%', documentType);
            wordFill = wordFill.replaceAll('%%Insurance_Contract_Number__c%%', NumeroPoliza);
    
            wordFill = wordFill.replaceAll('%%AgencyHolder%%', AgencyHolder);
            wordFill = wordFill.replaceAll('%%AgencyCode%%', AgencyCode);
            wordFill = wordFill.replaceAll('%%AgencyName%%', AgencyName);    
            wordFill = wordFill.replaceAll('%%AgencyEmail%%', AgencyEmail);
            wordFill = wordFill.replaceAll('%%AgencyPhone%%', AgencyPhone);
            wordFill = wordFill.replaceAll('%%NumeroSinistro%%', NumeroSinistro); 
        }

        /*  
        %%Nome%%
        %%Phone%%
        %%MobilePhone%% (dati contatto cliente)
        %%Email%%
        %%NumeroDocumentoIdentita%%
        %%Insurance_Contract_Number__c%%

        %%AgencyHolder%%
        %%AgencyCode%%
        %%AgencyName%%
        %%AgencyEmail%%
        %%AgencyPhone%%
        */

        return wordFill;
    }
}
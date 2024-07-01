public without sharing class LeadTrackingManagement {
    
    public static boolean trackingDone = false;
    public static boolean testingUnable = false;
    public class InputWrapper{
        public List<Lead> leadNew;
        public List<Lead> leadOld;
        public boolean isUpdate;
    }

    private class MapEntry{
        public Lead lNew;
        public Lead lOld;
        public String leadStatus;
        public List<Tracking_History_Lead__c> oldTrackings;
        public MapEntry(Lead lNew, Lead lOld, List<Tracking_History_Lead__c> oldTrackings, String leadStatus){
            this.lNew = lNew;
            this.lOld = lOld;
            this.leadStatus = leadStatus;
            this.oldTrackings = oldTrackings;
        }
    }

    public static void manageLead(InputWrapper i){
        if(!trackingDone){
            system.debug('TrackingDone: '+trackingDone);
            Map<String, MapEntry> leads = new Map<String, mapEntry>();
            if(i.isUpdate){
                
                // creazione mappa con entry in O(n), invece di O(n^2)
                Map<String, Lead> mapNewFromTrigger = new Map<String, Lead>();
                Map<String, Lead> mapOld = new Map<String, Lead>();
                Map<String, List<Tracking_History_Lead__c>> mapTracking = new Map<String, List<Tracking_History_Lead__c>>();
                for(Lead l : i.leadNew) { mapNewFromTrigger.put(l.Id, l); }
                for(Lead l : i.leadOld) { mapOld.put(l.Id, l); }
                if(mapNewFromTrigger.keySet().size()!=0){
                    List<Tracking_History_Lead__c> temp = [Select id, lead__c, Lead_Status__c, New_Owner__c from Tracking_History_Lead__c where Lead__c in: mapNewFromTrigger.KeySet() order by createdDate desc];
                    for(Tracking_History_Lead__c trackTemp : temp){
                        if(mapTracking.containsKey(trackTemp.Lead__c)){
                            mapTracking.get(trackTemp.Lead__c).add(trackTemp);
                        }
                        else{
                            List<Tracking_History_Lead__c> tempList = new List<Tracking_History_Lead__c>();
                            tempList.add(trackTemp);
                            mapTracking.put(trackTemp.Lead__c, tempList);
                        }
                    }

                    List<Lead> LeadNewQuery = [Select id, Ultima_data_di_riassegnazione__c, ownerId, Dettaglio__c, toLabel(Status), IsConverted, Owner.Name, Agency_Code__c, Agency__c, CreatedDate, CreatedbyId, Numero_assegnazioni_eseguite__c from Lead where id in:mapNewFromTrigger.keySet() ];
                    Map<String, Lead> mapNew = new Map<String, Lead> ();
                    for(Lead nL:LeadNewQuery){
                        mapNew.put(nL.Id, nL);
                    }

                    for(String l_Id : mapNew.KeySet()){
                      	String LeadStatus = mapNewFromTrigger.get(l_Id).Status;
                        Lead lNew = mapNew.get(l_Id);
                        Lead lOld = mapOld.get(l_Id);
                        List<Tracking_History_Lead__c> oldTracks = mapTracking.get(l_Id);
                        if(LeadStatus != lOld.Status || lNew.OwnerId != lOld.OwnerId || (lNew.IsConverted && !lOld.IsConverted))
                            leads.put(l_Id, new MapEntry(lNew, lOld, oldTracks, LeadStatus));
                    }
                }
                    
                
            }
            else{
                Set<Id> LeadsIds = new Set<Id>();
                
                for(Lead l : i.leadNew) {
                    LeadsIds.add(l.Id);
                }
                for(Lead l : [Select id, Ultima_data_di_riassegnazione__c, ownerId, Dettaglio__c, toLabel(Status), IsConverted, Owner.Name, Agency_Code__c, Agency__c, CreatedDate, Numero_assegnazioni_eseguite__c from Lead where id in:LeadsIds ]){ 
                    Leads.put(l.id,new MapEntry(l, null, null, null)); 
                }
            }
    
            try{
                if(Leads.keySet().size()!=0)
                    trackChanges(Leads, i.isUpdate);
            }
            catch(Exception ex){
                try{
                    System.debug('Eccezione su application log: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
                    ApplicationLogHelper.ERROR('LeadTrackingManagement', ex.getMessage(), ex.getStackTraceString());
                }
                catch(Exception e){
                    System.debug('Eccezione su application log: ' + e.getMessage() + '\n' + e.getStackTraceString());
                }
            }
        }
    }

    private static Map<String, Id> getMapFromLeads(Map<String, MapEntry> Leads){
        Set<String> AgencyCodes = new Set<String>();
        for(String lId : Leads.keySet()){
            String agCode = Leads.get(lId).lNew.Agency_Code__c;
            if(String.isNotBlank(agCode)){
                AgencyCodes.add(agCode);
            }
        }
        List<Account> agencies = [Select id, agency_code__c from Account where agency_Code__c in :AgencyCodes AND recordtype.developername = 'Agency'];
        Map<String,Id> mapToRet = new Map<String, Id>();
        for(Account a:agencies){
            mapToRet.put(a.Agency_Code__c, a.id);
        }
        return mapToRet;
    }

    private static void trackChanges(Map<String, MapEntry> Leads, boolean isUpdate){
        AAI_Code_Variables__c accName = AAI_Code_Variables__c.getValues('LeadTrackingDefaultAccount');
        String defAccName = accName!=null ? accName.Value__c : '';
        List<Account> defaultAgencyAccount = [Select id from Account where name = :defAccName and RecordType.DeveloperName ='Agency' limit 1];
        Map<String, Id> agencyIdsByCode = getMapFromLeads(Leads);
        Account defAccount = defaultAgencyAccount.size()!=0? defaultAgencyAccount.get(0):null; //definire filtri per account di agenzia di default
        List<SObject> toInsert = new List<SObject>();
        for(String l_Id : Leads.KeySet()){
            MapEntry m = Leads.get(l_Id);
            Lead lNew = m.lNew;
            Lead lOld = m.lOld;
            String LeadStatus = m.leadStatus;
            List<Tracking_History_Lead__c> oldTracks = Leads.get(l_Id).oldTrackings;
            SObject newTrack = new Tracking_History_Lead__c();
            newTrack.put('Lead__c', lNew.Id);
            newTrack.put('New_Agency_Code__c', lNew.Agency_Code__c);
            newTrack.put('Dettaglio_Fonte_Lead__c', lNew.Dettaglio__c);
            newTrack.put('Lead_Status__c', lNew.Status);
            newTrack.put('New_Owner__c',lNew.Owner.Name);
            if(String.isNotBlank(lNew.Agency_Code__c) && agencyIdsByCode.containsKey(lNew.Agency_Code__c)){
                newTrack.put('Agency__c', agencyIdsByCode.get(lNew.Agency_Code__c));
            }
            else{
                newTrack.put('Agency__c', defAccount.id); //se defAccount è null, il record non viene creato. sarà gestito da ApplicationLog
            }
            newTrack.put('Last_Assignment_Date__c', lNew.Ultima_data_di_riassegnazione__c);
            newTrack.put('Number_of_Assign__c', lNew.Numero_assegnazioni_eseguite__c);
            if(lOld != null){
                system.debug('il vecchio lead è presente');
                newTrack.put('Old_Agency_Code__c', lOld.Agency_Code__c);
                
            }
            if(oldTracks != null && !oldtracks.isEmpty()){
                SObject old = oldtracks.get(0);
                newTrack.put('Old_Lead_Status__c', old.get('Lead_Status__c'));
                newTrack.put('Old_Owner__c', old.get('New_Owner__c'));
            }

            //gestione attività

            DateTime actualDate = DateTime.now();
            DateTime oneMinuteBefore = actualDate.addMinutes(-1);
            Set<String> atts=new Set<String>();
            if(/*!isUpdate || lOld == null ||(lOld!= null && lNew.id != lOld.Id)*/
                lNew.CreatedDate >= oneMinuteBefore && lNew.CreatedDate <= actualDate && ((oldTracks != null && oldtracks.isEmpty()) || oldTracks == null)){
                atts.add('Lead Creato');
            }
            else if(lOld != null){
                
                if(lNew.OwnerId != lOld.OwnerId){
                    
                    if(((String)lNew.OwnerId).startsWith('005') && lNew.OwnerId==UserInfo.getUserId()){
                        atts.add('Preso in carico');
                    }
                    else{
                        if(lNew.Owner.Name.startsWith('Coda Agenzia')){
                            if(lNew.Numero_assegnazioni_eseguite__c == 1){
                                atts.add('Prima Assegnazione');
                            }
                            else{
                                atts.add('Riassegnazione');
                            }
                        }
                        else{
                            atts.add('Cambio Titolare');
                        }                        
                    }
                }
                if(LeadStatus != lOld.Status){
                    atts.add('Cambio Stato');
                    if(lOld.Status == 'To be processed' && !lNew.Owner.Name.startsWith('Coda Agenzia')){
                        atts.add('Preso in carico');
                    }
                }
                if(lNew.IsConverted && !lOld.IsConverted){
                    atts.add('Conversione');
                }
            }
            for(String att:atts){
                newTrack.put('Activity__c', att);
                toInsert.add(newTrack.clone(false,false,false,false));
            }
        }

        try{
            if(testingUnable){
                throw new DMLException('UNABLE_TO_LOCK_ROW');
            }
            insert toInsert;
            trackingDone = isUpdate; //viene messo a true solo se il metodo viene chiamato dall'update, in modo da tracciare un aggiornamento solo.
        }
        catch(DMLException ex){
            try{
                if(ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW'))
                    insert BulkRequest_TrackLeadHistory.prepareRequest(toInsert, false, 0);
                else
                    ApplicationLogHelper.ERROR('LeadTrackingManagement', ex.getMessage(), ex.getStackTraceString());
            }
            catch(Exception e){
                ApplicationLogHelper.ERROR('LeadTrackingManagement', ex.getMessage(), ex.getStackTraceString());
            }
        }
        catch(Exception ex){
            try{
                System.debug('Eccezione su application log: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
                ApplicationLogHelper.ERROR('LeadTrackingManagement', ex.getMessage(), ex.getStackTraceString());
            }
            catch(Exception e){
                System.debug('Eccezione su application log: ' + e.getMessage() + '\n' + e.getStackTraceString());
            }
        }

    }

}
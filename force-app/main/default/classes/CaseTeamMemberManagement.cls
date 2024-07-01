public without sharing class CaseTeamMemberManagement {

    public static void processCaseTeam(List<Case> Cases, Map<String,String> ownerIdProfileNameMap,Map<String, String> ownerIdRoleNameMap){
        try{
		Set<String> RecordtypeDevNames = new Set<String>();
        for(case c : cases){
            RecordtypeDevNames.add(c.Case_Record_Type_Formula__c);
        }        
        String defaultKey = [Select value__c from NewWorkingTimesMapping__mdt where developername = 'DefaultRole'].value__c;
        List<String> TeamRoleNameString = new List<String>();
        system.debug('+++Cases:' + Cases);
    	List<TeamMemberMap__mdt> configurationList = [SELECT Profilo_Advisor__c,
                                                      Ruolo_Advisor__c,
                                                      Ruolo_Team_Member__c,
                                                      CaseRecordType__c,
                                                      SLA__c 
                                                      FROM TeamMemberMap__mdt where CaseRecordtype__c in :RecordtypeDevNames or CaseRecordType__c = '*'];
        
        Map<String,TeamMemberMap__mdt> configurationMap = new Map<String,TeamMemberMap__mdt>();
        for(TeamMemberMap__mdt temp : configurationList){
            String tempKey;
            if(temp.Ruolo_Advisor__c == null){
                tempKey = temp.CaseRecordType__c.toLowerCase() + '_' + temp.Profilo_Advisor__c.toLowerCase()+'_*';
            }
            else{
                tempKey = temp.CaseRecordType__c.toLowerCase() + '_' + temp.Profilo_Advisor__c.toLowerCase()+'_'+temp.Ruolo_Advisor__c.toLowerCase();
            }
            configurationMap.put(tempKey,temp);
            TeamRoleNameString.add(temp.Ruolo_Team_Member__c);
        }
        
        Map<String, Id> mapTeamRoleId = new Map<String,Id>();
        for(CaseTeamRole temp : [Select id, name from caseTeamRole where name in:TeamRoleNameString]){
            mapTeamRoleId.put(temp.name, temp.id);
        }
        
        List<String> CaseIdAndCaseTeam = new List<String>();
        for(CaseTeamMember ctm : [Select ParentId, MemberId from CaseTeamMember where ParentId in:Cases]){
            CaseIdAndCaseTeam.add(String.valueOf(ctm.ParentId)+String.valueOf(ctm.MemberId));
        }
        List<CaseTeamMember> CTMToInsert = new List<CaseTeamMember>();
        System.Debug('OwnerIDProfileNameMap Debug\n: keys: ' + ownerIdProfileNameMap.keySet() +'\nvalues:'+ ownerIdProfileNameMap.values());
        System.Debug('ownerIdRoleNameMap Debug\n: keys: ' + ownerIdRoleNameMap.keySet() +'\nvalues:'+ ownerIdRoleNameMap.values());
        for(Case c : Cases){
            if(!String.valueOf(c.OwnerId).startsWith('00G') && (CaseIdAndCaseTeam.isEmpty() || !CaseIdAndCaseTeam.contains(String.valueOf(c.Id)+String.valueOf(c.OwnerId)))){
                Id role;
                String Key, KeyWithoutRole, key2;
                String keyWithoutRecType, KeyWithoutRoleAndRT;
                if(ownerIdProfileNameMap.containsKey(String.valueOf(c.OwnerId)) 
                   && ownerIdProfileNameMap.get(String.valueOf(c.OwnerId))!=null
                   && ownerIdRoleNameMap.containsKey(String.valueOf(c.OwnerId))
                   && ownerIdRoleNameMap.get(String.valueOf(c.OwnerId))!=null){
                    Key = c.Case_Record_Type_Formula__c.toLowerCase()+'_'+ownerIdProfileNameMap.get(String.valueOf(c.OwnerId)).toLowerCase() +'_'+ ownerIdRoleNameMap.get(String.valueOf(c.OwnerId)).toLowerCase();
                	KeyWithoutRole = c.Case_Record_Type_Formula__c.toLowerCase()+'_'+ownerIdProfileNameMap.get(String.valueOf(c.OwnerId)).toLowerCase()+'_*';
                    keyWithoutRecType = '*_'+ownerIdProfileNameMap.get(String.valueOf(c.OwnerId)).toLowerCase() +'_'+ ownerIdRoleNameMap.get(String.valueOf(c.OwnerId)).toLowerCase();
                    KeyWithoutRoleAndRT = '*_'+ownerIdProfileNameMap.get(String.valueOf(c.OwnerId)).toLowerCase()+'_*';
                    
                }
                if(Key!= null && KeyWithoutRole != null && keyWithoutRecType!= null && KeyWithoutRoleAndRT != null){
                    if(configurationMap.containsKey(Key))
                    	key2 = configurationMap.get(Key).Ruolo_Team_Member__c;
                    else if(configurationMap.containsKey(keyWithoutRecType))
                        key2 = configurationMap.get(keyWithoutRecType).Ruolo_Team_Member__c;
                    else if(configurationMap.containsKey(KeyWithoutRole))
                        key2 = configurationMap.get(KeyWithoutRole).Ruolo_Team_Member__c;
                    else if(configurationMap.containsKey(KeyWithoutRoleAndRT))
                        key2 = configurationMap.get(KeyWithoutRoleAndRT).Ruolo_Team_Member__c;
                    else{
                    key2 = configurationMap.get(defaultKey.toLowerCase()).Ruolo_Team_Member__c;
                }
                }
                else{
                    
                    key2 = configurationMap.get(defaultKey.toLowerCase()).Ruolo_Team_Member__c;
                }
                
                if(mapTeamRoleId.containsKey(key2))
                    CTMToInsert.add(
                        new CaseTeamMember(
                            TeamRoleId = mapTeamRoleId.get(key2),
                            MemberId = c.OwnerId,
                            ParentId = c.Id
                        )
                    );
            }
        }
        if(!CTMToInsert.isEmpty()){
                //insert(CTMToInsert);
                Database.SaveResult[] srList = Database.insert(CTMToInsert, false);
                List<ApplicationLogHelper.ErrorWrapper> Errors = new List<ApplicationLogHelper.ErrorWrapper>();
                Integer i = 0;
                for (Database.SaveResult sr : srList){

                    if (!sr.isSuccess()){
                        String ErrorMessage = '';
                        String ErrorDetail = 'Insert Case Team Member on caseId: ' + CTMToInsert.get(i).ParentId + ' with owner: '+ CTMToInsert.get(i).MemberId;
                        for(Database.Error err : sr.getErrors()){
                            ErrorMessage += err.message + '\n';
                        }
                        Errors.add(new ApplicationLogHelper.ErrorWrapper(ErrorMessage, ErrorDetail));

                    }
                    i++;
                }
                if(!Errors.isEmpty()){
                    ApplicationLogHelper.LogErrors('CaseTeamMemberManagement', Errors);
                }
        }
        }
            catch(Exception ex){
                try{    
                ApplicationLogHelper.ERROR('CaseTeamMemberManagement', ex.getmessage(), ex.getStackTraceString());
                }catch(Exception e){
                    System.debug(System.LoggingLevel.ERROR,'Exception: ' + e.getmessage() + '\tStackTrace: '+e.getStackTraceString());
                }        
            }
    }
    
}
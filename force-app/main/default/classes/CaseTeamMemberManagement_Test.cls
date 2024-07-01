@isTest
public class CaseTeamMemberManagement_Test {
   
    Static Map<String,String> OwnerIdProfileNameMap = new Map<String,String>();
    Static Map<String,String> OwenrIdRoleNameMap = new Map<String,String>();
    
    @testSetup static void setup() {
    	ID SysAdminProfile = [Select id from profile where name = 'System Administrator' OR name = 'Amministratore del sistema'].ID;

        
        ID userroleAAI= [Select id from userRole where name = 'AXA Assicurazioni'].ID;
        
        list<User> userToInsert = new List<User>();
        User tempUser ;
        tempUser = new User(username = 'UserNameTest1@test.test',
                                 LastName = 'Test1',
                                 Alias = 'Ttest',
                                 Email = 'UserNameTest@test.test',
                                 TimeZoneSidKey = 'Europe/Rome',
                                 LocaleSidKey = 'it',
                                 EmailEncodingKey = 'ISO-8859-1',
                                 ProfileId = SysAdminProfile,
                                 LanguageLocaleKey = 'it',
                                 UserRoleId = userroleAAI);
        usertoinsert.add(tempuser);
        insert userToInsert;
        OwnerIdProfileNameMap.put(userToInsert[0].ID,'System Administrator');
        OwenrIdRoleNameMap.put(userToInsert[0].ID,'AXA Assicurazioni');
    }
    
    @isTest
    static void test1(){
         ID BusinessHoursDefault = [Select id from businesshours where isDefault = true limit 1].id;
        List<MPS_Code_Variables__c> listCustomSetting = new List<MPS_Code_Variables__c>();
        listCustomSetting.add(new MPS_Code_Variables__c (Name = 'BusinessHours_Default', Value__c = BusinessHoursDefault));
        insert listCustomSetting;
        
        Test.startTest();
        recordtype recType = [Select id, name, developerName from recordtype where sobjectType = 'Case' and Name = 'Agenzia dipendenti'];
        User userID = [Select id from user where username = 'UserNameTest1@test.test'];
        system.runAs(userID){
        OwnerIdProfileNameMap.put(userID.ID,'System Administrator');
        OwenrIdRoleNameMap.put(userID.Id,'AXA Assicurazioni');
        List<Case> caList = new List<Case>();
        caList.add(new Case(status = 'Open', recordtype = recType, ownerId = userID.Id));
        insert(caList);
        List<Case> caseInserted = [Select Status, recordtype.id, Case_Record_Type_Formula__c, ownerId from case where id in: caList];
        CaseTeamMemberManagement.processCaseTeam(caseInserted, OwnerIdProfileNameMap,OwenrIdRoleNameMap);
        }
        
        test.stopTest();
    }
    
}
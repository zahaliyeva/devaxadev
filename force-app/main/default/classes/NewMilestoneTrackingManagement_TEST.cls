@isTest
public with sharing class NewMilestoneTrackingManagement_TEST {
    Static Map<String,String> OwnerIdProfileNameMap = new Map<String,String>();
    Static Map<String,String> OwnerIdRoleNameMap = new Map<String,String>();
    @TestSetup
    static void makeData(){
        
        ID HD1Profile = [Select id from profile where name = 'AAI - Supporto HD1 - Lightning'].ID;
        Group newGroup = new GRoup(Name = 'HD2 IT TEST', DeveloperName = 'HD2_IT_TEST', type = 'Queue');
        insert newGroup;
        
        QueuesObject testQueue = new QueueSObject(QueueID = newGroup.id, SobjectType = 'Case');
        insert testQueue;

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
                                 ProfileId = HD1Profile,
                                 LanguageLocaleKey = 'it',
                                 UserRoleId = userroleAAI);
        usertoinsert.add(tempuser);
        insert userToInsert;
        System.runAs(userToInsert[0]){
        OwnerIdProfileNameMap.put(userToInsert[0].Id,'AAI - Supporto HD1 - Lightning');
        OwnerIdRoleNameMap.put(userToInsert[0].ID,'AXA Assicurazioni');

        Case c = new Case(
            RecordtypeId = RecordTypeUtility.getRecordTypeIdByDeveloperName('Case','Axa_Assicurazioni'),
            LOB__c = 'Test',
            Category__c = 'Test',
            ownerId = userToInsert[0].Id,
            Status = 'Assigned' 
        );

        insert c;
        Mapping_Automatic_Owner_NMA__c m = new Mapping_Automatic_Owner_NMA__c(LOB__c = 'Test',Category__c = 'Test', Recordtype__c = 'Axa_Assicurazioni',Coda_di_Destinazione__c = 'HD2 IT TEST');
        Insert m;
        ID BusinessHoursDefault = [Select id from businesshours where isDefault = true limit 1].id;
        List<MPS_Code_Variables__c> listCustomSetting = new List<MPS_Code_Variables__c>();
        
        listCustomSetting.add(new MPS_Code_Variables__c (Name = 'Ivass41Solleciti', Value__c ='0;0;0;0;0'));
        listCustomSetting.add(new MPS_Code_Variables__c (Name = 'BusinessHours_Default', Value__c = BusinessHoursDefault));
        insert listCustomSetting;
    } 
        

    }

    @IsTest
    public static void Test1(){
        
        test.startTest();
        List<Case> c = [Select id, ownerId, Status from Case];
        Map<String,Case> oldMap = new Map<String, Case> ();
        
        for(Case temp : c){
            oldMap.put(temp.id, new Case(status = 'Assigned'));
            OwnerIdProfileNameMap.put(temp.Id,'AAI - Supporto HD1 - Lightning');
        OwnerIdRoleNameMap.put(temp.ID,'AXA Assicurazioni');
        }
        NewMilestoneTrackingManagement.processMilestoneandWorkingTime(c, OldMap, ownerIdProfileNameMap, ownerIdRoleNameMap);
        

        
        List<Case> newList = new List<Case>();
        c = [Select id, ownerId, status, HD3_IT__c, CaseNumber, Current_Owner_Queue__c from Case];
        
        case oldC = (case) c.get(0);
        case newC = (case) c.get(0);
        Map<String,Case> oldMap2 = new Map<String, Case> ();
        oldMap.put(newc.ID, oldc);
        String newOwner = SendCaseAutomaticQueueController.getOwnerIdForSendAutomatic(newC.id, '');
        system.debug(newOwner);
        newC.ownerID = newOwner;
        newC.Current_Owner_Queue__c = 'HD2_IT_CRM';
        newC.status = AP_Constants.caseStatusGestioneSpecialistica;
        newList.add(newC);
        update newlist;
        NewMilestoneTrackingManagement.processMilestoneandWorkingTime(c, OldMap, ownerIdProfileNameMap, ownerIdRoleNameMap);

        test.stopTest();
        
    } 
    @IsTest
    public static void Test2(){
        List<Case> c = [Select id, ownerId, Status from Case];
        Map<String,Case> oldMap = new Map<String, Case> ();
        
        for(Case temp : c){
            oldMap.put(temp.id, new Case(status = 'Assigned'));
            OwnerIdProfileNameMap.put(temp.Id,'AAI - Supporto HD1 - Lightning');
        OwnerIdRoleNameMap.put(temp.ID,'AXA Assicurazioni');
        }
        NewMilestoneTrackingManagement.processMilestoneandWorkingTime(c, OldMap, ownerIdProfileNameMap, ownerIdRoleNameMap);

        user u = [Select id from user where alias = 'Ttest' and LastName = 'Test1' limit 1];
        List<Case> newList = new List<Case>();
         c = [Select id, ownerId, status, HD3_IT__c, CaseNumber, Current_Owner_Queue__c from Case];
        test.startTest();
        
        case oldC = (case) c.get(0);
        case newC = (case) c.get(0);
        oldMap.put(newc.ID, oldc);
        OwnerIdProfileNameMap.put(newC.ownerId,'AAI - Supporto HD1 - Lightning');
        OwnerIdRoleNameMap.put(newC.ownerId,'AXA Assicurazioni');
        
        
        newC.ownerID = u.Id;
        newC.Current_Owner_Queue__c = 'HD2_IT_CRM';
        newC.status = 'Assigned';
        newList.add(newC);
        update newlist;
        NewMilestoneTrackingManagement.processMilestoneandWorkingTime(c, OldMap, ownerIdProfileNameMap, ownerIdRoleNameMap);

    test.stopTest();
    } 
    @IsTest
    public static void Test3(){
        
        
        
}
}
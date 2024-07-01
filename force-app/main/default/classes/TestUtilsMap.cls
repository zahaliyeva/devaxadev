@IsTest
public class TestUtilsMap {
    private static string mapName = 'map';


    @isTest
    static void test_getMapFromList() {
        List<Case> caseList = new List<Case>();
        caseList.add(new Case(Subject='sub1', Type='Anticipi', Origin='Email'));
        caseList.add(new Case(Subject='sub2', Type='Anticipi', Origin='Email'));
        caseList.add(new Case(Subject='sub3', Type='Pagamenti', Origin='Email'));
        caseList.add(new Case(Subject='sub4', Type='Pagamenti', Origin='Email'));
        caseList.add(new Case(Subject='sub5', Type='Anticipi', Origin='Email'));
        caseList.add(new Case(Subject='', Type='Anticipi', Origin='Email'));
        caseList.add(new Case(Subject='sub6', Type='', Origin='Email'));
        caseList.add(new Case(Subject='sub7', Type='', Origin='Email'));
        caseList.add(new Case(Subject='', Type='', Origin='Email'));

        Map<String, List<Case>> caseMap = (Map<String, List<Case>>) UtilsMap.getMapFromList(caseList, 'Type');

        List<Case> anticipi = caseMap.get('Anticipi');
        Set<String> anticipiSubjects = new Set<String>();

        System.assert(anticipi != null && anticipi.size() > 0);
        for(Case c : anticipi) {
            anticipiSubjects.add(c.Subject);
        }

        System.assert(anticipiSubjects.contains('sub1'));
        System.assert(anticipiSubjects.contains('sub2'));
        System.assert(anticipiSubjects.contains('sub5'));
        System.assert(anticipiSubjects.contains(''));


        List<Case> pagamenti = caseMap.get('Pagamenti');
        Set<String> pagamentiSubjects = new Set<String>();

        System.assert(pagamenti != null && pagamenti.size() > 0);
        for(Case c : pagamenti) {
            pagamentiSubjects.add(c.Subject);
        }

        System.assert(pagamentiSubjects.contains('sub3'));
        System.assert(pagamentiSubjects.contains('sub4'));

        List<Case> blank = caseMap.get('');
        Set<String> blankSubjects = new Set<String>();

        System.assert(blank != null && blank.size() > 0);
        for(Case c : blank) {
            blankSubjects.add(c.Subject);
        }

        System.assert(blankSubjects.contains('sub6'));
        System.assert(blankSubjects.contains('sub7'));
        System.assert(blankSubjects.contains(''));
        
        
    }

    @isTest 
    public static void Coverage(){
        Map<String,Object> dest=new Map<String,Object>();
        Map<String,Object> source=new Map<String,Object>();
        dest.put('key',(Object)'value');
        source.put('key2',(Object)'value2');
        List<SObject> solist= new List<SObject>();
        Sobject o= Schema.getGlobalDescribe().get('Account').newSObject();
        Sobject o2= Schema.getGlobalDescribe().get('Account').newSObject();

        Account acc = new Account(FirstName ='John',LastName= 'Smith', PersonEmail = 'john.smith@axa-italy-devtest.com');
        insert acc;

        o.put('Name',acc.id);
        o2.put('Name',acc.id);
        solist.add(o);
        solist.add(o2);

        Test.startTest();
        Map<String, SObject> res=UtilsMap.getMapFromListByUniqueKey(null,'');
        UtilsMap.getMapFromListByUniqueKey(solist,'Name');

        UtilsMap.getMapFromList(null,'');
        UtilsMap.getMapFromList(solist,'Name');

        UtilsMap.getIdMapFromList(null,'');
        UtilsMap.getIdMapFromList(solist,'Name');

        UtilsMap.getValueSetFromSObjectList(null,'');
        UtilsMap.getValueSetFromSObjectList(solist,'Name');

        UtilsMap.getIdSetFromSObjectList(null,'');
        UtilsMap.getIdSetFromSObjectList(solist,'Name');

        UtilsMap.putAllIfNotPresent(source,dest);
        Test.stopTest();
        
        Assert.areEqual(new Map<String, SObject>(),res);
    }
}
/*------------------------------------------------------------------------
Author:        Dario Bovolenta
Company:       Deloitte
Class:         BlackListAccountReprocessingBatch_TEST
Description:   Test class of BlackListAccountReprocessingBatch class
            
History

25/06/2018     Dario Bovolenta - Created
----------------------------------------------------------------------------*/

@istest
public class BlackListAccountReprocessingBatch_TEST{

    @testSetup  //preparing test database
    public static void setup() {

        list<AAI_Code_Variables__c> acvList = new list<AAI_Code_Variables__c>();
        AAI_Code_Variables__c acv1 = new AAI_Code_Variables__c(Name='AXA_TECHNICAL_USER_ID', Value__c=UserInfo.getUserId());
        AAI_Code_Variables__c acv2 = new AAI_Code_Variables__c(Name='BLAccReprocessingBatchLastStartDate',Value__c= ''+DateTime.now().addDays(-2));
        AAI_Code_Variables__c acv3 = new AAI_Code_Variables__c(Name='BLAccReprocessingBatchLastEndDate', Value__c=''+DateTime.now().addDays(-2));
        AAI_Code_Variables__c acv4 = new AAI_Code_Variables__c(Name='BLAccReprocessingBatchEmailAddr', Value__c='test@email.com');
        acvList.add(acv1);
        acvList.add(acv2);
        acvList.add(acv3);
        acvList.add(acv4);

        insert acvList;



        Node__c agencyNode = new Node__c(Address__c= 'VIA 7 BERGAMO BG',
                                        Agency_holder__c= 'ASSICURAZIONI S.R.L. ',
                                        BlackList_Abitazione__c= true,
                                        BlackList_Auto__c= true,
                                        BlackList_Aziende__c= false,
                                        BlackList_Commerciale__c= true,
                                        BlackList_Infortuni__c= false,
                                        BlackList_Malattia__c= false,
                                        BlackList_Protection__c= false,
                                        BlackList_Rinnovo__c= false,
                                        BlackList_Saving__c= false,
                                        BlackList_Servizio__c= true,
                                        CAP__c= '24121',
                                        Email__c= 'email@email.com',
                                        Intermediary_type__c= 'AGENZIA',
                                        Management_type__c= 'APPALTO',
                                        Node_description__c= 'BERGAMO',
                                        Node_level__c= 7,
                                        Node_unique_code__c= '000828',
                                        Parent_node_unique_code__c= 'Z023',
                                        Phone__c= '02324324324',
                                        Tree_name__c= 'DIF',
                                        Ultima_modifica_blacklist__c=  Datetime.newInstance(2017, 3, 29));

        Node__c agencySubNode = new Node__c(Address__c= 'VIA 7 BERGAMO BG',
                                        Agency_holder__c= 'BROKER ASSICURAZIONI S.R.L. ',
                                        BlackList_Abitazione__c= false,
                                        BlackList_Auto__c= false,
                                        BlackList_Aziende__c= true,
                                        BlackList_Commerciale__c= true,
                                        BlackList_Infortuni__c= true,
                                        BlackList_Malattia__c= true,
                                        BlackList_Protection__c= true,
                                        BlackList_Rinnovo__c= true,
                                        BlackList_Saving__c= true,
                                        BlackList_Servizio__c= true,
                                        CAP__c= '24121',
                                        Email__c= 'email@email.com',
                                        Intermediary_type__c= 'BROKER RATIFICATO',
                                        Management_type__c= 'APPALTO',
                                        Node_description__c= 'BROKER UNO',
                                        Node_level__c= 8,
                                        Node_unique_code__c= '000828000005',
                                        Parent_node_unique_code__c= '000828',
                                        Phone__c= '02324324324',
                                        Tree_name__c= 'DIF',
                                        Ultima_modifica_blacklist__c=  Datetime.newInstance(2017, 2, 22));

        list<Node__c> nodesList = new list<Node__c>();
        nodesList.add(agencyNode);
        nodesList.add(agencySubNode);

        insert nodesList;

        List<Account> accounts = new List<Account>();

        Contact ContacforID = new Contact(LastName='Cooper');
        insert ContacforID;
        
        RecordType accRT = [SELECT Id,IsPersonType FROM RecordType WHERE SObjectType = 'Account' and DeveloperName = 'B2C_Client' ];
        
        //insert 100 person accounts
        for(integer i=0;i<100;i++) {

            // 3 account per testare il Contact_Master_Id__c
            if(i < 3){
                accounts.add(new Account(FirstName = 'TestAccount ' + i,
                                     LastName = 'AccountTest ' + i,
                                     PersonEmail = 'account_' + i + '_md3@mail.test',
                                     Phone = '0333333333',
                                     AAI_Codice_fiscale__c = 'MMMSDF12D34S234M',
                                     PersonMobilePhone = '3333333333',
                                     Nodes__c = '000828;000828000005',
                                     Contact_Master_Id__c = ContacforID.id,
                                     Data_Contact_Master_ID__c = System.now(),
                                     AAI_Agency_Reference_Code__c = '005014',
                                     RecordTypeID = accRT.id));
            }else if(i>3 && i < 6){
                accounts.add(new Account(FirstName = 'TestAccount ' + i,
                                     LastName = 'AccountTest ' + i,
                                     PersonEmail = 'account_' + i + '_md3@mail.test',
                                     Phone = '0333333333',
                                     AAI_Codice_fiscale__c = 'MMMSDF12D34S234M',
                                     PersonMobilePhone = '3333333333',
                                     Nodes__c = '000828;000828000005',
                                     AAI_Agency_Reference_Code__c = '005014',
                                     RecordTypeID = accRT.id));
            }else
            accounts.add(new Account(FirstName = 'TestAccount ' + i,
                                     LastName = 'AccountTest ' + i,
                                     PersonEmail = 'account_' + i + '_md3@mail.test',
                                     Phone = '0333333333',
                                     PersonMobilePhone = '3333333333',
                                     AAI_Codice_fiscale__c = 'AAASDF12D34S234M',
                                     Nodes__c = '000828;000828000005',
                                     AAI_Agency_Reference_Code__c = '005014',
                                     RecordTypeID = accRT.id));
        }
        insert accounts;        
        
    }
    
    
    static testmethod void runBatch() {

        Test.startTest();
        BlackListAccountReprocessingBatch theBatch = new BlackListAccountReprocessingBatch();
        theBatch.FullQuery = 'Select id, OwnerId,Contact_Master_Id__c,Data_Contact_Master_ID__c,Peferred_way_of_contact__c,AAI_Codice_fiscale__c,Fiscal_ID__c,Codice_fiscale_ListView__c, BlackList_Abitazione__c,BlackList_Auto__c,BlackList_Aziende__c,BlackList_Commerciale__c,BlackList_Infortuni__c,BlackList_Malattia__c,BlackList_Protection__c,BlackList_Rinnovo__c,BlackList_Saving__c,BlackList_Servizio__c,NDG__c,Nodes__c,Ultima_modifica_blacklist__c,AAI_Agency_Reference_Code__c from Account where RecordType.DeveloperName in (\'B2C_Client\',\'B2B_Client\') and CreatedDate = TODAY ORDER BY AAI_Agency_Reference_Code__c';
        Id batchId = Database.executeBatch(theBatch);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        List<Account> accList = [SELECT id,OwnerId,BlackList_Abitazione__c,BlackList_Auto__c,BlackList_Aziende__c,BlackList_Commerciale__c,BlackList_Infortuni__c,BlackList_Malattia__c,BlackList_Protection__c,BlackList_Rinnovo__c,BlackList_Saving__c,BlackList_Servizio__c,NDG__c,Nodes__c,Ultima_modifica_blacklist__c FROM Account where FirstName = 'TestAccount 0'];
        System.assertEquals(accList[0].Ultima_modifica_blacklist__c, Datetime.newInstance(2017, 3, 29));
        System.assertEquals(accList[0].BlackList_Servizio__c,true);
        System.assertEquals(accList[0].BlackList_Saving__c,true);
        System.assertEquals(accList[0].BlackList_Protection__c,true);
        
    }
    //for see all true on dev times *-+
    static testmethod void runBatchTimeFilter() {

        Test.startTest();
        BlackListAccountReprocessingBatch theBatch = new BlackListAccountReprocessingBatch();
        Id batchId = Database.executeBatch(theBatch);
        Test.stopTest();

        
    }
    
}
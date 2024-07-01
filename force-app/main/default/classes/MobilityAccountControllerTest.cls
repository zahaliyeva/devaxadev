@isTest
class MobilityAccountControllerTest {
	static testMethod void testAccountList() {
		List<Account> accounts = new List<Account> ();
		accounts.add(new Account(FirstName = 'Mario', LastName = 'Rossi', NDG__c = '12345'));
		insert accounts;


		Account acc = MobilityAccountController.getAccountByNdg('12345');
		Integer row = 5;
		String ndgId = '12345';
		acc.BlackList_Abitazione__c = true;
		acc.FirstName = 'Antonio';
		//Integer page = 0;
		//Integer perPage = 10;
		//Integer maxPerPage = 10;
		//Integer lengthList = 10;
        String accId = String.valueOf(acc.Id);

		MobilityAccountController.getContactHistory(row, ndgId);
		MobilityAccountController.updateAccountBlackList(acc);
		MobilityAccountController.updateAccount(acc);
        MobilityAccountController.getSobjectFields('Account');
        MobilityAccountController.getAccountById(acc.id);
		
		Test.startTest(); //separare le SOQL in due transc per il errore Too many SOQL queries: 101
		MobilityAccountController.getContactHistoryPage(ndgId, 0, 10, 10, 11);
        MobilityAccountController.getFilteredContactHistoryPage(ndgId, 0, 10, 10, 11,'ContactHistoryList');
        MobilityAccountController.getAccountById(accId);
		Test.stopTest();
	}
}
/*------------------------------------------------------------------------
   Author:        Davide Fabris
   Company:       Deloitte
   Class:         BulkRequest_BlackListProcess
   Description:   Class that updates accounts with the latest blaklist options
   History

   17/03/2017     Created - D.F.

   ----------------------------------------------------------------------------*/

   public class BulkRequest_BlackListProcess implements BulkRequestHandler {

	//These are the attributes to be used for the update START
		public List<String> listProcess {get; set;}
		public Datetime DataModifica {get; set;}//The date and time to write
	//These are the attributes to be used for the update END

	//These are attributes to manage some business logics
		public String Origin {get; set;}//If it is NODI flags are only added, otherwise I write exactly what specified on the attributes
		public Datetime DateRequest {get; set;}//Necessary to make sure that a late processing of the queue is not overwriting subsequent modifications. Necessary as DataModifica can be null to delete the date

		public List<String> process(List<Sobject> scope){
			List<String> errors = new List<String>();
			system.debug('thisinstance_Origin '+Origin);
			if (String.isempty(Origin)) Origin = 'NODI'; //in this way I only Add flags;
			system.debug('processing scope');

			//Expecting Account instance
			List<Account> accToUpdate = (List<Account>)scope;
			for (Account account : accToUpdate) {
				 if(account.Ultima_modifica_blacklist__c == null || (account.Ultima_modifica_blacklist__c < DateRequest)) {//processing only the request is after the last edit on the Account
					  if (Origin != 'NODI') {//Going in update with the flag passed on all accounts
						   account.Blacklist_Processi__c = String.join(listProcess, ';');
					   } else {//From nodi i need to change only from false to true
							List<String> actualProcess = (account.Blacklist_Processi__c != null) ? account.Blacklist_Processi__c.split(';') : new string[0];
							actualProcess.addAll(this.listProcess);
						   List<String> updateList = new List<String>(new Set<String>(actualProcess));

						   account.Blacklist_Processi__c = String.join(updateList, ';');
					   }
					  account.Ultima_modifica_blacklist__c = DataModifica; // in any case i update the date
				  }
			 }

			system.debug('++++ updating');
			//va in DML exception
			List<Database.SaveResult> saveResult = Database.update(accToUpdate, false);
			return BulkRequestManager.getErrors(saveResult, accToUpdate, errors);
		}
	}
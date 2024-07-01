/*------------------------------------------------------------------------
   Author:        Davide Fabris
   Company:       Deloitte
   Class:         BulkRequest_BlackList
   Description:   Class that updates accounts with the latest blaklist options
   History

   17/03/2017     Created - D.F.

   ----------------------------------------------------------------------------*/

public class BulkRequest_BlackList implements BulkRequestHandler {

//These are the attributes to be used for the update START
	public boolean Auto {get; set;}
	public boolean Abitazione {get; set;}
	public boolean Infortuni {get; set;}
	public boolean Malattia {get; set;}
	public boolean Protection {get; set;}
	public boolean Saving {get; set;}
	public boolean Aziende {get; set;}
	public boolean Rinnovo {get; set;}
	public boolean Commerciale {get; set;}
	public boolean Servizio {get; set;}
	public Datetime DataModifica {get; set;}//The date and time to write
//These are the attributes to be used for the update END

//These are attributes to manage some business logics
	public String Origin {get; set;}//If it is NODI flags are only added, otherwise I write exactly what specified on the attributes
	public Datetime DateRequest {get; set;}//Necessary to make sure that a late processing of the queue is not overwriting subsequent modifications. Necessary as DataModifica can be null to delete the date


	public List<String> process(List<Sobject> scope){
		List<String> errors = new List<String>();
		system.debug('thisinstance_Auto'+Auto);
		system.debug('thisinstance_Origin '+Origin);
		if (String.isempty(Origin)) Origin = 'NODI'; //in this way I only Add flags;
		system.debug('processing scope');

		//Expecting Account instance
		List<Account> accToUpdate = (List<Account>)scope;
		for (Account a : accToUpdate) {
			 if(a.Ultima_modifica_blacklist__c==null || (a.Ultima_modifica_blacklist__c<DateRequest)) {//processing only the request is after the last edit on the Account
				  if (Origin!='NODI') {//Going in update with the flag passed on all accounts
					   a.BlackList_Auto__c = Auto;
					   a.BlackList_Abitazione__c = Abitazione;
					   a.BlackList_Infortuni__c = Infortuni;
					   a.BlackList_Malattia__c = Malattia;
					   a.BlackList_Protection__c = Protection;
					   a.BlackList_Saving__c = Saving;
					   a.BlackList_Aziende__c = Aziende;
					   a.BlackList_Rinnovo__c = Rinnovo;
					   a.BlackList_Commerciale__c = Commerciale;
					   a.BlackList_Servizio__c = Servizio;
				   } else {//From nodi i need to change only from false to true
					   if (!a.BlackList_Auto__c && Auto ) a.BlackList_Auto__c = Auto;
					   if (!a.BlackList_Abitazione__c && Abitazione ) a.BlackList_Abitazione__c = Abitazione;
					   if (!a.BlackList_Infortuni__c && Infortuni ) a.BlackList_Infortuni__c = Infortuni;
					   if (!a.BlackList_Malattia__c && Malattia ) a.BlackList_Malattia__c = Malattia;
					   if (!a.BlackList_Protection__c && Protection ) a.BlackList_Protection__c = Protection;
					   if (!a.BlackList_Saving__c && Saving ) a.BlackList_Saving__c = Saving;
					   if (!a.BlackList_Aziende__c && Aziende ) a.BlackList_Aziende__c = Aziende;
					   if (!a.BlackList_Rinnovo__c && Rinnovo ) a.BlackList_Rinnovo__c = Rinnovo;
					   if (!a.BlackList_Commerciale__c && Commerciale ) a.BlackList_Commerciale__c = Commerciale;
					   if (!a.BlackList_Servizio__c && Servizio ) a.BlackList_Servizio__c = Servizio;
				   }
                  a.Ultima_modifica_blacklist__c = DataModifica; // in any case i update the date
			  } 
		 }

		system.debug('++++ updating');
		//va in DML exception
		List<Database.SaveResult> saveResult = Database.update(accToUpdate, false);
		return BulkRequestManager.getErrors(saveResult, accToUpdate, errors);

    }

}
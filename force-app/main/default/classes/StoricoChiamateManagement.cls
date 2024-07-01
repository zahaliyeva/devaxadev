/*------------------------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         StoricoChiamateManagement
Description:   Apex class used to execute all the logics internal to the 
			   trigger related to the Storico Chiamate object

History

11/12/2018     Created 
-------------------------------------------------------------------------------------------*/
public class StoricoChiamateManagement 
{
	public StoricoChiamateManagement() 
	{
		
	}

	@Future(callout=true)
	public static void HistoricizeCall(Set<String> CallIDsSet)
	{
		Boolean result = false;

		for(String s: CallIDsSet)
		{
			result = AP17_STORMSavePhoneRecording_WS.SaveRecording(s,'true');

			system.debug('##result: '+result);
		}
	}
}
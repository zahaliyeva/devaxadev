public with sharing class MobilityEventController extends MobilityAbstract {

	public class MobilityEventException extends Exception {}
	public class MobilityEventResponse extends MobilityResponse {}

	@AuraEnabled(cacheable = true)
	public static List < Event > getEvents() {
		return MobilityEventController.getEvents(100);
	}

	@AuraEnabled(cacheable = true)
	public static List < Event > getEvents(Integer limitRows) {
		Datetime dateStart = Datetime.now();
		
		//Datetime dateEnd = Datetime.newInstance(
		//	Date.today().addDays(1),
		//	Time.newInstance(0, 0, 0, 0)
		//);

		return [
			SELECT id, Subject, StartDateTime, EndDateTime, Who.Name
			FROM Event
			WHERE (
				StartDateTime >= :dateStart OR EndDateTime >= :dateStart
			)
			ORDER BY StartDateTime ASC
			LIMIT :limitRows
		];
	}

	@AuraEnabled
	public static MobilityEventResponse deleteRecord(String recordId){
		DebugStart('MobilityEventController', 'deleteRecord');

		MobilityEventResponse response = new MobilityEventResponse();
		try{
			Event eventToDelete = new Event(Id = recordId);

			delete eventToDelete;

			response.isSuccess = true;
		}catch(MobilityEventException ex){
            Debug('Exception', ex.getStackTraceString());
			response.errorMessage = ex.getMessage();
        }catch(Exception ex){
            Debug('Exception', ex.getStackTraceString());
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();

        return response;
	}

}
@IsTest
class MobilityEventControllerTest {

    static testMethod void testEventList() {

        //creo una lista fittizzia di eventi
        List<Event> events = new List<Event> ();
        for (Integer count = 0; count < 50; count++) {
            events.add(new Event(
                Subject = 'Appuntamento',
                ActivityDateTime = Date.today(),
                StartDateTime = Date.today(),
                EndDateTime = Datetime.newInstance(
                    Date.today().addDays(1),
                    Time.newInstance(0, 0, 0, 0)
                )
            ));
        }

        //carico la lista
        insert events;


        //verifico che il caricamento corrisponda
        List<Event> eventList1 = MobilityEventController.getEvents();
        
        List<Event> eventList = MobilityEventController.getEvents(10);
        Event eve = eventList[0];
        System.assertEquals(
            String.valueOf(eve.Subject), 'Appuntamento'
        );
    }

}
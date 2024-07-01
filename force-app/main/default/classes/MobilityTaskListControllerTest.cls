@IsTest
class MobilityTaskListControllerTest {

    static testMethod void testTaskList() {

        //creo una lista fittizzia di Taski
        List<Task> tasks = new List<Task> ();
        for (Integer count = 0; count < 50; count++) {
            tasks.add(new Task(
                Subject = 'Appuntamento',
                ActivityDate = Date.today()
            ));
        }

        //carico la lista
        insert tasks;

        //verifico che il caricamento corrisponda
        List<Task> taskList1 = MobilityTaskListController.getTask();

        List<Task> taskList = MobilityTaskListController.getTask(10);
        Task tas = taskList[0];
        System.assertEquals(
            String.valueOf(tas.Subject), 'Appuntamento'
        );
    }

}
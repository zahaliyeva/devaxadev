@isTest
public class MobilityTaskListWidgetControllerTest {
    @isTest static void test() {
        Test.startTest();
        MobilityTaskListWidgetController.getTask();
        MobilityTaskListWidgetController.getTask(3);
        Test.stopTest();          
    }
}
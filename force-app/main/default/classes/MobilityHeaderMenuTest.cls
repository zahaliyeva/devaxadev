@isTest
public class MobilityHeaderMenuTest {
    
    @isTest static void test() {
        String menuItemLabel = 'menu_Home_Button';
        Test.startTest();
        MobilityHeaderMenu.getVisibility(menuItemLabel);
        Test.stopTest();          
    }
    
}
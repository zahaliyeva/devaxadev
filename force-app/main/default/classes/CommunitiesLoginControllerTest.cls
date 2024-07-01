/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest public class CommunitiesLoginControllerTest {
    @IsTest
    public static void testCommunitiesLoginController () {
     	CommunitiesLoginController controller = new CommunitiesLoginController();
     	System.assertEquals(null, controller.forwardToAuthPage());       
    }    
}
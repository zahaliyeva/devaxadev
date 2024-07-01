@IsTest
public class RLY_BehaviourTest {
    
    static testMethod void testRLY_Behaviour() {
        
        String mess;
        //Campaign camp = new campaign();
     
        Test.startTest();
        RLY_Behaviour.Debug(mess);
        RLY_Behaviour.DebugObject('Titolo',mess);
        RLY_Behaviour.DebugJson('Titolo',mess);
        RLY_Behaviour.DebugHash('Titolo',mess);
        RLY_Behaviour.DebugStart('Classe','Metodo');
        RLY_Behaviour.DebugEnd();
        //RLY_Behaviour.DebugOn();
        
        //RLY_Behaviour.DebugList('Titolo',camp);
        
        RLY_Behaviour.DebugBreak();
        RLY_Behaviour.DebugLimits(true);
        //RLY_Behaviour.DebugLimits('Titolo');
        //RLY_Behaviour.DebugOff();
        //RLY_Behaviour.DebugLimits(true,'Titolo');
        //RLY_Behaviour.DebugList('Titolo',mess);
        Test.stopTest();
        
    }

}
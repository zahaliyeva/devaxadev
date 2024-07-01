@isTest
public class AnagraficaAssuntoreHandlerTest {
    static testMethod void Test(){
        Anagrafica_Assuntore__c AA = new Anagrafica_Assuntore__c(Name = 'AssuntoreTest');
        Anagrafica_Assuntore__c AA2 = new Anagrafica_Assuntore__c (Name = 'AssuntoreTest2');
        List<Anagrafica_Assuntore__c> TempList = new List<Anagrafica_Assuntore__c>();
        TempList.add(AA);
        TempList.add(AA2);
        insert TempList;
        
        AA.Name = 'AssuntoreTest2';
        try{
            update AA;
        }
        catch(DMLException e){
            Assert.isTrue(e.getMessage().contains('È già presente un assuntore di tipo Assuntore Auto con nome Assuntoretest2'));
        }
        
		List<Anagrafica_Assuntore__c> NewList = [Select id from Anagrafica_Assuntore__c where Name = 'AssuntoreTest'];        
        system.assert(NewList.size() == 1);
        update NewList;
        delete NewList;
        undelete NewList;
        
		        
    }
    
}
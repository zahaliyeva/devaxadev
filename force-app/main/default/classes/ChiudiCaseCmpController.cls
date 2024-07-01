public class ChiudiCaseCmpController {
    
    @AuraEnabled
    public static String updateCaseStatus(String caseId, String value) {
        String toReturn;
        Case c = new Case();
        c.Id = caseId;
        c.Status = value;
     	try
            {
				Database.update(c);	toReturn='OK';
           	}
           	catch (Exception ex)
           	{
                System.debug('There was an exception: ' + ex.getMessage());
                toReturn = 'KO|FallitoSi è verificato il seguente errore:\n'+ex.getMessage()+'\nContattare l\'amministratore di sistema.';
           	}
        return toReturn;
    } 

}
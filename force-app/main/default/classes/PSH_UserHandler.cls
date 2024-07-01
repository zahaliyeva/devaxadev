/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         PSH_UserHandler
Description:   this handler creates a Dashboard record for each user passed

History
-19/08/2016   Davide Fabris - Created

----------------------------------------------------------------------------*/

public class PSH_UserHandler implements ProcedureStepHandler {
// No Final step required
// At each scope i save a DashboardRowSet
    public Map< String,Map<String,String> > WalkStep(Procedure_Step__c thisStep, List<Sobject> scope) {
        List<Dashboard_Row__c> DR_toUpsert = new List<Dashboard_Row__c>();
        
        //first sort out timeref
        string TimeRef = DashboardRemoter.getTimeRef();
        String Year = TimeRef.LEFT(4);
        String Month = TimeRef.left(6).right(2);//Padding
        String day = TimeRef.right(2);
        string Week = day + ' ' + DashboardRemoter.getMonthName(Month);
        
        //I expect a list of Agency Users
        List<User> theUsers = (List<User>) scope;
        
        for (User u :theUsers) {
            Dashboard_Row__c thisDR = new Dashboard_Row__c();
            thisDR.Agenzia__c = u.Agency_Code__c;
            if (String.isempty(u.Contact.Account.RSAC_Description_Code__c) || String.isempty(u.Contact.Account.RSAC_Description_Code__c) || String.isempty(u.Contact.Account.Department_Chief_Description_Code__c)) {
                thisDR.Area_Manager__c ='NON TRACCIATO';
                thisDR.Sales_Manager__c='NON TRACCIATO';
                thisDR.Welfare_Manager__c='NON TRACCIATO';
            } else {
                thisDR.Area_Manager__c =u.Contact.Account.RSAC_Description_Code__c;
                thisDR.Sales_Manager__c=u.Contact.Account.RSA_Description_Code__c;
                thisDR.Welfare_Manager__c=u.Contact.Account.Department_Chief_Description_Code__c;
            }    
            thisDR.Year__c = Year;
            thisDR.Month__c = Month;
            thisDR.Week__c = Week;
            thisDR.TimeRef__c = TimeRef;
            
//thisDR.Unique_Name__c = u.id+'_'+TimeRef+'_____TEST2____';
thisDR.Unique_Name__c = u.id+'_'+TimeRef+'';
            thisDR.User__c = u.id;
            
            DR_toUpsert.add(thisDR);
        }
        
        //Upsert the Dashboeard rows
        // try {
            Schema.SObjectField f = Dashboard_Row__c.Fields.Unique_Name__c;
            system.debug('++++inserting'+DR_toUpsert.size());
            List<Database.UpsertResult> theres = Database.Upsert(DR_toUpsert,f,false);//inserting as much as possible
        // } catch (exception e) {
            // system.debug('something went wrong');
            // system.debug('+++'+e);
        // }
        
        //returning just to comply with interface
        return new Map<String,Map<String,string>>(); 
    }
    
    public void FinalAction(Procedure_Step__c thisStep, Map< String,Map<String,String> > thePropList) {
        system.debug('+++here i handle'+thePropList);
    }
}
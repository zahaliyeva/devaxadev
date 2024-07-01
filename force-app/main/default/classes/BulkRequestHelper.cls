/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         BulkRequestHelper
Description:   Class with elper methods for the BulkRequestManager class
History

17/03/2017     Created - D.F.

----------------------------------------------------------------------------*/

public class BulkRequestHelper {
     
    public static List<String> ProcessScope(Bulk_Request__c currentRequest,List<Sobject> scope) {
        Type resultType = Type.forName(currentRequest.BulkRequestHandler__c); //get the type
        String jsoninstance = currentRequest.JsonInstance__c;// get the detailed attributes
        BulkRequestHandler thisHandler = (BulkRequestHandler) JSON.deserialize(jsoninstance, resultType); //get the variable to work with
        return thisHandler.process(scope);//run detailed method
    }


}
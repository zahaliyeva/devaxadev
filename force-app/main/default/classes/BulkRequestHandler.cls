/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         BulkRequestHandler
Description:   Interface Class for the bulk request
History
 -17/03/2017   Davide Fabris - Created

----------------------------------------------------------------------------*/

public interface BulkRequestHandler{
    
    List<String> process(List<Sobject> scope);    
    
}
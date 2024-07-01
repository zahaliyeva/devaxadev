global without sharing class InvocableSOSL {
    

    @InvocableMethod(label='Execute SOSL')
    public static List<Response> executeSOSL(List<Requests> config){

        List<Response> ListToReturn = new List<Response>();
        
        try{
            
            for(Requests Input : config){
                Response toRet = new Response();
                if(String.isNotBlank(Input.searchTerm)){

                    String searchs ='FIND {'+ Input.searchTerm +'} ';

                    if(String.isNotBlank(Input.inClause))
                        searchs = searchs + ' IN ' + Input.inClause;

                    if(String.isNotBlank(Input.objects))
                        searchs = searchs + ' RETURNING ' + Input.objects;
                    
                    List<List<SObject>> res = search.query(searchs);
                    
                    if(res.size() == 1){
                        toRet.resultList = res.get(0);
                    }

                }
                ListToReturn.add(toRet);
            }

        }
        catch(Exception e){
            system.debug(e.getMessage());
        }

        
        return ListToReturn;

    }

    public class Requests {

        @InvocableVariable (label='Salesforce Objects' description='Use the syntax: ApiName1 ( Field1, Field2, Field3, ... Where Condition Limit N)' required=true)
        public String objects;
        @InvocableVariable (label='IN Clause' description='Available options are: ALL FIELDS, NAME FIELDS, EMAIL FIELDS, PHONE FIELDS, SIDEBAR FIELDS' required=false)
        public String inClause;
        @InvocableVariable (label = 'Search term' description = 'Insert the term to search' required=true)
        public String searchTerm;
        
    }
      
    public class Response{
        @InvocableVariable public List<SObject> resultList;
    }

}
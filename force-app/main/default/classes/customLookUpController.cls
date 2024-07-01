public class customLookUpController {

    public class Results
    {
        @AuraEnabled public String ResultName;
        @AuraEnabled public String ResultValues;
        @AuraEnabled public sObject Obj;

        public Results()
        {   
            this.ResultName='';
            this.ResultValues='';
        }
    }

    @AuraEnabled
    public static List < Results > fetchLookUpValues(String searchKeyWord, String ObjectName, String WhereCondition, String ResultNum, String SelectString)
    {    
        system.debug('ObjectName-->' + ObjectName);

        //String searchKey = '%'+ String.escapeSingleQuotes(searchKeyWord) + '%';
        String searchKey = String.escapeSingleQuotes(searchKeyWord) + '%';
       
        List < Results > returnList = new List < Results > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, '+SelectString+' from ' +ObjectName + ' where Name LIKE: searchKey';
        
       /* if(String.isNotBlank(WhereCondition))
           sQuery+=' and '+WhereCondition+ ' order by Name DESC';*/
        Boolean AvoidQuery = false;
        if(String.isNotBlank(WhereCondition))
        {
           if(WhereCondition.contains('=\'\''))
            AvoidQuery = true;
           
           sQuery+=' and '+WhereCondition+ ' order by Name DESC';           
        }
        
        if(!AvoidQuery)
        {
            if(String.isNotBlank(ResultNum))
               sQuery+=' Limit '+integer.valueOf(ResultNum);

            system.debug('@@sQuery: '+sQuery);

            String type=ObjectName;

            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType RecordShema = schemaMap.get(type);
            Map<String, Schema.SObjectField> fieldMap = RecordShema.getDescribe().fields.getMap();


            for (String fieldName: fieldMap.keySet()) 
            {
                System.debug('##Field API Name='+fieldName);// list of all field API name
            //It provides to get the object fields label.
            }

            List < sObject > lstOfRecords = Database.query(sQuery);
            
            for (sObject obj: lstOfRecords)
            {
                Results t = new Results();
                t.obj=obj;

                String SearchStr;

                for(String s: SelectString.split(','))
                {    
                    s=s.trim();   

                    if(s=='Name')
                    {
                        t.ResultName = (String)obj.get(s);
                    }
                    else
                    {
                        if(s.indexOf('__r')<>-1)
                        {
                            String s_1=s.substringBefore('.');
                            String s1 = (s.substringBefore('__r')+'__c').tolowercase();
                            String s2 = s.substringAfter('.');

                            if(String.isNotBlank((String)obj.get(s1)))
                            {
                                if(String.isNotBlank((String)obj.getSObject(s_1).get(s2)))
                                {
                                    if(String.isNotBlank(SearchStr))
                                        SearchStr+=' • '+fieldMap.get(s1).getDescribe().getLabel()+' : ' +(String)obj.getSObject(s_1).get(s2);
                                    else
                                        SearchStr=fieldMap.get(s1).getDescribe().getLabel()+' : ' +(String)obj.getSObject(s_1).get(s2);
                                }
                            }                   
                        }
                        else
                        {

                            if(String.isNotBlank((String)obj.get(s)))
                            {
                                if(String.isNotBlank(SearchStr))
                                    SearchStr+=' • '+fieldMap.get(s).getDescribe().getLabel()+' : ' +(String)obj.get(s);
                                else
                                    SearchStr=fieldMap.get(s).getDescribe().getLabel()+' : ' +(String)obj.get(s);
                            }
                        }
                    }             
                }
                t.ResultValues = SearchStr;
                returnList.add(t);
            }
        }
        return returnList;
    }
}
/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         JSONUtility
Description:   Class that supports the usage of JSON objects in apex
History
 -28/01/2016   Davide Fabris - Created
----------------------------------------------------------------------------*/
public class JSONUtility
{
    
    //Given a json string returns the objects with a given name
   /* public static list<Object>  getObject(string StringJson, string ObjName)  {
        list<Object> result = new list<Object>();
        Map<String, Object> rawMap= (Map<String, Object>) JSON.deserializeUntyped(StringJson);
        system.debug('++++++++++rawMap '+rawMap);
        try {
            if (StringJson.countMatches(ObjName)>1 ) {
                List<Object> objects =(List<Object>)rawMap.get(ObjName);
                system.debug('++++++++++objects '+objects);
                result.addAll(objects);
            } else {
                Object objects =(Object) rawMap.get(ObjName);
                result.add(objects);

            }
        } catch (exception e) {
            return result;
        }
        return result;
      //  return null;
    }*/
    // Given a json string returns the objects with a given name
     public static list<Object>  getObjectList(string StringJson, string ObjName)  {
         list<Object> result = new list<Object>();
         Map<String, Object> rawMap= (Map<String, Object>) JSON.deserializeUntyped(StringJson);
        
         try {
             try  {
                 List<Object> objects =(List<Object>)rawMap.get(ObjName);
                 result.addAll(objects);
             } catch (exception e) {
                 Object objects =(Object) rawMap.get(ObjName);
                 result.add(objects);
             }
         } catch (exception e) {
             return result;
         }
         system.debug('++++++++++result'+result);
         
         return result;

        
        
        // return null;
     }    
    //Given an object returns the inner objects  with a given name
    public static list<Object>  getObject(Object ObjectJson, string ObjName) 
    {
        list<Object> result = new list<Object>();
        system.debug('++++++++++ObjectJson '+ObjectJson);
        system.debug('++++++++++ObjName '+ObjName);
        map<string, object> objectMap = (map<string, object>) ObjectJson;
        system.debug('++++++++++objectMap '+objectMap);
        try 
        {
            Object objects= objectMap.get(ObjName);
            system.debug('++++++++++ObjList '+objects);
            result.add(objects);
        } catch (exception e) 
        {
            list<Object> objects= (List<Object>)objectMap.get(ObjName);
            result.addAll(objects);
        }
        return result;
    }
    
    //Given s json string returns the field value with a given name
    public static list<string>  getField(string StringJson, string FieldName) 
    {
        list<String> result = new list<String>();
        Map<String, Object> rawMap= (Map<String, Object>) JSON.deserializeUntyped(StringJson);
        system.debug('++++++++++rawMap '+rawMap);
        try {
            if (StringJson.countMatches(FieldName)>1 ) {
                List<String> objects =(List<String>)rawMap.get(FieldName);
                system.debug('++++++++++objects '+objects);
                result.addAll(objects);
            } else {
                String objects =(String) rawMap.get(FieldName);
                result.add(objects);

            }
        } catch (exception e) {
            result=null;
        }
        return result;
    }
    
    //Given an object returns the field value with a given name
    public static list<string>  getField(Object ObjectJson, string FieldName) 
    {
        list<String> result = new list<String>();
        system.debug('++++++++++ObjectJson '+ObjectJson);
        system.debug('++++++++++FieldName '+FieldName);
        map<string, object> objectMap = (map<string, object>) ObjectJson;
        system.debug('++++++++++objectMap '+objectMap);
         try 
        {
            String objects= (String)objectMap.get(FieldName);
            system.debug('++++++++++ObjList '+objects);
            result.add(objects);
        } catch (exception e) 
        {
            List<String> objects= (List<String>)objectMap.get(FieldName);
            result.addAll(objects);
        }
        return result;
    }
    
    //Method to retrieve a field containing a list of strings
    public static List<String> getFieldList(string StringJson, string FieldName) {
        list<String> result = new list<String>();
        Map<String, Object> rawMap= (Map<String, Object>) JSON.deserializeUntyped(StringJson);
        system.debug('++++++++++rawMap '+rawMap);
        try {
            //this passage is required in order to cast a list of string in an apex list
            Object temp = rawMap.get(FieldName);
            String StringTemp =  JSON.serialize(temp);
            result = (List<String>)System.JSON.deserialize(StringTemp, List<String>.class);
        } catch (exception e) {
            result=null;
        }
        return result;
    }

}
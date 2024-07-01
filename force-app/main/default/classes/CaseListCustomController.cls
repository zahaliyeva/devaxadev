public with sharing class CaseListCustomController {

    public class ResponseWrapper{
        @AuraEnabled
        public List<ListViewCustom__mdt> TipologiaFilters;
        @AuraEnabled
        public List<ListViewCustom__mdt> CanaleIngressoFilters;
    }

    @AuraEnabled
    public static ResponseWrapper getFilter(){
        ResponseWrapper toRet = new ResponseWrapper();
        toRet.TipologiaFilters = [select Id,DeveloperName,Ingresso_Default__c , Label, Lob__c, Category__c, Status__c, Conditions__c, Default__c, Index__c from ListViewCustom__mdt where is_Ingresso__c = false order by Index__c ]  ;
        ToRet.CanaleIngressoFilters = [select Id,DeveloperName, Label, Lob__c, Category__c, Status__c, Conditions__c, Default__c, Index__c from ListViewCustom__mdt where is_Ingresso__c = true order by Index__c ];
        return toRet;
    }
 


    @AuraEnabled
    public static DataTableWrapper initRecords(String ObjectName, String fieldNamesStr, String Orderby, String OrderDir, String whereCondition) {
        system.debug('*'+fieldNamesStr);
        DataTableWrapper dtw = new DataTableWrapper();
        List<LabelDescriptionWrapper> labelList = new List<LabelDescriptionWrapper>();
        List<String> fieldSet = new List<String>();
        Set<String> fieldNameSet = new Set<String>(fieldNamesStr.split(','));
        system.debug('*'+fieldNameSet);
        if(Schema.getGlobalDescribe().containsKey(ObjectName) ) {
            sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
            
            //get all the labels for sObject fields and put them in a map, keyed to the field api name
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap();
            Map<Schema.SObjectField,String> fieldToAPIName = new Map<Schema.SObjectField,String>();
            Map<String, String> apiNameToLabel = new Map<String, String>();
            for(String fieldName :  fieldNameSet){
                if(fieldMap.containsKey(fieldName)) {
                    fieldSet.add(fieldName);              
                    labelList.add(new LabelDescriptionWrapper(fieldMap.get(fieldName).getDescribe().getLabel(), fieldName, fieldMap.get(fieldName).getDescribe().getType().name().toLowerCase() , false ));

                  }
            }

          
            fieldSet.add('Account.Name');              
            labelList.add(new LabelDescriptionWrapper('Cliente', 'AccountName', 'picklist', false ));
            fieldSet.add('Owner.Name');              
            labelList.add(new LabelDescriptionWrapper('Titolare', 'OwnerName', 'picklist', false ));



            
            //call method to query
            List<sObject> sObjectRecords = getsObjectRecords(ObjectName, fieldSet, 100, '', Orderby, OrderDir, whereCondition);
            dtw.ldwList 	= labelList;
            dtw.sobList 	= sObjectRecords;
            dtw.fieldsList 	= fieldSet;
            String query = 'SELECT count() FROM '+ObjectName;

            if(String.isNotBlank(whereCondition)){

                If (whereCondition.contains('CURRUSER'))
                whereCondition=  whereCondition.replace('CURRUSER', UserInfo.getUserId());

                query = query + ' WHERE '+ whereCondition;
                query += ' AND (Owner.Profile.Name like \'%AAI - Vendite%\' OR Owner.name like \'Coda Agenzia Case%\')';
                system.debug(query);
            } 
               
            dtw.totalCount  = Database.countQuery(query);
        }
        
        String CRMURL = [Select UrlPathPrefix from Network where name = 'CRM Agenzie' limit 1].UrlPathPrefix;
       	dtw.CRMURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+CRMURL+'/';
		
        
        return dtw;
    }
    
    @AuraEnabled
    public static List<sObject> getsObjectRecords(String ObjectName, List<String> fieldNameSet, Integer LimitSize, String recId, String Orderby, String OrderDir, String whereCondition) {
        system.debug('set'+fieldNameSet);
        OrderDir = String.isBlank(OrderDir) ? 'desc' : OrderDir;
        String query = 'SELECT '+String.join(fieldNameSet, ',')+' FROM '+ObjectName;
        query = query.replace('Status', 'toLabel(Status)');
        query = query.replace('LOB__c', 'toLabel(LOB__c)');
        query = query.replace(',Category__c', ',toLabel(Category__c)');
        query = query.replace(',SubCategory__c', ',toLabel(SubCategory__c)');

        if(String.isNotBlank(whereCondition)) {
            
            If (whereCondition.contains('CURRUSER'))
            whereCondition=   whereCondition.replace('CURRUSER', UserInfo.getUserId());

            query += ' WHERE '+ whereCondition;
            
            query += ' AND (Owner.Profile.Name like \'%AAI - Vendite%\' OR Owner.name like \'Coda Agenzia Case%\')';
        }
        
        query += ' ORDER BY '+Orderby+' '+OrderDir;
        
        if(LimitSize != null && Integer.valueOf(LimitSize) > 0) {
            LimitSize = Integer.valueOf(LimitSize);
            query += ' Limit '+LimitSize;
        }
        System.debug('Query string: '+ query);
        return Database.query(query);
    }

    public class DataTableWrapper {
        @AuraEnabled
        public List<LabelDescriptionWrapper> ldwList;
        @AuraEnabled
        public List<sObject> sobList;
        @AuraEnabled
        public List<String> fieldsList;
        @AuraEnabled
        public Integer totalCount;
        @AuraEnabled
        public String CRMURL;
    }
    


    public class LabelDescriptionWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public boolean sortable;
     
        
        
        public LabelDescriptionWrapper(String labelTemp, String fieldNameTemp, String typeTemp, boolean sortableTemp) {
            label 	  = labelTemp;
            fieldName = fieldNameTemp;
            type 	  = typeTemp;
            sortable  = sortableTemp;
        }
            
    }

  
}
public with sharing class CustomLayoutUtility {
    private static final String DATE_FORMAT = 'dd/MM/yyyy';
    private static final String DATETIME_FORMAT = 'dd/MM/yyyy-HH:mm';

    @AuraEnabled
    public static CustomLayoutWrapper getLayoutDefinition(String layoutName, String objectName, String recordTypeDeveloperName, String recordId) {
        List < CustomPageLayoutSection__mdt > sectionMDTList = [Select DeveloperName, MasterLabel, Index__c, ObjectName__c, RecordTypeDeveloperName__c, SectionName__c,
            (Select DeveloperName, MasterLabel, APIName__c, Index__c, ReadOnly__c, Required__c, ObjectNameLookup__c, FieldLabel__c From CustomPagesLayoutField__r)
            From CustomPageLayoutSection__mdt
            Where ObjectName__c =: objectName and RecordTypeDeveloperName__c =: recordTypeDeveloperName
            Order By Index__c ASC
        ];

        System.debug('sectionMDTList: ' + JSON.serialize(sectionMDTList));
        System.debug('layoutName: ' + layoutName);
        System.debug('objectName: ' + objectName);
        System.debug('recordTypeDeveloperName: ' + recordTypeDeveloperName);

        Set < String > fields = new Set < String > ();
        for (CustomPageLayoutSection__mdt section: sectionMDTList) {
            for (CustomPageLayoutField__mdt item: section.CustomPagesLayoutField__r) {
                fields.add(item.APIName__c);
            }
        }

        //System.debug('### '+sectionMDTList[0].CustomPagesLayoutField__r);
        DescribeSObjectResult objectResult = Schema.getGlobalDescribe()
            .get(objectName).getDescribe();

        Map < String, Schema.SObjectField > fieldMap = objectResult.fields.getMap();


        CustomLayoutWrapper wrapper = new CustomLayoutWrapper();
        wrapper.name = layoutName;
        wrapper.sections = getSectionsInformation(sectionMDTList, fieldMap);
        wrapper.record = getRecord(recordId, fields, objectName);
        
        if (wrapper.record != null) {
            wrapper.title = (String) wrapper.record.get('Name');
            for (CustomLayoutWrapper.SectionItem section: wrapper.sections) {
                for (CustomLayoutWrapper.FieldItem field: section.fields) {
                    if(!field.developerName.contains('.')){
                        field.value = wrapper.record.get(field.developerName);
                    }

                    //if( 'Date'.equalsIgnoreCase(field.type) && String.isNotBlank(field.value) ){
                    //    field.value = getFormattedDate( (Date.valueOf(wrapper.record.get(field.developerName))), DATE_FORMAT);
                    //    continue;
                    //}

                    //if( 'Datetime'.equalsIgnoreCase(field.type) && String.isNotBlank(field.value) ){
                    //    field.value = getFormattedDatetime( (Datetime.valueOf(wrapper.record.get(field.developerName))), DATETIME_FORMAT);
                    //    continue;
                    //}
                }
            }
        }


        System.debug('### wrapper: ' + JSON.serialize(wrapper, true));

        return wrapper;

    }
    @TestVisible
    private static sObject getRecord(String recordId, Set < String > fields, String objectName) {
        if (String.isBlank(recordId) || fields.isEmpty()) {
            return null;
        }
        Set < String > andCondition = new Set < String > {
            SObjectTable.whereField('Id', recordId)
        };

        if(fields != null) fields.add('Name');

        String query = SObjectTable.getTableQuery(fields, objectName, andCondition, null, null, null, null);
        List < sObject > sObjectList = Database.query(query);

        return sObjectList.isEmpty() ? null : sObjectList[0];

    }

    private static List < CustomLayoutWrapper.SectionItem > getSectionsInformation(List < CustomPageLayoutSection__mdt > sectionMDTList, Map < String, Schema.SObjectField > fieldMap) {
        List < CustomLayoutWrapper.SectionItem > sectionItemList = new List < CustomLayoutWrapper.SectionItem > ();
        for (CustomPageLayoutSection__mdt section: sectionMDTList) {
            CustomLayoutWrapper.SectionItem sectionItem = new CustomLayoutWrapper.SectionItem();
            sectionItem.fields = getColumnsInformation(section.CustomPagesLayoutField__r, fieldMap);
            sectionItem.name = section.SectionName__c;
            sectionItem.index = Integer.valueOf(section.Index__c);
            sectionItemList.add(sectionItem);
        }

        return sectionItemList;
    }

    private static String firstUpercase(String value){
        return value.substring(0,1).toUpperCase() + value.substring(1, value.length()); 
    }

    private static List < CustomLayoutWrapper.FieldItem > getColumnsInformation(List < CustomPageLayoutField__mdt > colList, Map < String, Schema.SObjectField > fieldMap) {
        List < CustomLayoutWrapper.FieldItem > fieldItemList = new List < CustomLayoutWrapper.FieldItem > ();
        for (CustomPageLayoutField__mdt item: colList) {


            String field = item.APIName__c.toLowerCase();

            System.debug('FieldItem: ' + field);

            if(!field.contains('.')){            
                if (fieldMap.get(field).getDescribe().isAccessible()) {
                    CustomLayoutWrapper.FieldItem fieldItem = new CustomLayoutWrapper.FieldItem();
                    fieldItem.developerName = item.APIName__c;
                    fieldItem.name = fieldMap.get(field).getDescribe().getLabel();
                    fieldItem.type = String.valueOf(fieldMap.get(field).getDescribe().getType());
                    fieldItem.readOnly = item.ReadOnly__c || !fieldMap.get(field).getDescribe().isUpdateable();
                    fieldItem.required = item.Required__c;
                    fieldItem.index = Integer.valueOf(item.Index__c);
                    fieldItem.labelName = item.FieldLabel__c;

                    if ('PICKLIST'.equalsIgnoreCase(fieldItem.type)) {
                        fieldItem.pickListMap = getPickListValues(fieldMap.get(field).getDescribe());
                    }

                    fieldItemList.add(fieldItem);
                }
            }else{
                DescribeSObjectResult objectResult = Schema.getGlobalDescribe().get(item.ObjectNameLookup__c).getDescribe();
                Map < String, Schema.SObjectField > fieldMapReference = objectResult.fields.getMap();

                System.debug('ObjectNameLookup__c: ' + item.ObjectNameLookup__c);
                System.debug('fieldMapReference: ' + fieldMapReference);
                System.debug('field: ' + field);

                String nameReference = field.split('\\.')[0];
                String developerNameReference = field.split('\\.')[1];  

                String label = fieldMapReference.get(developerNameReference).getDescribe().getLabel();

                CustomLayoutWrapper.FieldItem fieldItem = new CustomLayoutWrapper.FieldItem();
                fieldItem.developerName = item.APIName__c;
                fieldItem.name = firstUpercase(nameReference) + ' ' + firstUpercase(label);
                fieldItem.type = 'REFERENCE';
                fieldItem.readOnly = true;
                fieldItem.required = false;
                fieldItem.index = Integer.valueOf(item.Index__c);
                fieldItem.nameLookup = item.ObjectNameLookup__c;
                fieldItem.labelName = item.FieldLabel__c;

                fieldItemList.add(fieldItem);
            }
        }

        return fieldItemList;
    }

    public static Map < String, String > getPickListValues(Schema.DescribeFieldResult fieldResult) {
        List < Schema.PicklistEntry > pickListEntryList = fieldResult.getPicklistValues();
        Map < String, String > valueToLabelMap = new Map < String, String > ();
        for (Schema.PicklistEntry entry: pickListEntryList) {
            valueToLabelMap.put(entry.getLabel(), entry.getValue());
        }
        return valueToLabelMap;
    }

    public static sObject getRecordType(String objectName, String recordId) {
        Set < String > fields = new Set < String > {
            'Id',
            'Name',
            'RecordTypeId',
            'RecordType.Name',
            'RecordType.DeveloperName'
        };

        if (String.isBlank(recordId) || fields.isEmpty()) return null;

        Set < String > andCondition = new Set < String > {
            SObjectTable.whereField('Id', recordId)
        };

        String query = SObjectTable.getTableQuery(fields, objectName, andCondition, null, null, null, null);

        List < sObject > sObjectList = Database.query(query);

        return sObjectList.isEmpty() ? null : sObjectList[0];
    }

    @AuraEnabled
    public static CustomLayoutWrapper getLayout(String objectName, String recordId, String recordType) {

        if(recordId == null && recordType == null) return null;

        String developerName = null;

        if(recordType != null){
            return getLayoutDefinition(null, objectName, recordType, recordId);
        }

        sObject record = getRecordType(objectName, recordId);
        String recordTypeId = (String) record.get('RecordTypeId');

        developerName = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getDeveloperName();

        String name = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();

        return getLayoutDefinition(null, objectName, developerName, recordId);
    }

    
    @AuraEnabled
    public static CustomLayoutWrapper.CustomLayoutMobilityResponse save( SObject recordToSave){
        CustomLayoutWrapper.CustomLayoutMobilityResponse response = new CustomLayoutWrapper.CustomLayoutMobilityResponse();
		try {
			upsert recordToSave;

			response.isSuccess = true;
            response.record = recordToSave;
		} catch (MobilityException ex) {
			response.errorMessage = ex.getMessage();
		} catch (Exception ex) {
			response.errorMessage = ex.getMessage();
		}
		return response;
    }

    
    @AuraEnabled
    public static String getFormattedDate ( Date dateToFormat, String format ){
        DateTime newDateTime = DateTime.newInstance(dateToFormat.year(), dateToFormat.month(), dateToFormat.day());
        return newDateTime.format(format);
    }

    @AuraEnabled
    public static String getFormattedDatetime ( Datetime datetimeToFormat, String format ){
        return datetimeToFormat.format(format);
    }
}
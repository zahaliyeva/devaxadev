public without sharing class MobilityCustomLayout extends RLY_Behaviour {

    public class Section {
        public CustomPageLayoutSection__mdt data;
        public List < CustomPageLayoutField__mdt > fields;
    }

    public static List < CustomPageLayoutSection__mdt > getSections(String objectName, String recordTypeDeveloperName, String action) {
        return [
            SELECT DeveloperName, MasterLabel, Index__c, ObjectName__c, RecordTypeDeveloperName__c, SectionName__c, SectionSubName__c,
            isUsingLink__c,Link__c,SectionUnderSubName__c,page__c, invisible__c,isUsingURLpreview__c,isUsingIcon__c,Icon__c 
            From CustomPageLayoutSection__mdt
            Where ObjectName__c =: objectName
            AND RecordTypeDeveloperName__c =: recordTypeDeveloperName
            AND(page__c =: action OR page__c = null)
        ];
    }

    public static List < CustomPageLayoutSection__mdt > getSectionsByName(String nameLayout) {
        return [
            SELECT DeveloperName, MasterLabel, Index__c, ObjectName__c, RecordTypeDeveloperName__c, SectionName__c,SectionSubName__c,
            isUsingLink__c,Link__c,SectionUnderSubName__c, page__c, invisible__c,isUsingURLpreview__c,isUsingIcon__c,Icon__c 
            From CustomPageLayoutSection__mdt
            Where NameLayout__c =: nameLayout
        ];
    }

    public static List < CustomPageLayoutField__mdt > getFields(String sectionId, String action) {
        return [
            SELECT DeveloperName, MasterLabel, APIName__c, Index__c, ReadOnly__c, Required__c, ObjectNameLookup__c, FieldLabel__c, page__c, invisible__c, Domain__c, BaseUrl__c, params__c,redirectLabel__c
            FROM CustomPageLayoutField__mdt
            WHERE Section__c =: sectionId
            AND(page__c =: action OR page__c = null)
        ];
    }

    public static List < Section > getConfig(String layoutName, String objectName, String recordTypeDeveloperName, String action) {
        DebugStart('MobilityCustomLayout', 'getConfig');

        List < Section > sections = new List < Section > ();

        List < CustomPageLayoutSection__mdt > listSections = null;

        if (layoutName != null) {
            listSections = MobilityCustomLayout.getSectionsByName(layoutName);
        } else {
            listSections = MobilityCustomLayout.getSections(objectName, recordTypeDeveloperName, action);
        }

        Debug('listSections', listSections);

        for (CustomPageLayoutSection__mdt section: listSections) {
            Section sectionData = new Section();
            sectionData.data = section;
            sectionData.fields = MobilityCustomLayout.getFields((String) section.Id, action);

            Debug('section', sectionData.data);
            Debug('fields', sectionData.fields);

            sections.add(sectionData);
        }

        DebugEnd();
        return sections;
    }

    @AuraEnabled 
    public static Map<String, MobilityCustomLayoutWrapper.FieldDefinition> getFieldsDefinition(String objectName, List<String> fields){
        DebugStart('MobilityCustomLayout', 'getFieldsDefinition');

        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        Map<String, MobilityCustomLayoutWrapper.FieldDefinition> result = MobilityCustomLayout.getFieldsInfo(fields, fieldMap);

        Debug('result', result);
        DebugEnd();
        return result;
    }

    private static Map<String,MobilityCustomLayoutWrapper.FieldDefinition> getFieldsInfo(List<String> fieldsIn, Map<String, Schema.SObjectField> fieldMap){
        DebugStart('MobilityCustomLayout', 'getFieldsInfo');

        Map<String,MobilityCustomLayoutWrapper.FieldDefinition> mapResult = new Map<String,MobilityCustomLayoutWrapper.FieldDefinition>();
        for(String field : fieldsIn){
            MobilityCustomLayoutWrapper.FieldDefinition fieldDefinition = MobilityCustomLayout.getFieldInfo(field, fieldMap);
            Debug('fieldDefinition', fieldDefinition);

            mapResult.put(field,fieldDefinition);
        }

        Debug('result', mapResult);
        DebugEnd();
        return mapResult;
    }

    private static MobilityCustomLayoutWrapper.FieldDefinition getFieldInfo(String fieldIn, Map < String, Schema.SObjectField > fieldMap){
        DebugStart('MobilityCustomLayout', 'getFieldInfo');
        String field = fieldIn.toLowerCase();

        if (fieldMap.get(field) != null && fieldMap.get(field).getDescribe().isAccessible()) {
            MobilityCustomLayoutWrapper.FieldDefinition fieldItem = new MobilityCustomLayoutWrapper.FieldDefinition();

            fieldItem.developerName = fieldIn;
            fieldItem.name = fieldMap.get(field).getDescribe().getLabel();
            fieldItem.type = String.valueOf(fieldMap.get(field).getDescribe().getType());
            fieldItem.readOnly = fieldMap.get(field).getDescribe().isUpdateable();
            fieldItem.required = fieldMap.get(field).getDescribe().isNillable();

            if ('PICKLIST'.equalsIgnoreCase(fieldItem.type)) {
                fieldItem.pickListMap = getPickListValues(fieldMap.get(field).getDescribe());
            }

            Debug('return', fieldItem);
            return fieldItem;
        }

        DebugEnd();
        return null;
    }


    @AuraEnabled
    public static MobilityCustomLayoutWrapper getLayoutDefinition(String layoutName, String objectName, String recordTypeDeveloperName, String recordId, String action) {
        DebugStart('MobilityCustomLayout', 'getLayoutDefinition');
        Debug('layoutName', layoutName);
        Debug('objectName', objectName);
        Debug('recordTypeDeveloperName', recordTypeDeveloperName);
        Debug('recordId', recordId);
        Debug('action', action);

        List < Section > sectionMDTList = MobilityCustomLayout.getConfig(layoutName, objectName, recordTypeDeveloperName, action);

        Debug('sectionMDTList', JSON.serialize(sectionMDTList));

        Set < String > fields = new Set < String > ();
        for (Section section: sectionMDTList) {
            for (CustomPageLayoutField__mdt item: section.fields) {
                fields.add(item.APIName__c);
            }
        }

        DescribeSObjectResult objectResult = Schema.getGlobalDescribe()
            .get(objectName).getDescribe();

        Map < String, Schema.SObjectField > fieldMap = objectResult.fields.getMap();

        MobilityCustomLayoutWrapper wrapper = new MobilityCustomLayoutWrapper();
        wrapper.definition = new Map<String, MobilityCustomLayoutWrapper.FieldItem>();

        wrapper.name = layoutName;
        wrapper.sections = getSectionsInformation(wrapper, sectionMDTList, fieldMap);
        wrapper.record = getRecord(recordId, new Set < String > (wrapper.fields), objectName);
        wrapper.recordType = recordTypeDeveloperName;

        if (wrapper.record != null) {
            List<CustomPageLayoutTitle__mdt> titleConf = [Select ObjectName__c, Format__c, Fields__c  from CustomPageLayoutTitle__mdt where ObjectName__c =: objectName];
            Boolean isSet = false;
            if(titleConf != null && titleConf.size() == 1){
                CustomPageLayoutTitle__mdt conf = titleConf.get(0);
                String title = conf.Format__c;
                List<String> fieldList = conf.Fields__c.split(';');
                system.debug(wrapper.record);
                for( Integer i = 0 ; i < fieldList.size() && !isSet ; i++ ){
                    String temp = fieldList.get(i);
                    String fieldToInsert;
                    if(temp.contains('.')){
                        String lastName;
                        List<String> lookupFields = temp.split('\\.');
                        SObject tempObj = wrapper.record;
                        for(integer j = 0; j < lookupFields.size(); j++){
                            String ob = lookupFields.get(j);
                            if(j < lookupFields.size()-1 && tempObj.getSObject(ob) != null){
                                tempObj = (SObject) tempObj.getSObject(ob);
                            }
                            else if(j == lookupFields.size()-1){
                                lastName = ob;
                            }
                            else{
                                
                                wrapper.title = (String) wrapper.record.get('Name');
                                isSet = true;
                            
                            }
                        }
                        if(String.isNotBlank(lastName)){
                            title = title.replace('{'+ i +'}', (String) tempObj.get(lastName));
                        }
                        else{
                            wrapper.title = (String) wrapper.record.get('Name');
                            isSet = true;
                        }
                    }
                    else{
                        // cambiato per le date il formato aggiornato = d-MM-yyyy 21-01-2022 *-+
                        String formatoDate ;
                        SObjectType r = wrapper.record.getSObjectType();
                        DescribeSObjectResult d = r.getDescribe();
                        formatoDate=String.valueOf(d.fields.getMap().get(temp).getDescribe().getType());
                              
                        if(formatoDate=='DATE'){
                            Date dataRecord = (date)wrapper.record.get(temp);
                            String dt = DateTime.newInstance(dataRecord.year(),dataRecord.month(),dataRecord.day()).format('d/MM/YYYY');
                            title = title.replace('{'+ i +'}',dt != null ? dt : '');
                        }
                        else                                               
                        title = title.replace('{'+ i +'}', wrapper.record.get(temp) != null ? String.valueOf(wrapper.record.get(temp)) : '');
                        
                    }
                    
                }
                if(!isSet){
                    wrapper.title = title;
                    isSet = true;
                }
            }
            if(!isSet)
                wrapper.title = (String) wrapper.record.get('Name');
            for (MobilityCustomLayoutWrapper.SectionItem section: wrapper.sections) {
                for (MobilityCustomLayoutWrapper.FieldItem field: section.fields) {
                    if (!field.developerName.contains('.')) {
                        field.value = wrapper.record.get(field.developerName);
                    }
                }
            }
        }


        Debug('wrapper', JSON.serialize(wrapper, true));
        DebugEnd();
        return wrapper;
    }


    @AuraEnabled
    public static MobilityCustomLayoutWrapper getLayoutDefinitionModal(String layoutName,String reportLink) {
        DebugStart('MobilityCustomLayout', 'getLayoutDefinitionModal');

        List < Section > sectionMDTList = MobilityCustomLayout.getConfig(layoutName, null, null, null);//Modal non ha bisogno d altro 
        MobilityCustomLayoutWrapper wrapper = new MobilityCustomLayoutWrapper();
        wrapper.sections = new  List<MobilityCustomLayoutWrapper.SectionItem> ();
        List<MobilityCustomLayoutWrapper.FieldItem> listFieldsBySection = new  List<MobilityCustomLayoutWrapper.FieldItem> ();

        Debug('sectionMDTList', JSON.serialize(sectionMDTList));

        for (Section section: sectionMDTList) {

            for (CustomPageLayoutField__mdt item: section.fields) {
                MobilityCustomLayoutWrapper.FieldItem fieldTemp = new MobilityCustomLayoutWrapper.FieldItem();
                fieldTemp.labelName = item.FieldLabel__c;
                fieldTemp.redirectURL = item.BaseUrl__c;
                listFieldsBySection.add(fieldTemp);
            }
            MobilityCustomLayoutWrapper.SectionItem sectionTemp = new MobilityCustomLayoutWrapper.SectionItem();
            sectionTemp.isUsingIcon = section.data.isUsingIcon__c;
            sectionTemp.Icon = section.data.Icon__c;
            sectionTemp.name = section.data.SectionName__c;
            sectionTemp.subName = section.data.SectionSubName__c;
            sectionTemp.underSubName = section.data.SectionUnderSubName__c;
            sectionTemp.isUsingLink = section.data.isUsingLink__c;
            sectionTemp.link = section.data.Link__c;
            sectionTemp.fields = new List<MobilityCustomLayoutWrapper.FieldItem>();
            sectionTemp.fields.addAll(listFieldsBySection);

            wrapper.sections.add(sectionTemp);
        }

        Debug('wrapper', JSON.serialize(wrapper, true));

        DebugEnd();
        return wrapper;
    }

    private static sObject getRecord(String recordId, Set < String > fields, String objectName) {
        DebugStart('MobilityCustomLayout', 'getRecord');

        if (String.isBlank(recordId) || fields.isEmpty()) {
            return null;
        }
        Set < String > andCondition = new Set < String > {
            SObjectTable.whereField('Id', recordId)
        };

        List<CustomPageLayoutTitle__mdt> titleConf = [Select ObjectName__c, Format__c, Fields__c  from CustomPageLayoutTitle__mdt where ObjectName__c =: objectName];
        if(titleConf != null){
            for(CustomPageLayoutTitle__mdt cc : titleConf){
                List<String> titleFields = cc.Fields__c != null? cc.Fields__c.split(';') : new List<String>();
                fields.addAll(titleFields); 
            }
        }
        if (fields != null) fields.add('Name');

        String query = SObjectTable.getTableQuery(fields, objectName, andCondition, null, null, null, null);
        Debug('query', query);
        system.debug(query);
        List < sObject > sObjectList = Database.query(query);

        DebugEnd();
        return sObjectList.isEmpty() ? null : sObjectList[0];

    }

    private static List < MobilityCustomLayoutWrapper.SectionItem > getSectionsInformation(MobilityCustomLayoutWrapper wrapper, List < Section > sectionMDTList, Map < String, Schema.SObjectField > fieldMap) {
        DebugStart('MobilityCustomLayout', 'getSectionsInformation');

        List < MobilityCustomLayoutWrapper.SectionItem > sectionItemList = new List < MobilityCustomLayoutWrapper.SectionItem > ();
        for (Section section: sectionMDTList) {
            MobilityCustomLayoutWrapper.SectionItem sectionItem = new MobilityCustomLayoutWrapper.SectionItem();
            sectionItem.fields = getColumnsInformation(wrapper, section.fields, fieldMap);
            sectionItem.name = section.data.SectionName__c;
            sectionItem.index = Integer.valueOf(section.data.Index__c);
            sectionItemList.add(sectionItem);
            sectionItem.invisible = section.data.invisible__c;
            //using url if for iframe a URL on comm2customer sections
            sectionItem.isUsingURLpreview = section.data.isUsingURLpreview__c;
        }

        Debug('sectionItemList', sectionItemList);
        DebugEnd();
        return sectionItemList;
    }

    private static String firstUpercase(String value) {
        return value.substring(0, 1).toUpperCase() + value.substring(1, value.length());
    }

    

    private static List < MobilityCustomLayoutWrapper.FieldItem > getColumnsInformation(MobilityCustomLayoutWrapper wrapper, List < CustomPageLayoutField__mdt > colList, Map < String, Schema.SObjectField > fieldMap) {
        DebugStart('MobilityCustomLayout', 'getColumnsInformation');

        List < MobilityCustomLayoutWrapper.FieldItem > fieldItemList = new List < MobilityCustomLayoutWrapper.FieldItem > ();
        for (CustomPageLayoutField__mdt item: colList) {
            String field = item.APIName__c.toLowerCase();

            Debug('Item', item);
            Debug('FieldItem', field);

            if (!field.contains('.')) {

                if (fieldMap.get(field) != null /*&& fieldMap.get(field).getDescribe().isAccessible()*/) {
                    MobilityCustomLayoutWrapper.FieldItem fieldItem = new MobilityCustomLayoutWrapper.FieldItem();
                    fieldItem.developerName = item.APIName__c;
                    fieldItem.name = fieldMap.get(field).getDescribe().getLabel();
                    fieldItem.type = String.valueOf(fieldMap.get(field).getDescribe().getType());
                    fieldItem.readOnly = item.ReadOnly__c || !fieldMap.get(field).getDescribe().isUpdateable();
                    fieldItem.required = item.Required__c || !fieldMap.get(field).getDescribe().isNillable();
                    fieldItem.index = Integer.valueOf(item.Index__c);
                    fieldItem.labelName = item.FieldLabel__c;
                    fieldItem.invisible = item.invisible__c;
                    fieldItem.redirectURL = item.BaseUrl__c;
                    fieldItem.redirectLab = item.redirectLabel__c;
                    if(item.Params__c != null)
                        fieldItem.params = item.Params__c.split(';');
                    if ('PICKLIST'.equalsIgnoreCase(fieldItem.type)) {
                        if(item.Domain__c != null && String.isNotBlank(item.Domain__c)){
                            fieldItem.pickListMap = getPicklistValuesFromString(item.Domain__c,fieldMap.get(field).getDescribe());
                        }
                        else
                            fieldItem.pickListMap = getPickListValues(fieldMap.get(field).getDescribe());
                    }

                    fieldItemList.add(fieldItem);

                    wrapper.definition.put(item.APIName__c, fieldItem);
                    wrapper.fields.add(item.APIName__c);
                }
            } else {
                DescribeSObjectResult objectResult = Schema.getGlobalDescribe().get(item.ObjectNameLookup__c).getDescribe();
                Map<String, Schema.SObjectField> fieldMapReference = objectResult.fields.getMap();

                Debug('ObjectNameLookup__c', item.ObjectNameLookup__c);
                Debug('fieldMapReference', fieldMapReference);
                Debug('field', field);

                String nameReference = field.split('\\.')[0];
                String developerNameReference = field.split('\\.')[1];

                String developerName = nameReference.replace('__r', '__c');

                //String label = fieldMapReference.get(developerNameReference).getDescribe().getLabel();

                MobilityCustomLayoutWrapper.FieldItem fieldItem = new MobilityCustomLayoutWrapper.FieldItem();
                fieldItem.developerName = item.APIName__c;
                fieldItem.name = firstUpercase(developerName);
                fieldItem.type = 'REFERENCE';
                fieldItem.readOnly = true;
                fieldItem.required = false;
                fieldItem.index = Integer.valueOf(item.Index__c);
                fieldItem.nameLookup = item.ObjectNameLookup__c;
                fieldItem.labelName = item.FieldLabel__c;
                fieldItem.invisible = item.invisible__c;
                fieldItem.redirectURL = item.BaseUrl__c;
                fieldItem.redirectLab = item.redirectLabel__c;
                if(item.Params__c != null)
                    fieldItem.params = item.Params__c.split(';');
                fieldItemList.add(fieldItem);

                wrapper.definition.put(item.APIName__c, fieldItem);
                wrapper.fields.add(item.APIName__c);
            }
        }

        DebugEnd();
        return fieldItemList;
    }

    public static Map<String,String> getPicklistValuesFromString(String input, Schema.DescribeFieldResult fieldResult){
        List < Schema.PicklistEntry > pickListEntryList = fieldResult.getPicklistValues();
        Map < String, String > valueToLabelMap = new Map < String, String > ();
        Map<String,String> toRet = new Map<String,String>();
        for (Schema.PicklistEntry entry: pickListEntryList) {
            valueToLabelMap.put(entry.getValue(), entry.getLabel());
        }
        for(String s : input.split(';')){
            if(valueToLabelMap.containsKey(s)){
                
                toRet.put(valueToLabelMap.get(s),s);
            }
                
        }
        return toRet;
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
        DebugStart('MobilityCustomLayout', 'getRecordType');
        Debug('objectName', objectName);
        Debug('recordId', recordId);

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
        Debug('query', query);
        try{
            List < sObject > sObjectList = Database.query(query);
            Debug('sObjectList', sObjectList);
            DebugEnd();
            return sObjectList.isEmpty() ? null : sObjectList[0];
        }
        catch(QueryException qex){
            return (SObject) new Account(); //usato come oggetto generico
        }

        
    }

    @AuraEnabled
    public static MobilityCustomLayoutWrapper getLayout(String objectName, String recordId, String recordType, String typeLayout) {
        return MobilityCustomLayout.getLayout(objectName, recordId, recordType, typeLayout, null);
    }

    @AuraEnabled
    public static MobilityCustomLayoutWrapper getLayout(String objectName, String recordId, String recordType, String typeLayout, String nameLayout) {
        DebugStart('MobilityCustomLayout', 'getLayout');
        Debug('objectName', objectName);
        Debug('recordId', recordId);
        Debug('recordType', recordType);
        Debug('typeLayout', typeLayout);
        Debug('nameLayout', nameLayout);

        String action = null;
        if ('edit'.equalsIgnoreCase(typeLayout)) {
            if (String.isNotBlank(recordId)) {
                action = 'edit';
            } else {
                action = 'new';
            }
        } else {
            action = 'detail';
        }

        if (recordId == null && recordType == null && nameLayout == null) return null;

        if (recordId == null && recordType == null && nameLayout != null) return getLayoutDefinition(nameLayout, objectName, null, null, typeLayout);

        if (recordType != null) {
            return getLayoutDefinition(null, objectName, recordType, recordId, action);
        }

        sObject record = getRecordType(objectName, recordId);
        String recordTypeId = (String) record.get('RecordTypeId');

        String developerName;
        Schema.RecordTypeInfo rtInfo = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordTypeId);

        if(rtInfo != null)
           developerName = rtInfo.getDeveloperName();
        else
            developerName = '';
        //String name = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();

        DebugEnd();
        return getLayoutDefinition(null, objectName, developerName, recordId, action);
    }


    @AuraEnabled
    public static MobilityCustomLayoutWrapper.CustomLayoutMobilityResponse save(SObject recordToSave) {
        DebugStart('MobilityCustomLayout', 'save');
        Debug('recordToSave', recordToSave);

        MobilityCustomLayoutWrapper.CustomLayoutMobilityResponse response = new MobilityCustomLayoutWrapper.CustomLayoutMobilityResponse();
        try {
            DebugJson('recordToSave', recordToSave);
            upsert recordToSave;

            response.isSuccess = true;
            response.record = recordToSave;
        } catch (MobilityException ex) {
            response.errorMessage = ex.getMessage();
        } catch (Exception ex) {
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
        return response;
    }
}
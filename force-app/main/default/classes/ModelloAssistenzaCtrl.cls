public class ModelloAssistenzaCtrl {

    private static final Integer MAX_QUERY_RECORDS = 2000;
    public boolean jsDebug{get;set;}
    public String UserMainNode {get;set;}
    public String ProfileName {get;set;}
    public String screenwidth {get;set;}


public ModelloAssistenzaCtrl(ApexPages.StandardController controller) {

     Id user_debug_id;
             
             try{
                 user_debug_id = (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG') != null ? (AAI_Code_Variables__c.getAll()).get('JS_USER_DEBUG').Value__c : null;
             }
             catch (Exception e)
             {
                 user_debug_id = null;
             }
             if (user_debug_id != null && (user_debug_id  == UserInfo.getUserId()))
             {
                 jsDebug= true;
             }
             else
             {
                 jsDebug=false;
             }

}

   @AuraEnabled
    public static String getColumnMetadata(String sobject_name, List<String> field_names, List<String> field_labels, List<String> sortable_field_names, List<String> reference_fields, List<String> override_field_type){
        return JSON.serialize(new ColumnMetadataWrapper(sobject_name, field_names, field_labels, sortable_field_names, reference_fields, override_field_type), true);
    }

    @AuraEnabled
    public static Integer getTotalRecords(String sobject_name, String match_criteria){
        String query = 'SELECT COUNT() FROM ' + String.escapeSingleQuotes(sobject_name);
        if(String.isNotBlank(match_criteria)){
            query += ' WHERE ' + match_criteria;
        }
        system.debug('getTotalRecords query: '+query);
        return Database.countQuery(query);
    }

    @AuraEnabled
    //MOSCATELLI_M 25/10/2018: NMA Business - START
    //public static String getRecords(String sobject_name, List<String> field_names, String match_criteria, String sort_by_field, String sort_order){
    public static String getRecords(String sobject_name, List<String> field_names, String match_criteria, String sort_by_field, String sort_order, String CaseDescription){
    //MOSCATELLI_M 25/10/2018: NMA Business - END    
        String s2='toLabel(';
        List<String> field_names_tolabel = new List<String>();

        for(string s: field_names){

            if((s=='Origin' || s=='Status') && sobject_name == 'Case'){
            s= s2 +  s +')';
            }
            //system.debug('s'+s);
            field_names_tolabel.add(s);

        }

        if(sobject_name == 'Case'){
        if(match_criteria.contains('Origin')){
            match_criteria = match_criteria.replace('Origin','toLabel(Origin)');
        }

        if(match_criteria.contains('Status')){
            match_criteria = match_criteria.replace('Status','toLabel(Status)');
            system.debug('this is my new match'+match_criteria);
        }
            }

        //system.debug('my match_criteria'+match_criteria);

        //system.debug('list of string after for'+field_names);

        String query = 'SELECT ' + String.escapeSingleQuotes(String.join(field_names_tolabel, ',')) + ' FROM ' + String.escapeSingleQuotes(sobject_name);
        //system.debug('this is my fields list'+String.escapeSingleQuotes(String.join(field_names_tolabel, ',')));

        if(String.isNotBlank(match_criteria)){
            query += ' WHERE ' + match_criteria;
        }
        if(String.isNotBlank(sort_by_field)){
            query += ' ORDER BY ' + String.escapeSingleQuotes(sort_by_field) + ' ' + String.escapeSingleQuotes(sort_order);
            if(sort_order == 'ASC'){
                query += ' NULLS FIRST';
            } else {
                query += ' NULLS LAST';
            }
        }
        query += ' LIMIT ' + String.valueOf(MAX_QUERY_RECORDS);
        system.debug('this is my query'+query);
        List<SObject> sobjects = new List<SObject>();
        List<SObject> sobjects_filtered = new List<SObject>();//MOSCATELLI_M 25/10/2018: NMA Business
        try
        {
            sobjects = Database.query(query);
            //MOSCATELLI_M 25/10/2018: NMA Business - START
            if(String.isNotBlank(CaseDescription))
            {
                for(Sobject so: sobjects)
                {
                    Case SoCase = (Case)so;

                    if(String.isNotBlank(SoCase.Description))
                    {
                        system.debug('Found description: '+SoCase.Description);

                        if(SoCase.Description.tolowercase().indexOf(CaseDescription.tolowercase())<>-1)
                            sobjects_filtered.add(so);
                    }
                }
            }
            else
                sobjects_filtered.addAll(sobjects);
            //MOSCATELLI_M 25/10/2018: NMA Business - END
        } catch(QueryException e){
            return JSON.serialize(new SObjectWrapper(e.getMessage()));
        }
        //MOSCATELLI_M 25/10/2018: NMA Business - START
        //return JSON.serialize(new SObjectWrapper(sobjects));
        return JSON.serialize(new SObjectWrapper(sobjects_filtered));
        //MOSCATELLI_M 25/10/2018: NMA Business - END
    }

    private class ColumnMetadataWrapper {
        private Map<String, ColumnMetadata> column_metadata;
        private String error_message;

        public ColumnMetadataWrapper(String sobject_name, List<String> field_names, List<String> field_labels, List<String> sortable_field_names, List<String> reference_fields, List<String> override_field_type){
            String namespace = retrieveNamespace();
            try {
                String sobject_internal_name = parseSObjectName(namespace, sobject_name);
                if(!Schema.getGlobalDescribe().get(sobject_internal_name).getDescribe().isAccessible()){
                    throw new ModelloAssistenzaCtrl.DynamicTableException('User doesn\'t have access to object: ' + Schema.getGlobalDescribe().get(sobject_internal_name).getDescribe().getName() + '.');
                }
                parseFieldsString(namespace, sobject_internal_name, field_names);
                setColumnsLabels(field_labels);
                setSortableColumns(sortable_field_names);
                setReferenceColumns(reference_fields);
                setOverridedFieldTypeColumns(override_field_type);
            } catch (DynamicTableException e){
                error_message = e.getMessage();
                column_metadata = new Map<String, ColumnMetadata>();
            }
        }

        private String retrieveNamespace(){
            String class_name = ModelloAssistenzaCtrl.class.getName();
            if(class_name.countMatches('.') == 1){
                return class_name.substringBefore('.') + '__';
            }
            return '';
        }

        private String parseSObjectName(String namespace, String sobject_name){
            if(Schema.getGlobalDescribe().containsKey(sobject_name)){
                return sobject_name;
            } else if(String.isNotBlank(namespace) && Schema.getGlobalDescribe().containsKey(namespace + sobject_name)){
                return namespace + sobject_name;
            } else {
                throw new DynamicTableException('Unknown SObject: ' + sobject_name + '.');
            }
        }

        private void parseFieldsString(String namespace, String sobject_internal_name, List<String> field_names){
            column_metadata = new Map<String, ColumnMetadata>();
            for(String field_name : field_names){
                column_metadata.put(field_name, new ColumnMetadata(namespace, sobject_internal_name, field_name));
            }
        }

        private void setColumnsLabels(List<String> field_labels){
            for(String unconverted_field_label : field_labels){
                String field_name = unconverted_field_label.substringBefore(':');
                String field_label = unconverted_field_label.substringAfter(':');
                if(!column_metadata.containsKey(field_name)){
                    throw new DynamicTableException('Unknown field in label string: ' + field_name + '.');
                }
                column_metadata.get(field_name).setFieldLabel(field_label);
            }
        }

        private void setSortableColumns(List<String> sortable_field_names){
            if(!sortable_field_names.isEmpty()){
                for(String field_name : sortable_field_names){
                    if(!column_metadata.containsKey(field_name)){
                        throw new DynamicTableException('Unknown field in sortable string: ' + field_name + '.');
                    }
                    column_metadata.get(field_name).setFieldIsSortable(true);
                }
            } else {
                for(ColumnMetadata column : column_metadata.values()){
                    column.setFieldIsSortable(true);
                }
            }
        }

        private void setReferenceColumns(List<String> reference_fields){
            for(String field_name : reference_fields){
                if(!column_metadata.containsKey(field_name)){
                    throw new DynamicTableException('Unknown field in reference string: ' + field_name + '.');
                }
                column_metadata.get(field_name).setFieldIsReference(true);
            }
        }

        private void setOverridedFieldTypeColumns(List<String> override_field_type){
            for(String unconverted_field_label : override_field_type){
                String field_name = unconverted_field_label.substringBefore(':');
                String field_type = unconverted_field_label.substringAfter(':');
                if(!column_metadata.containsKey(field_name)){
                    throw new DynamicTableException('Unknown field in override field type string: ' + field_name + '.');
                }
                column_metadata.get(field_name).setFieldOverrideType(field_type);
            }
        }

    }

    private class ColumnMetadata {
        private String field_api_name;
        private String field_label;
        private String field_type;
        private String field_override_type;
        private Boolean field_is_reference;
        private Boolean field_is_sortable;

        public ColumnMetadata(String namespace, String sobject_internal_name, String field_name){
            Map<String, Schema.SObjectField> sobject_fields = Schema.getGlobalDescribe().get(sobject_internal_name).getDescribe().fields.getMap();
            List<String> relationship = field_name.split('\\.');
            if(relationship.size() > 1){
                populateRelationshipFieldDescribe(namespace, relationship, sobject_fields);
            } else {
                populateValueFieldDescribe(namespace, relationship[0], sobject_fields);
            }
            field_override_type = null;
            field_is_reference = false;
            field_is_sortable = false;
        }

        public void setFieldLabel(String label){
            field_label = label;
        }

        public void setFieldIsSortable(Boolean is_sortable){
            field_is_sortable = is_sortable;
        }

        public void setFieldIsReference(Boolean is_reference){
            field_is_reference = is_reference;
        }

        public void setFieldOverrideType(String override_type){
            field_override_type = override_type;
        }

        private void populateRelationshipFieldDescribe(String namespace, List<String> relationship, Map<String, SObjectField> sobject_fields){
            DescribeFieldResult describe_field_result;
            String field_name = getRelationshipField(relationship[0]);
            relationship.remove(0);
            if(sobject_fields.containsKey(field_name)){
                describe_field_result = sobject_fields.get(field_name).getDescribe();
            } else if(String.isNotBlank(namespace) && sobject_fields.containsKey(namespace + field_name)){
                describe_field_result = sobject_fields.get(namespace + field_name).getDescribe();
            } else {
                throw new DynamicTableException('Unknown relationship: ' + relationship[0] + '.');
            }
            if(!describe_field_result.isAccessible()){
                throw new DynamicTableException('User doesn\'t have access to field: ' + describe_field_result.getName() + '.');
            }
            if(field_api_name != null){
                field_api_name += '.' + describe_field_result.getRelationshipName();
            } else {
                field_api_name = describe_field_result.getRelationshipName();
            }
            if(relationship.size() > 1){
                populateRelationshipFieldDescribe(namespace, relationship, Schema.getGlobalDescribe().get(describe_field_result.getReferenceTo().get(0).getDescribe().getName()).getDescribe().fields.getMap());
            } else {
                populateValueFieldDescribe(namespace, relationship[0], Schema.getGlobalDescribe().get(describe_field_result.getReferenceTo().get(0).getDescribe().getName()).getDescribe().fields.getMap());
            }
        }

        private String getRelationshipField(String field_name){
            return field_name.endsWith('__r') ? field_name.replace('__r', '__c') : field_name + 'Id';
        }

        private void populateValueFieldDescribe(String namespace, String field_name, Map<String, SObjectField> sobject_fields){
            DescribeFieldResult describe_field_result;
            if(sobject_fields.containsKey(field_name)){
                describe_field_result = sobject_fields.get(field_name).getDescribe();
            } else if(String.isNotBlank(namespace) && sobject_fields.containsKey(namespace + field_name)){
                describe_field_result = sobject_fields.get(namespace + field_name).getDescribe();
            } else {
                throw new DynamicTableException('Unknown field: ' + field_name + '.');
            }
            if(!describe_field_result.isAccessible()){
                throw new ModelloAssistenzaCtrl.DynamicTableException('User doesn\'t have access to field: ' + describe_field_result.getName() + '.');
            }
            if(field_api_name != null){
                field_api_name += '.' + describe_field_result.getName();
            } else {
                field_api_name = describe_field_result.getName();
            }
            field_label =  describe_field_result.getLabel();
            system.debug('FIELD LABEL******'+ field_label);
            field_type = describe_field_result.getType().name();
        }

    }

    @AuraEnabled
    //MOSCATELLI_M 25/10/2018: NMA Business -- START
    //public static List<String> getgCaseStatusPicklist() {
    public static List<String> getgCaseStatusPicklist(Boolean showClosed) {
    //MOSCATELLI_M 25/10/2018: NMA Business -- END
    
    List<String>  status = new List<String>();
    List<String>  statusAgenti = new List<String>();
    String UserID = UserInfo.getUserId();
    User CurrentUser = [Select Name,Agency_Code__c,UserRole.name,Profile.Name from User where id=:UserID LIMIT 1];
    String Profile = CurrentUser.Profile.Name;

    //MOSCATELLI_M 25/10/2018: NMA Business -- START
    Set<String> closedStatusSet = new Set<String>();
    List<String> statusToRemove = new List<String>();
    List<String> statusAgentiToRemove = new List<String>();

    for (CaseStatus closestat:[Select MasterLabel From CaseStatus where IsClosed=true])
    {
        closedStatusSet.add(closestat.MasterLabel);
    }
    //MOSCATELLI_M 25/10/2018: NMA Business -- END
    
    Modello_di_Assistenza__mdt mdAss = [SELECT Id, DeveloperName,Status__c,StatusAgenti__c
                                                FROM Modello_di_Assistenza__mdt 
                                                WHERE DeveloperName  = 'AssistenzaAgentiStatusPicklist'
                                                LIMIT 1];
	//OAVERSANO 09/11/2018 : Nuovo Modello di Assistenza Biz -- START
	List<String>  tempStatus = new List<String>();
    List<String>  tempStatusAgenti = new List<String>();
    Map<String,String> statusItaEng = new Map<String, String>();
	//OAVERSANO 09/11/2018 : Nuovo Modello di Assistenza Biz -- END
    if(mdAss!=null)
    {
        if(String.isNotBlank(mdAss.Status__c)){
            for(String s:mdAss.Status__c.split(';')){
                status.add(s);
                tempStatus.add(s); //OAVERSANO 09/11/2018 : Nuovo Modello di Assistenza Biz
            }

            status.sort();
        }


        if(String.isNotBlank(mdAss.StatusAgenti__c)){
            for(String s:mdAss.StatusAgenti__c.split(';')){
                statusAgenti.add(s);
                tempStatusAgenti.add(s); //OAVERSANO 09/11/2018 : Nuovo Modello di Assistenza Biz
            }

            statusAgenti.sort();
        }
   
    	//OAVERSANO 09/11/2018 : Nuovo Modello di Assistenza Biz -- START 
    	for(Integer i = 0; i<tempStatus.size(); i++)
    	{
    		system.debug('tempStatusAgenti: '+tempStatusAgenti[i]+' && tempStatus: '+tempStatus[i]);
    		statusItaEng.put(tempStatusAgenti[i], tempStatus[i]);
    	}
    	//OAVERSANO 09/11/2018 : Nuovo Modello di Assistenza Biz -- END
    	
        //MOSCATELLI_M 25/10/2018: NMA Business -- START
        if(!showClosed)
        {
            for(String s: statusAgenti)
            {
            	//OAVERSANO 09/11/2018 : Nuovo Modello di Assistenza Biz -- START 
                //if(closedStatusSet.contains(s))
                if(closedStatusSet.contains(statusItaEng.get(s)))
                    statusAgentiToRemove.add(s);
               	//OAVERSANO 09/11/2018 : Nuovo Modello di Assistenza Biz -- END 
            }

            for(String s: status)
            {
                if(closedStatusSet.contains(s))
                    statusToRemove.add(s);
            }  

            if(!statusAgentiToRemove.isEmpty())
            {
                for(String s : statusAgentiToRemove)
                {
                    if(statusAgenti.indexOf(s)<>-1)
                        statusAgenti.remove(statusAgenti.indexOf(s));
                }
            }

            if(!statusToRemove.isEmpty())
            {
                for(String s : statusToRemove)
                {
                    if(status.indexOf(s)<>-1)
                        status.remove(status.indexOf(s));
                }
            }
        }
    }
    //MOSCATELLI_M 25/10/2018: NMA Business -- END
    
    //#631 - Assistenza Filtri non corrispondono con gli stati - START 
    List<String> statusAgent = new List<String>{
        'AAI - Vendite Base',
        'AAI - Vendite Avanzato',
        'AAI - Vendite No Accordo Digitale',
        'NFE - AAI - Vendite Base',
        'NFE - AAI - Vendite Avanzato'
    };

    if(statusAgent.contains(Profile)){
        return statusAgenti;
    }else
        return status;

    //#631 - Assistenza Filtri non corrispondono con gli stati - END
    
    /*List<String> status = new List<String>();
          
    List<AssistenzaAgentiStatusPicklist__c> AssAgentiStatus = AssistenzaAgentiStatusPicklist__c.getall().values();
    system.debug('AssAgentiStatus'+AssAgentiStatus);
    
           
        for (AssistenzaAgentiStatusPicklist__c a: AssAgentiStatus) {
              status.add(a.Name);
           
         }  

    return status;*/
    } 

    @AuraEnabled
    public static List<String> getgCaseLOBPicklist() {
    List<String> lob = new List<String>();
    //MOSCATELLI_M 25/10/2018: NMA Business -- START      
    /*Schema.DescribeFieldResult fieldResult = Case.LOB__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
           
        for (Schema.PicklistEntry f: ple) {
              lob.add(f.getLabel());
           
         }  */
    Set<String> LobSet = new Set<String>();

    for(Modello_di_Assistenza__mdt Ma:[Select Lob__c from Modello_di_Assistenza__mdt where DeveloperName like 'Lob%' and Gestito_con_TTP8__c= false order by Lob__c asc])
    {
        LobSet.add(Ma.Lob__c);
    }

    lob.addAll(LobSet);     
    //MOSCATELLI_M 25/10/2018: NMA Business -- END
    return lob;
    } 

    @AuraEnabled
    public static List<String> getgCaseCategoryPicklist(String LOB) {

    List<String>  category = new List<String>();

    Modello_di_Assistenza__mdt[] mdAss = [SELECT Id, DeveloperName,Lob__c,Categoria__c
                                                FROM Modello_di_Assistenza__mdt 
                                                WHERE Lob__c  =: LOB];
        if(mdAss!=null)
        {
            for(Modello_di_Assistenza__mdt cmt: mdAss)
            {
                if(!category.contains(cmt.Categoria__c))
                {
                    category.add(cmt.Categoria__c);
                }
            }

            category.sort();
        }

        
        return category;
    } 

   @AuraEnabled
     public static Map<String,String> getPageValues()
     {
        Map<String,String> PageValMap = new Map<String,String>();


        String UserID = UserInfo.getUserId();

        String PartnerUrl='';


        Boolean isStandardUser = true;
        String UserAgency = '';
        String UserRole = '';
        String UserProfile='';
        String UserName = '';
        Boolean isPilotaAgency = false; 
        List<String> AgenziePilota = new List<String>();
         
        

        User CurrentUser = [Select Name,Agency_Code__c,UserRole.name,Profile.Name from User where id=:UserID];

        if(UserInfo.getUserType()<>'Standard')
        {   
            isStandardUser = false;
        }  
        
        UserAgency = (String.isNotBlank(CurrentUser.Agency_Code__c))?CurrentUser.Agency_Code__c:'';
        UserRole = (String.isNotBlank(CurrentUser.UserRole.name))?CurrentUser.UserRole.name:'';
        UserProfile =  (String.isNotBlank(CurrentUser.Profile.Name))?CurrentUser.Profile.Name:'';  
        UserName = (String.isNotBlank(CurrentUser.Name))?CurrentUser.Name:''; 

        if(String.isBlank(UserAgency) && (UserProfile == 'System Administrator' || UserProfile == 'Amministratore del sistema')){
        	UserAgency = '000828';
        }

        

        Modello_di_Assistenza__mdt mdAss = [SELECT Id, DeveloperName,Pilota__c
                                                FROM Modello_di_Assistenza__mdt 
                                                WHERE DeveloperName  = 'AgenziePilota'
                                                LIMIT 1];

        if(mdAss!=null)
            {
                if(String.isNotBlank(mdAss.Pilota__c)){
                    for(String s:mdAss.Pilota__c.split(';')){
                        AgenziePilota.add(s);
                    }
                }

            }

    /*for(String ag: AgenziePilota){

        if(ag == UserAgency){*/

            isPilotaAgency = true; 
    /*        break;
    }
    }*/

        PageValMap.put('isStandardUser',(isStandardUser)?'true':'false');
        PageValMap.put('UserAgency',UserAgency);
        PageValMap.put('UserRole',UserRole);   
        PageValMap.put('UserProfile',UserProfile);
        PageValMap.put('UserId',UserID);  
        PageValMap.put('UserName',UserName);
        PageValMap.put('isPilotaAgency',String.valueOf(isPilotaAgency));
       
        system.debug('getPageValues'+PageValMap);

        return PageValMap;
     }

     @AuraEnabled
      public static List<Case> getCollaboratori(String CodiceAgenzia) 
      {         
          List<Case>ListCollaboratori = new List<Case>();
          Set<String>CollID = new Set<String>();

          String queryS = 'Select User__r.Id, User__r.Name from Case where User__r.isActive=true';

          if(String.isNotBlank(CodiceAgenzia))
          {
             queryS+=' and Agency_Code__c='+'\''+CodiceAgenzia.trim()+'\'';

   
          } 

          system.debug('##query: '+queryS);
         
          for(Case c:Database.query(queryS))
          {
            if(String.isNotBlank(c.User__r.Name) && String.isNotBlank(c.User__r.Id) && !CollId.contains(c.User__r.id))
            {
                ListCollaboratori.add(c);
                CollID.add(c.User__r.Id);
            }
          }
       	system.debug('##Collaboratori: '+ListCollaboratori + CollID); 
        return ListCollaboratori ;
     } 




    private class SObjectWrapper {
        String error_message;
        List<SObject> sobjects;

        public SObjectWrapper(String message){
            error_message = message;
            sobjects = new List<SObject>();
        }

        public SObjectWrapper(List<SObject> queried_sobjects){
            sobjects = queried_sobjects;
        }
    }

    private class DynamicTableException extends Exception {}

   //MOSCATELLI_M 25/10/2018: NMA Business -- START
   @AuraEnabled
   public static String FilterClosedCases()
   {
        String Filter = '';
        String currentStatus='';
        List<String>  status = new List<String>();
        List<String>  statusAgenti = new List<String>();
        List<String>  tempStatus = new List<String>();
        List<String>  tempStatusAgenti = new List<String>();        
        Map<String,String> statusEngIta = new Map<String, String>();
        Modello_di_Assistenza__mdt mdAss = [SELECT Id, DeveloperName,Status__c,StatusAgenti__c
                                                FROM Modello_di_Assistenza__mdt 
                                                WHERE DeveloperName  = 'AssistenzaAgentiStatusPicklist'
                                                LIMIT 1];        

        if(mdAss!=null)
        {
            if(String.isNotBlank(mdAss.Status__c)){
                for(String s:mdAss.Status__c.split(';')){
                    status.add(s);
                    tempStatus.add(s); 
                }

                status.sort();
            }

            if(String.isNotBlank(mdAss.StatusAgenti__c)){
                for(String s:mdAss.StatusAgenti__c.split(';')){
                    statusAgenti.add(s);
                    tempStatusAgenti.add(s); 
                }

                statusAgenti.sort();
            }
       
            for(Integer i = 0; i<tempStatus.size(); i++)
            {
                system.debug('tempStatusAgenti: '+tempStatusAgenti[i]+' && tempStatus: '+tempStatus[i]);
                statusEngIta.put(tempStatus[i],tempStatusAgenti[i]);
            }
        }

        for (CaseStatus closestat:[Select MasterLabel From CaseStatus where IsClosed=true])
        {
            currentStatus = closestat.MasterLabel;

            if(statusEngIta.containsKey(currentStatus))
                currentStatus = statusEngIta.get(currentStatus);

            currentStatus = currentStatus.replace('\'','\\\'');

            if(String.isBlank(Filter))
                Filter = ' and Status not in (\''+currentStatus+'\'';
            else
                Filter+= ',\''+currentStatus+'\'';
        }

        if(String.isNotBlank(Filter))
            Filter+=')';

        system.debug('@@Filter: '+Filter);

        return Filter;
   }
   //MOSCATELLI_M 25/10/2018: NMA Business -- END

}
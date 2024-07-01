public without sharing class QuotationManagement {
/* 
------------------------------------------------------------
-- - Name          : QuotationManagement 
-- - Author        : Andrea Capobianco 
-- - Description   : Apex class that creates a Quotation__c record for Leads and Opportunities

--
-- Maintenance History: 
--
-- Date         Name               Version  Remarks 
-- -----------  -----------------  -------  -----------------------------
-- 07-DEC-17    Andrea Capobianco  1.0      Initial version
------------------------------------------------------------
*/
    public static List<ApplicationLogHelper.ErrorWrapper> Errors = new List<ApplicationLogHelper.ErrorWrapper>();

    public static void createQuotationFromLead(List<Id> listWebLeadsId)
    {    
    
        System.debug('Entro in QuotationManagement');
                   
        Set<String> fields = new Set<String>();
        Set<String> fieldsQuot = new Set<String>();
        Set<String> fieldsQuotCalculated = new Set<String>();  
        

        Map <String, Schema.SObjectField> fieldQuotMap = Schema.getGlobalDescribe().get('Quotazione__c').getDescribe().fields.getMap();
        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap();
        

        for(Schema.SObjectField sfield : fieldQuotMap.Values())
        {

            schema.describefieldresult quotfield = sfield.getDescribe();
            fieldsQuot.add(quotfield.getname().toLowerCase());

            if(sfield.getDescribe().isCalculated()){

                 schema.describefieldresult formulafield = sfield.getDescribe();
                 fieldsQuotCalculated.add(formulafield.getname().toLowerCase());
            }
        }

        for(Schema.SObjectField slfield : fieldMap.Values())
        {

                 schema.describefieldresult leadfield = slfield.getDescribe();
                 fields.add(leadfield.getname().toLowerCase());  
        }

        system.debug('fieldsQuotCalculated'+fieldsQuotCalculated);
                   
        Map<String,Id> mapQuotationRTNameToId = new Map<String,Id>(); //connecting each Quotazione__c's Record Type Id to its Name
        List<Quotazione__c> quotationsToCreate = new List<Quotazione__c>(); 
        List<RecordType> quotationRTList = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Quotazione__c' ]; // NOPMD  Fix CRUD violation
        List<Lead> listWebLeads = new List<Lead>();


        /*
        * @description: A code snippet that mimics the popular Select * SQL syntax in force.com's Apex language.
        */

        // Initialize setup variables
        String objectName = 'Lead';  // modify as needed
        String query = 'SELECT ';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keySet()) {
             query += + s + ',';
        }

        // Manually add related object's fields that are needed.
        //query += 'Account.Name,'; // modify as needed

        // Strip off the last comma if it exists.
        query = query.removeEnd(',');


        system.debug('query'+query);

        // Add FROM statement
        query += ' FROM ' + objectName;

        system.debug('query2'+query);

        // Add on a WHERE/ORDER/LIMIT statement as needed
        query += ' WHERE Id IN: listWebLeadsId'; // modify as needed
 
        try {
            listWebLeads = database.query(query);
        } catch (QueryException e){
                ApplicationLogHelper.ERROR('QuotationManagement', e.getMessage(), e.getStackTraceString());
            
        //perform exception handling
        }

        //populating the Quotation's Name/Id Map 
        for(RecordType rt: quotationRTList)
        {

            mapQuotationRTNameToId.put(rt.Name,rt.Id);
        }

        for(Lead l: listWebLeads)
        {
            /*Quotazione__c newQuotation = new Quotazione__c( Name = 'Quotazione Lead '+l.Name,
                                                            RecordTypeId = mapQuotationRTNameToId.get(l.Landing_page__c),
                                                            Lead__c = l.Id);*/  
                                                                          
              
            Quotazione__c newQuotation = new Quotazione__c(); 
            newQuotation.Name = 'Quotazione Lead '+l.Name;
            if (l.Landing_page__c.equalsIgnoreCase('Full Quote'))
            {
                // the values in GET method below are hard-coded because of problems with capital letters
                if(l.Prodotto__c.equalsIgnoreCase('Nuova Protezione VAN'))
                    newQuotation.RecordTypeId = mapQuotationRTNameToId.get('Nuova Protezione VAN');
                else if(l.Prodotto__c.equalsIgnoreCase('Auto Protezione'))
                    newQuotation.RecordTypeId = mapQuotationRTNameToId.get('Auto Protezione');
                else if(l.Prodotto__c.equalsIgnoreCase('Protezione InMoto'))
                    newQuotation.RecordTypeId = mapQuotationRTNameToId.get('Protezione InMoto');
                else if(l.Prodotto__c.equalsIgnoreCase('Nuova Protezione Auto'))
                    newQuotation.RecordTypeId = mapQuotationRTNameToId.get('Nuova Protezione Auto');
            }
            else
            {
                newQuotation.RecordTypeId = mapQuotationRTNameToId.get(l.Landing_page__c);
            }
            newQuotation.Lead__c = l.Id;
            //newQuotation.OwnerId = UserInfo.getUserId();
            newQuotation.Origine__c = l.Landing_page__c;
            newQuotation.Notes__c = l.Notes__c;
            newQuotation.NumberOfEmployees__c = l.NumberOfEmployees;
           
            for(String field:fields) {
            //This will only copy custom fields of Lead and assumes that field api name is similar in Quotazione object
            system.debug('field to check'+field);
    
                    if(field.indexOf('__c')>-1 && fieldsQuot.contains(field) && !(fieldsQuotCalculated.contains(field))){

                        newQuotation.put(field, l.get(field));
                    }
        }


            quotationsToCreate.add(newQuotation);
        }       

        Database.SaveResult[] result = Database.insert(quotationsToCreate,false);
        System.debug('Sono qui ' + result[0]);
    }

    public static Sobject createQuotationFromConversion(sObject myOpp) //inputs: Id convertedLeadId, Id targetAccountId
    {    
    
        Opportunity Opp = (Opportunity)myOpp; 
        
        system.debug('****************'+myOpp);
        
        //Id LeadconvertedInOpp = [SELECT Id FROM Lead WHERE ConvertedOpportunityId =: Opp.Id LIMIT 1].Id;
        
        string LeadconvertedInOpp = Opp.TECH_LeadId__c;
        
        //retrieving the Opportunity created from the conversion
        //Opportunity oppFromConvertedLead = [SELECT Id FROM Opportunity WHERE AccountId =: targetAccountId];
        
        if(LeadconvertedInOpp != null)
            {
            //setting up the query to retrieve all the fields from the Quotation related to the converted Lead
            String query = 'SELECT';
            //getting all fields
            Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Quotazione__c').getDescribe().fields.getMap();
            for(String s : objectFields.keySet())
            {
                query += ' ' + s + ', ';
            }
            //eliminate last comma
            if (query.subString(query.Length()-2,query.Length()-1) == ',')
            {
                query = query.subString(0,query.Length()-2);
            }
            //adding the from 
            query += ' FROM Quotazione__c';

            //adding conditions
            query += ' WHERE Lead__c = \''+LeadconvertedInOpp+'\' LIMIT 1';
            system.debug('#@#@ '+query);
            try
            {
                Quotazione__c quotationToClone = database.query(query);
                
                if(quotationToClone != null)
                {
                    //cloning the Quotation and relating it to the Opportunity
                    Quotazione__c newQuotationForOpp = quotationToClone.clone(false,true,false,false);
                    newQuotationForOpp.Opportunity__c = Opp.Id;
                    newQuotationForOpp.Lead__c = null;
                    //newQuotationForOpp.OwnerId = UserInfo.getUserId();

                    Database.SaveResult SaveResult = Database.insert(newQuotationForOpp,false);
                    
                    system.debug('+++++++++++++++SAVERESULT'+SaveResult);
                    
                    
                }
            }
            catch (QueryException e)
            {
                Errors.add(new ApplicationLogHelper.ErrorWrapper(e.getMessage(), e.getStackTraceString()));
                
                //perform exception handling
            }
        }
        
        return Opp;
    }
    
    
    @future
    public static void ShareWithFullAgency (set <Id> allQuotIds) {

        List<Quotazione__c> allQuots = [SELECT Agency_Code__c, Id FROM Quotazione__c WHERE Id IN :allQuotIds];
        ShareWithFullAgency(allQuots);
        /**
        List<Quotazione__c> allQuots = new List<Quotazione__c>();
        
        for (Id myID : allQuotIds) {
            Quotazione__c myQuot = [SELECT Agency_Code__c, Id FROM Quotazione__c WHERE Id =: myID];
            allQuots.add(myQuot);
        }
        
        ShareWithFullAgency(allQuots);
        **/
    }
    
    
    public static void ShareWithFullAgency (list<Quotazione__c> allQuots) {
        //given a list of Quotazione__c shares them with all the corresponding Agency if they are Agency Quotazione__c
        
        List<Id> IdQuots = new List<Id>();                 
        List<Quotazione__c> QuotToShare = new List<Quotazione__c>();
        List<Quotazione__c> QuotnoAgency = new List<Quotazione__c>();
        Map<ID,String> MapQuotToNode = new Map<ID,String>();
        List<Quotazione__Share> SharetoDelete = new List<Quotazione__Share>();
        
        for (Quotazione__c thisQuot : allQuots) {
            if(thisQuot.Agency_Code__c == null){
                QuotnoAgency.add(thisQuot); 
            }
            IdQuots.add(thisQuot.id);
            QuotToShare.add(thisQuot);
            MapQuotToNode.put(thisQuot.Id, thisQuot.Agency_Code__c);
        }
        
        /*if(QuotnoAgency.size()>0){
            
            if(!(Test.isRunningTest())){
     
            update(QuotnoAgency);
            
            }
        
        }*/
        
        SharetoDelete = [SELECT AccessLevel,Id,IsDeleted,LastModifiedById,LastModifiedDate,ParentId,RowCause,UserOrGroupId FROM Quotazione__Share WHERE ParentId IN: IdQuots AND RowCause = 'Manual' ]; // NOPMD  Fix CRUD violation
        //Database.delete(SharetoDelete, true);
        delete SharetoDelete; // NOPMD  Fix CRUD violation
        
        system.debug('+++++MapQuotToNode'+MapQuotToNode);
        
        //Retrieving All involved nodes
        List<String> AllGroupCodes = MapQuotToNode.values() ;
        system.debug('++++++++AllGroupCodes'+AllGroupCodes);
        List<Node__c> Nodes7_AND_8 = [Select id, Node_unique_code__c, Parent_node_unique_code__c, Node_level__c FROM Node__c WHERE Node_unique_code__c IN :AllGroupCodes OR  Parent_node_unique_code__c IN :AllGroupCodes ]; // NOPMD  Fix CRUD violation
        system.debug('++++++++Nodes7_AND_8'+Nodes7_AND_8);

        Map<String,set<String>> MapGrouptoNodes = new Map<String,set<String>>();
        
        Map<String,Node__c> NodesLV7 = new Map<String,Node__c>();
        Map<String,Node__c> NodesLV8 = new Map<String,Node__c>();
        Map<String,Node__c> NodesLV9 = new Map<String,Node__c>();
        
        for (Node__c thisNode: Nodes7_AND_8) {           
            Set<String> currentNodeList = new set<String>();     

            if (thisNode.Node_level__c==7) {
                if (MapGrouptoNodes.get(thisNode.Node_unique_code__c)!=null) {
                    currentNodeList =   MapGrouptoNodes.get(thisNode.Node_unique_code__c);
                }    
                NodesLV7.put(thisNode.Node_unique_code__c,thisNode);
                currentNodeList.add('DIF_'+thisNode.Node_unique_code__c);
                MapGrouptoNodes.put(thisNode.Node_unique_code__c,currentNodeList);
            }
            
            if (thisNode.Node_level__c==8) {
                NodesLV8.put(thisNode.Node_unique_code__c,thisNode);
                String AgencyNode = thisNode.Parent_node_unique_code__c;
                if (MapGrouptoNodes.get(AgencyNode)!=null) {
                    currentNodeList =   MapGrouptoNodes.get(AgencyNode);
                }    
                currentNodeList.add('DIF_'+thisNode.Node_unique_code__c);
                MapGrouptoNodes.put(AgencyNode,currentNodeList);
            }
        }
        system.debug('++++++++MapGrouptoNodes'+MapGrouptoNodes);

        
        List<Node__c> Nodes9 = [Select id, Node_unique_code__c, Parent_node_unique_code__c, Node_level__c FROM Node__c WHERE Parent_node_unique_code__c IN :NodesLV8.keyset() ]; // NOPMD  Fix CRUD violation

        for (Node__c thisNode : Nodes9) {
            NodesLV9.put(thisNode.Node_unique_code__c,thisNode);
            String ParentNodeName = thisNode.Parent_node_unique_code__c;
            Node__c ParentNode = NodesLV8.get(ParentNodeName);
            Set<String> currentNodeList = new set<String>();     
            if (ParentNode!=null) {
                String AgencyCode = ParentNode.Parent_node_unique_code__c;
        
                if (MapGrouptoNodes.get(AgencyCode)!=null) {
                    currentNodeList = MapGrouptoNodes.get(AgencyCode);
                }
                currentNodeList.add('DIF_'+thisNode.Node_unique_code__c);
                MapGrouptoNodes.put(AgencyCode,currentNodeList);
            }
        }

        //The corresponding groups
        set<String> All_Nodes_Name = new set<String>();
        for (string thisAgency : MapGrouptoNodes.keyset()) {
            All_Nodes_Name.addAll(MapGrouptoNodes.get(thisAgency));
        }
        
        List<Group> All_Groups= [SELECT Id, Name, DeveloperName FROM Group WHERE Name IN:All_Nodes_Name ]; // NOPMD  Fix CRUD violation
        
        Map<String, Id> GroupMap = new Map<String,Id>();
        for (group thisGroup : All_Groups) {
            GroupMap.put(thisGroup.DeveloperName, thisGroup.Id);
        }
        system.debug('++++++GroupMap'+GroupMap);
        //For performance preparing, given a Node string of level 7, the Ids of the groups below
        Map<String, set<Id>> MapAgencytoGroupIds = new Map<String, set<Id>>();
        for (string thisAgency :MapGrouptoNodes.keyset()) {
            system.debug('+++++thisAgency'+thisAgency);
            system.debug('+++++thenodes'+ MapGrouptoNodes.get(thisAgency));
            set<Id> CurrentSet = new set<Id>();
            for (string thisNode :MapGrouptoNodes.get(thisAgency) ) {
                string nodetofind = thisNode;
                Id CurrentGroupId = GroupMap.get(nodetofind);
                system.debug('++++++adding node '+thisNode + ' with ID  '+ CurrentGroupId);
                CurrentSet.add(CurrentGroupId);
                system.debug('++++++CurrentSet'+CurrentSet);
            }
            MapAgencytoGroupIds.put(thisAgency,CurrentSet);
        }
        
        system.debug('++++++++MapAgencytoGroupIds'+MapAgencytoGroupIds);
        
        //Computing for each Quotazione__c the set of groups it should be shared to
        Map<Id, set<Id>> MapQuotIDtoGroupID = new Map<Id, set<Id>>();
        
        for (Quotazione__c thisQuot : QuotToShare) {
            //I get the nodes the current Quotazione__c Should be shared with 
            string CurrentAgencyNode = MapQuotToNode.get(thisQuot.Id); //given the Quotazione__c ID finds the Agency Code
            set<Id> CurrentSet = MapAgencytoGroupIds.get(CurrentAgencyNode);            
            MapQuotIDtoGroupID.put(thisQuot.Id, CurrentSet);
        }
        system.debug('++++++++MapQuotIDtoGroupID'+MapQuotIDtoGroupID);

        
        //Computing current share status of all involved Quotazione__cs and groups
        List<Quotazione__Share> CurrentSharing = [SELECT AccessLevel, ParentId, Id, RowCause,UserOrGroupId FROM Quotazione__Share where ParentId IN:MapQuotToNode.keyset() AND UserOrGroupId IN :GroupMap.values() ]; // NOPMD  Fix CRUD violation
        Map<Id,set<Id>> Quotazione_ShareMap = new Map<Id,set<Id>>(); //Each Quotazione__c with the set  of id it is shared with
        
        for (Quotazione__Share thisCS : CurrentSharing) {
            set<Id> currentGroups =  new set<Id>();
            if (Quotazione_ShareMap.get(thisCS.ParentId)!=null) {
                currentGroups= Quotazione_ShareMap.get(thisCS.ParentId);
            }
            currentGroups.add(thisCS.UserOrGroupId);
            Quotazione_ShareMap.put(thisCS.ParentId,currentGroups);
        }
                system.debug('++++++++Quotazione_ShareMap'+Quotazione_ShareMap);

        //Comparing the existing share with the desired one
        list<Quotazione__Share> ShareToInsert = new List<Quotazione__Share>();
        
        for (id thisGroupId : MapQuotIDtoGroupID.keyset()) {
            set<Id> currentGroupsShared = Quotazione_ShareMap.get(thisGroupId);
            set<Id> GroupsToShare = MapQuotIDtoGroupID.get(thisGroupId);
            system.debug('+++++currentSharing'+currentGroupsShared);
            system.debug('+++++DesiredSharing'+GroupsToShare);
            if (currentGroupsShared!=null && GroupsToShare!=null) {
                GroupsToShare.removeAll(currentGroupsShared);
            }
            
            system.debug('++++++NecessarySharing'+GroupsToShare );
            if (GroupsToShare!=null) {
                for (id thisGroupId2: GroupsToShare) {
                    ShareToInsert.add(new Quotazione__Share(ParentId=thisGroupId, UserOrGroupId=thisGroupId2,AccessLevel='Read' ));
                }
            }

        }
        system.debug('++++++ShareToInsert'+ShareToInsert);
        if (!ShareToInsert.isempty()) {
            //MDANTONIO - 24042019: bug fixing - start
            //insert ShareToInsert; 
            upsert ShareToInsert; // NOPMD  Fix CRUD violation
            //MDANTONIO - 24042019: bug fixing - end
            system.debug('++++sharing inserted correctly');
        } else {
            system.debug('++++no share inserted for the Quotazione__cs');
        }
    } 
    
    
    public static void setAgencyCode(List<SObject> myLeads){
        
        system.debug('*************myLeads'+myLeads);
    
        List<Lead> Leads = (List<Lead>)myLeads;
        List<Id> IdLeads = new List<Id>();
        List <Quotazione__c> ListQuots = new List<Quotazione__c>();
        //List<Quotazione__Share> SharetoDelete = new List<Quotazione__Share>();

        for(Lead l: Leads){
        
            IdLeads.add(l.Id); 
      
        }
        
        ListQuots = [SELECT Id, Agency_Code__c, Lead__c FROM Quotazione__c WHERE Lead__c IN: IdLeads];
        //SharetoDelete = [SELECT AccessLevel,Id,IsDeleted,LastModifiedById,LastModifiedDate,ParentId,RowCause,UserOrGroupId FROM Quotazione__Share WHERE ParentId =: quot.Id ];
        system.debug('++++Quotations ----> '+ListQuots);
        
        
        Database.SaveResult[] srList = Database.update(ListQuots, false);
        system.debug('MY RESULT'+srList);
        //Database.update(ListQuots);
        //delete(SharetoDelete);
        
       system.debug('***UPDATED***'); 
        
         
    
    }


}
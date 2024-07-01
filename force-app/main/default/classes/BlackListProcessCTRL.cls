/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         BlackListProcessCTRL
Description:   Controller for the VFP BlackList
History

21/03/2017     Created - D.F.

----------------------------------------------------------------------------*/

global class BlackListProcessCTRL {
    //
    public Account accountDa {get;set;}
    public Account accountA {get;set;}

    public boolean Auto {get;set;}
    public boolean Abitazione {get;set;}
    public boolean Infortuni {get;set;}
    public boolean Malattia {get;set;}
    public boolean Protection {get;set;}
    public boolean Saving {get;set;}
    public boolean Aziende {get;set;}

    public boolean Rinnovo {get;set;}
    public boolean Commerciale {get;set;}
    public boolean Servizio {get;set;}
    public Datetime DataModifica {get;set;}

    public string PageType {get;set;}
    public string SelectedNodesList {get;set;} //list of node codes separated by ";"
    public boolean isReset {get;set;}
    public boolean hasError {get;set;}
    public string ErrorMsg {get;set;}
    public string UserAgency {get;set;}
    public String ActiveStatuses {get; set;}
    public List<ProcessType> listProcess {get;set;}

    public User CurrentUser;
    
    public string teststring {get;set;}

	public class ProcessType {
		public String value {get;set;}
		public Boolean checked {get;set;} 
	}

    public string AllNodes {//deserialised list of nodes available for the current User
        get {
            string NodeQuery = computeNodeQuery(UserInfo.getUserId());
            List<Node__c> AllNodeList = new List<Node__c>();
            if (!String.isempty(NodeQuery) ){
                AllNodeList = Database.query(NodeQuery);
            }
            return String.escapeSingleQuotes(JSON.serialize(AllNodeList));
        }   
    }
    //BOVOLENTA_D Blacklist 2018
    public string AllCampaigns {//deserialised list of campaigns
        get {
            String campaignQuery = 'SELECT Blacklist_available__c,Blacklist_end_date__c,Id,RecordTypeId,Name FROM Campaign WHERE RecordType.DeveloperName in (\'Marketing_Campaign\', \'Informative_Campaign_PCC_MyAXA\') AND Blacklist_available__c = true AND Blacklist_end_date__c >= TODAY ORDER BY Blacklist_end_date__c';      
            List<Campaign> campaignlist = Database.query(campaignQuery);
            return String.escapeSingleQuotes(JSON.serialize(campaignlist));
        }   
    }
    //BOVOLENTA_D END

    //costruttore
    public BlackListProcessCTRL(){
        //at the beginning set node view
        List<String> accountActiveState = new List<String>(AP_Constants.getActiveStatusAccount());
        
        PageType='NODI';
        SelectedNodesList = '';
        teststring = 'constructor';
        isReset = false;
        hasError = false;
        ErrorMsg = 'No Error';
        CurrentUser = [Select id, FirstName, LastName, Profile.Name, Nodes__c,Agency_Code__c from User WHERE Id=:UserInfo.getUserId() ]; // NOPMD  Fix CRUD violation
        UserAgency = CurrentUser.Agency_Code__c;
        ActiveStatuses = '(\''+ String.join(accountActiveState, '\',\'') + '\')';

		this.listProcess = new List<ProcessType>();

		Schema.DescribeFieldResult fieldResult = Account.Blacklist_Processi__c.getDescribe();
		List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListValue : picklistValues){
			ProcessType process = new ProcessType();
			process.value = pickListValue.getValue();
			this.listProcess.add(process);
		}

        
        // string NodeQuery = computeNodeQuery(UserInfo.getUserId());
        // List<Node__c> AllNodeList = new List<Node__c>();
        // if (!String.isempty(NodeQuery) ){
            // AllNodeList = Database.query(NodeQuery);
        // }
        // AllNodes = JSON.serialize(AllNodeList);


    }

    public pagereference PageIsNodi() {
        PageType='NODI';
        return null;
    }

    public pagereference PageIsClienti() {
        PageType='CLIENTI';
        return null;
    }
    //BOVOLENTA_D Blacklist 2018
    public pagereference selectCampaign() {
        String valueOne = Apexpages.currentPage().getParameters().get('selectedValue');
        PageType='CLIENTI_CAMPAGNA';
        system.debug('CLIENTI_CAMPAGNA'+valueOne);
        return null;
    }    

    //BOVOLENTA_D Blacklist 2018
    @RemoteAction
    global static BlackListCampaignQuerier getCampaignMember (String filterString,String filterLastName,String filterFirstName,String filterName,Boolean firstTime, String accType) {

        BlackListCampaignQuerier supportQuerier = new BlackListCampaignQuerier (filterString,filterLastName,filterFirstName,filterName,firstTime,accType);

        return supportQuerier;
    }

    public void submitNodeRequest() {
        hasError=false;
        system.debug('++processing these nodes');
        system.debug(SelectedNodesList);
        
        //first i check that they are within the computed ones
        //List<Node__c> availableNodes = (List<Node__c>)JSON.deserialize(String.escapeSingleQuotes(AllNodes), List<Node__c>.class);
        List<Node__c> availableNodes = DataBase.Query(computeNodeQuery(UserInfo.getuserId()));
        //Preparing set for comparison
        set<String> availableNodesSet = new Set<String>();
        for (Node__c n : availableNodes) 
            availableNodesSet.add(n.Node_Unique_Code__c);

        system.debug('Using these flags');
        system.debug('List Process-->'+listProcess);
        system.debug('ISRESET-->'+isReset);

        if(String.isempty(SelectedNodesList)) {
            //hadle lack of selected nodes
        } else {
            //Get the list of node codes selected
            List<String> NodeCodes = SelectedNodesList.split(';');
            system.debug('NodeCodes-->'+NodeCodes);

			List<String> processListString = new List<String>();
			for(ProcessType process : listProcess) {
				if(process.checked){
					processListString.add(process.value);
				}
			}

            //Populate a map to make it easier to compare
            Map<String,String> InputFromPage = new Map<String,String>();
            InputFromPage.put('Blacklist_Processi__c', String.join(processListString, ';'));//in this way if isReset, it is always false, else it is the same as Auto

            List<Node__c> NodesToUpdate = New List<Node__c>();
			List<Node__c> nodes = [ // NOPMD  Fix CRUD violation
				SELECT Id,
					Node_Unique_Code__c,
					Blacklist_Processi__c,
					Ultima_modifica_blacklist__c
				FROM Node__c
				WHERE Node_Unique_Code__c IN: NodeCodes 
			];

            for(Node__c node : nodes){
                // check if this is a valid node
                if (availableNodesSet.contains(node.Node_Unique_Code__c)) {
                    system.debug('++valid node-->'+node.Node_Unique_Code__c);
                } else {
                    system.debug('not a valid node-->'+node.Node_Unique_Code__c);
                    hasError=true;
                    ErrorMsg='Non si hanno i permessi per modificare il nodo: '+node.Node_Unique_Code__c;
                    NodesToUpdate.clear();
                    break;//exit the loop
                }
                //I apply update the blacklist on the node only id flag and date are changed
                Node__c newNode = new Node__c();
                for(String theField : InputFromPage.keyset()) {
                    system.debug('comparing-->'+theField);
                    system.debug('FromPage-->'+InputFromPage.get(theField));
                    system.debug('FromNode-->'+node.get(theField));
                    if(IsReset || (InputFromPage.get(theField) != null)) { //It must be from false to true, unless isReset
                        NewNode.put('id',node.Id);
                        NewNode.put(theField,InputFromPage.get(theField));
                    }
                }

                //if(node.Ultima_modifica_blacklist__c==null || (node.Ultima_modifica_blacklist__c.date()!=Date.Today())) {//Even if all the same but applied in a different day i must update the date
                    NewNode.put('id',node.Id);//just to consider it for update--> Always update in casa some accounts have been modified
                // }

                if(newNode.Id!=null) {
                    if (!IsReset) {
                        NewNode.put('Ultima_modifica_blacklist__c',DateTime.Now()); //I write the date only if it is not a reset
                    } else {
                        NewNode.put('Ultima_modifica_blacklist__c',null);
                    }
                    NewNode.put('Node_Unique_Code__c',node.Node_Unique_Code__c);
                    NodesToUpdate.add(NewNode);
                }
            }
            if(NodesToUpdate.isempty()) {
                system.debug('did not find anything to update');
            } else {
                System.debug('updating'+NodesToUpdate);
                List<Bulk_Request__c> BRtoInsert = PrepareBulkRequest(NodesToUpdate);//Here i prepare the instances of he bulk requests records that will be processed by the scheduled batch
                try {
                insert BRtoInsert; // NOPMD  Fix CRUD violation
                update NodesToUpdate; // NOPMD  Fix CRUD violation
                } catch (exception e) {
                    hasError=true;
                    ErrorMsg='Si è verificato un errore.';
                }
            }

        teststring = 'submittedOK';
        deselectAllOptions();
        //return Page.BlackList.setRedirect(true);
        //return null;
        }   
    }
    
    //LUCA BASSANI - START - SALVATAGGIO REMOTE
    global class ReturnClass{
        global Boolean success;
        global String description;
        global List<String> ids;
        global List<String> process;
        global String prodotti = '';
        global String campagne = '';
        global String data = '';
    }

    private static List<sObject> getRecordToUpdate(List<sObject> sobjects, Map<String,Object> fieldNameValues){
        System.debug('- getRecordToUpdate -\nsobjects: ' + sobjects + '\nfieldNameValues: ' + fieldNameValues);
        List<sObject> result = new List<sObject>();
        for(Sobject sob : sobjects){
            Boolean isChanged = false;
            for(String fieldName : fieldNameValues.keySet()){
                Object newValue = fieldNameValues.get(fieldName);
                Object oldValue = sob.get(fieldName);
                if(newValue != oldValue){
                    isChanged = true;
                    sob.put(fieldName,newValue);
                }
            }
            //if(isChanged){
                sob.put('Ultima_modifica_blacklist__c' ,DateTime.now());
                result.add(sob);
            //}
        }
        return result;
    }

    @RemoteAction
    global static ReturnClass saveClientiBlackList(List<String> ndgs, Map<String,String> fieldNameValues){
        System.debug('saveClientiBlackList\nndgs: ' + ndgs + '\nfieldNameValues: ' + fieldNameValues);
		String processString = fieldNameValues.get('Blacklist_Processi__c');

        ReturnClass result = new ReturnClass();
        result.ids = ndgs;
        result.data = date.today().format();
        List<Account> clienti = [SELECT Id,NDG__c,BlackList_Auto__c,BlackList_Abitazione__c,BlackList_Infortuni__c,
                                 BlackList_Malattia__c,BlackList_Protection__c,BlackList_Saving__c,BlackList_Aziende__c,BlackList_Rinnovo__c,
                                 BlackList_Commerciale__c,BlackList_Servizio__c, Blacklist_Processi__c
                                 FROM Account 
                                 WHERE NDG__c IN: ndgs];
        List<Account> clientiToUpdate = (List<Account>) getRecordToUpdate(clienti, fieldNameValues);
        if(clientiToUpdate.isEmpty()){
            result.success = true;
            result.description = 'Non stati necessari aggiornamenti';
        } else {
            try {
                update clientiToUpdate;
                result.success = true;
				result.process = (processString != null) ? processString.split(';') : new string[0];
            } catch (DmlException e) {
                result.success = false;
                result.description = 'Errore: ' + e.getMessage() + ' ' + e.getLineNumber();
            }
        }
        return result;
    }

    @RemoteAction
    global static ReturnClass validateClients(List<String> ndgs){
        System.debug('validateClients\nndgs: ' + ndgs);//the page provide all ndgs on the current page
        //Here we check if the Ultima_modifica_blacklist__c is populated and update accordingly
        
        ReturnClass result = new ReturnClass();
        
        result.data = date.today().format();//the Date to be displayed on the Table
        Datetime currentValue = Datetime.now(); //so all accounts have the same datetime
        
        List<Account> clientInScope = [SELECT Id,NDG__c,Ultima_modifica_blacklist__c
                                         FROM Account 
                                         WHERE NDG__c IN: ndgs];

                                         
        List<Account> clientiToUpdate = new List<Account>();
        List<String> ndgUpdated = new List<String>();
        
        try{
            for(Account acc : clientInScope){
                system.debug('acc in scope-->'+acc);
                system.debug('acc in scope Ultima_modifica_blacklist__c-->'+acc.Ultima_modifica_blacklist__c);
                if(acc.Ultima_modifica_blacklist__c==null) {
                    system.debug('++++updating-->'+acc);
                    Account thisAcc = new Account(Id=acc.Id,Ultima_modifica_blacklist__c=currentValue);
                    clientiToUpdate.add(thisAcc);
                    ndgUpdated.add(acc.NDG__c);
                    system.debug('ndgUpdated-->'+ndgUpdated);
                }
            }
            system.debug('ndgUpdated-->'+ndgUpdated);
            update clientiToUpdate;
            result.success = true;
            result.ids = ndgUpdated;

            
        } catch (DmlException e) {
            result.success = false;
            result.description = 'Errore: ' + e.getMessage() + ' ' + e.getLineNumber();
        }
        system.debug('theresult-->'+result);
        return result;
    }

    //LUCA BASSANI - END - SALVATAGGIO REMOTE

    public string computeNodeQuery(Id UserId) {
        string myQ = 'Select Node_unique_code__c, Node_description__c,';
        
        //The single flags (prducts)
        myQ = myQ +'BlackList_Abitazione__c,';
        myQ = myQ +'BlackList_Auto__c,';
        myQ = myQ +'BlackList_Aziende__c,';
        myQ = myQ +'BlackList_Infortuni__c,';
        myQ = myQ +'BlackList_Malattia__c,';
        myQ = myQ +'BlackList_Protection__c,';
        myQ = myQ +'BlackList_Saving__c,';

        //The single Flags (types)
        myQ = myQ +'BlackList_Rinnovo__c,';
        myQ = myQ +'BlackList_Commerciale__c,';
        myQ = myQ +'BlackList_Servizio__c,';

        //Other fields
        myQ = myQ +'Blacklist_Processi__c,';
        myQ = myQ +'Ultima_modifica_blacklist__c ';  
        
        List<User> Usrs = [Select id, FirstName, LastName, Profile.Name, Nodes__c,Agency_Code__c from User WHERE Id=:UserId ]; // NOPMD  Fix CRUD violation
        if(Usrs.isempty()) {
            system.debug('NO USER FOND WITH ID-->'+UserId);
            myQ = '';
        } else {
            User U = Usrs[0];
            if (String.isempty(U.Agency_Code__c)) {
                myQ = myQ +'from Node__c ORDER BY Node_unique_code__c'; //if no agency code sowing all nodes
            } else {
                //if is on agnecy node can show all nodes
                List<String> profiledNodes = U.Nodes__c.remove('DIF_').split(';');
                Set<String> profiledNodesSet = New set<String>(profiledNodes);
                system.debug('++++profiledNodesSet'+profiledNodesSet);
                if(profiledNodesSet.contains(U.Agency_Code__c)) {
                    myQ = myQ +'from Node__c WHERE Node_unique_code__c LIKE \''+U.Agency_Code__c +'%\' ORDER BY Node_unique_code__c'; //if no agency code sowing all nodes
                } else {
                    myQ = myQ +'from Node__c WHERE Node_unique_code__c IN (';//Getting all profiled nodes
                    for (string thisNode : profiledNodesSet) {
                        myQ = myQ + '\''+thisNode+'\',';
                    }
                    myQ = myQ.REmoveEnd(',');
                    
                    myQ = myQ+') OR Parent_node_unique_code__c IN (';//getting all child nodes
                    for (string thisNode : profiledNodesSet) {
                        myQ = myQ + '\''+thisNode+'\',';
                    }
                    myQ = myQ.REmoveEnd(',');                    
                    myQ = myQ+') ORDER BY Node_unique_code__c';
                }
                
            }
            system.debug('computed string-->'+myQ);
            
        }
        
        return myQ;
    }

    
    public List<Bulk_Request__c> PrepareBulkRequest(List<Node__c> Nodes) {
        //this method, given a List of nodes with the blacklist flags and date populated insert the corresponding bulkRequest reocrds. one per each node
        List<Bulk_Request__c> BRtoInsert = new List<Bulk_Request__c>();
        for (Node__c thisN : Nodes) {
            Bulk_Request__c thisBR = new Bulk_Request__c();
            thisBR.BulkRequestHandler__c = 'BulkRequest_BlackListProcess';
            //computing the json instance for the batch
            //remeber it will be tha batch to check account per account wheter to ovverride or not

            //this instance is the same as the handler 
            BulkRequest_BlackListProcess BR_instance = new BulkRequest_BlackListProcess();
            BR_instance.listProcess = (thisN.Blacklist_Processi__c != null) ? thisN.Blacklist_Processi__c.split(';') : new string[0];
			BR_instance.DataModifica = thisN.Ultima_modifica_blacklist__c;

            if(thisN.Ultima_modifica_blacklist__c==null) {
                BR_instance.DateRequest = DateTime.Now();
            } else {
                BR_instance.DateRequest=thisN.Ultima_modifica_blacklist__c;
            }

            if(isReset) 
                BR_instance.Origin='NODI_RESET';//In this way the BulkHandler update all flags

            thisBR.JsonInstance__c = JSON.serialize(BR_instance);
            thisBr.Node__c=thisN.id;
            thisBr.Query__c = 'SELECT Id, Blacklist_Processi__c, Ultima_modifica_blacklist__c ';

            if (thisN.Node_Unique_Code__c.length()>6) {
                //BOVOLENTA_D 25062018 removed active client filter State__c =\'Active Client\' AND 
                thisBr.Query__c = thisBr.Query__c + 'FROM Account where AAI_Agency_Reference_Code__c=\''+thisN.Node_Unique_code__c.left(6)+'\' AND Nodes__c LIKE \'%'+thisN.Node_Unique_Code__c+'%\'';//looking for the specific subnode in the middle of the string
            } else {
                thisBr.Query__c = thisBr.Query__c + 'FROM Account where AAI_Agency_Reference_Code__c=\''+thisN.Node_Unique_code__c.left(6)+'\' AND (Nodes__c = \''+thisN.Node_Unique_Code__c+'\' OR Nodes__c = \''+thisN.Node_Unique_Code__c+';\') ';//looking only for the agency code (also with ;)
            }

            thisBR.Request_by__c = Userinfo.getUserId();
            thisBR.Status__c='SUBMITTED';
            if(thisN.Ultima_modifica_blacklist__c!=null) {
                thisBR.Submission_date__c = thisN.Ultima_modifica_blacklist__c;
            } else {
                thisBR.Submission_date__c = DateTime.Now();
            }
            BRtoInsert.add(thisBR);
        }
        system.debug('prepared the following BR-->'+BRtoInsert );
        return BRtoInsert;
        
    }
    
    public void deselectAllOptions() {
        Auto =false;
        Abitazione =false;
        Infortuni =false;
        Malattia =false;
        Protection =false;
        Saving =false;
        Aziende =false;
    
        Rinnovo =false;
        Commerciale =false;
        Servizio =false;

    }
    
    

}
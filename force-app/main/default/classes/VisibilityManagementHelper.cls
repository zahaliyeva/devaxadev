/*------------------------------------------------------------------------
Author:        Davide Fabris
Company:       Deloitte
Class:         VisibilityManagementHelper
Description:   Helper Class to perform visibility operations. Including CIF integration
History
-13/06/2015   Davide Fabris - Created
----------------------------------------------------------------------------*/

public class VisibilityManagementHelper {
    public static final Id AXA_TECHNICAL_USER_ID = (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID') != null ? (AAI_Code_Variables__c.getAll()).get('AXA_TECHNICAL_USER_ID').Value__c : UserInfo.getUserId();


    public static IE_Integration_Record__c PopulateIErecord(List<CampaignMembersViewCTRL.VisibilityRowItem> items, String Node) {
        //Integration used on the campaign page to add 1 node to multiple accounts
        IE_Integration_Record__c theResult = new IE_Integration_Record__c();
        List<IE_Configuration__c> theConfig = [SELECT id FROM IE_Configuration__c WHERE Name='CIF_nodes_onCampaign'  LIMIT 1]; // NOPMD  Fix CRUD violation
        if (!theConfig.isempty()) {
            theresult.IE_Configuration__c = theConfig[0].id;
        }
        
        Set<String> NdgSet = new set<String>();
        for (CampaignMembersViewCTRL.VisibilityRowItem thisItem : items) {
            system.debug('+++++ contactId'+thisItem.cm.contactId);
            system.debug('+++++ NDG'+thisItem.cm.contact.Account.NDG__c);
            NdgSet.add(thisItem.cm.contact.Account.NDG__c);
        }
        //Compiling the DevField with the JSON of the Node and NDG required
        JSONGenerator myGen= JSON.createGenerator(true);
        myGen.writeStartObject();
        myGen.writeStringField('NODE', Node);
        myGen.writeObjectField('NDGs', NdgSet);
        myGen.writeEndObject();

        theresult.DevField__c=myGen.getAsString(); 

        return theResult;
    }
    
    public static IE_Integration_Record__c PopulateIErecord(String NDG, Set<String> Nodes, string Action) {
        //Integration used on the Account page to ADD/REMOVE multiple nodes to a single account
        IE_Integration_Record__c theResult = new IE_Integration_Record__c();
        List<IE_Configuration__c> theConfig = [SELECT id FROM IE_Configuration__c WHERE Name='CIF_nodes_onAccount'  LIMIT 1]; // NOPMD  Fix CRUD violation
        if (!theConfig.isempty()) {
            theresult.IE_Configuration__c = theConfig[0].id;
        }
        system.debug('Nodes: '+Nodes);
        //Compiling the DevField with the JSON of the Nodes and NDG required
        JSONGenerator myGen= JSON.createGenerator(true);
        myGen.writeStartObject();
        myGen.writeStringField('tipoOperazione', Action);
        myGen.writeStringField('NDG', NDG);
        myGen.writeObjectField('NODEs', Nodes);
        myGen.writeEndObject();

        theresult.DevField__c=myGen.getAsString(); 

        return theResult;
    }
    

    public static List<CampaignMembersViewCTRL.VisibilityRowItem> UpdateVisibilityAndAssign(IE_Engine IEInstance,List<CampaignMembersViewCTRL.VisibilityRowItem> Old_cmNotVisible, user usrToAssign, string SelectedNode, boolean sendEmail) {
        List<CampaignMembersViewCTRL.VisibilityRowItem> NewVisibilityList =  new List<CampaignMembersViewCTRL.VisibilityRowItem>();//the new list to display
        List<CampaignMember> CMtoUpdate = new List<CampaignMember>();
        List<Account> AccToUpdate = new List<Account>();
        
        //Analise the reposnse
        system.debug('++++processing response+++++');
        system.debug(IEInstance.JSONResponse);
        system.debug('++++processing response+++++');
        
        //Query again in order to retrieve the most updated info
        set<ID> CMIds = new set<Id>();
        for (CampaignMembersViewCTRL.VisibilityRowItem thisItem : Old_cmNotVisible) {
            CMIds.add(thisItem.cm.Id);
        }
        
        Map<Id,CampaignMember> LatestCM = new Map<Id, CampaignMember>([SELECT Id, Campaign.URL_Salesforce_campagna__c, Campaign.Name,Campaign.Type, CampaignId,Campaign.StartDate,Campaign.EndDate, status,Nodes__c,contact.Account.NDG__c,  contact.account.Nodes__c, Owner__c FROM CampaignMember WHERE Id IN:CMids]);
        
        //The response will be formatted as a map NDG-->List<String>. The list of string contains first the esito code and second the  description
        //If a general error occurs (for example the node selected is non existent the map will be empty as the call failed for every client)
        Map<String,List<String>> formattedResponse = ResponseToMap(IEInstance.JSONResponse);
        
        for (CampaignMembersViewCTRL.VisibilityRowItem thisItem : Old_cmNotVisible) {
            system.debug('+++++thisItem'+thisItem);
            //CampaignMember thisCM = thisItem.cm;//Starting with the old CM
            CampaignMember thisCM = LatestCM.get(thisItem.cm.id);
            //Going for the selected ones
            if (thisItem.IsSelected) {
                system.debug('+++++thisItem.cm.Contact.Account.NDG__c'+thisItem.cm.Contact.Account.NDG__c);
                List<string> theEsito = formattedResponse.get(thisItem.cm.Contact.Account.NDG__c);
                if (theEsito!=null && (!theEsito.isEmpty())) {
                    thisItem.Result=theEsito[1];//updating the Message
                    if (theEsito[0]=='OK') {

                        //Proceeding with update of CM 
                        thisCM.Owner__c=usrToAssign.Id;//updating Owner
                        if (thisCM.status.tolowercase()=='in campagna'||thisCM.status.tolowercase()=='da assegnare') {//Updating Status if assigned from "in campagna" or "da assegnare"
                            thisCM.status='Da contattare';
                        }

                        CMtoUpdate.add(thisCM);
                        
                        //Proceeding with update of Account
                        Account thisAcc = new Account();//Starting with new Acc
                        thisAcc.Id = thisCM.contact.Account.Id;
                        thisAcc.NDG__c=thisCM.contact.Account.NDG__c;
                        List<String> OldNodesList = thisCM.contact.account.Nodes__c.split(';');
                        Set<String> OldNodesSet = new set<String>();
                        OldNodesSet.addAll(OldNodesList);
                        if (!OldNodesSet.contains(SelectedNode)) {
                            thisAcc.Nodes__c=thisCM.contact.account.Nodes__c+';'+SelectedNode;
                            //Here populate flag for batch
                            thisAcc.TECH_Batch_Visibility__c=true;
                        }
                        AccToUpdate.add(thisAcc);   

                    } //No else required as if it is KO I already updated the message
                } else {
                    List<string> GeneralError = formattedResponse.get('');
                    if (GeneralError==null || GeneralError.isEmpty()) {
                        thisItem.Result='Non processato';
                    } else {
                        thisItem.Result='Non processato'+' - '+formattedResponse.get('')[1];//Adding the general error non associateted to an NDG
                    }
                }
            } else {
                thisItem.Result='Non selezionato';
            }
            
            
            thisItem.cm=thisCM;//passing the updated CM
            NewVisibilityList.add(thisItem);
        }
        
        //proceeding with the update
        //try {
        List<Database.SaveResult> AccResult = Database.update(AccToUpdate, false);//allowing partial update
        List<Database.SaveResult> CMResult = Database.update(CMtoUpdate, false);//allowing partial update
        
        //setting up a map to populate the page with the updated info
        Map<Id, Account> updatedAcc = new Map<Id, Account>();
        
        for (Account thisAcc: AccToUpdate) {
            updatedAcc.put(thisAcc.Id, thisAcc);
        }
        
        //Passing in the updated infos
        for (CampaignMembersViewCTRL.VisibilityRowItem thisItem : NewVisibilityList) {
            if (updatedAcc.get(thisItem.cm.contact.Account.Id)!=null)//modify only if updated 
            thisItem.cm.contact.Account=updatedAcc.get(thisItem.cm.contact.Account.id);
            system.debug('++++passing the updated acc'+thisItem.cm.contact.account);
        }
        
        //} catch (exception e) {
        //revrite the visibility list here
        //}
        
        if (!CMtoUpdate.isempty()) {
            //Proceed with sending the email
            if (sendEmail) {
                // sending email
                string CName = cmToUpdate.get(0).Campaign.Name+'';
                string CType = cmToUpdate.get(0).Campaign.Type+'';
                string CId = cmToUpdate.get(0).CampaignId+'';
                string Cstart = '';
                string Cend = '';
                string CUrl = cmToUpdate.get(0).Campaign.URL_Salesforce_campagna__c + '';
                
                if (cmToUpdate.get(0).Campaign.StartDate==null) {
                    Cstart = 'Non disponibile';
                } else {
                    Cstart = cmToUpdate.get(0).Campaign.StartDate.format()+'';
                }
                
                if (cmToUpdate.get(0).Campaign.EndDate==null) {
                    Cend = 'Non disponibile';
                } else {
                    Cend = cmToUpdate.get(0).Campaign.EndDate.format()+'';
                }
                
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail = CampaignMembersViewCTRL.prepareEmailForAsssignment(usrToAssign, CName, Cid, Cstart,Cend, cUrl);
                system.debug('+++++++++mail prepared'+mail);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                system.debug('+++++EMAIL limit (calls/limit)='+Limits.getEmailInvocations()+'/'+Limits.getLimitEmailInvocations());
            }
        }
        return NewVisibilityList;
    }
    
    public static Map<String,List<String>> ResponseToMap(string JSONResponse) {
        Map<String,List<String>> result = new Map<String,List<String>>();
        List<Object> ResponseList = JSONUtility.getObjectList(JSONResponse, 'listaNdgOutput');
        for (Object thisResp: ResponseList) {
            
            system.debug('+++++ndg'+JSONUtility.getField(thisResp, 'ndg'));
            string theNDG = JSONUtility.getField(thisResp, 'ndg')[0];
            
            List<string> singleRes = new List<String>();
            system.debug('++++++'+JSONUtility.getField(thisResp, 'esito'));
            singleRes.addAll(JSONUtility.getField(thisResp, 'esito'));
            
            system.debug('++++++'+JSONUtility.getField(thisResp, 'descrizioneEsito'));
            singleRes.addAll(JSONUtility.getField(thisResp, 'descrizioneEsito'));
            
            result.put(theNDG,singleRes);
        }
        system.debug('++++++returning'+result);
        return result;
    }


    public static accountVisibilityResponse mapAccountExtensionResponse (String JSONResponse) {
        accountVisibilityResponse emptyInstance = new accountVisibilityResponse();
        Type typeInstance = Type.forName('accountVisibilityResponse');
        accountVisibilityResponse deserializeResults = (accountVisibilityResponse)JSON.deserialize(JSONResponse, typeInstance);
        System.debug('***************deserialize() results = ' + deserializeResults);
        return deserializeResults;
    }

    public static map <String,map<String,String>> manageAccountExtensionResponse (IE_Engine IEInstance, Account selectedAccount)
    {//List <GestioneNodiCTRL.NodoRowItem> selectedNodes,
        map <String,map<String,String>> results = new map <String,map<String,String>>();
        //need to modify the JSONREPONSE to add the reisposta structure
        string ModResp ='{'+  '"risposta":';
        ModResp = ModResp+IEInstance.JSONResponse+'}';
        system.debug('++++ MODIFIED WITH WRAPPER'+ ModResp);
        
        //accountVisibilityResponse formattedResponse = mapAccountExtensionResponse(IEInstance.JSONResponse);
        accountVisibilityResponse formattedResponse = mapAccountExtensionResponse(ModResp);        /*   List <String> accountNodes = new list <String>();
        accountNodes = theAccount.Nodes__c.split(';',0);
        Set <String> accountNodesSet = new Set <String>(accountNodes);*/
        if (formattedResponse == null)
        {
            //errore risposta vuota
            return results;
        }

        if(formattedResponse.risposta.ListaNodiOutput.size() == 1 && (formattedResponse.risposta.ListaNodiOutput[0].nodo[0] == null ||formattedResponse.risposta.ListaNodiOutput[0].nodo[0] == '') && formattedResponse.risposta.ListaNodiOutput[0].esito == 'KO'){
            //errore sintattico nella richiesta
        }
        map <String,String> currentOutputMap;
        for (accountVisibilityResponse.OutputNodo outputCurrentNode :formattedResponse.risposta.ListaNodiOutput)
        {
            currentOutputMap = new map <String,String>();
            currentOutputMap.put ('esito',outputCurrentNode.esito);
            currentOutputMap.put ('descrizioneEsito',outputCurrentNode.descrizioneEsito);
            results.put (outputCurrentNode.nodo[0],currentOutputMap);
            /*    outputCurrentNode.nodo
            outputCurrentNode.esito
            outputCurrentNode.descrizioneEsito */
        }
        //FMARCHESE - BUGFIX LISTANODIAGGIORNATA ORDERING -- START
        formattedResponse.risposta.listaNodiAggiornata.Nodo.sort();
        system.debug('ordered listaNodiAggiornata'+formattedResponse.risposta.listaNodiAggiornata.Nodo);
        //FMARCHESE - BUGFIX LISTANODIAGGIORNATA ORDERING -- END
        //nodes update part
        String newNodes = '';
        for (String updatedNode :formattedResponse.risposta.listaNodiAggiornata.Nodo){
            system.debug('############'+updatedNode);
            newNodes = newNodes+';'+updatedNode.trim();//MOSCATELLI_M 04/07/2017: Bugfix - introduced trim
        }
        newNodes= newNodes.removeStart(';');
        if (newNodes!= ''){//just in case           
            selectedAccount.Nodes__c = newNodes;
            selectedAccount.TECH_Batch_Visibility__c = True;
            Update selectedAccount;
        }
        return results;
    }
    
    public static List<Node__c> getNodesWhereVisible(Account Acc) {
        //Given an Account set of nodes wher eit is visible  
        List<Node__c> result = new List<Node__c>();
        if (string.isBlank(Acc.Nodes__c)) {
            return result;
        } else {
            List<String> NodesOnAcc = Acc.Nodes__c.split(';');
            Set<String> NodesOnAccSet = new set<String>(NodesOnAcc);
            result = [SELECT Id , Node_unique_code__c, Parent_node_unique_code__c, Node_level__c FROM Node__c WHERE Node_unique_code__c IN:NodesOnAccSet AND Node_level__c>6 ]; // NOPMD  Fix CRUD violation
            for (Node__c thisN : result) {
                NodesOnAccSet.add(thisN.Parent_node_unique_code__c);
            }
            result = [SELECT Id , Node_unique_code__c, Parent_node_unique_code__c, Node_level__c FROM Node__c WHERE Node_unique_code__c IN:NodesOnAccSet AND Node_level__c>6 ]; // NOPMD  Fix CRUD violation

        }
        system.debug('++++result'+result);
        return result;
    }
    
    public static set<String> getAccessibleNodes (user Us, List<Node__c> N) {
        //Given a list of nodes returns a list of strings containing the nodes the user has access to.
        // WARNING /!\ WARNING --> meant ot be used for Agents and SubAgents
        //In order to prevent QUERY on loop thi smethods checks only the nodes provided (N)
        set<String> result = new set<String>();
        
        List<String> UserNodes = Us.Nodes__c.remove('DIF_').split(';');
        Set<String> UserNodesSet = new set<String>(UserNodes);
        String AgCode = Us.Agency_Code__c;
        
        for (Node__c thisN : N) {
            if (UserNodesSet.contains(thisN.Node_unique_code__c) || 
                    UserNodesSet.contains(thisN.Parent_node_unique_code__c) ||
                    result.contains(thisN.Node_unique_code__c) || 
                    result.contains(thisN.Parent_node_unique_code__c) ) {
                result.add(thisN.Node_unique_code__c);
            }
            if (thisN.Node_unique_code__c.contains(AgCode) && UserNodesSet.contains(AgCode)) {
                result.add(thisN.Node_unique_code__c);
            }
        }
        
        
        
        return result;
    }
    
    //Method invoked on a batch for accounts with 
    public static List<Sobject> AlignVisibility_BATCH (List<Sobject> SoList) {
        //Assuming to get a list of Account
        List<Account> inputAcc = (List<Account>) SoList;
        
        Set<Id> AccIds = new set<Id>();
        
        //DO THE UPDATE HERE
        for (Account a : inputAcc) {
            a.TECH_Batch_Visibility__c=false;//Remove the flag in order to avoid the record to be included in the next batch
            AccIds.add(a.id);
            system.debug('+++++a'+a);
        }
        
        //Realted objects for which I need to recalculate the visibility
        List<InsurancePolicy__c> PolToUpdate = new List<InsurancePolicy__c>();
        List<Claim__c> ClaimToUpdate = new List<Claim__c>();
        List<Feedback__c> FeedbacktoUpdate = new List<Feedback__c>();
        
        //Related objects that need reassignment
        List<Opportunity> OppToCheck = new List<Opportunity>();
        List<Task> TaskToCheck = new List<Task>();
        List<Event> EventToCheck = new List<Event>();
        List<CampaignMember> CM_ToCheck = new List<CampaignMember>();
        List<Contact> Contact_ToCheck = new List<contact>();
        
        //Retrieve the objects
        PolToUpdate = [SELECT id FROM InsurancePolicy__c WHERE CUID__c IN:AccIds];
        ClaimToUpdate = [SELECT id FROM Claim__c WHERE Account__c IN:AccIDs];
        FeedbacktoUpdate=[SELECT id FROM Feedback__c WHERE Account__c IN:AccIds AND Recordtype.Developername='AAI_Feedback'];
        
        OppToCheck = [SELECT Id, OwnerId, Owner.Name, Account.Nodes__c, Account.AAI_Agency_Reference_Code__c, Owner.Nodes__c, Owner.Agency_Code__c FROM Opportunity WHERE AccountId IN:AccIDs];
        // TaskToReassign = [Select id, Subject, OwnerId, Account.Nodes__c FROM Task WHERE Accountid IN:AccIDs AND isClosed=false];//Cannot navigate to owner nodes as the owner can be a queue
        // EventToReassign = [SELECT id, OwnerId, Owner.Name,Account.Nodes__c FROM Event WHERE AccountId IN:AccIDs AND EndDateTime>TODAY];//Cannot navigate to owner nodes as the owner can be a queue
        // CM_ToReassign = [SELECT id, Campaign.Name, Owner__c, Owner__r.Nodes__c, Contact.Account.Nodes__c From CampaignMember WHERE Contact.Account.Id IN:AccIDs AND (Status = 'On-going' OR Status = 'Planned')];
        Contact_ToCheck = [SELECT id, OwnerId from Contact WHERE AccountId IN: AccIDs];
        
        system.debug('+++OppToCheck'+OppToCheck);
        //For polizze and sinistri simple update to trigger visibility on formula field
        update PolToUpdate;
        update ClaimToUpdate;
        update FeedbacktoUpdate;
        
        //For the other objects I need to check if the current nodes allow the owner to see the client. Cannot use URA as owning a Opportunity opens upd the visibility
        List<Opportunity> OppToUpdate = CheckvisibilityAndReassign(OppToCheck);
        List<Contact> contactToUpdate = CheckVisibilityAndReassign(Contact_ToCheck);
        
        update OppToUpdate;
        update ContactToUpdate;
        
        //Retrun the account fo rthe batch
        return inputAcc;
    }
    
    public static List<Contact> CheckVisibilityAndReassign(List<contact> ContactList) {
        // All reassigned to the technical user
        List<contact> ContactToUpdate = new List<contact>();
        
        for (contact thisC : ContactList) {
            if (thisC.OwnerId != AXA_TECHNICAL_USER_ID) {
                thisC.OwnerId = AXA_TECHNICAL_USER_ID;
                ContactToUpdate.add(thisC);
            }
        }
        return ContactToUpdate;
    }
    
    public static List<Opportunity> CheckvisibilityAndReassign(List<Opportunity> OppList) {
        //Assume the owner fields have been retrieved in the passed opportunity
        system.debug('++'+OppList);
        if (OppList.isempty()) {
        return Opplist;
        }
        
        //First retrieve the information avout the nodes structure
        // the first get providesa map with keys the nodes of level 8 and values the list of level 9
        Map<String, Map<String,Set<String>>> AgencyNodeMap = new Map<String, Map<String,Set<String>>>();
        
        Set<String> TheAgencies = new set<String>();
        
        for (Opportunity thisOpp : OppList) {
            TheAgencies.add(thisOpp.Account.AAI_Agency_Reference_Code__c);
            system.debug('+++'+thisOpp);
        }
        
        string QueryToRun = 'SELECT Id , Node_unique_code__c, Parent_node_unique_code__c, Node_level__c FROM Node__c WHERE Node_level__c>6 AND (';

        for (string s : TheAgencies) {
            QueryToRun = QueryToRun + 'Node_unique_code__c LIKE \'' +s+'%\' OR ';
            //Preparing the map as well
            //Map<String,Set<String>> theEmptyMap = new Map<String,Set<String>>();
            //AgencyNodeMap.put(s,theEmptyMap);
        }
        
        QueryToRun = QueryToRun.removeEnd('OR ');
        QueryToRun = QueryToRun + ')';
        system.debug('++++QueryToRun'+QueryToRun);
        
        List<Node__c> theNodes = Database.query(QueryToRun);
        system.debug('+++++'+theNodes.size());

        integer Nqueries = 0;
        integer AllowedQ = 0;
        
        Nqueries = Limits.getQueries();
        AllowedQ = Limits.getLimitQueries();
        system.debug('###############'+Nqueries+'\\'+AllowedQ);

        AgencyNodeMap = getAgencyStructure(theNodes);
        
        Nqueries = Limits.getQueries();
        AllowedQ = Limits.getLimitQueries();
        system.debug('###############'+Nqueries+'\\'+AllowedQ);
        
        List<Opportunity> OppToReassign = new List<Opportunity>();
        Set<String> theAgenciesInvolvedforReasignment = new Set<String>();

        for (Opportunity thisOpp : OppList) {
            
            boolean hasVisibility = checkOppVisibility(thisOpp.Owner.Nodes__c, thisOpp.Account.Nodes__c, AgencyNodeMap);
            
            Nqueries = Limits.getQueries();
            AllowedQ = Limits.getLimitQueries();
            system.debug('###############'+Nqueries+'\\'+AllowedQ);
            
            system.debug('+++++++thisOpp.Account.Nodes__c'+thisOpp.Account.Nodes__c);
            system.debug('+++++++thisOpp.Owner.Nodes__c'+thisOpp.Owner.Nodes__c);
            system.debug('+++++++thisOpp.ID'+thisOpp.Id);
            system.debug('++++hasvisiblity'+hasVisibility);
            
            if (!hasVisibility) {
                OppToReassign.add(thisOpp);
                theAgenciesInvolvedforReasignment.add(thisOpp.Account.AAI_Agency_Reference_Code__c);
            }
            

        }
        
        Map<String,Id> NewOwnersbyAgency = new Map<String,Id>();
        
        List<User> PossibleUsers = [SELECT Id, FirstName, LastName,Agency_Code__c,Nodes__c from User where isActive = true AND Profile.Name = 'NFE - AAI - Vendite Avanzato' and Agency_Code__c IN: theAgenciesInvolvedforReasignment  ORDER BY CreatedDate DESC]; // NOPMD  Fix CRUD violation
        
        for(User U : PossibleUsers) {
            //Not only must be "Vendite Avanzato" must be profiled on agency node
            List<String> profiledNodesList = new List<String>();
            string thisUnodes = U.Nodes__c;
            thisUnodes = thisUnodes.remove('DIF_');
            profiledNodesList = thisUnodes.split(';');
            system.debug('++++'+profiledNodesList);
            system.debug('++++'+U.Agency_Code__c);
            
            set<String> profiledNodesSet = new Set<String>(profiledNodesList);
            //given the sorting of the query i end up with the oldest user, that should be the agent
            if (profiledNodesSet.contains(U.Agency_Code__c)) {
                NewOwnersbyAgency.put(U.Agency_Code__c, U.Id);
            }
        }
        
        system.debug('+++++NewOwnersbyAgency'+NewOwnersbyAgency);
        
        Nqueries = Limits.getQueries();
        AllowedQ = Limits.getLimitQueries();
        system.debug('###############'+Nqueries+'\\'+AllowedQ);
        
        for (Opportunity thisOpp : OppToReassign) {
            thisOpp.Titolare_precedente__c = thisOpp.Owner.Name;
            thisOpp.OwnerId = NewOwnersbyAgency.get(thisOpp.Account.AAI_Agency_Reference_Code__c);
        }
        return OppToReassign;
        
    }
    
    public static boolean  checkOppVisibility(String theUserNodes, string TheAccountNodes, Map<string,map<String,set<String>>> theAgencyStructure) {
        List<String> userProfiledNodes = new List<String>();
        List<String> AccountProfiledNodes = new List<String>();

        if (!String.isblank(theUserNodes)) {
            userProfiledNodes = theUserNodes.remove('DIF_').split(';');
        }
        
        if (!String.isblank(TheAccountNodes)) {
            AccountProfiledNodes = TheAccountNodes.split(';');
        }

        Set<String> NodesVisibletoUser =new Set<String>(userProfiledNodes);
        set<String> NodesWhereAccountAvailable = new Set<String>(AccountProfiledNodes);
        
        for(string thenode : NodesVisibletoUser) {
            if (theAgencyStructure.keyset().contains(theNode)) {
                //profiled to the agency level
                return true;
            } else {
                string theAgencycode = theNode.left(6);
                Map<String,set<String>> currentMap = theAgencyStructure.get(theAgencycode);
                if (currentMap.keyset().contains(theNode)) {//Profiled to lv 8
                    NodesVisibletoUser.addAll(currentMap.get(theNode));
                }//Nothing to do on else, as it is profiled to a lv 9 node
            }
        }
        
        //I only have to consider the nodes of lv 9, and add the corresponding level 8
        string theAgencycode = AccountProfiledNodes[0].left(6);
        Map<String,set<String>> currentMap = theAgencyStructure.get(theAgencycode);
        for(String nodeLV8: currentMap.keyset()) {
            set<string> NodesLV9 = currentMap.get(NodeLV8);
            for (string nodeLV9: NodesLV9) {
                if (NodesWhereAccountAvailable.contains(nodeLV9)) {
                    NodesWhereAccountAvailable.add(NodeLV8);
                    system.debug('+++++adding++'+NodeLV8+'becuase the account is available on node'+nodeLV9);
                }
            }
        }
        
        system.debug('++++user visibility'+NodesVisibletoUser );
        system.debug('++++Account visibility'+NodesWhereAccountAvailable );
        
        boolean hasvisibility = false;
        
        for (string s : NodesWhereAccountAvailable) {
            if (NodesVisibletoUser.contains(s)) {
                hasvisibility = true;
                break;
            }
        }
        
        return hasvisibility;

    }
    


    public static Map<String, Map<String,Set<String>>> getAgencyStructure(List<Node__c> theNodes) {
        Map<String, Map<String,Set<String>>> AgencyNodeMap = new Map<String, Map<String,Set<String>>>();
        
        for (Node__c thisN : theNodes) {
            if (thisN.Node_level__c==7) {
                string Agencycode = thisN.Node_unique_code__c;
                Map<String,set<String>> currentMap = AgencyNodeMap.get(Agencycode);
                if (currentMap==null || currentMap.keyset().isempty()) {
                    currentMap = new Map<String,Set<String>>();
                    AgencyNodeMap.put(Agencycode, CurrentMap);
                }

            }
            
            
            
            if (thisN.Node_level__c==8) {
                //For the given agency contains a map with keyset the level 8 nodes and values a list of level 9 nodes
                string Agencycode = thisN.Parent_node_unique_code__c;
                Map<String,set<String>> currentMap = AgencyNodeMap.get(Agencycode);
                if (currentMap==null || currentMap.keyset().isempty()) {
                    currentMap = new Map<String,Set<String>>();
                    AgencyNodeMap.put(Agencycode, CurrentMap);
                }
                system.debug('++++++currentMap'+currentMap);
                system.debug('++++++AgencyNodeMap'+AgencyNodeMap);
                
                if (!currentMap.keyset().contains(thisN.Node_unique_code__c)) {
                    Set<String> currentList = new Set<String>();
                    currentMap.put(thisN.Node_unique_code__c,currentList);
                } //nothing to do in the else

                AgencyNodeMap.put(Agencycode,currentMap);
            }
            
            if (thisN.Node_level__c==9) {                
                //For the given agency contains a map with keyset the level 8 nodes and values a list of level 9 nodes
                string Agencycode = thisN.Parent_node_unique_code__c.Left(6);
                Map<String,set<String>> currentMap = AgencyNodeMap.get(Agencycode);
                if (currentMap==null || currentMap.keyset().isempty()) {
                    currentMap = new Map<String,Set<String>>();
                    AgencyNodeMap.put(Agencycode, CurrentMap);
                }
                
                set<String> CurrentList = currentMap.get(thisN.Parent_node_unique_code__c);
                if (currentList==null || currentList.isempty()) {
                    CurrentList = new set<String>();
                }
                
                system.debug('++++++CurrentList'+CurrentList);
                system.debug('++++++currentMap'+currentMap);
                system.debug('++++++AgencyNodeMap'+AgencyNodeMap);
                
                currentList.Add(thisN.Node_unique_code__c);
                currentMap.put(thisN.Parent_node_unique_code__c,currentList);
                AgencyNodeMap.put(Agencycode,currentMap);
                
                system.debug('++++++CurrentList'+CurrentList);
                system.debug('++++++currentMap'+currentMap);
                system.debug('++++++AgencyNodeMap'+AgencyNodeMap);
            }
        }
        // for(string s : AgencyNodeMap.keyset()) {
        // system.debug('++++++++AGENZIA+++++++');
        // system.debug('+++++'+s+'++++++++');
        // for (string ss :AgencyNodeMap.get(s).keyset() ) {
        // system.debug('++88888888888888++++'+ss);
        // for (string SSS : AgencyNodeMap.get(s).get(ss)) {
        // system.debug('++999999999999++++'+SSS);
        // }
        // }
        // }
        
        return AgencyNodeMap;
    }



}
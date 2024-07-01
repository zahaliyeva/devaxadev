/*------------------------------------------------------------------------
Author:        Gioele Brenz Verca, Dario Bovolenta, Davide Fabris
Company:       Deloitte
Class:         CampaignMembersExtendedViewAdvanced
Description:   Extension for the VF page of campaign members
            VF Page: CampaignMembersExtendedViewAdvanced 
            The query logic relies on the order by ID. Changing it requires
            a complete rework of the page
History

06/07/2015     Gioele Brenz Verca, Dario Bovolenta, Davide Fabris
08/10/2018     Tugal Serger - Ottimizzazione Campagna

To improve speed consider changing the formula in Portal_visibility__c
IF( TEXT($UserRole.PortalRole) <> 'Worker' , $User.Agency_code__c== Contact.Account.AAI_Agency_Reference_Code__c, IF($User.Id == Owner__c , TRUE, FALSE) )
------------------------------------------------------------------------*/

public class CampaignMembersViewCTRL {

    public Campaign CurrentCampaign;
    public Id CampaignId {get;set;}
    public String CampaignName {get;set;}
    public String CampaignType {get;set;}
    public Boolean ShowActionSection {get;set;}//MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti

    //CAPOBIANCO_A 24/07/2017 Data Enrichment Campaigns START
    public Boolean dataEnrichment {get;set;}
    //CAPOBIANCO_A 24/7/2017 Data Enrichment Campaigns END
	
    //SERGER_T 07/08/2017 Informative Campaign
    public Boolean informativeCamp {get;set;}
    public Boolean listeincentivazione{get;set;}
    public Boolean agencyCamp {get;set;}
    public Boolean marketingCamp {get;set;}
    public Boolean performaCamp {get;set;}
    
    public String taskGenericRTId;
    
    public String currentPageUrl {get;set;}
    public String pgType {get;set;}
    
    public boolean sendEmailToOwner {get;set;}
    
    public string URLBASE {get;set;}
    
    public CustomViewQuery queryToRun = new CustomViewQuery();
    public Map<Id,List<Task>> taskperCM = new Map<Id,List<Task>>();
    private String objName = 'CampaignMember';
    private String whereIdField = 'CampaignId';
    //OLD Version private String objField = 'Contact.Account.IsPersonAccount,Contact.Account.Promotional_privacy__c, LeadId,  ContactId,  Contact.Account.Expiring_policy_branch__c, Nodes__c, Status, Note__c, Policies_Expiration__c, Partner_Role_Visibility__c, Owner__c, Owner__r.Name, Number_of_contact_attempts__c';
    //QuickEvo3, added number of active campaigns and contracts on account
 
    //MOSCATELLI_M 24/07/2017: Data Enrichment -- START
    //private String objField = 'Cliente_prioritario__c, Sottostato__c, Contact.Account.Active_Insurance_Contracts__c,Contact.Account.Name, Contact.Account.Client_Index__c, Contact.Account.First_expiration_date__c, Contact.Account.Active_Campaigns__c,Contact.Account.IsPersonAccount,Contact.Account.Promotional_privacy__c, LeadId,  ContactId,  Contact.Account.Expiring_policy_branch__c, Nodes__c, Status, Note__c, Policies_Expiration__c, Partner_Role_Visibility__c, Owner__c, Owner__r.Name, Number_of_contact_attempts__c';
    private String objField = 'Codice_Nodo_Omnia__c,Contact.Account.Codice_fiscale_ListView__c,Contact.Account.AAI_Partita_Iva__c,ndg_certificato__c, target_2018__c,stop_carta_2018__c,firma_digitale_2018__c, flg_attivo__c, Cliente_prioritario__c, Sottostato__c, Contact.Account.Active_Insurance_Contracts__c,Contact.Account.Name, Contact.Account.Client_Index__c, Contact.Account.First_expiration_date__c, Contact.Account.Active_Campaigns__c,Contact.Account.IsPersonAccount,Contact.Account.Promotional_privacy__c, LeadId,  ContactId, Nodes__c, Status, Note__c, Partner_Role_Visibility__c, Owner__c, Owner__r.Name, Number_of_contact_attempts__c,Data_Enrichment_Target_Consensus__c,Data_Enrichment_Target_Email__c,Data_Enrichment_Target_Other__c,Data_Enrichment_Target_Phone__c,lastmodifieddate,Contact.Account.Id,CampaignId,Contact.Account.Recordtype.Name, Informative_Contact_Outcome__c, Stato_Opportunit_Custom__c, Contact_Priority__c';
    //MOSCATELLI_M 24/07/2017: Data Enrichment -- END
    // removed as not shown anymore: Lead.Email, Lead.Phone, Lead.MobilePhone, Contact.Account.PersonEmail, Contact.Account.Phone, Contact.Account.PersonMobilePhone,
    
    /* 
    *   item in context from the page
    */
    //public String contextItem{get;set;}

    /*
    *   set List and pageNumber
    */
    public List<CampaignMember> listRecords;//the one with the limit on reocrd per page-->this is the one used to vcreate row items
    public List<CampaignMember> cmToUpdate;//the list of the selected CM to update. 
    public List<VisibilityRowItem> cmNotVisible {get;set;}//the list of CM that requires visibility management
    public List<VisibilityRowItem> cmNotVisibleToExtend {get;set;}//the list of CM that are selected to be extended

    public List<CCWRowItem> RowRecords {get;set;}
    //public List<CampaignMember> filterList;//the one used to count CM at initialisation
    //public list<ID> filterListID;
    public Integer pageNumber{get;set;}
    public Integer totalSize {get;set;}
    
    public integer CountSelected {get;set;}
    
    public integer CountRequiringVisibility {get;set;}



    /*
    *   the records ids selected by the user
    */
    public Set<Id> selectedRecordIds {get;set;}
    public Boolean showRemoveButton {
        get {return true;}
        set;
    }    
    /*
    *   the filters selected by the user
    */
    //public String ExpireDate {get;set;}
    public String FirstNameFilter {get;set;}
    public String LastNameFilter {get;set;}
    public String RagioneSocialeFilter {get;set;}
    public String SelectedNode {get;set;}
    public String SelectedOwner {get;set;}
    public String SelectedStatus {get;set;}
    public String SelectedSubstatus {get;set;}
    public String SelectedPriority {get;set;}
    public String SelectedIndex {get;set;}
    public String SelectedContactPriority {get;set;}
    public String SelectedOpportunityStatus {get;set;}
    public String AssignStatus {get;set;}
    public String isProcessed {get;set;} //CAPOBIANCO_A 24/07/2017 Data enrichment campaigns
    // public String SelectedPrevCampaign {get;set;}
    // public String SelectedPrevStatus {get;set;}
    public String SelectedUser {get;set;}//the user id for assignment
    public user usrToAssign {get;set;}//the user object that should have the cm assigned to
    public String SelectedPolicyBranch {get;set;}    
    public String SelectedInformativeOutcome {get;set;}
    public Map<Id,Boolean> errorMap {get;set;}
    public Set<Id> cmIdSet {get;set;}
    // public Map<String,String> PrevCampaingCMStatus {get;set;}
    //public String promotionalPrivacyTerm {get;set;} //Promotional_privacy__c  REMOVED FOR FEEDBACK  19/02/16

    /*
    *   current user
    */  
    public User userRun {get;set;}
    
    /*
    *   dummy tasks for date selection
    */  
    public taskWrapper startTask {get;set;}
    public taskWrapper endTask {get;set;}
    
    /*
    *   New filtering logic to limit the number of records queued
    */    
    
    public list <Id> LastId;
    public list <Id> FirstId;
    public String Direction;
    public Integer pageRecords;
    public boolean selectedAllpicks {set; get;}
    public boolean selectedAllpicksVisibility {set; get;} //select all checkbox for visibility page
    public String SelectedNodeVisibility {get;set;}//the node used for the visibility extension
    public integer totalPages {set; get;}
    
    public integer totalCM {get;set;} //D.F. QuickEvo3: To count cfiltered CM over CM total
    public integer totalCMfiltered {get;set;} //D.F. QuickEvo3: To count cfiltered CM over CM total
 
    public Case c { get; set; }

    
    
    public CampaignMembersViewCTRL (ApexPages.StandardController stdController){
        
        c = new Case();
        String tempURL= System.URL.getCurrentRequestUrl().toExternalForm();
        URLBASE = tempURL.SPLIT('/apex/',-1).get(0);
        SYSTEM.DEBUG('+++++++++++++++++URLBASE'+URLBASE);
        
        selectedAllpicks = false;
        LastId = new List<Id>();
        FirstId = new List<Id>();
        FirstId.add(null);
        LastId.add(null);
        Direction = '';
        
        //CAPOBIANCO_A 24/7/2017 Data Enrichment Campaigns START
        dataEnrichment = false;
        isProcessed = '-- Cliente lavorato --';
        //CAPOBIANCO_A 24/7/2017 Data Enrichment Campaigns END
        
        //SERGER_T 04/10/2018 Organizzazione Campagna - START
        informativeCamp = false;
        agencyCamp = false;
        marketingCamp = false;
        performaCamp = false;
        //SERGER_T 04/10/2018 Organizzazione Campagna - END
        //MASSAROTTI ANTONINO 19/11/2019 START
        listeincentivazione = false;
        //MASSAROTTI ANTONINO 19/11/2019 END
        Decimal pageRecordsD = [SELECT Numerical_Value__c FROM CM_Page_Settings__c WHERE  Name = 'PageRecords' ].Numerical_Value__c;
        pageRecords = pageRecordsD.intValue();

        //init variable
        this.selectedRecordIds= new Set<Id>();
        // showRemoveButton = false;
        
        CampaignId = stdController.getRecord().id;
        //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- START
        ShowActionSection = true;
        //Campaign CurrentCampaign =[SELECT Id, Type, Name FROM Campaign WHERE Id =: CampaignId];
        CurrentCampaign = [SELECT Id, Type, Name, Recordtype.DeveloperName, ASA__c, Contact_Value__c, Contact_Alert__c, Action__c FROM Campaign WHERE Id =: CampaignId];
        //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- END
        CampaignType = CurrentCampaign.Type;
        CampaignName = CurrentCampaign.Name;
        currentPageUrl = Apexpages.currentPage().getUrl();
        
        createOpportunity = true;
        createAppointment = false;
        
        //CAPOBIANCO_A 24/7/2017 Data Enrichment Campaigns START
        if(CurrentCampaign.RecordType.DeveloperName == 'Data_Enrichment_Campaign')
        {
            dataEnrichment = true;
        }
        //CAPOBIANCO_A 24/7/2017 Data Enrichment Campaigns END
        
        //SERGER_T 07/08/2017 Informative Campaign START
        else if(CurrentCampaign.RecordType.Developername == 'Informative_Campaign')
        {
            //ANTONINO MASSAROTTI 19/11/2019 START
            if(CampaignId == /*'70125000000iTZhAAM'*/ CampaignCS__c.getOrgDefaults().Id1__c ||CampaignId == CampaignCS__c.getOrgDefaults().Id2__c || CampaignId == CampaignCS__c.getOrgDefaults().Id3__c){
                listeincentivazione = true;
            }
            else{
            	informativeCamp = true;
            }
            //ANTONINO MASSAROTTI 19/11/2019 END
        }
        //SERGER_T 07/08/2017 Informative Campaign END
        
        else if(CurrentCampaign.RecordType.Developername == 'Agency_campaign')
        {
            agencyCamp = true;
        }
        else if(CurrentCampaign.RecordType.Developername == 'Marketing_campaign')
        {
            marketingCamp = true;
        }
        else if(CurrentCampaign.RecordType.Developername == 'Performa_campaign')
        {
            performaCamp = true;
        }
        /* SERGER_T: OTTIMIZZAZIONE CAMPAGNA
        pgType=ApexPages.currentPage().getParameters().get('pgType');

        //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- START
        //MOSCATELLI_M 24/07/2017: Data Enrichment -- START
        //if(pgType == 'LavorazioneCampagna' && CurrentCampaign.Recordtype.DeveloperName == 'Marketing_Campaign')
        if(pgType == 'LavorazioneCampagna' && (dataEnrichment || CurrentCampaign.Recordtype.DeveloperName == 'Marketing_Campaign'))
        //MOSCATELLI_M 24/07/2017: Data Enrichment -- END
            ShowActionSection = false;
        //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- END
        */
        if (ApexPages.currentPage().getParameters().get('totalSize') == null)
            this.queryToRun.RowsPerPage = pageRecords;
        else
            this.queryToRun.RowsPerPage = Integer.valueOf(Apexpages.currentPage().getParameters().get('totalSize'));
        
        listRecords = new List<CampaignMember>();
        cmToUpdate = new List<CampaignMember>();

        //filterList = new List<CampaignMember>();
        //filterListID = new List<Id>();
        totalSize = null;
        errorMap = new Map<Id,Boolean>();
        cmIdSet = new Set<Id>();
        // promotionalPrivacyTerm =''; REMOVED FOR FEEDBACK  19/02/16
        startTask = new taskWrapper ();
        endTask = new taskWrapper ();
        // PrevCampaingCMStatus = new Map<String,String>();
        
        userRun = [SELECT Nodes__c, Profile.Name, Agency_Code__c FROM User WHERE  Id =: Userinfo.getUserId() ]; // NOPMD  Fix CRUD violation
        
        //  this.queryToRun.Query = 'SELECT Id, '+objField+' FROM '+objName+' WHERE '+whereIdField+' = : CampaignId AND Partner_Role_Visibility__c = TRUE';
        list<CampaignMembStatus__c> csList = new list<CampaignMembStatus__c>();//

        pageNumber = 1; 
        system.debug('++++++STARTthis'+this.queryToRun.Query);
        executeQuery();
        //D.F. QuickEvo3 START
        totalCM =  totalCMfiltered; //only on the constructor set the total CM to be the same as the filtered one as the only filter is that on the agency visibility
        //D.F. QuickEvo3 END

        List<RecordType> taskRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Task' and Name = 'Generico' ]; // NOPMD  Fix CRUD violation
        if (!taskRT.isEmpty())
            taskGenericRTId = taskRT[0].Id;
        
        //UNCLAIMED DEATH BENEFITS - NTORREGGIANI - START
        if(informativeCamp){
            buttons = getInformativeCampaignButtons();
            alertButton = getInformativeCampaignAlerts();
            actionValues = getInformativeCampaignActionValues();
        }
        informativeMessage = '';
        displayPopupInformative = false;
        //UNCLAIMED DEATH BENEFITS - NTORREGGIANI - END
    }
    
    /*
    *   Reset and query
    */
    public void CleanQuery(){ //reset the older query list before filtering
        system.debug('+++beginning applica filtri SelectedSubstatus'+SelectedSubstatus);
        system.debug('+++beginning applica filtri SelectedStatus'+SelectedStatus);
        system.debug('+++beginning applica filtri SelectedPriority'+SelectedPriority);

        // doDeselectAllItem();
        selectedAllpicks = false;
        errorMap = new Map<Id,Boolean>();
        getSelectedCount();
        LastId = new List<Id>();
        FirstId = new List<Id>();
        FirstId.add(null);
        LastId.add(null);
        Direction = '';
        pageNumber = 1;
        executeQuery();
        
    }   
    

    public void executeQuery(){
        system.debug('++++entering executequery');
        //String tempURL= System.URL.getCurrentRequestUrl().toExternalForm();
        //string URLBASE = tempURL.SPLIT('/apex/',-1).get(0);        
        
        totalPages = calcTotalPages();//here I already set the filterlist with the correct filters applied but without the limit on the items to display
        system.debug('++++filterlistsize'+totalCMfiltered);
        //errorMap = new Map<Id,Boolean>(); MUST NOT initialise otherwise i lose track of the errores traced
        this.queryToRun.Query = 'SELECT Id, '+objField+' FROM '+objName+' WHERE '+whereIdField+' = : CampaignId AND Partner_Role_Visibility__c = TRUE ';
        
        //Always filter on userRun Nodes
        List<Node__c> nodesList = new List<Node__c>();
        String ageCode = userRun.Agency_Code__c;
        system.debug('++++++ageCodeExQuery'+ageCode);
        //BOVOLENTA_D 10072017 BUGFIX FOR AGENCY NODES EGUAL TO OTHER AGENCIES' SUBNODES        
        String baseStringAgency = '';
        if (ageCode!= null && ageCode != ''){
            baseStringAgency = ' AND Agency_Code__c = \''+ageCode+'\'';
        }
        //BUGFIX END
        
        Set<String> userNodeSet = new Set<String> ();
        if (ageCode!= null && ageCode != '' && userRun.Nodes__c!=null && userRun.Nodes__c!=''){
            for(String uN : userRun.Nodes__c.split(';')){
                userNodeSet.add(uN.remove('DIF_'));
            }
            system.debug('***userNodeSet '+userNodeSet );
            if(userNodeSet.contains(ageCode)) {
                ageCode = ageCode+'%';
                nodesList =  [SELECT Node_unique_code__c FROM Node__c WHERE  Node_unique_code__c LIKE : ageCode and  Node_level__c >=7 and Node_level__c <=9 order by Node_unique_code__c  ASC]; // NOPMD  Fix CRUD violation
            }else{
                nodesList =  [SELECT Node_unique_code__c FROM Node__c WHERE  (Node_unique_code__c IN :userNodeSet OR Parent_node_unique_code__c IN: userNodeSet) AND Node_level__c >=7 and Node_level__c <=9 order by Node_unique_code__c  ASC]; // NOPMD  Fix CRUD violation
            }
            system.debug('***nodesList '+nodesList );
        }
        string BaseStringNodes = '';

        if(userNodeSet.contains(userRun.Agency_Code__c)) { // all nodes are like agency code
            BaseStringNodes =' AND (Nodes__c LIKE \'%'+userRun.Agency_Code__c+'%\')';
        } else {//must run thourgh the user nodes
            if (nodesList.size()>0){
                //string BaseStringNodes ='(';
                BaseStringNodes =' AND (';
                for (Node__c thisnode: nodesList) {
                    //BaseStringNodes=BaseStringNodes+'\''+thisNode.Node_unique_code__c+'\''+',';
                    BaseStringNodes=BaseStringNodes+'Nodes__c LIKE \'%'+thisNode.Node_unique_code__c+'%\' OR ';
                }
                BaseStringNodes=BaseStringNodes.removeEnd(',');
                BaseStringNodes=BaseStringNodes.removeEnd('OR ');
                BaseStringNodes=BaseStringNodes+')';
            }
        }


        system.debug('++++++basestring1'+BaseStringNodes);



        //this.queryToRun.Query =  this.queryToRun.Query + ' AND Nodes__c IN '+BaseStringNodes;
        //BOVOLENTA_D 10072017 BUGFIX FOR AGENCY NODES EGUAL TO OTHER AGENCIES' SUBNODES        
        this.queryToRun.Query =  this.queryToRun.Query+baseStringAgency+BaseStringNodes;

        system.debug('***pageNumber '+pageNumber );
        if (direction == 'Forward' && (lastid[pageNumber-1] != null)){
            this.queryToRun.Query = this.queryToRun.Query + ' AND id > \''+lastid[pageNumber-1]+'\' order by ID asc ';
        }
        else if (direction == 'Backward'){
            this.queryToRun.Query = this.queryToRun.Query + ' AND id <= \''+lastid[pageNumber]+'\' and id >= \''+firstId[pageNumber]+'\' order by ID asc ';
        }
        else if (direction == '' ||  (lastid[pageNumber-1] == null)){
            this.queryToRun.Query = this.queryToRun.Query + ' order by ID asc ';
        }
        this.queryToRun.Query = this.queryToRun.Query + 'limit '+pageRecords+' ';
        //system.debug('***Query filterlist: '+this.queryToRun.Query);
        //filterList = Database.query(this.queryToRun.Query);//BaseStringNodes set on line 209
        //filterList = getAllFiltered();
        // PrevCampaingCMStatus = new Map<String,String>();
        this.queryToRun.Query = 'SELECT Id, '+objField+' FROM '+objName+' WHERE '+whereIdField+' = : CampaignId AND Partner_Role_Visibility__c = TRUE';
        //this.queryToRun.Query =  this.queryToRun.Query + ' AND Nodes__c IN '+BaseStringNodes;
        //BOVOLENTA_D 10072017 BUGFIX FOR AGENCY NODES EGUAL TO OTHER AGENCIES' SUBNODES        
        this.queryToRun.Query =  this.queryToRun.Query+baseStringAgency+BaseStringNodes;

        /* OLD DATE FILTER - discontinued
        if(ExpireDate != '' && ExpireDate != null){
            this.queryToRun.Query = this.queryToRun.Query + ' AND ContactId != null AND Contact.Account.Policies_expiration__c LIKE \'%'+ExpireDate+'%\'';
        }*/
        
        if(SelectedNode != '' && SelectedNode != null){
            if (SelectedNode.length()>6){ //looking for sub nodes
                this.queryToRun.Query = this.queryToRun.Query + ' AND Nodes__c LIKE \'%'+SelectedNode+'%\'';
            }else{
                this.queryToRun.Query = this.queryToRun.Query + ' AND Nodes__c = \''+SelectedNode+'\'';
            }
        }  
        
        if(SelectedOwner != '' && SelectedOwner != null){
            if(SelectedOwner == 'Nessun Titolare'){
                this.queryToRun.Query = this.queryToRun.Query + ' AND Owner__c = null';
            }else{
                this.queryToRun.Query = this.queryToRun.Query + ' AND Owner__c =: SelectedOwner';
            }               
        }
        
        if(SelectedStatus != '' && SelectedStatus != null){
            this.queryToRun.Query = this.queryToRun.Query + ' AND Status =: SelectedStatus';
        }
        
         if(SelectedSubstatus != '' && SelectedSubstatus != null){
            this.queryToRun.Query = this.queryToRun.Query + ' AND Sottostato__c =: SelectedSubstatus';
        }
        
        if (!String.isempty(SelectedPriority)) {
            boolean isPriority = boolean.ValueOf(SelectedPriority);
            this.queryToRun.Query = this.queryToRun.Query + ' AND Cliente_prioritario__c =: isPriority';
        }
        
        if (SelectedIndex != '' && SelectedIndex != null){
            this.queryToRun.Query = this.queryToRun.Query + ' AND Contact.Account.Client_Index__c =: SelectedIndex';
        }
        
        if (SelectedContactPriority != '' && SelectedContactPriority != null){
            this.queryToRun.Query = this.queryToRun.Query + ' AND Contact_Priority__c =: SelectedContactPriority';
        }
        
        if (SelectedOpportunityStatus != '' && SelectedOpportunityStatus != null){
            this.queryToRun.Query = this.queryToRun.Query + ' AND Campaign_member_related_opportunity__r.StageName =: SelectedOpportunityStatus';
        }
        
        if(informativeCamp) {
            if(SelectedInformativeOutcome != '' && SelectedInformativeOutcome != null){
                this.queryToRun.Query = this.queryToRun.Query + ' AND Informative_Contact_Outcome__c =: SelectedInformativeOutcome';
            }
        }
        
        
        if(LastNameFilter != '' && LastNameFilter != null){
            this.queryToRun.Query = this.queryToRun.Query + ' AND Contact.Account.LastName LIKE \'%'+LastNameFilter+'%\'';
        }
        
        if(FirstNameFilter != '' && FirstNameFilter != null){
            this.queryToRun.Query = this.queryToRun.Query + ' AND Contact.Account.FirstName LIKE \'%'+FirstNameFilter+'%\'';
        }

        if(RagioneSocialeFilter != '' && RagioneSocialeFilter != null){
            this.queryToRun.Query = this.queryToRun.Query + ' AND Contact.Account.IsPersonAccount = false AND Contact.Account.Name LIKE \'%'+RagioneSocialeFilter+'%\'';
        } 

        /* SERGER_T: OTTIMIZZAZIONE CAMPAGNA
        //MOSCATELLI_M 24/07/2017: Data Enrichment -- START
        if(pgType == 'LavorazioneCampagna' && dataEnrichment)
        {
            this.queryToRun.Query = this.queryToRun.Query + ' AND ContactId <>\'\'';
        }   
        //MOSCATELLI_M 24/07/2017: Data Enrichment -- END
        */
        
        //CAPOBIANCO_A 24/07/2017 Data Enrichment Campaigns START
        system.debug('processed:'+isProcessed);
        if(isProcessed != '-- Cliente lavorato --')
        {
            if(isProcessed == 'Sì')
            {
                this.queryToRun.Query = this.queryToRun.Query + ' AND Status = \'Lavorato\'';
            }
            else if(isProcessed == 'No')
            {
                this.queryToRun.Query = this.queryToRun.Query + ' AND (Status = \'Da lavorare\' OR Status = \'Da assegnare\')';
            }
        }
        //CAPOBIANCO_A 24/07/2017 Data Enrichment Campaigns END
        
        /* REMOVED FOR FEEDBACK  19/02/16
        if(promotionalPrivacyTerm != '' && promotionalPrivacyTerm != null){
            Boolean privacySupport;
            if (promotionalPrivacyTerm =='TRUE')
            {
                privacySupport = true;
            }
            if (promotionalPrivacyTerm =='FALSE')
            {
                privacySupport = false;
            }            
            this.queryToRun.Query = this.queryToRun.Query + ' AND Contact.Account.Promotional_privacy__c=: privacySupport ';
        }    */    
        
        if(startTask.d.RecurrenceEndDateOnly != null){
            Date startDate = startTask.d.RecurrenceEndDateOnly;
            startDate = startDate.addDays(-1);
            this.queryToRun.Query = this.queryToRun.Query + ' AND ContactId != null AND Contact.Account.First_expiration_date__c > :startDate  ';
        }
        
        if(endTask.d.RecurrenceEndDateOnly != null){
            Date endDate = endTask.d.RecurrenceEndDateOnly;
            endDate = endDate.addDays (1);
            this.queryToRun.Query = this.queryToRun.Query + ' AND ContactId != null AND Contact.Account.First_expiration_date__c < :endDate ';
        }

        /* SERGER_T: OTTIMIZZAZIONE CAMPAGNA
        if(pgType == 'LavorazioneCampagna'){
            //MOSCATELLI_M 24/07/2017: Data Enrichment -- START
            if(dataEnrichment)
                this.queryToRun.Query = this.queryToRun.Query + ' AND Status IN (\'Da Lavorare\',\'Lavorato\')';
            else if (informativeCamp)
            	this.queryToRun.Query = this.queryToRun.Query + ' AND Status IN (\'Da Lavorare\',\'Lavorato\',\'Contatto errato\',\'Da ricontattare\',\'Non risponde\')';
            else
            //MOSCATELLI_M 24/07/2017: Data Enrichment -- END
                this.queryToRun.Query = this.queryToRun.Query + ' AND Status IN (\'Contatto errato\',\'Non interessato\',\'Interessato\',\'Da contattare\',\'Da ricontattare\')';
        } 
        */
        
        /* REMOVED FOR FEEDBACK  19/02/16

        if(SelectedPrevCampaign != '' && SelectedPrevCampaign != null){
            
            Set<Id> cmAccIdSet = new Set<Id>();
            
            String queryPrevCampaign = 'SELECT Contact.AccountId, Status FROM CampaignMember WHERE CampaignId =: SelectedPrevCampaign';
            
            //New Query string. retrieve contact id of current list
            Map<Id,Id> CMidToAccId= new map<Id,Id>();
            //populate map
            system.debug('+++++++++current filterList record size '+totalCMfiltered);
            if (listRecords.size()>0) {//check prev campaign only if I apply some filters, not on initialisation only if listRecords was initialised
                for (CampaignMember thisCM : listRecords) {//using listrecords in order to save only the id of the filtered list
                    CMidToAccId.put(thisCM.id,thisCM.ContactId);
                }
            

                //if (CMidToAccId.values().size()>0) {
                    //the new query retrieves only the previous campaign members of the current view
                    List<Id> currentCMids = CMidToAccId.values();
                    system.debug('++++++currentCMids '+currentCMids );
                    queryPrevCampaign = 'SELECT Contact.AccountId, Status FROM CampaignMember WHERE CampaignId =: SelectedPrevCampaign AND ContactId IN:currentCMids ';
                //}
                
                
                if(SelectedPrevStatus != '' && SelectedPrevStatus != null){
                    queryPrevCampaign = queryPrevCampaign + ' AND Status =: SelectedPrevStatus'; 
                }
                
                system.debug('+++++++++++query Prev Campaign'+queryPrevCampaign );
                List<CampaignMember> cmAccIdList = Database.query(queryPrevCampaign);
                
    
                for (CampaignMember cmai : cmAccIdList){
                    cmAccIdSet.add(cmai.Contact.AccountId);
                    PrevCampaingCMStatus.put(cmai.Contact.AccountId, cmai.Status);
                }
                
                if(SelectedPrevStatus != '' && SelectedPrevStatus != null){
                    this.queryToRun.Query = this.queryToRun.Query + ' AND Contact.AccountId IN: cmAccIdSet';
                }
            }
            
        }*/
        if (direction == 'Forward' && (lastid[pageNumber-1] != null))
        {

            this.queryToRun.Query = this.queryToRun.Query + ' AND id > \''+lastid[pageNumber-1]+'\' order by ID asc ';
        }
        else if (direction == 'Backward')
        {
            this.queryToRun.Query = this.queryToRun.Query + ' AND id <= \''+lastid[pageNumber]+'\' and id >= \''+firstId[pageNumber]+'\' order by ID asc ';
        }
        else if (direction == '' ||  (lastid[pageNumber-1] == null))
        {
            this.queryToRun.Query = this.queryToRun.Query + ' order by ID asc ';
        }
        this.queryToRun.Query = this.queryToRun.Query + ' limit '+pageRecords+' ';
        system.debug('***Query listrecords: '+this.queryToRun.Query);
        listRecords = Database.query(this.queryToRun.Query);//BaseStringNodes set on line 233;
        system.debug('***getQueryRows() '+limits.getQueryRows());
        system.debug('***listRecords '+listRecords);
        if (listRecords.size() > 0){
            if (FirstId.size()-1 < pageNumber){
                FirstId.add(listRecords.get(0).id);
                //  FirstId.add(pageNumber,listRecords.get(0).id);
                LastId.add(listRecords.get(listRecords.size()-1).id);
                //   LastId.add(pageNumber,listRecords.get(listSize-1).id);
            }else
            {
                FirstId.Set(pageNumber,listRecords.get(0).id);
                LastId.Set(pageNumber,listRecords.get(listRecords.size()-1).id);
            }
            totalSize = listRecords.size();
            
            // if(errorMap.isEmpty()){
            // for(CampaignMember cm : listRecords){
            // errorMap.put(cm.Id,false);
            
            // }
            // }
            
            for(CampaignMember cm : listRecords){
                if (!errorMap.containsKey(cm.Id)) {
                    errorMap.put(cm.Id,false);
                }
            }
            

            for(CampaignMember cm : listRecords){
                cmIdSet.add(cm.Id);
            }
            system.debug('Sono qua');
            List<Task> tskList = [SELECT Id, CreatedDate, TECH_SourceId__c  FROM Task WHERE RecordType.DeveloperName = 'Generico' AND TECH_SourceId__c IN: cmIdSet AND Subject like 'Contatt%' ORDER BY CreatedDate DESC]; //a.d. 14.12.2016
       //   List<Task> tskList = [SELECT Id, CreatedDate, TECH_SourceId__c  FROM Task WHERE Subject like 'Contatto%' AND TECH_SourceId__c IN: cmIdSet ORDER BY CreatedDate DESC];
            system.debug('***tskList : '+tskList);
            for(Task tsk : tskList){
                if(!taskperCM.containsKey(tsk.TECH_SourceId__c)){
                    taskperCM.put(tsk.TECH_SourceId__c,new List<Task>{tsk});
                }else{
                    if(taskperCM.get(tsk.TECH_SourceId__c).get(0).CreatedDate < tsk.CreatedDate){
                        taskperCM.get(tsk.TECH_SourceId__c).add(0,tsk);
                    }else{
                        taskperCM.get(tsk.TECH_SourceId__c).add(tsk);
                    }
                    
                }
            }
            system.debug('***taskperCM : '+taskperCM);
        }else{
            // if((SelectedPrevStatus != '' && SelectedPrevStatus != null) || (SelectedOwner != '' && SelectedOwner != null) || (SelectedNode != '' && SelectedNode != null) || (SelectedStatus != '' && SelectedStatus != null) || (SelectedPolicyBranch != '' && SelectedPolicyBranch != null)){
            if((SelectedOwner != '' && SelectedOwner != null) ||
               (SelectedNode != '' && SelectedNode != null) ||
               (SelectedStatus != '' && SelectedStatus != null) ||
               (SelectedPolicyBranch != '' && SelectedPolicyBranch != null) ||
               (SelectedInformativeOutcome != '' && SelectedInformativeOutcome != null) ||
               (SelectedSubstatus != '' && SelectedSubstatus != null) ||
               (SelectedContactPriority != '' && SelectedContactPriority != null) ||
               (SelectedOpportunityStatus != '' && SelectedOpportunityStatus != null) ||
               (!String.isempty(SelectedPriority))) {
                   ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'Modificare la selezione o cliccare reset filtri per visualizzare la lista di tutti i nominativi'));
               }
            else {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Nessun cliente in campagna può essere lavorato'));
                
                /* SERGER_T: OTTIMIZZAZIONE CAMPAGNA
                //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- START
                if(pgType == 'LavorazioneCampagna')
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Nessun cliente in campagna può essere lavorato'));                    
                else
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Nessun cliente associato a questa campagna'));
                //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- END
                */
            }
        }
        //Create the RowItems corresponding to the selected campaign members
        RowRecords = getRecords();


    }

    /*
    *   handle item selected
    */
    public void doSelectAllItem(){
        // set<Id> IdsToAdd = new set<Id>();
        // for (CCWRowItem r : RowRecords) {
        // r.isSelected = true;
        // IdsToAdd.add(r.tRecord.id);
        // }
        
        // this.selectedRecordIds.addAll(IdsToAdd);

        
        //showRemoveButton = true;
        //for(CampaignMember r : listRecords){
        //    this.selectedRecordIds.add(r.id);
        
        // }
    }

    /*
    *   handle item deselected
    */
    /*public void doDeselectAllItem(){
        for(CampaignMember r : listRecords){
            this.selectedRecordIds.remove(r.id);
        }
    }*/
    
    /*
    *   handle item selected
    /*
    /*public void doSelectItem(){
        showRemoveButton = true;
        this.selectedRecordIds.add(this.contextItem);
    }*/
     
    public void getSelectedItems() {
        selectedRecordIds.clear();//resetting the count every time
        for (CCWRowItem thisitem : RowRecords) {
            system.debug('++++thisitem'+thisitem);
            if (thisitem.IsSelected) {
                
                this.selectedRecordIds.add(thisitem.tRecord.Id);
            }
        }
    }

    /*
    *   handle item deselected
    */
    /*public void doDeselectItem(){
        
        this.selectedRecordIds.remove(this.contextItem);
        
        if(this.selectedRecordIds.size() == 0)
            showRemoveButton = false;
        
    }*/

    /*
    *   return count of selected items
    */
    public Integer getSelectedCount(){
        system.debug('***this.selectedRecordIds.size() '+this.selectedRecordIds.size() );
        
        return this.selectedRecordIds.size();
        
    }
    /*
    *   reload current and update first/last
    */
    /*public void refresh(){ 
        pageNumber--;
        FirstId.Set(pageNumber,listRecords.get(0).id);
        LastId.Set(pageNumber,listRecords.get(listRecords.size()-1).id);    
        direction = 'Backward';
        executeQuery();
        pageNumber++;
    }*/
    public void refreshAfterPopup(){
        errorMap = new Map<Id,Boolean>();
        refresh();
    }
    public void refresh(){ 
        //pageNumber--;
        // doDeselectAllItem();
        selectedAllpicks = false;
        system.debug('***listRecordsRefresh'+listRecords);
        FirstId.Set(pageNumber,listRecords.get(0).id);
        LastId.Set(pageNumber,listRecords.get(listRecords.size()-1).id);
        if (pageNumber == 1)
        direction = 'Forward';
        executeQuery();
        //pageNumber++;
        system.debug('***errorMap '+errorMap );
        
        
        //getOwnerList();
        
    }   
    
    /*
    *   advance to next page
    */
    public void doNext(){
        system.debug('***Step doNext' );
        // doDeselectAllItem();
        errorMap = new Map<Id,Boolean>();
        Integer listSize = listRecords.size();
        system.debug('***pageNumber '+pageNumber );
        system.debug('***listRecords.get(0).id '+listRecords.get(0).id);
        /*  if (FirstId.size()-1 < pageNumber){
            FirstId.add(listRecords.get(0).id);
        //  FirstId.add(pageNumber,listRecords.get(0).id);
            LastId.add(listRecords.get(listSize-1).id);
        //   LastId.add(pageNumber,listRecords.get(listSize-1).id);
        }else
        {
            FirstId.Set(pageNumber,listRecords.get(0).id);
            LastId.Set(pageNumber,listRecords.get(listSize-1).id);
        }*/
        direction = 'Forward';
        system.debug('***direction '+direction );
        system.debug('***pageNumber '+pageNumber );
        system.debug('***lastId[pageNumber] '+lastId+ '   '+listRecords.get(listSize-1).id );
        system.debug('***FirstId[pageNumber] '+FirstId +'  '+listRecords.get(0).id  );
        system.debug('***listRecords.get(listSize-1).id '+listRecords.get(listSize-1).id );     
        pageNumber ++;
        executeQuery();
        
        //direction = '';

        
    }

    /*
    *   advance to previous page
    */
    public void doPrevious(){
        // doDeselectAllItem();
        errorMap = new Map<Id,Boolean>();
        if (listRecords.size()>0)
        {
            system.debug('***ContactId '+listRecords.get(0).ContactId );   
            //  lastId = listRecords.get(0).id;
        }
        pageNumber --;  
        direction = 'Backward'; 
        system.debug('***direction '+direction );
        system.debug('***lastId '+lastId );
        
        executeQuery();
        //direction = ''; 
        //system.debug('***lastId pre inversione '+listRecords.get(0).id );
        //listRecords.sort();
        //system.debug('***lastId post inversione '+listRecords.get(0).id );
        
    }
    
    
    /*
    *   return whether previous page exists
    */

    public Boolean getHasPrevious(){
        
        if (pageNumber > 1)
        return true;
        else
        return false;

    }

    /*
    *   return whether next page exists
    */

    public Boolean getHasNext(){
        system.debug('***TotalPages: '+TotalPages);
        if (pageNumber < TotalPages)
        {
            system.debug('***Step getHasNext' );
            return true;
        }
        else
        return false;
        
    }

    /*
    *   return page number
    */
    public Integer getPageNumber(){
        
        return pageNumber;
        //return this.setCon.getPageNumber();
        
    }

    /*
    *    return total pages
    */
    /*  public Integer getTotalPages(){

        Decimal pageSize = this.queryToRun.RowsPerPage;
        if(totalSize != null){
            Decimal pages = totalSize/pageSize;
            return (Integer)pages.round(System.RoundingMode.CEILING);
        }else{
            return 1;
        }
    }*/

    /*
    *   Return current page of groups
    */
    public List<CCWRowItem> getRecords(){
        
        List<CCWRowItem> rows = new List<CCWRowItem>();
        Decimal rnum = 1;

        for(CampaignMember r : listRecords){
            CampaignMember c = r;
            
            CCWRowItem row;
            if(taskperCM.containsKey(c.Id)){
                /* removed for feedback 19/02/16
                if(PrevCampaingCMStatus.containsKey(c.Contact.AccountId)){
                    row = new CCWRowItem(c,(Integer)(rnum/this.queryToRun.RowsPerPage).round(System.RoundingMode.UP),false, taskperCM.get(c.Id).get(0), PrevCampaingCMStatus.get(c.Contact.AccountId));
                }else{*/
                row = new CCWRowItem(c,(Integer)(rnum/this.queryToRun.RowsPerPage).round(System.RoundingMode.UP),false, taskperCM.get(c.Id).get(0), 'Non in Campagna', informativeCamp);
                //}
            }else{
                Task t = new Task();
                /* removed for feedback 19/02/16

                if(PrevCampaingCMStatus.containsKey(c.Contact.AccountId)){
                    row = new CCWRowItem(c,(Integer)(rnum/this.queryToRun.RowsPerPage).round(System.RoundingMode.UP),false, t, PrevCampaingCMStatus.get(c.Contact.AccountId));
                }else{*/
                row = new CCWRowItem(c,(Integer)(rnum/this.queryToRun.RowsPerPage).round(System.RoundingMode.UP),false, t, 'Non in Campagna', informativeCamp);
                //}
            }
            
            
            //           if(this.selectedRecordIds.contains(c.Id)){
            //               row.IsSelected=true;
            //           }
            //           else{
            //                row.IsSelected=false;
            //           }
            
            // if (row.PageNum == pageNumber){
            rows.add(row);
            // }
            
            rnum++;
        }
        
        System.debug(' ===> rows: ' + rows);

        return rows;
        
    }
    
    /*
    *   Return expire date of Polizza
    */
    /* public List<SelectOption> getExpireDateList(){
        
        if(filterList.size() > 0){

            List<SelectOption> options = new List<SelectOption>();
            Set<String> policiesExpirationSet = new Set<String>();

            for (CampaignMember cm : filterList){
                if (cm.Policies_expiration__c!= null && cm.Policies_expiration__c != ''){
                    policiesExpirationSet.addAll(cm.Policies_expiration__c.split('\\|'));
                }
            }
            
            for (String cms : policiesExpirationSet){
                if(options.size() == 0){
                    options.add(new SelectOption('','-- Seleziona Data --'));
                }else{
                    options.add(new SelectOption(String.valueOf(cms),String.valueOf(cms)));
                }
            }
            
            if(options.size() == 0){
                options.add(new SelectOption('','-- Nessuna Data Selezionabile --'));
            }
            
            return options;
        }else{
            if((ExpireDate != '' && ExpireDate != null) || (SelectedNode != '' && SelectedNode != null) ){
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Nessun cliente campagna presente per i vincoli selezionati'));
            }
            else{
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Nessun cliente campagna associato a questa campagna'));
            }
            return null;
        }
    }*/
    
    /*
    *   Return nodes of CampaignMember
    */
    /*   public List<SelectOption> getNodeList(){
        
        if(filterList.size() > 0){

            List<SelectOption> options = new List<SelectOption>();

            for (CampaignMember cm : filterList){
                if (cm.Nodes__c!= null && cm.Nodes__c != ''){
                    if(options.size() == 0){
                        options.add(new SelectOption('','-- Nodo --'));
                    }
                    options.add(new SelectOption(cm.Nodes__c,cm.Nodes__c));
                }
            }
            
            if(options.size() == 0){
                options.add(new SelectOption('','-- Nessun Nodo Selezionabile --'));
            }
            
            return options;
        }else{
            if((ExpireDate != '' && ExpireDate != null) || (SelectedNode != '' && SelectedNode != null) ){
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Nessun cliente campagna presente per i vincoli selezionati'));
            }
            else{
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Nessun cliente campagna associato a questa campagna'));
            }
            return null;
        }
    }*/
    
    public void resetFilter(){
        // SelectedPrevStatus = null;                 /* removed for feedback 19/02/16
        SelectedOwner = '';
        SelectedNode = null;
        SelectedStatus = null;
        SelectedSubstatus = null;
        SelectedPriority= null;
        SelectedPolicyBranch = null;
        SelectedInformativeOutcome = null;
        SelectedOpportunityStatus = null;
        SelectedContactPriority = null;
        LastNameFilter = null;
        FirstNameFilter = null;
		RagioneSocialeFilter = null;
        isProcessed = '-- Cliente lavorato --'; //CAPOBIANCO_A 24/07/2017
        // SelectedPrevCampaign = null;                 /* removed for feedback 19/02/16
        // SelectedPrevStatus = null;                 /* removed for feedback 19/02/16
        startTask.d.RecurrenceEndDateOnly = null;
        endTask.d.RecurrenceEndDateOnly = null;
        // promotionalPrivacyTerm =null; REMOVED FOR FEEDBACK  19/02/16
        CleanQuery();
        
    }
    
    /* REMOVED FOR FEEDBACK  19/02/16
    public List<SelectOption> getPromoPrivacy(){

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Seleziona Impostazione Privacy Promozionale--'));
        options.add(new SelectOption('TRUE','Con consenso alle promozioni'));
        options.add(new SelectOption('FALSE','Senza consenso alle promozioni'));
        
        return options;   

    }*/
    
    public List<SelectOption> getNodesList(){
        
        List<SelectOption> options = new List<SelectOption>();
        if(totalCM > 0){

            
            List<Node__c> nodesList = new List<Node__c>();
            
            String ageCode = userRun.Agency_Code__c;
            system.debug('++++++ageCode'+ageCode);
            Set<String> userNodeSet = new Set<String> ();
            
            if (ageCode!= null && ageCode != '' && userRun.Nodes__c!=null && userRun.Nodes__c!='')
            {

                
                for(String uN : userRun.Nodes__c.split(';')){
                    userNodeSet.add(uN.remove('DIF_'));
                }
                
                system.debug('***userNodeSet '+userNodeSet );
                
                if(userNodeSet.contains(userRun.Agency_Code__c)) {
                    ageCode = ageCode+'%';
                    nodesList =  [SELECT Node_unique_code__c, Node_description__c FROM Node__c WHERE  Node_unique_code__c LIKE : ageCode and  Node_level__c >=7 and Node_level__c <=9 order by Node_unique_code__c  ASC]; // NOPMD  Fix CRUD violation
                }else{
                    nodesList =  [SELECT Node_unique_code__c, Node_description__c FROM Node__c WHERE  (Node_unique_code__c IN :userNodeSet OR Parent_node_unique_code__c IN: userNodeSet) AND Node_level__c >=7 and Node_level__c <=9 order by Node_unique_code__c  ASC]; // NOPMD  Fix CRUD violation
                }
                
                system.debug('***nodesList '+nodesList );
                
                for (Node__c nodE : nodesList)
                {
                    if(options.size() == 0){
                        options.add(new SelectOption('','-- Nodo --'));
                    }
                    options.add(new SelectOption(nodE.Node_unique_code__c,nodE.Node_unique_code__c+' - '+nodE.Node_description__c));
                }
                
                if(options.size() == 0){
                    options.add(new SelectOption('','-- Nessun Nodo Selezionabile --'));
                }
                
                
            }
            else
            {
                options.add(new SelectOption('','-- Nessun Nodo Selezionabile --'));
            }
            return options;
        }else{
            // if((SelectedPrevStatus != '' && SelectedPrevStatus != null) || (SelectedOwner != '' && SelectedOwner != null) || (SelectedNode != '' && SelectedNode != null) || (SelectedStatus != '' && SelectedStatus != null) || (SelectedPolicyBranch != '' && SelectedPolicyBranch != null)){
            if( (SelectedOwner != '' && SelectedOwner != null) ||
               (SelectedNode != '' && SelectedNode != null) ||
               (SelectedStatus != '' && SelectedStatus != null) ||
               (SelectedPolicyBranch != '' && SelectedPolicyBranch != null) ||
               (SelectedInformativeOutcome != '' && SelectedInformativeOutcome != null) ||
               (SelectedContactPriority != '' && SelectedContactPriority != null) ||
               (SelectedOpportunityStatus != '' && SelectedOpportunityStatus != null) ||
               (SelectedSubstatus != '' && SelectedSubstatus != null) ||
               (!String.isEmpty(SelectedPriority))){

                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Nessun cliente campagna presente per i vincoli selezionati'));
            }
            else{
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Nessun cliente campagna associato a questa campagna'));
            }
            return null;
        }
    }

    public List<SelectOption> getNodesForVisibility() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Nodo --'));
        if (String.isempty(usrToAssign.Nodes__c)) {
            return options;
        } else {
            if (String.isempty(usrToAssign.Agency_Code__c)) {
                options.add(new SelectOption('','-- Utente non profilato per una Agenzia --'));
            } else {
                set<String> ProfiledNodes = new set<String>();
                for(String uN : usrToAssign.Nodes__c.split(';')){
                    ProfiledNodes.add(uN.remove('DIF_'));
                }
                if (ProfiledNodes.contains(usrToAssign.Agency_Code__c)) {
                    options.add(new SelectOption('','-- Utente con completa visibilità di agenzia, estensione visibilità non necessaria --'));
                } else {
                    List<Node__c> visibleNodes = new List<Node__c>();
                    visibleNodes =  [SELECT Node_unique_code__c, Node_description__c FROM Node__c WHERE  (Node_unique_code__c IN :ProfiledNodes OR Parent_node_unique_code__c IN: ProfiledNodes) AND Node_level__c >=7 and Node_level__c <=9 order by Node_unique_code__c  ASC]; // NOPMD  Fix CRUD violation
                    for (Node__c thisN : visibleNodes) {
                        options.add(new SelectOption(thisN.Node_unique_code__c,thisN.Node_unique_code__c+' - '+thisN.Node_description__c));
                    }
                }
            }
        }
        return options;
        

    }    
    
    public List<SelectOption> getOwnerList(){
        list <CampaignMember> totalList = getAll ();
        
        if(totalList.size() > 0){

            List<SelectOption> options = new List<SelectOption>();
            Map<String, String> cmOwnerMap = new Map<String, String>();
            
            options.add(new SelectOption('','-- Titolare --'));
            options.add(new SelectOption('Nessun Titolare','Nessun Titolare'));
            
            for (CampaignMember cm : totalList) {
                if(cm.Owner__c != null){
                    if((!cmOwnerMap.containsKey(cm.Owner__c))&&(cm.Owner__r.Name!=null))
                    cmOwnerMap.put(cm.Owner__c,cm.Owner__r.Name);
                }
            }
            
            for(String cmOwn : cmOwnerMap.keySet()){
                options.add(new SelectOption(cmOwn,cmOwnerMap.get(cmOwn)));
            }
            
            system.debug('***options '+options );
            return options;
        }else{
            // if((SelectedPrevStatus != '' && SelectedPrevStatus != null) || (SelectedOwner != '' && SelectedOwner != null) || (SelectedNode != '' && SelectedNode != null) || (SelectedStatus != '' && SelectedStatus != null) || (SelectedPolicyBranch != '' && SelectedPolicyBranch != null)){
            if((SelectedOwner != '' && SelectedOwner != null) ||
               (SelectedNode != '' && SelectedNode != null) ||
               (SelectedStatus != '' && SelectedStatus != null) ||
               (SelectedPolicyBranch != '' && SelectedPolicyBranch != null) ||
               (SelectedInformativeOutcome != '' && SelectedInformativeOutcome != null) ||
               (SelectedContactPriority != '' && SelectedContactPriority != null) ||
               (SelectedOpportunityStatus != '' && SelectedOpportunityStatus != null) ||
               (SelectedSubstatus != '' && SelectedSubstatus != null) ||
               (!String.isEmpty(SelectedPriority))){  
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Nessun cliente campagna presente per i vincoli selezionati'));
            }
            else{
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Nessun cliente campagna associato a questa campagna'));
            }
            return null;
        }
    }    
    
    /*
    *   Return Status of CampaignMember
    */
    
    public List<SelectOption> getStatusCampaignLists (){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Stato Cliente in Campagna --'));
        
        options.addAll(getStatusLists());
        
        return options;
    }
    
    public List<SelectOption> getStatusCampaignListsForAssignment (){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Stato Cliente in Campagna --'));
        
        options.addAll(getStatusListsForAssignment());
        
        return options;
    }
    
    public List<SelectOption> getSubstatusCampaignLists (){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Tracking Cliente in Campagna --'));
        
        options.addAll(getSubstatusLists());
        
        return options;
    }

    //CAPOBIANCO_A 24/07/2017 Data Enrichment Campaigns START
    public List<SelectOption> getIsProcessedList (){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Cliente lavorato --'));
        options.add(new SelectOption('Sì','Sì'));
        options.add(new SelectOption('No','No'));
        
        return options;
    }
    //CAPOBIANCO_A 24/07/2017 Data Enrichment Campaigns END
    
    public List<SelectOption> getClientiPrioritari (){ 
        
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('','-- Clienti prioritari --'));
        options.add(new SelectOption('true','Clienti prioritari'));
        options.add(new SelectOption('false','Clienti non prioritari'));

        return options;
    }
    
    public List<SelectOption> getIndiceCliente (){ 
        
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('', '-- Indice Cliente --'));
        
        List<AccountClientIndex__c> indexList = [SELECT Id, Name, Client_Index_Name__c, Client_Index_Number__c FROM AccountClientIndex__c ORDER BY SortOrder__c]; // NOPMD  Fix CRUD violation
        
        for (AccountClientIndex__c index : indexList) {
        	options.add(new SelectOption(index.Name,index.Client_Index_Name__c));
        }
        
        return options;
    }
    
    public List<SelectOption> getPriorityList(){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Schema.CampaignMember.Contact_Priority__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '-- Propensione Acquisto --'));
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }

    public List<SelectOption> getOpportunityStatus(){
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('', '-- Stato Trattativa --'));
        options.add(new SelectOption('Open', 'Trattativa aperta'));
        options.add(new SelectOption('Proposal Made', 'Preventivo emesso'));
        options.add(new SelectOption('Closed Won', 'Vinta'));
        options.add(new SelectOption('Closed Lost', 'Persa'));
                                     
        return options;
    }
    
    /*         /* REMOVED FOR FEEDBACK  19/02/16

public List<SelectOption> getStatusPrevCampaignLists (){
List<SelectOption> options = new List<SelectOption>();
options.add(new SelectOption('','-- Seleziona Stato Cliente Campagna Precedente --'));

List<CampaignMembStatus__c> cmsList = CampaignMembStatus__c.getAll().values();

for (CampaignMembStatus__c cms : cmsList) {
options.add(new SelectOption(cms.Status_Name__c,cms.Status_Name__c));
}

return options;
} */
    
    public List<SelectOption> getStatusListsForAssignment (){ 
        
        List<SelectOption> options = new List<SelectOption>();
        //List<CampaignMembStatus__c> cmsList = CampaignMembStatus__c.getAll().values();
        
        
        Campaign currentCampaign = [Select id, recordtype.DeveloperName FROM Campaign where ID=: CampaignId Limit 1]; // NOPMD  Fix CRUD violation
        List<CampaignMemberStatus> cmsList = new List <CampaignMemberStatus>();
        cmsList=[SELECT Id, Label, SortOrder FROM CampaignMemberStatus WHERE CampaignId=:currentCampaign.id ORDER BY SortOrder]; // NOPMD  Fix CRUD violation
        
        for (CampaignMemberStatus cms : cmsList) { 
        system.debug('+++++ cms.Label='+cms.Label);
            /* SERGER_T: OTTIMIZZAZIONE CAMPAGNA
            if(pgType == 'LavorazioneCampagna'){
                //logic to exclude Statu not expected in lavorazione
                if (cms.Label != 'In Campagna' && cms.Label != 'Escluso'&& cms.Label != 'Da assegnare')  {
                    system.debug('+++++ add1: '+cms.Label);
                    options.add(new SelectOption(cms.Label,cms.Label));
                }
            } else {
            //here I assume to be in GestioneCampagna
            */
            if (cms.Label != 'Richiesta informazioni' && cms.Label != 'In preparazione') {
                //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- START
                if(!(currentCampaign.recordtype.DeveloperName == 'Marketing_Campaign' && cms.Label == 'Escluso'))
                    //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- END
                    options.add(new SelectOption(cms.Label,cms.Label));
            }
            
        
        
        }
    
      

        return options;
    }
    
    public List<SelectOption> getStatusLists (){ 
        
         List<SelectOption> options = new List<SelectOption>();
        //List<CampaignMembStatus__c> cmsList = CampaignMembStatus__c.getAll().values();
        
        
        Campaign currentCampaign = [Select id, recordtype.DeveloperName FROM Campaign where ID=: CampaignId Limit 1]; // NOPMD  Fix CRUD violation
        List<CampaignMemberStatus> cmsList = new List <CampaignMemberStatus>();
        cmsList=[SELECT Id, Label, SortOrder FROM CampaignMemberStatus WHERE CampaignId=:currentCampaign.id ORDER BY SortOrder]; // NOPMD  Fix CRUD violation
        
        for (CampaignMemberStatus cms : cmsList) {
            system.debug('+++++ cms.Label='+cms.Label);
            /* SERGER_T: OTTIMIZZAZIONE CAMPAGNA
            if(pgType == 'LavorazioneCampagna'){
                //logic to exclude Statu not expected in lavorazione
                if (cms.Label != 'In Campagna' && cms.Label != 'Escluso'&& cms.Label != 'Da assegnare')  {
                    system.debug('+++++ add1: '+cms.Label);
                    options.add(new SelectOption(cms.Label,cms.Label));
                }
            } else {
            //here I assume to be in GestioneCampagna
            */
            
            if (cms.Label != 'Richiesta informazioni' && cms.Label != 'In preparazione')
                //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- START
                if(!(currentCampaign.recordtype.DeveloperName == 'Marketing_Campaign' && cms.Label == 'Escluso'))
                //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- END
                options.add(new SelectOption(cms.Label,cms.Label));
            //}
        
        
        }
        
   

        return options;
    }
    
    /*        /* REMOVED FOR FEEDBACK  19/02/16

    *   Return Previous Closed Campagin for CampaignMember
    
    public List<SelectOption> getPrevCampaignLists (){ 
    
        List<SelectOption> options = new List<SelectOption>();
        Set<Id> cmAccIdSet = new Set<Id>();
        Map<String, String> cmCampaignMap = new Map<String, String>();
        options.add(new SelectOption('','-- Seleziona Campagna Precedente --'));
        if (listRecords.size()>0) {
        for(CampaignMember r : listRecords){
            cmAccIdSet.add(r.Contact.AccountId);
        }

        List<CampaignMember> cmCampaignList = [SELECT Campaign.Id, Campaign.Name FROM CampaignMember WHERE Campaign.Status = 'Completed' AND Campaign.Type =: CampaignType AND Contact.AccountId IN: cmAccIdSet];
        
        for (CampaignMember cms : cmCampaignList) { 
            if(!cmCampaignMap.containsKey(cms.Campaign.Id))
                cmCampaignMap.put(cms.Campaign.Id, cms.Campaign.Name);
        } 
        
        for(String Id : cmCampaignMap.keySet()){
            options.add(new SelectOption(Id,cmCampaignMap.get(Id)));
        }
        }

    return options;
    }*/
    
    public List<SelectOption> getPolicyBranchList (){ 
        
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('','-- Ramo Polizza in Scadenza --'));
        options.add(new SelectOption('AUTO','AUTO'));
        options.add(new SelectOption('RE','RE'));

        return options;
    }

    public List<SelectOption> getInformativeOutcomeList (){ 
        
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('','-- Esito contatto informativo --'));
        
        Campaign myCampaign =  [SELECT Contact_Value__c FROM Campaign WHERE Name=:CampaignName LIMIT 1].get(0);
        List<String> ret = (''+myCampaign.Contact_Value__c).split(';');

        for(String outcome : ret){
            options.add(new SelectOption(outcome, outcome));
        }

        return options;
    }
    
    public List<SelectOption> getSubstatusLists (){
     
      List<SelectOption> options = new List<SelectOption>();
        //List<CampaignMembStatus__c> cmsList = CampaignMembStatus__c.getAll().values();
        
        
        Campaign currentCampaign = [Select id, recordtype.DeveloperName FROM Campaign where ID=: CampaignId Limit 1]; // NOPMD  Fix CRUD violation

        //MOSCATELLI_M 30/08/2017: Data Enrichment -- START
        Set<String> AvailSubStatSet = new Set<String>();

        for(CampaignMemb_Sub_Status__c CMSs: CampaignMemb_Sub_Status__c.getall().values())
        {
            if(CMSs.Campaign_Record_Type__c.contains(currentCampaign.recordtype.DeveloperName))
                AvailSubStatSet.add(CMSs.Name);
        }
        //MOSCATELLI_M 30/08/2017: Data Enrichment -- END
        
        
        Schema.DescribeFieldResult fieldResult = CampaignMember.Sottostato__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            //MOSCATELLI_M 30/08/2017: Data Enrichment -- START
            if(AvailSubStatSet.contains(f.getValue()))
            //MOSCATELLI_M 30/08/2017: Data Enrichment -- END
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }   
     
     
     
     return options;
     }
     

     
    /*
    *   Remove CampaignMember
    */
    public void removeCampaignMember(){
        AssignStatus = 'Escluso';
        changeCampaignMemberStatus();
        displayPopupEsclusione=false;
    }
    
    /*
    *   Update Status of CampaignMember
    */
    public void changeCampaignMemberStatus(){
        cmToUpdate = new List<CampaignMember>();
        getSelectedItems();//populating the list of selected ids
        system.debug('+++++++errorMap'+errorMap);
        system.debug('+++++++selectedRecordIds'+selectedRecordIds);
        /* for (Id cmId : errorMap.keySet()){
            errorMap.put(cmId,false);
        }*/
        // errorMap = new Map<Id,Boolean>();
        
        if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
            if(AssignStatus != '' && AssignStatus != null){
                cmToUpdate = [SELECT Id, Status FROM CampaignMember WHERE Id IN: selectedRecordIds];
                
                for(CampaignMember cm : cmToUpdate){
                    cm.Status = AssignStatus;
                }

                update cmToUpdate;
                refresh();
                //executeQuery();
                //ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Confirm, 'Aggiornamento effettuato con successo'));
            }else{
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Nessuno Stato selezionato per l\'aggiornamento'));
            }
        }else{
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Nessun cliente campagna selezionato per l\'aggiornamento'));
        }
        displayPopupStato = false;
    }
    
    /*
    *   Return User for CampaignMember assignment
    */
    /*  public List<SelectOption> getAssigmentUser (){ 
    
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Seleziona Utente --'));
        
        User usrRun = [SELECT Agency_Code__c FROM User WHERE  Id =: Userinfo.getUserId()];

        List<User> usrList = [SELECT Id, Name FROM User WHERE  Agency_Code__c =: usrRun.Agency_Code__c ORDER BY Name ASC];
        
        for (User usr : usrList) { 
            options.add(new SelectOption(usr.Id,usr.Name));
        }

    return options;
    }*/
    
    public List<SelectOption> getAssignmentUser (){ 
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- Utente --'));
        

        //List<User> usrList = [SELECT Id, Name FROM User WHERE  Agency_Code__c =: userRun.Agency_Code__c ORDER BY Name ASC];
        List<User> usrList = [SELECT Id, Name FROM User WHERE  Agency_Code__c =: userRun.Agency_Code__c AND isActive=TRUE ORDER BY Name ASC]; // NOPMD  Fix CRUD violation , Added "isActive" check 
        system.debug('+++++++usrList '+usrList);
        for (User usr : usrList) { 
            options.add(new SelectOption(usr.Id,usr.Name));
        }

        return options;
    }
    
    /*
    *   START Assign User to CampaignMember OLD VERSION NOT USED
    */
    /*    
    public void changeCampaignMemberOwner_OLD(){
        List<CampaignMember> cmToUpdate = new List<CampaignMember>();
        Boolean error = false;
        
        for (Id cmId : errorMap.keySet()){
            errorMap.put(cmId,false);
        }
        User usrToAssign = new User();
        String CName = '';
        String CType = '';
        String CId = null; 
        String Cstart= '';
        String Cend = '';
        if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
            if(SelectedUser != '' && SelectedUser != null){
                cmToUpdate = [SELECT Id, Owner__c, CampaignId, Nodes__c, Campaign.StartDate, Campaign.EndDate, Campaign.Name, Campaign.Type FROM CampaignMember WHERE Id IN: selectedRecordIds];
                system.debug('+++++++cmToUpdate'+cmToUpdate);
                system.debug('++++++cmtoupdate.Campaign'+ cmToUpdate.get(0).Campaign);
                CName = cmToUpdate.get(0).Campaign.Name+'';
                CType = cmToUpdate.get(0).Campaign.Type+'';
                CId = cmToUpdate.get(0).CampaignId+'';
                
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
                
                usrToAssign = [SELECT Id, FirstName, Nodes__c, Agency_Code__c, TECH_Email__c FROM User WHERE Id =: SelectedUser];
                
                for(CampaignMember cm : cmToUpdate){
                    String Nodes = cm.Nodes__c;
                    String agencyCodeU = usrToAssign.Agency_Code__c; //used to check on agency code

                    Boolean naRes = false;
                    //String agencyCodeU = usrToAssign.Agency_Code__c; must check on user nodes, not on agency only
                    
                    //getting all nodes the usr is profiled for
                    Set<String> usrNodesSet = new set<String>();
                    for(String uN : usrToAssign.Nodes__c.split(';')){
                        usrNodesSet.add(uN.remove('DIF_'));
                    }
                    
                    if (usrNodesSet.contains(usrToAssign.Agency_Code__c)) { //only necessary to check the cm is on the correct agency
                        naRes = Nodes.contains(usrToAssign.Agency_Code__c); //i only need to find the agency code on the cm nodes string to be sure the usr has visibility
                    } else { //must check all nodes individually
                        //finding all nodes the user has visibility on
                        List<Node__c> usrvisibleNodes =  [SELECT Node_unique_code__c FROM Node__c WHERE  (Node_unique_code__c IN :usrNodesSet OR Parent_node_unique_code__c IN: usrNodesSet) AND Node_level__c >=7 and Node_level__c <=9 order by Node_unique_code__c  ASC];
                        
                        for (Node__c thisNode : usrvisibleNodes ){ //getting all the nodes codes
                            usrNodesSet.add(thisNode.Node_unique_code__c);
                        }
                        
                        for (String thisNodeCode: usrNodesSet){
                            if (!naRes) {//edit only if naRes is still false (node association not foundnot found)
                                naRes = Nodes.contains(thisNodeCode); //I check if any of the user nodes are present in the cm list
                            }
                        }
                    }
                    
                    
                    system.debug('++++++++++++Nodes : '+Nodes);
                    system.debug('++++++++++++agencyCodeU : '+usrToAssign.Agency_Code__c);
                    system.debug('++++++++++++naRes : '+naRes);
                    
                    if(naRes){
                        cm.Owner__c = SelectedUser;
                    }else{
                        errorMap.put(cm.Id,true);
                        error = true;
                        system.debug('***errorMap '+errorMap );
                    }
                }

                update cmToUpdate;
                refresh();
                //executeQuery();
                
                if(error) {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Attenzione! L\'utente assegnatario non ha visibilità sul cliente selezionato'));
                } else {
                    system.debug('++++++++++++++++did i check the flag?sendEmailToOwner+++'+sendEmailToOwner);
                    if (sendEmailToOwner) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        //String MailBody='';
                        //Mailbody=MailBody+'Ciao '+usrToAssign.FirstName+',<BR/>ti sono stati assegnati dei clienti da contattare per la campagna '+CType+' '+CName+ '.';
                        //Mailbody=Mailbody+'<BR/><BR/>Per accedere alla campagna puoi usare il seguente link<BR/> http://'+System.URL.getSalesforceBaseUrl().getHost()+'/'+Cid;
                        //Mailbody=Mailbody+'<BR/><BR/>Grazie per la collaborazione.';
                        List<EmailTemplate> template = new List<EmailTemplate>();
                        template = [select id, Subject, HtmlValue, Body from EmailTemplate where developername = : 'AAI_Assegnazione_membro_campagna'];
                        //template = [select id, Subject, HtmlValue, Body from EmailTemplate where developername = : 'AAI_Test_Template_HTML'];
            
                        system.debug('+++++++thisemailtemplate'+template.get(0));
                        mail.setUseSignature(false);
                        mail.setTemplateID(template.get(0).id);
                        map<String,String> mapFieldToValue = new Map<String,String>();
                        mapFieldToValue.put('{!User.FirstName}',usrToAssign.FirstName);
                        mapFieldToValue.put('{!Campaign.Name}',CName);
                        mapFieldToValue.put('{!Campaign.StartDate}',Cstart);
                        mapFieldToValue.put('{!Campaign.EndDate}',Cend);
                        mapFieldToValue.put('{!Campaign.Link}','http://'+System.URL.getSalesforceBaseUrl().getHost()+'/'+Cid);
            
                        //mail.setSubject('Assegnazione Lead Campagna '+CName);
                        //mail.setHtmlBody(MailBody);
                        //mail.setWhatId(Cid);
                        //mail.setTargetObjectId(usrToAssign.Id);
                        mail = UtilityClass.prepareEmailTemplate(template.get(0),mapFieldToValue );
                        //mail.setToAddresses( new String[] { 'dfabris@deloitte.it' } );
                        //mail.setToAddresses( new String[] { usrToAssign.TECH_Email__c } );
                        //mail.setTemplateID(template.get(0).id);
                        mail.setTargetObjectId(usrToAssign.id);
                        //system.debug('++++++++++++mail.getTargetObjectid'+mail.getTargetObjectId()+'+++++usrid'+usrtoassign.id);
                        mail.setSaveAsActivity(false);
                        //mail.setWhatid(Cid);
                        system.debug('+++++++++mail prepared'+mail);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        system.debug('+++++EMAIL limit (calls/limit)='+Limits.getEmailInvocations()+'/'+Limits.getLimitEmailInvocations());
                    }
                }  
            }else{
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Nessun Utente selezionato per l\'assegnazione'));
            }
        }else{
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Nessun cliente campagna selezionato per l\'assegnazione'));
        }
        

        displayPopupAssegnazione=false;
        sendEmailToOwner=false;
        
        
    }
*/    
    /*
    *   END Assign User to CampaignMember OLD VERSION NOT USED
    */   
    /*
    *  check visibility for button editing
    */   

    
    public boolean GetvisibilityCheck(){
        boolean visibility = false;
        Id currentProfileId = Userinfo.getProfileId();
        Profile currentProfile = [SELECT Name FROM Profile WHERE  Id =:currentProfileId ]; // NOPMD  Fix CRUD violation
        
        if ((currentProfile.Name=='AAI - Vendite Base')||  (currentProfile.Name=='AAI - Vendite Avanzato') ||  (currentProfile.Name=='System Administrator')||  (currentProfile.Name=='Amministratore del sistema'))
        {
            visibility = true;
        }
        
        return visibility;
    }
    
    /*
    *   helper class that represents a row
    */
    public with sharing class CCWRowItem{
        
        public CampaignMember tRecord{get;set;}
        public Integer PageNum{get; set;}
        public Boolean IsSelected{get;set;}
        public Task lastContact {get;set;}
        public String StatusPrecedente {get;set;}
        public String lastContactDate {get;set;}
        public String lastContactDateShort {get;set;}
        public String style {get;set;} //D.F. quickEvo3, to add style to CM status
        public String styleSP {get;set;} //A.V. quickEvo3, to add style to CM StatusPrecedente

        
        public CCWRowItem(CampaignMember c, Integer pn, Boolean s, Task lc, String sp, Boolean informativeCamp){
            system.debug('+++++'+c.id);
            system.debug('+++++'+c.contactId);
            system.debug('+++++'+c.contact.AccountId);
            
            
            //Just not to display blanks D.F. QuickEvo3
            //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- START
         //   if(String.isNotBlank(c.contactId) && String.isNotBlank(c.contact.AccountId))//added
         //   { BOVOLENTA_D REMOVED 11072017
            if (c.Contact.Account.Active_Insurance_Contracts__c == null)
                c.Contact.Account.Active_Insurance_Contracts__c=0;
            if (c.Contact.Account.Active_Campaigns__c == null)
                c.Contact.Account.Active_Campaigns__c=0;
        //    }
            //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- END
            
            this.tRecord=c;
            this.PageNum=pn;
            this.IsSelected=s;
            this.lastContact=lc;
            this.StatusPrecedente = sp;
            if (lastContact.createddate != null)
            if (informativeCamp) {
                if(c.LastModifiedDate != null){
                    lastContactDate = c.LastModifiedDate.format('dd-MM-yyyy HH:mm:ss');
                    lastContactDateShort = c.LastModifiedDate.format('dd-MM-yyyy');
                }
            } else {
                if (lastContact.createddate != null)
                {
                    lastContactDate = lastContact.createddate.format('dd-MM-yyyy HH:mm:ss');
                    lastContactDateShort = lastContact.createddate.format('dd-MM-yyyy');
                }
            }
            //D.F. quickEvo3 Start
            //CAPOBIANCO_A 25/07/2017 Data Enrichment -- START - Added "Lavorato" and "Da lavorare" conditions
            if (c.status=='Interessato' || c.status == 'Lavorato') {
                this.style='color: green;';
            } else if (c.status=='Da contattare' || c.status=='Da ricontattare' || c.status=='In Campagna' || c.status=='Non risponde') {
                this.style='color: #FF9518;';
            } else if (c.status=='Da assegnare') {
                this.style='color: black;';
            } else if (c.status=='Da lavorare') {
                this.style='color: #005fb2;';
            } else {
                this.style='color:red;';
            }
            //D.F. quickEvo3 END
            
            //A.V. quickEvo3 Start
            if (StatusPrecedente =='Interessato' || c.status == 'Lavorato') {
                this.styleSP='color: green;';
            } else if ( StatusPrecedente =='Da contattare' || StatusPrecedente =='Da ricontattare' || StatusPrecedente =='In Campagna'|| StatusPrecedente=='Da assegnare' || c.status=='Da lavorare') {
                this.styleSP='color: #FF9518;';    
            } else {
                this.styleSP='color:red;';
            }
            //A.V. quickEvo3 END
            //CAPOBIANCO_A 25/07/2017 Data Enrichment -- END
        }
        
    } 
    
    /*
    *   helper class to wrap the task
    */
    public without sharing class taskWrapper{
        
        public Task d {get;set;}

        
        public taskWrapper(){
            d = new task ();
        }
        
    }

    //TBD
    public with sharing class VisibilityRowItem {
        //Add here columns of the table for the visibility management
        public Boolean IsSelected{get;set;}
        public CampaignMember cm {get;set;}
        public String Result {get;set;}
        
        public VisibilityRowItem(CampaignMember cm) {
            this.cm=cm;
            this.IsSelected=false;
            this.Result='-';
        }
    }
    
    public Integer calcTotalPages(){   
        
        List<CampaignMember> totalList = getAllFiltered();
        Integer totalRecords = totalList.size();
        totalCMfiltered = totalRecords; //D.F. QuickEvo3
        Decimal totalRecordsD = totalRecords;
        
        Decimal limitSize = pageRecords;
        Decimal block = totalRecords/limitSize;
        Double totalPagesD = Math.ceil(block);
        /*Double totalPagesDB = Math.floor(block);
        system.debug('***totalRecords: '+totalRecords);
        system.debug('***totalPagesD: '+totalPagesD);
        system.debug('***totalPagesDB: '+totalPagesDB);*/
        Integer totalPagesI = totalPagesD.intValue();
        //totalPages = totalPagesI;
        //  Integer totalPages = block.round(System.RoundingMode.UP));
        return totalPagesI;
    }
    
    public List<CampaignMember> getAllFiltered(){
        
        List<CampaignMember> allList = new List<CampaignMember>();
        //this.queryToRun.Query = 'SELECT Id, '+objField+' FROM '+objName+' WHERE '+whereIdField+' = : CampaignId AND Partner_Role_Visibility__c = TRUE ';
        this.queryToRun.Query = 'SELECT Id, '+objField+' FROM '+objName+' WHERE '+whereIdField+' = : CampaignId AND Partner_Role_Visibility__c = TRUE ';
        
        /*
        //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- START
        if(pgType == 'LavorazioneCampagna')
        {
            if(dataEnrichment)
            {
                this.queryToRun.Query = this.queryToRun.Query + ' AND ContactId <> \'\' AND Status IN (\'Da Lavorare\',\'Lavorato\')';                
            }
            else
            //MOSCATELLI_M 24/07/2017: Data Enrichment -- END        
            this.queryToRun.Query = this.queryToRun.Query + ' AND Status IN (\'Contatto errato\',\'Non interessato\',\'Interessato\',\'Da contattare\',\'Da ricontattare\')';
        }
        //MOSCATELLI_M 05/07/2017: Bugfix_Blocco inserimento/esclusione clienti -- END
        */
        
        //Always filter on userRun Nodes
        List<Node__c> nodesList = new List<Node__c>();
        String ageCode = userRun.Agency_Code__c;
        system.debug('++++++ageCodeExQuery'+ageCode);
        if (ageCode!= null && ageCode != '')
        {
            //BOVOLENTA_D 10072017 BUGFIX FOR AGENCY NODES EGUAL TO OTHER AGENCIES' SUBNODES

            this.queryToRun.Query = this.queryToRun.Query + ' AND Agency_Code__c = \''+ageCode+'\'';

            //BUGFIX END
        }
        Set<String> userNodeSet = new Set<String> ();
        if (ageCode!= null && ageCode != '' && userRun.Nodes__c!='' && userRun.Nodes__c!=null)
        {

            for(String uN : userRun.Nodes__c.split(';')){
                userNodeSet.add(uN.remove('DIF_'));
            }
            system.debug('***userNodeSet '+userNodeSet );
            if(userNodeSet.contains(userRun.Agency_Code__c)) {
                ageCode = ageCode+'%';
                nodesList =  [SELECT Node_unique_code__c FROM Node__c WHERE  Node_unique_code__c LIKE : ageCode and  Node_level__c >=7 and Node_level__c <=9 order by Node_unique_code__c  ASC]; // NOPMD  Fix CRUD violation
            }else{
                nodesList =  [SELECT Node_unique_code__c FROM Node__c WHERE  (Node_unique_code__c IN :userNodeSet OR Parent_node_unique_code__c IN: userNodeSet) AND Node_level__c >=7 and Node_level__c <=9 order by Node_unique_code__c  ASC]; // NOPMD  Fix CRUD violation
            }
            system.debug('***nodesList '+nodesList );


        }
        
        string BaseStringNodes = '';

        if(userNodeSet.contains(userRun.Agency_Code__c)) { // all nodes are like agency code
            BaseStringNodes =' AND (Nodes__c LIKE \'%'+userRun.Agency_Code__c+'%\')';
        } else {//must run thourgh the user nodes
            if (nodesList.size()>0){
                //string BaseStringNodes ='(';
                BaseStringNodes =' AND (';
                for (Node__c thisnode: nodesList) {
                    //BaseStringNodes=BaseStringNodes+'\''+thisNode.Node_unique_code__c+'\''+',';
                    BaseStringNodes=BaseStringNodes+'Nodes__c LIKE \'%'+thisNode.Node_unique_code__c+'%\' OR ';
                }
                BaseStringNodes=BaseStringNodes.removeEnd(',');
                BaseStringNodes=BaseStringNodes.removeEnd('OR ');
                BaseStringNodes=BaseStringNodes+')';
            }
        }


        
        system.debug('++++++basestring2'+BaseStringNodes);


        //this.queryToRun.Query =  this.queryToRun.Query + ' AND Nodes__c IN '+BaseStringNodes;
        this.queryToRun.Query =  this.queryToRun.Query +BaseStringNodes;
        System.debug('*****queryToRun '+this.queryToRun.Query);
        


        /* OLD DATE FILTER - discontinued
        if(ExpireDate != '' && ExpireDate != null){
            this.queryToRun.Query = this.queryToRun.Query + ' AND ContactId != null AND Contact.Account.Policies_expiration__c LIKE \'%'+ExpireDate+'%\'';
        }*/
        
        /*CAPOBIANCO_A BUGFIX 10/04/2017 --- START
         * if(SelectedNode != '' && SelectedNode != null){
            this.queryToRun.Query = this.queryToRun.Query + ' AND Nodes__c LIKE \'%'+SelectedNode+'%\'';
        }*/
        if(SelectedNode != '' && SelectedNode != null){
            if (SelectedNode.length()>6){ //looking for sub nodes
                this.queryToRun.Query = this.queryToRun.Query + ' AND Nodes__c LIKE \'%'+SelectedNode+'%\''; //LIKE \'%'+SelectedNode+'%\'';
            }else{
                this.queryToRun.Query = this.queryToRun.Query + ' AND Nodes__c = \''+SelectedNode+'\'';
            }
        } 
        //CAPOBIANCO_A BUGFIX 10/04/2017 --- END
        
        
        if(SelectedOwner != '' && SelectedOwner != null){
            if(SelectedOwner == 'Nessun Titolare'){
                this.queryToRun.Query = this.queryToRun.Query + ' AND Owner__c = null';
            }else{
                this.queryToRun.Query = this.queryToRun.Query + ' AND Owner__c =: SelectedOwner';
            }               
        }
        
        system.debug('++in getallfiltered SelectedStatus'+SelectedStatus);
        if(SelectedStatus != '' && SelectedStatus != null){
            this.queryToRun.Query = this.queryToRun.Query + ' AND Status =: SelectedStatus';
        }
        system.debug('++in getallfiltered substatus'+SelectedSubstatus);
         if(SelectedSubstatus != '' && SelectedSubstatus != null){
            this.queryToRun.Query = this.queryToRun.Query + ' AND Sottostato__c =: SelectedSubstatus';
        }

        //CAPOBIANCO_A 24/07/2017 Data Enrichment Campaigns START
        system.debug('processed:'+isProcessed);
        if(isProcessed != '-- Cliente lavorato --')
        {
            if(isProcessed == 'Sì')
            {
                this.queryToRun.Query = this.queryToRun.Query + ' AND Status = \'Lavorato\'';
            }
            else if(isProcessed == 'No')
            {
                this.queryToRun.Query = this.queryToRun.Query + ' AND (Status = \'Da lavorare\' OR Status = \'Da assegnare\')';
            }
        }
        //CAPOBIANCO_A 24/07/2017 Data Enrichment Campaigns END
        
        system.debug('++in getallfiltered SelectedPriority'+SelectedPriority);
         if(!String.isEmpty(SelectedPriority)){
             boolean isPriority = boolean.ValueOf(SelectedPriority);
            this.queryToRun.Query = this.queryToRun.Query + ' AND Cliente_prioritario__c =: isPriority';
        }
        
        if(informativeCamp){
            if(SelectedInformativeOutcome != '' && SelectedInformativeOutcome != null){
                this.queryToRun.Query = this.queryToRun.Query + ' AND Informative_Contact_Outcome__c =: SelectedInformativeOutcome';
            }
        }   
        
        /* REMOVED FOR FEEDBACK  19/02/16
        if(promotionalPrivacyTerm != '' && promotionalPrivacyTerm != null){
            Boolean privacySupport;
            if (promotionalPrivacyTerm =='TRUE')
            {
                privacySupport = true;
            }
            if (promotionalPrivacyTerm =='FALSE')
            {
                privacySupport = false;
            }            
            this.queryToRun.Query = this.queryToRun.Query + ' AND Contact.Account.Promotional_privacy__c=: privacySupport ';
        }        */
        
        if(startTask.d.RecurrenceEndDateOnly != null){
            Date startDate = startTask.d.RecurrenceEndDateOnly;
            startDate = startDate.addDays(-1);
            this.queryToRun.Query = this.queryToRun.Query + ' AND ContactId != null AND Contact.Account.First_expiration_date__c > :startDate  ';
        }
        
        if(endTask.d.RecurrenceEndDateOnly != null){
            Date endDate = endTask.d.RecurrenceEndDateOnly;
            endDate = endDate.addDays (1);
            this.queryToRun.Query = this.queryToRun.Query + ' AND ContactId != null AND Contact.Account.First_expiration_date__c < :endDate ';
        }

        if(LastNameFilter != '' && LastNameFilter != null){
            LastNameFilter = LastNameFilter.trim();
            this.queryToRun.Query = this.queryToRun.Query + ' AND Contact.Account.LastName LIKE \'%'+LastNameFilter+'%\'';
        }
        
        if(FirstNameFilter != '' && FirstNameFilter != null){
            FirstNameFilter = FirstNameFilter.trim();
            this.queryToRun.Query = this.queryToRun.Query + ' AND Contact.Account.FirstName LIKE \'%'+FirstNameFilter+'%\'';
        }
        /* REMOVED FOR FEEDBACK  19/02/16
        if(pgType == 'LavorazioneCampagna'){
            this.queryToRun.Query = this.queryToRun.Query + ' AND Status IN (\'Interessato\',\'Da contattare\',\'Da ricontattare\')';
        }*/
        
        /* REMOVED FOR FEEDBACK  19/02/16

        if(SelectedPrevCampaign != '' && SelectedPrevCampaign != null){
            
            Set<Id> cmAccIdSet = new Set<Id>();
            
            String queryPrevCampaign = 'SELECT Contact.AccountId, Status FROM CampaignMember WHERE CampaignId =: SelectedPrevCampaign';
            
            
            List<CampaignMember> allListSoFar = new List<CampaignMember>();
            allListSoFar = Database.query(this.queryToRun.Query);//BaseStringNodes set on line 1284 

            //New Query string. retrieve contact id of current list
            Map<Id,Id> CMidToAccId= new map<Id,Id>();
            //populate map
            system.debug('+++++++++current list record size in getallfiltered '+listRecords.size());
            for (CampaignMember thisCM : allListSoFar) {
                CMidToAccId.put(thisCM.id,thisCM.ContactId);
            }
            //if (CMidToAccId.values().size()>0) {
                //the new query retrieves only the previous campaign members of the current view
                List<Id> currentCMids = CMidToAccId.values();
                system.debug('++++++currentCMids '+currentCMids );
                queryPrevCampaign = 'SELECT Contact.AccountId, Status FROM CampaignMember WHERE CampaignId =: SelectedPrevCampaign AND ContactId IN:currentCMids ';
            //} 
            
            if(SelectedPrevStatus != '' && SelectedPrevStatus != null){
                queryPrevCampaign = queryPrevCampaign + ' AND Status =: SelectedPrevStatus'; 
            }
            
            system.debug('+++++++++++prev camp query '+queryPrevCampaign);
            List<CampaignMember> cmAccIdList = Database.query(queryPrevCampaign);
            

            for (CampaignMember cmai : cmAccIdList){
                cmAccIdSet.add(cmai.Contact.AccountId);
                PrevCampaingCMStatus.put(cmai.Contact.AccountId, cmai.Status);
            }
            
            if(SelectedPrevStatus != '' && SelectedPrevStatus != null){
                this.queryToRun.Query = this.queryToRun.Query + ' AND Contact.AccountId IN: cmAccIdSet';
            }
            
        }*/

        system.debug('***Query: '+this.queryToRun.Query);
        allList = Database.query(this.queryToRun.Query);//BaseStringNodes set on line 1284 
        //filterListID.clear();
        //for (CampaignMember thisCM : allList){
        //    filterListID.add(thisCM.ID);
        //}
        totalCMfiltered= allList.size();
        //filterlist = allList;
        return allList;
    }

    public List<CampaignMember> getAll(){
        
        List<CampaignMember> allList = new List<CampaignMember>();
        this.queryToRun.Query = 'SELECT Id, '+objField+' FROM '+objName+' WHERE '+whereIdField+' = : CampaignId AND Partner_Role_Visibility__c = TRUE ';
        
        //Always filter on userRun Nodes
        List<Node__c> nodesList = new List<Node__c>();
        String ageCode = userRun.Agency_Code__c;
        system.debug('++++++ageCodeExQuery'+ageCode);
        if (ageCode!= null && ageCode != '')
        {
            //BOVOLENTA_D 10072017 BUGFIX FOR AGENCY NODES EGUAL TO OTHER AGENCIES' SUBNODES

            this.queryToRun.Query = this.queryToRun.Query + ' AND Agency_Code__c = \''+ageCode+'\'';

            //BUGFIX END
        }

        Set<String> userNodeSet = new Set<String> ();
        if (ageCode!= null && ageCode != '' && userRun.Nodes__c!=null && userRun.Nodes__c!='')
        {

            for(String uN : userRun.Nodes__c.split(';')){
                userNodeSet.add(uN.remove('DIF_'));
            }
            system.debug('***userNodeSet '+userNodeSet );
            if(userNodeSet.contains(ageCode)) {
                ageCode = ageCode+'%';
                nodesList =  [SELECT Node_unique_code__c FROM Node__c WHERE  Node_unique_code__c LIKE : ageCode and  Node_level__c >=7 and Node_level__c <=9 order by Node_unique_code__c  ASC]; // NOPMD  Fix CRUD violation
            }else{
                nodesList =  [SELECT Node_unique_code__c FROM Node__c WHERE  (Node_unique_code__c IN :userNodeSet OR Parent_node_unique_code__c IN: userNodeSet) AND Node_level__c >=7 and Node_level__c <=9 order by Node_unique_code__c  ASC]; // NOPMD  Fix CRUD violation
            }
            system.debug('***nodesList '+nodesList );
        }
        
        string BaseStringNodes = '';

        if(userNodeSet.contains(userRun.Agency_Code__c)) { // all nodes are like agency code
            BaseStringNodes =' AND (Nodes__c LIKE \'%'+userRun.Agency_Code__c+'%\')';
        } else {//must run thourgh the user nodes
            if (nodesList.size()>0){
                //string BaseStringNodes ='(';
                BaseStringNodes =' AND (';
                for (Node__c thisnode: nodesList) {
                    //BaseStringNodes=BaseStringNodes+'\''+thisNode.Node_unique_code__c+'\''+',';
                    BaseStringNodes=BaseStringNodes+'Nodes__c LIKE \'%'+thisNode.Node_unique_code__c+'%\' OR ';
                }
                BaseStringNodes=BaseStringNodes.removeEnd(',');
                BaseStringNodes=BaseStringNodes.removeEnd('OR ');
                BaseStringNodes=BaseStringNodes+')';
            }
        }


        system.debug('++++++basestring3'+BaseStringNodes);


        
        this.queryToRun.Query =  this.queryToRun.Query +BaseStringNodes;

        system.debug('***Query: '+this.queryToRun.Query);
        allList = Database.query(this.queryToRun.Query); //BaseStringNodes set on line 1431   
        return allList;
    }   
    

    /*
    *   Assign User to CampaignMember new version optimized LS 25/09/2015
    */
    public void changeCampaignMemberOwner(){
        cmToUpdate = new List<CampaignMember>();//visible only by this method
        cmNotVisible = new List<VisibilityRowItem>();//to be passed to other methods that manage the visibility process
        cmNotVisibleToExtend = new List<VisibilityRowItem>();//to be passed to other methods that manage the visibility process
        Boolean error = false;
        getSelectedItems();//populating the list of selected ids
        system.debug('+++++++errorMap'+errorMap);
        system.debug('+++++++selectedRecordIds'+selectedRecordIds);
        
        //Resetting errors before next operation
        for (Id cmId : errorMap.keySet()){
            errorMap.put(cmId,false);
        }
        
        //Variables used for the email composition
        usrToAssign = new User();
        String CName = '';
        String CType = '';
        String CId = null;
        String Cstart= '';
        String Cend = '';
        String cUrl = '';
        
        //Starting operations here
        if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){//handling no slection case for CM
            if(SelectedUser != '' && SelectedUser != null){//handling no selection case for User
                cmToUpdate = [SELECT Id, Owner__c, Status, CampaignId, Nodes__c, Campaign.URL_Salesforce_campagna__c, Campaign.StartDate, Campaign.EndDate, Campaign.Name, Campaign.Type, LeadId, ContactId, Contact.Account.Ndg__c, contact.Account.Id, contact.Account.Nodes__c FROM CampaignMember WHERE Id IN: selectedRecordIds];
                system.debug('+++++++cmToUpdate'+cmToUpdate);
                system.debug('++++++cmtoupdate.Campaign'+ cmToUpdate.get(0).Campaign);
                //to be used for the email
                CName = cmToUpdate.get(0).Campaign.Name+'';
                CType = cmToUpdate.get(0).Campaign.Type+'';
                CId = cmToUpdate.get(0).CampaignId+'';
                CUrl = cmToUpdate.get(0).Campaign.URL_Salesforce_campagna__c + '';

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
                
                usrToAssign = [SELECT Id, Name, FirstName, Nodes__c, Agency_Code__c, TECH_Email__c FROM User WHERE Id =: SelectedUser ]; // NOPMD  Fix CRUD violation
                //Checking visiblity
                Set<Id> relatedRecordIds = new Set<Id>();
                for (CampaignMember cm : cmToUpdate){
                    if (cm.LeadId != null ) {relatedRecordIds.add(cm.LeadId);}
                    if (cm.ContactId != null ) {relatedRecordIds.add(cm.ContactId);}
                }
                List<UserRecordAccess> usrAccessRecordList = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :SelectedUser AND RecordId in :relatedRecordIds ]; // NOPMD  Fix CRUD violation
                system.debug('++++++++++ usrAccessRecordList '+usrAccessRecordList);
                system.debug('++++++++++ SelectedUser '+SelectedUser);
                Set<Id> campaignMemberIdVisibleToUser = new Set<Id>();
                for(UserRecordAccess ura : usrAccessRecordList)
                {
                    if (ura.hasReadAccess == true)
                    {
                        campaignMemberIdVisibleToUser.add(ura.RecordId);
                    }
                }
                
                //For dispaly purpose on the popup
                CountRequiringVisibility = 0;
                CountSelected = cmToUpdate.size();
                //For dispaly purpose on the popup
                
                
                for(CampaignMember cm : cmToUpdate){
                    
                    if(campaignMemberIdVisibleToUser.contains(cm.ContactId) || campaignMemberIdVisibleToUser.contains(cm.LeadId)){
                        cm.Owner__c = SelectedUser;
                        //CAPOBIANCO_A 25/07/2017 Data Enrichment -- START
                        //D.F. QuickEvo3 START - on assignment if cm.Status='in campagna' or if cm.Status='da assegnare' set it to 'da contattare'
                        //if (cm.status.tolowercase()=='in campagna' || cm.status.tolowercase()=='da assegnare') {
                        /* // SERGER_T: OTTIMIZZAZIONE CAMPAGNA
                        if (!dataEnrichment && !informativeCamp && (cm.status.tolowercase()=='in campagna' || cm.status.tolowercase()=='da assegnare')) {
                            cm.status='Da contattare';
                        }//D.F. QuickEvo3 END
                        else if(dataEnrichment || informativeCamp)
                        {
                            if(cm.Status=='Da assegnare')
                            {
                                cm.Status = 'Da lavorare';
                            }
                        }*/
                        if (cm.status.tolowercase() == 'da assegnare')
                            cm.Status = 'Da lavorare';
                        //CAPOBIANCO_A 25/07/2017 Data Enrichment -- END
                    }else{
                        CountRequiringVisibility=CountRequiringVisibility+1;
                        cmNotVisible.add(new VisibilityRowItem(cm));
                        errorMap.put(cm.Id,true);
                        error = true;
                        system.debug('***errorMap '+errorMap );
                    }
                }
                
                //ENTRY POINT FOR VISIBILITY MANAGEMENT CIF for Sprint 9
                if (CountRequiringVisibility>0 && userRun.Profile.Name == 'AAI - Vendite Avanzato') {
                    showPopupVisibility();
                    /////////////////// MUST SPLIT REMAINING PROCESS ON OTHER METHODS ////////////////////7
                } else { //runnnng nomral process
                    //Normal Process without visibility assignment
                    update cmToUpdate;
                    refresh();
                    if(error) {
                        system.debug('***Errore5'); //Antonino Massarotti 18/11
                        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Attenzione! L\'utente assegnatario non ha visibilità sul cliente selezionato'));
                    } else {
                        //Proceeding with the email
                        system.debug('++++++++++++++++did i check the flag?sendEmailToOwner+++'+sendEmailToOwner);
                        if (sendEmailToOwner) {
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail = prepareEmailForAsssignment(usrToAssign, CName, Cid, Cstart, Cend, CUrl);
                            system.debug('+++++++++mail prepared'+mail);
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                            system.debug('+++++EMAIL limit (calls/limit)='+Limits.getEmailInvocations()+'/'+Limits.getLimitEmailInvocations());
                            sendEmailToOwner=false;//switching for next request
                        }
                    }
                } //close options visibility
            }else{
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Nessun Utente selezionato per l\'assegnazione'));
            }
        }else{
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Nessun cliente campagna selezionato per l\'assegnazione'));
        }
        displayPopupAssegnazione=false;
    }
    
    public static Messaging.SingleEmailMessage prepareEmailForAsssignment(User usrToAssign, string CampaignName,String CampaignId, String StartDate, String EndDate, String CampaignUrl) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<EmailTemplate> template = new List<EmailTemplate>();
        template = [select id, Subject, HtmlValue, Body from EmailTemplate where developername = : 'AAI_Assegnazione_membro_campagna' ]; // NOPMD  Fix CRUD violation
        if (template != null && !template.isEmpty()) {
            system.debug('+++++++thisemailtemplate'+template.get(0));
            mail.setTemplateID(template.get(0).id);
        }
        mail.setUseSignature(false);
        map<String,String> mapFieldToValue = new Map<String,String>();
        mapFieldToValue.put('{!User.FirstName}',usrToAssign.FirstName);
        mapFieldToValue.put('{!Campaign.Name}',CampaignName);
        mapFieldToValue.put('{!Campaign.StartDate}',StartDate);
        mapFieldToValue.put('{!Campaign.EndDate}',EndDate);
        mapFieldToValue.put('{!Campaign.Link}',CampaignUrl);
        
        if (template != null && !template.isEmpty()) {
            mail = UtilityClass.prepareEmailTemplate(template.get(0), mapFieldToValue);
        } else {
            mail.setPlainTextBody('htmlbody');
        }
        mail.setTargetObjectId(usrToAssign.id);
        mail.setSaveAsActivity(false);
        return mail ;
    }

    public void AssignVisibleOnly() {
        //the list cmToUpdate is already populated with the correct new owners (see line 1704)
        system.debug('++++++'+cmToUpdate);
        update cmToUpdate;
        refresh();
        
        //Proceeding with the email
        system.debug('++++++++++++++++did i check the flag?sendEmailToOwner+++'+sendEmailToOwner);
        if (sendEmailToOwner) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            String Cstart ='Non disponibile';
            String Cend = 'Non disponibile';
            
            Campaign CurrentCampaign =[SELECT Id,StartDate,EndDate, Type, Name, URL_Salesforce_campagna__c FROM Campaign WHERE Id =: CampaignId];

            if (CurrentCampaign.StartDate!=null) Cstart = CurrentCampaign.StartDate.format()+'';
            if (CurrentCampaign.EndDate!=null) Cend = CurrentCampaign.EndDate.format()+'';        
            
            user usrToAssign = [SELECT Id, FirstName, Nodes__c, Agency_Code__c, TECH_Email__c FROM User WHERE Id =: SelectedUser ]; // NOPMD  Fix CRUD violation

            mail = prepareEmailForAsssignment(usrToAssign, CurrentCampaign.Name, CurrentCampaign.Id, Cstart,Cend, CurrentCampaign.URL_Salesforce_campagna__c);
            system.debug('+++++++++mail prepared'+mail);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            system.debug('+++++EMAIL limit (calls/limit)='+Limits.getEmailInvocations()+'/'+Limits.getLimitEmailInvocations());
        }
        closePopup();
    }
    
    public PageReference gotToVisibilityMngmt() {
        update cmToUpdate;//Assigne the ones that are already visible
        
        //if there are some visible I already send the mail here and dont send it later.
        //if all the selected are not visible i send the mail only when the visibility is extended
        if(CountRequiringVisibility<CountSelected) {//Some have already been assigned in the precedent update
            if (sendEmailToOwner) {
                String CName = cmToUpdate.get(0).Campaign.Name+'';
                String CId = cmToUpdate.get(0).CampaignId+'';
                String Cstart = '';
                String Cend = '';
                String CUrl = cmToUpdate.get(0).Campaign.URL_Salesforce_campagna__c + '';
                
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
                mail = prepareEmailForAsssignment(usrToAssign, CName, Cid, Cstart,Cend, CUrl);
                system.debug('+++++++++mail prepared'+mail);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                system.debug('+++++EMAIL limit (calls/limit)='+Limits.getEmailInvocations()+'/'+Limits.getLimitEmailInvocations());
                sendEmailToOwner=false;//switching for next request
            }
        }
        closePopup();
        return Page.VisibilityManagement;
    }    
    
    public PageReference goToCampaignPage() {
        // SERGER_T: OTTIMIZZAZIONE CAMPAGNA - START
        //PageReference pageRef = new PageReference('/apex/CampaignMembersView?id='+CampaignId+'&pgType='+pgType);//in order to keep compiled the URL parameters
        PageReference pageRef = new PageReference('/apex/CampaignMembersView?id='+CampaignId);//in order to keep compiled the URL parameters
        // SERGER_T: OTTIMIZZAZIONE CAMPAGNA - END
        
        pageRef.setRedirect(true); //in order to call the constructor again
        return pageRef;
    }

    public void ExtendVisibility(){
        if (String.isEmpty(SelectedNodeVisibility)) {        //Handle no node selected
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Selezionare almeno un nodo'));
        } else {
            getSelectedItemsVisibility();
            if (cmNotVisibleToExtend.isEmpty()) {        //Handle no client selected
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Selezionare almeno un cliente'));
            } else {
                //Prepare Engine record
                IE_Integration_Record__c myIErecord = VisibilityManagementHelper.PopulateIErecord(cmNotVisibleToExtend, SelectedNodeVisibility);
                
                //Initialise Engine
                IE_Engine myIEInstance = new IE_Engine(myIErecord);
                
                //Perform Integration
                system.debug('++++++++++compiling request+++++++++');
                try {
                    myIEInstance.compilerequest();
                    myIErecord.RequestBody__c=myIEInstance.compiledXML;
                    system.debug('+++THE compiled request'+myIEInstance.compiledXML);
                } catch ( exception e ) {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Si è verificato un errore'));
                    myIErecord.ErrorMessage__c='Error at line '+ e.getLineNumber() + 'IE could not COMPILE a request'+ e.getStackTraceString();
                    myIErecord.Status__c='KO';
                    upsert myIErecord; // NOPMD  Fix CRUD violation            
                    return;
                }

                system.debug('++++++++++sending request+++++++++');
                try {
                    myIEInstance.sendRequest();
                } catch ( exception e ) {
                    /*
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Si è verificato un errore'));
                    myIErecord.ErrorMessage__c='Error at line '+ e.getLineNumber() + 'IE could not SEND a request'+ e.getStackTraceString();
                    myIErecord.Status__c='KO';
                    upsert myIErecord;            
                    return;
                    */
                    //Temporary for test purposes
                    CIF_Nodes_Mock mockServer = new CIF_Nodes_Mock();
                    mockServer.TestCase='';
                    MyIEInstance.RawResponse = mockServer.respond(myIEInstance.myReq);
                    myIErecord.ResponseBody__c = MyIEInstance.RawResponse.getBody().normalizeSpace();//Ususally done by engine
                }
                
                system.debug('++++++++++INTERPRETING request+++++++++');
                try {
                    myIEInstance.interpretResponse();
                } catch ( exception e ) {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Error, 'Si è verificato un errore'));
                    myIErecord.ErrorMessage__c='Error at line '+ e.getLineNumber() + 'IE could not INTERPRET a response'+ e.getStackTraceString();
                    myIErecord.Status__c='KO';
                    upsert myIErecord; // NOPMD  Fix CRUD violation
                                
                    return;
                }
                system.debug('+++++myIEInstance'+myIEInstance);
                //Update According to the response received. returning the updated list of rowitems
                cmNotVisible = VisibilityManagementHelper.UpdateVisibilityAndAssign(myIEInstance,cmNotVisible, usrToAssign,SelectedNodeVisibility, sendEmailToOwner);
                sendEmailToOwner = false;//switching as the email is sent here "UpdateVisibilityAndAssign"
            }
        }
        system.debug('+++++cmNotVisibleToExtend'+cmNotVisibleToExtend);
    }
    
    public void getSelectedItemsVisibility() {
        cmNotVisibleToExtend.clear(); //resetting every time
        for (VisibilityRowItem thisItem : cmNotVisible) {
            system.debug('++++thisitem'+thisitem);
            if (thisitem.IsSelected) {
                cmNotVisibleToExtend.add(thisItem);
            }
        }
    }
    
    
    // SERGER_T: OTTIMIZZAZIONE CAMPAGNA - START
    
    public CampaignMember myCM {get;set;}
    public Id cmID {get;set;}
    
    public boolean createOpportunity {get;set;}
    public boolean createAppointment {get;set;}
    
    public boolean displayTCpositive {get;set;}
    public boolean displayTCrecall {get;set;}
    public boolean displayTCnegative {get;set;}
    public boolean displayTCinformative_p1 {get;set;}
    public boolean displayTCinformative_p2 {get;set;}
    public boolean displayCP {get;set;}
    public String notInterestedReason {get;set;}
    
    public void tcPositive() {
        displayTCpositive = true;
        
        createOpportunity = true;
        createAppointment = false;
        taskEmailtoUser = false;
        
        alertMessage = 'Cliente interessato';
        
        myCM = [SELECT Id, Status, ContactId, Contact.AccountId, Contact.Account.PersonMailingAddress, Contact.Name, CampaignId, Campaign.RecordType.DeveloperName, Owner__c, Not_Interested_Reason__c, Lead.Name, Lead.Id, Number_of_contact_attempts__c, Nodes__c,Campaign_member_related_opportunity__c, Informative_Contact_Outcome__c FROM CampaignMember WHERE Id=:cmID LIMIT 1];
        myCM.Status = 'Interessato';
        myCM.Not_Interested_Reason__c = null;
        myCM.Owner__c = Userinfo.getUserId();
        
        taskSelectedUser = Userinfo.getUserId();
        
        createAppointment();
        myAppointment.StartDateTime = DateTime.now();
        myAppointment.EndDateTime = myAppointment.StartDateTime.addHours(1);
        myAppointment.Luogo_appuntamento__c ='Presso cliente';
        myAppointment.Location = printAddress(myCM.Contact.Account.PersonMailingAddress);
        myAppointment.WhoId = myCM.ContactId;
        myAppointment.Subject = 'Appuntamento per campagna ' + CampaignName;
        
		createReminder();
        myTask.Interest_Rate__c= 'Interessato';
        myTask.Status = 'Completed';
        myTask.IsReminderSet = false;
        myTask.ReminderDateTime = null;
        myTask.Subject = 'Contattato per la campagna ' + CampaignName;
    }
    public void tcRecall() {
        displayTCrecall = true;
        
        createOpportunity = false;
        createAppointment = false;
        taskEmailtoUser = false;
        
        alertMessage = 'Cliente da ricontattare';
        
        myCM = [SELECT Id, Status, ContactId, Contact.AccountId, Contact.Account.PersonMailingAddress, Contact.Name, CampaignId, Campaign.RecordType.DeveloperName, Owner__c, Not_Interested_Reason__c, Lead.Name, Lead.Id, Number_of_contact_attempts__c, Nodes__c,Campaign_member_related_opportunity__c, Informative_Contact_Outcome__c FROM CampaignMember WHERE Id=:cmID LIMIT 1];
        myCM.Status = 'Da ricontattare';
        myCM.Owner__c = Userinfo.getUserId();
        
        createReminder();
        myTask.Interest_Rate__c= 'Da ricontattare';
    }
    public void tcNegative() {
        displayTCnegative = true;
        
        createOpportunity = false;
        createAppointment = false;
        taskEmailtoUser = false;
        
        alertMessage = 'Perchè non era interessato?';
        
        myCM = [SELECT Id, Status, ContactId, Contact.AccountId, Contact.Account.PersonMailingAddress, Contact.Name, CampaignId, Campaign.RecordType.DeveloperName, Owner__c, Not_Interested_Reason__c, Lead.Name, Lead.Id, Number_of_contact_attempts__c, Nodes__c,Campaign_member_related_opportunity__c, Informative_Contact_Outcome__c FROM CampaignMember WHERE Id=:cmID LIMIT 1];
        myCM.Status= 'Non interessato';
        myCM.Owner__c = Userinfo.getUserId();

        createReminder();
        myTask.Status = 'Completed';
        myTask.Interest_Rate__c= 'Non interessato';
        myTask.IsReminderSet = false;
        myTask.ReminderDateTime = null;
        
        createOpportunity = false;
        createAppointment = false;
    }
    
    public void tcInformative() {
        displayTCinformative_p1 = true;
        
        createOpportunity = false;
        createAppointment = false;
        taskEmailtoUser = false;
        
        alertMessage = '';
        
        myCM = [SELECT Id, Status, ContactId, Contact.AccountId, Contact.Account.PersonMailingAddress, Contact.Name, CampaignId, Campaign.RecordType.DeveloperName, Owner__c, Not_Interested_Reason__c, Lead.Name, Lead.Id, Number_of_contact_attempts__c, Nodes__c,Campaign_member_related_opportunity__c, Informative_Contact_Outcome__c FROM CampaignMember WHERE Id=:cmID LIMIT 1];
        myCM.Status = 'Lavorato';
        myCM.Not_Interested_Reason__c = null;
        myCM.Owner__c = Userinfo.getUserId();
        
        taskSelectedUser = Userinfo.getUserId();
        createReminder();
    }
    
    public void backTC() {
        displayTCinformative_p1 = true;
        displayTCinformative_p2 = false;
    }
    public void closeTC() {
        alertMessage = '';
        
        displayTCpositive = false;
        displayTCrecall = false;
        displayTCnegative = false;
        displayTCinformative_p1 = false;
        displayTCinformative_p2 = false;
        
        createOpportunity = false;
        createAppointment = false;
        taskEmailtoUser = false;
        
        refresh();
    }
    /*
    public void createProposal() {
        string myOppId = Apexpages.currentPage().getParameters().get('oppId');
        cmID = Apexpages.currentPage().getParameters().get('mycmId');
        
        system.debug('TUGAL-myOpp: ' + myOppId);
        system.debug('TUGAL-myCM: ' + cmID);
        
        
        myCM = [SELECT Id, Status, ContactId, Contact.AccountId, Contact.Account.PersonMailingAddress, Contact.Name, CampaignId, Campaign.RecordType.DeveloperName, Owner__c, Not_Interested_Reason__c, Lead.Name, Lead.Id, Number_of_contact_attempts__c, Nodes__c,Campaign_member_related_opportunity__c, Informative_Contact_Outcome__c FROM CampaignMember WHERE Id=:cmID LIMIT 1];
        if (myOppId != '')
            myCM.Campaign_member_related_opportunity__c = myOppId;
        myCM.Status = 'Interessato';
        myCM.Owner__c = Userinfo.getUserId();
        
        update myCM;
        
        refresh();
    }
    */
    public boolean checkOpp {get;set;}
    public string urlTEST {get;set;}
    public string urlDAOL {get;set;}
    
	public void createProposal() {
        
        myCM = [SELECT Id, Status, ContactId, Contact.AccountId, Contact.Account.PersonMailingAddress, Contact.Name, CampaignId, Campaign.RecordType.DeveloperName, Owner__c, Not_Interested_Reason__c, Lead.Name, Lead.Id, Number_of_contact_attempts__c, Nodes__c,Campaign_member_related_opportunity__c, Informative_Contact_Outcome__c FROM CampaignMember WHERE Id=:cmID LIMIT 1];
        
        string accId = myCM.Contact.Account.Id;
        Account myAccount = [SELECT Id, Name, NDG__c FROM Account WHERE Id =: accId LIMIT 1];
        string NDG = myAccount.NDG__c;
        string accName = myAccount.Name;
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Account.Id =: accId AND StageName= 'Open' AND Numero_proposte__c = 0];
        
        if (oppList.size() == 0) {
            if (GetvisibilityCheck()) {
                //Crea Opportunità
                RecordType oppRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Opportunita_AXA_Assicurazioni' ]; // NOPMD  Fix CRUD violation
                
                Opportunity newOpp = new Opportunity();
                newOpp.Name = 'OPP-XXXXXXX';
                newOpp.AccountId = accId;
                newOpp.StageName = 'Open';
                newOpp.CloseDate = Date.Today().addMonths(1);
                newOpp.RecordTypeId = oppRT.Id;
                newOpp.Codice_ASA__c = CurrentCampaign.ASA__c;
                newOpp.CampaignId = myCM.CampaignId;
                insert newOpp;
                
                Opportunity myOpp = [SELECT Id, Name FROM Opportunity WHERE Account.Id =: accID ORDER BY CreatedDate DESC LIMIT 1];
                
                myCM.Campaign_member_related_opportunity__c = myOpp.Id;
                myCM.Status = 'Interessato';
                myCM.Owner__c = Userinfo.getUserId();
                
                string ProfileName = Userinfo.getProfileId();
                User myUser = [SELECT Agency_Code__c, CommunityNickname FROM User WHERE Id =: myCM.Owner__c LIMIT 1]; // NOPMD  Fix CRUD violation
                string AgencyCode = myUser.Agency_Code__c;
                string MyriamUsername = myUser.CommunityNickname;
                
                checkOpp = true;
                
                update myCM;
                refresh();
                
                AAI_Code_Variables__c aaiValue = [SELECT Value__c FROM AAI_Code_Variables__c WHERE Name = 'DAOL_URL_Prefix_CreaPropostaAccount' LIMIT 1]; // NOPMD  Fix CRUD violation
                string myParams = 'ServletSalesForce?RGICommand=NewProp&utente='+MyriamUsername+'&codiceAgenzia='+Agencycode+'&codiceNDG='+NDG+'&keySFDC='+myOpp.Id+'&descSFDC='+myOpp.Name;
                urlDAOL = aaiValue.Value__c + myParams + '_blank';
            }
            
            else {
                // Insufficient privileges
            }
            
        }
        
        else {
            checkOpp = false;
            
            urlTEST = '/agenzie/apex/CreaPropostaAccount?Id=' + myCM.Contact.AccountId + '&cmID=' + myCM.Id;
            displayCP = true;
            
            myCM.Status = 'Interessato';
            myCM.Owner__c = Userinfo.getUserId();
            
            update myCM;
            refresh();

        }
        
    }
    
    
    public void closeCP() {
        displayCP = false;
    }
    
    
    // Action PopUp Management
    public boolean displayPopupAssegnazione {get;set;}    
    public boolean displayPopupEsclusione {get;set;}    
    public boolean displayPopupStato {get;set;} 
    public boolean displayPopupVisibility {get;set;}
    public String taskErrorMessage {get;set;}
    
    public void showPopupAssegnazione() {        
        alertMessage = 'Sei sicuro di voler procedere con l\'assegnazione dei clienti campagna selezionati?';
        displayPopupAssegnazione = true;
    }
    public void showPopupStato() {
        alertMessage = 'Sei sicuro di voler cambiare lo stato dei clienti campagna selezionati?';
        displayPopupStato = true; 
    }
    public void showPopupVisibility() {
        alertMessage = 'Attenzione: ' + CountRequiringVisibility + ' dei ' + CountSelected + ' clienti campagna selezionati non possono essere assegnati poiché non sono visibili all\'utente ' + usrToAssign.Name;
        displayPopupVisibility = true;
    }
    public void showPopupEsclusione() {
        alertMessage = 'Sei sicuro di voler escludere i clienti campagna selezionati?';
        displayPopupEsclusione = true;
    }
    public void closePopup() {
        displayPopupStato = false;
        displayPopupEsclusione = false;
        displayPopupAssegnazione = false;
        displayPopupVisibility = false;
    }
    
    
    // TASK MANAGEMENT
    public Task myTask {get;set;}
    public Event myAppointment {get;set;}
    public Task taskForEvent {get;set;}
    public Boolean eventError {get;set;}
    public Boolean eventNoContact {get;set;}
    public String taskSelectedUser {get;set;}
    public User taskUserToAssign;
    public String taskSelectedUserName {get;set;}
    public Boolean taskEmailtoUser {get;set;}
    public String alertMessage {get;set;}
    
    public Life_event__c tmp {get;set;} //appointment
    public Life_event__c tmp2 {get;set;} //reminder
    public Life_event__c tmp3 {get;set;} //reminder for appointment
    
    public String inTime {get;set;}
    public String outTime {get;set;}
    public String taskTime {get;set;}
    public String taskAppointmentTime {get;set;}
    
    // UNCLAIMED DEATH BENEFITS - NTORREGGIANI - START
    public List<String> buttons {get;set;}
    public String buttonValue {get;set;}
    public boolean displayPopupInformative {get;set;}
    public boolean displayInformativePromemoria {get;set;}
    public String informativeMessage {get;set;}
    public Map<String, String> alertButton {get;set;}
    public Map<String, String> actionValues {get;set;}
    // UNCLAIMED DEATH BENEFITS - NTORREGGIANI - END
    
    public void createReminder() {
        
        //The object Life_event__c is used only because is the smallest object that contain a date.
        tmp2 = new Life_event__c();
        tmp2.Effective_date__c = DateTime.now().date();
        
        myTask = new Task();
        
        myTask.Status = 'Open';
        myTask.Subject = 'Contatto';
        myTask.Type = 'Contact';
        myTask.Contact_Date__c = Date.today();
        myTask.Recordtypeid = taskGenericRTId;
        
        taskTime = setTime(taskTime);
        
        Datetime dt = setReminderDateTime(tmp2,taskTime);
        myTask.ReminderDateTime = dt;
        
        
        if(myCM != null){
            myTask.TECH_SourceId__c = validateId(myCM.Id);
            myTask.WhoId = myCM.ContactId;
            myTask.WhatId = validateId(CampaignId);
            myTask.OwnerId = validateId(userinfo.getUserId());
        }
    }
    
    public void createAppointment() {

        eventError = false;
        eventNoContact = false;
        taskSelectedUser = Userinfo.getUserId();
        
        //Appointment
        myAppointment = new Event();
        myAppointment.StartDateTime = DateTime.now();
        myAppointment.EndDateTime = myAppointment.StartDateTime.addHours(1);
        myAppointment.Luogo_appuntamento__c ='Presso cliente';
        
        //The object Life_event__c is used only because is the smallest object that contain a date.
        tmp = new Life_event__c();
        tmp.Effective_date__c = myAppointment.StartDateTime.date();
        tmp3 = new Life_event__c();
        tmp3.Effective_date__c = myAppointment.StartDateTime.date();
        
        // Reminder for the Appointment
        taskForEvent = new Task();
        taskForEvent.Status = 'Open';
        taskForEvent.Type = 'Contact';
        taskForEvent.Contact_Date__c = Date.today();
        taskForEvent.Recordtypeid = taskGenericRTId;
        
        if(myCM != null){
            taskForEvent.Subject = 'Appuntamento con '+myCM.Contact.Name;
            taskForEvent.WhoId = myCM.ContactId;
            taskForEvent.OwnerId = validateId(userinfo.getUserId());
            
            Address addr = myCM.Contact.Account.PersonMailingAddress;
            if(addr != null)
                myAppointment.Location = printAddress(addr);
            else myAppointment.Location ='';
            myAppointment.TECH_SourceId__c = validateId(myCM.Id);
            myAppointment.Subject = 'Appuntamento con '+myCM.Contact.Name;
            myAppointment.WhoId = myCM.ContactId;
        }
        
        InTime = setTime(InTime);
        
        taskAppointmentTime = InTime;

    }
    
    public void saveTC() {
        eventError = false; //BOVOLENTA_D & TORRREGGIANI_N 24122018 - Null pointer for informative campaigns fix
        if (marketingCamp||agencyCamp) {
            string cmStatus = myCM.Status;
            
            if (cmStatus == 'Interessato') {
                
                /* SERGER_T: This part is not indicated in the approved User Stories of Ottimizzazione Campagna
                if (myTask.Way_of_contact__c != null && myTask.Way_of_contact__c != '')
                    myTask.Subject = myTask.Subject+' tramite ' + myTask.Way_of_contact__c+'';
				*/
                if (createAppointment) {
                    if (taskSelectedUser == '' || taskSelectedUser == null) {
                        eventError = true;
                        taskErrorMessage = 'Inserisci l\'assegnatario dell\'appuntamento';
                    }
                    else if (myAppointment.StartDateTime == null || myAppointment.EndDateTime == null) {
                        eventError = true;
                        taskErrorMessage = 'Inserisci le date dell\'appuntamento';
                    }
                    else if (Integer.valueOf(inTime.split(':').get(0)) > Integer.valueOf(outTime.split(':').get(0))) {
                        eventError = true;
                        taskErrorMessage = 'L\'orario di inizio appuntamento è posteriore a quello di fine';
                    }
                    else if ((Integer.valueOf(inTime.split(':').get(0)) == Integer.valueOf(outTime.split(':').get(0))) && (Integer.valueOf(inTime.split(':').get(1)) > Integer.valueOf(outTime.split(':').get(1)))) {
                        eventError = true;
                        taskErrorMessage = 'L\'orario di inizio appuntamento è posteriore a quello di fine';
                    }
                    else {
                        taskUserToAssign = [SELECT Id, FirstName, LastName, Nodes__c, Agency_Code__c, TECH_Email__c FROM User WHERE Id =: taskSelectedUser ]; // NOPMD  Fix CRUD violation
                        
                        if (myCM.Nodes__c != null) {
                            if (!RecordVisibilityCheck(myCM.Nodes__c,taskUserToAssign.Nodes__c)) {
                                eventError = true;
                                system.debug('***Errore4'); //Antonino Massarotti 18/11
                                taskErrorMessage = 'Attenzione! L\'utente assegnatario non ha visibilità sul cliente selezionato';
                            }
                        }
                        else {
                            system.debug('***Errore3'); //Antonino Massarotti 18/11
                            eventError = true;
                            taskErrorMessage = 'Attenzione! L\'utente assegnatario non ha visibilità sul cliente selezionato';
                        }
                    }
                }
                
                if (!eventError) {
                
                    if (createOpportunity) {
                        
                        //Crea Opportunità
                        Opportunity opp = new Opportunity();
                        opp.Name = 'OPP-XXXXXXX';
                        opp.StageName = 'Open';
                        opp.CloseDate = Date.Today().addMonths(1);
                        opp.CampaignId = myCM.CampaignId;
                        opp.AccountId = myCM.Contact.AccountId;
                        string ASA = CurrentCampaign.ASA__c;
                        if(!(String.isBlank(ASA)))
                            opp.Codice_ASA__c = ASA;
                        
                        RecordType rtOpp = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Opportunita_AXA_Assicurazioni' ]; // NOPMD  Fix CRUD violation
                        opp.RecordTypeId = rtOpp.Id;
                        taskUserToAssign = [SELECT Id, FirstName, LastName, Nodes__c, Agency_Code__c, TECH_Email__c FROM User WHERE Id =: taskSelectedUser ]; // NOPMD  Fix CRUD violation
                        taskSelectedUserName = taskUserToAssign.FirstName + ' ' + taskUserToAssign.LastName;
                        
                        if (myCM.Nodes__c != null) {
                            if (RecordVisibilityCheck(myCM.Nodes__c,taskUserToAssign.Nodes__c)) {
                                system.debug('VISIBILITY OK');
                                myCM.Owner__c = taskSelectedUser;
                                myAppointment.OwnerId = taskSelectedUser;
                                opp.OwnerId = taskSelectedUser;
                            }
                            else {
                                system.debug('***Errore2'); //Antonino Massarotti 18/11
                                eventError = true;
                                taskErrorMessage = 'Attenzione! L\'utente assegnatario non ha visibilità sul cliente selezionato';
                            }
                        }
                        else {
                            system.debug('***Errore1'); //Antonino Massarotti 18/11
                            eventError = true;
                            taskErrorMessage = 'Attenzione! L\'utente assegnatario non ha visibilità sul cliente selezionato';
                        }
                        
                        insert opp;
                        
                        myCM.Campaign_member_related_opportunity__c = opp.id;
                        
                        if (createAppointment == true) {
                            
                            taskForEvent.WhatId = opp.id;
                            myAppointment.WhatId = opp.Id;   
                            setDateTimeapp();
                            insert myAppointment; // NOPMD  Fix CRUD violation
                            System.debug(' ==> Event inserted');
                            
                            if (taskForEvent.IsReminderSet == true) {
                                taskForEvent.TECH_EventId__c = myAppointment.id;
                                taskForEvent.Interest_Rate__c= 'Interessato';
                                
                                Datetime dt = setReminderDateTime(tmp3,taskAppointmentTime);
                                taskForEvent.ReminderDateTime = dt;
                                taskForEvent.ActivityDate = date.newinstance(dt.year(), dt.month(), dt.day());
                                
                                insert taskForEvent; // NOPMD  Fix CRUD violation
                                System.debug(' ==> Task inserted');
                            }
                            
                            if (taskEmailtoUser) {
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                List<EmailTemplate> template = new List<EmailTemplate>();
                                template = [SELECT Id, Subject, HtmlValue, Body from EmailTemplate where developername = : 'Event_New_assigned_event' ];  // NOPMD  Fix CRUD violation                          
                                myAppointment =[SELECT Id, Subject, Owner.FirstName, Type, Description, StartDateTime, EndDateTime, Location, IsReminderSet, ReminderDateTime,Luogo_appuntamento__c  FROM Event WHERE Id =: myAppointment.id ]; // NOPMD  Fix CRUD violation
                                system.debug('+++++++thisemailtemplate'+template.get(0));
                                mail.setUseSignature(false);
                                map<String,String> mapFieldToValue = new Map<String,String>();
                                mapFieldToValue.put('{!Event.Owner}',myAppointment.Owner.FirstName);
                                mapFieldToValue.put('{!Event.StartDateTime}',String.valueOf(myAppointment.StartDateTime));
                                mapFieldToValue.put('{!Event.EndDateTime}',String.valueOf(myAppointment.EndDateTime));
                                mapFieldToValue.put('{!Event.Who}',String.valueOf(myCM.contact.Name));
                                mapFieldToValue.put('{!Event.What}',String.valueOf(myAppointment.Subject));
                                if (String.isNotEmpty(myAppointment.Description))
                                    mapFieldToValue.put('{!Event.Description}',String.valueOf(myAppointment.Description));
                                else
                                    mapFieldToValue.put('{!Event.Description}','--Nessuna descrizione tracciata--');
                                
                                if ((myAppointment.Location != null) && (myAppointment.Location != ''))
                                    mapFieldToValue.put('{!Event.Location}',myAppointment.Location);
                                
                                mapFieldToValue.put('{!Event.Link}','http://'+System.URL.getSalesforceBaseUrl().getHost()+'/'+myAppointment.Id);
                                system.debug('+++++++mapFieldToValue '+mapFieldToValue);
                                system.debug('+++++++template.get(0)'+template.get(0));
                                mail = UtilityClass.prepareEmailTemplate(template.get(0), mapFieldToValue );
                                mail.setToAddresses( new String[] { taskUserToAssign.TECH_Email__c } );
                                system.debug('+++++++++mail prepared'+mail);
                                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                            }
                            
                        }
                    }
                }
            }
            
            else if(cmStatus == 'Da ricontattare') {
                
                if (myTask.IsReminderSet == true) {
                    System.debug(' ==> Task is set');
                    boolean validDate = validateDate(tmp2.Effective_date__c);
                    if (!validDate){
                        eventError = true;
                    }
                    
                    Datetime dt = setReminderDateTime(tmp2,taskTime);
                    myTask.ReminderDateTime = dt;
                    myTask.ActivityDate = date.newinstance(dt.year(), dt.month(), dt.day());
                    
                    if (myTask.ReminderDateTime == null){
                        eventError = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Inserisci la data del promemoria'));
                    }
                }
            }
            
            else if(cmStatus == 'Non interessato') {
                //myCM.Not_Interested_Reason__c = notInterestedReason;
                myTask.Reason__c = myCM.Not_Interested_Reason__c; //BOVOLENTA_D Contact History improvement + FIX
            }
            
            if (!eventError) {
                insert myTask;
                update myCM;
            }
        }

        else if(informativeCamp) {
                        
            if (myTask.IsReminderSet == true) {
                boolean validDate = validateDate(tmp2.Effective_date__c);
                if (!validDate) {
                    eventError = true;
                }
                Datetime dt = setReminderDateTime(tmp2,taskTime);
                myTask.ReminderDateTime = dt;
                myTask.ActivityDate = date.newinstance(dt.year(), dt.month(), dt.day());
                
                if (myTask.ReminderDateTime == null) {
                    eventError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Inserisci la data del promemoria'));
                }
                
                else
                    insert myTask;
            }
            
            update myCM;
            
            closePopupInformative();
        }

        if (!eventError)
            closeTC();
    }
    
    static public String validateId(String Idparam) {
        try{
            Id testId = Idparam;
            return testId;
        }
        catch (Exception e){
            return null;
        }
    }
    static public String printAddress(Address x) {
        String res = '';
        if(x.getStreet() != null) 
            res = res + x.getStreet()+ ', ';
        if(x.getPostalCode() != null) 
            res = res + x.getPostalCode() + ' ';
        if(x.getCity() != null) 
            res = res + x.getCity();
        return res;
    }
    public void changeIndirizzo() {
        if (myAppointment.Luogo_appuntamento__c != null && myAppointment.Luogo_appuntamento__c == 'Presso cliente'){
            Address addr = myCM.Contact.Account.PersonMailingAddress; 
            if(addr != null)
                myAppointment.Location = printAddress(addr);
        }
        else myAppointment.Location = '';
    }
    public List<SelectOption> calculateTimes() {
        
        List<SelectOption> options = new List<SelectOption>();
        Time myTime = Time.newInstance(0, 0, 0, 0);        
        String stringTime= ''+myTime;
        stringTime = stringTime.substring(0,5);
        options.add(new SelectOption(stringTime ,stringTime ));
        System.debug('*********'+stringTime );
        for (Integer i = 0; i < 95; i++) {
            myTime=myTime.addMinutes(15);
            stringTime= ''+myTime;
            stringTime = stringTime.substring(0,5);
            System.debug('*******'+stringTime );
            options.add(new SelectOption(stringTime ,stringTime));
        }
        
        System.debug('**************options'+options );
        return options;
    }
    public string setTime(string myTime) {
        
        Time  timeNow = DateTime.now().time();
        Integer hours = timeNow.hour();
        Integer minutes = timeNow.minute();
        if ((minutes>0) && (minutes<16))
            minutes = 15; 
        else if ((minutes>15) && (minutes<31))
            minutes = 30;
        else if ((minutes>30) && (minutes<46))
            minutes = 45;
        else if (minutes>45){
            minutes = 0;
            hours++;
        }
        
        String strMinutes = '' + minutes;
        String strHours = '' + hours;
        if (strMinutes.length()<2)
            strMinutes = strMinutes + '0';
        if (strHours.length()<2)
            strHours = '0' + strHours;
        
        myTime = strhours + ':' + strminutes;
        
        hours++;
        strHours = '' + hours;
        if (strHours.length()<2)
            strHours = '0'+strHours;
        OutTime = strhours+':'+strminutes;
        
        return myTime;
    }
    public void updateEventEndTime() {
        Integer startHour = Integer.valueOf(inTime.split(':').get(0));
        Integer startMinute = Integer.valueOf(inTime.split(':').get(1));
        Integer endHour = startHour + 1;
        String endHourStr = endHour + '';
        String startMinuteStr = startMinute + '';
        if (endHourStr.length() < 2)
            endHourStr = '0' + endHourStr;
        if (startMinuteStr.length() < 2)
            startMinuteStr = startMinuteStr + '0';
        OutTime = endHourStr + ':' + startMinuteStr;
    }
    private boolean validateDate (Date inDate) {
        try{
            Date outDate = inDate;
            return true;
        }
        catch (Exception e){
            return false;
        }
    }
    public Datetime setReminderDateTime (Life_event__c LE, String theTime) {
        SYSTEM.DEBUG('***********LE '+LE);  
        SYSTEM.DEBUG('***********theTime '+theTime);    
        Datetime reminderDT = DateTime.newInstance(LE.Effective_date__c.year(), LE.Effective_date__c.month(), LE.Effective_date__c.day(),
                                                   Integer.valueOf(theTime.split(':').get(0)), Integer.valueOf(theTime.split(':').get(1)), 0);
        SYSTEM.DEBUG('+++++++++++++++++reminderDT '+reminderDT);                                            
        return reminderDT;
    }
    public boolean RecordVisibilityCheck(String RecordNodesString, String UserNodeString) {
        system.debug(LoggingLevel.ERROR, '********RecordNodesString: '+RecordNodesString+' UserNodeString: '+UserNodeString);
        set<String> RecordNodes = new set<String>();
        set<String> UserNodes = new set<String>();
        RecordNodes.addAll(RecordNodesString.tolowercase().split(';'));
        UserNodes.addAll(UserNodeString.tolowercase().remove('dif_').split(';'));
        system.debug('+++++++RecordNodes'+RecordNodes);
        system.debug('+++++++RecordNodes'+UserNodes);
        boolean usercontainsNodes = RecordNodes.removeAll(UserNodes); //returns true if removing the set changes the original set
        return usercontainsNodes;
    }
    public void setDateTimeapp() {
        myAppointment.StartDateTime = DateTime.newInstance(tmp.Effective_date__c.year(), tmp.Effective_date__c.month(), tmp.Effective_date__c.day(),
                                                  Integer.valueOf(inTime.split(':').get(0)), Integer.valueOf(inTime.split(':').get(1)), 0);
        myAppointment.EndDateTime = DateTime.newInstance(tmp.Effective_date__c.year(), tmp.Effective_date__c.month(), tmp.Effective_date__c.day(),
                                                Integer.valueOf(outTime.split(':').get(0)), Integer.valueOf(outTime.split(':').get(1)), 0);                                  
    }
    public List<SelectOption> getInTimesAppointment() {
        List<SelectOption> options = calculateTimes();
        return options;
    }
    public List<SelectOption> getOutTimesAppointment() {
        List<SelectOption> options = calculateTimes();
        return options;
    }
    public List<SelectOption> getTimesTaskEvent() {
        List<SelectOption> options = calculateTimes();
        return options;
    }
    public List<SelectOption> getTimesTask() {
        List<SelectOption> options = calculateTimes();
        return options;
    }
    public List<SelectOption> getTaskAssignmentUser() { 
        
        List<SelectOption> options = new List<SelectOption>();
        // options.add(new SelectOption('','-- Seleziona Utente --'));
        
        User userRun = [SELECT Id, Name, Nodes__c, Agency_Code__c FROM User WHERE  Id =: Userinfo.getUserId() ]; // NOPMD  Fix CRUD violation
        options.add(new SelectOption(userRun.Id,userRun.Name));
        List<User> usrList = [SELECT Id, Name FROM User WHERE  Agency_Code__c =: userRun.Agency_Code__c ORDER BY Name ASC]; // NOPMD  Fix CRUD violation
        
        for (User usr : usrList) { 
            if (usr.Id != userRun.id)
                options.add(new SelectOption(usr.Id,usr.Name));
        }
        
        return options;
    }
    
    //UNCLAIMED DEATH BENEFITS - NTORREGGIANI - START
    public List<String> getInformativeCampaignButtons() {
        List<String> ret = (''+currentCampaign.Contact_Value__c).split(';');
        return ret;
    }
    public Map<String, String> getInformativeCampaignAlerts() {
        List<String> alerts = (''+currentCampaign.Contact_Alert__c).split(';');
        Map<String, String> ret = new Map<String, String>();
        
        Integer i = 0;
        for(String alrt : alerts){
            ret.put(buttons.get(i), alrt);
            i++;
        }
        
        
        return ret;
    }
    public Map<String, String> getInformativeCampaignActionValues() {
        
        Map<String, String> ret = new Map<String, String>();
        
        if (currentCampaign.Action__c != 'Nessuna action') {
            
            Informative_Campaign__mdt infoCampMdt = [SELECT Action_Values__c // NOPMD  Fix CRUD violation
                                                     FROM Informative_Campaign__mdt 
                                                     WHERE Label =: currentCampaign.Action__c
                                                     LIMIT 1];
            
            List<String> actions = (''+infoCampMdt.Action_Values__c).split(';');  
            
            Integer i = 0;
            for(String action : actions){
                ret.put(buttons.get(i), action);
                i++;
            }
            
        }
        
        
        return ret;
    }
    public void informativaClick() {
        
        //informativeMessage = 'Lavorazione campagna effettuata con successo';
        informativeMessage = 'Confermi la chiusura campagna con stato <b>' + buttonValue.toLowerCase()  + '</b>?';

        String alert = alertButton.get(buttonValue);
        if(alert != null && alert != ''){
            informativeMessage = informativeMessage + '<br/>' + alert;
        }
        
        myCM.Informative_Contact_Outcome__c = '' + buttonValue;
        myCM.Status = 'Lavorato';
        
        displayTCinformative_p1 = false;
        displayTCinformative_p2 = true;
        displayInformativePromemoria = false;
        
    }
    public void selectEsitoDiServizio() {
        
        myCM.Status = '' + buttonValue;
        
        
        informativeMessage = 'Hai selezionato <b>' + buttonValue.toLowerCase() + '</b>. <br/> Ricordati che per completare la lavorazione della campagna è necessario selezionare un esito di chiusura campagna.';
        displayTCinformative_p1 = false;
        displayTCinformative_p2 = true;
        displayInformativePromemoria = true;
    }
    public void closePopupInformative() {

        if (!actionValues.isEmpty()) {
            
            Account usr = myCM.Contact.Account;

            switch on currentCampaign.Action__c {
                when 'Tracciamento su Account vivo/morto/x' {
                    usr.Existence_in_life_for_IVASS__c = ''+actionValues.get(buttonValue);
                }
                when else {
                    System.debug('Errore nella gestione della action');
                }
            }

            update usr;

        }
        displayPopupInformative = false;
    }
    //UNCLAIMED DEATH BENEFITS - NTORREGGIANI - END
    
    
    // SERGER_T: OTTIMIZZAZIONE CAMPAGNA - END
}
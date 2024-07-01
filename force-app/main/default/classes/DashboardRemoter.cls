public class DashboardRemoter {
    //Only these profiles have access to the Page
    // AAI - Vendite Avanzato
    // AAI - Vendite Base
    // AAI - Distribuzione  Avanzato
    // AAI - Dipartimento Avanzato
    
    //Add to this set to show all users of an agency
    static final set<String> ProfilesThatCanSeeAllAgencyUsers = new set<String>{'AAI - Vendite Avanzato','System Administrator','Amministratore del sistema','AAI - Distribuzione Avanzato','AAI - Dipartimento Avanzato'};
    
    //Add to this set to show all Manager
    static final set<String> ProfilesThatCanSeeAllManagers = new set<String>{'System Administrator','Amministratore del sistema','AAI - Distribuzione Avanzato'};
    
    @RemoteAction @ReadOnly
    public static PageDetails retrievePlotPoints(String AreaManager,String SalesManager,String Agency,String UserId,String Anno,String Mese,String Settimana,String Focus, String Type) {
        //Given the inputs of the page returns the points for the plot and the options for the focus
        //The focus input is not used, for general purposes
        
        //check input
        system.debug('++++INPUT'+ AreaManager+'---'+SalesManager+'---'+Agency+'---'+UserId+'---'+Anno+'---'+Mese+'---'+Settimana+'---'+Focus+'---'+Type);
        //Consider adding extra check here before actual query. the filters provided should already be appropriate
        String Querytorun = 'SELECT '+
        'Sum(Campaign_contacts__c) CC ,'+//CC=CampaignContacts
        'Sum(Campaign_Opportunities__c) CO ,'+//CO=CampaignOpp
        'Sum(Campaign_Opportunities_Won__c) COW,'+//COW=CampaignOppWon
        'Sum(Client_Opportunities__c) CLO, '+//CLO=CLientOpp
        'Sum(Client_Opportunities_Won__c) CLOW,'+//CLOW=CLientOppwon
        'Sum(Lead_Contacts__c) LC,'+//LC=LeadContact
        'Sum(Lead_Opportunities__c) LO ,'+//LO=LeadOpp
        'Sum(Lead_Opportunities_Won__c) LOW,'+//LOW=LeadOppWon
        'TimeRef__c, Week__c '+
        'FROM Dashboard_Row__c';
        
        string grouping= ' GROUP BY TimeRef__c, Week__c ';
        
        string Filters = ' WHERE '+
        'Year__c>=\''+Anno+'\' AND '+
        'Month__c>=\''+Mese+'\'';
        
        if (AreaManager !='Tutti') Filters = Filters + ' AND Area_Manager__c=\''+AreaManager+'\' ';
        if (SalesManager !='Tutti') Filters = Filters + ' AND (Sales_Manager__c=\''+SalesManager+'\' OR Welfare_Manager__c=\''+SalesManager+'\') ';


        
        
        if (Settimana!='null' && (!String.isblank(Settimana))) {
            Filters= Filters + ' AND TimeRef__c>=\''+Settimana+'\'';
        }
        
        if (Agency!='Tutte') {
            Filters = Filters+ ' AND Agenzia__c=\''+Agency+'\'';
        }
        
        
        if (UserId!='Tutti' && UserId!='null') {//Selected a single user to monitor
            Filters = Filters+ ' AND User__c=\''+UserId+'\'';
        }
        
        string orderby = ' ORDER BY TimeRef__c ASC LIMIT 12';//Important the Limit 12 to get only the 12 points
        system.debug('++++running query-->'+Querytorun+Filters+grouping+orderby);
        
        List<AggregateResult> theAggResults = database.Query(Querytorun+Filters+grouping+orderby);
        List<PlotItem> datapoints = new List<PlotItem>();
        List<String> FocusOptions = new List<String>();
        List<String> FocusOptionsId = new List<String>();

        //running query result to defne plot points
        for (AggregateResult agr : theAggResults) {
            PlotItem thispoint = new PlotItem();
            thispoint.x = ''+agr.get('TimeRef__c');
            FocusOptionsId.add(thispoint.x);
            FocusOptions.add(''+agr.get('Week__c'));

            String scopeString = '';
            if (Type=='' || Type=='Campaign') scopeString = 'C';
            if (Type=='Lead') scopeString='L';
            if(Type=='Client') scopeString = 'CL';

            if(scopeString!='CL') thispoint.Contatti=''+agr.get(scopeString+'C');
            thispoint.Opp=''+agr.get(scopeString+'O');
            thispoint.Vinte=''+agr.get(scopeString+'OW');
            
            datapoints.add(thispoint);
        }
        
        
        //Returning the whole structure
        //First the datapoints
        PageDetails theDetails = new PageDetails();
        theDetails.Data = New PageData();
        theDetails.Data.PlotPoints = datapoints;
        
        //And the picklist option for the week
        theDetails.FocusOptions.addAll(FocusOptions);
        theDetails.FocusOptionsId.addAll(FocusOptionsId);

        return theDetails;
    }
    
    @RemoteAction @ReadOnly
    public static PageDetails retrieveTableRows(String AreaManager,String SalesManager,String Agency,String UserId,String Anno,String Mese,String Settimana,String Focus, String Type) {
        //Given the inputs of the page returns the rows for the tables (both list and KPI)
        //Remeber the tables are focussed on on selected week
        
        //check input
        system.debug('++++INPUT'+ AreaManager+'---'+SalesManager+'---'+Agency+'---'+UserId+'---'+Anno+'---'+Mese+'---'+Settimana+'---'+Focus+'---'+Type);
        //Consider adding extra check here before actual query. the filters provided should already be appropriate
        String Querytorun = 'SELECT Area_Manager__c, Sales_Manager__c,Welfare_Manager__c, Agenzia__c, '+
        'Sum(Campaign_contacts__c) CC ,'+
        'Sum(Campaign_Opportunities__c) CO ,'+
        'Sum(Campaign_Opportunities_Curr__c) COC ,'+
        'Sum(Campaign_Opportunities_Past__c) COP ,'+
        'Sum(Campaign_Opportunities_Won__c) COW,'+
        'Sum(Campaign_Opportunities_Won_Curr__c) COWC,'+
        'Sum(Campaign_Opportunities_Won_Past__c) COWP,'+
        'Sum(Client_Opportunities__c) CLO, '+
        'Sum(Client_Opportunities_Curr__c) CLOC, '+
        'Sum(Client_Opportunities_Past__c) CLOP, '+
        'Sum(Client_Opportunities_Won__c) CLOW,'+
        'Sum(Client_Opportunities_Won_Curr__c) CLOWC,'+
        'Sum(Client_Opportunities_Won_Past__c) CLOWP,'+
        'Sum(Lead_Contacts__c) LC,'+
        'Sum(Lead_Opportunities__c) LO ,'+
        'Sum(Lead_Opportunities_Curr__c) LOC ,'+
        'Sum(Lead_Opportunities_Past__c) LOP ,'+
        'Sum(Lead_Opportunities_Won__c) LOW, '+
        'Sum(Lead_Opportunities_Won_Curr__c) LOWC, '+
        'Sum(Lead_Opportunities_Won_Past__c) LOWP ';
        //Cannot use average as it is done by tablerow record
        // 'AVG(Campaign_contacts__c) AVG_CC ,'+
        // 'AVG(Campaign_Opportunities__c) AVG_CO ,'+
        // 'AVG(Campaign_Opportunities_Won__c) AVG_COW,'+
        // 'AVG(Client_Opportunities__c) AVG_CLO, '+
        // 'AVG(Client_Opportunities_Won__c) AVG_CLOW,'+
        // 'AVG(Lead_Contacts__c) AVG_LC,'+
        // 'AVG(Lead_Opportunities__c) AVG_LO ,'+
        // 'AVG(Lead_Opportunities_Won__c) AVG_LOW';    
        
        
        string Filters = ' WHERE ';
        // 'Area_Manager__c=\''+AreaManager+'\' AND '+
        // 'Sales_Manager__c=\''+SalesManager+'\' AND ';
        
        if (AreaManager !='Tutti') Filters = Filters + ' Area_Manager__c=\''+AreaManager+'\' AND ';
        if (SalesManager !='Tutti') Filters = Filters + ' (Sales_Manager__c=\''+SalesManager+'\' OR Welfare_Manager__c=\''+SalesManager+'\') AND ';

        
        if (Focus=='null' || Focus =='') {
            Filters = Filters + ' TimeRef__c=\''+Settimana+'\''; 
        } else {
            Filters = Filters + ' TimeRef__c=\''+Focus+'\''; //-->Data regarding selected Week

        }
        string filterforcounting = Filters;//this extra string is necessary otherwise i count only the selected users
        
        string grouping= ' GROUP BY Area_Manager__c, Sales_Manager__c, Welfare_Manager__c, Agenzia__c';
        
        if (Agency!='Tutte') {
            // If the agency is selected must add a filter
            Filters = Filters+ ' AND Agenzia__c=\''+Agency+'\'';
            //And group by User
            grouping = grouping + ', User__c';
            QueryToRun = Querytorun+', User__c';
            if (UserId!='Tutti') {//Selected a single user to monitor
                Filters = Filters+ ' AND User__c=\''+UserId+'\'';
            } 
        } else {//Looking at grouped agencies
            //no more grouping required as the grouped agency view is the highest one and already set
        }
        
        Querytorun = Querytorun + ' FROM Dashboard_Row__c ';

        string orderby = ' ORDER BY Agenzia__c';
        system.debug('++++running query-->'+Querytorun+Filters+grouping+orderby);
        List<AggregateResult> theAggResults = database.Query(Querytorun+Filters+grouping+orderby);
        
        //Running a query to count users based on the record stored, not on agencies
        //there may be record of past users, not active anymore
        
        string queryToCountUsers = 'SELECT User__c, Agenzia__c FROM Dashboard_Row__c '+ filterforcounting + ' GROUP BY Agenzia__c, User__c';
        List<AggregateResult> theUserAgg = database.Query(queryToCountUsers);
        Map<String, Integer> countUserByAgency = new Map<String,Integer>();
        for (AggregateResult a : theUserAgg) {
            string currentAgency = ''+a.get('Agenzia__c');
            system.debug('+++themap'+countUserByAgency);
            system.debug('+++theAgency'+currentAgency);
            if (countUserByAgency.keyset().contains(currentAgency)) {
                integer currentcount = countUserByAgency.get(currentAgency);
                system.debug('++++currentcount'+currentcount);
                countUserByAgency.put(currentAgency,currentcount+1);
            } else {
                countUserByAgency.put(currentAgency,1);
            }
        }

        List<ResultListItem> theTablerows = new List<ResultListItem>();
        
        //Calculating AVG and AggregatedKPI
        Integer TOT_Contatti = 0;
        Integer TOT_Opp = 0;
        Integer TOT_Opp_c = 0;
        Integer TOT_Opp_P = 0;
        Integer TOT_OppWon = 0;
        Integer TOT_OppWon_C = 0;
        Integer TOT_OppWon_P = 0;
        Integer TOT_Users = 0;
        
        
        for (AggregateResult agr : theAggResults) {
            
            ResultListItem thisRow = new ResultListItem();
            thisRow.AreaManager=''+agr.get('Area_Manager__c');
            thisRow.SalesManager=''+agr.get('Sales_Manager__c')+'/'+agr.get('Welfare_Manager__c');
            thisRow.Agenzia=''+agr.get('Agenzia__c');
            
            //Must check if it was grouped by users or not
            string theUser='';
            if (grouping.contains('User__c')) {
                string theUserId=''+agr.get('User__c');
                
                theUser = [SELECT Name FROM User where Id=:theUserId Limit 1].Name;
                thisRow.Utenti = theUser;
            } else { 
                thisRow.Utenti = countUserByAgency.get(thisRow.Agenzia)+'';
            }
            
            String scopeString = '';
            if (Type=='' || Type=='Campaign') scopeString = 'C';
            if (Type=='Lead') scopeString='L';
            if(Type=='Client') scopeString = 'CL';
            
            if(scopeString!='CL') {
                Integer Contatti = Integer.ValueOf(''+agr.get(scopeString+'C'));
                thisRow.Contatti=Contatti+'';
                TOT_Contatti = TOT_Contatti + Contatti;
            } else {
                thisRow.Contatti='N.D.';
            }
            
            Integer OppLavorate = Integer.ValueOf(''+agr.get(scopeString+'O'));
            TOT_Opp = TOT_Opp + OppLavorate;
            Integer OppLavorate_thisW =  Integer.ValueOf(''+agr.get(scopeString+'OC'));
            Integer OppLavorate_prevW = Integer.ValueOf(''+agr.get(scopeString+'OP'));
            thisRow.OppLavorate=''+OppLavorate+' ('+OppLavorate_thisW+'|'+OppLavorate_prevW+')';

            
            Integer OppVinte = Integer.ValueOf(''+agr.get(scopeString+'OW'));
            thisRow.OppVinte=''+OppVinte;
            TOT_OppWon = TOT_OppWon + OppVinte;
            Integer OppVinte_thisW = Integer.ValueOf(''+agr.get(scopeString+'OWC'));
            Integer OppVinte_prevW = Integer.ValueOf(''+agr.get(scopeString+'OWP'));
            thisRow.OppVinte=''+OppVinte+' ('+OppVinte_thisW+'|'+OppVinte_prevW+')';

            
            Integer NumberOfUsers = 0;
            if (theUser!='') {
                NumberOfUsers=1;
            } else {
                NumberOfUsers = Integer.ValueOf(thisRow.Utenti);
            }
            TOT_Users = TOT_Users + NumberOfUsers;

            if (Type!='Client') {
                Decimal Mediacontatti =(Decimal) (double.ValueOf(thisRow.Contatti)/double.ValueOf(NumberOfUsers));
                thisRow.MediaContatti=''+Mediacontatti.setScale(0);
            } else {
                thisRow.MediaContatti='N.D.';
            }
            
            Decimal MediaOppLavorate =(Decimal) (OppLavorate/double.ValueOf(NumberOfUsers));
            thisRow.MediaOppLavorate=''+MediaOppLavorate.setScale(0);
            
            Decimal MediaOppVinte =(Decimal) (OppVinte/double.ValueOf(NumberOfUsers));
            thisRow.MediaOppVinte=''+MediaOppVinte.setScale(0);

            if (Type!='Client') {
                if (thisRow.Contatti=='0'){
                    thisRow.RedContatti = 'N.D.'; 
                } else {
                    Decimal RedContatti =(Decimal) (OppLavorate/double.ValueOf(thisRow.Contatti))*100;
                    thisRow.RedContatti=''+RedContatti.setScale(0)+'%';
                    system.debug('++++Ration='+thisRow.RedContatti);
                }
            } else {
                thisRow.RedContatti='N.D.';
            }

            if (thisRow.OppLavorate=='0' || OppLavorate==0){
                thisRow.RedOpp = 'N.D.'; 
            } else {
                Decimal RedOpp =(Decimal) (double.ValueOf(OppVinte)/double.ValueOf(OppLavorate))*100;
                thisRow.RedOpp=''+RedOpp.setScale(0)+'%';
                system.debug('++++Ratio='+thisRow.RedOpp);
            }
            theTablerows.add(thisRow);
        }
        //Returning the whole structure
        //First the datapoints
        PageDetails theDetails = new PageDetails();
        
        if(theTablerows.size()==0){
            ResultListItem r = new ResultListItem();
            r.AreaManager      ='N.D.';
            r.SalesManager     ='N.D.';
            r.Agenzia          ='N.D.';
            r.Utenti           ='N.D.';
            r.Contatti         ='N.D.';
            r.OppLavorate      ='N.D.';
            r.OppVinte         ='N.D.';
            r.MediaContatti    ='N.D.';
            r.MediaOppLavorate ='N.D.';
            r.MediaOppVinte    ='N.D.';
            r.RedContatti      ='N.D.';
            r.RedOpp           ='N.D.';
            theTablerows.add(r);
            
        }
        
        theDetails.Data.tableRows.addAll(theTablerows);
        
        if (TOT_Users!=0) {
            theDetails.Data.KPI.MediaContatti =''+ TOT_Contatti/TOT_Users;
            theDetails.Data.KPI.MediaOppLavorate =''+ TOT_Opp/TOT_Users;
            theDetails.Data.KPI.MediaOppVinte =''+ TOT_OppWon/TOT_Users;
        } else {
            theDetails.Data.KPI.MediaContatti ='N.D.';
            theDetails.Data.KPI.MediaOppLavorate ='N.D.';
            theDetails.Data.KPI.MediaOppVinte ='N.D.';
        }
        
        if (TOT_Contatti!=0) {
            theDetails.Data.KPI.RedContatti =''+ 100*TOT_Opp/TOT_Contatti+'%';
        } else {
            theDetails.Data.KPI.RedContatti ='N.D.';
        }
        
        if (TOT_Opp!=0) {
            theDetails.Data.KPI.RedOpp =''+ 100*TOT_OppWon/TOT_Opp+'%';
        } else {
            theDetails.Data.KPI.RedOpp ='N.D.';
        }



        return theDetails;
    }


    
    @RemoteAction @ReadOnly
    public static PageDetails retrieveFilterOptions(string UserId, String Anno, string Mese, string AreaManager,String SalesManager,string Agenzia) {
        //Method used to initialise the page. To be tested for update of dependent picklist
        PageDetails result = new PageDetails();
        system.debug('++input--> UserId,  Anno,  Mese,  AreaManager, SalesManager, Agenzia==>'+ UserId+'##'+  Anno+'##'+ Mese+'##'+ AreaManager+'##'+ SalesManager+'##'+ Agenzia);
            
            //The first time i do not have any option for the time, so i set it to three months before now
            if (Anno=='null' || Mese=='null') {
                date d = Date.today().addMonths(-3);
                result.SelectedYear = String.ValueOf(d.year());
                string selmonth= '0'+String.ValueOf(d.month());
                result.SelectedMonth = selmonth.right(2);
                Anno=result.SelectedYear;
                Mese=result.SelectedMonth;
            } else {
                //just return the same selected months and year
                result.SelectedYear=Anno;
                result.SelectedMonth=Mese;
            }
            
            //Preparing the query on the snapshot to find the remaining filter options
            String Filters ='';

            if(String.isBlank(UserId)) {
                UserId = Userinfo.getUserId();
                result.isAdmin=false;//here i do not know yet if the current user is an admin
            } else {
                //Safety check. If the current user is not an admin return an error
                User AdminUser = [SELECT Id, Name, Profile.Name FROM User where Id=:Userinfo.getUserId()];
                if (AdminUser.Profile.Name =='System Administrator' || AdminUser.Profile.Name == 'Amministratore del sistema') {
                    system.debug('+++request by '+AdminUser);
                    result.isAdmin=true;
                    result.hasAccess =true;

                } else {
                    system.debug('SOMETHING IS WRONG.... not responding');
                    result.isAdmin=false;
                    result.hasAccess=false;
                    return result;
                }
            }
            
            User CurrentUser = new User();        
            CurrentUser=[SELECT Id,Name,FirstName,LastName, IsPortalEnabled,Profile.Name,UserRole.DeveloperName, Contact.Account.isPartner, Nodes__c, Agency_code__c, Contact.Account.RSAC_Description_Code__c, Contact.Account.RSA_Description_Code__c  FROM User  WHERE id=:Userid Limit 1];
            result.UserDetails = 'Name: '+CurrentUser.Name+' Profile: '+CurrentUser.Profile.Name+' Role: '+CurrentUser.UserRole.DeveloperName;
            if(CurrentUser.IsPortalEnabled) {//Agency User
                system.debug('++enetered portal user');
                result.hasAccess =true;//All agency users can access the page as the visibility of the page for agency users is set at ptrofie level
                string theAreaManager = CurrentUser.Contact.Account.RSAC_Description_Code__c;
                string theSalesManager = CurrentUser.Contact.Account.RSA_Description_Code__c;
                string theAgency = CurrentUser.Agency_code__c;
                
                result.AreaManagerOptions.add(theAreaManager);
                Filters = Filters + ' AND Area_Manager__c=\''+theAreaManager+'\'';
                
                result.SalesManagerOptions.add(theSalesManager);
                Filters = Filters + ' AND Sales_Manager__c=\''+theSalesManager+'\'';
                
                result.AgencyOptions.add(theAgency);
                Filters = Filters + ' AND Agenzia__c=\''+theAgency+'\'';
                
                Map<String,String> CollaboratorOptions = new Map<String, String>();
                CollaboratorOptions = retrieveCollaboratorOptions(theAgency, CurrentUser);

                result.CollaboratorOptions.addAll(CollaboratorOptions.values());
                result.CollaboratorOptionsId.addAll(CollaboratorOptions.keyset());
                
                if (result.CollaboratorOptionsId[0]!='Tutti') {//handling tutti Option
                    Filters = Filters + ' AND User__c=\''+result.CollaboratorOptionsId[0]+'\'';
                }
                
            } else {//InternalUser
                system.debug('++enetered Internal user');
                if (CurrentUser.Profile.Name=='System Administrator' || CurrentUser.Profile.Name=='Amministratore del sistema') {
                    result.isAdmin = true;
                    result.hasAccess = true;
                } else {
                    result.isAdmin = false || result.isAdmin;
                }
                
                //First Calculate all dependencies
                Map<String,Set<String>> AreaToSalesManagers = new Map<String, Set<String>>();
                AreaToSalesManagers = CalculateAreaToSalesManagers();
                system.debug('+++++AreaToSalesManagers'+AreaToSalesManagers);
                
                //Now decide what to show
                //First we get the list of managed agencies by the current user (we check the name of the user with what is written on the Agency acc)
                List<Account> ManagedAgencies = getManagedAgencies(CurrentUser);
                if (ProfilesThatCanSeeAllManagers.contains(CurrentUser.Profile.Name)) {//Show all options
                    result.AreaManagerOptions.add('Tutti');
                    result.AreaManagerOptions.addAll(AreaToSalesManagers.keyset());
                    result.hasAccess =true;
                } else {//Check if is a Manager and show only relevant options
                    //Must check if current user is a Manager (Area, Sales or Wlfare)
                    boolean isManager = false;
                    if (ManagedAgencies.size()>0){
                        result.hasAccess =true;
                        isManager = true;
                    } 
                    system.debug('++isManager'+isManager);
                    if(isManager) {
                        set<String> theAreaManagers = new set<String>();
                        //Returning Only the AreaManagers of its agencies
                        for (Account a : ManagedAgencies) {
                            theAreaManagers.add(a.RSAC_Description_Code__c);
                        }
                        result.AreaManagerOptions.addAll(theAreaManagers);
                        
                        //Before Proceeding I remove all AreaManager not allowed
                        for (string thisAreaManger : AreaToSalesManagers.keyset()) {
                            if (!theAreaManagers.contains(thisAreaManger)) {
                                AreaToSalesManagers.remove(thisAreaManger);
                            }
                        }
                    }
                    
                }

                Set<String> SMOpt = new Set<String>();
                if (AreaManager=='Tutti') {//At initialisation set to "Tutti"
                    //Retruning only the options for the first Area Manager
                    //Could have used retrieveSalesManager(AreaManager), but one more query.
                    SMOpt.add('Tutti');
                } else {//selected a specific AreaManager or initialise
                    //If I am the Area Manager I need the "Tutti" Option for the SalesManagers
                    boolean isAreaManager = false;
                    isAreaManager = CheckIsAreaManager(currentUser,ManagedAgencies);
                    if (isAreaManager || ProfilesThatCanSeeAllManagers.contains(CurrentUser.Profile.Name)) {
                        SMOpt.add('Tutti');
                        if (AreaManager=='' || AreaManager=='null') {
                            set<String> theOptions = AreaToSalesManagers.get(result.AreaManagerOptions[0]);
                            if (theOptions!=null) SMOpt.addAll(theOptions);
                        } else {
                            SMOpt.addAll(AreaToSalesManagers.get(AreaManager));
                        }
                    } else {//is not area Manager, must be SalesManager or Wlefare Manager
                    string TypeOfManager = CheckIsSalesManager(currentUser,ManagedAgencies);
                    system.debug('++++TypeOfManager'+TypeOfManager);
                        for (Account theAgency : ManagedAgencies) {
                            if (TypeOfManager=='SalesManager') SMOpt.add(theAgency.RSA_Description_Code__c);
                            if (TypeOfManager=='WelfareManager') SMOpt.add(theAgency.Department_Chief_Description_Code__c);
                        }
                    } 
                }
                result.SalesManagerOptions.addAll(SMOpt);
                
                //computing SalesManager
                List<String> theAgencies = new List<String>();
                if (SalesManager=='' || SalesManager=='null') {//initialise picklist
                    //Returning only the option for the first SalesManager
                    theAgencies = retrieveAgencyOptions(result.SalesManagerOptions[0], AreaManager);
                    result.AgencyOptions.addAll(theAgencies);
                } else {//if The SM is selected so must be the AM
                    if(SMOpt.contains(SalesManager)) {
                        theAgencies = retrieveAgencyOptions(SalesManager,AreaManager);
                        result.AgencyOptions.addAll(theAgencies);
                    } else {
                        //Returning only the option for the first SalesManager
                        theAgencies = retrieveAgencyOptions(result.SalesManagerOptions[0],AreaManager);
                        result.AgencyOptions.addAll(theAgencies);
                    }
                }

                //Computing available collaborators
                if (Agenzia=='' || Agenzia=='null') {
                    Map<String,String> CollaboratorOptions = new Map<String, String>();
                    CollaboratorOptions = retrieveCollaboratorOptions(result.AgencyOptions[0], CurrentUser);
                    result.CollaboratorOptions.addAll(CollaboratorOptions.values());
                    result.CollaboratorOptionsId.addAll(CollaboratorOptions.keyset());
                } else {
                    Set<String> Availableagenzie = new Set<String>();
                    Availableagenzie.addAll(result.AgencyOptions);
                    if (Availableagenzie.contains(Agenzia)) {
                        Map<String,String> CollaboratorOptions = new Map<String, String>();
                        CollaboratorOptions = retrieveCollaboratorOptions(Agenzia, CurrentUser);
                        result.CollaboratorOptions.addAll(CollaboratorOptions.values());
                        result.CollaboratorOptionsId.addAll(CollaboratorOptions.keyset());
                    } else {
                        Map<String,String> CollaboratorOptions = new Map<String, String>();
                        CollaboratorOptions = retrieveCollaboratorOptions(result.AgencyOptions[0], CurrentUser);
                        result.CollaboratorOptions.addAll(CollaboratorOptions.values());
                        result.CollaboratorOptionsId.addAll(CollaboratorOptions.keyset());
                    }
                }
            }
            
            //Now that we know we can run the query on the snapshot to find the available data and return the options for week available in that month
            String TimeFilters_Exact = ' WHERE Year__c=\''+Anno+'\' AND Month__c=\''+Mese+'\'';
            String TimeFilters_gt = ' WHERE Year__c>=\''+Anno+'\' AND Month__c>=\''+Mese+'\'';

            String QueryToRun = 'SELECT count(id), Week__c, TimeRef__c, Month__c FROM Dashboard_Row__c '+ TimeFilters_Exact + Filters  + ' GROUP BY Week__c, TimeRef__c,Month__c ORDER BY TimeRef__c ASC';
            
            system.debug('++++++++++++running the query'+ QueryToRun);
            List<AggregateResult> myRes=Database.query(QueryToRun);
            if (myRes.isEmpty()) {
                //run query with less limits
                String QueryToRun2 = 'SELECT count(id), Week__c, TimeRef__c, Month__c FROM Dashboard_Row__c '+ TimeFilters_gt + Filters  + ' GROUP BY Week__c, TimeRef__c,Month__c ORDER BY TimeRef__c ASC';
                myRes=Database.query(QueryToRun2);
            }
            
            Set<String> availableWeeks = new Set<String>();
            Set<String> availableWeeksId = new Set<String>();
            
            if (myRes.isEmpty()) {
                availableWeeks.add('-- Nessun Dato disponibile --');
                availableWeeksId.add('-- Nessun Dato disponibile --');
                // handle no options case
            } else {
                string startingMonth = myRes[0].get('Month__c')+'';
                for (AggregateResult  thisRes :myRes) {
                    string thisMonth = thisRes.get('Month__c')+'';
                    if (thisMonth!=startingMonth) {
                        break;
                    } else {
                        availableWeeks.add(''+thisRes.get('Week__c'));
                        availableWeeksId.add(''+thisRes.get('TimeRef__c'));
                        
                        result.SelectedMonth = ''+thisRes.get('Month__c');
                        
                    }
                }
            }
            
            result.WeekOptions.addAll(availableWeeks);
            result.WeekOptionsId.addAll(availableWeeksId);
            system.debug('++++result.hasAccess'+result.hasAccess);
            return result;
        }
        
        //Object returned to the client
        public class PageDetails {
            public boolean isAdmin {get;set;}
            public boolean hasAccess {get;set;}
            public List<String> AreaManagerOptions{get;set;}
            public List<String> SalesManagerOptions{get;set;}
            public List<String> AgencyOptions {get;set;}
            public String UserDetails {get;set;}//To display in the admin box
            public List<String> CollaboratorOptions {get;set;}
            public List<String> CollaboratorOptionsID {get;set;}
            public List<String> AnnoOptions {get;set;}
            public List<String> MonthOptionsName {get;set;}
            public List<String> MonthOptionsNum {get;set;}
            public string SelectedYear {get;set;}
            public string SelectedMonth {get;set;}
            public List<String> WeekOptions{get;set;}
            public List<String> WeekOptionsId{get;set;}
            public List<String> FocusOptions{get;set;}
            public List<String> FocusOptionsId{get;set;}
            public PageData Data {get;set;}//The object with the list of datapoints and the table rows

            //Custom constructor for initialisation of lists and defaults
            public PageDetails() {
                AreaManagerOptions = new List<String>();
                SalesManagerOptions = new List<String>();
                AgencyOptions = new List<String>();
                UserDetails = 'N.A.';
                CollaboratorOptions = new List<String>();
                CollaboratorOptionsId = new List<String>();
                WeekOptions = new List<String>();
                WeekOptionsId = new List<String>();
                FocusOptions = new List<String>();
                FocusOptionsId = new List<String>();
                Data = new PageData();

                AnnoOptions = new List<string>();
                Integer startingYear = integer.ValueOf('2016');
                DateTime dt = DateTime.now();
                integer lastYear = dt.year();
                
                for (integer i = startingYear; i<=lastYear; i++) {
                    AnnoOptions.add(String.ValueOf(i));
                }
                
                MonthOptionsName = new List<String>();
                MonthOptionsName.add('Gennaio');
                MonthOptionsName.add('Febbraio');
                MonthOptionsName.add('Marzo');
                MonthOptionsName.add('Aprile');
                MonthOptionsName.add('Maggio');
                MonthOptionsName.add('Giugno');
                MonthOptionsName.add('Luglio');
                MonthOptionsName.add('Agosto');
                MonthOptionsName.add('Settembre');
                MonthOptionsName.add('Ottobre');
                MonthOptionsName.add('Novembre');
                MonthOptionsName.add('Dicembre');
                
                MonthOptionsNum = new List<String>();
                for (integer m=1; m<13;m++) {
                    //Must be padded for correct sorting of strings
                    String monthsStringNum = '0'+String.ValueOf(m);
                    MonthOptionsNum.add(monthsStringNum.right(2));
                }
            }
        }
        
        //Object returned to the client to populate tables and plots
        public class PageData {
            public List<ResultListItem> tableRows {get;set;}    //Data for the table
            public KPI_Row KPI {get;set;}                       //Data for KPI ROW
            public List<PlotItem> PlotPoints {get;set;}         //Data to draw the plot
            // public String JsonPlotPoints {get;set;}
            
            //Constructor
            public PageData() {
                tableRows = new List<ResultListItem>();
                
                //FAKE DATA
                // for (Integer i = 1; i<10;i++) {
                // ResultListItem r = new ResultListItem();
                // r.AreaManager      ='AreaManager'+i;
                // r.SalesManager     ='SalesManager'+i;
                // r.Agenzia          ='Agenzia'+i;
                // r.Utenti           ='Utenti'+i;
                // r.Contatti         ='Contatti'+i;
                // r.OppLavorate      ='OppLavorate'+i;
                // r.OppVinte         ='OppVinte'+i;
                // r.MediaContatti    ='MediaContatti'+i;
                // r.MediaOppLavorate ='MediaOppLavorate'+i;
                // r.MediaOppVinte    ='MediaOppVinte'+i;
                // r.RedContatti      ='RedContatti'+i;
                // r.RedOpp           ='RedOpp'+i;
                // tableRows.add(r);
                // }
                
                KPI = new KPI_Row();
                // KPI.MediaContatti='1';
                // KPI.MediaOppLavorate='2';
                // KPI.MediaOppVinte='3';
                // KPI.RedContatti='4%';
                // KPI.RedOpp='5%';
                
                PlotPoints = new List<PlotItem>();
                // for (Integer i = 1; i<12;i++) {
                // PlotItem r = new PlotItem();
                // r.x      ='201608'+String.valueOf(i).leftPad(2).replace(' ','0');
                // r.Contatti     =3+i+'';
                // r.Opp          =2*i+'';
                // r.Vinte           =0.5+i+'';
                // PlotPoints.Add(r);
                // }
                // JsonPlotPoints = JSON.serialize(PlotPoints,false);
            }
        }

        //Auxiliary class to populate detail table
        public class ResultListItem {
            public String AreaManager {get;set;}
            public String SalesManager {get;set;}
            public String Agenzia {get;set;}
            public String Utenti {get;set;}
            public String Contatti {get;set;}
            public String OppLavorate {get;set;}
            public String OppVinte {get;set;}
            public String MediaContatti {get;set;}
            public String MediaOppLavorate {get;set;}
            public String MediaOppVinte {get;set;}
            public String RedContatti {get;set;}
            public String RedOpp {get;set;}
        }
        
        //Auxiliary class to populate KPI row
        public class KPI_Row {
            public String MediaContatti {get;set;}
            public String MediaOppLavorate {get;set;}
            public String MediaOppVinte {get;set;}
            public String RedContatti {get;set;}
            public String RedOpp {get;set;}
        }
        //Auxiliary class to populate graph
        public class PlotItem {
            public String x {get;set;}
            public String Contatti {get;set;}
            public String Opp {get;set;}
            public String Vinte {get;set;}        
        }

        
        ///////////////UTILITY METHODS /////////////////////
        public static Map<String, Set<String>> CalculateAreaToSalesManagers() {
            // RSAC=Area Manager
            //RSA=SalesManager
            // Department Chief Description/Code = welfare Manager
            Map<String, Set<String>> AreaToSalesManagers =new Map<String, Set<String>>();
            for (Account thisAgency :[SELECT Id,Department_Chief_Description_Code__c, RSAC_Description_Code__c, RSA_Description_Code__c FROM Account where Recordtype.DeveloperName='Agency' AND Active__c=true AND RSAC_Description_Code__c!='' AND RSA_Description_Code__c!='']){
                Set<String> currentSalesManager = AreaToSalesManagers.get(thisAgency.RSAC_Description_Code__c);
                if (currentSalesManager!=null && !currentSalesManager.isEmpty()) {
                    
                    currentSalesManager.add(thisAgency.RSA_Description_Code__c);
                    currentSalesManager.add(thisAgency.Department_Chief_Description_Code__c);
                    
                    AreaToSalesManagers.put(thisAgency.RSAC_Description_Code__c, currentSalesManager);
                } else {
                    currentSalesManager = new set<String>();
                    
                    currentSalesManager.add(thisAgency.RSA_Description_Code__c);
                    currentSalesManager.add(thisAgency.Department_Chief_Description_Code__c);

                    AreaToSalesManagers.put(thisAgency.RSAC_Description_Code__c,currentSalesManager);
                }
            }
            return AreaToSalesManagers;
        }
        public static boolean CheckIsAreaManager (user currentUser, List<Account> ManagedAgencies) {
            boolean isAreaManager = false;
            if (!ManagedAgencies.isempty()) {
                set<String> searchkeys = new set<String>();
                searchkeys.add(currentUser.FirstName+' '+currentUser.LastName);
                searchkeys.add(currentUser.LastName+' '+currentUser.FirstName);
                searchkeys.add(currentUser.LastName.tolowercase()+' '+currentUser.FirstName.tolowercase());
                searchkeys.add(currentUser.LastName.tolowercase()+' '+currentUser.FirstName.tolowercase());
                searchkeys.add(currentUser.LastName.toUppercase()+' '+currentUser.FirstName.toUppercase());
                searchkeys.add(currentUser.LastName.toUppercase()+' '+currentUser.FirstName.toUppercase());
                
                for(Account a : ManagedAgencies) {
                    if (searchkeys.contains(a.RSAC_Description_Code__c)) isAreaManager = true;
                }
                
            }
            return isAreaManager;
        }
        
        public static string CheckIsSalesManager (user currentUser, List<Account> ManagedAgencies) {
            string isSalesManager = 'fasle';
            if (!ManagedAgencies.isempty()) {
                set<String> searchkeys = new set<String>();
                searchkeys.add(currentUser.FirstName+' '+currentUser.LastName);
                searchkeys.add(currentUser.LastName+' '+currentUser.FirstName);
                searchkeys.add(currentUser.LastName.tolowercase()+' '+currentUser.FirstName.tolowercase());
                searchkeys.add(currentUser.LastName.tolowercase()+' '+currentUser.FirstName.tolowercase());
                searchkeys.add(currentUser.LastName.toUppercase()+' '+currentUser.FirstName.toUppercase());
                searchkeys.add(currentUser.LastName.toUppercase()+' '+currentUser.FirstName.toUppercase());
                
                for(Account a : ManagedAgencies) {
                    if (searchkeys.contains(a.RSA_Description_Code__c)) {
                        isSalesManager = 'SalesManager';
                        return isSalesManager;
                    }
                    if (searchkeys.contains(a.Department_Chief_Description_Code__c)) {
                        isSalesManager = 'WelfareManager';
                        return isSalesManager;
                    }
                }
                
            }
            return isSalesManager;
        }
        
        public static List<Account> getManagedAgencies(user currentUser) {
            set<String> searchkeys = new set<String>();
            searchkeys.add(currentUser.FirstName+' '+currentUser.LastName);
            searchkeys.add(currentUser.LastName+' '+currentUser.FirstName);
            searchkeys.add(currentUser.LastName.tolowercase()+' '+currentUser.FirstName.tolowercase());
            searchkeys.add(currentUser.LastName.tolowercase()+' '+currentUser.FirstName.tolowercase());
            searchkeys.add(currentUser.LastName.toUppercase()+' '+currentUser.FirstName.toUppercase());
            searchkeys.add(currentUser.LastName.toUppercase()+' '+currentUser.FirstName.toUppercase());

            
            List<Account> ManagedAgencies = new List<Account>();
            for(Account a : [SELECT Agency_Code__c,RSAC_Description_Code__c,RSA_Description_Code__c,Department_Chief_Description_Code__c FROM Account WHERE Recordtype.DeveloperName='Agency' AND Active__c = true AND isPartner = true]) {
                if (searchkeys.contains(a.RSA_Description_Code__c) ||
                        searchkeys.contains(a.RSAC_Description_Code__c) ||
                        searchkeys.contains(a.Department_Chief_Description_Code__c)) {
                    ManagedAgencies.add(a);
                }
            }
            
            return ManagedAgencies;

        }
        
        public static Map<String,String> retrieveCollaboratorOptions(String theAgencycode, User CurrentUser) {
            //Given agency and user I return the options for available collaborator options
            
            boolean isAgent = false;
            string ProfileName = CurrentUser.Profile.Name;
            string RoleName = currentUser.UserRole.DeveloperName;
            
            if (ProfilesThatCanSeeAllAgencyUsers.contains(ProfileName)) {
                isAgent = true;
            } else {
                // I must check if the CurrentUser is a AreaManager or a SalesManager
                if (!CurrentUser.IsPortalEnabled) {//skip check if agency user
                    List<account> ManagedAgencies = getManagedAgencies(CurrentUser);
                    if (ManagedAgencies.size()>0) isAgent = true;
                }
            }
            
            //Map Id--User for picklist code-values
            Map<String,String> CollaboratorOptions = new Map<String,String>();

            if (isAgent) {//I GIVE ALL THE USERS OF THAT AGENCY
                CollaboratorOptions.put('Tutti', 'Tutti');
                for(user thisUser : [SELECT id, Name, Agency_code__c FROM User where Agency_code__c=:theAgencycode AND isActive=true]) {
                    CollaboratorOptions.put(thisUser.Id,thisUser.Name);
                }
            } else { //I provide only the current user as option
                CollaboratorOptions.put(CurrentUser.Id, CurrentUser.Name);
            }
            return CollaboratorOptions;
        }
        
        public static List<String> retrieveAgencyOptions(String theSalesManager, string theAreaManager) {
            // Given a SalesManager or WelfareManger Name i get alll the relative agencies
            Set<String> theAgencies = new set<String>();
            theAgencies.add('Tutte');
            if (String.isempty(theAreaManager) || theAreaManager=='null') {
                for (Account thisAgency: [SELECT id, Agency_code__c FROM ACCount where Recordtype.DeveloperName='Agency' AND Active__c=true AND (RSA_Description_Code__c=:theSalesManager OR Department_Chief_Description_Code__c=:theSalesManager)]){
                    theAgencies.add(thisAgency.Agency_code__c);
                }
            } else {
                for (Account thisAgency: [SELECT id, Agency_code__c FROM ACCount where Recordtype.DeveloperName='Agency' AND Active__c=true AND RSAC_Description_Code__c=:theAreaManager AND (RSA_Description_Code__c=:theSalesManager OR Department_Chief_Description_Code__c=:theSalesManager)]){
                    theAgencies.add(thisAgency.Agency_code__c);
                }
            }
            
            List<String> result = new List<String>();
            if (!theAgencies.isEmpty()) {
                result.addAll(theAgencies);
            }
            return result;
        }
        
        public static string getMonthName(string MonthNumber) {
            //if the monthnumber is wrong i return the same monthnumber
            String MonthName = MonthNumber;
            
            if (MonthNumber=='01' || MonthNumber=='1') MonthName = 'Gennaio';
            if (MonthNumber=='02' || MonthNumber=='2') MonthName = 'Febbraio';
            if (MonthNumber=='03' || MonthNumber=='3') MonthName = 'Marzo';
            if (MonthNumber=='04' || MonthNumber=='4') MonthName = 'Aprile';
            if (MonthNumber=='05' || MonthNumber=='5') MonthName = 'Maggio';
            if (MonthNumber=='06' || MonthNumber=='6') MonthName = 'Giugno';
            if (MonthNumber=='07' || MonthNumber=='7') MonthName = 'Luglio';
            if (MonthNumber=='08' || MonthNumber=='8') MonthName = 'Agosto';
            if (MonthNumber=='09' || MonthNumber=='9') MonthName = 'Settembre';
            if (MonthNumber=='10') MonthName = 'Ottobre';
            if (MonthNumber=='11') MonthName = 'Novembre';
            if (MonthNumber=='12') MonthName = 'Dicembre';
            return MonthName;
        }
        
        /*
    public static string getTimeRef_old(){
        //First sort out the time 
        Date thisMonday = Date.today().toStartOfWeek();
        Date previousMonday = thisMonday.addDays(-7);
        
        String Year = String.ValueOf(previousMonday.year());
            
        String tempMonth = '0'+String.ValueOf(previousMonday.month());
        String Month = tempMonth.left(2);//Padding
            
        String tempday = '0'+String.ValueOf(previousMonday.day());
        String day = tempday.left(2);
        
        string TimeRef = Year+Month+day;
        
        return TimeRef;
    }
    */
        
        //if today is 22/08/2016 the method will return the string '20160815'
        public static string getTimeRef(){
            //return (Date.today().toStartOfWeek().addDays(-7)+'').substring(0,10).replace('-', '');
            return (Date.today().toStartOfWeek().addDays(-0)+'').substring(0,10).replace('-', '');
        }
        
        public static boolean isInLastWeek(DateTime theDate) {
            if ( theDate == null ) return false;
            DateTime thisMonday = Date.today().toStartOfWeek();
            system.debug('thisMonday:'+thisMonday);
            DateTime previousMonday = thisMonday.addDays(-7); //NECESSARIO CONFRONTARE DATA-ORA CON DATA-ORA, ALTRIMENTI SI PERDE 1 GIORNO --> DEFINIRE DATETIME 23.59.59
            system.debug('previousMonday:'+previousMonday);
            
            if (theDate>=previousMonday && theDate<thisMonday) {
                return true;
            } else {
                return false;
            }
        }
        
        
        public static boolean isInThisWeek(DateTime theDate) 
        {
            if ( theDate == null ) return false;
            system.debug('theDate:'+theDate);
            DateTime thisMonday = Date.today().toStartOfWeek();
            system.debug('thisMonday:'+thisMonday);
            DateTime nextMonday = thisMonday.addDays(+7); 
            system.debug('nextMonday:'+nextMonday);
            
            if (theDate>=thisMonday&& theDate<nextMonday) {
                return true;
            } else {
                return false;
            }
        }
        
        public static void commitRows (Map<String,Map<String,string>> theRows) {
            system.debug('+++trying to commit the following');
            for(string s : theRows.keyset()) {
                system.debug('###'+s);
                system.debug('###'+theRows.get(s));
            }
        }
        
        public static void commitRowsNew (Map<String,Map<String,string>> theRows) 
        {

            List<Dashboard_Row__c> DR_toUpsert = new List<Dashboard_Row__c>();

            for(String recordUniqueKey : theRows.keySet())
            {
                //SObject so = new Dashboard_Row__c(Unique_Name__c=recordUniqueKey);
                SObject so = new Dashboard_Row__c();// = Schema.getGlobalDescribe().getSObject('Dashboard_Row__c').newSObject('Dashboard_Row__c');// = new Dashboard_Row__c(Unique_Name__c=recordUniqueKey);
                so.put('Unique_Name__c',recordUniqueKey);
                Map<String,String> mapFieldValue = theRows.get(recordUniqueKey);
                for (String keyF : mapFieldValue.keySet())
                {
                    
                    
                    
                    
                    Map<String, Schema.SObjectField> M;
                    M = Schema.SObjectType.Dashboard_Row__c.fields.getMap();
                    Schema.SObjectField field = M.get(keyF);
                    Schema.DisplayType FldType = field.getDescribe().getType();
                    
                    //TO BE EXTENDED WITH ALL POSSIBLE TYPE AND RIGHT ValueOf METHOD
                    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_enum_Schema_DisplayType.htm
                    
                    if(FldType == Schema.DisplayType.Double)
                    {
                        so.put(keyF, Decimal.valueOf(mapFieldValue.get(keyF)));
                    }
                    else if(FldType == Schema.DisplayType.String)
                    {
                        so.put(keyF, mapFieldValue.get(keyF));
                    }                    
                    
                    
                }
                DR_toUpsert.add((Dashboard_Row__c)so);
            }

            Schema.SObjectField f = Dashboard_Row__c.Fields.Unique_Name__c;
            system.debug('++++inserting DR_toUpsert.size(): '+DR_toUpsert.size());
            system.debug('++++inserting DR_toUpsert: '+DR_toUpsert);
            List<Database.UpsertResult> theres = Database.Upsert(DR_toUpsert,f,false);//inserting as much as possible

        }
        
        
        
    }
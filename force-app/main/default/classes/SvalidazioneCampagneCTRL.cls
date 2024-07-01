public without sharing class SvalidazioneCampagneCTRL {

    public SvalidazioneCampagneCTRL() {

    }
    public class wrapperCampagneMembers {
        @AuraEnabled public String Id;
        @AuraEnabled public String dataCreazione;
        @AuraEnabled public String dataUltimaModifica;
        @AuraEnabled public String Name;
        @AuraEnabled public String NominativoOmnia;
        @AuraEnabled public String Nodes;
        @AuraEnabled public String CodiceOmnia;
        @AuraEnabled public String Status;
        @AuraEnabled public String CampagnaEsclusa;
        @AuraEnabled public String MessagioErrore;
        
        //@AuraEnabled public String type;
    }
    public class wrapperCampagne {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        //@AuraEnabled public String type;
    }
    public class wrapperNode {
        @AuraEnabled public String Id;
        @AuraEnabled public String codeUnique;
        @AuraEnabled public String Name;
        //@AuraEnabled public String type;
    }
    public class wrapperNodoOmnia {
        @AuraEnabled public String codeUnique;
        @AuraEnabled public String agencyHolder;
        @AuraEnabled public String MessagioErrore;
        //@AuraEnabled public String type;
    }
    @AuraEnabled
    public static List<wrapperCampagne> getListCampaignForRT(String developerNameRT) {

        List<wrapperCampagne> response = new List<wrapperCampagne>();
        List<Campaign> CampaigLista = new List<Campaign>();
        Date oggi = System.today();

        //per gestire il fatto che sono due RT per informative
        if(developerNameRT.equalsIgnoreCase('Marketing_campaign'))
            CampaigLista = [select id,Name from Campaign where RecordType.DeveloperName ='Marketing_campaign'  and Blacklist_end_date__c >=:oggi];
        else 
            CampaigLista = [select id,Name from Campaign where RecordType.DeveloperName IN ('Informative_Campaign_PCC_MyAXA','Informative_Campaign') and Blacklist_end_date__c >=:oggi];

        for (Campaign temp: CampaigLista) {
            response.add(popolaWrapperCampaign(temp));
        }
        return response;
    }
    @AuraEnabled
    public static List<wrapperCampagneMembers> getCampaignMembersFilterAll(String idCampagna, String NodoAgency ,String NodoOmnia,String Privacy,String dataIniCliente,String dataEndCliente){
       
        String UserId=UserInfo.GetUserId();
        User CurrentUser = new User();
        CurrentUser=[SELECT Id,CommunityNickname, Agency_code__c,Main_Node__c,Profile.Name,UserRole.Name,Nodes__c,Nodes_tree__c FROM User WHERE Id=:UserId Limit 1];
        //calculo del user actuale
        String MainCode = '';
        if(CurrentUser.Main_Node__c!= null && CurrentUser.Main_Node__c!= '')
            MainCode = CurrentUser.Main_Node__c;
        
        List<wrapperCampagneMembers> response = new List<wrapperCampagneMembers>();
        String whereCondition = ' where id != null';
        String filtroCampaignRT= '',filtroNodoAgency= '',filtroAgency='',filtroNodoOmnia= '',filtroPrivacy = '', filtroData = '';
        String SecurityEnforced = ' WITH SECURITY_ENFORCED';//for testing
        Datetime initDate = Datetime.now(), endDate = Datetime.now();


        try {
            // da testare perche non so se un Agente Main node = agency code ????
            if(CurrentUser.Agency_code__c != null && String.isNotBlank(CurrentUser.Agency_code__c)
            && MainCode != null && String.isNotBlank(MainCode) ){
                if(CurrentUser.Agency_code__c == CurrentUser.Main_Node__c)// deve essere un user Agente che Main_code = agency_code
                    filtroAgency = ' AND CampaignMember.Contact.Account.AAI_Agency_Reference_Code__c=:MainCode';
                else {
                 if(MainCode!= 'None' && MainCode!= '' )
                   filtroAgency =' AND CampaignMember.Contact.Account.Ccod_Produttore__c=:MainCode';
                }
            } else {

            }
      

            if(idCampagna!= 'None')
                filtroCampaignRT = ' AND  CampaignId =:idCampagna  ';

            if(NodoAgency != 'None')
                filtroNodoAgency= ' AND Contact.Account.Nodes__c like \'%'+NodoAgency+'%\'';

            if(NodoOmnia!= 'None') 
                filtroNodoOmnia = ' AND Nodo_Omnia_produttore__c =:NodoOmnia ';
            
            if(Privacy!= 'None') 
                filtroPrivacy = ' AND Contact.Account.CIF_Privacy_4__c =:Privacy ';
            
            if(dataIniCliente != 'None' && dataEndCliente != 'None'){
                //from string to date to datetime :(
                Date tempInitDate = Date.valueOf(dataIniCliente);
                Date tempEndDate = Date.valueOf(dataEndCliente);

                initDate = DateTime.newInstance(tempInitDate, Time.newInstance(23,59,59,59));
                endDate = DateTime.newInstance(tempEndDate, Time.newInstance(23,59,59,59));

                filtroData = ' AND Contact.Account.createddate >=:initDate AND  Contact.Account.createddate <=:endDate ';
            }

            String query = 'select id,Campaign.Name,Nodes__c,Stato_Adesione__c, Campagna_Esclusa__c,Contact.Account.createddate,Contact.Account.Name,'
            +'Ultima_modifica_svalidazione__c,Nominativo_Nodo_Omnia__c,Nodo_Omnia_produttore__c,Contact.Account.CIF_Privacy_4__c from CampaignMember ';

            //
            List<CampaignMember> listaCampaignMembers  = Database.query( query +  whereCondition +filtroAgency+ filtroCampaignRT 
            +filtroNodoAgency+filtroNodoOmnia +filtroPrivacy +filtroData  ); // SecurityEnforced aggiungere per restringere a Account condivise


            System.debug(' --> lista -'+ listaCampaignMembers);
            if(listaCampaignMembers.isempty()){
                return null ;
            }
            else
                for(CampaignMember temp : listaCampaignMembers){
                response.add(popolaWrapperCampaignMemb(temp));
                }
            
            return response;

        } catch (Exception error) {
            system.debug(error.getStackTraceString());
            wrapperCampagneMembers tempErrorWrapper = new wrapperCampagneMembers();
            tempErrorWrapper.MessagioErrore = (String)error.getStackTraceString();
            response.add(tempErrorWrapper);
            return response;
        }
    }
    @AuraEnabled
    public static String modificaAdessione_Incl_or_esclude(String IdsCampaignmembersSelected,String CampaignId){
        try {
            List<wrapperCampagneMembers> response = new List<wrapperCampagneMembers>();
            Campaign CampaignNameSelect = new Campaign ();
            if(CampaignId!= null)
            CampaignNameSelect = [Select id,Name from Campaign where id =:CampaignId];

            List<String> AllIdsCampMembers = IdsCampaignmembersSelected.split(';');

                if(AllIdsCampMembers.size()>10000){
                    //da rivedere come fare con queue
                }else {
                    //sono meno da 10 k si puo fare senza assyncronos
                }
                
                List <CampaignMember> ListaAggiornareCampMembers = [Select id,Ultima_modifica_svalidazione__c,Stato_Adesione__c,Campagna_Esclusa__c from CampaignMember where id =: AllIdsCampMembers];

                for(CampaignMember cammpMember_pivot:ListaAggiornareCampMembers){
                    if('Incluso'.equalsIgnoreCase(cammpMember_pivot.Stato_Adesione__c)){
                        cammpMember_pivot.Stato_Adesione__c = 'ESCLUSO';
                        cammpMember_pivot.Campagna_Esclusa__c = CampaignNameSelect!= null? CampaignNameSelect.Name: 'Nessuna Campagna ERRORE' ;
                        cammpMember_pivot.Ultima_modifica_svalidazione__c = System.today();

                    }else if('ESCLUSO'.equalsIgnoreCase(cammpMember_pivot.Stato_Adesione__c)){
                        cammpMember_pivot.Stato_Adesione__c = 'Incluso';
                        cammpMember_pivot.Campagna_Esclusa__c = '' ;
                        cammpMember_pivot.Ultima_modifica_svalidazione__c = System.today();

                    }
                }

                Database.SaveResult[] drList = Database.update(ListaAggiornareCampMembers,false);
                String messaggio = '';
                integer contadorAggiornati=0,contadorNonAggiornati=0;
                for(Database.SaveResult result : drList) {
                    if(result.isSuccess()){
                        system.debug('Aggiornato-'+result.getId());
                        contadorAggiornati++;
                    }       
                    else {  
                    system.debug('Non Aggiornato-'+result.getId());
                    system.debug('Error Updating because --'+result.getErrors());
                    system.debug('Error Updating for --'+System.UserInfo.getName()+'-Profilo-'+System.UserInfo.getProfileId());
                    contadorNonAggiornati++;
                    }
                }
                if(contadorAggiornati>0 && contadorNonAggiornati==0)
                messaggio = 'Tutti CM sono stati modificati correttamente -' +contadorAggiornati ;
                else if (contadorAggiornati>0 && contadorNonAggiornati>0)
                messaggio = 'Sono stati modificati correctamente CM:'+contadorAggiornati + ', non modificate CM:'+contadorNonAggiornati + '. Probabilmente i campaign member sono in lavorazione per un altro processo in questo momento, si prega di riprovare più tardi.';
                else if (contadorAggiornati==0 && contadorNonAggiornati > 0)
                messaggio = 'ERRORE, nessuna modifica. Probabilmente i campaign member sono in lavorazione per un altro processo in questo momento, si prega di riprovare più tardi.';
                
                return messaggio;

            } catch (Exception error) {
                system.debug(error.getStackTraceString());
                return (String)error.getStackTraceString();
            }
    }

    @AuraEnabled
    public static String validaPagina(String IdsCampaignmembersSelected){
        try {
                

            List<String> AllIdsCampMembers = IdsCampaignmembersSelected.split(';');
            List <CampaignMember> ListaAggiornareCampMembers = [Select Ultima_modifica_svalidazione__c from CampaignMember where id =: AllIdsCampMembers];

            for(CampaignMember cammpMember_pivot:ListaAggiornareCampMembers){
                cammpMember_pivot.Ultima_modifica_svalidazione__c = System.today();
            }
            
            Database.SaveResult[] drList = Database.update(ListaAggiornareCampMembers,false);
            String messaggio = '';
            integer contadorAggiornati=0,contadorNonAggiornati=0;
            for(Database.SaveResult result : drList) {
                if(result.isSuccess()){
                    system.debug('Aggiornato-'+result.getId());
                    contadorAggiornati++;
                }       
                else {  
                system.debug('Non Aggiornato-'+result.getId());
                system.debug('Error Updating because --'+result.getErrors());
                system.debug('Error Updating for --'+System.UserInfo.getName()+'-Profilo-'+System.UserInfo.getProfileId());
                contadorNonAggiornati++;
                }
            }
            if(contadorAggiornati>0 && contadorNonAggiornati==0)
            messaggio = 'Tutti sono stati modificata correttamente -' +contadorAggiornati ;
            else if (contadorAggiornati>0 && contadorNonAggiornati>0)
            messaggio = 'Sono state modificate correctamente '+contadorAggiornati + ', non modificate '+contadorNonAggiornati;
            else if (contadorAggiornati==0 && contadorNonAggiornati > 0)
            messaggio = 'ERRORE custom view, nessuna modificata correttamente ';
            
            return messaggio;

        } catch (Exception error) {
            system.debug(error.getStackTraceString());
            return (String)error.getStackTraceString();
        }    
    }
    private static wrapperCampagneMembers popolaWrapperCampaignMemb (CampaignMember temp){
        wrapperCampagneMembers nuovoWrapper = new wrapperCampagneMembers();
        Datetime createddateTimelast=null;
        Date myDate,myDateLast=null;
        String ultimaModificaString = '';
        Datetime createddateTime = temp.Contact.Account.createddate;
        myDate = date.newinstance(createddateTime.year(), createddateTime.month(), createddateTime.day());

        if(temp.Ultima_modifica_svalidazione__c != null){
            myDateLast = date.newinstance(temp.Ultima_modifica_svalidazione__c.year(), temp.Ultima_modifica_svalidazione__c.month(), temp.Ultima_modifica_svalidazione__c.day());
            ultimaModificaString = String.valueOf(myDateLast);
        }

        nuovoWrapper.id = temp.id;       
        nuovoWrapper.dataCreazione = String.valueOf(myDate);
        nuovoWrapper.dataUltimaModifica = ultimaModificaString;
        //nuovoWrapper.dataUltimaModifica = String.valueOf(temp.Ultima_modifica_svalidazione__c);
        nuovoWrapper.Name = temp.Contact.Account.Name ;
        nuovoWrapper.Nodes = temp.Nodes__c ;
        nuovoWrapper.CodiceOmnia = temp.Nodo_Omnia_produttore__c ;
        nuovoWrapper.Status = temp.Stato_Adesione__c ;
        nuovoWrapper.NominativoOmnia = temp.Nominativo_Nodo_Omnia__c ;
        nuovoWrapper.CampagnaEsclusa = temp.Campagna_Esclusa__c ;
        return nuovoWrapper;
    }
    private static wrapperCampagne popolaWrapperCampaign (Campaign temp){
        wrapperCampagne nuovoWrapper = new wrapperCampagne();
        nuovoWrapper.id = temp.id;
        nuovoWrapper.Name = temp.Name ;
        return nuovoWrapper;
    }
    private static wrapperNode popolaWrapperNodes (Node__c temp){
        wrapperNode nuovoWrapper = new wrapperNode();
        nuovoWrapper.codeUnique = temp.Node_unique_code__c;
        nuovoWrapper.Name = temp.Node_unique_code__c +' - '+ temp.Node_description__c ;
        return nuovoWrapper;
    }
    private static wrapperNodoOmnia popolaWrapperNodoOmnia (Node__c temp){
        wrapperNodoOmnia nuovoWrapper = new wrapperNodoOmnia();
        nuovoWrapper.codeUnique = temp.Node_unique_code__c;
        nuovoWrapper.agencyHolder =temp.Agency_holder__c  ;
        return nuovoWrapper;
    }
    @AuraEnabled
    public static List<wrapperNode> getListNodesByUser(){

        List<wrapperNode> response = new List<wrapperNode> ();
        List<Node__c> availableNodes = DataBase.Query(computeNodeQuery(UserInfo.getuserId()));
        system.debug('availableNodes'+availableNodes);

        for(Node__c nodeTemp: availableNodes){
            response.add(popolaWrapperNodes(nodeTemp));
        }

        return response;
    }
    @AuraEnabled
    public static List<wrapperNodoOmnia> getListNodoOmniaByUser(){

        List<wrapperNodoOmnia> response = new List<wrapperNodoOmnia> ();
        List<Node__c> availableNodes = DataBase.Query(computeNodeQuery(UserInfo.getuserId()));
        system.debug('availableNodes'+availableNodes);

        for(Node__c nodeTemp: availableNodes){
            response.add(popolaWrapperNodoOmnia(nodeTemp));
        }

        return response;
    }
    @AuraEnabled
    public static List<wrapperNodoOmnia> getListNodoOmniaByCampaign(String idCampaign){

        List<wrapperNodoOmnia> response = new List<wrapperNodoOmnia> ();
        String AgencyCodeUser = '';
        List<Node__c> availableNodesForAgency = DataBase.Query(computeNodeQuery(UserInfo.getuserId()));
        Map<Id,Node__c> mapIdsNodesForAgency =  new Map <id,Node__c> (availableNodesForAgency);
        List<Node__c> availableNodesFinal = new List<Node__c>();
        List<User> UserNFE = [Select id, FirstName, LastName, Profile.Name, Nodes__c,Agency_Code__c from User WHERE Id=:UserInfo.getuserId()];
        //filtro aggiunto per quantita di campaingmembers troppa per una query *-+ 09-02-2023 bug errore omnia picklist
        if(!UserNFE.isEmpty()) 
            AgencyCodeUser = UserNFE[0].Agency_Code__c;

        List<AggregateResult> IdsOnCampaingmembersByCampa = [select  Contact.Account.Nodo_Omnia__c from CampaignMember  where CampaignId =:idCampaign AND Contact.Account.AAI_Agency_Reference_Code__c=: AgencyCodeUser And Contact.Account.Nodo_Omnia__c != null group by Contact.Account.Nodo_Omnia__c];
        
        for(AggregateResult resultsTempID:IdsOnCampaingmembersByCampa ){
            if(mapIdsNodesForAgency.containsKey(String.valueOf(resultsTempID.get('Nodo_Omnia__c')))){
                availableNodesFinal.add(mapIdsNodesForAgency.get(String.valueOf(resultsTempID.get('Nodo_Omnia__c'))));
            }
        }

        for(Node__c nodeTemp: availableNodesFinal){
            response.add(popolaWrapperNodoOmnia(nodeTemp));
        }

        return response;
    }
    public static string computeNodeQuery(Id UserId) {
        string myQ = 'Select Node_unique_code__c, Node_description__c,';
        
        //Other fields
        myQ = myQ +'Agency_holder__c ,';
        myQ = myQ +'Tutti_i_prodotti__c,';
        myQ = myQ +'Ultima_modifica_blacklist__c ';  
        
        List<User> Usrs = [Select id, FirstName, LastName, Profile.Name, Nodes__c,Agency_Code__c from User WHERE Id=:UserId];
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
                    myQ = myQ+') ';                 
                    myQ = myQ+' ORDER BY Node_unique_code__c';
                }
                
            }
            system.debug('computed string-->'+myQ);
            
        }
        
        return myQ;
    }
     
}
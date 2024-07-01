//BOVOLENTA_D Blacklist 2018
global without sharing class BlackListCampaignQuerier {
        public list<CampaignMember> queryResult;
        public string lastName;
        public string firstName;
        public string name;
        public integer externalCount;
        public BlackListCampaignQuerier (String filterString,String filterLastName, String filterFirstName, String filterName, Boolean firstTime, String type)
        {
            Integer maxRecords = 5000;
            queryResult = new list<CampaignMember>();
            //Small security check
            if(!filterString.startsWith(' AND CampaignId = \'')) return;
            String UserId=UserInfo.GetUserId();
            User CurrentUser = new User();
            CurrentUser=[SELECT Id,CommunityNickname, Agency_code__c,Profile.Name,UserRole.Name,Nodes__c,Nodes_tree__c FROM User WHERE Id=:UserId Limit 1];
            AAI_Code_Variables__c defaultAdminAgency = AAI_Code_Variables__c.getValues('AdminAgencyCode');
            String agencyCode = '';
            if ((CurrentUser.Profile.Name == 'System Administrator') || (CurrentUser.Profile.Name == 'Amministratore del sistema')) agencyCode = defaultAdminAgency.Value__c;
            if(CurrentUser.Agency_code__c!= null && CurrentUser.Agency_code__c!= '') agencyCode = CurrentUser.Agency_code__c;
            
            String countQuery= 'Select count() FROM CampaignMember WHERE CampaignMember.Contact.Account.TECH_Company__c=\'AAI\' ';
            String mainQuery = 'Select Contact.Account.Name,Contact.Account.FirstName,Contact.Account.LastName, Contact.Account.Nodes__c, Contact.Account.CreatedDate,Contact.Account.BlackList_Auto__c,Contact.Account.BlackList_Abitazione__c,Contact.Account.BlackList_Aziende__c,Contact.Account.BlackList_Infortuni__c,Contact.Account.BlackList_Malattia__c,Contact.Account.BlackList_Protection__c,Contact.Account.BlackList_Saving__c,Contact.Account.BlackList_Rinnovo__c,Contact.Account.BlackList_Servizio__c,Contact.Account.BlackList_Commerciale__c,Contact.Account.Tutte_le_tipologie__c,Contact.Account.Tutti_i_prodotti__c,Contact.Account.Ultima_modifica_blacklist__c,Contact.Account.NDG__c FROM CampaignMember WHERE CampaignMember.Contact.Account.TECH_Company__c=\'AAI\' ';
            String countFullQuery = countQuery + ' AND CampaignMember.Contact.Account.AAI_Agency_Reference_Code__c= \''+agencyCode+'\' '+ filterString;
            String fullQuery = mainQuery +' AND CampaignMember.Contact.Account.AAI_Agency_Reference_Code__c= \''+agencyCode+'\' '+ filterString;

            Set<String> userNodeSet = new Set<String> ();
            List<Node__c> nodesList = new list<Node__c>();
            if (agencyCode!= null && agencyCode != '' && CurrentUser.Nodes__c!=null && CurrentUser.Nodes__c!='')
            {

                for(String uN : CurrentUser.Nodes__c.split(';')){
                    userNodeSet.add(uN.remove('DIF_'));
                }
                system.debug('***userNodeSet '+userNodeSet );
                if(userNodeSet.contains(agencyCode)) {
                    agencyCode = agencyCode+'%';
                    nodesList =  [SELECT Node_unique_code__c FROM Node__c WHERE  Node_unique_code__c LIKE : agencyCode and  Node_level__c >=7 and Node_level__c <=9 order by Node_unique_code__c  ASC];
                }else{
                    nodesList =  [SELECT Node_unique_code__c FROM Node__c WHERE  (Node_unique_code__c IN :userNodeSet OR Parent_node_unique_code__c IN: userNodeSet) AND Node_level__c >=7 and Node_level__c <=9 order by Node_unique_code__c  ASC];
                }
                system.debug('***nodesList '+nodesList );
            }
            string BaseStringNodes = '';

            if(userNodeSet.contains(CurrentUser.Agency_Code__c)) { // all nodes are like agency code
                BaseStringNodes =' AND (Nodes__c LIKE \'%'+CurrentUser.Agency_Code__c+'%\')';
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
            String namePagination = '';
            String rtFilter = '';
            if (type =='B2C')
            {
                rtFilter = ' AND Contact.Account.RecordType.DeveloperName = \'B2C_Client\' ';
                if (filterLastName != '') 
                {
                    namePagination = ' AND (Contact.Account.LastName>\''+filterLastName+'\' OR (Contact.Account.FirstName>=\''+filterfirstName+'\' AND Contact.Account.LastName=\''+filterLastName+'\' ))';
                }
            }
            if (type =='B2B')
            {
                rtFilter = ' AND Contact.Account.RecordType.DeveloperName = \'B2B_Client\' ';
                if (filterName != '')
                {
                    namePagination = ' AND Contact.Account.Name>=\''+filterName+'\'';
                }
            }

            countFullQuery=countFullQuery+BaseStringNodes+namePagination+rtFilter; //no need to order in a count
            system.debug(LoggingLevel.INFO,'++++++countFullQuery'+countFullQuery);
            integer count= database.countQuery(countFullQuery);
            system.debug(LoggingLevel.INFO,'++++++count'+count);
            if (firstTime)
            externalCount = count;
            fullQuery=fullQuery+BaseStringNodes+namePagination+rtFilter+' ORDER BY CampaignMember.Contact.Account.LastName,CampaignMember.Contact.Account.FirstName,CampaignMember.Contact.Account.Name NULLS LAST ';

            if (count > maxRecords) //we need to limit the results in order not to make a response greater than 15mb (sf calculation)
            {
                fullQuery = fullQuery+' LIMIT '+maxRecords;
            }
            
            system.debug ('The campaign member query is: '+fullQuery);

            queryResult= Database.query(fullQuery);
            lastName= '';
            firstName = '';
            name = '';
            if (count > maxRecords) 
            {
                integer lastIndex = queryResult.size()-1;
                CampaignMember lastCm = queryResult.get(lastIndex);

                if (lastCm.Contact.Account.LastName!= '') lastName = lastCm.Contact.Account.LastName;
                if (lastCm.Contact.Account.FirstName!= '') firstName = lastCm.Contact.Account.FirstName;

                if (lastCm.Contact.Account.Name!= '') name = lastCm.Contact.Account.Name;


            }
        }
}
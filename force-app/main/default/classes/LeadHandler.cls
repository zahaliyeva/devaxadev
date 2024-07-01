//md4 LeadHandler

/**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers

 * Class LeadHandler  

 *  

 * Trigger Handler for the Lead SObject. This class implements the ITrigger  

 * interface to help ensure the trigger code is bulkified and all in one place. 
 * -----------------------------------------------------------------------------------------------------------------------
 * Log History
 *
 * ID 001 
 * Initiative Lead Management Sprint 45: Handle duplication and assignment process and set value "Web" as LeadSoruce and
 * "Richiedi appuntamento" as default in case the "Dettaglio Fonte Lead" is not present
 * date: 13/06/2017
 * author: Juana Valenzuela
 * -----------------------------------------------------------------------------------------------------------------------
 * ID 002 
 * Initiative Lead Management Sprint 45: Review of Lead Handler process to include the new deduplication and
 * assignment
 * date: 28/06/2017
 * author: Juana Valenzuela
 * -----------------------------------------------------------------------------------------------------------------------
 */ 


public with sharing class LeadHandler implements ITrigger {   

    public final String objectShare = 'LeadShare';  
    public final String parentId = 'LeadId';
    public final String rawCause = 'Manual'; 
    public final String accessLevelName = 'LeadAccessLevel';
    public final String accessLevelvalue = 'Read'; //'None','Read','Edit','All'
    public final String separatorOfGroups = ';';
    public final String fieldNameOfGroup ='Main_Node__c';  
    
    public final String sObjectTypeFuture = 'Lead';
    
    static List<SObject> LeadisQtuotobeEdited = new List<SObject>();
    //public final List<Lead> LeadwithoutAgency = new List<Lead>();
    //public Boolean isSharingtobeDeleted; 



    // Constructor  

    public LeadHandler(){  

    }     

    /**  

     * bulkBefore  

     *  

     * This method is called prior to execution of a BEFORE trigger. Use this to cache  

     * any data required into maps prior execution of the trigger.  

     */ 

    public void bulkBefore(){  

    }  
       
    public void bulkAfter(){  

    }          

    public void beforeInsert(SObject so){   
        
    }
    
    public void beforeInsert(List<SObject> soList){  

        system.debug('+++++++++++++beforeisnertTriggeronLead');
        List<Lead> rListComplete = (List<Lead>) soList; //list added to handle the trigger skip
        List<Lead> rList = new List<Lead> (); //list added to handle the trigger skip
        List<Lead> MPSLead = new List<Lead>();
        List<Lead> MPSLeadForAgencyLookup = new List<Lead>();
        List<Lead> OutsourceLeads = new List<Lead>();
        //Start - 001
        String richiediAppuntamento = UtilityClass.getPicklistValue(rListComplete.get(0),'Dettaglio__c').get('Richiedi appuntamento');
        Id currentUserId = UserInfo.getuserid();
        User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id =:currentUserId limit 1];
        List<Lead> leadNonWeb = new List<Lead> ();
        List<Lead> leadWeb = new List<Lead>();
        //End - 001
        Id MPSLeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead MPS').getRecordTypeId();
        Id OutsourceLeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Outsource').getRecordTypeId();//service 2 sell leads
        for (Lead l : rListComplete){
            if (!l.TECH_Skip_triggers__c){
                
                if(l.RecordTypeId == MPSLeadRecTypeId) {
                    if(l.Status!=null){
                        
                        l.put('Status_Last_Modified_Date__c',Date.today());
                    	
                    }
                    if(!l.Gi_cliente_AXA__c){
                    MPSLead.add(l);
                }

                    MPSLeadForAgencyLookup.add(l);

                    
                }
                else if(!l.TECH_isECommerceLead__c){
                    System.debug(' ===> TECH_Skip_triggers__c: ' +  l.TECH_Skip_triggers__c);
                    System.debug(' ===> TECH_isECommerceLead__c: ' +  l.TECH_isECommerceLead__c);
                    rList.add (l);
                }
                if(l.RecordTypeId == OutsourceLeadRecTypeId){
                    OutsourceLeads.add(l);
                }
            }
        }

        System.debug(' ===> rList: ' +  rList);
        if(!MPSLead.isEmpty()){
            LeadMPSManagement.leadMPSToAgency(MPSLead);
        }
        if(!MPSLeadForAgencyLookup.isEmpty()){
            LeadMPSManagement.AssociaAgenzia(MPSLeadForAgencyLookup);
        }
        for (Lead l : rList){ 
           l.TECH_N_Notes_field_char__c = l.Notes__c==null ? 0 : l.Notes__c.length();
           //Start - 001
           //FM 12/01/2018  added LeadSource as condition in order to set ASA and SottoASA values to massively uploaded Leads
           if((l.Landing_Page__c != null && 
                (currentUser.Profile.Name =='System Administrator'|| currentUser.Profile.Name =='Amministratore del sistema')) || l.LeadSource == 'Web'){
                l.LeadSource = 'Web';
                if (l.Data_richesta_quotazione__c == null ) l.Data_richesta_quotazione__c = System.now(); //BOVOLENTA_D SPRINT 59 US635
                if (l.Data_ultima_quotazione__c == null ) l.Data_ultima_quotazione__c = l.Data_richesta_quotazione__c;//BOVOLENTA_D SPRINT 59 US635
                if (l.Numero_quotazioni__c == null ) l.Numero_quotazioni__c = 1; //BOVOLENTA_D SPRINT 59 US635
                leadWeb.add(l);
                if (l.Dettaglio__c == null){
                    Boolean hasAgency = String.isNotBlank(l.Agency_Code__c);
                    List<Lead_default_source_detail__c> detailList = [SELECT Id,Name,HasAgency__c,Landing_page__c,Lead_source_detail__c FROM Lead_default_source_detail__c WHERE Landing_page__c = :l.Landing_Page__c AND HasAgency__c = :hasAgency limit 1];                
                    System.debug ('*****detailList '+detailList);
                    System.debug ('*****queryparams hasAgency'+hasAgency+' l.Landing_Page__c  '+l.Landing_Page__c );

                    if (!detailList.isEmpty())
                    {
                        //Set default from custom setting
                        l.Dettaglio__c = detailList[0].Lead_source_detail__c;
                    }
                    else
                    {
                        //If not found in the custom setting the default is "Richiedi appuntamento"
                        l.Dettaglio__c = richiediAppuntamento;
                    }
                    
                   
                } 
                //BOVOLENTA_D 13102017 TEMPFIX for agency code
                if ((l.Landing_page__c ==  'Pagina prodotto AXA' || l.Landing_page__c =='Trova Agente') && String.isNotBlank(l.Agency_Code__c))
                {
                    while(l.Agency_Code__c.length()<6)
                    {
                        l.Agency_Code__c='0'+l.Agency_Code__c;
                    }
                }
                //BOVOLENTA_D END
                

            }
            if(l.LeadSource != 'Web')
                leadNonWeb.add(l);    
            //End - 001
        }

        System.debug(' ===> leadWeb: ' +  leadWeb);
        System.debug(' ===> leadNonWeb: ' +  leadNonWeb);
       
        if(leadWeb.size()>0){
            System.debug('===> Lead da web');
            LeadManagement.setASA(leadWeb);
        }
        //rList = LeadManagement.SetDuplicateFlag(rList);       FM 23/06 - Dismissed, introduced the method LeadDuplicationCheck
        //Start - 001 - The check for duplicates in before insert is done only for non Web Leads. For Web the check is done
        // in the assignement process
        if(!OutsourceLeads.isEmpty()){
            LeadManagementECommerce.checkAgentSiteAgencyCampaignWithoutUpdate(OutsourceLeads);
        }
        if(leadNonWeb.size()>0)
            LeadManagement.leadDeduplicationCheck(leadNonWeb);  
        //End - 001             
    }   
    
    public void beforeUpdate(SObject oldSo, SObject so){  
        
    }  
        
    public void beforeUpdate(List<SObject> oldSoList, List<SObject> soList){
        List<Lead> rListComplete = (List<Lead>) soList; //list added to handle the trigger skip
        List<Lead> rList = new List<Lead> (); //list added to handle the trigger skip
        List<Lead> oldrList = (List<Lead>) oldSoList; //list of old leads
        List<String> listOldOwnerIds = new List<String>(); //list that contains the old owner ids
        Map<String,String> mapOldOwnerIdWithProfileName = new Map<String,String>(); //map that contains the old owner id with their profile name
        Id axaQueue = UtilityClass.retrieveGroupId('Queue','AAI_Lead_Queue'); //CAPOBIANCO_A BUGFIX 29/09 moved outside the For cycle
        Id MPSLeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead MPS').getRecordTypeId();
        Id currentUserId = UserInfo.getuserid();
        User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id =:currentUserId limit 1];

        for (Integer i=0;i<rListComplete.size();i++){
            Lead l=rListComplete[i];
            if (l.TECH_Skip_triggers__c == false ){ //BOVOLENTA_D 07052019 bugfix && !l.TECH_isECommerceLead__c
                if(l.Status!=oldrList[i].Status && l.RecordTypeId == MPSLeadRecTypeId){
                        
                        l.put('Status_Last_Modified_Date__c',Date.today());
                    	
                    }
                rList.add(l);
            }
        }       
        for(integer i=0; i<soList.size(); i++)
        {
            if (soList.get(i).get('LeadSource') == 'Web')
            {
                system.debug('+++++++++++++++++++++++'+soList.get(i).get('Agency_Code__c'));
                system.debug('***********************'+oldSoList.get(i).get('Agency_Code__c'));
                if ( soList.get(i).get('Agency_Code__c') != oldSoList.get(i).get('Agency_Code__c'))
                {
                    LeadisQtuotobeEdited.add(soList.get(i));  
                }
            }
        
        }
        
        system.debug('***********************LeadisQtuotobeEdited'+LeadisQtuotobeEdited);
        
        //CAPOBIANCO_A 07/04/2017 - START Populating the list and the map of the Old owners' Ids
        for (Lead Ol : oldrList)
        {
            listOldOwnerIds.add(Ol.OwnerId);
        }
        
        for (User u : [SELECT Id,Profile.Name FROM User WHERE Id IN: listOldOwnerIds])
        {
            mapOldOwnerIdWithProfileName.put(u.Id,u.Profile.Name);
        }
        //CAPOBIANCO_A 07/04/2017 - END

       //Added 18/04
        //rList = LeadManagement.SetDuplicateFlag(rList);       FM 23/06 - Dismissed, introduced the method LeadDuplicationCheck

        //002 - Start
        //rList = LeadManagement.LeadDeduplicationCheck(rList);
        //002 - End

        Set<Id> leadToReassignFuture = new set<Id>();
    
        Boolean needreassignment = false;
        if (currentUser.Profile.Name!= null && String.isNotBlank(currentUser.Profile.Name) &&
        (currentUser.Profile.Name.containsIgnoreCase('AAI - Vendite Avanzato') || currentUser.Profile.Name.containsIgnoreCase('AAI - Vendite Base'))) {
           needreassignment = true;
        }
        
        //rList = LeadManagement.reassingLeadAAI(rList); //SYNC method-- 

        //Start - 002
        List<Lead> leadsWebToAssignList = new List<Lead>();
        List<Lead> leadsDuplicationCheck = new List<Lead>();
        List<Lead> leadsToCheckPhone = new List<Lead>();
        //End - 002
        List<Lead> leadsForFinalCheck = new List<Lead>(); //CAPOBIANCO_A 10/01/2018
        List<Lead> leadsMCClick = new List<Lead>(); 
        List<QueueAssignmentLogicParameters__c> settings=QueueAssignmentLogicParameters__c.getall().values();
        system.debug('#### rlist'+rList);
        for(integer j=0;j<rList.size();j++){

            boolean allowedToReassign = true;
            Lead l = rList.get(j);
            Lead oldLead = oldrList.get(j);

                         
            Boolean isNewLead = !oldLead.TECH_IsNewLead__c && l.TECH_IsNewLead__c && l.LeadSource == 'Web'?TRUE:FALSE;
            if(isNewLead && !l.TECH_isECommerceLead__c){ //BOVOLENTA_D 07052019 ecommerce leads should not be assigned here
                //In this check should be considered also "External List"
                leadsWebToAssignList.add(l);
            }
            if(l.Agency_Code__c != null )  
                leadsDuplicationCheck.add(l);                                
            //002 - End
            if(l.MarketingCloudEmailClick__c && !oldLead.MarketingCloudEmailClick__c){ // if mc email has been clicked                           
                QueueAssignmentLogicParameters__c setting=WS_REST_Lead_eCommerce.getQueueAssignmentLogicParameters(l.Dettaglio__c, l.Landing_Page__c, settings);
                if(setting.MCEmailClickAction__c=='AG Noovle, riassegna'){
                    leadsMCClick.add(l);
                }
            }

            //if the old owner exists, wasn't a queue, and was an agency agent
            //[19/05/17]JV - Start: Lead Management: Do not reassign if the previous owner is a queue            
            /*
            if ((oldLead.OwnerId!=null)&&(!(String.valueOf(oldLead.OwnerId).left(3) == '00G'))&&(mapOldOwnerIdWithProfileName.get(oldLead.OwnerId) == 'AAI - Vendite Avanzato' || mapOldOwnerIdWithProfileName.get(oldLead.OwnerId) == 'AAI - Vendite Base'))
            {   
                //now, if the new owner is a queue
              if(String.valueOf(l.OwnerId).left(3) == '00G')
              {
                 allowedToReassign = false; //boolean that doesnt allow to reassign the Lead
              }
              else 
              {
              }
            }
            */
             
             //If the old owner is a queue and the new owner is a queue, don't reassign the Lead
             //}//else if(oldLead.OwnerId!=null && String.valueOf(oldLead.OwnerId).left(3) == '00G' && String.valueOf(l.OwnerId).left(3) == '00G'){
                // allowedToReassign = false; //boolean that doesnt allow to reassign the Lead
             //}
                
            if(oldLead.OwnerId!=null){
                //Id axaQueue = UtilityClass.retrieveGroupId('Queue','AAI_Lead_Queue');
                if((!(String.valueOf(oldLead.OwnerId).left(3) == '00G') && 
                    (mapOldOwnerIdWithProfileName.get(oldLead.OwnerId) == 'AAI - Vendite Avanzato' || 
                        mapOldOwnerIdWithProfileName.get(oldLead.OwnerId) == 'AAI - Vendite Base')) ||
                (String.valueOf(oldLead.OwnerId).left(3) == '00G' && oldLead.OwnerId == axaQueue)){
                    if(String.valueOf(l.OwnerId).left(3) == '00G'){
                        allowedToReassign = false; //boolean that doesnt allow to reassign the Lead
                    }    
                }
            }
            //[19/05/17]JV - End

            system.debug('+++the owner'+l.ownerId);
            system.debug('+++the currentuser'+currentUser.Id);
            l.TECH_N_Notes_field_char__c = l.Notes__c==null ? 0 : l.Notes__c.length(); 
        
            if(l.TECH_Company__c=='AAI' && needreassignment && allowedToReassign && String.valueOf(l.OwnerId).left(3) == '00G' && !isNewLead) { 
            //checked that is a AAI lead, that the user has the Agnecy profiles and that the current owner is a group
            //The same check is performed in the future method
                leadToReassignFuture.add(l.Id);
            }
            
            /*
               //DISMISSED, the mail is sent anyway see
            //https://help.salesforce.com/apex/HTViewSolution?id=000176854&language=en_US
            Must use future method
            //D.F. Feedback. Reassign lead to currentuser if the user is modifying a lead in the queue
            if(l.TECH_Company__c=='AAI' && needreassignment && String.valueOf(l.OwnerId).left(3) == '00G' ) { 
            //checked that is a AAI lead, that the user has the Agnecy profiles and that the current owner is a group
                l.OwnerId=CurrentUser.Id;
            }
            */
            //D.F. QuickEvo1 addinc a custom lookup to display the owner link on a leed view
            system.debug('++++++++++++++l.OwnerId'+String.valueOf(l.OwnerId).left(3));
            if (String.valueOf(l.OwnerId).left(3)=='005' && l.TECH_Company__c=='AAI') {
                l.Custom_Lead_Owner__c=l.OwnerId;
            } else {
                 l.Custom_Lead_Owner__c=null;
            }                  
            
        }

        if(!leadsMCClick.isEmpty()){
            LeadManagementECommerce.checkAgentSiteAgencyCampaign(leadsMCClick);
        }
        //Start - 002
        system.debug('****JV - TriggerNew_LeadWebList: ' + leadsWebToAssignList);  
        if(leadsWebToAssignList.size()>0){
            
            //CAPOBIANCO_A 09/01/2018 SPRINT 59: New first assignment process -- START
            //Step 1: splitting the new Leads into 2 Lists:
            //List 1: "Visualizza Quotazione" Leads from Web (Immediately assigned in the Lead Assignment class)
            //List 2: All the other ones
            LeadAssignment.LeadsListsWrapper webVisualizzaQuotazioneLeads = LeadAssignment.getWebVisualizzaQuotazioneLeads(leadsWebToAssignList); 
            system.debug ('++++++++webVisualizzaQuotazioneLeads'+webVisualizzaQuotazioneLeads.leadsList2.size());
            //Step 2: splitting the List 2 into another 2 Lists:
            //List 1: "Salva quotazione" and "Visualizzazione quotazione" not from Web
            //List 2: "Richiedi appuntamento" leads
            LeadAssignment.LeadsListsWrapper SalvaVisualizzaRichiediappuntamento = LeadAssignment.getSalvaVisualizzaQuotazione(webVisualizzaQuotazioneLeads.leadsList2);
            
            //Adding the first list (Salva and Not Web Visualizza quotazione Leads) into the list for the deduplication checks
            system.debug ('++++++++SalvaVisualizzaRichiediappuntamento.leadsList1'+SalvaVisualizzaRichiediappuntamento.leadsList1.size());
            leadsForFinalCheck.addAll(SalvaVisualizzaRichiediappuntamento.leadsList1);
            system.debug ('++++++++leadsDuplicationCheck'+leadsForFinalCheck.size());

            LeadAssignment.LeadsListsWrapper leadsRichiediAppuntamento = LeadAssignment.getRichiediAppuntamento(SalvaVisualizzaRichiediappuntamento.leadsList2);  
            
            //Adding the second list ("Richiedi appuntamento" Leads WITH the agency code) in the list for the deduplication checks
            leadsForFinalCheck.addAll(leadsRichiediAppuntamento.leadsList2);  
            
            //anche i lead da web devono passare per noovle
            if(webVisualizzaQuotazioneLeads.leadsList2 != null && !webVisualizzaQuotazioneLeads.leadsList2.isEmpty()){
                leadsForFinalCheck.addAll(webVisualizzaQuotazioneLeads.leadsList2);  
            }
            
            //Step 4: Performing the deduplication and then the first assignment of the remaining leads with Noovle
            if(leadsForFinalCheck.size()>0 && !System.isFuture() && !System.isQueueable()){
                system.debug ('*********leadsForFinalCheck'+leadsForFinalCheck);
                LeadAssignmentQueueable assignRemainingLeads = new LeadAssignmentQueueable(leadsForFinalCheck);
                Id assignWithoutPhoneJobId = System.enqueueJob(assignRemainingLeads);    
            }
            
            //Step 5: Splitting all the leads that arrived to the deduplication checks into 2 lists:
            //List 1: Leads without phone (immediately assigned in the Lead Assignment class)
            //List 2: Leads with phone
            //BOVOLENTA_D MOVED INTO THE QUEUABLE
            //LeadAssignment.LeadsListsWrapper leadsWithoutWithPhone = LeadAssignment.getLeadsWithoutWithPhone(leadsForFinalCheck);              
            
            
        }
        //Launching the deduplication checks
        if(leadsDuplicationCheck.size()>0)
        {
            LeadManagement.leadDeduplicationCheck(leadsDuplicationCheck); 
        }
        //CAPOBIANCO_A 09/01/2018 SPRINT 59: New first assignment process -- END

        if (!System.isFuture() && !System.isQueueable() && leadToReassignFuture.size()>0) { //CALLING FUTURE METHOD ONLY IF NOT ALREADY IN A FUTURE CALL
            LeadManagement.reassingLeadAAI(leadToReassignFuture);
          //  LeadReassignQueueable theQueueable = new LeadReassignQueueable();
           // theQueueable.leadIdSet= leadToReassignFuture; 
           // theQueueable.leadList =rList;
          //  ID jobID = System.enqueueJob(theQueueable);
            system.debug('on beforeupdate');
            system.debug('called future method for these ids'+leadToReassignFuture);
        } else {
            system.debug('+++++FUTURE CALL to reassign Before Update NOT MADE.');
            system.debug('++++++If size is positive something is wrong, a future call is calling a future mathod SIZE='+leadToReassignFuture.size());
        }       
    }        

    /**  

     * beforeDelete  

     *  

     * This method is called iteratively for each record to be deleted during a BEFORE  

     * trigger.  

     */ 

    public void beforeDelete(SObject so){     

    }  
    
    public void beforeDelete(List<SObject> soList){  

    } 

    public void afterInsert(SObject so){  
         
    }  

    public void afterInsert(List<SObject> soList){
        if(LeadManagementECommerce.shouldUpdate()){
            List<Lead> leadForRanking = new List<Lead>();
            for(SObject so : soList){
                leadForRanking.add((Lead) so);
            }
            LeadManagementECommerce.updateLeadIds(leadForRanking);
        }
       // List<Lead> rListComplete = (List<Lead>) soList; //list added to handle the trigger skip
        List<Lead> rList = new List<Lead> (); //list added to handle the trigger skip
        List<SObject> rSoList = new List<SObject> (); //list added to handle the trigger skip
        for(Integer i = 0; i < soList.size(); i++){
            if (soList[i].get('TECH_Skip_triggers__c') == false)
                {
                    rSoList.add (soList[i]);
                    Lead l = (Lead) soList[i];
                    system.debug('LEAD in handler' + soList[i].get('TECH_isECommerceLead__c'));
                    if (!(l.TECH_isECommerceLead__c)){
                        rList.add((Lead)soList[i]);
                    }
                }

        }

        System.debug(' ===> rList: ' +  rList);
        System.debug(' ===> rSoList: ' +  rSoList);

        Map<id,Lead> m = new Map<id,Lead>();
        List<Id> listWebLeadsId = new List<Id>(); //CAPOBIANCO_A 07/12/2017 -- SPRINT 57
        for(Lead l : rList)
        {
            
            //Start - 001
            if(l.LeadSource != 'Web')
                m.put(l.id,l);
            //End - 001
        //CAPOBIANCO_A 07/12/2017 -- SPRINT 57 - START
        
            
            else if(l.LeadSource == 'Web')
            {
                listWebLeadsId.add(l.Id);
            }

        }
        
        if(listWebLeadsId.size()!=0){
            QuotationManagement.createQuotationFromLead(listWebLeadsId);
             }
        
        System.debug(' ===> m: ' +  m);
        
        //CAPOBIANCO_A 07/12/2017 -- SPRINT 57 - END
        if (!m.isEmpty())
        {
            system.debug('on after insert calling future method for '+m.keyset());
            LeadManagement.reassingLeadAAI(m.keyset());
        }
        

        //SHARING
        Map<id,SObject> mapSObj = new Map<id,SObject>();
        for(SObject s : rSoList)
        {
            mapSObj.put(s.id,s);
        }
        LeadRecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);     
        if(!Test.isRunningTest()){

            LeadTrackingManagement.InputWrapper i = new LeadTrackingManagement.InputWrapper();
            i.leadNew = (List<Lead>) soList;
            i.isUpdate = false;
            LeadTrackingManagement.manageLead(i);

        }

    }       

    public void afterUpdate(SObject oldSo, SObject so){     
        
    } 

    public void afterUpdate(List<SObject> oldSoList, List<SObject> soList){
        system.debug('GDS - LEADHANDLER AFTERUPDATE OLDSOLIST : ' + oldSoList);
        system.debug('GDS - LEADHANDLER AFTERUPDATE soList : ' + soList);
        
        List<SObject> rSoList = new List<SObject> (); //list added to handle the trigger skip
        List<SObject> oldrSoList = new List<SObject> (); //list added to handle the trigger skip
        for(Integer i = 0; i < soList.size(); i++){
            if (soList[i].get('TECH_Skip_triggers__c') == false)
                {
                    rSoList.add (soList[i]);
                    oldrSoList.add (oldSoList[i]);
                }

        }
        
        

        //SHARING
        Map<id,SObject> mapSObj = new Map<id,SObject>();
        for(SObject s : rSoList)
        {
            mapSObj.put(s.id,s);
        }       
        System.debug(' ===> mapSObj: ' + mapSObj);
        LeadRecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
        
        //SHARING FUTURE
        Set<Id> setSobjToFutureSharing = new Set<Id>();
        for(integer i=0; i<rSoList.size(); i++)
        {
            if ( rSoList.get(i).get('OwnerId') != oldrSoList.get(i).get('OwnerId') && UserInfo.getUserType() != 'Standard' )
            {
                setSobjToFutureSharing.add(rSoList.get(i).Id);
            }
        }
        if (setSobjToFutureSharing.size()>0 && (!System.isFuture()) ) //DF added check on isfuture
        {
            LeadRecordSharing.shareRecordBasedOnFieldFuture(setSobjToFutureSharing, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups, sObjectTypeFuture);
        }
        
        system.debug('*************'+LeadisQtuotobeEdited);
        
        if(LeadisQtuotobeEdited.size()>0){
        
        system.debug('GDS - FINE - LEADHANDLER AFTERUPDATE LeadisQtuotobeEdited : ' + LeadisQtuotobeEdited);
        
        QuotationManagement.setAgencyCode(LeadisQtuotobeEdited);
        IndividualEmailResultManagement.setAgencyCode(LeadisQtuotobeEdited);//BOVOLENTA_D CONTACT HISTORY 21112018
        
               
        }
        
        
        system.debug('GDS - FINE - LEADHANDLER AFTERUPDATE OLDSOLIST : ' + oldSoList);
        system.debug('GDS - FINE - LEADHANDLER AFTERUPDATE soList : ' + soList); 
        if(!Test.isRunningTest()){

            LeadTrackingManagement.InputWrapper i = new LeadTrackingManagement.InputWrapper(); 
            i.leadNew = (List<Lead>) soList;
            i.leadOld = (List<Lead>) oldSoList;
            i.isUpdate = true;
            LeadTrackingManagement.manageLead(i);     
        }

    }  

    public void afterDelete(SObject so){  

    }  
    
    public void afterUndelete(SObject so){  

    }  
    
    public void afterDelete(List<SObject> soList){    

    }  

    public void afterUndelete(List<SObject> soList){  
        List<SObject> rSoList = new List<SObject> (); //list added to handle the trigger skip
        //List<SObject> oldrSoList = new List<SObject> (); //list added to handle the trigger skip
        for(Integer i = 0; i < soList.size(); i++){
            if (SoList[i].get('TECH_Skip_triggers__c') == false)
                {
                    rSoList.add (soList[i]);
                    //oldrSoList.add (oldSoList[i]);
                }

        }
        //SHARING
        Map<id,SObject> mapSObj = new Map<id,SObject>();
        for(SObject s : rSoList)
        {
            mapSObj.put(s.id,s);
        }
        LeadRecordSharing.shareRecordBasedOnField(mapSObj, objectShare, parentId, rawCause, accessLevelName, accessLevelvalue, fieldNameOfGroup, separatorOfGroups);
    }         

    /**  

     * andFinally  

     *  

     * This method is called once all records have been processed by the trigger. Use this   

     * method to accomplish any final operations such as creation or updates of other records.  

     */ 

    public void andFinally(){  

    }  

}
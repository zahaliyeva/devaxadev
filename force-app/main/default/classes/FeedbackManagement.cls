/*------------------------------------------------------------------------
Author:        Francesca Marchese
Company:       Deloitte
Class:         FeedbackManagement
Description:   Apex class with reusable methods whose purpose is to prepare 
the records on which recalculate the visibility 

History

18/01/2016     Created - F.M.
----------------------------------------------------------------------------*/


public class FeedbackManagement {


    /*
    public static void RollUpAccountFeedback ( List<Feedback__c> fList ) {
        
        
        //---------------- PREPARE DATA - START
        //Create map id to Account 
        Map<Id,Account> MapIdToAccount=new map<Id,Account>();
        for(Feedback__c f : fList){
            if (f.Account__c!=null && f.RecordType.Name=='AAI Feedback') {
                MapIdToAccount.put(f.Account__c,new account(id=f.Account__c));
            }
        }
        Set<Id> AccountIds = MapIdToAccount.keyset(); // USED for QUERY
        
        
        //add more maps here if necessary for new logics
        //---------------- PREPARE DATA - END
        
        ///////////////////////////////////////////////////////////////////////////////////////
        
        //-------------------------------------------ROLLUP START
        
        /* for (Feedback__c thisfeedback : [SELECT Id, Name, Account__c, TECH_Account_Nodes__c Stato__c FROM Feedback__c WHERE Account__c IN: AccountIds]) {



//add more logics here if necessary
} */
    //-------------------------------------------ROLLUP END

    ///////////////////////////////////////////////////////////////////////////////////////

    //-------------------Preparation of nucleo members to update  START


    //-------------------Preparation of nucleo members to update  END


    //-------------------Preparation of account to update  START

    //-------------------Preparation of account to update  END

    ///////////////////////////////////////////////////////////////////////////////////////

    //----------------  UPDATE ON ACCOUNT LIST - START
    //Account Update List
    /* List<Account> upList = new List<Account>();

upList = MapIdToAccount.values();

if(upList.size() > 0){
SYSTEM.DEBUG('+++++UPDATE OF ACCOUNTS FOR ROLLUP POLIZZE');
SYSTEM.DEBUG('+++++START');
update upList;
SYSTEM.DEBUG('+++++UPDATE OF ACCOUNTS FOR ROLLUP POLIZZE');
SYSTEM.DEBUG('+++++STOP');
system.debug('***upList: '+upList);
}*/
    //---------------- FINAL UPDATE ON ACCOUNT LIST - END

    //----------------  UPDATE ON NUCLEO MEMBERS LIST - START
    //Account Update List


    /* if(MembersToUpdate.size() > 0){
SYSTEM.DEBUG('+++++UPDATE OF MembersToUpdate FOR ROLLUP POLIZZE');
SYSTEM.DEBUG('+++++START');
update MembersToUpdate;
SYSTEM.DEBUG('+++++UPDATE OF MembersToUpdate FOR ROLLUP POLIZZE');
SYSTEM.DEBUG('+++++STOP');
system.debug('***upList: '+MembersToUpdate);
} 
    //---------------- FINAL UPDATE ON ACCOUNT LIST - END

}

*/
    //MMOSCATELLI 09/02/2017: Close the loop ICF -- START
    @future
    //OAVERSANO 09/07/2017: Close the loop ICF -- START
    //public static void CreateCase(Set<String> FeedbackSet, Set<String> CustIdentifier) 
    public static void CreateCase(Set<String> FeedbackSet, Set<String> CustIdentifier, Set<String> phoneIdentifier, Set<String> emailIdentifier)
    //OAVERSANO 09/07/2017: Close the loop ICF -- END
    {
        //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START 
        //Map<String,String> FoundCustomerMap = new Map<String,String>();
        Map<String,Account> FoundCustomerMap = new Map<String,Account>();
        //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END
        Map<String,String> IdentifierToContactId = new Map<String,String>();
        Map<String,String> MapCaseRecordType = new Map<String,String>();
        Map<Integer,Integer> MapIndexCaseToIndexFdbk = new Map<Integer,Integer>();
        Map<String,String> MapFeedbackRecordType = new Map<String,String>();//MMOSCATELLI 09/06/2017: EVO 86
        Set<String> SetEnableFunc = new Set<String>();//MMOSCATELLI 09/06/2017: EVO 86
        

        List<String> FeedbackNewOrigins = new List<String>();
        AAI_Code_Variables__c acv = AAI_Code_Variables__c.getValues('FeedbackNewOrigins');

        if (acv != null && String.isNotBlank(acv.Value__c)) {
            FeedbackNewOrigins = acv.Value__c.split(';');
        }

        List<Account> FoundAccounts = new list<Account>();
        List<Account> AccountsToUpdate = new list<Account>();
        List<Feedback__c> FeedbackToUpdateList = new list<Feedback__c>();
        List<Case> CaseToInsert = new list<Case>();
        List<Feedback__c> FeedbackList = new list<Feedback__c>();
        //MMOSCATELLI 09/06/2017: EVO 86 -- START
        //String[] types = new String[]{'Case'};
        String[] types = new String[]{'Case','Feedback__c'};
        List<Case> CaseToInsertCTLService = new list<Case>();
        Map<String,Case> RelatedCasesMap = new Map<String,Case>();
        Set<String> FeedbackIdsSet = new Set<String>();
        List<Feedback__c> FeedbackToUpdateListService = new list<Feedback__c>();
        Map<Integer,Integer> MapIndexCaseToIndexFdbkService = new Map<Integer,Integer>();
        //OAVERSANO 09/07/2017: Close the loop ICF -- START
        List<Lead> FoundLeads = new list<Lead>();
        Map<String,String> FoundLeadMap = new Map<String,String>();
        //OAVERSANO 09/07/2017: Close the loop ICF -- END
        List<Feedback__c> PositiveAgencyFeedbacks = new List<Feedback__c>();//MOSCATELLI_M 07/11/2018: CTL Acquisto

        //MMOSCATELLI 28/03/2019: ICF CR2 -- START
        String defaultHoursId;

        Boolean NotifActive = ICFNotifications__c.getInstance().IsActive__c;
        
        final List<String> EXCLUDED_ACCOUNTS_NDG = getExcludedAccountsNDG();

        for(BusinessHours bh: [select Id,IsDefault,Name from BusinessHours where IsActive =true ]) // NOPMD  Fix CRUD violation

        {
            if(bh.Name == 'AAI_Agency_CTL')
                defaultHoursId = bh.Id;
        }
        //MMOSCATELLI 28/03/2019: ICF CR2 -- END

        if(String.isNotBlank(Bypass__c.getInstance().BypassTrigger__c))
        {
            for(String s:(Bypass__c.getInstance().BypassTrigger__c).split(';'))
            {
                SetEnableFunc.add(s);
            }
        }
        //OAVERSANO 16/07/2017: Close the loop ICF -- START
        Set<String> feedBacksetAgentID = new Set<String>();
        //OAVERSANO 16/07/2017: Close the loop ICF -- END
        //MMOSCATELLI 09/06/2017: EVO 86 -- END

        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true  limit 1]; // NOPMD  Fix CRUD violation

        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;

        for(String s:FeedbackSet)
        {
            Feedback__c objFdbk = (Feedback__c)Json.deserializeStrict(s, System.Type.forName('Feedback__c'));
            FeedbackList.add(objFdbk);
            FeedbackIdsSet.add(objFdbk.Complaint__c);//MMOSCATELLI 09/06/2017: EVO 86
            feedBacksetAgentID.add(objFdbk.Agent_ID__c);//OAVERSANO 16/07/2018: Close the loop ICF
        }
        system.debug('##FeedbackIdsSet: '+FeedbackIdsSet);
        system.debug('##FeedbackList: '+FeedbackList);

        //OAVERSANO 16/07/2018: Close the loop ICF -- START
        Map<String, Id> userAgentIDMAP = new Map<String, Id>();
        List<User> userAgentID = [SELECT ID, CommunityNickname FROM User WHERE CommunityNickname IN:feedBacksetAgentID ]; // NOPMD  Fix CRUD violation
        if(!userAgentID.isEmpty()){
            for(User u:userAgentID){
                if(String.isNotBlank(u.CommunityNickname)){
                    userAgentIDMAP.put(u.CommunityNickname, u.Id);
                }
            }
        }
        //OAVERSANO 16/07/2018: Close the loop ICF -- END

        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types);

        //MMOSCATELLI 09/06/2017: EVO 86 --START

        for(Case c:[Select accountid,id,Distribution_Network__c,SuppliedEmail,LinktoPolicy__c,AgentName__c,Complainant__c from Case where id in:FeedbackIdsSet])
        {
            RelatedCasesMap.put(c.id,c);
        }
        system.debug('##RelatedCasesMap: '+RelatedCasesMap);

        for(Schema.DescribeSobjectResult re: results)
        {
            if(re.getName()=='Case')
            {
                for (Schema.RecordTypeInfo ri: re.getRecordTypeInfos())
                {
                    MapCaseRecordType.put(ri.getName(), ri.getRecordTypeId());
                }
            }
            else if(re.getName()=='Feedback__c')
            {
                for (Schema.RecordTypeInfo ri: re.getRecordTypeInfos())
                {
                    MapFeedbackRecordType.put(ri.getName(), ri.getRecordTypeId());
                }
            }
        }
        system.debug('##MapCaseRecordType: '+MapCaseRecordType);
        system.debug('##MapFeedbackRecordType: '+MapFeedbackRecordType);


        if(CustIdentifier.size()>0)
        {
            FoundAccounts = getAccounts(CustIdentifier);
            //OAVERSANO 09/07/2018 Close The Loop ICF -- START
           	Set<Id>AccountIds = new Set<Id>();
            if(!FoundAccounts.isEmpty())
            {
                for(Account account:FoundAccounts)
                {
                    AccountIds.add(account.Id);
                    if(String.isNotBlank(account.Fiscal_ID__c))
                        //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
                        //FoundCustomerMap.put('MPS_'+account.Fiscal_ID__c, account.Id);
                        FoundCustomerMap.put('MPS_'+account.Fiscal_ID__c, account);
                    //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END
                    else
                            //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
                            //FoundCustomerMap.put('AAI_'+account.NDG__c, account.Id);
                            FoundCustomerMap.put('AAI_'+account.NDG__c, account);
                    //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END 

                }
              	if(!AccountIds.isEmpty()){
            		for(Contact c : [Select Id, Account.NDG__c, Account.Fiscal_ID__c from Contact where AccountId in: AccountIds]){
                		if(String.isNotBlank(c.account.Fiscal_ID__c) && !IdentifierToContactId.containsKey('MPS_'+c.account.Fiscal_ID__c))
                    
                			IdentifierToContactId.put('MPS_'+c.account.Fiscal_ID__c, c.Id);
                   
                		else if(String.isNotBlank(c.account.NDG__c) && !IdentifierToContactId.containsKey('AAI_'+c.account.NDG__c))
                    
                    		IdentifierToContactId.put('AAI_'+c.account.NDG__c, c.Id);
            		}    
        		}
            }
            else
            {
                FoundLeads = [SELECT Id, Fiscal_ID__c, Phone, MobilePhone, Email, IsConverted
                FROM Lead
                WHERE Status NOT IN (:AP_Constants.leadStatusDuplicate)
                AND IsConverted = false
                AND Owner.Name != :AP_Constants.leadQueueWebDuplicati
                AND (Fiscal_ID__c IN:CustIdentifier
                OR Phone IN:phoneIdentifier
                OR MobilePhone IN:phoneIdentifier
                OR Email IN:emailIdentifier)
                ];
                Set<String> FoundDuplicate = new Set<String>();

                if(!FoundLeads.isEmpty())
                {

                    for(Lead FoundLead:FoundLeads)
                    {
                        if(String.isNotBlank(FoundLead.Fiscal_ID__c)){
                            if(FoundLeadMap.containsKey(FoundLead.Fiscal_ID__c)){
                                FoundDuplicate.add(FoundLead.Fiscal_ID__c);
                            }
                            else
                            {
                                FoundLeadMap.put(FoundLead.Fiscal_ID__c, FoundLead.Id);
                            }

                        }
                        if(String.isNotBlank(FoundLead.Phone)){
                            if(FoundLeadMap.containsKey(FoundLead.Phone)){
                                FoundDuplicate.add(FoundLead.Phone);
                            }
                            else
                            {
                                FoundLeadMap.put(FoundLead.Phone, FoundLead.Id);
                            }
                        }
                        if(String.isNotBlank(FoundLead.MobilePhone)){
                            if(FoundLeadMap.containsKey(FoundLead.MobilePhone)){
                                FoundDuplicate.add(FoundLead.MobilePhone);
                            }
                            else{
                                FoundLeadMap.put(FoundLead.MobilePhone, FoundLead.Id);
                            }

                        }
                        if(String.isNotBlank(FoundLead.Email)){
                            if(FoundLeadMap.containsKey(FoundLead.Email)){
                                FoundDuplicate.add(FoundLead.Email);
                            }
                            else
                            {
                                FoundLeadMap.put(FoundLead.Email, FoundLead.Id);
                            }
                        }
                    }
                }
                if(!FoundDuplicate.isEmpty())
                {
                    for(String s:FoundDuplicate)
                        FoundLeadMap.remove(s);
                }
                system.debug('FoundLeadMap: '+FoundLeadMap);
            }
            //OAVERSANO 09/07/2018 Close The Loop ICF -- END
        }

        Integer iCountCaseService=0;
        Integer iCountFdbkService = 0;
        //MMOSCATELLI 09/06/2017: EVO 86 --END

        Integer iCountCase = 0;
        Integer iCountFdbk = 0;
        String  FeedbackComment='';//MMOSCATELLI 06/04/2017: CTL Change Request

        //OAVERSANO 25/09/2018 : ICF Close The Loop -- START
        List<QueueSobject> PilotQueues = new List<QueueSobject>();
        Map<String, String> QueueDEVNameIdMap = new Map<String, String>();
        String queuePreDevName = 'Coda_Agenzia_Case_';
        Set<String> pilotAgenciesSet = new Set<String>();
        //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
        Boolean SendSurveyClaimToAgency = (MPS_Code_Variables__c.getInstance('SendSurveyClaimToAgency') != null && MPS_Code_Variables__c.getInstance('SendSurveyClaimToAgency').value__c=='true')?true:false;
        Boolean SendSurveyAcquistoToAgency = (MPS_Code_Variables__c.getInstance('SendSurveyAcquistoToAgency') != null && MPS_Code_Variables__c.getInstance('SendSurveyAcquistoToAgency').value__c=='true')?true:false;
        Boolean SendSurveyCheckINToAgency = (MPS_Code_Variables__c.getInstance('SendSurveyCheckINToAgency') != null && MPS_Code_Variables__c.getInstance('SendSurveyCheckINToAgency').value__c=='true')?true:false;
        //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END

        List<MPS_Code_Utils__mdt> mpsList = [SELECT Id, DeveloperName, Value__c, High_Volume_Values__c // NOPMD  Fix CRUD violation
        FROM MPS_Code_Utils__mdt
        WHERE DeveloperName LIKE '%CloseTheLoop%' 
        ];

        for(MPS_Code_Utils__mdt mps : mpsList)
        {
            if(mps.DeveloperName == 'CloseTheLoop_AgenciesAvailable')
            {
                if(String.isNotBlank(mps.High_Volume_Values__c))
                {
                    for(String s:mps.High_Volume_Values__c.split(';'))
                    {
                        pilotAgenciesSet.add(queuePreDevName+s);
                    }
                }
            }
        }


        /*if(MPS_Code_Variables__c.getValues('CloseTheLoop_AgenciesAvailable')!=null)
        {
            if(String.isNotBlank(MPS_Code_Variables__c.getValues('CloseTheLoop_AgenciesAvailable').value__c))
            {
                for(String s:(MPS_Code_Variables__c.getValues('CloseTheLoop_AgenciesAvailable').value__c).split(';'))
                {
                    pilotAgenciesSet.add(queuePreDevName+s);                
                }
            }
        }*/

        if(SendSurveyAcquistoToAgency || SendSurveyClaimToAgency)
        {
            if(!pilotAgenciesSet.IsEmpty())
            {
                PilotQueues = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName IN :pilotAgenciesSet ]; // NOPMD  Fix CRUD violation
                if(!PilotQueues.IsEmpty())
                {
                    for(QueueSobject q:PilotQueues)
                    {
                        QueueDEVNameIdMap.put(q.Queue.DeveloperName, q.Queue.Id);
                    }
                }
            }
            else
            {
                for(QueueSobject so: [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName LIKE 'Coda_Agenzia_Case_%' ]) // NOPMD  Fix CRUD violation
                {
                    QueueDEVNameIdMap.put(so.Queue.DeveloperName, so.Queue.Id);
                }
            }
        }
        //OAVERSANO 25/09/2018 : ICF Close The Loop -- END

        for(Feedback__c feedback :FeedbackList)
        {
            system.debug('##Type: '+feedback.Recordtype.Name);
            //MMOSCATELLI 09/06/2017: EVO 86 --START

            //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
            //if(feedback.RecordtypeId == MapFeedbackRecordType.get(Ap_Constants.rtClaimSurveyFeedback))
            if((feedback.RecordtypeId == MapFeedbackRecordType.get(Ap_Constants.rtClaimSurveyFeedback)) ||
                    (feedback.RecordtypeId == MapFeedbackRecordType.get(Ap_Constants.rtAcquistoSurveyFeedback)))
            //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END
            {
                Feedback__c UpdateFeedback = new Feedback__c(Id=feedback.id);

                //MMOSCATELLI 06/04/2017: CTL Change Request -- START
                if(String.isNotBlank(feedback.FeedbackComments__c))
                {
                    FeedbackComment=(feedback.FeedbackComments__c).normalizeSpace();
                    UpdateFeedback.FeedbackComments__c = FeedbackComment;
                }

                //OAVERSANO 16/07/2018 Close the loop ICF -- START
                /*if(String.isNotBlank(feedback.Agent_ID__c))
                {
                    if(userAgentIDMAP.containsKey(feedback.Agent_ID__c)){
                      UpdateFeedback.Questionario_richiesto_da__c  = userAgentIDMAP.get(feedback.Agent_ID__c);
                    }
                    
                } */
                //OAVERSANO 16/07/2018 Close the loop --END

                //update : puting the label intest of value on case origin
                Map<String, String> valueMap_surveyOrigin_label = new Map<String,String>();
                Map<String, String> valueMap_surveyOriginFeedback_label = new Map<String,String>();

                valueMap_surveyOrigin_label = UtilityClass.getPicklistValueOnlyActive(new Feedback__c(), 'Survey_Origin__c');
                valueMap_surveyOriginFeedback_label = UtilityClass.getPicklistLabels(new Case(), 'Category__c');
    

                String originCategori = valueMap_surveyOriginFeedback_label.containsKey(feedback.Survey_Origin__c) ? valueMap_surveyOriginFeedback_label.get(feedback.Survey_Origin__c) : feedback.Survey_Origin__c;
               
                system.debug('##FeedbackComment: '+feedback.FeedbackComments__c+'   '+FeedbackComment);
                system.debug('##id: '+feedback.RecordTypeId+' ##mapresult: '+MapFeedbackRecordType);
                //MMOSCATELLI 06/04/2017: CTL Change Request -- END                       

                Case CDLCase = new Case(RecordtypeId=MapCaseRecordType.get(Ap_Constants.rtCaseCloseTheLoop),
                        Complainant__c =Ap_Constants.rtCaseCustComp,
                        Distribution_Network__c=(feedback.Company__c=='MPS')?'MPS':'Axa Assicurazioni',
                        Category__c=(String.isNotBlank(feedback.TECH_Case_Category__c))?feedback.TECH_Case_Category__c:originCategori,
                        SubCategory__c=(String.isNotBlank(feedback.TECH_Case_Subcategory__c))?feedback.TECH_Case_Subcategory__c:'',
                        SubCategoryDetail__c=(String.isNotBlank(feedback.TECH_Case_detail__c))?feedback.TECH_Case_detail__c:'',
                        TECH_CTL_Codice_Sottonodo__c = feedback.TECH_Sottonodo__c,
                        //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
                        //Origin=Ap_Constants.caseOriginClaim,
                        Origin=(feedback.RecordTypeId==MapFeedbackRecordType.get(Ap_Constants.rtClaimSurveyFeedback))?Ap_Constants.caseOriginClaim:Ap_Constants.caseOriginsurveyRinnovo,
                        //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END
                        Claim_Number__c=feedback.Claim_number__c,
                        Status = Ap_Constants.caseStatusOpen,
                        SuppliedEmail=(String.isNotBlank(feedback.Email__c))?feedback.Email__c:'',
                        Oggetto_Apertura_Case__c = String.isNotBlank(feedback.Survey_Origin__c) ? feedback.Survey_Origin__c:originCategori,
                        //OAVERSANO 04/07/2018: Close the Loop ICF -- START
                        Agency_Code__c = (String.isNotBlank(feedback.Agency_Code__c))?feedback.Agency_Code__c:'',
                        //OAVERSANO 04/07/2018: Close the Loop ICF -- END
                        TECH_CTL_FeedbackComment__c = (String.isNotBlank(feedback.FeedbackComments__c))?feedback.FeedbackComments__c:'', //OAVERSANO 24/10/2018 : ICF CLose The Loop
                        TechNPS__c =  (feedback.NPS__c!=null)?feedback.NPS__c:null,
                        Health_Name__c=feedback.Health_Name__c,
                        Health_Surname__c=feedback.Health_Surname__c,
                        Health_Mobile_Phone__c=feedback.Health_Mobile_Phone__c,
                        Health_Fiscal_Code__c=feedback.Health_Fiscal_Code__c
                );
                //OAVERSANO 25/09/2018 : ICF Close The Loop -- START

                //MMOSCATELLI 28/03/2019: ICF CR2 -- START
                if(CDLCase.Origin ==Ap_Constants.caseOriginsurveyRinnovo)
                    CDLCase = ServiceUtilsClass.setAgentICFAlerts(CDLCase,defaultHoursId);
                //MMOSCATELLI 28/03/2019: ICF CR2 -- END

                if(String.isNotBlank(feedback.Agency_Code__c) && 
                    getIfCaseGoesToAgency(feedback, SendSurveyAcquistoToAgency, SendSurveyClaimToAgency,
                    SendSurveyCheckINToAgency,MapFeedbackRecordType))// *-+ :05/05/2022 ID IDCRM021 Evolutiva gestione feedback Survey
                {
                     if(QueueDEVNameIdMap.containsKey(queuePreDevName+feedback.Agency_Code__c))
                    {
                        //bugfix checkIn *-+ 22-06-2022 fill ICF_Agent_Alert_1 and 2
                        CDLCase = ServiceUtilsClass.setAgentICFAlerts(CDLCase,defaultHoursId);
                        
                        CDLCase.OwnerId = QueueDEVNameIdMap.get(queuePreDevName+feedback.Agency_Code__c);
                        CDLCase.CTL_da_agenzia__c = true;
                        CDLCase.Status = AP_Constants.caseStatusGestioneAgente;
                        if(CDLCase.TECH_Secondo_Sollecito_Agenti__c!=null)
                            CDLCase.Limite_Attivit_CTL_Agenti__c = CDLCase.TECH_Secondo_Sollecito_Agenti__c.format('dd/MM/yyyy HH:mm');
                    }
                    else
                            CDLCase.setOptions(dmlOpts);
                }
                else
                        CDLCase.setOptions(dmlOpts);
                //OAVERSANO 25/09/2018 : ICF Close The Loop -- END

                //MMOSCATELLI 27/03/2019: ICF CR 2--START
                String ColoredNPS = '';

                if(feedback.NPS__c!=null)
                {
                    if(Integer.valueOf(feedback.NPS__c)>=9)
                    {
                        ColoredNPS = '<span style="color:green"><b>'+Integer.valueOf(feedback.NPS__c)+'/10 PROMOTORE</b></span>';
                    }
                    else if(Integer.valueOf(feedback.NPS__c)>=7 && Integer.valueOf(feedback.NPS__c)<=8)
                    {
                        ColoredNPS = '<span style="color:orange"><b>'+Integer.valueOf(feedback.NPS__c)+'/10 PASSIVO</b></span>';
                    }
                    else
                    {
                        ColoredNPS = '<span style="color:red"><b>'+Integer.valueOf(feedback.NPS__c)+'/10 DETRATTORE</b></span>';
                    }
                }
                //MMOSCATELLI 27/03/2019: ICF CR 2--END

                if(feedback.Company__c == 'AAI')
                {
                    if(FoundCustomerMap.containsKey('AAI_'+feedback.NDG__c))
                    {
                        //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START 
                        //if(String.isNotBlank(FoundCustomerMap.get('AAI_'+feedback.NDG__c)))
                        if(String.isNotBlank(FoundCustomerMap.get('AAI_'+feedback.NDG__c).id))
                        //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END
                        {
                            //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
                            //Account UpdateAccount = new Account(Id=FoundCustomerMap.get('AAI_'+feedback.NDG__c),
                            Account UpdateAccount = new Account(Id=FoundCustomerMap.get('AAI_'+feedback.NDG__c).Id,
                                    //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END
                                    //OAVERSANO 04/07/2018: Close the Loop ICF -- START
                                    NPS__c = (feedback.NPS__c!=null)?feedback.NPS__c:null,

                                    Net_Promoter_Score_NPS__c = (String.isNotBlank(ColoredNPS))?ColoredNPS:''//MMOSCATELLI 27/03/2019: ICF CR 2
                                    //OAVERSANO 04/07/2018: Close the Loop ICF -- END
                            );
                            //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
                            /*UpdateFeedback.Account__c = FoundCustomerMap.get('AAI_'+feedback.NDG__c);
                            CDLCase.Accountid = FoundCustomerMap.get('AAI_'+feedback.NDG__c);*/
                            UpdateFeedback.Account__c = FoundCustomerMap.get('AAI_'+feedback.NDG__c).Id;
                            CDLCase.Accountid = FoundCustomerMap.get('AAI_'+feedback.NDG__c).Id;
                            //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END

                            if(IdentifierToContactId.containsKey('AAI_'+feedback.NDG__c) && String.isNotBlank(IdentifierToContactId.get('AAI_'+feedback.NDG__c)))
                                UpdateFeedback.TECH_PersonContactId__c = IdentifierToContactId.get('AAI_'+feedback.NDG__c);
                            if(!feedback.is_Corporate_Customer__c){
                                if(String.isNotBlank(feedback.Mobile_Phone__c))
                                    UpdateAccount.Claim_PersonalMobile__c = feedback.Mobile_Phone__c;
                                if(String.isNotBlank(feedback.Email__c))
                                    UpdateAccount.Claim_PersonalEmail__c = feedback.Email__c;
                            }
                            else UpdateAccount.Net_Promoter_Score_NPS__c=null;
                            //Change - 4 ggu - Feedback Management - modifica per Account particolari #387
                            if(!EXCLUDED_ACCOUNTS_NDG.contains(feedback.NDG__c)){
                                AccountsToUpdate.add(UpdateAccount);
                            }
                        }
                    }
                }
                else
                {
                    if(FoundCustomerMap.containsKey('MPS_'+feedback.Fiscal_ID__c))
                    {
                        //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
                        //if(String.isNotBlank(FoundCustomerMap.get('MPS_'+feedback.Fiscal_ID__c)))
                        if(String.isNotBlank(FoundCustomerMap.get('MPS_'+feedback.Fiscal_ID__c).Id))
                        //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END
                        {
                            //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
                            //Account UpdateAccount = new Account(Id=FoundCustomerMap.get('MPS_'+feedback.Fiscal_ID__c),
                            Account UpdateAccount = new Account(Id=FoundCustomerMap.get('MPS_'+feedback.Fiscal_ID__c).Id,
                                    //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
                                    //OAVERSANO 04/07/2018: Close the Loop ICF -- START
                                    NPS__c = (feedback.NPS__c!=null)?feedback.NPS__c:null,
                                    Net_Promoter_Score_NPS__c = (String.isNotBlank(ColoredNPS))?ColoredNPS:''//MMOSCATELLI 27/03/2019: ICF CR 2
                                    //OAVERSANO 04/07/2018: Close the Loop ICF -- END
                            );

                            //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
                            /*UpdateFeedback.Account__c = FoundCustomerMap.get('MPS_'+feedback.Fiscal_ID__c);
                            CDLCase.Accountid = FoundCustomerMap.get('MPS_'+feedback.Fiscal_ID__c);*/
                            UpdateFeedback.Account__c = FoundCustomerMap.get('MPS_'+feedback.Fiscal_ID__c).Id;
                            CDLCase.Accountid = FoundCustomerMap.get('MPS_'+feedback.Fiscal_ID__c).Id;
                            //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END
							if(IdentifierToContactId.containsKey('MPS_'+feedback.Fiscal_ID__c) && String.isNotBlank(IdentifierToContactId.get('MPS_'+feedback.Fiscal_ID__c)))
                                UpdateFeedback.TECH_PersonContactId__c = IdentifierToContactId.get('MPS_'+feedback.Fiscal_ID__c);
                            if(!feedback.is_Corporate_Customer__c){
                                if(String.isNotBlank(feedback.Mobile_Phone__c))
                                    UpdateAccount.Claim_PersonalMobile__c = feedback.Mobile_Phone__c;
                                if(String.isNotBlank(feedback.Email__c))
                                    UpdateAccount.Claim_PersonalEmail__c = feedback.Email__c;
                            }
                            else UpdateAccount.Net_Promoter_Score_NPS__c=null;
                            AccountsToUpdate.add(UpdateAccount);
                        }
                    }
                }

                //OAVERSANO 09/07/2018 Close The Loop ICF -- START
                if(String.isBlank(CDLCase.AccountId))
                {
                    List<String> fieldList = new List<String>{'Fiscal_ID__c','Mobile_Phone__c','Email__c'};
                    for(String field:fieldList)
                    {
                        if(String.isNotBlank(FoundLeadMap.get( (String) feedback.get(field))))
                        {
                            CDLCase.Lead__c = FoundLeadMap.get( (String) feedback.get(field));
                            UpdateFeedback.Lead__c = FoundLeadMap.get( (String) feedback.get(field));
                            break;
                        }
                    }
                    if(String.isBlank(CDLCase.Lead__c))
                        CDLCase.Description = 'Dati Cliente'+'\n'+'\n'+'NDG: '+((String.isNotBlank(feedback.NDG__c))?feedback.NDG__c:'')+'\n'+'Codice Fiscale: '+((String.isNotBlank(feedback.Fiscal_ID__c))?feedback.Fiscal_ID__c:'')+'\n'+'Telefono: '+((String.isNotBlank(feedback.Mobile_Phone__c))?feedback.Mobile_Phone__c:'')+'\n'+'Email: '+((String.isNotBlank(feedback.Email__c))?feedback.Email__c:'');

                }
                FeedbackToUpdateList.add(UpdateFeedback);
                //OAVERSANO 09/07/2018 Close The Loop ICF -- END  
                if(feedback.CDL_needed__c)
                {
                    CaseToInsert.add(CDLCase);
                    MapIndexCaseToIndexFdbk.put(iCountCase, iCountFdbk);
                    iCountCase++;
                }
                //falso  ..but is posite and has a comment ..email auto ticked 265-- 28-10-2021 *-+
                else if (!feedback.CDL_needed__c && String.isNotBlank(feedback.FeedbackComments__c) 
                         && valueMap_surveyOrigin_label.get(feedback.Survey_Origin__c) == 'Sinistri Check IN' ){
                    PositiveAgencyFeedbacks.add(feedback);
                }
                //MOSCATELLI_M 07/11/2018: CTL Acquisto --  START
                // else if(feedback.FeedbackComments__c != null ||(feedback.FeedbackComments__c == null && feedback.NPS__c <6) && feedback.RecordtypeId == MapFeedbackRecordType.get(Ap_Constants.rtAcquistoSurveyFeedback)) // *** DP 12/08 Modifica invio email ticket #20
                else if(feedback.RecordtypeId == MapFeedbackRecordType.get(Ap_Constants.rtAcquistoSurveyFeedback))
                {
                    if(feedback.Invio_Notifica__c || FeedbackNewOrigins.contains(feedback.Survey_Origin__c))
                    {
                    PositiveAgencyFeedbacks.add(feedback);
                    system.debug('+++PositiveAgencyFeedbacks:' + PositiveAgencyFeedbacks + 'PositiveAgencyFeedbacks Comment:' + feedback.FeedbackComments__c);
                    }
                }
                //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END
                iCountFdbk++;
            }
            else if(!SetEnableFunc.contains('FeedbackManagement'))
            {
                Feedback__c CTLFeedback = new Feedback__c(Id=feedback.id);
                FeedbackToUpdateListService.add(CTLFeedback);

                Case CTLCase = new Case(RecordtypeId=MapCaseRecordType.get(Ap_Constants.rtCaseCloseTheLoop),
                        Complainant__c =RelatedCasesMap.get(feedback.Complaint__c).Complainant__c,
                        Distribution_Network__c=RelatedCasesMap.get(feedback.Complaint__c).Distribution_Network__c,
                        LinktoPolicy__c=RelatedCasesMap.get(feedback.Complaint__c).LinktoPolicy__c,
                        AgentName__c = RelatedCasesMap.get(feedback.Complaint__c).AgentName__c,
                        Origin=feedback.Survey_Origin__c,
                        Status = Ap_Constants.caseStatusOpen,
                        AccountId = RelatedCasesMap.get(feedback.Complaint__c).AccountId,
                        SuppliedEmail = RelatedCasesMap.get(feedback.Complaint__c).SuppliedEmail,
                        ParentId = RelatedCasesMap.get(feedback.Complaint__c).Id,
                        TECH_CTL_Codice_Sottonodo__c = feedback.TECH_Sottonodo__c,
                        TECH_CTL_FeedbackComment__c = (String.isNotBlank(feedback.FeedbackComments__c))?feedback.FeedbackComments__c:'',
                        Health_Name__c=feedback.Health_Name__c,
                        Health_Surname__c=feedback.Health_Surname__c,
                        Health_Mobile_Phone__c=feedback.Health_Mobile_Phone__c,
                        Health_Fiscal_Code__c=feedback.Health_Fiscal_Code__c); //OAVERSANO 24/10/2018 : ICF CLose The Loop
                //OAVERSANO 25/09/2018 : ICF Close The Loop -- START
                /* if(String.isNotBlank(feedback.Agency_Code__c) && originAcquistoRinnovoCTLSet.contains(feedback.Survey_Origin__c))
                 {
                   if(QueueDEVNameIdMap.containsKey(queuePreDevName+feedback.Agency_Code__c))
                   {
                     CTLCase.OwnerId = QueueDEVNameIdMap.get(queuePreDevName+feedback.Agency_Code__c);
                         CTLCase.CTL_da_agenzia__c = true;
                   }
                   else
             CTLCase.setOptions(dmlOpts);
                 }
                 else*/
                CTLCase.setOptions(dmlOpts);
                //OAVERSANO 25/09/2018 : ICF Close The Loop -- END

                CaseToInsertCTLService.add(CTLCase);
                MapIndexCaseToIndexFdbkService.put(iCountCaseService,iCountFdbkService);
                iCountCaseService++;
                iCountFdbkService++;
            }
            //MMOSCATELLI 09/06/2017: EVO 86 --END
        }

        system.debug('##MapIndexCaseToIndexFdbk: '+MapIndexCaseToIndexFdbk);
        List<ApplicationLogHelper.ErrorWrapper> Errors = new List<ApplicationLogHelper.ErrorWrapper>();

        if(CaseToInsert.size()>0)
        {
            Database.SaveResult[] srList = Database.insert(CaseToInsert, false);

            for (integer i=0;i<srList.size();i++)
            {
                if (srList[i].isSuccess())
                {
                    FeedbackToUpdateList[MapIndexCaseToIndexFdbk.get(i)].Complaint__c = srList[i].id;
                    FeedbackToUpdateList[MapIndexCaseToIndexFdbk.get(i)].CTL_Case__c = srList[i].id;//MMOSCATELLI 09/06/2017: EVO 86
                }
                else
                {
                    for(Database.Error err : srList[i].getErrors())
                    {
                        //system.debug('@@Errors on case creation: '+srList[i].getErrors());
                        //ApplicationLogHelper.ERROR('FeedbackManagement', err.getMessage(), JSON.serialize(err.getFields()));
                        Errors.add(new ApplicationLogHelper.ErrorWrapper('FeedbackManagement', err.getMessage()+JSON.serialize(err.getFields())));
                        MapIndexCaseToIndexFdbk.remove(i);
                    }
                    if(!Errors.isEmpty())
                    ApplicationLogHelper.LogErrors('FeedbackManagement', Errors);   
                }
            }
        }

        for(integer i=0;i<FeedbackToUpdateList.size();i++)
        {
            if(String.isBlank(FeedbackToUpdateList[i].Complaint__c) && String.isBlank(FeedbackToUpdateList[i].Account__c))
                FeedbackToUpdateList.remove(i);
        }

        if(FeedbackToUpdateList.size()>0)
        {
            Savepoint sp = Database.setSavepoint();

            try
            {
                Update FeedbackToUpdateList;
            }
            catch(exception ex)
            {
                Database.rollback(sp);
                ApplicationLogHelper.ERROR('FeedbackManagement', ex.getmessage(), ex.getStackTraceString());
                system.debug('Error: '+ex.getmessage());
            }
        }

        if(AccountsToUpdate.size()>0)
        {
            Savepoint sp = Database.setSavepoint();

            try
            {
                //avoid duplicates in list
                //Change - 4 ggu - Feedback Management - modifica per Account particolari #387
                Set<Account> accountsToUpdateSet = new Set<Account>();
                List<Account> accountsToUpdateList = new List<Account>();
                accountsToUpdateSet.addAll(AccountsToUpdate);
                accountsToUpdateList.addAll(accountsToUpdateSet);
                update accountsToUpdateList;
            }
            catch(exception ex)
            {
                Database.rollback(sp);
                ApplicationLogHelper.ERROR('FeedbackManagement', ex.getmessage(), ex.getStackTraceString());
                system.debug('Error: '+ex.getmessage());
            }
        }

        //MMOSCATELLI 09/06/2017: EVO 86 --START
        if(CaseToInsertCTLService.size()>0)
        {
            //Database.SaveResult[] srList = Database.insert(CaseToInsertCTLService, false);
            Database.SaveResult[] srList = Database.insert(CaseToInsertCTLService, false);

            for (integer i=0;i<srList.size();i++)
            {
                if (srList[i].isSuccess())
                {
                    FeedbackToUpdateListService[MapIndexCaseToIndexFdbkService.get(i)].CTL_Case__c = srList[i].id;
                }
                else
                {
                    for(Database.Error err : srList[i].getErrors())
                    {
                        //ApplicationLogHelper.ERROR('FeedbackManagement', err.getMessage(), JSON.serialize(err.getFields()));
                        Errors.add(new ApplicationLogHelper.ErrorWrapper('FeedbackManagement', err.getMessage()+JSON.serialize(err.getFields())));
                        MapIndexCaseToIndexFdbkService.remove(i);
                    }
                    if(!Errors.isEmpty())
                    ApplicationLogHelper.LogErrors('FeedbackManagement', Errors);   
                }
            }
        }

        if(FeedbackToUpdateListService.size()>0)
        {
            Savepoint sp = Database.setSavepoint();

            try
            {
                Update FeedbackToUpdateListService;
            }
            catch(exception ex)
            {
                Database.rollback(sp);
                ApplicationLogHelper.ERROR('FeedbackManagement', ex.getmessage(), ex.getStackTraceString());
                system.debug('Error: '+ex.getmessage());
            }
        }
        //MMOSCATELLI 09/06/2017: EVO 86 --END


        //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
        if(!PositiveAgencyFeedbacks.isEmpty() && NotifActive)
            SendEmailNotification(PositiveAgencyFeedbacks,FoundCustomerMap);
        //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END
    }
    //MMOSCATELLI 09/02/2017: Close the loop ICF -- END  

    //MOSCATELLI_M 07/11/2018: CTL Acquisto -- START
    public static void SendEmailNotification(List<Feedback__c> FeedbackList, Map<String,Account> FoundCustomerMap)
    {
        String OrgEmail    = MPS_Code_Variables__c.getInstance('CTL_Template_Positive_Feedback_Email').value__c;
        String EmailTemplateName = MPS_Code_Variables__c.getInstance('CTL_Template_Positive_Feedback').value__c;
        String CustomersName='';

        if(String.isNotBlank(OrgEmail) && String.isNotBlank(EmailTemplateName))
        {
            List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
            EmailTemplate etem = [Select Subject,Body,HtmlValue From EmailTemplate where DeveloperName =: EmailTemplateName ]; // NOPMD  Fix CRUD violation

            String Agency = '';

            String url = '';
            String urlNFE = '';
            url = [SELECT OrgLink__c
            FROM Modello_di_Assistenza__mdt
            WHERE DeveloperName = 'RedirectCommunity'
            LIMIT 1].OrgLink__c;
            
            urlNFE = [SELECT OrgLink__c
            FROM Modello_di_Assistenza__mdt
            WHERE DeveloperName = 'RedirectCommunityNFE'
            LIMIT 1].OrgLink__c;


            //OAVERSANO 22/03/2019 : FIX too many query -- START
            Set<String> agencyList = new Set<String>();
            for(Feedback__c f:FeedbackList)
            {
                agencyList.add('Coda Agenzia Case '+f.Agency_Code__c);
            }
            List<GroupMember> groupMembers = [SELECT Group.Name, UserOrGroupId FROM GroupMember WHERE Group.Name IN:agencyList ]; // NOPMD  Fix CRUD violation
            Map<String, Set<Id>> mapAgencyUsers = new Map<String, Set<Id>>();
            Set<Id> allUsers = new Set<Id>();
            Set<Id> activeUsers = new Set<Id>();
            Map<Id, User> mapActiveAgencyUsers = new Map<Id, User>();
            Map<String,List<String>> mapAgencyUsersEmail = new Map<String, List<String>>();
            for(GroupMember GM:groupMembers)
            {
                if((String.valueOf(GM.UserOrGroupId)).startsWithIgnoreCase('005'))
                {
                    allUsers.add(GM.UserOrGroupId);
                }
            }
            List<User> activeUserList = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.Destinatario_notifica_Feedback_Case__c // NOPMD  Fix CRUD violation
                                         FROM User 
                                         WHERE Id IN:allUsers AND IsActive = true ];
            for(User us:activeUserList)
            {
                activeUsers.add(us.Id);
                mapActiveAgencyUsers.put(us.Id, us);
            }
            for(GroupMember GM:groupMembers)
            {
                if(activeUsers.contains(GM.UserOrGroupId))
                {
                    if(mapAgencyUsers.containsKey(GM.Group.Name))
                    {
                        Set<Id> agencyUsersSet = mapAgencyUsers.get(GM.Group.Name);
                        agencyUsersSet.add(GM.UserOrGroupId);
                        mapAgencyUsers.put(GM.Group.Name, agencyUsersSet);
                        if (mapActiveAgencyUsers.get(GM.UserOrGroupId).ContactId != null 
                            && mapActiveAgencyUsers.get(GM.UserOrGroupId).Contact.AccountId != null 
                            && mapActiveAgencyUsers.get(GM.UserOrGroupId).Contact.Account.Destinatario_notifica_Feedback_Case__c != null
                            && mapActiveAgencyUsers.get(GM.UserOrGroupId).Contact.Account.Destinatario_notifica_Feedback_Case__c != '') {
                        	mapAgencyUsersEmail.put(GM.Group.Name, mapActiveAgencyUsers.get(GM.UserOrGroupId).Contact.Account.Destinatario_notifica_Feedback_Case__c.split(';'));
                        }
                    }
                    else
                    {
                        mapAgencyUsers.put(GM.Group.Name, new Set<Id> { GM.UserOrGroupId });
                        if (mapActiveAgencyUsers.get(GM.UserOrGroupId).ContactId != null 
                            && mapActiveAgencyUsers.get(GM.UserOrGroupId).Contact.AccountId != null 
                            && mapActiveAgencyUsers.get(GM.UserOrGroupId).Contact.Account.Destinatario_notifica_Feedback_Case__c != null
                            && mapActiveAgencyUsers.get(GM.UserOrGroupId).Contact.Account.Destinatario_notifica_Feedback_Case__c != '') {
                        	mapAgencyUsersEmail.put(GM.Group.Name, mapActiveAgencyUsers.get(GM.UserOrGroupId).Contact.Account.Destinatario_notifica_Feedback_Case__c.split(';'));
                        }
                    }
                }
            }
            if(!mapAgencyUsers.containsKey(null))
                system.debug('mapAgencyUsers: '+JSON.serializePretty(mapAgencyUsers));
            //OAVERSANO 22/03/2019 : FIX too many query -- END

            Map<String, String> valueMap = new Map<String,String>();
            valueMap = UtilityClass.getPicklistValue(new feedback__c(), 'Survey_Origin__c');


            for(Feedback__c f:FeedbackList)
            {
                String origin = valueMap.containsKey(f.Survey_Origin__c) ? valueMap.get(f.Survey_Origin__c) : f.Survey_Origin__c;
                Agency = 'Coda Agenzia Case '+f.Agency_Code__c;

                CustomersName='';

                if(f.Company__c == 'AAI')
                {
                    if(FoundCustomerMap.containsKey('AAI_'+f.NDG__c))
                    {
                        if(String.isNotBlank(FoundCustomerMap.get('AAI_'+f.NDG__c).Id))
                            CustomersName=FoundCustomerMap.get('AAI_'+f.NDG__c).Name;
                    }
                }
                else
                {
                    if(FoundCustomerMap.containsKey('MPS_'+f.Fiscal_ID__c))
                    {
                        if(String.isNotBlank(FoundCustomerMap.get('MPS_'+f.Fiscal_ID__c).Id))
                            CustomersName=FoundCustomerMap.get('MPS_'+f.Fiscal_ID__c).Name;
                    }
                }
                //OAVERSANO 22/03/2019 : FIX too many query -- START
                //OAVERSANO 20/12/2018 : FIX email to inactive users -- START
                /*List<GroupMember> groupMembers = [select UserOrGroupId from GroupMember where Group.Name =:Agency];
                Set<Id> gmIdSet = new Set<Id>();
                for(GroupMember GM:groupMembers)
                {
                  gmIdSet.add(GM.UserOrGroupId);
                }
                //for(GroupMember GM: [select UserOrGroupId from GroupMember where Group.Name =:Agency])
                for(User GM: [SELECT Id FROM User WHERE Id IN:gmIdSet AND IsActive = true])*/
                if(mapAgencyUsers.containsKey(Agency))
                {
                    for(String GM: mapAgencyUsers.get(Agency)) {
                        //OAVERSANO 20/12/2018 : FIX email to inactive users -- END
                        //OAVERSANO 22/03/2019 : FIX too many query -- END
                        if (mapAgencyUsersEmail.get(Agency) != null) {
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            String htmlBody = etem.HtmlValue;
                            String subject = etem.Subject;
                            String body    = etem.body;
                            
                            subject  = subject.replace('#OrigineSurvey', ((origin).indexOf('Survey')<>-1)?(origin).substringAfter('Survey'):origin);

                            htmlBody = htmlBody.replace('#Cliente', (String.isNotBlank(CustomersName))?CustomersName:((String.isNotBlank(f.NDG__c))?f.NDG__c:((String.isNotBlank(f.Fiscal_ID__c))?f.Fiscal_ID__c:'')));
                            body     = body.replace('#Cliente', (String.isNotBlank(CustomersName))?CustomersName:((String.isNotBlank(f.NDG__c))?f.NDG__c:((String.isNotBlank(f.Fiscal_ID__c))?f.Fiscal_ID__c:'')));
                            htmlBody = htmlBody.replace('#OrigineSurvey', origin);
                            body     = body.replace('#OrigineSurvey', origin);
                            htmlBody = htmlBody.replace('#Agenzia', f.Agency_Code__c == null ? '':f.Agency_Code__c);
                            body     = body.replace('#Agenzia', f.Agency_Code__c == null ? '':f.Agency_Code__c);
                            // #278 -- Non Presente if is blank 26-01-2022 *-+
                            htmlBody = htmlBody.replace('#Sottonodo',  String.isBlank(f.TECH_Sottonodo__c)?' Non Presente':f.TECH_Sottonodo__c);
                            body     = body.replace('#Sottonodo',  String.isBlank(f.TECH_Sottonodo__c)?' Non Presente':f.TECH_Sottonodo__c);
                            // #278 -- Non Presente if is blank 26-01-2022 *-+
                            htmlBody = htmlBody.replace('#CommentoCliente', String.isNotBlank(f.FeedbackComments__c)?f.FeedbackComments__c:' Non Presente');
                            body     = body.replace('#CommentoCliente', String.isNotBlank(f.FeedbackComments__c)?f.FeedbackComments__c:' Non Presente');
                            htmlBody = htmlBody.replace('#FeedbackNumber', f.Name);
                            body     = body.replace('#FeedbackNumber', f.Name);
                            //NPS non presente on origin Sinistri Check In 10-2021 *-+
                            if(origin == 'Sinistri Check IN'){
                                htmlBody = htmlBody.replace('#NPS', String.isBlank(String.valueOf(f.NPS__c)) ?String.valueOf(' Non Presente'):'');
                                body     = body.replace('#NPS', String.isBlank(String.valueOf(f.NPS__c))  ?String.valueOf(' Non Presente'):'');
                            }else { // #278 -- Non Presente if is blank 26-01-2022 *-+
                            htmlBody = htmlBody.replace('#NPS', String.isBlank(String.valueOf(f.NPS__c))  ?String.valueOf(' Non Presente'):String.valueOf((integer)f.NPS__c));
                            body     = body.replace('#NPS', String.isBlank(String.valueOf(f.NPS__c))  ?String.valueOf(' Non Presente'):String.valueOf((integer)f.NPS__c));
                            }
                            htmlBody = htmlBody.replace('#Link1', url + f.Id);
                            htmlBody = htmlBody.replace('#Link2', urlNFE + f.Id);
                            body = body.replace('#Link2', urlNFE + f.Id);
                            //htmlBody = htmlBody.replace('#FbId', f.Name);
                            body     = body.replace('#Link1', url + f.Id);
                            htmlBody = htmlBody.replace('#NumeroFb', f.Name);
                            body     = body.replace('#NumeroFb', f.Name);
                            
                            email.setHtmlBody(htmlBody);
                            email.setSubject(subject);
                            email.saveAsActivity = false;
                            email.setOrgWideEmailAddressId(OrgEmail);
                            email.setToAddresses(mapAgencyUsersEmail.get(Agency));
                            
                            listEmail.add(email);
                            break;
                        } else {
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            String htmlBody = etem.HtmlValue;
                            String subject = etem.Subject;
                            String body    = etem.body;
                            
                            subject  = subject.replace('#OrigineSurvey', ((origin).indexOf('Survey')<>-1)?(origin).substringAfter('Survey'):origin);

                            htmlBody = htmlBody.replace('#Cliente', (String.isNotBlank(CustomersName))?CustomersName:((String.isNotBlank(f.NDG__c))?f.NDG__c:((String.isNotBlank(f.Fiscal_ID__c))?f.Fiscal_ID__c:'')));
                            body     = body.replace('#Cliente', (String.isNotBlank(CustomersName))?CustomersName:((String.isNotBlank(f.NDG__c))?f.NDG__c:((String.isNotBlank(f.Fiscal_ID__c))?f.Fiscal_ID__c:'')));
                            htmlBody = htmlBody.replace('#Agenzia', f.Agency_Code__c == null ? '':f.Agency_Code__c);
                            body     = body.replace('#Agenzia', f.Agency_Code__c == null ? '':f.Agency_Code__c);
                            // #278 -- Non Presente if is blank 26-01-2022 *-+
                            htmlBody = htmlBody.replace('#Sottonodo',  String.isBlank(f.TECH_Sottonodo__c)?' Non Presente':f.TECH_Sottonodo__c);
                            body     = body.replace('#Sottonodo',  String.isBlank(f.TECH_Sottonodo__c)?' Non Presente':f.TECH_Sottonodo__c);
                            htmlBody = htmlBody.replace('#OrigineSurvey', origin);
                            body     = body.replace('#OrigineSurvey', origin);
                            // #278 -- Non Presente if is blank 26-01-2022 *-+
                            htmlBody = htmlBody.replace('#CommentoCliente', String.isNotBlank(f.FeedbackComments__c)?f.FeedbackComments__c:' Non Presente');
                            body     = body.replace('#CommentoCliente', String.isNotBlank(f.FeedbackComments__c)?f.FeedbackComments__c:' Non Presente');
                            htmlBody = htmlBody.replace('#FeedbackNumber', f.Name);
                            body     = body.replace('#FeedbackNumber', f.Name);    
                            //NPS non presente on origin Sinistri Check In 10-2021 *-+
                            if(origin == 'Sinistri Check IN'){
                                htmlBody = htmlBody.replace('#NPS', String.isBlank(String.valueOf(f.NPS__c))  ?String.valueOf(' Non Presente'):'');
                                body     = body.replace('#NPS', String.isBlank(String.valueOf(f.NPS__c))  ?String.valueOf(' Non Presente'):'');
                            }else { // #278 -- Non Presente if is blank 26-01-2022 *-+
                            htmlBody = htmlBody.replace('#NPS', String.isBlank(String.valueOf(f.NPS__c)) ?String.valueOf(' Non Presente'):String.valueOf((integer)f.NPS__c));
                            body     = body.replace('#NPS', String.isBlank(String.valueOf(f.NPS__c)) ?String.valueOf(' Non Presente'):String.valueOf((integer)f.NPS__c));
                            }
                            htmlBody = htmlBody.replace('#Link1', url + f.Id);
                            htmlBody = htmlBody.replace('#Link2', urlNFE + f.Id);
                            body = body.replace('#Link2', urlNFE + f.Id);
                            //htmlBody = htmlBody.replace('#FbId', f.Name);
                            body     = body.replace('#Link1', url + f.Id);
                            htmlBody = htmlBody.replace('#Link', url + f.Id);
                            htmlBody = htmlBody.replace('#FbId', f.Name);
                            body     = body.replace('#Link', url + f.Id);
                            htmlBody = htmlBody.replace('#NumeroFb', f.Name);
                            body     = body.replace('#NumeroFb', f.Name);
                            
                            email.setHtmlBody(htmlBody);
                            email.setSubject(subject);
                            email.saveAsActivity = false;
                            email.setOrgWideEmailAddressId(OrgEmail);
                            //OAVERSANO 20/12/2018 : FIX email to inactive users -- START
                            //email.setTargetObjectId(GM.UserOrGroupId);
                            //email.setTargetObjectId(GM.Id);
                            //OAVERSANO 22/03/2019 : FIX too many query -- START
                            email.setTargetObjectId(GM);
                            //OAVERSANO 22/03/2019 : FIX too many query -- END
                            //OAVERSANO 20/12/2018 : FIX email to inactive users -- END
                            
                            listEmail.add(email);
                        }
                    }
                }
            }
            try
            {
                Messaging.SendEmailResult [] results = Messaging.sendEmail(listEmail);
            }
            catch(exception ex) 
            {
                ApplicationLogHelper.ERROR('FeedbackManagement', ex.getmessage(), ex.getStackTraceString());
                system.debug('Error: '+ex.getMessage());
            }
        }
    }
    //MOSCATELLI_M 07/11/2018: CTL Acquisto -- END  

    public static List<Account> getAccounts(Set<String> customerIdentifiers){
       return [SELECT Id, NDG__c, Fiscal_ID__c, TECH_Company__c, Name from Account where // NOPMD  Fix CRUD violation
            Recordtype.Developername in (:Ap_Constants.rtAccIndividualClient,
                    :Ap_Constants.rtAccCorporateClient,
                    :Ap_Constants.rtAccB2C,
                    :Ap_Constants.rtAccB2B,
                    :Ap_Constants.rtAccAAFB2C) and
            (Fiscal_ID__c in :customerIdentifiers
            or NDG__c in :customerIdentifiers)  FOR UPDATE];
    }

    public static List<String> getExcludedAccountsNDG(){
        List<String> excludedAccountsNDG = new List<String>();
        for(FeedbackManagementExcludedAccounts__mdt config: [SELECT NDG__c FROM FeedbackManagementExcludedAccounts__mdt ]){ // NOPMD  Fix CRUD violation
            excludedAccountsNDG.add(config.NDG__C);
        }
        return excludedAccountsNDG;
    }

     /**
    * Method that given an feedback and Custom settings(3 on version 1.0) return True if the Case to be created by this
    * feedback has to be handle by the Agenzy as Owner. Otherwise the Case created goes to assignment Rules. (Close the loop queue)
    * @author: *-+
    * @date: 05/05/2022
    * @param objectName: feedback CTL, to turn on and off logic SendSurveyAcquistoToAgency,SendSurveyClaimToAgency,SendSurveyCheckINToAgency
    * @return  isOwnerAgenzy: boolean  TRUE if the feedback needs to be handle by Agenzy Queue      
    */
    public static boolean getIfCaseGoesToAgency(Feedback__c feedback, boolean SendSurveyAcquistoToAgency, boolean SendSurveyClaimToAgency,
    boolean SendSurveyCheckINToAgency,Map<String,String> MapFeedbackRecordType){

        // String hardCode popolato per sandSiv nel feedback ctl di tipo Sinistri check In.
        String QuestionsRatingForAgencyWork = 'Gestione sinistro secondo aspettative:  no  Ambiti_difficoltà_Opzione2:  Interazione con l’Agenzia';  
        String QuestionsRatingFromFeedback = '';
        boolean isCheckInSurvey = false ;
        // nel caso sia survey check in salvare la risposta per fare la comparazione dopo nel IF
        if('Sinistri Check IN'.equalsIgnoreCase(feedback.Survey_Origin__c)){
            isCheckInSurvey = true ;
            if (String.isNotBlank(feedback.Questions_Rating__c))
             QuestionsRatingFromFeedback = feedback.Questions_Rating__c.replace('\n','');
        }
            
        if ((SendSurveyAcquistoToAgency && feedback.RecordTypeId!=MapFeedbackRecordType.get(Ap_Constants.rtClaimSurveyFeedback)))
            return true ;// if Custom setting is ON for send Cases RT:Acquisto_Rinnovo to Agenzy handle  
        else if (SendSurveyClaimToAgency && feedback.RecordTypeId==MapFeedbackRecordType.get(Ap_Constants.rtClaimSurveyFeedback))
            return true ;// if Custom setting is ON for send Cases RT:ClaimSurvey to Agenzy handle 
        else if (SendSurveyCheckINToAgency && feedback.RecordTypeId==MapFeedbackRecordType.get(Ap_Constants.rtClaimSurveyFeedback)
            && feedback.Agency_Code__c != '000729' && isCheckInSurvey)
            return true ; // if Custom setting is ON for send Cases RT:ClaimSurvey ...conditions. to agency handle
        else if(isCheckInSurvey && String.isNotBlank(QuestionsRatingFromFeedback) && feedback.Company__c == 'AAI' && QuestionsRatingFromFeedback.startsWithIgnoreCase(QuestionsRatingForAgencyWork))
            return true ;
        else
            return false ;
    }

}
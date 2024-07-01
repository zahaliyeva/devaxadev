/*------------------------------------------------------------------------------------------
Author:        Francesca Marchese
Company:       Deloitte
Class:         WS_SOL_Service_Management
Description:   Apex class used to execute all the logics internal to the 
web service Callout related to Caring Angel

History

25/9/2018     Created 
-------------------------------------------------------------------------------------------*/
public with sharing class WS_SOL_Service_Management
{    
    public static Boolean isSinistri=false;//MMOSCATELLI 19032019:Axa Assistance
    public static Boolean isSinistriRecordType=false; //OAVERSANO 09/04/2019 : AXA Assistance fix numero sinistro e Visualizza sinistro
    public static Boolean updateCase=false; //OAVERSANO 09/04/2019 : AXA Assistance fix numero sinistro e Visualizza sinistro

    public WS_SOL_Service_Management()
    {

    }
    /*
            CORE METHODS
            VALIDATE for polizza and proposta inputs
            INSERT/UPSERT for polizza/proposta
    */


    public static void validateSOLInput(WS_SOL_Service.SOL_Request_STATE currentState){

        system.debug('++++START validateSOLInput');
        validateMandatoryFields(currentState);
        if (currentState.output.resultCode=='KO') {
            system.debug('+++++missing fields, returning KO');
            return;
        }

        validateNullableFields(currentState);
        if (currentState.output.resultCode=='KO') {
            system.debug('+++++nullable fields not allowed, returning KO');
            return;
        }
        
        validateCase(currentState);
        if(currentState.output.resultCode=='KO') {
            system.debug('+++++The Case provided is unknown');
            return;
        }
        
        validateFieldsFormat(currentState);
        if(currentState.output.resultCode=='KO') {
            system.debug('+++++Input format not allowed');
            return;
        }

        validateFieldsDomains(currentState);
        if(currentState.output.resultCode=='KO') {
            system.debug('+++++Input domain is wrong');
            return;
        }        
        
        system.debug('++++END validateSOLInput');
    }

    public static void refreshCase(WS_SOL_Service.SOL_Request_STATE currentState){
        system.debug('++++START refreshCase');
        
        PopulateCaseInstance(currentState);

        if(currentState.CAIExists)
            PopulateQuestionarioInstance(currentState);

        if(currentState.output.resultCode == 'KO')
        {
            system.debug('+++++could not populate the Case instance');
            return;
        } 
        else 
        {
            refreshCase_wDML(currentState);
        }
        system.debug('++++END refreshCase');
    }  

/*
    /////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
    ////////////////UTILITY METHODS//////////////////////
    //////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////
*/    

    
    public static void validateFieldsFormat(WS_SOL_Service.SOL_Request_STATE currentState)
    {
        system.debug('++++START__validateFieldsFormat');
        system.debug('++++currentState.input'+currentState.input);

        List<string> WrongFormatFields = new List <String>();

        if(String.isNotBlank(currentState.input.caseInfo.ClaimLink))
        {
            try
            {
                Url CheckUrl = new Url(currentState.input.caseInfo.ClaimLink);
            }
            catch(exception e)
            {
                WrongFormatFields.add('ClaimLink');
            }     
        }

        if(String.isNotBlank(currentState.input.caseInfo.EventDateTime))
        {
            String EventDateTime = currentState.input.caseInfo.EventDateTime.trim();
            String EventDateTimeNoDash = EventDateTime.remove('-');

            Integer counter = 0;
            Boolean isWrong = false;

            if(!EventDateTimeNoDash.isNumeric())
                isWrong = true;
            else if(EventDateTimeNoDash.length()<14)
            {
                isWrong = true;
            }
            else
            {
                for(String s : EventDateTime.split('-'))  
                {
                    if(counter==0)
                    {
                        if(s.length()<>4)
                            isWrong = true;
                    }
                    else if(counter>0 && counter<6)
                    {
                        if(s.length()<>2)
                            isWrong = true;
                    }
                    else if(counter>=6)
                    {
                        if(String.isNotBlank(s))
                            isWrong = true;
                    }

                    counter++;
                }
            }

            if(isWrong)
            {
                WrongFormatFields.add('EventDateTime');
            }           
        }

        if(String.isNotBlank(currentState.input.caseInfo.EventDateTimeSent))
        {
            String EventDateTimeSent = currentState.input.caseInfo.EventDateTimeSent.trim();
            String EventDateTimeSentNoDash = EventDateTimeSent.remove('-');

            Integer counter = 0;
            Boolean isWrong = false;

            if(!EventDateTimeSentNoDash.isNumeric())
                isWrong = true;
            else if(EventDateTimeSentNoDash.length()<14)
            {
                isWrong = true;
            }
            else
            {
                for(String s : EventDateTimeSent.split('-'))  
                {
                    if(counter==0)
                    {
                        if(s.length()<>4)
                            isWrong = true;
                    }
                    else if(counter>0 && counter<6)
                    {
                        if(s.length()<>2)
                            isWrong = true;
                    }
                    else if(counter>=6)
                    {
                        if(String.isNotBlank(s))
                            isWrong = true;
                    }

                    counter++;
                }
            }

            if(isWrong)
            {
                WrongFormatFields.add('EventDateTimeSent');
            }           
        }        

        if(String.isNotBlank(currentState.input.caseInfo.PolicyNumber))
        {
            String PolicyNumber = (currentState.input.caseInfo.PolicyNumber.trim()).replace('.','_');

            Integer counter = 0;
            Boolean isWrong = false;

            for(String s : PolicyNumber.split('_'))  
            {
                if(counter>3)
                    isWrong = true;
                else
                {
                    if(counter<3 && s.contains('-'))
                    {
                        isWrong = true;
                    }
                }

                counter++;
            }
            
            if(isWrong)
            {
                WrongFormatFields.add('PolicyNumber');
            }           
        }   

        if (WrongFormatFields.size()>0) {
            currentState.output.resultMessage='The following input has a wrong format: '+WrongFormatFields;
            currentState.output.resultCode='KO';
        } else {//in order to proceed to the next step
            currentState.output.resultCode='OK';
            currentState.output.resultMessage='All fields provided';
            
        }
        system.debug('++++END__validateFieldsFormat');         
    }

    public static void validateMandatoryFields(WS_SOL_Service.SOL_Request_STATE currentState)
    {
        //List of compulsory fields:   --CaseId   --ClaimId --ClaimNumber --ClaimType   --EventType   --EventDateTime   --EventDetails   --SessionId   

        system.debug('++++START__validateMandatoryFields');
        system.debug('++++currentState.input'+currentState.input);

        List<string> MissingFields = new List <String>();

        if(String.isempty(currentState.input.caseInfo.CaseId)){
            MissingFields.add('CaseId');
        }

        if(String.isempty(currentState.input.caseInfo.EventType)){
            MissingFields.add('EventType');
        }

        if (MissingFields.size()>0) {
            currentState.output.resultMessage='The following mandatory inputs are missing: '+MissingFields;
            currentState.output.resultCode='KO';
        } else {//in order to proceed to the next step
            currentState.output.resultCode='OK';
            currentState.output.resultMessage='All fields provided';
            
        }
        system.debug('++++END__validateMandatoryFields');        
    }

    public static void validateNullableFields(WS_SOL_Service.SOL_Request_STATE currentState)
    {
        //List of compulsory fields:   --CaseId   --ClaimId --ClaimNumber --ClaimType   --CAIisCompiled --EventType   --EventDateTime   --EventDetails   --SessionId   

        system.debug('++++START__validateNullableFields');
        system.debug('++++currentState.input'+currentState.input);

        List<string> NullableFields = new List <String>();

        if(currentState.input.caseInfo.CaseId==null){
            NullableFields.add('CaseId');
        }

        if(currentState.input.caseInfo.CAIGenerable==null){
            NullableFields.add('CAIGenerable');
        }

        if(currentState.input.caseInfo.EventType==null){
            NullableFields.add('EventType');
        }

        if (NullableFields.size()>0) {
            currentState.output.resultMessage='The value null for the following fields is not allowed: '+NullableFields;
            currentState.output.resultCode='KO';
        } else {//in order to proceed to the next step
            currentState.output.resultCode='OK';
            currentState.output.resultMessage='All fields provided';
            
        }
        system.debug('++++END__validateNullableFields');        
    }

    public static void validateFieldsDomains(WS_SOL_Service.SOL_Request_STATE currentState)
    {
        system.debug('++++START__validateFieldsDomains');

        Set<String> pickListValuesListEvent= new Set<String>();
        Set<String> pickListValuesListClaim= new Set<String>();
        Set<String> NotAllowedValues = new Set<String>();

        Schema.DescribeFieldResult fieldResult = Questionario_CA__c.Event_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        Schema.DescribeFieldResult fieldResult1 = Questionario_CA__c.Claim_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();        

        for( Schema.PicklistEntry pickListVal : ple)
        {
            pickListValuesListEvent.add(pickListVal.getLabel());
        }         

        for( Schema.PicklistEntry pickListVal1 : ple1)
        {
            pickListValuesListClaim.add(pickListVal1.getLabel());
        }   

        if(!pickListValuesListEvent.contains(currentState.input.caseInfo.EventType))
            NotAllowedValues.add(currentState.input.caseInfo.EventType);   

        /*if(String.isNotBlank(currentState.input.caseInfo.ClaimType))
        {
            if(!pickListValuesListClaim.contains(currentState.input.caseInfo.ClaimType))
                NotAllowedValues.add(currentState.input.caseInfo.ClaimType);
        }*/


        if(NotAllowedValues.size()>0)
        {
            currentState.output.resultMessage='The following value is not allowed: '+NotAllowedValues;
            currentState.output.resultCode='KO';
        }

        system.debug('++++END__validateFieldsDomains');

    }

    public static void validateCase(WS_SOL_Service.SOL_Request_STATE currentState)
    {
        system.debug('++++START__validateCase');
        //The id should already be checked by the schema as it is exposed as SFDC Id
        string selectedCaseId=currentState.input.caseInfo.CaseId;
        string selectedClaimId=currentState.input.caseInfo.ClaimId;
        string selectedEventType=currentState.input.caseInfo.EventType;
        system.debug('+++++input selectedCaseId'+selectedCaseId);
        //List<Case> selectedCaselist = [SELECT Id,Status,OwnerId,Account_email__c,CaseNumber FROM Case WHERE Id=:selectedCaseId limit 1];
        //OAVERSANO 04/03/2019 : CR Caring Angel -- START
        String selectedClaimNumber = currentState.input.caseInfo.ClaimNumber;
        /*List<Case> selectedCaselist = [SELECT Id, Status, OwnerId, Account_email__c, CaseNumber,
                                        (SELECT Id, Claim_Id__c FROM Questionari_CA__r) 
                                        FROM Case WHERE Id=:selectedCaseId limit 1];*/
        List<Case> selectedCaselist = [SELECT Id, Status, OwnerId, Account_email__c, CaseNumber,RecordtypeId,Origin, TECHThreadId__c, Account.Name,Numero_Sinistro__c,
                                        (SELECT Id, Claim_Id__c, Claim_Number__c FROM Questionari_CA__r) 
                                        FROM Case WHERE Id=:selectedCaseId limit 1];                                
        //OAVERSANO 04/03/2019 : CR Caring Angel -- END
        List<Questionario_CA__c> providedCAI = new List<Questionario_CA__c>();

        providedCAI = selectedCaselist[0].Questionari_CA__r;
        currentState.threadId = selectedCaselist[0].TECHThreadId__c;
        currentState.CAIExists = false;
        currentState.EmInfo.CustomerName = (String.isNotBlank(selectedCaselist[0].Account.Name))?selectedCaselist[0].Account.Name:'';
        currentState.EmInfo.claimNumber = selectedClaimId;
         
        if(selectedCaselist.isempty())
        {
            currentState.output.resultMessage='The Case provided is unknown --'+selectedCaseId+'--';
            currentState.output.resultCode='KO';
            return;
        } 
        else 
        {
            //Must check alignment between the CaseId on the Questionario related to ClaimId and the CaseId in the request
           // system.debug('+++++CaseId on Claim'+currentState.RelatedClaim.Questionario_CAI__r.Case__r.Id);
            system.debug('+++++CaseId on call'+currentState.input.caseInfo.CaseId);

            Case Cas = new Case(Id = selectedCaseId);
            currentState.RelatedCase = Cas;
            currentState.RelatedCase.Status = selectedCaselist[0].Status;
            //MMOSCATELLI 19032019:Axa Assistance -- START
            currentState.RelatedCase.RecordTypeId =selectedCaselist[0].RecordTypeId; 
            currentState.RelatedCase.Origin =selectedCaselist[0].Origin;
            //MMOSCATELLI 19032019:Axa Assistance -- END            
            currentState.EmInfo.CaseOwner=selectedCaselist[0].OwnerId;
            currentState.EmInfo.AccountEmail=selectedCaselist[0].Account_email__c;
            currentState.EmInfo.CaseNumber=selectedCaselist[0].CaseNumber;
            currentState.EmInfo.CaseStatus=selectedCaselist[0].Status;
            currentState.EmInfo.CaseId=selectedCaselist[0].Id;
            
            //OAVERSANO 04/03/2019 : CR Caring Angel -- START
            //if(String.isNotBlank(selectedClaimId))
            if(String.isNotBlank(selectedClaimNumber))
            //OAVERSANO 04/03/2019 : CR Caring Angel -- END
            {
                //OAVERSANO 23/11/2018 - with claim opening -- START
                Set<String> idQuestWithBlankClaimSet = new Set<String>();
                Questionario_CA__c CAI;
                if(!selectedCaselist[0].Questionari_CA__r.isEmpty())
                {
                    for(Questionario_CA__c quest : selectedCaselist[0].Questionari_CA__r)
                    {
                        //OAVERSANO 04/03/2019 : CR Caring Angel -- START
                        //if(quest.Claim_Id__c == selectedClaimId)
                        if(quest.Claim_Number__c == selectedClaimNumber)
                        //OAVERSANO 04/03/2019 : CR Caring Angel -- END
                        {
                            CAI = new Questionario_CA__c(Id = providedCAI[0].Id);
                            break;
                        }
                        //OAVERSANO 04/03/2019 : CR Caring Angel -- START
                        //else if(String.isBlank(quest.Claim_Id__c))
                        else if(String.isBlank(quest.Claim_Number__c))
                        //OAVERSANO 04/03/2019 : CR Caring Angel -- END
                        {
                            idQuestWithBlankClaimSet.add(quest.Id);
                        }
                    }
                }
                if(CAI!=null)
                {
                    currentState.CAIExists = true;
                    currentState.RelatedQuestionario = CAI;
                }
                else if(CAI == null && idQuestWithBlankClaimSet.size() == 1 && selectedEventType!=null)
                {
                    if(selectedEventType == 'APERTURA_SINISTRO' || selectedEventType == 'APERTURA_PREDENUNCIA')
                    {
                        String idQuest;
                        for(String s : idQuestWithBlankClaimSet)
                        {
                            idQuest = s;
                        }
                        CAI = new Questionario_CA__c(Id = idQuest, Sinistro_aperto_su_SOL__c = true);
                        currentState.RelatedQuestionario = CAI;
                        currentState.CAIExists = true;
                    }
                    else
                    {
                        currentState.output.resultMessage='The claim provided has not been found ';
                        currentState.output.resultCode='KO';
                    }
                }
                else
                {
                    currentState.output.resultMessage='The claim provided has not been found.';
                    currentState.output.resultCode='KO';
                }
                
                /*providedCAI = [Select Id,Case__c from Questionario_CA__c where Claim_Id__c=:selectedClaimId limit 1];

                if(providedCAI.size()>0) 
                {
                    if(providedCAI[0].Case__c <> selectedCaseId)
                    {
                        currentState.output.resultMessage='The claim provided is not associated to the case provided';
                        currentState.output.resultCode='KO';
                    }
                    else
                    {

                        currentState.CAIExists = true;
                        Questionario_CA__c CAI = new Questionario_CA__c(Id = providedCAI[0].Id);

                        currentState.RelatedQuestionario=CAI;
                    }
                }
                else
                {
                    currentState.output.resultMessage='The claim provided is not associated to the case provided';
                    currentState.output.resultCode='KO';                   
                }*/
            }
            else
            {
                currentState.output.resultMessage='The claim has not been provided';
                currentState.output.resultCode='KO';
            }
            //OAVERSANO 23/11/2018 - with claim opening -- END
        } 
        system.debug('++++END__validateCase');
    }


    public static void PopulateCaseInstance(WS_SOL_Service.SOL_Request_STATE currentState) 
    {
        system.debug('++++START__PopulateCaseInstance');
        //from the available inputs (already checked) populates a Case instance
        
        //ACT HERE TO CHANGE MAPPING
        Map<String,String> StatusChangeMap = new Map<String,String>();
        Map<String,String> RouteToHd2Map = new Map<String,String>();
        currentState.CaseToUpdate = false;
        String HD2QueueId = '';

        //MMOSCATELLI 19032019:Axa Assistance — START
        Schema.DescribeSObjectResult d = Schema.SObjectType.Case; 
        Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
        Schema.RecordTypeInfo rtById =  rtMapById.get(currentState.RelatedCase.RecordtypeId);

        String CaseType =rtById.getDeveloperName();

        if(CaseType =='Sinistri_Danni_Banca' || CaseType =='Sinistri_AAI')
        {
            isSinistriRecordType = true; //OAVERSANO 09/04/2019 : AXA Assistance fix numero sinistro e Visualizza sinistro
            if(currentState.RelatedCase.Origin =='Phone')
            {
                for(Assistenza_sinistri__mdt AsS: [Select Key__c, Value__c,DeveloperName from Assistenza_sinistri__mdt])
                {
                    if(AsS.DeveloperName.contains('StatusChange'))
                        StatusChangeMap.put(AsS.Key__c,AsS.Value__c);
                    else if(AsS.DeveloperName.contains('RouteTo_'+CaseType))
                        RouteToHd2Map.put(AsS.Key__c,AsS.Value__c);
                }

                isSinistri=true;
            }
        }
        else
        {
        //MMOSCATELLI 19032019:Axa Assistance — END
            for(Caring_Angel__mdt Ca: [Select Key__c, Value__c,DeveloperName from Caring_Angel__mdt])
            {
                if(Ca.DeveloperName.contains('StatusChange'))
                    StatusChangeMap.put(Ca.Key__c,Ca.Value__c);
                else if(Ca.DeveloperName.contains('RouteToHD2Status'))
                    RouteToHd2Map.put(Ca.Key__c,Ca.Value__c);
            }
        }//MMOSCATELLI 19032019:Axa Assistance
        system.debug('@@StatusChangeMap: '+JSON.serializePretty(StatusChangeMap));
        system.debug('@@RouteToHd2Map: '+RouteToHd2Map);


        String Key = currentState.RelatedCase.Status+'|'+currentState.input.caseInfo.EventType;
        //OAVERSANO 05/12/2018 : Caring Angel -- START
        String KeyWithoutClaimType = Key;
        //OAVERSANO 05/12/2018 : Caring Angel -- END
        try 
        {
            if(String.isNotBlank(currentState.input.caseInfo.ClaimType))
                Key+='|'+currentState.input.caseInfo.ClaimType;
            if(CaseType != AP_Constants.rtCaseCaringProperty){
            if(StatusChangeMap.containsKey(Key))
            {
                currentState.CaseToUpdate = true;
                currentState.RelatedCase.Status = StatusChangeMap.get(Key);
                currentState.EmInfo.CaseStatus = StatusChangeMap.get(Key);

                if(RouteToHd2Map.containsKey(StatusChangeMap.get(Key))) 
                {
                    currentState.RelatedCase.OwnerId = RouteToHd2Map.get(StatusChangeMap.get(Key));
                    currentState.EmInfo.CaseOwner=RouteToHd2Map.get(StatusChangeMap.get(Key));
                }
            }
            //OAVERSANO 05/12/2018 : Caring Angel -- START
            else if(StatusChangeMap.containsKey(KeyWithoutClaimType))          
            {
                currentState.CaseToUpdate = true;
                currentState.RelatedCase.Status = StatusChangeMap.get(KeyWithoutClaimType);
                currentState.EmInfo.CaseStatus = StatusChangeMap.get(KeyWithoutClaimType);

                if(RouteToHd2Map.containsKey(StatusChangeMap.get(KeyWithoutClaimType))) 
                {
                    currentState.RelatedCase.OwnerId = RouteToHd2Map.get(StatusChangeMap.get(KeyWithoutClaimType));
                    currentState.EmInfo.CaseOwner=RouteToHd2Map.get(StatusChangeMap.get(KeyWithoutClaimType));
                }
            }
            }
            else{
                if(RouteToHd2Map.containsKey(StatusChangeMap.get(Key))) 
                    {
                        currentState.RelatedCase.OwnerId = RouteToHd2Map.get(StatusChangeMap.get(Key));
                        currentState.EmInfo.CaseOwner=RouteToHd2Map.get(StatusChangeMap.get(Key));
                    }
                else if(RouteToHd2Map.containsKey(StatusChangeMap.get(KeyWithoutClaimType))) 
                    {
                        currentState.RelatedCase.OwnerId = RouteToHd2Map.get(StatusChangeMap.get(KeyWithoutClaimType));
                        currentState.EmInfo.CaseOwner=RouteToHd2Map.get(StatusChangeMap.get(KeyWithoutClaimType));
                    }
            }
            //OAVERSANO 05/12/2018 : Caring Angel -- END

            //MMOSCATELLI 19032019:Axa Assistance — START
            if(currentState.RelatedCase.Status=='Pending')
                currentState.EmInfo.AddresseeType='Cliente';
            //MMOSCATELLI 19032019:Axa Assistance — END
            
            if(isSinistriRecordType || CaseType == AP_Constants.rtCaseCaringSalute || CaseType == AP_Constants.rtCaseCaringProperty || CaseType == AP_Constants.rtCaseCaringAngel) {
                system.debug ('currentState.input.caseInfo.ClaimId'+currentState.input.caseInfo.ClaimId);
                if(String.isNotBlank(currentState.input.caseInfo.ClaimId))
                    currentState.RelatedCase.Numero_Sinistro__c = currentState.input.caseInfo.ClaimId;
                if(String.isNotBlank(currentState.input.caseInfo.ClaimLink))
                    currentState.RelatedCase.Visualizza_sinistro__c = '<a href="'+currentState.input.caseInfo.ClaimLink+'" >Visualizza su SOL</a>';
                updateCase = true;
            }
            
            //to go to the next step
            currentState.output.resultMessage='Case Details OK';
            currentState.output.resultCode='OK';
        } 
        catch (exception e) 
        {
            currentState.output.resultMessage='Errore durante la compilazione del Case --'+e.getStackTraceString();
            currentState.output.resultCode='KO';
        }
        system.debug('++++END__PopulateCaseInstance');
    }

    //here's the method to populate the questionario with the information passed inside the request
    public static void PopulateQuestionarioInstance(WS_SOL_Service.SOL_Request_STATE currentState)
    {
        system.debug('++++START__PopulateQuestionarioInstance');

        try
        {
            if(String.isNotBlank(currentState.input.caseInfo.ClaimId))
                currentState.RelatedQuestionario.Claim_Id__c = currentState.input.caseInfo.ClaimId;

            if(String.isNotBlank(currentState.input.caseInfo.PolicyNumber))
                currentState.RelatedQuestionario.Id_Polizza__c = currentState.input.caseInfo.PolicyNumber;

            if(String.isNotBlank(currentState.input.caseInfo.ClaimNumber))
                currentState.RelatedQuestionario.Claim_Number__c = currentState.input.caseInfo.ClaimNumber;

            if(String.isNotBlank(currentState.input.caseInfo.ClaimLink))
            {
                currentState.RelatedQuestionario.Link_su_SOL__c = currentState.input.caseInfo.ClaimLink;
            }

            if(String.isNotBlank(currentState.input.caseInfo.ClaimType))
                currentState.RelatedQuestionario.Claim_Type__c = currentState.input.caseInfo.ClaimType;

            if(String.isNotBlank(currentState.input.caseInfo.CAIGenerable))
                currentState.RelatedQuestionario.CAI_Generabile__c = currentState.input.caseInfo.CAIGenerable;

            if(String.isNotBlank(currentState.input.caseInfo.EventType))
                currentState.RelatedQuestionario.Event_Type__c = currentState.input.caseInfo.EventType;

            if(String.isNotBlank(currentState.input.caseInfo.EventDateTime))
            {
                String ProvidedDate = currentState.input.caseInfo.EventDateTime.trim();
                String DateToConvert ='';
                Integer counter = 0;

                for(String s:ProvidedDate.split('-'))
                {
                    if(counter<2)
                    {
                        DateToConvert += s+'-';
                    }
                    else if(counter==2)
                    {
                        DateToConvert += s+' ';
                    }
                    else
                    {
                        DateToConvert += s+':';
                    }

                    counter++;
                }

                system.debug('##DateToConvert: '+DateToConvert);

                currentState.RelatedQuestionario.Data_inserimento_sinistro_su_SOL__c = Datetime.valueOf(DateToConvert);
            }

            if(String.isNotBlank(currentState.input.caseInfo.EventDateTimeSent))
            {
                String ProvidedDate = currentState.input.caseInfo.EventDateTimeSent.trim();
                String DateToConvert ='';
                Integer counter = 0;

                for(String s:ProvidedDate.split('-'))
                {
                    if(counter<2)
                    {
                        DateToConvert += s+'-';
                    }
                    else if(counter==2)
                    {
                        DateToConvert += s+' ';
                    }
                    else
                    {
                        DateToConvert += s+':';
                    }

                    counter++;
                }

                system.debug('##SentDateToConvert: '+DateToConvert);

                currentState.RelatedQuestionario.Data_comunicazione_sinistro_da_SOL__c = Datetime.valueOf(DateToConvert);
            }
        }
        catch (exception e) 
        {
            currentState.output.resultMessage='Errore durante la compilazione del questionario CAI --'+e.getStackTraceString();
            currentState.output.resultCode='KO';
        }
        system.debug('++++END__PopulateQuestionarioInstance');
    }

    public static void refreshCase_wDML(WS_SOL_Service.SOL_Request_STATE currentState) 
    {
        system.debug('++++START__refreshCase_wDML');

        try 
        {           
            //Populating the Opportunity in order to update the relevant fields            
            
            if(currentState.CaseToUpdate || updateCase)
            {
                system.debug('currentState.RelatedCase:'+currentState.RelatedCase);
                Database.SaveResult result = Database.update(currentState.RelatedCase, false);//false here is not necessary. If it was a list it would allow to insert the one with OKinfo and reject only the bad records
                
                if(result.isSuccess())
                {               
                    system.debug('++++Case updated'+currentState.RelatedCase.id);
                    currentState.output.resultMessage = 'Case updated:' + result.getId()+'--';                
                    
                    if(currentState.CAIExists)
                    {
                        Database.SaveResult resultCAI = Database.update(currentState.RelatedQuestionario, false);
                        
                        if(!resultCAI.isSuccess())
                        {
                            System.debug('@@Error in update Questionario: '+resultCAI.getErrors());
                        }

                        system.debug('+++++Questionario updated');
                    }
                    currentState.output.resultCode='OK';

                    //sendNotificationEmail(currentState);//send email notification to customer or Support after status changing
                    //MMOSCATELLI 19032019:Axa Assistance — START
                    if(isSinistri && currentState.RelatedCase.Origin =='Phone' && currentState.RelatedCase.Status =='Pending' )
                        sendNotificationEmail(currentState);
                    //MMOSCATELLI 19032019:Axa Assistance — END
                }
                else 
                {
                    currentState.output.resultMessage='Error during the case update --'+result.getErrors();
                    currentState.output.resultCode='KO';
                }
            }
            else
            {
                if(currentState.CAIExists)
                {
                    Database.SaveResult resultCAI = Database.update(currentState.RelatedQuestionario, false);
                    
                    if(!resultCAI.isSuccess())
                    {
                        System.debug('@@Error in update Questionario: '+resultCAI.getErrors());
                        currentState.output.resultMessage='Error during the case update --'+resultCAI.getErrors();
                        currentState.output.resultCode='KO';
                    }
                    else
                    {
                        system.debug('++++Case RelatedCase'+currentState.RelatedCase);
                        system.debug('++++Case updated'+currentState.RelatedCase.id);
                        currentState.output.resultMessage = 'Case updated:' + currentState.RelatedCase.id+'--';  
                    }

                    system.debug('+++++Questionario updated');
                }
                currentState.output.resultCode='OK';                
            }            
        } 
        catch (exception e)
        {
            currentState.output.resultMessage='Error during the case update --'+e.getStackTraceString();
            currentState.output.resultCode='KO';
        }
        system.debug('++++END__refreshCase_wDML');
    }
@testvisible
    public static void sendNotificationEmail (WS_SOL_Service.SOL_Request_STATE currentState)
    {
        try
        {
            String KeyTemplate = currentState.EmInfo.AddresseeType+'|'+currentState.EmInfo.CaseStatus;

            //MMOSCATELLI 19032019:Axa Assistance — START
            /*Map<String,Caring_Angel__mdt> MapConfigsTemplate = new Map<String,Caring_Angel__mdt>();
            Map<String,Caring_Angel__mdt> MapConfigsUrl = new Map<String,Caring_Angel__mdt>();*/
            Map<String,String> MapConfigsTemplate = new Map<String,String>();
            Map<String,String> MapConfigsUrl = new Map<String,String>();
            String OrgId;
            if(!isSinistri)
            {
                for(Caring_Angel__mdt Config : [Select Key__c, Value__c,DeveloperName from Caring_Angel__mdt])
                {
                    if(Config.DeveloperName.contains('EmailTemplate'))
                        //MapConfigsTemplate.put(Config.Key__c,Config);
                        MapConfigsTemplate.put(Config.Key__c,Config.Value__c);
                    else if(Config.DeveloperName.contains('EmailUrl'))
                        MapConfigsUrl.put(Config.Key__c,Config.Value__c);
                        //MapConfigsUrl.put(Config.Key__c,Config);
                }
            }
            else
            {
                for(Assistenza_sinistri__mdt Config : [Select Key__c, Value__c,DeveloperName from Assistenza_sinistri__mdt])
                {
                    if(Config.DeveloperName.contains('EmailTemplate'))
                        MapConfigsTemplate.put(Config.Key__c,Config.Value__c);
                    else if(Config.DeveloperName.contains('EmailUrl'))
                        MapConfigsUrl.put(Config.Key__c,Config.Value__c);
                    else if(Config.DeveloperName.contains('OrgWideEmailAddress'))
                        OrgId = Config.Value__c;
                }                
            }
            //MMOSCATELLI 19032019:Axa Assistance — END

            EmailTemplate etem = new EmailTemplate();
            String Url = '';

            if(MapConfigsUrl.containsKey(currentState.EmInfo.AddresseeType)) 
            //MMOSCATELLI 19032019:Axa Assistance — START
                Url = MapConfigsUrl.get(currentState.EmInfo.AddresseeType);
                //Url = MapConfigsUrl.get(currentState.EmInfo.AddresseeType).Value__c;
            //MMOSCATELLI 19032019:Axa Assistance — END

            if(MapConfigsTemplate.containsKey(KeyTemplate))
            {
                //MMOSCATELLI 19032019:Axa Assistance — START
                //etem  = [SELECT Markup, Subject, HtmlValue, body FROM EmailTemplate WHERE DeveloperName =: MapConfigsTemplate.get(KeyTemplate).Value__c]; 
                etem  = [SELECT Markup, Subject, HtmlValue, body FROM EmailTemplate WHERE DeveloperName =: MapConfigsTemplate.get(KeyTemplate)]; 
                //MMOSCATELLI 19032019:Axa Assistance — END

                List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
                List<String> AddresseeEmail = new list<String>();
                AddresseeEmail.add(currentState.EmInfo.AccountEmail);

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String htmlBody = etem.HtmlValue;
                String subject = etem.Subject;
                String body    = etem.body;
                subject  = subject.replace('{!Case.CaseNumber}', currentState.EmInfo.CaseNumber);
                subject  = subject.replace('{!Case.Status}', currentState.EmInfo.CaseStatus);
                subject  = subject.replace('{!Case.TECHThreadId__c}', currentState.threadId);
                htmlBody = htmlBody.replace('{!Case.User__c}', (currentState.EmInfo.AddresseeType=='Advisor')?currentState.EmInfo.OwnerName:currentState.EmInfo.CustomerName);
                body     = body.replace('{!Case.User__c}', (currentState.EmInfo.AddresseeType=='Advisor')?currentState.EmInfo.OwnerName:currentState.EmInfo.CustomerName);       
                htmlBody = htmlBody.replace('{!Case.Account}', currentState.EmInfo.CustomerName);    
                body     = body.replace('{!Case.Account}', currentState.EmInfo.CustomerName);
                htmlBody = htmlBody.replace('{!Case.Numero_Sinistro__c}', currentState.EmInfo.claimNumber);    
                body     = body.replace('{!Case.Numero_Sinistro__c}', currentState.EmInfo.claimNumber);
                htmlBody = htmlBody.replace('{!Case.CaseNumber}', currentState.EmInfo.CaseNumber);    
                body     = body.replace('{!Case.CaseNumber}', currentState.EmInfo.CaseNumber);
                htmlBody = htmlBody.replace('{!Case.Link}', Url+currentState.EmInfo.CaseId);    
                body     = body.replace('{!Case.Link}', Url+currentState.EmInfo.CaseId);   
                email.setHtmlBody(htmlBody);
                email.setSubject(subject);
                if(String.isNotBlank(OrgId))
                {
                    email.setOrgWideEmailAddressId(orgId);
                }
                if(currentState.EmInfo.AddresseeType == 'Advisor')
                    email.setTargetObjectId(currentState.EmInfo.CaseOwner);
                else
                    email.setToAddresses(AddresseeEmail);

                email.saveAsActivity = false;
                listEmail.add(email);
                Messaging.SendEmailResult [] results = Messaging.sendEmail(listEmail);
            }     
        }
        catch(exception ex)
        {
            system.debug('@@Error during email sending: '+ex.getMessage());
        }
    }
}
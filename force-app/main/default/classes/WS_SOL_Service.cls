/*------------------------------------------------------------------------------------------
Author:        Francesca Marchese
Company:       Deloitte
Class:         WS_SOL_Service
Description:   Apex class used to execute all the logics internal to the 
web service Callout related to Caring Angel

History

25/9/2018     Created 
-------------------------------------------------------------------------------------------*/
global class WS_SOL_Service {

	//Define the objects in apex that are exposed in the web service

    //Define the input object (input of the WS operations)


	 global class  SOL_Item {

	 	webservice SOL_Item_caseInfo caseInfo;
	 		 	
        
    }

    global class SOL_Item_caseInfo{

    	webservice string CaseId; //Case record Id in SFDC (provided to SOL after the claim creation)
	 	webservice string ClaimId; //Claim record Id generated in SOL after the claim creation 
	 	//webservice string PolicyId; //Policy record Id retrieved by SOL from MyAXA
	 	webservice string ClaimNumber; //Claim number generated in SOL
	 	webservice string PolicyNumber; //Policy record Id retrieved by SOL from MyAXA
	 	webservice string ClaimLink; //Url that must be accessed to visualize the claim into SOL
	 	webservice string ClaimType; //Type of the claim /(the values allowed for this input will be restricted to a limited group)
	 	webservice string CAIGenerable; //Information about the presence of a compiled CAI on SOL
        webservice string EventType; //Type of the event related to the claim /(the values allowed for this input will be restricted to a limited group)
        webservice string EventDateTimeSent;        
        webservice string EventDateTime; //Info on the Date and Time on which the event had occurred /(format: year -month -day -hour -minute –second)        
        webservice List<SOL_Item_EventInfo> EventInfo;

        global SOL_Item_caseInfo()
        {
            this.Caseid='';
            this.ClaimId='';
            this.ClaimNumber='';
            this.PolicyNumber='';
            this.ClaimLink = '';
            this.ClaimType='';
            this.CAIGenerable='';
            this.EventType='';
            this.EventDateTimeSent='';
            this.EventDateTime='';
            this.EventInfo = new List<SOL_Item_EventInfo>();
        }
    }

    global class SOL_Item_EventInfo{

        webservice string key;
        webservice string value;

        global SOL_Item_EventInfo()
        {
            this.key='';
            this.value='';
        }

    }

    //Define the output object (input of the WS operations)
    global class SOL_Service_Result {
        webservice string resultCode; //OK/KO
        webservice string resultMessage;// just a verbose explanation of the error
        
        //Constructor with Standard values
        public SOL_Service_Result() {
            system.debug('+++START___constructor for SOL_Service_Result');
            resultCode='KO';
            resultMessage = 'Result only initialised';
            system.debug('+++END___constructor for REOL_Service_Result');
            system.debug('+++cunstructed'+this);
        }
    }

    global class EmailInfo{

        public string CaseOwner;
        public string AccountEmail;
        public string CaseStatus;
        public string CaseNumber;
        public string CaseId;
        public string OwnerName;
        public string CustomerName;
        public string AddresseeType;
        public String claimNumber;

        global EmailInfo()
        {
            this.CaseOwner='';
            this.AccountEmail='';
            this.CaseStatus='';
            this.CaseNumber='';
            this.CaseId='';
            this.OwnerName='';
            this.CustomerName='';
            this.AddresseeType='Advisor';
            this.claimNumber  = '';
        }

    }

    //class where to store the information processed during the transaction
    global class SOL_Request_STATE {
        public WS_SOL_Service.SOL_Item input;
        public WS_SOL_Service.SOL_Service_Result output;//public so that any method can modify the output of the transaction
        
        public Case RelatedCase;//the Case which has to be updated
        public Questionario_CA__c RelatedQuestionario; //the Questionario related to Claim and Case
        public Boolean CAIExists;
        public Boolean CaseToUpdate;
        public String threadId;
        public WS_SOL_Service.EmailInfo EmInfo;
        
        //Add here other attributes that can be usefull on the various steps
        
        //Custom contructor to be used with the input of the WS
        public SOL_Request_STATE(WS_SOL_Service.SOL_Item input) {
            system.debug('+++START___constructor for SOL_Request_STATE');
            system.debug('+++input'+input);

            this.input=input;
            this.output=new SOL_Service_Result();
            this.EmInfo = new EmailInfo(); 

            system.debug('+++END___constructor for SOL_Request_STATE');
            system.debug('+++cunstructed'+this);

            //the remaining attributes wil be populated by other methods
        }
        
    }

//DEFINE THE OPERATIONS//


//Operation to update a case
    webservice static SOL_Service_Result refreshCase(SOL_Item input) {//method of the webservice that refresh a case
        system.debug('@@Inputs: '+input);
        SOL_Request_STATE currentState = new SOL_Request_STATE(input);
        system.debug('#@#@ '+currentState);

        //Performing the validation step
        WS_SOL_Service_Management.validateSOLInput(currentState);
        system.debug('#@#@ '+currentState);

        if(currentState.output.resultCode =='OK')
        {
            //Performing the refresh
            WS_SOL_Service_Management.refreshCase(currentState);     
            return currentState.output;
        } 
        else 
        {
            return currentState.output;                
        }
        
    }
}
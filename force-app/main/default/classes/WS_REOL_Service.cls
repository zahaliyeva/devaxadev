global class WS_REOL_Service {
    
    
    //Define the objects in apex that are exposed in the web service

    //Define the input object (input of the WS operations)
    global class  REOL_Item {
        webservice string PropostaNum; //Just string with a ref num, not external id
        webservice long IdProposta;//the id to be used for upser
        webservice string IdPolizza;//the external id of the polizza
        webservice string NumeroPolizza;// not external id. To be used as polizza name
        webservice string AgencyCode;//AgencyCode, STRING(20), no padding required
        webservice string Node;//the node wher ethe polizza is positioned. Could be the same as the agency STRING(20)
        webservice string Branch;// Portion of the polizza and proposta IDs
        webservice string Holder; //the holder of the polizza/proposta, has the NDG as corresponding id
        webservice Integer SubAsaCode; //code to categorize the polizza/proposta
        webservice string SubAsaDesc;// Description of the SubAsa
        webservice string ProductName;// Name of the product object of the proposta/polizza
        webservice string ProductCode;//Code of the product
        webservice string ProductDesc;//Description of the Product
        webservice string ConvenzioneCode;//Code of the convenzione applied
        webservice string ConvenzioneDesc;//Name-Description of the convenzione applied
        webservice string FrazionamentoCode;//Code for the payment Frazionamento
        webservice string FrazionamentoDesc;//Name-Description of the Frazionamento
        webservice double Premium;//Gross premium to be paid
        webservice string NDG;//NDG of the selected client (Holder)
        webservice id  IdOpp; //SFDC id of the opportunity to associate the proposta to
        webservice string LastModifiedBy;//Myriam USR that executed the last modification in REOL   
        webservice string ObjectType;//Defines if the dataset is to be considered belonging to a proposta or a polizza
        webservice Long PropostaStatusCode;//Code of the proposta status
        webservice string PropostaStatusDesc;//Status Description
        webservice Date DataEffetto;// date when the proposta-polizza becomes active
        webservice Date DataScadenza;//date when the proposta-polizza expires
        webservice Date DataFineValidita;//date when the proposta-polizza becomes invalid
        //FM --- added for CRM DAOL 2.0 --- START
        webservice string Targaveicolo;//vehicle licence number
        webservice string Modelloveicolo;//vehicle model
        webservice string Marcaveicolo;//vehicle mark
        webservice string Versioneveicolo;//vehicle version
        webservice double Diritti;//rights 
        webservice double Compensi;//fees
        webservice double Premiototaleapagare;//total annual premium
        webservice Integer AsaCode;
        //FM --- END
        
    }



    //Define the output object (input of the WS operations)
    global class REOL_Service_Result {
        webservice string Result;//OK-NOK
        webservice string ResultCode; //X-0000 --> T-0001 B-0001 S-0001
        webservice string Message;// just a verbose explanation of the error
        
        //Constructor with Standard values
        public REOL_Service_Result() {
            system.debug('+++START___constructor for REOL_Service_Result');
            Result='KO';
            ResultCode = 'T-0000';
            Message = 'Result only initialised';
            system.debug('+++END___constructor for REOL_Service_Result');
            system.debug('+++cunstructed'+this);
        }
    }
    
    //class where to store the information processed during the transaction
    global class REOL_Request_STATE {
        public WS_REOL_Service.REOL_Item input;
        public WS_REOL_Service.REOL_Service_Result output;//public so that any method can modify the output of the transaction
        
        public Opportunity RelatedOpp;//the opportunity related to the proposta
        public InsurancePolicy__c RelatedPol; //the Polizza related to the proposta
        public Account Holder;//the Account holder rof the proposta-Policy -->maybe another account is necessary if the holder is not the one related to the opportunity??
        public Proposta__c p;//the proposta being trated;
        //Add here other attributes that can be usefull on the various steps
        
        //Custom contructor to be used with the input of the WS
        public REOL_Request_STATE(WS_REOL_Service.REOL_Item input) {
            system.debug('+++START___constructor for REOL_Request_STATE');
            system.debug('+++input'+input);

            this.input=input;
            this.output=new REOL_Service_Result();

            system.debug('+++END___constructor for REOL_Request_STATE');
            system.debug('+++cunstructed'+this);

            //the remaining attributes wil be populated by other methods
        }
        
    }

//DEFINE THE OPERATIONS//

// operation to insert a new polizza after a proposta is sold
    webservice static REOL_Service_Result insertPolizza(REOL_Item input) {//method of the webservice that insert a Polizza
        
        system.debug('++++++START insertPolizza WS method');
        
        //Initialising the state
        REOL_Request_STATE currentState = new REOL_Request_STATE(input);
        
        //Performing the validation step
        WS_REOL_Service_Management.validatePolizzaInput(currentState);
        
        if(currentState.output.Result=='OK') {
            //Performing the insert
            WS_REOL_Service_Management.insertPolizza(currentState);    
        }
        
        system.debug('++++++END insertPolizza WS method');
        return currentState.output;                
    }
    
    
//Operation to update a proposta
    webservice static REOL_Service_Result upsertProposta(REOL_Item input) {//method of the webservice that upsert a proposta
    
        REOL_Request_STATE currentState = new REOL_Request_STATE(input);
                system.debug('#@#@ '+currentState);
        //Performing the validation step
        WS_REOL_Service_Management.validatePropostaInput(currentState);
        system.debug('#@#@ '+currentState);
        if(currentState.output.Result=='OK') {
            //Performing the upsert
            WS_REOL_Service_Management.upsertProposta(currentState);     
            return currentState.output;
        } else {
            return currentState.output;                
        }
        
    }

}
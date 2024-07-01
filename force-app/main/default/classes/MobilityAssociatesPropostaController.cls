public class MobilityAssociatesPropostaController  { 
    public class CustomException extends Exception{}
    
    
    
    @AuraEnabled
    public static User getUserInfo(){
        User userInfo =[SELECT Profile.Name 
                        FROM User
                        WHERE id =: UserInfo.getUserId() 
                        LIMIT 1];
        return userInfo;
    } 
    
    
    @AuraEnabled
    public static Opportunity getOpportunityInfo(Id oppId){
        Opportunity OpportunityInfo =[SELECT Id, AccountId, Numero_proposte__c
                                      FROM Opportunity
                                      WHERE id =: oppId
                                      LIMIT 1];
        return OpportunityInfo;
    } 
   /*
     @AuraEnabled
     public static  Proposta__c confirmMock(Id oppId, String CodiceProposta){
     Proposta__c p = new Proposta__c();
         p.Opportunita__c =oppId;
         p.ID_proposta__c = 10;
         insert p;
         return p;
     
     }*/
    
    @AuraEnabled
     public static  Proposta__c confirm(Id oppId, String CodiceProposta){
            Proposta__c createdProposta = new Proposta__c();

            transient IE_Integration_Record__c myIR_associa;
            transient IE_Engine myIE_associa;
            system.debug('+++CONFIRM');
             
         List<IE_Configuration__c> theConfig = [SELECT id from IE_Configuration__c WHERE Name='REOL_AssociaProposta' LIMIT 1];//TO BE MODIFIED WHEN ACTUAL int in place
         if (!theConfig.isempty()) {
            myIR_associa = new IE_Integration_Record__c();
            
           
            myIR_associa.IE_Configuration__c=theConfig[0].id;
            
            system.debug('++++compiled--myIR_associa'+myIR_associa);
            system.debug('+++'+myIE_associa);
            myIE_associa = new IE_Engine(myIR_associa);
            
            system.debug('++++compiled--myIE_associa'+myIE_associa);  
        } 
          myIR_associa.DevField__c='{"numProposta": "'+CodiceProposta+'","idOpp": "'+oppId+'"}';
         if (myIE_associa==null){
             throw new CustomException('Integrazione non configurata correttamente');          
         } else {
              try {
                myIE_associa.compileRequest();
                system.debug('++++'+myIE_associa.CompiledXML );
                myIE_associa.sendRequest();
                myIE_associa.interpretResponse();
            } catch (Exception e) {
                throw new CustomException('Si è verificato un errore');              
     }
            system.debug('+++'+myIE_associa.JSONresponse);
            
            boolean serviceOK = false;
            String serviceMessage = '';
            
            serviceOK = check_Associa_ServiceResponse(myIE_associa.JSONresponse);
            serviceMessage = getServiceMessage(myIE_associa.JSONresponse);
            
            if(serviceOK) {                
              createdProposta=  AssociaProposta(myIE_associa.JSONresponse);               
            } else {
                throw new CustomException(serviceMessage);             
            }
         }
  return createdProposta;
     }
    
     public static Proposta__c AssociaProposta(string JSONResult) {
        Proposta__c createdProposta = new Proposta__c();
        //Useing the class from the exposed WS to re-use validations
        WS_REOL_Service.REOL_Item  thisItem = new WS_REOL_Service.REOL_Item();
        WS_REOL_Service.REOL_Service_Result thisResult= new WS_REOL_Service.REOL_Service_Result();
        try {//mapping to the item from the JSON
            thisItem = mapResponseToREOL_Item(JSONResult);
        } catch (Exception e ) {
            system.debug('+++++ERROR'+ e);
             throw new CustomException('Si è verificato un errore');
           
        }
        thisResult = WS_REOL_Service.upsertProposta(thisItem);
        
        system.debug('+++++######'+thisResult);
        if(thisResult.Result=='KO') {
             throw new CustomException(thisResult.Message);
        } else {
            createdProposta = [SELECT id FROM Proposta__c where ID_proposta__c=:thisItem.IdProposta];
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Proposta associata con successo'));
           // displaySuccess=true;
           // showtable = false;
            
        }
       return createdProposta; 
    }
    
        public static boolean check_Associa_ServiceResponse(string JSONresponse) {
        //Cannot use utility due to duplicate filed name
        List<string> theEsito = JSONresponse.split('result');
        boolean result = false;
        
        for (string s :theEsito) {
            system.debug('++++the s'+s);
            if (s.contains('"OK"')) {
                result = true;
            } else {
                system.debug('+++code result not found, it is a fault');
                result = false;
            }
        }
        return result;
    }
    
    
    @AuraEnabled
    public static  List<RowDetail>  getListFromREOL(Opportunity scopeOpp) {
        
        List<RowDetail> ProposteList = new List<RowDetail>();
        transient IE_Integration_Record__c myIR_getList;
        transient IE_Engine myIE_getList;
        
        //initialise element for IE
        List<IE_Configuration__c> theConfig = [SELECT id from IE_Configuration__c WHERE Name='REOL_getProposte' LIMIT 1];//TO BE MODIFIED WHEN ACTUAL int in place
        
        if (!theConfig.isempty()) {
            myIR_getList = new IE_Integration_Record__c();
            
            myIR_getList.ScopeID__c=''+scopeOpp.AccountId+';'+UserInfo.getUserId();
            myIR_getList.IE_Configuration__c=theConfig[0].id;
            
            system.debug('++++compiled--myIR_getList'+myIR_getList);
            myIE_getList = new IE_Engine(myIR_getList);
            
            system.debug('++++compiled--myIE_getList'+myIE_getList);  
        }   
        
        if (myIE_getList==null){             
            throw new CustomException('Integrazione non configurata correttamente');
        }
        
        try {
            myIE_getList.compileRequest();
            system.debug('++++'+myIE_getList.CompiledXML);
            myIE_getList.sendRequest();
            system.debug('++++'+myIE_getList.CompiledXML); 
            myIE_getList.interpretResponse();
        } catch (Exception e) {
            throw new CustomException('Si è verificato un errore');           
            
        }
        boolean serviceOK = false;
        String serviceMessage = '';
        
        serviceOK = checkServiceResponse(myIE_getList.JSONresponse);
        serviceMessage = getServiceMessage(myIE_getList.JSONresponse);
        
        if(serviceOK) {
            ProposteList = displayResult(myIE_getList.JSONresponse);
            
        } else {
            throw new CustomException(serviceMessage);
            
        }      
        return ProposteList;
        
    }
    
     public static WS_REOL_Service.REOL_Item mapResponseToREOL_Item(string JSONResult) {
        WS_REOL_Service.REOL_Item  result = new WS_REOL_Service.REOL_Item();
        
        List<Object> tempOb = JSONUtility.getObjectList(JSONResult,'input');
        String InputJSON = JSON.serialize(tempOb[0]);
        system.debug('++++++InputJSON'+InputJSON+'+++++++InputJSON');
        /*
        result.PropostaNum       = JSONUtility.getField(InputJSON,'PropostaNum')[0];
        result.IdProposta        = Long.valueOf(JSONUtility.getField(InputJSON,'IdProposta')[0]);
        result.IdPolizza         = JSONUtility.getField(InputJSON,'IdPolizza')[0];//
        result.NumeroPolizza     = JSONUtility.getField(InputJSON,'IdPolizza')[0];//
        result.AgencyCode        = JSONUtility.getField(InputJSON,'AgencyCode')[0];
        result.Node              = JSONUtility.getField(InputJSON,'Node')[0];
        result.Branch            = JSONUtility.getField(InputJSON,'Branch')[0];
        result.Holder            = JSONUtility.getField(InputJSON,'Holder')[0];
        result.SubAsaCode        = Integer.valueOf(JSONUtility.getField(InputJSON,'SubAsaCode')[0]);
        result.SubAsaDesc        = JSONUtility.getField(InputJSON,'IdPolizza')[0];//
        result.ProductName       = JSONUtility.getField(InputJSON,'ProductName')[0];
        result.ProductCode       = JSONUtility.getField(InputJSON,'ProductCode')[0];
        result.ProductDesc       = JSONUtility.getField(InputJSON,'IdPolizza')[0];//
        result.ConvenzioneCode   = JSONUtility.getField(InputJSON,'IdPolizza')[0];//
        result.ConvenzioneDesc   = JSONUtility.getField(InputJSON,'IdPolizza')[0];//
        result.FrazionamentoCode = JSONUtility.getField(InputJSON,'FrazionamentoCode')[0];
        result.FrazionamentoDesc = JSONUtility.getField(InputJSON,'FrazionamentoDesc')[0];
        result.Premium           = Double.ValueOf(JSONUtility.getField(InputJSON,'amount')[0]);
        result.NDG               = JSONUtility.getField(InputJSON,'NDG')[0];
        result.IdOpp             = JSONUtility.getField(InputJSON,'IdOpp')[0];
        result.LastModifiedBy    = JSONUtility.getField(InputJSON,'LastModifiedBy')[0];
        result.ObjectType        = JSONUtility.getField(InputJSON,'descrizione')[0];
        result.PropostaStatusCode= Long.ValueOf(JSONUtility.getField(InputJSON,'PropostaStatusCode')[0]);
        result.PropostaStatusDesc= JSONUtility.getField(InputJSON,'PropostaStatusDesc')[0];
        result.DataEffetto       = Date.valueOf(JSONUtility.getField(InputJSON,'DataEffetto')[0]);
        result.DataScadenza      = Date.valueOf(JSONUtility.getField(InputJSON,'DataScadenza')[0]);
        result.DataFineValidita  = Date.valueOf(JSONUtility.getField(InputJSON,'DataFineValidita')[0]);
        */  
        
        
        result.PropostaNum       = getFieldFromJSON(InputJSON,'PropostaNum');
        
        
        string temp = getFieldFromJSON(InputJSON,'IdProposta');
        system.debug('+++temp'+temp);
        if (String.isblank(temp)) {
            result.IdProposta = null;
        } else {
            result.IdProposta        = Long.valueOf(temp);
        }
        
        result.IdPolizza         = getFieldFromJSON(InputJSON,'IdPolizza');
        result.NumeroPolizza     = getFieldFromJSON(InputJSON,'IdPolizza');
        result.AgencyCode        = getFieldFromJSON(InputJSON,'AgencyCode');
        result.Node              = getFieldFromJSON(InputJSON,'Node');
        result.Branch            = getFieldFromJSON(InputJSON,'Branch');
        result.Holder            = getFieldFromJSON(InputJSON,'Holder');
        
        temp=getFieldFromJSON(InputJSON,'SubAsaCode');
        system.debug('+++temp'+temp);
        if (String.isblank(temp)) {
            result.SubAsaCode = null;
        } else {
            result.IdProposta        = Integer.valueOf(temp);
        }
        
        
        
        result.SubAsaDesc        = getFieldFromJSON(InputJSON,'SubAsaDesc');//
        result.ProductName       = getFieldFromJSON(InputJSON,'ProductName');
        result.ProductCode       = getFieldFromJSON(InputJSON,'ProductCode');
        result.ProductDesc       = getFieldFromJSON(InputJSON,'ProductDesc');//
        result.ConvenzioneCode   = getFieldFromJSON(InputJSON,'ConvenzioneCode');//
        result.ConvenzioneDesc   = getFieldFromJSON(InputJSON,'ConvenzioneDesc');//
        result.FrazionamentoCode = getFieldFromJSON(InputJSON,'FrazionamentoCode');
        result.FrazionamentoDesc = getFieldFromJSON(InputJSON,'FrazionamentoDesc');
        
        
        //CAPOBIANCO_A 14/12/2017 SPRINT 55 - START
        /*temp=getFieldFromJSON(InputJSON,'Premium');
        system.debug('+++temp'+temp);
        if (String.isblank(temp)) {
            result.Premium = null;
        } else {
            result.Premium        = Double.valueOf(temp);
        }*/
        temp = getAmountFromJSON(InputJSON, 'Premium');
        if(String.isblank(temp))
        {
          result.Premium = null;
        }
        else {
          result.Premium = Double.valueOf(temp);
        }
        
        temp = getAmountFromJSON(InputJSON, 'TotalAnnualPremium');
        if(String.isblank(temp))
        {
          result.Premiototaleapagare = null;
        }
        else {
          result.Premiototaleapagare = Double.valueOf(temp);
        }
                
        temp = getAmountFromJSON(InputJSON, 'Fee');
        if(String.isblank(temp))
        {
          result.Compensi = null;
        }
        else {
          result.Compensi = Double.valueOf(temp);
        }
                
        temp = getAmountFromJSON(InputJSON, 'Due');
        if(String.isblank(temp))
        {
          result.Diritti = null;
        }
        else {
          result.Diritti = Double.valueOf(temp);
        }
        system.debug('#@#@ result premium '+result.Premium);
        system.debug('#@#@ result Premiototaleapagare '+result.Premiototaleapagare);
        system.debug('#@#@ result Compensi '+result.Compensi);
        system.debug('#@#@ result Diritti '+result.Diritti);
        //CAPOBIANCO_A 14/12/2017 SPRINT 55 - END
        
        
        result.NDG               = getFieldFromJSON(InputJSON,'NDG');
        result.IdOpp             = getFieldFromJSON(InputJSON,'IdOpp');
        result.LastModifiedBy    = getFieldFromJSON(InputJSON,'LastModifiedBy');
        result.ObjectType        = getFieldFromJSON(InputJSON,'descrizione');
        
        
        temp=getFieldFromJSON(InputJSON,'PropostaStatusCode');
        system.debug('+++temp'+temp);
        if (String.isblank(temp)) {
            result.PropostaStatusCode = null;
        } else {
            result.PropostaStatusCode        = Long.valueOf(temp);
        }
        
        
        result.PropostaStatusDesc= getFieldFromJSON(InputJSON,'PropostaStatusDesc');
        
        result.DataEffetto       = getDateFromJSON(InputJSON, 'DataEffetto');
        result.DataScadenza       = getDateFromJSON(InputJSON, 'DataScadenza');
        result.DataFineValidita       = getDateFromJSON(InputJSON, 'DataFineValidita');
        
        return result;
    }
    
      public static string getFieldFromJSON(string Json, string field) {//Method dedicated for mapping method mapResponseToREOL_Item
        string result = '';
        system.debug('++++Json'+Json);
        system.debug('++++field'+field);
        List<String> listRes = JSONUtility.getField(Json,field);
        system.debug('++++listRes'+listRes);
        if (ListRes.isempty()) {
            return result;
        } else {
            result = listRes[0];
        }
        return result;
    }

    //CAPOBIANCO_A 14/12/2017 SPRINT 55 - START
    public static String getAmountFromJSON(String JSON, String objectName)
    {
      Object objectTemp = null;
      string result = '';
      objectTemp = JSONUtility.getObjectList(JSON, objectName)[0];
      if(objectTemp == null)
      {
        return result;
      } else 
      {
        result = JSONUtility.getField(objectTemp,'amount')[0];
        if(result == null)
        {
          result = '';
          return result;
        }
        else{
          return result;
        }
      }
    }
    //CAPOBIANCO_A 14/12/2017 SPRINT 55 - END
    
    public static Date getDateFromJSON(string Json, string field) {
        string temp = '';
        system.debug('+++Json'+Json);
        system.debug('+++field'+field);
        temp = getFieldFromJSON(Json,field);
        system.debug('+++temp'+temp);
        if (String.isblank(temp)) {
            return null;
        } else {
            return Date.Valueof(temp);
        }
    }
    
    public static List<RowDetail> displayResult(string JSONresult) {
        List<RowDetail> result = new List<RowDetail>();
        
        list<Object> elencoProposteAssociabiliSalesForce = JSONUtility.getObjectList(JSONresult,'elencoProposteAssociabiliSalesForce' );
        system.debug('++++****'+elencoProposteAssociabiliSalesForce.size());
        
        for (Object thisObj : elencoProposteAssociabiliSalesForce) {
            List<String> thisCode = JSONUtility.getField(thisObj, 'numeroProposta');
            List<String> thisDE = JSONUtility.getField(thisObj, 'dataEffetto');
            List<String> thisDS = JSONUtility.getField(thisObj, 'dataScadenza');
            List<String> thisDV = JSONUtility.getField(thisObj, 'dataFineValidita');
            List<String> thisPC = JSONUtility.getField(thisObj, 'productCode');
            List<String> thisPN = JSONUtility.getField(thisObj, 'productName');
            List<String> thisSA = JSONUtility.getField(thisObj, 'subAsaDesc');
            List<String> thisStatus = JSONUtility.getField(thisObj, 'propostaStatusDesc');
            List<String> thisLMD = JSONUtility.getField(thisObj, 'dataUltimaModifica');
            List<String> thisLMB = JSONUtility.getField(thisObj, 'lastModifiedBy');
            
            result.add(new RowDetail(thisCode[0],
                                     thisDE[0],
                                     thisDS[0],
                                     thisDV[0],
                                     thisPC[0],
                                     thisPN[0],
                                     thisSA[0],
                                     thisStatus[0],
                                     thisLMD[0],
                                     thisLMB[0]));
        }
        return result;
    }
    
    public static string getServiceMessage(string JSONresponse) {
        String theMessage = '';
        List<string> theMessageOK = JSONUtility.getField(JSONresponse, 'message');
        List<string> theMessageKO = JSONUtility.getField(JSONresponse, 'errorDescription');
        system.debug('++++theMessageOK'+theMessageOK[0]);
        system.debug('++++theMessageKO'+theMessageKO[0]);
        
        if (!theMessageOK.isempty()) {
            if (theMessageOK[0]!=null) theMessage = theMessageOK[0];
            system.debug('++++++theMessage'+theMessage);
            
        }
        
        if (!theMessageKO.isempty()) {
            if (theMessageKO[0]!=null) theMessage = theMessageKO[0];
            system.debug('++++++theMessage'+theMessage);
        }
        
        system.debug('++++++theMessage'+theMessage);
        return theMessage;
    }
    
    
    public static boolean checkServiceResponse(string JSONresponse) {
        List<string> theEsito = JSONUtility.getField(JSONresponse, 'result');
        system.debug('++++the Esito'+theEsito);
        
        if (theEsito==null) {
            system.debug('+++code result not found, it is a fault');
            return false;
        } else {
            if (theEsito[0]=='OK') {
                return true;
            } else {
                return false;
            }
        }
    }
    
   /* 
    @AuraEnabled
    public static List<RowDetail> getListFromREOLMock(Opportunity scopeOpp) {  
        
        List<RowDetail> ProposteList = new List<RowDetail>();
        RowDetail mock = new RowDetail('codprop1','2019-11-27','2019-11-27','2019-11-27', 'ProdName1','ProdCode1','SubAsa1','Stato','2019-11-27', 'io'); 
        ProposteList.add(mock);
        mock = new RowDetail('codprop2','2019-11-27','2019-11-27','2019-11-27', 'ProdName2','ProdCode2','SubAsa2','Stato2','2019-11-27', 'io');
        ProposteList.add(mock);
        System.debug('ProposteList '+ ProposteList);
        // String response =  JSON.serialize(ProposteList);
        return ProposteList;
    }
	*/
    
    
    
    public class RowDetail{
        //Attributes to display on the page
        @AuraEnabled
        public boolean isSelected {get;set;}
        @AuraEnabled
        public String CodiceProposta {get;set;}
        @AuraEnabled
        public String DataEffetto {get;set;}
        @AuraEnabled
        public string dataScadenza {get;set;}
        @AuraEnabled
        public String dataFineValidita {get;set;}
        @AuraEnabled
        public String ProdName{get;set;}
        @AuraEnabled
        public String ProdCode {get;set;}
        @AuraEnabled
        public String SubAsa{get;set;}
        @AuraEnabled
        public String Stato {get;set;}
        @AuraEnabled
        public String LastModDate{get;set;}
        @AuraEnabled
        public String LastModBy {get;set;}
        
        public RowDetail(   string CodiceProposta ,
                         String DataEffetto ,
                         String dataScadenza,
                         string dataFineValidita ,
                         string ProdName ,
                         string ProdCode ,
                         string SubAsa ,
                         string Stato,
                         string LastModDate,
                         string LastModBy) {
                             this.CodiceProposta = CodiceProposta ;
                             this.DataEffetto = Date.ValueOf(DataEffetto).format();
                             this.dataScadenza = Date.ValueOf(dataScadenza).format() ;
                             this.dataFineValidita = Date.ValueOf(dataFineValidita).format() ;
                             this.ProdName = ProdName;
                             this.ProdCode= ProdCode;
                             this.SubAsa= SubAsa;
                             this.Stato = Stato;
                             this.LastModDate = Date.ValueOf(LastModDate).format() ;
                             this.LastModBy = LastModBy;
                             this.isSelected= false;
                         }
    }
}
/*------------------------------------------------------------------------------------------
   Author:        Orlando Aversano
   Company:       Deloitte
   Class:         LightningGetAllPoliciesCTRL
   Description:   Apex class used to execute all the logics internal to the
   VISUALFORCE PAGE LightningGetAllPolicies related to Caring Angel

   History

   4/10/2018     Created
   -------------------------------------------------------------------------------------------*/
public class LightningGetAllPoliciesCTRL {

	public LightningGetAllPoliciesCTRL(){

	}

	@AuraEnabled
	public static IE_GetPolicies.ResponseDto getPoliciesCTRL(String fiscalCode, String startDate,String targa) {
		IE_GetPolicies.ResponseDto response = new IE_GetPolicies.ResponseDto();
		try{
            String PIVARegex = '^[0-9]{11}';
            Pattern regPattern = Pattern.compile(PIVARegex);
            Matcher regMatcher = regPattern.matcher(fiscalCode);
            if(regMatcher.matches()){
                response = IE_GetPolicies.sendRequestGetPolicies('',  fiscalCode,  null, startDate, null,  true,  true, targa );
            }
            else{
			 response = IE_GetPolicies.sendRequestGetPolicies(fiscalCode,  '',  null, startDate, null,  true,  true , targa);
            }
			 if(response!=null)
			  {
				  if(response.deserializedResults!=null) {
					   for(GetPoliciesResponse policy : response.deserializedResults) {
						    policy.policyId = policy.idPolicy; 
                            policy.publicId = policy.idPolicy;
							policy.effectiveDate = policy.commonData.policyEffectDate;
							policy.expirationDate = policy.commonData.policyEndDate;
							policy.productName = policy.commonData.productName;
							policy.statusCode = policy.commonData.statusCode;
								// recupero targa e company code Wave 3
							policy.companyCode = policy.commonData.companyCode;
							if(policy.assets != null && !policy.assets.isEmpty() && String.isNotBlank(policy.assets[0].licensePlate)){
								policy.assetDescription = policy.assets[0].assetDescription;
								policy.licensePlate = policy.assets[0].licensePlate;
							}            							
							 // calcolo policy id per sol
                            String companyCode = string.valueOf(integer.valueof(policy.commonData.companyCode));
                           String nodeCode;
                           
                            nodeCode =   policy.commonData.nodeCode.removeStart('00');
                            String branchCode = policy.commonData.branchCode;
                            String[] arrSplit = policy.idPolicy.split('\\.');
                            String ultimaPartePolicyId =  arrSplit[arrSplit.size()-1];  
                            String numberP = ultimaPartePolicyId.left(9);                            
                            if(policy.portfolio.equalsIgnoreCase('DAOL')){
                               policy.policyIdSOl= '1' + '.'+ nodeCode.left(4)+ '.'+branchCode+'.'+ numberP; //Substring per prendere solo il codice agenzia
                           }
                           else if(policy.portfolio.equalsIgnoreCase('NAIS')){
                               policy.policyIdSOl= '3' + '...'+ ultimaPartePolicyId;
                           }
                           else{
                            policy.policyIdSOl= companyCode + '.'+ nodeCode+ '.'+branchCode+'.'+ numberP;
                           }
                            
                            // calcolo num applicazione
                            policy.numApplicazione= ultimaPartePolicyId.length() > 9 ? ultimaPartePolicyId.right(6) : '';  
						}
				   }
			  }
			 system.debug('getPoliciesCTRL  --> response: '+response);
		 } catch (Exception ex) {
			 response.isSuccess = false;
			 response.message = 'Attenzione ! Non è al momento possibile recuperare i dati sulle polizze, ti chiediamo di riprovare più tardi';
       response.message += '\n' + ex.getStackTraceString();
      }
		return response;
	}


	@AuraEnabled
	//MOSCATELLI_M 18/03/2019: AXA Assistance -- START
	//public static IE_GetAllPolicies.ResponseDto getAllPoliciesCTRL(String fiscalCode, String accountId) {
	public static IE_GetAllPolicies.ResponseDto getAllPoliciesCTRL(String fiscalCode, String accountId, String CaseId)
	{
		system.debug ('accountId: '+accountId);
		String CurrentCaseRT = '';
		Boolean isSinistri = false;
	case currentCase;

		if(String.isNotBlank(CaseId))
		 {
			 currentCase = [Select accountid, RecordType.Name from Case where id=: CaseId];
			 CurrentCaseRT = currentCase.RecordType.Name;

			 if(CurrentCaseRT=='Sinistri AAI' || CurrentCaseRT=='Sinistri Danni Banca')
				 isSinistri = true;

			 if(String.isBlank(accountId))
				 accountId= (String.isNotBlank(currentCase.AccountId)) ? currentCase.AccountId : '';
		 }

		IE_GetAllPolicies.ResponseDto response = new IE_GetAllPolicies.ResponseDto();

		if(!isSinistri)
		 {
			 //MOSCATELLI_M 18/03/2019: AXA Assistance -- END
			 system.debug(' -- getAllPolicies start method-- ');
			 //IE_GetAllPolicies.ResponseDto response = new IE_GetAllPolicies.ResponseDto();
			 response = IE_GetAllPolicies.sendRequest(fiscalCode, accountId);
			 /**PURE IT RIMOZIONE REFERENZA 
			 if(response!=null)
			  {
				  if(response.deserializedResults!=null)
				   {
					   if(!(response.deserializedResults).isempty())
						{
							
							for(GetAllPoliciesResponse policy : response.deserializedResults)
							 {

								 policy.commercialType = (policy.commercialTypes)!=null ? policy.commercialTypes[0].code : '';
								 if(policy.commonData!=null)
								  {
									  policy.publicId = policy.commonData.publicId;
									  policy.effectiveDate = policy.commonData.effectiveDate;
									  policy.expirationDate = policy.commonData.expirationDate;
									  policy.productName = policy.commonData.productName;
									  policy.dataSource = policy.commonData.policyCommonDataMetadata.dataSource;
									  policy.statusCode = policy.commonData.statusCode;
								  }
								 policy.make = (policy.insuredVehicle)!=null ? policy.insuredVehicle.make : '';
								 policy.model  = (policy.insuredVehicle)!=null ? policy.insuredVehicle.model : '';
								 policy.licensePlate = (policy.insuredVehicle)!=null ? (policy.insuredVehicle!=null) ? policy.insuredVehicle.registration.id : '' : '';
								 if(String.isNotBlank(policy.commonData.policyCommonDataMetadata.dataSource))
								  {
									  if(policy.commonData.policyCommonDataMetadata.dataSource=='AAI' && String.isNotBlank(policy.policyId))
									   {
										   if(policy.policyId.indexOf('-')!=-1)
											{
												policy.decodedPolicyId = '';
												List<String> policyToDecodify = policy.policyId.split('-');
												for(Integer i=0; i<policyToDecodify.size(); i++)
												 {
													 if(i == 0)
														 policy.decodedPolicyId = policyToDecodify[i].substring(policyToDecodify[i].indexOfAnyBut('0'));
													 //OAVERSANO 04/12/2018 : Enhancement DecodedPolicy -- START
													 else if(i == 1)
													  {
														  String valueTo = policyToDecodify[i].substring(policyToDecodify[i].indexOfAnyBut('0'));
														  if(valueTo.length()<4)
														   {
															   while(valueTo.length()<4)
																{
																	valueTo = '0'+valueTo;
																}
														   }

														  policy.decodedPolicyId = policy.decodedPolicyId+'.'+valueTo;
													  }
													 //OAVERSANO 04/12/2018 : Enhancement DecodedPolicy -- END
													 else if(i == policyToDecodify.size()-1)
														 policy.decodedPolicyId = policy.decodedPolicyId+'.'+policyToDecodify[i];
													 else
														 policy.decodedPolicyId = policy.decodedPolicyId+'.'+policyToDecodify[i].substring(policyToDecodify[i].indexOfAnyBut('0'));
												 }
											}
									   }
									  else if(policy.commonData.policyCommonDataMetadata.dataSource=='AMPS' && String.isNotBlank(policy.commonData.publicId))
									   {
										   policy.decodedPolicyId = '3...'+policy.commonData.publicId;
									   }
								  }
							 } 
						}
				   }
			  } PURE IT RIMOZIONE REFERENZA*/
			 //MOSCATELLI_M 18/03/2019: AXA Assistance -- START
		 }
		else
		 {
			 //List<GetAllPoliciesResponse> GprList = new List<GetAllPoliciesResponse>(); PURE IT RIMOZIONE REFERENZA
			 List<String> PolicyNumbers = new List<String>();
			 if(String.isNotBlank(accountId))
			  {
				  for(InsurancePolicy__c policy: [Select id,Name,CCDATE__c, EXPIRY_DATE__c,Tech_company__c,Product_Name__c,Product__c,Status__c,Targa_veicolo__c, Marca_veicolo__c, Modello_veicolo__c from InsurancePolicy__c where Cuid__c=:accountId])
				   {
					/**PURE IT RIMOZIONE REFERENZA
					   GetAllPoliciesResponse Gpr = new GetAllPoliciesResponse();

					   Gpr.publicId = policy.Name;
					   Gpr.commercialType='';
					   Gpr.effectiveDate =(policy.CCDATE__c!=null) ? policy.CCDATE__c.format() : null;
					   Gpr.expirationDate = (policy.EXPIRY_DATE__c!=null) ? policy.EXPIRY_DATE__c.format() : null;
					   Gpr.productName = (String.isNotBlank(policy.Product_Name__c) ? policy.Product_Name__c : policy.Product__c);
					   Gpr.dataSource = (policy.Tech_company__c=='AAI') ? 'AXA Assicurazioni' : ((policy.Tech_company__c=='AMF') ? 'AXA MPS Financial' : ((String.isNotBlank(policy.Tech_company__c) || policy.Tech_company__c=='MPS') ? 'AXA MPS' : policy.Tech_company__c));
					   Gpr.statusCode = policy.Status__c;
					   Gpr.make=String.isNotBlank(policy.Marca_veicolo__c) ? policy.Marca_veicolo__c : '';
					   Gpr.model=String.isNotBlank(policy.Modello_veicolo__c) ? policy.Modello_veicolo__c : '';
					   Gpr.licensePlate=String.isNotBlank(policy.Targa_veicolo__c) ? policy.Targa_veicolo__c : '';
					   Gpr.policyId = (policy.Name.isNumeric() && policy.Name.startsWith('0')) ? '3...'+policy.Name.substring(policy.Name.indexOfAnyBut('0')) : '3...'+policy.Name;
					   Gpr.decodedPolicyId = Gpr.policyId;
					   Gpr.isCollective = false;

					   GprList.add(Gpr);
					   PURE IT RIMOZIONE REFERENZA */
					   PolicyNumbers.add(policy.Name);
				   }
			  }
			 Map<String,Integer> MapPolNumToCount = new Map<String,Integer>();

			 AggregateResult[] ARs = [select count(id) totalSize, Name from InsurancePolicy__c where Name =: PolicyNumbers group by Name];

			 for(AggregateResult Ar: ARs)
			  {
				  MapPolNumToCount.put((String)Ar.get('Name'),(Integer)Ar.get('totalSize'));
			  }
			  /**PURE IT RIMOZIONE REFERENZA
			 for(GetAllPoliciesResponse Gp: GprList)
			  {
				  if(MapPolNumToCount.get(Gp.publicId)>1)
				   {
					   Gp.isCollective = true;
				   }
			  }
			  PURE IT RIMOZIONE REFERENZA */

			 system.debug('MapPolNumToCount: '+MapPolNumToCount);
			 /** PURE IT RIMOZIONE REFERENZA 
			 if(GprList.size()>0)
			  {
				  response.isSuccess = true;
				  response.deserializedResults = GprList;
			  }
			 else
			  {
				  response.isSuccess = false;
				  response.message = 'Attenzione ! Non è al momento possibile recuperare i dati sulle polizze, ti chiediamo di riprovare più tardi';
			  } PURE IT RIMOZIONE REFERENZA */
		 }
		//MOSCATELLI_M 18/03/2019: AXA Assistance -- END

		system.debug('getAllClaimsCTRL  --> response: '+response);
		return response;
	}

	@AuraEnabled
	public static Garanzie getAllGaranzieCTRL(String fiscalCode, String policyId){

		Garanzie gar = new Garanzie();
		Caring_Angel__mdt caringAngel = [SELECT Id, DeveloperName, CaseTriggerRecordType__c,
										 Garanzie_GOLD__c
										 FROM Caring_Angel__mdt
										 WHERE DeveloperName  = 'PolizzaGOLD'
																LIMIT 1];
		List<String> garanzieGold = new List<String>();
		if(caringAngel!=null)
		 {
			 if(String.isNotBlank(caringAngel.Garanzie_GOLD__c))
			  {
				  for(String s:caringAngel.Garanzie_GOLD__c.split(';'))
				   {
					   garanzieGold.add(s);
				   }
			  }
		 }
		gar.garanzieGOLD = garanzieGold;
		try  {

			 IE_Configuration__c Myconfig = [SELECT EndPoint__c, Certificate__c FROM IE_Configuration__c WHERE Name ='Integrazione_Garanzie' limit 1 ];
			 String path = '/policies/'+policyId+'/coverages';
			 String url = Myconfig.EndPoint__c + path;

			 // Instantiate a new HTTP request
			 HttpRequest Req = new HttpRequest();
			 //specify the method (GET)  well as the endpoin
			 Req.setMethod('GET');
			 //specify the endpoint
			 Req.setEndpoint(url);

			 Req.setHeader('Connection','Keep-Alive');
			 Req.setHeader('userId','usermyaxa2@axa.it');
			 Req.setHeader('personId', fiscalCode);
			 Req.setHeader('Accept','application/json');
			 Req.setHeader('Content-type','application/json');

			 Req.setTimeout(2 * 60 * 1000);
			 if (!String.isempty(Myconfig.Certificate__c)) {
				  Req.setClientCertificateName(Myconfig.Certificate__c);
			  }

			 system.debug('+++++myReq'+Req);

			 // sending request
			 Http http = new Http();


			 //Execute web service call here
			 HTTPResponse RawResponse = http.send(Req);
			 System.debug('++++++++Start to excute web service call');


			 System.debug('++++++++Finish to excute web service call');
			 //Helpful debug messages
			 System.debug('++++++++BODY'+RawResponse.getBody());
			 System.debug('++++++++STATUS:'+RawResponse.getStatus());
			 System.debug('++++++++STATUS_CODE:'+RawResponse.getStatusCode());

			 if(RawResponse.getStatusCode() == 200)
			  {
				  string check_InputJson = RawResponse.getBody();
				  string InputJson = check_InputJson;
				  gar.JSONToReturn = InputJson;
				  return gar;
			  }
			 else
			  {
				  string InputJson = RawResponse.getBody();
				  gar.JSONToReturn = InputJson;
				  return gar;
			  }
		 }
		catch(exception e) {
			 string JSON_INPUT = '{"code": "System.CalloutException","developerMessage": "Non è al momento possibile recuperare i dati sulle garanzie, ti chiediamo di riprovare più tardi. \nSe il problema persiste contatta il tuo referente AXA.", "userMessage": "test"}';
			 gar.JSONToReturn = JSON_INPUT;
			 return gar;
		 }
	}

	public class Garanzie {

		@AuraEnabled public List<String> garanzieGOLD;
		@AuraEnabled public String JSONToReturn;
		public Garanzie(){
		}
	}

}
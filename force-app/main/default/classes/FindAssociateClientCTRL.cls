/*------------------------------------------------------------------------------------------
Author:        Orlando Aversano
Company:       Deloitte
Class:         FindAssociateClientCTRL
Description:   Apex class used to execute all the logics internal to the 
Lightning component FindAssociateClient related to Caring Angel

History

11/10/2018     Created 
-------------------------------------------------------------------------------------------*/
public class FindAssociateClientCTRL {

	@AuraEnabled
 	//public static List<Account> findPersonaFisicaListCTRL(String nomeCliente, String cognomeCliente, String polizzaCliente, String codiceFiscaleCliente, String targaCliente) {
        public static List<Account> findPersonaFisicaListCTRL(String nomeCliente, String cognomeCliente, String polizzaCliente, String codiceFiscaleCliente, String targaCliente, String datanascita) {//MOSCATELLI_M 27/11/2018: CR Caring Angel
		List<Account> accListToReturn = new List<Account>();
		Map<String,Id> mapAccountRecordtype = AP_Constants.getDeveloperIdMap( AP_Constants.sobjectAcc );
    	String rtAccIndividualId = mapAccountRecordtype.get(AP_Constants.rtAccIndividualClient);
    	String rtAccCorporateId = mapAccountRecordtype.get(AP_Constants.rtAccCorporateClient);
    	String rtAccountB2CId = mapAccountRecordtype.get(AP_Constants.rtAccB2C);
    	String rtAccountB2BId = mapAccountRecordtype.get(AP_Constants.rtAccB2B);
		
		if(String.isNotBlank(targaCliente) || String.isNotBlank(polizzaCliente))
		{
			String queryStatement = 'id WHERE CUID__r.RecordType.Name in (\'Individual\',\'B2C Client\')';
			String toFind = '';
		 	if( String.IsNotBlank(polizzaCliente))
        	{       
	            queryStatement += ' AND Name ='+'\''+polizzaCliente+'\'';
	            toFind = polizzaCliente;
        	}
        	if( String.IsNotBlank(targaCliente))
        	{       
	            queryStatement += ' AND Targa_veicolo__c ='+'\''+targaCliente+'\'';
	           	if(String.isNotBlank(toFind))
                	toFind+= ' AND '+targaCliente;
                else
                    toFind= targaCliente;
        	}
            if( String.IsNotBlank(nomeCliente))
            {
                String searchFirstName = (nomeCliente).escapeJava();
                queryStatement += ' AND CUID__r.firstname ='+'\''+searchFirstName+'\'';
            }
            if( String.IsNotBlank(cognomeCliente))
            { 
                //String searchLastName = (cognomeCliente).escapeJava();
                //queryStatement += ' AND CUID__r.lastname ='+'\''+searchLastName+'\'';
                queryStatement += ' AND CUID__r.lastname ='+'\''+cognomeCliente+'\'';
            }//end of check blank
            if( String.IsNotBlank(codiceFiscaleCliente))
            { 
                String searchFiscalId = (codiceFiscaleCliente).escapeJava();
                queryStatement += ' AND (CUID__r.Fiscal_ID__c = :searchFiscalId OR CUID__r.AAI_Codice_fiscale__c = :searchFiscalId OR CUID__r.Partita_IVA__c = :searchFiscalId OR CUID__r.AAI_Partita_IVA__c = :searchFiscalId ) ';
            } 

            //MOSCATELLI_M 27/11/2018: CR Caring Angel -- START
            if( String.IsNotBlank(datanascita))
            { 
                queryStatement += ' AND CUID__r.PersonBirthdate = '+ datanascita;
            }             
            //MOSCATELLI_M 27/11/2018: CR Caring Angel -- END        
      		
   			system.debug('>>>>>>>>>>> queryStatement : '+queryStatement);
        	String searchs ='FIND {'+toFind+'} IN ALL FIELDS RETURNING InsurancePolicy__c('+queryStatement+')'; 
        	system.debug('##searchs: '+searchs);
        	List<List<SObject>> ListPolicies = search.query(searchs);
        	List<InsurancePolicy__c> ListPoliciesQuery = new list<InsurancePolicy__c>();
        	ListPoliciesQuery = ((List<InsurancePolicy__c>)ListPolicies[0]);
        	for(InsurancePolicy__c policy : [Select id, name, CUID__c, CUID__r.name , CUID__r.FirstName, CUID__r.PersonBirthdate, 
        									CUID__r.LastName, CUID__r.Codice_fiscale_ListView__c, CUID__r.IsPersonAccount, 
        									CUID__r.Fiscal_ID__c, CUID__r.Partita_IVA__c,CUID__r.AAI_Partita_IVA__c, 
        									CUID__r.AAI_Codice_fiscale__c,CUID__r.RecordType.Name,CUID__r.TECH_Company__c,
        									CUID__r.AAI_Agency_Reference_Code__c,CUID__r.CIF_Phone__c,CUID__r.CIF_PersonMobilePhone__c,
        									CUID__r.CIF_Work_phone__c,CUID__r.CIF_MobilePhone__c,CUID__r.CIF_PersonEmail__c,
        									CUID__r.CIF_Personalemail__c,CUID__r.CIF_Work_email__c,CUID__r.PersonMailingStreet, 
        									CUID__r.PersonMailingCity, CUID__r.PersonMailingState, CUID__r.PersonMailingPostalCode, 
        									CUID__r.PersonMailingCountry, CUID__r.BillingStreet, CUID__r.BillingCity, CUID__r.BillingState, 
        									CUID__r.BillingPostalCode, CUID__r.BillingCountry, CUID__r.AAI_Agency__r.Name from InsurancePolicy__c where id in:ListPoliciesQuery]) 
        	{
            	if(policy.CUID__c != null){
                	accListToReturn.add(policy.CUID__r);
            }      
        }    
		}
		else if(String.isBlank(nomeCliente) && String.isBlank(cognomeCliente) && String.isBlank(codiceFiscaleCliente) )
		{
			
		}
        //MOSCATELLI_M 27/11/2018: CR Caring Angel -- START
        else if(String.isBlank(targaCliente) &&
                String.isBlank(polizzaCliente) &&
                String.isBlank(nomeCliente)&&
                String.isBlank(cognomeCliente) &&
                String.isBlank(codiceFiscaleCliente)&&
                String.isNotBlank(datanascita))
        {
            
        }
        //MOSCATELLI_M 27/11/2018: CR Caring Angel -- END
		else{
			String queryStatement = 'id where RecordType.name in (\'Individual\',\'B2C Client\')';
	       	String toFind = '';
        
        	if( String.IsNotBlank(nomeCliente))
        	{
            	nomeCliente = (nomeCliente).escapeJava();
	            if(nomeCliente.contains('\''))
	                nomeCliente = nomeCliente.replace('\'','\\'+'\'');
	
	            queryStatement += ' and firstname ='+'\''+nomeCliente+'\'';
	            toFind = nomeCliente;
        	}
           	if( String.IsNotBlank(cognomeCliente))
           	{
             	//cognomeCliente = (cognomeCliente).escapeJava();   
            	if(cognomeCliente.contains('\''))
                	cognomeCliente = cognomeCliente.replace('\'','\\'+'\'');

            	queryStatement += ' AND lastname ='+'\''+cognomeCliente+'\'';
            	if(String.isBlank(toFind))
                	toFind = cognomeCliente; 
            	else
                	toFind = toFind+' AND '+cognomeCliente; 
        	}
        	if( String.IsNotBlank(codiceFiscaleCliente)){
            	codiceFiscaleCliente = (codiceFiscaleCliente).escapeJava();
          		
				queryStatement += ' AND (Fiscal_ID__c = :codiceFiscaleCliente OR AAI_Codice_fiscale__c = :codiceFiscaleCliente OR Codice_Fiscale_AAF__c = :codiceFiscaleCliente OR Partita_IVA__c = :codiceFiscaleCliente OR AAI_Partita_IVA__c = :codiceFiscaleCliente ) ';
            	if(String.isBlank(toFind))
                	toFind = (codiceFiscaleCliente).escapeJava(); 
            	else
                	toFind = toFind+' AND '+(codiceFiscaleCliente).escapeJava(); 
         
        	}

            //MOSCATELLI_M 27/11/2018: CR Caring Angel -- START
            if(String.IsNotBlank(datanascita))
            { 
                queryStatement += ' AND PersonBirthdate = '+ datanascita;
            }             
            //MOSCATELLI_M 27/11/2018: CR Caring Angel -- END      

			queryStatement = queryStatement.removeEndIgnoreCase('AND ')+ ' limit 100';
        
			system.debug('>>>>>>>>>>> queryStatement1 : '+queryStatement);
    		String [] SpecialChar = new String[]{'&#124;', '&','|','!','{','}','[',']','(',')','^','~', '*', ':','"','+','-'};
	        for(String s: SpecialChar)
	        {
	            if(toFind.contains(s))
	            {
	                toFind= toFind.replace(s,'\\'+s);
	                system.debug('\\'+s);
	            }
	        }

	        String searchs ='FIND {'+toFind+'} IN ALL FIELDS RETURNING ACCOUNT('+queryStatement+')'; 
	        system.debug('##searchs: '+searchs);
	        List<List<SObject>> ListAccounts = search.query(searchs);
	        system.debug('ListAccounts: '+ListAccounts);
	        
	        List<Account> ListAccountsQuery = new list<Account>();
	        ListAccountsQuery = ((List<Account>)ListAccounts[0]);
        
	        for (Account client : [Select id,name, FirstName, PersonBirthdate, LastName, IsPersonAccount,
	        						Fiscal_ID__c,Codice_fiscale_ListView__c,Partita_IVA__c,
	        						AAI_Partita_IVA__c,AAI_Codice_fiscale__c,RecordType.Name,Codice_Fiscale_AAF__c,TECH_Company__c,
	        						AAI_Agency_Reference_Code__c,CIF_Phone__c,CIF_PersonMobilePhone__c,CIF_Work_phone__c,CIF_MobilePhone__c,
	        						CIF_PersonEmail__c,CIF_Personalemail__c,CIF_Work_email__c,PersonMailingStreet,BillingStreet,
	        						PersonMailingCity, PersonMailingState, PersonMailingPostalCode, PersonMailingCountry,  
	        						BillingCity, BillingState, BillingPostalCode, BillingCountry,AAI_Agency__r.Name
									from Account where id in:ListAccountsQuery])
	        {
	 			accListToReturn.add(client);
	        }
		}
		return accListToReturn;
 	}
 	
 		@AuraEnabled
 	public static List<Account> findPersonaGiuridicaListCTRL(String ragioneSociale, String polizzaB2BClient, String partitaIVA) {
		List<Account> accListToReturn = new List<Account>();
		Map<String,Id> mapAccountRecordtype = AP_Constants.getDeveloperIdMap( AP_Constants.sobjectAcc );
    	String rtAccIndividualId = mapAccountRecordtype.get(AP_Constants.rtAccIndividualClient);
    	String rtAccCorporateId = mapAccountRecordtype.get(AP_Constants.rtAccCorporateClient);
    	String rtAccountB2CId = mapAccountRecordtype.get(AP_Constants.rtAccB2C);
    	String rtAccountB2BId = mapAccountRecordtype.get(AP_Constants.rtAccB2B);
		
		if(String.isNotBlank(polizzaB2BClient) )
		{
			String queryStatement = 'id WHERE CUID__r.RecordType.Name in (\'Corporate\',\'B2B Client\')';
			String toFind = '';
		 	if( String.IsNotBlank(polizzaB2BClient))
        	{       
	            queryStatement += ' AND Name ='+'\''+polizzaB2BClient+'\'';
	            toFind = polizzaB2BClient;
        	}
            if( String.IsNotBlank(partitaIVA))
            {
                String searchFirstName = (partitaIVA).escapeJava();
				queryStatement += ' AND (CUID__r.AAI_Partita_IVA__c = :searchFirstName OR CUID__r.Partita_IVA__c = :searchFirstName ) ';

            }
            if( String.IsNotBlank(ragioneSociale))
            { 
                String Name = (ragioneSociale).escapeJava();
                queryStatement += ' AND CUID__r.name ='+'\''+Name+'\'';
            }
   			system.debug('>>>>>>>>>>> queryStatement : '+queryStatement);
        	String searchs ='FIND {'+toFind+'} IN ALL FIELDS RETURNING InsurancePolicy__c('+queryStatement+')'; 
        	system.debug('##searchs: '+searchs);
        	List<List<SObject>> ListPolicies = search.query(searchs);
        	List<InsurancePolicy__c> ListPoliciesQuery = new list<InsurancePolicy__c>();
        	ListPoliciesQuery = ((List<InsurancePolicy__c>)ListPolicies[0]);
        	for(InsurancePolicy__c policy : [Select id, name, CUID__c, CUID__r.name , CUID__r.FirstName, CUID__r.PersonBirthdate, 
        									CUID__r.LastName, CUID__r.Codice_fiscale_ListView__c, CUID__r.IsPersonAccount, 
        									CUID__r.Fiscal_ID__c, CUID__r.Partita_IVA__c,CUID__r.AAI_Partita_IVA__c, 
        									CUID__r.AAI_Codice_fiscale__c,CUID__r.RecordType.Name,CUID__r.TECH_Company__c,
        									CUID__r.AAI_Agency_Reference_Code__c,CUID__r.CIF_Phone__c,CUID__r.CIF_PersonMobilePhone__c,
        									CUID__r.CIF_Work_phone__c,CUID__r.CIF_MobilePhone__c,CUID__r.CIF_PersonEmail__c,
        									CUID__r.CIF_Personalemail__c,CUID__r.CIF_Work_email__c,CUID__r.PersonMailingStreet, 
        									CUID__r.PersonMailingCity, CUID__r.PersonMailingState, CUID__r.PersonMailingPostalCode, 
        									CUID__r.PersonMailingCountry, CUID__r.BillingStreet, CUID__r.BillingCity, CUID__r.BillingState, 
        									CUID__r.BillingPostalCode, CUID__r.BillingCountry,CUID__r.AAI_Agency__r.Name from InsurancePolicy__c where id in:ListPoliciesQuery]) 
        	{
            	if(policy.CUID__c != null){
                	accListToReturn.add(policy.CUID__r);
            }      
        }    
		}
		else if(String.isBlank(ragioneSociale) && String.isBlank(partitaIVA))
		{
			
		}
		else{
			String queryStatement = 'id where RecordType.name in (\'Corporate\',\'B2B Client\')';
	       	String toFind = '';
        
        	if( String.IsNotBlank(ragioneSociale))
        	{
            	ragioneSociale = (ragioneSociale).escapeJava();
	            if(ragioneSociale.contains('\''))
	                ragioneSociale = ragioneSociale.replace('\'','\\'+'\'');
	
	            queryStatement += ' and name ='+'\''+ragioneSociale+'\'';
	            toFind = ragioneSociale;
        	}
           	if( String.IsNotBlank(partitaIVA))
           	{
             	partitaIVA = (partitaIVA).escapeJava();   
            	if(partitaIVA.contains('\''))
                	partitaIVA = partitaIVA.replace('\'','\\'+'\'');

				queryStatement += ' AND (AAI_Partita_IVA__c = :partitaIVA OR Partita_IVA__c = :partitaIVA ) ';
            	if(String.isBlank(toFind))
                	toFind = partitaIVA; 
            	else
                	toFind = toFind+' AND '+partitaIVA; 
        	}
			queryStatement = queryStatement.removeEndIgnoreCase('AND ')+ ' limit 100';
        
			system.debug('>>>>>>>>>>> queryStatement1 : '+queryStatement);
    		String [] SpecialChar = new String[]{'&#124;', '&','|','!','{','}','[',']','(',')','^','~', '*', ':','"','+','-'};
	        for(String s: SpecialChar)
	        {
	            if(toFind.contains(s))
	            {
	                toFind= toFind.replace(s,'\\'+s);
	                system.debug('\\'+s);
	            }
	        }

	        String searchs ='FIND {'+toFind+'} IN ALL FIELDS RETURNING ACCOUNT('+queryStatement+')'; 
	        system.debug('##searchs: '+searchs);
	        List<List<SObject>> ListAccounts = search.query(searchs);
	        system.debug('ListAccounts: '+ListAccounts);
	        
	        List<Account> ListAccountsQuery = new list<Account>();
	        ListAccountsQuery = ((List<Account>)ListAccounts[0]);
        
	        for (Account client : [Select id,name, FirstName, PersonBirthdate, LastName, IsPersonAccount,
	        						Fiscal_ID__c,Codice_fiscale_ListView__c,Partita_IVA__c,
	        						AAI_Partita_IVA__c,AAI_Codice_fiscale__c,RecordType.Name,Codice_Fiscale_AAF__c,TECH_Company__c,
	        						AAI_Agency_Reference_Code__c,CIF_Phone__c,CIF_PersonMobilePhone__c,CIF_Work_phone__c,CIF_MobilePhone__c,
	        						CIF_PersonEmail__c,CIF_Personalemail__c,CIF_Work_email__c,PersonMailingStreet,BillingStreet,
	        						PersonMailingCity, PersonMailingState, PersonMailingPostalCode, PersonMailingCountry,  
	        						BillingCity, BillingState, BillingPostalCode, BillingCountry,AAI_Agency__r.Name 
									from Account where id in:ListAccountsQuery])
	        {
	 			accListToReturn.add(client);
	        }
		}
		return accListToReturn;
 	}
}
global virtual class RestRequestAbstract extends RLY_Behaviour implements IRestRequest{
	
	global RestWebService.TransactionData transactionData  	= new RestWebService.TransactionData();

	public virtual String getMethod(){
		return 'Default_Name';
	}

	public virtual String getBaseUrl(){
		return '/path/';
	}

	public virtual String getMethodType(){
		return 'POST';
	}

	public virtual String getType(){
		return 'INBOUND';
	}

	public virtual String getScope(){
		return '';
	}

	public RestWebService.TransactionData getTransanctionData(){
		return this.transactionData;
	}

	public String getTransanctionId(){
		if(this.transactionData != null){
			return this.transactionData.transactionId;
		}

		return 'no-transaction-data';
	}
}
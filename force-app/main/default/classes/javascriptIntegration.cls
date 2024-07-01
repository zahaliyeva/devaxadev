global with sharing class javascriptIntegration {
	public static final String MONITORING_KEY = 'appdynamics';

	public String parameters                                   	{get; private set;}
	public String appKey               						 	{get; private set;}
	public String beaconUrlHttp               				 	{get; private set;}
	public String beaconUrlHttps               				 	{get; private set;}
	public Boolean monitor								{get; private set;}

	public javascriptIntegration() {

		parameters = JSON.serialize(ApexPages.currentPage().getParameters());
		monitor = true;
		MonitoringParams__mdt [] monitoringParams= [
			SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, appKey__c, beaconUrlHttp__c, beaconUrlHttps__c 
			FROM MonitoringParams__mdt 
			WHERE DeveloperName = :MONITORING_KEY
		];	

		if(parameters.containsIgnoreCase('mobilityPushHomePage')||
			parameters.containsIgnoreCase('mobilityEcollabCruscotto')){
			monitor = false;
		}

		if(monitoringParams.size() != 1){
			System.debug('configurare il custom setting MonitoringParams__mdt');
		}else{
			MonitoringParams__mdt monitoringParam = monitoringParams.get(0);

			appKey = monitoringParam.appKey__c;
			beaconUrlHttp = monitoringParam.beaconUrlHttp__c;
			beaconUrlHttps = monitoringParam.beaconUrlHttps__c;
			
			System.debug('monitoringParam: '+ monitoringParam);

		}
	}
}
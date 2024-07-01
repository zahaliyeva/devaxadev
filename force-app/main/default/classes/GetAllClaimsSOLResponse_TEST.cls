@IsTest
public class GetAllClaimsSOLResponse_TEST {
    static testMethod void testParse() {
	    String json='{"Claims":[{"channel":"SOL","claimNumber":"1.7504.99.011268","claimId":12777216,"claimNumberEfnol":"","fiscalYear":"99","isIncompleteClaim":false,"idCase":"","policy":{"policyAgencyCode":"7504","policyNumber":"1.7504.5.238344972","branchCode":"5","policyProgressive":"238344972"},"companyCode":"1","companyDescription":"AXA Assicurazioni","agencyCode":"7504","agencySubCode":"","producerCode":"","productCode":"AUTO15","productDescription":"Nuova Protezione AUTO","commercialTypeCode":"AUTO_PRODUCT","plateNumber":"DX936AA","claimCategory":{"code":1,"description":"Auto"},"claimType":{"code":"20","description":"DD_RCA CID DEBITORE"},"claimDamageType":{"code":1,"description":"AUTO"},"insuredAsset":"DX936AA","claimEventDate":"29/08/2018","claimTimeEvent":"","claimNotificationDate":"21/09/2018","claimClosingDate":"05/10/2018","claimEventPlace":{"placeAddress":"--","latitude":null,"longitude":null,"nation":"IT","province":"TA","city":"TARANTO","zipCode":"-- ","address":""},"claimState":{"code":3,"description":"Pagato Totalmente","isOpen":false,"currentStep":"Auto Debitore"},"claimBaseCoverage":{"code":"RCA","description":"RESPONSABILITACIVILE AUTO"},"claimEvent":{"code":"EV000424","description":"INCIDENTE STRADALE"},"claimEventCategories":{"code":"GE000051","description":"INCIDENTE STRADALE"},"policyHolder":{"policyHolderId":31400030,"status":{"code":4,"description":"Senza Seguito"},"name":"GIOVANNI","surname":"CIANCIARUSO","email":null,"phone":null},"links":[{"rel":"ClaimHistory","self":"claims/12777216?trackingProcess=true","method":{"Method":"GET"}}]}],"IncompleteReports":[]}';
        String json2='[{"Claims":[{"channel":"SOL","claimNumber":"1.7504.99.011268","claimId":12777216,"claimNumberEfnol":"","fiscalYear":"99","isIncompleteClaim":false,"idCase":"","policy":{"policyAgencyCode":"7504","policyNumber":"1.7504.5.238344972","branchCode":"5","policyProgressive":"238344972"},"companyCode":"1","companyDescription":"AXA Assicurazioni","agencyCode":"7504","agencySubCode":"","producerCode":"","productCode":"AUTO15","productDescription":"Nuova Protezione AUTO","commercialTypeCode":"AUTO_PRODUCT","plateNumber":"DX936AA","claimCategory":{"code":1,"description":"Auto"},"claimType":{"code":"20","description":"DD_RCA CID DEBITORE"},"claimDamageType":{"code":1,"description":"AUTO"},"insuredAsset":"DX936AA","claimEventDate":"29/08/2018","claimTimeEvent":"","claimNotificationDate":"21/09/2018","claimClosingDate":"05/10/2018","claimEventPlace":{"placeAddress":"--","latitude":null,"longitude":null,"nation":"IT","province":"TA","city":"TARANTO","zipCode":"-- ","address":""},"claimState":{"code":3,"description":"Pagato Totalmente","isOpen":false,"currentStep":"Auto Debitore"},"claimBaseCoverage":{"code":"RCA","description":"RESPONSABILITACIVILE AUTO"},"claimEvent":{"code":"EV000424","description":"INCIDENTE STRADALE"},"claimEventCategories":{"code":"GE000051","description":"INCIDENTE STRADALE"},"policyHolder":{"policyHolderId":31400030,"status":{"code":4,"description":"Senza Seguito"},"name":"GIOVANNI","surname":"CIANCIARUSO","email":null,"phone":null},"links":[{"rel":"ClaimHistory","self":"claims/12777216?trackingProcess=true","method":{"Method":"GET"}}]}],"IncompleteReports":[]}]';
		String json3='[{"IncompleteReports":[{"channel":"SOL","claimNumber":"1.7504.99.011268","claimId":12777216,"claimNumberEfnol":"","fiscalYear":"99","isIncompleteClaim":false,"idCase":"","policy":{"policyAgencyCode":"7504","policyNumber":"1.7504.5.238344972","branchCode":"5","policyProgressive":"238344972"},"companyCode":"1","companyDescription":"AXA Assicurazioni","agencyCode":"7504","agencySubCode":"","producerCode":"","productCode":"AUTO15","productDescription":"Nuova Protezione AUTO","commercialTypeCode":"AUTO_PRODUCT","plateNumber":"DX936AA","claimCategory":{"code":1,"description":"Auto"},"claimType":{"code":"20","description":"DD_RCA CID DEBITORE"},"claimDamageType":{"code":1,"description":"AUTO"},"insuredAsset":"DX936AA","claimEventDate":"29/08/2018","claimTimeEvent":"","claimNotificationDate":"21/09/2018","claimClosingDate":"05/10/2018","claimEventPlace":{"placeAddress":"--","latitude":null,"longitude":null,"nation":"IT","province":"TA","city":"TARANTO","zipCode":"-- ","address":""},"claimState":{"code":3,"description":"Pagato Totalmente","isOpen":false,"currentStep":"Auto Debitore"},"claimBaseCoverage":{"code":"RCA","description":"RESPONSABILITACIVILE AUTO"},"claimEvent":{"code":"EV000424","description":"INCIDENTE STRADALE"},"claimEventCategories":{"code":"GE000051","description":"INCIDENTE STRADALE"},"policyHolder":{"policyHolderId":31400030,"status":{"code":4,"description":"Senza Seguito"},"name":"GIOVANNI","surname":"CIANCIARUSO","email":null,"phone":null},"links":[{"rel":"ClaimHistory","self":"claims/12777216?trackingProcess=true","method":{"Method":"GET"}}]}],"IncompleteReports":[]}]';

		GetAllClaimsSOLResponse obj = GetAllClaimsSOLResponse.parse(json);        
        GetAllClaimsSOLResponse.parseList(json2);
    }
    
    static testMethod void testParse2() {
		String json = '{'+
		'  \"errors\": ['+
		'    {'+
		'      \"status\": \"string\",'+
		'      \"code\": \"string\",'+
		'      \"title\": \"string\",'+
		'      \"detail\": \"string\",'+
		'      \"source\": \"string\"'+
		'    }'+
		'  ],'+
		'  \"result\": \"string\",'+
		'  \"status_response\": \"Success\"'+
		'}';
        
      GetAllClaimsSOLResponse obj = GetAllClaimsSOLResponse.parse(json);

    }

}
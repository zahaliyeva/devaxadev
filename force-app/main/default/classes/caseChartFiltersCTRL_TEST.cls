@isTest
private class caseChartFiltersCTRL_TEST {
	@isTest static void testGetters() {
		caseChartFiltersCTRL.ResponseDto emptyResponse = new caseChartFiltersCTRL.ResponseDto(false, 'Error');
        //OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz -- START
		//caseChartFiltersCTRL.ResponseDto lobValues = caseChartFiltersCTRL.getLob();
        List<String> filterLob = caseChartFiltersCTRL.getLob();
        //List<String> filterLob = (List<String>)lobValues.values.get('queryResults');
        //OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz -- END
		
		List<String> categoryValues = caseChartFiltersCTRL.getCategory(filterLob[0]);
		List<String> categoryValuesIT = caseChartFiltersCTRL.getCategory('IT');
		if(categoryValues.size()>0)
			List<String> subCategoryValues = caseChartFiltersCTRL.getSubCategory(categoryValues[0],filterLob[0]);//OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz
		else
			List<String> subCategoryValuesIT = caseChartFiltersCTRL.getSubCategory(categoryValuesIT[0],filterLob[0]);//OAVERSANO 02/11/2018 : Nuovo Modello di Assistenza Biz
	}	
}
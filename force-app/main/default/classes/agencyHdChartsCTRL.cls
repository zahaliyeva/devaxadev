public with sharing class agencyHdChartsCTRL {

	/*
    @AuraEnabled
    public static String getreport(){
        //Using report id for example purpose
        Report reportRec = [SELECT
                            Id
                            FROM Report
                            WHERE Id = '00O6E000000I75h'];
        
        Reports.ReportResults reportResult =
            Reports.ReportManager.runReport(reportRec.Id, true);
        
        return JSON.serialize(reportResult
                             );
    }

    @AuraEnabled
    public static String getData(String year,String month,String week,String LOB,Boolean allAgencyCases){
        //Using report id for example purpose
        Report reportRec = [SELECT
                            Id
                            FROM Report
                            WHERE Id = '00O6E000000I74Z'];
        
        Reports.ReportResults reportResult =
            Reports.ReportManager.runReport(reportRec.Id, true);
        
        return JSON.serialize(reportResult);
    }*/

    @AuraEnabled
    public static ResponseDto getCasesByStatus(String selectedYear,String selectedMonth,String selectedWeek,String selectedLob, String selectedCategory, String selectedSubCategory, String selectedOwnership){
        String dateFilter = createDateFilter ( selectedYear, selectedMonth, selectedWeek);
        String catFilter = createCategoryFilter (selectedLob,  selectedCategory, selectedSubCategory);
        String ownerFilter = createOwnerFilter(selectedOwnership);
        //
        String baseQueryString = 'SELECT count(Id),ToLabel(Status) FROM Case WHERE RecordType.DeveloperName = \'Assistenza_Agenti\'';
        String fullQuery = baseQueryString+dateFilter+catFilter+ownerFilter+' GROUP BY Status';
        system.debug ('******fullQuery = '+fullQuery);
        List<AggregateResult> caseGrouped = Database.query (fullQuery);
        ResponseDto result = new ResponseDto();
        if (caseGrouped.size()>0){
            
            List<queryResult> qResList = new List<queryResult>();
            for (AggregateResult ar : caseGrouped)  {
                queryResult singleResult = new queryResult();
                singleResult.label = (String)ar.get('Status');
                singleResult.value = String.valueOf(ar.get('expr0'));
                qResList.add (singleResult);
            }
            Map<Object,Object> valuesMap = new Map<Object,Object>();
            valuesMap.put ('queryResults',qResList);
            result.values = valuesMap;
            result.isSuccess = true;
        } else
        {
            result.message = 'no results';
        }       
       
        return result;
    }

    @AuraEnabled
    public static ResponseDto getAverageRating(String selectedYear,String selectedMonth,String selectedWeek,String selectedLob, String selectedCategory, String selectedSubCategory, String selectedOwnership){
        
        String dateFilter = createDateFilter ( selectedYear, selectedMonth, selectedWeek);
        String catFilter = createFeedbackCategoryFilter (selectedLob,  selectedCategory, selectedSubCategory);
        String ownerFilter = createFeedbackOwnerFilter(selectedOwnership);

        //Retrieve AVG of avarage of all user's cases
        String baseQueryString = 'SELECT AVG(AverageRating_NMA__c) FROM Feedback__c WHERE CreatedBy.Id = \'' + UserInfo.getUserId() + '\' AND Complaint__r.RecordType.DeveloperName = \'Assistenza_Agenti\'';
        String fullQuery = baseQueryString + dateFilter+catFilter+ownerFilter;
        System.debug(' ===> fullQuery: ' + fullQuery);
        List<AggregateResult> feedbacks = Database.query(fullQuery);

        //Retrieve AVG of avarage of all user's cases
        baseQueryString = 'SELECT AVG(AverageRating_NMA__c) FROM Feedback__c WHERE Complaint__r.RecordType.DeveloperName = \'Assistenza_Agenti\'';
        fullQuery = baseQueryString + dateFilter+catFilter+ownerFilter;
        System.debug(' ===> fullQuery: ' + fullQuery);
        List<AggregateResult> feedbacksAgency = Database.query(fullQuery);

        ResponseDto result = new ResponseDto();
        if (feedbacks.size()>0 && feedbacksAgency.size()>0){

            System.debug(' ===> feedbacks: ' + feedbacks);
            
            List<String> avg = new List<String>();            
            avg.add(String.valueOf(feedbacks.get(0).get('expr0')));
            avg.add(String.valueOf(feedbacksAgency.get(0).get('expr0')));

            Map<Object,Object> valuesMap = new Map<Object,Object>();
            valuesMap.put ('queryResults',avg);
            result.values = valuesMap;
            result.isSuccess = true;
            
        } else {
            System.debug(' ===> feedbacks empty');
            result.message = 'no results';
        }       
       
        return result;
    }

    @AuraEnabled
    public static ResponseDto getCasesResolutionTime (String selectedYear,String selectedMonth,String selectedWeek,String selectedLob, String selectedCategory, String selectedSubCategory, String selectedOwnership){
        String dateFilter = createDateFilter ( selectedYear, selectedMonth, selectedWeek);
        String catFilter = createCategoryFilter (selectedLob,  selectedCategory, selectedSubCategory);
        String ownerFilter = createOwnerFilter(selectedOwnership);
        //

        //List<String> status = new List<String> { 'Cancelled', 'Closed', 'Out of time', 'Chiuso mancanza QADV', 'Risolto', 'Chiuso in autonomia', 'Risolto in autonomia dall\'Agente' };

        String baseQueryStringSupportTime = 'SELECT AVG(Time_With_Customer__c) FROM Case WHERE Status IN (\'Cancelled\', \'Closed\', \'Out of time\', \'Chiuso mancanza QADV\', \'Risolto\', \'Chiuso in autonomia\', \'Risolto in autonomia dall\\\'Agente\') AND RecordType.DeveloperName = \'Assistenza_Agenti\'';
        String fullQueryFLSupportTme = baseQueryStringSupportTime+dateFilter+catFilter+ownerFilter;
        system.debug ('******fullQueryFLSupportTme = '+fullQueryFLSupportTme);
        List<AggregateResult> flSupportTime = Database.query (fullQueryFLSupportTme);

        String baseQueryStringTotalTime = 'SELECT AVG(E2E_Age_in_Business_Hours__c)  FROM Case WHERE Status IN (\'Cancelled\', \'Closed\', \'Out of time\', \'Chiuso mancanza QADV\', \'Risolto\', \'Chiuso in autonomia\', \'Risolto in autonomia dall\\\'Agente\') AND RecordType.DeveloperName = \'Assistenza_Agenti\'';
        String fullQueryTotalTme = baseQueryStringTotalTime+dateFilter+catFilter+ownerFilter;
        system.debug ('******fullQueryTotalTme = '+fullQueryTotalTme);
        List<AggregateResult> totalTime = Database.query (fullQueryTotalTme);

        runQueryWOS queryRunner = new runQueryWOS();
        List<AggregateResult> totalTimeGlobal = queryRunner.getGlobalResolutionTime (dateFilter, catFilter, ownerFilter);

        system.debug ('getQueryRows limit '+limits.getQueryRows());

        ResponseDto result = new ResponseDto();
        Map<Object,Object> valuesMap = new Map<Object,Object>();
        system.debug ('******flSupportTime = '+flSupportTime );
        if (flSupportTime.size()>0)
        {
            queryResult singleResult = new queryResult();
            singleResult.label = 'Tempo medio gestione agente (ore)';
            singleResult.value = '0';
            Decimal toRoundValue = (Decimal)flSupportTime[0].get('expr0');
            if( toRoundValue!= null) 
            {
            	singleResult.value = String.valueOf(toRoundValue.setScale(2, RoundingMode.HALF_UP));
        	}
            valuesMap.put ('flSupportTime',singleResult);
            result.isSuccess = true;
        }
        if(totalTime.size()>0) 
        {
            queryResult singleResult = new queryResult();
            singleResult.label = 'Tempo totale di gestione (ore)';
            singleResult.value = '0';
            Decimal toRoundValue = (Decimal)totalTime[0].get('expr0');
            if( toRoundValue!= null) 
            {
            	singleResult.value = String.valueOf(toRoundValue.setScale(2, RoundingMode.HALF_UP));
            }
            valuesMap.put ('totalTime',singleResult);
            result.isSuccess = true;        	
        }
        if(totalTimeGlobal.size()>0) 
        {
            queryResult singleResult = new queryResult();
            singleResult.label = 'Tempo totale di gestione sulla rete';
            singleResult.value = '0';
            Decimal toRoundValue = (Decimal)totalTimeGlobal[0].get('expr0');
        	if( toRoundValue!= null) 
            {
            	singleResult.value = String.valueOf(toRoundValue.setScale(2, RoundingMode.HALF_UP));
            } 
            valuesMap.put ('totalTimeGlobal',singleResult);
            result.isSuccess = true;        	
        }
        result.values = valuesMap;
        return result;
    }

    public static String createOwnerFilter (String selectedOwnership){
    	String ownerFilter = ' ';
    	if (selectedOwnership!= 'None' && selectedOwnership!='')
    	{
    		ownerFilter = ' AND User__c =\''+UserInfo.getUserId()+'\' ';
    	}
    	return ownerFilter;
    }

    public static String createFeedbackOwnerFilter (String selectedOwnership){
        String ownerFilter = ' ';
        if (selectedOwnership!= 'None' && selectedOwnership!='')
        {
            ownerFilter = ' AND Complaint__r.User__c =\''+UserInfo.getUserId()+'\' ';
        }
        return ownerFilter;
    }

    public static String createCategoryFilter (String selectedLob, String selectedCategory, String selectedSubCategory){
    	String categoryFilter = ' ';
    	if (selectedLob!='' && selectedLob !='None')
    	{
    		categoryFilter=categoryFilter+' AND LOB__c =\''+(String.escapeSingleQuotes(selectedLob))+'\' ';
    		if(selectedCategory!='' && selectedCategory !='None')
    		{
				categoryFilter=categoryFilter+' AND Category__c =\''+(String.escapeSingleQuotes(selectedCategory))+'\' ';
	    		if(selectedSubCategory!='' && selectedSubCategory !='None')
	    		{
					categoryFilter=categoryFilter+' AND SubCategory__c =\''+(String.escapeSingleQuotes(selectedSubCategory))+'\' ';
	    		}
    		}
    	}
    	return categoryFilter;
    }

    public static String createFeedbackCategoryFilter (String selectedLob, String selectedCategory, String selectedSubCategory){
        String categoryFilter = ' ';
        if (selectedLob!='' && selectedLob !='None')
        {
            categoryFilter=categoryFilter+' AND Complaint__r.LOB__c =\''+(String.escapeSingleQuotes(selectedLob))+'\' ';
            if(selectedCategory!='' && selectedCategory !='None')
            {
                categoryFilter=categoryFilter+' AND Complaint__r.Category__c =\''+(String.escapeSingleQuotes(selectedCategory))+'\' ';
                if(selectedSubCategory!='' && selectedSubCategory !='None')
                {
                    categoryFilter=categoryFilter+' AND Complaint__r.SubCategory__c =\''+(String.escapeSingleQuotes(selectedSubCategory))+'\' ';
                }
            }
        }
        return categoryFilter;
    }

    public static String createDateFilter (String selectedYear,String selectedMonth,String selectedWeek){
    	String timeFilter = ' ';
    	if (selectedYear != '' && selectedYear != 'None')
    	{
    		if (selectedMonth != '' && selectedMonth != 'None')
    		{
    			if (selectedWeek != '' && selectedWeek != 'None')
    			{
    				DateTime startDate = DateTime.newInstance (Integer.valueOf(selectedYear), (Integer.valueOf(selectedMonth)+1), Integer.valueOf(selectedWeek)); 
    				DateTime endDate = startDate.addDays(7);
    				timeFilter = ' AND CreatedDate >='+startDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+' and CreatedDate <='+endDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+' ';
    			}
    			else //no week selected
    			{
    				DateTime startDate = DateTime.newInstance (Integer.valueOf(selectedYear), (Integer.valueOf(selectedMonth)+1), 1); 
    				DateTime endDate = DateTime.newInstance (Integer.valueOf(selectedYear),  (Integer.valueOf(selectedMonth))+2, 1); 
    				timeFilter = ' AND CreatedDate >='+startDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+' and CreatedDate <='+endDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+' ';
    			}
    		}
    		else //no month & week selected
    		{
    			timeFilter = ' AND CALENDAR_YEAR(CreatedDate) = '+selectedYear+' ';
    		}
    	}
    	return timeFilter;
    }

    public class ResponseDto { // Object to better handle errors from http://blog.terrasky.com/blog/how-to-handle-apex-errors-for-lightning-component-implementations
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Map<Object, Object> values { get; set; }
        public ResponseDto(Boolean isSuccess, String msg){
            this.isSuccess = isSuccess;
            this.message = msg;
            this.values = new Map<Object, Object>();
            }   

        public ResponseDto(){
            this.isSuccess = False;
            this.message = '';
            this.values = new Map<Object, Object>();
            }       
    }

    public class queryResult {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
    }

    public without sharing class runQueryWOS {
    	public runQueryWOS()
    	{
    	}
    	public List<AggregateResult> getGlobalResolutionTime (String dateFilter,String catFilter,String ownerFilter){
	        String baseQueryStringTotalTimeGlobal = 'SELECT AVG(E2E_Age_in_Business_Hours__c)  FROM Case WHERE RecordType.DeveloperName = \'Assistenza_Agenti\'';
	        String fullQueryTotalTmeGlobal = baseQueryStringTotalTimeGlobal+dateFilter+catFilter;
	        system.debug ('******fullQueryTotalTmeGlobal = '+fullQueryTotalTmeGlobal);
	        List<AggregateResult> totalTimeGlobal = Database.query (fullQueryTotalTmeGlobal);
	        return totalTimeGlobal;

    	}
    }


    

}
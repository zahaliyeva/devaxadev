public with sharing class MobilityReportController extends MobilityAbstract {

    public class MobilityReportException extends Exception {}

    public class MobilityReport extends MobilityResponse{
        @AuraEnabled public String reportId;
        @AuraEnabled public String reportResult;
    }
    
    @AuraEnabled(cacheable=true)
    public static MobilityReport getReport(String reportDeveloperName, String filterName, String filterValue){
        DebugStart('MobilityReportController', 'getReport');

        MobilityReport response = new MobilityReport();

        try{

            List<Report> reportsData = [
                SELECT Id 
                FROM Report 
                WHERE DeveloperName = :reportDeveloperName
                LIMIT 1
            ];

            if(reportsData.size() == 0) throw new MobilityReportException('No report found');

            Report reportData = reportsData.get(0);
            response.reportId = reportData.Id;

            // Get the report metadata
            Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportData.Id);
            Reports.ReportMetadata reportMd = describe.getReportMetadata();

            Debug('reportMd', reportMd);
            Debug('getReportFilters', reportMd.getReportFilters());

            List<Reports.ReportFilter> reportFilters = reportMd.getReportFilters();

            for(Reports.ReportFilter filter : reportFilters){
                String filterColumn = filter.getColumn();

                Debug('filterColumn', filterColumn + ' > ' + filter.getValue());

                if(filterName.equalsIgnoreCase(filterColumn)){
                    filter.setValue(filterValue);
                }
            }   

            reportMd.setReportFilters(reportFilters);

            Reports.ReportResults reportResult = Reports.ReportManager.runReport(reportData.Id, reportMd, true);

            Debug('reportResult', reportResult);
            response.reportResult =  JSON.serialize(reportResult);
        }catch(MobilityReportException ex){
            Debug('Exception', ex.getStackTraceString());
            response.errorMessage = ex.getMessage();
        }

        Debug('response', response);
        DebugEnd();
    	return response;
    }

}
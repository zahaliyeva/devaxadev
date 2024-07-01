public with sharing class javascriptIntegrationInit {
    public String parameters                                   	{get; private set;}
    public String counters                                      {get; private set;}

    public javascriptIntegrationInit() {
        parameters = JSON.serialize(ApexPages.currentPage().getParameters());

        List<String> countersList = ApexPages.currentPage().getParameters().get('counters').split(',');
        counters = JSON.serialize(MobilityWidgetsHomepage.getCounters(countersList));
    }
}
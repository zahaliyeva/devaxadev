public class OpportunityProgressBarCtrl{   
    
    public Opportunity MyOpp {get; set;}
    public String ColourBackground {get; set;}
    public String ColourCircles {get; set;}
    public String ColourFrontLines {get; set;}
    
    public OpportunityProgressBarCtrl(ApexPages.StandardController stdController){
        ColourBackground = '47b4db';
        ColourCircles = '47b4db';
        ColourFrontLines = '29a4d0';
        this.MyOpp = (Opportunity)stdController.getRecord();
        this.MyOpp = [select Id, Step__c, StageName from Opportunity where Id =: MyOpp.Id];
        if (this.MyOpp.Step__c == 4) //Persa
        {
            ColourBackground = 'D52437';
            ColourCircles = 'D52437';
            ColourFrontLines = 'B81F2F';        
        }
        if (this.MyOpp.Step__c == 5) //Vinta
        {
            ColourBackground = '1ACC3B';
            ColourCircles = '1ACC3B';
            ColourFrontLines = '1AAB34';        
        }           
    }

}
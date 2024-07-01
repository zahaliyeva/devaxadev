public class SendSmsWrapper {
    public List<SubscriberItem> Subscribers {get;set;}
    
    public class SubscriberItem{
        public String MobileNumber  			{get; set;}
        public String SubscriberKey 			{get; set;}
        public AttributeItem Attributes 	   {get; set;}
    }
    
    public class AttributeItem{
        public String FirstName     {get;set;}
        public String AccountID     {get;set;}
        public String URL		    {get;set;}
        public String Type          {get;set;}
        public Boolean reAssigned   {get;set;}
        public String hours         {get;set;}
        public String Case_ID       {get;set;}
    }
    
    public Boolean Subscribe   	{get;set;}
    public Boolean Resubscribe 	{get;set;}
    public String keyword 	   	{get;set;}
    public Boolean pls_Override    {get;set;}
   

}
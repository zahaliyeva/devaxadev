public with sharing class VFC18_GiacenzaLeadViewCTRL {
    
    public string giacenza {get;set;}
    public Double LeadExistanceHours {get;set;}
    public Lead Ld {get;set;} 
    public Id LeadId {get;set;}
    public Id BHoursBefore;
    public Id BHoursAfter;
    public String TimeinBH {get;set;}
    
        public VFC18_GiacenzaLeadViewCTRL(ApexPages.StandardController controller){
       LeadId =  System.currentPageReference().getParameters().get('id');
       TimeinBH = '';

        BHoursBefore = [SELECT id FROM BusinessHours WHERE Name = 'AAI_Agency_BeforeLunch'].Id;
        BHoursAfter = [SELECT id FROM BusinessHours WHERE Name = 'AAI_Agency_AfterLunch'].Id;
    
        Lead LeadToUpdLst = [Select Ultima_data_di_riassegnazione__c,Contact_Date__c from lead where id =: LeadId];
    
        if(LeadToUpdLst.Ultima_data_di_riassegnazione__c<>null)
        {
    
            if(LeadToUpdLst.Contact_Date__c<>null)
            {
               Double HoursBefore = BusinessHours.diff(BHoursBefore,LeadToUpdLst.Ultima_data_di_riassegnazione__c , LeadToUpdLst.Contact_Date__c)/3600000.0;          
               Double HoursAfter = BusinessHours.diff(BHoursAfter,LeadToUpdLst.Ultima_data_di_riassegnazione__c , LeadToUpdLst.Contact_Date__c)/3600000.0;                  
               LeadExistanceHours = HoursBefore+HoursAfter;
               system.debug(LeadToUpdLst.Contact_Date__c+ '     '+LeadToUpdLst.Ultima_data_di_riassegnazione__c+ '     '+LeadExistanceHours);
            }
            else
            {
               Double HoursBefore = BusinessHours.diff(BHoursBefore,LeadToUpdLst.Ultima_data_di_riassegnazione__c , system.now())/3600000.0;          
               Double HoursAfter = BusinessHours.diff(BHoursAfter,LeadToUpdLst.Ultima_data_di_riassegnazione__c , system.now())/3600000.0;         
               LeadExistanceHours = HoursBefore+HoursAfter;
               system.debug(system.now()+ '     '+LeadToUpdLst.Ultima_data_di_riassegnazione__c+ '     '+LeadExistanceHours);
     
            }

            if(LeadExistanceHours>0)
            {

                Integer Ore = 0;
                Integer Minuti = 0;
                Integer Giorni= 0;
                Integer Secondi = 0;
               if(LeadExistanceHours>=8)
               {
                   Giorni = Integer.valueof(LeadExistanceHours/8);

                  if(LeadExistanceHours-Giorni>0)
                  {
                     Ore = Integer.valueof(LeadExistanceHours-8*Giorni);

                     Minuti = Integer.valueof(Math.ceil((LeadExistanceHours- Ore - Giorni*8)*60));
                    
                    if(Minuti>0)
                    {
                         Secondi = Integer.valueof((((LeadExistanceHours- Ore - Giorni*8)*60)- Minuti)*100);

                        if(Secondi<0)
                          Secondi = 0;
                    }

                  }

                  TimeinBH = Giorni+' Giorni, '+Ore+' Ore, '+Minuti+' Minuti';
                  
               }
               else
               {
                
                   Ore = Integer.valueof(LeadExistanceHours);

                   Minuti = Integer.valueof(Math.ceil((LeadExistanceHours- Ore )*60));

                   Secondi = 0;

                  if(Minuti<0)
                      Minuti = 0;

                  else
                  {
                    Secondi = Integer.valueof((((LeadExistanceHours- Ore )*60)- Minuti)*100);

                    if(Secondi<0)
                      Secondi = 0;
                  }

                  //Integer Secondi = ((LeadExistanceHours- Ore )*60) - Minuti;

                  


                  TimeinBH = Ore+' Ore, '+Minuti+' Minuti';
  
                              
               }


            }
        }
    }
}
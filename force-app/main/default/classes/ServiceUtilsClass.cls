/*------------------------------------------------------------------------------------------
Author:        Orlando Aversano
Company:       Deloitte
Class:         ServiceUtilsClass
Description:   Apex class containing the methods used by the Service-side classes

History

18/01/2019     Created 
-------------------------------------------------------------------------------------------*/
public class ServiceUtilsClass {

  public static void calculateAlertDT (Case c, String bh)
  {
    Integer MissingDays = (system.today()).daysBetween(Date.valueOf(c.NextStatusDate__c));
        c.TECH_SLAHours__c = MissingDays*24;   
        if(c.TECH_SLAHours__c<0)
        {
            c.TECH_SLAHours__c = 0;
        }
        if(MissingDays >=4)
        {
          c.Automatic_Closure_Activation_DT__c = null;
          c.Automatic_Closure_Execution_DT__c = null;
            c.First_Alert_Before_Closure_DT__c = System.now().addDays(MissingDays/2);
        }
        else if(MissingDays <4 && MissingDays>0)
        {
            c.Current_Color_vs_SLA__c = 'GIALLO';
        }
        else if(MissingDays <=0)
        {
            c.Current_Color_vs_SLA__c = 'ROSSO';
        }
  }

  //MMOSCATELLI 28/03/2019: ICF CR2 -- START
  public static Case setAgentICFAlerts(Case CurrentCase, String BizHoursID)
  {
    //cambiato a double per tempi piu corti *-+ 22-06-2022
    Double Alert_1;
    Double Alert_2;

    try
    {
        if((MPS_Code_Variables__c.getValues('ICF_Agent_Alert_1')!=null) && 
            (MPS_Code_Variables__c.getValues('ICF_Agent_Alert_2')!=null) &&	
            String.isNotBlank(BizHoursID))
        {
            Alert_1= Double.valueOf(MPS_Code_Variables__c.getValues('ICF_Agent_Alert_1').Key__c);
            Alert_2= Double.valueOf(MPS_Code_Variables__c.getValues('ICF_Agent_Alert_2').Key__c);
			CurrentCase.TECH_Primo_Sollecito_Agenti__c = null;
            CurrentCase.TECH_Secondo_Sollecito_Agenti__c = null;
            if(Alert_1>0 && Alert_2>0)
            {
                CurrentCase.TECH_Primo_Sollecito_Agenti__c = BusinessHours.addGMT(BizHoursID,System.now(),(long)((Alert_1)*60 * 60 * 1000L));
                CurrentCase.TECH_Secondo_Sollecito_Agenti__c = BusinessHours.addGMT(BizHoursID,System.now(),(long)((Alert_2)*60 * 60 * 1000L));
            }
        }
    }
    catch(exception ex)
    {
        system.debug(ex.getMessage());
    }
    return CurrentCase;
  }
  //MMOSCATELLI 28/03/2019: ICF CR2 -- END
  
	//OAVERSANO 04/07/2019 : Sito Impresa (validazione visura camerale) -- START
	public static Case setSitoImpresaAlertsAndClosure(Case CurrentCase, String BizHoursID){
  		
  		Integer Alert1;
    	Integer closureAlert;

    	try
    	{
        	if((MPS_Code_Variables__c.getValues('SitoImpresa_tempiSollecito')!=null) && 
            	(MPS_Code_Variables__c.getValues('SitoImpresa_tempiChiusura')!=null) &&	
            	String.isNotBlank(BizHoursID))
        	{
	            Alert1= Integer.valueOf(MPS_Code_Variables__c.getValues('SitoImpresa_tempiSollecito').Value__c);
	            closureAlert= Integer.valueOf(MPS_Code_Variables__c.getValues('SitoImpresa_tempiChiusura').Value__c);
				CurrentCase.TECH_Sollecito_1_VC__c = null;
	            CurrentCase.TECH_Sollecito_2_VC__c = null;
	            if(Alert1>0 && closureAlert>0)
	            {
	                CurrentCase.TECH_Sollecito_1_VC__c = BusinessHours.addGMT(BizHoursID,System.now(),((Alert1)*60 * 60 * 1000L));
	                CurrentCase.TECH_Sollecito_2_VC__c = BusinessHours.addGMT(BizHoursID,System.now(),((closureAlert)*60 * 60 * 1000L));
            	}
        	}
    	}
    	catch(exception ex)
    	{
    	    system.debug(ex.getMessage());
    	}
    	return CurrentCase;
  	}
  	//OAVERSANO 04/07/2019 : Sito Impresa (validazione visura camerale) -- END
  
  //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - start
  public static void populateCustomSettingsForTests(){

    Account a = new Account(FirstName = 'test4',
                            LastName  = 'AP01',
                            Servizio__c = '',
                            PersonEmail = 'test4@ap01.com',
                            RecordTypeId = [Select Id from RecordType where Name = 'Individual'].Id
                           );
    insert a;

    List<Entitlement> entitlements = new List<Entitlement>();
    Entitlement ent1 = new entitlement(Name='Gestione SLA SmartCenter', AccountId=a.Id, StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
    entitlements.add(ent1);
    Entitlement ent2 = new Entitlement(Name='Gestione SLA GDPR Smart Center', AccountId=a.Id, StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
    entitlements.add(ent2);
    Entitlement ent3 = new Entitlement(Name='Gestione SLA GDPR Smart Center 2', AccountId=a.Id, StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
    entitlements.add(ent3);
    Entitlement ent4 = new Entitlement(Name='Gestione SLA GDPR Smart Center 3', AccountId=a.Id, StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
    entitlements.add(ent4);
    Entitlement ent5 = new Entitlement(Name='Gestione SLA Assistenza Agenti', AccountId=a.Id, StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
    entitlements.add(ent5);
    Entitlement ent6 = new Entitlement(Name='Gestione SLA Caring Angel', AccountId=a.Id, StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
    entitlements.add(ent6);
    Entitlement ent7 = new Entitlement(Name='Gestione SLA Reclamo', AccountId=a.Id, StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
    entitlements.add(ent7);
    insert entitlements;

    List<MPS_Code_Variables__c> settings = new List<MPS_Code_Variables__c>();
    for(Entitlement ent : entitlements){
        MPS_Code_Variables__c setting = new MPS_Code_Variables__c();
        setting.Name = ent.Name;
        setting.Value__c = ent.Id;
        settings.add(setting);
    }
    
    for(BusinessHours bh: [select Id,IsDefault,Name from BusinessHours where IsActive =true]){
        MPS_Code_Variables__c setting;
        if(bh.Name == 'Default'){
            setting = new MPS_Code_Variables__c();
            setting.Name = 'BusinessHours_Default';
            setting.Value__c = bh.Id;
            settings.add(setting);
        }
        else if(bh.Name == 'GDPR'){
            setting = new MPS_Code_Variables__c();
            setting.Name = 'BusinessHours_GDPR';
            setting.Value__c = bh.Id;
            settings.add(setting);
        }
        else if(bh.Name=='AAI_Agency_CTL'){
            setting = new MPS_Code_Variables__c();
            setting.Name = 'BusinessHours_AAI_Agency_CTL';
            setting.Value__c = bh.Id;
            settings.add(setting);
        }
    }
    insert settings;  
    FileUploadHelperTest.setConfig();
  }
  //MDANTONIO 09/04/2019 popolamento custom settings per classi di test - end
}
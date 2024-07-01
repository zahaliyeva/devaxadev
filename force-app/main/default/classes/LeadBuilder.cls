public class LeadBuilder{
    
    public static  Lead auto(String x){
        List<String> part = x.split(';');
        System.debug('****************part '+part);
        //File standardization
        While(part.size()<=33) part.add('');
        
        Date nomineeBday;       
        try{
            nomineeBday = Date.parse(part[8]);
    
            }
        catch(Exception e){
            nomineeBday = null;
        }
        Boolean cac;
        try{
            cac = convertBoolean(part[9]);
            }
        catch(Exception e){
            cac = null;
        }
        Decimal rcCarPrice;
        try{ 
            rcCarPrice = Decimal.valueOf(part[11]);
            }
        catch(Exception e){
            rcCarPrice = null;
        }    
        Decimal tPrice;
        try{ 
            tPrice = Decimal.valueOf(part[12]);
            }
        catch(Exception e){
            tPrice = null;
        }
        Decimal fPrice;
        try{ 
            fPrice = Decimal.valueOf(part[13]);
            }
        catch(Exception e){
            fPrice = null;
        }
        Decimal diPrice;
        try{ 
            diPrice = Decimal.valueOf(part[14]);
            }
        catch(Exception e){
            diPrice = null;
        }    
        Decimal aPrice;
        try{ 
            aPrice = Decimal.valueOf(part[15]);
            }
        catch(Exception e){
            aPrice = null;
        }   
        Decimal ufrca;
        try{ 
            ufrca = Decimal.valueOf(part[16]);
            }
        catch(Exception e){
            ufrca = null;
        }
        Decimal mcsrca;
        try{ 
            mcsrca = Decimal.valueOf(part[20]);
            }
        catch(Exception e){
            mcsrca = null;
        }
        Decimal mcst;
        try{ 
            mcst = Decimal.valueOf(part[21]);
            }
        catch(Exception e){
            mcst = null;
        }
        Decimal mcsf;
        try{ 
            mcsf = Decimal.valueOf(part[22]);
            }
        catch(Exception e){
            mcsf = null;
        }
        Decimal mcsdi;
        try{ 
            mcsdi = Decimal.valueOf(part[23]);
            }
        catch(Exception e){
            mcsdi = null;
        }
        Integer nscc5;
        try{
            nscc5 = Integer.valueOf(part[24]);
            }    
        catch(Exception e){
            nscc5 = null;
        }
        Integer nscc2;
        try{ 
            nscc2 = Integer.valueOf(part[25]);
            }    
        catch(Exception e){
            nscc2 = null;
        }
        Date sPolizza;
        try{ 
            sPolizza = Date.parse(part[26]);
            }    
        catch(Exception e){
            sPolizza = null; 
        }        
        String PIVA;
        try{ 
            PIVA = part[32];
            }    
        catch(Exception e){
            PIVA = '';
        }
        String Company;
        try{ 
            Company = part[33];
            }    
        catch(Exception e){
            Company = '';
        }
        String last = null;
        
        //Data richiesta quotazione
        
        DateTime leadDdaytime;     //
       try{ 
           leadDdaytime = DateTime.parse(part[34]);
           }
       catch(Exception e){
        leadDdaytime = null;
       }
        
        
        // dettaglio fonte lead
        
        String Leaddettagliofonte;
        try{ 
            Leaddettagliofonte = part[35];
            }    
        catch(Exception e){
            Leaddettagliofonte = '';
        }

        //CAPOBIANCO_A 11/07/2017 SPRINT 46 -- START
        //Agency Sub-Code
        String agencySubCode;
        try{
          agencySubCode = part[36];
        }
        catch(Exception e){
            agencySubCode = '';
        }
        //CAPOBIANCO_A 11/07/2017 SPRINT 46 -- END
        
        
        
        String LeadSource ='External List' ;
        String LeadSourceDetail = null;
        Boolean WebLeadMassivelyUploaded = false; //CAPOBIANCO_A 26/07/2017
        Boolean Var_TECH_Skip_triggers = true; //BOVOLENTA_D 20092017
        Boolean Var_TECH_Send_Email_Notification = false; //BOVOLENTA_D 20092017
        if (Leaddettagliofonte == 'Salva quotazione')
        {
               LeadSource = 'Web';
               WebLeadMassivelyUploaded = true; //CAPOBIANCO_A 26/07/2017
               LeadSourceDetail = 'Salva quotazione';
               Var_TECH_Skip_triggers = false;
               Var_TECH_Send_Email_Notification= true;
        }
        //CAPOBIANCO_A 28/07/2017 START - Massive upload of "Visualizza quotazione" leads
        else if (Leaddettagliofonte == 'Visualizza quotazione')
        {
               LeadSource = 'Web';
               WebLeadMassivelyUploaded = true;
               LeadSourceDetail = 'Visualizza quotazione';
               Var_TECH_Skip_triggers = false;
               Var_TECH_Send_Email_Notification= true;
        }
        //CAPOBIANCO_A 28/07/2017 END - Massive upload of "Visualizza quotazione" leads
        
        return new Lead( FirstName = part[0], 
                         LastName = part[1], 
                         Phone = part[2], 
                         Email = part[3],
                         Fiscal_ID__c = part[4] , 
                         Agency_Code__c = padding(part[5]),
                         External_List_Source__c = part[6],
                         Notes__c = part[7], 
                         Nominee_Birthdate__c = nomineeBday, 
                         Commercial_Activity_Consensus__c = cac ,
                         Line__c = transcodeLine(part[10]), 
                         RC_Car_Price__c = rcCarPrice, 
                         Theft_price__c = tPrice,
                         Fire_Price__c = fPrice, 
                         Driver_Injury_Price__c = diPrice, 
                         Assistance_Price__c = aPrice, 
                         Uncovered_Franchise_RC_Auto__c = ufrca,
                         Uncovered_Franchise_Theft__c = part[17],
                         Uncovered_Franchise_Fire__c = part[18],
                         Uncovered_Franchise_Driver_Injury__c = part[19], 
                         Maximum__c = mcsrca, 
                         Maximum_Capital_Secured_Theft__c = mcst,
                         Maximum_Capital_Secured_Fire__c = mcsf,
                         Maximum_Capital_Secured_Driver_Injury__c = mcsdi,
                         N_di_sinistri_con_colpa_ultimi_5_anni__c = nscc5, 
                         N_di_sinistri_con_colpa_ultimi_2_anni__c = nscc2, 
                         Data_scadenza_polizza_c_o_concorrente__c = sPolizza, 
                         Universal_Class__c = part[27],
                         Car_Model__c = part[28], 
                         Plate__c = part[29], 
                         Car_Supply__c = part[30], 
                         Landing_page__c = part[31],
                         AAI_Partita_IVA__c = PIVA,
                         Company = Company,
                         TECH_Company__c = 'AAI',
                         Data_richesta_quotazione__c = leadDdaytime,
                         LeadSource = LeadSource, 
                         Dettaglio__c=LeadSourceDetail,
                         CountryCode = 'IT',
                         TECH_Skip_triggers__c = Var_TECH_Skip_triggers, 
                         TECH_Send_Email_Notification__c = Var_TECH_Send_Email_Notification,
                         //CAPOBIANCO_A 14/07/2017 -- START
                         Status = 'To be processed',
                         Codice_Sub_Agenzia__c = agencySubCode, 
                         //CAPOBIANCO_A 14/07/2017 -- END
                         PostalCode = part[37], //BOVOLENTA_D 31072017
                         TECH_Massively_uploaded_web_lead__c = WebLeadMassivelyUploaded, //CAPOBIANCO_A 26/07/2017 

                         //no limits on recortypeID calls. Here no problems on the name as DEv name, and all languages (IT-ENG) have the "Auto" label
                         recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead AXA Assicurazioni').getRecordTypeId()
                         );
                        
       }
   
   public static  Lead nonAuto(String x,Map<String,String> siglaCitta ){
       List<String> part = x.split(';');
       System.debug('****************part '+part);
       //File standardization
       While(part.size()<=36) part.add('');
       Date leadBday;
       try{ 
           leadBday = Date.parse(part[9]);
           }
       catch(Exception e){
        leadBday = null;
       }
       Boolean cac;
       try{
            cac = convertBoolean(part[11]);
            }
       catch(Exception e){
        cac = null;
       }
       Boolean privacy;
       try{
            privacy = convertBoolean(part[12]);
            }
       catch(Exception e){
        privacy = null;
       }
       String state = part[15];
       
      
      DateTime leadDdaytime;     //
       try{ 
           leadDdaytime = DateTime.parse(part[21]);
           }
       catch(Exception e){
        leadDdaytime = null;
       }
       
       
       
       
       //If is a code
       if(state.length()==2) state = siglaCitta.get(state.toUpperCase());

        String PIVA;
        try{ 
            PIVA = part[19];
            }    
        catch(Exception e){
            PIVA = '';
        }
        String Company;
        try{ 
            Company = part[20];
            }    
        catch(Exception e){
            Company = '';
        }
        
        // dettaglio fonte lead
        
        String Leaddettagliofonte;
        try{ 
            Leaddettagliofonte = part[22];
            }    
        catch(Exception e){
            Leaddettagliofonte = '';
        }
        
        
       
        String LeadSource ='External List' ;
        String LeadSourceDetail = null;
        Boolean WebLeadMassivelyUploaded = false; //CAPOBIANCO_A 26/07/2017
        Boolean Var_TECH_Skip_triggers = true; //BOVOLENTA_D 20092017
        Boolean Var_TECH_Send_Email_Notification = false; //BOVOLENTA_D 20092017
        if (Leaddettagliofonte == 'Salva quotazione')
        {
               LeadSource = 'Web';
               WebLeadMassivelyUploaded = true; //CAPOBIANCO_A 26/07/2017
               LeadSourceDetail = 'Salva quotazione';
               Var_TECH_Skip_triggers = false;
               Var_TECH_Send_Email_Notification= true;
        }
        //CAPOBIANCO_A 28/07/2017 START - Massive upload of "Visualizza quotazione" leads
        else if (Leaddettagliofonte == 'Visualizza quotazione')
        {
               LeadSource = 'Web';
               WebLeadMassivelyUploaded = true;
               LeadSourceDetail = 'Visualizza quotazione';
               Var_TECH_Skip_triggers = false;
               Var_TECH_Send_Email_Notification= true;
        }
        //CAPOBIANCO_A 28/07/2017 END - Massive upload of "Visualizza quotazione" leads        
               system.debug('++++++++++++++++++++++++'+LeadSourceDetail); 

       /////
     Boolean razz;
        try{
            razz = convertBoolean(part[29]);
            }
        catch(Exception e){
            razz = null;
        }
        
     Boolean RC;
        try{
            RC = convertBoolean(part[30]);
            }
        catch(Exception e){
            RC = null;
        } 
        
     
     Boolean TutelaLegale;
        try{
            TutelaLegale = convertBoolean(part[32]);
            }
        catch(Exception e){
            TutelaLegale = null;
        } 
     Boolean Assistenza;
        try{
            Assistenza = convertBoolean(part[33]);
            }
        catch(Exception e){
            Assistenza = null;
        }
     
     Decimal PrezzoAnnuo;
        try{
            PrezzoAnnuo =  Decimal.valueOf(part[23]);
            }
        catch(Exception e){
            PrezzoAnnuo = null;
        }
        
Decimal PremioinProduzione;
        try{
            PremioinProduzione =  Decimal.valueOf(part[24]);
            }
        catch(Exception e){
            PremioinProduzione = null;
        }
    
Decimal massimaTutela;
        try{
            massimaTutela =  Decimal.valueOf(part[31]);
            }
        catch(Exception e){
            massimaTutela = null;
        }

        //CAPOBIANCO_A 11/07/2017 SPRINT 46 -- START
        //Agency Sub-Code
        String agencySubCode;
        try{
          agencySubCode = part[37];
        }
        catch(Exception e){
            agencySubCode = '';
        }
        //CAPOBIANCO_A 11/07/2017 SPRINT 46 -- END   
       
       ///
       Address addr = null;
       Lead thislead = new Lead( FirstName = part[0], 
                        LastName = part[1],                      
                        Phone = part[2], 
                        Email = part[3],
                        Fiscal_ID__c = part[4] , 
                        Gender__c = transcodeGender(part[5]),
                        Agency_Code__c = padding(part[6]), 
                        External_List_Source__c = part[7], 
                        Notes__c = part[8], 
                        Lead_Birthdate__c = leadBday,
                        Available_Hours__c = part[10], 
                        Commercial_Activity_Consensus__c = cac, 
                        Privacy_Terms__c = privacy, 
                        Line__c = transcodeLine(part[13]),
                        City = part[14],
                        State = state,
                        PostalCode = part[16],
                        Street = part[17],
                        Landing_page__c = part[18],
                        Data_richesta_quotazione__c = leadDdaytime,   //
                        AAI_Partita_IVA__c = PIVA,
                        Company = Company,                        
                        TECH_Company__c = 'AAI',
                        //Country = 'Italy',
                        CountryCode = 'IT',
                        TECH_Skip_triggers__c = Var_TECH_Skip_triggers, 
                        TECH_Send_Email_Notification__c = Var_TECH_Send_Email_Notification,
                        Dettaglio__c= LeadSourceDetail ,
                        LeadSource = LeadSource,
                        Prezzo_annuo_Confido__c = PrezzoAnnuo,
                        Premio_in_promozione__c = PremioinProduzione,
                        Nome_animale__c= part[26],
                        Tipologia_animale__c= part[27],
                        Et_animale__c= part[28],
                        Razza_pericolosa__c = razz,
                        RC_cani_e_gatti_plus__c= RC,
                        Massimale_Tutela_medica_e_sanitaria__c=massimaTutela,
                        Tutela_legale__c= TutelaLegale,
                        Assistenza_H24__c= Assistenza,
                        Provincia_att_assicurare__c = (part[34]),
                        Citta_att_assicurare__c = (part[35]),
                        CAP_att_assicurare__c = (part[36]),
                        //CAPOBIANCO_A 14/07/2017 -- START
                        Codice_Sub_Agenzia__c = agencySubCode,
                        Status = 'To be processed',
                        //CAPOBIANCO_A 14/07/2017 -- END
                        TECH_Massively_uploaded_web_lead__c = WebLeadMassivelyUploaded //CAPOBIANCO_A 26/07/2017 

                        //Not here as I must check the lagnuage label
                        //recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead AXA Assicurazioni').getRecordTypeId()
                        );
       try {
            Schema.RecordTypeInfo myRTinfo = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead AXA Assicurazioni');
            if (myRTinfo!=null) {
                thislead.RecordtypeId=myRTinfo.getRecordTypeId();
            } else {
                thislead.recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead AXA Assicurazioni').getRecordTypeId();
            }
       } catch (exception e) {
            ApplicationLogHelper.ERROR('LeadBuilder', e.getMessage(), e.getStackTraceString());
        
       }
       return thislead;
   }
 
    public static  Lead previdenza(String x,Map<String,String> siglaCitta ){
       List<String> part = x.split(';');
       System.debug('****************part '+part);
       //File standardization
       While(part.size()<=36) part.add('');
       Date leadBday;
       try{ 
           leadBday = Date.parse(part[9]);
           }
       catch(Exception e){
        leadBday = null;
       }
       Boolean cac;
       try{
            cac = convertBoolean(part[11]);
            }
       catch(Exception e){
        cac = null;
       }
       Boolean privacy;
       try{
            privacy = convertBoolean(part[12]);
            }
       catch(Exception e){
        privacy = null;
       }
       String state = part[15];
       
       //If is a code
       if(state.length()==2) state = siglaCitta.get(state.toUpperCase());

        String PIVA;
        try{ 
            PIVA = part[19];
            }    
        catch(Exception e){
            PIVA = '';
        }
        String Company;
        try{ 
            Company = part[20];
            }    
        catch(Exception e){
            Company = '';
        }
       
       Address addr = null;
       
       DateTime leadDdaytime;     //
       try{ 
           leadDdaytime = DateTime.parse(part[21]);
           }
       catch(Exception e){
        leadDdaytime = null;
       }
       
       
        // dettaglio fonte lead
        
        String Leaddettagliofonte;
        try{ 
            Leaddettagliofonte = part[22];
            }    
        catch(Exception e){
            Leaddettagliofonte = '';
        }
        
        String LeadSource ='External List' ;
        String LeadSourceDetail = null;
        Boolean WebLeadMassivelyUploaded = false; //CAPOBIANCO_A 26/07/2017
        Boolean Var_TECH_Skip_triggers = true; //BOVOLENTA_D 20092017
        Boolean Var_TECH_Send_Email_Notification = false; //BOVOLENTA_D 20092017
        if (Leaddettagliofonte == 'Salva quotazione')
        {
               LeadSource = 'Web';
               WebLeadMassivelyUploaded = true; //CAPOBIANCO_A 26/07/2017
               LeadSourceDetail = 'Salva quotazione';
               Var_TECH_Skip_triggers = false;
               Var_TECH_Send_Email_Notification= true;
        }
        //CAPOBIANCO_A 28/07/2017 START - Massive upload of "Visualizza quotazione" leads
        else if (Leaddettagliofonte == 'Visualizza quotazione')
        {
               LeadSource = 'Web';
               WebLeadMassivelyUploaded = true;
               LeadSourceDetail = 'Visualizza quotazione';
               Var_TECH_Skip_triggers = false;
               Var_TECH_Send_Email_Notification= true;
        }
        //CAPOBIANCO_A 28/07/2017 END - Massive upload of "Visualizza quotazione" leads        

        //CAPOBIANCO_A 11/07/2017 SPRINT 46 -- START
        //Agency Sub-Code
        String agencySubCode;
        try{
          agencySubCode = part[23];
        }
        catch(Exception e){
            agencySubCode = '';
        }
        //CAPOBIANCO_A 11/07/2017 SPRINT 46 -- END    
        
       system.debug('++++++++++++++++++++++++'+LeadSourceDetail);
       
       Lead thislead = new Lead( FirstName = part[0], 
                        LastName = part[1],                      
                        Phone = part[2], 
                        Email = part[3],
                        Fiscal_ID__c = part[4] , 
                        Gender__c = transcodeGender(part[5]),
                        Agency_Code__c = padding(part[6]), 
                        External_List_Source__c = part[7], 
                        Notes__c = part[8], 
                        Lead_Birthdate__c = leadBday,
                        Available_Hours__c = part[10], 
                        Commercial_Activity_Consensus__c = cac, 
                        Privacy_Terms__c = privacy, 
                        Line__c = transcodeLine(part[13]),
                        City = part[14],
                        State = state,
                        PostalCode = part[16],
                        Street = part[17],
                        Landing_page__c = part[18],
                        Data_richesta_quotazione__c= leadDdaytime,
                        AAI_Partita_IVA__c = PIVA,
                        Company = Company,                          
                        TECH_Company__c = 'AAI',
                        //Country = 'Italy',
                        LeadSource = LeadSource,
                        Dettaglio__c = LeadSourceDetail,
                        CountryCode = 'IT',
                        TECH_Skip_triggers__c = Var_TECH_Skip_triggers, 
                        TECH_Send_Email_Notification__c = Var_TECH_Send_Email_Notification, 
                        //CAPOBIANCO_A 14/07/2017 -- START
                        Status = 'To be processed',
                        Codice_Sub_Agenzia__c = agencySubCode, 
                        //CAPOBIANCO_A 14/07/2017 -- END
                        TECH_Massively_uploaded_web_lead__c = WebLeadMassivelyUploaded //CAPOBIANCO_A 26/07/2017 
                        //Not here as I must check the lagnuage label
                        //recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead AXA Assicurazioni').getRecordTypeId()
                        );
       try {
            Schema.RecordTypeInfo myRTinfo = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead AXA Assicurazioni');
            if (myRTinfo!=null) {
                thislead.RecordtypeId=myRTinfo.getRecordTypeId();
            } else {
                thislead.recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead AXA Assicurazioni').getRecordTypeId();
            }
       } catch (exception e) {
            ApplicationLogHelper.ERROR('LeadBuilder', e.getMessage(), e.getStackTraceString());
        
       }
       return thislead;
   }

public static  Lead protezione(String x,Map<String,String> siglaCitta ){
       List<String> part = x.split(';');
       System.debug('****************part '+part);
       //File standardization
       While(part.size()<=20) part.add('');
       Date leadBday;
       try{ 
           leadBday = Date.parse(part[9]);
           }
       catch(Exception e){
        leadBday = null;
       }
       Boolean cac;
       try{
            cac = convertBoolean(part[11]);
            }
       catch(Exception e){
        cac = null;
       }
       Boolean privacy;
       try{
            privacy = convertBoolean(part[12]);
            }
       catch(Exception e){
        privacy = null;
       }
       String state = part[15];
       
       //If is a code
       if(state.length()==2) state = siglaCitta.get(state.toUpperCase());
       
        String PIVA;
        try{ 
            PIVA = part[19];
            }    
        catch(Exception e){
            PIVA = '';
        }
        String Company;
        try{ 
            Company = part[20];
            }    
        catch(Exception e){
            Company = '';
        }
       
       Address addr = null;
       
       DateTime leadDdaytime;     //
       try{ 
           leadDdaytime = DateTime.parse(part[21]);
           }
       catch(Exception e){
        leadDdaytime = null;
       }
       
        // dettaglio fonte lead
        
        String Leaddettagliofonte;
        try{ 
            Leaddettagliofonte = part[22];
            }    
        catch(Exception e){
            Leaddettagliofonte = '';
        }

        //CAPOBIANCO_A 11/07/2017 SPRINT 46 -- START
        //Agency Sub-Code
        String agencySubCode;
        try{
          agencySubCode = part[23];
        }
        catch(Exception e){
            agencySubCode = '';
        }
        //CAPOBIANCO_A 11/07/2017 SPRINT 46 -- END
        
        
        
        String LeadSource ='External List' ;
        String LeadSourceDetail = null;
        Boolean WebLeadMassivelyUploaded = false; //CAPOBIANCO_A 26/07/2017
        Boolean Var_TECH_Skip_triggers = true; //BOVOLENTA_D 20092017
        Boolean Var_TECH_Send_Email_Notification = false; //BOVOLENTA_D 20092017
        if (Leaddettagliofonte == 'Salva quotazione')
        {
               LeadSource = 'Web';
               WebLeadMassivelyUploaded = true; //CAPOBIANCO_A 26/07/2017
               LeadSourceDetail = 'Salva quotazione';
               Var_TECH_Skip_triggers = false;
               Var_TECH_Send_Email_Notification= true;
        }
        //CAPOBIANCO_A 28/07/2017 START - Massive upload of "Visualizza quotazione" leads
        else if (Leaddettagliofonte == 'Visualizza quotazione')
        {
               LeadSource = 'Web';
               WebLeadMassivelyUploaded = true;
               LeadSourceDetail = 'Visualizza quotazione';
               Var_TECH_Skip_triggers = false;
               Var_TECH_Send_Email_Notification= true;
        }
        //CAPOBIANCO_A 28/07/2017 END - Massive upload of "Visualizza quotazione" leads 
        
       system.debug('++++++++++++++++++++++++'+LeadSourceDetail);
        
       Lead thislead = new Lead( FirstName = part[0], 
                        LastName = part[1],                      
                        Phone = part[2], 
                        Email = part[3],
                        Fiscal_ID__c = part[4] , 
                        Gender__c = transcodeGender(part[5]),
                        Agency_Code__c = padding(part[6]), 
                        External_List_Source__c = part[7], 
                        Notes__c = part[8], 
                        Lead_Birthdate__c = leadBday,
                        Available_Hours__c = part[10], 
                        Commercial_Activity_Consensus__c = cac, 
                        Privacy_Terms__c = privacy, 
                        Line__c = transcodeLine(part[13]),
                        City = part[14],
                        State = state,
                        PostalCode = part[16],
                        Street = part[17],
                        Landing_page__c = part[18],
                        AAI_Partita_IVA__c = PIVA,
                        Company = Company,                          
                        TECH_Company__c = 'AAI',
                        CountryCode = 'IT',
                        TECH_Skip_triggers__c = Var_TECH_Skip_triggers, 
                        TECH_Send_Email_Notification__c = Var_TECH_Send_Email_Notification,
                        //Country = 'Italy',
                        Data_richesta_quotazione__c= leadDdaytime,
                        LeadSource = LeadSource,
                        Dettaglio__c = LeadSourceDetail,
                        //CAPOBIANCO_A 14/07/2017 -- START
                        Status = 'To be processed',
                        Codice_Sub_Agenzia__c = agencySubCode, 
                        //CAPOBIANCO_A 14/07/2017 -- END
                        TECH_Massively_uploaded_web_lead__c = WebLeadMassivelyUploaded //CAPOBIANCO_A 26/07/2017 

                        //Not here as I must check the lagnuage label
                        //recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead AXA Assicurazioni').getRecordTypeId()
                        );
       try {
            Schema.RecordTypeInfo myRTinfo = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead AXA Assicurazioni');
            if (myRTinfo!=null) {
                thislead.RecordtypeId=myRTinfo.getRecordTypeId();
            } else {
                thislead.recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead AXA Assicurazioni').getRecordTypeId();
            }
       } catch (exception e) {
            ApplicationLogHelper.ERROR('LeadBuilder', e.getMessage(), e.getStackTraceString());
        
       }
       return thislead;
   }   

    public static boolean convertBoolean(String x){
         if(x.toUpperCase() == 'VERO') return true;
         return false;
        }
    public static String transcodeGender(String x){
         if(x.toUpperCase() == 'MASCHIO') return 'Maschio';
         if(x.toUpperCase() == 'M') return 'Maschio';
         if(x.toUpperCase() == 'FEMMINA') return 'Femmina';
         if(x.toUpperCase() == 'F') return 'Femmina';
         return '';
        }
    public static String transcodeLine(String x){
         System.debug('-------- Inizio codifica Line -------------');
         if(x.toUpperCase() == 'AUTO') return 'Auto';
         if(x.toUpperCase() == 'ALTRO') return 'Altro';
         if(x.toUpperCase() == 'FAMIGLIA') return 'Famiglia';
         if(x.toUpperCase() == 'INVESTIMENTO') return 'Investimento';
         if(x.toUpperCase() == 'PREVIDENZA') return 'Previdenza';
         if(x.toUpperCase() == 'PROTEZIONE') return 'Protezione';
         if(x.toUpperCase() == 'RISPARMIO') return 'Risparmio';
         if(x.toUpperCase() == 'SALUTE') return 'Salute';      
         return '';
        }
     
    //CAPOBIANCO_A 11/07/2017 SPRINT 46 -- START - the agency code is not mandatory anymore
    public static String padding(String x){
        if(String.isNotBlank(x))
        {
            while(x.length()<6) x = '0' + x;
        }
        return x;
    }
     //CAPOBIANCO_A 11/07/2017 SPRINT 46 -- END

     /*public static String padding(String x){
         while(x.length()<6) x = '0' + x;
         return x;
     }*/
}
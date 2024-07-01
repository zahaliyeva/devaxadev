public without sharing class LM_Email_CTRL {

    public Id relatedToLeadId {get;set;}
    public Datetime minDatetimeForReassign {get;set;}
    public String minDatetimeForReassignString {get;set;}
    public Lead theLead {get;set;}
    public String Error {get;set;}
    public String Agency {get;set;}
    public String Error2 {get;set;}
    public String AgNumber {get;set;}
    public String InfoBanner {get;set;}
    public String ErrorInfo {get;set;}
    public String InfoBanner2 {get;set;}
    public String ErrorInfo2 {get;set;}
    
    public LM_Email_CTRL() {

    }
    
    public String getReassignDateTime () {
        
        //theLead = [SELECT Id,FirstName,LastName,Ultima_data_di_riassegnazione__c FROM Lead WHERE Id = :relatedToLeadId LIMIT 1];
        BusinessHours bhAfterLunch = [SELECT CreatedById,CreatedDate,FridayEndTime,FridayStartTime,Id,IsActive,IsDefault,LastModifiedById,LastModifiedDate,MondayEndTime,MondayStartTime,Name,SaturdayEndTime,SaturdayStartTime,SundayEndTime,SundayStartTime,SystemModstamp,ThursdayEndTime,ThursdayStartTime,TimeZoneSidKey,TuesdayEndTime,TuesdayStartTime,WednesdayEndTime,WednesdayStartTime FROM BusinessHours WHERE Name = 'AAI_Agency_AfterLunch' ]; // NOPMD  Fix CRUD violation
        BusinessHours bhBeforeLunch = [SELECT CreatedById,CreatedDate,FridayEndTime,FridayStartTime,Id,IsActive,IsDefault,LastModifiedById,LastModifiedDate,MondayEndTime,MondayStartTime,Name,SaturdayEndTime,SaturdayStartTime,SundayEndTime,SundayStartTime,SystemModstamp,ThursdayEndTime,ThursdayStartTime,TimeZoneSidKey,TuesdayEndTime,TuesdayStartTime,WednesdayEndTime,WednesdayStartTime FROM BusinessHours WHERE Name = 'AAI_Agency_BeforeLunch' ]; // NOPMD  Fix CRUD violation
        
        List<Lead> theLeads = [SELECT Id,FirstName,LastName,Ultima_data_di_riassegnazione__c,Landing_Page__c,Provenienza_Campagne_Agenti__c FROM Lead WHERE Id = :relatedToLeadId LIMIT 1];
        Datetime minDatetimeForReassign;

        String agencyCampaign = ''; 
        Boolean isNotSitiAgenti = true;

        if (theLeads.size()>0 && theLeads[0].Ultima_data_di_riassegnazione__c != null && (String.isBlank(theLeads[0].Provenienza_Campagne_Agenti__c) || theLeads[0].Provenienza_Campagne_Agenti__c == null) && theLeads[0].Landing_Page__c != 'Siti Agenti') //CAPOBIANCO_A 03/11/2017 Added the condition on the Ultima_data_di_riassegnazione__c
        {
            Lead theLead=theLeads[0];
     
            Double toBeProcessedLimitInMillisecondsDouble = LeadAssignmentConfiguration__c.getValues('ToBeProcessedTimeLimitHours').HoursLimit__c*60*60*1000;

            Long toBeProcessedLimitInMilliseconds = (Long)toBeProcessedLimitInMillisecondsDouble;
            Long elapsedTimeMs;
            Long remainingTimeMs = toBeProcessedLimitInMilliseconds;

            Date dayOfAssignment = date.newinstance(theLead.Ultima_data_di_riassegnazione__c.year(), theLead.Ultima_data_di_riassegnazione__c.month(), theLead.Ultima_data_di_riassegnazione__c.day());
            Datetime endDatetime;
            Datetime startNextDatetime;

            //CAPOBIANCO_A 03/11/2017 BUGFIX Visualforce Email Template -- START
            //String dayOfWeek = system.now().format('u');
            //Integer numDayOfWeek = Integer.ValueOf (dayOfWeek);
            DateTime dayOfWeekDT = DateTime.newInstance(dayOfAssignment, Time.newInstance(0, 0, 0, 0));
            String dayOfWeek = dayOfWeekDT.format('u');
            Integer numDayOfWeek = Integer.ValueOf (dayOfWeek);
            //CAPOBIANCO_A 03/11/2017 BUGFIX Visualforce Email Template -- END

            Integer daysToAdd = 1;
            Datetime currentDatetime = theLead.Ultima_data_di_riassegnazione__c;
            
            String momentToEval;
            
            Time hoursOfAssignment = currentDatetime.time();
                        
            Boolean inBeforeLunch = BusinessHours.isWithin(bhBeforeLunch.Id, currentDatetime);
            Boolean inAfterLunch = BusinessHours.isWithin(bhAfterLunch.Id, currentDatetime);
            Boolean lunch = ((numDayOfWeek <= 5) && ( hoursOfAssignment >= bhBeforeLunch.MondayEndTime ) && (hoursOfAssignment <= bhAfterLunch.MondayStartTime));
            Boolean weekend = (numDayOfWeek > 5);
            Boolean close = (( hoursOfAssignment >= bhAfterLunch.MondayEndTime ) || (hoursOfAssignment <= bhBeforeLunch.TuesdayStartTime));
            //Boolean lunch_weekend = ((numDayOfWeek > 5) && ( hoursOfAssignment >= bhBeforeLunch.MondayEndTime ) && (hoursOfAssignment <= bhAfterLunch.MondayStartTime));
              
            if ( inBeforeLunch ){
                momentToEval = 'morning';
            } else if ( inAfterLunch ){
                momentToEval = 'afternoon';
            } else if ( lunch ) {
                // SERGER 03/04/2018: This check is added to control if the reassignment in the lunchtime is during the holiday
                // FOZDEN 22/08/2019: BUGFIX - Start
                // if(currentDatetime.day() == Businesshours.add(bhBeforeLunch.id, currentDatetime, 1).day()){
                if(currentDatetime.day() == BusinessHours.nextStartDate(bhAfterLunch.Id, currentDatetime).day()){
                // FOZDEN 22/08/2019: BUGFIX - End
                    // SERGER 03/04/2018: NOT Holiday
                    momentToEval = 'afternoon';
                    currentDatetime = BusinessHours.nextStartDate(bhAfterLunch.Id, currentDatetime);
                }
                else {
                    // SERGER 03/04/2018: Holiday
                    momentToEval = 'morning';
                    currentDatetime = BusinessHours.nextStartDate(bhBeforeLunch.Id, currentDatetime);
                }
            } else if ( weekend || close ){
                momentToEval = 'morning';
                currentDatetime = BusinessHours.nextStartDate(bhBeforeLunch.Id, currentDatetime);
            } else {
                // SERGER 03/04/2018: All the other cases are BH in Holiday
                momentToEval = 'morning';
                currentDatetime = BusinessHours.nextStartDate(bhBeforeLunch.Id, currentDatetime);
            }
                        
            Datetime endEstimated;
            Integer i = 0;
            
            while(remainingTimeMs > 0){
                i = i + 1; 
                
                if (momentToEval.equals('morning')){
                    
                    endDatetime = Datetime.newInstance(currentDatetime.date(), Time.newInstance(bhBeforeLunch.MondayEndTime.hour(), bhBeforeLunch.MondayEndTime.minute(), bhBeforeLunch.MondayEndTime.second(), 0));
                    endEstimated = BusinessHours.add(bhBeforeLunch.Id, currentDatetime, remainingTimeMs);
                
                    if(currentDatetime.day() == endEstimated.day() && currentDatetime.month() == endEstimated.month() && currentDatetime.year() == endEstimated.year() ){
                    
                        elapsedTimeMs = BusinessHours.diff(bhBeforeLunch.Id, currentDatetime, endEstimated);
                        currentDatetime = endEstimated;
                        remainingTimeMs = remainingTimeMs - elapsedTimeMs;
                        
                    } else {
                        
                        momentToEval = 'afternoon';
                        elapsedTimeMs = BusinessHours.diff(bhBeforeLunch.Id, currentDatetime, endDatetime);
                        remainingTimeMs = remainingTimeMs - elapsedTimeMs;
                        currentDatetime = BusinessHours.nextStartDate(bhAfterLunch.Id, currentDatetime);    
                        
                    }
                                        
                } else if (momentToEval.equals('afternoon')){
                                        
                    endDatetime = Datetime.newInstance(currentDatetime.date(), Time.newInstance(bhAfterLunch.MondayEndTime.hour(), bhAfterLunch.MondayEndTime.minute(), bhAfterLunch.MondayEndTime.second(), 0));
                    endEstimated = BusinessHours.add(bhAfterLunch.Id, currentDatetime, remainingTimeMs);                    
                    
                    if(currentDatetime.day() == endEstimated.day() && currentDatetime.month() == endEstimated.month() && currentDatetime.year() == endEstimated.year() ){
                        
                        elapsedTimeMs = BusinessHours.diff(bhAfterLunch.Id, currentDatetime, endEstimated);
                        currentDatetime = endEstimated;
                        remainingTimeMs = remainingTimeMs - elapsedTimeMs;
                                            
                    } else {

                        momentToEval = 'morning';
                        elapsedTimeMs = BusinessHours.diff(bhAfterLunch.Id, currentDatetime, endDatetime);
                        remainingTimeMs = remainingTimeMs - elapsedTimeMs;
                        currentDatetime = BusinessHours.nextStartDate(bhBeforeLunch.Id, currentDatetime);   
                        
                    }                   
                }
                minDatetimeForReassign = currentDatetime;
            }
            
            //CAPOBIANCO_A 03/11/2017 BUGFIX Visualforce Email Template -- START
            if(minDatetimeForReassign != null)
            {
                if((String.isBlank(agencyCampaign) || agencyCampaign == null)  && isNotSitiAgenti){
                
                minDatetimeForReassignString = minDatetimeForReassign.format();
                return minDatetimeForReassignString;

                }else{

                    Error = getError(agencyCampaign, isNotSitiAgenti);
                    return '';
                }
            }
            else
            {   
                Error = getError(agencyCampaign, isNotSitiAgenti);
                return Error;
            }
        }else
        {   if(theLeads.size()>0){
            if((!(String.isBlank(theLeads[0].Provenienza_Campagne_Agenti__c)) && theLeads[0].Provenienza_Campagne_Agenti__c != null) || !(theLeads[0].Landing_Page__c != 'Siti Agenti')){
            agencyCampaign = theLeads[0].Provenienza_Campagne_Agenti__c; 
            isNotSitiAgenti = theLeads[0].Landing_Page__c != 'Siti Agenti';
            Error = getError(agencyCampaign, isNotSitiAgenti);
            return Error;
            }
            }
            else if(theLeads.size()==0){
                Error = getError(agencyCampaign, isNotSitiAgenti);
                return Error;
            }
            Error = getError(agencyCampaign, isNotSitiAgenti);
            return Error;
        }
    }

    public String getError(String agencyCampaign, Boolean isNotSitiAgenti)
    {
        String errorString = '';
        try
        {  
            if((String.isBlank(agencyCampaign) || agencyCampaign == null)  && isNotSitiAgenti){

                Integer timeLimit = Integer.valueOf(LeadAssignmentConfiguration__c.getValues('ToBeProcessedTimeLimitHours').HoursLimit__c);
                String timeLimitString = String.valueOf(timeLimit);
                errorString = timeLimitString+' ore lavorative dall\'assegnazione ';
                return errorString;
            }else{

                if((!String.isBlank(agencyCampaign) && !(agencyCampaign == null))  || !isNotSitiAgenti){

                return errorString;
            }
            }
        }
        catch(exception e)
        {
            errorString = 'le ore lavorative previste dall\'assegnazione ';
            return errorString;
        }
        return errorString;
    }
    //CAPOBIANCO_A 03/11/2017 BUGFIX Visualforce Email Template -- END

    public String getAgencyString (){
        List<Lead> theLeads = [SELECT Id,FirstName,LastName,Numero_assegnazioni_eseguite__c FROM Lead WHERE Id = :relatedToLeadId LIMIT 1];
        if (theLeads.size() >0){
            Lead theLead=theLeads[0];
            
            if (theLead.Numero_assegnazioni_eseguite__c != null ){
                if(theLead.Numero_assegnazioni_eseguite__c -1 == 1){
                    Agency = 'agenzia'; 
                }else{
                    Agency = 'agenzie';
                }
            } 
            return Agency;
        }else{
            Error2 = 'agenzia/e';
            return Error2;
        }
    }
    
    public String getAgencyNumberString (){
        List<Lead> theLeads = [SELECT Id,FirstName,LastName,Numero_assegnazioni_eseguite__c FROM Lead WHERE Id = :relatedToLeadId LIMIT 1];
        
        if (theLeads.size() >0){
            Lead theLead=theLeads[0];
                        
            if (theLead.Numero_assegnazioni_eseguite__c != null ){
                AgNumber = String.valueOf(theLead.Numero_assegnazioni_eseguite__c-1);
            } 
            return AgNumber;
        }else{
            Error2 = 'numero agenzie non disponibile';
            return Error2;
        }
    }
    
    public String getInfoString (){
        
    
        List<Lead> theLeads = [SELECT Id,FirstName,LastName,Landing_Page__c, Ammontare_sconto_NPC__c, Ammontare_sconto_RC_Auto__c  FROM Lead WHERE Id = :relatedToLeadId LIMIT 1];
 
        if (theLeads.size() >0){
            Lead theLead=theLeads[0];
              
            //List <String> InfoBanner = new List<String>();
            
            if (theLead.Landing_Page__c == 'Semplicemente casa' && theLead.Ammontare_sconto_NPC__c!=0){
            
                //List<Document>  imgid = [select id, name, body from Document where name = 'sconto_NPC' LIMIT 1]; 
                
                InfoBanner = '<b>Ricontatta il tuo lead</b> e ricordati che il <b>prezzo è inclusivo</b> della convenzione <b>clienti web</b>!';
                //InfoBanner = System.URL.getSalesforceBaseUrl().toExternalForm().replace('https','http')+'/servlet/servlet.ImageServer?id='+imgid[0].id+'&oid='+UserInfo.getOrganizationId();
                
            }else if(theLead.Landing_Page__c == 'Preventivo veloce' && theLead.Ammontare_sconto_RC_Auto__c!=0){
            
                //List<Document>  imgid = [select id, name, body from Document where name = 'sconto_NPA' LIMIT 1]; 
         
                InfoBanner = '<b>Ricontatta il tuo lead</b> e ricordati che per replicare il <b>premio su AOL</b> devi applicare la <b>convenzione d\'attacco del 20% su RCA</b>';
                //InfoBanner = System.URL.getSalesforceBaseUrl().toExternalForm().replace('https','http')+'/servlet/servlet.ImageServer?id='+imgid[0].id+'&oid='+UserInfo.getOrganizationId();
            
            }else if(theLead.Landing_Page__c == 'Preventivatore Turismo' ){
            
                //List<Document>  imgid = [select id, name, body from Document where name = 'sconto_PT' LIMIT 1]; 
         
                InfoBanner = '<b>Ricontatta il tuo lead</b> e ricordati che per applicare lo <b>sconto del 10% su DAOL</b> devi inserire <b>il codice convenzione COLP03</b>';
                //InfoBanner = System.URL.getSalesforceBaseUrl().toExternalForm().replace('https','http')+'/servlet/servlet.ImageServer?id='+imgid[0].id+'&oid='+UserInfo.getOrganizationId();
            }
            
            return InfoBanner;
        }else{
            
            String ErrorInfo = '';
            ErrorInfo = 'Nessun Lead di riferimento trovato';
           
            return ErrorInfo;
        }
    
    }
    
    public String getImageDocURL (){
        
    
        List<Lead> theLeads = [SELECT Id,FirstName,LastName,Landing_Page__c, Ammontare_sconto_NPC__c, Ammontare_sconto_RC_Auto__c  FROM Lead WHERE Id = :relatedToLeadId LIMIT 1];
 
        if (theLeads.size() >0){
            Lead theLead=theLeads[0];
              
            //List <String> InfoBanner = new List<String>();
            
            if (theLead.Landing_Page__c == 'Semplicemente casa' && theLead.Ammontare_sconto_NPC__c!=0){
            
                List<Document>  imgid = [select id, name, body from Document where name = 'sconto_NPC'  LIMIT 1]; // NOPMD  Fix CRUD violation
                
                //InfoBanner.add('<b>Ricontatta il tuo lead</b> e ricordati che il <b>prezzo è inclusivo</b> della convenzione <b>clienti web</b>!');
                InfoBanner2 = System.URL.getSalesforceBaseUrl().toExternalForm().replace('https','http')+'/servlet/servlet.ImageServer?id='+imgid[0].id+'&oid='+UserInfo.getOrganizationId();
                
            }else if(theLead.Landing_Page__c == 'Preventivo veloce' && theLead.Ammontare_sconto_RC_Auto__c!=0){
            
                List<Document>  imgid = [select id, name, body from Document where name = 'sconto_NPA'  LIMIT 1]; // NOPMD  Fix CRUD violation
         
               //InfoBanner.add('<b>Ricontatta il tuo lead</b> e ricordati che per replicare il <b>premio su AOL</b> devi applicare la <b>convenzione d\'attacco del 20% su RCA</b>');
                InfoBanner2 = System.URL.getSalesforceBaseUrl().toExternalForm().replace('https','http')+'/servlet/servlet.ImageServer?id='+imgid[0].id+'&oid='+UserInfo.getOrganizationId();
            
            }else if(theLead.Landing_Page__c == 'Preventivatore Turismo' ){
            
                List<Document>  imgid = [select id, name, body from Document where name = 'sconto_PT'  LIMIT 1]; // NOPMD  Fix CRUD violation
         
                //InfoBanner.add('<b>Ricontatta il tuo lead</b> e ricordati che per applicare lo <b>sconto del 10% su DAOL</b> devi inserire <b>il codice convenzione COLP03</b>');
                InfoBanner2 = System.URL.getSalesforceBaseUrl().toExternalForm().replace('https','http')+'/servlet/servlet.ImageServer?id='+imgid[0].id+'&oid='+UserInfo.getOrganizationId();
            }
            
            return InfoBanner2;
        }else{
            
            String ErrorInfo2 = '';
            ErrorInfo2 = 'Nessun Lead di riferimento trovato';
           
            return ErrorInfo2;
        }
    
    }
    
    
}
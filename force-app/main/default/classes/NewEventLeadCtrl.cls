global with sharing class NewEventLeadCtrl{
    private ApexPages.StandardController controller;
    public Event newEvent = new Event();
    public String errorMessage {get;set;} 
    public Boolean showError {get;set;}
    public String returnUrl {get;set;}
    public String relatedPhone {get;set;}
    public String relatedEmail {get;set;}
    public Lead relatedLead {get;set;}
    public String DefaultLookup{get;set;}
    public String DefaultLookupLead{get;set;}
    public String LookupIds {get;set;}
    public String LookupIds2 {get;set;}
    public Boolean showReminder {get;set;}
    public Life_event__c dateContainer {get;set;} //start date
    public Life_event__c dateContainer2 {get;set;} //end date
    public String inTime {get;set;} //start time
    public String outTime {get;set;} //end time
    public String taskTime {get;set;} //reminder time
    public Life_event__c dateContainerReminder {get;set;} //reminder date
    
    public NewEventLeadCtrl(ApexPages.StandardController controller) {
        this.controller = controller;
        relatedLead = new Lead();
        DefaultLookup = '';
        DefaultLookupLead='';
        LookupIds = '';
        LookupIds2 = '';
        
        newEvent = (Event)controller.getRecord();

        newEvent.WhoId = ApexPages.currentPage().getParameters().get('who_id');
        newEvent.OwnerId = UserInfo.getUserId();
        newEvent.RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        
        //BOVOLENTA_D US629
        newEvent.Subject = 'Appuntamento';
        dateContainer = new Life_event__c ();
        dateContainer.effective_date__c = System.Today().addDays(1);
        dateContainer2 = new Life_event__c ();
        dateContainer2.effective_date__c = System.Today().addDays(1); 
        dateContainerReminder = new Life_event__c ();
        dateContainerReminder.effective_date__c = System.Today().addDays(1);            
        Time  timeNow = DateTime.now().time();
        Integer hours = timeNow.hour();
        Integer minutes = timeNow.minute();
        if ((minutes>0) && (minutes<16) ) minutes = 15; 
        else if ((minutes>15) && (minutes<31)) minutes = 30;
        else if ((minutes>30) && (minutes<46)) minutes = 45;
        else if (minutes>45) 
        {
            minutes = 0;
            hours++;
        }
        System.debug('*********'+minutes );
        System.debug('*********'+hours);
        String strMinutes = ''+minutes;
        String strHours = ''+hours;
        if (strMinutes.length()<2) strMinutes = strMinutes+'0';
        if (strHours.length()<2) strHours = '0'+strHours;
        InTime = strhours+':'+strminutes;
        hours++;
        strHours = ''+hours;
        if (strHours.length()<2) strHours = '0'+strHours;
        OutTime = strhours+':'+strminutes;        
        
        taskTime =InTime;
            
        /*
        Integer roundUp = 60 - System.now().minute();
        DateTime startDate = System.now().addMinutes(roundUp);
        newEvent.StartDateTime = startDate;
        Datetime endDate = System.now().addMinutes(60+roundUp);
        newEvent.EndDateTime = endDate; */
        if(String.isNotBlank(newEvent.WhoId))
        {
            relatedLead = [SELECT Name, Phone, Email FROM Lead WHERE Id =: newEvent.WhoId];
            DefaultLookupLead = relatedLead.Name;
            relatedEmail = relatedLead.Email;
            relatedPhone = relatedLead.Phone;
        }
        DefaultLookup = [SELECT Id, Name FROM User WHERE Id =: newEvent.OwnerId].Name;
    }

    public void updateStatusLead(){
        Lead leadToUpdate = new Lead(Id=newEvent.WhoId, Status='Appointment');
        update leadToUpdate;
        }

    public PageReference save(){
        errorMessage = '';
        
        Boolean hasAccess = false;
        Id CurrentUserId = UserInfo.getuserid();
        List <UserRecordAccess> AccessList = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId =: CurrentUserId AND RecordId =: newEvent.WhoId];
        
        if(AccessList.size() != 0)
            hasAccess = AccessList.get(0).HasReadAccess;
            
        if(hasAccess) {
            
            if(newEvent.Subject ==null || newEvent.Subject ==''
               || (dateContainer.effective_date__c == null ||   InTime == '') || (dateContainer2.effective_date__c == null ||   OutTime == '')
               || (NewEvent.isReminderSet && (dateContainerReminder.effective_date__c == null  ||  taskTime == '')) )
            {  
                showError = true;
                errorMessage = 'Errore: compilare tutti i campi obbligatori:';
                if(newEvent.Subject ==null || newEvent.Subject =='')
                {
                    errorMessage = errorMessage+' - Oggetto dell\'evento';
                }
                /*   if(newEvent.StartDateTime == null)
                {
                errorMessage = errorMessage+' - Data/Ora d\'inizio dell\'evento';
                }
                if(newEvent.EndDateTime ==null)
                {
                errorMessage = errorMessage+' - Data/Ora di fine dell\'evento';
                }*/
                if(dateContainer.effective_date__c == null ||   InTime == '')
                {
                    errorMessage = errorMessage+' - Data/Ora d\'inizio dell\'evento';
                }
                if(dateContainer2.effective_date__c == null ||   OutTime == '')
                {
                    errorMessage = errorMessage+' - Data/Ora di fine dell\'evento';
                    
                }
                if(NewEvent.isReminderSet && (dateContainerReminder.effective_date__c == null  ||  taskTime == '') )
                {
                    errorMessage = errorMessage+' - Data/Ora del promemoria';
                }            
                return null;
            }
            else
            {   
            
                updateStatusLead(); 
                newEvent.StartDateTime = setReminderDateTime(dateContainer,InTime);
                newEvent.EndDateTime= setReminderDateTime(dateContainer2,OutTime);          
                newEvent.ReminderDateTime = setReminderDateTime(dateContainerReminder,taskTime); 
                Database.SaveResult SaveResult = Database.insert (newEvent,false);
                
                //if(SaveResult.isSuccess()){
                if(SaveResult.isSuccess() && String.isNotBlank(newEvent.WhoId)){    //CAPOBIANCO_A 18/01/2018
                    //updateStatusLead();
                    returnUrl = '/'+newEvent.WhoId;
                    PageReference retPage = new PageReference(returnURL);
                    retPage.setRedirect(true);
                    return retPage;
                }
                else
                {
                    String stringErrors = 'Si sono verificati i seguenti errori: ';
                    for(Database.Error err : SaveResult.getErrors())
                    {
                        stringErrors = stringErrors+'<br/>';
                        stringErrors = stringErrors+err.getMessage();   
                    }
                    System.debug('#@#@# DEBUG ERRORSTR '+stringErrors);
                    showError=true;
                    errorMessage = stringErrors; 
                    return null;                             
                }
            }
        }
        else {
            system.debug('*****USER DOES NOT HAVE ACCESS ' + hasAccess);
            String stringErrors = 'Il lead è stato assegnato o riassegnato ad un altro utente';
            showError=true;
            errorMessage = stringErrors;
            return null;
        }
    }

    public PageReference cancel(){
        returnUrl = '/'+newEvent.WhoId;
        PageReference retPage = new PageReference(returnURL);
        retPage.setRedirect(true);
        return retPage;
    }

    public PageReference changeShowReminder(){
        showReminder=false;
        System.debug('#@#@ sono dentro get show reminder');
        if(NewEvent.isReminderSet == true)
        {
            System.debug('#@#@ sono dentro l if di get show reminder');
            showReminder=true;
        }
        return null;
    }

    public List<SelectOption> getShowTimeAsList(){
        list<selectoption> options = new list<selectoption>();                     
        try {               
            DescribeFieldResult fieldResult = Schema.Event.ShowAs.getDescribe();
            list<schema.picklistentry> values = fieldResult.getPickListValues();               
            for (Schema.PicklistEntry a : values) {                  
                options.add(new SelectOption(a.getValue(), a.getLabel()));
                system.debug('#@#@ OPTIONS'+options);
            }           
        }catch (Exception e){ 
            errorMessage = e.getmessage();
            showError=true;
            return null;                  
        }
        return options; 
    }

    public List<SelectOption> getSubjectList(){
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult = Schema.Event.Subject.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       options.add(new SelectOption('', ''));     

       for( Schema.PicklistEntry f : ple)
       {
          if (f.getValue() == 'Email' || f.getValue() == 'Meeting' || f.getValue() == 'Call')
          {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
          }
       }       
       return options;
    }

    public List<SelectOption> getTypeList(){
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult = Schema.Event.Type.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       options.add(new SelectOption('', ''));     

       for( Schema.PicklistEntry f : ple)
       {
          if (f.getValue() == 'Other' || f.getValue() == 'Appointment at the phone' || f.getValue() == 'Incontro preliminare' || f.getValue() == 'Primo appuntamento' || f.getValue() == 'Secondo appuntamento' || f.getValue() == 'Terzo appuntamento' )
          {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
          }
       }       
       return options;
    }

    public  List<SelectOption> getInTimesAppointment() {
        List<SelectOption> options = calculateTimes();
        return options;
    }
    public  List<SelectOption> getOutTimesAppointment() {
        List<SelectOption> options = calculateTimes();
        return options;
    }
    
    public  List<SelectOption> getTimesTask() {
        List<SelectOption> options = calculateTimes();
        return options;
    }     

    public  List<SelectOption> calculateTimes() {
        
        List<SelectOption> options = new List<SelectOption>();
        Time myTime = Time.newInstance(0, 0, 0, 0);        
        String stringTime= ''+myTime;
        stringTime = stringTime.substring(0,5);
        options.add(new SelectOption(stringTime ,stringTime ));
        System.debug('*********'+stringTime );
        for (Integer i = 0; i < 95; i++) {
            myTime=myTime.addMinutes(15);
            stringTime= ''+myTime;
            stringTime = stringTime.substring(0,5);
            System.debug('*******'+stringTime );
            options.add(new SelectOption(stringTime ,stringTime));
        }

        System.debug('**************options'+options );
        return options;
    }
    
    public Datetime setReminderDateTime (Life_event__c LE, String theTime) {
        SYSTEM.DEBUG('***********LE '+LE);  
        SYSTEM.DEBUG('***********theTime '+theTime);    
        Datetime reminderDT = DateTime.newInstance(LE.Effective_date__c.year(), LE.Effective_date__c.month(), LE.Effective_date__c.day(),
                                                      Integer.valueOf(theTime.split(':').get(0)), Integer.valueOf(theTime.split(':').get(1)), 0);
        SYSTEM.DEBUG('+++++++++++++++++reminderDT '+reminderDT);                                            
        return reminderDT;
    } 
    
    public void updateEventEndTime(){
        Integer startHour = Integer.valueOf(inTime.split(':').get(0));
        Integer startMinute = Integer.valueOf(inTime.split(':').get(1));
        Integer endHour = startHour+1;
        String endHourStr = endHour+'';
        String startMinuteStr = startMinute+'';
        if (endHourStr.length()<2) endHourStr = '0'+endHourStr;
        if (startMinuteStr.length()<2) startMinuteStr = startMinuteStr+'0';
        OutTime = endHourStr+':'+startMinuteStr;
    }     

    @RemoteAction
    global static List<User> queryContacts(String keyword) {
        List<User> UserList = new List<User>();
        if (keyword != null && keyword.trim() != '') {
            keyword = '%' + keyword + '%';
            UserList = [Select Id, Name from User where Name like :keyword limit 5];
        }
        return UserList;
    }

    @RemoteAction
    global static List<Lead> queryLeads(String keyword) {
        List<Lead> LeadList = new List<Lead>();
        if (keyword != null && keyword.trim() != '') {
            keyword = '%' + keyword + '%';
            LeadList = [Select Id, Name from Lead where Name like :keyword limit 5];
        }
        return LeadList;
    }

    public PageReference theMethod()
    {
       //leadToUpdate.Account_referente__c = LookupIds; 
        
        system.debug('****theMethod: '+LookupIds);
        return null;
    }

    public PageReference theMethod2()
    {
       //leadToUpdate.Account_referente__c = LookupIds; 
        
        system.debug('****theMethod: '+LookupIds2);
        return null;
    }

}
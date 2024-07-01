global with sharing class NewActivityLeadCtrl{
    private ApexPages.StandardController controller;
    public Task newTask = new Task();
    public String errorMessage {get;set;} 
    public Boolean showError {get;set;}
    public String returnUrl {get;set;}
    public String DefaultLookup{get;set;}
    public String DefaultLookupLead{get;set;}
    public String LookupIds {get;set;}
    public String LookupIds2 {get;set;}
    public Boolean showReminder {get;set;}
    public Life_event__c dateContainer {get;set;} //reminder date
    public String taskTime {get;set;} //reminder time
    
    public NewActivityLeadCtrl(ApexPages.StandardController controller) {
        this.controller = controller;
        DefaultLookup = '';
        LookupIds = '';
        LookupIds2 = '';
        
        newTask = (Task)controller.getRecord();

        newTask.WhoId = ApexPages.currentPage().getParameters().get('who_id');
        newTask.OwnerId = UserInfo.getUserId();
        newTask.RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        //BOVOLENTA_D US629
        newTask.Priority = 'High';
        newTask.Subject = 'Call';
        newTask.ActivityDate = System.Today().addDays(1);
        dateContainer = new Life_event__c ();
        dateContainer.effective_date__c = System.Today().addDays(1);
        
        //newTask.Contact_Date__c is already defaulted to today()
        

        DefaultLookup = [SELECT Id, Name FROM User WHERE Id =: newTask.OwnerId].Name;
        if(String.isNotBlank(NewTask.WhoId))
        {
            DefaultLookupLead = [SELECT Name FROM Lead WHERE Id =: newTask.WhoId].Name;
        }
        
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
        String InTime = strhours+':'+strminutes;
        taskTime =InTime;
        //taskAppointmentTime =InTime;
        hours++;
        strHours = ''+hours;
        if (strHours.length()<2) strHours = '0'+strHours;
        String OutTime = strhours+':'+strminutes;        
        
    }

    public void updateStatusLead(){
        Lead leadToUpdate = new Lead(Id=newTask.WhoId, Status='Call again');
        update leadToUpdate;
        }

    public PageReference save(){
        //SAVE THE REMINDER DATE
        
        errorMessage = '';

        if( newTask.Subject =='' || newTask.Subject ==null
            || newTask.WhoId == null
            || newTask.Status == null
            || newTask.Priority == null 
            || newTask.ActivityDate == null 
            || (newTask.isReminderSet && (dateContainer.effective_date__c == null  ||  taskTime == '') ))
        {  
            showError = true;
            errorMessage = 'Errore: compilare tutti i campi obbligatori:';
            if(newTask.WhoId ==null)
            {
                errorMessage = errorMessage+' - Lead di riferimento';
            }
            if(newTask.Subject ==null || newTask.Subject =='')
            {
                errorMessage = errorMessage+' - Oggetto';
            }
            if(newTask.Status ==null)
            {
                errorMessage = errorMessage+' - Stato';
            }
            if(newTask.Priority ==null)
            {
                errorMessage = errorMessage+' - Priorità';
            }
            if(newTask.ActivityDate ==null)
            {
                errorMessage = errorMessage+' - Data';
            }
            if(dateContainer.effective_date__c == null ||   taskTime == '')
            {
                errorMessage = errorMessage+' - Data e ora del promoemoria';
            }
            return null;
        }
        else
        {
            Id CurrentUserId = UserInfo.getuserid();
            List <UserRecordAccess> AccessList = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId =: CurrentUserId AND RecordId =: newTask.WhoId];
            Boolean hasAccess = AccessList.get(0).HasReadAccess;
            
            if(hasAccess) {
                
                updateStatusLead();
                newTask.ReminderDateTime = setReminderDateTime(dateContainer,taskTime);
                
                Database.SaveResult SaveResult = Database.insert (newTask,false);
                
                if(SaveResult.isSuccess()){
                    //updateStatusLead();
                    returnUrl = '/'+newTask.WhoId;
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
            else {
                system.debug('*****USER DOES NOT HAVE ACCESS ' + hasAccess);
                String stringErrors = 'Il lead è stato assegnato o riassegnato ad un altro utente';
                showError=true;
                errorMessage = stringErrors;
                return null;
            }
        }
    }

    public PageReference cancel(){
        returnUrl = '/'+newTask.WhoId;
        PageReference retPage = new PageReference(returnURL);
        retPage.setRedirect(true);
        return retPage;
    }

    public List<SelectOption> getSubjectList(){
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult = Schema.Task.Subject.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       options.add(new SelectOption('', ''));     

       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getValue(), f.getLabel()));
       }       
       return options;
    }

    public List<SelectOption> getStatusList(){
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult = Schema.Task.Status.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 

       for( Schema.PicklistEntry f : ple)
       {
            if(f.getValue() == 'Open' || f.getValue() == 'Completed')
            {
                options.add(new SelectOption(f.getValue(), f.getLabel()));
            }   
       }       
       return options;
    }

    public List<SelectOption> getPriorityList(){
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult = Schema.Task.Priority.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       options.add(new SelectOption('', ''));     

       for( Schema.PicklistEntry f : ple)
       {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
       }       
       return options;
    }

    public PageReference changeShowReminder(){
        showReminder=false;
        System.debug('#@#@ sono dentro get show reminder');
        if(NewTask.isReminderSet == true)
        {
            System.debug('#@#@ sono dentro l if di get show reminder');
            showReminder=true;
        }
        return null;
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
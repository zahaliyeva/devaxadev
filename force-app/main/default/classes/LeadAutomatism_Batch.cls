global class LeadAutomatism_Batch implements Database.Batchable<sObject>,Database.Stateful,Schedulable{

    global Database.QueryLocator start(Database.BatchableContext bc) {

        
        return Database.getQueryLocator(
            'Select id, status, ownerId,'+
            '(select id, ActivityDate, WhoId from Tasks order by activityDate desc limit 1),'+ 
            '(select id, ActivityDate, WhoId from Events order by activityDate desc limit 1)'+
            'from Lead '+
            'where (status = \'Call Again\' or status = \'Appointment\') and isConverted = false and Recordtype.DeveloperName in (\'Lead_AXA_Assicurazioni\', \'eCommerce\', \'Outsource\')'+
            'AND createdDate >= 2021-10-01T00:00:00.000+02:00'
        );

    }

    private boolean scheduled = false;

    global void execute(Database.BatchableContext bc, List<Lead> scope){

        List<Lead> leadToUpdate = new List<Lead>();
        Integer days = -1*(Integer.valueOf(AAI_Code_Variables__c.getAll().get('LeadAutomatism_Batch_DaysBefore').Value__c));
        Date DateToCheck = Date.today().addDays(days);

        List<Group> queues  = [Select id, developername, name from group where developername like 'Coda_Lead_Non_Lavorati_%'];
        Map<String, Id> queueIdsByDevName = new Map<String, Id>();
        for(Group g : queues){
            system.debug(g);
            queueIdsByDevName.put(g.DeveloperName, g.Id);

        }

        for(Lead l : scope){
            system.debug(l.Tasks);
            system.debug(l.Events);
            switch on l.Status {
                when 'Call again' {
                    if(l.Tasks != null && !l.Tasks.isEmpty()){
                        Task t = l.Tasks.get(0);
                        if(t.ActivityDate <= DateToCheck){
                            
                            l.TECH_Send_Email_Notification__c = false;
                            l.Status = 'Non Lavorato';
                            l.OwnerId = queueIdsByDevName.containsKey('Coda_Lead_Non_Lavorati_Da_ricontattare') ?
                                queueIdsByDevName.get('Coda_Lead_Non_Lavorati_Da_ricontattare') : l.OwnerId;
                            
                            System.debug(l);
                            leadToUpdate.add(
                                l
                            );
                        }
                    }
                        
                }
                when 'Appointment'{
                    if(l.Events != null && !l.Events.isEmpty()){
                        Event e = l.Events.get(0);
                        if(e.ActivityDate <= DateToCheck){

                            l.TECH_Send_Email_Notification__c = false;
                            l.Status = 'Non Lavorato';
                            l.OwnerId = queueIdsByDevName.containsKey('Coda_Lead_Non_Lavorati_Appuntamento') ?
                                queueIdsByDevName.get('Coda_Lead_Non_Lavorati_Appuntamento') : l.OwnerId;
                            

                            System.debug(l);

                            leadToUpdate.add(
                                l
                            );
                        }
                    }
                }
            }
        }

        try{
            update leadToUpdate;
        }
        catch(Exception e){
            try{
                ApplicationLogHelper.ERROR('LeadAutomatism_Batch', e.getMessage(), e.getStackTraceString());
            }
           catch(Exception ex){
                System.debug(System.LoggingLevel.ERROR,'Exception: ' + e.getmessage() + '\tStackTrace: '+e.getStackTraceString());
           }
        }
    }

    global void execute(SchedulableContext SC){

        System.abortJob(SC.getTriggerId());        
        
        LeadAutomatism_Batch b = new LeadAutomatism_Batch();
        b.setScheduled(true);
        Database.ExecuteBatch(b);

    }

    public void setScheduled(boolean scheduled){
        this.scheduled = scheduled;
    }

    global void finish(Database.BatchableContext BC){

        if(this.scheduled){
            
            schedule(false);
        }

    }

    public static String schedule(boolean isFirst){
        Datetime CurrentTime = Datetime.now();
        if(!isFirst){
            CurrentTime = CurrentTime.addDays(1);
        }
        String sch = '0 0 ' + AAI_Code_Variables__c.getAll().get('LeadAutomatism_Batch_Hour').Value__c;
        sch = sch+' '+CurrentTime.day();
        sch = sch+ ' ' +CurrentTime.month();
        sch = sch+' ? ';//any day of the week
        sch = sch+' '+CurrentTime.Year();
        return system.Schedule('LeadAutomatism'+String.ValueOf(System.currentTimeMillis()),sch,new LeadAutomatism_Batch());
        
    }
    
}
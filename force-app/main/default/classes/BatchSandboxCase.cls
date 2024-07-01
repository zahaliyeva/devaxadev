global class BatchSandboxCase implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
      System.debug('BatchSandboxCase.start');
      if(![SELECT IsSandbox FROM Organization].isSandbox && !Test.isRunningTest()){
          throw new DmlException('Clean Object only for Sandbox Environment');
      }
        return Database.getQueryLocator([SELECT Id, Visualizza_sinistro__c  ,RecordTypeId
                                         FROM Case 
                                         WHERE
                                         (SuppliedEmail!='test@test.it' and SuppliedEmail!='axa.test@test.axa')
                                         or(
                                             RecordType.DeveloperName = 'Caring_Angel' 
                                             OR RecordType.DeveloperName = 'Sinistri_Danni_Banca'
                                         ) 
                                         ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Case> cases){
      list<Recordtype> rTList=[select id 
                               from recordtype
                               where 
                               SobjectType ='Case'and(
                               DeveloperName = 'Caring_Angel' or
                               DeveloperName = 'Sinistri_Danni_Banca' 
                               )
                              ];
      System.debug('BatchSandboxCase.execute');
        for(Case c: cases) {
            if (c.Visualizza_sinistro__c != null && c.Visualizza_sinistro__c.contains('sol.axa')){
                for(Recordtype rt: rTList){
                    if(rt.id== c.RecordTypeId ){
                    	c.Visualizza_sinistro__c = c.Visualizza_sinistro__c.replace('sol.axa', 'precol.axa');
                        break;
                    }
                }
            }
            setInvalidEmail( c);
            System.debug('*** URL: '+c.Visualizza_sinistro__c);
        }
        Database.update( cases, false);
       //update cases;
    }
    
    private void setInvalidEmail(Case c){
        String newmail= 'axa.test@test.axa';
        c.Account_Email__c=newmail;
        c.Agency_Email__c=newmail;
        c.Case_Contact_Email__c=newmail;
        c.Other_Email__c=newmail;
        c.Partner_Email__c=newmail;
        c.SuppliedEmail=newmail;
    } 
    
    global void finish(Database.BatchableContext bc){
      System.debug('BatchSandboxCase.finish');
    }
}
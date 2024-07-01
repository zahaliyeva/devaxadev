public without sharing class SendCaseAutomaticQueueController {
    
    
    //d.pirelli case automatic owner 30/11/2019
    
    @AuraEnabled
    public static Id getOwnerIdForSendAutomatic(String caseId, String MotivoTrasferimento){
        Id sendToOwnerId;
        String allId = '*';
        
        Case cs = [SELECT Id, LOB__c, Category__c, SubCategory__c, SubCategoryDetail__c, RecordType.DeveloperName, Distribution_Network__c FROM Case WHERE Id=: caseId LIMIT 1];
        Map<String,String> Mapping = new Map<String,String>();
        
        // bug fix ID 240 per record type CA motor *-+ 25-02-2022 
        if(cs.Distribution_Network__c == 'RCI' 
           && 'Claims Trasformation'.equals(MotivoTrasferimento) 
           && ('Caring_Angel_Property'.equalsIgnoreCase(cs.RecordType.DeveloperName) 
               || 'Caring_Angel'.equalsIgnoreCase(cs.RecordType.DeveloperName)))
        {
            sendToOwnerId = getOwnerQueueIdFromName('HD2 BIZ CLAIMS TRANSFORMATION');
            
        }else if (cs.Distribution_Network__c == 'RCI' 
                  && !'Claims Trasformation'.equals(MotivoTrasferimento) 
                  && 'Caring_Angel'.equalsIgnoreCase(cs.RecordType.DeveloperName))
        {
            sendToOwnerId = getOwnerQueueIdFromName('HD2 BIZ CA RCI');
            
        }else{
            List<Mapping_Automatic_Owner_NMA__c> MappingComplete = [SELECT Coda_di_Destinazione__c,LOB__c,Category__c, Sub_Category__c, SubCategoryDetail__c, motivoTrasferimento__c // NOPMD  Fix CRUD violation
                                                                    FROM Mapping_Automatic_Owner_NMA__c 
                                                                    WHERE RecordType__c = :cs.RecordType.DeveloperName AND Lob__c =: cs.LOB__c 
                                                                    AND Category__c =: cs.Category__c ];
            
            for(Mapping_Automatic_Owner_NMA__c temp : MappingComplete){
                Mapping.put(temp.LOB__c.toLowerCase()+ 
                            temp.Category__c.toLowerCase() + 
                            temp.Sub_Category__c.toLowerCase() + 
                            temp.SubCategoryDetail__c.toLowerCase() + 
                            temp.MotivoTrasferimento__c.toLowerCase(),
                            temp.Coda_di_Destinazione__c);
            }
            //Chiave completa
            String KeyWithSubDetail = cs.SubCategoryDetail__c != null ? cs.LOB__c.toLowerCase()+cs.Category__c.toLowerCase()+cs.SubCategory__c.toLowerCase()+cs.SubCategoryDetail__c.toLowerCase(): '';
            
            
            
            
            //Chiave senza dettaglio
            String keyWithSubCat = cs.SubCategory__c != null ? cs.LOB__c.toLowerCase()+cs.Category__c.toLowerCase()+cs.SubCategory__c.toLowerCase()+allId:'';
            //Chiave senza SottoCategoria
            String keyWithCat = cs.Category__c != null? cs.LOB__c.toLowerCase()+cs.Category__c.toLowerCase()+allId+allId:'';
            
            String FinalKey = '';
            Boolean motivoInviato = MotivoTrasferimento != '';

            system.debug('getOwnerIdForSendAutomatic - KeyWithSubDetail: '+KeyWithSubDetail);
            system.debug('getOwnerIdForSendAutomatic - keyWithSubCat: '+keyWithSubCat);
            system.debug('getOwnerIdForSendAutomatic - keyWithCat: '+keyWithCat);
            system.debug('getOwnerIdForSendAutomatic - Mapping: '+Mapping);
            
            //Per ogni chiave controllo prima che sia presente a db la versione con il motivo trasferimento, se non c'è, controllo se è presente la versione senza motivo trasferimento
            //Da considerare la possibilità di usare un Array di chiavi, invece di 3 chiavi differenti, e fare quindi il controllo dentro un ciclo FOR
            
            if(KeyWithSubDetail != '' && motivoInviato && Mapping.containsKey(KeyWithSubDetail+MotivoTrasferimento.toLowerCase())){
                
                sendToOwnerId = getOwnerQueueIdFromName(Mapping.get(KeyWithSubDetail+MotivoTrasferimento.toLowerCase()));
                
            }
            else if(KeyWithSubDetail != '' && Mapping.containsKey(KeyWithSubDetail+allId)){
                
                sendToOwnerId = getOwnerQueueIdFromName(Mapping.get(KeyWithSubDetail+allId));
                
            }
            else if(keyWithSubCat != '' && motivoInviato && Mapping.containsKey(keyWithSubCat+MotivoTrasferimento.toLowerCase())){
                
                sendToOwnerId = getOwnerQueueIdFromName(Mapping.get(keyWithSubCat+MotivoTrasferimento.toLowerCase()));
                
            }
            else if(keyWithSubCat != '' && Mapping.containsKey(keyWithSubCat+allId)){
                
                sendToOwnerId = getOwnerQueueIdFromName(Mapping.get(keyWithSubCat+allId));
                
            }
            else if(keyWithCat!=''&& motivoInviato && Mapping.containsKey(keyWithCat+MotivoTrasferimento.toLowerCase())){
                
                sendToOwnerId = getOwnerQueueIdFromName(Mapping.get(keyWithCat+MotivoTrasferimento.toLowerCase()));
                
            }
            else if(keyWithCat!=''&& Mapping.containsKey(keyWithCat+allId)){

                system.debug('getOwnerIdForSendAutomatic - getOwnerQueueIdFromName: '+getOwnerQueueIdFromName(Mapping.get(keyWithCat+allId)));
                
                sendToOwnerId = getOwnerQueueIdFromName(Mapping.get(keyWithCat+allId));
                
            }
        }
        system.debug('getOwnerIdForSendAutomatic - sendToOwnerId: '+sendToOwnerId);
        return sendToOwnerId;
    } 
    @AuraEnabled
    public static Id getOwnerIdForSendAutomaticHD1IT(String caseId)  {
        Id sendToOwnerId;
        
        Case cs = [SELECT Id, LOB__c, Category__c, SubCategory__c, SubCategoryDetail__c, RecordType.DeveloperName FROM Case WHERE Id=: caseId LIMIT 1];
        
        /*list<Mapping_Automatic_Owner_NMA__c> mapping = new list<Mapping_Automatic_Owner_NMA__c>();
list<Mapping_Automatic_Owner_NMA__c> mapping2 = new list<Mapping_Automatic_Owner_NMA__c>();
list<Mapping_Automatic_Owner_NMA__c> mapping3 = new list<Mapping_Automatic_Owner_NMA__c>();
list<Mapping_Automatic_Owner_NMA__c> mapping4 = new list<Mapping_Automatic_Owner_NMA__c>();*/
        Map<String,String> Mapping = new Map<String,String>();
        List<Mapping_Automatic_Owner_NMA__c> MappingComplete = [SELECT Coda_di_Destinazione__c,LOB__c,Category__c, Sub_Category__c, SubCategoryDetail__c FROM Mapping_Automatic_Owner_NMA__c where RecordType__c = :cs.RecordType.DeveloperName and Lob__c =: cs.LOB__c ]; // NOPMD  Fix CRUD violation
        
        for(Mapping_Automatic_Owner_NMA__c temp : MappingComplete){
            
            Mapping.put((temp.LOB__c == null ? '':temp.LOB__c.toLowerCase())+
                        (temp.Category__c == null? '':temp.Category__c.toLowerCase())+
                        (temp.Sub_Category__c == null? '':temp.Sub_Category__c.toLowerCase())+
                        (temp.SubCategoryDetail__c == null ? '':temp.SubCategoryDetail__c.toLowerCase()),
                        temp.Coda_di_Destinazione__c);
        }
        
        String KeyWithSubDetail = cs.SubCategoryDetail__c != null? cs.LOB__c.toLowerCase()+cs.Category__c.toLowerCase()+cs.SubCategory__c.toLowerCase()+cs.SubCategoryDetail__c.toLowerCase(): '';
        String keyWithSubCat = cs.SubCategory__c != null ? cs.LOB__c.toLowerCase()+cs.Category__c.toLowerCase()+cs.SubCategory__c.toLowerCase():'';
        String keyWithCat = cs.Category__c != null? cs.LOB__c.toLowerCase()+cs.Category__c.toLowerCase():'';
        String keyWithLob = cs.LOB__c.toLowerCase();
        
        
        
        if(KeyWithSubDetail != '' && Mapping.containsKey(KeyWithSubDetail)){
            sendToOwnerId = getOwnerQueueIdFromName(Mapping.get(KeyWithSubDetail));
        }
        else if(keyWithSubCat != '' && Mapping.containsKey(keyWithSubCat)){
            sendToOwnerId = getOwnerQueueIdFromName(Mapping.get(keyWithSubCat));
        }
        else if(keyWithCat!=''&& Mapping.containsKey(keyWithCat)){
            sendToOwnerId = getOwnerQueueIdFromName(Mapping.get(keyWithCat));
        }
        else if(Mapping.containsKey(keyWithLob)){
            sendToOwnerId = getOwnerQueueIdFromName(Mapping.get(keyWithLob));
        }
        
        /*if (mapping.size()>0 && mapping[0] !=null && String.isNotBlank(mapping[0].Coda_di_Destinazione__c)){
sendToOwnerId = getOwnerQueueIdFromName(mapping[0].Coda_di_Destinazione__c);}
else if (mapping2.size()>0 && mapping2[0] !=null && String.isNotBlank(mapping2[0].Coda_di_Destinazione__c)){
sendToOwnerId = getOwnerQueueIdFromName(mapping2[0].Coda_di_Destinazione__c);}
else{
sendToOwnerId = getOwnerQueueIdFromName(mapping3[0].Coda_di_Destinazione__c);}*/
        
        return sendToOwnerId;
    }
    @AuraEnabled
    public static Id getOwnerIdForSendAutomaticCaring(String MotivoTrasferimento){
        List<Mapping_Automatic_Owner_NMA__c> MappingComplete = [SELECT Coda_di_Destinazione__c,MotivoTrasferimento__c FROM Mapping_Automatic_Owner_NMA__c where MotivoTrasferimento__c!=null ]; // NOPMD  Fix CRUD violation
        Map<String,String> Mapping = new Map<String,String>();
        for(Mapping_Automatic_Owner_NMA__c temp : MappingComplete){
            
            Mapping.put(temp.MotivoTrasferimento__c, temp.Coda_di_Destinazione__c);
        }
        if(Mapping.containsKey(MotivoTrasferimento))
            return getOwnerQueueIdFromName(Mapping.get(MotivoTrasferimento));
        else
            return null;
    }
    @AuraEnabled
    public static Id getOwnerIdForSendAutomaticHD1Contabilita(String caseId)  {
        /*Id sendToOwnerId;

Case cs = [SELECT Id, LOB__c, Category__c, SubCategory__c FROM Case WHERE Id=: caseId LIMIT 1];

list<Mapping_Automatic_Owner_NMA__c> mapping = new list<Mapping_Automatic_Owner_NMA__c>();
list<Mapping_Automatic_Owner_NMA__c> mapping2 = new list<Mapping_Automatic_Owner_NMA__c>();
list<Mapping_Automatic_Owner_NMA__c> mapping3 = new list<Mapping_Automatic_Owner_NMA__c>();

mapping = [SELECT Coda_di_Destinazione__c,LOB__c,Category__c, Sub_Category__c FROM Mapping_Automatic_Owner_NMA__c WHERE LOB__c =: cs.LOB__C and Category__c =: cs.Category__c  and Sub_Category__c =: cs.SubCategory__c order by CreatedDate asc ] ;
mapping2 = [SELECT Coda_di_Destinazione__c,LOB__c,Category__c FROM Mapping_Automatic_Owner_NMA__c WHERE LOB__c =: cs.LOB__C and Category__c =: cs.Category__c and Sub_Category__c = null  order by CreatedDate asc   ] ;
mapping3 = [SELECT Coda_di_Destinazione__c,LOB__c FROM Mapping_Automatic_Owner_NMA__c WHERE LOB__c =: cs.LOB__C and Category__c = null and Sub_Category__c = null   order by CreatedDate asc    ] ;
if (mapping.size()>0 && mapping[0] !=null && String.isNotBlank(mapping[0].Coda_di_Destinazione__c)){
sendToOwnerId = getOwnerQueueIdFromName(mapping[0].Coda_di_Destinazione__c);}
else if (mapping2.size()>0 && mapping2[0] !=null && String.isNotBlank(mapping2[0].Coda_di_Destinazione__c)){
sendToOwnerId = getOwnerQueueIdFromName(mapping2[0].Coda_di_Destinazione__c);}
else{
sendToOwnerId = getOwnerQueueIdFromName(mapping3[0].Coda_di_Destinazione__c);}
return sendToOwnerId;*/
        return getOwnerIdForSendAutomaticHD1IT(caseId);
        
    }
    @AuraEnabled
    public static Id getOwnerIdForSendManualHD1IT(String caseId){
        Id sendToSameOwner;
        
        Case c = [SELECT Id , OwnerId,Current_Owner_Queue__c FROM Case WHERE Id =: caseId LIMIT 1];
        
        sendToSameOwner =c.OwnerId;
        
        return sendToSameOwner;
        
        
    }
    
    @AuraEnabled
    public static Id getOwnerQueueIdFromName(String name)  {
        Id queueId;
        list<Group> codaDestinazione = [SELECT Id // NOPMD  Fix CRUD violation
                                        FROM Group
                                        WHERE Type ='Queue' and Name=: name  LIMIT 1];
        
        if(!codaDestinazione.isEmpty()){
            
            return codaDestinazione[0].Id;
        }
        else{
            Group queueDefault = [SELECT Id FROM Group WHERE Type ='Queue' and Name = 'CodaBuffer'  LIMIT 1]; // NOPMD  Fix CRUD violation
            
            return queueDefault.Id;
        }        
        
        
    }
    
    @AuraEnabled
    public static Id getOwnerQueueIdFromDevName(String devName)  {
        Id queueId;
        Group g = [SELECT Id // NOPMD  Fix CRUD violation
                   FROM Group
                   WHERE Type ='Queue' and DeveloperName=: devName  LIMIT 1];
        
        
        return g.Id;
    }
    
    @AuraEnabled
    public static Boolean showModalOnRitornoHD1(String caseId){
        
        Case c = [select id, Current_Owner_Queue__c from Case where id =: caseId];
        return c.Current_Owner_Queue__c != null ? c.Current_Owner_Queue__c.startsWith('HD2_IT') || c.Current_Owner_Queue__c.startsWith('HD3_IT') : false;
        
    }
    
    public class hd3Wrapper{
        @AuraEnabled public String SelectedValue{get;set;}
        @AuraEnabled public String Dettaglio{get;set;}
        @AuraEnabled public DateTime now{get;set;}
        @AuraEnabled public List<SelectOptions> options{get;set;}
        @AuraEnabled public String SilvaId{get;set;}
        @AuraEnabled public String CurrentOwnerQueue{get;set;}
        @AuraEnabled public String ApplicationName{get;set;}
    }
    
    @AuraEnabled
    public static hd3Wrapper getOptionsValuesInvioAHD3(String caseId){
        hd3Wrapper resp = new hd3Wrapper();
        Case c = [Select HD3_IT__c, Dettaglio_supporto_HD3__c,Current_Owner_Queue__c, Recordtype.DeveloperName, Silva_Id__c from case where id =: caseId];
        List<String> recList = new List<String>();
        recList.add(c.RecordType.DeveloperName);
        recList.add('*');
        List<MapInvioHD3__mdt>  mapping = [SELECT values__c, conditions__c FROM MapInvioHD3__mdt where RecordType__c in :recList ]; // NOPMD  Fix CRUD violation
        
        resp.SelectedValue = c.HD3_IT__c;
        resp.Dettaglio = c.Dettaglio_supporto_HD3__c;
        resp.now = system.now();
        resp.SilvaId = c.Silva_Id__c;
        resp.CurrentOwnerQueue = c.Current_Owner_Queue__c;
        
        List<SelectOptions> options = new List<SelectOptions>();
        for(MapInvioHD3__mdt m : mapping){
            boolean add = false;
            if(String.isNotBlank(m.Conditions__c) && !'*'.equals(m.Conditions__c))
                for(String s : m.Conditions__c.split(';')){
                    if(String.isNotBlank(c.Current_Owner_Queue__c) && c.Current_Owner_Queue__c.containsIgnoreCase(s)){
                        add = true;
                    }
                }
            else{
                add = true;
            }
            if(add)
                for(String s : m.values__c.split(';')){
                    options.add(new SelectOptions(s,s));
                }
        }
        /*Schema.DescribeFieldResult fieldResult = Case.HD3_IT__c.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

for( Schema.PicklistEntry f : ple)
{
options.add(new SelectOptions(f.getLabel(), f.getValue()));
}*/
        //options = getOptionsValues(caseId, 'Terzo_Livello');
        
        resp.options = options;
        return resp;
    }
    
    @AuraEnabled
    public static hd3Wrapper getOptionsValuesForTicketSilva(String caseId){
        hd3Wrapper resp = new hd3Wrapper();
        Case c = [Select Tipologia_Ticket_Silva__c, Application_EAGP__c, Application_EAGP__r.Name, Current_Owner_Queue__c, Recordtype.DeveloperName from case where id =: caseId];
        List<String> recList = new List<String>();
        recList.add(c.RecordType.DeveloperName);
        recList.add('*');
        List<Application_EAGP__c>  mapping = [SELECT Id, Name FROM Application_EAGP__c where Salesforce_Assignment_Group__c INCLUDES (:c.Current_Owner_Queue__c) ]; // NOPMD  Fix CRUD violation
        
        resp.ApplicationName = c.Application_EAGP__r.Name;
        resp.SelectedValue = c.Application_EAGP__c;
        resp.Dettaglio = c.Tipologia_Ticket_Silva__c;
        
        List<SelectOptions> options = new List<SelectOptions>();
        for(Application_EAGP__c m : mapping){
            options.add(new SelectOptions(m.Name, m.Id));
        }       
        resp.options = options;
        return resp;
    }
    
    
    @AuraEnabled
    public static Boolean skipMappingAutomaticOwnerNMAConfiguration(String caseId){
        Case c = [SELECT RecordType.DeveloperName from Case where Id = :caseId ]; // NOPMD  Fix CRUD violation
        return 'Caring_Angel'.equalsIgnoreCase(c.RecordType.DeveloperName);
    }
    
    @AuraEnabled
    public static List<SelectOptions> getOptionsValuesInvioASecondoLivello(String caseId)  
    {
        
        List<SelectOptions> options = new  List<SelectOptions>() ; 
        
        
        if(String.isNotBlank(caseId))
        {
            Case cs = [SELECT Current_Owner_Queue__c   FROM Case WHERE id =:caseId LIMIT 1]; 
            if(cs.Current_Owner_Queue__c!= null){              
                
                //set options for layout HD1 BIZ e Buon Lavoro
                //
                /*
if(((cs.Current_Owner_Queue__c).contains('HD1_Biz_') &&(!(cs.Current_Owner_Queue__c.equals('HD1_Biz_Vita')))) || (cs.Current_Owner_Queue__c).contains('Buon_Lavoro')){
options.add(new SelectOptions('Auto','HD2_Biz_Auto') );  
options.add(new SelectOptions('Famiglia','HD2_Biz_Famiglia') );  
options.add(new SelectOptions('Salute','HD2_Biz_Salute') );  
}

if((cs.Current_Owner_Queue__c).contains('HD1_Biz_Vita')){
options.add(new SelectOptions('Vita','Vita') );
}


//set options for button HD1 IT
if((cs.Current_Owner_Queue__c).contains('HD1_IT') ){
options.add(new SelectOptions('Selezione Automatica','Selezione Automatica') );  
options.add(new SelectOptions('Selezione Manuale','Selezione Manuale') );     
}


//set options HD1 Contabilità
if((cs.Current_Owner_Queue__c).contains('HD1_Contabilita') )
options.add(new SelectOptions('Vita','Vita') );

//set options HD1 Caring Salute
if((cs.Current_Owner_Queue__c).contains('Caring_Salute_HD1') )
{
options.add(new SelectOptions('Caring Salute','Caring_Salute_HD2'));
options.add(new SelectOptions('HD2 IT DIGITAL','HD2_IT_DIGITAL'));                 
}*/
                MapInvioSecondoLivello__mdt defaultChoice;
                List<MapInvioSecondoLivello__mdt> mapping = [SELECT Conditions__c, Negative_Conditions__c, Keys__c, Values__c FROM MapInvioSecondoLivello__mdt ]; // NOPMD  Fix CRUD violation
                boolean found = false;
                for(MapInvioSecondoLivello__mdt temp : mapping){
                    if(temp.Conditions__c == '*')
                        defaultChoice = temp;
                    
                    else{
                        boolean positive = false;
                        for(String condition : temp.Conditions__c.split(';')){
                            if(cs.Current_Owner_Queue__c.contains(condition)){
                                positive = true;
                            }
                        }
                        boolean negative = true;
                        if(temp.Negative_Conditions__c != null)
                            for(String condition : temp.Negative_Conditions__c.split(';')){
                                if(cs.Current_Owner_Queue__c.contains(condition)){
                                    negative = false;
                                }
                            }
                        if(positive && negative){
                            found = true;
                            List<String> keys = temp.keys__c.split(';');
                            List<String> values = temp.values__c.split(';');
                            for(integer i = 0; i<keys.size(); i++){
                                options.add(new SelectOptions(values[i],keys[i]));
                            }
                        }
                    }
                }
                if(!found){
                    List<String> keys = defaultChoice.keys__c.split(';');
                    List<String> values = defaultChoice.values__c.split(';');
                    for(integer i = 0; i<keys.size(); i++){
                        options.add(new SelectOptions(values[i],keys[i]));
                    }
                }
                
            }
            
        }
        return options;        
    }
    
    @AuraEnabled
    public static  List<SelectOptions>  getOptionsValuesInviaAdAltraArea(String caseId)  
    {
        
        
        List<SelectOptions> options = new  List<SelectOptions>() ; 
        SelectOptions it = new SelectOptions('IT','HD1_IT');
        SelectOptions vita = new SelectOptions('Vita','HD1_Biz_Vita');
        SelectOptions moduloDiCalcolo = new SelectOptions('Modulo di calcolo','HD2_Modulo_di_Calcolo');
        SelectOptions contabilitaVita = new SelectOptions('Contabilità Vita','HD1_ContabilitaVita');
        SelectOptions contabilitaDanni = new SelectOptions('Contabilità Danni','HD1_ContabilitaDanni');
        SelectOptions contenzioso = new SelectOptions('Contenzioso','HD1_Contenzioso');
        SelectOptions famiglia = new SelectOptions('Famiglia','HD1_Biz_Famiglia');
        SelectOptions salute = new SelectOptions('Salute','HD1_Biz_Salute');
        SelectOptions auto = new SelectOptions('Auto','HD1_Biz_Auto');
        SelectOptions commercialLines = new SelectOptions('Commercial line','HD1_Biz_Commercial_line');
        SelectOptions vitaLOL = new SelectOptions('Vita-LOL','HD1_IT_AAI_VITA_LOL');
        
        if(String.isNotBlank(caseId))
        {
            Case cs = [SELECT Current_Owner_Queue__c   FROM Case WHERE id =:caseId LIMIT 1]; 
            if(cs.Current_Owner_Queue__c!= null){              
                
                //set options for layout HD1 BIZ e Buon Lavoro
                //
                if( (cs.Current_Owner_Queue__c).contains('HD1_Biz_') || (cs.Current_Owner_Queue__c).contains('Buon_Lavoro')){
                    List<SelectOptions> tempList = new List<SelectOptions>{it,vita,moduloDiCalcolo,contabilitaVita,contabilitaDanni,contenzioso,vitaLOL};
                        if( (cs.Current_Owner_Queue__c).equalsIgnoreCase('HD1_Biz_Vita')){
                            tempList.addAll(new List<SelectOptions>{auto, famiglia, salute ,commercialLines});
                        }
                    options = tempList;
                }
                //set options for button HD1 IT
                if((cs.Current_Owner_Queue__c).contains('HD1_IT') )
                    options =   new List<SelectOptions>{famiglia,salute,auto,vita,commercialLines,moduloDiCalcolo,contabilitaVita,contabilitaDanni,contenzioso,vitaLOL};
                        
                        //set options HD1 Contabilità
                        if((cs.Current_Owner_Queue__c).contains('HD1_Contabilita') )
                        options =  new List<SelectOptions>{it,famiglia,salute,auto,commercialLines,moduloDiCalcolo,contenzioso,vitaLOL};
                            
                            //set options HD1 Contenzioso
                            if((cs.Current_Owner_Queue__c).contains('HD1_Contenzioso') )
                            options = new List<SelectOptions>{it,famiglia,salute,auto,commercialLines,moduloDiCalcolo,contabilitaVita,contabilitaDanni,vitaLOL};
                                
                                //set options HD1 AAI VITA LOL
                                if((cs.Current_Owner_Queue__c).contains('HD1_IT_AAI_VITA_LOL') )
                                options = new List<SelectOptions>{it,vita,famiglia,salute,auto,commercialLines,moduloDiCalcolo,contabilitaVita,contabilitaDanni,contenzioso};
                                    }
            
        }
        return options;        
    }
    
    public class SelectOptions{
        @AuraEnabled public  string label {get;set;}
        @AuraEnabled public  string  value {get;set;}        
        
        public SelectOptions(string label, string value){
            this.label=label;
            this.value= value; 
        }
        
    }
    
    @AuraEnabled
    public static boolean checkProfileHD2()
    {
        Id id1 = UserInfo.getProfileId();
        String profileName = [Select Name from Profile WHERE Id =: id1 LIMIT 1].Name;
        
        if (profileName.equalsIgnoreCase('Technical Office') || profileName.equalsIgnoreCase('AAI - Supporto HD2') || profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD2') ||
            
            profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD2 BIZ') || profileName.equalsIgnoreCase('AAI - Supporto HD2 BIZ')) 
            
        { 
            return true;
        }
        
        return false;
    }
    
    public without sharing class runQueryWOS
    {
        public runQueryWOS()
        {
        }
        
        public User getUser (Case ca, boolean isOwner)
        {
            
            User u;
            if(isOwner)
            {
                u = [SELECT Name FROM User WHERE Id =: ca.OwnerId ]; // NOPMD  Fix CRUD violation
            } 
            else 
            {
                u = [SELECT Name FROM User WHERE Id =: ca.User__c ]; // NOPMD  Fix CRUD violation
            }
            
            return u;
            
        }
        
        public String getQueueEmail (Case ca)
        {
            
            String emailToReturn = '';
            List<Group> grp = [SELECT Id, Email, name FROM Group where Type = 'Queue' AND Id =: ca.OwnerId  LIMIT 1]; // NOPMD  Fix CRUD violation
            if(!grp.isEmpty())
            {
                emailToReturn = grp[0].Email;
            }
            return emailToReturn;
            
        }
        
        public List<CaseTeamMember> getCaseTeamMembers(Case ca)
        {
            List<CaseTeamMember> CaseTeamList = new List<CaseTeamMember>();
            
            for(CaseTeamMember Memb: [Select MemberId,Member.Name from CaseTeamMember where Parentid=:ca.Id and MemberId!=:ca.OwnerId ]) // NOPMD  Fix CRUD violation
            {
                CaseTeamList.add(Memb);
            }
            
            return CaseTeamList;
        }
        
        
        public Messaging.SendEmailResult[] sendEmail (List<Messaging.SingleEmailMessage> listEmail)
        {
            system.debug('sendEmail: '+listEmail);
            
            return Messaging.sendEmail(listEmail);
        }
    }
    @AuraEnabled
    public static Boolean getDefectMdC(String idCase){
        
        Case c = [SELECT Defect_Mdc__c FROM Case WHERE Id =: idCase];
        return c.Defect_Mdc__c;
    }
    
    @AuraEnabled	
    public static String InvioAHD3(String CaseID, String selectedValue, Datetime d, String dettaglio, String SilvaId){
        Case c = [Select ID, HD3_IT__c, Data_assegnazione_HD3_IT__c, Dettaglio_supporto_HD3__c, Current_Owner_Queue__c, Status from case where id =: CaseID];
        c.HD3_IT__c = selectedValue;
        c.Data_assegnazione_HD3_IT__c = d;
        c.Dettaglio_supporto_HD3__c=dettaglio;
        c.Current_Owner_Queue__c = c.Current_Owner_Queue__c!=null && c.Current_Owner_Queue__c.contains('HD2_IT')? 'HD3_IT_DIGITAL' : 'HD3_FORNITORE_ESTERNO';
        c.status = 'In gestione all\'HD3';
        c.Silva_Id__c = SilvaId;
        
        system.debug('InvioAHD3 debug - Case: ' + c);
        try{
            update c;
        }
        catch(Exception e){
            system.debug(e.getMessage() +' - '+ e.getStackTraceString());
            return 'KO';
        }
        
        return 'OK';
    }
    
    @AuraEnabled	
    public static String CompilaTicketSilva(String CaseID, String selectedValue, String dettaglio){
        Case c = [SELECT id, Current_Owner_Queue__c from case where id =: CaseId];
        c.Application_EAGP__c = selectedValue;
        c.Tipologia_Ticket_Silva__c = dettaglio;	
        c.Silva_Assignment_Group__c = c.Current_Owner_Queue__c;     	
        
        system.debug('CompilaTicketSilva debug - Case: ' + c);
        try{
            update c;
        }
        catch(Exception e){
            system.debug(e.getMessage() +' - '+ e.getStackTraceString());
            return 'KO';
        }
        
        return 'OK';
    }
    
    //Giorgio Bonifazi NMA Proposta automazione START
    @AuraEnabled
    public static String NewsaveCommentAttachment(String cmt, String cCase, String rT, Integer numberOfAttachment, List<String> attachmentList, String OrgUrl, String Label, String profileName, String userRole, Boolean defectCheckbox,String motivoTrasferimento, String selectedValue, String selectedLabel, String OwnerId){
        Case ca = [SELECT CaseNumber, LOB__c, Status, OwnerId, AccountID, Account.AAI_Agency_Reference_Code__c, TECH_LastHD1Queue__c, User__c, RecordType.Name, Agency_Code__c, PushNotification__c,Interazioni_Agente__c, ProfileNameOwner__c, QueueNameOwner__c, RoleNameOwner__c, supporto_mdc__c, Last_Advisor__c, Owner_HD1__c,Current_Owner_Queue__c, SubCategoryDetail__c FROM Case WHERE Id =: cCase];
        //String CodaDevName = [SELECT  DeveloperName   FROM Group WHERE Type ='Queue' and  id  =:  OwnerId ].DeveloperName;
        String oldCaseStatus = ca.Status.equals(AP_Constants.caseStatusAssigned) ? 'Preso in carico' : ca.Status;
        String destinatario;
        String emTemplate = '';
        User toUser = new User();
        runQueryWOS queryRunner = new runQueryWOS();
        EmailTemplate etem;
        boolean sendIt = true;
        String Output  = 'OK';
        String HD1OwnerId='';
        String HD1OwnerName='';
        Boolean isOwnwerTarget = false; 
        String toQueueEmail; 
        List<CaseTeamMember> toTeamMembers = new List<CaseTeamMember>();
        String recordtypeName;
        List<Case> csList = [SELECT Id,  RecordType.DeveloperName FROM Case WHERE id =:cCase  LIMIT 1];  // NOPMD  Fix CRUD violation
        recordTypeName = csList[0].RecordType.DeveloperName; 
        
        List<bypass__c> skipValidations = [select Id, Name, SetupOwnerId, SetupOwner.Name, BypassTrigger__c, BypassValidationRules__c, BypassWorkflows__c from Bypass__c  ]; // NOPMD  Fix CRUD violation
        
        //ECLEMENTE - 27/02/2024 - START: ADDED CUSTOM METADATA FOR CHECK IF THE LENGHT OF cmt IS > 1000(caseSNDcm.NumberChar__c)
        CaseSendComment__mdt caseSNDcm = [SELECT DeveloperName, ErrorMessage__c, NumberChar__c From CaseSendComment__mdt Where DeveloperName = 'FirstOptionValue'];
        
        if(cmt.length() > caseSNDcm.NumberChar__c){
            return Output =  'COMMENTO;'+caseSNDcm.ErrorMessage__c;
        }
        //ECLEMENTE - 27/02/2024 - END
                
        bypass__c skipValidation;
        for(bypass__c bp : skipvalidations)
        {
            if(bp.SetupOwnerId == UserInfo.getProfileId())
                skipValidation = bp;
        }

        if(String.isNotBlank(ca.Current_Owner_Queue__c) && (ca.Current_Owner_Queue__c.containsIgnoreCase('HD1') || ca.Current_Owner_Queue__c.containsIgnoreCase('Buon_Lavoro')|| ca.Current_Owner_Queue__c.containsIgnoreCase('Axa_Assicurazioni') || ca.Current_Owner_Queue__c.containsIgnoreCase('GDPR') ||ca.Current_Owner_Queue__c.containsIgnoreCase('Caring_Angel'))){
            if(ca.RecordType.Name == 'AXA Caring Salute' && rT.equalsIgnoreCase('Supporto')){
                ca.Status = 'In gestione Specialista';   
                ca.OwnerId =  OwnerId;
                destinatario ='Secondo Livello Business';
                sendIt = false; 
            }
            else if(ca.RecordType.Name.containsIgnoreCase('Caring Angel')  && rT.equalsIgnoreCase('Supporto') && motivoTrasferimento.containsIgnoreCase('In attesa info da cliente/rete')){
                ca.Status = 'Pending';   
                ca.OwnerId =  OwnerId;
                ca.Motivo_Trasferimento__c = motivoTrasferimento;
                destinatario ='Secondo Livello Business';
                sendIt = false; 
            }
            else if(ca.RecordType.Name.containsIgnoreCase('Caring Angel')  && rT.equalsIgnoreCase('Supporto')){
                ca.Status = 'Assegnato II Livello';   
                ca.OwnerId =  OwnerId;
                ca.Motivo_Trasferimento__c = motivoTrasferimento;
                destinatario ='Secondo Livello Business';
                sendIt = false; 
                
            }
            else if(ca.RecordType.Name == 'Axa Assicurazioni' && rT.equalsIgnoreCase('Supporto')){
                ca.Status = 'In gestione Specialista';   
                ca.OwnerId =  OwnerId;
                destinatario ='Secondo Livello Business';
                sendIt = false; 
                
            }
            /*if(ca.RecordType.Name == AP_Constants.rtCaseCloseTheLoop)  rT = 'Agente';*/
            if (rT.equalsIgnoreCase('Agente')){
                destinatario = 'Agente';
                
                List<QueueSobject> AgencyQueue = new List<QueueSobject>();
                String coda = '';
                if(ca.RecordType.Name == AP_Constants.rtCaseCloseTheLoop && String.isNotBlank(ca.Agency_Code__c))
                {
                    String queueName = 'Coda_Agenzia_Case_'+ca.Agency_Code__c;
                    AgencyQueue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName =:queueName  LIMIT 1]; // NOPMD  Fix CRUD violation
                    if(!AgencyQueue.IsEmpty())
                    {
                        coda = AgencyQueue[0].Queue.Id;
                        ca.OwnerId = coda;
                        ca.Status = AP_Constants.caseStatusGestioneAgente;
                    }
                    
                    sendIt = false;
                }
                else if (ca.RecordType.Name == AP_Constants.rtCaseAAIName){
                    if(ca.AccountID != null){
                        if(ca.Account.AAI_Agency_Reference_Code__c != null){
                            String queueName = 'Coda_Agenzia_Case_'+ca.Account.AAI_Agency_Reference_Code__c;
                            AgencyQueue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName =:queueName  LIMIT 1]; // NOPMD  Fix CRUD violation
                            String AgencyEmail = [Select Agency_Email__c from Account where Agency_Code__c =: ca.Account.AAI_Agency_Reference_Code__c limit 1].Agency_Email__c;
                            if(!AgencyQueue.IsEmpty())
                            {
                                coda = AgencyQueue[0].Queue.Id;
                                ca.Agency_Code__c = ca.Account.AAI_Agency_Reference_Code__c;
                                ca.OwnerId = coda;
                                ca.Status = 'Inoltrato all\'Agenzia';
                                if(AgencyEmail != null){
                                    ca.Agency_Email__c = AgencyEmail;
                                }
                            }
                            
                            sendIt = false;
                        }
                    }
                    else{
                        system.debug('Sto ritornando KOCliente');
                        return 'KOCliente';
                    }
                }
                else
                {
                    if(ca.User__c == null){
                        return 'KO';
                    }
                    ca.Status = 'Attesa Info Agente';    
                    
                    sendIt = true;
                    
                    Modello_di_Assistenza__mdt mdAss = [SELECT Id, Email_Template__c // NOPMD  Fix CRUD violation
                                                        FROM Modello_di_Assistenza__mdt 
                                                        WHERE DeveloperName = 'TemplateComunicazioneDaHD1' 
                                                        LIMIT 1];
                    
                    emTemplate = mdAss.Email_Template__c;                           
                    etem       = [SELECT Markup, Subject, HtmlValue, body // NOPMD  Fix CRUD violation
                                  FROM EmailTemplate 
                                  WHERE DeveloperName =: emTemplate ];
                    
                    if(recordTypeName != 'Assistenza_Applicativa'){  																						 
                        toUser = queryRunner.getUser(ca, false);}  
                } 
            }
            else if (rT.equalsIgnoreCase('Supporto') && ca.RecordType.Name != 'AXA Caring Salute' && ca.RecordType.Name != 'AXA Assicurazioni' && !ca.RecordType.Name.containsIgnoreCase('Caring Angel')){
                sendIt    = false;
                if(selectedValue.contains('HD1_IT')){
                    destinatario = 'Primo Livello IT';
                    ca.Status='Inoltrato ad IT';
                    ca.OwnerId = OwnerId;
                    if(selectedLabel == 'IT' && selectedValue == 'HD1_IT'){
                        ca.Lob__c = 'IT';
                        ca.Category__c = null;
                        ca.SubCategory__c = null;
                    }
                }
                else if(selectedLabel == 'Vita' && selectedValue == 'HD1_Biz_Vita' ){
                    destinatario = 'Primo Livello Business';
                    ca.Status='Inoltrato a Linea di Business';
                    ca.OwnerId = OwnerId;
                    if(selectedLabel == 'Vita' && selectedValue == 'HD1_Biz_Vita'){
                        ca.Lob__c = 'Vita';
                        ca.Category__c = null;
                        ca.SubCategory__c = null;
                    }
                }
                else if(selectedValue.contains('HD1_Contabilita')){
                    destinatario = 'Primo Livello Contabilità';
                    ca.Status='Inoltrato a Contabilità';
                    ca.OwnerId = OwnerId;
                    if(selectedLabel == 'Contabilità Vita' && selectedValue == 'HD1_Contabilita'){
                        ca.Lob__c = 'Contabilità Vita';
                        ca.Category__c = null;
                        ca.SubCategory__c = null;
                    }else if(selectedLabel == 'Contabilità Danni' && selectedValue == 'HD1_Contabilita'){
                        ca.Lob__c = 'Contabilità Danni';
                        ca.Category__c = null;
                        ca.SubCategory__c = null;
                    }                
                }
                else if(selectedValue.contains('HD1_Contenzioso')){
                    destinatario = 'Primo Livello Contenzioso';
                    ca.Status='Inoltrato a Contenzioso';
                    ca.OwnerId = OwnerId;
                    if(selectedLabel == 'Contenzioso' && selectedValue == 'HD1_Contenzioso'){
                        if(ca.Current_Owner_Queue__c.equalsIgnoreCase('HD1_Contabilita')){
                            if(!ca.LOB__c.equalsIgnoreCase('Contenzioso')){
                                ca.Lob__c = 'Contenzioso';
                                ca.Category__c = null;
                                ca.SubCategory__c = null;
                            }
                        }
                        else{
                            ca.Lob__c = 'Contenzioso';
                            ca.Category__c = null;
                            ca.SubCategory__c = null;
                        }
                    } 
                }
                else if(selectedValue.contains('HD1_Biz')){
                    destinatario = 'Primo Livello Business';
                    ca.Status='Inoltrato a Linea di Business';
                    ca.OwnerId = OwnerId;
                    if(selectedLabel == 'Vita' && selectedValue == 'HD1_Biz_Vita'){
                        ca.Lob__c = 'Vita';
                        ca.Category__c = null;
                        ca.SubCategory__c = null;
                    }if(selectedLabel == 'Famiglia' && selectedValue == 'HD1_Biz_Famiglia'){
                        ca.Lob__c = 'Famiglia';
                        ca.Category__c = null;
                        ca.SubCategory__c = null;
                    }else if(selectedLabel == 'Salute' && selectedValue == 'HD1_Biz_Salute'){
                        ca.Lob__c = 'Salute';
                        ca.Category__c = null;
                        ca.SubCategory__c = null;
                    }else if(selectedLabel == 'Auto' && selectedValue == 'HD1_Biz_Auto'){
                        ca.Lob__c = 'Auto';
                        ca.Category__c = null;
                        ca.SubCategory__c = null;
                    }else if(selectedLabel == 'Commercial line' && selectedValue == 'HD1_Biz_Commercial_line'){
                        ca.Lob__c = 'Commercial line';
                        ca.Category__c = null;
                        ca.SubCategory__c = null;
                    }
                    
                }
                else if(selectedValue.contains('HD1_IT_AAI_VITA_LOL')){
                    destinatario = 'Primo Livello Business';
                    ca.Status='Inoltrato a Linea di Business';
                    ca.OwnerId = OwnerId;
                    ca.Lob__c = 'Vita-LOL';
                    ca.Category__c = null;
                    ca.SubCategory__c = null;
                    
                }
                else if(selectedValue.contains('HD2_Modulo_di_Calcolo')){
                    destinatario = 'Supporto Modulo di Calcolo';
                    ca.Status = 'In gestione Specialista';
                    ca.OwnerId = OwnerId;
                }
                else{
                    ca.Status = 'In gestione Specialista';
                    if(selectedValue.contains('Biz'))
                        destinatario = 'Secondo Livello Business';
                    else
                        destinatario ='Secondo Livello IT';
                    
                    ca.OwnerId = OwnerId; 
                }
                /*if(!profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD2 BIZ') && !profileName.equalsIgnoreCase('AAI - Supporto HD2 BIZ'))ca.Status = 'In gestione Specialista';destinatario = '';*/
            }                                    
        }
        
        else if(String.isNotBlank(ca.Current_Owner_Queue__c) && (ca.Current_Owner_Queue__c.containsIgnoreCase('HD2')||ca.Current_Owner_Queue__c.containsIgnoreCase('HD3_IT_DIGITAL')) && ca.RecordType.Name != 'AXA Caring Salute' && ca.RecordType.Name != 'Close the loop'){
       
            if (rT.equalsIgnoreCase('Agente') && (profileName.equalsIgnoreCase('AAI - Supervisor Supporto HD2 BIZ') || profileName.equalsIgnoreCase('AAI - Supporto HD2 BIZ'))) {
                destinatario = 'Agente';
                ca.Status = 'Attesa Info Agente';    
                sendIt = true;
                Modello_di_Assistenza__mdt mdAss = [SELECT Id, Email_Template__c // NOPMD  Fix CRUD violation
                                                    FROM Modello_di_Assistenza__mdt 
                                                    WHERE DeveloperName = 'TemplateComunicazioneDaHD1' 
                                                    LIMIT 1];
                emTemplate = mdAss.Email_Template__c;                           
                etem       = [SELECT Markup, Subject, HtmlValue, body // NOPMD  Fix CRUD violation
                              FROM EmailTemplate 
                              WHERE DeveloperName =: emTemplate ];
                toUser = queryRunner.getUser(ca, false);                  
            }
            else{ 
                MPS_Code_Variables__c mdc_axa_role_config = MPS_Code_Variables__c.getValues('MdC AXA');
                List<String> mdc_axa_roles = new List<String>();
                for(String role : mdc_axa_role_config.Value__c.split(';')){
                    mdc_axa_roles.add(role);
                }
                if(Label == 'Supporto Modulo di Calcolo'){
                    destinatario = 'Supporto Modulo di Calcolo';
                    ca.Status = 'In gestione Specialista';
                    if(mdc_axa_roles.contains(userRole)){
                        List<CaseTeamMember> HD2_RGI_Owner = [Select  memberid, member.name from CaseTeamMember where parentid=:cCase and member.userRole.Name = 'RGI'  Order by createddate desc LIMIT 1]; // NOPMD  Fix CRUD violation
                        ca.OwnerId = HD2_RGI_Owner[0].memberid;
                        ca.Da_testare_Modulo_di_Calcolo__c = false;
                    }
                    else{
                        List<QueueSobject> HD2MdcQueue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName =:'HD2_Modulo_di_Calcolo'  LIMIT 1]; // NOPMD  Fix CRUD violation
                        ca.OwnerId = HD2MdcQueue[0].Queue.Id;
                    }
                }
                else if(Label == 'Supporto Modulo di Calcolo AXA'){
                    destinatario = 'Supporto Modulo di Calcolo AXA';
                    ca.Status = 'In gestione specialistica Ufficio tecnico';
                    List<QueueSobject> HD2MdcAXAQueue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName =:'HD2_Modulo_di_Calcolo_AXA'  LIMIT 1]; // NOPMD  Fix CRUD violation
                    ca.OwnerId = HD2MdcAXAQueue[0].Queue.Id;
                    MPS_Code_Variables__c businessHoursDefault = MPS_Code_Variables__c.getValues('BusinessHours_Default');
                    String bizHoursID = businessHoursDefault.Value__c;
                    Integer alert= Integer.valueOf(MPS_Code_Variables__c.getValues('ModuloDiCalcolo_tempiInoltroCoda').Value__c);
                    ca.TECH_Inoltro_Coda_HD2_MdC_AXA__c = BusinessHours.addGMT(bizHoursID,System.now(),((alert)*60 * 60 * 1000L));
                    ca.Da_testare_Modulo_di_Calcolo__c = true;
                    ca.Supporto_MdC__c = true;
                    ca.Defect_Mdc__c = defectCheckbox;
                }
                else{
                    if (ca.RecordType.Name != 'AXA Caring Salute' && !rT.equals('SendHD3') && !ca.RecordType.Name.contains('Caring Angel') && (String.isBlank(selectedValue) || selectedValue == null) ){
                        if(mdc_axa_roles.contains(userRole))
                            ca.Da_testare_Modulo_di_Calcolo__c = false;
                        sendIt = true;
                        ca.Status = 'Risposta specialista';
                        String HD1Type = '';
                        if(profileName.indexOf('HD2 BIZ')<>-1){
                            if(ca.LOB__c!= null && ca.LOB__c.equalsIgnoreCase(AP_constants.caseLobVita)){
                                HD1Type = 'HD1 Contabilita';
                                destinatario = 'Primo Livello Business';
                            }
                            else{
                                HD1Type = 'HD1 BIZ';
                                destinatario = 'Primo Livello Business';
                            }
                        }
                        else{
                            HD1Type = 'HD1 IT';
                            destinatario = 'Primo Livello IT';
                        }
                        List<CaseTeamMember> HD1Owner = new List<CaseTeamMember>();
                        if(mdc_axa_roles.contains(userRole)|| ca.RecordType.Name.equals('Axa Assicurazioni')){
                            String lastHD1Id = ca.Last_Advisor__c;
                            HD1Owner = [SELECT  memberid, member.name, TeamRole.Name FROM CaseTeamMember WHERE (parentid=:cCase AND memberid =: lastHD1Id)  LIMIT 1]; // NOPMD  Fix CRUD violation
                            if(!HD1Owner.isEmpty()){
                                if(HD1Owner[0].TeamRole.Name == 'HD1 IT')
                                    destinatario = 'Primo Livello IT';
                                else if(HD1Owner[0].TeamRole.Name == 'HD1 Contabilita')
                                    destinatario = 'Primo Livello Contabilità';
                                else if(HD1Owner[0].TeamRole.Name == 'HD1 Contenzioso')
                                    destinatario = 'Primo Livello Contenzioso';
                                else
                                    destinatario = 'Primo Livello Business';
                            }
                        }
                        else{ 
                            if(ca.supporto_mdc__c == true && userRole == 'RGI'){ //allow to assign cases to others HD1
                                HD1Owner = [Select  memberid,member.name from CaseTeamMember where parentid=:cCase and TeamRole.Name like 'HD1%'  Order by lastModifieddate desc LIMIT 1];     // NOPMD  Fix CRUD violation 
                            }else{
                                HD1Owner = [Select  memberid,member.name from CaseTeamMember where parentid=:cCase and TeamRole.Name =:HD1Type  Order by createddate desc LIMIT 1]; // NOPMD  Fix CRUD violation    
                                if(HD1Owner.isEmpty()){
                                    HD1Owner = [Select  memberid,member.name from CaseTeamMember where parentid=:cCase and TeamRole.Name like 'HD1%'  Order by lastModifieddate desc LIMIT 1]; // NOPMD  Fix CRUD violation
                                }
                            }  
                        }     
                        if(!HD1Owner.isEmpty()){
                            HD1OwnerId = HD1Owner[0].memberid;
                            HD1OwnerName = HD1Owner[0].member.name;
                            ca.OwnerId = HD1OwnerId;
                        }
                        else{
                            HD1Owner = [Select  memberid,member.name from CaseTeamMember where parentid=:cCase and TeamRole.Name like 'HD2%'  Order by lastModifieddate asc LIMIT 1]; // NOPMD  Fix CRUD violation
                            HD1OwnerId = HD1Owner[0].memberid;
                            HD1OwnerName = HD1Owner[0].member.name;
                            ca.OwnerId = HD1OwnerId;
                        }
                        ca.Current_Owner_Queue__c = ca.TECH_LastHD1Queue__c;
                        Modello_di_Assistenza__mdt mdAss = [SELECT Id, Email_Template__c // NOPMD  Fix CRUD violation
                                                            FROM Modello_di_Assistenza__mdt 
                                                            WHERE DeveloperName = 'TemplateComunicazioneDaHD2' 
                                                            LIMIT 1];
                        emTemplate = mdAss.Email_Template__c;
                        etem       = [SELECT Markup, Subject, HtmlValue, body // NOPMD  Fix CRUD violation
                                      FROM EmailTemplate 
                                      WHERE DeveloperName =: emTemplate ];        
                    }  
                }
            }
        }
        else if((String.isBlank(selectedValue) || selectedValue == null) && ( String.isNotBlank(ca.Current_Owner_Queue__c) && (ca.Current_Owner_Queue__c.containsIgnoreCase('HD2') || ca.Current_Owner_Queue__c.containsIgnoreCase('HD3')) &&  ca.RecordType.Name == 'AXA Caring Salute' && !rT.equals('SendHD3'))){
            ca.Status = 'Risposta Specialista';
            List<CaseTeamMember> HD1_Owner = [Select  memberid, member.name from CaseTeamMember where parentid=:cCase and member.userRole.Name in ('HD1 Outsourcer AD Salute','HD1 Outsourcer AD Sinistri','HD1 Outsourcer AD','Caring Salute HD1','Caring Salute') and memberid != :ca.OwnerId  Order by createddate desc LIMIT 1]; // NOPMD  Fix CRUD violation
            ca.OwnerId = HD1_Owner[0].memberid;
            ca.Current_Owner_Queue__c = ca.TECH_LastHD1Queue__c;
            destinatario = 'Primo Livello Business';
            sendIt = true; 
            
            Modello_di_Assistenza__mdt mdAss = [SELECT Id, Email_Template__c // NOPMD  Fix CRUD violation
                                                FROM Modello_di_Assistenza__mdt 
                                                WHERE DeveloperName = 'TemplateComunicazioneDaHD2' 
                                                LIMIT 1];
            emTemplate = mdAss.Email_Template__c;
            etem       = [SELECT Markup, Subject, HtmlValue, body // NOPMD  Fix CRUD violation
                          FROM EmailTemplate 
                          WHERE DeveloperName =: emTemplate ];     
        }
        else if(rt.equalsIgnoreCase('Supporto') && selectedValue != null && selectedValue.contains('Selezione') && 
                !ca.recordtype.name.equals(AP_Constants.rtCaseCloseTheLoop)){
                    ca.Status = 'In gestione Specialista';   
                    ca.OwnerId =  OwnerId;
                    destinatario ='Secondo Livello Business';
                }
        else if(ca.recordtype.name.equals(AP_Constants.rtCaseCloseTheLoop)){
            if(rt.equalsIgnoreCase('Supporto')){
                if(selectedValue != null){
                    ca.Status = 'In gestione Specialista';   
                    ca.OwnerId =  OwnerId;
                    destinatario ='Secondo Livello Business';
                }
                else{
                    List<CaseTeamMember> HD1Owner = [Select  memberid,member.name from CaseTeamMember where parentid=:cCase and TeamRole.Name like 'HD1%'  Order by lastModifieddate desc LIMIT 1]; // NOPMD  Fix CRUD violation
                    if(!HD1Owner.isEmpty())
                    {
                        HD1OwnerId = HD1Owner[0].memberid;
                        HD1OwnerName = HD1Owner[0].member.name;
                        ca.OwnerId = HD1OwnerId;
                        ca.Status = 'Risposta specialista';
                        ca.Current_Owner_Queue__c = ca.TECH_LastHD1Queue__c;
                    }
                }
            }
            else if(rT.equalsIgnoreCase('Agente') && ca.Agency_Code__c != null){
                String coda = '';
                String queueName = 'Coda_Agenzia_Case_'+ca.Agency_Code__c;
                List<QueueSobject> AgencyQueue = [SELECT Id, Queue.Id, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE Queue.DeveloperName =:queueName  LIMIT 1]; // NOPMD  Fix CRUD violation
                if(!AgencyQueue.IsEmpty())
                {
                    coda = AgencyQueue[0].Queue.Id;
                    ca.OwnerId = coda;
                    ca.Status = AP_Constants.caseStatusGestioneAgente;
                }
                
                sendIt = false;                
            }
        }
        String profileAlias;
        if(profileName.contains('Vendite'))
        {
            profileAlias = 'Agente';
            userRole = '-';
        }            
        
        else if(profileName.contains('HD1') || profileName.contains('SmartCenter')) 
            profileAlias = 'Primo Livello';
        else if(profileName.contains('HD2'))
            profileAlias = 'Secondo Livello';
        
        
        String TechProfileName = '';
        
        if(profileName.contains('Vendite'))
            TechProfileName = 'Agente';
        else if(profileName.contains('HD1 BIZ') || profileName.contains('Caring Salute HD1'))
            TechProfileName = 'Primo Livello Business';
        
        else if(!profileName.contains('HD1 BIZ') && profileName.contains('HD1') && userRole!='HD1 Contabilita' && userRole!='HD1 Contenzioso')
            
            TechProfileName = 'Primo Livello IT';   
        else if(!profileName.contains('HD2 BIZ') && !profileName.contains('Caring Salute HD2') && profileName.contains('HD2') )         
            TechProfileName = 'Secondo Livello IT';   
        else if(profileName.contains('HD2 BIZ') || profileName.contains('Caring Salute HD2'))
            TechProfileName = 'Secondo Livello Business';            
        
        else if(profileName.contains('HD1 Contabilità') || userRole =='HD1 Contabilita')
            TechProfileName = 'Primo Livello Contabilità';
        else if(profileName.contains('HD1 Contenzioso') || userRole =='HD1 Contenzioso')
            TechProfileName = 'Primo Livello Contenzioso';
        
        
        String description = '';
        String attachmentnames ='';
        String commenttype='';
        
        if(attachmentList.size()>0)
        {
            for(String s: attachmentList)
            {
                if(String.isNotBlank(attachmentnames))
                    attachmentnames+=', '+s;
                else
                    attachmentnames = s;
            }
        }
        
        
        if(ca.RecordType.Name == AP_Constants.rtCaseCloseTheLoop)
        {
            if(cmt.length()>0){
                description= String.valueOf(cmt);
                system.debug('description - ENTER IF description: '+description);
            }
            
            commenttype='Supporto richiesto ad Agenzia';
        }
        else
        {
            if((Integer.valueOf(numberOfAttachment) > 0) && (cmt.length() > 0)){           
                description = String.valueOf(cmt);
                commenttype = 'Inserimento commento e allegato';
            } else if(cmt.length() != 0){
                description = String.valueOf(cmt);
                commenttype = 'Inserimento commento';
                
                Integer currentIntAgente = Integer.valueOf(ca.Interazioni_Agente__c);
                if(currentIntAgente == null){
                    currentIntAgente = 0;
                }
                
                if(oldCaseStatus != 'Attesa Info Agente' && TechProfileName == 'Agente')
                {
                    ca.Interazioni_Agente__c = currentIntAgente+1;
                }
                
            } else if ((Integer.valueOf(numberOfAttachment) > 0) && (!(cmt.length() > 0))) {
                description = 'Sono stati inseriti i seguenti nuovi allegati: '+attachmentnames;
                commenttype = 'Condivisione allegato';
                
                
            } else{
                description = 'Non sono stati inseriti commenti / allegati ';
                commenttype = '';
                
            }
        }
        
        if(rT.equals('SendHD3')){
            rt = 'Supporto';
        }
        
        String rTId = [SELECT Id FROM RecordType WHERE DeveloperName =: rT].Id;
        Storico_conversazioni__c sc = new Storico_conversazioni__c();
        sc = new Storico_conversazioni__c( Description__c = description, Connected_case__c = cCase, CaseStatus__c = oldCaseStatus, Type__c = commenttype, RecordTypeId = rTId, Profilo_utente__c = profileAlias, Ruolo_utente__c = userRole, Tech_Profilo_Utente__c = TechProfileName, Destinatario_Commento__c = destinatario, /*Defect_Mdc__c = defectCheckbox,*/Motivo_trasferimento__c = motivoTrasferimento); //OAVERSANO 10/12/2018 : modifica CaseStatus Storico Conversazioni
        Boolean checkUpsert = false;
        Savepoint sp = Database.setSavepoint();
        try
        {         
            checkUpsert = true;  
            insert sc; // NOPMD  Fix CRUD violation
            
            update ca;
            if (skipValidation!=null && (profileName.equalsIgnoreCase('AAI - Vendite solo Assistenza') || profileName.equalsIgnoreCase('AAI - Vendite Base') || profileName.equalsIgnoreCase('AAI - Vendite Avanzato') || profileName.equalsIgnoreCase('AAI - Vendite No Accordo Digitale')))
            {
                skipValidation.BypassValidationRules__c= false;
                update skipValidation; // NOPMD  Fix CRUD violation
            }
        }
        catch(exception ex)
        {
            Output = ex.getmessage();
            checkUpsert = false;
            system.debug('errore: ' +ex.getmessage());
            Database.rollback(sp);
            
        }
        
        try
        {       
            system.debug('sendIt: '+sendIt+' checkUpsert : '+checkUpsert);
            if(sendIt && checkUpsert){
                
                String OrgEmail    = (MPS_Code_Variables__c.getAll()).get('ModelloAssistenzaOrgEmail') != null ? (MPS_Code_Variables__c.getAll()).get('ModelloAssistenzaOrgEmail').Value__c : null;
                
                List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String htmlBody = etem.HtmlValue;
                String htmlBody2 = htmlBody;
                String subject = etem.Subject;
                String body    = etem.body;
                subject  = subject.replace('{!Case.CaseNumber}', ca.CaseNumber);
                subject  = subject.replace('{!Case.Status}', ca.Status);
                htmlBody = htmlBody.replace('{!Case.User__c}', (isOwnwerTarget?'':String.isBlank(HD1OwnerId)?toUser.Name:HD1OwnerName));
                body     = body.replace('{!Case.User__c}', (isOwnwerTarget?'':String.isBlank(HD1OwnerId)?toUser.Name:HD1OwnerName));
                htmlBody = htmlBody.replace('{!Case.CaseNumber}', ca.CaseNumber);    
                body     = body.replace('{!Case.CaseNumber}', ca.CaseNumber);
                htmlBody = htmlBody.replace('{!Case.Description}', description);    
                body     = body.replace('{!Case.Description}', description);
                
                
                
                String url = '';
                String urlNFE = '';
                if (profileName.equalsIgnoreCase('AAI - Vendite solo Assistenza') || profileName.equalsIgnoreCase('AAI - Vendite Base') || profileName.equalsIgnoreCase('AAI - Vendite Avanzato') || profileName.equalsIgnoreCase('AAI - Vendite No Accordo Digitale'))
                {
                    url = [SELECT OrgLink__c 
                           FROM Modello_di_Assistenza__mdt 
                           WHERE DeveloperName = 'Redirect'
                           LIMIT 1].OrgLink__c;
                    url = url + cCase;
                }
                else
                {
                    if (rT.equalsIgnoreCase('Supporto')) 
                    {
                        url = [SELECT OrgLink__c 
                               FROM Modello_di_Assistenza__mdt 
                               WHERE DeveloperName = 'Redirect'
                               LIMIT 1].OrgLink__c;    
                        url = url + cCase;
                    }
                    else
                    {
                        url = [SELECT OrgLink__c 
                               FROM Modello_di_Assistenza__mdt 
                               WHERE DeveloperName = 'RedirectCommunity'
                               LIMIT 1].OrgLink__c;    
                        url = url + cCase;                         
                        urlNFE =    [SELECT OrgLink__c 
                                     FROM Modello_di_Assistenza__mdt 
                                     WHERE DeveloperName = 'RedirectCommunityNFE'
                                     LIMIT 1].OrgLink__c + cCase;                      
                    }                    
                }
                
                if(htmlBody.contains('{!Case.Link1}')){
                    htmlBody = htmlBody.replace('{!Case.Link1}', url );
                    htmlBody = htmlBody.replace('{!Case.Link2}', urlNFE ); 
                    body = body.replace('{!Case.Link1}', url ); 
                    body = body.replace('{!Case.Link2}', urlNFE ); 
                }
                else{
                    htmlBody = htmlBody.replace('{!Case.Link}', url);    
                    body     = body.replace('{!Case.Link}', url);   
                } 
                
                email.setHtmlBody(htmlBody);
                email.setSubject(subject);
                
                
                email.saveAsActivity = false;
                
                if(String.isNotBlank(OrgEmail))
                    email.setOrgWideEmailAddressId(OrgEmail);
                
                if(isOwnwerTarget)
                {
                    List<String> toAddresses = new List<String>();
                    toAddresses.add(toQueueEmail);
                    email.setToAddresses(toAddresses);
                }
                else
                {
                    email.setTargetObjectId((String.isBlank(HD1OwnerId)?toUser.Id:HD1OwnerId));
                }
                listEmail.add(email);
                
                Messaging.SendEmailResult [] results = queryRunner.sendEmail(listEmail);
                
                for(Messaging.SendEmailResult re : results)
                {
                    if (re.success) {
                        System.debug('The email was sent successfully.');
                    } else {
                        System.debug('The email failed to send: ' + re.errors[0].message);
                    }
                }
                
                if(!toTeamMembers.isEmpty())
                {
                    for(CaseTeamMember u : toTeamMembers)
                    {
                        List<Messaging.SingleEmailMessage> listEmail2 = new List<Messaging.SingleEmailMessage>();
                        Messaging.SingleEmailMessage email2 = new Messaging.SingleEmailMessage();
                        String Html3 =htmlBody2;
                        email2.setSubject(subject);
                        email2.setTargetObjectId(u.Memberid);
                        Html3 = Html3.replace('{!Case.User__c}', u.Member.Name);
                        Html3 = Html3.replace('{!Case.CaseNumber}', ca.CaseNumber);  
                        Html3 = Html3.replace('{!Case.Description}', description);
                        Html3 = Html3.replace('{!Case.Link}', url);    
                        email2.setHtmlBody(Html3);
                        email2.setOrgWideEmailAddressId(OrgEmail);
                        email2.saveAsActivity = false;
                        listEmail2.add(email2);
                        Messaging.SendEmailResult [] results2 = queryRunner.sendEmail(listEmail2);
                        
                        for(Messaging.SendEmailResult re : results2)
                        {
                            if (re.success) {
                                System.debug('The email was sent successfully.');
                            } else {
                                System.debug('The email failed to send: ' + re.errors[0].message);
                            }
                        }                        
                    }
                } 
            }           
        }
        catch(exception ex)
        {
            System.debug(ex.getStackTraceString());
        }
        
        return Output;
    }
    @AuraEnabled	
    public static String UpdateTagRichiesta(String CaseId, String selectedValue){
        System.debug('Update Tag Richiesta START - CaseId ' + CaseID);
        Case c = [SELECT id, Current_Owner_Queue__c,Tag_Richiesta__c from case where id =: CaseID];
        c.Tag_Richiesta__c = selectedValue;
        
        system.debug('UpdateTagRichiesta debug'+'Case: ' + c);
        try{
            update c;
        }
        catch(Exception e){
            system.debug(e.getMessage() +' - '+ e.getStackTraceString());
            return 'KO';
        }
        
        return 'OK';
    }    
    
    //ML Aggiunto per check Owner
    @AuraEnabled
    public static Case getCaseFields(String caseId){
        Case c = [SELECT RecordType.DeveloperName, LOB__c, Category__c FROM Case WHERE Id =: caseId LIMIT 1];
        return c;
    }
    
    @AuraEnabled
    public static CaseOptionsWrapper getCaseValues(String CaseId){
        CaseOptionsWrapper resp = new CaseOptionsWrapper();
        boolean blockButton = false;
        
        Case c = [Select Tipologia_Ticket_Silva__c, Stato_Integrazione_Silva__c, Silva_Id__c, Application_EAGP__c, Application_EAGP__r.Name, Current_Owner_Queue__c, Recordtype.DeveloperName, Tag_Richiesta__c from case where id =: CaseId];
        
        resp.TagRichiesta = c.Tag_Richiesta__c;
        resp.NomeApplicazioneSilva = c.Application_EAGP__r.Name;
        resp.TipologiaTicketSilva = c.Tipologia_Ticket_Silva__c;
        
        List<MPS_Code_Utils__mdt> mpsList = [SELECT Id, DeveloperName, Value__c, High_Volume_Values__c // NOPMD  Fix CRUD violation
                                             FROM MPS_Code_Utils__mdt 
                                             WHERE DeveloperName LIKE 'Tag_Richiesta_Not_Needs_Silva%' 
                                            ];
        List<String> TagRichiestaSilva = new List<String>();
        for(MPS_Code_Utils__mdt mps : mpsList){
            TagRichiestaSilva.add(mps.Value__c);
        }
        
        resp.TagRichiestaNeedSilva = TagRichiestaSilva;
        
        List<String> TRoptions = new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.Tag_Richiesta__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            TRoptions.add(pickListVal.getLabel());
        }     
        resp.TagRichiestaValues = TRoptions;
        
        /*if(c.Tag_Richiesta__c == 'XXX' || (c.Stato_Integrazione_Silva__c == null && c.Silva_Id__c == null)){
blockButton = true;
}*/
        resp.BlockButton = blockButton;
        
        return resp;
    }
    
    public class CaseOptionsWrapper{
        @AuraEnabled public List<String> TagRichiestaValues{get;set;}
        @AuraEnabled public String TagRichiesta{get;set;}
        @AuraEnabled public boolean BlockButton{get;set;}
        @AuraEnabled public String NomeApplicazioneSilva{get;set;}
        @AuraEnabled public String TipologiaTicketSilva{get;set;}
        @AuraEnabled public List<String> TagRichiestaNeedSilva{get;set;}
        
        
    }
}
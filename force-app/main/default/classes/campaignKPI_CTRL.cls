public with sharing class campaignKPI_CTRL {
    
    public String mycurrentCampaignId {get;set;}
   // public String UserAgency {get;set;}
    public String CampaignType {get;set;}
   /*
    public Boolean isStandardUser {get;set;}
    public String UserRole {get;set;}
    public String PartnerUrl {get;set;}
    public String UserProfile {get;set;}
   */
    
    
    public campaignKPI_CTRL(ApexPages.StandardController controller) {
       
        myCurrentCampaignId = ApexPages.currentPage().getParameters().get('id');

        CampaignType = [Select Recordtype.DeveloperName from Campaign where Id=:myCurrentCampaignId].Recordtype.DeveloperName;
/*
        UserAgency ='';
        UserRole='';
        UserProfile='';
        

        isStandardUser = true;

        if(UserInfo.getUserType()<>'Standard')
        {
            User CurrentUser = [Select Agency_Code__c,UserRole.name,Profile.Name from User where id=:UserInfo.getUserId()];
            
            UserAgency = (String.isNotBlank(CurrentUser.Agency_Code__c))?CurrentUser.Agency_Code__c:'';
            UserRole = (String.isNotBlank(CurrentUser.UserRole.name))?CurrentUser.UserRole.name:'';
            UserProfile = (String.isNotBlank(CurrentUser.Profile.Name))?CurrentUser.Profile.Name:'';
          

            isStandardUser = false;
        }

        PartnerUrl='';

        PartnerUrl=[SELECT Value__c FROM AAI_Code_Variables__c WHERE Name = 'CampaignKPI' limit 1].Value__c;
        */
    }   
    
    public static Campaign getCampaign(Id mycurrentCampaignId){
        
        Campaign myCampaign = new Campaign();
        
        myCampaign = [SELECT Name FROM Campaign WHERE Id =:mycurrentCampaignId LIMIT 1];

        return myCampaign;
        
    }
    
    /*
* @Name : - fetchUserSessionId
* @Description: - Call the VF page and get the Log In Use Session Id
* @Params : - none
* @ReturnType : - String
*/

    public static String fetchUserSessionId(){
        String SessionId = '';
        // Refer to the Page
        PageReference reportPage = Page.campaignKPIwrapper;
        // Get the content of the VF page
        String vfContent = reportPage.getContent().toString();
        System.debug('vfContent '+vfContent);
        // Find the position of Start_Of_Session_Id and End_Of_Session_Id
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
            endP = vfContent.indexOf('End_Of_Session_Id');
        // Get the Session Id
        SessionId = vfContent.substring(startP, endP);
        System.debug('SessionId '+SessionId);
        // Return Session Id
        return SessionId;
    }
    
    
    /*
* @Name - makeAPICall
* @Description - Responsible for making API Call out
* @params - None
* @ReturnType - String
*/
    @AuraEnabled
    public static String ClientiInTarget(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        
        system.debug('#CampaignId: '+AgencyList);

        String query = 'SELECT+COUNT(Id)+FROM+CampaignMember+WHERE+CampaignId+=+'+'\''+CampaignId+'\'';

        if(string.isnotblank(CollaboratoreId))
            query+='+AND+Owner__r.Id+='+'\''+CollaboratoreId+'\'';

        if(String.isNotBlank(CodiceAgenzia))
        {
            query+='+AND+Agency_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';
        }
        
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                    age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Agency_Code__c+in+'+age;
        }
        
       //String SessionId = fetchUserSessionId();
        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();

        system.debug('##SessionId: '+String.isnotblank(SessionId));
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        //req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v41.0/query/?q='+query);

        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }    

        
        system.debug('rew: '+req);
        resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
    @AuraEnabled
    public static String ClientiLavorati(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();

        String query = 'SELECT+COUNT(Id)+FROM+CampaignMember+WHERE+Status+NOT+IN+(\'Da+assegnare\',\'Da+contattare\',\'Da+lavorare\')+AND+CampaignId+=+'+'\''+CampaignId+'\'';
        
        if(string.isnotblank(CollaboratoreId))
            query+='+AND+Owner__r.Id+='+'\''+CollaboratoreId+'\'';
       
        if(String.isNotBlank(CodiceAgenzia))
        {
            query+='+AND+Agency_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Agency_Code__c+in+'+age;
        }

        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        } 

        system.debug('rew1: '+req);
        resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
    @AuraEnabled
    public static String ClientiPrioritari(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();

        String query = 'SELECT+COUNT(Id)+FROM+CampaignMember+WHERE+Cliente_prioritario__c+=+true+AND+CampaignId+=+'+'\''+CampaignId+'\'';

        if(string.isnotblank(CollaboratoreId))
            query+='+AND+Owner__r.Id+='+'\''+CollaboratoreId+'\'';
       
        if(String.isNotBlank(CodiceAgenzia))
        {
            query+='+AND+Agency_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Agency_Code__c+in+'+age;
        }

        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
    @AuraEnabled
    public static String ClientiPrioritariLavorati(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();

        String query='SELECT+COUNT(Id)+FROM+CampaignMember+WHERE+Status+NOT+IN+(\'Da+assegnare\',\'Da+contattare\',\'Da+lavorare\')+AND+Sottostato__c+IN+(\'Richiesta+di+contatto+da+Email\',\'Richiesta+di+contatto+da+SMS\')+AND+CampaignId+=+'+'\''+CampaignId+'\'';

        if(string.isnotblank(CollaboratoreId))
            query+='+AND+Owner__r.Id+='+'\''+CollaboratoreId+'\'';
       
        if(String.isNotBlank(CodiceAgenzia))
        {
            query+='+AND+Agency_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Agency_Code__c+in+'+age;
        }

        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
    @AuraEnabled
    public static String OpportunitaCreate(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();

        String query = 'SELECT+COUNT(Id)+FROM+Opportunity+WHERE+CampaignId+=+'+'\''+CampaignId+'\'';
       
        if(string.isnotblank(CollaboratoreId))
            query+='+AND+CreatedById+='+'\''+CollaboratoreId+'\'';

        if(String.isNotBlank(CodiceAgenzia))
        {
            query+='+AND+Account.AAI_Agency_Reference_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';  
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Account.AAI_Agency_Reference_Code__c+in+'+age;          
        }

        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
    @AuraEnabled
    public static String OpportunitaVinte(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();

        String query='SELECT+COUNT(Id)+FROM+Opportunity+WHERE+StageName+=+\'Closed+Won\'+AND+CampaignId+=+'+'\''+CampaignId+'\'';
       
        if(string.isnotblank(CollaboratoreId))
            query+='+AND+CreatedById+='+'\''+CollaboratoreId+'\'';

        if(String.isNotBlank(CodiceAgenzia))
        {

            query+='+AND+Account.AAI_Agency_Reference_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';  
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Account.AAI_Agency_Reference_Code__c+in+'+age;                                  
        }

        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
    @AuraEnabled
    public static String OpportunitaVinteClientiPrioritari(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();

        String query='SELECT+COUNT(Id)+FROM+Opportunity+WHERE+StageName+=+\'Closed+Won\'+AND+Id+IN+(SELECT+Campaign_member_related_Opportunity__c+FROM+CampaignMember+WHERE+Sottostato__c+IN+(\'Richiesta+di+contatto+da+Email\',\'Richiesta+di+contatto+da+SMS\'))+AND+CampaignId+=+'+'\''+CampaignId+'\'';
       
        if(string.isnotblank(CollaboratoreId))
            query+='+AND+CreatedById+='+'\''+CollaboratoreId+'\'';

        if(String.isNotBlank(CodiceAgenzia))
        {

            query+='+AND+Account.AAI_Agency_Reference_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';  
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Account.AAI_Agency_Reference_Code__c+in+'+age;                                  
        }

        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
    @AuraEnabled
    public static String RevenueOpportunitaVinte(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();

        String query='SELECT+SUM(Amount)+FROM+Opportunity+WHERE+StageName+=+\'Closed+Won\'+AND+CampaignId+=+'+'\''+CampaignId+'\'';
       
        if(string.isnotblank(CollaboratoreId))
            query+='+AND+CreatedById+='+'\''+CollaboratoreId+'\'';

        if(String.isNotBlank(CodiceAgenzia))
        {

            query+='+AND+Account.AAI_Agency_Reference_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';  
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Account.AAI_Agency_Reference_Code__c+in+'+age;                                  
        }

        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
    @AuraEnabled
    public static String OpportunitaIncorso(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();

        String query='SELECT+COUNT(Id)+FROM+Opportunity+WHERE+StageName+IN+(\'Open\',\'Proposal+Made\')+AND+CampaignId+=+'+'\''+CampaignId+'\'';
       
        if(string.isnotblank(CollaboratoreId))
            query+='+AND+CreatedById+='+'\''+CollaboratoreId+'\'';

        if(String.isNotBlank(CodiceAgenzia))
        {

            query+='+AND+Account.AAI_Agency_Reference_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';  
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Account.AAI_Agency_Reference_Code__c+in+'+age;                                  
        }

        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
     @AuraEnabled
    public static String RevenueOpportunitaInCorso(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();

        String query='SELECT+SUM(Amount)+FROM+Opportunity+WHERE+StageName+IN+(\'Open\',\'Proposal+Made\')+AND+CampaignId+=+'+'\''+CampaignId+'\'';
       
        if(string.isnotblank(CollaboratoreId))
            query+='+AND+CreatedById+='+'\''+CollaboratoreId+'\'';

        if(String.isNotBlank(CodiceAgenzia))
        {

            query+='+AND+Account.AAI_Agency_Reference_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';  
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Account.AAI_Agency_Reference_Code__c+in+'+age;                                  
        }

        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
    @AuraEnabled
    public static String EmailSMSrecapitati(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();

        String query='SELECT+COUNT(Id)+FROM+CampaignMember+WHERE+Sottostato__c+IN+(\'Inviata+Email\',\'Inviato+SMS\',\'Aperta+Email\',\'Aperto+SMS\',\'Richiesta+di+contatto+da+Email\',\'Richiesta+di+contatto+da+SMS\')+AND+CampaignId+=+'+'\''+CampaignId+'\'';
       
        if(string.isnotblank(CollaboratoreId))
            query+='+AND+Owner__r.Id+='+'\''+CollaboratoreId+'\'';

        if(String.isNotBlank(CodiceAgenzia))
        {
            query+='+AND+Agency_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Agency_Code__c+in+'+age;
        }
      
        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
    @AuraEnabled
    public static String ClientiConEmailSMSInTarget(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();

        String query='SELECT+COUNT(Id)+FROM+CampaignMember+WHERE+Sottostato__c+IN+(\'Inviata+Email\',\'Inviato+SMS\',\'Aperta+Email\',\'Aperto+SMS\',\'Richiesta+di+contatto+da+Email\',\'Richiesta+di+contatto+da+SMS\',\'SMS+non+recapitabile\',\'Email+non+recapitabile\')+AND+CampaignId+=+'+'\''+CampaignId+'\'';
       
        if(string.isnotblank(CollaboratoreId))
            query+='+AND+Owner__r.Id+='+'\''+CollaboratoreId+'\'';

        if(String.isNotBlank(CodiceAgenzia))
        {
            query+='+AND+Agency_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Agency_Code__c+in+'+age;
        }
      
        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
    @AuraEnabled
    public static String EmailSMSNonRecapitabili(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();

        String query='SELECT+COUNT(Id)+FROM+CampaignMember+WHERE+((MobilePhone+<>+Null+AND+Sottostato__c+=+\'SMS+non+recapitabile\')+OR+(Email+<>+Null+AND+Sottostato__c+=+\'Email+non+recapitabile\'))+AND+CampaignId+=+'+'\''+CampaignId+'\'';
        
        if(string.isnotblank(CollaboratoreId))
            query+='+AND+Owner__r.Id+='+'\''+CollaboratoreId+'\'';

        if(String.isNotBlank(CodiceAgenzia))
        {
            query+='+AND+Agency_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Agency_Code__c+in+'+age;
        }

        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
    @AuraEnabled
    public static String ClientiConEmailInTarget(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();
        String query = 'SELECT+COUNT(Id)+FROM+CampaignMember+WHERE+Email+<>+Null+AND+Sottostato__c+IN+(\'Inviata+Email\',\'Aperta+Email\',\'Richiesta+di+contatto+da+Email\')+AND+CampaignId+=+'+'\''+CampaignId+'\'';
        
        if(string.isnotblank(CollaboratoreId))
            query+='+AND+Owner__r.Id+='+'\''+CollaboratoreId+'\'';

        if(String.isNotBlank(CodiceAgenzia))
        {
            query+='+AND+Agency_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Agency_Code__c+in+'+age;
        }

        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
    @AuraEnabled
    public static String ClientiEmailApertaRichiestaContatto(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();
        String query='SELECT+COUNT(Id)+FROM+CampaignMember+WHERE+Email+<>+Null+AND+Sottostato__c+IN+(\'Aperta+Email\',\'Richiesta+di+contatto+da+Email\')+AND+CampaignId+=+'+'\''+CampaignId+'\'';
        if(string.isnotblank(CollaboratoreId))
            query+='+AND+Owner__r.Id+='+'\''+CollaboratoreId+'\'';

        if(String.isNotBlank(CodiceAgenzia))
        {
            query+='+AND+Agency_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';
        }
        else if(AgencyList.size()>0) 
        {
           String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Agency_Code__c+in+'+age;
        }

        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
    @AuraEnabled
    public static String ClientiConSMSInTarget(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();

        String query = 'SELECT+COUNT(Id)+FROM+CampaignMember+WHERE+MobilePhone+<>+Null+AND+Sottostato__c+IN+(\'Inviato+SMS\',\'Aperto+SMS\',\'Richiesta+di+contatto+da+SMS\')+AND+CampaignId+=+'+'\''+CampaignId+'\'';
        if(string.isnotblank(CollaboratoreId))
            query+='+AND+Owner__r.Id+='+'\''+CollaboratoreId+'\'';

        if(String.isNotBlank(CodiceAgenzia))
        {
            query+='+AND+Agency_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Agency_Code__c+in+'+age;
        }

        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
    @AuraEnabled
    public static String ClientiSMSApertoRichiestaContatto(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();
        String query='SELECT+COUNT(Id)+FROM+CampaignMember+WHERE+MobilePhone+<>+Null+AND+Sottostato__c+IN+(\'Aperto+SMS\',\'Richiesta+di+contatto+da+SMS\')+AND+CampaignId+=+'+'\''+CampaignId+'\'';
        
        if(string.isnotblank(CollaboratoreId))
            query+='+AND+Owner__r.Id+='+'\''+CollaboratoreId+'\'';

        if(String.isNotBlank(CodiceAgenzia))
        {
            query+='+AND+Agency_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Agency_Code__c+in+'+age;
        }

        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody(); 
        
    }
    
    @AuraEnabled
    public static String ClientiConEmailSMSAperti(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();

        String query='SELECT+COUNT(Id)+FROM+CampaignMember+WHERE+((MobilePhone+<>+Null+AND+Sottostato__c+=+\'Aperto+SMS\')+OR+(Email+<>+Null+AND+Sottostato__c+=+\'Aperta+Email\'))+AND+CampaignId+=+'+'\''+CampaignId+'\'';

        if(string.isnotblank(CollaboratoreId)){
            query+='+AND+Owner__r.Id+='+'\''+CollaboratoreId+'\'';
        }


        if(String.isNotBlank(CodiceAgenzia))
        {
            query+='+AND+Agency_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Agency_Code__c+in+'+age;
        }
            
        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody(); 
        
    }
    
    @AuraEnabled
    public static String ClientiPrioritariEmail(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();

        String query = 'SELECT+COUNT(Id)+FROM+CampaignMember+WHERE+Email+<>+Null+AND+(Sottostato__c+=+\'Richiesta+di+contatto+da+Email\')+AND+CampaignId+=+\''+CampaignId+'\'';

        if(string.isnotblank(CollaboratoreId))
            query+='+AND+Owner__r.Id+='+'\''+CollaboratoreId+'\'';
       
        if(String.isNotBlank(CodiceAgenzia))
        {
            query+='+AND+Agency_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Agency_Code__c+in+'+age;
        }

        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
    @AuraEnabled
    public static String ClientiPrioritariSMS(String CampaignId,String CollaboratoreId,String CodiceAgenzia,String PartnerUrl,String SessionId,List<String>AgencyList){
        //String SessionId = fetchUserSessionId();

        String query = 'SELECT+COUNT(Id)+FROM+CampaignMember+WHERE+MobilePhone+<>+Null+AND+Sottostato__c+=+\'Richiesta+di+contatto+da+SMS\'+AND+CampaignId+=+'+'\''+CampaignId+'\'';

        if(string.isnotblank(CollaboratoreId))
            query+='+AND+Owner__r.Id+='+'\''+CollaboratoreId+'\'';
       
        if(String.isNotBlank(CodiceAgenzia))
        {
            query+='+AND+Agency_Code__c+='+'\''+CodiceAgenzia.trim()+'\'';
        }
        else if(AgencyList.size()>0)
        {
            String age = '';

            for(String ag: AgencyList)
            {
                if(String.isBlank(age))
                           age+=ag.trim();
                else
                    age+=','+ag.trim();
            }

            age = '('+age+')';

            system.debug('age :'+age);
           query+='+AND+Agency_Code__c+in+'+age;
        }

        HTTP h = new HTTP();
        
        HTTPRequest req = new HTTPRequest();     
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + SessionId);
        req.setTimeout(120000);
        if(Network.communitiesLanding() <> null)
        {
            req.setEndpoint(((Network.communitiesLanding()).geturl()).replace('home/home.jsp','services/data/v41.0/query/?q='+query));
        }
        else
        {
            req.setEndpoint((PartnerUrl.replace('--c.','.')).replace('visual.force','my.salesforce')+'/services/data/v41.0/query/?q='+query);
        }         resp = h.send(req);
        System.debug('#### Response Status '+resp.getStatus());
        System.debug('#### Response Status Code '+resp.getStatusCOde());
        System.debug(resp.getBody());
        return resp.getBody();
        
        
    }
    
    @AuraEnabled
          public static Map<String, String>  getUserInfos() { 
          String UserId=UserInfo.GetUserId();
          User CurrentUser = new User();
          CurrentUser=[SELECT Profile.Name FROM User WHERE Id=:UserId Limit 1];
                 
          Map<String, String> userinfomap = new Map<String,String>();
              
              string UserProfile = CurrentUser.Profile.Name;
              

              userinfomap.put('UserProfile', UserProfile);
              

          return userinfomap;
}
    
    
    

    @AuraEnabled
      public static List<CampaignMember> getCollaboratori(String CampaignId,String CodiceAgenzia,String UserRole) 
      {         
          List<CampaignMember>ListCollaboratori = new List<CampaignMember>();
          Set<String>CollID = new Set<String>();

          String queryS = 'Select Owner__r.Id, Owner__r.Name from CampaignMember where Owner__r.isActive=true and CampaignId='+'\''+CampaignId+'\'';

          if(String.isNotBlank(CodiceAgenzia))
          {
             queryS+=' and Agency_Code__c='+'\''+CodiceAgenzia.trim()+'\'';

             String lowerRole =UserRole.toLowerCase();

             if(String.isNotBlank(UserRole) && !lowerRole.contains('responsabile'))
                queryS+=' and Owner__r.Id='+'\''+UserInfo.getUserId()+'\'';
          } 

          system.debug('##query: '+queryS);
         
          for(CampaignMember cm:Database.query(queryS))
          {
            if(String.isNotBlank(cm.Owner__r.name) && String.isNotBlank(cm.Owner__r.Id) && !CollId.contains(cm.Owner__r.id))
            {
                ListCollaboratori.add(cm);
                CollID.add(cm.Owner__r.Id);
            }
          }
       	system.debug('##Collaboratori: '+ListCollaboratori + CollID); 
        ListCollaboratori.sort();
        return ListCollaboratori ;
     } 



    @AuraEnabled
      public static Map<String,String> getAgencyValues() 
      {         
        Map<String,String> MapAgencyValues = new  Map<String,String>();
        Set<String> FoundAgencies = new Set<String>();

        for(Account acc : [SELECT Id,Name, Agency_Code__c,RSAC_Description_Code__c, RSA_Description_Code__c FROM Account where Recordtype.DeveloperName='Agency' AND Active__c=true AND RSAC_Description_Code__c!='' AND RSA_Description_Code__c!=''])
        {
            if(!FoundAgencies.contains(acc.Agency_Code__c))
            {
                MapAgencyValues.put('Area|'+acc.RSAC_Description_Code__c,acc.RSAC_Description_Code__c);
                MapAgencyValues.put('Sales|'+acc.RSA_Description_Code__c,acc.RSA_Description_Code__c);
                MapAgencyValues.put('Agency|'+acc.Agency_Code__c+' - '+acc.Name,acc.Agency_Code__c);
                MapAgencyValues.put('Map|'+acc.RSAC_Description_Code__c+'_'+acc.RSA_Description_Code__c+'_'+acc.Agency_Code__c+' - '+acc.Name,acc.RSAC_Description_Code__c+'_'+acc.RSA_Description_Code__c+'_'+acc.Agency_Code__c+' - '+acc.Name);
                FoundAgencies.add(acc.Agency_Code__c);
            }
        }
  		system.debug('MapAgencyValues'+MapAgencyValues);		
        return MapAgencyValues ;
     }

 @AuraEnabled
     public static List<String> getAgencyCodes(String AM, String SM,String CodiceAgenzia)
     {
        List<String> AgencyList = new List<String>();
        Set<String> FoundAgencies = new Set<String>();

        String queryS = 'Select Agency_Code__c from Account where Recordtype.Name ='+'\''+'Agency'+'\'';

        if(String.isNotBlank(AM) || String.isNotBlank(SM) || String.isNotBlank(CodiceAgenzia))
        {
            if(String.isNotBlank(AM))
            {
                queryS+= ' and RSAC_Description_Code__c='+'\''+AM.trim()+'\'';
/*
                if(String.isNotBlank(SM))
                    queryS+=' and RSA_Description_Code__c='+'\''+SM+'\'';

                if(String.isNotBlank(CodiceAgenzia))
                    queryS+=' and Agency_Code__c='+'\''+CodiceAgenzia.trim()+'\'';
*/
            }
            //else if(String.isNotBlank(SM))
            if(String.isNotBlank(SM))
                queryS+=' and RSA_Description_Code__c='+'\''+SM.trim()+'\'';
            
            if(String.isNotBlank(CodiceAgenzia))
                queryS+=' and Agency_Code__c='+'\''+CodiceAgenzia.trim()+'\'';

            system.debug('##queryS: '+queryS);

            for(Account a: Database.query(queryS))
            {
                if(!AgencyList.contains(a.Agency_Code__c))
                {
                    FoundAgencies.add(a.Agency_Code__c);
                    AgencyList.add('\''+a.Agency_Code__c+'\'');
                }
            }
        }
        return AgencyList;
     }

     @AuraEnabled
     public static Map<String,String> getPageValues()
     {
        Map<String,String> PageValMap = new Map<String,String>();


        String UserID = UserInfo.getUserId();

        String PartnerUrl='';

        PartnerUrl=[SELECT Value__c FROM AAI_Code_Variables__c WHERE Name = 'CampaignKPI' limit 1].Value__c;

        Boolean isStandardUser = true;
        String UserAgency = '';
        String UserRole = '';
        String UserProfile='';
        String UserName = '';
         
        

        User CurrentUser = [Select Name,Agency_Code__c,UserRole.name,Profile.Name from User where id=:UserID];

        if(UserInfo.getUserType()<>'Standard')
        {   
            isStandardUser = false;
        }  
        
        UserAgency = (String.isNotBlank(CurrentUser.Agency_Code__c))?CurrentUser.Agency_Code__c:'';
        UserRole = (String.isNotBlank(CurrentUser.UserRole.name))?CurrentUser.UserRole.name:'';
        UserProfile =  (String.isNotBlank(CurrentUser.Profile.Name))?CurrentUser.Profile.Name:'';  
        UserName = (String.isNotBlank(CurrentUser.Name))?CurrentUser.Name:''; 

        PageValMap.put('sessionId',UserInfo.getSessionId());
        PageValMap.put('PartnerUrl',PartnerUrl);
        PageValMap.put('isStandardUser',(isStandardUser)?'true':'false');
        PageValMap.put('UserAgency',UserAgency);
        PageValMap.put('UserRole',UserRole);   
        PageValMap.put('UserProfile',UserProfile);
        PageValMap.put('UserId',UserID);  
        PageValMap.put('UserName',UserName);
       
        system.debug('getPageValues'+PageValMap);

        return PageValMap;
     }


    

}
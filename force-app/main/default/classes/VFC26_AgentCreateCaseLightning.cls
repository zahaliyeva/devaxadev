/*
************************************************************************************************************
------------------------------------------------------------------------------------------------------------
-- - Name          : VFC26_AgentCreateCaseLightning
-- - Author        : Marco Moscatelli
-- - Description   : Custom controller used by the visualforce page VFP26_AgentCreateCaseLightning 
-- -                 to execute all the logics related to the usage of the lightning component CreateCaseCmp
--
-- Maintenance History:
--
-- Date          Version  Remarks
-- -----------  -------  ------------------------------------------------------------------------------------
-- 16-08-2018   1.0     
-------------------------------------------------------------------------------------------------------------
*************************************************************************************************************
*/
public with sharing class VFC26_AgentCreateCaseLightning 
{
    public boolean jsDebug{get;set;}
    public Static Set<String> LobSet;
    public Static List<String> LobList;
    public Static List<String> CategoriesList;
    public Static String CaseRT;  

    public VFC26_AgentCreateCaseLightning() 
    {

    }

    public class CharacteristicsPicklist
    {
        @AuraEnabled public List<String> Category;
        @AuraEnabled public List<String> SubCategory;
        @AuraEnabled public List<String> Lob;
        @AuraEnabled public Boolean DisableSubCat;
        @AuraEnabled public List<String> Lob_Cat_subCat_details;
        @AuraEnabled public String ButtonId;
        @AuraEnabled public Boolean ShowTTP8Error;
        @AuraEnabled public Map<String,Boolean> LobAvailable;
        @AuraEnabled public String CaseType;
        @AuraEnabled public String OrgId;
        @AuraEnabled public String AgentId;
        @AuraEnabled public User AgentInfos;
        @AuraEnabled public String Theme;
        @AuraEnabled public String Chat_deploymentId;
        @AuraEnabled public String Chat_deploymentUrl;
        @AuraEnabled public String Chat_Endpoint;        

        public CharacteristicsPicklist()
        {
            this.Category = new List<String>();
            this.SubCategory = new List<String>();
            this.Lob = new List<String>();
            this.DisableSubCat = false;
            this.Lob_Cat_subCat_details = new List<String>();
            this.ButtonId='';
            this.ShowTTP8Error = false;
            this.LobAvailable = new Map<String,Boolean>();
            this.CaseType='';
            this.OrgId='';
            this.AgentId='';
            this.AgentInfos = new User();
            this.Theme = '';
            this.Chat_deploymentUrl = '';
            this.Chat_Endpoint = '';
            this.Chat_deploymentId = '';
        }
    }

    public class CreateCaseResult
    {
        @AuraEnabled public String CaseId;
        @AuraEnabled public String ResultStatus;
        @AuraEnabled public String ResultMsg;

        public CreateCaseResult()
        {
            this.CaseId='';
            this.ResultStatus='';
            this.ResultMsg='';
        }
    }

    @AuraEnabled
    public Static CharacteristicsPicklist SetPicklistInitialValues()
    {
        CharacteristicsPicklist Cpick = new CharacteristicsPicklist();
        LobSet = new Set<String>();
        LobList = new List<String>();
        Set<String> NotAvailableLobs = new Set<String>();
        Cpick.LobAvailable.clear();
		
        List<Modello_di_Assistenza__mdt> listaMDA = [Select Lob__c, Categoria__c, Sotto_Categoria__c, Dettaglio__c,Gestito_con_TTP8__c,Id_Bottone_Chat__c,CRMAgenzieChatButtonId__c,Record_type_name__c from Modello_di_Assistenza__mdt where DeveloperName like 'Lob%' order by Gestito_con_TTP8__c desc];
            
        for(Modello_di_Assistenza__mdt Ma:listaMDA){

            System.debug('VFC26_AgentCreateCaseLightning.SetPicklistInitialValues Site Name:' + Site.getName());
            System.debug('VFC26_AgentCreateCaseLightning.SetPicklistInitialValues Network Id: ' + Network.getNetworkId());
            if(Site.getName() != null  && Site.getName().containsIgnoreCase('CRM_Agenzie')){
                Cpick.Lob_Cat_subCat_details.add(Ma.Record_type_name__c+'$'+Ma.Lob__c+'$'+Ma.Categoria__c+'$'+Ma.Sotto_Categoria__c+'$'+Ma.CRMAgenzieChatButtonId__c+'$'+Ma.Dettaglio__c);   
            } else {
                Cpick.Lob_Cat_subCat_details.add(Ma.Record_type_name__c+'$'+Ma.Lob__c+'$'+Ma.Categoria__c+'$'+Ma.Sotto_Categoria__c+'$'+Ma.Id_Bottone_Chat__c+'$'+Ma.Dettaglio__c);
            }
            if(Ma.Gestito_con_TTP8__c)
                NotAvailableLobs.add(Ma.Lob__c);

            if(!Cpick.LobAvailable.containskey(Ma.Lob__c))
                Cpick.LobAvailable.put(Ma.Lob__c,true);

            LobSet.add(Ma.Lob__c);
        }

        for(String s :NotAvailableLobs)
        {
            Cpick.LobAvailable.put(s,false);
        }

        for(MPS_Code_Variables__c ChatConfig : [Select Name, Value__c from MPS_Code_Variables__c where Name in ('ModelloAssistenzaConfigCHAT1','ModelloAssistenzaConfigCHAT2','ModelloAssistenzaConfigCHAT3')])
        {
            if(ChatConfig.Name=='ModelloAssistenzaConfigCHAT1')
                Cpick.Chat_deploymentId = ChatConfig.Value__c;
            else if(ChatConfig.Name=='ModelloAssistenzaConfigCHAT2')
                Cpick.Chat_deploymentUrl = ChatConfig.Value__c;
            else if(ChatConfig.Name=='ModelloAssistenzaConfigCHAT3')
                Cpick.Chat_Endpoint = ChatConfig.Value__c;   
        }

        Cpick.Lob.addAll(LobSet);
        Cpick.Lob.sort();
        LobList.addAll(LobSet);
        Cpick.OrgId = String.valueOf(UserInfo.getOrganizationId()).substring(0,15);
        Cpick.AgentId = String.valueOf(UserInfo.getUserId()).substring(0,15);

        List<User> UserList = new List<User>();
        UserList = [Select Id, Agency_Code__c, Name, Email from User where id=:UserInfo.getUserId()];
        Cpick.AgentInfos = UserList[0];

        Cpick.Theme = UserInfo.getUiThemeDisplayed();

        system.debug('@@LobAvailable: '+Cpick.LobAvailable);
        system.debug('@@LobList: '+Cpick.Lob);
        system.debug('@@Lob_Cat_subCat_details: '+Cpick.Lob_Cat_subCat_details);

        return Cpick;
    }

    @AuraEnabled
    public Static CharacteristicsPicklist ChangeDisplayedCategories(String Selected_Lob, String Cpick)
    {
        Set<String> CategorySet = new Set<String>();
        system.debug(Cpick);
        CharacteristicsPicklist Cpick_1 = (CharacteristicsPicklist)JSON.deserialize(Cpick, CharacteristicsPicklist.class);
        Cpick_1.ShowTTP8Error=false;

        List<String> LobToCat = Cpick_1.Lob_Cat_subCat_details;
        Map<String,Boolean> LobAvailable =  Cpick_1.LobAvailable;
        Cpick_1.Category.clear();
        Cpick_1.SubCategory.clear();
        Cpick_1.DisableSubCat=false;

        if(LobAvailable.get(Selected_Lob))
        {
            for(String s: LobToCat)
            {
                system.debug('@@test: '+(s.substringAfter('$')).subStringBefore('$'));
                if((s.substringAfter('$')).subStringBefore('$') == Selected_Lob)
                {
                    if(s.contains(Selected_Lob))
                    {
                        system.debug('@@Selected_Lob: '+Selected_Lob);
                        system.debug('@@LobToCat: '+s);

                        String Category = (s.substringAfter(Selected_Lob+'$')).substringBefore('$');

                        system.debug('@@Category: '+Category);

                        if(Category <> 'null')
                            CategorySet.add(Category);
                    }
                }
            }

            if(CategorySet.size()>0)
            {
                Cpick_1.Category.addAll(CategorySet);
                Cpick_1.Category.sort();
            }
        }
        else
        {
            Cpick_1.ShowTTP8Error=true;
        }

        return Cpick_1;
    }

    @AuraEnabled
    public Static CharacteristicsPicklist ChangeDisplayedSub_Categories(String Selected_Lob, String Selected_Category, String Cpick)
    {
        Set<String> Sub_CategorySet = new Set<String>();
        CharacteristicsPicklist Cpick_1 = (CharacteristicsPicklist)JSON.deserialize(Cpick, CharacteristicsPicklist.class);
        Cpick_1.DisableSubCat = false;
        Cpick_1.SubCategory.clear();
        String CaseType = '';
        CaseRT = '';

        List<String> LobToCat = Cpick_1.Lob_Cat_subCat_details;

        for(String s: LobToCat)
        {           
            system.debug(s.substringBefore('$'));

            

            if(s.contains(CaseRT+'$'+Selected_Lob+'$'+Selected_Category))
            {
            CaseRT = s.substringBefore('$');

            CaseType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CaseRT).getRecordTypeId();

                String SubCat = (s.substringAfter(CaseRT+'$'+Selected_Lob+'$'+Selected_Category+'$')).substringBefore('$');

                if(String.isNotBlank(SubCat) && SubCat <> 'null')
                    Sub_CategorySet.add(SubCat);
            }
        }

        if(Sub_CategorySet.size()>0)
        {
            Cpick_1.SubCategory.addAll(Sub_CategorySet);
            Cpick_1.SubCategory.sort();
        }
        else
            Cpick_1.DisableSubCat=true;

        Cpick_1.CaseType = CaseType;
        
        return Cpick_1;
    }

    @AuraEnabled
    public Static CharacteristicsPicklist SelectChatButtonId(String Selected_Lob, String Selected_Category, String Selected_SubCategory, String Cpick)
    {
        CharacteristicsPicklist Cpick_1 = (CharacteristicsPicklist)JSON.deserialize(Cpick, CharacteristicsPicklist.class);
        String ButtonId ='';
        List<String> LobToCat = Cpick_1.Lob_Cat_subCat_details;

        for(String s: LobToCat)
        {
            system.debug(s);
            system.debug(s.substringAfter(Selected_Lob+'$'+Selected_Category+'$'+Selected_SubCategory+'$'));

            if(s.contains(Selected_Lob+'$'+Selected_Category+'$'+Selected_SubCategory+'$'))
            {
                ButtonId= (s.substringAfter(Selected_Lob+'$'+Selected_Category+'$'+Selected_SubCategory+'$')).substringBefore('$');
            }
        }

        if(ButtonId <> 'null')
            Cpick_1.ButtonId =  ButtonId;
        else
            Cpick_1.ButtonId = '';

        return Cpick_1;
    }
    
     @AuraEnabled
    public static Id getCaringSaluteRT()
    {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('AXA_Caring_Salute').getRecordTypeId();
        
    }

    @AuraEnabled
    public static CreateCaseResult CreateCase(Case NewCase)
    {
        system.debug('@@Case: '+NewCase);
        List<Case> CaseList = new List<Case>();
        CreateCaseResult Ccr = new CreateCaseResult(); 
        
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];

         //*-+ 16-11-2021 Il account scelto è relazionatto con quella polizza ??? */     

        if(String.isNotBlank((String)NewCase.get('AccountId')) && String.isNotBlank((String)NewCase.get('LinkToPolicy__c'))){ 
           // list <InsurancePolicy__c> polizzas = [select id,CUID__c from InsurancePolicy__c where CUID__c != null];
            list <InsurancePolicy__c> polizzas = [select id,CUID__c from InsurancePolicy__c where CUID__c =: (id)NewCase.get('AccountId') and id =:(id)NewCase.get('LinkToPolicy__c')];
        
            if(polizzas.isEmpty()){ 
                System.debug('Non relazionato Account con Polizza ');
                Ccr.ResultMsg ='Cliente non relazionato con la Polizza';
                Ccr.ResultStatus ='KO';
                return Ccr ;
            }
        }
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;                               

        NewCase.Status='Open';
        NewCase.Origin='Portale Assistenza';
        NewCase.Complainant__c='Agente';
        NewCase.Distribution_Network__c='Axa Assicurazioni';
        NewCase.Internal_LOB__c = NewCase.LOB__c;
        NewCase.Internal_Category__c = NewCase.Category__c;
        NewCase.Internal_SubCategory__c = NewCase.SubCategory__c;
        NewCase.setOptions(dmlOpts);
       
        CaseList.add(NewCase);
        
        Database.SaveResult[] srList = Database.insert(CaseList, false);
        
        for (Database.SaveResult sr : srList) 
        {
            if (sr.isSuccess()) 
            {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted case. Case ID: ' + sr.getId());
                Ccr.CaseId = sr.getId();
                Ccr.ResultStatus ='OK';
            }
            else 
            {
            // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) 
                {               
                    System.debug('The following error has occurred.');  
                    Ccr.ResultMsg = err.getMessage();
                    Ccr.ResultStatus ='KO';                   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Case fields that affected this error: ' + err.getFields());
                }
            }
        }
        return Ccr;
    }
/*
    @AuraEnabled
    public static void CreateAttachments (List<String> AttList, String CaseId,Map<String,String> AttMap)
    {
        system.debug('@@CreateAttachments:'+ AttList);
        List<Attachment> UploadList = new List<Attachment>();

        for(String s: AttList)
        {
            String FileName = s.substringBefore('VFC26');
            String FileType = s.substringAfter('VFC26');

            Attachment att = new Attachment();
            att.parentid=CaseId;
            
            
            att.Name = FileName;
            String FileBody = AttMap.get(FileName);
            FileBody = EncodingUtil.urlDecode(FileBody, 'UTF-8');
            att.Body = EncodingUtil.base64Decode(FileBody);
            att.ContentType = FileType;
            UploadList.add(att);
        }

        system.debug('@@UploadList: '+UploadList);

        Database.SaveResult[] srList = Database.insert(UploadList, false);
    }*/
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId)
    {
        if (fileId == '') 
        {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else 
        {
            appendToFile(fileId, base64Data);
        }
 
        return Id.valueOf(fileId);
    }
 
    public static String saveTheFile(Id parentId, String fileName, String base64Data, String contentType)
    {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
 
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
 		AP_Constants.blockAttachmentInsert = false;
        insert oAttachment;
 
        return oAttachment.Id;
    }  

    private static void appendToFile(Id fileId, String base64Data)
    {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];

        String existingBody = EncodingUtil.base64Encode(a.Body);

        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);

        update a;
    }

    
    //metodo utilizzato nel createCase LWC
    @AuraEnabled
    public static void saveFiles(String filesToInsert, Id parentId){
    if(String.isNotEmpty(filesToInsert) && String.isNotEmpty(parentId)){      
            List<FileInfo> listFiles =  (List<FileInfo>) System.JSON.deserialize(filesToInsert, List<FileInfo>.class);
            List <Attachment> lstAttachments = new List <Attachment> ();
        
            for (FileInfo f : listFiles){
                Attachment iAttachment = new Attachment();
                iAttachment.parentId = parentId; 
                iAttachment.Body = f.VersionData;
                iAttachment.Name = f.Title;
                iAttachment.ContentType = f.Type;

                lstAttachments.add(iAttachment);
            }
            list<Database.saveResult> res = Database.insert(lstAttachments,false);
       }
        
    } 

    public class FileInfo {
        public String Title {get; set;}      
        public Blob VersionData {get; set;}
        public String Type {get; set;}
		public Integer Size {get; set;}  
    }
}
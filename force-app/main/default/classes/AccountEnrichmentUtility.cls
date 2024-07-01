/*------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         AccountEnrichmentUtility
Description:   Apex class used to execute all the logics related to the 
               Campaign Enrichment process

History

31/07/2017     Created - Marco Moscatelli.
----------------------------------------------------------------------------*/
public with sharing class AccountEnrichmentUtility 
{
    public static DefineOutputs CheckEnrichment(String CampaignId, Account accountToSave, String CampMemberId) 
    {
        DefineOutputs Out = new DefineOutputs();

        String AccountRT = accountToSave.Recordtype.Name;

        Campaign Camp = [Select Data_Enrichment_Target_Consensus__c,Data_Enrichment_Target_Email__c,Data_Enrichment_Target_Other__c,Data_Enrichment_Target_Phone__c from Campaign where id=:CampaignId];
        CampaignMember CampMemb = [Select Data_Enrichment_Target_Consensus__c,Data_Enrichment_Target_Email__c,Data_Enrichment_Target_Other__c,Data_Enrichment_Target_Phone__c from CampaignMember where id=:CampMemberId];
        
        List<String> ReqEnrichmentField = new list<String>();
        List<String> ReqEnrichmentFieldTelefono = new list<String>();
        List<String> ReqEnrichmentFieldEmail = new list<String>();
        Map<String,String> MapFieldToControlling = new Map<String,String>();
        Map<String,Boolean> CheckedMap = new Map<String,Boolean>();
        Map<String,String> MapFieldToExpValue = new Map<String,String>();
        Set<String> ModifiedFields = new Set<String>();
        Set<String> NotModifiedFields = new Set<String>();
        Set<String> ModifiedFieldsEmail = new Set<String>();
        Set<String> ModifiedFieldsPhone = new Set<String>();
        Set<String> ToBeCheckeSet = new Set<String>();
        //List<EnrichmentCampaignReqField__c> ECRF_All = new List<EnrichmentCampaignReqField__c>();
        List<EnrichmentCampaignReqField__c> ECRF_Telefono = new List<EnrichmentCampaignReqField__c>();
        List<EnrichmentCampaignReqField__c> ECRF_Email = new List<EnrichmentCampaignReqField__c>();
        List<EnrichmentCampaignReqField__c> ECRF_Consensi = new List<EnrichmentCampaignReqField__c>();
        List<EnrichmentCampaignReqField__c> ECRF_AltriDati = new List<EnrichmentCampaignReqField__c>();

        List<EnrichmentCampaignReqField__c> ECRF_All = [SELECT Name, AccountRT__c, ControllingField__c, ExpectedValue__c, Field__c,Trace_on_Member__c FROM EnrichmentCampaignReqField__c ORDER BY Name];

        //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement--START
        Map<String,Boolean>TraceOnMemberMap = new Map<String,Boolean>();        
        Boolean TraceOnMember_Email = false;
        Boolean TraceOnMember_Other = false;
        Boolean TraceOnMember_Phone = false;
        Boolean TraceOnMember_Consensus = false;
        //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement--END

        for(EnrichmentCampaignReqField__c ECRF: ECRF_All)
        {
            if(ECRF.Name.contains('Phone'))
            {
                ECRF_Telefono.add(ECRF);
            }
            if(ECRF.Name.contains('Email'))
            {
                ECRF_Email.add(ECRF);
            }
            if(ECRF.Name.contains('Consensi'))
            {
                ECRF_Consensi.add(ECRF);
            }
            if(ECRF.Name.contains('Altro'))
            {
                ECRF_AltriDati.add(ECRF);
            }
        }
        
        String type='Account';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        String QueryS = '';
        Integer count = 0;

        if(Camp.Data_Enrichment_Target_Consensus__c && !CampMemb.Data_Enrichment_Target_Consensus__c)
            ToBeCheckeSet.add('Data_Enrichment_Target_Consensus__c');

        if(Camp.Data_Enrichment_Target_Email__c && !CampMemb.Data_Enrichment_Target_Email__c)
            ToBeCheckeSet.add('Data_Enrichment_Target_Email__c');

        if(Camp.Data_Enrichment_Target_Other__c && !CampMemb.Data_Enrichment_Target_Other__c)
            ToBeCheckeSet.add('Data_Enrichment_Target_Other__c');

        if(Camp.Data_Enrichment_Target_Phone__c && !CampMemb.Data_Enrichment_Target_Phone__c)
            ToBeCheckeSet.add('Data_Enrichment_Target_Phone__c');  

        for(EnrichmentCampaignReqField__c ecrfr: ECRF_Telefono)
        {
            if(ecrfr.AccountRT__c == AccountRT)
            {
                if(String.isBlank(QueryS))
                    QueryS = ecrfr.Field__c;
                else
                    QueryS += ','+ecrfr.Field__c;

                ReqEnrichmentFieldTelefono.add(ecrfr.Field__c);

                MapFieldToControlling.put(ecrfr.Field__c,ecrfr.ControllingField__c);

                if(String.isNotBlank(ecrfr.ExpectedValue__c))
                    MapFieldToExpValue.put(ecrfr.Field__c, ecrfr.ExpectedValue__c);

                if(ToBeCheckeSet.contains(ecrfr.ControllingField__c))
                    CheckedMap.put(ecrfr.Field__c,false);

                TraceOnMemberMap.put(ecrfr.Field__c,ecrfr.Trace_on_Member__c);//MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement

                count++;
            }
        }

        system.debug('********************ReqEnrFieldTelefono'+ReqEnrichmentFieldTelefono);

            
        for(EnrichmentCampaignReqField__c ecrfr: ECRF_Email)
        {
            if(ecrfr.AccountRT__c == AccountRT)
            {
                if(String.isBlank(QueryS))
                    QueryS = ecrfr.Field__c;
                else
                    QueryS += ','+ecrfr.Field__c;

                ReqEnrichmentFieldEmail.add(ecrfr.Field__c);

                MapFieldToControlling.put(ecrfr.Field__c,ecrfr.ControllingField__c);

                if(String.isNotBlank(ecrfr.ExpectedValue__c))
                    MapFieldToExpValue.put(ecrfr.Field__c, ecrfr.ExpectedValue__c);

                if(ToBeCheckeSet.contains(ecrfr.ControllingField__c))
                    CheckedMap.put(ecrfr.Field__c,false);

                TraceOnMemberMap.put(ecrfr.Field__c,ecrfr.Trace_on_Member__c);//MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement

                count++;
            }
        }

        system.debug('********************ReqEnrFieldEmail'+ReqEnrichmentFieldEmail);

        for(EnrichmentCampaignReqField__c ecrfc: ECRF_Consensi)
        {
            if(ecrfc.AccountRT__c == AccountRT)
            {
                if(String.isBlank(QueryS))
                    QueryS = ecrfc.Field__c;
                else
                    QueryS += ','+ecrfc.Field__c;

                ReqEnrichmentField.add(ecrfc.Field__c);

                MapFieldToControlling.put(ecrfc.Field__c,ecrfc.ControllingField__c);

                if(String.isNotBlank(ecrfc.ExpectedValue__c))
                    MapFieldToExpValue.put(ecrfc.Field__c, ecrfc.ExpectedValue__c);

                if(ToBeCheckeSet.contains(ecrfc.ControllingField__c))
                    CheckedMap.put(ecrfc.Field__c,false);

                TraceOnMemberMap.put(ecrfc.Field__c,ecrfc.Trace_on_Member__c);//MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement

                count++;
            }
        }

        system.debug('********************CheckedMap'+CheckedMap);

        for(EnrichmentCampaignReqField__c ecrfa: ECRF_AltriDati)
        {
            if(ecrfa.AccountRT__c == AccountRT)
            {
                if(String.isBlank(QueryS))
                    QueryS = ecrfa.Field__c;
                else
                    QueryS += ','+ecrfa.Field__c;

                ReqEnrichmentField.add(ecrfa.Field__c);

                MapFieldToControlling.put(ecrfa.Field__c,ecrfa.ControllingField__c);

                if(String.isNotBlank(ecrfa.ExpectedValue__c))
                    MapFieldToExpValue.put(ecrfa.Field__c, ecrfa.ExpectedValue__c);

                if(ToBeCheckeSet.contains(ecrfa.ControllingField__c))
                    CheckedMap.put(ecrfa.Field__c,false);

                TraceOnMemberMap.put(ecrfa.Field__c,ecrfa.Trace_on_Member__c);//MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement

                count++;
            }
        } 

        system.debug('********************ReqEnrField'+ReqEnrichmentField);                                

       system.debug(accountToSave.Id);
       system.debug ('****theQuery: '+'Select '+QueryS+' from Account where Id =\''+accountToSave.Id+'\' ');
       
       if(String.isBlank(QueryS))
            QueryS = 'Id';       
       
       Account OUTACCOUNT = Database.Query('Select '+QueryS+' from Account where Id =\''+accountToSave.Id+'\' ');
      
       
       for (integer i=0; i<ReqEnrichmentFieldTelefono.size(); i++)
       {
           
           string index = ReqEnrichmentFieldTelefono.get(i);
           
           system.debug('*******index ' + index);
           system.debug('*****OUTACCOUNT.get(index)'+OUTACCOUNT.get(index));
           system.debug('*****accountToSave.get(index)'+accountToSave.get(index));
           system.debug('******************MapFieldToExpValue'+MapFieldToExpValue);

            if (OUTACCOUNT.get(index) != accountToSave.get(index))
            {
                if(!((OUTACCOUNT.get(index) !='' && OUTACCOUNT.get(index) !=null) && (accountToSave.get(index) =='' || accountToSave.get(index)==null)))
                {   
                    if(MapFieldToExpValue.containsKey(index))
                    {
                        if((MapFieldToExpValue.get(index)).toLowerCase() == (String.valueOf(accountToSave.get(index))).toLowerCase())
                        {
                            ModifiedFieldsPhone.add(index);

                            //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- START
                            if(!TraceOnMember_Phone && TraceOnMemberMap.get(index))
                                TraceOnMember_Phone = true;
                            //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- END                                
                        }
                    }
                    else
                    {
                        ModifiedFieldsPhone.add(index);

                        //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- START
                        if(!TraceOnMember_Phone && TraceOnMemberMap.get(index))
                            TraceOnMember_Phone = true;
                        //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- END                           
                    }
                }        
            }   
        } 
                        
        if(ModifiedFieldsPhone.size()>0)
        {
            ModifiedFieldsPhone.addAll(ReqEnrichmentFieldTelefono);
        }

        system.debug('********************ModifiedFieldsPhone'+ModifiedFieldsPhone);                                

        for (integer i=0; i<ReqEnrichmentFieldEmail.size(); i++)
        {
           
           string index = ReqEnrichmentFieldEmail.get(i);
           
           system.debug('*******index ' + index);
           system.debug('*****OUTACCOUNT.get(index)'+OUTACCOUNT.get(index));
           system.debug('*****accountToSave.get(index)'+accountToSave.get(index));
           system.debug('******************MapFieldToExpValue'+MapFieldToExpValue);

            if (OUTACCOUNT.get(index) != accountToSave.get(index))
            {
                if(!((OUTACCOUNT.get(index) !='' && OUTACCOUNT.get(index) !=null) && (accountToSave.get(index) =='' || accountToSave.get(index)==null)))
                {   
                    if(MapFieldToExpValue.containsKey(index))
                    {
                        if((MapFieldToExpValue.get(index)).toLowerCase() == (String.valueOf(accountToSave.get(index))).toLowerCase())
                        {
                            ModifiedFieldsEmail.add(index);

                            //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- START
                            if(!TraceOnMember_Email && TraceOnMemberMap.get(index))
                                TraceOnMember_Email = true;
                            //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- END                                
                        }
                    }
                    else
                    {
                        ModifiedFieldsEmail.add(index);

                        //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- START
                        if(!TraceOnMember_Email && TraceOnMemberMap.get(index))
                            TraceOnMember_Email = true; 
                        //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- END                                                   
                    }
                }        
            }   
        }  
            
        if(ModifiedFieldsEmail.size()>0)
        {
        
            ModifiedFieldsEmail.addAll(ReqEnrichmentFieldEmail);
        } 

        system.debug('********************ModifiedFieldsEmail'+ModifiedFieldsEmail);                                


       
        system.debug('++++++'+ReqEnrichmentField);

        for (integer i=0; i<ReqEnrichmentField.size(); i++)
        {           
           string index = ReqEnrichmentField.get(i);
           
           system.debug('*******index ' + index);
           system.debug('*****OUTACCOUNT.get(index)'+OUTACCOUNT.get(index));
           system.debug('*****accountToSave.get(index)'+accountToSave.get(index));
           system.debug('******************MapFieldToExpValue'+MapFieldToExpValue);

            if (OUTACCOUNT.get(index) != accountToSave.get(index))
            {
                //if(!((OUTACCOUNT.get(index) !='' && OUTACCOUNT.get(index) !=null) && (accountToSave.get(index) =='' || accountToSave.get(index)==null)))
                //{   
                    if(MapFieldToExpValue.containsKey(index))
                    {
                        if((MapFieldToExpValue.get(index)).toLowerCase() == (String.valueOf(accountToSave.get(index))).toLowerCase())
                        {
                            ModifiedFields.add(index);

                            //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- START
                            if(MapFieldToControlling.get(index) == 'Data_Enrichment_Target_Consensus__c')
                            {                                
                                if(!TraceOnMember_Consensus && TraceOnMemberMap.get(index))
                                    TraceOnMember_Consensus = true;                                        
                            }
                            else if(MapFieldToControlling.get(index) == 'Data_Enrichment_Target_Other__c')
                            {

                                if(!TraceOnMember_Other && TraceOnMemberMap.get(index))
                                    TraceOnMember_Other = true;    
                            }
                            //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- END                            
                        }
                    }
                    else
                    {
                        ModifiedFields.add(index);

                        //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- START
                        if(MapFieldToControlling.get(index) == 'Data_Enrichment_Target_Consensus__c')
                        {
                            if(!TraceOnMember_Consensus && TraceOnMemberMap.get(index))
                                TraceOnMember_Consensus = true;    
                        }
                        else if(MapFieldToControlling.get(index) == 'Data_Enrichment_Target_Other__c')
                        {
                            if(!TraceOnMember_Other && TraceOnMemberMap.get(index))
                                TraceOnMember_Other = true;    
                        }
                        //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- END                             
                    }
                //}        
            }  
            else 
            {
                if (OUTACCOUNT.get(index) != null && OUTACCOUNT.get(index) != '' && accountToSave.get(index)!= null && accountToSave.get(index)!= '')
                {
                    if(MapFieldToExpValue.containsKey(index))
                    {
                    //system.debug('+++++++MapFieldToExpValueindex'+MapFieldToExpValue.get(index));
                        if((MapFieldToExpValue.get(index)).toLowerCase() == (String.valueOf(accountToSave.get(index))).toLowerCase())
                        {
                            NotModifiedFields.add(index);
                        }
                    }
                }
            }  
        }   

        system.debug('********************ModifiedFields'+ModifiedFields); 

        system.debug('********************NotModifiedFields'+NotModifiedFields);                                

        if(ModifiedFieldsPhone.size()>0)
        {
            for(String s:MapFieldToControlling.keySet())
            {
                if(ModifiedFieldsPhone.contains(s))
                {
                    if(ToBeCheckeSet.contains(MapFieldToControlling.get(s)))
                    {
                        CheckedMap.put(s,true);//per verificare se manca qualche campo obbligatorio
                    }
                    else
                    {
                        if(MapFieldToControlling.get(s) == 'Data_Enrichment_Target_Phone__c' && TraceOnMember_Phone)//MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement
                            Out.UpdatedPhone = true;                                                                                 
                    }
                }
            }
        }
        
        if(ModifiedFieldsEmail.size()>0)
        {
            for(String s:MapFieldToControlling.keySet())
            {
                if(ModifiedFieldsEmail.contains(s))
                {
                    if(ToBeCheckeSet.contains(MapFieldToControlling.get(s)))
                    {
                        CheckedMap.put(s,true);//per verificare se manca qualche campo obbligatorio
                    }
                    else
                    {
                        if(MapFieldToControlling.get(s) == 'Data_Enrichment_Target_Email__c' && TraceOnMember_Email)//MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement
                            Out.UpdatedEmail = true;                                                                                                      
                    }
                }
            }
        }

        if(NotModifiedFields.size()>0)
        {

            for(String s:MapFieldToControlling.keySet())
            {
                if(NotModifiedFields.contains(s))
                {
                   if(ToBeCheckeSet.contains(MapFieldToControlling.get(s)))
                    {
                        CheckedMap.put(s,true);//per verificare se manca qualche campo obbligatorio
                    }             
                }
            }
        }

        if(ModifiedFields.size()>0)
        {
            for(String s:MapFieldToControlling.keySet())
            {
                if(ModifiedFields.contains(s))
                {
                    if(ToBeCheckeSet.contains(MapFieldToControlling.get(s)))
                    {
                        CheckedMap.put(s,true);//per verificare se manca qualche campo obbligatorio
                    }
                    else
                    {
                        if(MapFieldToControlling.get(s) == 'Data_Enrichment_Target_Consensus__c' && TraceOnMember_Consensus)//MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement                        
                            Out.UpdatedConsensus = true;

                        if(MapFieldToControlling.get(s) == 'Data_Enrichment_Target_Email__c' && TraceOnMember_Email)//MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement
                            Out.UpdatedEmail = true;

                        if(MapFieldToControlling.get(s) == 'Data_Enrichment_Target_Other__c' && TraceOnMember_Other)//MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement
                            Out.UpdatedOthers = true;

                        if(MapFieldToControlling.get(s) == 'Data_Enrichment_Target_Phone__c' && TraceOnMember_Phone)//MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement
                            Out.UpdatedPhone = true;                                                                                
                    }
                }
            }
        }

        String MissingFields = '';

        for(String s : CheckedMap.keySet())
        {
            if(!CheckedMap.get(s))
            {
                if(String.isBlank(MissingFields))   
                {               
                    MissingFields = fieldMap.get(s).getDescribe().getLabel();

                    //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- START
                    if(TraceOnMemberMap.get(s))
                        Out.ListRelevantFields.add(fieldMap.get(s).getDescribe().getLabel());
                    else
                    //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- END
                        Out.ListFields.add(fieldMap.get(s).getDescribe().getLabel());
                }
                else
                {   
                    
                    MissingFields+=', '+fieldMap.get(s).getDescribe().getLabel();
                    //Out.ListFields.add(fieldMap.get(s).getDescribe().getLabel());

                    //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- START
                    if(TraceOnMemberMap.get(s))
                        Out.ListRelevantFields.add(fieldMap.get(s).getDescribe().getLabel());
                    else
                    //MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement -- END
                        Out.ListFields.add(fieldMap.get(s).getDescribe().getLabel());
                }
            }
            else
            {
                if(MapFieldToControlling.get(s) == 'Data_Enrichment_Target_Consensus__c' && TraceOnMember_Consensus)//MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement                        
                    Out.UpdatedConsensus = true;

                if(MapFieldToControlling.get(s) == 'Data_Enrichment_Target_Email__c' && TraceOnMember_Email)//MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement
                    Out.UpdatedEmail = true;

                if(MapFieldToControlling.get(s) == 'Data_Enrichment_Target_Other__c' && TraceOnMember_Other)//MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement
                    Out.UpdatedOthers = true;

                if(MapFieldToControlling.get(s) == 'Data_Enrichment_Target_Phone__c' && TraceOnMember_Phone)//MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement
                    Out.UpdatedPhone = true;     
            }
        }
        system.debug('these are missing MissingFields'+MissingFields);
        //if(String.isNotBlank(MissingFields))
        if(String.isNotBlank(MissingFields)){

            if (Out.ListRelevantFields.size()>0){
            Out.ErrorMsg = 'Non sono state modificate tutte le informazioni previste per la Campagna di Data Enrichment.';
        }
        }


        system.debug('UpdatedConsensus'+Out.UpdatedConsensus);    
        return Out;
    }


    public static void UpdateMember(Boolean isMail, Boolean isPhone, Boolean isConsensus, Boolean isOther, String CampMemberId)
    {
        Id currentUser = Userinfo.getUserId();
        CampaignMember CampMemb = new CampaignMember(Id = CampMemberId,Status='Lavorato',Owner__c=currentUser);

        if(isMail)
            CampMemb.Data_Enrichment_Target_Email__c = true;

        if(isPhone)
            CampMemb.Data_Enrichment_Target_Phone__c = true;

        if(isConsensus)
            CampMemb.Data_Enrichment_Target_Consensus__c = true;

        if(isOther)
            CampMemb.Data_Enrichment_Target_Other__c = true;    
            
        Database.SaveResult SaveResult = database.update (CampMemb,false);                  
    }

    public class DefineOutputs
    {
        public String errorMsg = '';
        public Boolean UpdatedEmail = false;
        public Boolean UpdatedPhone = false;
        public Boolean UpdatedConsensus = false;
        public Boolean UpdatedOthers = false;
        public List<String> ListFields = new List<String>();
        public List<String> ListRelevantFields = new List<String>();//MOSCATELLI_M 29/09/2017: Data Enrichment Enhancement
    }
}
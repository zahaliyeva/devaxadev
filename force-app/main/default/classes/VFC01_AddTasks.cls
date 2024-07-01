public class VFC01_AddTasks {
    /* 
------------------------------------------------------------
-- - Name          : VFC01_AddTasks 
-- - Author        : SC
-- - Description   : Apex controller for visualforce page VFP01_AddTasks

--
-- Maintenance History: 
--
-- Date         Name   Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 26-NOV-14     NAP    1.0    Initial version
-- 12-JAN-15     HDU    2.0    Create Standard Task Rather than custom obj Task__c
------------------------------------------------------------
*/ 
    
    public static Decimal calculateSLA(Map<String,Configurazione_SLA_Uffici_Tecnici__c> MapSLAConfigurations, String HierarchyLevel1, String HierarchyLevel2, String HierarchyLevel3, String CasRecTyp, String CustServModel, Boolean IsPrivate, Boolean isVIPCustomer)
    {
        system.debug('#Inputs: '+HierarchyLevel1+', '+HierarchyLevel2+', '+HierarchyLevel3+', '+CasRecTyp+', '+CustServModel+', '+IsPrivate+', '+isVIPCustomer);     

        String AllValues = 'All';
        String NullValues = null;
        
        Decimal SLA=0;
    
        if(MapSLAConfigurations.size()>0)
        {
            if(CustServModel!=NullValues && MapSLAConfigurations.containsKey(HierarchyLevel1+'-'+HierarchyLevel2+'-'+HierarchyLevel3+'-'+CasRecTyp+'-'+CustServModel))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    SLA = MapSLAConfigurations.get(HierarchyLevel1+'-'+HierarchyLevel2+'-'+HierarchyLevel3+'-'+CasRecTyp+'-'+CustServModel).SLA_for_Private_Customers__c;
                else
                    SLA = MapSLAConfigurations.get(HierarchyLevel1+'-'+HierarchyLevel2+'-'+HierarchyLevel3+'-'+CasRecTyp+'-'+CustServModel).SLA__c;
            }
            else if(CustServModel!=NullValues && MapSLAConfigurations.containsKey(HierarchyLevel1+'-'+HierarchyLevel2+'-'+HierarchyLevel3+'-'+AllValues+'-'+CustServModel))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    SLA = MapSLAConfigurations.get(HierarchyLevel1+'-'+HierarchyLevel2+'-'+HierarchyLevel3+'-'+AllValues+'-'+CustServModel).SLA_for_Private_Customers__c;
                else
                    SLA = MapSLAConfigurations.get(HierarchyLevel1+'-'+HierarchyLevel2+'-'+HierarchyLevel3+'-'+AllValues+'-'+CustServModel).SLA__c;
            }
            else if(CustServModel!=NullValues && MapSLAConfigurations.containsKey(AllValues+'-'+NullValues+'-'+NullValues+'-'+CasRecTyp+'-'+CustServModel))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    SLA = MapSLAConfigurations.get(AllValues+'-'+NullValues+'-'+NullValues+'-'+CasRecTyp+'-'+CustServModel).SLA_for_Private_Customers__c;
                else
                    SLA = MapSLAConfigurations.get(AllValues+'-'+NullValues+'-'+NullValues+'-'+CasRecTyp+'-'+CustServModel).SLA__c;
            }            
            else if(MapSLAConfigurations.containsKey(HierarchyLevel1+'-'+HierarchyLevel2+'-'+HierarchyLevel3+'-'+CasRecTyp+'-'+AllValues))
            {    
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    SLA = MapSLAConfigurations.get(HierarchyLevel1+'-'+HierarchyLevel2+'-'+HierarchyLevel3+'-'+CasRecTyp+'-'+AllValues).SLA_for_Private_Customers__c;
                else
                    SLA = MapSLAConfigurations.get(HierarchyLevel1+'-'+HierarchyLevel2+'-'+HierarchyLevel3+'-'+CasRecTyp+'-'+AllValues).SLA__c;
            }
            else if(MapSLAConfigurations.containsKey(HierarchyLevel1+'-'+HierarchyLevel2+'-'+HierarchyLevel3+'-'+AllValues+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    SLA = MapSLAConfigurations.get(HierarchyLevel1+'-'+HierarchyLevel2+'-'+HierarchyLevel3+'-'+AllValues+'-'+AllValues).SLA_for_Private_Customers__c;
                else
                    SLA = MapSLAConfigurations.get(HierarchyLevel1+'-'+HierarchyLevel2+'-'+HierarchyLevel3+'-'+AllValues+'-'+AllValues).SLA__c;
            }                                    
            else if(MapSLAConfigurations.containsKey(AllValues+'-'+NullValues+'-'+NullValues+'-'+CasRecTyp+'-'+AllValues))
            {
                if(IsPrivate || isVIPCustomer)//MOSCATELLI_M 17/11/2016:EVO 70
                    SLA = MapSLAConfigurations.get(AllValues+'-'+NullValues+'-'+NullValues+'-'+CasRecTyp+'-'+AllValues).SLA_for_Private_Customers__c;
                else
                    SLA = MapSLAConfigurations.get(AllValues+'-'+NullValues+'-'+NullValues+'-'+CasRecTyp+'-'+AllValues).SLA__c;
            }
        }
        system.debug('##SLA: '+SLA);
        
        return SLA;
    }
}
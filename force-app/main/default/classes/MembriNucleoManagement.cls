/**
 * @description PURE IT 22/05 - commentata la classe
 */
public class MembriNucleoManagement {

    /** PURE IT
    public static List<Membro_del_nucleo__c> PopulateRollupFieldsOnCreation(List<Membro_del_nucleo__c> inputL){
        //---------------- PREPARE DATA - START
        //Create map id to Account 
        Map<Id,Account> MapIdToAccount=new map<Id,Account>();
        for(Membro_del_nucleo__c mn : inputL){
            if (mn.Account_correlato__c!=null) {
                MapIdToAccount.put(mn.Account_correlato__c,new account(id=mn.Account_correlato__c));
            }
        }
        Set<Id> AccountIds = MapIdToAccount.keyset(); // USED for QUERY


        //MAP USED TO STORE ROLLUP VALUES
        map<id, Integer> Map_AccId_To_N_ActivePolicies = new map<id, integer>();
        map<id, double> Map_AccId_To_TotPremium = new map<id, double>();

        map<id, map<string,integer>> Map_AccId_To_N_ActivePolicies_ASA = new map<id, map<string,integer>>();

        //add more maps here if necessary for new logics
        //---------------- PREPARE DATA - END

        ///////////////////////////////////////////////////////////////////////////////////////
        
        //-------------------------------------------ROLLUP START        
        for (InsurancePolicy__c thispolizza : [SELECT Id, EXPIRY_DATE__c, CUID__c, Status__c, Line__c,Last_Premium_Paid__c, Total_premium_Policy_value__c,  Premio_totale_a_pagare__c, Equivalent__c, Balance_position__c FROM InsurancePolicy__c WHERE CUID__c IN: AccountIds]) {
            //Counting active Policies on accounts
            Map_AccId_To_N_ActivePolicies = PolizzaManagement.countActivePolicies(Map_AccId_To_N_ActivePolicies,thispolizza);
            Map_AccId_To_TotPremium = PolizzaManagement.countPremium(Map_AccId_To_TotPremium,thispolizza);
            Map_AccId_To_N_ActivePolicies_ASA = PolizzaManagement.countActivePoliciesByAsa(Map_AccId_To_N_ActivePolicies_ASA, thispolizza);
            
            //Not necessary for now
            //Map_AccId_To_Price_ActivePolicies_ASA = countPremiumByAsa(Map_AccId_To_Price_ActivePolicies_ASA,thispolizza);
            
            //add more logics here if necessary
        }
        //-------------------------------------------ROLLUP END        
        
        //Prepare result to return
        List<Membro_del_nucleo__c> MembersToUpdate = new List<Membro_del_nucleo__c>();
        for (Membro_del_nucleo__c thisMember : inputL) {
            //Populating the the number of polizze by asa
            SYSTEM.DEBUG('++++THISMEMBER'+thisMember);
            if (Map_AccId_To_N_ActivePolicies_ASA.get(thisMember.Account_correlato__c)!=null) {
                thisMember.Polizze_ASA_1__c = Map_AccId_To_N_ActivePolicies_ASA.get(thisMember.Account_correlato__c).get('1');
                thisMember.Polizze_ASA_2__c = Map_AccId_To_N_ActivePolicies_ASA.get(thisMember.Account_correlato__c).get('2');
                thisMember.Polizze_ASA_3__c = Map_AccId_To_N_ActivePolicies_ASA.get(thisMember.Account_correlato__c).get('3');
                thisMember.Polizze_ASA_4__c = Map_AccId_To_N_ActivePolicies_ASA.get(thisMember.Account_correlato__c).get('4');
                thisMember.Polizze_ASA_5__c = Map_AccId_To_N_ActivePolicies_ASA.get(thisMember.Account_correlato__c).get('5');
                thisMember.Polizze_ASA_6__c = Map_AccId_To_N_ActivePolicies_ASA.get(thisMember.Account_correlato__c).get('6');
                thisMember.Polizze_ASA_71__c= Map_AccId_To_N_ActivePolicies_ASA.get(thisMember.Account_correlato__c).get('71');
                thisMember.Polizze_ASA_72__c= Map_AccId_To_N_ActivePolicies_ASA.get(thisMember.Account_correlato__c).get('72');
                thisMember.Polizze_ASA_8__c= Map_AccId_To_N_ActivePolicies_ASA.get(thisMember.Account_correlato__c).get('8'); 
            }else
            {//fix for changing account in a member if the account does not have active policies
                thisMember.Polizze_ASA_1__c = 0;
                thisMember.Polizze_ASA_2__c = 0;
                thisMember.Polizze_ASA_3__c = 0;
                thisMember.Polizze_ASA_4__c = 0;
                thisMember.Polizze_ASA_5__c = 0;
                thisMember.Polizze_ASA_6__c = 0;
                thisMember.Polizze_ASA_71__c= 0;
                thisMember.Polizze_ASA_72__c= 0;
                thisMember.Polizze_ASA_8__c= 0; 
            }            

            
            //populating the total premium
            thisMember.Premio_totale__c = Map_AccId_To_TotPremium.get(thisMember.Account_correlato__c);

            MembersToUpdate.add(thisMember);
        }
        system.debug('+++++MembersToUpdate.size()'+MembersToUpdate.size());
        system.debug('+++++MembersToUpdate'+MembersToUpdate); 

        return         MembersToUpdate;
        

    }
PURE IT */
}
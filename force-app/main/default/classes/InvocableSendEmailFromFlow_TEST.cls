@isTest
public class InvocableSendEmailFromFlow_TEST {
    @isTest
    public static void testMain(){
        InvocableSendEmailFromFlow.Requests temps =  new InvocableSendEmailFromFlow.Requests();
        list <InvocableSendEmailFromFlow.Requests> requestList = new list<InvocableSendEmailFromFlow.Requests>();

        temps.PathOfDevelop = 'Portale Cauzioni'; // version 1 only have - Portale Cauzioni on CASESWITCH
        temps.templateDeveloperName = 'Notifica_Agente_Portale_Cauzioni';
        temps.OrgWideEmailAddress_Name = 'Assistenza RCI';// is allow to all profile ?
        temps.CaseDesc = '[{"key":"Nome Agenzia","value":"CERVIA"},{"key":"Numero proposta","value":"103999"},{"key":"Tipologia proposta","value":"Definitiva"},{"key":"nome e cognome del beneficiario","value":"SOCIETA EMMEELLE"},{"key":"data effetto","value":"2022-11-01T16:02:01Z"},{"key":"importo garantito","value":100.0}]';
        temps.Subject = 'SUBJECT ogget';
        temps.CaseEmail = 'j.nickfury@shield.com';
        temps.AgencyCodeCase = '001622';
        temps.AccountName = 'Sheldon Cooper';
        
        requestList.add(temps);
        requestList.add(temps);//Case 07185006 - BUG - Anomalia Case CTL *-+ 05-12-2022
        requestList.add(temps);//Case 07185006 - BUG - Anomalia Case CTL *-+ 05-12-2022

        InvocableSendEmailFromFlow.execute(requestList);

    }
}
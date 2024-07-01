/*
***************************************************************************************************
---------------------------------------------------------------------------------------------------
-- - Name          : VFC21_Modify_Customer
-- - Author        : Moscatelli Marco
-- - Description   : Sample controller to define the behaviour of the button "Modify Customer" 
-- - 				 internal to the Case page
--
-- Maintenance History:
--
-- Date         Version  Remarks
-- -----------  -------  --------------------------------------------------------------------------
-- 13-04-2018   1.0     
---------------------------------------------------------------------------------------------------
***************************************************************************************************
*/

public with sharing class VFC21_Modify_Customer 
{
	public Case cas;
	public String CaseId{set;get;}
	public String AccountId{set;get;}
	public Boolean IsRO{set;get;}
	public String AccountName{set;get;}


	public VFC21_Modify_Customer(ApexPages.StandardController std) 
	{
		Cas = (Case)std.getRecord();

		Case c = [Select Id,AccountId, Account.Name, Account.RecordType.Developername from Case where id=:Cas.Id];

		CaseId = Cas.Id;
		AccountName=c.Account.Name;
		AccountId=c.AccountId;
		IsRO = false;

		String AccRT = c.Account.RecordType.Developername;

		if(String.isBlank(AccountId) || (String.isNotBlank(AccountId) && AccRT <>'B2C_Client' && AccRT <>'B2B_Client'))
			IsRO = true;
	}
}
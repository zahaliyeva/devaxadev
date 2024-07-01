/*------------------------------------------------------------------------------------------
Author:        Marco Moscatelli
Company:       Deloitte
Class:         GetSOLDetailResponse
Description:   Apex class used to execute all the logics internal to the 
rest Callout related to Caring Angel

History

4/10/2018     Created 
-------------------------------------------------------------------------------------------*/
public class GetSOLDetailResponse
{
	public cls_MessageBody MessageBody; 
	public cls_MessageHeader MessageHeader;

	public class cls_MessageBody
	{
		public String Url;
		public List<String> Errori;
	}

	public class cls_MessageHeader
	{
		public Integer ResultMessage;
		public String Resultexception;
	}
}
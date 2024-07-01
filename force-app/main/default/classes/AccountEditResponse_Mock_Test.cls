/*------------------------------------------------------------------------
Author:        Anna Riccardi
Company:       Deloitte
Class:         AccountEditResponse_Mock_Test
Description:   Response Test
               
History

16/22/2016     Anna Riccardi
----------------------------------------------------------------------------*/
@isTest
global class AccountEditResponse_Mock_Test implements HttpCalloutMock{

    public String TestCase;//MOSCATELLI_M 15/11/2017: Elimina DAC
    
    global HTTPResponse respond(HTTPRequest req) {

   
      // Create a fake response

      HttpResponse res = new HttpResponse();

      //res.setHeader('Content-Type', 'application/json');
      string myXml='';
      system.debug('##TestCase: '+TestCase);
      //MOSCATELLI_M 15/11/2017: Elimina DAC--START
      if(TestCase<>'EliminaDAC')
      {
            myXml='[{"ndg":"0001270000138297","occurrencyNumber":"1","dacOperationResult":{"operationResult":"OK","operationDetail":"Sono stati aperti dei fascicoli dalla chiamata DAC oppure ci sono dei documenti da consegnare"},"parties":[{"party":{"sourceExternal":"SFDC","userExternal":"AG2901A2","externalUpdateDateTime":"2018-10-08T16:23:17.470Z","ndg":["0001270000138297"],"agencyCode":"000127","operativePrivacy":true,"promotionalPrivacy":false,"marketResearchPrivacy":false,"thirdPartiesPrivacy":false,"mailDigitalPrivacy":false,"emailDac":"","graphometricSignaturePrivacy":true,"otpPrivacy":true,"telephoneOtp":"3332221111","marketResearchPrivacyUser":"AG2901A2","mailDigitalPrivacyUser":"AG2901A2","graphometricSignaturePrivacyUser":"AG2901A2","otpPrivacyUser":"AG2901A2","operativePrivacyDate":"2018-10-08T18:21:40.000+02:00","promotionalPrivacyDate":"2018-10-08T16:21:39.000+02:00","marketResearchPrivacyDate":"2018-10-08T16:21:39.000+02:00","thirdPartiesPrivacyDate":"2018-10-08T16:21:39.000+02:00","mailDigitalPrivacyDate":"2018-10-08T16:23:17.472Z","graphometricSignaturePrivacyDate":"2018-10-08T16:23:17.472Z","aggPrivacyOTP":"2018-10-08T16:23:17.472Z","eTypeAggPrivacy1":"SFDC","eTypeAggPrivacy2":"SFDC","eTypeAggPrivacy3":"SFDC","eTypeAggPrivacy4":"SFDC","eTypeAggPrivacyEmail":"SFDC","eTypeAggPrivacyFirma":"SFDC","eTypeAggPrivacyOTP":"SFDC","timestampCif":"2018-10-08T18:23:18.644+02:00"},"documents":[{"documentType":"1","nationCode":"AFG","documentNumber":"xx12312312","releaseAuthority":"1","releaseDate":"2018-10-01T00:00:00.000Z","expirationDate":"2028-01-01T00:00:00.000Z","dacDocument":true,"documentId":"1519027840"}],"telephone":[{"number":"3332221111","internationalPrefix":"+39","telephoneType":"2","contactId":"1519027838","propagaOmnia":true,"opposition":false}],"companyId":"2"}]}]';
}
else
{
  myXml='{"code":"E0064","developerMessage":" Necessario compilare tutte le privacy"}';
}
system.debug('##myXml: '+myXml);
//MOSCATELLI_M 15/11/2017: Elimina DAC--END
      myXml=myXml.normalizespace();

      res.setBody(myXml);

      res.setStatusCode(200);

      return res;

    }

}
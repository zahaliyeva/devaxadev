/*------------------------------------------------------------------------
Author:        Anna Riccardi
Company:       Deloitte
Class:         AccountEditResponseB2B_Mock_Test
Description:   Response Test
               
History

16/22/2016     Anna Riccardi
----------------------------------------------------------------------------*/
@isTest
global class AccountEditResponseB2B_Mock_Test implements HttpCalloutMock{


    global HTTPResponse respond(HTTPRequest req) {

   
      // Create a fake response

      HttpResponse res = new HttpResponse();

      //res.setHeader('Content-Type', 'application/json');
      string myXml='';
            myXml='[{"ndg":"0001270000138293","occurrencyNumber":"1","dacOperationResult":{"operationResult":"OK","operationDetail":"Sono stati aperti dei fascicoli dalla chiamata DAC oppure ci sono dei documenti da consegnare"},"parties":[{"party":{"sourceExternal":"SFDC","userExternal":"fmarchese@italy.axa.com.pre","externalUpdateDateTime":"2018-10-09T10:16:34.990Z","ndg":["0001270000138293"],"agencyCode":"000127","operativePrivacy":true,"promotionalPrivacy":true,"marketResearchPrivacy":true,"thirdPartiesPrivacy":true,"mailDigitalPrivacy":true,"emailDac":"wwwwww@wwwww.ww","graphometricSignaturePrivacy":false,"otpPrivacy":false,"marketResearchPrivacyUser":"fmarchese@italy.axa.com.pre","mailDigitalPrivacyUser":"fmarchese@italy.axa.com.pre","graphometricSignaturePrivacyUser":"AG2901A2","otpPrivacyUser":"AG2901A2","operativePrivacyDate":"2018-10-08T16:24:17.000+02:00","promotionalPrivacyDate":"2018-10-09T10:16:34.993Z","marketResearchPrivacyDate":"2018-10-09T10:16:34.993Z","thirdPartiesPrivacyDate":"2018-10-09T10:16:34.993Z","mailDigitalPrivacyDate":"2018-10-09T10:16:34.993Z","graphometricSignaturePrivacyDate":"2018-10-08T14:24:16.000+02:00","aggPrivacyOTP":"2018-10-08T00:00:00.000+02:00","eTypeAggPrivacy1":"SFDC","eTypeAggPrivacy2":"SFDC","eTypeAggPrivacy3":"SFDC","eTypeAggPrivacy4":"SFDC","eTypeAggPrivacyEmail":"SFDC","eTypeAggPrivacyFirma":"SFDC","eTypeAggPrivacyOTP":"SFDC","timestampCif":"2018-10-09T12:16:36.370+02:00"},"telephone":[{"number":"34234234234234","internationalPrefix":"+39","telephoneType":"1","contactId":"1519032896","propagaOmnia":true,"opposition":false},{"number":"543543543543","internationalPrefix":"+39","telephoneType":"2","contactId":"1519027293","propagaOmnia":true,"opposition":false},{"number":"64565645645","internationalPrefix":"+39","telephoneType":"4","contactId":"1519027241","propagaOmnia":false,"opposition":false},{"number":"423423423","internationalPrefix":"+39","telephoneType":"8","contactId":"1519032895","propagaOmnia":true,"opposition":false}],"telemContact":[{"contactType":"1","text":"wwwwww@wwwww.ww","contactId":"1519027298","propagaOmniaindicator":true,"opposition":false}],"companyId":"2"}]}]';
           myXml=myXml.normalizespace();

      res.setBody(myXml);

      res.setStatusCode(200);

      return res;

    }

}
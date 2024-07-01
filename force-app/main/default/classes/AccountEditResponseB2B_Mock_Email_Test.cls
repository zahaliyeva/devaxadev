/*------------------------------------------------------------------------
Author:        Anna Riccardi
Company:       Deloitte
Class:         AccountEditResponseB2B_Mock_Email_Test
Description:   Response Test
               
History

16/22/2016     Anna Riccardi
----------------------------------------------------------------------------*/
@isTest
global class AccountEditResponseB2B_Mock_Email_Test implements HttpCalloutMock{


    global HTTPResponse respond(HTTPRequest req) {

   
      // Create a fake response

      HttpResponse res = new HttpResponse();

      //res.setHeader('Content-Type', 'application/json');
      string myXml='';
            myXml='[{"ndg":"0001270000138293","occurrencyNumber":"1","dacOperationResult":{"operationResult":"Non Eseguita","operationDetail":"Esistono Fascicoli Aperti oppure dei documenti da consegnare per il soggetto che si sta aggiornando"},"parties":[{"party":{"sourceExternal":"SFDC","userExternal":"fmarchese@italy.axa.com.pre","externalUpdateDateTime":"2018-10-09T10:18:33.478Z","ndg":["0001270000138293"],"agencyCode":"000127","operativePrivacy":true,"promotionalPrivacy":true,"marketResearchPrivacy":true,"thirdPartiesPrivacy":true,"mailDigitalPrivacy":true,"emailDac":"WWWWWW@WWWWW.WW","graphometricSignaturePrivacy":false,"otpPrivacy":false,"marketResearchPrivacyUser":"FMARCHESE@ITALY.AXA.COM.PRE","mailDigitalPrivacyUser":"FMARCHESE@ITALY.AXA.COM.PRE","graphometricSignaturePrivacyUser":"AG2901A2","otpPrivacyUser":"AG2901A2","operativePrivacyDate":"2018-10-08T16:24:17.000+02:00","promotionalPrivacyDate":"2018-10-09T10:16:34.000+02:00","marketResearchPrivacyDate":"2018-10-09T10:16:34.000+02:00","thirdPartiesPrivacyDate":"2018-10-09T10:16:34.000+02:00","mailDigitalPrivacyDate":"2018-10-09T10:16:34.000+02:00","graphometricSignaturePrivacyDate":"2018-10-08T14:24:16.000+02:00","aggPrivacyOTP":"2018-10-08T00:00:00.000+02:00","eTypeAggPrivacy1":"SFDC","eTypeAggPrivacy2":"SFDC","eTypeAggPrivacy3":"SFDC","eTypeAggPrivacy4":"SFDC","eTypeAggPrivacyEmail":"SFDC","eTypeAggPrivacyFirma":"SFDC","eTypeAggPrivacyOTP":"SFDC","timestampCif":"2018-10-09T12:18:34.549+02:00"},"telephone":[{"number":"34234234234234","internationalPrefix":"+39","telephoneType":"1","contactId":"1519032896","propagaOmnia":true,"opposition":true,"oppositionReason":"Altro"},{"number":"543543543543","internationalPrefix":"+39","telephoneType":"2","contactId":"1519027293","propagaOmnia":true,"opposition":true,"oppositionReason":"Altro"},{"number":"64565645645","internationalPrefix":"+39","telephoneType":"4","contactId":"1519027241","propagaOmnia":false,"opposition":true,"oppositionReason":"Cliente"},{"number":"423423423","internationalPrefix":"+39","telephoneType":"8","contactId":"1519032895","propagaOmnia":true,"opposition":true,"oppositionReason":"Altro"}],"telemContact":[{"contactType":"32","text":"mail@mail.com","contactId":"1519033276","propagaOmniaindicator":false,"opposition":true,"oppositionReason":"Altro"}],"companyId":"2"}]}]';
           myXml=myXml.normalizespace();

      res.setBody(myXml);

      res.setStatusCode(200);

      return res;

    }

}
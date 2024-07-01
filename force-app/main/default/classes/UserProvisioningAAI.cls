global class UserProvisioningAAI {
    
   //Define the objects in apex that are exposed in the web service
   
   //Define the input object with the user details (requested by the WS)
   global class UserDetailsInput {
      webservice String Active;
      webservice String FirstName;
      webservice String LastName;
      webservice String Email;
      webservice String UserName;
      webservice String MyriamUserName;
      webservice String AgencyCode;
      webservice List<UserNodeInput> Nodes;
      
   }
   
   //Define the object in the user details with the node info 
   global class UserNodeInput {
       webservice String NodeCode;
       webservice integer NodeLevel;
       webservice String Profile;
       webservice String Functionality;
       webservice boolean AdminFlag;
   }
   
   //Define the response of the WS
   global class ServiceResult {
       webservice string Result;
       webservice String Message;
       webservice UserDetailsInput UserD;
   }

   webservice static ServiceResult UpsertUserAAI(UserDetailsInput UserD) {//method of the webservice that upsert a User
       ServiceResult WSresult = new ServiceResult();
       
       UserProvisioningManagement CurrentUserManagement = new UserProvisioningManagement(UserD);
       
       system.debug('++++++++++++++++++++START___LOGrequest\n'+UserD+'\n++++++++++++++++++++END___LOGrequest');
       
       //Validate user input details
       CurrentUserManagement.ValidateInputFields();
       
       if (CurrentUserManagement.getAreUserInputsOK()){
           CurrentUserManagement.CreateUser();
           if (CurrentUserManagement.getWasUserCreated()){
               WSresult.Result='OK';
           } else {
               WSresult.Result='KO';
           }
           WSresult.Message=CurrentUserManagement.Message;
       } else {
           WSresult.Result='KO';
           WSresult.Message='Inputs Details not correct - ' + CurrentUserManagement.Message;
       }
       
       //return the inputs as well
       WSresult.UserD=UserD;
       system.debug('++++++++++++++++++++START___LOGresponse\n'+WSresult+'\n++++++++++++++++++++END___LOGresponse');
       return WSresult;
  }

}
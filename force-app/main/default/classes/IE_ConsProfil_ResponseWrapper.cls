/**
* @description JSON Error Response Wrapper
* @author Fincons
* @since [04/2024
*/
public class IE_ConsProfil_ResponseWrapper {
    public List<ErrorDetail> errors;
    public class ErrorDetail {
        public String status;
        public String title;
        public String detail;
    }
 
 }
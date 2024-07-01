public class DocumentValidationResponse {

    public Data data;
    public List<Error> errors;

    public String id;
    public String status;
    public String code;
    public String title;
    public String detail;
    public Source source;
    
    public class Data {
        public String type;
        public String id;
    }

    public class Error {
        public String id;
        public String status;
        public String code;
        public String title;
        public String detail;
        public Source source;
    }

    public class Source {
        public String pointer;
        public String parameter;
    }

}
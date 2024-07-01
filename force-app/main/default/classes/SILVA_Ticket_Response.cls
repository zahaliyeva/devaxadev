public class SILVA_Ticket_Response {
    public class GTIValues {
        public String value;
        public String name;
    }

    public class OKResponse {
        public String GTIstatus;
        public String sys_id;
        public String SilvaNumber;
    }

    public String status { get; set; }
    public OKResponse result;
}
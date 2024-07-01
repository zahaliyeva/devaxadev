/**
 * Created by francesco on 2019-07-09.
 */

public class GetFilenetDocumentResponse {

    public Data data;
    public List<Error> error;

    public class Data {
        public String type;
        public String id;
        public Attributes attributes;
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

    public class Attributes {
        public String fileName;
        public String mimeType;
        public String content;
        public String fileSize;
    }

}
public class CustomViewQuery {
    
    public String Query;
    public Decimal RowsPerPage;
    
    public CustomViewQuery (){
        this.Query = '';
        this.RowsPerPage = 10;      
    }
    
    public CustomViewQuery (String Query){
        this.Query = Query;
        this.RowsPerPage = 10;      
    }
    
    public CustomViewQuery (String Query, Decimal RowsPerPage){
        this.Query = Query;
        this.RowsPerPage = RowsPerPage;     
    }

}
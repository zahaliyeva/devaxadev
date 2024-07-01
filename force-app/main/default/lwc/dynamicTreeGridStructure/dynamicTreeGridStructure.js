import { LightningElement, track , api} from 'lwc';
import getKnowledges from '@salesforce/apex/TreeGridController.findHierarchyData';

export default class TreeGridBasic extends LightningElement {

@track gridColumns;
@track gridData;
@track expandedRows;
@api params={};


  connectedCallback() 
  {
    this.handleSearch(this.params);  
  }



  handleSearch(params) {
    getKnowledges(params)
        .then((result) => {
  
            var parentFieldName = params.parentFieldAPIName;
          var fieldList= params.fieldAPINameList;
          var apexResponse = result;
            var columns = apexResponse.headerList;      
            this.gridColumns =columns; 
            var expandedR = [];
            var hierarchydata = apexResponse.recordList;
            var roles = {};
          //console.log('*******hierarchydata:'+JSON.stringify(hierarchydata));
            var results = hierarchydata;
            roles[undefined] = { Name: "Root", _children: [] };
            hierarchydata.forEach(function(v) {
            expandedR.push(v.Id);             
                var recordDetail = {};
                fieldList.forEach(function(fieldAPIName) {
  
                    if(fieldAPIName.includes(".")){
                        var fname= fieldAPIName;
                        var ss= fname.split(".");
                        //console.log('****ss.length:'+ss.length);
                        var tempValue=v[ss[0]];
                        //console.log('****initial tempValue:'+JSON.stringify(tempValue));
                        for(var i=1;i<ss.length;i++){
                            console.log('****tempValue for '+fname+':'+tempValue[ss[i]]);
                            tempValue = tempValue[ss[i]];
                        }   
                        recordDetail[fname]=tempValue;
                    }else{
                      recordDetail[fieldAPIName]=v[fieldAPIName];   
                    }
                    
                    
                });
                recordDetail["Id"]=v["Id"];
                recordDetail["RecordURL"]= '/'+v["Id"];
                recordDetail["_children"]= [];
                roles[v.Id] = recordDetail;
            });
            hierarchydata.forEach(function(v) {
                roles[v[parentFieldName]]._children.push(roles[v["Id"]]);   
            });       
            this.gridData= roles[undefined]._children;
            this.expandedRows=expandedR;
          
        })

        
        .catch((error) => {
            //this.error = error;
        });
}

}
({	
    //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
    checkShowRT : function(component,event,helper)
    {
    	var action = component.get("c.checkRTSelection");

        action.setCallback(this, function(response) 
        {
           var state = response.getState();
                               
           if (state === "SUCCESS")
           {
              var result = response.getReturnValue();
                                   
              if(result)
              {
                console.log('##Result: ',result);
    			component.set("v.ShowRTSelection",true);
              }
           }
           else if (state === "INCOMPLETE")
            {
            }
            else if (state === "ERROR")
            {
                
            }
        });
        $A.enqueueAction(action);
	},
    //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
    fetchData : function(component,page, recordToDisplay)
    {
        component.set("v.ErrorSearchCustomer","");
        console.log("data: "+component.get("v.CustomerBirthDate"));
        
        //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
        var CustomerType = component.get("v.personaContr");
        
        if(!component.get("v.ClaimNumber") && ( // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II
            (CustomerType=="fisica" &&
                (!component.get("v.CustomerName") &&
                 !component.get("v.CustomerSurname") &&
                 !component.get("v.Policy") &&
                 !component.get("v.FiscalId") &&
                 !component.get("v.Plate"))
            ) ||
            (CustomerType=="giuridica" &&
                (!component.get("v.CustomerName") &&
                 !component.get("v.CustomerIVA") &&
                 !component.get("v.Policy") &&
                 !component.get("v.Plate"))
            ))
          )
        {
            if(CustomerType=="fisica")
            {
                if(!component.get("v.CustomerBirthDate"))
                {
                    console.log('errore');
                    component.set("v.ErrorSearchCustomer","E' necessario inserire dei criteri di ricerca");
                    component.set("v.ClienteIsFound",false);
                    component.set("v.ShowCustomerTable",true);
                    return;
                }
                else
                {
                    console.log('errore');
                    component.set("v.ErrorSearchCustomer","E' necessario indicare anche un'altro criterio di ricerca");
                    component.set("v.ClienteIsFound",false);
                    component.set("v.ShowCustomerTable",true);
                    return;
                }
			}                
        }
        else
        {
            var action = component.get("c.SearchCustomers");
            component.set("v.ClienteIsFound",false);
            action.setParams({ "Name" : component.get("v.CustomerName"),
                              "Lastname" : component.get("v.CustomerSurname"),
                              "Policy" : component.get("v.Policy"),
                              "Plate" : component.get("v.Plate"),
                              "FiscalId" : component.get("v.FiscalId"),
                              "BirthDate": component.get("v.CustomerBirthDate"),
                              "IVA": component.get("v.CustomerIVA"),
                              "CustomerType": CustomerType,
                              "ClaimNumber": component.get("v.ClaimNumber")
                             });
            
            action.setCallback(this, function(response) 
                               {
                                   var state = response.getState();
                                   component.set("v.ShowCustomerTable",true);
                                   
                                   if (state === "SUCCESS")
                                   {
                                       console.log("From server: ",response.getReturnValue());
                                       var result = response.getReturnValue();
                                       
                                       if(result!=null)
                                       {
                                           console.log('##Result: ',result);
                                           
                                           if(result.Founds.length>0)
                                           {
                                               component.set("v.ClienteIsFound",true);
                                               component.set("v.MapIdToFounds",result.MapIdToFounds);
                                               
                                               var mymap = {};
                                               var i;
                                               
                                               for(i=0;i<result.Founds.length;i++)
                                               {
                                                   mymap[i]=result.Founds[i];
                                               }
                                               console.log('mappa: ',mymap);
                                               
                                               component.set("v.CustomerResultedMap",mymap);
                                               component.set("v.ShowCustomerTable",true);
                                               
                                               console.log('pageNumber: '+page+' recordToDisplay: '+component.get("v.recordToDisplay"));
                                               
                                               component.set("v.total", result.Founds.length);
                                               component.set("v.pages", Math.ceil(result.Founds.length / component.get("v.recordToDisplay")));
                                               var self = this;
                                               self.Nextcustomerpage(component,1, component.get("v.recordToDisplay"));
                                           }
                                           else
                                           {
                                               component.set("v.ErrorSearchCustomer","Non sono stati ottenuti risultati per la ricerca effettuata");
                                               component.set("v.ClienteIsFound",false);
                                               component.set("v.ShowCustomerTable",true);
                                               //Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - START -->
                                               component.set("v.ShowButtonNoAnagrafica",true);
                                               //Giorgio Bonifazi 23/07/2019 : Caring Angel fase 2 - END -->
                                               
                                               return;
                                           }
                                       }
                                   }
                                   else if (state === "INCOMPLETE")
                                   {
                                       console.log('errore');
                                       component.set("v.ErrorSearchCustomer","La funzionalità non è al momento disponibile. Contatta l'Amministratore di sistema");
                                       component.set("v.ClienteIsFound",false);
                                       component.set("v.ShowCustomerTable",true);
                                       return;
                                   }
                                       else if (state === "ERROR")
                                       {                
                                           var errors = response.getError();
                                           if (errors) 
                                           {
                                               if (errors[0] && errors[0].message) 
                                               {
                                                   console.log("Error message: " +errors[0].message);
                                               }
                                           } 
                                           else
                                           {
                                               console.log("Unknown error");
                                               component.set("v.ErrorSearchCustomer","La funzionalità non è al momento disponibile. Contatta l'Amministratore di sistema");
                                               component.set("v.ClienteIsFound",false);
                                               component.set("v.ShowCustomerTable",true);
                                               return;
                                           }
                                       }
                               });
            $A.enqueueAction(action);
        }        
    },
    
    highlightRow: function(component, event, helper, row, row_type)
    {
        console.log('highlightRow');
        var tBody = document.getElementById(row_type);
        var allTr = tBody.childNodes;
        console.log('allTr.length: ',allTr.length);
        for (var i=0; i<allTr.length; i++) 
        {
            allTr[i].setAttribute("style", "background-color:#ffffff;");
        }
        console.log('row.id: ',row.id);
        row.setAttribute("style", "background-color:rgb(232, 232, 232);");
    },
    findCases : function(component,page,recordToDisplay)
    {
        var action = component.get("c.SearchCases");
        component.set("v.CasesAreFound",false);
        component.set("v.ErrorSearchCase","");
        
        action.setParams({ "AccountId" : component.get("v.SelectedAccountId"),              
                        //MOSCATELLI_M 13/03/2019: Axa Assistance -- START
                        "FormType" : component.get("v.FormType")
                        //MOSCATELLI_M 13/03/2019: Axa Assistance -- END
                        });
        
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               component.set("v.ShowCaseTable",true);
                               
                               if (state === "SUCCESS")
                               {
                                   console.log("From server Case: ",response.getReturnValue());
                                   var result = response.getReturnValue();
                                   
                                   if(result!=null)
                                   {
                                       console.log('##Result: ',result);
                                       
                                       if(result.length>0)
                                       {
                                           component.set("v.CasesAreFound",true);
                                           
                                           var mymap ={};
                                           var i=0;
                                           
                                           for(i=0;i<result.length;i++)
                                           {
                                               mymap[i]=result[i];
                                           }
                                           
                                           component.set("v.CasesFoundMap",mymap);
                                           component.set("v.totalCase", result.length);
                                           component.set("v.pagesCase", Math.ceil(result.length / component.get("v.recordToDisplay")));
                                           component.set("v.ShowCaseTable",true);
                                           var self = this;
                                           self.Nextcasepage(component,1, component.get("v.recordToDisplay"));
                                       }
                                       else
                                       {
                                           component.set("v.ErrorSearchCase","Nessun case Caring Angel è associato al Cliente selezionato");
                                           component.set("v.CasesAreFound",false);
                                           component.set("v.ShowCaseTable",true);
                                           return;
                                       }
                                   }
                               }
                               else if (state === "INCOMPLETE")
                               {
                                   component.set("v.ErrorSearchCase","La funzionalità non è al momento disponibile. Contatta l'Amministratore di sistema");
                                   component.set("v.CasesAreFound",false);
                                   component.set("v.ShowCaseTable",true);
                                   return;
                               }
                                   else if (state === "ERROR")
                                   {
                                       var errors = response.getError();
                                       if (errors) {
                                           if (errors[0] && errors[0].message) 
                                           {
                                               console.log("Error message: " +errors[0].message);                                
                                           }
                                       } 
                                       else
                                       {
                                           console.log("Unknown error");
                                       }
                                       component.set("v.ErrorSearchCase","La funzionalità non è al momento disponibile. Contatta l'Amministratore di sistema");
                                       component.set("v.CasesAreFound",false);
                                       component.set("v.ShowCaseTable",true);
                                       return;
                                   }
                           });
        $A.enqueueAction(action);        
    },
    
    ViewCase: function(component,event,helper)
    {
        var caseid= component.get("v.SelectedCaseId");
        
        var myEvent = $A.get("e.c:tabclosing");
        myEvent.setParams({"data":component.get("v.SelectedCaseNumber"),
                           "recordid":component.get("v.SelectedCaseId"),
                           "Url":''});
        myEvent.fire();
    },
    Nextcustomerpage: function(component,page, recordToDisplay)
    {
        var total_records = component.get("v.total");
        var page_size = recordToDisplay;
        var page_number = page;
        component.set("v.page",page_number);
        var records = JSON.parse( JSON.stringify(  component.get("v.CustomerResultedMap")));
        
        let pages_total = component.get("v.pages");
        
        
        let first_record_on_page = (total_records > 0) ? (((page_number - 1) * page_size) + 1) : 0;
        let last_record_on_page;
        
        if((page_number * page_size) > total_records)
        {
            last_record_on_page = total_records;
        } 
        else 
        {
            last_record_on_page = (page_number * page_size);
        }
        console.log('first: '+first_record_on_page+' last: '+last_record_on_page+' total: '+total_records+' page_number: '+page_number);
        
        component.set('v.FirstRecordOnPage', first_record_on_page);
        component.set('v.LastRecordOnPage', last_record_on_page);
        console.log('records: ',records);
        
        let row = [];
        
        for(let i = first_record_on_page-1; i < last_record_on_page; i++)
        {
            console.log(records[i]);
            row.push(records[i]);       
        }
        component.set("v.data",row);
    },
    Nextcasepage: function(component,page, recordToDisplay)
    {
        var total_records = component.get("v.totalCase");
        var page_size = recordToDisplay;
        var page_number = page;
        component.set("v.pageCase",page_number);
        var records = JSON.parse( JSON.stringify(  component.get("v.CasesFoundMap")));
        
        let pages_total = component.get("v.pagesCase");
        
        
        let first_record_on_page = (total_records > 0) ? (((page_number - 1) * page_size) + 1) : 0;
        let last_record_on_page;
        
        if((page_number * page_size) > total_records)
        {
            last_record_on_page = total_records;
        } 
        else 
        {
            last_record_on_page = (page_number * page_size);
        }
        console.log('first: '+first_record_on_page+' last: '+last_record_on_page+' total: '+total_records+' page_number: '+page_number);
        
        component.set('v.FirstRecordOnPageCase', first_record_on_page);
        component.set('v.LastRecordOnPageCase', last_record_on_page);
        console.log('records: ',records);
        
        let row = [];
        
        for(let i = first_record_on_page-1; i < last_record_on_page; i++)
        {
            console.log(records[i]);
            row.push(records[i]);       
        }
        component.set("v.dataCases",row);
    },
    
    CreateCase : function(component,event,helper)
    {
        var action = component.get("c.generateNewCase");
        console.log(JSON.parse( JSON.stringify(component.get("v.MapIdToFounds"))));
        var mapAcc = JSON.parse(JSON.stringify(component.get("v.MapIdToFounds")));
        var SelectedAcc = mapAcc[component.get("v.SelectedAccountId")];
        console.log('valore',mapAcc[component.get("v.SelectedAccountId")]);
        action.setParams({ "Id": SelectedAcc.Id,
                          "AccountEmail": SelectedAcc.AccountEmail,
                          "PolicyId" : SelectedAcc.PolicyId,
                          "Targa" : SelectedAcc.Targa,
                          "CaseRT" : component.get("v.SelectedCaseType")
                         });
        
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               
                               if (state === "SUCCESS")
                               {
                                   var result = response.getReturnValue();
                                   
                                   if(result!=null)
                                   {
                                       console.log('##Result: ',result);
                                       
                                       if(result.isSuccess)
                                       {
                                           component.set("v.NewCaseId",result.CsId);
                                           component.set("v.NewCaseNumber",result.CsNumber);
                                           
                                           var self = this;
                                           self.showToast(component,event,helper,'success','Il Case '+ result.CsNumber + ' è stato creato con successo',component.get("v.FormType"),result.CsNumber);
                                       }
                                       else
                                       {
                                           var self = this;
                                           self.showToast(component,event,helper,'error',result.Msg,component.get("v.FormType"),'');
                                       }
                                   }
                               }
                               else if (state === "INCOMPLETE")
                               {
                                   var self = this;
                                   self.showToast(component,event,helper,'error','La funzionalità non è al momento disponibile. Contatta l\'Amministratore di sistema',component.get("v.FormType"),'');
                                   
                               }
                                   else if (state === "ERROR")
                                   {
                                       var errors = response.getError();
                                       if (errors) {
                                           if (errors[0] && errors[0].message) 
                                           {
                                               console.log("Error message: " +errors[0].message);                                
                                           }
                                       } 
                                       else
                                       {
                                           console.log("Unknown error");
                                       }
                                       var self = this;
                                       self.showToast(component,event,helper,'error','La funzionalità non è al momento disponibile. Contatta l\'Amministratore di sistema',component.get("v.FormType"),'');
                                   }
                           });
        $A.enqueueAction(action);
    },
    
    CreateCaseNoAnagrafica : function(component,event,helper)
    {
        var action = component.get("c.generateNewCase");
        
        debugger;
        action.setParams({"CaseRT" : component.get("v.SelectedCaseType")});
        
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               
                               if (state === "SUCCESS")
                               {
                                   var result = response.getReturnValue();
                                   
                                   if(result!=null)
                                   {
                                       console.log('##Result: ',result);
                                       
                                       if(result.isSuccess)
                                       {
                                           component.set("v.NewCaseId",result.CsId);
                                           component.set("v.NewCaseNumber",result.CsNumber);
                                           
                                           var self = this;
                                           self.showToast(component,event,helper,'success','Il Case '+ result.CsNumber + ' è stato creato con successo',component.get("v.FormType"),result.CsNumber);
                                       }
                                       else
                                       {
                                           var self = this;
                                           self.showToast(component,event,helper,'error',result.Msg,component.get("v.FormType"),'');
                                       }
                                   }
                               }
                               else if (state === "INCOMPLETE")
                               {
                                   var self = this;
                                   self.showToast(component,event,helper,'error','La funzionalità non è al momento disponibile. Contatta l\'Amministratore di sistema',component.get("v.FormType"),'');
                                   
                               }
                                   else if (state === "ERROR")
                                   {
                                       var errors = response.getError();
                                       if (errors) {
                                           if (errors[0] && errors[0].message) 
                                           {
                                               console.log("Error message: " +errors[0].message);                                
                                           }
                                       } 
                                       else
                                       {
                                           console.log("Unknown error");
                                       }
                                       var self = this;
                                       self.showToast(component,event,helper,'error','La funzionalità non è al momento disponibile. Contatta l\'Amministratore di sistema',component.get("v.FormType"),'');
                                   }
                           });
        $A.enqueueAction(action);
    },
    //OAVERSANO 16/05/2019 : AXA Assistance Enhancement Fase I -- START
    showToast : function(component, event, helper,type, message, FormType, CaseNumber){
    //showToast : function(component, event, helper,type, message){
    //OAVERSANO 16/05/2019 : AXA Assistance Enhancement Fase I -- END
        console.log('showToast method');
        component.set("v.ShowToast",true);
        component.set("v.messageToast", message);
        component.set("v.typeToast", type);
        
        var self = this;
        
        if(type!='error')
        {
            window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.NewCaseNumber", "");
                    component.set("v.ShowToast",false);
                    
                    //OAVERSANO 16/05/2019 : AXA Assistance Enhancement Fase I -- START
                    var myEvent = $A.get("e.c:tabclosing");
                    if(FormType == "Sinistri")
                    {
                    	console.log("NewCaseNumber: "+component.get("v.NewCaseNumber"));
                    	myEvent.setParams({"data":"openCaseTab",
                                       "recordid":component.get("v.NewCaseId"),
                                       "Url":CaseNumber});
                    }
                    else
                    {
                    	myEvent.setParams({"data":'Open_Questionario',
                                       "recordid":'',
                                       "Url":'caseId='+component.get("v.NewCaseId")+'&accountId='+component.get("v.SelectedAccountId")+'&fiscalCode='+component.get("v.SelectedFiscal")+'&caller=cliente&source=NewCaseCApage'});
                    }
                    myEvent.fire(); 
                    //OAVERSANO 16/05/2019 : AXA Assistance Enhancement Fase I -- END
                }), 3000
            );
        }
    },

    // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II - START
    createCaseRapido: function(component, event, helper) {
        var action = component.get("c.getCaseRapidoPrepopulatedFields");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                let values = response.getReturnValue();

                let lobField = $A.get("$Label.c.LOB_ID");
                let lobValue = values["LOB__c"];
                if(lobValue == 'undefined' || lobValue == undefined) {
                    lobValue = '';
                }

                let categoryField = $A.get("$Label.c.Categoria_ID");
                let categoryValue = values["Category__c"];
                if(categoryValue == 'undefined' || categoryValue == undefined) {
                    categoryValue = '';
                }

                let RTID = component.get("v.SelectedCaseType");

                let url = '?cas11=Phone&cas7=Closed&' + lobField + '=' + lobValue + '&' +
                            categoryField + '=' + categoryValue + '&RecordType=' + RTID + '&classicEdit=true';

                console.log('DBG | New Case Rapido URL: ' + url);

                this.callEvent(component, event, helper, "openNewCasePage", "", url);

            } else {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                var msg = 'Unknown error';

                if (errors) {
                    if (errors[0] && errors[0].message) {
                        msg = errors[0].message;
                        console.log("Error message: " + msg);
                    }
                } else {
                    console.log(msg);
                }

                toastEvent.setParams({
                    "title": "Error",
                    "type": 'error',
                    "message": msg
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
    },

    callEvent : function(component, event, helper, data, recordId, Url) {
        var myEvent = $A.get("e.c:tabclosing");
        myEvent.setParams({ "data": data,
                            "recordid": recordId,
                            "Url": Url});
        myEvent.fire();
    }
    // FOZDEN 26/06/2019: AXA Assistance Enhancement Fase II - END

})
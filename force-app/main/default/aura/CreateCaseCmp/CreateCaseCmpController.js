({
	chiudiTab: function(component,event,helper)
	{
		document.body.setAttribute('style', '-webkit-overflow-scrolling:touch;');//OAVERSANO 25/01/2019 : NMA Fix Mobile
        /*
        if(component.get("v.Theme") == "Theme4t")
        {
            sforce.one.back(true);
        }
        else
        {*/
        var pathName = window.location.pathname;
        var agencyIndex = pathName.indexOf("agenzie");
        var pathCrm = pathName.includes("crm");
        var myURL = "https://"+window.location.hostname;
        if (agencyIndex!= -1)
        {
            myURL = myURL+"/agenzie/apex/ModelloAssistenza";
        } else if (pathCrm) {    
          myURL = myURL+"/crm/s/assistenza";
        } else {
      	  myURL = myURL+'/apex/ModelloAssistenza';
        }
        console.log("********"+myURL);
        //console.log ("*****sforce.one "+sforce.one);
        
        if ((typeof sforce != 'undefined') && (typeof sforce.one != 'undefined') && (sforce.one != null) )
        {
            //OAVERSANO 24/01/2019 : NMA Fix Mobile -- START
            //sforce.one.back(true);
            sforce.one.navigateToURL(myURL, true);
            //OAVERSANO 24/01/2019 : NMA Fix Mobile -- END
        }
        else
        {
           window.location.href = myURL; 
        }            
            //window.close();
        //}			
	},
    doInit: function(component,event,helper) 
    {
        //var recordTypeName = "Motor";
        //helper.DefineSelectableLob(component,"RecordType",recordTypeName);

        if($A.get("$Browser.formFactor") == "DESKTOP" || $A.get("$Browser.formFactor") == "TABLET")
        {
            component.set("v.DeviceIsMobile",true);
        }
        
        helper.DefineSelectableLob(component);
        //cmp.set("v.NewCase", record);
    },
    ChangeLob: function(component,event,helper)
    {
        var Lob = component.find("LobSelection").get("v.value");
        component.set("v.NewCase.LOB__c",Lob);
        if(Lob=='Sinistri Salute')
           component.set("v.isCaringSalute",true);
            
       
        component.set("v.NewCase.Category__c","");
        component.set("v.NewCase.SubCategory__c","");
        component.set("v.SelectedLOB",Lob);
        console.log('Lob: +'+Lob+'+');
        //OAVERSANO 15/05/2019 : AM Fix Lob -- START
        if(Lob == "")
        {
        	component.set("v.ShowCategoriesSection",false);
        }
        else
        {
        	helper.DefineCategories(component);
    	}    
    	//OAVERSANO 15/05/2019 : AM Fix Lob -- END
    },
    ChangeCategory: function(component,event,helper)
    {
        var Category = component.find("CategorySelection").get("v.value");
        component.set("v.NewCase.Category__c",Category);
        component.set("v.NewCase.SubCategory__c","");
        console.log('Category: '+Category);
        helper.DefineSub_Categories(component);    
    },
    SelectChatButton: function(component,event,helper)
    {
        console.log(component.find("Sub-CategorySelection"));
        var SubCategory = component.find("Sub-CategorySelection").get("v.value");
        component.set("v.NewCase.SubCategory__c",SubCategory);
       
        if(SubCategory=='Trattative nuovi libro matricola')
            component.set("v.ShowTrattativeLM",true);
        
        helper.SelectChatButton(component);
    },
    SendToSupport: function(component,event,helper)
    {
        //console.log(component.get("v.SelectedAccount").Obj.Id);
        if(component.get("v.SelectedAccount"))
        {
            component.set("v.NewCase.AccountId",component.get("v.SelectedAccount").Obj.Id);
        }
        
        if(component.get("v.SelectedPolicy"))
        {
            component.set("v.NewCase.LinkToPolicy__c",component.get("v.SelectedPolicy").Obj.Id);
        }
        component.set("v.DisableCreateCase",true);
        helper.CreateAction(component,event,helper);
    },
    SetPoliciesLookupFilter: function(component,event,helper,SelectedAccount)
    {
        console.log('SetPoliciesLookupFilter');
        var currentFilter = component.get("v.PoliciesFilter");
        //var SelectedAccount =component.get("v.NewCase.AccountId");
        
        if(SelectedAccount!= null)
        {
            currentFilter = currentFilter + ' AND CUID__c= '+SelectedAccount;
            component.set("v.PoliciesFilter",currentFilter);
            console.log("@@PoliciesFilter: "+currentFilter);
        }
    },
    
    handleComponentEventCaseCmp : function(component, event, helper)
    {
        console.log('handleComponentEventCaseCmp');
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        console.log('selectedAccountGetFromEvent: ',selectedAccountGetFromEvent);
        var currentFilter = component.get("v.PoliciesFilter");
        
        var OBJtype = event.getParam("ObjectType");
        var currentAccountFilter = component.get("v.AccountFilter");
        
        if(selectedAccountGetFromEvent!= null)
        {
            if(OBJtype == "Account")
            {
                console.log('1_1');
                console.log('id account in createcasecmp: ',selectedAccountGetFromEvent.Obj.Id);
                var SelectedAccount =selectedAccountGetFromEvent.Obj.Id;
                /* ORLANDO PICKLIST ENHANCEMENT */
               // component.set("v.SelectedAccountQuery",selectedAccountGetFromEvent.Obj);
                /* ORLANDO PICKLIST ENHANCEMENT */
                //var SelectedAccount =component.get("v.NewCase.AccountId");
                
                if(SelectedAccount!= null)
                {
                    console.log('1_2');
                    currentFilter = currentFilter + ' AND CUID__c= \''+SelectedAccount+'\'';
                    component.set("v.PoliciesFilter",currentFilter);
                    console.log("@@PoliciesFilter: "+currentFilter);
                    
                    if(component.get("v.SelectedPolicy")==null)
                    {
                        component.set("v.SelectedAccountQuery",false);
                        component.set("v.SelectAccountByPolicy",false);
                    }
                    
                    else
                    {
                        component.set("v.SelectAccountByPolicy",true);
                        component.set("v.SelectedAccountQuery",true);
                    }
                    	
                }
            }
            else
            { 
                console.log('1_3');
               // if(component.get("v.NewCase.AccountId")!=null)
               // {
                    console.log('1_4');
                    console.log('id account polizza in createcasecmp: ',selectedAccountGetFromEvent.Obj.CUID__c);
                    var SelectedPolizzaHolder = selectedAccountGetFromEvent.Obj.CUID__c;
                    //component.set("v.SelectedPolicyQuery",selectedAccountGetFromEvent.Obj);
                    if(component.get("v.SelectedAccount")==null)
                    {
                        console.log('1_4_1');
                        component.set("v.SelectedAccountQuery",true);
                        component.set("v.SelectAccountByPolicy",true);
					}
                    //else
                      //  component.set("v.SelectAccountByPolicy",false);
                		console.log('1_4_2');

                        
                    
                    if(SelectedPolizzaHolder!= null && component.get("v.SelectedAccount")==null)
                    {
                        console.log('1_5');
                        currentAccountFilter = currentAccountFilter + ' AND Id= \''+SelectedPolizzaHolder+'\'';
                        component.set("v.AccountFilter",currentAccountFilter);
                        console.log("@@AccountFilter: "+currentAccountFilter);
                    }
                	else if(SelectedPolizzaHolder== null && component.get("v.SelectedAccount")==null)
                    {
                        currentAccountFilter = currentAccountFilter + ' AND Id= \'\'';
                        component.set("v.AccountFilter",currentAccountFilter);
                        console.log("@@AccountFilter: "+currentAccountFilter);                        
                    }
                //}
            }
        }
        else
        {
            console.log('1_6');
            if(OBJtype == "Account")
            {
                console.log("@@AccountFilter_1_7: "+component.get("v.AccountFilter"));
                console.log('1_7'+component.get("v.AccountFilter").indexOf('AND Id= \'\''));
                
                
                component.set("v.SelectedAccountQuery",true);                
                component.set("v.SelectAccountByPolicy",false);
                
                if(component.get("v.AccountFilter").indexOf('AND Id= \'\'')==-1)
                {
                    console.log('found');
                if(component.get("v.SelectedPolicy") != null)
                    component.set("v.SelectedPolicy", null);
                }
                else
                {
                    component.set("v.SelectAccountByPolicy",true);
                }
                
                if(component.get("v.SelectedAccount") != null)
                    component.set("v.SelectedAccount", null);
                
                if(currentFilter.indexOf(' AND CUID__c= ')>-1)
                {
                    console.log('1_8');
                    currentFilter = currentFilter.substring(0, currentFilter.indexOf(' AND CUID__c= '));
                    component.set("v.PoliciesFilter",currentFilter);
                    console.log("@@PoliciesFilter: "+currentFilter);
                  //  component.set("v.SelectedAccount",null);
                }
                
                if(currentAccountFilter.indexOf('AND Id= \'\'')==-1)
                {
                component.set("v.NewCase.LinkToPolicy__c",null);
                var a = component.get('c.hidePolicyPick');
				$A.enqueueAction(a);
                }

                //if(currentAccountFilter.indexOf(' AND Id= ')>-1)
                if(currentAccountFilter.indexOf(' AND Id= ')>-1 && currentAccountFilter.indexOf('AND Id= \'\'')==-1)
                {
                    console.log('1_10');
                    currentAccountFilter = currentAccountFilter.substring(0, currentAccountFilter.indexOf(' AND Id= '));
                    component.set("v.AccountFilter",currentAccountFilter);
                    console.log("@@AccountFilter: "+currentAccountFilter);
                    //component.set("v.SelectedPolicy",null);
                }                 
              
               
                
                
                /* ORLANDO PICKLIST ENHANCEMENT */
               // component.set("v.SelectedAccountQuery",null);
              //  component.set("v.SelectedAccountQuery",true); 
                //component.set("v.SelectAccountByPolicy",false);
                /* ORLANDO PICKLIST ENHANCEMENT */
                
/*
                component.set("v.NewCase.LinkToPolicy__c",null);
                var a = component.get('c.hidePolicyPick');
				$A.enqueueAction(a);*/
                
            }
            else
            {
                console.log('1_9');
                //component.set("v.SelectAccountByPolicy",false);
                component.set("v.SelectedAccountQuery",false); 
                
                if(component.get("v.SelectedAccount") != null)
                    component.set("v.SelectedAccountQuery", false);
                else
                    component.set("v.SelectedAccountQuery", true);
                
               if(component.get("v.SelectedPolicy") != null)
                    component.set("v.SelectedPolicy", null);
                
                if(currentAccountFilter.indexOf('AND Id= \'\'')>-1)
                {
                    currentAccountFilter = currentAccountFilter.substring(0, currentAccountFilter.indexOf(' AND Id= '));
                    component.set("v.AccountFilter",currentAccountFilter);
                    console.log("@@AccountFilter: "+currentAccountFilter);
					component.set("v.SelectAccountByPolicy",false);                    
                }
                
               // if(component.get("v.SelectedAccount")==null)
             //   {
                    // component.set("v.SelectAccountByPolicy",false);
               // 	 component.set("v.SelectedAccountQuery",true);
              //  }
  //              else
               //     component.set("v.SelectAccountByPolicy",true);
                /*
                if(currentAccountFilter.indexOf(' AND Id= ')>-1)
                {
                    console.log('1_10');
                    currentAccountFilter = currentAccountFilter.substring(0, currentAccountFilter.indexOf(' AND Id= '));
                    component.set("v.AccountFilter",currentAccountFilter);
                    console.log("@@AccountFilter: "+currentAccountFilter);
                    //component.set("v.SelectedPolicy",null);

                }
                
                if(currentFilter.indexOf(' AND CUID__c= ')>-1)
                {
                    console.log('1_8');
                    currentFilter = currentFilter.substring(0, currentFilter.indexOf(' AND CUID__c= '));
                    component.set("v.PoliciesFilter",currentFilter);
                    console.log("@@PoliciesFilter: "+currentFilter);
                   // component.set("v.SelectedAccount",null);//test
                } */
                
                
                //component.set("v.SelectedPolicyQuery",null);
               // component.set("v.NewCase.AccountId",null);
            }
        }
        
    },
    
    NewRequest : function (component,event,helper)
    {
    	window.location.href = window.location.href;     
    },
    
    doSave: function(component, event, helper) 
    {   
        //console.log('filename: '+component.find("fileId").get("v.files")[0].name);//OAVERSANO 25/01/2019 : NMA Fix Mobile
        if (component.get("v.parentId")!= "")
        {
            //OAVERSANO 25/01/2019 : NMA Fix Mobile -- START
            if(component.find("fileId").get("v.files")!=null)
            {
            //OAVERSANO 25/01/2019 : NMA Fix Mobile -- END
	            if (component.find("fileId").get("v.files").length > 0) 
	            {
	                helper.uploadHelper(component, event);
	            } 
	            else 
	            {
	                alert('Selezionare un file valido');
	            }
            //OAVERSANO 25/01/2019 : NMA Fix Mobile -- START
            }
            else 
            {
                alert('Selezionare un file valido');
            }
            //OAVERSANO 25/01/2019 : NMA Fix Mobile -- END
        }
    },
    
    handleFilesChange: function(component, event, helper)
    {
        var fileName = 'Nessun file selezionato';
        
        if (event.getSource().get("v.files").length > 0) 
        {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        
        var attachmentList = component.get("v.attachmentListFileNames");
        console.log('@attachmentList '+attachmentList);
        
        if (attachmentList.indexOf(fileName) != -1)
        {
            component.set("v.fileName", 'Attenzione, il file selezionato è già stato inserito');
            component.set("v.showLoadingSpinner", false);
        } 
        else 
        {
            component.set("v.newfileadded",true);
            component.set("v.fileName", fileName);
		}
        	
    },
    
    handleChangeList: function(component, event, helper) 
    {
        var list = component.get("v.attachmentListFileNames");
        
        if (typeof list!= undefined && list != null && list != "")
        {
            component.set ("v.showAttachmentList",true);
        }
    },
    
    AttachmentModal: function(component,event,helper)
    {
        component.set("v.ShowAttachmentModal",true);
        if($A.get("$Browser.isIOS"))
        	component.set("v.displayCaseForm", "display: none;"); //OAVERSANO 29/01/2019 : NMA Fix Mobile
    },    
    CloseAttachmentModal: function(component,event,helper)
    {
        component.set("v.ShowAttachmentModal",false);
        if($A.get("$Browser.isIOS"))
        	component.set("v.displayCaseForm", "display: block;"); //OAVERSANO 29/01/2019 : NMA Fix Mobile
    },
    CloseMissingInputsModal: function(component,event,helper)
    {
        component.set("v.ShowErrorMsg",false);
        if($A.get("$Browser.isIOS"))
        	component.set("v.displayCaseForm", "display: block;"); //OAVERSANO 29/01/2019 : NMA Fix Mobile
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    passInfoToChat : function(component, event, helper) 
    {
        var Subject = component.get("v.NewCase.Subject");
        var Description = component.get("v.NewCase.Description");
        var Targa = component.get("v.NewCase.Targa__c");
        var Cliente = component.get("v.SelectedAccount").Obj.Id;
        var Polizza = component.get("v.SelectedPolicy").Obj.Id;
        var chatComponent = component.find("chatCmp");
        
        chatComponent.setValues(Subject, Description, Targa, Cliente,Polizza);
    },
    setPageToReadOnly: function(component,event,helper)
    {
        var IsPressed = event.getParam("IsPressed");
        component.set("v.DisableCreateCase",IsPressed);
        console.log("Received component event with param = "+ IsPressed);
    },    
    hidelookupresults: function(component,event,helper)
    {
        console.log('click hidelookupresults');
        var childComponent = component.find('cmplookup');
        var childComponent1 = component.find('cmplookup1');
        childComponent.hidepill(true);
        childComponent1.hidepill(true);
    },
    //SALVADOR ATTACHMENT ENHANCEMENT
    doCancel: function(component, event, helper) {
        component.set("v.Spinner", true);
        
        var attachments             = component.get("v.Attachments");
        var attachmentListFileNames = component.get("v.attachmentListFileNames");
        var bodyMap                 = component.get("v.Bodymap");
        var reacheddim 				= component.get("v.ReachedDimesion");
        
        console.log('attachments:' + attachments);
        console.log('attachmentListFileNames:' + attachmentListFileNames);
        //console.log('bodyMap:' + bodyMap[event.getSource().get('v.value')]);
        
        var index = attachmentListFileNames.indexOf(event.getSource().get('v.value'));
        console.log('@@index: '+attachments[index].size+' reached: '+reacheddim);
        var attachmentDimension = attachments[index].size;
        component.set("v.ReachedDimesion",reacheddim-attachmentDimension);
        console.log('@@newreached: '+component.get("v.ReachedDimesion"));
        
        delete bodyMap[event.getSource().get('v.value')]; 
        attachments.splice(index, 1);
        attachmentListFileNames.splice(index, 1);
        component.set("v.Attachments", attachments);
        component.set("v.attachmentListFileNames", attachmentListFileNames);
        component.set("v.Bodymap", bodyMap);
        component.find("fileId").set('v.files', null);

        if (attachmentListFileNames.length == 0)
        {
            component.set("v.showAttachmentList", false);   
        }
        
        component.set("v.Spinner", false); 
    },
       
    hidePolicyPick: function(component,event,helper)
    {
        console.log('click2');
        var childComponent = component.find('cmplookup1');
        console.log('childComponent: ',childComponent);
        //childComponent.remove(true);
        [].concat(childComponent)[0].removePill(true);
    }
})
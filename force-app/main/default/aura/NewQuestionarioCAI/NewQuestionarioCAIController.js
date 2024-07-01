({
    doInit : function(component, event, helper) 
    {
        
        console.log('doInit NewQuestionarioCA');
        console.log('questionarioCaID : ',component.get("v.questionarioCaID"));
        console.log('fiscalCode: '+component.get("v.fiscalCode"));
        console.log('accountId: '+component.get("v.accountId"));
        console.log('phone: '+component.get("v.phone"));
        console.log('caller: '+component.get("v.caller"));
        console.log('category: '+component.get("v.category"));
        console.log('subcategory: '+component.get("v.subcategory"));
        console.log('caseid: '+component.get("v.caseId"));
        console.log('Case from LIGHTNING: ',component.get("v.simpleRecord.Case__c"));
        console.log('questionario ID from LIGHTNING red: ',component.get("v.recordId"));
        console.log('LISTA TESTIMONI',component.get("v.testimoniList"));
        
        helper.getListOfRegularExpressions(component); //set validator Expr
        
        //set step label path
        var mapLabelStepBar =       [{ key: 'STEP1', label: $A.get("$Label.c.Step1PathQuestionarioCA")},
                                     { key: 'STEP2', label: $A.get("$Label.c.Step2PathQuestionarioCA")},
                                     { key: 'STEP3', label: $A.get("$Label.c.Step3PathQuestionarioCA")},
                                     { key: 'STEP4', label: $A.get("$Label.c.Step4PathQuestionarioCA")},
                                     { key: 'STEP5', label: $A.get("$Label.c.Step5PathQuestionarioCA")},
                                     { key: 'STEP6', label: $A.get("$Label.c.Step6PathQuestionarioCA")}
                                    ];
        component.set("v.mapLabelStepBar",mapLabelStepBar);

        var HOURSList = component.get("v.HOURSList");
        //Giorgio Bonifazi Caring Angel Fase 2 START
        var profiloCorrente = component.get("v.UsrProfile");
        var comm = component.set("v.questionarioCA.Description__c","");  
        console.log('TEST PROFILO ATTUALE:'+ component.get("v.UsrProfile"));
        
       if(profiloCorrente =="Caring Angel - Supervisor" || profiloCorrente == "Caring Angel - Supporto HD2" || profiloCorrente =="Caring Angel - Supporto HD2 Supervisor" || profiloCorrente == "Caring Angel - Supporto HD1" || profiloCorrente =="Caring Angel - Supporto HD1 Supervisor"){
			component.set("v.isCaringAngelProfile",true);
           
       }

        if(profiloCorrente =="Caring Angel - Supervisor" || profiloCorrente == "Caring Angel - Supporto HD2" || profiloCorrente =="Caring Angel - Supporto HD2 Supervisor" ){
            component.set("v.isHD2Profile",true);
            component.set("v.showSinistroCanalizzato", true);
            let listSortPage=component.get("v.sortOrderPage");
            listSortPage.push('v.isVisibleSTEP9');//add at end section 'Sezione Note HD2'
            component.set("v.sortOrderPage",listSortPage); 
            
             helper.setHideStepPath(component,'STEP6', 'Y');          
            
        }
        
            console.log('la visibilita su HD2:'+ component.get("v.isHD2Profile"));
            console.log('la visibilita su sinistro canalizzato:'+component.get("v.showSinistroCanalizzato"));

            var pageReference = {
                type: 'standard__component',
                attributes: {
                    componentName: 'c__NewCommentAndAttachment'}
                
            };
            component.set("v.pageReference", pageReference); 
        //Giorgio Bonifazi Caring Angel Fase 2 END
        
        for(var i = 0; i<24; i++)
        {
            if(i<10)
                HOURSList.push('0'+i);
            else
                HOURSList.push(i);
        }
        
        var HOURSListRecall = component.get("v.HOURSListRecall");
        for(var i = 9; i<19; i++)
        {
            if(i<10)
                HOURSListRecall.push('0'+i);
            else
                HOURSListRecall.push(i);
        }        
        
        var MINUTESList = component.get("v.MINUTESList");
        for(var i = 0; i<60; i++)
        {
            if(i<10)
                MINUTESList.push('0'+i);
            else
                MINUTESList.push(i);
        }
		/** */
        MINUTESList ? component.set("v.MINUTESList",MINUTESList) : MINUTESList;
        HOURSList ? component.set("v.HOURSList",HOURSList) : HOURSList;
        HOURSListRecall ? component.set("v.HOURSListRecall",HOURSListRecall) : HOURSListRecall;
        /** */
        let questionarioCAid = component.get("v.questionarioCaID");
        let caseId = component.get("v.caseId");
        let questionarioCAidLIGHTNING = component.get("v.recordId");
        if(questionarioCAid!= null && questionarioCAid !='')
        {
            console.log("edit From SF");
            component.set("v.method","update");
            component.set("v.OpeningMethod","update");
            component.set("v.questionarioCA.Id",questionarioCAid);
        }
        else if(caseId!= null && caseId !='')
        {
            console.log("new From SF");
            component.set("v.method","insert");
            component.set("v.OpeningMethod","insert");
            component.set("v.questionarioCA.Case__c",caseId);
        }
            else if(questionarioCAidLIGHTNING!=null && questionarioCAidLIGHTNING!= '')
            {
                console.log("edit From SF Lightning");
                component.set("v.method","update");
                component.set("v.OpeningMethod","update");
                component.set("v.questionarioCA.Id",questionarioCAidLIGHTNING);
            }
                else
                {
                    console.log("new From VFP06")
                    component.set("v.method","insert");
                    component.set("v.OpeningMethod","insert");
                    let accountId = component.get("v.accountId");
                    if(accountId!=null)
                    {
                        component.set("v.questionario.Contraente__c",accountId);
                    }
                }
        var numChiamante = component.get("v.phone");
        if(numChiamante!=null) component.set("v.questionarioCA.Numero_chiamante__c",numChiamante);	
        //OAVERSANO 22/11/2018 : Caring Angel Enhancement -- START
        var todayISODateTime = new Date();
        console.log('todayISODateTime.toISOString(): ',todayISODateTime.toISOString().substring(0, 10));
        component.set("v.todayISODateTime", todayISODateTime.toISOString().substring(0, 10));
        //OAVERSANO 22/11/2018 : Caring Angel Enhancement -- END
        helper.initializeCA(component, event, helper);
        helper.initializeTestimoni(component,event,helper);
        helper.initializeFeriti(component,event,helper);
    },
    
     /*performStep : function(component, event, helper)
    {   
        console.log("LISTA",component.get("v.testimoniList"));
        console.log('performStep method');
        let action =  event.getSource().get("v.name");
       /*var newArray = array.filter(function(el) {
            
            return   el.Nome__c || el.Cognome__c ||el.Telefono__c;
        });
        */ /*
        var formMap = {};
        //Bonifazi Giorgio 19/07/2019: Caring Angel Fase 2 - START
        var listForm = [component.get("v.isVisibleSTEP1"), component.get("v.isVisibleSTEP2"), component.get("v.isVisibleSTEP3"), component.get("v.isVisibleSTEP4"), component.get("v.isVisibleSTEP5"), component.get("v.isVisibleSTEP6"), component.get("v.isVisibleSTEP7"),component.get("v.isVisibleSTEP8"),component.get("v.isVisibleSTEP9")];
        
        //Bonifazi Giorgio 19/07/2019: Caring Angel Fase 2 - END
        for(var i = 0; i<listForm.length; i++)
        {
            formMap[(i+1)] = listForm[i];
        }
        for(var key in formMap)
        {
            if(formMap[key] == true)
            {
                component.set("v.isVisibleSTEP"+key, false);
                if(action=="next"){ 
                    
                    console.log("PAGINA"+ key);
                    //Giorgio Bonifazi CAI DIGITALE START
                    
                    
                    if(key=="5" && component.get("v.questionarioCA.Presenza_Testimoni__c") == "Sì" && component.get("v.questionarioCA.Feriti__c")=="Sì"){
                       
                        component.set("v.isVisibleSTEP"+(parseInt(key)+1), true);   
                    }
                    else if(key=="6" && component.get("v.questionarioCA.Feriti__c") == "Sì" && (component.get("v.questionarioCA.Presenza_Testimoni__c")=="No" || component.get("v.questionarioCA.Presenza_Testimoni__c")=="")){

                        component.set("v.isVisibleSTEP"+(parseInt(key)+2), true);
                    }
                    else if(key=="5" && (component.get("v.questionarioCA.Feriti__c") == "No" || component.get("v.questionarioCA.Feriti__c")=="") && component.get("v.questionarioCA.Presenza_Testimoni__c")=="Sì"){

                        component.set("v.isVisibleSTEP"+(parseInt(key)+2), true);
                    }
                    else if(key=="5" && (component.get("v.questionarioCA.Feriti__c") == "No" || component.get("v.questionarioCA.Feriti__c")=="") && (component.get("v.questionarioCA.Presenza_Testimoni__c")=="No" || component.get("v.questionarioCA.Presenza_Testimoni__c")=="")){

                        component.set("v.isVisibleSTEP"+(parseInt(key)+3), true);
                    }
                    else
                    //Giorgio Bonifazi CAI DIGITALE END
                    component.set("v.isVisibleSTEP"+(parseInt(key)+1), true); 
                    
                    if ((parseInt(key)+1) == "5"  && component.get("v.condControparteUgualeContr"))
                     helper.copiaDatiControparteContraenteInConducente(component, event, helper);
                    
                }                   
                else if(action=="previous"){
                  
                    //Giorgio Bonifazi CAI DIGITALE START
                    if((key=="8" || key =="9") && component.get("v.questionarioCA.Feriti__c") == "Sì" && component.get("v.questionarioCA.Presenza_Testimoni__c")=="Sì"){
                       
                        component.set("v.isVisibleSTEP"+(parseInt(key)-1), true);   
                    }
                    else if(key=="8" && component.get("v.questionarioCA.Feriti__c") == "Sì" && (component.get("v.questionarioCA.Presenza_Testimoni__c")=="No" || component.get("v.questionarioCA.Presenza_Testimoni__c")=="")){

                        component.set("v.isVisibleSTEP"+(parseInt(key)-2), true);
                    }
                    else if(key=="7" && (component.get("v.questionarioCA.Feriti__c") == "No" || component.get("v.questionarioCA.Feriti__c")=="") && component.get("v.questionarioCA.Presenza_Testimoni__c")=="Sì"){

                        component.set("v.isVisibleSTEP"+(parseInt(key)-2), true);
                    }
                    else if(key=="8" && (component.get("v.questionarioCA.Feriti__c") == "No" || component.get("v.questionarioCA.Feriti__c")=="") && (component.get("v.questionarioCA.Presenza_Testimoni__c")=="No" || component.get("v.questionarioCA.Presenza_Testimoni__c")=="")){

                        component.set("v.isVisibleSTEP"+(parseInt(key)-3), true);
                    }
                    
                    else
                    //Giorgio Bonifazi CAI DIGIATLE END
                   component.set("v.isVisibleSTEP"+(parseInt(key)-1), true);
                   
                   if ((parseInt(key)-1) == "5"  && component.get("v.condControparteUgualeContr"))
                   helper.copiaDatiControparteContraenteInConducente(component, event, helper);
                }
                    
                //copia dati contraente in conducente -- START
                if(key == "1" && component.get("v.condUgualeContr"))
                {
                    helper.copiaDatiContraenteInConducente(component, event, helper);
                }

                
                //MOSCATELLI_M 16/11/2018: Caring Angel CR -- START
                if(key=="2" && action=="next")
                {
                    helper.generaLuogoEvento(component,event,helper);
                }
                //MOSCATELLI_M 16/11/2018: Caring Angel CR -- END
                
                //copia dati contraente in conducente -- END
                

                
                
            }   

        }
    },*/
   
      performStep : function(component, event, helper)
    {   
        console.log("LISTA",component.get("v.testimoniList"));
        console.log('performStep method');
        let action =  event.getSource().get("v.name");
        let index= component.get("v.IndexCurrPage");
        let pages = component.get("v.sortOrderPage");
        
        console.log('performStep action '+ action);
        console.log('performStep index '+ index);
        console.log('performStep pages '+ pages);
        
        var checkValidate = helper.checkValidate(component, event, helper,pages[index]);
        
        if (checkValidate){
        if(action=="next"){ 
            component.set(pages[index],false);
            component.set("v.IndexCurrPage",index+1);  
            component.set(pages[index+1], true); 
            console.log('pages +1' + pages[index+1] );
            
            helper.setProgressBar(component, event, helper,action, pages[index], pages[index+1]); 
            
        }  else if(action=="previous"){           
            component.set(pages[index],false);
            component.set("v.IndexCurrPage",index-1);  
            component.set(pages[index-1], true);  
             helper.setProgressBar(component, event, helper,action, pages[index], pages[index-1]); 
            
        }
        

       var scrollDiv = document.getElementById('scrollDiv');
           scrollDiv.scrollTop = 0;
     
        
        if (pages[component.get("v.IndexCurrPage")]==="v.isVisibleSTEP3" && component.get("v.condUgualeContr") && component.get("v.OpeningMethod") === "insert"){
              helper.copiaDatiContraenteInConducente(component, event, helper);
        }
        
        if (pages[component.get("v.IndexCurrPage")]==="v.isVisibleSTEP5" && component.get("v.condControparteUgualeContr") && component.get("v.OpeningMethod") === "insert"){
              helper.copiaDatiControparteContraenteInConducente(component, event, helper);
        }
        
        }else
             helper.showToast(component, event, helper, 'error','Errore', 'Controllare gli errori in pagina.');
       
        
    },
   
    ShowOrHideNoteSection : function(component, event, helper)
    {
        console.log('ShowOrHideNoteSection method');
        var Map = {};
        Map['Sì'] = false;
        Map['No'] = true;
        let pick =  event.getSource().get("v.name");
        let value =  event.getSource().get("v.value");
        //console.log('pick : ',pick + ' - value : ',value);
        if(Map[value]==true && pick!=null)
        {
        	//OAVERSANO 23/11/2018 : Caring Angel Enhancement -- START
        	if(pick == "Carroattrezzi")
        	{
        		component.set("v.isVisibleNote"+pick, false);
        	}
        	else
        	{
        		component.set("v.isVisibleNote"+pick, true);
    		}
        }
        else if(Map[value]==false && pick!=null)
        {
        	if(pick == "Carroattrezzi")
        	{
        		component.set("v.isVisibleNote"+pick, true);
        	}
            else
            {
            	component.set("v.isVisibleNote"+pick, false);
            }
            //OAVERSANO 23/11/2018 : Caring Angel Enhancement -- END
        }
    },
    
    salvaQuestionario : function(component, event, helper)
    {
        //ZA prima salva per prendere l'id del questionario
        helper.preControlloSalva(component, event, helper);
        helper.upsertQuestionarioCA(component, event, helper);
        //Giorgio Bonifazi CAI DIGITALE END
    },
    /*handleAssociatePolicyToQuestionarioCA : function(component, event, helper)
    { 
        console.log('handleAssociatePolicyToQuestionarioCA method');
        var policy = event.getParam("policy");
        var listDataSource = ['AAI', 'AMPS','ICBPI'];
        var policyMap = {};
        policyMap['AAI'] = 'AXA Assicurazioni';
        policyMap['AMPS'] = 'AXA MPS';
        policyMap['ICBPI'] = '';
        if(!policy)
        {
            helper.showToast(component, event, helper, 'error', 'Attenzione ! Si è verificato un errore. Si prega di riprovare più tardi.');
        }
        else if(policy!=null)
        {
            helper.showToast(component, event, helper, 'success', 'Polizza associata correttamente');
            if(policy.publicId!=null)
                component.set("v.questionarioCA.Numero_Polizza__c",policy.decodedPolicyId);
            else
                component.set("v.questionarioCA.Numero_Polizza__c",'');
            if(policy.licensePlate!=null)
                component.set("v.questionarioCA.Targa__c",policy.licensePlate);
            else
                component.set("v.questionarioCA.Targa__c",'');
            if(policy.dataSource!=null)
                component.set("v.questionarioCA.Compagnia__c",policyMap[policy.dataSource]);
            else
                component.set("v.questionarioCA.Compagnia__c",'');
            
            console.log("isGoldCustomer: "+event.getParam("isGoldCustomer"));
            if(event.getParam("isGoldCustomer"))
                component.set("v.questionarioCA.Cliente_GOLD__c",true);
            else if(!event.getParam("isGoldCustomer"))
                component.set("v.questionarioCA.Cliente_GOLD__c",false);
            console.log("isGoldCustomer set: "+component.get("v.questionarioCA.Cliente_GOLD__c"));
        }
    },*/
    handleAssociatePolicyToQuestionarioCA : function(component, event, helper) { 
        console.log('handleAssociatePolicyToQuestionarioCA method');
        var policy = event.getParam("policy");
        if(!policy)
        {
            helper.showToast(component, event, helper, 'error', 'Attenzione ! Si è verificato un errore. Si prega di riprovare più tardi.');
        }
        else if(policy!=null)
        {
            if(policy.commonData.nodeCode.startsWith("000729")){
                helper.showToast(component, event, helper, 'warning', 'Attenzione: La targa selezionata è relativa al cliente RCI. Ricordati le caratteristiche di questa gestione');
            }
            else{
                helper.showToast(component, event, helper, 'success', 'Polizza associata correttamente');
            }
            if(policy.publicId!=null){
                console.log('publicId Public public: '+policy.publicId);
                component.set("v.questionarioCA.Numero_Polizza__c",policy.publicId);
            }
            else
                component.set("v.questionarioCA.Numero_Polizza__c",'');
            
            if(policy.portfolio === 'DAOL'){
                component.set("v.questionarioCA.Compagnia__c",'AAI');
                component.set("v.questionarioCA.NumApplicazione__c",policy.numApplicazione);
            }
            else{
                component.set("v.questionarioCA.Compagnia__c",'MPS');
                component.set("v.questionarioCA.NumApplicazione__c",policy.idAdhesion);
            }
            component.set("v.questionarioCA.TECH_NDG__c",policy.commonData.ndg);
            component.set("v.policyNodeCode",policy.commonData.nodeCode);
            component.set("v.questionarioCA.Id_Polizza_SOL__c",policy.policyIdSOl);
            console.log(component.get("v.questionarioCA.Id_Polizza_SOL__c"));
            console.log(component.get("v.questionarioCA.NumApplicazione__c"));
            component.set("v.getPolizzeModal" , false);
            console.log("isGoldCustomer: "+event.getParam("isGoldCustomer"));
            if(event.getParam("isGoldCustomer"))
                component.set("v.questionarioCA.Cliente_GOLD__c",true);
            else if(!event.getParam("isGoldCustomer"))
                component.set("v.questionarioCA.Cliente_GOLD__c",false);
            console.log("isGoldCustomer set: "+component.get("v.questionarioCA.Cliente_GOLD__c"));
            
            console.log('publicId: '+policy.publicId);
            if(policy.licensePlate!=null){
                component.set("v.questionarioCA.Targa__c",policy.licensePlate);
                component.set("v.NonEditTarga",true);
            }
            else {
                component.set("v.questionarioCA.Targa__c",'');
                component.set("v.NonEditTarga",false);
            }

            if(policy.companyCode!=null)
                component.set("v.questionarioCA.Compagnia__c",policy.companyCode);
            else
                component.set("v.questionarioCA.Compagnia__c",'');
            helper.checkPolicyType(component,policy.publicId,helper);
        }
    },
    getPolizze : function(component, event, helper)
    {
        component.set("v.getPolizzeModal" , true);
    },
    chiudiModalePolizze : function(component, event, helper)
    {
        component.set("v.getPolizzeModal" , false);
    },
    findAssociateClient : function(component, event, helper)
    {
        var isFindConducente = component.get('v.isVisibleSTEP3');
        
        if(isFindConducente)
            component.set("v.personaContr","fisica");
        
        let tipoCliente =  event.getSource().get("v.name");
        component.set("v.tipoCliente", tipoCliente);
        component.set("v.findClientModal" , true);
    },
    chiudiModalfindAssociateClient : function(component, event, helper) {
        helper.chiudiModalfindAssociateClient(component);
    },
    handleAssociateClientToQuestionarioCA : function(component, event, helper)
    { 
        console.log('handleAssociateClientToQuestionarioCA method');
        var client = event.getParam("client");
        var clientType = event.getParam("type");
        var persona = event.getParam("persona");
        if(!client)
        {
            helper.showToast(component, event, helper, 'error', 'Attenzione ! Si è verificato un errore. Si prega di riprovare più tardi.');
        }
        else if(clientType == 'contraente' && client!=null)
        {
            helper.showToast(component, event, helper, 'success', 'Contraente associato correttamente');
            helper.populateClientInfo(component, event, helper,client, persona);
            if(client.Id!=null)
            {
                component.set("v.accountIdToUpdate", client.Id);
                component.set("v.questionario.Contraente__c",client.Id);
                component.set("v.accountId",client.Id);//MOSCATELLI_M 18/03/2019: AXA Assistance
                helper.chiudiModalfindAssociateClient(component);
            }
        }
            else if(clientType == 'conducente' && client!=null)
            {
                helper.showToast(component, event, helper, 'success', 'Conducente associato correttamente');
                helper.populateCondClientInfo(component, event, helper,client, persona);
                helper.chiudiModalfindAssociateClient(component);
            }
    },
    chiudiToast : function(component, event, helper) 
    {
        component.set("v.messageToast", "");
        component.set("v.typeToast", "");
        component.set("v.showToast",false);
    },
    returnToCase : function(component, event, helper)
    {
        var idCaseLightning = component.get("v.recordId");

        //MMOSCATELLI 23/11/2018 : Caring Angel Enhancement -- START
        var source = component.get("v.source");
        var idQuestionario = component.get("v.questionarioCaID");
        var idCase = component.get("v.caseId");
        //MMOSCATELLI 23/11/2018 : Caring Angel Enhancement -- END
        
        if(idCaseLightning!='' && idCaseLightning!=null)
        {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            .catch(function(error) {
                console.log(error);
            });
        }
        else
        {
            console.log('returnToCase method');

            if(source!='NewCaseCApage')//MMOSCATELLI 23/11/2018 : Caring Angel Enhancement  
            {            
                let prefix = $A.get("$Label.c.SiteDomain");
                let caseId = component.get("v.caseId");
                window.location.href = prefix+caseId;
                helper.chiudiTab(component,event,helper);
            }
            //MMOSCATELLI 23/11/2018 : Caring Angel Enhancement -- START 
            else
            {
                if(idCase)
                {
                    console.log('##START deleteRecords');
                    component.set("v.AnnullaModal",false);
                    helper.deleteRecords(component,event,helper,idCase,idQuestionario);
                }
            }
            //MMOSCATELLI 23/11/2018 : Caring Angel Enhancement -- END
        }
    },
    showModalAnnulla : function(component, event, helper) 
    {
        component.set("v.AnnullaModal",true);
    },
    chiudiModalAnnulla :  function(component, event, helper) 
    {
        component.set("v.AnnullaModal",false);
    },
    
    creaSinistro : function(component,event,helper)
    {
        
        //ZA prima salva per prendere l'id del questionario start
        component.set("v.sinistro",true);
        helper.preControlloSalva(component, event, helper);
        helper.upsertQuestionarioCA(component,event,helper);
        //ZA prima salva per prendere l'id del questionario fine
        
        //helper.nuovoSinistro(component,event,helper);
        //now upsert alldata from status vars now
        //var saveSurvey = $A.get("e.c:saveSurveyEvent");     
        //saveSurvey.fire();   
    },
    endQuestionario : function(component,event,helper)
    {   
        if(component.get("v.questionarioCA.Presenza_Testimoni__c") == "No" || component.get("v.questionarioCA.Presenza_Testimoni__c") == ""){  
   
            component.set("v.testimoniList",[]);
            
            }   
    
            if(component.get("v.questionarioCA.Feriti__c")=="No"||component.get("v.questionarioCA.Feriti__c")==""){
    
                component.set("v.feritiList",[]);
            
            }
            //Giorgio Bonifazi CAI DIGITALE START
            var arraytestimoni = component.get("v.testimoniList");
            var arrayferiti = component.get("v.feritiList");
            var newArrayTestimoni=arraytestimoni.filter(function(el) {
                
                if(!el.Nome__c || !el.Cognome__c ){
                    
                    return true;
                }
                
                    return false;
            }).length;
            var newArrayFeriti = arrayferiti.filter(function(el) {
                
                if(!el.Nome__c || !el.Cognome__c ){
                    
                    return true;
                }
                
                    return false;
            }).length;
            if(newArrayTestimoni>0){
    
                helper.showToast(component, event, helper, 'error', 'Attenzione ! Inserire il Nome e il Cognome per i Testimoni / Feriti');
                return;
            }else if(newArrayFeriti>0){
                helper.showToast(component, event, helper, 'error', 'Attenzione ! Inserire il Nome e il Cognome per i Testimoni / Feriti');
                return;
            }
            
            else{
                var newArrayTestimoniNoEmpty = arraytestimoni.filter(function(el){
    
                    return Object.keys(el)
                        .filter(function(el){
                            return el !== 'sobjectType'
                        })
                        .reduce(function(previous,current){
        
                            return previous || el[current]
                    },false)
        
                });
                component.set("v.testimoniList",newArrayTestimoniNoEmpty);
        
                
                var newArrayFeritiNoEmpty = arrayferiti.filter(function(el){
        
                    return Object.keys(el)
                        .filter(function(el){
                            return el !== 'sobjectType'
                        })
                        .reduce(function(previous,current){
        
                            return previous || el[current]
                    },false)
        
                });
                component.set("v.feritiList",newArrayFeritiNoEmpty);}
            console.log('salvaQuestionario method');
            component.set("v.SaveButtonPressed","Salva");
            
        component.set("v.SaveButtonPressed","Fine");
        
        var steps=component.get("v.steps");         
        var profiloCorrente = component.get("v.UsrProfile");
        
        if(profiloCorrente =="Caring Angel - Supervisor" || profiloCorrente == "Caring Angel - Supporto HD2" || profiloCorrente =="Caring Angel - Supporto HD2 Supervisor" )
                steps[(steps.length)-1].completed='Y';
            else
                steps[(steps.length)-2].completed='Y'; 
        component.set("v.steps", steps);
        component.set("v.questionarioCA.Codice_fiscale_controparte__c",component.get("v.CodiceFiscaleControparte"));
		console.log("Codice Fiscale Controparte: " + component.get("v.questionarioCA.Codice_fiscale_controparte__c"));        
        helper.upsertQuestionarioCA(component,event,helper);
        //Giorgio Bonifazi CAI DIGITALE END
    },//Giorgio Bonifazi - Caring Angel Fase 2 - START
    AssegnaCaseHD2: function(component, event, helper) {
        component.set("v.isOpen", true);
    },
    closeModel: function(component,event,helper){
        component.set("v.isOpen", false);
    },
    //Giorgio Bonifazi CAI DIGITALE START
    closeModelANIAOK: function(component,event,helper){
        component.set("v.AniaServiceOK", false);
    },
    //Giorgio Bonifazi CAI DIGITALE END
    countCharacters: function(component,event,helper){
        let value =  event.getSource().get("v.value");
        let charactersN = value.length;
        component.set("v.remainingCharacters",1000-charactersN);
    },
    updateattachmentlst : function(component,event,helper){
        var value = event.getParam("param");
        component.set("v.attachmentnamelist",value);
        //Giorgio Bonifazi - Caring Angel Fase 2 - START
        var fileList = component.get("v.attachmentnamelist");
        
        if(fileList.length > 0){
            component.set("v.questionarioCA.CheckFileAllegati__c","Sì");}
        //Giorgio Bonifazi - Caring Angel Fase 2 - END
        
    },
    openAddAttachment: function(component,event,helper){
        component.set("v.showAttachmentBox", true);
    },
    closeAddAttachment: function(component,event,helper){
        component.set("v.showAttachmentBox", false);
    },

    toggle : function(component, event, helper){
        var motivo = component.get("v.questionarioCA.Motivo_trasferimento__c");
        if(motivo != "Altro"){
        component.set("v.MandatoryInputsMissing", false);}
    },
    //Giorgio Bonifazi - Caring Angel Fase 2 - START
    clickCreate : function(component, event, helper) {
        var comm = component.get("v.questionarioCA.Description__c");
        var motivo = component.get("v.questionarioCA.Motivo_trasferimento__c");
        
        var fileList =component.get("v.attachmentnamelist");
        
        if((comm === undefined && motivo == "Altro")||(comm === undefined && motivo == "" && fileList.length ==0 )){
            component.set("v.error", 'Attenzione! Non è stato inserito alcun commento');
            component.set("v.MandatoryInputsMissing", true);
        }
        else if(comm===undefined && motivo !=="Altro"){
            component.set("v.questionarioCA.Description__c","");
            component.set("v.SaveButtonPressed","Fine");
            helper.upsertQuestionarioCA(component,event,helper);
        }
        else if ((comm.length == 0  && motivo == "Altro")||(comm.length == 0 && motivo == "" && fileList.length ==0 )){
            component.set("v.error", 'Attenzione! Non è stato inserito alcun commento');
            component.set("v.MandatoryInputsMissing", true);
           
        } else{
        
        component.set("v.SaveButtonPressed","Fine");
        helper.upsertQuestionarioCA(component,event,helper);}

    },
    //Giorgio Bonifazi - Caring Angel Fase 2 - END
    VerifyANIA : function(component, event, helper) {

        console.log('targa contraente' ,component.get("v.questionarioCA.Targa__c"));
        console.log('polizza' ,component.get("v.questionarioCA.Numero_Polizza__c"));
        console.log('codice fiscale' ,component.get("v.questionarioCA.Codice_fiscale_contraente__c"));
        console.log('targa controparte' ,component.get("v.questionarioCA.Targa_controparte__c"));
        if(component.get("v.questionarioCA.Targa__c")==undefined || component.get("v.questionarioCA.Numero_Polizza__c")== undefined|| component.get("v.questionarioCA.Codice_fiscale_contraente__c")== undefined || component.get("v.questionarioCA.Targa_controparte__c")==undefined || component.get("v.questionarioCA.Email_Contraente__c")==undefined){

            console.log('**********');

            helper.showToast(component, event, helper, 'error', 'Attenzione ! Per procedere con la verifica ANIA, inserire tutti i dati: Targa , Numero Polizza, Codice Fiscale, Email e la Targa della controparte');

        }
        else{
                var personId = component.get("v.questionarioCA.Codice_fiscale_contraente__c");
                var policyId = component.get("v.questionarioCA.Numero_Polizza__c");
                var publicId = component.get("v.questionarioCA.Numero_Polizza__c");
                var plateCounterParties = component.get("v.questionarioCA.Targa_controparte__c");
                var plate = component.get("v.questionarioCA.Targa__c");
                var action = component.get("c.invokeSicAnia");
                var userId = component.get("v.questionarioCA.Email_Contraente__c");

                        action.setParams({"plate" : plate,
                                        "policyId" : policyId,
                                        "publicId" : publicId,
                                        "personId" : personId,
                                        "userId" : userId,
                                        "plateCounterParties" : plateCounterParties
                                        });

                                    action.setCallback(this,function(response){
                                        var state = response.getState();

                                        if (state === "SUCCESS") {
                                            var result = response.getReturnValue();
                                            console.log('### ',JSON.stringify(result));
                                            component.set("v.AniaStatus",result.status);
                                            if(result.status=='OK'){

                                                component.set("v.CompagniaAssicurativa",result.counterPartiesResponseWrapper.insuranceCompanyDni);
                                                component.set("v.Marca",result.counterPartiesResponseWrapper.make);
                                                component.set("v.Modello",result.counterPartiesResponseWrapper.model);
                                                component.set("v.ProvenienzaVeicolo",result.counterPartiesResponseWrapper.vehicleProvenance);
                                                component.set("v.TipoVeicolo",result.counterPartiesResponseWrapper.vehicleType);
                                                

                                                component.set("v.AniaServiceOK", true);
                                                
                                            }
                                            else if(result.status=='KO'){
                                                
                                                helper.showToast(component, event, helper, 'warning', 'Attenzione ! Il servizio ha risposto con un KO, non è possibile verificare i dati della controparte');
                                            }
                                            
                                        }
                                        else if (state === "ERROR") {
                                            var errors = response.getError();
                                                if (errors) {
                                                    if (errors[0] && errors[0].message) {
                                                            console.log("Error message: " +errors[0].message);                                
                                                    }
                                                } 
                                            }
                                        
                                    
                                    });
                                    $A.enqueueAction(action);
            }
    },
	//r.valente
    calculateFiscalCode : function (component , event, helper){
       var surname = component.get("v.questionarioCA.Cognome_Controparte__c");
       var name = component.get("v.questionarioCA.Nome_controparte__c");
       var city = component.get("v.questionarioCA.Comune_di_Nascita_Controparte__c");
       var province = component.get("v.questionarioCA.Provincia_Nascita_Controparte__c");
       var birthDate = ''+component.get("v.questionarioCA.Data_di_nascita_controparte__c");
       var gender = component.get("v.questionarioCA.Sesso_Controparte__c");
        
        if ( surname && name && city && province && birthDate && gender ){

       var action = component.get("c.calculateFiscalCodeCtrl");
            action.setParams({"surname" : surname,
                              "firstName" : name,
                              "city" : city,
                              "province" : province,
                              "birthdate" : ''+birthDate,
                              "gender" : gender
                            });

                          action.setCallback(this,function(response){
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                	var result = response.getReturnValue();
                                	console.log('### fiscalCode'+result);
                                	component.set("v.Codice_fiscale_controparte__c",result);
                                    component.set("v.CodiceFiscaleControparte",result);
                                
                            }
                            else if (state === "ERROR") {
                                var errors = response.getError();
                                    if (errors) {
                                        if (errors[0] && errors[0].message) {
                                                console.log("Error message: " +errors[0].message);                                
                                        }
                                    } 
                                }
                                
                        });
                        $A.enqueueAction(action);
        }
    
	},
    
    calculateFiscalCodeContr : function (component , event, helper){
       var surname = component.get("v.questionarioCA.Cognome_Controparte_Contr__c");
       var name = component.get("v.questionarioCA.Nome_Controparte_Contr__c");
       var city = component.get("v.questionarioCA.Luogo_Nascita_Controparte_Contr__c");
       var province = component.get("v.questionarioCA.Provincia_Nascita_Conducente_Contr__c");
       var birthDate = ''+component.get("v.questionarioCA.Data_Nascita_Controparte_Contr__c");
       var gender = component.get("v.questionarioCA.Sesso_Controparte_Contr__c");
       var condControparteUgualeContr = component.get("v.questionarioCA.Sesso_Controparte_Contr__c");
        
        if ( surname && name && city && province && birthDate && gender){

       var action = component.get("c.calculateFiscalCodeCtrl");
            action.setParams({"surname" : surname,
                              "firstName" : name,
                              "city" : city,
                              "province" : province,
                              "birthdate" : ''+birthDate,
                              "gender" : gender
                            });

                          action.setCallback(this,function(response){
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                	var result = response.getReturnValue();
                                	console.log('### fiscalCode'+result);
                                	component.set("v.Codice_Fiscale_Controparte_Contr__c",result);
                                    component.set("v.CodiceFiscaleControparteContr",result);
                                
                            }
                            else if (state === "ERROR") {
                                var errors = response.getError();
                                    if (errors) {
                                        if (errors[0] && errors[0].message) {
                                                console.log("Error message: " +errors[0].message);                                
                                        }
                                    } 
                                }
                                
                        });
                        $A.enqueueAction(action);
        }
    },

    calculateFiscalCodeContrCond : function (component , event, helper){
        var surname = component.get("v.questionarioCA.Cognome_Conducente__c") ;
        var name = component.get("v.questionarioCA.Nome_conducente__c"); 
        var city = component.get("v.comuneNascitaContrCond"); 
        var province = component.get("v.provinciaNascitaContrCond");
        var birthDate = ''+component.get("v.questionarioCA.Data_di_nascita_conducente__c"); 
        var gender = component.find('SessoContrCond').get('v.value'); 
        console.log( 'fiscal code surname '+surname +' name '+  name +' city '+ city + ' prov '+province + ' birt '+birthDate + ' gend ' +gender );
         if ( surname && name && city && province && birthDate && gender ){
 
        var action = component.get("c.calculateFiscalCodeCtrl");
             action.setParams({"surname" : surname,
                               "firstName" : name,
                               "city" : city,
                               "province" : province,
                               "birthdate" : ''+birthDate,
                               "gender" : gender
                             });
 
                           action.setCallback(this,function(response){
                             var state = response.getState();
                             if (state === "SUCCESS") {
                                     var result = response.getReturnValue();
                                     console.log('### fiscalCode'+result);
                                     component.set("v.Codice_fiscale_conducente__c",result);
                                     component.set("v.CodiceFiscaleCondContr",result);
                                 
                             }
                             else if (state === "ERROR") {
                                 var errors = response.getError();
                                     if (errors) {
                                         if (errors[0] && errors[0].message) {
                                                 console.log("Error message: " +errors[0].message);                                
                                         }
                                     } 
                                 }
                                 
                         });
                         $A.enqueueAction(action);
         }
     
     },
    //d.pirelli
    

    onChangeFeriti : function (component , event, helper){       
        var presenzaFeriti = event.getSource().get("v.value");
        console.log('*PresenzaFeriti'+ presenzaFeriti);
    
        var listSortPage=component.get("v.sortOrderPage");
        
        if (presenzaFeriti=='Sì'){
            if(listSortPage.indexOf("v.isVisibleSTEP5")!=-1){           
                listSortPage.splice(listSortPage.indexOf("v.isVisibleSTEP5")+1, 0, "v.isVisibleSTEP6");//add page next v.isVisibleSTEP5
                
            }else{
                listSortPage.push("v.isVisibleSTEP6"); //add page at end
            }            
            
            
              helper.setHideStepPath(component,'STEP4', 'N');  
            
        }else if (presenzaFeriti=='No' || presenzaFeriti=='') {
            
            if(listSortPage.indexOf("v.isVisibleSTEP6") != -1){
                if (component.get("v.questionarioCA.Presenza_Testimoni__c")!='Sì')
                     helper.setHideStepPath(component,'STEP4', 'Y');
              
                console.log('** index of isVisibleSTEP6 ' + listSortPage.indexOf("v.isVisibleSTEP6")); 
                listSortPage.splice(listSortPage.indexOf("v.isVisibleSTEP6"), 1);//remove v.isVisibleSTEP6 
            }
            
           
        }
         component.set("v.sortOrderPage",listSortPage);
         console.log('** sortPage ', listSortPage);   
        
        
    },
    
    onChangeTestimoni : function (component , event, helper) {      
        var presenzaTestimoni = event.getSource().get("v.value");
        console.log('*PresenzaTestimoni'+ presenzaTestimoni);
        var listSortPage=component.get("v.sortOrderPage");
        
        if (presenzaTestimoni=='Sì'){
            if(listSortPage.indexOf("v.isVisibleSTEP6")!=-1){           
                listSortPage.splice(listSortPage.indexOf("v.isVisibleSTEP6")+1, 0, "v.isVisibleSTEP7");//add page next v.isVisibleSTEP6
                
            }else if(listSortPage.indexOf("v.isVisibleSTEP5")!=-1) {
                listSortPage.splice(listSortPage.indexOf("v.isVisibleSTEP5")+1, 0, "v.isVisibleSTEP7");//add page next v.isVisibleSTEP8            
            }else             
                listSortPage.push("v.isVisibleSTEP7"); //add page at end
            
                helper.setHideStepPath(component,'STEP4', 'N');
            
        }else if (presenzaTestimoni=='No' || presenzaTestimoni=='') {
            
            if(listSortPage.indexOf("v.isVisibleSTEP7") != -1){
                if (component.get("v.questionarioCA.Feriti__c")!='Sì')
                     helper.setHideStepPath(component,'STEP4', 'Y');
                console.log('** index of isVisibleSTEP7 ' + listSortPage.indexOf("v.isVisibleSTEP7")); 
                listSortPage.splice(listSortPage.indexOf("v.isVisibleSTEP7"), 1);//remove v.isVisibleSTEP7
                              
            }  
            
        }
        component.set("v.sortOrderPage",listSortPage);  
        console.log('** sortPage ', listSortPage);   
        
        
    },
    
   dataCopy : function (component , event, helper) {
      
       if (component.get("v.condUgualeContr"))       
           helper.copiaDatiContraenteInConducente(component, event, helper);
        },
        
    dataCopyControparte : function (component , event, helper) {
        if (component.get("v.condControparteUgualeContr"))    
            helper.copiaDatiControparteContraenteInConducente(component, event, helper);
        },
     

        
    secondoLivello: function(component,event,helper){
        helper.upsertQuestionarioCA(component, event, helper);
        component.set("v.showInviaAdHD2", true);
        console.log(component.get("v.questionarioCA.Fast_Payment__c"));
    }
})
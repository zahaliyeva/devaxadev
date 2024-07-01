import { LightningElement, api, wire } from 'lwc';
import {  CurrentPageReference  } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class LghtFlowSubTab extends LightningElement {

    @api subFlowApiName;
    @api recordId;

    @wire(CurrentPageReference) pageRef;
    get inputVariables() {

        var ret=[
            {
                name: 'recordId',
                type: 'String',
                value: this.pageRef['attributes']['attributes']['recordId']
            }
        ];
        console.log('Return:',ret);
        return ret;
    }

    @wire(CurrentPageReference)
    setinputeAttributes(CurrentPageReference) {
        if(CurrentPageReference){
            const subFlowApiName = CurrentPageReference.attributes.attributes.subFlowApiName;
            const recordId = CurrentPageReference.attributes.attributes.recordId;

            if(subFlowApiName){
                this.subFlowApiName = subFlowApiName;
                this.recordId = recordId;
            }
        }
    }

    handleStatusChange(event) {
        console.log(event);
        var titolo;
        var messaggio;
        var variante;
        if(event.detail.status === 'FINISHED'){
            const outputVariables = event.detail.outputVariables;
            for (let i = 0; i < outputVariables.length; i++) {
                const outputVar = outputVariables[i];
                if (outputVar.name == "titolo") {
                    titolo = outputVar.value;
                }
                if (outputVar.name == "messaggio") {
                    messaggio = outputVar.value;
               }
               if (outputVar.name == "variante") {
                variante = outputVar.value;
           }
            }
            const alertPopup = new ShowToastEvent({
                title: titolo,
                message: messaggio,
                variant: variante,
                mode: 'sticky'
            });
            this.dispatchEvent(alertPopup);
            
            this.closeTabHandler();
            this.refreshTabHandler();
        }

        if(event.detail.status === 'ERROR'){
                    const messaggio = new ShowToastEvent({
                        title: 'Errore',
                        message: 'Errore nell\'esecuzione del Flow',
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(messaggio);
        }

    }

    async refreshTabHandler() {
        let foucedTabInfo = await this.invokeWorkspaceAPI('getFocusedTabInfo');
        console.log('FocusedTabOnRefresh:',foucedTabInfo);
        await this.invokeWorkspaceAPI('refreshTab', {
            tabId: foucedTabInfo.parentTabId,
            //includeAllSubtabs: true
        })

        //location.reload();
    }

    async closeTabHandler(event) {
        let foucedTabInfo = await this.invokeWorkspaceAPI('getFocusedTabInfo');
        console.log('FocusedTabOnCLose:',foucedTabInfo);
        await this.invokeWorkspaceAPI('closeTab', {
            tabId: foucedTabInfo.tabId,
        })
    }

    invokeWorkspaceAPI(methodName, methodArgs) {
        return new Promise((resolve, reject) => {
            const apiEvent = new CustomEvent("internalapievent", {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    category: "workspaceAPI",
                    methodName: methodName,
                    methodArgs: methodArgs,
                    callback: (err, response) => {
                        if (err) {
                            return reject(err);
                        } else {
                            return resolve(response);
                        }
                    }
                }
            });

            this.dispatchEvent(apiEvent);
        });
    }
}
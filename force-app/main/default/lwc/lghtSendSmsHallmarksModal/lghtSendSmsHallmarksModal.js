import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LghtSendSmsHallmarksModal extends LightningElement {
    @api recordId;
    @api labelButton;
    @api subFlowApiName;
    @api closeCallback
    questionarioId='';
    

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
            
            
            this.refreshTabHandler();
            this.closeCallback();
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

    get inputVariables() {
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
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
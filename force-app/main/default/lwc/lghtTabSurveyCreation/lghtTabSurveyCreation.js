import { LightningElement, api,wire } from 'lwc';
import { FlowAttributeChangeEvent} from 'lightning/flowSupport';
import { NavigationMixin,CurrentPageReference  } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { IsConsoleNavigation, getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';

export default class LghtTabSurveyCreation extends NavigationMixin(LightningElement) {
    @api recordId;
    @api questionarioId;

    
    @wire(CurrentPageReference) pageRef;
    @wire(IsConsoleNavigation) isConsoleNavigation;
    get inputVariables() {
        var ret=[
            {
                name: 'recordId',
                type: 'String',
                value: this.pageRef['attributes']['recordId']
            }
        ];
        console.log('Return:',ret);
        return ret;
    }

    
    
    handleStatusChange(event) {
        console.log(event);
        if(event.detail.status === 'FINISHED'){
            const outputVariables = event.detail.outputVariables;
            for (let i = 0; i < outputVariables.length; i++) {
                const outputVar = outputVariables[i];
                if (outputVar.name == "questionarioId") {
                    this.questionarioId = outputVar.value;
                }
            }
            this.closeCallback();
        }

    }


    closeCallback(questionarioId){
        /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: questionarioId,
                objectApiName: 'Questionario_CA__c',
                actionName: 'view'
			}
        });*/
        if (this.isConsoleNavigation) {
            getFocusedTabInfo().then((tabInfo) => {
                closeTab(tabInfo.tabId);
            }).catch(function(error) {
                console.log(error);
            });
     }
    }
}
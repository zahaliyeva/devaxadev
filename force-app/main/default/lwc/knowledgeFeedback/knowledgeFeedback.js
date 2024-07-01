import { LightningElement, api, track, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';
import TASK_OBJECT from '@salesforce/schema/Task';
import ARTICLE_OBJECT from '@salesforce/schema/Article_Feedback__c';
import REASON_FIELD from '@salesforce/schema/Article_Feedback__c.Feedback_Reason__c';
import saveTask from '@salesforce/apex/TaskManagement.saveTaskFromLWC';

export default class KnowledgeFeedback extends LightningElement {

    @track taskRecord = {objectApiName : 'Task'};
    @track reasonValuesLike;
    @track reasonValuesDislike;
    @api recordId;
    @track likeState = true;
    @track dislikeState = false;
    @track spinner = false;  
    nChar = 255;  
    remainingChartsError = '';

    @wire(getObjectInfo, { objectApiName: ARTICLE_OBJECT}) article;

    @wire(getPicklistValues, {recordTypeId: '$article.data.defaultRecordTypeId',
                            fieldApiName: REASON_FIELD}) reasonPicklist({data, error}){
                                this.spinner = true;
                                this.reasonValuesLike = [];
                                this.reasonValuesDislike = [];
                                if(data){

                                    var indexLike;
                                    var indexDisLike;
                                    
                                    indexLike = data.controllerValues.Thumbs_up;
                                    
                                    
                                    indexDisLike = data.controllerValues.Thumbs_down;
                                    console.log(indexLike, indexDisLike);
                                    console.log(data.values.length);
                                    data.values.forEach((element) => { 
                                        
                                        for(var i = 0; i < element.validFor.length; i++){
                                            if(element.validFor[i] === indexDisLike){
                                                this.reasonValuesDislike.push(element);
                                            }
                                            else if(element.validFor[i] === indexLike) {
                                                this.reasonValuesLike.push(element);
                                            }
                                        }
                                        
                                        
                                    });
                                    
                                    //this.reasonValues = data.values;
                                    this.error = undefined;
                                    
                                }
                                if(error){
                                    this.error = error;
                                    
                                    this.reasonValues = undefined;
                                }
                                this.spinner = false;
                            }

    


                            
    handleLikeButtonClick(){
        this.dislikeState = false;
        this.likeState = true;
        this.taskRecord.TECH_ArticleFeedbackVote__c='Thumbs_up';
    }

    handleDislikeButtonClick(){
        this.dislikeState = true;
        this.likeState = false;
        this.taskRecord.TECH_ArticleFeedbackVote__c='Thumbs_down';
    }

    handleReasonChange(event){
        this.taskRecord.TECH_ArticleFeedbackReason__c=event.target.value;
    }
    
        
         

    

    handleDescriptionChange(event){
        
        //davide pagano idcrm011
        var e = event.target.value;
        var delta= 255 - e.length;
        if (delta < 0){
            this.remainingChartsError='Superato il numero di caratteri disponibili (255)';
            //this.nChar=delta;   

        }else{
            this.remainingChartsError='';
            this.nChar=delta;   
        }
        
        this.taskRecord.TECH_ArticleFeedbackDescription__c=event.target.value;

    }
    get nCharGetter(){
        return this.nChar;
    }
    get charErrorGetter(){
        return this.remainingChartsError;
    }
    handleSubmit(){
        if((!this.taskRecord.TECH_ArticleFeedbackDescription__c || !this.taskRecord.TECH_ArticleFeedbackReason__c) && this.dislikeState){
            this.template.querySelector('lightning-combobox').reportValidity();
            this.template.querySelector('lightning-input').reportValidity();
        }
        else{
        this.spinner = true;
        this.taskRecord.TECH_ArticleFeedbackSource__c='Internal';
        
        this.taskRecord.TECH_ArticleVersionId__c=this.recordId;
        if(this.taskRecord.TECH_ArticleFeedbackVote__c==null) 
            this.taskRecord.TECH_ArticleFeedbackVote__c='Thumbs_up';
        saveTask({taskRecord: this.taskRecord})
        .then(response => {
            console.log(response);
            this.handleSuccess();
        }).catch(error => {
            console.log(error);
            this.handleError(error);
        });
    }
        /*
        
        */
    }

    handleSuccess(){
        this.spinner = false;

        var event = new ShowToastEvent({
            title: 'Operazione riuscita',
            message: 'Feedback salvato con successo.',
            variant: 'success'
        });
        this.dispatchEvent(event);
    }
 
    handleError(error){
        this.spinner = false;
        var errorMessage;
        if(error.message!=null) errorMessage=error.message;
        var event = new ShowToastEvent({
            title: 'Operazione non riuscita',
            message: errorMessage,
            variant: 'error'
        });
        this.dispatchEvent(event);
    }

  

}
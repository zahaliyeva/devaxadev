import { LightningElement, api , track } from 'lwc';
import voteArticle from '@salesforce/apex/CommunityKnowledgeController.voteArticle';
import { LghtAbstract } from 'c/lghtAbstract';

export default class LikeDislike extends LghtAbstract {
  @api articleId;
  @api likeNumber;
  @api dislikeNumber;
  @api likeSelected = false;
  @api disabled = false;
  @track spinner = false;
  isLike = false;
  isDislike = false;

  get likeClass(){
   if(this.isLike)
    return 'focusLike'
  }

  get dislikeClass(){
    if(this.isDislike)
     return 'focusLike'
   }

  get dislikeSelected() {
    return !this.likeSelected;
  }

  async handleLikeClick() {
    this.showSpinner();
    let totalVotes = await voteArticle({
      articleId: this.articleId,
      vote: 'Thumbs_up'
    });
    this.likeNumber = totalVotes;
    this.disabled = true;
    this.dispatchEventData();
    this.isLike = true;
    this.hideSpinner();
  }

  async handleDislikeClick() {
    this.showSpinner();
    let totalVotes = await voteArticle({
      articleId: this.articleId,
      vote: 'Thumbs_down'
    });
    this.dislikeNumber = totalVotes;
    this.disabled = true;
    this.dispatchEventData();
    this.isDislike = true;
    this.hideSpinner();
  }

  dispatchEventData() {
    let data = {
      likes: this.likeNumber,
      dislikes: this.dislikeNumber,
      disabled: this.disabled
    };
    this.dispatchEvent(new CustomEvent('like', { detail: data }));
  }
}
import { LightningElement, api, track } from 'lwc';

export default class ListItem extends LightningElement {
  @api articleId;
  @api title;
  @api question;
  @api answer;
  @api likeNumber;
  @api dislikeNumber;
  @track showPopover = false;
  @track showModalTitle;
  @track disabledLikeComponent = false;

  get showButton() {
    console.log('data button', window.innerWidth, window.innerHeight);
    return window.innerWidth <= 700;
  }

  showModal(event) {
    this.showModalTitle = true;
  }

  closeModal() {
    this.showModalTitle = false;
  }

  handlePopover() {
    this.showPopover = !this.showPopover;
  }

  async handleDisabledLikeComponent(event) {
    this.likeNumber = event.detail.likes;
    this.dislikeNumber = event.detail.dislikes;
    this.disabledLikeComponent = event.detail.disabled;
  }
}
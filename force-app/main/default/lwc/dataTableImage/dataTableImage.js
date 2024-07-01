import { LightningElement, api } from 'lwc';

export default class DataTableImage extends LightningElement {
    @api url;
    @api altText;
}
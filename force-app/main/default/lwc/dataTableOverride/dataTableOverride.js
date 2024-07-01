import LightningDatatable from 'lightning/datatable';
import imageTableControl from './dataTableImageOverride.html';
import paragraphControl from './dataTableParagraphOverride.html';

export default class DataTableOverride extends LightningDatatable {
    static customTypes = {
        image: {
            template: imageTableControl,
            //typeAttributes: ['month']
        },
        paragraph: {
            template: paragraphControl
        }
    };
}
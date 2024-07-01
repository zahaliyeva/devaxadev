import LightningDatatable from "lightning/datatable";
import richTextAreaCustomTemplate from "./richTextAreaCustomTemplate.html";

export default class CustomDataTableFlow extends LightningDatatable {

  static customTypes = {
    richTextAreaCustom: {
      template: richTextAreaCustomTemplate,
      standardCellLayout: true,
      typeAttributes: ["recordId","bodyHTML"],
    }
  };
}
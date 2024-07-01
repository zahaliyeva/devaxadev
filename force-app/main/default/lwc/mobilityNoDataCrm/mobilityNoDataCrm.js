import {
  MobilityAbstract
} from "c/mobilityAbstract";
import {
  track,
  api
} from "lwc";

/**
 * Per importare il noData sul CMP inserire:
 *          HTML --> <c-mobility-no-data show={noData}></c-mobility-no-data>
 *            JS --> this.showNoData(this.records.length === 0);
 */

export default class MobilityNoDataCrm extends MobilityAbstract {

  @api show;
  @api noImage = false;

}
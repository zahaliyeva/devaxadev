/**
 * Created by a.turrini on 2020-02-27.
 * Duplicazione del MassiveCommunicationBatchScheduler per permettere la schedulazione con flag a false
 */

global class MassiveCommunicationBatchScheduler2 implements Schedulable {

    /**
     * Used to start MassiveCommunicationBatch enabling the change status in case of error
     * Status = 'Error Contact Id'
     *
     * @param SC
     */
    global void execute(SchedulableContext SC) {
        MassiveCommunicationBatch mcb = new MassiveCommunicationBatch(false);
        Database.executeBatch(mcb);
    }
}
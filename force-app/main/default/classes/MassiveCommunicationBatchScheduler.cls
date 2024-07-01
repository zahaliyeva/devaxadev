/**
 * Created by francesco on 2019-07-15.
 */

global class MassiveCommunicationBatchScheduler implements Schedulable {

    /**
     * Used to start MassiveCommunicationBatch enabling the change status in case of error
     * Status = 'Error Contact Id'
     *
     * @param SC
     */
    global void execute(SchedulableContext SC) {
        MassiveCommunicationBatch mcb = new MassiveCommunicationBatch(true);
        Database.executeBatch(mcb);
    }
}
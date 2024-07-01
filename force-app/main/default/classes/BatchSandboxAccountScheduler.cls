global class BatchSandboxAccountScheduler implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
    BatchSandboxAccount b = new BatchSandboxAccount();
      database.executebatch(b);
    }
}
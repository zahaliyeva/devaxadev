global class BatchSandboxLeadScheduler implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
    BatchSandboxLead b = new BatchSandboxLead();
      database.executebatch(b);
    }
}
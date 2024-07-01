public without sharing class  BatchSandboxCaseScheduler implements Schedulable
{
  public void execute(SchedulableContext sc)
    {
    BatchSandboxCase b = new BatchSandboxCase();
      database.executebatch(b,100);
    }
}
public class QueueableUser implements Queueable {
    
    private Set<Groupmember> gmToBeAddedClass = new Set<Groupmember>();
    
    public QueueableUser (Set<Groupmember> GmToBeAdded) {
      System.debug('QueueableUser - GmToBeAdded: '+GmToBeAdded);
      for (GroupMember gprMmb : GmToBeAdded) {
        System.debug('QueueableUser - gprMmb: '+gprMmb);
        this.gmToBeAddedClass.add(gprMmb);
      }
       System.debug('QueueableUser - gmToBeAddedClass: '+gmToBeAddedClass);
    }
    
    public void execute(QueueableContext context) {
      insert new List<Groupmember>(gmToBeAddedClass);  
    }
}
public with sharing class ExtrernalServiceQueue implements Queueable, Database.AllowsCallouts  {
    private List<Case> cases;
    public ExtrernalServiceQueue(List<Case> cases) {
        this.cases = cases;
    }

    public void execute(QueueableContext context) {
        ExternalSystemService service = new ExternalSystemService(this.cases);
        service.registerAttendees();
    }

}
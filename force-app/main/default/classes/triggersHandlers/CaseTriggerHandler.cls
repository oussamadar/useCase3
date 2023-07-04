public with sharing class CaseTriggerHandler extends TriggerHandler{

    List<Case> newCaseList = new List<Case>();

    public CaseTriggerHandler() {
      newCaseList = (List<Case>) Trigger.new;
    }

    public override void afterUpdate() {
      CaseTriggerHelper.callExternalService(newCaseList);
    }

    public override void beforeInsert() {
      CaseTriggerHelper.checkCaseIsValid(newCaseList);
    }
}
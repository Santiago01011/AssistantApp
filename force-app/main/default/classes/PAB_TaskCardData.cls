global class PAB_TaskCardData {
    @InvocableVariable @AuraEnabled global String subject;
    @InvocableVariable @AuraEnabled global String status;
    @InvocableVariable @AuraEnabled global String dueDate;
    @InvocableVariable @AuraEnabled global String context;
    @InvocableVariable @AuraEnabled global String description;

    global PAB_TaskCardData(PAB_Task__c t) {
        this.subject = t.Name;
        this.status = t.Status__c;
        this.dueDate = String.valueOf(t.Due_Date__c);
        this.context = t.Context__c;
        this.description = t.Description__c;
    }
}
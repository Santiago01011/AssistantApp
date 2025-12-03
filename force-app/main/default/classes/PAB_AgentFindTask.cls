global with sharing class PAB_AgentFindTask {

    global class TaskCardWrapper {
        @InvocableVariable @AuraEnabled global String taskId;
        @InvocableVariable @AuraEnabled global String subject;
        @InvocableVariable @AuraEnabled global String status;
        @InvocableVariable @AuraEnabled global String dueDate;
        @InvocableVariable @AuraEnabled global String context;
        @InvocableVariable @AuraEnabled global String description;

        global TaskCardWrapper(PAB_Task__c t) {
            this.taskId = t.Id;
            this.subject = t.Name;
            this.status = t.Status__c;
            this.dueDate = String.valueOf(t.Due_Date__c);
            this.context = t.Context__c;
            this.description = t.Description__c;
        }
    }

    global class Request {
        @InvocableVariable public String status;
        @InvocableVariable public String keyword;
        @InvocableVariable public Boolean debug;
    }

    global class TaskCardResults {
        @InvocableVariable @AuraEnabled public List<TaskCardWrapper> tasks;

        global TaskCardResults(List<TaskCardWrapper> tasks) {
            this.tasks = tasks;
        }
    }

    @InvocableMethod(label='Find Assistant Tasks' description='Returns task wrapper objects for card rendering')
    global static List<TaskCardResults> execute(List<Request> requests) {
        List<TaskCardResults> results = new List<TaskCardResults>();

        for (Request req : requests) {
            // Retrieve tasks for the request
            List<PAB_Task__c> tasks = PAB_AgentService.findTasks(req.status, req.keyword);
            // Debug path: return a deterministic set if the request asks for it
            if (req.debug == true) {
                List<TaskCardWrapper> debugWrappers = new List<TaskCardWrapper>();
                debugWrappers.add(new TaskCardWrapper(new PAB_Task__c(Id='a00cf00000B7JkNAAV', Name='Debug Meeting', Status__c='New', Due_Date__c=Datetime.newInstance(2025,12,1,18,15,0), Description__c='Debug sample meeting', Context__c='@Work')));
                debugWrappers.add(new TaskCardWrapper(new PAB_Task__c(Id='a00cf00000B7XQjAAN', Name='Debug Dinner', Status__c='New', Due_Date__c=Datetime.newInstance(2025,12,1,20,0,0), Description__c='Debug sample dinner', Context__c='@Home')));
                results.add(new TaskCardResults(debugWrappers));
                continue;
            }
            List<TaskCardWrapper> wrappers = new List<TaskCardWrapper>();
            for (PAB_Task__c t : tasks) {
                wrappers.add(new TaskCardWrapper(t));
            }
            results.add(new TaskCardResults(wrappers));
        }
        return results;
    }
}
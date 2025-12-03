public with sharing class PAB_Ctrl {
    @AuraEnabled(cacheable=true)
    public static List<PAB_Task__c> getTasks() {
        return [SELECT Id, Name, Status__c, Context__c, Energy_Level__c, Due_Date__c, Description__c 
                FROM PAB_Task__c 
                WHERE Status__c != :PAB_AgentService.STATUS_SOFT_DELETED
                ORDER BY Due_Date__c ASC NULLS LAST, CreatedDate DESC];
    }

    @AuraEnabled
    public static PAB_Task__c saveTask(PAB_Task__c task) {
        upsert task;
        return [SELECT Id, Name, Status__c, Context__c, Energy_Level__c, Due_Date__c, Description__c 
                FROM PAB_Task__c WHERE Id = :task.Id];
    }

    @AuraEnabled
    public static PAB_Task__c updateTaskStatus(Id taskId, String status) {
        if (taskId == null || String.isBlank(status)) {
            return null;
        }
        PAB_Task__c t = new PAB_Task__c(Id = taskId, Status__c = status);
        update t;
        return [SELECT Id, Name, Status__c, Context__c, Energy_Level__c, Due_Date__c, Description__c 
                FROM PAB_Task__c WHERE Id = :taskId];
    }

    @AuraEnabled
    public static PAB_Task__c quickCapture(String description) {
        if (String.isBlank(description)) {
            return null;
        }
        Date today = Date.today();
        PAB_Task__c created = PAB_AgentService.createTask(description, '@Anywhere', today, 'Medium', 'New');
        return [SELECT Id, Name, Status__c, Context__c, Energy_Level__c, Due_Date__c, Description__c 
                FROM PAB_Task__c WHERE Id = :created.Id];
    }

    @AuraEnabled
    public static Boolean deleteTask(Id taskId) {
        if (taskId == null) return false;
        return PAB_AgentService.softDeleteTask(taskId);
    }
}
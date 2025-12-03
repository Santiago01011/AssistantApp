public with sharing class PAB_AgentUpdateTask {
    public class Request {
        @InvocableVariable(label='Task ID' description='ID of the task to update' required=true)
        public String taskId;
        
        @InvocableVariable(label='Status' description='New status' required=false)
        public String status;
        
        @InvocableVariable(label='Description' description='Updated description' required=false)
        public String description;
    }
    
    @InvocableMethod(label='Update Assistant Task' description='Updates the status or description of an existing PAB_Task__c record. USE WHEN: The user explicitly indicates they want to modify or change the status of a task (e.g., "Mark complete", "Change to in progress", "Move to next week", "Reschedule"). NEGATIVE CONSTRAINT: Do not use if user is asking a question about their tasks.')
    public static List<PAB_Task__c> execute(List<Request> requests) {
        List<PAB_Task__c> results = new List<PAB_Task__c>();
        for(Request req : requests) {
            PAB_Task__c updated = PAB_AgentService.updateTask(req.taskId, req.description, req.status);
            if (updated != null) {
                results.add(updated);
            }
        }
        return results;
    }
}
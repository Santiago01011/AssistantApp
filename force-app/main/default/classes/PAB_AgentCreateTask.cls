public with sharing class PAB_AgentCreateTask {
    public class Request {
        @InvocableVariable(label='Description' description='Task description' required=true)
        public String description;
        
        @InvocableVariable(label='Context' description='Context (@Home, @Work)' required=false)
        public String context;
        
        @InvocableVariable(label='Due DateTime' description='Due date and time (ISO 8601 format: YYYY-MM-DDTHH:mm:ss)' required=false)
        public String dueDateTime;
        
        @InvocableVariable(label='Energy Level' description='High, Medium, Low' required=false)
        public String energyLevel;
    }
    
    @InvocableMethod(label='Create Assistant Task' description='Creates a new PAB_Task__c record. USE WHEN: The user explicitly states an intent to add, remember, or schedule something (e.g., "Remind me to...", "Add to list..."). NEGATIVE CONSTRAINT: NEVER use this action if the user is asking a QUESTION about their list (e.g., "What do I have?", "Show me my tasks"). Questions should use Find Assistant Tasks instead. Do not hallucinate a task description from a question.')
    public static List<PAB_Task__c> execute(List<Request> requests) {
        List<PAB_Task__c> results = new List<PAB_Task__c>();
        for(Request req : requests) {
            Date dueDate = null;
            if (String.isNotBlank(req.dueDateTime)) {
                try {
                    String cleanDateTime = req.dueDateTime.replaceAll('[Z+].*', '');
                    List<String> dateTimeParts = cleanDateTime.split('T');
                    if (dateTimeParts.size() > 0) {
                        List<String> dateParts = dateTimeParts[0].split('-');
                        if (dateParts.size() == 3) {
                            dueDate = Date.newInstance(
                                Integer.valueOf(dateParts[0]),
                                Integer.valueOf(dateParts[1]),
                                Integer.valueOf(dateParts[2])
                            );
                        }
                    }
                } catch (Exception e) {
                    dueDate = Date.today().addDays(1);
                }
            }
            results.add(PAB_AgentService.createTask(req.description, req.context, dueDate, req.energyLevel, 'New'));
        }
        return results;
    }
}
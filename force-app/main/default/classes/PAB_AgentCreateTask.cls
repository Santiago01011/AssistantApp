/**
 * @description: Invocable action for creating assistant tasks with Agentforce.
 * Returns task in the same format as PAB_AgentFindTask for consistent component rendering.
 */
public with sharing class PAB_AgentCreateTask {
    
    public class Request {
        @InvocableVariable(label='Title' description='Task title/name. Extract concise action statement from user request (e.g., "Buy groceries", "Review project proposal"). Max 255 characters.' required=true)
        public String title;
        
        @InvocableVariable(label='Description' description='Detailed task description. Preserve user intent and any important details provided (e.g., "milk, eggs, bread, vegetables"). Leave empty if title is self-explanatory.' required=false)
        public String description;
        
        @InvocableVariable(label='Context' description='Location or context tag. Use these values when extractable: @Home, @Work, @Computer, @Errands, @Meetings. Leave empty if not specified by user.' required=false)
        public String context;
        
        @InvocableVariable(label='Due Date (ISO 8601)' description='Due date and optional time in ISO format (YYYY-MM-DD or YYYY-MM-DDTHH:mm:ss). Extract from user phrases like "today", "tomorrow", "next Friday", "Dec 15". If user does not specify, leave empty.' required=false)
        public String dueDateTime;
        
        @InvocableVariable(label='Energy Level' description='User energy requirement to complete task. Only set if explicitly mentioned or strongly implied. Allowed values: High, Medium, Low. Examples: "quick 5-min task"=Low, "brainstorm session"=Medium, "deep focus work"=High.' required=false)
        public String energyLevel;
        
        @InvocableVariable(label='User ID' description='System Context: Map the "End User Id" context variable here. If empty or invalid, defaults to current user.' required=false)
        public String userId;
    }
    
    @InvocableMethod(label='Create Assistant Task' description='Creates a new task record. CRITICAL: Only call when user EXPLICITLY states intent to add/schedule/remember something (e.g., "Remind me to...", "Add to my list", "Schedule...", "I need to..."). NEVER use for questions about existing tasks. NEVER hallucinate task details. If user says "What do I need to do?", use Find Assistant Tasks instead.')
    public static List<PAB_TaskResponse> execute(List<Request> requests) {
        List<PAB_TaskResponse> responseList = new List<PAB_TaskResponse>();
        
        for (Request req : requests) {
            PAB_TaskResponse response = new PAB_TaskResponse();
            response.aUserTasks = new AvaiableUserTasks();
            response.aUserTasks.userTasks = new List<TaskCardWrapper>();
            
            try {
                // Parse due date
                Date dueDate = null;
                if (String.isNotBlank(req.dueDateTime)) {
                    dueDate = parseDueDate(req.dueDateTime);
                }
                
                // Get user ID
                Id targetUserId = UserInfo.getUserId();
                if (String.isNotBlank(req.userId)) {
                    try {
                        targetUserId = Id.valueOf(req.userId.trim());
                    } catch (Exception ex) {
                        targetUserId = UserInfo.getUserId();
                    }
                }
                
                // Create task
                PAB_Task__c createdTask = PAB_AgentService.createTask(
                    req.title,
                    req.context,
                    dueDate,
                    req.energyLevel,
                    'New'
                );
                
                // Wrap response in same format as Find Task
                TaskCardWrapper wrapped = new TaskCardWrapper(
                    createdTask.Id,
                    createdTask.Title__c,
                    createdTask.Description__c,
                    createdTask.Context__c,
                    createdTask.Status__c,
                    createdTask.Energy_Level__c,
                    String.valueOf(createdTask.Start_Date__c),
                    String.valueOf(createdTask.Due_Date__c),
                    String.valueOf(createdTask.Completed_Date__c),
                    createdTask.Created_By_Agent__c
                );
                wrapped.Name = createdTask.Name;
                
                response.aUserTasks.userTasks.add(wrapped);
                responseList.add(response);
                
            } catch (Exception ex) {
                // Return error response in same format
                PAB_TaskResponse errorResponse = new PAB_TaskResponse();
                errorResponse.aUserTasks = new AvaiableUserTasks();
                errorResponse.aUserTasks.userTasks = new List<TaskCardWrapper>();
                responseList.add(errorResponse);
            }
        }
        
        return responseList;
    }
    
    /**
     * Parse ISO 8601 date strings and common user date formats
     */
    private static Date parseDueDate(String dateString) {
        if (String.isBlank(dateString)) {
            return null;
        }
        
        try {
            // Handle ISO 8601 format (YYYY-MM-DD or YYYY-MM-DDTHH:mm:ss)
            String cleanDate = dateString.replaceAll('[Z+].*', '').split('T')[0];
            List<String> parts = cleanDate.split('-');
            
            if (parts.size() == 3) {
                return Date.newInstance(
                    Integer.valueOf(parts[0]),
                    Integer.valueOf(parts[1]),
                    Integer.valueOf(parts[2])
                );
            }
        } catch (Exception ex) {
            // Silently fail and return null
        }
        
        return null;
    }
    
    /**
     * Response wrapper matching PAB_AgentFindTask format
     */
    public class PAB_TaskResponse {
        @InvocableVariable
        public AvaiableUserTasks aUserTasks;
    }
    
    public class AvaiableUserTasks {
        public List<TaskCardWrapper> userTasks;
    }
    
    public class TaskCardWrapper {
        @InvocableVariable public String Id;
        @InvocableVariable public String Name;
        @InvocableVariable public String Title;
        @InvocableVariable public String Description;
        @InvocableVariable public String Context;
        @InvocableVariable public String Status;
        @InvocableVariable public String Energy_Level;
        @InvocableVariable public String Start_Date;
        @InvocableVariable public String Due_Date;
        @InvocableVariable public String Completed_Date;
        @InvocableVariable public Boolean Created_By_Agent;
        
        public TaskCardWrapper(String id, String title, String description, String context, String status,
                          String energyLevel, String startDate, String dueDate, String completedDate,
                          Boolean createdByAgent) {
            this.Id = id;
            this.Name = null;
            this.Title = title;
            this.Description = description;
            this.Context = context;
            this.Status = status;
            this.Energy_Level = energyLevel;
            this.Start_Date = startDate;
            this.Due_Date = dueDate;
            this.Completed_Date = completedDate;
            this.Created_By_Agent = createdByAgent;
        }
    }
}
/**
 * @description: This class is responsible for helping the assistant to find user tasks.
 */
public with sharing class PAB_AgentFindTask {
    
    @InvocableMethod(label='Find Assistant Tasks' description='Searches tasks for a user by keyword, status, and context. USE WHEN: User asks "What do I have to do?", "Do I have any tasks about X?"')
    public static List<PAB_TaskResponse> getUserTasks(List<PAB_TaskRequest> requestList) {

        List<PAB_TaskResponse> responseList = new List<PAB_TaskResponse>();
        PAB_TaskResponse response = new PAB_TaskResponse();
        response.aUserTasks = new AvaiableUserTasks();
        response.aUserTasks.userTasks = new List<TaskCardWrapper>();

        if (requestList == null || requestList.isEmpty()) {
            responseList.add(response);
            return responseList;
        }

        PAB_TaskRequest req = requestList[0];
        String keywords = req.keywords;
        String status = req.status;
        String trimmedUserId = req.userId != null ? req.userId.trim() : null;

        if (String.isBlank(keywords)) {
            keywords = '';
            status = null; // When no keyword, retrieve all tasks without status filter
        }

        Id targetUserId = UserInfo.getUserId();
        if (String.isNotBlank(trimmedUserId)) {
            try {
                targetUserId = Id.valueOf(trimmedUserId);
            } catch (Exception ex) {
                targetUserId = UserInfo.getUserId();
            }
        }

        List<PAB_Task__c> tasks = PAB_AgentService.findTasks(status, keywords, targetUserId);

        for (PAB_Task__c t : tasks) {
            String titleVal = (t.Title__c != null && String.isNotBlank(t.Title__c)) ? t.Title__c : (t.Name != null ? t.Name : null);
            TaskCardWrapper wrapped = new TaskCardWrapper(
                t.Id,
                titleVal,
                t.Description__c,
                t.Context__c,
                t.Status__c,
                t.Energy_Level__c,
                String.valueOf(t.Start_Date__c),
                String.valueOf(t.Due_Date__c),
                String.valueOf(t.Completed_Date__c),
                t.Created_By_Agent__c
            );
            
            wrapped.Name = (t.Name != null) ? t.Name : null;
            response.aUserTasks.userTasks.add(wrapped);
        }

        responseList.add(response);
        return responseList;
    }



    public class PAB_TaskRequest {
        @InvocableVariable(label='Search Keyword' description='Fuzzy search term for Task Title/Name, Description, or Context (e.g., "groceries", "project", "urgent"). Leave empty to see all tasks.')
        public String keywords;

        @InvocableVariable(label='Status' description='Filter by status: New, In Progress, Completed, Deferred.')
        public String status;

        @InvocableVariable(label='User ID' description='System Context: Map the "End User Id" context variable here. If empty or invalid, defaults to the current user running the action.' required=false)
        public String userId;
    }

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
public with sharing class PAB_AgentService {

    public static final String STATUS_SOFT_DELETED = 'Deleted';

    public static PAB_Task__c createTask(String description, String context, Date dueDate, String energyLevel, String status) {
        PAB_Task__c t = new PAB_Task__c();
        String titleVal = String.isNotBlank(description) ? description : 'New Task';
        t.Name = titleVal.length() > 80 ? titleVal.substring(0, 77) + '...' : titleVal;
        t.Description__c = description;
        t.Context__c = context;
        t.Status__c = String.isBlank(status) ? 'New' : status;
        t.Energy_Level__c = energyLevel;
        
        if (dueDate != null) {
            t.Due_Date__c = DateTime.newInstance(dueDate.year(), dueDate.month(), dueDate.day());
        } else {
            t.Due_Date__c = DateTime.now().addDays(1).addHours(-DateTime.now().hour()).addMinutes(-DateTime.now().minute()).addSeconds(-DateTime.now().second());
        }
        
        insert t;
        return t;
    }

    public static PAB_Task__c updateTask(String taskId, String description, String status) {
        if (String.isBlank(taskId)) return null;
        
        PAB_Task__c t = new PAB_Task__c(Id = taskId);
        boolean isChanged = false;
        
        if (String.isNotBlank(status)) {
            t.Status__c = status;
            isChanged = true;
        }
        if (String.isNotBlank(description)) {
            t.Description__c = description;
            t.Name = (description.length() > 80) ? description.substring(0, 77) + '...' : description;
            isChanged = true;
        }
        
        if (isChanged) {
            update t;
            return [SELECT Id, Name, Status__c, Description__c, Context__c, Due_Date__c FROM PAB_Task__c WHERE Id = :t.Id];
        }
        return null;
    }

    public static List<PAB_Task__c> findTasks(String status, String titleKeyword, Id ownerId) {
        String query = 'SELECT Id, Name, Title__c, Description__c, Status__c, Energy_Level__c, Start_Date__c, Due_Date__c, Completed_Date__c, Created_By_Agent__c, Context__c, OwnerId FROM PAB_Task__c';
        List<String> clauses = new List<String>();
        Boolean allowDeleted = true;
        if (String.isNotBlank(status) && status.equalsIgnoreCase(STATUS_SOFT_DELETED)) {
            allowDeleted = false;
        }
        if (allowDeleted) {
                clauses.add('Status__c != \'' + String.escapeSingleQuotes(STATUS_SOFT_DELETED) + '\'');
        }
        if (String.isNotBlank(status)) {
            clauses.add('Status__c = \'' + String.escapeSingleQuotes(status) + '\'');
        }
        if (String.isNotBlank(titleKeyword)) {
            String escapedKeyword = String.escapeSingleQuotes(titleKeyword);
            String likeClause = '(Name LIKE \'%' + escapedKeyword + '%\' OR Title__c LIKE \'%' + escapedKeyword + '%\' OR Context__c LIKE \'%' + escapedKeyword + '%\')';
            clauses.add(likeClause);
        }

        // OwnerId filter when provided
        if (ownerId != null) {
              clauses.add('OwnerId = \'' + String.escapeSingleQuotes(String.valueOf(ownerId)) + '\'');
        }

        if (!clauses.isEmpty()) {
            query += ' WHERE ' + String.join(clauses, ' AND ');
        }
        query += ' ORDER BY Due_Date__c ASC NULLS LAST, CreatedDate DESC LIMIT 20';
        return Database.query(query);
    }

    /**
     * Marks the provided tasks as deleted so they can be excluded from assistant queries.
     *
     * @param taskIds task identifiers to mark as deleted
     * @return map of task Id to whether the update succeeded
     */
    public static Map<Id, Boolean> softDeleteTasks(Set<Id> taskIds) {
        Map<Id, Boolean> results = new Map<Id, Boolean>();
        if (taskIds == null || taskIds.isEmpty()) {
            return results;
        }
        List<PAB_Task__c> toUpdate = new List<PAB_Task__c>();
        for (Id taskId : taskIds) {
            toUpdate.add(new PAB_Task__c(Id = taskId, Status__c = STATUS_SOFT_DELETED));
        }
        try {
            Database.SaveResult[] saveResults = Database.update(toUpdate, false);
            for (Integer i = 0; i < saveResults.size(); i++) {
                results.put(toUpdate[i].Id, saveResults[i].isSuccess());
            }
        } catch (DmlException e) {
            for (PAB_Task__c record : toUpdate) {
                results.put(record.Id, false);
            }
        }
        return results;
    }

    /**
     * Marks a single task as deleted and reports whether the update succeeded.
     *
     * @param taskId task identifier to mark as deleted
     * @return true when the status update succeeded
     */
    public static Boolean softDeleteTask(Id taskId) {
        if (taskId == null) {
            return false;
        }
        Map<Id, Boolean> resultMap = softDeleteTasks(new Set<Id>{taskId});
        return resultMap.containsKey(taskId) && resultMap.get(taskId);
    }
}
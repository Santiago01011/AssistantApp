public with sharing class PAB_AgentDeleteTask {
    public class Request {
        @InvocableVariable(label='Task ID' description='ID of task to delete' required=true)
        public String taskId;
    }
    
    @InvocableMethod(label='Delete Assistant Task' description='Deletes an existing PAB_Task__c record. USE WHEN: The user explicitly states they want to remove or delete a task (e.g., "Delete that", "Remove this task", "Get rid of that item"). NEGATIVE CONSTRAINT: Do not use if user is asking a question about their tasks.')
    public static List<Boolean> execute(List<Request> requests) {
        List<Boolean> results = new List<Boolean>();
        if (requests == null || requests.isEmpty()) {
            return results;
        }

        Map<Id, List<Integer>> indexesById = new Map<Id, List<Integer>>();
        Set<Id> idsToDelete = new Set<Id>();

        for (Integer index = 0; index < requests.size(); index++) {
            Request req = requests[index];
            results.add(false);
            if (String.isBlank(req.taskId)) {
                continue;
            }
            try {
                Id recordId = Id.valueOf(req.taskId);
                idsToDelete.add(recordId);
                if (!indexesById.containsKey(recordId)) {
                    indexesById.put(recordId, new List<Integer>());
                }
                indexesById.get(recordId).add(index);
            } catch (Exception e) {
                continue;
            }
        }

        if (idsToDelete.isEmpty()) {
            return results;
        }

        Map<Id, Boolean> deleteResults = PAB_AgentService.softDeleteTasks(idsToDelete);
        for (Id recordId : idsToDelete) {
            Boolean success = deleteResults.containsKey(recordId) && deleteResults.get(recordId);
            if (!indexesById.containsKey(recordId)) {
                continue;
            }
            for (Integer resultIndex : indexesById.get(recordId)) {
                results.set(resultIndex, success);
            }
        }

        return results;
    }
}
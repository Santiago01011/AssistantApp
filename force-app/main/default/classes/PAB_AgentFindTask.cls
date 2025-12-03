global with sharing class PAB_AgentFindTask {

    global class Request {
        @InvocableVariable @AuraEnabled public String keyword;
        @InvocableVariable @AuraEnabled public String status;
    }

    global class TaskCardWrapper {
        @InvocableVariable @AuraEnabled public String Id;
        @InvocableVariable @AuraEnabled public String Name;
        @InvocableVariable @AuraEnabled public String Description_c;
        @InvocableVariable @AuraEnabled public String Status_c;
        @InvocableVariable @AuraEnabled public String Due_Date_c;
        @InvocableVariable @AuraEnabled public String Context_c;
    }

    @InvocableMethod(label='Find Assistant Tasks')
    global static List<List<TaskCardWrapper>> execute(List<Request> requests) {

        List<List<TaskCardWrapper>> resultsList = new List<List<TaskCardWrapper>>();

        for (Request req : requests) {

            List<TaskCardWrapper> taskList = new List<TaskCardWrapper>();

            String query = 'SELECT Id, Name, Description__c, Status__c, Due_Date__c, Context__c FROM PAB_Task__c WHERE 1=1';

            if (String.isNotEmpty(req.status)) {
                query += ' AND Status__c = \'' + String.escapeSingleQuotes(req.status) + '\'';
            }

            if (String.isNotEmpty(req.keyword)) {
                query += ' AND Name LIKE \'%' + String.escapeSingleQuotes(req.keyword) + '%\'';
            }

            query += ' LIMIT 50';

            List<PAB_Task__c> tasks = Database.query(query);

            for (PAB_Task__c t : tasks) {
                TaskCardWrapper wrapper = new TaskCardWrapper();
                wrapper.Id = t.Id;
                wrapper.Name = t.Name;
                wrapper.Description_c = t.Description__c;
                wrapper.Status_c = t.Status__c;
                wrapper.Due_Date_c = (t.Due_Date__c != null ? String.valueOf(t.Due_Date__c) : null);
                wrapper.Context_c = t.Context__c;
                taskList.add(wrapper);
            }

            resultsList.add(taskList);
        }

        return resultsList;
    }
}
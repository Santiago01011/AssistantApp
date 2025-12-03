public with sharing class PAB_AgentBridge {
    @AuraEnabled
    public static Object askAssistant(String userInput) {
        if (String.isBlank(userInput)) return null;
        String lower = userInput.toLowerCase();

        // Simple intent heuristics: if user asks what they have (tomorrow/today), return matching tasks
        if ((lower.contains('what') || lower.contains('what\'s') || lower.contains('what do i have')) && (lower.contains('tomorrow') || lower.contains('today'))) {
            Date targetDate = Date.today();
            if (lower.contains('tomorrow')) targetDate = Date.today().addDays(1);

            List<PAB_Task__c> allTasks = PAB_AgentService.findTasks(null, null);
            List<PAB_Task__c> filtered = new List<PAB_Task__c>();
            for (PAB_Task__c t : allTasks) {
                if (t.Due_Date__c != null) {
                    Date d = t.Due_Date__c.date();
                    if (d == targetDate) filtered.add(t);
                }
            }
            return filtered;
        }

        // Fallback: create a task using same helper as Agent to keep behavior consistent
        // Use '@Anywhere' and today's date as defaults; the Agent console will remain the advanced path.
        Date defaultDate = Date.today();
        PAB_Task__c created = PAB_AgentService.createTask(userInput, '@Anywhere', defaultDate, 'Medium', 'New');
        return created;
    }
}
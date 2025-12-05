// Script to create sample PAB_Task__c records for testing
String currentUserId = UserInfo.getUserId();
List<PAB_Task__c> testTasks = new List<PAB_Task__c>();

testTasks.add(new PAB_Task__c(
    Title__c = 'Review project proposal',
    Description__c = 'Review and provide feedback on the Q1 project proposal document',
    Context__c = '@Work',
    Status__c = 'New',
    Energy_Level__c = 'High',
    Start_Date__c = DateTime.now().addDays(1),
    Due_Date__c = DateTime.now().addDays(3),
    Created_By_Agent__c = true,
    OwnerId = currentUserId
));

testTasks.add(new PAB_Task__c(
    Title__c = 'Buy groceries',
    Description__c = 'Get milk, eggs, bread, and vegetables from the store',
    Context__c = '@Errands',
    Status__c = 'New',
    Energy_Level__c = 'Low',
    Start_Date__c = DateTime.now().addDays(2),
    Due_Date__c = DateTime.now().addDays(2),
    Created_By_Agent__c = false,
    OwnerId = currentUserId
));

testTasks.add(new PAB_Task__c(
    Title__c = 'Prepare presentation slides',
    Description__c = 'Create slides for the team meeting on data analytics trends',
    Context__c = '@Computer',
    Status__c = 'In Progress',
    Energy_Level__c = 'High',
    Start_Date__c = DateTime.now().addDays(1),
    Due_Date__c = DateTime.now().addDays(4),
    Created_By_Agent__c = true,
    OwnerId = currentUserId
));

testTasks.add(new PAB_Task__c(
    Title__c = 'Call dentist',
    Description__c = 'Schedule annual dental checkup appointment',
    Context__c = '@Home',
    Status__c = 'Deferred',
    Energy_Level__c = 'Medium',
    Start_Date__c = DateTime.now().addDays(5),
    Due_Date__c = DateTime.now().addDays(7),
    Created_By_Agent__c = false,
    OwnerId = currentUserId
));

testTasks.add(new PAB_Task__c(
    Title__c = 'Update documentation',
    Description__c = 'Update API documentation with new endpoints and parameters',
    Context__c = '@Computer',
    Status__c = 'New',
    Energy_Level__c = 'Medium',
    Start_Date__c = DateTime.now().addDays(2),
    Due_Date__c = DateTime.now().addDays(5),
    Created_By_Agent__c = true,
    OwnerId = currentUserId
));

testTasks.add(new PAB_Task__c(
    Title__c = 'Morning run',
    Description__c = 'Go for a 5K morning run in the park',
    Context__c = '@Anywhere',
    Status__c = 'New',
    Energy_Level__c = 'High',
    Start_Date__c = DateTime.now().addDays(1),
    Due_Date__c = DateTime.now().addDays(1),
    Created_By_Agent__c = false,
    OwnerId = currentUserId
));

try {
    insert testTasks;
    System.debug('✓ Successfully created ' + testTasks.size() + ' test tasks');
    for (PAB_Task__c task : testTasks) {
        System.debug('  - ' + task.Title__c + ' (ID: ' + task.Id + ')');
    }
} catch (DmlException e) {
    System.debug('✗ Error creating test tasks: ' + e.getMessage());
}

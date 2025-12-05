// Script to assign Agentforce_Task_Agent permissions to the Agentforce bot user
try {
    PermissionSet agentPermSet = [SELECT Id FROM PermissionSet 
                                 WHERE Name = 'Agentforce_Task_Agent236172584_Permissions' LIMIT 1];
    
    User agentUser = [SELECT Id FROM User 
                     WHERE Username LIKE '%agentforce_task_agent%' LIMIT 1];
    
    PermissionSetAssignment existingAssignment = [SELECT Id FROM PermissionSetAssignment 
                                                 WHERE PermissionSetId = :agentPermSet.Id 
                                                 AND AssigneeId = :agentUser.Id LIMIT 1];
    System.debug('✓ Agentforce permission set already assigned to agent user ' + agentUser.Id);
} catch (QueryException e) {
    try {
        PermissionSet agentPermSet = [SELECT Id FROM PermissionSet 
                                     WHERE Name = 'Agentforce_Task_Agent236172584_Permissions' LIMIT 1];
        
        User agentUser = [SELECT Id FROM User 
                         WHERE Username LIKE '%agentforce_task_agent%' LIMIT 1];
        
        PermissionSetAssignment psa = new PermissionSetAssignment(
            PermissionSetId = agentPermSet.Id,
            AssigneeId = agentUser.Id
        );
        insert psa;
        System.debug('✓ Successfully assigned Agentforce_Task_Agent permissions to agent user ' + agentUser.Id);
    } catch (Exception ex) {
        System.debug('✗ Error assigning Agentforce permissions: ' + ex.getMessage());
    }
}

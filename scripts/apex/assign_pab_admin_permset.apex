// Script to assign PAB_Admin permission set to the current user
String currentUserId = UserInfo.getUserId();
PermissionSet pabAdminPermSet = [SELECT Id FROM PermissionSet WHERE Name = 'PAB_Admin' LIMIT 1];

try {
    PermissionSetAssignment existingAssignment = [SELECT Id FROM PermissionSetAssignment 
                                                  WHERE PermissionSetId = :pabAdminPermSet.Id 
                                                  AND AssigneeId = :currentUserId LIMIT 1];
    System.debug('✓ PAB_Admin permission set already assigned to user ' + currentUserId);
} catch (QueryException e) {
    PermissionSetAssignment psa = new PermissionSetAssignment(
        PermissionSetId = pabAdminPermSet.Id,
        AssigneeId = currentUserId
    );
    try {
        insert psa;
        System.debug('✓ Successfully assigned PAB_Admin permission set to user ' + currentUserId);
    } catch (DmlException dmlEx) {
        System.debug('✗ Error assigning PAB_Admin: ' + dmlEx.getMessage());
    }
}

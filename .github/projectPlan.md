Project Context: "The Assistant" (Packageable & Org-Agnostic)
1. The Goal: A Portable "Life OS" We are building a personal assistant application on Salesforce.

Distribution Strategy: This project will be built as a Salesforce Unlocked Package (2GP).

Target Audience: It must be installable in any Salesforce Org (Enterprise, Developer, Scratch) without conflicting with existing metadata.

Future Proofing: The architecture must allow for an eventual transition to a Managed 2GP package for the AppExchange.

2. Architectural Constraints (Org Agnostic)

Prefixing: ALL metadata (Objects, Fields, Classes, LWC) must use a 3-letter prefix to avoid conflicts. Let's use PAB_ (Personal Assistant Bot).

Example: PAB_Assistant_Task__c, PAB_AssistantService, pabDashboard.

No Hardcoding: The code must never reference specific Profile IDs, Role IDs, or Usernames.

Configuration: Use Custom Metadata Types (PAB_Config__mdt) to handle environment-specific settings (like API toggles or default task owners) so the user can configure the app without editing code.

3. The Stack & Components

Data Model: A custom object PAB_Task__c (Do not use standard Task to avoid conflicting with the host org's business processes).

Logic (Apex):

PAB_AgentService: Handles the AI logic.

PAB_Ctrl: Handles the LWC UI.

Crucial: All Apex methods for the UI must be @AuraEnabled(cacheable=true) where possible to support flexible UI usage.

AI Integration (Agentforce):

We will package the Apex Invocable Actions (@InvocableMethod) so they are ready to be used by any Agent in the host org.

We assume the host org will create the Agent manually and link it to our Actions (since Agent metadata is complex to package).

4. The "Assistant" Dashboard (LWC)

Component: pabAssistantDashboard

Design: It must be a self-contained "App Page" component.

Isolation: Use lightning-card and SLDS classes to ensure it looks good regardless of the host org's theme.

Instruction to Copilot: Based on the constraints above, please generate the SFDX Project JSON (sfdx-project.json) configuration for a new package called "AssistantApp" and the Schema Definition (SDL/XML) for the PAB_Task__c object, ensuring the PAB_ prefix is applied strictly.

Why this specific context block?
The PAB_ Prefix: This is the #1 rule for packaging. If you call your object Task__c (generic) and install it in an org that already has a Task__c from another package, the installation will fail. The prefix protects you.

Custom Metadata (PAB_Config__mdt): By telling Copilot to use this, you avoid the trap of hardcoding things. It will generate a settings table so that when you install this in a new org, you just go to "Custom Metadata" to set it up, rather than rewriting Apex.

Invocable Actions: We explicitly tell the AI to package the Actions, not the Agent. This makes the package "Agent-Ready" but doesn't break if the target org doesn't have Agentforce set up yet.
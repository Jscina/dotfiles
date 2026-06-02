---
name: azure-workflow
description: Hard constraint skill for any agent touching Azure. Enforces read-only access — no create, update, or delete operations without explicit user confirmation. Load this before running any az commands.
compatibility: opencode
metadata:
  mcp: azure
  access: read-only
  agents: [builder, debugger]
---

# Azure Workflow

You have access to the `azure` MCP. This skill governs how you use it. The rules here are not guidelines — they are hard stops.

---

## Prohibited commands

Never run any command that mutates Azure resources. This includes but is not limited to:

```
az ... create
az ... update
az ... delete
az ... set
az ... add
az ... remove
az ... deploy
az ... start
az ... stop
az ... restart
az ... reset
```

If you find yourself reaching for any of these, stop. Describe what you would do and why, then wait for explicit user confirmation before proceeding. If the user confirms, document that confirmation before running the command.

---

## Permitted commands

Use these freely for inspection and diagnosis:

```bash
# Resource state
az resource list --resource-group <rg> --output table
az resource show --ids <resource-id>

# Deployments
az deployment group list --resource-group <rg> --output table
az deployment group show --resource-group <rg> --name <name>
az deployment group show \
  --resource-group <rg> \
  --name <name> \
  --query "properties.error"

# Specific resources
az functionapp show --name <name> --resource-group <rg>
az webapp show --name <name> --resource-group <rg>
az storage account show --name <name> --resource-group <rg>
az keyvault show --name <name> --resource-group <rg>

# Logs
az monitor activity-log list --resource-group <rg> --offset 1h
az webapp log tail --name <app> --resource-group <rg>

# What-if (safe simulation — never executes)
az deployment group what-if \
  --resource-group <rg> \
  --template-file <file> \
  --parameters <params>
```

---

## What-if for any proposed deployment change

Before any template change is handed off for execution, always run what-if and show the full output:

```bash
az deployment group what-if \
  --resource-group <rg> \
  --template-file <file> \
  --parameters <params>
```

Summarize the output clearly — what will be created, modified, and deleted. Never skip this step.

---

## Hard stops

- No guessing resource state — if you don't know, run the appropriate `show` or `list` command
- No writes of any kind without a documented, explicit user confirmation in the current conversation
- No assuming a prior confirmation carries forward — each destructive action requires its own confirmation

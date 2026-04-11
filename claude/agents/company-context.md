---
name: company-context
model: claude-sonnet-4-6
description: >
  Template agent for your company-specific context. Customize with internal
  systems, tech stack, business rules, and conventions relevant to your work.
---

# Company Context Agent

This is a blank template. Customize it with information about your employer,
clients, or project-specific context that you want Claude to have in every
session where this agent is invoked.

## How to customize

Add sections with information relevant to your work:

### Internal systems
- System names, stacks, and purposes
- Databases (production vs. staging)
- Access rules (what you can and cannot modify)

### Tech stack conventions
- Default backend and frontend frameworks
- Database engines in use
- Deployment targets

### Critical rules
- Things that must never happen in production
- Compliance requirements
- Security constraints

### Business context
- Domain-specific vocabulary
- Key stakeholders and decision makers
- Project lifecycle conventions

## Privacy recommendation

If this file contains sensitive information (internal system names, credentials
patterns, confidential business rules), keep a private version in
`~/memory/agents/company-context.md` instead of committing it here. Use a
symlink or copy during install if needed.

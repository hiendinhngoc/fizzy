# PRD: GitHub PR Integration

## Problem Statement

Development teams using Fizzy for issue tracking want to link their cards (issues) to GitHub pull requests and have cards automatically close when their associated PRs are merged. Currently, users must manually close cards after merging PRs, which is error-prone and creates extra work.

## Goals

1. Allow users to link GitHub PR URLs to Fizzy cards
2. Support referencing Fizzy cards in GitHub PR descriptions
3. Automatically close linked cards when PRs are merged
4. Maintain multi-tenant security (accounts isolated from each other)

## User Stories

### US1: Link PR URL to Card
**As a** developer
**I want to** paste a GitHub PR URL into a Fizzy card
**So that** I can track which PR addresses this card

**Acceptance Criteria:**
- Card detail view has a field/button to add a GitHub PR link
- Only valid GitHub PR URLs are accepted (https://github.com/owner/repo/pull/123)
- Multiple PRs can be linked to a single card
- PR links display on the card with their current state (open/merged/closed)
- Users can remove PR links

### US2: Reference Card in PR
**As a** developer
**I want to** reference a Fizzy card in my PR description
**So that** the systems stay connected without leaving GitHub

**Acceptance Criteria:**
- PR body can contain Fizzy card URLs (fizzy.com/ACCOUNT/cards/123)
- When PR is merged, referenced cards are identified
- Only cards in accounts with active GitHub integration are affected

### US3: Auto-Close on PR Merge
**As a** developer
**I want** linked cards to automatically close when I merge a PR
**So that** I don't have to manually update Fizzy after merging

**Acceptance Criteria:**
- When a PR is merged on GitHub, Fizzy receives a webhook event
- Cards linked to that PR (via direct link or PR body reference) are closed
- Closure is attributed to the system user (like entropy auto-postpone)
- Card activity shows the closure was triggered by PR merge
- Open cards are closed; already-closed cards are unaffected

### US4: Configure GitHub Integration
**As an** account admin
**I want to** set up the GitHub integration for my Fizzy account
**So that** my team can use the auto-close feature

**Acceptance Criteria:**
- Account settings page has a GitHub Integration section
- Admin can generate a webhook secret
- Instructions explain how to configure the GitHub webhook
- Admin can disable/enable the integration
- Admin can regenerate the webhook secret

## Technical Requirements

### Database Schema

**github_integrations:**
- id (uuid)
- account_id (uuid, unique, not null)
- webhook_secret (string, not null)
- active (boolean, default true)
- created_at, updated_at

**pull_request_links:**
- id (uuid)
- account_id (uuid, not null)
- card_id (uuid, not null)
- github_pr_url (string, not null)
- github_repo_full_name (string)
- github_pr_number (string)
- state (string, default "open")
- created_at, updated_at
- Unique index on [card_id, github_pr_url]
- Index on [github_repo_full_name, github_pr_number]

### API Endpoints

**Incoming (from GitHub):**
- `POST /github/webhooks` - Receive GitHub webhook events

**Internal:**
- `POST /cards/:card_id/pull_request_links` - Link PR to card
- `DELETE /cards/:card_id/pull_request_links/:id` - Remove PR link
- `GET /account/github_integration` - View integration settings
- `POST /account/github_integration` - Create integration
- `DELETE /account/github_integration` - Remove integration

### Security

1. Webhook signature verification using X-Hub-Signature-256
2. Per-account webhook secrets
3. Account isolation - webhooks only affect cards in accounts with matching integration
4. CSRF protection disabled only for webhook endpoint
5. No authentication required for webhook endpoint (signature is the auth)

## Out of Scope

- GitHub App OAuth flow (manual secret configuration only)
- GitHub API calls from Fizzy to GitHub (one-way integration only)
- Comments posted to GitHub PRs when cards change
- Real-time PR state sync (only updates on merge)
- Branch/commit references (PR URLs only)

## Implementation Tasks

1. Create database migrations
2. Create GithubIntegration model
3. Create PullRequestLink model
4. Create Card::PullRequestLinkable concern
5. Create Github::WebhooksController
6. Create Github::ProcessMergedPrJob
7. Create Cards::PullRequestLinksController
8. Create Account::GithubIntegrationsController
9. Add routes
10. Create views for PR links on cards
11. Create views for integration settings
12. Write model tests
13. Write controller tests
14. Write integration tests

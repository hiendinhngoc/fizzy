# GitHub Integration

Automatically close Fizzy cards when linked GitHub pull requests are merged.

## Overview

The GitHub integration allows you to connect your development workflow with Fizzy's card tracking. When you merge a pull request on GitHub, any linked Fizzy cards are automatically closed.

## Setup

### 1. Enable the Integration in Fizzy

1. Go to **Account Settings** in your Fizzy account
2. Find the **GitHub Integration** section
3. Click **Manage GitHub Integration**
4. Click **Enable GitHub Integration**
5. Copy the **Webhook URL** and **Webhook Secret** displayed on the page

### 2. Configure GitHub Webhook

1. Go to your GitHub repository
2. Navigate to **Settings → Webhooks**
3. Click **Add webhook**
4. Configure the webhook:
   - **Payload URL**: Paste the webhook URL from Fizzy
   - **Content type**: Select `application/json`
   - **Secret**: Paste the webhook secret from Fizzy
   - **Which events?**: Select "Let me select individual events" and check **Pull requests**
5. Click **Add webhook**

Repeat for each repository you want to connect.

## Linking Cards to Pull Requests

There are two ways to link a Fizzy card to a GitHub PR:

### Option 1: Add PR Link on Card

1. Open a card in Fizzy
2. Scroll to the **Pull Requests** section
3. Paste the GitHub PR URL (e.g., `https://github.com/owner/repo/pull/123`)
4. Click **Link PR**

The PR will appear under the card with its current state (open/merged).

### Option 2: Reference Card in PR Description

Include a Fizzy card URL in your PR title or description:

```
Fixes https://fizzy.com/1234567/cards/42
```

Or simply:

```
fizzy.com/1234567/cards/42
```

The account number (`1234567`) is visible in your Fizzy URLs.

## What Happens When a PR is Merged

1. GitHub sends a webhook event to Fizzy
2. Fizzy verifies the webhook signature
3. Fizzy finds all cards linked to that PR:
   - Cards with the PR URL added directly
   - Cards referenced in the PR description
4. All linked cards are automatically closed
5. The closure is attributed to the system user in the card's activity log

## Managing the Integration

### View Linked PRs

Each card shows its linked PRs with their current state:
- **open** - PR is still open
- **merged** - PR was merged (card was auto-closed)
- **closed** - PR was closed without merging

### Remove a PR Link

Click the × button next to any PR link to remove it. This won't affect the card's state.

### Disable the Integration

1. Go to **Account Settings → GitHub Integration**
2. Click **Remove Integration**

This stops auto-closing cards but doesn't affect existing PR links.

## Security

- Each Fizzy account has a unique webhook secret
- All incoming webhooks are verified using HMAC-SHA256 signatures
- Only webhooks with valid signatures are processed
- Cards can only be closed within their own account

## Troubleshooting

### Cards Not Auto-Closing

1. **Check webhook configuration**: Ensure the secret matches exactly
2. **Verify the event type**: Only "Pull requests" events should be enabled
3. **Check integration status**: Ensure the integration is active in Fizzy settings
4. **Confirm card reference**: The card URL must be exact (including account number)

### Webhook Delivery Failures

Check GitHub's webhook delivery history:
1. Go to repository **Settings → Webhooks**
2. Click on the Fizzy webhook
3. View **Recent Deliveries**
4. Check response codes (should be `200 OK`)

## Limitations

- Only GitHub.com is supported (not GitHub Enterprise)
- Cards must be explicitly linked or referenced (no automatic matching by title)
- Only PR merge events trigger card closure (not commits or branches)
- The integration is one-way (Fizzy receives events from GitHub, not vice versa)

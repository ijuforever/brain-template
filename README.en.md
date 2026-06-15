# My Brain — Remote Claude Code via LINE / Telegram

> A unified entry point to trigger any Claude Code Skill from LINE or Telegram — no computer needed.
> Querying a private family wiki is the starter example. The real value is running any skill you have already built in Claude Code, straight from your phone.
> Estimated monthly cost: around USD $10 (n8n $5 + Anthropic API $5)
> Canonical file: [README.md](./README.md) | Chinese version: [README.zh.md](./README.zh.md)
> Quickest setup: [GETTING_STARTED.md](./GETTING_STARTED.md) | Chinese fast path: [GETTING_STARTED.zh.md](./GETTING_STARTED.zh.md)

---

## What is this?

This template lets you:
- **Trigger any Claude Code Skill remotely** from LINE or Telegram — update your resume, push to a repo, run a custom skill — without opening a laptop
- Query your private wiki by tagging the bot in a LINE group (WiFi password, insurance info, schedules, and more)
- Say "save to wiki ..." to auto-write to your knowledge base and commit to GitHub
- Use Telegram as a direct personal channel (more stable than LINE for solo use)

**Highlights:**
- Your GitHub repo is your brain: wiki, skills, and memory — all version-controlled
- Scale-to-zero architecture — no idle cost beyond the n8n instance
- Full git history for every knowledge edit
- Dual platform support (LINE for family groups, Telegram for personal control)

---

## Architecture

```text
LINE Group / Telegram
  ↓  Ask the bot
n8n (deployed on Railway)
  ↓  Trigger GitHub Actions
GitHub Actions
  ↓  Run Claude Code CLI and read wiki/
Claude Code (Haiku for lower cost)
  ↓  Return answer
n8n → Push back to LINE/Telegram
```

---

## Quick Start

### 1) Fork this repo

Fork this repo (or use "Use this template") and set it to **Private**.

### 2) Fill your wiki content

Edit `wiki/family/home.md` with family info such as:
- WiFi credentials
- Common contact numbers
- Any recurring family questions

### 3) Configure GitHub Secrets

Go to `Settings > Secrets and variables > Actions` and add:

| Secret | Description | Where to get it |
|---|---|---|
| `ANTHROPIC_API_KEY` | Anthropic API key | console.anthropic.com |
| `OWNER_LINE_USER_ID` | Your LINE user ID | LINE Developers Console |
| `ALLOWED_LINE_USER_IDS` | Comma-separated LINE user IDs allowed to query | Collect from n8n logs |
| `OWNER_TELEGRAM_USER_ID` | Your Telegram user ID (optional) | Send `/start` to @userinfobot |
| `N8N_WEBHOOK_URL` | n8n webhook URL for GitHub callback | Step 5 below |
| `N8N_WEBHOOK_SECRET` | Random secret to authenticate GitHub→n8n calls | Generate any random string |

> **GitHub PAT**: Use a **fine-grained personal access token** scoped to this repo only, with **Contents: Read and Write** permission. Avoid classic PATs with broad scopes.

> How to find your LINE user ID: send a message, then read `source.userId` from your n8n logs.

### 4) Create a LINE Messaging API bot

1. Go to [LINE Developers Console](https://developers.line.biz/)
2. Create a Provider, then create a Messaging API channel
3. Add your bot into your family group
4. Copy the **Channel Access Token** (for n8n)

### 5) Deploy n8n

Recommended: deploy with Railway:

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/n8n)

Direct link: <https://railway.app/template/n8n>

Then import both workflows from the `n8n/` folder:

**Workflow A (`workflow1-incoming.json`)** — Receives LINE/Telegram messages and triggers GitHub Actions

**Workflow B (`workflow2-outgoing.json`)** — Receives GitHub callback and pushes reply to LINE/Telegram

Set credentials in n8n. For each Header Auth credential, the exact values are:

| Credential name | Header name | Header value |
|---|---|---|
| `GitHub PAT` | `Authorization` | `Bearer <your fine-grained PAT>` |
| `LINE channel token` | `Authorization` | `Bearer <LINE channel access token>` |
| `Brain Webhook Secret` | `X-Brain-Token` | `<your N8N_WEBHOOK_SECRET>` |

> **Required n8n env vars** (Railway: service → Variables tab):
> - `LINE_CHANNEL_SECRET` — your LINE channel secret (required; missing = all LINE messages rejected)
> - `NODE_FUNCTION_ALLOW_BUILTIN=crypto` — allows the signature verification Code node to run
>
> For Workflow B: Webhook node → Authentication → Header Auth, name `X-Brain-Token`, value = `N8N_WEBHOOK_SECRET`.

> **Note**: This template includes reference n8n workflows. Please import and test them in your own n8n instance before using with real family data.

### 6) Test

LINE test: send `@your-bot-name What is our WiFi password?` in your group.

---

## Before Going Live Checklist

- Keep your GitHub repository private
- Enable webhook verification in n8n (`LINE_CHANNEL_SECRET` and `X-Brain-Token`)
- Use a fine-grained GitHub PAT with the smallest required repo scope
- Enable 2FA on GitHub, n8n, LINE, and Telegram accounts
- Do not store bank passwords, national ID numbers, 2FA codes, or complete financial credentials in `wiki/`
- Test the imported n8n workflows with sample data before adding real family data

---

## Expand the Knowledge Base

Add more wiki folders as needed:

```text
wiki/
├── family/
│   └── home.md
├── finance/
│   └── index.md
└── health/
    └── index.md
```

Then update keyword routing in `.github/workflows/agent.yml`.

---

## Cost Estimate

| Item | Cost |
|---|---|
| n8n (Railway starter plan) | USD $5/month |
| Anthropic API (Haiku, usage-based) | USD $3–8/month (depends on usage) |
| GitHub Actions | Free (2,000 min/month on private repo) |
| LINE Messaging API | Free (within monthly quota) |
| **Total** | **About USD $8–13/month** |

---

## FAQ

**Q: Why is response time slow sometimes?**  
A: GitHub Actions cold start is usually 30–60 seconds. If this is unacceptable, switch to an always-on setup.

**Q: Can I use OpenAI instead of Claude?**  
A: Yes, but you must update the CLI command and workflow logic in `.github/workflows/agent.yml`.

**Q: Is my family data exposed?**  
A: Your wiki content is included in prompts sent to Anthropic's API for processing. Anthropic's API terms prohibit using API inputs for model training, but your data does leave your infrastructure. Keep sensitive information out of the wiki, or accept this trade-off knowingly.

**Q: Can I allow more family members?**  
A: Yes. Add their LINE user IDs to `ALLOWED_LINE_USER_IDS` in GitHub Secrets, and update the whitelist in n8n Workflow A.

---

## Credit

- Architecture: [Iju](https://ijuhsu.com)
- Inspiration: [Andrej Karpathy's personal wiki](https://github.com/karpathy/lexicap)

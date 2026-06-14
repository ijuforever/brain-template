# My Brain — LINE + Telegram Family Assistant Template

> Build your private AI assistant with GitHub + Claude Code CLI, then use LINE or Telegram to ask questions only your family would know.
> Estimated monthly cost: around USD $10 (n8n $5 + Anthropic API $5)
> Chinese version: [README.zh.md](./README.zh.md)
> Quickest setup: [GETTING_STARTED.md](./GETTING_STARTED.md) | 中文快速版: [GETTING_STARTED.zh.md](./GETTING_STARTED.zh.md)

---

## What is this?

This template lets you:
- Query your private wiki in a LINE group by tagging your bot (WiFi password, insurance info, schedules, and more)
- Ask the bot directly on Telegram (often more stable when LINE push delivery fails)
- Say "save to wiki ..." to auto-write knowledge and commit to GitHub
- Reuse your Claude Code Skills remotely through LINE / Telegram

**Highlights:**
- Wiki files stay in your private repo; prompts are sent to Anthropic's API for processing
- Scale-to-zero architecture to reduce idle costs
- Full git history for every knowledge edit
- Dual platform support (LINE + Telegram), with Telegram as backup

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
| `N8N_WEBHOOK_SECRET` | A random secret string to authenticate GitHub→n8n calls | Generate any random string |

> **GitHub PAT**: When creating the token for n8n to trigger GitHub Actions, use a **fine-grained personal access token** scoped to this repo only, with **Contents: Read and Write** permission. Avoid classic PATs with broad scopes.

> How to find your LINE user ID:
> LINE Developers Console -> your channel -> webhook settings.  
> Send a message, then read `source.userId` from your n8n logs.

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

> **Security — Workflow B**: Go to its Webhook node → Authentication → Header Auth, set header name `X-Brain-Token`, value = your `N8N_WEBHOOK_SECRET`.  
> **Required n8n env vars** (Railway: service → Variables tab):
> - `LINE_CHANNEL_SECRET` — your LINE channel secret
> - `NODE_FUNCTION_ALLOW_BUILTIN=crypto` — allows the signature verification Code node to run
>
> Without these, all incoming LINE messages will be rejected.

### 6) Test

Local test (requires Claude Code CLI):
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
USER_INPUT="What is our WiFi password?" ./scripts/agent.sh
```

LINE test: send `@your-bot-name What is our WiFi password?` in your group.

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
| Anthropic API (Haiku, usage-based) | USD $3-8/month (depends on usage) |
| GitHub Actions | Free (2,000 min/month on private repo) |
| LINE Messaging API | Free (within monthly quota) |
| **Total** | **About USD $8-13/month** |

---

## FAQ

**Q: Why is response time slow sometimes?**  
A: GitHub Actions cold start is usually 30-60 seconds. If this is unacceptable, switch to an always-on setup.

**Q: Can I use OpenAI instead of Claude?**  
A: Yes, but you must update the CLI command and workflow logic in `.github/workflows/agent.yml`.

**Q: Is my family data exposed?**  
A: Your wiki content is included in prompts sent to Anthropic's API for processing. Anthropic's API terms prohibit using API inputs for model training, but your data does leave your infrastructure. Keep sensitive information (passwords, ID numbers, financial details) out of the wiki, or accept this trade-off knowingly.

**Q: Can I allow more family members?**  
A: Yes. Add more user IDs to your whitelist (n8n + workflow secrets).

---

## Credit

- Architecture: [Iju](https://ijuhsu.com)
- Inspiration: [Andrej Karpathy's personal wiki](https://github.com/karpathy/lexicap)

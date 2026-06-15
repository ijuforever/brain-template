# My Brain — Trigger Any Claude Code Skill from Your Phone

> One message on Telegram. Any Claude Code skill runs on GitHub Actions. No laptop needed.
> Estimated monthly cost: around USD $10 (n8n $5 + Anthropic API $5)
> Chinese version: [README.zh.md](./README.zh.md)
> Quickest setup: [GETTING_STARTED.md](./GETTING_STARTED.md) | 中文快速版: [GETTING_STARTED.zh.md](./GETTING_STARTED.zh.md)

---

## What is this?

A template that turns Telegram (or LINE) into a remote control for Claude Code.

```
You send a message → n8n triggers GitHub Actions → Claude Code runs in your repo → reply comes back to your phone
```

Your GitHub repo is the brain: wiki content, Claude Code skills, memory — all version-controlled, all triggerable from your phone.

**The starter example is a family wiki bot** (query WiFi passwords, save notes, answer household questions). But the real point is the architecture — once it is wired up, any skill you have built in Claude Code works the same way.

---

## Example Use Cases

| What you send | What runs |
|---|---|
| "What's our WiFi password?" | Reads `wiki/family/home.md` |
| "Save to wiki: plumber John 0912-345-678" | Writes to wiki, commits to GitHub |
| "Update my resume with [new role]" | Runs your resume skill |
| "What's my asset allocation this month?" | Reads your finance wiki |
| Any skill trigger phrase you define | Runs that Claude Code skill |

---

## Architecture

```text
Telegram (primary) / LINE group (optional)
  ↓  Send command or question
n8n (deployed on Railway)
  ↓  Trigger GitHub Actions
GitHub Actions
  ↓  Run Claude Code CLI — read wiki / execute skill
Claude Code
  ↓  Return result
n8n → Push reply back to Telegram / LINE
```

**Why this stack:**
- Scale-to-zero — GitHub Actions only runs when triggered, no idle cost beyond the n8n instance
- Full git history for every wiki edit or skill run
- Telegram as primary (simple setup, no push limits); LINE optional for group use

---

## Quick Start

### 1) Fork this repo

Fork this repo (or use "Use this template") and set it to **Private**.

### 2) Add your content

The starter wiki is at `wiki/family/home.md`. Fill it in with anything you want the bot to know — or skip it and point the agent at your own skills instead.

The agent reads everything under `wiki/` and can invoke any Claude Code skill defined in your repo.

### 3) Configure GitHub Secrets

Go to `Settings > Secrets and variables > Actions` and add:

| Secret | Description | Where to get it |
|---|---|---|
| `ANTHROPIC_API_KEY` | Anthropic API key | console.anthropic.com |
| `OWNER_TELEGRAM_USER_ID` | Your Telegram user ID | Send `/start` to @userinfobot |
| `OWNER_LINE_USER_ID` | Your LINE user ID (if using LINE) | LINE Developers Console |
| `ALLOWED_LINE_USER_IDS` | Comma-separated LINE user IDs allowed to query | Collect from n8n logs |
| `N8N_WEBHOOK_URL` | n8n webhook URL for GitHub callback | Step 5 below |
| `N8N_WEBHOOK_SECRET` | A random secret string to authenticate GitHub→n8n calls | Generate any random string |

> **GitHub PAT**: Use a **fine-grained personal access token** scoped to this repo only, with **Contents: Read and Write** permission. Avoid classic PATs with broad scopes.

### 4) Set up your messaging bot

**Telegram (primary — recommended)**

1. Open Telegram and message [@BotFather](https://t.me/BotFather)
2. Send `/newbot` and follow the prompts to get your **Bot Token**
3. Send `/start` to [@userinfobot](https://t.me/userinfobot) to find your **User ID**
4. Add the Bot Token as a credential in n8n (`Telegram account`)

**LINE (optional — for group use)**

1. Go to [LINE Developers Console](https://developers.line.biz/)
2. Create a Provider, then create a Messaging API channel
3. Add your bot into your group
4. Copy the **Channel Access Token** (for n8n)

### 5) Deploy n8n

Recommended: deploy with Railway:

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com?referralCode=WPRBMu)

Direct link: <https://railway.com?referralCode=WPRBMu>

Then import both workflows from the `n8n/` folder:

**Workflow A (`workflow1-incoming.json`)** — Receives Telegram/LINE messages and triggers GitHub Actions

**Workflow B (`workflow2-outgoing.json`)** — Receives GitHub callback and pushes reply to Telegram/LINE

Set credentials in n8n:

| Credential name | Header name | Header value |
|---|---|---|
| `GitHub PAT` | `Authorization` | `Bearer <your fine-grained PAT>` |
| `LINE channel token` | `Authorization` | `Bearer <LINE channel access token>` |
| `Brain Webhook Secret` | `X-Brain-Token` | `<your N8N_WEBHOOK_SECRET>` |

> **Workflow B Webhook**: Authentication → Header Auth, name `X-Brain-Token`, value = your `N8N_WEBHOOK_SECRET`.
> **Required n8n env vars** (Railway: service → Variables tab):
> - `LINE_CHANNEL_SECRET` — your LINE channel secret (required if using LINE; missing = all LINE messages rejected)
> - `NODE_FUNCTION_ALLOW_BUILTIN=crypto` — allows the signature verification Code node to run

> **Note**: These are reference n8n workflows. Import and test in your own n8n instance before going live.

### 6) Test

Telegram: send any message directly to your bot.

LINE (if configured): send `@your-bot-name What is our WiFi password?` in your group.

---

## Extending with Your Own Skills

The starter template covers wiki queries and wiki writes. To add your own skills:

1. Add your skill files to the repo (Claude Code skills, prompts, or scripts)
2. Update the keyword routing in `.github/workflows/agent.yml` to recognize your trigger phrases
3. Update the agent prompt to describe what each skill does

Example skill folders you might add:

```text
wiki/
├── family/
│   └── home.md
├── finance/
│   └── index.md
└── health/
    └── index.md
skills/
├── resume.md
└── weekly-review.md
```

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

**Q: Why is response time slow?**
A: GitHub Actions cold start is 30–60 seconds. This is a scale-to-zero trade-off. If latency is unacceptable, switch to an always-on setup.

**Q: Is this overkill if I just want a wiki bot?**
A: Yes — if all you need is wiki queries and you don't care about privacy, just wire n8n directly to an LLM API. This template makes sense when you also want to trigger Claude Code skills remotely.

**Q: Is my data exposed?**
A: Wiki content is included in prompts sent to Anthropic's API. Anthropic's terms prohibit using API inputs for model training, but your data does leave your own infrastructure. Avoid storing highly sensitive information (bank credentials, ID numbers, 2FA codes) in the wiki.

**Q: Can I allow other users?**
A: Yes. Add their Telegram user ID to `OWNER_TELEGRAM_USER_ID` logic, or add LINE user IDs to `ALLOWED_LINE_USER_IDS`.

**Q: Can I use OpenAI instead of Claude?**
A: Yes, but you need to update the CLI command and model logic in `.github/workflows/agent.yml`.

---

## Before Going Live Checklist

- Keep your GitHub repository private
- Enable webhook verification in n8n (`LINE_CHANNEL_SECRET` and `X-Brain-Token`)
- Use a fine-grained GitHub PAT with the smallest required repo scope
- Enable 2FA on GitHub, n8n, LINE, and Telegram accounts
- Do not store bank passwords, national ID numbers, 2FA codes, or complete financial credentials in `wiki/`
- Test the imported n8n workflows with sample data before going live

---

## Credit

- Architecture: [Iju](https://ijuhsu.com)
- Inspiration: [Andrej Karpathy's personal wiki](https://github.com/karpathy/lexicap)

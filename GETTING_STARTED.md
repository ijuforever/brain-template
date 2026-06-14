# 10-Minute Setup (Fast Path)

Use this guide if you want the quickest way to make this template your own.

> Chinese version: [GETTING_STARTED.zh.md](./GETTING_STARTED.zh.md)

## 0) What You Need

- A private GitHub repository (fork or "Use this template")
- An Anthropic API key
- A LINE bot (or Telegram bot)
- A running n8n instance (Railway is the easiest path)

## 1) Fill Your Own Content First (2 minutes)

Edit:

- `wiki/family/home.md`

Replace the placeholders with your own:

- WiFi name/password
- Important contacts
- Any family notes you want the bot to answer

If this file is empty or generic, the bot will be generic too.

## 2) Set Required GitHub Secrets (3 minutes)

Go to `Settings -> Secrets and variables -> Actions` and add:

- `ANTHROPIC_API_KEY`
- `OWNER_LINE_USER_ID`
- `OWNER_TELEGRAM_USER_ID` (if using Telegram)
- `ALLOWED_LINE_USER_IDS` (comma-separated LINE user IDs, no spaces)
- `N8N_WEBHOOK_URL`
- `N8N_WEBHOOK_SECRET` (any random string — must match n8n Workflow B header auth)

Minimal example for `ALLOWED_LINE_USER_IDS`:

```text
U11111111111111111111111111111111,U22222222222222222222222222222222
```

> **GitHub PAT**: Use a fine-grained PAT scoped to this repo only, with **Contents: Read and Write**. Do not use a classic PAT.

## 3) Import n8n Workflows (3 minutes)

Import **both** files:

- `n8n/workflow1-incoming.json`
- `n8n/workflow2-outgoing.json`

For **workflow1**, update these placeholders:

- `YOUR_GITHUB_USERNAME` / `YOUR_REPO_NAME`
- `YOUR_BOT_NAME`
- `YOUR_LINE_USER_ID_1` / `YOUR_LINE_USER_ID_2`
- `YOUR_TELEGRAM_USER_ID`

Set credentials in n8n. For each Header Auth credential, the exact values are:

| Credential name | Header name | Header value |
|---|---|---|
| `GitHub PAT` | `Authorization` | `Bearer <your fine-grained PAT>` |
| `LINE channel token` | `Authorization` | `Bearer <LINE channel access token>` |
| `Brain Webhook Secret` | `X-Brain-Token` | `<your N8N_WEBHOOK_SECRET>` |

Add `Telegram account` credential if using Telegram.

For **workflow2**, after import:

- Go to the Webhook node → Authentication → Header Auth
- Header name: `X-Brain-Token`
- Header value: your `N8N_WEBHOOK_SECRET`

> **Required n8n environment variables** (Railway: service → Variables tab):
> - `LINE_CHANNEL_SECRET` — your LINE channel secret (required for signature verification)
> - `NODE_FUNCTION_ALLOW_BUILTIN=crypto` — allows the Code node to use Node's crypto module
>
> Without these, the Verify LINE Signature node will throw an error and block all incoming LINE messages.

## 4) Smoke Test (2 minutes)

1. Send a question from LINE or Telegram:
   - `@your-bot What is our WiFi password?`
2. Check GitHub Actions — the workflow `My Brain Agent` should have 4 jobs: `detect`, `query`, `write` (skipped), `notify`
3. Confirm the reply arrives back in your chat

If you get "Unauthorized user":

- Check `ALLOWED_LINE_USER_IDS` contains your LINE user ID
- Check `OWNER_TELEGRAM_USER_ID` if using Telegram
- Verify the actual `user_id` in n8n execution logs

## 5) First Personalization Checklist

- Update the bot name mention rule in n8n Workflow A
- Add 5–10 real entries in `wiki/family/home.md`
- Add one extra folder (e.g. `wiki/finance/index.md`)
- Ask 3 real questions your family actually asks

That is enough to turn this into your own working assistant.

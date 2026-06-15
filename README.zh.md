# My Brain — 用手機觸發任何 Claude Code Skill

> 傳一則 Telegram 訊息，任何 Claude Code skill 就在 GitHub Actions 上跑起來。不用開電腦。
> 月費約 USD $10（n8n $5 + Anthropic API $5）
> English version: [README.md](./README.md)
> 最快上手（中文）：[GETTING_STARTED.zh.md](./GETTING_STARTED.zh.md) | English fast path: [GETTING_STARTED.md](./GETTING_STARTED.md)

---

## 這是什麼？

把 Telegram（或 LINE）變成 Claude Code 的遠端遙控器。

```
你傳訊息 → n8n 觸發 GitHub Actions → Claude Code 在你的 repo 裡跑 → 結果推回手機
```

你的 GitHub repo 就是大腦：wiki 知識、Claude Code skills、memory——全部有 version control，全部可以從手機觸發。

**這個 template 的 starter example 是家族 wiki 機器人**（查 WiFi 密碼、儲存筆記、回答家裡的問題）。但重點是這個架構——接好之後，你在 Claude Code 建的任何 skill 都能用同樣的方式觸發。

---

## 使用情境

| 你說什麼 | 執行什麼 |
|---|---|
| 「WiFi 密碼是什麼？」 | 讀取 `wiki/family/home.md` |
| 「幫我記：水電工 John 0912-345-678」 | 寫入 wiki，commit 到 GitHub |
| 「幫我用這段更新履歷：[新職務]」 | 執行你的履歷 skill |
| 「這個月資產配置怎麼樣？」 | 讀取你的財務 wiki |
| 任何你定義的 skill 觸發詞 | 執行對應的 Claude Code skill |

---

## 架構

```text
Telegram（主）/ LINE 群組（選填）
  ↓  傳指令或問問題
n8n（Railway 部署）
  ↓  觸發 GitHub Actions
GitHub Actions
  ↓  執行 Claude Code CLI——讀取 wiki / 執行 skill
Claude Code
  ↓  回傳結果
n8n → 推播回 Telegram / LINE
```

**為什麼選這個架構：**
- Scale to zero——GitHub Actions 只在被觸發時才跑，除 n8n 月費外沒有閒置成本
- 完整 git history，每一次 wiki 編輯或 skill 執行都有記錄
- Telegram 為主（設定簡單、無推播限制）；LINE 為選填，適合群組使用

---

## 快速開始

### 1. Fork 這個 repo

把這個 repo fork（或用 "Use this template"），設為 **Private**。

### 2. 加入你的內容

Starter wiki 在 `wiki/family/home.md`，填入你想讓 bot 知道的事——或者跳過這步，直接指向你自己的 skills 也行。

Agent 會讀取 `wiki/` 底下的所有內容，並可以呼叫 repo 裡定義的任何 Claude Code skill。

### 3. 設定 GitHub Secrets

到 repo `Settings > Secrets and variables > Actions`，新增：

| Secret 名稱 | 說明 | 哪裡找 |
|------------|------|-------|
| `ANTHROPIC_API_KEY` | Anthropic API 金鑰 | console.anthropic.com |
| `OWNER_TELEGRAM_USER_ID` | 你的 Telegram User ID | 傳 `/start` 給 @userinfobot |
| `OWNER_LINE_USER_ID` | 你的 LINE User ID（若使用 LINE） | LINE Developers Console |
| `ALLOWED_LINE_USER_IDS` | 允許查詢的 LINE User ID，逗號分隔 | 從 n8n log 收集 |
| `N8N_WEBHOOK_URL` | n8n 接收 GitHub 回傳的 webhook URL | 見步驟 5 |
| `N8N_WEBHOOK_SECRET` | 驗證 GitHub→n8n 回傳的隨機密鑰 | 自行產生任意字串 |

> **GitHub PAT**：建立 token 時請用 **fine-grained personal access token**，只限本 repo、只給 **Contents: Read and Write** 權限，避免使用 classic PAT 全權限。

### 4. 設定訊息平台 Bot

**Telegram（主要——建議先從這裡開始）**

1. 在 Telegram 找 [@BotFather](https://t.me/BotFather)
2. 傳 `/newbot`，取得 **Bot Token**
3. 傳 `/start` 給 [@userinfobot](https://t.me/userinfobot) 取得你的 **User ID**
4. 在 n8n 新增 `Telegram account` credential，填入 Bot Token

**LINE（選填——供群組使用）**

1. 到 [LINE Developers Console](https://developers.line.biz/)
2. 新增 Provider → 新增 Messaging API channel
3. 把 Bot 加入你的群組
4. 記下 **Channel Access Token**（給 n8n 用）

### 5. 架設 n8n

推薦用 Railway 一鍵部署：

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com?referralCode=WPRBMu)

也可以直接用連結：<https://railway.com?referralCode=WPRBMu>

部署後匯入 `n8n/` 資料夾裡的兩個 workflow：

**Workflow A（`workflow1-incoming.json`）** — 接收 Telegram/LINE 訊息，觸發 GitHub Actions

**Workflow B（`workflow2-outgoing.json`）** — 接收 GitHub 回傳，推播到 Telegram / LINE

在 n8n 設定 credentials：

| Credential 名稱 | Header name | Header value |
|---|---|---|
| `GitHub PAT` | `Authorization` | `Bearer <你的 fine-grained PAT>` |
| `LINE channel token` | `Authorization` | `Bearer <LINE channel access token>` |
| `Brain Webhook Secret` | `X-Brain-Token` | `<你的 N8N_WEBHOOK_SECRET>` |

> **Workflow B Webhook**：Webhook 節點 → Authentication → Header Auth，name `X-Brain-Token`，value = `N8N_WEBHOOK_SECRET`。
> **必填 n8n 環境變數**（Railway：服務 → Variables tab）：
> - `LINE_CHANNEL_SECRET` — 你的 LINE channel secret（使用 LINE 時必填；未設則所有 LINE 訊息被拒）
> - `NODE_FUNCTION_ALLOW_BUILTIN=crypto` — 讓驗簽 Code node 能使用 crypto 模組

> **注意**：本模板提供的 n8n workflow 為參考實作，請先在自己的 n8n 環境匯入並測試，確認正常運作後再上線。

### 6. 測試

Telegram 測試：直接傳任一訊息給你的 bot。

LINE 測試（若有設定）：在群組輸入 `@你的bot名稱 WiFi 密碼是什麼？`

---

## 擴充你的 Skills

Starter template 涵蓋 wiki 查詢和 wiki 寫入。要加入自己的 skill：

1. 把 skill 檔案加進 repo（Claude Code skills、prompt、或腳本）
2. 在 `.github/workflows/agent.yml` 的 keyword routing 加入對應的觸發詞
3. 更新 agent prompt，說明每個 skill 的功能

可以擴充的資料夾結構範例：

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

## 費用估算

| 項目 | 費用 |
|------|------|
| n8n（Railway 最低方案） | USD $5/月 |
| Anthropic API（Haiku，按量計費） | USD $3–8/月（視用量） |
| GitHub Actions | 免費（private repo 2,000 min/月） |
| LINE Messaging API | 免費（月額度內） |
| **合計** | **約 USD $8–13/月** |

---

## FAQ

**Q: 回應好慢？**
A: GitHub Actions cold start 約 30–60 秒，這是 scale-to-zero 的取捨。如果無法接受，考慮用 always-on 方案。

**Q: 只想要 wiki 查詢，這樣會不會太殺雞用牛刀？**
A: 是。如果只需要查詢知識庫、又不在意隱私，直接把 n8n 接 LLM API 就好。這個 template 的價值在於同時想遠端觸發 Claude Code skills。

**Q: 我的資料會外流嗎？**
A: Wiki 內容會被組進 prompt 傳送到 Anthropic API 處理。Anthropic 條款禁止用 API 輸入訓練模型，但資料確實會離開你的基礎設施。請避免在 wiki 裡放高敏感資訊（銀行帳密、身分證號、2FA codes）。

**Q: 可以讓其他人使用嗎？**
A: 可以。Telegram 使用者加到 `OWNER_TELEGRAM_USER_ID` 的判斷邏輯，LINE 使用者加進 `ALLOWED_LINE_USER_IDS`。

**Q: 可以用 OpenAI 代替 Claude 嗎？**
A: 可以，但需要修改 `.github/workflows/agent.yml` 裡的 CLI 指令與模型邏輯。

---

## 上線前檢查清單

- GitHub repo 設為 private
- n8n webhook 驗證已設定完成（`LINE_CHANNEL_SECRET` 與 `X-Brain-Token`）
- GitHub PAT 使用 fine-grained token，且只給必要的 repo 權限
- GitHub、n8n、LINE、Telegram 帳號都開啟 2FA
- 不要把銀行帳密、身分證號、2FA codes、完整金融憑證放進 `wiki/`
- 匯入的 n8n workflows 先用測試資料跑通，再正式上線

---

## Credit

- 架構設計：[Iju](https://ijuhsu.com)
- 靈感來源：[Andrej Karpathy's personal wiki](https://github.com/karpathy/lexicap)

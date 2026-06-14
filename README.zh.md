# My Brain — LINE + Telegram 家族助手模板

> 用 GitHub + Claude Code CLI 打造屬於你的私人 AI 助手，透過 LINE 或 Telegram 回答只有你才知道的問題。
> 月費約 USD $10（n8n $5 + Anthropic API $5）
> English version: [README.md](./README.md)
> 最快上手（中文）：[GETTING_STARTED.zh.md](./GETTING_STARTED.zh.md) | English fast path: [GETTING_STARTED.md](./GETTING_STARTED.md)

---

## 這是什麼？

這個 template 讓你可以：
- 在 LINE 群組 @bot，直接查詢你的私人 wiki（WiFi 密碼、保單、行程…）
- 用 Telegram 直接問 bot（更穩定，不會有 push 失敗問題）
- 說「幫我記 wiki xxx」，自動寫入知識庫並 commit 到 GitHub
- 把你的 Claude Code Skills 變成可以遠端用 LINE / Telegram 操控的能力

**特點：**
- Wiki 檔案存在自己的 GitHub private repo；prompt 會送到 Anthropic API 處理
- Scale to zero，沒有查詢就不花錢
- 完整 git history，知道誰改了什麼
- 支援雙平台（LINE + Telegram），Telegram 作為 LINE Push 失敗時的備援

---

## 架構

```text
LINE 群組 / Telegram
  ↓  @bot 問問題
n8n（Railway 部署）
  ↓  觸發 GitHub Actions
GitHub Actions
  ↓  執行 Claude Code CLI，讀取 wiki/
Claude Code（Haiku 省錢版）
  ↓  回傳答案
n8n → LINE / Telegram 推播
```

---

## 快速開始

### 1. Fork 這個 repo

把這個 repo fork（或用 "Use this template"），設為 **Private**。

### 2. 填入你的 wiki

編輯 `wiki/family/home.md`，填入家庭資訊：
- WiFi 密碼
- 常用聯絡電話
- 任何家人常問你的事

### 3. 設定 GitHub Secrets

到 repo `Settings > Secrets and variables > Actions`，新增：

| Secret 名稱 | 說明 | 哪裡找 |
|------------|------|-------|
| `ANTHROPIC_API_KEY` | Anthropic API 金鑰 | console.anthropic.com |
| `OWNER_LINE_USER_ID` | 你的 LINE User ID | LINE Developers Console |
| `ALLOWED_LINE_USER_IDS` | 允許查詢的 LINE User ID，逗號分隔 | 從 n8n log 收集 |
| `OWNER_TELEGRAM_USER_ID` | 你的 Telegram User ID（選填） | 傳訊息給 @userinfobot |
| `N8N_WEBHOOK_URL` | n8n 接收 GitHub 回傳的 webhook URL | 見步驟 5 |
| `N8N_WEBHOOK_SECRET` | 驗證 GitHub→n8n 回傳的隨機密鑰 | 自行產生任意字串 |

> **GitHub PAT**：建立 token 時請用 **fine-grained personal access token**，只限本 repo、只給 **Contents: Read and Write** 權限，避免使用 classic PAT 全權限。

> 怎麼查 LINE User ID：發一則訊息，在 n8n execution log 裡看 `source.userId`。

### 4. 申請 LINE Messaging API Bot

1. 到 [LINE Developers Console](https://developers.line.biz/)
2. 新增 Provider → 新增 Messaging API channel
3. 把 Bot 加入你的家族群組
4. 記下 **Channel Access Token**（給 n8n 用）

### 5. 架設 n8n

推薦用 Railway 一鍵部署：

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/n8n)

也可以直接用連結：<https://railway.app/template/n8n>

部署後匯入 `n8n/` 資料夾裡的兩個 workflow：

**Workflow A（`workflow1-incoming.json`）** — 接收 LINE/Telegram 訊息，觸發 GitHub Actions

**Workflow B（`workflow2-outgoing.json`）** — 接收 GitHub 回傳，推播到 LINE / Telegram

> **必填 n8n 環境變數**（Railway：服務 → Variables tab）：
> - `LINE_CHANNEL_SECRET` — 你的 LINE channel secret（必填；未設則所有 LINE 訊息被拒）
> - `NODE_FUNCTION_ALLOW_BUILTIN=crypto` — 讓驗簽 Code node 能使用 crypto 模組
>
> Workflow B：Webhook 節點 → Authentication → Header Auth，name `X-Brain-Token`，value = `N8N_WEBHOOK_SECRET`。

### 6. 測試

LINE 測試：在群組輸入 `@你的bot名稱 WiFi 密碼是什麼？`

---

## 擴充知識庫

新增更多 wiki 資料夾：

```text
wiki/
├── family/
│   └── home.md
├── finance/
│   └── index.md
└── health/
    └── index.md
```

在 `agent.yml` 的 keyword routing 區段加入對應的關鍵字即可。

---

## 費用估算

| 項目 | 費用 |
|------|------|
| n8n（Railway 最低方案） | USD $5/月 |
| Anthropic API（Haiku，按量計費） | USD $3–8/月（視用量） |
| GitHub Actions | 免費（private repo 2000 min/月） |
| LINE Messaging API | 免費（500則/月內） |
| **合計** | **約 USD $8–13/月** |

---

## FAQ

**Q: 回應好慢？**  
A: GitHub Actions cold start 約 30–60 秒。如果無法接受，考慮用 always-on 方案。

**Q: 可以用 OpenAI 代替 Claude 嗎？**  
A: 需要修改 `agent.yml` 裡的 CLI 指令。

**Q: 家人說的話會被看到嗎？**  
A: 你的 wiki 內容會被組進 prompt 傳送到 Anthropic API 處理。Anthropic API 條款禁止用 API 輸入訓練模型，但資料確實會離開你的基礎設施。請避免在 wiki 裡放高敏感資訊（密碼、身分證字號、金融帳戶），或在充分了解這個取捨後使用。

**Q: 可以加更多家人嗎？**  
A: 把他們的 LINE User ID 加進 `ALLOWED_LINE_USER_IDS` secret，並更新 n8n Workflow A 的白名單。

---

## Credit

- 架構設計：[Iju](https://ijuhsu.com)
- 靈感來源：[Andrej Karpathy's personal wiki](https://github.com/karpathy/lexicap)

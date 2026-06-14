# 10 分鐘上手（快速路徑）

如果你想最快把這個 template 變成自己的，請走這份流程。

> English version: [GETTING_STARTED.md](./GETTING_STARTED.md)

## 0) 先準備好

- 一個 private GitHub repo（fork 或 Use this template）
- Anthropic API key
- LINE bot（或 Telegram bot）
- 一個可用的 n8n（最簡單是用 Railway）

## 1) 先填自己的內容（2 分鐘）

請先編輯：

- `wiki/family/home.md`

把範例內容換成你自己的：

- WiFi 名稱／密碼
- 重要聯絡方式
- 你希望家人能直接問到的資訊

如果這份檔案內容太空或太泛，bot 回答就會很泛。

## 2) 設定必要 GitHub Secrets（3 分鐘）

到 `Settings -> Secrets and variables -> Actions`，新增：

- `ANTHROPIC_API_KEY`
- `OWNER_LINE_USER_ID`
- `OWNER_TELEGRAM_USER_ID`（若有用 Telegram）
- `ALLOWED_LINE_USER_IDS`（LINE user ID 用逗號分隔，不要空白）
- `N8N_WEBHOOK_URL`
- `N8N_WEBHOOK_SECRET`（任意隨機字串，需與 n8n Workflow B 的 header auth 一致）

`ALLOWED_LINE_USER_IDS` 範例：

```text
U11111111111111111111111111111111,U22222222222222222222222222222222
```

> **GitHub PAT**：請用 fine-grained PAT，只限本 repo，只給 **Contents: Read and Write** 權限，不要用 classic PAT。

## 3) 匯入 n8n Workflows（3 分鐘）

請同時匯入這**兩個**檔案：

- `n8n/workflow1-incoming.json`
- `n8n/workflow2-outgoing.json`

**workflow1** 請更新這些 placeholder：

- `YOUR_GITHUB_USERNAME` / `YOUR_REPO_NAME`
- `YOUR_BOT_NAME`
- `YOUR_LINE_USER_ID_1` / `YOUR_LINE_USER_ID_2`
- `YOUR_TELEGRAM_USER_ID`

在 n8n 設定 credentials：

- `GitHub PAT`（Header Auth，用來觸發 GitHub Actions）
- `LINE channel token`（Header Auth，用來推播 LINE 訊息）
- `Telegram account`（若有用 Telegram）

**workflow2** 匯入後：

- 到 Webhook 節點 → Authentication → Header Auth
- Header name：`X-Brain-Token`
- Header value：你的 `N8N_WEBHOOK_SECRET`

> **LINE 訊息驗簽**：在 n8n 實例新增環境變數 `LINE_CHANNEL_SECRET`（Railway：服務 → Variables tab）。設好後 workflow 會自動驗證 `X-Line-Signature`，防止偽造請求。

## 4) 冒煙測試（2 分鐘）

1. 在 LINE/Telegram 丟一個簡單問題：
   - `@你的bot WiFi 密碼是什麼？`
2. 看 GitHub Actions 是否有跑：workflow `My Brain Agent` 應有 4 個 job：`detect`、`query`、`write`（skipped）、`notify`
3. 確認 n8n 有把結果回推到聊天室

如果看到 `Unauthorized user`：

- 確認 `ALLOWED_LINE_USER_IDS` 包含你的 LINE user ID
- 若用 Telegram，確認 `OWNER_TELEGRAM_USER_ID` 正確
- 在 n8n execution logs 核對實際進來的 `user_id`

## 5) 第一輪個人化清單

- 更新 n8n Workflow A 裡 bot 名稱提及規則
- 在 `wiki/family/home.md` 先填 5–10 筆真實資料
- 先加一個新資料夾（例如 `wiki/finance/index.md`）
- 問 3 個你家人真的會問的問題

做到這裡，就已經是可用的「你自己的」AI 助手了。

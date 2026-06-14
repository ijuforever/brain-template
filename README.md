# My Brain — LINE 家族助手模板

> 用 GitHub + Claude Code CLI 打造屬於你的私人 AI 助手，透過 LINE 回答只有你才知道的問題。
> 月費約 USD $10（n8n $5 + Anthropic API $5）

---

## 這是什麼？

這個 template 讓你可以：
- 在 LINE 群組 @bot，直接查詢你的私人 wiki（WiFi 密碼、保單、行程…）
- 說「幫我記 wiki xxx」，自動寫入知識庫並 commit 到 GitHub
- 把你的 Claude Code Skills 變成可以遠端用 LINE 操控的能力

**特點：**
- 資料在自己的 GitHub private repo，不進任何第三方 AI 平台
- Scale to zero，沒有查詢就不花錢
- 完整 git history，知道誰改了什麼

---

## 架構

```
LINE 群組
  ↓  @bot 問問題
n8n（Railway 部署）
  ↓  觸發 GitHub Actions
GitHub Actions
  ↓  執行 Claude Code CLI，讀取 wiki/
Claude Code（Haiku 省錢版）
  ↓  回傳答案
n8n → LINE 推播
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
| `N8N_WEBHOOK_URL` | n8n 接收 GitHub 回傳的 webhook URL | 見步驟 5 |

> **怎麼查你的 LINE User ID？**
> LINE Developers Console > 選你的 channel > Webhook 設定 > 用 LINE 傳訊息後，在 n8n log 裡可以看到 `source.userId`

### 4. 申請 LINE Messaging API Bot

1. 到 [LINE Developers Console](https://developers.line.biz/)
2. 新增 Provider → 新增 Messaging API channel
3. 把 Bot 加入你的家族群組
4. 記下 **Channel Access Token**（給 n8n 用）

### 5. 架設 n8n

推薦用 Railway 一鍵部署：

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/n8n)

部署後在 n8n 建立兩個 workflow：

**Workflow A — 接收 LINE 訊息，觸發 GitHub Actions：**
```
LINE Webhook → 判斷是否 @bot → 觸發 GitHub repository_dispatch
```

**Workflow B — 接收 GitHub 回傳，推播 LINE：**
```
Webhook（接 GitHub Actions 回傳）→ LINE Push Message
```

> 詳細 n8n workflow 設定請參考文章（連結待補）

### 6. 測試

本機測試（需要先安裝 Claude Code CLI）：
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
USER_INPUT="WiFi 密碼是什麼？" ./scripts/agent.sh
```

LINE 測試：在群組輸入 `@你的bot名稱 WiFi 密碼是什麼？`

---

## 擴充知識庫

新增更多 wiki 資料夾：

```
wiki/
├── family/
│   └── home.md        ← 家庭資訊
├── finance/           ← 財務（自行新增）
│   └── index.md
└── health/            ← 健康（自行新增）
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

> 單次查詢約 $0.07–$0.1（含 wiki context）

---

## FAQ

**Q: 回應好慢？**
A: GitHub Actions cold start 約 30–60 秒，這是這個方案的主要缺點。如果無法接受，考慮用 OpenClaw 之類的 always-on 方案。

**Q: 可以用 OpenAI 代替 Claude 嗎？**
A: 需要修改 `agent.yml` 裡的 CLI 指令，Claude Code CLI 目前只支援 Anthropic 模型。

**Q: 家人說的話會被看到嗎？**
A: 問題內容會傳到 Anthropic API，但你的 wiki 資料只在自己的 GitHub repo，不進任何第三方平台。

**Q: 可以加更多家人嗎？**
A: 可以在 `agent.yml` 的白名單區段加入更多 LINE User ID。

---

## Credit

- 架構設計：[Iju](https://ijuhsu.com)
- 原文：[聰明透透 — 我的 LINE 家族 AI 助手](待補)
- 靈感來源：[Andrej Karpathy's personal wiki](https://github.com/karpathy/lexicap)

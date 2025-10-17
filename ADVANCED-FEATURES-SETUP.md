# 高级功能配置指南

本指南介绍如何配置博客的评论、表单和搜索功能。

## 📋 功能清单

- ✅ **评论系统**: Talkyard（免费，无需自建服务器）
- ✅ **联系表单**: Formspree（免费额度：50次/月）
- ✅ **全文搜索**: Algolia（免费额度：10k搜索/月）

---

## 1. 配置 Talkyard 评论系统

### 1.1 注册账号

1. 访问 [Talkyard](https://www.talkyard.io/)
2. 点击 **Sign Up** 注册账号
3. 创建新的 Community/Forum

### 1.2 获取配置参数

1. 进入你的 Talkyard 管理后台
2. 找到 **Settings** → **Embedded Comments**
3. 获取以下信息：
   - **Server URL**: 类似 `https://comments-for-yourblog.talkyard.net`
   - **Site ID**: 数字 ID（如 `1`）

### 1.3 更新配置文件

编辑 `_config.yml`，找到 `talkyard` 部分：

```yaml
talkyard:
  server_url: 'https://comments-for-yourblog.talkyard.net'
  site_id: 1
```

### 1.4 测试评论功能

1. 提交配置到 GitHub
2. 等待 GitHub Pages 构建完成（约1-2分钟）
3. 访问任意博客文章页面
4. 页面底部应显示 Talkyard 评论框

### 1.5 控制评论显示

**全局禁用评论**（在 `_config.yml`）：
```yaml
comments: false
```

**单篇文章禁用评论**（在文章头部 Front Matter）：
```yaml
---
title: "文章标题"
comments: false
---
```

---

## 2. 配置 Formspree 表单

### 2.1 注册账号

1. 访问 [Formspree](https://formspree.io/)
2. 点击 **Sign Up** 注册（可用 GitHub 账号登录）
3. 免费计划：50次表单提交/月

### 2.2 创建表单

1. 登录后点击 **New Form**
2. 输入表单名称：如 `Contact Form`
3. 获得 Form ID：类似 `xpznabcd`（8位随机字符）

### 2.3 配置表单设置

在 Formspree 后台：
- ✅ **Email Notifications**: 开启邮件通知
- ✅ **Spam Filter**: 开启垃圾邮件过滤
- ✅ **File Uploads**: 根据需要决定是否允许附件

### 2.4 更新配置文件

编辑 `_config.yml`，找到 `formspree` 部分：

```yaml
formspree:
  form_id: xpznabcd  # 替换为你的实际 Form ID
```

### 2.5 测试表单

1. 提交配置到 GitHub
2. 访问 `/contact/` 页面
3. 填写表单提交测试
4. 应跳转到 `/thank-you/` 页面
5. 检查你的邮箱是否收到提交通知

---

## 3. 配置 Algolia 搜索

### 3.1 注册账号

1. 访问 [Algolia](https://www.algolia.com/)
2. 点击 **Sign Up** 注册（可用 GitHub 账号登录）
3. 选择免费计划：10,000 次搜索/月

### 3.2 创建应用和索引

1. 在 Dashboard 创建新应用：如 `my-blog`
2. 创建索引（Index）：如 `blog_posts`
3. 索引名称建议使用小写和下划线

### 3.3 获取 API Keys

在 **Settings** → **API Keys** 页面：

- **Application ID**: 类似 `5GZNQJ7W8M`（10位大写字母+数字）
- **Search-Only API Key**: 公开使用的只读密钥（前端安全）
- **Admin API Key**: 管理密钥（仅用于索引更新，**不要公开**）

### 3.4 更新配置文件

编辑 `_config.yml`，找到 `algolia` 部分：

```yaml
algolia:
  application_id: 5GZNQJ7W8M           # 替换为你的 Application ID
  index_name: blog_posts               # 替换为你的索引名称
  search_only_api_key: 8a8d3...f9c2e   # 替换为你的 Search-Only API Key
```

⚠️ **重要**: `search_only_api_key` 是公开的，不要使用 Admin API Key！

### 3.5 配置 GitHub Secret

Admin API Key 用于自动更新索引，需要添加到 GitHub Secrets：

1. 进入你的 GitHub 仓库
2. **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**
4. Name: `ALGOLIA_ADMIN_API_KEY`
5. Value: 粘贴你的 Admin API Key
6. 点击 **Add secret**

### 3.6 手动索引（首次或测试）

在本地运行（需要先 `bundle install`）：

```bash
# Windows PowerShell
$env:ALGOLIA_API_KEY="你的Admin_API_Key"
bundle exec jekyll algolia

# macOS/Linux
export ALGOLIA_API_KEY="你的Admin_API_Key"
bundle exec jekyll algolia
```

成功后会看到：
```
Indexing 15 records...
✔ All records indexed!
```

### 3.7 自动索引

配置完 GitHub Secret 后，每次推送代码到 `main` 分支：
- 自动触发 `.github/workflows/algolia.yml`
- 更新 Algolia 索引
- 在 **Actions** 标签查看运行日志

### 3.8 测试搜索

1. 提交所有配置到 GitHub
2. 等待 Actions 运行完成
3. 访问 `/search/` 页面
4. 输入关键词测试搜索功能

---

## 📊 配置检查清单

### Talkyard
- [ ] 已注册 Talkyard 账号
- [ ] 已创建 Community
- [ ] 已获取 `server_url` 和 `site_id`
- [ ] 已更新 `_config.yml`
- [ ] 已测试评论显示正常

### Formspree
- [ ] 已注册 Formspree 账号
- [ ] 已创建表单并获取 Form ID
- [ ] 已更新 `_config.yml` 中的 `form_id`
- [ ] 已开启邮件通知
- [ ] 已测试表单提交成功

### Algolia
- [ ] 已注册 Algolia 账号
- [ ] 已创建应用和索引
- [ ] 已获取 Application ID 和 API Keys
- [ ] 已更新 `_config.yml` 的三个参数
- [ ] 已添加 `ALGOLIA_ADMIN_API_KEY` 到 GitHub Secrets
- [ ] 已完成首次索引（手动或自动）
- [ ] 已测试搜索功能正常

---

## 🔧 故障排查

### Talkyard 评论不显示

1. 检查浏览器控制台（F12）是否有 JavaScript 错误
2. 确认 `server_url` 格式正确（包含 https://）
3. 确认 `site_id` 是纯数字，不带引号
4. 访问 Talkyard 管理后台检查配置

### Formspree 表单无法提交

1. 确认 `form_id` 格式正确（8位字符）
2. 检查 Formspree 后台是否有提交记录
3. 确认邮箱地址有效
4. 查看垃圾邮件文件夹

### Algolia 搜索无结果

1. 访问 Algolia Dashboard 检查索引记录数
2. 确认 `application_id` 和 `index_name` 正确
3. 检查 GitHub Actions 运行日志：`Actions` → `Update Algolia Index`
4. 手动运行 `bundle exec jekyll algolia` 测试
5. 确认 `search_only_api_key` 权限正确（只读权限）

### GitHub Actions 失败

**Algolia 索引失败**:
- 检查 `ALGOLIA_ADMIN_API_KEY` 是否正确添加到 Secrets
- 确认 Admin API Key 有写入权限
- 查看 Actions 日志的详细错误信息

**IndexNow 通知失败**:
- 检查 `INDEXNOW_KEY` 是否添加到 Secrets
- 确认 key 文件已上传到网站根目录

---

## 🎯 最佳实践

### 安全建议

1. ✅ **永远不要**把 Admin API Key 提交到代码仓库
2. ✅ 使用 GitHub Secrets 存储敏感密钥
3. ✅ 定期轮换 API Keys
4. ✅ 为 Formspree 开启 reCAPTCHA（防机器人）

### 性能优化

1. Algolia 索引仅在 `_posts/**` 或 `*.md` 文件变更时触发
2. 评论系统按需加载，不影响页面初始性能
3. 搜索使用 CDN 加速，全球访问快速

### 内容管理

1. 使用 Front Matter `comments: false` 控制单篇文章评论
2. 定期清理 Formspree 提交记录
3. 监控 Algolia 搜索分析优化关键词

---

## 📚 相关文档

- [Talkyard 文档](https://www.talkyard.io/docs)
- [Formspree 文档](https://help.formspree.io/)
- [Algolia Jekyll Plugin](https://community.algolia.com/jekyll-algolia/)
- [GitHub Actions 文档](https://docs.github.com/actions)

---

## ❓ 需要帮助？

如遇到问题：
1. 检查本文档的故障排查部分
2. 查看各服务的官方文档
3. 检查 GitHub Actions 运行日志
4. 在浏览器控制台查看错误信息

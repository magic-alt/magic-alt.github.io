# IndexNow 配置指南

IndexNow 是一个协议，允许网站主动通知搜索引擎（Bing、Yandex 等）内容更新，加速索引过程。

## 🔑 设置 IndexNow Key

### 方法 1: 使用 GitHub Secrets（推荐）

1. 生成一个 UUID 格式的密钥：
   ```bash
   # Linux/macOS
   uuidgen
   
   # 或在线生成: https://www.uuidgenerator.net/
   # 示例: 12345678-1234-1234-1234-123456789abc
   ```

2. 在 GitHub 仓库设置中添加 Secret：
   - 进入仓库 → Settings → Secrets and variables → Actions
   - 点击 "New repository secret"
   - Name: `INDEXNOW_KEY`
   - Value: 你生成的 UUID

3. 在网站根目录创建验证文件：
   ```bash
   # 创建文件: 12345678-1234-1234-1234-123456789abc.txt
   # 文件内容就是这个 UUID
   echo "12345678-1234-1234-1234-123456789abc" > 12345678-1234-1234-1234-123456789abc.txt
   ```

4. 提交验证文件到仓库根目录

### 方法 2: 使用固定密钥

如果不想使用 GitHub Secrets，可以：

1. 生成一个 UUID（如上）
2. 编辑 `.github/workflows/indexnow.yml`，将 `your-indexnow-key-here` 替换为你的 UUID
3. 创建对应的验证文件（见上面第 3 步）

## 📋 验证文件示例

在仓库根目录创建文件：`12345678-1234-1234-1234-123456789abc.txt`

文件内容：
```
12345678-1234-1234-1234-123456789abc
```

## 🚀 工作流程

1. 当你推送新文章或修改文章到 `main` 分支时
2. GitHub Actions 自动检测变更的文章
3. 提取文章 URL
4. 通过 IndexNow API 通知 Bing/Yandex
5. 搜索引擎在几小时内重新抓取这些页面

## 🔍 支持的搜索引擎

- ✅ **Bing** - 完全支持
- ✅ **Yandex** - 完全支持
- ❌ **Google** - 不支持（Google 不参与 IndexNow）

对于 Google，仍需使用 Google Search Console 的 URL 检查工具手动提交。

## 📊 查看提交结果

1. GitHub Actions 运行后，查看 Actions 页面的摘要
2. 在 Bing Webmaster Tools 查看索引状态
3. 使用 `site:magic-alt.github.io` 搜索验证收录情况

## 🆘 故障排除

### 密钥验证失败
- 确认验证文件名与密钥完全一致
- 确认验证文件在网站根目录可访问：`https://magic-alt.github.io/your-key.txt`

### GitHub Action 失败
- 检查 INDEXNOW_KEY secret 是否正确设置
- 查看 Actions 日志了解具体错误

### 未收录
- IndexNow 只是"通知"，不保证立即收录
- 确保在 Bing Webmaster Tools 已验证网站所有权
- 检查 robots.txt 没有禁止抓取

## 📖 相关资源

- [IndexNow 官方文档](https://www.indexnow.org/)
- [Bing IndexNow 集成指南](https://www.bing.com/indexnow)
- [IndexNow API 规范](https://www.indexnow.org/documentation)

---

**注意**: IndexNow 对 Google 无效。Google 推荐使用 Sitemap + Google Search Console 的 URL 检查工具。

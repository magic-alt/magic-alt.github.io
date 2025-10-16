# Kaermaxc 博客模板

这是一个使用 [Jekyll](https://jekyllrb.com/) 构建的简洁博客模板，预配置了文章、分页、标签、归档和 RSS 等常见功能，适合部署在 GitHub Pages 上。

## 功能特性

- ✅ 支持 Markdown 文章发布，示例文章位于 `_posts/`
- ✅ 首页文章列表支持分页，默认每页显示 5 篇文章
- ✅ 自动生成 RSS 订阅源，位于 `/feed.xml`
- ✅ 提供标签与归档页面，方便浏览历史内容
- ✅ 自适应布局与暗色模式支持，可在 `assets/css/styles.css` 中自定义样式

## 本地预览

1. 安装 Ruby 及 Bundler（Ruby 3.0 及以上版本需额外安装 `webrick`，本模板已在 `Gemfile` 中配置）。
2. 在项目根目录运行：

   ```bash
   bundle install
   bundle exec jekyll serve
   ```

3. 打开浏览器访问 <http://localhost:4000> 查看效果。

## 发布到 GitHub Pages

1. Fork 本仓库或将其作为模板创建新仓库。
2. 将仓库名称命名为 `<username>.github.io` 并推送到 GitHub。
3. 在仓库的 **Settings → Pages** 中确认部署分支为 `main`（或默认分支）。
4. 几分钟后访问 `https://<username>.github.io` 即可看到博客上线。

## 自定义

- 修改 `_config.yml` 设置站点标题、描述、作者信息和分页等参数。
- 在 `_posts` 中添加新文章，命名格式为 `YYYY-MM-DD-标题.md`，使用标准 Markdown 编写内容。
- 需要新增页面可创建新的 Markdown/HTML 文件并在 Front Matter 中指定 `permalink`。
- 在 `assets/css/styles.css` 中调整配色、字体等样式。

欢迎基于本模板打造你的个人博客！

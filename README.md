# magic-alt.github.io

使用 Jekyll 与 GitHub Pages 搭建的个人博客，采用 Minimal Mistakes 的 GitHub Pages 模板结构。

## 本地预览

1. 安装 Ruby 与 Bundler。
2. 安装依赖：
   ```bash
   bundle install
   ```
3. 本地运行：
   ```bash
   bundle exec jekyll serve
   ```

## 部署到 GitHub Pages

- 推送仓库到 GitHub。
- 在仓库 Settings → Pages 中，将发布源设置为默认分支的根目录。

## 常用配置入口

- `_config.yml`：站点信息、主题皮肤、作者信息。
- `_data/navigation.yml`：顶部导航。
- `_pages/`：页面（关于、归档、分类、标签、搜索）。

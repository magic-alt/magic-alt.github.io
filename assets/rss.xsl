<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <xsl:output method="html" indent="yes"/>
  <xsl:template match="/">
    <html lang="zh-CN">
      <head>
        <meta charset="utf-8" />
        <title>
          <xsl:value-of select="/rss/channel/title" /> - RSS 订阅
        </title>
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
            margin: 2rem auto;
            max-width: 800px;
            line-height: 1.6;
            color: #2d2d2d;
            background: #f9fafb;
            padding: 0 1.5rem 3rem;
          }
          header {
            text-align: center;
            margin-bottom: 2.5rem;
          }
          header h1 {
            margin: 0;
            font-size: 2rem;
          }
          header p {
            color: #555;
          }
          .feed-meta {
            display: flex;
            justify-content: center;
            gap: 1.5rem;
            margin-top: 0.75rem;
            font-size: 0.9rem;
            color: #666;
          }
          .post-list {
            list-style: none;
            padding: 0;
            margin: 0;
          }
          .post-item {
            background: #fff;
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 4px 12px rgba(15, 23, 42, 0.08);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
          }
          .post-item:hover {
            transform: translateY(-4px);
            box-shadow: 0 6px 18px rgba(15, 23, 42, 0.12);
          }
          .post-item h2 {
            margin: 0 0 0.5rem;
            font-size: 1.5rem;
          }
          .post-item h2 a {
            color: #2563eb;
            text-decoration: none;
          }
          .post-item h2 a:hover {
            text-decoration: underline;
          }
          .post-meta {
            font-size: 0.9rem;
            color: #666;
            margin-bottom: 0.75rem;
          }
          .post-description {
            color: #374151;
          }
          .tag-list {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin-top: 1rem;
          }
          .tag {
            background: #e0e7ff;
            color: #3730a3;
            padding: 0.25rem 0.75rem;
            border-radius: 999px;
            font-size: 0.8rem;
          }
        </style>
      </head>
      <body>
        <header>
          <h1>
            <xsl:value-of select="/rss/channel/title" /> RSS 订阅源
          </h1>
          <p>
            <xsl:value-of select="/rss/channel/description" />
          </p>
          <div class="feed-meta">
            <span>
              <strong>订阅地址：</strong>
              <xsl:value-of select="/rss/channel/link" />/feed.xml
            </span>
            <span>
              <strong>最新更新：</strong>
              <xsl:value-of select="/rss/channel/lastBuildDate" />
            </span>
          </div>
        </header>
        <ul class="post-list">
          <xsl:for-each select="/rss/channel/item">
            <li class="post-item">
              <h2>
                <a>
                  <xsl:attribute name="href">
                    <xsl:value-of select="link" />
                  </xsl:attribute>
                  <xsl:value-of select="title" />
                </a>
              </h2>
              <div class="post-meta">
                <span>
                  <strong>发布时间：</strong>
                  <xsl:value-of select="pubDate" />
                </span>
                <xsl:if test="dc:creator">
                  <span> · <strong>作者：</strong> <xsl:value-of select="dc:creator" /></span>
                </xsl:if>
              </div>
              <div class="post-description">
                <xsl:value-of select="description" disable-output-escaping="yes" />
              </div>
              <xsl:if test="category">
                <div class="tag-list">
                  <xsl:for-each select="category">
                    <span class="tag">#<xsl:value-of select="." /></span>
                  </xsl:for-each>
                </div>
              </xsl:if>
            </li>
          </xsl:for-each>
        </ul>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>

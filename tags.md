---
layout: default
title: 标签
permalink: /tags/
---
<section class="tags">
  {% assign tags = site.tags | sort %}
  {% for tag in tags %}
  <h2 id="{{ tag[0] | slugify }}">{{ tag[0] }}</h2>
  <ul>
    {% for post in tag[1] %}
    <li>
      <span class="tag-date">{{ post.date | date: "%Y-%m-%d" }}</span>
      <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
    </li>
    {% endfor %}
  </ul>
  {% endfor %}
</section>

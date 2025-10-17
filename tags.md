---
layout: default
title: 标签
permalink: /tags/
---
<section class="tags">
  {% assign tags = site.tags | sort %}
  {% for tag in tags %}
  <div class="tag-group" data-tag="{{ tag[0] | slugify }}">
    <h2 id="{{ tag[0] | slugify }}">{{ tag[0] }}</h2>
    <ul>
      {% for post in tag[1] %}
      <li>
        <span class="tag-date">{{ post.date | date: "%Y-%m-%d" }}</span>
        <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
      </li>
      {% endfor %}
    </ul>
  </div>
  {% endfor %}
</section>

<script>
  document.addEventListener('DOMContentLoaded', function () {
    const groups = Array.from(document.querySelectorAll('.tag-group'));

    function showTag(slug) {
      groups.forEach(group => {
        group.style.display = !slug || group.dataset.tag === slug ? '' : 'none';
      });
    }

    function updateFromHash() {
      const slug = window.location.hash.replace('#', '');
      showTag(slug);
      if (slug) {
        const heading = document.getElementById(slug);
        if (heading) {
          heading.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
      }
    }

    window.addEventListener('hashchange', updateFromHash);
    updateFromHash();
  });
</script>

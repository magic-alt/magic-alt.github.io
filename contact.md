---
layout: default
title: 联系我
permalink: /contact/
---

<section class="contact-page">
  <h1>联系我</h1>
  <p>有任何问题或建议？欢迎通过下方表单与我联系，我会尽快回复。</p>

  <form 
    id="contact-form" 
    action="https://formspree.io/f/{{ site.formspree.form_id }}" 
    method="POST"
    class="contact-form"
  >
    <div class="form-group">
      <label for="email">邮箱地址 <span class="required">*</span></label>
      <input 
        type="email" 
        id="email"
        name="email" 
        required 
        placeholder="your@email.com"
        aria-required="true"
      >
      <small>用于接收回复，不会被公开</small>
    </div>

    <div class="form-group">
      <label for="name">姓名</label>
      <input 
        type="text" 
        id="name"
        name="name" 
        placeholder="张三"
      >
    </div>

    <div class="form-group">
      <label for="subject">主题 <span class="required">*</span></label>
      <input 
        type="text" 
        id="subject"
        name="subject" 
        required
        placeholder="关于..."
        aria-required="true"
      >
    </div>

    <div class="form-group">
      <label for="message">留言内容 <span class="required">*</span></label>
      <textarea 
        id="message"
        name="message" 
        rows="8" 
        required
        placeholder="请输入您的留言..."
        aria-required="true"
      ></textarea>
    </div>

    <!-- Formspree 反垃圾邮件隐藏字段 -->
    <input type="text" name="_gotcha" style="display:none">
    
    <!-- 提交后跳转 -->
    <input type="hidden" name="_next" value="{{ site.url }}{{ site.baseurl }}/thank-you/">
    
    <!-- 邮件主题前缀 -->
    <input type="hidden" name="_subject" value="[博客留言] 新消息">

    <div class="form-actions">
      <button type="submit" class="hero-button">
        <span class="button-text">发送消息</span>
        <span class="button-loading" style="display:none;">发送中...</span>
      </button>
      <p class="form-note">提交即表示您同意我们使用您的邮箱地址回复您的留言。</p>
    </div>
  </form>

  <div class="contact-alternatives">
    <h2>其他联系方式</h2>
    <ul>
      <li>📧 邮箱：<a href="mailto:{{ site.author.email }}">{{ site.author.email }}</a></li>
      <li>🐙 GitHub：<a href="https://github.com/magic-alt" target="_blank">@magic-alt</a></li>
      <li>📰 RSS 订阅：<a href="{{ '/feed.xml' | relative_url }}">订阅博客</a></li>
    </ul>
  </div>
</section>

<style>
.contact-page {
  max-width: 650px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.contact-form {
  background: #f9fafb;
  padding: 2rem;
  border-radius: 8px;
  margin: 2rem 0;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: #374151;
}

.required {
  color: #ef4444;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  font-size: 1rem;
  font-family: inherit;
  transition: border-color 0.2s;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-group small {
  display: block;
  margin-top: 0.25rem;
  font-size: 0.875rem;
  color: #6b7280;
}

.form-actions {
  text-align: center;
}

.form-note {
  margin-top: 1rem;
  font-size: 0.875rem;
  color: #6b7280;
}

.button-loading {
  opacity: 0.7;
}

.contact-alternatives {
  margin-top: 3rem;
  padding-top: 2rem;
  border-top: 1px solid #e5e7eb;
}

.contact-alternatives ul {
  list-style: none;
  padding: 0;
}

.contact-alternatives li {
  margin: 0.75rem 0;
  font-size: 1.1rem;
}
</style>

<script>
document.getElementById('contact-form').addEventListener('submit', function() {
  var button = this.querySelector('button[type="submit"]');
  var textSpan = button.querySelector('.button-text');
  var loadingSpan = button.querySelector('.button-loading');
  
  textSpan.style.display = 'none';
  loadingSpan.style.display = 'inline';
  button.disabled = true;
});
</script>

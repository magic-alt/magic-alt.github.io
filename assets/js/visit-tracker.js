(function () {
  'use strict';

  var viewElement = document.getElementById('page-view-count');
  if (!viewElement) {
    return;
  }

  if (!('localStorage' in window)) {
    viewElement.textContent = '暂不可用（浏览器不支持本地存储）';
    return;
  }

  var storageKey = 'kaermaxc-visit-counts';
  var pageId = viewElement.getAttribute('data-page-url') || window.location.pathname;

  function readCounts() {
    try {
      var raw = localStorage.getItem(storageKey);
      if (!raw) {
        return {};
      }
      var parsed = JSON.parse(raw);
      if (typeof parsed === 'object' && parsed) {
        return parsed;
      }
    } catch (error) {
      console.warn('无法从本地存储读取访问数据', error);
    }
    return {};
  }

  function writeCounts(counts) {
    try {
      localStorage.setItem(storageKey, JSON.stringify(counts));
      return true;
    } catch (error) {
      console.warn('无法将访问数据写入本地存储', error);
      return false;
    }
  }

  var counts = readCounts();
  var current = counts[pageId] || 0;
  current += 1;
  counts[pageId] = current;
  if (writeCounts(counts)) {
    viewElement.textContent = current + ' 次（仅记录本设备）';
  } else {
    viewElement.textContent = '暂不可用（浏览器禁用了本地存储）';
  }
})();

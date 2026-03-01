---
layout: single
title: "LangChain 用法总结：从入门到实践"
date: 2026-02-15 10:00:00 +0800
categories: [技术笔记]
tags: [LangChain, LLM, Python, AI]
excerpt: "LangChain 是构建 LLM 应用的主流框架之一。本文总结其核心概念、常用模块和实战技巧，帮你快速上手。"
---

## 什么是 LangChain

[LangChain](https://github.com/langchain-ai/langchain) 是一个用于构建**大语言模型（LLM）应用**的开源框架。它的核心价值在于：

- 将 LLM 调用与外部数据源、工具**串联起来**
- 提供标准化的接口，方便切换不同的模型和服务
- 内置常见的 AI 应用模式（RAG、Agent、Chain 等）

简单说，LangChain 就像是 LLM 应用开发的**胶水层**——它帮你把模型、数据、工具粘在一起。

## 安装与基本配置

```bash
# 安装核心包
pip install langchain langchain-openai langchain-community

# 如果需要向量数据库支持
pip install langchain-chroma
# 或者
pip install faiss-cpu
```

设置 API Key（以 OpenAI 为例）：

```python
import os
os.environ["OPENAI_API_KEY"] = "sk-your-key-here"
```

> **建议**：使用 `.env` 文件配合 `python-dotenv` 管理密钥，不要把 Key 硬编码到代码里。

## 核心概念

LangChain 的架构围绕几个核心概念展开：

### 1. Model（模型）

LangChain 支持多种 LLM 提供商，接口统一：

```python
from langchain_openai import ChatOpenAI

# 创建模型实例
llm = ChatOpenAI(model="gpt-4o", temperature=0.7)

# 直接调用
response = llm.invoke("用一句话解释什么是 Transformer")
print(response.content)
```

切换到其他模型也很方便：

```python
# 使用 Anthropic Claude
from langchain_anthropic import ChatAnthropic
llm = ChatAnthropic(model="claude-sonnet-4-20250514")

# 使用本地 Ollama 模型
from langchain_community.llms import Ollama
llm = Ollama(model="llama3")
```

### 2. Prompt Template（提示词模板）

模板化管理 Prompt，避免到处拼字符串：

```python
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages([
    ("system", "你是一个专业的{domain}助手，回答要简洁准确。"),
    ("human", "{question}")
])

# 使用模板
messages = prompt.invoke({
    "domain": "机器学习",
    "question": "什么是梯度消失问题？"
})

response = llm.invoke(messages)
```

### 3. Output Parser（输出解析器）

把 LLM 的文本输出转换为结构化数据：

```python
from langchain_core.output_parsers import JsonOutputParser
from pydantic import BaseModel, Field

class BookRecommendation(BaseModel):
    title: str = Field(description="书名")
    author: str = Field(description="作者")
    reason: str = Field(description="推荐理由")

parser = JsonOutputParser(pydantic_object=BookRecommendation)

prompt = ChatPromptTemplate.from_messages([
    ("system", "推荐一本关于{topic}的书。{format_instructions}"),
    ("human", "请推荐")
])

chain = prompt | llm | parser
result = chain.invoke({
    "topic": "深度学习",
    "format_instructions": parser.get_format_instructions()
})
# result 是一个 dict: {"title": "...", "author": "...", "reason": "..."}
```

### 4. Chain（链）

Chain 是 LangChain 最核心的概念——把多个步骤串联起来。现在推荐用 **LCEL**（LangChain Expression Language）来构建：

```python
# 用 | 管道符串联
chain = prompt | llm | output_parser

# 调用
result = chain.invoke({"question": "什么是注意力机制？"})
```

LCEL 的优势：
- 语法直观，类似 Unix 管道
- 自动支持流式输出（streaming）
- 自动支持异步（async）
- 方便调试和追踪

## 实战场景

### 场景一：RAG（检索增强生成）

RAG 是目前最常见的 LLM 应用模式——让模型基于你的私有文档回答问题。

```python
from langchain_community.document_loaders import TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
from langchain_chroma import Chroma
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough

# 1. 加载文档
loader = TextLoader("my_notes.txt", encoding="utf-8")
docs = loader.load()

# 2. 文本分割
splitter = RecursiveCharacterTextSplitter(
    chunk_size=500,
    chunk_overlap=50
)
chunks = splitter.split_documents(docs)

# 3. 创建向量数据库
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_documents(chunks, embeddings)
retriever = vectorstore.as_retriever(search_kwargs={"k": 3})

# 4. 构建 RAG 链
template = """基于以下上下文回答问题。如果上下文中没有相关信息，请说明。

上下文：
{context}

问题：{question}
"""

prompt = ChatPromptTemplate.from_template(template)

def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
)

# 5. 使用
answer = rag_chain.invoke("文档里提到了哪些关键技术？")
print(answer.content)
```

### 场景二：Agent（智能体）

Agent 可以让 LLM 自主决定调用哪些工具来完成任务：

```python
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain_core.tools import tool

@tool
def search_web(query: str) -> str:
    """搜索互联网获取最新信息"""
    # 实际项目中接入搜索 API
    return f"搜索结果：关于 '{query}' 的最新信息..."

@tool
def calculate(expression: str) -> str:
    """计算数学表达式"""
    try:
        return str(eval(expression))
    except Exception as e:
        return f"计算错误: {e}"

# 创建 Agent
tools = [search_web, calculate]

prompt = ChatPromptTemplate.from_messages([
    ("system", "你是一个有用的助手，可以使用工具来回答问题。"),
    ("human", "{input}"),
    ("placeholder", "{agent_scratchpad}")
])

agent = create_tool_calling_agent(llm, tools, prompt)
executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

# 运行
result = executor.invoke({"input": "帮我算一下 1024 * 768 是多少"})
```

### 场景三：对话记忆

让 LLM 记住多轮对话的上下文：

```python
from langchain_core.chat_history import InMemoryChatMessageHistory
from langchain_core.runnables.history import RunnableWithMessageHistory

store = {}

def get_session_history(session_id: str):
    if session_id not in store:
        store[session_id] = InMemoryChatMessageHistory()
    return store[session_id]

prompt = ChatPromptTemplate.from_messages([
    ("system", "你是一个友好的助手。"),
    ("placeholder", "{history}"),
    ("human", "{input}")
])

chain = prompt | llm

chain_with_history = RunnableWithMessageHistory(
    chain,
    get_session_history,
    input_messages_key="input",
    history_messages_key="history"
)

# 多轮对话
config = {"configurable": {"session_id": "user-001"}}

r1 = chain_with_history.invoke({"input": "我叫小明"}, config=config)
print(r1.content)  # "你好小明！..."

r2 = chain_with_history.invoke({"input": "我叫什么名字？"}, config=config)
print(r2.content)  # "你叫小明..."（记住了上下文）
```

## 常用技巧与踩坑记录

### Token 用量控制

```python
from langchain_community.callbacks import get_openai_callback

with get_openai_callback() as cb:
    response = chain.invoke({"question": "解释反向传播算法"})
    print(f"Token 用量: {cb.total_tokens}")
    print(f"费用: ${cb.total_cost:.4f}")
```

### 流式输出

```python
# LCEL 链天然支持流式
for chunk in chain.stream({"question": "写一首关于代码的诗"}):
    print(chunk.content, end="", flush=True)
```

### 调试与追踪

```python
# 开启 verbose 模式
import langchain
langchain.debug = True

# 或者使用 LangSmith（推荐）
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = "your-langsmith-key"
```

### 常见踩坑

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| `ImportError` 找不到模块 | LangChain 拆包后模块位置变了 | 安装对应的子包，如 `langchain-openai` |
| 返回结果格式不对 | Prompt 不够明确 | 加上 `format_instructions`，用 Few-shot 示例 |
| RAG 检索结果不相关 | chunk 太大或太小 | 调整 `chunk_size` 和 `chunk_overlap` |
| Agent 陷入循环 | 工具描述不清晰 | 优化 `@tool` 的 docstring，加上使用示例 |
| 中文分割效果差 | 默认分割器按字符数 | 考虑用 `SpacyTextSplitter` 或自定义分割逻辑 |

## LangChain 生态一览

| 包名 | 用途 |
|------|------|
| `langchain-core` | 核心抽象和 LCEL |
| `langchain` | 链、Agent 等高级功能 |
| `langchain-openai` | OpenAI 模型集成 |
| `langchain-anthropic` | Anthropic Claude 集成 |
| `langchain-community` | 社区贡献的集成 |
| `langchain-chroma` | Chroma 向量数据库 |
| `langgraph` | 构建多步骤 Agent 工作流 |
| `langsmith` | 调试、测试和监控 |

## 总结

LangChain 的学习曲线不算陡峭，但它迭代很快，API 经常变动。我的建议是：

1. **先理解核心概念**（Model、Prompt、Chain、Retriever），不要急着上手复杂功能
2. **用 LCEL 写新代码**，不要用旧版的 `LLMChain` 等已弃用的 API
3. **从 RAG 开始实践**，这是最实用也最容易出成果的场景
4. **善用 LangSmith** 做调试和追踪，比 print 高效得多
5. **关注官方 Changelog**，及时了解 breaking changes

LangChain 不是银弹，简单任务直接调 API 可能更合适。但当你需要构建复杂的 LLM 应用时，它确实能帮你省很多事。

---

*这篇文章会随着我的使用经验持续更新。如果你有补充或不同的观点，欢迎在 GitHub 上提 Issue 交流。*

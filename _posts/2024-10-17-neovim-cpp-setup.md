---
title: 打造高效 Neovim C/C++ 开发环境：从零到一的完整指南
date: 2024-10-17 10:00:00 +0800
tags: [Neovim, C++, 开发环境, LSP]
excerpt: "用 clangd + Treesitter 打造 IDE 级体验，覆盖补全/诊断/调试/格式化/构建；修正 GDB/Lldb 适配，提供 Windows 与 CMake 指南。"
layout: post
comments: true
---

作为一个追求效率的开发者，我一直在寻找一个轻量、快速、可高度定制的编辑器。在尝试了各种 IDE 和编辑器后，我最终选择了 Neovim，并成功打造了一套完整的 C/C++ 开发环境。这篇文章将分享我的配置经验，帮你快速上手。

* TOC
{:toc}

## 为什么选择 Neovim？

Neovim 是 Vim 的现代化分支，相比传统 Vim，它具有以下优势：

- **异步执行**：插件和 LSP 不会阻塞编辑器
- **Lua 配置**：相比 VimScript，Lua 更现代、更易维护
- **内置 LSP 客户端**：原生支持 Language Server Protocol
- **活跃社区**：大量优秀插件和配置范例
- **跨平台**：Windows、Linux、macOS 都有良好支持

对于 C/C++ 开发，Neovim 配合 clangd LSP 可以实现：代码补全、跳转定义、实时诊断、重构、格式化等现代 IDE 的核心功能。

## 环境准备

### 安装 Neovim

**Windows (PowerShell):**
```powershell
# 使用 Chocolatey
choco install neovim

# 或使用 Scoop
scoop install neovim
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt install neovim

# Arch Linux
sudo pacman -S neovim

# 或下载最新 AppImage
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
sudo mv nvim.appimage /usr/local/bin/nvim
```

**macOS:**
```bash
brew install neovim
```

### 安装必要工具

C/C++ 开发需要以下工具链：

```bash
# 编译器 (选择其一)
# GCC
sudo apt install build-essential  # Linux
# Clang
sudo apt install clang

# CMake (项目构建)
sudo apt install cmake

# clangd (LSP 服务器)
sudo apt install clangd
# 或从 LLVM 官网下载最新版本

# clang-format (代码格式化)
sudo apt install clang-format

# GDB (调试器)
sudo apt install gdb
```

**Windows 用户**可通过 MSYS2 或 Visual Studio Build Tools 安装工具链。

## 插件管理器：lazy.nvim

现代 Neovim 配置首选 [lazy.nvim](https://github.com/folke/lazy.nvim) 插件管理器，它具有懒加载、性能优化、锁定版本等特性。

创建配置目录结构：

```bash
# Linux/macOS
mkdir -p ~/.config/nvim/lua

# Windows
mkdir ~\AppData\Local\nvim\lua
```

在 `~/.config/nvim/init.lua` 中添加：

```lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 基础设置
vim.g.mapleader = " "  -- 设置 Leader 键为空格
vim.g.maplocalleader = " "

-- 加载插件
require("lazy").setup("plugins")
```

## 核心插件配置

在 `~/.config/nvim/lua/plugins/` 目录下创建插件配置文件。

### LSP 配置 (lsp.lua)

```lua
return {
  -- LSP 配置管理
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")
      local lspconfig = require("lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      -- Mason 安装管理
      mason.setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })

      mason_lspconfig.setup({
        ensure_installed = {
          "clangd",  -- C/C++
          "cmake",   -- CMake
        },
        automatic_installation = true,
      })

      -- LSP 能力增强
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- clangd 配置
      lspconfig.clangd.setup({
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
        on_attach = function(client, bufnr)
          -- 键位绑定
          local opts = { buffer = bufnr, noremap = true, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
        end,
      })

      -- CMake LSP
      lspconfig.cmake.setup({
        capabilities = capabilities,
      })
    end,
  },

  -- Mason 工具安装器
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
  },
}
```

### 自动补全 (completion.lua)

```lua
return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer",       -- 缓冲区补全
    "hrsh7th/cmp-path",         -- 路径补全
    "hrsh7th/cmp-nvim-lsp",     -- LSP 补全
    "hrsh7th/cmp-cmdline",      -- 命令行补全
    "L3MON4D3/LuaSnip",         -- 代码片段引擎
    "saadparwaiz1/cmp_luasnip", -- 片段补全
    "rafamadriz/friendly-snippets", -- 预定义片段
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    
    -- 加载预定义片段
    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip", priority = 750 },
        { name = "buffer", priority = 500 },
        { name = "path", priority = 250 },
      }),
      formatting = {
        format = function(entry, vim_item)
          -- 图标美化
          vim_item.kind = string.format("%s %s", 
            ({
              Text = "",
              Method = "",
              Function = "",
              Constructor = "",
              Field = "",
              Variable = "",
              Class = "ﴯ",
              Interface = "",
              Module = "",
              Property = "ﰠ",
              Unit = "",
              Value = "",
              Enum = "",
              Keyword = "",
              Snippet = "",
              Color = "",
              File = "",
              Reference = "",
              Folder = "",
              EnumMember = "",
              Constant = "",
              Struct = "",
              Event = "",
              Operator = "",
              TypeParameter = ""
            })[vim_item.kind] or "",
            vim_item.kind
          )
          vim_item.menu = ({
            nvim_lsp = "[LSP]",
            luasnip = "[Snip]",
            buffer = "[Buf]",
            path = "[Path]",
          })[entry.source.name]
          return vim_item
        end
      },
    })
  end,
}
```

### 语法高亮 (treesitter.lua)

```lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "c", "cpp", "cmake", "make",
        "lua", "vim", "vimdoc",
        "bash", "markdown", "json",
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
      },
    })
  end,
}
```

### 文件浏览器 (neo-tree.lua)

```lua
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
  },
  config = function()
    require("neo-tree").setup({
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = {
          enabled = true,
        },
      },
      window = {
        width = 30,
      },
    })
  end,
}
```

### 模糊搜索 (telescope.lua)

```lua
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  cmd = "Telescope",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    { "<leader>fr", "<cmd>Telescope lsp_references<cr>", desc = "LSP references" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
          },
        },
      },
    })
    telescope.load_extension("fzf")
  end,
}
```

### 调试支持 (dap.lua)

```lua
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "theHamsta/nvim-dap-virtual-text",
    -- 如使用 LLDB：需要系统安装 lldb；如偏好 cpptools（Windows 友好），见下方"cppdbg"
  },
  keys = {
    { "<F5>", function() require("dap").continue() end, desc = "Debug: Continue" },
    { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
    { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
    { "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
    { "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
    { "<leader>dr", function() require("dap").repl.open() end, desc = "Debug: Open REPL" },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    -- DAP UI 配置
    dapui.setup()
    require("nvim-dap-virtual-text").setup()

    -- 自动打开/关闭 UI
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    -- 方案 A：LLDB（Linux/macOS 原生良好）
    dap.adapters.lldb = {
      type = "executable",
      command = "lldb-vscode", -- 一般随 lldb 安装
      name = "lldb",
    }
    dap.configurations.cpp = {
      {
        name = "Debug (LLDB)",
        type = "lldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},
      },
    }
    dap.configurations.c = dap.configurations.cpp

    -- 方案 B：cppdbg（VS Code cpptools 适配，Windows/跨平台）
    -- 安装 Microsoft 'cpptools'，获取 OpenDebugAD7 可执行文件路径并替换下面的 command
    -- local cpptools = "/path/to/OpenDebugAD7"
    -- dap.adapters.cppdbg = {
    --   id = "cppdbg",
    --   type = "executable",
    --   command = cpptools,
    --   options = { detached = false },
    -- }
    -- table.insert(dap.configurations.cpp, {
    --   name = "Debug (cppdbg)",
    --   type = "cppdbg",
    --   request = "launch",
    --   program = function()
    --     return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    --   end,
    --   cwd = "${workspaceFolder}",
    --   MIMode = "gdb", -- 或 "lldb"
    --   setupCommands = {
    --     { text = "-enable-pretty-printing", description = "pretty print", ignoreFailures = true },
    --   },
    -- })
  end,
}
```

## 基础编辑器配置

在 `~/.config/nvim/lua/config/options.lua` 中添加编辑器选项：

```lua
local opt = vim.opt

-- 行号
opt.number = true
opt.relativenumber = true

-- 缩进
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

-- 搜索
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- 外观
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8

-- 分割窗口
opt.splitright = true
opt.splitbelow = true

-- 系统剪贴板
opt.clipboard = "unnamedplus"

-- 备份
opt.swapfile = false
opt.backup = false
opt.undofile = true

-- 性能
opt.updatetime = 250
opt.timeoutlen = 300
```

在 `init.lua` 中加载：

```lua
require("config.options")
```

## 常用键位映射

在 `~/.config/nvim/lua/config/keymaps.lua` 中定义快捷键：

```lua
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 保存与退出
keymap("n", "<leader>w", ":w<CR>", opts)
keymap("n", "<leader>q", ":q<CR>", opts)

-- 窗口导航
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- 缓冲区切换
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- 移动行
keymap("n", "<A-j>", ":m .+1<CR>==", opts)
keymap("n", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- 代码折叠
keymap("n", "<leader>z", "za", opts)

-- 清除搜索高亮
keymap("n", "<leader>nh", ":nohl<CR>", opts)
```

## C/C++ 项目配置

### compile_commands.json

clangd 依赖 `compile_commands.json` 来理解项目结构。使用 CMake 生成：

```bash
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build
ln -s build/compile_commands.json .
```

或使用 [Bear](https://github.com/rizsotto/Bear) 为 Makefile 项目生成：

```bash
bear -- make
```

### .clang-format

在项目根目录创建 `.clang-format` 定义代码风格：

```yaml
BasedOnStyle: LLVM
IndentWidth: 4
ColumnLimit: 100
PointerAlignment: Left
AllowShortFunctionsOnASingleLine: Empty
```

### .clangd

创建 `.clangd` 配置文件：

```yaml
CompileFlags:
  Add: [-std=c++17, -Wall, -Wextra]
  Remove: [-W*, -std=*]

Diagnostics:
  UnusedIncludes: Strict
  MissingIncludes: Strict

InlayHints:
  Enabled: Yes
  ParameterNames: Yes
  DeducedTypes: Yes
```

## 实战演示

创建一个简单的 C++ 项目测试配置：

```cpp
// main.cpp
#include <iostream>
#include <vector>
#include <algorithm>

class Calculator {
public:
    int add(int a, int b) const {
        return a + b;
    }
    
    double average(const std::vector<int>& nums) const {
        if (nums.empty()) return 0.0;
        int sum = 0;
        for (int num : nums) {
            sum += num;
        }
        return static_cast<double>(sum) / nums.size();
    }
};

int main() {
    Calculator calc;
    std::cout << "5 + 3 = " << calc.add(5, 3) << std::endl;
    
    std::vector<int> numbers = {1, 2, 3, 4, 5};
    std::cout << "Average: " << calc.average(numbers) << std::endl;
    
    return 0;
}
```

打开文件后，你会看到：
- **语法高亮**：基于 Tree-sitter 的精准高亮
- **实时诊断**：clangd 提供错误和警告提示
- **自动补全**：输入时显示智能补全菜单
- **跳转定义**：按 `gd` 跳转到函数定义
- **悬停文档**：按 `K` 查看函数签名和文档
- **代码格式化**：按 `<leader>f` 格式化当前文件

## 性能优化技巧

1. **延迟加载插件**：使用 `lazy.nvim` 的 `event`、`cmd`、`ft` 触发器
2. **限制 LSP 作用域**：对大型项目，使用 `.clangd` 排除不需要的目录
3. **禁用不需要的 Treesitter 功能**：如 `rainbow` 括号匹配
4. **使用更快的 grep 工具**：安装 `ripgrep` 提升搜索速度

```bash
sudo apt install ripgrep
```

## 主题美化（可选）

推荐几个流行主题：

```lua
-- catppuccin
return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    vim.cmd.colorscheme "catppuccin-mocha"
  end,
}

-- tokyonight
return {
  "folke/tokyonight.nvim",
  priority = 1000,
  config = function()
    vim.cmd.colorscheme "tokyonight-night"
  end,
}
```

## 常见问题与解决方案

### clangd 无法找到头文件

**解决方法**：确保生成了 `compile_commands.json`，或在 `.clangd` 中手动指定包含路径：

```yaml
CompileFlags:
  Add: [-I/usr/include, -I/usr/local/include]
```

### 补全菜单不显示

**解决方法**：检查 LSP 是否正常运行：

```vim
:LspInfo
```

确保 clangd 状态为 `active`。

### 格式化风格不符合预期

**解决方法**：创建或修改 `.clang-format` 文件，参考 [Clang-Format 文档](https://clang.llvm.org/docs/ClangFormatStyleOptions.html)。

### 启动速度慢

**解决方法**：
1. 运行 `:Lazy profile` 查看插件加载时间
2. 对慢速插件添加懒加载配置
3. 减少 `ensure_installed` 的语言数量

## 进阶技巧

### CMake 集成

安装 `cmake-tools` 插件实现一键构建：

```lua
return {
  "Civitasv/cmake-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("cmake-tools").setup({})
  end,
}
```

快捷键：
- `<leader>cg`：CMake 配置
- `<leader>cb`：CMake 构建
- `<leader>cr`：CMake 运行

### Git 集成

使用 `gitsigns` 和 `lazygit`：

```lua
-- Gitsigns
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup({
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
      },
    })
  end,
}

-- Lazygit
return {
  "kdheepak/lazygit.nvim",
  keys = {
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
  },
}
```

### 单元测试

对于 Google Test 项目，配置调试启动项：

```lua
-- 在 dap.configurations.cpp 中添加
{
  name = "Run Tests",
  type = "cppdbg",
  request = "launch",
  program = "${workspaceFolder}/build/tests/unit_tests",
  args = { "--gtest_filter=MyTest.*" },
  cwd = "${workspaceFolder}",
  stopAtEntry = false,
}
```

## 完整配置示例

我的完整配置已开源在 GitHub，包含更多插件和细节：

```bash
git clone https://github.com/magic-alt/nvim-cpp-ide.git ~/.config/nvim
```

> 该仓库包含完整的 Neovim C/C++ IDE 配置，开箱即用。

## 总结

通过本文的配置，你已经拥有了一个功能完整的 Neovim C/C++ 开发环境，包括：

- ✅ 强大的 LSP 支持（代码补全、诊断、跳转）
- ✅ 智能自动补全与代码片段
- ✅ 语法高亮与代码折叠
- ✅ 可视化调试
- ✅ 代码格式化
- ✅ 文件浏览与模糊搜索
- ✅ Git 集成

相比传统 IDE，Neovim 配置更灵活、启动更快、资源占用更低。虽然初期需要投入时间学习，但一旦掌握，你将拥有一个完全按照自己习惯定制的开发环境。

如果你在配置过程中遇到问题，欢迎在评论区交流，或者参考 [Neovim 官方文档](https://neovim.io/doc/) 和社区资源。Happy Coding! 🚀

---

## Windows 专项提示

1. **工具链**：首选 LLVM/Clang + lldb（choco/scoop 可得），或 MSVC + cpptools（cppdbg）。  
2. **编译数据库**：CMake 生成的 `build/compile_commands.json` 在 Windows 可用 `mklink` 建软链接：  
   ```bat
   mklink compile_commands.json .\build\compile_commands.json
   ```  
3. **路径与编码**：确保 `shell` 使用 UTF-8，PowerShell 里：`[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()`。

## CMake Presets 与构建一键化

在项目根加入 `CMakePresets.json`（示例）：

```json
{
  "version": 3,
  "cmakeMinimumRequired": { "major": 3, "minor": 20 },
  "configurePresets": [
    {
      "name": "dev",
      "generator": "Ninja",
      "binaryDir": "${sourceDir}/build",
      "cacheVariables": {
        "CMAKE_EXPORT_COMPILE_COMMANDS": "ON",
        "CMAKE_BUILD_TYPE": "Debug"
      }
    }
  ],
  "buildPresets": [{ "name": "dev", "configurePreset": "dev" }]
}
```

Neovim 内可配合 `Civitasv/cmake-tools.nvim`：  
`<leader>cg` 配置、`<leader>cb` 构建、`<leader>cr` 运行。

## clangd 体验升级参数

在 `lspconfig.clangd.setup` 中建议启用：

```lua
cmd = {
  "clangd",
  "--background-index",
  "--clang-tidy",
  "--header-insertion=never", -- 避免自动插入不需要的头
  "--completion-style=detailed",
  "--function-arg-placeholders",
  "--fallback-style=llvm",
}
```

## 常见故障排查（速查表）

| 现象 | 排查点 | 处理 |
|---|---|---|
| 补全失效 | `:LspInfo` 看 clangd 是否 attached | 检查 `compile_commands.json`、根目录是否一致 |
| 跳转慢 | 后台索引未完成 | 等待 `clangd` 后台索引；排除巨型目录 |
| 调试断点不生效 | 可执行无符号表 | 使用 `-g` 或 `-DCMAKE_BUILD_TYPE=Debug` 重新构建 |
| 终端中文乱码 | 终端编码/字体 | 统一 UTF-8，选择等宽字体（JetBrains Mono） |
| Mason 安装失败 | 网络问题/权限不足 | 使用代理或手动下载 LSP 二进制文件 |

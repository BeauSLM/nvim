-- TODO:
-- :s respects case
-- wrap mapping function
-- give all my keymaps descriptions
-- put all autocommands in a group so they don't get re-added on re-source
-- have mini pickers put shit in qf list where possible and replace with gf variants where not




vim.cmd('filetype plugin indent on')

-- apparently I have to put this before the package manager
vim.g.mapleader = ' '

-- strangely enough this contains what shell I'm using - huh
-- TODO: check if fish exists and use it if so
if vim.env.STARSHIP_SHELL then
    vim.opt.shell = vim.env.STARSHIP_SHELL
end

vim.g.zig_fmt_autosave = 0

vim.opt.termguicolors  = true
vim.opt.number         = true
vim.opt.relativenumber = true

vim.opt.tabstop        = 4
vim.opt.shiftwidth     = 0 -- indent is just the length of one tab
vim.opt.expandtab      = true
vim.opt.smarttab       = true
vim.opt.autoindent     = true
vim.opt.smartindent    = true
vim.opt.cindent        = true
vim.opt.breakindent    = true
vim.opt.breakindentopt = 'list:-1'
vim.opt.linebreak      = true

vim.opt.scrolloff      = 10
vim.opt.colorcolumn    = '81'
vim.opt.splitbelow     = true
vim.opt.splitright     = true

vim.opt.hidden         = true
vim.opt.swapfile       = false
vim.opt.undofile       = true

vim.opt.incsearch      = true
vim.opt.ignorecase     = true
vim.opt.smartcase      = true

vim.opt.pumheight      = 5

vim.opt.foldmethod     = 'indent'
vim.opt.foldnestmax    = 10
vim.opt.foldlevel      = 99
vim.g.markdown_folding = 1

vim.opt.cursorline     = true
vim.opt.cursorcolumn   = true

vim.opt.cmdheight      = 1

vim.filetype.add({
    extension = {
        mdpp = 'markdown',
        mdx = 'markdown.mdx'
    },
})

local make_keymap = vim.keymap.set

-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local clone_cmd = {
        'git', 'clone', '--filter=blob:none',
        'https://github.com/echasnovski/mini.nvim', mini_path
    }
    vim.fn.system(clone_cmd)
    vim.cmd('packadd mini.nvim | helptags ALL')
    vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require'mini.deps'.setup { path = { package = path_package } }

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

add('nvim-tree/nvim-web-devicons')
require'nvim-web-devicons'.setup()

require'mini.extra'      .setup() -- first because other plugins depend on it

require'mini.align'      .setup()
require'mini.bracketed'  .setup()
require'mini.bufremove'  .setup()
require'mini.cursorword' .setup()
require'mini.indentscope'.setup()
require'mini.move'       .setup()
require'mini.splitjoin'  .setup()
require'mini.statusline' .setup()
require'mini.tabline'    .setup()

require'mini.jump'       .setup {
    delay = {
        idle_stop = 750,
    }
}

require'mini.operators'  .setup {
    exchange = { prefix = 'sx' }
}

require'mini.trailspace' .setup()
make_keymap( 'n', '<leader>w', function()
    MiniTrailspace.trim()
    MiniTrailspace.trim_last_lines()
end, {} )

require'mini.git' .setup()
make_keymap( {'n', 'x'}, '<leader>gg', MiniGit.show_at_cursor, {} )

require'mini.diff'.setup {
    view = { style = 'sign' },
    mappings = { textobject = 'ih', },
}
make_keymap( '', '<leader>gh', MiniDiff.toggle,         {} )
make_keymap( '', '<leader>gf', MiniDiff.toggle_overlay, {} )

local hipatterns = require'mini.hipatterns'
local hi_words = MiniExtra.gen_highlighter.words
hipatterns.setup {
    highlighters = {
        todo  = hi_words({ 'TODO',  'REVIEW', 'INCOMPLETE'           }, 'MiniHipatternsTodo' ),
        fixme = hi_words({ 'FIXME', 'BUG',    'ROBUSTNESS', 'CRASH', }, 'MiniHipatternsFixme'),
        note  = hi_words({ 'NOTE',  'INFO',                          }, 'MiniHipatternsNote' ),
        hack  = hi_words({ 'HACK',  'XXX',                           }, 'MiniHipatternsHack' ),

        hex_color = hipatterns.gen_highlighter.hex_color(),
    },
    delay = {
        text_change = 0,
        scroll = 0,
    },
}

require 'mini.comment'.setup {
    options = {
        custom_commentstring = function()
            return require 'ts_context_commentstring'.calculate_commentstring()
        end,
    },
    mappings = { textobject = 'ic', },
}

require 'mini.surround'.setup {
    respect_selection_type = true,
}

require 'mini.notify'.setup {
    lsp_progress = {
        -- enable = false,
        duration_last = 350,
    },
}

require 'mini.pick'.setup {
    mappings = {
        refine        = '<C-;>',
        refine_marked = '<M-;>',
    },
}
local builtin = MiniPick.builtin
local extra_pickers = MiniExtra.pickers

make_keymap( 'n', '<leader>ff', builtin.files,   {} )
make_keymap( 'n', '<leader>fh', builtin.help,    {} )
make_keymap( 'n', '<leader>fb', builtin.buffers, {} )

-- TODO: make cword maps use word highlighted by visual if applicable
-- TODO: leader-8 find cword in the current buffer
make_keymap( 'n', '<leader>/', extra_pickers.buf_lines, {} )
-- make_keymap( 'n', '<leader>8', '<Cmd>Pick buf_lines prompt="<cword>"<CR>', {} )
-- TODO: ugrep_live (fuzzy finding + --and patterns for each word)
make_keymap( 'n', '<leader>?', builtin.grep_live,                          {} )
make_keymap( 'n', '<leader>*', '<Cmd>Pick grep pattern="<cword>"<CR>',     {} )

make_keymap( '',  '<leader>fc', extra_pickers.commands )
make_keymap( '',  '<leader>fd', extra_pickers.diagnostic )
make_keymap( 'n', '<leader>fo', extra_pickers.options )
make_keymap( 'n', '<leader>td', '<Cmd>Pick hipatterns highlighters={"todo" "fixme" "hack"}<CR>' )

make_keymap( '', '<leader>fq', function() extra_pickers.list({ scope = 'quickfix' }) end, {})
make_keymap( '', '<leader>fv', function() extra_pickers.visit_paths() end, {})
make_keymap( '', '<leader>fl', function() extra_pickers.visit_labels() end, {})

require 'mini.visits'.setup()
vim.api.nvim_create_autocmd( 'BufReadPre', {
    callback = function(args)
        local currentDir = vim.fn.getcwd()
        local bufDir     = vim.fn.fnamemodify( args.file, ':p:h' )
        if not vim.startswith( bufDir, currentDir ) then
            vim.b.minivisits_disable = true
        end
    end,
})
make_keymap( 'n', '<leader>vp', MiniVisits.select_path, {} )
make_keymap( 'n', '<leader>vl', MiniVisits.select_label, {} )
make_keymap( 'n', '<leader>va', MiniVisits.add_label, {} )
make_keymap( 'n', '<leader>vd', MiniVisits.remove_label, {} )

local ai = require'mini.ai'
local gen_spec = ai.gen_spec
local extra_ai_spec = MiniExtra.gen_ai_spec
ai.setup({
    custom_textobjects = {
        F = gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
        c = gen_spec.treesitter({ a = '@class.outer',    i = '@class.inner'    }),
        S = gen_spec.treesitter({ a = '@block.outer',    i = '@block.inner'    }),
        j = extra_ai_spec.line(),
        d = extra_ai_spec.number(),
        g = extra_ai_spec.buffer(),
        e = extra_ai_spec.diagnostic(),
        -- TODO:
        --      assignment inner
        --      assignment outer
        --      assignment lhs
        --      assignment rhs
    },
})

require 'mini.files'.setup {
    windows = {
        max_number = 3,
    },
}
local open = MiniFiles.open
make_keymap( 'n', '<leader>fe', open, {} )
make_keymap( 'n', '<leader>fi', function()
    local buf = vim.api.nvim_buf_get_name( 0 )

    local file = io.open( buf ) and buf or vim.fs.dirname( buf )

    open( file )
end, {} )

require 'mini.misc'.setup()
MiniMisc.setup_restore_cursor()
make_keymap( 'n', '<leader>z', MiniMisc.zoom, {} )

require 'mini.sessions'.setup()
make_keymap( 'n', '<leader>ss', function()
    local session = #vim.v.this_session == 0 and vim.fn.input({
        prompt = 'Session name: ',
        default = MiniSessions.config.file,
        completion = 'file',
    }) or nil

    if session then
        if session == '' then return end
        if not vim.endswith(session, '.vim') then session = session .. '.vim' end
    end

    MiniSessions.write(session)
end, {} )

local function sessionaction(action)
    local exists = false
    for _, _ in pairs(MiniSessions.detected) do
        exists = true
        break
    end

    if not exists then
        print('No sessions')
        return
    end

    MiniSessions.select(action)
end

make_keymap( 'n', '<leader>sf', function()
    sessionaction('read')
end, {} )
make_keymap( 'n', '<leader>sd', function()
    sessionaction('delete')
end, {} )
make_keymap( 'n', '<leader>sw', function()
    sessionaction('write')
end, {} )

local starter = require'mini.starter'
starter.setup {
    evaluate_single = true,
    items = {
        starter.sections.sessions(),
        starter.sections.recent_files(4, true, false),
        starter.sections.builtin_actions(),
    },
}

require 'mini.completion'.setup {
    mappings = {
        force_twostep  = '<C-j>',
        force_fallback = '<C-k>',
    },
    delay = { completion = 9999, info = 0, signature = 0 },
    lsp_completion = {
        source_func = 'omnifunc',
        auto_setup  = false
    },
    window = { signature = { width = 120 }, },
    set_vim_settings = true, -- set shortmess and completeopt
}

add('tpope/vim-dispatch')
add('tpope/vim-abolish')

vim.g.scratchpad_autostart = 0
vim.g.scratchpad_location  = vim.fn.stdpath( 'data' ) .. '/scratchpad'
add('FraserLee/ScratchPad')
make_keymap( 'n', 'S', require'scratchpad'.invoke, {} )

add("stevearc/dressing.nvim")

require'dressing'.setup {
    input = {
        insert_only     = false,
        start_in_insert = false,
    },
}


add({
    source = 'nvim-treesitter/nvim-treesitter',
    checkout = 'master',
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
})
require'nvim-treesitter.configs'.setup {
    auto_install = true,
    ensure_installed = {
        'asm',
        'astro',
        'bash',
        'c',
        'cpp',
        'css',
        'csv',
        'diff',
        'dockerfile',
        'fish',
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'gitignore',
        'go',
        'gomod',
        'gosum',
        'gowork',
        'html',
        'javascript',
        'jsdoc',
        'json',
        'json5',
        'just',
        'lua',
        'luadoc',
        'make',
        'markdown',
        'markdown_inline',
        'ocaml',
        'ocaml_interface',
        'ocamllex',
        'odin',
        'printf',
        'python',
        'regex',
        'requirements',
        'rust',
        'scss',
        'todotxt',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
    },
    -- TODO: use ziglibs zig ts parser
    ignore_install = { 'zig' },
    indent = {
        enable = true,
        disable = { 'odin', 'ocaml' },
    },
}
vim.api.nvim_create_autocmd("Filetype", {
    callback = function(ev)
        -- TODO: if longest line in buffer is too long kill

        if not require "nvim-treesitter.parsers".has_parser() or
          vim.api.nvim_buf_line_count(ev.buf) > 1024 then
            return
        end

        vim.treesitter.start()
    end,
})

add('nvim-treesitter/nvim-treesitter-textobjects')

vim.g.skip_ts_context_commentstring_module = true
add('JoosepAlviste/nvim-ts-context-commentstring')
require'ts_context_commentstring'.setup {
    enable_autocmd = false,
    languages = {
        cpp = '// %s',
        wgsl = '// %s',
        just = '# %s',
    },
}

add('HiPhish/rainbow-delimiters.nvim')

add('nvim-treesitter/nvim-treesitter-context')
require'treesitter-context'.setup {
    multiline_threshold = 4,
    trim_scope = 'inner',
    mode = 'topline',
}

-- additional textobject keys after "a" and "i" e.g. <something>[a|i]q where q is quote text object
add('nvim-treesitter/nvim-treesitter-textobjects')

vim.g.gruvbox_material_foreground = 'original'
vim.g.gruvbox_material_background = 'hard'
add('sainnhe/gruvbox-material')

vim.g.material_style = "deep ocean"
add('marko-cerovac/material.nvim')
require'material'.setup {
    plugins = {
        "indent-blankline",
        "mini",
        "nvim-web-devicons",
        "rainbow-delimiters",
    },
}

add("lukas-reineke/indent-blankline.nvim")
require'ibl'.setup { scope = { enabled = false }, }

vim.g.VM_maps = {
    [ 'Add Cursor Down' ] = '<C-j>',
    [ 'Add Cursor Up'   ] = '<C-k>',
}
add('mg979/vim-visual-multi')

-- highlight cursor after large jump
add('rainbowhxch/beacon.nvim')

-- fast j and k YEAH BUDDY
-- holding j, k, w, b, W, B, etc goes fast after a while
add('rainbowhxch/accelerated-jk.nvim')
require'accelerated-jk'.setup {
    acceleration_motions = { 'w', 'b', 'W', 'B' },
}


-- jai syntax-highlighting + folds + whatever
vim.g.jai_compiler = vim.env.HOME .. '/thirdparty/jai/bin/jai-macos'
add('puremourning/jai.vim')

add('supermaven-inc/supermaven-nvim')
require'supermaven-nvim'.setup {
    keymaps = {
        accept_suggestion = '<M-l>',
        clear_suggestion = '<M-h>',
        accept_word = '<M-j>',
    },
    ignore_filetypes = {
        DressingInput = true,
    },
}

add('stevearc/conform.nvim')
local conform = require'conform'
conform.setup {
    formatters_by_ft = {
        css             = { { "prettierd", "prettier" } },
        go              = { "gofmt", }, -- TODO: goimports
        html            = { { "prettierd", "prettier" } },
        javascript      = { { "prettierd", "prettier" } },
        javascriptreact = { { "prettierd", "prettier" } },
        json            = { { "prettierd", "prettier" } },
        ocaml           = { "ocp-indent", "ocamlformat", }, -- TODO: goimports
        odin            = { "odinfmt" },
        python          = { "ruff_format" },
        rust            = { "rustfmt" },
        typescript      = { { "prettierd", "prettier" } },
        typescriptreact = { { "prettierd", "prettier" } },
        zig             = { "zigfmt" },
    }
}
vim.api.nvim_create_autocmd('FileType', {
    pattern = vim.tbl_keys(conform.formatters_by_ft),
    -- group = vim.api.nvim_create_augroup('conform_formatexpr', { clear = true }),
    callback = function()
        vim.opt_local.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
})

add('luckasRanarison/tailwind-tools.nvim')
require'tailwind-tools'.setup({})

add('neovim/nvim-lspconfig')

add("folke/lazydev.nvim")
require'lazydev'.setup()

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function( ev )
        vim.bo[ev.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'

        local bufopts = { buffer = ev.buf }
        local lsp     = vim.lsp
        local lspbuf  = lsp.buf
        local function picklsp( scope )
            return function()
                MiniExtra.pickers.lsp( { scope = scope } )
            end
        end

        make_keymap( 'n', '<leader>gD',  lspbuf.declaration,     bufopts )
        make_keymap( 'n', '<leader>i',   lspbuf.signature_help,  bufopts )
        make_keymap( 'n', '<leader>rn',  lspbuf.rename,          bufopts )
        make_keymap( 'n', '<leader>ca',  lspbuf.code_action,     bufopts )

        make_keymap( 'n', '<leader>gr',  lspbuf.references,      bufopts )
        make_keymap( 'n', '<leader>gd',  lspbuf.definition,      bufopts )
        make_keymap( 'n', '<leader>gi',  lspbuf.implementation,  bufopts )
        make_keymap( 'n', '<leader>gtd', lspbuf.type_definition, bufopts )
        make_keymap( 'n', '<leader>fs',  lspbuf.document_symbol, bufopts )
        make_keymap( 'n', '<leader>co',  lspbuf.incoming_calls,  bufopts )
        make_keymap( 'n', '<leader>ci',  lspbuf.outgoing_calls,  bufopts )

        local inlay_hint = lsp.inlay_hint
        make_keymap( 'n', '<leader>h', function()
            local enabled = inlay_hint.is_enabled( { bufnr = ev.buf, } )
            inlay_hint.enable( not enabled, { bufnr = ev.buf, } )
        end, bufopts )

        local diagnostic = vim.diagnostic

        make_keymap('n', '<leader>bd', diagnostic.setloclist, bufopts)

        make_keymap('n', '<leader>d', function()
            local buf = { bufnr = ev.buf }
            diagnostic.enable(not diagnostic.is_enabled(buf), buf)
        end, bufopts)
    end
})
local lspconfig = require'lspconfig'
for _, server in pairs({
    'astro',
    'bashls',
    'clangd',
    'cssls',
    'dockerls',
    'eslint',
    'gopls',
    'html',
    'jsonls',
    'lua_ls',
    'ocamllsp',
    'pyright',
    'rust_analyzer',
    'tailwindcss',
    'tsserver',
    'yamlls',
}) do
    lspconfig[server].setup{}
end
lspconfig.ols.setup {
    init_options = {
        enable_document_symbols  = true,
        enable_snippets          = false,
        enable_inlay_hints       = true,
        enable_references        = true,
        enable_hover             = true,
        enable_procedure_context = true,
    },
}

local configs = require'lspconfig.configs'

if configs.jails then error("Jails config exists") end

local util = lspconfig.util
configs.jails = {
    default_config = {
        cmd                 = { 'jails', },
        filetypes           = { 'jai', },
        single_file_support = true,
        root_dir            = function( fname )
            return util.root_pattern(
                'build.jai',
                'first.jai',
                'jails.json'
            )(fname) or util.find_git_ancestor(fname)

                -- HACK: jails crashes if I don't put this - lspconfig docs tell me explicitly to NOT do this
                or util.path.dirname(fname)
        end,
    },
}
lspconfig.jails.setup{}

-- keymaps for built in things
make_keymap( '',  '<C-s>', vim.cmd.wall, {} ) -- save file
make_keymap( '!', '<C-s>', vim.cmd.wall, {} ) -- save file

make_keymap( 'n', '<TAB>e', vim.cmd.tabedit, {} ) -- new tab
make_keymap( 'n', '<TAB>q', vim.cmd.tabclose, {} ) -- new tab
make_keymap( 'n', '<TAB>o', vim.cmd.tabonly, {}  ) -- new tab

make_keymap( 'n', '<leader>cw', '<C-w><C-q>', {} )
make_keymap( '', '<C-l>', 'g$', {} )
make_keymap( '', '<C-h>', 'g^', {} )


make_keymap( '', '<leader>q', function()
    local windows = vim.fn.getwininfo()
    for _, win in pairs(windows) do
        if win['quickfix'] == 1 then
            vim.cmd.cclose()
            return
        end
    end
    vim.cmd.copen()
end, {} )

-- credit: fraser and https://github.com/echasnovski/mini.basics/blob/c31a4725710db9733e8a8edb420f51fd617d72a3/lua/mini/basics.lua#L600-L606
make_keymap( 'n', '<C-z>', '[s1z=',                     { desc = 'Correct latest misspelled word' } )
make_keymap( 'i', '<C-z>', '<C-g>u<Esc>[s1z=`]a<C-g>u', { desc = 'Correct latest misspelled word' } )

-- from mini.basic
make_keymap('x', 'g/', '<esc>/\\%V', { silent = false, desc = 'Search inside visual selection' })

 --[[ BEGIN https://github.com/echasnovski/mini.nvim/blob/1fdbb864e2015eb6f501394d593630f825154385/lua/mini/basics.lua#L549C11-L549C11 ]]
-- Add empty lines before and after cursor line supporting dot-repeat
local cache_empty_line = nil
function put_empty_line(put_above)
    -- This has a typical workflow for enabling dot-repeat:
    -- - On first call it sets `operatorfunc`, caches data, and calls
    --   `operatorfunc` on current cursor position.
    -- - On second call it performs task: puts `v:count1` empty lines
    --   above/below current line.
    if type(put_above) == 'boolean' then
        vim.o.operatorfunc = 'v:lua.put_empty_line'
        cache_empty_line = { put_above = put_above }
        return 'g@l'
    end
    local target_line = vim.fn.line('.') - (cache_empty_line.put_above and 1 or 0)
    vim.fn.append(target_line, vim.fn['repeat']({ '' }, vim.v.count1))
end
make_keymap( 'n', '[<space>', 'v:lua.put_empty_line(v:true)',  { expr = true, desc = 'Put empty line above' } )
make_keymap( 'n', ']<space>', 'v:lua.put_empty_line(v:false)', { expr = true, desc = 'Put empty line below' } )
--[[ ----------------------------------- END ---------------------------------- ]]

make_keymap( 'n', 'Y',         'y$',   {} ) -- yank to end of line
make_keymap( 'n', '<leader>Y', '"+y$', {} ) -- yank to end of line

make_keymap( { 'n', 'v' }, '<leader>y', '"+y', {} ) -- yank to clipboard
make_keymap( { 'n', 'v' }, '<leader>p', '"+p', {} ) -- put from clipboard

make_keymap( '', '<C-d>', '<C-d>zz', {} ) -- scroll down
make_keymap( '', '<C-u>', '<C-u>zz', {} ) -- scroll down

-- change directory to current file - thanks fraser
-- TODO: print directory I cd'd to
-- TODO: look at vim cd commands and see if one of them is applicable
--     - current file
--     - current buffer
--     - current window
--     - etc.
make_keymap( 'n', '<leader>cd', '<Cmd>cd %:p:h<CR>', {} )
make_keymap( 'n', '<leader>..', '<Cmd>cd ..<CR>',    {} )

-- fraser again goddamn
make_keymap( 'n', '<ESC>', function()
    vim.cmd.nohlsearch()
    vim.cmd.cclose()
    vim.cmd.lclose()
    MiniJump.stop_jumping()
end, {} )

make_keymap( 'n', '<leader>cc', MiniBufremove.delete, {}   )
make_keymap( 'n', 'Q',          vim.cmd.bd,           {} )

-- jk fixes (thanks yet again fraser)
make_keymap( 'n', 'j', '<Plug>(accelerated_jk_gj)', {} )
make_keymap( 'n', 'k', '<Plug>(accelerated_jk_gk)', {} )

make_keymap( 'v', 'j', 'gj', {} )
make_keymap( 'v', 'k', 'gk', {} )

---------------------------------------------------------------------------
-- write centered line - 80 character line with text in the middle and dashes
-- padding it
make_keymap( 'n', '<leader>l', function()
    local line = vim.fn.trim( vim.fn.getline( '.' ) )

    local comment_text = line ~= '' and line or vim.fn.input( 'Comment text: ' )

    -- make the comment_text either an empty string, or pad it with spaces
    if comment_text ~= '' then comment_text = ' ' .. comment_text .. ' ' end

    local comment_len = string.len( comment_text )
    local indent_len  = vim.fn.cindent( '.' )
    local dash_len    = 77 - indent_len -- TODO: factor in commentstring

    local half_dash_len    = math.floor( dash_len    / 2 )
    local half_comment_len = math.floor( comment_len / 2 )

    local num_left_dashes  = half_dash_len - half_comment_len
    local num_right_dashes = dash_len - num_left_dashes - comment_len

    local leading_spaces    = string.rep( ' ', indent_len       ) -- indent
    local left_dash_string  = string.rep( '-', num_left_dashes  )
    local right_dash_string = string.rep( '-', num_right_dashes )

    local new_line = leading_spaces .. left_dash_string .. comment_text .. right_dash_string
    vim.fn.setline( '.', new_line )

    local linenum = vim.api.nvim_win_get_cursor( 0 )[ 1 ]
    MiniComment.toggle_lines( linenum, linenum )
end , {} )

vim.cmd[[
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank( { timeout = 100 } )

    autocmd Filetype * setlocal formatoptions+=jcqrno formatoptions-=t

    autocmd FileType html,css,scss,json,jsonc,xml,javascript,javascriptreact,typescript,typescriptreact,astro,yaml setlocal nocindent shiftwidth=2 tabstop=2 foldmethod=expr foldexpr=nvim_treesitter#foldexpr()

    autocmd Filetype text,markdown,gitcommit setlocal spell autoindent comments-=fb:* comments-=fb:- comments-=fb:+
    autocmd BufEnter * lua pcall(require'mini.misc'.use_nested_comments)

    autocmd FileType DressingInput,gitcommit let b:minicompletion_disable = v:true | let b:minivisits_disable = v:true | let b:minitrailspace_disable = v:true

    autocmd FileType odin setlocal smartindent errorformat+=%f(%l:%c)\ %m

    autocmd FileType gitconfig,go setlocal noexpandtab tabstop=8

    " colorscheme gruvbox-material
    colorscheme material

    set rtp^="/Users/beaum/.opam/default/share/ocp-indent/vim
]]

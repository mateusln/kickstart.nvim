-- PHP Refactoring Tools

return {
    'Exafunction/codeium.vim',
    event = 'BufEnter',
    config = function()
        vim.g.codeium_no_map_tab = 1
        vim.keymap.set('i', '<C-a>', function()
            return vim.fn['codeium#Accept']()
        end, { expr = true, silent = true })
        vim.keymap.set('i', '<c-;>', function()
            return vim.fn['codeium#CycleCompletions'](1)
        end, { expr = true, silent = true })
        vim.keymap.set('i', '<c-,>', function()
            return vim.fn['codeium#CycleCompletions'](-1)
        end, { expr = true, silent = true })
    end,
}

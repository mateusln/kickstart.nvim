-- ~/.config/nvim/lua/php-interface.lua

local M = {}

function M.generate_php_interface()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    local class_name = ''
    local namespace = ''
    local methods = {}

    local capturing_method = false
    local current_method_lines = {}

    for _, line in ipairs(lines) do
        -- Detect namespace
        if line:match '^namespace ' then
            namespace = line:match 'namespace%s+(.-);'
        end

        -- Detect class name
        if line:match 'class ' then
            class_name = line:match 'class%s+(%w+)'
        end

        -- Handle method capture
        if capturing_method then
            local before_brace = line:match '^(.-){'
            if before_brace then
                table.insert(current_method_lines, before_brace)
                capturing_method = false
                -- Process captured lines
                local full_method = table.concat(current_method_lines, ' ')
                local method_signature = full_method:match 'public%s+function%s+(.-)%s*$'
                if method_signature then
                    method_signature = method_signature:gsub('%s+', ' '):gsub('^%s*', ''):gsub('%s*$', '')
                    table.insert(methods, method_signature)
                end
                current_method_lines = {}
            else
                table.insert(current_method_lines, line)
            end
        else
            if line:match '^%s*public%s+function%s+' then
                capturing_method = true
                current_method_lines = { line }
                -- Check if the opening brace is on the same line
                local before_brace = line:match '^(.-){'
                if before_brace then
                    capturing_method = false
                    local full_method = before_brace
                    local method_signature = full_method:match 'public%s+function%s+(.-)%s*$'
                    if method_signature then
                        method_signature = method_signature:gsub('%s+', ' '):gsub('^%s*', ''):gsub('%s*$', '')
                        table.insert(methods, method_signature)
                    end
                    current_method_lines = {}
                end
            end
        end
    end

    if class_name == '' then
        print 'Nenhuma classe encontrada no buffer atual'
        return
    end

    local interface_lines = {}

    if namespace ~= '' then
        table.insert(interface_lines, 'namespace ' .. namespace .. ';')
        table.insert(interface_lines, '')
    end

    table.insert(interface_lines, 'interface ' .. class_name .. 'Interface')
    table.insert(interface_lines, '{')

    for _, method in ipairs(methods) do
        table.insert(interface_lines, '    public function ' .. method .. ';')
    end

    table.insert(interface_lines, '}')

    local interface_filename = class_name .. 'Interface.php'
    vim.api.nvim_command('vsplit ' .. vim.fn.fnameescape(interface_filename))

    local new_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, interface_lines)
    vim.api.nvim_buf_set_option(new_buf, 'filetype', 'php')
end

vim.api.nvim_create_user_command('GeneratePHPInterface', M.generate_php_interface, {})

return M

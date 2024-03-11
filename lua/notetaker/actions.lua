local M = {}

local notes_dir = nil -- Directory to store notes


local function list_files_recursive(base_path, path, files, prefix)
    prefix = prefix or ""
    local full_path = base_path .. "/" .. path
    local scan, err = vim.loop.fs_scandir(full_path)
    if err then
        print("Error reading directory: " .. err)
        return
    end

    while true do
        local name, type = vim.loop.fs_scandir_next(scan)
        if not name then break end
        if type == "directory" then
            list_files_recursive(base_path, path .. "/" .. name, files, prefix .. name .. "/")
        elseif type == "file" then
            table.insert(files, prefix .. name)
        end
    end
end

local function create_and_open_file(filename)
    -- Ensure the notes directory exists
    local notes_base_path = vim.fn.expand(notes_dir)
    if vim.fn.isdirectory(notes_base_path) == 0 then
        vim.fn.mkdir(notes_base_path, "p")
    end

    -- Construct the full path for the file, accommodating subdirectories if specified
    local file_path = notes_base_path .. '/' .. filename

    -- Extract the directory part from the file path to check if it needs to be created
    local file_dir = vim.fn.fnamemodify(file_path, ":h")
    if vim.fn.isdirectory(file_dir) == 0 then
        vim.fn.mkdir(file_dir, "p")
    end

    -- Check if the file already exists to avoid overwriting
    if vim.fn.filereadable(file_path) == 1 then
        print("File already exists: " .. file_path)
        return
    end

    -- Create the file (it's empty initially)
    vim.fn.writefile({}, file_path)

    -- Open the file in a new split
    vim.cmd("split " .. file_path)
    vim.cmd("edit " .. file_path)
end

function M.create_note()
    if not notes_dir then
        print("Notes directory not set. Please set the directory first.")
        return
    end

    -- Prompt for the file name
    local filename = vim.fn.input('Note name: ')
    if filename == "" then
        print("Note creation cancelled.")
        return
    end

    create_and_open_file(filename)
end

function M.show_notes()
    if not notes_dir then
        print("Notes directory not set. Please set the directory first.")
        return
    end

    local path = vim.fn.fnamemodify(notes_dir, ":p")
    local files = {}
    list_files_recursive(path, "", files)

    if #files == 0 then
        print("No notes found in " .. path)
        return
    end

    -- Show selector using ui.select
    -- vim.ui.select(files, {
    --     prompt = 'Select a note:',
    --     kind = 'note',
    -- }, function(choice)
    --     if choice then
    --         local file_path = path .. choice
    --         vim.cmd("split " .. file_path)
    --         vim.cmd("edit " .. file_path)
    --     end
    -- end)

    -- Show selector using a floating window
    local num_files = #files
    local buf = vim.api.nvim_create_buf(false, true)
    local width = 80
    local height = math.max(10, math.min(num_files, 20))
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = math.ceil((vim.o.columns - width) / 2),
        row = math.ceil((vim.o.lines - height) / 2),
        border = 'rounded',
    })

    -- Set lines in the buffer to the filenames
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, files)

    -- Status window for showing the number of files
    local status_buf = vim.api.nvim_create_buf(false, true)
    local status_text = "(" ..num_files ..") file(s)"
    local text_width = string.len(status_text)
    local padding = width - text_width
    local padded_status_text = string.rep(" ", padding) .. status_text
    vim.api.nvim_buf_set_lines(status_buf, 0, -1, false, {padded_status_text})

    local status_win = vim.api.nvim_open_win(status_buf, false, { -- false means the window is not enter-able
        relative = 'editor',
        width = width,
        height = 1, -- Only one line is needed for the status
        col = math.ceil((vim.o.columns - width) / 2),
        row = math.ceil((vim.o.lines + height + 4) / 2), -- Position just below the main window
        border = 'rounded',
        style = 'minimal',
    })

    local function close_windows()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_win_is_valid(status_win) then
            vim.api.nvim_win_close(status_win, true)
        end
    end

    -- Key mappings for navigation and selection
    local function on_select()
        local line = vim.api.nvim_win_get_cursor(win)[1]
        local choice = files[line]
        if choice then
            local file_path = path .. choice
            vim.api.nvim_win_close(win, true)
            vim.cmd("split " .. file_path)
            vim.cmd("edit " .. file_path)
        end
    end

    -- Key mappings for navigation and selection
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
        noremap = true, 
        silent = true, 
        callback = function()
            local line = vim.api.nvim_win_get_cursor(win)[1]
            local choice = files[line]
            if choice then
                local file_path = path .. choice
                vim.api.nvim_win_close(win, true)
                vim.cmd("split " .. file_path)
                vim.cmd("edit " .. file_path)
            end
        end
    })

    -- Key mappings for the main window
    vim.api.nvim_buf_set_keymap(buf, 'n', '<ESC>', '', {
        noremap = true, 
        silent = true, 
        callback = close_windows
    })

    -- Autocommand to close the status window when the main window is closed
    vim.api.nvim_create_autocmd("WinClosed", {
        buffer = buf,
        callback = function(args)
            if args.win == main_win and vim.api.nvim_win_is_valid(status_win) then
                vim.api.nvim_win_close(status_win, true)
            end
        end,
    })
    -- Make buffer read-only
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

function M.set_notes_dir(dir)
    notes_dir = dir
end

return M

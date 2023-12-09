local output = ""
local volume = {}
local function create_win()
    -- We save handle to window from which we open the navigation
    start_win = vim.api.nvim_get_current_win()

    vim.api.nvim_command('botright vnew') -- We open a new vertical window at the far right
    win = vim.api.nvim_get_current_win() -- We save our navigation window handle...
    buf = vim.api.nvim_get_current_buf() -- ...and it's buffer handle.

    -- We should name our buffer. All buffers in vim must have unique names.
    -- The easiest solution will be adding buffer handle to it
    -- because it is already unique and it's just a number.
    vim.api.nvim_buf_set_name(buf, 'Audio Selector #' .. buf)

    -- Now we set some options for our buffer.
    -- nofile prevent mark buffer as modified so we never get warnings about not saved changes.
    -- Also some plugins treat nofile buffers different.
    -- For example coc.nvim don't triggers aoutcompletation for these.
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    -- We do not need swapfile for this buffer.
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    -- And we would rather prefer that this buffer will be destroyed when hide.
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    -- It's not necessary but it is good practice to set custom filetype.
    -- This allows users to create their own autocommand or colorschemes on filetype.
    -- and prevent collisions with other plugins.
    vim.api.nvim_buf_set_option(buf, 'filetype', 'nvim-oldfile')

    -- For better UX we will turn off line wrap and turn on current line highlight.
    vim.api.nvim_win_set_option(win, 'wrap', false)
    vim.api.nvim_win_set_option(win, 'cursorline', true)

    -- set_mappings() -- At end we will set mappings for our navigation.
end
local function redraw()
    -- First we allow introduce new changes to buffer. We will block that at end.
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)

end

vim.api.nvim_create_user_command('SetVolume', function(opts)
    local volumePercent= opts.args
    local command="pactl -- set-sink-volume 0 " .. volumePercent .. "%"
    local unmute="pactl set-sink-mute @DEFAULT_SINK@ false"
    vim.fn.jobstart(unmute,{
    on_stdout = function()end,
    })
    vim.fn.jobstart(command,{
    on_stdout = function()
        vim.notify("Volume Set")
        -- volume = vim.json.decode(output)
        -- vim.notify(vim.json.decode(output))
    end,
    })
end, {nargs=1})

vim.api.nvim_create_user_command('Mute', function()
    local mute="pactl set-sink-mute @DEFAULT_SINK@ true"
    vim.fn.jobstart(mute,{
    on_stdout = function()
        vim.notify("Muted Audio")
    end,
    })
end, {})
vim.api.nvim_create_user_command('UnMute', function()
    local mute="pactl set-sink-mute @DEFAULT_SINK@ false"
    vim.fn.jobstart(mute,{
    on_stdout = function()
        vim.notify("Unmuted Audio")
    end,
    })
end, {})
vim.api.nvim_create_user_command('SoundOutput', function()
    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_set_current_win(win)
    else
        create_win()
    end

    redraw()
end, {})
vim.fn.jobstart("pactl -f json info", {
    on_stdout = function(j, d, e)
        for k, v in pairs(d) do
            output = output .. v
        end
        vim.notify(output)
        -- volume = vim.json.decode(output)
        -- vim.notify(vim.json.decode(output))
    end,
})

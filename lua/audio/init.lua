local output = ""
local volume={}
vim.fn.jobstart("pactl -f json info", {
  on_stdout = function(j, d, e)
      for k,v in pairs(d) do
          output=output .. v
       end
       volume=vim.json.decode(output)
       vim.notify(volume["server_string"])
  end,
})

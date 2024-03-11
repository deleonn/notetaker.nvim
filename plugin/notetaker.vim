if exists("g:loaded_notetakerplugin")
    finish
endif
let g:loaded_notetakerplugin = 1

" Defines a package path for Lua. This facilitates importing the
" Lua modules from the plugin's dependency directory.
exe "lua package.path = package.path .. ';" . "/lua-?/init.lua'"

" Exposes the plugin's functions for use as commands in Neovim.
command! -nargs=0 NoteTakerCreate lua require("notetaker").create_note()
command! -nargs=0 NoteTakerShow lua require("notetaker").show_notes()

if empty(maparg('<Leader>ntc', 'n'))
  nnoremap <Leader>ntc :NoteTakerCreate<CR>
endif

if empty(maparg('<Leader>nts', 'n'))
  nnoremap <Leader>nts :NoteTakerShow<CR>
endif

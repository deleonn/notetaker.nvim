local actions = require("notetaker.actions")

local M = {}

M.create_note = actions.create_note
M.show_notes = actions.show_notes
M.set_notes_dir = actions.set_notes_dir

return M

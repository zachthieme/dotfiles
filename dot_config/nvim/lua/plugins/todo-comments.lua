return {
	"folke/todo-comments.nvim",
	opts = {
		highlight = {
			-- This will highlight TODO or TODO: — colon is optional
			pattern = [[.*<(KEYWORDS)[:]?\s*]],
		},
		search = {
			-- This will match TODO or TODO: in search and Trouble
			pattern = [[\b(KEYWORDS):?]],
		},
		keywords = {
			TODO = {
				alt = { "TODO", "TODAY", "DELEGATED" },
			},
		},
	},
	config = function(_, opts)
		require("todo-comments").setup(opts)

		local function parse_iso_date(text)
			local date = text:match("(%d%d%d%d%-%d%d%-%d%d)")
			if date then
				local year = tonumber(date:sub(1, 4))
				local month = tonumber(date:sub(6, 7))
				local day = tonumber(date:sub(9, 10))
				if year and month and day then
					return os.time({ year = year, month = month, day = day, hour = 0, min = 0, sec = 0 })
				end
			end
			return nil
		end

		local function is_due_or_today(comment)
			local now = os.date("*t")
			local today = os.time({ year = now.year, month = now.month, day = now.day, hour = 0, min = 0, sec = 0 })
			local due = parse_iso_date(comment.text or "")
			return not due or due <= today
		end

		local function filtered_todos()
			local todo_comments = require("todo-comments")
			local trouble = require("trouble")

			todo_comments.search(function(results)
				local filtered = vim.tbl_filter(function(item)
					local tag = item.tag or ""
					local match = tag == "TODO" or tag == "TODAY" or tag == "DELEGATED"
					return match and is_due_or_today(item)
				end, results)

				table.sort(filtered, function(a, b)
					if a.tag == "TODAY" and b.tag ~= "TODAY" then
						return true
					end
					if b.tag == "TODAY" and a.tag ~= "TODAY" then
						return false
					end
					return (a.lnum or 0) < (b.lnum or 0)
				end)

				trouble.open({ mode = "todo", results = filtered })
			end)
		end

		vim.api.nvim_create_user_command("TodoFiltered", filtered_todos, {})
		vim.keymap.set("n", "<leader>xt", filtered_todos, { desc = "Filtered TODOs" })
	end,
}

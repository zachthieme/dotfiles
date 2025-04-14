require("which-key").register({
	f = {
		name = "+file",
		f = { "<cmd>Telescope find_files<cr>", "Find File" },
		r = { "<cmd>Telescope oldfiles<cr>", "Recent Files" },
		e = { "<cmd>Oil<cr>", "File Explorer" },
	},
	n = {
		name = "+notes",
		t = { "<cmd>ObsidianToday<cr>", "Today’s Note" },
		y = { "<cmd>ObsidianYesterday<cr>", "Yesterday’s Note" },
		n = { "<cmd>ObsidianNew<cr>", "New Note" },
		f = { "<cmd>ObsidianSearch<cr>", "Find in Vault" },
		b = { "<cmd>ObsidianBacklinks<cr>", "Backlinks" },
		l = { "<cmd>ObsidianFollowLink<cr>", "Follow Link" },
	},
	t = {
		name = "+theme",
		c = { "<cmd>Telescope colorscheme<cr>", "Choose Colorscheme" },
	},
}, { prefix = "<leader>" })

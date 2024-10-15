local M = {}

local cached_credentials = nil

local function get_db_cli_binary()
	local uname = vim.loop.os_uname().sysname
	if uname == "Linux" then
		return "/Users/renan-dev/Desktop/estudos/cli/db-cli-nvim/bin/db-cli-linux"
	elseif uname == "Darwin" then
		return "/Users/renan-dev/Desktop/estudos/cli/db-cli-nvim/bin/db-cli-mac"
	elseif uname == "Windows_NT" then
		return "/Users/renan-dev/Desktop/estudos/cli/db-cli-nvim/bin/db-cli.exe"
	else
		return nil
	end
end

local function get_db_credentials()
	if cached_credentials then
		return cached_credentials
	end

	local user = vim.env.DB_USER or vim.fn.input("DB User: ", "")
	local password = vim.env.DB_PASSWORD or vim.fn.inputsecret("DB Password: ")
	local dbname = vim.env.DB_NAME or vim.fn.input("DB Name: ", "")
	local host = vim.env.DB_HOST or "localhost"
	local sslmode = vim.env.DB_SSLMODE or "disable"

	if user == "" or password == "" or dbname == "" then
		vim.api.nvim_err_writeln("Error: User, password, and database name are required.")
		return nil
	end

	cached_credentials =
		string.format("user=%s dbname=%s password=%s host=%s sslmode=%s", user, dbname, password, host, sslmode)
	return cached_credentials
end

local function show_popup(output)
	local width = math.ceil(vim.o.columns * 0.7)
	local height = math.ceil(vim.o.lines * 0.5)
	local row = math.ceil((vim.o.lines - height) / 2)
	local col = math.ceil((vim.o.columns - width) / 2)

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, "\n"))

	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "single",
	})
end

M.run_query = function(query)
	local db_cli = get_db_cli_binary()
	if not db_cli then
		vim.api.nvim_err_writeln("Unsupported OS")
		return
	end

	local conn_str = get_db_credentials()
	if not conn_str then
		return
	end

	local cmd = string.format('%s "%s" %s', db_cli, conn_str, query)

	vim.api.nvim_out_write("Connecting to the database...\n")

	local output = vim.fn.system({ "sh", "-c", cmd })

	if vim.v.shell_error ~= 0 then
		vim.api.nvim_err_writeln("Error executing the query: " .. output)
	else
		vim.api.nvim_out_write("Query executed successfully.\n")
		show_popup(output)
	end
end

vim.api.nvim_create_user_command("DBQuery", function(opts)
	M.run_query(opts.args)
end, { nargs = 1 })

return M

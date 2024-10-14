local M = {}

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
	local user = vim.env.DB_USER or vim.fn.input("DB User: ", "")
	local password = vim.env.DB_PASSWORD or vim.fn.inputsecret("DB Password: ")
	local dbname = vim.env.DB_NAME or vim.fn.input("DB Name: ", "")
	local host = vim.env.DB_HOST or "localhost"
	local sslmode = vim.env.DB_SSLMODE or "disable"

	return string.format("user=%s dbname=%s password=%s host=%s sslmode=%s", user, dbname, password, host, sslmode)
end

M.run_query = function(query)
	local db_cli = get_db_cli_binary()
	if not db_cli then
		vim.api.nvim_err_writeln("Unsupported OS")
		return
	end

	local conn_str = get_db_credentials()

	local cmd = string.format('%s "%s" %s', db_cli, conn_str, query)

	vim.api.nvim_out_write("Comando gerado: " .. cmd .. "\n")

	local output = vim.fn.system({ "sh", "-c", cmd })

	vim.api.nvim_echo({ { output } }, false, {})
end

vim.api.nvim_create_user_command("DBQuery", function(opts)
	M.run_query(opts.args)
end, { nargs = 1 })

return M

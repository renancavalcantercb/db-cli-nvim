
# DB CLI Neovim Plugin

**db-cli-nvim** is a Neovim plugin that allows you to execute SQL queries directly from your Neovim editor, specifically for PostgreSQL databases. It also provides a CLI tool that you can use outside Neovim for the same functionality.

## Features

- Execute PostgreSQL queries directly from Neovim.
- Supports dynamic input for database credentials.
- Can be used as a standalone CLI tool.
- Outputs query results in an easy-to-read format within Neovim or the terminal.

## Requirements

- **Go** (Golang) installed for building the CLI tool.
- PostgreSQL database credentials (user, password, host, and database name).
- Neovim 0.5+ (for the plugin).

## Installation

### Via LazyVim or Neovim Plugin Manager

1. Clone or download the repository to your local machine.

2. Add the following configuration to your **`lazy.lua`** or **`init.lua`** file to load the plugin in Neovim:

   ```lua
   {
     dir = "/path/to/db-cli-nvim", -- Replace with the correct path
     config = function()
       vim.api.nvim_create_user_command(
         'DBQuery',
         function(opts)
           require('dbcli').run_query(opts.args)
         end,
         { nargs = 1 }
       )
     end,
   }
   ```

### Build the CLI Binary

1. Navigate to the project directory:

   ```bash
   cd /path/to/db-cli-nvim
   ```

2. Build the CLI binary:

   ```bash
   go build -o bin/db-cli-mac cmd/main.go  # Replace with your OS binary (Linux/Windows/Mac)
   ```

   Ensure the binary is correctly placed in the **`bin/`** directory of the project.

## Usage in Neovim

Once installed, you can use the **`:DBQuery`** command to run SQL queries directly from Neovim.

### Example

1. Open Neovim:

   ```bash
   nvim
   ```

2. Execute the following command in Neovim to run a SQL query:

   ```vim
   :DBQuery "SELECT * FROM table;"
   ```

   This will execute the query and display the results directly in Neovim.

### Setting Database Credentials

You can provide your PostgreSQL database credentials either through environment variables or interactively.

#### Using Environment Variables

Set the following environment variables before launching Neovim:

```bash
export DB_USER="your_user"
export DB_PASSWORD="your_password"
export DB_NAME="your_db"
export DB_HOST="localhost"
export DB_SSLMODE="disable"  # Or "require" if SSL is used
```

The plugin will automatically use these credentials.

#### Interactive Input

If the environment variables are not set, the plugin will prompt you to enter the database credentials interactively.

## Usage via CLI

You can also use the CLI directly in the terminal to execute SQL queries:

### Example

```bash
./bin/db-cli-mac "user=my_user password=my_password dbname=my_db host=localhost sslmode=disable" "SELECT * FROM players;"
```

This will output the query result:

```plaintext
1 | Player1 | 10 | 1500
2 | Player2 | 20 | 3000
3 | Player3 | 5 | 800
4 | Player4 | 15 | 2200
```

### Parameters

- **Connection string**: PostgreSQL connection string containing user, password, host, and database name.
- **SQL query**: The SQL query you want to execute.

# PGConnect

PGConnect is a Bash script designed to facilitate PostgreSQL database
connections and interactions.
It offers various functionalities to execute queries,
watch queries periodically, or execute SQL script files.

---

PGConnect script was inspired by the need for a simple yet powerful tool to
manage PostgreSQL database connections and operations.

With PGConnect, you can easily interact with your PostgreSQL databases without
the need for complex database management tools or interfaces.

And with less boilerplate code, you can focus on your queries and scripts,
making your database interactions more efficient and productive.

If you often use `psql` or `pgcli`, you'll find PGConnect to be a valuable addition
to your database toolkit by reducing the manual steps required to connect and execute
queries, or the hassle of searching for the right connection parameters from your
terminal history each time you need to interact with your database.

## Features

- **Environment File Support**:
  Utilize a `.env` file to store and manage environment variables.
  The same one you probably already have in your project anyway,
  `PGConnect` reads from it. Or you can also specify a different path.

- **Flexible Configuration**:
  Easily configure database connection parameters such as username,
  password, host, port, and database name.

- **Query Execution**:
  Execute individual SQL queries against your database with ease with
  the `--query` (or `-q`) option.
  It's quick: Connect, execute, and quit. In one call.

- **Query Watching**:
  Monitor query results periodically using the `watch` command.
  The `--watch` (or `-w`) option allows you to watch the query output
  at a specified interval. Useful for tracking changes or monitoring.
  Just specify the query and watch.

- **Script Execution**:
  Need to run that DDL file real quick? With `PGConnect` it's easey to
  execute SQL script files directly from the command line.
  Just specify the path to the script file using the `--script` (or `-s`) option
  followed by the path to the script file and let `PGConnect` do the rest.

## Installation, Setup, and Usage

To use PGConnect, clone the repository or download the script file directly.

It's strongly recommended to place the script in the same directory as your
project or in a directory that is included in your system's PATH.

```bash
git clone https://github.com/paulo-granthon/pgconnect
```

If you include it in your PATH, you can use it from any directory without
specifying the full path to the script.

```bash
export PATH=$PATH:/path/to/pgconnect
```

By creating an alias, you can also use a shorter command to run the script. Example:

```bash
alias pgc="/path/to/pgconnect/pgconnect.sh"
```

This will allow you to run the script using the `pgc` command. Example:

```bash
pgc -e .env -q "SELECT * FROM table_name"
```

Or by including the script in the root directory of the project in which you
want to use it, you can run it directly from the project directory. Example:

```bash
./pgconnect.sh -e .env -q "SELECT * FROM table_name"
```

## Commands, Advanced Usage, and Examples

To use PGConnect, simply run the script with appropriate options and arguments.
Below are some common usage examples:

1. **Connect to Database**:

    This will read the default environment file `.env` in the current directory
    and use the default environment variable names to attempt a connection to the
    database.

    ```bash
    ./pgconnect.sh
    ```

    The default environment variable names are:

    | Variable Name | Description |
    | ------------- | ----------- |
    | username      | DB_USER     |
    | password      | DB_PASS     |
    | hostname      | DB_HOST     |
    | port          | DB_PORT     |
    | database name | DB_NAME     |

2. **Specify Connection Parameters**:

    If you want to specify the names of the environment variables directly,
    you can use the following options. This will change what environment variables
    the script looks for on the environment file.

    ```bash
    ./pgconnect.sh --user <username> --pass <password> --host <hostname> --name <database_name> --port <port_number>
    ```

    or

    ```bash
    ./pgconnect.sh -u <username> -p <password> -h <hostname> -n <database_name> -o <port_number>
    ```

3. **Specify Environment File**:

    ```bash
    ./pgconnect.sh --env <path_to_env_file>
    ```

4. **Execute Query**:

    ```bash
    ./pgconnect.sh --query "SELECT * FROM table_name"
    ```

5. **Watch Query**:

    ```bash
    ./pgconnect.sh --watch "SELECT * FROM table_name"
    ```

6. **Execute SQL Script File**:

    ```bash
    ./pgconnect.sh --script <path_to_script_file>
    ```

## Requirements

- **Bash Shell**: The script is written in Bash and requires a compatible shell environment.
- [`psql`](https://www.postgresql.org/docs/current/app-psql.html): PostgreSQL
interactive terminal.
- [`pgcli`](https://www.pgcli.com/): PostgreSQL command-line interface.

## Configuration

You can configure the script behavior by modifying the default variable values at
the beginning of the script or by passing arguments directly via the command line.

### Default Variables

The script includes the following default variables to read from the environment
file or environment variables. the values on the left are the names of the variables
that the script will look for in the environment file.

```bash
DEFAULT_VAR_NAME_DB_USER="DB_USER"
DEFAULT_VAR_NAME_DB_PASS="DB_PASS"
DEFAULT_VAR_NAME_DB_HOST="DB_HOST"
DEFAULT_VAR_NAME_DB_NAME="DB_NAME"
DEFAULT_VAR_NAME_DB_PORT="DB_PORT"
DEFAULT_ENV_FILE=".env"
```

### Environment File

With the default variable names, you can store your database connection details
in a `.env` file using the following format:

```bash
DB_USER=username
DB_PASS=password
DB_HOST=hostname
DB_NAME=database_name
DB_PORT=port_number
```

## Caveats

- **Environment Variables**: Depends on the presence of environment variables or
file. Ensure the environment variables are set correctly and accessible.
make sure to overwrite the default variable names if you use different ones.

- **Security**: Exercise caution when handling sensitive information such as
database credentials. Sensitive data may be exposed if not handled securely.

- **Compatibility**: The script is designed to work with Bash shell environments.
Ensure compatibility with your shell environment.

## License

This script is released under the [MIT License](LICENSE).

---

Feel free to modify and enhance the script according to your specific requirements.
If you encounter any issues or have suggestions for improvement, please don't hesitate
to open an issue or submit a pull request

# Shellspace

This is a utility software to manage workspaces in your shell.

## Installation

Clone the repo using
```sh
git clone https://github.com/AvyChanna/shellspace
```
Add the following lines to your rc file (like .bashrc or .zshrc)

```sh
# Change it with your installation directory, (where you cloned it)
export SHELLSPACE_DIR="${HOME}/.shellspace"

# This will load shellspace as well as shell_completions
[ -s "${SHELLSPACE_DIR}/shellspace.sh" ] && \. "$SHELLSPACE_DIR/shellspace.sh"

# This will activate wokspace on shell restart
declare -F shellspace &>/dev/null && shellspace init
```

## Why?

- Most of the time, I have to compile programs from source, and add them to my PATH. But isolating different versions, local/global installs is always a headache. I have to periodcally modify my .zshrc to source different stuff.
- While working on a project, I always have to cd project-folder everytime I open a shell and that annoys me.
- Constantly editing and sourcing your .rc file is a pain in the ass.
- Just wanted to learn shell scripting.

## Usage

```sh
shellspace [help|-h|--help]     - Display help
shellspace current              - Get active workspace
shellspace deactivate           - Deactivate workspace
shellspace init                 - Configure new shell
shellspace info                 - Show general info
shellspace list                 - List all workspaces
shellspace add <workspace>      - Add new workspace
shellspace activate <workspace> - Activate workspace
shellspace edit <workspace>     - Edit workspace config
shellspace remove <workspace>   - Remove workspace
```

A workspace is a shell script which containes all the required shell commands you would've otherwise added to your .rc file

Use `shellspace add my_ws` to add a new workspace named `my_ws`. An editor will pop up. Default editor is selected by EDITOR shell variable(or will default to vi. Save the file. 

After you have successfully made a workspace file, use `shellspace activate my_ws` to activate it. Its workspace file will be sourced every time you open a shell.

Once you are done, use `shellspace deactivate`. This will not clear your exports you set in workspace file. So, it is recommended you restart your shell.

## Contributing

Have a complaint/suggestion/bugfix/PR ?
Did this help you in any way ?

I am open to suggestions and feedback. Open an issue over at [ISSUES](https://github.com/AvyChanna/shellspace/issues) to get in touch


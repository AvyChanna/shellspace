shellspace(){
	# shellspace is a workspace manager for shell.
	# Workspace is a shell script (like .bashrc or .cshrc)
	# Whenever you open a shell, shellspacec will execute this workspace script
	# So, instead of perpetually editing your .rc file, you can make a workspace
	# for your program and switch between them easily.

	# This function is fully self-contained. I did not want to expose unnecessary 
	# functions to the user.(Though functions would've reduced code repitition)
	# I'm no expert in this matter, so correct me if I do something BAD

	# ============ Config ============
	local shellspace_version='0.1.0'
	# shellspace_dir = Directory in which contains all workspaces and configs
	local shellspace_dir="${SHELLSPACE_DIR-${HOME}/.shellspace}"
	# shellspace_active_config = File in which active workspace name is stored
	local shellspace_active_config="${shellspace_dir}/current"
	# shellspace_workspace_dir = Directory in which all workspaces are stored
	local shellspace_workspace_dir="${shellspace_dir}/workspaces"
	mkdir -p "${shellspace_workspace_dir}"
	touch "${shellspace_active_config}"
	# ========== End Config ==========

	# Check arguments
	if [ ${#} -lt 1 ]; then
		shellspace help
		return
	fi

	# This may not be required. Just keeping it here for now.
	# # Set Exit on failure. If something fails, bail out !!
	# if [ "${-#*e}" != "$-" ]; then
	# 	set +e
	# 	shellspace "$@"
	# 	return $?
	# fi
	
	# Command to run (add, remove, activate etc)
	local COMMAND=''
	COMMAND="${1}"
	shift

	# Check for additional args
	# Currently only help is implemented (for ease of use)
	# This may change in future revision
	for args in "$@"; do
		case $args in
		'-h'|'--help')
			shellspace help
			return $?
		;;
		esac
	done

	case $COMMAND in
	'help')
		# Print help info
		echo ''
		echo "ShellSpace v${shellspace_version}"
		echo ''
		echo 'Workspace manager for your shell'
		echo ''
		echo 'Usage:'
		echo '  shellspace [help|-h|--help]     - Display this help'
		echo ''
		echo '  shellspace current              - Get active workspace'
		echo '  shellspace deactivate           - Deactivate workspace[1]'
		echo '  shellspace init                 - Configure new shell'
		echo '  shellspace info                 - Show general info'
		echo '  shellspace list                 - List all workspaces'
		echo ''
		echo '  shellspace add <workspace>      - Add new workspace'
		echo '  shellspace activate <workspace> - Activate workspace'
		echo '  shellspace edit <workspace>     - Edit workspace config'
		echo '  shellspace remove <workspace>   - Remove workspace'
		echo ''
		echo 'Note:' 
		echo '  [0] Workspace names can contain only alphanumeric(a-zA-Z0-9),'
		echo '        or underscore(_) characters.'
		echo '  [1] You must restart your shell to clear all your set variables.'
	;;
	'current')
		# Prints name of currently active workspace
		# Or prints error to stderr and returns with code 1
		local active_workspace=''
		active_workspace=$(<"${shellspace_active_config}")

		# If config was empty, return
		if [ ${#active_workspace} -eq 0 ]; then
			echo 'No workspace activated' >&2
			echo 'To activate workspace, use "shellspace activate <workspace>"' >&2
			return 1
		fi
		echo "${active_workspace}"
	;;
	'deactivate')
		# Deactivates currently active workspace
		# Or prints error
		local active_workspace=''
		active_workspace=$(<"${shellspace_active_config}")

		# If config is empty, return
		if [ ${#active_workspace} -eq 0 ]; then
			echo "No workspace was activated, nothing to deactivate" >&2
			return 1
		fi

		echo "Deactivating workspace '${active_workspace}'"
		echo '' > "${shellspace_active_config}"
		return 0
	;;
	'init')
		# Sources the workspace script.
		# This is intended to be directly added to .rc
		local active_workspace=''
		active_workspace=$(<"${shellspace_active_config}")
		
		# If config is non-empty, source file
		if [ ${#active_workspace} -ne 0 ]; then
			"." "${shellspace_workspace_dir}/${active_workspace}.sh"
			return $?
		fi
		# It may be possible that no workspace is active.
		# This is vaild case and will not return error.
		return 0
	;;
	'info')
		# Print info about workspace, and shellspace itself
		local active_workspace=''
		active_workspace=$(<"${shellspace_active_config}")
		if [ ${#active_workspace} -eq 0 ]; then
			echo "Current workspace   = none"
			echo "Workspace File      = none"
		else
			echo "Current workspace   = ${active_workspace}"
			echo "Workspace File      = ${shellspace_workspace_dir}/${active_workspace}.sh"
		fi
		echo ''
		echo "Workspace directory = ${shellspace_workspace_dir}"
		echo "Active config file  = ${shellspace_active_config}"
	;;
	'list')
		# List all workspaces
		local lst=''

		# Get list of all workspaces and sanitize their names
		lst=$(find "${shellspace_workspace_dir}" -maxdepth 1 -type f -name "*.sh" \
				-exec basename -a -s '.sh' {} + | sort)

		# Empty list :(
		if [ ${#lst} -eq 0 ]; then
			echo "No workspace found" >&2
			echo 'To add workspace, use "shellspace add <workspace>"' >&2
			return 1
		fi
		# Print list
		for i in ${lst}; do
			echo "${i}"
		done
		return 0
	;;
	'add')
		if [ ${#} -ne 1 ]; then
			echo "ADD needs 1 argument, ${#} given." >&2
			echo 'Use "shellspace add <workspace-name>" instead' >&2
			return 1
		fi
		local workspace_name=''
		workspace_name=${1}

		# Sanitize workspace name
		if [[ ${workspace_name} = *[^[:alnum:]_]* ]]; then
			echo 'Use alnum(a-zA-Z0-9) or underscore(_) only for workspace names' >&2
			return 1
		fi
		# If workspace already exists, return
		if [ -f "${shellspace_workspace_dir}/${workspace_name}.sh" ]; then
			echo "Workspace '${workspace_name}' already exists" >&2
			echo "To edit the workspace, use \"shellspace edit ${workspace_name}\"" >&2
			return 1
		fi

		echo "Adding workspace '${workspace_name}'"
		# To open another editor,
		# set "editor='<your-editor-here>'" in your .rc BEFORE shellspace
		"${EDITOR:-vi}" "${shellspace_workspace_dir}/${workspace_name}.sh"
		return $?
	;;
	'activate')
		# Activates workspace
		if [ ${#} -ne 1 ]; then
			echo "ACTIVATE needs 1 argument, ${#} given." >&2
			echo 'Use "shellspace activate <workspace>" instead' >&2
			echo 'To list existing workspaces, use "shellspace list"' >&2
			echo 'To add workspace, use "shellspace add <workspace-name>"' >&2
			return 1
		fi
		local workspace_name=''
		workspace_name=${1}
		# Sanitize workspace name
		if [[ ${workspace_name} = *[^[:alnum:]_]* ]]; then
			echo 'Use alnum(a-zA-Z0-9) or underscore(_) only for workspace names' >&2
			return 1
		fi
		# Check if that workspace exists
		if [ -f "${shellspace_workspace_dir}/${workspace_name}.sh" ]; then
			# This will overwrite config file with new workspace name
			echo "${workspace_name}" > "${shellspace_active_config}"
			shellspace init
			return $?
		fi
		echo "No workspace with name='${workspace_name}'" >&2
		echo "To add new workspace, use \"shellspace add ${workspace_name}\"" >&2
		echo 'To list existing workspaces, use "shellspace list"' >&2
		return 1
	;;
	'edit')
		# Edit workspace
		if [ ${#} -ne 1 ]; then
			echo "EDIT needs 1 argument, ${#} given." >&2
			echo 'Use "shellspace edit <workspace-name>" instead' >&2
			return 1
		fi
		
		local workspace_name=''
		workspace_name=${1}
		if [[ ${workspace_name} = *[^[:alnum:]_]* ]]; then
			echo 'Use alnum(a-zA-Z0-9) or underscore(_) only for workspace names' >&2
			return 1
		fi
		# Launch editor to edit workspace
		if [ -f "${shellspace_workspace_dir}/${workspace_name}.sh" ]; then
			echo "Editing workspace '${workspace_name}'"
			"${EDITOR:-vi}" "${shellspace_workspace_dir}/${workspace_name}.sh"
			return $?
		fi
		echo "No workspace with name='${workspace_name}'" >&2
		echo 'To list existing workspaces, use "shellspace list"' >&2
		echo "To add new workspace, use \"shellspace add ${workspace_name}\"" >&2
		return 1
	;;
	'remove')
		# Remove workspace
		# TODO check for current active workspace
		if [ ${#} -ne 1 ]; then
			echo "REMOVE needs 1 argument, ${#} given." >&2
			echo 'Use "shellspace remove <workspace-name>" instead' >&2
			return 1
		fi
		local workspace_name=''
		workspace_name=${1}
		if [[ ${workspace_name} = *[^[:alnum:]_]* ]]; then
			echo 'Use alnum(a-zA-Z0-9) or underscore(_) only for workspace names' >&2
			return 1
		fi
		# Check that to-be-removed workspace is not active
		local active_workspace=''
		active_workspace=$(<"${shellspace_active_config}")
		if [ ${#active_workspace} -ne 0 ] && [ "${active_workspace}" = "${workspace_name}" ]; then
			echo "Workspace '${active_workspace}' is currently active." >&2
			echo "Deactivate it first using 'shellspace deactivate'" >&2
			return 1
		fi

		# Remove workspace
		if [ -f "${shellspace_workspace_dir}/${workspace_name}.sh" ]; then
			echo "Removing workspace '${workspace_name}'"
			rm "${shellspace_workspace_dir}/${workspace_name}.sh"
			return $?
		fi
		echo "No workspace '${workspace_name}' found" >&2
		echo 'For a list of existing workspaces, use "shellspace list"' >&2
		return 1
	;;
	*)
		# Any other command means "show help"
		shellspace help
	esac
}

__shellspace_completion(){
	# This provides shell completion with TAB character
	local cur="${COMP_WORDS[COMP_CWORD]}"
	local prev="${COMP_WORDS[COMP_CWORD-1]}"

	case "${prev}" in
	'activate' | 'edit' | 'remove')
		# Typed these, wants a suggestion for workspace name
		local lst=''
		lst=$(shellspace list 2>/dev/null)
		COMPREPLY=( $(compgen -W "${lst}" -- "${cur}") )
		return 0
	;;
	'current' | 'deactivate' | 'init' | 'info' | 'list' | 'add')
		# Typed these, does not want any completion
		# Add is in this category because it does not need completion
		COMPREPLY=( $(compgen -W "--help -h" -- "${cur}") )
		return 0
	;;
	'-h' | '--help' | 'help')
		# Once user inputs help, we are going to skip all other args anyway
		COMPREPLY=()
		return 0
	;;
	*)
	# None of the above.
	# This means user typed --* or did not type anything at all (or a wrong keyword)

		# -* completion
		if [[ ${cur} == -* ]] ; then
			COMPREPLY=( $(compgen -W "--help -h" -- "${cur}") )
			return 0
		fi

		# No/Wrong input completion
		local opts
		opts="help current deactivate init info list add activate edit remove"
		COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
		return 0
	;;
  esac

  return 0
}
# zsh specific stuff
if [[ -n ${ZSH_VERSION-} ]]; then
  autoload -U +X bashcompinit && bashcompinit
  autoload -U +X compinit && if [[ ${ZSH_DISABLE_COMPFIX-} = true ]]; then
	compinit -u
  else
	compinit
  fi
fi
complete -F __shellspace_completion shellspace
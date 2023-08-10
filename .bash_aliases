# Global Define : ENV
# ================================================================= #
CD_REMEMBER_PATH=${HOME}/.cd.history
CD_MAX_REMEMBER_LINE=100

# Global Define : Color
# ================================================================= #
cBLK='\e[30m'
cRED='\e[31m'
cSKY='\e[36m'
bWHT='\e[47m'
cRST='\e[00m'

# Global Define : Prefix
# ================================================================= #
ESC=`printf "\033"`;

# Functions
# ================================================================= #
function shorten_path() {
	local path=$(pwd)
	echo ${path//${HOME}/\~}
}

function input_key() {
    read -s -n3 INPUT;
    echo $INPUT;
}

function check_selected() {
    if [ $1 = $2 ];
    then echo -e ${bWHT}${cBLK}
    else echo -e ${cRST}
    fi
}

function select_menu() {
    local SELECTED=1;
    local INPUT="";
    local MIN_MENU=1;
    local MAX_MENU=$#;

    echo -e "-----------------------------------------------------------------------------------------------"
    echo -e " Choose the path you want to move among the directories"
    echo -e "-----------------------------------------------------------------------------------------------"
    while true; do
        for (( i=1; i<=$#; i++)); do
            printf "$ESC[2K$(check_selected $i $SELECTED) $i. ${!i}${cRST}\n";
        done
    echo -e "-----------------------------------------------------------------------------------------------"
        printf "$ESC[2K * Use Arrow key to select and input '${cSKY}Enter${cRST}' to select, Cancel '${cRED}Ctrl+C${cRST}'\n";
    echo -e "-----------------------------------------------------------------------------------------------"
        INPUT=$(input_key);
        if [[ $INPUT = "" ]]; then
            break;
        fi

        if   [[ $INPUT = "$ESC[A" ]]; then SELECTED=$(expr $SELECTED - 1);
        elif [[ $INPUT = "$ESC[B" ]]; then SELECTED=$(expr $SELECTED + 1);
        fi

        if   [[ $SELECTED -lt $MIN_MENU ]]; then SELECTED=${MIN_MENU};
        elif [[ $SELECTED -gt $MAX_MENU ]]; then SELECTED=${MAX_MENU};
        fi

        printf "$ESC[$(expr $# + 3)A";
    done

    return `expr ${SELECTED} - 1`;
}

# return 0 : delete success OR delete no need to delete
# return 1 : need delete but head line is "[HERE]" OR file not exist
function check_remember_max() {
	if [ ! -e "${CD_REMEMBER_PATH}" ]; then
		return 1
	fi

	local line=$(wc -l < "${CD_REMEMBER_PATH}")
	if [ "${line}" -gt ${CD_MAX_REMEMBER_LINE} ]; then

		local first_line=$(head -n 1 "${CD_REMEMBER_PATH}")
		if [ "${first_line}" = "[HERE]" ]; then
			return 1
		else
			sed -i '1d' "${CD_REMEMBER_PATH}"
		fi
	fi

	return 0
}

# if exist dirs below [HERE], echo that line
function pop_below_dir() {
	local line_number=1
	while IFS= read -r line; do
		if [[ "${line}" == *"[HERE]"* ]]; then
			local next_line=$(sed -n "$((line_number + 1))p" "${CD_REMEMBER_PATH}")
			if [ -n "${next_line}" ]; then
				echo "${next_line}"
				sed -i -e "$((line_number + 1))d" "${CD_REMEMBER_PATH}"
			else
				echo ""
			fi
			break;
		fi
		((line_number++))
	done < "${CD_REMEMBER_PATH}"
}

# if exist dirs above [HERE], echo that line
function pop_above_dir() {
	local line_number=1
	local prev_line=""
	while IFS= read -r line; do
		if [[ "${line}" == *"[HERE]"* ]]; then
			if [ "${line_number}" -gt 1 ]; then
				echo "${prev_line}"
				sed -i "$((line_number - 1))d" "${CD_REMEMBER_PATH}"
			else
				echo ""
			fi
			break
		fi
		prev_line="${line}"
		((line_number++))
	done < "${CD_REMEMBER_PATH}"
}

function remember_pwd_above() {
	if [ ! -e "${CD_REMEMBER_PATH}" ]; then
		echo '[HERE]' >> ${CD_REMEMBER_PATH}
	fi

	check_remember_max

	if [ $? -gt 0 ]; then
		return 1
	fi

	local dir=$1
	local isHere="false"

	while IFS= read -r line; do
		if [[ "${line}" == *"[HERE]"* ]]; then
			sed -i "/\[HERE\]/i ${dir}" "${CD_REMEMBER_PATH}"
			isHere="true"
			break
		fi
	done < "${CD_REMEMBER_PATH}"

	if [ "${isHere}" == "false" ]; then
		echo "[HERE]" >> ${CD_REMEMBER_PATH}
		sed -i "/\[HERE\]/i ${dir}" "${CD_REMEMBER_PATH}"
	fi
}

function remember_pwd_below() {
	if [ ! -e "${CD_REMEMBER_PATH}" ]; then
		echo '[HERE]' >> ${CD_REMEMBER_PATH}
	fi

	check_remember_max

	if [ $? -gt 0 ]; then
		return 1
	fi

	local dir=$1
	local isHere="false"

	while IFS= read -r line; do
		if [[ "${line}" == *"[HERE]"* ]]; then
			sed -i "/\[HERE\]/a ${dir}" "${CD_REMEMBER_PATH}"
			isHere="true"
			break
		fi
	done < "${CD_REMEMBER_PATH}"

	if [ "${isHere}" == "false" ]; then
		echo "[HERE]" >> ${CD_REMEMBER_PATH}
		sed -i "/\[HERE\]/a ${dir}" "${CD_REMEMBER_PATH}"
	fi
}

function remember_n_cd() {
	remember_pwd_above $(pwd)
	builtin cd "$@"
}

function cd_mv_prev() {
	if [ ! -e "${CD_REMEMBER_PATH}" ]; then
		return 1
	fi

	echo -ne "{ $(shorten_path) ->"

	local target=`pop_above_dir`
	if [ x"${target}" == "x" ]; then
		echo -e " (NONE) } "
		return 1
	fi

	local cur=$(pwd)
	cd "${target}"
	local del=`pop_above_dir`
	remember_pwd_below "${cur}"

	echo -e " $(shorten_path) } "
}

function cd_mv_next() {
	if [ ! -e "${CD_REMEMBER_PATH}" ]; then
		return 1
	fi

	echo -ne "{ $(shorten_path) ->"

	local target=`pop_below_dir`
	if [ x"${target}" == "x" ]; then
		echo -e " (NONE) } "
		return 1
	fi

	local cur=$(pwd)
	cd "${target}"
	local del=`pop_above_dir`
	remember_pwd_above "${cur}"

	echo -e " $(shorten_path) } "
}

function cd_list_clear() {
	echo "[HERE]" > ${CD_REMEMBER_PATH}
	echo -e "[Set] cd history clear."
}

function cd_select_history() {
	local num_lines=15

	local lines=$(tail -n $num_lines "$CD_REMEMBER_PATH")

	IFS=$'\n' read -d '' -r -a lines_array <<< "$(echo "$lines" | grep -v '\[HERE\]' | sort -u)"

	select_menu "${lines_array[@]}"
	local selected_dir=$(echo ${lines_array[$?]})

	cd ${selected_dir}
}

# ================================================================= #
#                          Global Aliases                           #
# ================================================================= #

alias sc='f() {
			source ~/.bashrc;
			echo -e "source ~/.bashrc Complete "; }; f'

alias cd='remember_n_cd'

alias cdc='cd_list_clear'
alias cdl='cd_select_history'

alias prev='cd_mv_prev'
alias p='cd_mv_prev'
alias next='cd_mv_next'
alias n='cd_mv_next'
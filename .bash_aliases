# "internal" functions
_printRed() {
	echo -e "\e[1;31m$1\e[0m"
}

_printGreen() {
	echo -e "\e[1;32m$1\e[0m"
}

_printYellow() {
	echo -e "\e[1;33m$1\e[0m"
}

_printBlue() {
	echo -e "\e[1;34m$1\e[0m"
}

_printNested() {
	echo -e "\t$1"
}

# simplifying docker command
function runtests() {
	local file_path=""
	local container_name='container_name'
	local container_path="application/tests"
	local local_path="$HOME/Projects/$container_path"

	echo "Provide part of test path/filename: $( _printYellow 'it should be enough to differentiate this from other files')"
	read file

	echo "Which type of test do you want to run? $( _printYellow 'integration, nonintegration or unit' )$( _printGreen '(default)' )"
	read test_type

	# $test_type is null
	if [ -z $test_type ]; then
		local test_type='unit'
	fi

	# $file is not null
	if [ ! -z $file ]; then
		_printYellow "\nSearching INTO:"
		_printNested $local_path
		_printYellow "Filename:"
		_printNested "$file\n"

		local result=$(find "$local_path/$test_type" -type f -iwholename "*$file*")
		local count_files=$(echo "$result" | wc -l)

		# if the result lines of files is greater than 1
	    if [ "$count_files" -gt 1 ]; then
	        echo -e "Found file(s):\n $result"
	        _printYellow "Please provide a more specific filename."

	        return 1
	    fi

	    # if the result lines of files is = 1
	    if [ "$count_files" == 1 ]; then
	    	# if there is no result (when result of lines is empty it counts 1)
	    	if [ -z "$result" ]; then
		        _printRed "File not found."

		        return 1
		    fi

		    _printGreen "Found:"
		    _printNested "$result \n"

		    # str_replace using shell script result = search, local_path = old_value, container_path = new_value 
			local file_path="${result//$local_path/$container_path}"

	        _printGreen 'Executing:'
	        _printNested "docker exec $container_name phpunit --bootstrap $container_path/bootstrap.php --configuration $container_path/$( _printGreen $test_type )/phpunit.xml $file_path \n"
	    fi
	fi

	docker exec $container_name phpunit --bootstrap "$container_path/bootstrap.php" --configuration "$container_path/$test_type/phpunit.xml" "$file_path"
}

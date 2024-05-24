# importing helpers
. ~/.bash_helpers

# simplifying docker command to run tests into a Zend 1 project
function runtests() {
	local file_path=""
	local container_name='container_name'
	local container_path="application/tests"
	local project_path="$HOME/Projects/$container_path"

	echo "Provide part of test path/filename: $( _printYellow 'it should be enough to differentiate this from other files') - $( _printGreen '## ENTER to run all tests ##' )" 
	read file

	echo "These folders were found INTO $project_path:"
	_printRed 'select one that stores some tests to run'

	# creating an array with the result of find
	local options=($(find $project_path -mindepth 1 -maxdepth 1 -type d -printf '%f '))
	local test_type=$( _menu "${options[@]}" )

	_line

	# $file is not null
	if [ ! -z $file ]; then
		_printYellow "Searching INTO:"
		_printNested "$project_path/$( _printGreen $test_type )/"
		_printYellow "Filename:"
		_printNested "$file"

		local result=$(find "$project_path/$test_type" -type f -iwholename "*$file*" | sed 's/^/\t/')
		local count_files=$(echo "$result" | wc -l)

		# if the result lines of files is greater than 1
	    if [ "$count_files" -gt 1 ]; then
	        _printYellow "Found file(s):"
	        echo -e "$result"
	        _printRed "\nPlease, provide a more specific filename."

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
		    echo -e "$result"
		    _line

		    # str_replace using shell script result = search, project_path = old_value, container_path = new_value 
			local file_path="${result//$project_path/$container_path}"

	        _printGreen 'Executing:'
	        _printNested "docker exec $container_name phpunit --bootstrap $container_path/bootstrap.php --configuration $container_path/$( _printGreen $test_type )/phpunit.xml $file_path \n"
	    fi
	else
		_printRed "Let's run all the $test_type tests!🤪"
		_printNested "INTO $project_path/$( _printGreen $test_type )"
	fi

	docker exec $container_name phpunit --bootstrap "$container_path/bootstrap.php" --configuration "$container_path/$test_type/phpunit.xml" "$file_path"
}

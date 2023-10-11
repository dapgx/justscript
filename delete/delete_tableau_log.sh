#!/bin/bash

# Display the usage information

display_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h : Display this help message"
    echo "  -d : Select a directory to delete files from (by number)"
    echo "  -m : Enter the month (e.g., 01 for January)"
    echo "  -y : Enter the year (e.g., 2023)"
    echo "  -s : Show the directory list"
    echo
    echo "Example usage:"
    echo "  $0 -d 1 -m 01 -y 2023"
    echo
    exit 1
}

# Display the directory options
display_directory_options() {
    echo "Select a directory to delete files from:"
    for i in "${!directories[@]}"; do
        echo "$((i+1)). ${directories[i]}"
    done
}

# Display the list of directories
list_directories() {
    echo "List of directories:"
    for i in "${!directories[@]}"; do
        echo "$((i+1)). ${directories[i]}"
    done
}

# Validate the month format
validate_month() {
    local month="$1"
    # Remove any leading zeros
    month="${month#"${month%%[!0]*}"}"
    if [[ $month =~ ^[0-9]{1,2}$ && $month -ge 1 && $month -le 12 ]]; then
        return 0
    else
        return 1
    fi
}

# Validate the year format
validate_year() {
    local year="$1"
    if [[ $year =~ ^[0-9]{4}$ && $year -ge 1900 && $year -le 2100 ]]; then
        return 0
    else
        return 1
    fi
}

# Define an array of directory names
directories=(
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/activationservice/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/analyticsextensions'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/apigateway'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/appzookeeper/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/backgrounder/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/clientfileservice/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/clustercontroller/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/collections/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/contentexploration/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/dataserver/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/filestore/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/flowminerva/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/flowprocessor/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/httpd/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/hyper/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/interactive/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/metrics/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/noninteractive/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/tabadminagent/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/tdsservice/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/vizportal/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/vizqlserver/'
    '/var/opt/tableau/tableau_server/data/tabsvc/logs/webhooks/'
    
#    Delete logs all in logs directory
#    I don't recommend using this method, but this script can delete all logs for the month and year you specify.
#    You don't need to specify the directory, it will search inside the "logs" directory
#    '/var/opt/tableau/tableau_server/data/tabsvc/logs/'
)

# Check if there are no arguments
if [ $# -eq 0 ]; then
    display_directory_options
    read -p "Enter the number of the directory: " dir_number
fi

# Get the current year and month
current_year=$(date +%Y)
current_month=$(date +%m)

while getopts "hsd:m:y:" opt; do
    case $opt in
        h)
            display_usage
            ;;
        s)
            list_directories
            exit 0
            ;;
        d)
            dir_number="$OPTARG"
            ;;
        m)
            month="$OPTARG"
            if ! validate_month "$month"; then
                echo "Invalid month format. Please enter a valid month (e.g., 01 for January)." >&2
                display_usage
            fi
            ;;
        y)
            year="$OPTARG"
            if ! validate_year "$year"; then
                echo "Invalid year format. Please enter a valid year (e.g., 2023)." >&2
                display_usage
            fi
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            display_usage
            ;;
    esac
done

# Ensure the chosen directory number is valid
if [ -n "$dir_number" ] && ((dir_number >= 1 && dir_number <= ${#directories[@]})); then
    directory="${directories[dir_number-1]}"

    # Ask the user for the month and year if not provided as options
    if [ -z "$month" ]; then
        read -p "Enter the month (e.g., 01 for January): " month
        if ! validate_month "$month"; then
            echo "Invalid month format. Please enter a valid month (e.g., 01 for January)." >&2
            exit 1
        fi
    fi
    if [ -z "$year" ]; then
        read -p "Enter the year (e.g., 2023): " year
        if ! validate_year "$year"; then
            echo "Invalid year format. Please enter a valid year (e.g., 2023)." >&2
            exit 1
        fi
    fi

    # Check if the specified directory exists
    if [ -d "$directory" ]; then
        # Check if the selected year and month match the current year and month
        if [ "$year" -eq "$current_year" ] && [ "$month" -eq "$current_month" ]; then
            echo "Cannot delete files for the current year and month."
            exit 1
        fi

        # Define the pattern based on the user's input
        pattern="${year}-${month}-.*|${year}_${month}_.*"

        # Delete files matching the pattern in a directory
        delete_files_with_pattern() {
            local directory="$1"
            local pattern="$2"
        
            find "$directory" -type f | grep -E "$pattern" | while read -r file; do
                rm -f "$file"
                echo "Deleted: $file"
            done
        }

        delete_files_with_pattern "$directory" "$pattern"
        echo "Cleanup complete."
    else
        echo "Directory not found: $directory"
    fi
else
    echo "Invalid directory number."
    display_usage
fi

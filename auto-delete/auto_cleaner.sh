#!/bin/bash

log_directories=(
  "/home/ubuntu/environment/testing/a"
  "/home/ubuntu/environment/testing/b"
  "/home/ubuntu/environment/testing/c"
)

archive_directories=(
  "/home/ubuntu/environment/testing/z/a"
  "/home/ubuntu/environment/testing/z/b"
  "/home/ubuntu/environment/testing/z/c"
)

log_file="/home/ubuntu/environment/testing/log_cleaner.sh.log"

log_message() {
    local message=$1
    echo "$(date): $message" >> "$log_file"
}

clean_logs() {
    local src_dir=$1
    local dest_dir=$2
    local pattern=$3

    for file in "$src_dir"/*"$pattern"*; do
        if [ -f "$file" ]; then
            base_file=$(basename "$file")

            log_message "Compressing: $file"

            gzip -c "$file" > "$dest_dir/compressed_$base_file.gz"

            log_message "Deleting: $file"

            rm -f "$file"

            log_message "Moved to: $dest_dir/compressed_$base_file.gz"
        fi
    done
}

pattern1=$(date -d '2 days ago' +%Y-%m-%d)
pattern2=$(date -d '2 days ago' +%Y_%m_%d)

for ((i=0; i<${#log_directories[@]}; i++)); do
    clean_logs "${log_directories[i]}" "${archive_directories[i]}" "$pattern1"
    clean_logs "${log_directories[i]}" "${archive_directories[i]}" "$pattern2"
done

log_message "Log cleaning script executed on $(date)"

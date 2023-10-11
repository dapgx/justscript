# What is this script?

So, what is this script? I was tired of manually deleting Tableau logs one by one, so I created this script to automate the process. With this script, all I have to do is run it and specify the directory, month, and year. What sets this script apart is its accidental log deletion protection. It won't delete logs from the current month and year. For example, if I run this script in October 2023, it won't touch any logs created in October 2023. I can safely delete those logs in November 2023 or later.

# Other method

I need to specify the directory if i want to delete logs, which in my case tableau have 23 logs directory. The script can delete all logs instantly, just modify the directories to ```/var/opt/tableau/tableau_server/data/tabsvc/logs/``` and it will delete all logs (example, 2023-09- and 2023_09_) instantly and i don't need to specify which directory. But i think this will be very rare case.

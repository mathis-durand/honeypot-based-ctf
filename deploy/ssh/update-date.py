import os
import random
import time
import datetime

def random_date(start_date, end_date):
    """Generates a random datetime between two datetime objects."""
    time_between_dates = end_date - start_date
    days_between_dates = time_between_dates.days
    random_number_of_days = random.randrange(days_between_dates)
    random_date = start_date + datetime.timedelta(days=random_number_of_days)
    return random_date

def touch_random_date(root_dir="/home"):
    """Recursively touches all files and folders under root_dir with a random date
    between three weeks ago and today.
    """

    today = datetime.datetime.now()
    three_weeks_ago = today - datetime.timedelta(weeks=3)

    for dirpath, dirnames, filenames in os.walk(root_dir, topdown=False): # Use topdown=False for folders
        # Touch files
        for filename in filenames:
            filepath = os.path.join(dirpath, filename)

            # Generate a random datetime
            # The original code used random.randint(10,1814400) which is roughly 3 weeks
            # We'll stick to the same random range for consistency
            random_dt = today - datetime.timedelta(seconds=random.randint(10,1814400))
            timestamp = time.mktime(random_dt.timetuple())  # Convert to timestamp

            try:
                os.utime(filepath, (timestamp, timestamp))  # Change both access and modification times
                print(f"Touched file: {filepath} with date {random_dt.strftime('%Y-%m-%d %H:%M:%S')}")
            except OSError as e:
                print(f"Error touching file {filepath}: {e}")

        # Touch folders
        # dirnames contains the list of subdirectories in the current dirpath.
        # We only need to touch the current dirpath, which is `dirpath` itself.
        # When topdown=False, os.walk visits subdirectories first,
        # so when we are processing dirpath, its children have already been touched.
        if dirpath != root_dir: # Avoid touching the root_dir itself again if it's the starting point
            random_dt_folder = today - datetime.timedelta(seconds=random.randint(10,1814400))
            timestamp_folder = time.mktime(random_dt_folder.timetuple())
            try:
                os.utime(dirpath, (timestamp_folder, timestamp_folder))
                print(f"Touched folder: {dirpath} with date {random_dt_folder.strftime('%Y-%m-%d %H:%M:%S')}")
            except OSError as e:
                print(f"Error touching folder {dirpath}: {e}")


if __name__ == "__main__":
    root_directory = "/home"  # The directory to start the recursive touch
    touch_random_date(root_directory)
    print("Done.")

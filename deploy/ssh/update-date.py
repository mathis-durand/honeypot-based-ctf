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
    """Recursively touches all files under root_dir with a random date
    between three weeks ago and today.
    """

    today = datetime.datetime.now()
    three_weeks_ago = today - datetime.timedelta(weeks=3)

    for dirpath, dirnames, filenames in os.walk(root_dir):
        for filename in filenames:
            filepath = os.path.join(dirpath, filename)

            # Generate a random datetime
            random_dt = random_date(three_weeks_ago, today)
            timestamp = time.mktime(random_dt.timetuple())  # Convert to timestamp

            try:
                os.utime(filepath, (timestamp, timestamp))  # Change both access and modification times
                print(f"Touched: {filepath} with date {random_dt.strftime('%Y-%m-%d %H:%M:%S')}")
            except OSError as e:
                print(f"Error touching {filepath}: {e}")


if __name__ == "__main__":
    root_directory = "/home"  # The directory to start the recursive touch
    touch_random_date(root_directory)
    print("Done.")

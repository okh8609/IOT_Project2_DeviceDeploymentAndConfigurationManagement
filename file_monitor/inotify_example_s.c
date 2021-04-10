#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/inotify.h>
#include <unistd.h>

#define EVENT_SIZE (sizeof(struct inotify_event))
#define EVENT_BUF_LEN (1024 * (EVENT_SIZE + 16))

int main()
{
    int length, i = 0;
    int ino_fd;
    int ino_wd;
    char buffer[EVENT_BUF_LEN];

    /*creating the INOTIFY instance*/
    ino_fd = inotify_init();

    /*checking for error*/
    if (ino_fd < 0)
        perror("inotify_init");

    /*adding the “/tmp” directory into watch list. Here, the suggestion is to validate the existence of the directory before adding into monitoring list.*/
    ino_wd = inotify_add_watch(ino_fd, "/tmp", IN_CREATE | IN_DELETE | IN_MODIFY);

    /*read to determine the event change happens on “/tmp” directory. Actually this read blocks until the change event occurs*/
    length = read(ino_fd, buffer, EVENT_BUF_LEN);

    /*checking for error*/
    if (length < 0)
        perror("read");

    /*actually read return the list of change events happens. Here, read the change event one by one and process it accordingly.*/
    while (i < length)
    {
        struct inotify_event* event = (struct inotify_event*) & buffer[i];
        if (event->len)
        {
            if (event->mask & IN_CREATE)
            {
                if (event->mask & IN_ISDIR)
                {
                    printf("New directory %s created.\n", event->name);
                }
                else
                {
                    printf("New file %s created.\n", event->name);
                }
            }
            else if (event->mask & IN_DELETE)
            {
                if (event->mask & IN_ISDIR)
                {
                    printf("Directory %s deleted.\n", event->name);
                }
                else
                {
                    printf("File %s deleted.\n", event->name);
                }
            }
            else if (event->mask & IN_MODIFY)
            {
                if (event->mask & IN_ISDIR)
                {
                    printf("Directory %s modified.\n", event->name);
                }
                else
                {
                    printf("File %s modified.\n", event->name);
                }
            }
        }
        i += EVENT_SIZE + event->len;
    }

    /*removing the “/tmp” directory from the watch list.*/
    inotify_rm_watch(ino_fd, ino_wd);

    /*closing the INOTIFY instance*/
    close(ino_fd);
}
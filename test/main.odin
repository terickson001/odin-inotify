package main

import ".."
import "core:os"
import "core:fmt"

main :: proc()
{
    fd := inotify.init();
    wd := inotify.add_watch(fd, "/home/tyler/Odin/inotify/test", inotify.IN_CREATE);
    
    { events := inotify.read_events(fd);
        for event in events
        {
            fmt.printf("%s\n", event.name);
        }
    }
}

package inotify

import "core:os"
import "core:c"
import bind "./bindings"

Event :: struct
{
    wd:     os.Handle, /* Watch Descriptor */
    mask:   u32,   /* Mask of events */
    cookie: u32,   /* Unique cookie associating related events */
    length: u32,   /* length of `name` */
    name:   ^c.char, /* Optional name */
}

init  :: proc() -> os.Handle { return bind.init() };
init1 :: proc(flags: int) -> os.Handle { return bind.init1(c.int(flags)) };

add_watch :: proc(fd: os.Handle, pathname: string, mask: uint) -> os.Handle
{
    
}

rm_watch :: proc(fd, wd: os.Handle) -> int
{
    
}
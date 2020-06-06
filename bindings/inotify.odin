package bindings

import "core:c"
import "core:os"
foreign import libc "system:c"

Event :: struct
{
    wd: os.Handle,
    mask: u32,
    cookie: u32,
    length: u32,
    name: #no_bounds_check [0]c.char,
}

@(link_prefix="inotify_")
foreign libc
{
    init  :: proc() -> os.Handle ---;
    init1 :: proc(flags: c.int) -> os.Handle ---;
    
    add_watch :: proc(fd: os.Handle, pathname: ^c.char, mask: u32) -> os.Handle ---;
    rm_watch  :: proc(fd: os.Handle, wd: os.Handle) -> c.int ---;
}

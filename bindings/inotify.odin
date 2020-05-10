package bindings

import "core:c"
import "core:os"
foreign import "system:c"

@(link_prefix="inotify_")
foreign inotify
{
    init  :: proc() -> os.Handle ---;
    init1 :: proc(flags: c.int) -> os.Handle ---;
    
    add_watch :: proc(fd: os.Handle, pathname: ^c.char, mask: u32) -> os.Handle ---;
    rm_watch  :: proc(fd: os.Handle, wd: os.Handle) -> c.int;
}
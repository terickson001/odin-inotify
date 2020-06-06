package bindings

import "core:c"
import "core:os"
foreign import libc "system:c"

IN_ACCESS :: 0x001;
IN_MODIFY :: 0x002;
IN_ATTRIB :: 0x004;
IN_CLOSE_WRITE :: 0x008;
IN_CLOSE_NOWRITE :: 0x010;
IN_OPEN :: 0x020;
IN_MOVED_FROM :: 0x040;
IN_MOVED_TO :: 0x080;
IN_CREATE :: 0x100;
IN_DELETE :: 0x200;
IN_DELETE_SELF :: 0x400;
IN_MOVE_SELF :: 0x800;

Event :: struct
{
     wd: os.Handle,
     mask: u32,
     cookie: u32,
     length: u32,
     name: [0]c.char,
}

@(link_prefix="inotify_")
foreign libc
{
     init  :: proc() -> os.Handle ---;
     init1 :: proc(flags: c.int) -> os.Handle ---;
     
     add_watch :: proc(fd: os.Handle, pathname: ^c.char, mask: u32) -> os.Handle ---;
     rm_watch  :: proc(fd: os.Handle, wd: os.Handle) -> c.int ---;
}

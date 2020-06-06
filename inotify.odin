package inotify

import "core:os"
import "core:c"
import "core:strings"
import "core:mem"
import bind "./bindings"

Event :: struct
{
    wd:     os.Handle, /* Watch Descriptor */
    mask:   u32,   /* Mask of events */
    cookie: u32,   /* Unique cookie associating related events */
    name:   string,  /* Optional name */
}

Watch_Descriptor :: distinct os.Handle;
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

init  :: proc() -> os.Handle { return bind.init() }
init1 :: proc(flags: int) -> os.Handle { return bind.init1(c.int(flags)) }

add_watch :: proc(fd: os.Handle, pathname: string, mask: uint) -> Watch_Descriptor
{
    c_pathname := strings.clone_to_cstring(pathname, context.temp_allocator);
    defer delete(c_pathname);
    return Watch_Descriptor(bind.add_watch(fd, (^byte)(c_pathname), u32(mask)));
}

rm_watch :: proc(fd: os.Handle, wd: Watch_Descriptor) -> int
{
    return int(bind.rm_watch(fd, os.Handle(wd)));
}

@(deferred_out=free_events)
read_events :: proc(fd: os.Handle, count := 16, allocator := context.allocator) -> [dynamic]Event
{
    bytes := make([]byte, count * (size_of(bind.Event)+256));
    out := make([dynamic]Event);
    length, ok := os.read(fd, bytes[:]);
    if ok != 0 do return out;
    i := 0;
    
    for i < length
    {
        bevent := (^bind.Event)(&bytes[i]);
        event := Event{};
        event.wd = bevent.wd;
        event.mask = bevent.mask;
        event.cookie = bevent.cookie;
        
        length := 0;
        for length < int(bevent.length) && bevent.name[length] != 0 do
            length += 1;
        event.name = strings.clone(strings.string_from_ptr(&bevent.name[0], length));
    }
    return out;
}

free_events :: proc(buffer: [dynamic]Event)
{
    for event in buffer do
        delete(event.name);
    delete(buffer);
}
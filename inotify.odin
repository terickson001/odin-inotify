package inotify

import "core:os"
import "core:c"
import "core:strings"
import "core:mem"
import "core:fmt"
import bind "./bindings"

Event :: struct
{
     wd:     os.Handle, /* Watch Descriptor */
     mask:   u32,   /* Mask of events */
     cookie: u32,   /* Unique cookie associating related events */
     name:   string,  /* Optional name */
}

Watch_Descriptor :: distinct os.Handle;

Event_Kind :: enum u16
{
     Access = bind.IN_ACCESS,
     Modify = bind.IN_MODIFY,
     Attrib = bind.IN_ATTRIB,
     Close_Write = bind.IN_CLOSE_WRITE,
     Close_NoWrite = bind.IN_CLOSE_NOWRITE,
     Open = bind.IN_OPEN,
     Moved_From = bind.IN_MOVED_FROM,
     Moved_To = bind.IN_MOVED_TO,
     Create = bind.IN_CREATE,
     Delete = bind.IN_DELETE,
     Delete_Self = bind.IN_DELETE_SELF,
     Move_Self = bind.IN_MOVE_SELF,
}

init  :: proc() -> os.Handle { return bind.init() }
init1 :: proc(flags: int) -> os.Handle { return bind.init1(c.int(flags)) }

add_watch :: proc(fd: os.Handle, pathname: string, mask: Event_Kind) -> Watch_Descriptor
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
     fmt.printf("READING\n");
     for i < length
         {
         bevent := (^bind.Event)(&bytes[i]);
         event := Event{};
         event.wd = bevent.wd;
         event.mask = bevent.mask;
         event.cookie = bevent.cookie;
         
         #no_bounds_check event.name = strings.clone(cast(string)mem.slice_ptr(&bevent.name[0], int(bevent.length)));
         append(&out, event);
         
         i += size_of(bind.Event)+int(bevent.length);
     }
     fmt.printf("EVENTS READ: %d\n", len(out));
     return out;
}

free_events :: proc(buffer: [dynamic]Event)
{
     for event in buffer do
         delete(event.name);
     delete(buffer);
}
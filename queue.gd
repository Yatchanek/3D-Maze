extends RefCounted
class_name Queue

var first : int = 0
var last : int = -1

var storage : Dictionary = {}


func enq(value : Variant):
    last += 1
    storage[last] = value
    

func deq() -> Variant:
    var value : Variant = storage[first]
    storage.erase(first)
    first += 1

    if first == last:
        first = 0
        last = -1
    
    return value

func size() -> int:
    return last - first + 1

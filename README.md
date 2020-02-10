# HidApi

[![Build Status](https://travis-ci.com/laborg/HidApi.jl.svg?branch=master)](https://travis-ci.com/laborg/HidApi.jl)

This is a high level, cross platform wrapper of the `hidapi` library <https://github.com/libusb/hidapi> for
Julia. It comes with _batteries included_ (no need to install additional libraries).
It can be used to communicate with HID devices on Linux, Mac and Windows. 

### Under the hood
The binary build of the `hidapi` library is provided by Julias binary build infrastructure and
can be found here: `hidapi_jll`(<https://github.com/JuliaBinaryWrappers/hidapi_jll.jl>)

# Installation
```julia
Pkg.add("HidApi.jl")
using HidApi
```

# Usage (high level API)
A high level API allows to enumerate, open, read and write

```julia
# initalize
init()

# enumerate
dump.(enumerate_devices())

# open and read data
dev = open(find_device(0x04ec, 0x2605))
data = read(dev)

# do something with data
...

# close
close(dev)

# exit
shutdown()
```

# Usage (low level API)
All low level `hidapi.h` functions are available but not exported. They typicall are prefixed
with `hid_xxx`.

```julia

# initialize
val = HidApi.hid_init()
if val < 0
    error("init failed")
end

# enumerate
devs = HidApi.hid_enumerate(0x0, 0x0)
cur_dev = devs
while cur_dev != C_NULL
    hid_device_info = unsafe_load(cur_dev)
    dump(hid_device_info)
    global cur_dev = hid_device_info.next
end

# free up devices list
HidApi.hid_free_enumeration(devs)

# open the device
handle = HidApi.hid_open(0x04ec, 0x2605, C_NULL)
if handle == C_NULL 
    error("open failed")
end

# create a vector, pass it to hid_read
data = Vector{Cuchar}(undef, 64)
val = HidApi.hid_read_timeout(handle, data, 64, 2000)
if val == -1 
    error("error while reading")
end

# do something with data
...

# close the device
HidApi.hid_close(handle)

# exit at the end
HidApi.hid_exit()
```




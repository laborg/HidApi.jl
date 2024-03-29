
"""
Represents a HID device.
"""
mutable struct HidDevice
    path::String
    vendor_id::UInt16
    product_id::UInt16
    serial_number::String
    release_number::UInt16
    manufacturer_string::String
    product_string::String
    usage_page::UInt16
    usage::UInt16
    interface_number::Int
    handle::Ptr{hid_device}
    _hid_device_info::hid_device_info
    function HidDevice(hdi::hid_device_info)
        return new(
            unsafe_string(hdi.path),
            hdi.vendor_id,
            hdi.product_id,
            _wcharstring(hdi.serial_number),
            hdi.release_number,
            _wcharstring(hdi.manufacturer_string),
            _wcharstring(hdi.product_string),
            hdi.usage_page,
            hdi.usage,
            hdi.interface_number,
            C_NULL,
            hdi,
        )
    end
end

function Base.show(io::IO, ::MIME"text/plain", hd::HidDevice)
    return print(
        io,
        """
Vendor/Product ID : $(repr(hd.vendor_id)) / $(repr(hd.product_id))
             Path : $(hd.path)
          Product : $(hd.product_string)
    Serial number : $(hd.serial_number)
     Manufacturer : $(hd.manufacturer_string)""",
    )
    return nothing
end

_hid_error() = _wcharstring(hid_error(C_NULL))
_hid_error(hd) = _wcharstring(hid_error(hd.handle))

"""
    init()

Initialize the hidapi library.
"""
function init()
    val = hid_init()
    val != 0 && error("init failed: $(_hid_error())")
    return nothing
end

"""
    shutdown()

Finalize the hidapi library.
"""
function shutdown()
    val = hid_exit()
    val != 0 && error("exit failed")
    return nothing
end

"""
    enumerate_devices()

Enumerate all connected hid devices.
"""
function enumerate_devices()
    hdis = hid_device_info[]

    devs = hid_enumerate(0x0, 0x0)
    cur_dev = devs
    while cur_dev != C_NULL
        hid_device_info = unsafe_load(cur_dev)
        push!(hdis, hid_device_info)
        cur_dev = hid_device_info.next
    end

    res = HidDevice.(hdis)
    hid_free_enumeration(devs)

    return res
end

"""
    find_device(vendor_id, product_id, serial_number = nothing)

Find the device with the first matching `vendor_id` and `product_id`. If serial_number is
provided it will be used for matching as well.
"""
function find_device(vid::Integer, pid::Integer, serial_number=nothing)
    vid = convert(UInt16, vid)
    pid = convert(UInt16, pid)
    for hd in enumerate_devices()
        match = hd.vendor_id == vid && hd.product_id == pid
        if serial_number === nothing
            if match
                return hd
            end
        else
            if match && hd.serial_number == serial_number
                return hd
            end
        end
    end
    return nothing
end

"""
    find_devices(vendor_id, product_id)

Find all devices with matching `vendor_id` and `product_id`.
"""
function find_devices(vid::Integer, pid::Integer)
    vid = convert(UInt16, vid)
    pid = convert(UInt16, pid)
    return filter(enumerate_devices()) do hd
        hd.vendor_id === vid && hd.product_id === pid
    end
end

"""
    open(hid_device)

Open the `hid_device` for subsequent reading/writing.
"""
function Base.open(hd::HidDevice)
    hd.handle != C_NULL && error("device has already been opened")
    hd.handle = hid_open_path(hd.path)
    hd.handle == C_NULL &&
        error("couldn't open the device $(hd.handle) (err: $(_hid_error()))")
    return hd
end

"""
    close(hid_device)

Close the `hid_device`. Needs to be called before `shutdown()`.
"""
function Base.close(hd::HidDevice)
    hd.handle == C_NULL && error("device isn't open")
    hid_close(hd.handle)
    hd.handle = C_NULL
    return hd
end

"""
    read(hid_device, size = 64, timeout = 2000)

Read a hid message from `hid_device` with `size` within `timeout` milliseconds.
Usually 64 bytes.
"""
function Base.read(hd::HidDevice, size=64, timeout=2000)
    size > 64 && error("can't read more than 64 bytes")
    hd.handle == C_NULL && error("device is closed")
    data = Vector{Cuchar}(undef, size)
    val = if timeout == 0
        hid_read(hd.handle, data, size)
    else
        hid_read_timeout(hd.handle, data, size, timeout)
    end
    if timeout == val == 0
        warn("hid_read_timeout() timed out")
    end
    if val == -1
        error("hid_read() failed: $(hid_error(hd.handle))")
    end
    return data
end

"""
    write(hid_device, data::Vector{UInt8})

Write `data` as a hid message to `hid_device`. Usually 64 bytes.
"""
function Base.write(hd::HidDevice, data::Vector{UInt8})
    length(data) > 64 && error("can't write more than 64 bytes")
    hd.handle == C_NULL && error("device is closed")
    written = hid_write(hd.handle, data, length(data))
    if written == -1
        error("hid_write() failed: $(hid_error(hd.handle))")
    end
    return nothing
end

manufacturer_string(hd::HidDevice) = _read_hid_string(hd, hid_get_manufacturer_string)
product_string(hd::HidDevice) = _read_hid_string(hd, hid_get_product_string)
serial_number_string(hd::HidDevice) = _read_hid_string(hd, hid_get_serial_number_string)
lib_version() = unsafe_string(hid_version_str())

function _read_hid_string(hd::HidDevice, f::Base.Callable; maxlength=256)
    hd.handle == C_NULL && error("device is closed")
    str = Vector{Cwchar_t}(undef, maxlength)
    val = f(hd.handle, str, maxlength)
    val != 0 && error("couldn't read string")
    return transcode(String, str)[1:(findfirst(==(0), str) - 1)]
end

function _wcharstring(p::Ptr{Cwchar_t})
    p == C_NULL && return ""
    arr = Cwchar_t[]
    len = 1
    while (c = unsafe_load(p, len)) != 0
        len += 1
        push!(arr, c)
    end
    return transcode(String, arr)
end

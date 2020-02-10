
mutable struct HidDevice
    path::String
    vendor_id::UInt16
    product_id::UInt16
    serial_number::String
    release_number::UInt16
    manufacturer_string::String
    product_string::String
    interface_number::Int
    handle::Ptr{hid_device}
    _hid_device_info::hid_device_info
    function HidDevice(hdi::hid_device_info)
        new(unsafe_string(hdi.path),
            hdi.vendor_id,
            hdi.product_id,
            _wcharstring(hdi.serial_number),
            hdi.release_number,
            _wcharstring(hdi.manufacturer_string),
            _wcharstring(hdi.product_string),
            hdi.interface_number,
            C_NULL,
            hdi)
    end
end

function Base.show(io::IO, ::MIME"text/plain", hd::HidDevice)
    println(io, "Vendor/Product ID: $(repr(hd.vendor_id))/$(repr(hd.product_id)), Path: $(hd.path)")
    !isempty(hd.manufacturer_string) && print(io, "Manufacturer: $(hd.manufacturer_string) ")
    !isempty(hd.product_string) && print(io, "Product: $(hd.product_string) ")
    !isempty(hd.serial_number) && print(io, "Serial number: $(hd.serial_number) ")
end

function hidinit()
    val = hid_init()
    val != 0 && error("init failed")
    return nothing
end

function hidexit()
    val = hid_exit()
    val != 0 && error("exit failed")
    return nothing
end

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


function find_device(vid::UInt16, pid::UInt16, serial_number = nothing)
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

function Base.open(hd::HidDevice)
    hd.handle != C_NULL && error("device has already been opened")
    hd.handle = hid_open_path(hd.path)
    hd.handle == C_NULL && error("error while opening the device $(hd.handle)")
    finalizer(hd -> hid_close(hd),hd)
    return hd
end

function Base.close(hd::HidDevice)
    hd.handle == C_NULL && error("device isn't open")
    hid_close(hd.handle)
    hd.handle = C_NULL
    return hd
end

function Base.read(hd::HidDevice, size = 64, timeout = 2000)
    size > 64 && error("Can't read more than 64 bytes")
    hd.handle == C_NULL && error("device is closed")
    data = Vector{Cuchar}(undef, size)
    val = if timeout == 0
        hid_read(hd.handle, data, size)
    else
        hid_read_timeout(hd.handle, data, size, timeout)
    end
    val == -1 && error("error while reading")
    return data
end

function Base.write(hd::HidDevice, data::Vector{UInt8})
    length(data) > 64 && error("Can't write more than 64 bytes")
    hd.handle == C_NULL && error("device is closed")
    written = hid_write(hd.handle, data, length(data))
    written == -1 && error("error while writing data")
    return nothing
end

manufacturer_string(hd::HidDevice) = _read_hid_string(hd, hid_get_manufacturer_string)
product_string(hd::HidDevice) = _read_hid_string(hd, hid_get_product_string)
serial_number_string(hd::HidDevice) = _read_hid_string(hd, hid_get_serial_number_string)

function _read_hid_string(hd::HidDevice, f::Base.Callable; maxlength = 256)
    hd.handle == C_NULL && error("device is closed")
    str = Vector{Cwchar_t}(undef, maxlength)
    val = hid_get_serial_number_string(hd.handle, str, maxlength)
    val != 0 && error("couldn't read string")
    return transcode(String, str)[1:findfirst(==(0), str) - 1]
end

function _wcharstring(p::Ptr{Cwchar_t})
    p == C_NULL && return ""
    arr = Cwchar_t[]
    len = 1
    while (c = unsafe_load(p, len)) != 0
        len += 1
        push!(arr, c)
    end
    transcode(String, arr)
end
# Julia wrapper for header: hidapi.h
# Automatically generated using Clang.jl


function hid_init()
    ccall((:hid_init, hidapi), Cint, ())
end

function hid_exit()
    ccall((:hid_exit, hidapi), Cint, ())
end

function hid_enumerate(vendor_id, product_id)
    ccall((:hid_enumerate, hidapi), Ptr{hid_device_info}, (UInt16, UInt16), vendor_id, product_id)
end

function hid_free_enumeration(devs)
    ccall((:hid_free_enumeration, hidapi), Cvoid, (Ptr{hid_device_info},), devs)
end

function hid_open(vendor_id, product_id, serial_number)
    ccall((:hid_open, hidapi), Ptr{hid_device}, (UInt16, UInt16, Ptr{Cwchar_t}), vendor_id, product_id, serial_number)
end

function hid_open_path(path)
    ccall((:hid_open_path, hidapi), Ptr{hid_device}, (Cstring,), path)
end

function hid_write(dev, data, length)
    ccall((:hid_write, hidapi), Cint, (Ptr{hid_device}, Ptr{Cuchar}, Csize_t), dev, data, length)
end

function hid_read_timeout(dev, data, length, milliseconds)
    ccall((:hid_read_timeout, hidapi), Cint, (Ptr{hid_device}, Ptr{Cuchar}, Csize_t, Cint), dev, data, length, milliseconds)
end

function hid_read(dev, data, length)
    ccall((:hid_read, hidapi), Cint, (Ptr{hid_device}, Ptr{Cuchar}, Csize_t), dev, data, length)
end

function hid_set_nonblocking(dev, nonblock)
    ccall((:hid_set_nonblocking, hidapi), Cint, (Ptr{hid_device}, Cint), dev, nonblock)
end

function hid_send_feature_report(dev, data, length)
    ccall((:hid_send_feature_report, hidapi), Cint, (Ptr{hid_device}, Ptr{Cuchar}, Csize_t), dev, data, length)
end

function hid_get_feature_report(dev, data, length)
    ccall((:hid_get_feature_report, hidapi), Cint, (Ptr{hid_device}, Ptr{Cuchar}, Csize_t), dev, data, length)
end

function hid_get_input_report(dev, data, length)
    ccall((:hid_get_input_report, hidapi), Cint, (Ptr{hid_device}, Ptr{Cuchar}, Csize_t), dev, data, length)
end

function hid_close(dev)
    ccall((:hid_close, hidapi), Cvoid, (Ptr{hid_device},), dev)
end

function hid_get_manufacturer_string(dev, string, maxlen)
    ccall((:hid_get_manufacturer_string, hidapi), Cint, (Ptr{hid_device}, Ptr{Cwchar_t}, Csize_t), dev, string, maxlen)
end

function hid_get_product_string(dev, string, maxlen)
    ccall((:hid_get_product_string, hidapi), Cint, (Ptr{hid_device}, Ptr{Cwchar_t}, Csize_t), dev, string, maxlen)
end

function hid_get_serial_number_string(dev, string, maxlen)
    ccall((:hid_get_serial_number_string, hidapi), Cint, (Ptr{hid_device}, Ptr{Cwchar_t}, Csize_t), dev, string, maxlen)
end

function hid_get_indexed_string(dev, string_index, string, maxlen)
    ccall((:hid_get_indexed_string, hidapi), Cint, (Ptr{hid_device}, Cint, Ptr{Cwchar_t}, Csize_t), dev, string_index, string, maxlen)
end

function hid_error(dev)
    ccall((:hid_error, hidapi), Ptr{Cwchar_t}, (Ptr{hid_device},), dev)
end

function hid_version()
    ccall((:hid_version, hidapi), Ptr{hid_api_version}, ())
end

function hid_version_str()
    ccall((:hid_version_str, hidapi), Cstring, ())
end

struct hid_api_version
    major::Cint
    minor::Cint
    patch::Cint
end

mutable struct hid_device_ end

const hid_device = hid_device_

"""
    hid_bus_type

HID underlying bus types.

` API`
"""
@enum hid_bus_type::UInt32 begin
    HID_API_BUS_UNKNOWN = 0
    HID_API_BUS_USB = 1
    HID_API_BUS_BLUETOOTH = 2
    HID_API_BUS_I2C = 3
    HID_API_BUS_SPI = 4
end

"""
    hid_device_info

hidapi info structure
"""
struct hid_device_info
    path::Ptr{Cchar}
    vendor_id::Cushort
    product_id::Cushort
    serial_number::Ptr{Cvoid} # serial_number::Ptr{Cwchar_t}
    release_number::Cushort
    manufacturer_string::Ptr{Cvoid} # manufacturer_string::Ptr{Cwchar_t}
    product_string::Ptr{Cvoid} # product_string::Ptr{Cwchar_t}
    usage_page::Cushort
    usage::Cushort
    interface_number::Cint
    next::Ptr{hid_device_info}
    bus_type::hid_bus_type
end

function Base.getproperty(x::hid_device_info, f::Symbol)
    f === :serial_number && return Ptr{Cwchar_t}(getfield(x, f))
    f === :manufacturer_string && return Ptr{Cwchar_t}(getfield(x, f))
    f === :product_string && return Ptr{Cwchar_t}(getfield(x, f))
    return getfield(x, f)
end


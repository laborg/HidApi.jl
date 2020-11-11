# Automatically generated using Clang.jl

const HID_API_VERSION_MAJOR = 0
const HID_API_VERSION_MINOR = 10
const HID_API_VERSION_PATCH = 0

struct hid_api_version
    major::Cint
    minor::Cint
    patch::Cint
end

const hid_device_ = Cvoid
const hid_device = hid_device_

struct hid_device_info
    path::Cstring
    vendor_id::UInt16
    product_id::UInt16
    serial_number::Ptr{Cwchar_t}
    release_number::UInt16
    manufacturer_string::Ptr{Cwchar_t}
    product_string::Ptr{Cwchar_t}
    usage_page::UInt16
    usage::UInt16
    interface_number::Cint
    next::Ptr{hid_device_info}
end

# Automatically generated using Clang.jl


const hid_device = Cvoid

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

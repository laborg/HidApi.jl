module HidApi

using hidapi_jll: hidapi_jll
const hidapi = hidapi_jll.hidapi

include(joinpath(@__DIR__, "common.jl"))
include(joinpath(@__DIR__, "api.jl"))
include(joinpath(@__DIR__, "high_level_api.jl"))

export HidDevice
export init, shutdown, open, close, read, write
export find_device, find_devices, enumerate_devices

end # module

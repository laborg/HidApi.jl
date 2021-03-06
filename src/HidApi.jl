module HidApi

import hidapi_jll
const hidapi = hidapi_jll.hidapi

include(joinpath(@__DIR__, "hidapi_common.jl"))
include(joinpath(@__DIR__, "hidapi_api.jl"))
include(joinpath(@__DIR__, "high_level_api.jl"))

export HidDevice
export init, shutdown, open, close, read, write
export find_device, enumerate_devices

end # module

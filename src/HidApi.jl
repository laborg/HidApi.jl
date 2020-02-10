module HidApi

import hidapi_jll
const hidapi = hidapi_jll.hidapi

using CEnum

include(joinpath(@__DIR__, "hidapi_common.jl"))
include(joinpath(@__DIR__, "hidapi_api.jl"))
include(joinpath(@__DIR__, "high_level_api.jl"))

export init, shutdown
export open, close, find_device, enumerate_devices
export read, write

end # module

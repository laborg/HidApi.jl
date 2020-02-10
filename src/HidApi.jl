module HidApi

import hidapi_jll
const hidapi = hidapi_jll.hidapi

using CEnum

include(joinpath(@__DIR__, "hidapi_common.jl"))
include(joinpath(@__DIR__, "hidapi_api.jl"))
include(joinpath(@__DIR__, "high_level_api.jl"))

export open, find_device, enumerate_devices, close, init, exit, read, write

# export everything
# foreach(names(@__MODULE__, all=true)) do s
#    if startswith(string(s), "hid_")
#        @eval export $s
#    end
# end

end # module

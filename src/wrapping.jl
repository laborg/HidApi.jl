# this file contains the code to wrap hidapi using Clang.jl

using hidapi_jll
using Clang

mkpath(joinpath(@__DIR__,"..","gen"))

wc = Clang.init(; headers = [joinpath(hidapi_jll.artifact_dir,"include","hidapi","hidapi.h")],
            output_file = joinpath(@__DIR__,"..","gen","hidapi_api.jl"),
            common_file = joinpath(@__DIR__,"..","gen","hidapi_common.jl"),
            clang_includes = vcat(CLANG_INCLUDE),
            clang_args = map(x->"-I"*x, find_std_headers()),
            header_wrapped = (root, current)->root == current,
            header_library = x->"hidapi",
            clang_diagnostics = true,
            )

run(wc)

# certain adjustments need to be done afterwards:
# -remove ctypes.jl (not needed in this package)
# -remove the LibTemplate (we are relying on the _jll to provide the library)
# -remove "const HID_API_EXPORT_CALL = HID_API_EXPORT" from hidapi_common.jl
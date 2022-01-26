# this file contains the code to wrap hidapi using Clang.jl

##############
# with Clang.jl < 0.14
##############


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

##############
# with Clang.jl >= 0.14
##############

using Clang.Generators
using hidapi_jll

cd(@__DIR__)

include_dir = normpath(hidapi_jll.artifact_dir, "include","hidapi")
options = load_options(joinpath(@__DIR__, "generator.toml"))
args = get_default_args()
push!(args, "-I$include_dir")
headers = [joinpath(include_dir, header) for header in readdir(include_dir) if endswith(header, "hidapi.h")]
ctx = create_context(headers, args, options)
build!(ctx)

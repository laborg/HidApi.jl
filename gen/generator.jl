using Clang.Generators
using hidapi_jll

cd(@__DIR__)

include_dir = normpath(hidapi_jll.artifact_dir, "include")
hidapi_c_dir = joinpath(include_dir, "hidapi")

# wrapper generator options
options = load_options(joinpath(@__DIR__, "generator.toml"))

# add compiler flags, e.g. "-DXXXXXXXXX"
args = get_default_args()
push!(args, "-I$include_dir")

# header files
headers = [joinpath(hidapi_c_dir, header) for header in readdir(hidapi_c_dir) if endswith(header, "hidapi.h")]

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx,false)

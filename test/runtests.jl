using HidApi
using Test

@testset "HidApi.jl" begin

    # just a smoke test, as CI has not a known USB target to test
    @test init() === nothing
    @test enumerate_devices() isa Vector{HidDevice}
    @test nothing === find_device(0x0000,0x0000)
    @test shutdown() === nothing
end

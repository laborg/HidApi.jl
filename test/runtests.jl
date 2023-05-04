using HidApi
using Test

@testset "HidApi.jl" begin
    # just a smoke test, as CI has not a known USB target to test
    @test enumerate_devices() isa Vector{HidDevice}
    @test nothing === find_device(0x0000, 0x0000)
    @test find_devices(0x0000, 0x0000) isa Vector{HidDevice}
    @test shutdown() === nothing
end

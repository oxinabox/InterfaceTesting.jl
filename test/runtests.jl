using InterfaceTesting
using Base.Test

# write your own tests here
@testset "partial_method_exists" begin
    partial_method_exists(length, Array)
end

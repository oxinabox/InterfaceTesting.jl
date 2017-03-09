using InterfaceTesting
using Base.Test
using Base.Test: Fail

type NoThrowTestSet <: Base.Test.AbstractTestSet
    results::Vector
    NoThrowTestSet(desc) = new([])
end
Base.Test.record(ts::NoThrowTestSet, t::Base.Test.Result) = (push!(ts.results, t); t)
Base.Test.finish(ts::NoThrowTestSet) = ts.results<num
num_fails(results) = sum(res->isa(res, Fail), results)



immutable BrokenJuliaZeroFourIterator end
Base.start(::BrokenJuliaZeroFourIterator) = 1
Base.next(::BrokenJuliaZeroFourIterator, state) = state+1, state+1
Base.done(::BrokenJuliaZeroFourIterator, state) = state>5

immutable BrokenHasLengthIterator end
Base.start(::BrokenHasLengthIterator) = 1
Base.next(::BrokenHasLengthIterator, state) = state+1, state+1
Base.done(::BrokenHasLengthIterator, state) = state>5
Base.iteratorsize(::Type{BrokenHasLengthIterator}) = Base.HasLength #Return the Type not the instance
Base.length(::BrokenHasLengthIterator) = 5

immutable BrokenIteratorsizeIterator end
Base.start(::BrokenIteratorsizeIterator) = 1
Base.next(::BrokenIteratorsizeIterator, state) = state+1, state+1
Base.done(::BrokenIteratorsizeIterator, state) = false
Base.iteratorsize(::BrokenIteratorsizeIterator) = Base.IsInfinite()
#Set iteratorsize on the instance not the type


immutable BrokenLengthIterator end
Base.start(::BrokenLengthIterator) = 1
Base.next(::BrokenLengthIterator, state) = state+1, state+1
Base.done(::BrokenLengthIterator, state) = state>5
Base.iteratorsize(::Type{BrokenLengthIterator}) = Base.HasLength()
#Don't define the length

immutable UnknownLengthIterator end
Base.start(::UnknownLengthIterator) = 1
Base.done(::UnknownLengthIterator, state) = state>100
Base.iteratorsize(::Type{UnknownLengthIterator}) = Base.SizeUnknown()
function Base.next(::UnknownLengthIterator, state)
    ret = rand(1:10)
    ret, state+ret
end

@testset "partial_method_exists" begin
    @test partial_method_exists(length, (Array,))
    @test !partial_method_exists(length, (Function,))

    @test partial_method_exists(rpad, (String,Int))
    @test partial_method_exists(rpad, (String,Int))
    @test !partial_method_exists(rpad, (Vector{Int},))
    @test partial_method_exists(rpad, (:, Int))
end


@testset "Iterators" begin
    test_iterator_interface(Vector)
    test_iterator_interface(Vector{Int})
    test_iterator_interface(typeof(zip([1,2,3],[2,23])))
    test_iterator_interface(typeof(zip([1,2,3],[2,23],[3,2,3])))
    test_iterator_interface(Matrix)
    test_iterator_interface(Int)

    test_iterator_interface(UnknownLengthIterator)
BrokenIteratorsizeIterator_res = test_iterator_interface(BrokenIteratorsizeIterator; testset_type=NoThrowTestSet)
    @test 0<num_fails(BrokenIteratorsizeIterator_res)

    BrokenJuliaZeroFourIterator_res=test_iterator_interface(BrokenJuliaZeroFourIterator; testset_type=NoThrowTestSet)
    @test 0<num_fails(BrokenJuliaZeroFourIterator_res)

    BrokenLengthIterator_res=test_iterator_interface(BrokenLengthIterator; testset_type=NoThrowTestSet)
    @test 0<num_fails(BrokenLengthIterator_res)
end


@testset "Indexing" begin
    test_index_interface(Matrix)
    test_index_interface(SparseVector)
    test_index_interface(UnitRange{Int64}) #Logically this should *not* pass, since not setable, but that method as been coded to manually throw an error

    Dict_res = test_index_interface(Dict,  testset_type=NoThrowTestSet) #Not a proper indexable, no endof
    @test 0<num_fails(Dict_res)
end


@testset "Abstract Array" begin
    test_abstractarray_interface(Matrix)
    test_abstractarray_interface(SparseVector)
    test_abstractarray_interface(UnitRange{Int64}) #Logically this should *not* pass, since not setable, but that method as been coded to manually throw an error

    Dict_res = test_abstractarray_interface(Dict,  testset_type=NoThrowTestSet) #Not a proper indexable, no endof
    @test has_fails(Dict_res)
end

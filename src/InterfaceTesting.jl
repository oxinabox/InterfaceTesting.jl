module InterfaceTesting
using Base.Test

export partial_method_exists,
    test_iterator_interface,
    test_index_interface,
    test_abstractarray_interface

"""
Checks if a method exist.
The first parameter is the function.
The second parameter is a list of types, or wild cards.
THe `:` is used as a wildcard.
Wild cards match any type (Not just `Any`)

"""
function partial_method_exists(f, types)
    meths = methods(f)
    for mm in meths
        sig_types =  mm.sig.types[2:end]
        length(types)!=length(sig_types)  && continue

        for (spec, sig) in zip(types, sig_types)
            spec==(:) && continue
            spec <: sig || @goto next_meth
        end
        return true
        @label next_meth
    end
    return false
end

"""
Checks that all the method expected of an Interator are defined.
This is the most formal and common of informal interfaced.
It is practically useless to not implement it properly.
"""
function test_iterator_interface(itertype; testset_type=Test.DefaultTestSet)
    @testset testset_type "$(itertype)" begin
        #Basic Methods
        @test method_exists(start, (itertype,))
        @test partial_method_exists(next, (itertype,:))
        @test partial_method_exists(done, (itertype,:))

        #Iterators size
        if Base.iteratorsize(itertype)==Base.HasShape()
            @test method_exists(size, (itertype,))
            @test method_exists(length, (itertype,))
        elseif Base.iteratorsize(itertype)==Base.HasLength()
            @test method_exists(length, (itertype,))
        else
            @test Base.iteratorsize(itertype) in (Base.SizeUnknown(), Base.IsInfinite())
        end

        #Iterator Eltype
        if Base.iteratoreltype(itertype) == Base.HasEltype()
            @test method_exists(eltype, (itertype,))
        end

    end
end

"""
Checks Indexing Interface implemented.
This is the least formal of informal interfaces.
There a plenty of useful partial implementatons of it.
Eg a read-only things
"""
function test_index_interface(kind; testset_type=Test.DefaultTestSet)
    @testset testset_type "$(kind)" begin
        if method_exists(getindex, (kind, Vararg))
            @test partial_method_exists(size, (kind, :)) #otherwise `end` won't work in multidimentional index expressions
        else #Assume 1D indexing only has been defined
            @test partial_method_exists(getindex, (kind,:))
        end
        @test partial_method_exists(setindex!, (kind,:,:)) #Got to have something. 1D will do. Might have more, kinda complex
        @test method_exists(endof, (kind,)) #If not defined then `end` won't work

    end
end


"""
Checks AbstractArray Interface implemented.
This is required for all subtypes of AbstractArray.
Filling this will mean automatically furfilling `test_index_interface`
"""
function test_abstractarray_interface(kind; testset_type=Test.DefaultTestSet)
    @testset testset_type "$(kind)" begin
        @test method_exists(size, (kind,))
        @test method_exists(getindex, (kind, Vararg{Int}))
        @test partial_method_exists(setindex!, (kind, :, :))
    end
end

end # module

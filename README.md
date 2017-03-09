# InterfaceTesting.jl

Julia has several ["Informal Interfaces"](http://docs.julialang.org/en/stable/manual/interfaces/).
Unlike many mainstream static languages,
interfaces are not statically defined.
Nor, can it be directly required that concrete types of an abstract type implement certain methods.

The Iterator interface is very common.
It is also very easy to mess up.
Eg by forgetting to define `iteratorsize`,
or by defining it on the values, rather than on the types.


This package makes testing it simple.

If in your src file you have defined an iterator `SomeRandomNumbers`

```julia
module CountingGames
    export SomeRandomNumbers
    immutable SomeRandomNumbers end
    Base.start(::SomeRandomNumbers) = 1
    Base.done(::SomeRandomNumbers, state) = state>100
    Base.iteratorsize(::Type{SomeRandomNumbers}) = Base.SizeUnknown()
    function Base.next(::SomeRandomNumbers, state)
        ret = rand(1:10)
        ret, state+ret
    end
end
```

then you can check it meets all the requirements by writing a tests:

```julia
using Base.Test
using CountingGames
using InterfaceTesting

test_iterator_interface(SomeRandomNumbers)
```

This will run a `@testset` to check everything is defined correctly:

```
Test Summary:                   | Pass  Total
  CountingGames.SomeRandomNumbers |    5      5
```
#### On testing parametric types
If your type takes a parameter, eg `Foo{T}`, you are better to run the tests with that parameter filled in.
Eg `test_iterator_interface(Foo{Int})` rather than `test_iterator_interface(Foo)`.
Because of how dispatch to parametric types works.
`Foo{T} != Foo` but `Foo{T} <: Foo`.
This means that if you have defined `iteratorsize{T}{::Type{Foo{T}})`
generally the `test_iterator_interface(Foo)` will fail as that definion does not apply to `Foo`.
It is complicated like that.
But the take away should be to fill in your type parameters when using these tests.

### Supported Interfaces

The focus of this package is the testing of the Iterator interface, with its several traits and complexities.
it does support several others, though these have not had as much testing or thought put in.

 -  [Iterator interface](http://docs.julialang.org/en/stable/manual/interfaces/#iteration). method: `test_iterator_interface`
 -  [Indexing interface](http://docs.julialang.org/en/stable/manual/interfaces/#indexing). method: `test_index_interface`
 -  [AbstractArray interface](http://docs.julialang.org/en/stable/manual/interfaces/#abstract-arrays). method: `test_abstractarray_interface`

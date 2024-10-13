+++
title = "Functors and applicative functors in haskell"
date = 2021-08-21
description = "A small exploration of functors and applicative functors in haskell."

[taxonomies]
tags = ["haskell", "functors"]
+++

# Functors

A functor in haskell is defined as any type which takes another concrete type
as an argument, and provides meaning to the function `fmap`, with signature
```haskell
fmap :: (a -> b) -> f a -> f b
```

### Functor's intuition

Informally, we can understand a functor as a context around something. Any 
functor takes a concrete type as an argument, and we say that the functor is
adding context around that type.

For example, `[]` is a functor. When we define the type "list of integers", 
what we are doing is providing the `[]` functor the argument `Int` to create
the type `[Int]`. 

`[Int]` is the original `Int` type but with an added context: that there may be
more than one integer, or none at all.

Another example of a functor, although this one may seem more pathological, is
`(->) r`. As we've seen, in haskell we can wrap an infix function in `()` to 
transform it into a prefix function. Therefore `(->) r` is nothing but `r ->`,
where a second argument (a concrete type) is lacking. 

If we combine the `(->) r` functor with `Int` we get the type `(->) r Int` or
`r -> Int`, which is all functions that return an integer. In this case, the 
context provided around `Int` is that instead of having an integer, we have
a function that takes one argument of type `r` and then returns and integer.

Other examples which I won't explore in detail are: 

 * `Maybe`, which adds the context of perhaps having no actual value

 * `Either String`, which adds the context of besides having a value, perhaps 
 having a `String` instead.  
 In this last example, a concrete type is already provided to `Either`, as it 
 takes two but a functor can only take one.  
 _(Just like_ `(->) r`_, which needed a type for_ `r`_)_

### Understanding `fmap`

Although the idea of functors is interesting, since creating a new functor is
the same as creating a brand new type, functions which used to work with a
type no longer work in it's functor equivalent.

As an example, let's work with the type "list of integers", in haskell `[Int]`.
There are a lot of functions that work with integers, like the basic arithmetic
operations, or even functions like `succ` or `pred`. These types of functions
become unavailable when we use `[Int]` instead of `Int`. Since `succ`s signature
is 
```haskell
succ :: Enum a => a -> a
```
then the following doesn't make any sense
```haskell
succ [1,2,3]
```
although perhaps it'd be easy to find an equivalent by "tweaking" a little the
original function (That is, a function `succ` that works on lists of integers,
applying `succ` to all elements).
```haskell
succForLists :: Enum a => [a] -> [a]
succForLists = map succ
```
If we think about other functors (Like `Maybe`) it's easy to see that, although
previous functions don't work anymore, they could be easily tweaked to work.

What `fmap` does is take a function and tweak it to work for functors. Each
functor must specify how its tweaked by providing the implementation of `fmap`
for their instance.

This is the implementation of `fmap` for `[]`
```haskell
instance Functor [] where
	fmap = map 
```
and the implementation of `fmap` for `Maybe`
```haskell
instance Functor Maybe where
	fmap _ Nothing = Nothing
	fmap f Just a = Just f a
```

### Functor laws

For any functor we can define how `fmap` behaves in any way. That is, besides
following the given signature, there's no restriction as to how `fmap ` behaves.
However, it's usually advised that `fmap` is defined "sensibly". 

We say that `fmap` has been defined "sensibly" if it makes its functor follow
the functor laws:
 1. `fmap id = id`  
 A tweaked identity is the identity
 2. `fmap (f . g) = fmap f . fmap g`
 A tweaked function composition is the composition of the tweaked functions

# Applicative functors

We say a functor is applicative if it also implements for its type the following
functions:
 * The `pure`, which given a value returns a contextualized version of said 
   value
   ```haskell
   pure :: Applicative f => a -> f a
   ```
 * The `<*>` operator, which applies a contextualized function to a 
   contextualized value, and returns the contextualized result.
   ```haskell
   (<*>)  :: Applicative f => f (a -> b) -> f a -> f b
   ```

### The job of `pure`

The `pure` function gives us a way to make functors from any given value. This
is an injective function between the original type, and the contextualized one.

For example, in the case of a list of integers, `[Int]`, the function `pure` is
implemented in the following way  
```haskell
pure a = [a]
```
which means that, for any integer, you can transform it into a list of integers
by simply putting it in a list alone (a singleton). This function is injective 
since integers and their singletons have a 1 to 1 correspondence. However, not
every list can be accessed using `pure`. Lists like `[1,2]` are inaccessible. 

It's important to note that `pure` can not be bijective, which means that we 
can make a distinction between contextualized values (The values a functor of
that type can take), and pure contextualized values, which are those that can
be obtained by using `pure`

### Understanding the `<*>` operator

With regular functors, we've managed to salvage functions which take one 
argument and use them on the contextualized values. However, when trying to use
any type of function, we encounter a problem. 

Because in haskell any function is a curried function, a binary function is
actually a function which takes one argument and returns a function that takes
the other argument and then returns the final value.

This detail can usually be ignored, but the problem is that for functors, since
`fmap` can only transform a function that works on value into a function that
works on the contextualized values, if we provide it a binary function, it will
return a function that returns a contextualized function. And we don't have a
way of applying a contextualized function to a contextualized value, which 
means this second function is useless to us. We can't give it any values.

The `<*>` operator is our way to fix this. There's usually another tweak we
can make to a function so that it makes sense applying its contextualized
version to a contextualized value. This other tweak is defined with the `<*>` 
operator

Let's see it with an example. The `(+)` function takes two integers and adds
them together. Let's try to apply it over two lists of numbers, of type 
`[Int]`.

The first thing we do is tweak the `(+)` function so that it works over lists
using `fmap`
```haskell
fmap (+)
```
This will return a function that takes a list of integers and returns a list
of functions. Those functions take another integer and adds it up to an integer
from the first list.
```haskell
prompt> fmap (+) [1,2,3]
[(1+), (2+), (3+)]
```
Now we need a way to provide to those functions another list of numbers and
finish the operation. For this, we use `<*>`. The implementation of `<*>` for
`[a]` is the following
```haskell
instace Applicative [] where
    pure a = [a]
    (<*>) fs xs = [f x | f <- fs, x <- xs]
```
This means that the result of applying a list of functions to a list of numbers
returns a list with the results of all possible combinations of functions and
numbers. As an example:
```haskell
prompt> fmap (+) [1,2,3] <*> [1,2,3]
[2,3,4,3,4,5,4,5,6]
```
### The `ZipList` type

Perhaps this isn't what one would expect at first. If you want to add together
the elements of two lists, like `[1,2,3] <specialAdd> [6,5,4]` one would 
expect the output to be `[7, 7, 7]` since both lists have the same length, but
we instead get `[7,6,5,8,7,6,9,8,7]`.

This implementation makes sense when we realize that lists provided may not 
have the same length. We could make it so, if two lists of different lengths
are provided, we truncate the longest one to fit the size of the first one, and
this implementation is included in haskell with the type `ZipList` in the 
module `Control.Applicative`, named this way because the process described
earlier is basically what the function `zipWith` does.

Using `ZipList`, the previous operation would look like this
```haskell
prompt> fmap (+) ZipList [1,2,3] <*> ZipList [6,5,3]`
ZipList [7,7,7]
```
This is the implementation of `ZipList` as an `Applicative`. Note that because
`Applicative` depends on `Functor`, `ZipList` must also be an instance of `Functor`.
```haskell
instance Applicative ZipList where
    pure x = ZipList (repeat x)
    ZipList fs <*> ZipList xs = ZipList (zipWith ($) fs xs)
```
The reason we define `pure` this way is because that's how it should be defined
in order for it to be "sensible". What do we mean by sensible? That's where the
applicative laws come in.

### Applicative laws

In the same way we had functor laws to define what were sensible 
implementations of `fmap`, for applicatives we have the applicative laws, which
define what are sensible implementations for `pure` and `<*>`.

These are 4 equalities that must hold
 1. `pure id <*> v = v`  
 Applying a pure contextualized identity is applying the identity.
 2. `pure (.) <*> u <*> v <*> w = u <*> (v <*> w)`  
 Applying a pure contextualized composition over two functors and a value is 
 the same as applying the first contextualized function after the second.
 3. `pure f <*> pure x = pure (f x)`  
 Applying a pure contextualized function over a pure contextualized value 
 is the pure contextualized function applied over the value.
 4. `u <*> pure y = pure ($ y) <*> u`  
 Applying a contextualized function over a pure contextualized value is the
 same as applying the pure contextualized function "apply value" over the 
 contextualized function.

### The `<$>` operator

To recap, if we want to apply a binary function, like `(+)`, over two 
contextualized values, like `Just 10` and `Nothing` of type `Maybe Int`, we
would first tweak `(+)` to work on the `Maybe` functor with `fmap`, apply it
over the first value and the using `<*>` provide the second value.
```haskell
fmap (+) Just 10 <*> Nothing
```
Because the act of giving a function to `fmap` and then applying it to some
value is so common, haskell provides an operator that directly does that, the
`<$>` operator.
```haskell
(<$>) :: Functor f => (a -> b) -> f a -> f b
<$> = `fmap`
```
This way, the previous expression becomes 
```haskell
(+) <$> Just 10 <*> Nothing
```
which is arguably much more readable.

In `Control.Applicative` there also is a function, `liftA2`, which basically
implements the following as a single function
```haskell
liftA2 :: Functor f => (a -> b -> c) -> f a -> f b -> f c
liftA2 f x y = f <$> x <*> y
```
We can think of it as a version of `fmap` for functions with 2-parameters.

There's also a `liftA3`, but no `liftA4`


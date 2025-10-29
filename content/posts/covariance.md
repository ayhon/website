+++
title = "Covariance and contravariance"
date = 2025-05-31
description= "An explanation of covariance and contravariance"
slug = "/covariance"
draft = true

[taxonomies]
tags = [ "functional-programming", "scala", "category-theory" ]
+++

<!-- Who is really the audience for this blog post? -->

Recently I started reading [Functional Programming Strategies] and so far I have greatly
enjoyed it. I like how every concept is approached from a programmers perspecive, but at
the same time the end of every chapter contains references to all resources that the author
used to write it. This makes the content accessible while allowing readers who are thirsty
for more to easily find their next stop in what will inevitably become a trip down the
rabbit hole.

The reason I decided to write this blog post was section 4.6. This section covers the topic
of covariance and contravariance. I remeber when I learned about the topic myself, in my
_Functional Programming_ class at university, and how difficult of a concept it was at the
time. I also recall fondly how I tried to explain it in simplier terms to a classmate in a
message that ended up spanning a couple of pages. I definitely had understood the concept
at some level, yet I was unable to explain it in simpler terms. At the time I felt that I
was lacking some context to better explain this.

I feel like I may have acquired this context now, after all this time, and reading back the
explanation about it in section 4.6 I thought I could maybe try to explain it again. 

<!-- Talking about type constructors -->
> Not super happy about this whole section. I might just take it all out. I don't really
> care how someone chooses to understand something, the definitions don't change. And 
> the change of perspective doesn't really aid at this point.

First of all, covariance is a property of type constructors. What is a type constructor? In
programming languages, a constructor is a special operation that creates something new,
usually an object. Therefore, my first impression would be to think about a type
constructor as an operation that results in a type. This is not an incorrect conception,
however I now feel that it's more ilustrative to think about a type constructor as the
result of the operation, instead of the operation itself. This is because, in most programming
languages, there is no concept of "computation" at the type level. Therefore, the resulting
type of a type constructor is identified uniquely by the type constructor itself.

To further explain this, we can translate the argument to expressions, and see what the
difference is. If I have a function on expressions, for instance `f: Int → Int → Int`, then
it could happen that `f x y = z` for some value `z` which is obtainable without calling `f`.
The most trivial example would be by unfolding the definition of `f`. To make it more concrete, 
if we have that `f x y = x + y` then `x + y` does not make a call to `f` (that is, syntactically,
`f` does not appear in `x + y`), yet we have the equality `x + y = f x y` **by definition**. We
then say that `f x y` evaluates to `x + y`. This is the computation I was talking about.

However when we define the type of lists of elements of type `A`, which we'll call `List[A]`,
we can't evaluate `List[A]` to some sort of "type expression". To begin with, type expressions
don't exist. The only way we can refer to the type constructor is with the identiifer `List`.
Therefore, I find it more useful to think of the type constructor as the type `List[A]`, where
`A` must be filled in afterwards. 

Then, one can understand covariance to be a relationship between some type `F[A]` and a type
`A` it depends upon.

<!-- Original definitions -->
## Original definitions


Before jumping to my preferred explanation, I will give the definitions I was given when I
had to learn this topic.

To understand covariance in type constructors, one must first understand the subtyping
relation.

### Subtyping relation

> We say that some type `A` is a subtype of type `B` (which we state as `A <: B`) if any operation
which expects an element of type `B` can instead take an element of type `A`.

The typical examples of subtype relations given in object oriented programming are the following:
- An `Orange` is a `Fruit`, therefore `Orange <: Fruit`.
- An `Cat` is a `Animal`, therefore `Cat <: Animal`.
- A `Square` is a `Rectangle`, therefore `Square <: Rectangle`.

In object oriented programming, subtype relationships are usually given by inheritance. More
generally, an instance of one class may be promoted to an instance of any of its superclasses.

### Type constructors

A type constructor is simply a type which depends on other types. For instance, `List` is a type
constructor, since it depends on the type of its elements. I will write `List[A]` to indicate
the type of lists of elements of type `A`. Then, `List` is a type constructor.

Another example of a type constructor would be a type `Handler[A]`, which takes elements of type
`A` and, presumably, handles them in some way. For instance, one could imagine the use case of
a web-server which 


### Covariance

A type constructor `F[A]` is covariant over `A` if for any subtype `B` of `A`, we have that `F[B]`
is a subtype of `F[A]`. In mathematical terms: `A <: B` implies `F[A] <: F[B]`.



## In category theorey

The terminology of _covariance_ and _contravariance_ is also found in a field of mathematics called
category theory. In this field, there is a concept called _functor_ which is similar to our
previous concept of type constructor (??).




## Tranlating programming to simpler concepts

Covariance is a mathematical term. Therefore, if we want to understand covariance we need to think
about programming in mathematical terms. This is not really difficult, since programming is pretty
close to mathematics in some sense, but there are still some concepts that must be translated over
to the mathematical domain.

I believe that the concepts which are most in need of translation are those of state (the idea that
a variable can change its value) and of classes (which are ubiquitous in programming languages).

### State

In programming, one can do things that are not allowed in math. For instance, in mathematics a 
variable isn't really allowed to change value. It's called a variable because it may represent
any value from a set of values (this set in programming is represented by types, by the way), 
but once one chooses a specific value for the variabe, this one cannot be set.



### Classes

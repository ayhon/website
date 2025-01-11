+++
title = "The Rocq proof assistant"
date = 2025-01-11
description= ""
slug = "/coq-proof-assistant"
draft = false

[taxonomies]
tags = [ "theorem-proving", "overview" ]
+++

This whole blogpost is a chapter I submitted as part of my bachelors'
thesis in Computer Science. For those interested, the full thesis 
can be found in [the following link](https://docta.ucm.es/rest/api/core/bitstreams/0d70f687-7572-4265-9659-918b99e701d1/content).
Only some minor changes have been made from the original text, mainly
to translate the $\LaTeX$ source from the report into the Markdown
used to generate these pages.

I wrote the following text after having used Rocq for a couple of
months, so I wouldn't count myself as an expert in the topic. However,
I was particularly proud at the time on how I managed to explain all
the concepts that I was juggling with on my head, and after recently
redescovering my thesis' report I decided this would be an interesting
chapter to host in my blog. I've wanted to post more things in this
website for a while, but the kinds of content I want to include would
require more of my time than I'm willing to give right now. In the
meantime, I believe this to be a nice addition.


# The Rocq Proof Assistant

From [Rocq's website](https://coq.inria.fr/):

> Rocq is a formal proof management system. It provides a formal language to write mathematical
> definitions, executable algorithms and theorems together with an environment for semi-interactive
> development of machine-checked proofs. Typical applications include the certification of properties
> of programming languages, the formalization of mathematics, and teaching.

Of the mentioned typical applications in this project we are most interested in 
the first, the ``certification of properties of programming languages''. In
particular we are interested in verifying that certain algorithms satisfy certain properties
that ensure they are implemented correctly and fulfill their purpose. The Rocq proof assistant 
has been used extensively to verify a multitude of projects.

 - `CompCert`, a certified compiler for the majority of the C language.
 - `Iris`, a higher-order concurrent separation logic framework, used for reasoning about safety of concurrent programs, as the logic in logical relations, to reason about type-systems, data-abstraction, .... It has been used in other projects such as RustBelt.
 - `Fiat-Crypto`, a tool for cryptographic primitive code generation.
 - `ConCert`, a framework for smart contract verification in Rocq.
 - `Cosette`, an automated prover for checking equivalences of SQL queries.

In essence, it is a tool for writing and verifying mathematical proofs and developing certified software.
To provide this functions, Rocq provides a way of creating programs, functioning as a programming 
languages, and a way to develop proofs, functioning as a proof assistant.


## Rocq as a functional programming language

Although, at its core, Rocq is a typed functional programming language, we interact with this language
in a peculiar way. When you write a program in Rocq you can think of it as having a conversation with the
language, where each statement is a question and its result is what Rocq gives you as an answer. It is not
that different from writing your programs in a REPL in other languages. However, Rocq  allows you to be
very creative with your questions. For example, the following command will prompt Rocq to show the internal
representation of its grammar. Pay attention to the final dot. All Rocq commands must end in a dot.

```coq
Print Grammar constr.
```
```
Entry constr is
[ LEFTA
  [ "@"; global; univ_annot
  | term LEVEL "8" ] ]
and lconstr is
  ...
```

At first this might come off as odd. Why would one need such a command? The answer is that, while in most
programming languages we regard the grammar as something static, Rocq allows you to alter the way it parses
your definitions. Therefore, it is useful to know what Rocq currently thinks the grammar looks like. 

However, these commands are not to what we refer to when we talk about Rocq being a programming language.
The programming language inside Rocq can be accessed through some special commands, such as 
`Inductive` or `Definition`.

`Inductive` allows us to define data types. They work similarly to enumerations in other
languages. Consider, for example, the following definition of the booleans as a type containing two 
constructors, `false`.

```coq
Inductive bool := 
  | true
  | false.
```

An inductive type defined in this way can have any number of constructors, including zero!

```coq
Inductive void := .
```

You can check for the type of a value with the `Check` command.

```coq
Check false. 
```
```coq
false
     : bool
```

While the `Definition`
allows us to define values. This works in a similar way to general programming languages. The 
following statement assigns to the variable named `my_true` the value 
`true`.

```coq
Definition my_true := true.
```

A function can be defined through the `Definition` command by specifying its arguments on
the left side of the `:=` symbol. The parenthesis around the arguments are only needed if you 
want to specify the argument's type, or if the type itself could not be inferred by Rocq itself. For 
example we define the function `always_true` which takes a boolean argument 
`true`.

```coq
Definition always_true (b: bool) := true.
```

To express the return type of a function we also use the `:type` syntax, putting it 
right before the `:=` symbol. The following line defines the identity function for
values of type `bool`.

```coq
Definition bool_identity (b: bool) : bool := b.
```

To the right side of the `:=` symbol we can put any Rocq expression. Technically, the 
language of expressions in Rocq is called Gallina
% https://coq.inria.fr/doc/v8.9/refman/language/gallina-specification-language.html#:~:text=This%20chapter%20describes%20Gallina%2C%20the,%2C%20functions%2C%20predicates%20and%20sets.
but people usually refer to it as just Rocq informally. Calling a function is an expression, and the syntax
used is the same as when defining one. To illustrate this we introduce the `Compute`
command, which prompts Rocq to evaluate an expression and show its result. 

```coq
Compute bool_identity true.
```
```coq
= true
     : bool
```

A useful construct of Gallina is that of the 
`match _ with ... end` which lets us act differently depending on the way values were
constructed. This can be used, for example, to define the boolean `notb` function,
which exchanges `false` and vice versa.

```coq
Definition notb b := match b with 
                     | true => false
                     | false => true
                     end.
```

Observe that in this case we could omit the parenthesis in the argument definition, since Rocq was
able to infer the type of `b` from how it was used in the expression.

We can also create functions which return anonymous functions by using the `fun` 
keyword. The arguments are specified with the same syntax as before, with the main difference being 
that now the `=>` symbol is used to separate the arguments from the body, and not 
`->` symbol to separate the 
argument type from the return type. Consider the following function which implements a curried
version of the boolean and function.

```coq
Definition andb (b: bool) : bool -> bool :=
  fun b' => match b with 
            | true => b'
            | false => false
            end.
```

As with most functional programming languages, functions in Rocq can be curried, which means 
that they can be partially applied, providing only one argument and returning a function which takes 
the others. Therefore this type of definition is, in fact, unnecessary. We could have achieved the 
same result by having the function take both arguments `b'` 
directly.

When defining a new type with `Inductive`, the constructors themselves can also take 
arguments. This works as the main way of storing values in Rocq, similar to how records work in other
programming languages. For example, this is how we would define a named pair of two boolean values.

```coq
Inductive two_bools := my_bools (b b': bool).
```

Notice that `b'` is a valid identifier in Rocq. While this is not unique to Rocq (OCaml 
also has this feature), it is still novel enough to be worth pointing it out. Also notice that since 
both `b'` had the same type we could specify it under the 
same set of parenthesis.

`Inductive` definitions are also allowed to be recursive, as long as Rocq is able to 
prove that this recursion comes to an end. In general this means that at least one constructor is not 
recursive. For example, here is the definition of Peano natural numbers in Rocq.

```coq
Inductive nat :=
  | O 
  | S (n: nat).
```

You can also define recursive functions, but not through the `Definition` command. We 
use the `match` over a type 
with arguments in its constructors, it can be useful to use an identifier instead of a value in order 
to bind the value to the identifier. Observe how this is used in the following definition of addition
for Peano's natural numbers.

```coq
Fixpoint add (n m: nat) :=
  match n with
  | O => m
  | S n' => add n' (S m)
  end.
```

If the argument itself will not be used, you can also use the special
identifier `_` to discard it, like it is used in the following example 
of the function `is_zero`.

```coq
Fixpoint is_zero(n: nat): bool :=
  match n with
  | O => true
  | _ => false
  end.
```


`Fixpoint` functions in Rocq also have the catch that Rocq must be able to ensure that
they are terminating. Therefore, a function that loops infinitely cannot be defined in Rocq. 

```coq
Fixpoint loop (n: nat): nat := loop n.
```
```coq
Recursive definition of loop is ill-formed.
In environment
loop : nat -> nat
n : nat
Recursive call to loop has principal argument equal to 
"n" instead of a subterm of "n".
Recursive definition is: "fun n : nat => loop n".
```

These are the basic building blocks of Rocq's programming language. There are not any built-in data 
types commonly found in other languages like booleans or numbers. These are instead defined as part of 
the standard library, in `Coq.Init.Nat`. Common 
expressions such as the `if` expression are actually just syntactic sugar over the
`let ... in` expression, 
which lets you bind an expression to a variable and use it in another expression.
```coq
let x := 10 in x + 1
```
In Rocq, this statement desugars to a `match` expression.
```coq
match 10 with
| x => x + 1
end
```

To let Rocq know that we want to use the definitions for `bool` and 
`nat` defined in its standard library, we would use the following commands.

```coq
From Coq Require Import Bool.Bool.
From Coq Require Import Init.Nat.
```

Besides including the definitions mentioned before, the standard library also defines some
common functions, such as addition, and provide some syntactic sugar to work with them. For example, 
the two following statements are equivalent since they make use of the same function.

```coq
Compute add 1 2.
```
```coq
= 3
     : nat
```

```coq
Compute 1 + 2.
```
```coq
= 3
     : nat
```

To show the syntactic sugar that Rocq is currently aware of you can use the following command. 

```coq
Print Visibility.
```
```coq
...
Visible in scope nat_scope
"x >= y" := (ge x y)
"x > y" := (gt x y)
"x <= y <= z" := (and (le x y) (le y z))
"x <= y < z" := (and (le x y) (lt y z))
"n <= m" := (le n m)
"x < y <= z" := (and (lt x y) (le y z))
"x < y < z" := (and (lt x y) (lt y z))
"x < y" := (lt x y)
"x - y" := (Nat.sub x y)
"x + y" := (Nat.add x y)
"x * y" := (Nat.mul x y)
```

One thing to point out from the output of this command is the fact that boolean equality of two numbers,
recognized as the function `==` or 
`=?` symbol. This is to highlight that this operator returns a boolean
value, since unlike other programming languages, booleans are not built-in into the language. Furthermore,
the `=` operator is reserved for some other purpose in Rocq, which we will explore
in the next section.

Rocq also allows overloading a symbol to different operations depending on the types of its
operands. This can ease the readability of some proofs and theorems, however it can also
sometimes lead to ambiguity. To prevent this, Rocq offers the possibility to define this
syntactic sugar under a scope, and later specify under which scope a given piece of syntax
should be interpreted by. This is done by enclosing the syntax in parenthesis and following
it with the `%` symbol and the name of the scope, which usually tends to
correspond to a type.

This is useful, for example, when juggling with multiple
definitions of numbers. Besides `nat`, Rocq also defines the data-types
`Z` for naturals and integers. The differences
between `N` lie in how they are defined. 
`nat` implements the Peano natural numbers, encoded as zero and its
successors. `N` on the other hand follows the computer representation
of numbers, using a sequence of zeroes and ones. Fortunately, we can use the `+`
symbol to express addition for both data-types.

```coq
Check (1 + 1)%nat. 
```
```coq
(1 + 1)%N
     : N
```

```coq
Check (1 + 1)%N. 
```
```coq
(1 + 1)%nat
     : nat
```



## Rocq as a theorem prover

Besides the commands that allow you to interface with the programming language, Rocq also offers commands
with which you can define theorems and prove them. In fact, the commands `Theorem`, 
`Example`, the main way in which you interact with the 
theorem proving side of Rocq, are all equivalent with one another. The different names are simply for the 
developers to classify the properties they are trying to prove as they see fit.

Consider the following proposition. Pay attention to how we now use the `:` symbol to separate the 
proposition with its name instead of the `:=` symbol as we did in the programming language.

```coq
Example true_is_true : true = true.
```

The proposition appears after the first `:` symbol, and it follows a similar syntax 
to expressions. % Warning 1 of Cury-Howard correspondance
After this command is executed Rocq registers the proposition you want to prove and awaits for you
to provide a proof of this proposition. We do this by entering proof mode using the 
`Proof` command.

In proof mode, Rocq shows you the proposition you have to prove as a goal. In graphical interfaces this
is usually the proposition which appears under the horizontal line.

```coq
1 subgoal


========================= (1 / 1)

true = true
```

The space above the horizontal line is reserved for local definitions, which are definitions that can
only be accessed from within the proof. Most of the time these definitions refer to our hypothesis. There
are no hypothesis at the moment, which is why the only text above the horizontal line is the goal counter.
The goal is the current proposition we need to prove. There can be more than one goal to prove in a proof,
and we say that the proof has concluded when there are no goals left.

Inside proof mode, a new set of commands a syntax are available to us to construct the proof. These are
called _tactics_. For example, to prove the goal `true = true` we wouldd use the 
`reflexivity` tactic, which concludes an equality if both sides are syntactically the same. This is
exactly the case for this goal, which has `true` on both sides.

Once the goal has been proven you can exit proof mode using the `Qed` command. Therefore,
a theorem and its proof would look like this

```coq
Example true_is_true : true = true.
Proof.
  reflexivity.
Qed.
```

This example is not terribly exciting. It would be more interesting if we could prove a property 
for a greater amount of values, not just one. To achieve this in Rocq we use the
`forall` keyword, which has a similar syntax to that of function application.

```coq
Example bool_refl' : forall b : bool, b = b.
```

If we enter proof mode, the goal is now `forall b : bool, b = b`. We cannot conclude this
proof with `reflexivity`, since the goal is not an equality, it has a quantifier 
beforehand. What we would like to say is that the proof is the same regardless of our choice of 
`b` and
proving the theorem for that `intros` 
tactic.

```coq
Proof.
  intros b.
  reflexivity.
Qed.
```

Proving something for all elements of a type is pretty powerful, but usually we are only interested in
proving things for elements which satisfy certain properties. To do this we make use of implication,
written with the `->` symbol.
```coq
Example bool_eq_sym' : forall b b' : bool, b = b' -> b' = b.
```

To start the proof we introduce the variables `b'` with 
`intros` as before. This leaves us in the following state.

```coq
1 subgoal

b, b' : bool

========================= (1 / 1)

b = b' -> b' = b
```

To proceed, we use `eq_b_b'`
to reflect its meaning

```coq
1 subgoal

b, b' : bool
eq_b_b' : b = b'

========================= (1 / 1)

b' = b
```

What we have introduced this time under the name `eq_b_b'` is not a value, but the
evidence that the proposition `eq_b_b'` is true. We can later use that evidence with
other tactics, like `rewrite`, which takes an equality and rewrites all appearances of
the expression on the left side of the `=` symbol with that on the right side of the 
equality.

```coq
1 subgoal

b, b' : bool
eq_b_b' : b = b'

========================= (1 / 1)

b' = b'
```

At this point we can conclude the proof with the `reflexivity` tactic.

```coq
Example bool_eq_sym' : forall b b' : bool, b = b' -> b' = b.
Proof.
  intros b b'.
  intros eq_b_b'.
  rewrite eq_b_b'.
  reflexivity.
Qed.
```

The dual of the universal quantifier `forall` is the existential quantifier
`exists`, which states that there is a value of one type which satisfies the specified
proposition.

```coq
Example has_zero : exists n: nat, n = 0.
```

When proving a goal with an `exists`, Rocq expects you to provide a value with the 
equally-named `exists` tactic, and show that the property holds for the given value.

```coq
Proof.
  (* Goal is [exists n : nat, n = 0.] *)
  exists 0. 
  (* Goal is [0 = 0.] *)
  reflexivity.
Qed.
```

<!-- % However, in mathematics this is not the only approach to prove these kinds of theorems. It is also common -->
<!-- % to use _reductio ad absurdum_, by attempting to prove that the proposition is false and failing to -->
<!-- % do so. However, this type of reasoning is not allowed in Coq, since it is not constructive. That is, if -->
<!-- % Coq allowed these types of arguments we could prove the existence of elements which followed one --> 
<!-- % property, but be unable --> 

In these proofs so far, we have treated all elements of a type the same way, not making a distinction on
how they were constructed. However, for some proofs it is necessary to make this distinction.

```coq
Theorem negb_involutive : forall b : bool, negb (negb b) = b.
```

To prove this statement, we need to show that it holds true for both `true` and 
`destruct` tactic, which takes a term as
an argument and creates as many subgoals as constructors it has. In each of these subgoals, the term
has been replaced by one of its constructors. Therefore, `destruct` allows us to prove
that a proposition is true depending on how the term was constructed.

In this case, the first subgoal asks us to prove `negb (negb true) = true`.
We can use the `simpl` tactic to ask Rocq to simplify the goal, for example by executing
the `negb` function through its definition. This leaves us with 
`reflexivity` tactic. The
same argument holds for the second subgoal

```coq
Proof.
  intros b. destruct b.
  - simpl.
    reflexivity.
  - simpl.
    reflexivity. 
Qed.
```

As a matter of fact, the `true = true` goal is something we already proved in the
`true_is_true` example before. We could reuse this proof
by using the `apply` tactic instead, which receives the name of a proposition previously
defined and attempts to fit it into the current goal, by trying to infer the values of quantified 
variables. For example, we could have also used the 
`bool_eq_refl'` theorem, and Rocq would have set the value of
`true`.

The `apply` tactic also works if the proposition to apply is part of an implication.
If we have a lemma `Q`, we can use
`P`, since if we are able to
prove `h`. An example
of such a situation would be using the previously defined 
`bool_eq_sym'`.

```coq
Lemma  h': forall b: bool, b = true -> true = b.
Proof.
  intros b b_true.
  (* Goal is [true = b] *)
  apply bool_eq_sym'.
  (* Goal is [b = true] *)
  apply b_true.
Qed.
```

Notice how we conclude this example by applying a proof which lives as a local definition. The apply 
tactic is not restricted to the theorems available to Rocq, but also to those arising from the context
of the proof.

Negation in Rocq is not a first-class feature, but it is implemented in terms of implication and 
`False` proposition represents a proposition which cannot be
proven, its dual is the `True` proposition, for which there is one trivial proof called
`I`.

Then, the negation of a proposition `~ P`, is defined as
`P` allows
you to derive a proof of `P`
in the first place, since there is no proof for `P`.

The same way we have `reflexivity` to end a proof if the goal is an equality and both
sides of the equality are constructed with the same constructors, the `discriminate`
tactic allows us to end a proof if given one hypothesis of an equality which can be shown to be false
since both sides use different constructors.

For instance, consider the following proposition.
```coq
Example one_not_zero : ~ (1 = 0).
Proof.
  unfold not. (* Transforms [~ (1 = 0)] into [(1 = 0) -> False] *)
  intros h.   (* Introduces hypothesis [h: 1 = 0] *)
  discriminate h. (* Concludes that hypothesis h cannot be obtained *)
Qed.
```

We have defined `P -> False`. If we revert the terms in that implication we have
`P`. This fact is known in the literature
as the principle of explosion or _ex falso quodlibet_. In Rocq this principle shows in some proofs
where instead of proving the goal it may be convenient that with the assumed hypothesis we can derive
a proof for false. This principle is accessed through the `exfalso` tactic.

```coq
Theorem not_true_is_false' : forall b : bool,
  ~ (b = true) → b = false.
Proof.
  intros b not_b_true.
  destruct b.
  - (* b = true *)
    unfold not in not_b_true.
    exfalso.
    apply not_b_true.
    reflexivity.
  - (* b = false *) 
    reflexivity.
Qed.
```

Besides negating a proposition, Rocq also allows us to use the usual logical connectives. And is expressed 
with the symbol `\/`, mimicking their shape's 
in mathematical notation: $\wedge$ and $\vee$.

When dealing with `split` tactic to
divide the goal into two, which we will have to prove separately. If the `/\` is instead
in a hypothesis `destruct h` tactic, which would 
separate both sides of the conjunction in different hypothesis. Rocq will try to give appropriate names
to the new hypothesis, but most of the time it is a better idea to give the names on your own. To do so,
you can use `hr`
are the names given to the left and right sides of the conjunction respectively.

When dealing with `\/` in the goal, we need to decide which part of the proposition we would
like to prove in order to prove the hypothesis. To choose the left side of the disjunction we use the
appropriately named `right` tactic choosing the
right side of the disjunction as expected. If the `\/` is instead in a hypothesis 
`destruct h` tactic, which will ask us to
prove the same goal twice: once with the left side of the disjunction `h` and once with
the right side of the disjunction `h`. In both of these options the sides of the 
disjunction would replace the `h` hypothesis, but it is also possible to rename them 
by employing the tactic as `hl` and
`hr` are again the names of the left and right side of the disjunction respectively.

Before moving on to the next topic, I wanted to point out a particularity of Rocq's mathematical
foundations. Notice that when handling a goal of type $P \vee Q$ we need to know which between $P$ or $Q$
holds before proceeding with the proof. This is due to Rocq's logic being constructive. In a 
non-constructive logic proving that a proposition cannot be false is equivalent to proving that that
proposition is true. In a constructive logic, however, a proposition is only true if you show it to be
true. While nuanced, this is a powerful distinction.

Consider the following proposition:

> There exist irrational numbers $a$ and $b$ such that $a^b$ is rational.

In classical logic, a proof of the previous would proceed like this. We assume we have already proven that
$\sqrt{2}$ is irrational. Then consider whether $\sqrt{2}^{\sqrt{2}}$ is rational. If it is, we can conclude
the proof with $a = b = \sqrt{2}$. Otherwise $\sqrt{2}^{\sqrt{2}}$ is irrational. We choose $a = \sqrt{2}^
{\sqrt{2}}$ and $b = \sqrt{2}$. Then
$$
a^b = \left(\sqrt{2}^{\sqrt{2}}\right)^{\sqrt{2}} = \sqrt{2}^{\sqrt{2}\sqrt{2}} = \sqrt{2} ^ 2 = 2
$$
Since $2$ is rational this concludes the proof.

Notice how we have concluded the proof without knowing the values of $a$ and $b$. This happened because we
were able to assume the following: 

> $\sqrt{2}^{\sqrt{2}}$ is rational ${\Large{\vee}} \sqrt{2}^{\sqrt{2}}$ is  irrational.

A constructive logic has the advantage that, if something is proven within it, you are 
guaranteed to have values for what was proven. Nevertheless, sometimes proofs require of the 
`excluded_middle`
as an Axiom in the module `Coq.Logic.ClassicalFacts`. An axiom is a proposition
which Rocq accepts as true without proof, and can be declared with the `Axiom`
command. However, it is dangerous to do so, one may introduce a proposition which would enable 
proving `true = false`. Fortunately, we can rely on Rocq's provided assumptions to
not break the consistency of its logic.


## The Curry-Howard correspondence

In the field of programming languages and type theory, the Curry-Howard correspondence states that there
exists an isomorphism between programs and proofs, and types and propositions. So far we have treated Rocq
the programming language and Rocq the proof assistant as two different things, but in fact, they are the 
same. Whenever we wrote `Theorem`, we could have used
`Definition` instead!

```coq
Definition true_is_true' : true = true.
Proof.
  reflexivity.
Qed.
```

The type of `true_is_true` is in fact the proposition we are trying to prove, and its 
value is the proof built in proof mode. In fact, not even proof mode was necessary. We could have 
specified the ``proof object'' directly after the `:=` symbol. This is made apparent if we
ask Rocq to print one of our prior proofs.

```coq
Print has_zero. 
```
```coq
has_zero = 
ex_intro (fun n : nat => n = 0) 0 eq_refl
     : exists n : nat, n = 0
```


Here we see that we construct a proof value using the `ex_intro` constructor, with the
following parameters:

 - `n = 0`
 - 0 is the witness of the `n` for which the property is true
 - `reflexivity` tactic!

The feature which allows us to use Rocq as a theorem prover is its type system. In fact, Rocq's type system
is not like those of other general purpose language, since it allows the definition of dependent types. A
dependent type is a type whose definition depends on a value. This allows us to make types such as 
`Vector.t nat 10`, of all lists of natural numbers of length 10, 
or more importantly, since propositions are types it allows us to refer to individual values in our
propositions, instead of just their types.

Dependent data types can be created with the `Record` command.
```coq
Record dependent_example := {
  a: nat;
  proof_a_not_0: a <> 0
}.
```
The `dependent_example` type represents all pairs of naturals 
`a` and
proofs that `a` is not 0. We can generalize this example to define the subset of 
elements of a type $A$ which fulfill some condition $P$, that is $\{x \in A : P (x)\}$. This type of record is defined in Rocq's standard
library and it is called `sig`.

```coq
Print sig.
```
```coq
Inductive sig (A : Type) (P : A -> Prop) : Type :=
    exist : forall x : A, P x -> {x : A | P x}.

Arguments sig [A]%type_scope P%type_scope
Arguments exist [A]%type_scope P%function_scope x _
```
`sig` is usually used through a special syntax also defined in the standard library
where `sig A P`.

The `forall` keyword behaves like function application, with the difference that it
allows the return type to use the argument's value, that is, it allows the return type to depend on
the  function's parameters. Otherwise, `forall n : nat, nat` is the same as
`nat -> nat`, as can be seen in the following example.

```coq
Definition a : forall n: nat, nat := add 1.
Check a.
```
```coq
a
     : nat -> nat
```

The `False` is equivalent to our previous definition of 
`void`, an inductive type with no constructors, and 
`I`. Intuitively it 
makes sense, since there is not proof of falsehood, therefore it has no constructors, and you can always
prove `True` without needing any extra information, hence the constructor without 
arguments.

Dependent types also allow us to achieve something similar to parametric polymorphism. Consider the
previously defined `bool_identity function`. This function is a less powerful version
of the generic `identity` function which works for arguments of any type. These types
of functions are defined in other functional programming languages through the use of parametric
polymorphism, making both the input and output types generic. However, since in Rocq types are first
class values we do not need parametric polymorphism to define such a function.
```coq
Definition identity' (A: Type)(b: A) := b. 
Compute identity' bool true.
```
This definition is possible since we are allowed to make the type of the second argument depend on the
value of the first with dependent types. However, using this identity function is noticeably less
ergonomic than its counterpart in other functional programming languages since we also need to 
explicitly specify the type of its argument. In other functional programming languages, this task is
left to the type checker through the feature of type inference. Instead, Rocq introduces a more powerful
feature: implicit arguments. An explicit argument is defined by surrounding it with curly brackets instead of parenthesis.
```coq
Definition identity {A: Type}(b: A) := b. 
Compute identity true.
```
Rocq will attempt to derive the value for implicit arguments automatically, using globally available
information as well as its signature. You can also ask Rocq to infer the value of a parameter which was
not marked as implicit by using the `_` identifier instead of its value.
```coq
Compute identity' _ true.
```
To provide all arguments of a function explicitly, even if they were defined as implicit, you can 
refer to the function with a prepended `@`.
```coq
Compute @identity bool true.
```
This is occasionally useful if Rocq is struggling to infer the implicit argument (Rocq's algorithm for type checking and type synthesis [can be exponential](https://cs.stackexchange.com/q/147849) in time in the worst case).


In other programming languages, many commonly used functions are made available in the form of a
standard library. Rocq does the same thing, with its standard library perhaps containing more basic
definitions than in most other functional programming languages since the booleans and integers are
delegated to it. For example, Rocq's standard library defines the `list` data type and
its constructors, and the usual operations over them such as `map`, 
`fold_right` or
`existsb`. These are defined in the
`Coq.Lists.List` module.

```coq
Print existsb.
```
```coq
existsb = 
fun (A : Type) (f : A -> bool) =>
fix existsb (l : list A) : bool :=
  match l with
  | nil => false
  | a :: l0 => f a || existsb l0
  end
     : forall A : Type, (A -> bool) -> list A -> bool
```


However, besides providing data types and operations Rocq also provides theorems which let us reason
about these data types and operations. For example, in `Coq.Lists.List` the
`existsb_exists` lemma is defined, which establishes the relationship between the
`exists` quantifier.

```coq
Print existsb.
```
```coq
existsb_exists
     : forall (A : Type) (f : A -> bool) (l : list A),
       existsb f l = true <-> (exists x : A, In x l /\ f x = true)
```

These lemmas are used extensively throughout this project, and they are also the reason why we try to
define things in terms of functions in the standard library whenever possible.


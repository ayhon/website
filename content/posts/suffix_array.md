+++
title = "The suffix array algorithm"
date = 2023-06-12
description= "How does Ctlr+F work? The suffix array algorithm is the answer."
slug = "/suffix-array"

[taxonomies]
tags = [ "comp-prog", "suffix-array" ]
+++

## Introduction: searching for elements in a list

Searching for an element in a list is one of the classical problems in Computer Science. The simple solution consists of looking one by one at each element, starting from the beginning of the list. This is a linear algorithm, but we can't do much better for a general list, since in the worst case we'll have to check all the elements of the list to see if the element we're looking for is there. This algorithm is called linear search.

```python
def linear_search(ls: list[Elem], target: Elem) -> Optional[int]:
    for i, elem in enumerate(ls):
        if elem == target:
            return i
    return None
```

If you know that your list is sorted in some kind of way, then we can exploit this to craft a more efficient algorithm, binary search. With binary search, we look for the element the same way we look for a word in the dictionary. We first look at the element in the middle, decide if it's our element, and if not, whether to look at the first half of the list or the second half. We repeat this process until we find our element in the list, or we run out of places to look for. Since at each iteration we're discarding half of the elements (instead of only one like we did in the linear search) the runtime of this algorithm is logarithmic. Therefore, it's preferable to search for items in an ordered list rather than an unordered one.

```python
def binary_search(ls: list[Elem], target: Elem) -> Optional[int]:
    beg = 0
    end = len(ls) - 1
    while beg <= end:          # Search in ls[beg:end] while not empty
        mid = (beg + end) // 2 # Get middle element
        if ls[mid] == target:
            return mid
        elif ls[mid] < target: # Target after middle
            beg = mid + 1
        elif target < ls[mid]: # Target before middle
            end = mid - 1
    return None
```

If we want to search for an element in a list, then we can only use linear search, since we don't have the guarantee that the list will be sorted. However, if we know that this list will be queried more than once, that is, we'll need to search for more than one element, then we could improve our algorithm by first sorting the list and then performing the search in the sorted version. We could even prevent modifying the original list by sorting a list of indices instead of the list itself. That way, we could search in this second list of indices to get the index of the element in our original list.

Actually, the same list can be ordered in different ways depending on how we decide to compare its elements. We can compare the elements directly, or use different criteria. For example, the list $[1, 2, 3, 4]$ would be sorted as $[1,2,3,5,4]$ if we use by criteria the number of prime factors each number has. $1$ has no prime factors, $2$, $3$ and $5$ are primes themselves and $4$ features $2$ twice since $4 = 2\cdot 2$. When our criteria involves comparing something other than the element, we call that which we compare the key. Therefore, when we talked about sorting the list of indices instead of the original list we meant sorting the list of indices where the keys are the elements which they point to in the original list.

```python
def sort_indices(ls: list[Elem]) -> list[int]:
    indices = list(range(len(ls)))
    return sorted(indices, key = lambda idx : ls[idx])
```

However ordering an unordered list is no trivial matter. This is also one of those classical problems in Computer Science, most often taught to Computer Science students in their first algorithms class. There are many different sorting algorithms: insertion sort, selection sort, bubble sort, merge sort, quick sort, etc. These algorithms make use of comparisons to sort the list, and the most efficient ones have a complexity bound of $O(n\log (n))$. This bound is actually tight, which means that you can't have a more efficient algorithm relying on comparisons.

<details>
<summary>Why is this bound tight?</summary>
<p> Imagine you have a list of length $n$. Then, the sorted list is a permutation of the elements of the list since the first element will have $n$ possible places to go, but the second one will only have $n-1$, since it can't take the place occupied by the first element. Similarly, the $k$-th element can't take the $k-1$ spots taken by the previous elements, until the final element which only has one final spot to take. We can therefore count the number of possible orders as $n! = n\cdot(n-1)\cdot(n-2)\cdot\dots\cdot 2\cdot 1$.</p>
<p>In our algorithm, each time we make a comparison is to make a decision. We can draw a binary tree from our algorithm, where each node is a comparison it makes and its two children are the continuation of the algorithm, depending on whether the comparison is true or not. The leafs of this tree would be the permutation of the original list which makes it be sorted.</p>
<p>We've calculated that there are $n!$ such permutations, and we know from algorithms class that the minimum height of a binary tree with $n!$ leaves is $\log(n!)$. In this case, the height of the tree represents the worst case performance of our algorithm, that is the maximum number of comparisons you'll have to make to sort a list. Therefore, the number of comparisons needed for an algorithm is $O(\log(n!))$. Knowing that $n! = n(n-1)\dots2\cdot1 \le {n(n-1)\dots(\frac{n}{2}+1)\frac{n}{2}}\le{\frac{n}{2}\dots\frac{n}{2}} = \frac{n}{2}^{\frac{n}{2}}$ then $O(\log(n!)) = O(\frac{n}{2}\log(\frac{n}{2})) = O(n\log(n))$, which ends our proof.</p>
</details>

In the end, whether to use linear search or sorting the list first and then searching on the sorted list of indices is a matter of how many searches you want to support. If the list isn't that big and you aren't searching for many elements, using a linear search probably makes more sense.

## Searching for consecutive elements

For example, consider what happens when you search for a word in a PDF. Even on this webpage, pressing Ctrl+F will let you search for a sequence of characters in the current post. It makes sense to want to be able to search for multiple substrings in a document. This is the motivation behind the algorithm I want to explain in this post, the suffix array algorithm.

We're interested in being able to search any sequence of characters (from here forth referred to as string, or substring) in the document. However, if our document has a number $n$ of characters, the number of substrings it can have is in the order of $n^2$ ($O(\frac{n(n+1)}{2}) = O(\frac{n^2}{2} + \frac{n}{2}) = O(n^2)$ to be exact, the number of possible pairs $(i,j)$ where $i \le  j$). This already imposes a big constraint in the complexity of our algorithm.

Thankfully, we don't need to include every substring in our index list. It suffices to consider only the suffixes. A suffix of a string is a substring obtained by removing a number of characters from the beginning. This is why the word suffix is in the name of the algorithm. We'll be sorting the suffixes, not the substrings. Intuitively, we don't care how long the substring we're searching for is, only where it starts in the document. That's reflected by the suffix.

```python
##    Suffixes of "abcdefg"    ##
"abcdefg" # Suffix at position 0
 "bcdefg" # Suffix at position 1
  "cdefg" # Suffix at position 2
   "defg" # Suffix at position 3
    "efg" # Suffix at position 4
     "fg" # Suffix at position 5
      "g" # Suffix at position 6
       "" # Suffix at position 7 (the empty suffix)
```

Since there are roughly as many suffixes in a string as characters in the document, we'd be tempted to say that our algorithm has a complexity of $O(n\log(n))$. But actually, $O(n\log(n))$ is the order of the number of comparisons we'll have to make. In this particular case, the comparisons themselves are not constant. To check if two strings are equal, we must check each of its characters. To compare two strings, we must check if they are equal, and if they're not, compare the first characters in which they differ. This operation could potentially scan through the whole document. A comparison of two suffixes of the document has a complexity of $O(n)$, and since it's performed $O(n\log(n))$ times, the final complexity comes around $O(n^2\log(n))$.

This is not ideal. However, it seems like there's nothing we can do, since I've already told you that the minimum number of comparisons needed to sort a list is $O(n\log(n))$. Because this is true, right?

## Beyond the basic sorting algorithms

What's actually true is that if your algorithm sorts a list using comparisons, then the minimum number of comparisons it has to make is $O(n\log(n))$. But there are sorting algorithms that do away with the comparisons all together, and therefore don't suffer from this restriction.

One of these sorting algorithms is count sort. The idea behind count sort is the following: to sort a list, if you already know the elements that can appear in the list and their order, forget about comparing them. Simply count how many of each element does the list have and then construct a new list by repopulating them with the number of elements in order.

```python
def count_sort(
    ls: list[Key],
    alph: Iterable[Key]
) -> list[Key]:
    count = {key: 0 for key in alph}
    for elem in ls:
        count[elem] += 1
    return concat([key] * count[key] for key in alph)
```

The complexity of count sort is $O(n + m)$ where $n$ is the length of the list and $m$ is the possible number of elements in the list. We call the sorted list of all possible elements that can be found int the list the alphabet, therefore $m$ is just the size of the alphabet. The factor $m$ is introduced in the complexity of count sort since when we construct the ordered list, we must iterate over the whole alphabet, even if the original list only had a couple of elements.

If you're comparing elements by using some sort of key, and not the whole element, then you can use a variant of count sort called bin sort, which instead of counting the number of appearances of each element and later recreating them, stores each element in a bin according to its key. To construct the sorted list we just concatenate the bins by the order of their keys. Bin sort is a stable sorting algorithm, which means that if you have two elements with the same key, their relative order in the unordered list is preserved in the sorted one.

```python
def bin_sort(
    ls: list[Elem],
    alph: Iterable[Key],
    to_key: Callable[[Elem],Key]
) -> list[Elem]:
    bins = {key: [] for key in alph}
    for elem in ls:
        bins[to_key(elem)] += [elem]
    return concat(bins[key] for key in alph)
```

Count sort and bin sort are really useful if the size of the alphabet is of a reasonable size. However, this isn't always the case. Take as an example the problem we first set out to solve, sorting a list of substrings. What's the size of the alphabet? Well, the strings can have any length from $n$ to $1$, and use any character. Let's assume that all suffixes have the same length (we could just pad the shorter suffixes with some extra "empty" characters). Then if $m$ is the number of characters that can appear, the alphabet of suffixes has $m^n$ possible elements. This makes it so count sort has a complexity of $O(n + m^n)$, which is completely unreasonable.

The problem manifests itself generally when sorting lists of sequences of elements. However, there is another sorting algorithm which doesn't use comparisons like count sort, but performs much better with sequences of elements. This algorithm is called radix sort, and can actually be thought of as a generalization of bin sort to tackle this specific problem.

Radix sort assumes it receives a list of sequences of elements, where the sequences all have the same size $k$. We can extend it to sequences of length at most $k$ by padding those shorter with a special empty element. The algorithm performs $k$ bin sorts, where at first the key is the last element of each sequence, then the previous to last, and so own until in the last iteration the sequences are sorted by their first element.

```python
def radix_sort(
    ls: list[list[Elem]],
    alph: list[Key],
    to_key: Callable[[Elem],Key]
) -> list[list[Elem]]:
    k = len(ls[0])
    for i in range(k-1,-1,-1):
        ith_elem = lambda seq : to_key(seq[i])
        ls = bin_sort(ls, ith_elem, alph)
    return ls
```

For example, to sort the list $[qaz, wsx, edc, rfv, tgb]$ of sequences of length $3$, we'd iterate $3$ times, and after each iteration, we'd get the following lists.

1. $[tg\underline{b}, ed\underline{c}, rf\underline{v}, ws\underline{x}, qa\underline{z}]$ after the first iteration, ordering by the last element of each sequence
  
2. $[q\underline{a}z, e\underline{d}c, r\underline{f}v, t\underline{g}b, w\underline{s}x]$ after the second iteration, ordering by the second element of each sequence
  
3. $[\underline{e}dc, \underline{q}az, \underline{r}fv, \underline{t}gb, \underline{w}sx]$ after the third and last iteration, ordering by the first element of each sequence
  

The final result will surely have the sequence sorted by their first elements. In the case where two sequences share the same first element, since in the previous iteration of radix sort the sequences were sorted by their second element and bin sort is a stable algorithm, they'll be ordered by their second element. It's easy to see how this would extend even if the second, third or any number of elements in the beginning of two sequences are equal.

We can actually relax the condition that all elements must be sequences by instead asking for multiple keys or different criteria, one for each iteration. In the following example
we model this by having the function returning keys take two arguments, the element as before and an added index which identifies which criteria to use. I introduce this construction since it's more general and it'll be of use later on.

```python
def radix_sort(
    ls: list[Elem],
    alph: Iterable[Key],
    k: int,
    to_key: Callable[[Elem,int],Key]
) -> list[Elem]:
    for i in range(k-1,-1,-1):
        ith_elem = lambda seq : to_key(seq,i)
        ls = bin_sort(ls, ith_elem, alph)
    return ls
```

The complexity of radix sort is $O(k (n + m))$, since we perform $k$ bin sorts. This is a great improvement over our previous $O(n + m^k)$ in count sort or bin sort. However, if the length of our sequences is large, like in our example of lists of suffixes where $k = n$, then the complexity of radix sort is quadratic, $O(n^2 + nm)$, which improves over our $O(n^2\log(n))$ with merge sort or quick sort, but not by much.

In general, radix sort works better if you keep $k$ small and bounded, although this may not always be a choice. However, this fact is exploited by the suffix array algorithm to sort a list of suffixes in $O(n\log(n))$. Before we see that, we need to squeeze a final bit of structure from our original problem.

## The final bit of structure

Radix sort requires that the sequences it sorts are all of the same length. If we want to use it to sort a list of suffixes, this is a problem since all our suffixes have different sizes, ranging from $1$ to the whole length of the string. We've seen how to solve this problem already though, by padding our suffixes with a special "empty" character, but this is not the best solution. It works, but intuitively we're losing information specific to our problem in order to make it fit to what radix sort expects. We're solving a more general problem, that is, sorting sequences of the same length. In doing so, we're not using all the information we have available.

How can we recover a bit of that information? Well, instead of padding the suffixes with an arbitrary character, we could instead have them wrap around. That is, we take the characters at the beginning of our string which our suffix doesn't include and stick them at the end. This way, our new padded suffixes all have the same length as the source string, since no characters where deleted. We just selected a number of them from the beginning and put them at the end. These padded suffixes receive a name of their own, they're called cyclic shifts. If you think of our source string as a cycle, where we continue from the final character into the first one, then our padded suffixes represent just that, a shift.

```python
## Suffixes → Cyclic shifts of "abcdefg" ##
"abcdefg" → "abcdefg" # Cyclic shift of 0
 "bcdefg" → "bcdefga" # Cyclic shift of 1
  "cdefg" → "cdefgab" # Cyclic shift of 2
   "defg" → "defgabc" # Cyclic shift of 3
    "efg" → "efgabcd" # Cyclic shift of 4
     "fg" → "fgabcde" # Cyclic shift of 5
      "g" → "gabcdef" # Cyclic shift of 6
```

The good thing about this representation is that we maintain a crucial piece of information about our problem: the fact that all sequences come from the same string. Not only did we get all our suffixes to be represented by sequences of the same length, but we highlighted that these sequences can be derived from one another. There's a small problem with this padding though, as we are no longer able to recover our suffixes from the cyclic shifts. We can fix this though by adding to our original source document a "enf of string" character, which we'll use to know where our original string ended. To recover a suffix from the cyclic shift, we just take the characters from the beginning of the cyclic shift found before the "end of string" character.

Considering that our source string is a cyclic string not only makes it so all suffixes have the same length, but now the number of substrings of the cycle of any length is always the same, the length of the string. Just choose a substring length $k$ pick any starting position and take $k$ characters from that point. If you reach the end of the string you can just go back to the beginning and continue where you left off. Under this definition of substrings of a cycle, we can consider the cyclic shifts to just be the substrings of length $n$ of the string as a cycle.

Cyclic shifts are really interesting because you can get any one from one another by shifting. We could sort our cyclic shifts with radix sort, since they are all sequences of the same length, but this wouldn't be exploiting the previous property. This property is exploited by the suffix array algorithm.

## The algorithm

Given a list of length $n$, the suffix array algorithm sorts its suffixes by sorting its cyclic shifts. Since each cyclic shift corresponds to a suffix, this sorts the suffixes as well. Before we consider the cyclic shifts though, we introduce an "end of string" character which is smaller than all other characters in the alphabet. We do this in order to ensure that there are no two equal cyclic shits.

The suffix array algorithm works by iteratively doing a radix sort with a $k$ of $2$, changing at each iteration the alphabet it uses. The key insight of the algorithm is the following: if you have sorted all substrings of length $h$, you can sort all substrings of length $2h$ by doing a radix sort. We can consider the substrings of length $2h$ to be a sequence of two substrings of length $h$. Also, we can use the substrings of length $h$ as an alphabet, since they are sorted by hypothesis and are all the building blocks we need. Therefore, radix sort works just fine.

First, the suffix array algorithm sorts the substrings of length $1$ of the string as a cycle. This can be done easily with a count sort. Then, it proceeds to build the ordered list of substrings of length $2$, $4$, and so on until the length covers the whole string. This will be done in $\log(n)$ iterations since $2^{\log(n)} = n$. In each iteration we perform a radix sort on sequences formed by 2 elements, meaning that the radix sort has a complexity of $O(2(n + m)) = O(n + m)$. Therefore our final complexity is of the order of $O((n+m)\log(n))$.

## The implementation

To implement the algorithm we just need to follow the ideas found above.
 1. Sort all indices by the character they point to. This corresponds to $h = 1$
 2. Iteratively sort the cyclic substrings of length $2h$ using the alphabet constructed from the substrings of length $h$

However, if we're not careful implementing this, we'll again fall into the problem of comparisons among strings taking $O(n)$. When we use the previous substrings as an alphabet, we can't use the actual substrings themselves, but something else to stand in their place. To this end, we'll assign each substring a number which will represent its place in the order. In particular, if two substrings are the same, even if they occur at different places in the source string, will have the same number, since they correspond to the same key in the alphabet. 

To achieve this we implement a `compress_alphabet` function which will take the previous assignment from cyclic shifts to keys and the sorted indices, and return a list which maps cyclic shifts to the number representing the new key.

```python
def compress_alphabet(keys: list[Key], indices: list[int]) -> list[int]:
    compressed = [0 for idx in indices]
    next_key = 0
    for pos in range(1,len(keys)): # Access elements in order
        i = indices[pos]
        prev_i = indices[pos-1]
        if keys[i] != keys[prev_i]:
            next_key += 1
        compressed[indices[pos]] = next_key
    return compressed
```

With this function implemented, we can finally proceed to implement the final suffix array algorithm.

```python
def suffix_array(source: str, alph: str) -> list[int]:
    n = len(source)
    # First we sort the indices by substrings of length 1
    indices = bin_sort(list(range(n)), lambda i : source[i], alph)
    h = 1
    # Get the key differentiating each letter in source
    keys = compress_alphabet(list(source), indices)
    # Do until we cover a cyclic substring of length greater than n
    while h <= n: 
        # Get the keys of substrings of length 2h
        block_keys  = [[keys[i], keys[(i+h)%n]] for i in range(n)]
        # Use radix sort to sort the indices the 2h substrings
        indices = radix_sort(indices,
            alph=range(max(keys)+1),
            k=2,
            to_key = lambda i, j: block_keys[i][j]
        )
        # Compress the alphabet into just numbers
        keys = compress_alphabet(block_keys, indices)
        # Update the size of substrings we've sorted
        h *= 2
    # Return the sorted indices of substrings of length >= n
    # which match those of cyclic shifts and therefore 
    # of suffixes
    return indices
```


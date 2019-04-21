---
title: Swift Arrays
topic: Swift
description: In the past we've only worked with a single item of data in a constant or a variable. There's much more to this of course, and working with groups or collections of data is an important part of programming. In this course we'll look at the the first fundamental type that we use in Swift to represent these collections - Arrays
concepts_covered: "Declaring array literals\nAppending, inserting, updating and removing elements\nFor in loops"
status: New
skill_level: Beginner
access_level: Basic
estimated_publish_date: 2019-05-01
roadmap: false
responsible_teacher: pasan@teamtreehouse.com
---

# Stage - Storing Data Sequentially

```yaml
---
description: |
  Arrays are one of many different collection types in Swift. Let's start by understanding what arrays are and take a look at the syntax used to create them
topics:
    - Swift
topics_covered:
    - Array basics
    - Declaring array literals
    - Defining array types
```

## Video - Lists of Data

```yaml
---
description: In Swift the Array type is used to represent lists of data. In this video lets talk about what an array is and how we create array literals
access_level: Basic
published: false
```

### On Set

Hi, my name is Pasan and welcome to this course on collections. If you're just getting started with programming, congratulations on making it this far. Earlier you learned about constants, variables and data types like String, Int, Double and Bool. If you don't know what any of that means, check out the pre-requisites associated with this course.

So far we have only worked with single instances of data. We've looked at a String value in isolation, a lone Int value and so on. This won't always be the case and in programming it's common to work with multiple values. We may want to work with a group of Strings or a series of integers.

In programming, a collection is a structure that contains multiple values [LO-1]. In Swift, there are three collection types: Arrays, Dictionaries and Sets [LO-2]. Each of these structures can hold multiple values, but the way they do this and the reasons for doing it differ. In this course, we're going to focus on the first of the three - arrays.

[^MOTION]

Each collection, or data structure as they are commonly called, has a distinguishing characteristic and what makes an array an array is that the data is stored in an ordered sequence [LO-3].

When we learned about constants we said one way we could think of a constant was as a box with a name containing some data. 

An array can be thought of as several of these boxes connected to one another and instead of a name, each box has a number associated with it [LO-4]. The first box, containing the first value stored in the array, starts with the number 0. Every box after is numbered sequentially, so the second box is 1, third is 2 and so on.

We call this number an index and we can more formally say that an array is an indexed data structure [LO-5]. There's one important thing we need to keep in mind regarding arrays - the index always starts at 0, not 1 [LO-6]. This is a quirk of programming you will get used to and it's not a Swift thing - nearly all programming languages use 0 to access the first element in an array.

When we assign a string literal to a constant, that constant name refers to the individual string literal. With arrays, once assigned to a constant, that name refers to the entire collection of data, not just one element [LO-7]. 

Now that we have some understanding of what an array is, let's see what it looks like in code. 

[/MOTION]

### Screencast

I've created a new playground for this course named Collections - you should do the same, whether you're using Xcode or one of the alternatives.

We're going to start in here with an empty file and a comment on the top.

```swift
// Arrays
```

An array, as I mentioned earlier, is a data structure - meaning it is some way of storing related data with well defined ways to work with it [LO-8]. All data structures have a set of defined operations. At it's most basic we need to create the structure, so let's start there.

For this example, let's consider our data to be the days of the week and we will represent that using String literals. There's actually more than one way to declare an array, so I'll just go ahead and type out the first one here, and we'll break it down. 

```swift
["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
```

Back when we started learning Swift, I mentioned that syntax was the set of rules that defined our program. While the line of code I wrote out, may look complicated, ultimately the syntax for the array comes down to two things. 

The first bit is the set of square brackets or box brackets as some people call them [LO-9]. What I mean by set here is the opening bracket on the left, and the closing bracket on the right.

Between the set of square brackets, we can write out a series of values where each value is separated by a comma [LO-10]. This is important, these commas are the second required bit of syntax. Together the square brackets and commas let the compiler know that we want to create an array literal. Let's add this in as a note.

```swift
// Start with a set of empty square brackets - []
// Add values between the brackets and separate them using commas
```

When we learned about constants, remember I said that if we didn't assign a String, Int, Double or Bool literal to a constant or variable, the compiler would just get rid of it right? The same concept applies here. 

So what you see here is the syntax for creating a new array literal, but to work with it after this line of code, we actually need to assign it to a constant and give it a name, so let's do that [LO-11].

```swift
let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
```

It's important to keep in mind here that there are two conceptual things we did here. The first is to create an array literal, which involves everything on the right side of the assignment operator, and second, assigning that array literal to a constant which is everything on the left. The two things are distinct - you can create array literals without assigning them, and you can assign anything to a constant, not just array literals [LO-12-2].

Alright before we talk about anything else, let's get some quick practice declaring arrays. Getting the syntax internalized is the first step to learning about arrays. After that let's explore those two other ways to create arrays.

---

[LO-1]: Recall that a collection is a structure that contains multiple values

[LO-2]: Recall that in Swift there are three basic collection types - Array, Dictionary and Set

[LO-3]: Recall that data in an array is stored in an ordered sequence

[LO-4]: Recall that an array can be thought of as a ordered series of constants where instead of a name each constant is assigned a number and the entire array is given a name

[LO-5]: Recall that the number used to refer to containers in an array is known as an index

[LO-6]: Recall that array indexes in Swift start at 0 not 1

[LO-7]: Recall that when an array is assigned to a constant, the name of the constant refers to the entire array

[LO-8]: Recall that a data structure is a way of storing data along with defined ways of operating on the data

[LO-9]: Recall that to create an array literal the first step is to write out a set of square brackets

[LO-10]: Recall that to create an array literal the second step is to list out the values inside the square brackets separated by commas

[LO-11]: Recall that to work with an array literal previously declared it needs to be assigned to a variable or constant

[LO-12-2]: Differentiate between declaring an array literal and assigning it to a constant


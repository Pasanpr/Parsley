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

```notes
This is a test note
```

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

```notes-documentation
- [String](http://array.com)
```

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

```notes-documentation
- [Arrays](https://developer.apple.com/documentation/swift/array)
```

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

## Instruction - Learning at Treehouse

```yaml
---
description: In this document we cover how to fully utilize the resources Treehouse offers
format: Markdown
estimated_minutes: 5
```

If this is your first time at Treehouse, welcome! In this document we’re going to talk about how you can fully utilize the resources Treehouse provides to get the best learning experience. If you've been here a while and know how to use the Treehouse app, go all the way to the bottom of this document and hit "Ok, I got it".

All Treehouse courses consist of a combination of units:
1. Videos, one of which you just watched
2. Instruction Steps - text based documents (like this one)
3. Quizzes
4. Code Challenges
5. Practice Sessions

### Videos and Instructions

In Videos and Instruction Steps you will learn new material that will introduce concepts, walk you through code and teach you how to program and build apps. To achieve this goal both videos and Instruction steps contain some additional resources. 

#### Teacher’s Notes

On a video page, if you scroll down, you can find a section called **Teacher’s Notes**. While we aim to make Treehouse the one stop shop for all your educational needs there will always be a wealth of material online that can supplement your learning journey.

Most videos will link to such external resources, particularly the official Swift documentation. Pay special attention to these. They are guides written by the people who built Swift and they contain the one true source of advice on how to use the language. Reading the documentation is an extremely important part of being a developer and we’re going to get used to it right from the start.

In addition you will find links to blog posts, glossary items, code snippets and even Wikipedia pages. Make sure you go through all this as you take a course. These external links are considered part of the course experience and you might find yourself with a few unanswered questions if you don’t check the Notes frequently.

#### Questions

Speaking of questions, all Video and Instruction pages also consist of a **Questions** section. Here you will find questions that other students have asked and answered about material introduced in the video or instruction step. If you find that you have some questions about material that was not addressed in either the video or the notes, this is a good place to start.

There’s a high chance that another student has already asked the question you have and has received an answer. Before you jump into the [Treehouse Community][https://teamtreehouse.com/community] and ask a question, skim the existing ones to see if your answer exists. If not, ask away! If the thought of asking a question on a public forum makes you uncomfortable, don’t worry we [have a guide for that](./HowToAskForHelp.md).

#### Downloads

When you follow along with a Video or an Instruction step and write code we want to make sure that you have easy access to the files that we create or the videos you watch. In the **Downloads** section you can find download links to the project files associated with the course, standard and high definition video files as well as the transcripts for the videos.

We highly encourage you to modify code that we write in videos to further your understanding of concepts and to experiment with features you build. At any point if you want to reset state, you can use the project files as an easy way to achieve this.

#### Workspaces

Writing and running code can happen in many types of software and on different kinds of computers. When starting out, getting your _environment_ set up can be a daunting task so Treehouse offers an easy in-browser, coding environment called Workspaces to get you up and running.

In Swift content, both the videos and instruction steps will always use a program called Xcode to write and run code. Xcode only runs on macOS however so if you’re on either Linux or Windows, you can use Workspaces to learn how to program in Swift.

We’ll cover Workspaces more in detail later but if you’re using Workspaces you will find all of your created workspaces in this section.

### Quizzes and Code Challenges

Once you have learned new content at Treehouse we want to make sure that it sticks in your brain. To test your knowledge you will encounter two tools - quizzes and code challenges.

You might be familiar with quizzes from other learning environments and Treehouse quizzes are no different - they are a combination of multiple choice, fill in the blanks or True/False questions to help test concepts and small snippets of code.

Code challenges are where you will get your first taste of programming. A code challenge consists of a set of directions along with a _text editor_ to enter your code. Follow the directions and hit Run to see if you passed the code challenge or not!

There are a couple things you should keep in mind when using code challenges:
1. It is not cheating to solve the problem in your preferred coding environment and paste it in the challenge editor. In fact, I highly encourage  this. As you will find out soon, Xcode, the editor we will use, is a powerful piece of software that has many tricks up its sleeve to help you write code.
2. Like Videos and Instruction steps, Code Challenges also have student discussions associated with them. If you can’t solve the problem, click on the *Get Help* button to ask a question. If a similar question exists Treehouse will bring it up so you can check it out.

It is not a big deal if you can’t pass code challenges on your first try. It’s common to feel frustrated or upset but know that everyone has difficulties and sometimes it just takes reviewing the material again.

### Practice Sessions

Finally, courses have **Practice Sessions** associated with them. While passing Quizzes and Code Challenges are necessary to _completing_ a course, Practice Sessions are a voluntary, on-your-own-time activities that you can take to get in additional practice.

You won’t find a Practice Session listed on the main page of the course, but when you finish relevant material Treehouse will suggest some practice sessions for you to try out.

The format of a Practice Session will vary based on what the instructor thinks is best but you can expect to find a series of Code Challenges that you have to pass, a list of instructions to build a simple program followed by a solution video, or even a full blown project.

Regardless of the format, you should definitely make time to work through these practice exercises. A big part of understanding programming is using simple tools in a variety of concepts and Practice Sessions is where you will get the most opportunity for this.

Alright, if you’re ready, hit “Ok, I got it” to head to the next step.

---

[LO-13]: Recall how to best use Treehouse to study

## Code Challenge - Concatenating Strings

In the editor below I've defined a constant named `greeting` and assigned a string literal. 

Task 1: Define a constant named `name` and assign a string literal with your name to it.

Task 2: We want to display a personalized greeting in our app. Concatenate `greeting` and `name` to output a string literal and assign it to a constant named `message`. If your name is Sue, then the output should read "Hi Sue!".  

```swift
let greeting = "Hi"
let name = "Pasan"

// Hi Pasan!
let message = greeting + " " + name + "!"
```

## Quiz - Recap: Strings

```quiz
::mc-true-*1

Which of the following lines of code would result in the output shown below:
<br>
<pre><code>
Good morning!
It is 75 degrees today.
</code><pre>

[A-1-true] "Good morning!" + "\n" + "It is 75 degrees today."
[F-1] Test feedback!

[A-2] "Good morning!" + "\t" + "It is 75 degrees today."

[A-3] Good morning!" + "\r" + "It is 75 degrees today."
```

---

```quiz
::fitb-*1

Fill in the blank to complete the while loop defined below:
~~~
var counter = 0

___ counter < 10 {
    print(counter)
    counter += 1
}
~~~

[A-0-false-true] while
```

---

```quiz
::tf-true-*1

This is a true false question

[F-F] This is false feedback
[F-T] This is true feedback
```

---

```quiz
::mcma-true-*1

Which of the following lines of code would result in the output shown below:
<br>
<pre><code>
Good morning!
It is 75 degrees today.
</code><pre>

[A-1-true] "Good morning!" + "\n" + "It is 75 degrees today."
[F-1] Test feedback!

[A-2-true] "Good morning!" + "\t" + "It is 75 degrees today."

[A-3-true] Good morning!" + "\r" + "It is 75 degrees today."
```
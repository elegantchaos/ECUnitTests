Some assorted unit-testing related utilities.

Project
=======

There project contains two targets for building Mac and iOS static libraries. 

It also contains a target with some example unit tests in it, which illustrate how to use ECTestCase and ECParameterisedTestCase.


Contents
========

Macros
------

The ECTest macros are much like the STTest ones, except that they don't take a description parameter. Instead, they generate a suitable description from the context.

In practise I find that most of the time, the description is redundant, and ends up repeating the logic of the test itself. The knowledge that an assertion has failed is usually enough, and the descriptions just add clutter to the code.


ECTestCase
----------

This class contains a few utility methods which:

- support the macros
- support using classes that need run loops from unit tests

See [this blog post](http://www.bornsleepy.com/bornsleepy/run-loop-cocoa-unit-tests) for more details of the run loop support.


ECParameterisedTestCase
-----------------------

This class allows you to define unit tests that have a series of test data items applied in turn.

See [this blog post](http://www.bornsleepy.com/bornsleepy/parameterised-unit-tests) for more details.

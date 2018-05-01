# Contributing

## Guidelines

Guidelines for contributing.

### How can I get involved?

First of all, we'd love to welcome you into our Slack community where we exchange ideas, ask questions and chat about Peggy Meter and other PeggyJo-related questions. (*See below for how to join*)

We have two major areas where we can accept contributions:

* Write Swift code for the iOS version of Peggy Meter
* Write Java code for the Android version of Peggy Meter
* Review pull requests
* Test out new features or work-in-progress
* Get involved in design reviews and technical proof-of-concepts (PoCs)
* Help our growing community feel at home
* Create docs, guides and write blogs

This is just a short list of ideas, if you have other ideas for contributing please make a suggestion.

### I've found a typo

* A Pull Request is not necessary. Raise an [Issue](https://github.com/rustema/peggy-meter/issues) and we'll fix it as soon as we can. 

### Branches

We keep master stable. All development is done on the development branch.
All pull requests should by default go into development.

### Paperwork for Pull Requests

Please read this whole guide and make sure you agree to our DCO agreement (included below):

* See guidelines on commit messages (below)
* Sign-off your commits
* Complete the whole template for issues and pull requests
* [Reference addressed issues](https://help.github.com/articles/closing-issues-using-keywords/) in the PR description & commit messages - use 'Fixes #IssueNo' 
* Always give instructions for testing
* Provide screenshots where you can

### Commit messages

The first line of the commit message is the *subject*, this should be followed by a blank line and then a message describing the intent and purpose of the commit. These guidelines are based upon a [post by Chris Beams](https://chris.beams.io/posts/git-commit/).

* When you run `git commit` make sure you sign-off the commit by typing `git commit -s`.
* The commit subject-line should start with an uppercase letter
* The commit subject-line should not exceed 72 characters in length
* The commit subject-line should not end with punctuation (., etc)

When giving a commit body:
* Leave a blank line after the subject-line
* Make sure all lines are wrapped to 72 characters

Here's an example:

```
Add niea.de to the MAINTAINERS file

We need to add niea.de to the MAINTAINERS file for project maintainer
duties.

Signed-off-by: Rustem Arzymbetov <rustem@peggyjo.io>
```

If you would like to ammend your commit follow this guide: [Git: Rewriting History](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History)

**I have a question, a suggestion or need help**

Please raise an Issue or email admin@peggyjo.io for an invitation to our Slack community.

**I need to add a dependency**

We use vendoring for projects written in Go. This means that we will maintain a copy of the source-code of dependencies within Git. It allows a repeatable build and isolates change. 

**How do I become a maintainer?**

Maintainers are well-known contributors who help with:
* Fixing, testing and triaging issues
* Joining contributor meetings and supporting new contributors
* Testing and reviewing pull requests
* Offering other project support and strategical advice
* Attending contributors' meetings

## Community

This project is written in Golang but many of the community contributions so far have been through blogging, speaking engagements, helping to test and drive the backlog of Peggy Meter. If you'd like to help in any way then that would be more than welcome whatever your level of experience.

### Slack

There is an Slack community which you are welcome to join to discuss Peggy Meter and other PeggyJo projects.

Please send in a short one-line message about yourself to admin@peggyjo.io so that we can give you a warm welcome and help you get started.

## License

This project is licensed under the Apache 2.0 License.

### Copyright notice

Please add a Copyright notice to new files you add where this is not already present:

```
// Copyright (c) Peggy Meter Project 2017. All rights reserved.
// Licensed under the Apache 2.0 license. See LICENSE file in the project root for full license information.
```

### Sign your work

> Note: all of the commits in your PR/Patch must be signed-off.

The sign-off is a simple line at the end of the explanation for a patch. Your
signature certifies that you wrote the patch or otherwise have the right to pass
it on as an open-source patch. The rules are pretty simple: if you can certify
the below (from [developercertificate.org](http://developercertificate.org/)):

```
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.
1 Letterman Drive
Suite D4700
San Francisco, CA, 94129

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.

Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```

Then you just add a line to every git commit message:

    Signed-off-by: Joe Smith <joe.smith@email.com>

Use your real name (sorry, no pseudonyms or anonymous contributions.)

If you set your `user.name` and `user.email` git configs, you can sign your
commit automatically with `git commit -s`.

* Please sign your commits with `git commit -s` so that commits are traceable.

If you forgot to sign your work and want to fix that, see the following guide: [Git: Rewriting History](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History)

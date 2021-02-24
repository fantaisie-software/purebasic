# Contributors' Guidelines

Some basic guidelines on how to contribute to the __[PureBasic OpenSource Projects]__.

> **WIP** — These guidelines are still work-in-progress.

-----

**Table of Contents**

<!-- MarkdownTOC autolink="true" bracket="round" autoanchor="false" lowercase="only_ascii" uri_encoding="true" levels="1,2,3,4" -->

- [Introduction](#introduction)
    - [Who Can Contribute and How?](#who-can-contribute-and-how)
    - [Submitted Contents and License](#submitted-contents-and-license)
    - [A Brief Note About Timing and Collaboration](#a-brief-note-about-timing-and-collaboration)
- [The Guidelines](#the-guidelines)
    - [Contributing Feedback](#contributing-feedback)
    - [Editing The Wiki](#editing-the-wiki)
    - [Contributing to the Repository](#contributing-to-the-repository)
        - [Development Cycle and Strategy](#development-cycle-and-strategy)
        - [Setting-up Your Fork for Contributions](#setting-up-your-fork-for-contributions)
        - [Working With `devel` Branch](#working-with-devel-branch)
        - [PureBasic IDE Settings](#purebasic-ide-settings)
        - [Code Styles Conventions](#code-styles-conventions)
            - [Code Styles Validation](#code-styles-validation)
            - [Linting PureBasic Sources](#linting-purebasic-sources)
- [Useful Links](#useful-links)
    - [Installing Git](#installing-git)
        - [GUI Clients for Git](#gui-clients-for-git)
        - [GitHub Desktop](#github-desktop)
        - [Editors with Git Integration](#editors-with-git-integration)
    - [Learning Git](#learning-git)
    - [Working on GitHub](#working-on-github)

<!-- /MarkdownTOC -->

-----

# Introduction

First of all, thank you for dedicating your precious time to reading these guidelines, your interest means a lot to us.
Your contribution to the project is most welcome, and we'd be delighted to have you on board.

## Who Can Contribute and How?

The good news is that contributing is not limited to programming gurus; there are many ways to improve this project and help its growth, and some of them don't even require using __[Git]__ — e.g. editing the [project Wiki], which can be done in the browser.

These are the main areas where you could help us:

- __[Feedback]__ — whether it's a bug report, a feature request or a question, your opinion counts because it informs us on how end users perceive the software, allowing us to shape our product around their needs and deliver an optimal user experience.
- __[The Wiki]__ — the [project Wiki] can be edited by any GitHub user, directly in the browser, and only requires learning [GitHub Flavored Markdown]  (similar to the [BBCode] syntax used in [PureBasic Forums], but simpler).
- __Internationalization__ (aka _i18n_ or _localization_) — keeping translations of the software interfaces and its documentation up to date across the various supported languages (_locales_) is an area where there's never enough help, and we need native speaker to help improve and fix translations.
    Translating the PureBasic IDE menus and interfaces to new languages would be a significant improvement.
    To find out pending translation tasks, check the Issues labeled as:
    + <button>[:lips: French][label French]</button>
    + <button>[:lips: German][label German]</button>
- __Documentation__ — keeping the project documentation up to date with its evolution is a time-consuming task, and volunteers in this area are always welcome.
    To find out pending documentation tasks, check the Issues labeled as:
    + <button>[:books: documentation][label documentation]</button> — repository documentation.
    + <button>[:gear: PB Help][label PB Help]</button> — PureBasic Help documentation.
- __Coding__ — the codebase of the project can always be improved, whether it's through the introduction of new features or optimization of the existing code.
- __Maintenance__ — the repository needs volunteers to help integrating external services, standards and tools that can improve the collaborative experience and its outreach in the open source echo-system.
    Third party services evolve in time, we need help from the community to ensure that the project keeps up with these changes and doesn't lag behind.

Below follow some basic guidelines devised to render cooperation a smooth process.
These are not "sacred rules" engraved in holy stone — _far from it!_ — they're just guidelines based on well established best practices, personal experience and common sense, for the sole purpose of making long-term collaboration a pleasant and smooth experience.
We'd like to shape the project around the needs of its participants, and not the other way round.
So, if you think that these guidelines could be improved, [let us know how it can be done][open an Issue].


## Submitted Contents and License

Any contents you submit to this project will fall under the same license terms that govern it:

- The __[PureBasic OpenSource Projects]__ is dual licensed under [GPLv3] and [Fantaisie Software License].
- The __[project Wiki]__ is dual licensed under [CC BY-SA 4.0] and [Fantaisie Software License].

This means that the code, documents and assets you submit for inclusion in this project will become part of it and therefore implicitly subject to the same licenses terms, unless otherwise specified.

Any third party contents submitted to this project must have a license that is compatible with the project license terms (this also applies to contents published by yourself elsewhere, under a different license).

## A Brief Note About Timing and Collaboration

Before getting into the nitty-gritty of specific areas of contribution, a few words about time in collaborative projects.

Every individual open source project has its own pace, but as a general rule open source projects are not in a hurry.
There are indeed times when major changes are in the making, especially if there deadlines to be met; in such occasions developers will be more present and trying to be actively working at the same time in order to allow real-time exchanges and move the project forward.

But this is not always the case, and indeed not the norm.
Most of the time, open source projects are just in "maintenance mode", and nothing much happens except the usual routine checks, supervising and replying to new Issues.

It's tempting to think that behind the curtain of the repository (as we see it through our browser) there's an ever-vigilant and never-sleeping administrator ready to intercept our requests 24/7.
However, the reality is quite different — believe it or not, even project maintainers do eat and sleep now and then, contrary to the circulating rumours.
Even the most active contributors to any project are not always working at that specific project, and rarely in real-life developers are committed to a single project (on the contrary, they're usually spread thin across many unrelated projects).

Therefore, feel free to open all the Issues and pull requests that you deem fit, just don't expect an immediate response every time.
If a couple of days go by before you get a reply, don't take it personal, it's normal (no one is ignoring you).
Take also into account that some participants might live in a different time-zone from you, and therefore your day might be their night, and vice versa.
Fortunately, communication systems on GitHub are not bound to be in real time, and people are free to reply when they deem it fit.

Some contributors might be present more often but for less time, others more sporadically but dedicating more time each session.
Ultimately, everyone is donating his/her own time to the project, and this is what grants it continuity.

A key element in open source development is constancy over time.
Many project start off loud and frenetic, only to die out quietly when the original momentum fades away.
PureBasic has been around since the late 90's, with over two decades of constant updates, taking on all the challenges of renewal that came along the way; that should suffice us as a guarantee of constancy over time.

# The Guidelines

## Contributing Feedback

Communications about the project happen via [Issues], which are threads around specific topics, similar to forums, but designed to interconnect to other aspects of the project, as well as other repositories too, making it easier for maintainers to track development of the project by keeping relevant information accessible throughout the project.

The repository also has a [Discussions] area, aimed to promote general discussions about the project which are not directly related to its maintenance and development.

To create Issues, all you need is a GitHub account and a browser.

The basic guidelines for Issue are:

- __Is It an Issue?__ — Issues are used for bug reports, features requests, questions and any feedback that _directly addresses development_ of the project.
    For generic topics and discussions, it might be better to either use the repository's [Discussions] area, or post on the [PureBasic Forums], so that repository Issues can focus on development tasks, ideas and feedback.
- __Avoid duplicate Issues__ — Before opening an Issue check that it doesn't already exist; you can use the Search box to look up the keyword of your proposed topic to verify that there isn't already an open (or closed) Issue on the same topic.
    You can comment on a closed Issue if you need to add to it (e.g. a bug that was fixed and is now back), and it might get reopend if necessary.
- __Use intuitive titles__ — Give to your Issues a self-explaining title, so that users sifting through the list of current Issues can immediately understand what it addresses.
- __Stay on topic__ — Issues are topic-oriented, instead of getting side-tracked open another Issue to discuss a secondary topic and provide a cross reference.
    Sidetracking makes it harder to follow Issues, especially if the discussion gets long.
- __Make it accessible__ — Issues are publicly available to anyone, and should be easy to understand for all users, not just the parties involved in the discussion:
    - Don't give for granted previous knowledge that you share with other collaborators, make it easy for newbies to understand and join the discussion.
    - Write with the greater audience in mind — Issues are not private exchanges, they're are record of the repository history and the decisions taken, and people who join a project lately will often read the past Issues to grasp what's going on and how team members works together.
    - If you mention external sources, articles and tools, provide links so that readers can consult them without having to google them up.
- __Interconnect via autolinked references__ — In GitHub everything can be connected to everything else, making it easier to correlate Issues, pull requests, commits and code changes via a web of links.
    Issues provide a special notation to make this happen:
    - If you mention a GitHub user, prefix his/her username with a `@` (e.g. `@some_user`) so that he/she will [receive a notification that he/she's being mentioned] and get a chance to join the discussion.
    - If you mention an Issue, pull request or commit (in this repository or others) use the [autolinked references and URLs] notation, which creates a permanent association between the two, making it easier for others to discover related contents.
- __Bug Reports and OS specific help requests__ — If you need to report a bug, or ask a technical question, please provide detailed information that can help us contextualize the problem or question and reproduce the bug on our machine:
    + __Operating System__ (Windows, Linux or macOS version).
    + __Architecture and bitness__ (AMD/Intel, 32/64 bits, etc.).
    + __PureBasic/SpiderBasic info__ (version number and bitness).
    + __Anti-virus software__ (if any).
    + __Reproduction steps__ — whenever possible, supply enough info to allow reproducing the bug/problem on our machine.
    + __Error Reports__ — if you're stumbling on an error, try to copy and paste the error text (remove any sensitive data first).

## Editing The Wiki

The __[project Wiki]__ offers additional information, in-depth tutorials and useful references to maximize end users' experience of the __[PureBasic OpenSource Projects]__.
It's a collaborative joint effort where PureBasic and SpiderBasic users can freely contribute their insights and experience of the project by writing tutorials, examples, and whatever might be useful to use and enjoy the open sourced parts of PureBasic made available to the public via the __[PureBasic OpenSource Projects]__.

Participating to the Wiki doesn't require using __[Git]__, pages can be edited and created directly in the browser via the GitHub WebUI, which provides an intuitive interface for contents formatting.
Wiki pages are written in [GitHub Flavored Markdown] syntax (GFM), which is similar in principle to the [BBCode] syntax used in [PureBasic Forums]  (but actually simpler).

To discover pending Wiki tasks which you might help with, check the Issues labeled as <button>[:books: Wiki][label Wiki]</button>.

There aren't strict rules regarding the Wiki, and users should feel free to add contents that they deem useful, as long as they stick to the general topic of the main repository.

The __[project Wiki]__ is dual licensed under [CC BY-SA 4.0] and [Fantaisie Software License], and any contents you submit to the Wiki will fall under the same license terms.

Here are some guidelines:

- __Third party contents__ — you should not paste contents written by third parties without first asking them permission to reuse their material — it doesn't matter if they wrote it on a public forum or list, contents belong to their authors and are copyrighted, so you must assume that they are not reusable without author permission, unless the author granted its reuse via an open source license or an explicit statement.
In any case, you should always credit authors, mention the original source and provide a back-link.
- __Quoting__ — when you quote someone else literally, make it clear by using quotations marks or quote blocks.
Don't paste other people's words into your own writing in a way which blurs the line between the two — allow credits where credits are due, and avoid ambiguity.
- __Copyrighted assets__ — don't include in the Wiki any assets (images, code examples, etc.) unless it's reusable material released under a permissive license.
Always mention the author and the assets source, providing a back-link to the original material and its license.

## Contributing to the Repository

Submission of contents to the main project require using __[Git]__, the famous version control tool, and embracing [GitHub's Fork & Pull Workflow].

In this workflow, you won't be editing the project contents directly on the main repository (the _upstream_ repository), instead you'll be editing your own copy (a _fork_) of the repository, on your local machine, by working on a custom branch derived from the `devel` branch (and _never_ editing the `master` branch directly), then when you're ready to submit your changes, you create a _pull request_ on GitHub, which is a request to integrate the changes from your custom branch into the upstream repository.

This approach is at the core of the _version control_ collaborative model, and it's what allows different people to work independently on the same files and then be able to integrate each other's changes without disrupting the main project.

> **WARNING** — Currently the __[PureBasic OpenSource Projects]__ repository isn't fully Git compliant ([#24]) — (**1**) building the IDE requires modifying files tracked by Git, and (**2**) some artefacts produced during compilation might not be adequately ignored by the repository.
> The project is still transitioning from a personal machine-bound [SVN] project into a [machine-agnostic] collaborative Git repository, and there's an ongoing joint effort to make the transition happen in a smooth manner.

### Development Cycle and Strategy

Since May 2020 the repository has adopted a new development strategy:

- `master` branch can be modified only by the maintainers.
- `devel` branch (now the default branch) is the baseline branch for all contributions.

All pull-requests should be made to the [`devel` branch][devel].

> **IMPORTANT** — You should _not_ make any changes directly in your local copy of the `devel` branch! Instead, you must create a new custom branch based on `devel`, and apply your changes to this custom branch, as explained further on.

The `master` branch is now used by the maintainers to publish tagged-releases (i.e. when a new version of PureBasic is released) and additional commits which are considered stable and tested.

The idea is to separate development from public releases.
The `devel` baseline is where all new contributions are accepted and tested, and if a merged pull-request introduced a problem it can be fixed without exposing the `master` branch to bugs.

Maintainers are free to decide if and when it's worth updating the `master` branch, whichever way they deem best.
A tagged release is created on `master` branch whenever a new PureBasic version is released, so that the users can easily pin-point the PureBasic IDE source code that was used for its official package release.

Additional commits might be added to `master` branch between tagged-releases, so that end-users can access the latest updates to the IDE without having to wait for the next official release — but all commits to `master` should only contain changes which have been tested and deemed safe and stable to use in production.

### Setting-up Your Fork for Contributions

If you intend to contribute contents to this project, you'll need to first clone the repository on GitHub, create a local copy of your fork, and then carry out some additional set-up steps in your local fork in order to be able to contribute to the _upstream_ repository.
You'll need to create a GitHub account, if you don't already have one.

1. **FORK THE REPOSITORY** — Log-into GitHub and browse to the landing page of the official PureBasic repository:

    - https://github.com/fantaisie-software/purebasic

    then click on the <kbd>Fork</kbd> button that appears on the right side at beginning of the page (you need to be logged-in to see this option).
    For more info on forking, see [GitHub Docs » Fork a repo][Fork a repo].

2. **CLONE YOUR FORK LOCALLY** — You then need to _clone_ your fork locally, i.e. make a copy on your machine.
Open up the Git Bash and type:

    ```bash
    $ git clone https://github.com/<your-GitHub-account>/purebasic
    $ cd purebasic
    ```

    replacing in the above command `<your-GitHub-account>` with whatever your GitHub account is (without brackets, exact letter casing).
    For more info on how to clone a fork, see [GitHub Docs » Cloning a repository][Cloning a repository].


3. **CONFIGURE THE UPSTREAM REMOTE** — You need to ensure that your fork is able to track the upstream repository by adding the `upstream` remote and _fetching_ it (i.e. updating its status information):

    ```bash
    $ git remote add upstream https://github.com/fantaisie-software/purebasic
    $ git fetch upstream
    ```

    Henceforth, your repository fork will recognize `upstream` as a reference to the main project (as opposed to the `origin` remote, which points to your fork on GitHub).
    For more info on how to add remotes, see [GitHub Docs » Adding a remote][Adding a remote].


4. **TRACKING `master` BRANCH** — The default branch of the PureBasic repository is set to `devel`, not `master`, because it's main goal is development.
So, you might also want to ensure that your local fork of the repository contains a copy of the `master` branch (which is not created automatically when you fork and clone) in order to gain access to the stable status of the project:

    ```bash
    $ git checkout --track -b master upstream/master
    ```

    Henceforth you're fork will contain a local copy of the `master` branch which tracks `upstream/master` too.
    The above commands only needs to be executed once.

Now that you're set-up and ready to start contributing, the next section will introduce the main steps of the contribution cycle.


### Working With `devel` Branch

In this section we'll provide some basic guidelines on the contributions workflow of the __[PureBasic OpenSource Projects]__.

Practical examples of the required Git commands are offered for each step, in order to help users who are new to working with Git — bare in mind: these are intended mainly as guidelines to orientate users in the right direction and, although _they do work_, they are not necessarily the best way to use Git.

Contributors should always use the `devel` branch as the reference baseline for their contents submissions.
All changes should be made to a new custom branch created from `devel`, but you shouldn't edit the `devel` branch directly (more details below).


1. **SYNCH** — Ensure that your local fork of the repository is up-to-date by _pulling_ from [`upstream/devel`][devel] while inside your local `devel` branch:

    ```bash
    $ git checkout devel
    $ git pull upstream devel
    ```

    The above commands will synchronize your local copy of `devel` to mirror the current state of the upstream repository (a _pull_ command carries out a _fetch_ operation followed by a _merge_).

    > **NOTE** — These commands might fail to execute if your current branch has some file changes waiting to be committed, or if you have changed the contents of your local `devel` branch (which you _shouldn't_ do, ever) causing to be out-of-synch with its upstream counterpart.

2. **BRANCH** — In your local fork, create a new branch from `devel`:

    ```bash
    $ git checkout devel
    $ git checkout -b <your-branch-name>
    ```

    where `<your-branch-name>` will be replaced by whatever name you choose for the contribution you're planning to work on (e.g. `new-themes`, `bug-fix`, etc., without angle brackets).
    Try to choose a short and concise name that intuitively conveys the nature of the changes contained in the new branch.

    The newly created branch is what you'll be working on (locally) to implement the changes you want to contribute to the upstream repository.
    Once your changes are approved, your pull-request branch will be merged into the `devel` branch of the upstream repository and the pull request is closed.
    At that point you usually delete your working branch since it's no longer needed, its contents having now become part of the `upstream/devel` branch.

3. **REBASE** — As you're working on your new features, chances are that in the meanwhile the upstream repository might get updated with new pull-requests being merged into `devel`. When this happens, you'll need to:

    1. Update your local copy of the `devel` branch (as explained above, in the **SYNCH** step).
    2. _Rebase_ your local working branch in order to integrate the new commits that were added to `upstream/devel` since you created your branch (or since your last rebase operation).

    So, after having updated your local `devel` branch, checkout your working branch (here called `<your-branch-name>`, for the sake of example), and then rebase via the `git rebase` command, like this:

    ```bash
    $ git checkout <your-branch-name>
    $ git rebase upstream devel
    ```

    The above commands will update your contributions branch and _replay_ all your changes on the latest `upstream/devel` branch, as if you had started to work on it from its last commit.

    In most cases rebasing will work auto-magically, without requiring any adjustments on your side; but sometimes it might not (e.g. if folders and files were renamed in some later commit) and might fail and/or require some manual intervention on your side — that's called "solving conflicts", and it's beyond the scope of these guidelines.

4. **COMMIT** — When preparing you commits for the pull request, ensure to create a meaningful commit message that delivers in a concise way the nature of the changes:

    + _[How to Write a Git Commit Message]_ — by Chris Beams.

    Also, if the commit relates to one or more open Issues, don't forget to references them via [Autolinked references and URLs], which greatly helps tracking the project status on GitHub and preventing dangling Issues which are already solved.

5. **PULL-REQUEST** — Once your contribution is ready for submission, you can push your changes (i.e. your contribution branch) to your GitHub fork (i.e. to your `origin` remote) and then create a pull-request from your repository landing page, on GitHub.
    While inside your contribution branch, type:

    ```bash
    $ git push -u origin HEAD
    ```

    The above command will create a copy of your local work branch on your GitHub fork (i.e. if your local branch was named `bug-fix` it will create `origin/bug-fix`).

    Now that your contributions are published on GitHub (in your own _fork_) you can visit your fork's homepage on GitHub and create a pull-request from your browser (once you push your branch, in the landing page of your fork you'll see a new option to create a pull request).

These are the main steps of the contribution cycle.
Some steps, like rebasing to keep in synch with `upstream/devel`, might need to be carried out more than once.

Once you've created your pull-request on the upstream repository, the project maintainers will start to review your submitted contents.
During this stage there might be questions to better understand what your changes do, and often a discussion might follow regarding possible improvements, small corrections, etc.

During the review process, you can still edit your working branch, and whenever you push changes to your fork/origin, the PR (pull request) contents are automatically updated (because it's linked to your origin/branch).
It's not uncommon that maintainers might ask you to rebase your PR a couple of times in order to be able to integrate changes from other PRs that are being merged during the process — as a matter of fact, it's quite common practice that multiple pending PRs are handled all at once, in order to ensure that any conflicts are smoothly resolved in a single session.

If you're stuck, or need help, don't hesitate to [open an Issue] — we'll be happy to help you out.

### PureBasic IDE Settings

Before editing the source files of the repository with the PureBasic IDE, you must ensure that the IDE doesn't save its settings at the end of the source files.

In "__Preferences » Editor »  Save Settings to:__", there are four options to handle how compiler options are saved/loaded:

1. __The end of the Source file__ — settings are saved as a comments block at the end of each source file.
2. __The file &lt;filename&gt;.pb.cfg__ — for each source file, a corresponding `<filename>.pb.cfg` file is created. The file is a PureBASIC [Preference file].
3. __A common file project.cfg for every directory__ — a single `project.cfg` [Preference file] is created within a folder, the settings of each source file are grouped in a [Preference Group] named as the source file.
4. __Don't save anything__

Check that your IDE is not configured to use the first option, otherwise you'll be modifying files tracked by Git, even if you don't actually change the file contents.
Options two and three are fine because the repository is set to ignore any files matching the patterns `*.pb.cfg`, `*.pbi.cfg` and `project.cfg` — i.e. those files are excluded from the repository (see [`.gitignore`][.gitignore]).

### Code Styles Conventions

This project uses [EditorConfig] settings to enforce consistent coding styles in the repository, protecting it from mixed indentation styles and sizes, file encoding corruption, trailing white spaces and other code inconsistencies commonly found in collaborative editing:

- [`.editorconfig`](./.editorconfig)

These settings allow multiple developers to work on the same files across various editors and IDEs without disrupting the adopted code styles conventions.
Modern editors will automatically detect the settings in the `.editorconfig` file and enforce them project-wide, overriding user settings in favour of project-specific settings.

Code consistency simplifies tracking changes in the repository history by preventing spurious code changes from polluting the diffs in each commit, and ensuring that only meaningful and intended changes are actually submitted.
For example, if you editor was allowed to change the adopted EOL (end-of-line sequence) at save time, or convert tabs into spaces (or vice versa), then every line of the file would result as having been modified in your commits, which would make it very hard to track which code lines were changed in a meaningful way — not to mention that simply saving a file would cause Git to see it as having been modified, even if you didn't actually edit its code, due to changes in white space characters.

You should check whether your editor supports [EditorConfig] natively or you need to install a plug-in.
[A list of free plug-ins is available at editorconfig.org] for editors and IDEs that don't support EditorConfig natively.

#### Code Styles Validation

Every commit and pull request to the project is immediately validated against the `.editorconfig` settings via [Travis CI], an automated on-line service for [continuous integration].
Any commit or pull request that doesn't pass the validation test will be reported as a _build_ failure, providing an error report that lists the files which need to be fixed.

To prevent submitting pull requests that will not pass the build test, you can run these validation checks locally, before committing to GitHub, by launching the validation Bash script found in the project root:

- [`validate.sh`](./validate.sh)

The `validate.sh` script is cross-platform, and under Windows can be launched from the Bash that ships with Git installation.
The script requires installing __[EClint]__, a __[Node.js]__ command line tool to validate files against EditorConfig settings.

#### Linting PureBasic Sources

For code styles consistency of PureBasic source files, it's sufficient to reformat all source files via the native linter of the PureBasic IDE, available in "__Edit » Format indentation__" (<kbd>Ctrl</kbd>+<kbd>I</kbd>).

The code formatting functionality of the PureBasic IDE offers advanced linting and code alignment correction, and will guarantee that source files are consistently formatted across all user machines, which greatly simplifies tracking actual code changes when diffing commits and pull requests.

Since every PureBasic user has access to PureBasic IDE, adopting it as the standard linter tool grants 100% code style consistency without requiring [EditorConfig] settings (which are not supported by the PureBasic IDE).
Just make sure that your IDE is configured to use the default settings for code indentation.

-------------------------------------------------------------------------------

# Useful Links

If you're new to Git and GitHub, in this section you'll find some links to useful articles, tutorials and learning resources to help you out.

## Installing Git

You can download Git from the official website:

- [git-scm.com](https://git-scm.com/ "Visit Git official website")

### GUI Clients for Git

You might also consider installing a GUI client/frontend for Git, which simplifies and speeds up many common operations.

- [List of GUI clients for Linux](https://git-scm.com/download/gui/windows)
- [List of GUI clients for Mac](https://git-scm.com/download/gui/mac)
- [List of GUI clients for Windows](https://git-scm.com/download/gui/linux)
- [List of Git interfaces, frontends, and tools](https://git.wiki.kernel.org/index.php/InterfacesFrontendsAndTools) — at Kernel.org.

> __NOTE__ — Some GUI clients require that you also install Git on your machine while others include a full Git version in their setup, so you'll need to check this with each Git client software.
> Windows users are advised to install Git anyway because Git for Windows also installs a full Bash and many common Linux tools, which are very handy to work with and are needed to execute Bash scripts.

### GitHub Desktop

Windows and macOS users might consider installing  __GitHub Desktop__, a free and open source Git client specifically targeting GitHub, which reduces the complexity of Git interactions by abstracting them into easier to grasp operational concepts:

- [desktop.github.com](https://desktop.github.com/)

### Editors with Git Integration

__Visual Studio Code__ and __Atom__ are two free and open source editors that support Git out-of-the-box, allowing you to work on repositories source files without having to leave the editor:

- [code.visualstudio.com](https://code.visualstudio.com/)
- [atom.io](https://atom.io/)

## Learning Git

Free books on Git:

- _[Pro Git]_ — by Scott Chacon and Ben Straub, a comprehensive guide covering all aspects of Git, available in many languages.
- _[Git Magic]_ — a step by step approach to learn Git, available in many languages.
- _[Learn Version Control with Git]_ — A step-by-step course for the complete beginner, by Git Tower.
- _[Das Git-Buch]_ (DE) — Free comprehensive book on Git, in German.
Includes cross-platform installation guidelines and a chapter dedicated to the GitHub workflow.

    + **English Edition** — An English translation  by PureBasic users [@tajmone] and [@SicroAtGit] is under way:

        * https://github.com/tajmone/Git-Buch_EN

        The latest draft is always available for [LiveHTML Previewing][GitBuch-EN Live]  (the whole book was translated, but needs to be revised and polished).

Git primers and tutorials:

- [Everyday Git] — Learn the basics with 20 of the most common commands.
- [Backlog Git Tutorials] — a series of introductory tutorials for Git newbies.
- _[How to Write a Git Commit Message]_ — by Chris Beams.

Video tutorials on Git:

- [Free videos at Git website](https://git-scm.com/videos)

## Working on GitHub

Understanding the _Fork & Pull_ model used on GitHub:

- [Wikipedia » Fork and pull model]
- [GitHub's Fork & Pull Workflow for Git Beginners] — by Tom Hombergs.

Learning to work on GitHub:

- [GitHub Docs] — Official GitHub Help documentation.
    + [Fork a repo]
    + [Cloning a repository]
    + [Adding a remote]
    + [Autolinked references and URLs]
- [GitHub Guides] — Free Git and GitHub guides.
- [GitHub Learning Lab] — Learn new skills by completing fun, realistic projects in your very own GitHub repository.
    + [Introduction to GitHub]
    + [First Day on GitHub]
    + [First Week on GitHub]

<!-----------------------------------------------------------------------------
                               REFERENCE LINKS
------------------------------------------------------------------------------>

[PureBasic Forums]: https://www.purebasic.fr/english/ "Visit the PureBasic Forums (English)"
[A list of free plug-ins is available at editorconfig.org]: https://editorconfig.org/#download "See the list of EditorConfig plug-ins"

<!-- repo files -->

[.gitignore]: ./.gitignore "See the '.gitignore' settings file"

<!-- repo links -->

[PureBasic OpenSource Projects]: https://github.com/fantaisie-software/purebasic
[Issues]: https://github.com/fantaisie-software/purebasic/issues "Go the Issue main page"
[open an Issue]: https://github.com/fantaisie-software/purebasic/issues/new "Open an Issue and talk to us!"
[Discussions]: https://github.com/fantaisie-software/purebasic/discussions "Go to the repository Discussions page"
[project Wiki]: https://github.com/fantaisie-software/purebasic/wiki "Visit the Wiki of the PureBasic OpenSource Projects"

<!-- repo issues and milestones -->

[#24]: https://github.com/fantaisie-software/purebasic/issues/24 "Issue #24 — Achieving Full Git Compliance"
[#35]: https://github.com/fantaisie-software/purebasic/issues/35 "Issue #35 — Machine Agnostic Build Scripts"
[machine-agnostic]: https://github.com/fantaisie-software/purebasic/milestone/1 "See milestone: machine agnosis"

<!-- repo labels -->

[label documentation]: https://github.com/fantaisie-software/purebasic/labels/%3Abooks%3A%20documentation "View all Issues labeled as 'documentation'"
[label French]: https://github.com/fantaisie-software/purebasic/labels/%3Alips%3A%20French "View all Issues labeled as 'French'"
[label German]: https://github.com/fantaisie-software/purebasic/labels/%3Alips%3A%20German "View all Issues labeled as 'German'"
[label PB Help]: https://github.com/fantaisie-software/purebasic/labels/%3Agear%3A%20PB%20Help "View all Issues labeled as 'PB Help'"
[label Wiki]: https://github.com/fantaisie-software/purebasic/labels/%3Abooks%3A%20Wiki "View all Issues labeled as 'Wiki'"

<!-- repo branches -->

[devel]: https://github.com/fantaisie-software/purebasic/tree/devel "View the 'devel' branch"

<!-- xrefs -->

[Feedback]: #feedback "Jump to the Feedback guidelines"
[The Wiki]: #editing-the-wiki "Jump to the Wiki guidelines"

<!-- license -->

[GPLv3]: ./LICENSE "The GNU General Public License v3"
[Fantaisie Software License]: ./LICENSE-FANTAISIE "The Fantaisie Software License"
[CC BY-SA 4.0]: https://creativecommons.org/licenses/by-sa/4.0/legalcode "Creative Commons Attribution-ShareAlike 4.0 International"

<!-- PureBasic Documentation -->

[Preference file]: https://www.purebasic.com/documentation/preference/index.html "See PureBasic Documentation on 'PureBASIC Preference'"


<!-- 3rd party websites -->

[EClint]: https://www.npmjs.com/package/eclint "Visit the EClint page at NPM"
[EditorConfig]: https://editorconfig.org "Visit EditorConfig website"
[Git]: https://git-scm.com "Visit Git official website"
[Node.js]: https://nodejs.org/en/ "Visit Node.js website"
[SVN]: https://en.wikipedia.org/wiki/Apache_Subversion "Learn more about Apache Subversion"
[Travis CI]: https://travis-ci.com "Visit Travis CI website"

<!-- misc. references -->

[BBCode]: https://www.phpbb.com/community/help/bbcode "Read the BBCode Guide at phpBB"
[continuous integration]: https://en.wikipedia.org/wiki/Continuous_integration "See Wikipedia page on 'Continuous integration'"

<!-- GitHub Help, Docs, Tutorials, etc. --------------------------------------->

<!-- GitHub Docs -->

[GitHub Docs]: https://docs.github.com/en/github "Official GitHub Documentation"

[Adding a remote]: https://docs.github.com/en/github/using-git/adding-a-remote "Learn how to add a remote to a repository"
[Autolinked references and URLs]: https://docs.github.com/en/enterprise-server@3.0/github/writing-on-github/autolinked-references-and-urls "Learn how to use autolinked references and URLs in your commits"
[Cloning a repository]: https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository "Learn how to clone a repository from GitHub"
[Fork a repo]: https://docs.github.com/en/github/getting-started-with-github/fork-a-repo "Learn how to fork a repository on GitHub"

<!-- GitHub Guides -->

[GitHub Guides]: https://guides.github.com "Free GitHub Guides at guides.github.co"

[GitHub Flavored Markdown]: https://guides.github.com/features/mastering-markdown/ "Read the 'Mastering Markdown' tutorial (3 minutes)"
[receive a notification that he/she's being mentioned]: https://guides.github.com/features/issues/#notifications "See GitHub Help to learn more about notification on mentions"

<!-- GitHub Learning Lab -->

[GitHub Learning Lab]: https://lab.github.com "Interactive Git and GitHub tutorials"

[First Day on GitHub]: https://lab.github.com/githubtraining/paths/first-day-on-github
[First Week on GitHub]: https://lab.github.com/githubtraining/paths/first-week-on-github
[Introduction to GitHub]: https://lab.github.com/githubtraining/introduction-to-github

<!-- Useful links: Git Books -->

[Git Magic]: http://www-cs-students.stanford.edu/~blynn/gitmagic/ "Read 'Git Magic' on-line for free"
[Pro Git]: https://git-scm.com/book/en/v2 "Read 'Pro Git' on-line for free"
[Learn Version Control with Git]: https://www.git-tower.com/learn/git/ebook/en/command-line/introduction "Read 'Learn Version Control with Git' on-line for free"
[Das Git-Buch]: http://gitbu.ch/ "Read or download the free German book 'Das Git-Buch'"
[GitBuch-EN Live]: https://htmlpreview.github.io/?https://github.com/tajmone/Git-Buch_EN/blob/alpha-dev/docs_src/Git-Buch_EN.html "Preview the latest draft of the English translation of the 'Git Buch'"

<!-- Useful links: Git Tutorials -->

[Everyday Git]: https://git-scm.com/docs/giteveryday "Learn everyday Git with 20 commands or so"
[Backlog Git Tutorials]: https://backlog.com/git-tutorial/
[How to Write a Git Commit Message]: https://chris.beams.io/posts/git-commit/ "Learn how to write a good Git commit message, by Chris Beams"

<!-- Useful links: GitHub -->

[GitHub's Fork & Pull Workflow for Git Beginners]: https://reflectoring.io/github-fork-and-pull/ "Read the article 'Github's Fork & Pull Workflow for Git Beginners' by Tom Hombergs"
[GitHub's Fork & Pull Workflow]: https://reflectoring.io/github-fork-and-pull/ "Read the article 'Github's Fork & Pull Workflow for Git Beginners' by Tom Hombergs"
[Wikipedia » Fork and pull model]: https://en.wikipedia.org/wiki/Fork_and_pull_model

<!-- people -->

[@tajmone]: https://github.com/tajmone "View @tajmone's GitHub profile"
[@SicroAtGit]: https://github.com/SicroAtGit "View @SicroAtGit's GitHub profile"

<!-- EOF -->

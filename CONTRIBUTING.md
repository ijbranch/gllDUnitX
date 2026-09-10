## How to contribute ##

The following are the guidelines, everyone should use to contribute to DUnitX.  
Changes are welcome from all members of the Delphi Community. 

## Getting Started ##

1. Create a [GitHub Account](https://github.com/join).
2. Fork the DUnitX Repository and setup your local Repository.
     * Each of of the steps below are detailed [How to Fork](https://help.github.com/articles/fork-a-repo) article!
     * Clone your Fork to your local machine.
     * Configure "upstream" remote to the [master DUnitX repository](https://github.com/ijbranch/gllDUnitX).
3. For each change you want to make:       
     * Create a new branch for your change. 
     * Make your change in your new branch. 
         * Although changes can be made in the master branch, it easier long term if a new branch is used.
     * **Verify code compiles and unit tests still pass.** 
         * The quickest way to have a Pull Request not be accepted, is to submit code that does not compile or pass tests.
     * Commit change to your local repository.
     * Push change to your remote repository
     * Submit a [Pull Request](https://help.github.com/articles/using-pull-requests).
     * Note: local and remote branches can be deleted after pull request has been accepted.

**Note:** Getting changes from others requires [Syncing your Local repository](https://help.github.com/articles/syncing-a-fork) with Master DUnitX repository.    This can happen at any time.


## Dependencies ##

The following both are required to run the Unit Tests on DUnitX itself.   

* [glldelphi-mocks](https://github.com/ijbranch/glldelphi-mocks), checked out as a sibling of this
  repository at the commit pinned in [DEPENDENCIES.md](DEPENDENCIES.md). This fork consumes our own
  Delphi-Mocks fork from source — not upstream
  [VSoftTechnologies/Delphi-Mocks](https://github.com/VSoftTechnologies/Delphi-Mocks), and not the DPM
  package that upstream pinned.
* Delphi 13 (Florence) or later, Windows only - Win32 and Win64 (Delphi-Mocks is required for the test project)
* Any project you build against `Source\` needs its own platform-varying DCU output directory — see
  **Tips and Tricks** in [README.md](README.md) for why.

## New to GIT ##

If you are new to GIT here are some links to help you with understanding how it works.    

- [GIT Documentation](http://git-scm.com/doc)
- [Atlassian Git Tutorial](https://www.atlassian.com/git/tutorial/git-basics)
- [What are other resources for learning Git and GitHub](https://help.github.com/articles/what-are-other-good-resources-for-learning-git-and-github) 


## Feedback and Collaboration ##

A [Delphi Praxis forum](https://en.delphipraxis.net/forum/36-dunitx/) has been setup to discuss DUnitX.   It's a great place to get feedback on your changes if desired before submitting them as a pull request.

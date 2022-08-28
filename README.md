# Personal Website

[![Build Status](https://travis-ci.org/banerjs/banerjs.github.io.svg?branch=devel)](https://travis-ci.org/banerjs/banerjs.github.io)

## Branches

There are three parallel branches in this repo:

- `devel` (current): This branch should be used for development. All pushes on this branch are automatically built by Travis, and if successful, the build artifacts are pushed into `master`. If there are breaking changes in development, then create a branch off this one and then merge back through a PR; the PR will be built by Travis.
- `master`: The branch is automatically deployed to the website by Github. The files in this branch are updated by Travis after successful builds on `devel`. Try not to develop and/or modify this branch manually.
- `docker`: Contains the `Dockerfile` folders that have the details of images relevant to this project. The images are updated automatically through Docker Hub when this branch is pushed.

## Helpful Reference

- [jekyll-resume](https://github.com/mattcouchman/jekyll-resume)
- [resume](https://github.com/mhyee/resume)
- [jekyll-scholar](https://github.com/inukshuk/jekyll-scholar)
- [Deedy-Resume](https://github.com/deedy/Deedy-Resume)
- [hyde](https://github.com/poole/hyde)
- [MathJax](http://sgeos.github.io/github/jekyll/2016/08/21/adding_mathjax_to_a_jekyll_github_pages_blog.html)
- [Kramdown Quick Reference](https://kramdown.gettalong.org/quickref.html)

## Running locally

`bundle exec jekyll serve -P 8000 --drafts`

**Prerequisites**:

* Install [RVM](https://github.com/rvm/ubuntu_rvm)
* (temporary; hopefully) Install older openssl: `rvm pkg install openssl`
* Install ruby (matching the Gemfile version): `rvm install ruby-3.0.0 --with-openssl-dir=/usr/share/rvm/usr` (different openssl is hopefully temporary)
* Install from Gemfile: `bundle install`

## TODO

- Create YAML files for the different sections of the resume, and fill them out
- Create PDF from YAML files
- Create PDF automatically from the bibtex

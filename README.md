Description
===========

Make it easy to manage private source repos. This provides some resources that
let you checkout code in your own recipies/cookbooks.

Requirements
============

Nothing outside of stock Chef.

Resource/Provider
=================

This cookbook includes an LWRP for managing private git repos.

`glue_git`
----------

# Actions

- :sync: Sync a remote repo

# Attribute Parameters

- path: The path to checkout the repo to.
- repository: Link to the repository.
- revision: Revision to use.
- user: The ssh key to use for checking the repo out.

# Setup

There's a little setup required for this. Namely, you need to store the SSH
private key to be used for checking code out (so that everyone can get it).

Towards this end, you'll need to create a `glue` data bag. To do this from
knife, you can:

    $ knife data bag create glue

Then, create a file with the id of the user you'd like to check out as
`deploy.json` and then with content that looks something like this:

    {
      "id": "deploy",
      "key": "-----BEGIN RSA PRIVATE KEY-----\n-----END RSA PRIVATE KEY-----\n"
    }

To put this file into your chef server, you can run:

    $ knife data bag from file glue deploy.json

# Example

    glue_git "/opt/my_project" do
      repository "git@github.com:me/my_project.git"
    end

    glue_git "/opt/my_project" do
      repository "git@github.com:me/my_project.git"
      revision "HEAD"
    end

    # The user parameter is the same as what you used for the id in the `glue`
    # data bag
    glue_git "/opt/my_project" do
      repository "git@github.com:me/my_project.git"
      revision "HEAD"
      user "my_deploy_user"
    end

Usage
=====

License and Author
==================

Author:: Thomas Rampelberg (<thomas@saunter.org>)

Copyright:: 2011, BitTorrent, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


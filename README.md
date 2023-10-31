# Introduction

FaaSr is a package that makes it easy for developers to create R functions and workflows that can run in the cloud, on-demand, based on triggers - such as timers, or repository commits. It is built for Function-as-a-Service (FaaS) cloud computing, and supports both widely-used commercial (GitHub Actions, AWS Lambda, IBM Cloud) and open-source platforms (OpenWhisk). It is also built for cloud storage, and supports the S3 standard also widely used in commercial (AWS S3), open-source (Minio) and research platforms (Open Storage Network). With FaaSr, you can focus on developing the R functions, and leave dealing with the idiosyncrasies of different FaaS platforms and their APIs to the FaaSr package.

This tutorial guides you through the setup and execution of a simple FaaSr workflow. In this tutorial, you will learn how to describe, configure, and execute a FaaSr workflow of R functions in the cloud, using GitHub Actions for cloud execution of functions, and a public Minio S3 “bucket” for cloud data storage. With the knowledge gained from this tutorial, you will be able to also run FaaSr workflows in OpenWhisk and Amazon Lambda, as well as use an S3-compliant bucket of your choice. 

The main requirements to go through this tutorial are the following; the tutorial will guide you through the installation of additional software pre-requisites (the git and gh tools):

* A GitHub account
* Rstudio installed in your computer

# Tutorial terminology and roadmap

* Function: a function written in the R language
* Function Repo: a GitHub repository where Functions are stored
* Action: abstraction of the execution of the R Function in a FaaSr cloud
* Docker container: the execution environment hosting the execution of the Function when an Action is invoked
* Workflow: a graph describing the order in which Actions are invoked (and Functions executed)
* S3 Data Store: an S3 data bucket where files can be stored/retrieved from a cloud storage service conformant to the S3 protocol (e.g. Minio, AWS S3)
* FaaS Compute Server: a FaaS cloud computing service supported by FaaSr (GitHub Actions is used in this tutorial; OpenWhisk and Lambda are also supported)
* FaaSr JSON file: a configuration file for FaaSr, in the JSON format, which describes a Workflow and its associated Functions, Docker container(s), S3 Data Store(s), and FaaS Compute Server(s)
* FaaSr JSON Builder: a Shiny app that provides a graphical user interface to generate FaaSr JSON configuration files
* FaaSr Secrets file: a file with R environment variables storing the secrets/credentials to access your S3 Data Store and FaaS Compute Server clouds

The tutorial is structured as the following sequence of steps:

* Install pre-requisites in your computer
* Configure a GitHub Token
* Configure your FaaSr Secrets file
* Configure a FaaSr JSON file with a simple Workflow
* Create S3 bucket
* Register the Workflow with GitHub Actions
* Invoke the Workflow
* Browse the S3 Data Store to view outputs
* Browse the GitHub Actions interface to view Action 
* Repeat for a more complex Workflow

# Installing pre-requisites

## System pre-requisites
First, install the git and gh tools for Git/GitHub in your computer, following the instructions here:

* https://github.com/git-guides/install-git
* https://cli.github.com/

## Rstudio pre-requisites

Within Rstudio, install devtools, if you don’t already have it:

```
install.packages("devtools")
```

Then install FaaSr:

```
devtools::install_github('FaaSr/FaaSr-package',ref='main',force=TRUE)
```

And install minioclient:

```
install.packages("minioclient")
library(minioclient)
install_mc()
```

```

# Create GitHub Token

Within Rstudio, configure the environment to use your GitHub username and email:

```
usethis::use_git_config(user.name = "YOUR_GITHUB_USERNAME", user.email = "YOUR_GITHUB_EMAIL")
```

The command below will open a browser window for you to create a GitHub token (If you already have a GitHub personal access token (PAT), skip this step
). When you create a token: 
* in the "Note" field, give your token a descriptive name, and
* in scopes, select “workflow” and “read:org” (under admin:org)
* be mindful that tokens have an expiration date (which you can set); once yours expires, you'll need to recreate by following these instructions
* copy the token to your clipboard or save to a temporary file in your computer; you will need to use it below
  
```
usethis::create_github_token()
```

Now set this token as a credential for use with Rstudio - paste the token you copied above to the pop-up window that opens with this command:

```
library("credentials")
credentials::set_github_pat()
```

# Configure your FaaSr Secrets file

Download the file faasr_env from the FaaSr-tutorial repository to your computer. Edit this file and replace the string "REPLACE_WITH_YOUR_GITHUB_TOKEN" with your GitHub token. Save this file.

# Configure a FaaSr JSON file with a simple Workflow

Download the file tutorial_simple.json from the FaaSr-tutorial repository to your computer. Edit this file and replace the string "YOUR_GITHUB_USERNAME" with your GitHub username. Save this file.

# Create S3 Bucket

This tutorial uses the minioclient package with the free/openly available Minio "play" server as your Data Store. The "play" server provides an easy way to get started, but keep in mind data stored there is available to the public and deleted every day - this is only intended to be used for this tutorial. Don't store any data other than the tutorial files!

Create a bucket called "faasr" using minioclient's mb (make bucket) command:

```
mc_mb("play/faasr")
```

# Register the Workflow with GitHub Actions

Use the faasr function in the FaaSr library to use the tutorial_simple.json and faasr_env files above. The faasr function returns a list (faasr_tutorial in this example) that you can then use to register and run your workflow:

```
library("FaaSr")
faasr_tutorial <- faasr(json_path="tutorial_simple.json", env="faasr_env")
```

To register this workflow with GitHub Actions:

```
faasr_tutorial$register_workflow()
```

# Invoke the workflow

Now invoke the workflow:

```
faasr_tutorial$invoke_workflow()
```

# Browse the S3 Data Store to view outputs

You can use the mc_ls command to browse the outputs:

```
mc_ls("play/faasr/tutorial")
```

You will eventually see three files that have been produced by the execution of the tutorial workflow: sample1.csv and sample2.csv (created by the function create_sample_data) and sum.csv (created by the function compute_sum)





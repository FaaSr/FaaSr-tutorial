# Introduction

FaaSr is a package that makes it easy for developers to create R functions and workflows that can run in the cloud, on-demand, based on triggers - such as timers, or repository commits. It is built for Function-as-a-Service (FaaS) cloud computing, and supports both widely-used commercial (GitHub Actions, AWS Lambda, IBM Cloud) and open-source platforms (OpenWhisk). It is also built for cloud storage, and supports the S3 standard also widely used in commercial (AWS S3), open-source (Minio) and research platforms (Open Storage Network). With FaaSr, you can focus on developing the R functions, and leave dealing with the idiosyncrasies of different FaaS platforms and their APIs to the FaaSr package.

# Objectives

This tutorial guides you through the setup and execution of a simple FaaSr workflow. In this tutorial, you will learn how to describe, configure, and execute a FaaSr workflow of R functions in the cloud, using GitHub Actions for cloud execution of functions, and a public Minio S3 “bucket” for cloud data storage. With the knowledge gained from this tutorial, you will be able to also run FaaSr workflows in OpenWhisk and Amazon Lambda, as well as use an S3-compliant bucket of your choice. 

# Requirements

For a reproducible experience, this tutorial is designed to work with the rocker/rstudio Docker container, and the main requirements to run the tutorial are: 1) a GitHub account, 2) a GitHub personal access token (PAT), and 3) Docker installed in your computer

# Start and connect to Rocker Rstudio container

"Pull" and run the Rocker Rstudio container with the following command:

```
docker pull rocker/rstudio
docker run --rm -ti -e ROOT=true -e PASSWORD=yourpassword -p 8787:8787 rocker/rstudio
```

Then, point your browser to http://localhost:8787 and log in (username is rstudio and use the password you provided in the command above)

# Install FaaSr package and required dependences

## Clone the FaaSr tutorial repo

First let's clone the FaaSr tutorial repo:

* Click on "File -> New Project"
* Select "Version Control"
* Select "Git"
* Enter the following URL: https://github.com/FaaSr/FaaSr-tutorial
* Use your keyboard's tab; leave the default Project directory name: FaaSr-tutorial
* Click on "Create Project"

## Set as working directory

You should now see the FaaSr-tutorials repository on the lower right-hand window of Rstudio

Use the drop-down menu from "More" and select "Set As Working Directory"

## Source the script that sets up FaaSr and dependences

Run the following command (fair warning: it will take a few minutes)

```
source('rocker_setup.R')
```

# Configure Rstudio to use GitHub Token

Within Rstudio, configure the environment to use your GitHub account (replace with your username and email)

```
usethis::use_git_config(user.name = "YOUR_GITHUB_USERNAME", user.email = "YOUR_GITHUB_EMAIL")
```

Now set your GitHub token as a credential for use with Rstudio - paste your token to the pop-up window that opens with this command:

```
credentials::set_github_pat()
```

# Configure the FaaSr secrets file with your GitHub token

Open the file named faasr_env in the editor. You need to enter your GitHub token here: replace the string "REPLACE_WITH_YOUR_GITHUB_TOKEN" with your GitHub token, and save this file. 

The secrets file stores all credentials you use for FaaSr. You will notice that this file has the pre-populated credentials (secret key, access key) to access the Minio "play" bucket

# Configure the FaaSr JSON simple workflow template with your GitHub username

Open the file tutorial_simple.json  and replace the string "YOUR_GITHUB_USERNAME" with your GitHub username, and save this file.

The JSON file stores the configuration for your workflow. We'll come back to that later.

# Register and invoke the simple workflow with GitHub Actions

Now you're ready for some Action! The steps below will:

* Use the faasr function in the FaaSr library to load the tutorial_simple.json and faasr_env in a list called faasr_tutorial
* Use the register_workflow() function to create a repository called FaaSr-tutorial in GitHub, and configure the workflow there using GitHub Actions
* Use the invoke_workflow() function to invoke the execution of your workflow

```
faasr_tutorial <- faasr(json_path="tutorial_simple.json", env="faasr_env")
faasr_tutorial$register_workflow()
```

When prompted, select "public" to create a public repository. Now run the workflow:

```
faasr_tutorial$invoke_workflow()
```

# Browse the S3 Data Store to view outputs

Now the workflow is running; soon it will create outputs in the Minio play S3 bucket. You can use the mc_ls command to browse the outputs:

```
mc_ls("play/faasr/tutorial")
```

The simple example you just executed consists of two R functions: create_sample_data.R creates two CSV files, and compute_sum.R computes their sum.  You will eventually see three files that have been produced by the execution of the tutorial workflow: sample1.csv and sample2.csv (created by the function create_sample_data) and sum.csv (created by the function compute_sum)

# A more complex workflow

The tutorial includes a more complex workflow, as shown in the diagram below:

![alt text](tutorial_larger_workflow.jpg)

To run this workflow, you can follow similar steps as above, but you will be working with a different JSON file - one that describes the larger workflow.

First off, open the file tutorial_larger.json and replace the string "YOUR_GITHUB_USERNAME" with your GitHub username, and save this file

Then, you can load this file into another R list faasr_tutorial_larger:

```
faasr_tutorial_larger <- faasr(json_path="tutorial_larger.json", env="faasr_env")
```

Use it to create a new repository for this workflow with GitHub Actions (remember to type public when prompted):

```
faasr_tutorial_larger$register_workflow()
```

Then invoke the workflow:

```
faasr_tutorial_larger$invoke_workflow()
```

You can monitor the outputs in the S3 bucket using minioclient:

```
mc_ls("play/faasr/tutorial2")
```

# Using the JSON Builder Shiny app

While you can create and edit FaaSr configuration files in any text editor, we provide a graphical user interface in a shiny app to facilitate the development of simple workflows. You can use this tool to create a configuration from scratch, or upload a JSON configuration as a starting point. The Shiny app allows you to download the final JSON to your computer for use in FaaSr, for example as in faasr_tutorial_larger <- faasr(json_path="tutorial_larger.json", env="faasr_env")

[Right-click here to open the JSON Builder Shiny app in another window](https://faasr.shinyapps.io/faasr-json-builder/). You can download the tutorial_larger.json from this repository, then upload to the Shiny app, and you will be able to visualize the image shown above

# Under the hood - GitHub Actions

This tutorial creates two repositories in your GitHub account:

* FaaSr-tutorial
* FaaSr-tutorial2

Notice that if you browse to these repositories on GitHub, if you select "Actions" on the top tab, you will see a list of actions that have executed (e.g. create_sample_data, sum). 

This repository only holds the actions that were created automatically with the register_workflow FaaSr call, and invoked with invoke_workflow. Feel free to delete these repositories after you finish the tutorial.

Note: for the tutorial_larger example, you will notice that both "sum2" and "finalsum" have both a successful invocation (green check) and an aborted invocation (red X) - this is normal! These are invoked twice, because they have two predecessors in the graph above; however, only one of the invocations succeeds (the other one is terminated)

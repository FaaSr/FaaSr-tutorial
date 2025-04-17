# Building and Deploying Ecological Forecasts with neon4cast and FaaSr

In this tutorial, we will run a [neon4cast package](https://github.com/eco4cast/neon4cast) example locally and deploy using a FaaSr-ready workflow. 


## Prerequisites
- A Github account
- A Github personal access token (PAT)
- RStudio on Posit Cloud (recommended) or a local Docker-based installation. 
- a Minio S3 bucket (you can use the [Play Console](https://min.io/docs/minio/linux/administration/minio-console.html#minio-console) to use a public/unauthenticated server)

**This tutorial assumes that you have finished the [basic FaaSr tutorial](https://github.com/FaaSr/FaaSr-tutorial) first, as it guides you through the process of setting up your Posit or Rocker environment and your GitHub PAT. If you have not already done so, please complete that tutorial first before proceeding.**


# Part I: Running a neon4cast example manually

This part is optional; it guides you through executing the neon4cast example in [this repo](https://github.com/eco4cast/neon4cast/tree/main) locally so you gain a better understanding of the code we use as a basis for this tutorial before you run it through FaaSr. If you would like to first execute this example locally in your Rstudio session, follow the instructions in the appendix. Otherwise, continue to Part II to run it using FaaSr.

# Part II: Deploy a simple FaaSr workflow.


## Objectives

In this part, we will learn how to configure the working environment and deploy a simple FaasR workflow that is prebuilt for you.

## Clone the FaaSr tutorial repo

We assume that you have already cloned the FaaSr-tutorial as per instructions for the [basic FaaSr tutorial](https://github.com/FaaSr/FaaSr-tutorial). 

- In RStudio, navigate to the neon4cast_faasr folder inside FaaSr-tutorial. 
- Then set it as the working directory (More > Set as Working Directory).

## Source the script that sets up FaaSr and dependences

We assume that you have already executed the posit_, rocker_ or rstudio_setup_script that sets up FaaSr and its dependences for your Rstudio session as per the [basic FaaSr tutorial](https://github.com/FaaSr/FaaSr-tutorial). 

## Configure Rstudio to use GitHub Token

We assume that you have already configured your GitHub username, email and PAT token as per the [basic FaaSr tutorial](https://github.com/FaaSr/FaaSr-tutorial). 

## Configure the FaaSr secrets file with your GitHub token

We assume that you have already setup your faasr_env file with your GitHub PAT token as per the [basic FaaSr tutorial](https://github.com/FaaSr/FaaSr-tutorial). 


## Configure the FaaSr JSON workflow

Head over to files tab and open `neon_workflow.json`. This is where we will decide the workflow for our project. Replace YOUR_GITHUB_USERNAME with your actual github username in the username of ComputeServer section. A workflow has been configured for you, shown in the image attached below. For more information, please refer to [this schema](https://github.com/FaaSr/FaaSr-package/blob/main/schema/FaaSr.schema.json).

![image](https://github.com/user-attachments/assets/da1f0143-9387-431c-b466-818ddd943d67)


### Workflow Pipeline
1. getData - Invoke function:
    - Download and process aquatic dataset and upload it to S3
    - This function will act as the starting point for our workflow, invoking both oxygenForecastRandomWalk and temperatureForecastRandomWalk next.
2. The following two functions will run simultaneously:

   a. oxygenForecastRandomWalk
     - Use the filtered dataset to create Oxygen forecast using RandomWalk method and upload it to S3
     - Invoke combined forecast next.
       
    b.temperatureForecastRandomWalk
     - Use the filtered dataset to create Temperature forecast using RandomWalk method and upload it to S3
     - Invoke combined forecast next.
 3. combineForecastRandomWalk:
    - Download the 2 forecasts file from S3 to generate a combined forecast and store it in S3
    - This function doesn't invoke any function after, meaning this is the end of our workflow.



## Register and invoke the simple workflow with GitHub Actions

Now you're ready for some Action! The steps below will:

* Use the faasr function in the FaaSr library to load the neon_workflow.json and faasr_env in a list called neon4cast_tutorial
* Use the register_workflow() function to create a repository called neon4cast_faasr_actions in GitHub, and configure the workflow there using GitHub Actions
* Use the invoke_workflow() function to invoke the execution of your workflow

Enter the following commands to your console:

```
neon4cast_tutorial<- faasr(json_path="neon_workflow.json", env="../faasr_env")
neon4cast_tutorial$register_workflow()
```

When prompted, select "public" to create a public repository. Now run the workflow:

```
neon4cast_tutorial$invoke_workflow()
```

## Check if action is successful



Head over to the github repo `neon4cast_faasr_actions` just created by FaaSr, go to actions page to see if your actions has successfully run. 
If the runs are successful, you can explore the S3 bucket with either the mc_ls command or the Web console using https://play.min.io:9443 and the credentials as per the [basic FaaSr tutorial](https://github.com/FaaSr/FaaSr-tutorial)

In your faasr bucket, there are two folders called FaaSrLog and neon4cast. In FaaSrLogYou can find logging and status for each function in the workflow. In neon4cast folder, files that are created during the workflow are stored here.  

Another way to check if our workflow has run successfully is using mc_ls command by FaaSr to list files in either of the above folders:

```
mc_ls("play/faasr/neon4cast")
```
After that, you can retrieve the files listed into your working environment using mc_cat command in the console:
```
mc_cat("play/faasr/neon4cast/aquatic_full.csv")
mc_cat("play/faasr/neon4cast/blinded_aquatic.csv")
mc_cat("play/faasr/neon4cast/rw_forecast_combined.csv")
```

# Part III: Build a FaaSr workflow by yourself.

## Objectives

This part of the tutorial will guide you to create a new workflow by extending the one you worked on part II. We have provided you some guidance and an example file `create_oxygen_forecast_mean.R` to assist you in this part. The function in this file is similar to the previous two we have seen, but with a modification of the method when creating a forecast. See [file](https://github.com/FaaSr/FaaSr-tutorial/neon4cast_faasr/blob/main/create_oxygen_forecast_mean.R). 



## Configure the FaaSr JSON workflow

The workflow we are aiming to create will have two addition functions compared to the one in previous part. Those are "oxygenForecastMean" and "temperatureForecastMean", which will create forecasts using "Mean" method (instead of "Random walk' as in part II)  on the two variables oxygen and temperature respectively. *Friendly reminder:*  the base function `create_oxygen_forecast_mean.R` has been created for you.

![image](https://github.com/user-attachments/assets/808eb754-3bd1-4d8d-a7bd-9573a701f265)

In part II, our getData function will invoke oxygenForecastRandom walk and temperatureForecastRandomWalk after its execution. We want to add a little complexity to this by having getData invoke two other functions, which are oxygenForecastMean and temperatureForecastMean in this case. However, after executions, they will not invoke a combining function as we have seen previously. 


## Add function to the workflow using JSON Builder App


While you can create and edit FaaSr configuration files in any text editor, FaaSr also provides a Shiny app graphical user interface to facilitate the development of simple workflows using your browser. You can use it to edit a configuration from scratch, or from an existing JSON configuration file that you upload as a starting point, and then download the edited JSON file to your computer for use in FaaSr. [Right-click here to open the FaaSr workflow builder in another window](https://faasr.shinyapps.io/faasr-json-builder/). 

To start, you will need to download "neon_workflow.json" and upload it to the FaaSr JSON Builder, your Workflow section should represent the workflow we had in part II. Next, we will guide you through the process of adding the provided function `create_oxygen_forecast_mean.R` to this workflow. 

### oxygenForecastMean

Let's first create our function in the workflow:

1. On the left sidebar, choose `Functions` for "Select type" field.
2. For "Action Name" and "Function Name", input the following: `oxygenForecastMean` and `create_oxygen_forecast_mean`. Notice: the function name declared here should match the function name initialized in `create_oxygen_forecast_mean.R`.
3. For "Function Arguments", we need to match this field with the actual arguments in our file, which is `folder=neon4cast, input_file=blinded_aquatic.csv, output_file=oxygen_fc_mean.csv`
4. Since we won't invoke anything after this function, we can leave "Next Actions to Invoke" blank.
5. For "Repository/Path": input `FaaSr/FaaSr-tutorial/neon4cast_faasr`
6. For "Dependencies - Github Package for the function": tidyverts/tsibble, eco4cast/neon4cast,
7. For "Dependencies - Repository/Path for the function": neon4cast, tidyverse, tsibble, fable.
8. Click Apply

Now that we have our function, we can connect it to our workflow by invoking it after getData function.

1. Click on getData function in the workflow section.
2. In "Next Actions to Invoke" section, add `oxygenForecastMean` to the list.
3. Click apply

You should see an arrow from getData function to oxygenForecastMean, which indicates you have successfully established oxygenForecastMean that is also invoked after GetData completes execution.



### temperatureForecastMean

Now, try to follow the instructions below to create your own function and register it.

1. Create a function for forecasting temperature with the new method.
   a. Create an R script and paste the code from `create_temperature_forecast_rw.R`. Then, replace model(benchmark_rw = RW(temperature)) with `model(benchmark_mean = MEAN(temperature))`.
   b. Modify variables, function names, and file names.
   c. Save the file and push it to your own repository. **Notice that you will need to create a github repository in order to host this function.**
2. Register the newly created function in the workflow through FaaSr JSON builder.
   
   a. Head over to the shiny app and select the "Functions" tab.
   
   b. Fill in the fields:
      - **Action name**: The name that represents your function on the workflow.
      - **Function name**: This field should match the name of the function you just created in step 1.
      - **Function FaaS Server**: Keep as default for this tutorial.
      - **Function arguments**: The arguments needed for your function.
      - **Next Actions to Invoke**: Since we won't invoke any other function now, keep it blank.
      - **Repository/Path**: Where your function file is located, which should be "your_github_username/your_repo_name". 
      - **Dependencies-Github Package**: "tidyverts/tsibble, eco4cast/neon4cast"
      - **Dependencies-Repository/Path**: "neon4cast, tidyverse, tsibble, fable"
        
   c. Click "Apply" to add the function to the workflow.
   
   d. In getData's "Next Actions to Invoke", add the action name and click apply to save.
4. Now, download the workflow file by clicking on the download button in the top right of the app, and upload it to your Posit cloud environment using upload button under the "Files" tab. Make sure the target directory is the one you are working on and upload the JSON workflow file. 
5. Enter the following commands to your console (remember to replace "your_workflow_name" with your actual file name):

```
neon4cast_tutorial<- faasr(json_path="your_workflow_name.json", env="faasr_env")
neon4cast_tutorial$register_workflow()
```

When prompted, select "public" to create a public repository. Now run the workflow:

```
neon4cast_tutorial$invoke_workflow()
```

## Check if action is successful

Just like in the previous part, you can browse your faasr bucket in the Console at https://play.min.io:9443 or use mc_ls command to see if the forecasts are created


# Part IV: Challenge - Create a Combine Function for the Mean Method

Now that you've built individual forecast functions using the mean method, your challenge is to create a new function to combine these forecasts.

**Steps to Complete the Challenge**
1. Create a new R script for combining the forecasts, similar to how forecasts were combined in Part I.
2. Modify your FaaSr workflow to include this new function:
   - Name it `combineForecastMean`.
   - Modify your function to merge the mean method forecast files into a single dataset.
3. Register and deploy your updated workflow
   - Add `combineForecastMean` to you JSON workflow.
   - Connect it to `oxygenForecastMean` and `temperatureForecastMean`.
   - Deploy using the same FaaSr commands as before.
4. Check Github Actions to confirm successful execution.

Here is the JSON snippet:

![image](https://github.com/user-attachments/assets/9639d723-9948-45ec-8100-5ab249e2df08)


Good luck, and have fun building your forecasting pipeline!



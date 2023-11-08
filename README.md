# Terraform Cloud API Workflow

1. Create Workspace

2. Tie the Workspace to a repo

3. Assign a variable set to the Workspace (for cloud credentials)

4. Create variables specific to the run

5. Trigger a run

# Executing the Workflow

1. Set the TOKEN, which can be obtained by clicking User Settings -> Token and clicking "Creating an API Token"

```
export TOKEN=<Terraform Token>
```

2. Set the GITHUB APP ID, which can be obtained by clicking User Settings -> Token and then copying a token that connect your Organzation to the Version Control System (VCS)

```
export GITHUB_APP_ID=<GITHUB APP ID>
```
The create script within this repo will trigger this workflow by giving it some
parameters

```
./create.sh <organization name> <workspace to create> <vcs repo> <variable set id>
```

Here's an example of how to use it
```
./create.sh mack-demo test11-demo dOpensource/dsiprouter-terraform varset-w4DJSHoHri647d3t
```

Note, the variable set id can be found in the URL of the Variable Set Page in Terraform Cloud.  You can access it by clicking Organization Settings -> Variable Sets -> Select your specify Variable Set.  You will see the variable set at the end of the URL in the browser.  It will start with "varset"

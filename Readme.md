# ABD Dev Experience -- Terraform Environment

This repo is to provide a consistent interface to Azure in order to allocate
and configure VM resources.

## How to Store Your Azure Credentials

Open a terminal to the dev container specified by DevEnv.Dockerfile. This container
has an environment variable that the azure commandline will use to get access to the
azure login service (REQUESTS_CA_BUNDLE). Run the following command to login with
your CTC azure credentials:

`az login --use-device-code`

Select the "id" value from the subscriptions your account has access to from the json
list of dictionaries returned from the login commend.

If you cleared your screen and need to re-output that list, run:

`az account list`

Once you have the id, set that as the default subscription you are going to use for
the terraform operations:

`az account set --subscription="<SUBCSCRIPTION_ID_HERE>"`
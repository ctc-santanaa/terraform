# ABD Dev Experience -- Terraform Environment

This repo is to provide a consistent interface to Azure in order to allocate
and configure VM resources.

## How to Store Your Azure Credentials

Open a terminal to the dev container specified by DevEnv.Dockerfile. This container
has an environment variable that the azure commandline will use to get access to the
azure login service (REQUESTS_CA_BUNDLE). Run the following command to login with
your CTC azure credentials:

`az login --use-device-code`

Now you need to initialize terraform in your environment in order to plan or apply
and terraform changes.

`terraform init`

The bottom-line-innovations-rg was already created for us by the DSE team. We
need to import it to match our terraform file.

`terraform import azurerm_resource_group.abd-de-rg /subscriptions/378079de-70e6-423f-bf1a-93947a02ee38/resourceGroups/bottom-line-innovations-rg`

At this point, you can now run terraform plan. It will look for .tf files in the
current directory, merge them, and then try to operate on the merged file.

`terraform plan`

You can look at the output and decide if you want to deploy the changes.

`terraform apply`
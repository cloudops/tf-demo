Demo Automation
===============

Prerequisites
-------------

1. Download Terraform binary and add it to your `PATH`.
2. Install CCA plugin in the Terraform plugin directory (https://github.com/cloud-ca/terraform-provider-cloudca/releases).
  - On Windows, in the sub-path `terraform.d/plugins` beneath your user's `Application Data` directory.
  - On all other systems, in the sub-path `.terraform.d/plugins` in your user's `HOME` directory.


Usage
-----

In the `variables.tf` file there is a lot of customizable options.  I have attempted to set defaults for the majority of the values, however, there are a few options which will need to be confirmed/changed.

- `api_key` - The cloud.ca API key for a user in the desired organization.
- `organization` - The cloud.ca organization name to deploy the environment in.
- `username` - The linux user on the VM (unlikely to need to change).
- `admin_role` - The cloud.ca user(s) who will be admins for the created cca environment.
- `tf_ui_password` - The `admin` password in the Tungsten Fabric Web UI.
- `tf_repo` - The TF repository to use for the deployment (eg: `docker.io/opencontrailnightly` or `docker.io/tungstenfabric`).
- `tf_release` - The build or release of TF which should be deployed (default: `latest`).

There are additional variables to be aware of, but they mainly relate to the `zone` and the `compute_offering` to use as well as `master_vcpu_count`, `master_ram_in_mb`, `worker_vcpu_count`, `worker_ram_in_mb` and more.  The defaults are likely fine for initial use/testing...

Once the variables have been defined, you will need to actually do a deploy.

```bash
$ terraform init
$ terraform workspace new <env_name>
$ export TF_VAR_api_key=<your_api_key>
$ terraform plan
$ terraform apply
```


Assets
------

In order to simplify the ability for the same automation to control multiple environments, the `terraform workspace` feature is used.  This means that all of the assets, such as the `id_rsa` and `id_rsa.pub` files are located under `./terraform.tfstate.d/<env_name>/`.


Fixing Problems
---------------

It is possible that you find a problem with a deployed setup after it has been deployed.  If this happens, follow these steps.

- In the cloud.ca UI, delete the problem VM.
- Rerun the terraform automation to replace the associated assets.

```bash
$ terraform workspace select <env_name>
$ terraform plan
$ terraform apply
```

Doing this will redeploy the VM and reconfigure the associated assets.
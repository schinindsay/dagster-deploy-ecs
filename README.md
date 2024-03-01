# deploy-dagster-ecs-tf

- Description:
    - This project provides insfrastructure to build and deploy the example deploy-ecs project provided by dagster.io here: https://github.com/dagster-io/dagster/tree/master/examples/deploy_ecs

    - The dagster module located in infra/modules/dagster builds the following resources:
        - cloudwatch log group for dagster
        - ecr repositories with attached policies for the 3 dagster services (webserver, user_code, and daemon)
        - iam task and task_execution roles for all ecs services
        - security group for dagster
        - service discovery namespace
        - ecs cluster
        - ecs services for the 3 dagster services
        - ecs tasks for the 3 dagster services

    - The dagster module is dependent on a vpc and rds instance, which are terraformed and provisioned in infra/db.tf and infra/vpc.tf


## run dagster locally with docker:

```bash
cd code
cp .env.example .env
docker compose build
docker compose up
```

## deploy on aws
 - if you need do not need to provision a new vpc or new rds instance comment out or remove infra/db.tf and infra/vpc.tf

 - update locals blocks in:
    - infra/dagster.tf
    - infra/db.tf
    - infra/vpc.tf

```bash
cd infra
terraform init
terraform apply

# once the ecr repositories are created, you can tag and push your code.  You might have to restart the services in ecs after you do this.  (needs to be fixed to update automatically)
```




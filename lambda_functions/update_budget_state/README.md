# Update Budget State - Lambda

> Updates the `S3` file that stores the **Budget State**

Deployed as `ZIP` in `AWS Lambda`.

```mermaid
sequenceDiagram
    participant Client as Client
    participant Lambda as Lambda
    participant S3 as S3 Budget State

    Client ->> Lambda: HTTP Request
    activate Lambda
    Lambda ->> S3: Update State
    deactivate Lambda
    activate S3

    S3 ->> Lambda: Status: ok
    deactivate S3

    activate Lambda
    Lambda ->> Client: Budget Update OK
    deactivate Lambda
```

## Build Process

**TLDR: Build Deployable** `ZIP file`:
```sh
rm lambda_functions/update_budget_state/update_budget_state.zip
./scripts/build-lambda-zip.sh -r ./lambda_functions/update_budget_state/ -p python3.11 -h update_budget_state.py
```

## How-to: Deploy new version, with `ZIP`
```sh
rm lambda_functions/update_budget_state/update_budget_state.zip

./scripts/build-lambda-zip.sh -r ./lambda_functions/update_budget_state/ -p python3.11 -h update_budget_state.py

cd terraform

# let terraform upload the zip file produced, by state transitioning
terraform plan --var-file env_dev.tfvars -out tfplan

terraform apply tfplan
```

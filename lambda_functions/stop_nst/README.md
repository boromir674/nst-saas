# Stop NST Lambda

> Stops the NST Elastic Container Service

Deployed as `ZIP` in `AWS Lambda`.

```mermaid
sequenceDiagram
    participant Client as Client
    participant Lambda as Lambda
    participant NST as NST Service

    activate NST

    Client ->> Lambda: HTTP Event

    activate Lambda
    Lambda ->> NST: Stop Task
    deactivate Lambda

    NST ->> Lambda: Status: stoped

    deactivate NST
    activate Lambda
    Lambda ->> Client: HTTP Response
    deactivate Lambda
```

## Build Process

**TLDR: Build Deployable** `ZIP file`:
```sh
rm lambda_functions/stop_nst/stop_nst.zip
./scripts/build-lambda-zip.sh -r ./lambda_functions/stop_nst/ -p python3.11 -h stop_nst.py
```

## How-to: Deploy new version, with `ZIP`
```sh
rm lambda_functions/stop_nst/stop_nst.zip

./scripts/build-lambda-zip.sh -r ./lambda_functions/stop_nst/ -p python3.11 -h stop_nst.py

cd terraform

# let terraform upload the zip file produced, by state transitioning
terraform plan --var-file env_dev.tfvars -out tfplan

terraform apply tfplan
```

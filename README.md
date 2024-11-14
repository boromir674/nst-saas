# Neural Style Transfer - System

## Components

- **CDN**, Cloudfront/S3/Route53
- **Web UI** (aka Client), written with `React`, built with `Gatsby`, deployed in S3
- **NST Handler**, possibly deployed in AWS Lambda
  - Able to check if `nst budget` is depleted or not
  - nst budget is a certain quota in AWS to prevent charges from increasing too much
  - assumption is that both AWS Fargate and AWS App Runner provide this functionality
- **URL Provider**, a Lambda function to generate `Pre-signed URLs with Access Permissions`
  - generates `Pre-signed URLs with Access Permissions` on invocation
  - Infrastructure as Code for `AWS Lambda`: see [terraform/modules/aws_lambda](./terraform/modules/aws_lambda/) and [terraform/main.tf](./terraform/main.tf)
  - [Lambda Function](./lambda_url_provider/) deployed as `ZIP` to minimize cost (no deployment as `Container`, since no OS modifications or complex dependencies are required)
- **Web API**, written with `Python` and `FastAPI`, deployed in AWS Fargate or AWS App Runner
  - **REST** or **RPC**
  - Runs CPU-bound NST algorithm
- **Image Cloud Storage** for Client File Uploads
  - Infrastructure as Code for `AWS S3 Bucket` in [terraform/modules/s3_bucket](./terraform/modules/s3_bucket/)

> Manage Infra via [terraform/main.tf](./terraform/main.tf)

## Actors

- `User`: an anonymous user


## User flow

1. User Visits website at nst-art.org and CDN serves static html/js/css site
2. Web UI is rendered in browser
3. User Loads `Content` Image
4. User Loads `Style` Image
5. User Selects `Algorithm parameters`
6. User Clicks the `Run` button
   1. A message is dispatched to **NST Handler** and decides
      1. If `nst budget` is not depleted
         2. Then it sends a response to Web UI so `UI update A` should indicate to User that NST algo is triggering
         3. Should call the Web API to actually run the CPU-bound NST Algo
            1. File upload should happen (either from Client or Lambda, not sure yet)
         4. The Web API (or possibly another components?) should be able to stream algo updates to the Client
         5. UI should then be able to update its content on regular step/interval with NST algo updates (ie number of epoch)
   2. If `nst budget` is depleted
      1. Then **NST Handler** sends a response to Web UI, so that `UI update B` should indicate to User that "unfortunately there is no budget"


> If NST was triggered and the algo was started then:

Then we would like ideally to stream an image to the Client too. NST stands for Neural Style Transfer, so we want to stream the so-called `Generated Image`. We can try websockets.

If streaming is not possible or for a quicker PoC we should just "send" the image once, when the algorithm epochs stop.


```mermaid
sequenceDiagram
    actor User
    participant WebUI as Web Client
    participant APIGateway as API Gateway
    participant StepFunction as Step Function (Budget + URL Gen)
    participant BudgetCheckLambda as Budget Check Lambda
    participant URLGenLambda as URL Generator Lambda
    participant S3 as Amazon S3
    participant WebAPI as Web API (FastAPI on Fargate)
    participant NSTWorker as NST Worker

    User->>WebUI: Access nst-art.org

    WebUI->>User: Render Web UI
    User->>WebUI: Load Content & Style Images
    WebUI->>APIGateway: Request Budget Check (via Step Function)

    APIGateway->>StepFunction: Start Step Function Workflow
    StepFunction->>BudgetCheckLambda: Invoke Budget Check Lambda
    BudgetCheckLambda->>BudgetCheckLambda: Verify Budget in DynamoDB
    alt Budget Available
        BudgetCheckLambda->>StepFunction: Budget Approved
        StepFunction->>URLGenLambda: Invoke Pre-signed URL Lambda
        URLGenLambda->>S3: Request Pre-signed URL 
        S3->>URLGenLambda: URL with Access Permissions
        URLGenLambda->>StepFunction: Send Pre-signed URL to Step Function
        StepFunction->>WebUI: Return Pre-signed URL to Client

        WebUI->>S3: Upload Images Directly to S3 (via Pre-signed URL)
        S3->>WebUI: Confirm Image Upload

        WebUI->>APIGateway: Trigger NST Algo (via /run-nst)
        APIGateway->>WebAPI: Start NST Algorithm with S3 URLs
        WebAPI->>NSTWorker: Process NST Algorithm in Worker

        loop Stream NST Progress
            NSTWorker->>WebAPI: Stream Progress Updates
            WebAPI->>WebUI: Send NST Progress to Client
            WebUI->>User: Update Progress in UI
        end

        NSTWorker->>WebAPI: Complete NST Processing (Final Image)
        WebAPI->>WebUI: Send Final Image
        WebUI->>User: Display Styled Image
    else Budget Depleted
        BudgetCheckLambda->>StepFunction: Notify Budget Depletion
        StepFunction->>WebUI: Return "No Budget" Message
        WebUI->>User: Show "No Budget" Notification
    end
```

```mermaid
flowchart TB
    %% Client Layer
    subgraph ClientLayer [Client Layer]
        User["User (Client)"]
        WebUI["Web UI (React)"]
    end

    %% Edge Layer
    subgraph EdgeLayer [Edge Layer]
        CDN["CDN (Cloudfront + S3)"]
        APIGateway["API Gateway"]
    end

    %% Application Layer
    subgraph ApplicationLayer [Application Layer]
        StepFunction["NST Handler (Step Function)"]
        
        subgraph LambdaFunctions [Lambdas for NST Workflow]
            CheckBudgetLambda["Check Budget Lambda"]
            StartNSTLambda["Start NST Lambda"]
            MonitorNSTLambda["Monitor NST Lambda"]
            StopNSTLambda["Stop NST Lambda"]
        end

        WebAPI["Web API (FastAPI)"]
        Fargate["Fargate NST Processing"]
    end

    %% Data Storage Layer
    subgraph DataStorageLayer [Data Storage Layer]
        S3["S3 Bucket for Images"]
        DynamoDB["DynamoDB for Budget Tracking"]
    end

    %% Connections
    User -->|Interacts with| WebUI
    WebUI -->|Requests NST| APIGateway
    APIGateway -->|Triggers Workflow| StepFunction
    StepFunction --> CheckBudgetLambda
    StepFunction --> StartNSTLambda
    StepFunction --> MonitorNSTLambda
    StepFunction --> StopNSTLambda
    StartNSTLambda -->|Launch NST Task| Fargate
    Fargate -->|Process Images| S3
    MonitorNSTLambda -->|Check Status| DynamoDB
    Fargate -->|Store Results| S3
    S3 -->|Retrieve Results| WebUI


```
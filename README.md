# Neural Style Transfer - System

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/boromir674/nst-saas/cicd.yml?branch=main&label=CI%2FCD&link=https%3A%2F%2Fgithub.com%2Fboromir674%2Fnst-saas%2Factions)

## High-level Architecture
> Infrastructure overview

This Block Diagram visualizes all the AWS Resources involved in the `NST System` and groups them:

- <span style="color:#696;">EDGE</span>: All internet (client) requests, arrive here first
  - **CDN** acting as Edge (File) Server of the Static Website
  - **API** acting as Gateway to Client HTTP requests
- <span style="color:#03a1fc;">APPLICATION</span>: Serverless Compute
  - **Orchestrator** modeling the App's Logic, with a State Machine, and triggering Lambdas
  - 5 **Lambda Functions**, (aka serverless) for handling events within the system, with auto-scaling
  - **NST Service** (Elastic Container Service) running the NST Algorithm, deployed in AWS Fargate
- <span style="color:#6f03fc;">STORAGE</span>: Website, App File Storage
  - **NST Storage**, as Bucket in S3, for Images Uploads/Downloads
  - **Website**, as Bucket in S3, for hosting the (SSR) Static website files (HTML/CSS/JS)
  - **NST Badget**, as Bucket in S3, for tracking the remaining badget

> Manage Infra via [terraform/main.tf](./terraform/main.tf)
 
```mermaid
block-beta

columns 5

%% EDGE LAYER - group taking up whole row
  block:EDGE
    columns 1
    CDN["CDN:
    Cloudfront Distrinution"]
    API["API:
    API Gateway"]
  end

%% APP LAYER - group taking up whole row
  block:APP:1
    columns 1
    block:LAMBDA
      columns 1
      read_badget["Read Budget: Lambda"]
      get_url["Get Upload URL: Lambda"]
      update_budget["Update Badget: Lambda"]
      start_nst["Start NST: Lambda"]
      stop_nst["Stop NST: Lambda"]
    end
    step["Orchestrator:
    Step Function"]
    nst["NST:
    Elastic Container Service"]
  end

%% V1
%% EDGE --> APP
%% APP --> EDGE
%% V2
%% leftright<["&nbsp;&nbsp;&nbsp;"]>(x, right)

%% STORAGE LAYER - group taking up whole row
  block:S3:1
    columns 1
    storage["NST Storage:
    S3 Bucket"]
    state["Budget State:
    S3 Bucket"]
    web["Website:
    S3 Bucket"]
  end

style EDGE fill:#696;
style APP fill:#03a1fc;
style S3 fill:#6f03fc;

```

## Actors

- `User`: an anonymous user

## User Flows

### Access Web Client

> Visit nst-art.org in your browser.

```mermaid
flowchart LR

Browser@{ shape: circle, label: "Browser" }
Browser -. "`1: visit nst-art.org`".-> DNS
DNS -. 2: IP.-> Browser

Browser == 3: IP==> CDN

subgraph EdgeServer [Edge Server, close to User]
serve_cache[["Serve Files from cache"]]
update_cache[["Update Edge cache"]]
cache_hit{"cache hit"?}
end

CDN --> cache_hit
cache_hit -- yes--> serve_cache

cache_hit -- no --> s3_bucket

s3_bucket@{ shape: lin-cyl, label: "Website: S3 Bucket" }
%% s3_bucket[["Website: S3 Bucket"]]

s3_bucket -- Get Static Files--> update_cache
update_cache --> serve_cache
serve_cache == Static HTML/CSS/JS==> Browser
```
### Upload Image
```mermaid
flowchart TB

    WebUI(("Web Client/UI (React)"))

    %% Edge Layer
    subgraph EdgeLayer [Edge Layer, Serverless]
        APIGateway["API Gateway"]
    end

    %% Application Layer
    subgraph ApplicationLayer [Application Layer]

        subgraph LambdaFunctions [Serverless Lambda]
            ProvideURL["Provide Upload URL"]
        end

    end

    %% Data Storage Layer
    subgraph DataStorageLayer [Data Storage Layer]
        S3["NST Storage: S3 Bucket"]
    end

    %% Connections
    WebUI -->|1: Request Upload URL| APIGateway
    APIGateway --> ProvideURL
    ProvideURL --> S3
    APIGateway --> WebUI
    S3 -->|Pre-signed Upload URL| ProvideURL
    ProvideURL --> APIGateway
    WebUI -->|2: Upload Image| S3

```

### End to End 

1. User Visits website at nst-art.org and CDN serves static html/js/css site
2. Web UI is rendered in browser
3. User Loads `Content` Image
4. User Loads `Style` Image
5. User Selects `Algorithm parameters`
6. User Clicks the `Run` button

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
    WebUI["Web Client/UI (React)"]

    %% Edge Layer
    subgraph EdgeLayer [Edge Layer]
        CDN["CDN (Cloudfront + S3)"]
        APIGateway["API Gateway"]
    end

    %% Application Layer
    subgraph ApplicationLayer [Application Layer]
        StepFunction["NST Handler (Step Function)"]
        
        subgraph LambdaFunctions [Lambdas for NST Workflow]
            CheckBudgetLambda["Read Budget Lambda"]
            UpdateBudgetLambda["Update Budget Lambda"]
            StartNSTLambda["Start NST Lambda"]
            StopNSTLambda["Stop NST Lambda"]
        end
        RequestURL["Request URL Lambda"]

        Fargate["Fargate NST Processing"]
    end

    %% Data Storage Layer
    subgraph DataStorageLayer [Data Storage Layer]
        S3["S3 Bucket for Images"]
        Budget_state["S3 Bucket for Budget State"]
    end

    %% Connections
    WebUI -->|Requests NST| APIGateway
    APIGateway -->|Triggers Workflow| StepFunction
    APIGateway --> RequestURL
    RequestURL --> S3
    StepFunction --> CheckBudgetLambda
    StepFunction --> StartNSTLambda
    StepFunction --> StopNSTLambda
    StartNSTLambda -->|Launch NST Task| Fargate
    Fargate -->|Process Images| S3
    Fargate -->|Store Results| S3
    S3 -->|Retrieve Results| WebUI


```

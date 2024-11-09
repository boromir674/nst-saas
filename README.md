# Neural Style Transfer - System

## Components

- **CDN**, Cloudfront/S3/Route53
- **Web UI** (aka Client), written with `React`, built with `Gatsby`, deployed in S3
- **NST Handler**, possibly deployed in AWS Lambda
  - Able to check if `nst budget` is depleted or not
  - nst budget is a certain quota in AWS to prevent charges from increasing too much
  - assumption is that both AWS Fargate and AWS App Runner provide this functionality
- **Web API**, written with `Python` and `FastAPI`, deployed in AWS Fargate or AWS App Runner
  - **REST** or **RPC**
  - Runs CPU-bound NST algorithm

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

flowchart TB

    C["Web UI"]
    C --Run Algorithm --> F["NST Handler (AWS Lambda/Step Function)"]
    F --> G{"NST Budget Available?"}
    
    G -- Yes --> H["Upload Images to S3 (Content and Style Images)"]
    H --> I["Trigger Web API for NST Algo"]
    I --> J["Web API (FastAPI, Fargate/App Runner)"]
    J --> K["CPU-bound NST Algorithm (Fargate Worker)"]
    K --> D["UI Update: Stream Algo Progress"]
    K --> D["UI Update: Stream Final Image"]

    G -- No --> D["UI Update: Budget Depleted"]


```

```mermaid
sequenceDiagram
    participant User
    participant WebUI as Web UI (Client)
    participant APIGateway as API Gateway
    participant StepFunction as Step Function (Budget + URL Gen)
    participant BudgetCheckLambda as Budget Check Lambda
    participant URLGenLambda as Generate Pre-signed URL Lambda
    participant S3 as Amazon S3
    participant WebAPI as Web API (FastAPI on Fargate)
    participant NSTWorker as NST Worker (CPU-bound Task on Fargate)

    User->>WebUI: 1. Access nst-art.org
    WebUI->>S3: 2. Load Static Assets (HTML/CSS/JS)
    WebUI->>User: 3. Render Web UI
    User->>WebUI: 4. Load Content & Style Images
    WebUI->>APIGateway: 5. Request Budget Check (via Step Function)

    APIGateway->>StepFunction: 6. Start Step Function Workflow
    StepFunction->>BudgetCheckLambda: 7. Invoke Budget Check Lambda
    BudgetCheckLambda->>BudgetCheckLambda: 8. Verify Budget in DynamoDB
    alt Budget Available
        BudgetCheckLambda->>StepFunction: 9. Budget Approved
        StepFunction->>URLGenLambda: 10. Invoke Pre-signed URL Lambda
        URLGenLambda->>S3: 11. Create Pre-signed URL with Access Permissions
        S3->>URLGenLambda: 12. Return Pre-signed URL
        URLGenLambda->>StepFunction: 13. Send Pre-signed URL to Step Function
        StepFunction->>WebUI: 14. Return Pre-signed URL to Client

        WebUI->>S3: 15. Upload Images Directly to S3 (via Pre-signed URL)
        S3->>WebUI: 16. Confirm Image Upload

        WebUI->>APIGateway: 17. Trigger NST Algo (via /run-nst)
        APIGateway->>WebAPI: 18. Start NST Algorithm with S3 URLs
        WebAPI->>NSTWorker: 19. Process NST Algorithm in Worker

        loop Stream NST Progress
            NSTWorker->>WebAPI: 20. Stream Progress Updates
            WebAPI->>WebUI: 21. Send NST Progress to Client
            WebUI->>User: 22. Update Progress in UI
        end

        NSTWorker->>WebAPI: 23. Complete NST Processing (Final Image)
        WebAPI->>WebUI: 24. Send Final Image
        WebUI->>User: 25. Display Styled Image
    else Budget Depleted
        BudgetCheckLambda->>StepFunction: 9. Notify Budget Depletion
        StepFunction->>WebUI: 10. Return "No Budget" Message
        WebUI->>User: 11. Show "No Budget" Notification
    end
```

# HawkerCare

**Full Stack Engineer Take-Home Assessment (MSF)**

I built HawkerCare in OutSystems Reactive Web to make Singapore hawker centre information easier to browse. The data comes from a public dataset on data.gov.sg. Rather than just displaying a long list, I added search, an owner filter, sorting and pagination.

**Working application:** https://personal-345ipche.outsystemscloud.com/HawkerCare/Home

The demo runs in my OutSystems Cloud environment. It has not been deployed to AWS.

## What the application does

The main screen displays the hawker centre name, location, number of stalls and owner. Users can:

- Search by centre name or location. Search is case-insensitive.
- Filter the results by **All Owners**, **HDB** or **Government**.
- Use search and the owner filter together.
- Clear the search without resetting the selected owner.
- Sort centre names A–Z or Z–A by clicking the table heading.
- Move between pages of 10 records.
- See the number of matching centres and a message when nothing matches.

I also added a loading message and a separate error message for API failures. Login is not needed because this is a public, read-only directory.

At the time of testing, the API returned **107 centres** (82 HDB and 25 Government). These counts are from the data I tested and may change if the source dataset is updated.

## How I built it

I used **OutSystems Service Studio** to build the screen and logic. The `GetHawkerCentres` Data Action calls the consumed REST method `GetDatastoreSearch` to get records from data.gov.sg.

Once the records are fetched, the Home screen keeps the list for the user interactions. `FilterHawkerCentres` handles both name/location search and owner filtering. `BuildPageCentres` sorts the filtered list and takes the records for the current page. This means that sorting happens before pagination, rather than sorting only the 10 visible rows.

The main parts of the module are:

| Part | Purpose |
| --- | --- |
| `GetHawkerCentres` | Retrieve public data through the REST integration |
| `InitializeCentres` | Prepare the list after the fetch |
| `FilterHawkerCentres` | Apply search and owner conditions |
| `BuildPageCentres` | Sort and build the current page |
| `ToggleSortName` | Switch between A–Z and Z–A |
| `ClearSearch` | Clear the text and reapply the owner filter |
| `HasApiError` / `If_ApiError` | Display a separate message when data retrieval fails |
| `If_Loading` | Display feedback while the data is being fetched |

The screen calls the backend REST integration once to retrieve the dataset and handles these list interactions in the application. For this small dataset, this kept the implementation straightforward. For a much larger dataset, I would review server-side filtering, sorting and pagination instead.

## Running HawkerCare

**Option 1: Open the published demo**

Open the [HawkerCare application](https://personal-345ipche.outsystemscloud.com/HawkerCare/Home) in a browser. The main screen is public and does not require login.

**Option 2: Review the OutSystems module**

The `outsystems/` folder contains the exported `.oml` module. To review or publish the module:

1. Open the `.oml` in a compatible OutSystems Service Studio version.
2. Connect to an OutSystems environment where you have permission to publish.
3. Check the referenced dependencies and data.gov.sg REST configuration.
4. Publish the module and open its Home screen.

I developed the app using Service Studio on Windows, but the running application is hosted in OutSystems Cloud. It is **not a standalone app that starts locally with `npm` or `dotnet`**. Running an imported `.oml` requires a suitable OutSystems environment.

## API errors and recovery

The Data Action has an `AllExceptions` handler that sets `HasApiError = True` if an exception is raised. The Home screen then shows a friendly error message rather than the results table. An ordinary search with no matches uses a different message.

I checked this with a controlled `TestApiFailure` exception in Service Studio. The error message appeared, and after switching back to the normal API path, the hawker centre list loaded again. This was a **simulated failure**, not an actual data.gov.sg outage. The published demo should be left on the normal API path.

## Automated tests

I used **Playwright with TypeScript and Chromium** to test the published application from a browser. The test file is `tests/tests/hawkerCare.spec.ts`.

| Test | What it checks |
| --- | --- |
| TC01 | Hawker centres load and display |
| TC02 | Search by location |
| TC03 | HDB owner filter |
| TC04 | Search and owner filter together |
| TC05 | No-results message |
| TC06 | Clear search keeps the owner selection |
| TC07 | Pagination moves to the next 10 records |
| TC08 | Name sorting A–Z and Z–A |

**Latest verified result: 8 passed, 0 failed (24 October 2026).** I reran the suite after the API error test and recovery. The screenshots and saved report are included as evidence where available.

To run the tests on Windows, open PowerShell in the repository's `tests` folder and run:

```powershell
npm.cmd ci
npx.cmd playwright install chromium
npx.cmd playwright test tests/hawkerCare.spec.ts --project=chromium --reporter=list
```

To generate or open the HTML report:

```powershell
npx.cmd playwright test tests/hawkerCare.spec.ts --project=chromium --reporter=html
npx.cmd playwright show-report
```

These are browser tests against the hosted demo, so they need an internet connection and the OutSystems environment to be available. Some assertions check the counts seen during development, such as 107 total records and 82 HDB records. If the public dataset changes, those expectations may need updating.

## AWS infrastructure design

I prepared the AWS infrastructure definition separately using **Terraform**. The configuration uses the Singapore region (`ap-southeast-1`) and includes:

- A VPC, public and private subnets, routing, Internet Gateway and NAT Gateways.
- An Application Load Balancer and target group.
- Two Windows EC2 instances in private application subnets.
- A private Amazon RDS SQL Server database.
- Security groups, an IAM role for Systems Manager and CloudWatch alarms.

The `terraform/` directory contains the `.tf` source files, including `main.tf`, `variables.tf`, `network.tf`, `security.tf`, `compute.tf`, `loadbalancer.tf`, `database.tf`, `monitoring.tf` and `outputs.tf`.

I ran `terraform fmt` and `terraform validate`; Terraform reported **"Success! The configuration is valid."** To repeat the configuration checks, run this from `terraform/`:

```powershell
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
```

**I did not run `terraform apply` or deploy resources to AWS.** The assessment does not require an AWS deployment. This is an infrastructure reference design, not a completed OutSystems platform installation. A real deployment would need the appropriate OutSystems licensing, platform installation and configuration, a LifeTime environment, certificates/HTTPS, production security and operational checks. The sample load balancer currently uses HTTP and is not intended to be a production security configuration.

## Repository layout

```text
HawkerCare-Submission/
├── outsystems/
│   └── HawkerCare_Final.oml            # Latest exported module
├── terraform/
│   └── *.tf                           # AWS infrastructure definition
├── tests/
│   ├── tests/hawkerCare.spec.ts       # Playwright test cases
│   ├── playwright.config.ts
│   ├── package.json
│   ├── package-lock.json
│   └── playwright-report/             # HTML report, if included
├── docs/                              # Screenshots and test evidence
└── README.md
```

The `.oml` filename in the example above should match the actual exported file. Terraform state, credentials, `.terraform/` and Playwright `node_modules/` should not be committed to the repository.

## Notes and limitations

- HawkerCare is a read-only application. It does not edit the government dataset.
- The running demo depends on OutSystems Cloud and the data.gov.sg API being available.
- The application is hosted on OutSystems Cloud rather than being a standalone local executable.
- The AWS Terraform configuration is validated, but AWS deployment and OutSystems platform installation have not been tested.
- API failure handling was verified with a controlled exception, not a live API outage.
- Counts in the automated tests can change when the public dataset is updated.

I kept the application small enough to explain and demonstrate clearly, while covering the data integration, user interactions, error handling, AWS infrastructure design and automated testing parts of the assessment.

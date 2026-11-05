# Run the app locally

Open `Rcheology.Rproj` in RStudio, then either open `app/app.R` and click
**Run App**, or run this from the Console:

```r
shiny::runApp("app")
```

The app uses `shiny`, `bslib`, `DT`, and `dplyr`.

# Deployment

The app is hosted on [Posit Connect Cloud](https://hughjonesd-rcheology.share.connect.posit.cloud/).
Its content ID is `01a1a703-dd79-d72a-b895-55649380249f` in account
`hughjonesd`. Deploy to this ID to update the migrated app rather than create
a second copy.

The daily GitHub workflow builds the app data, then deploys it in a separate
job using R 4.6.1, matching the working Connect Cloud runtime. R versions used
for snapshot extraction and package building are independent of this pin.

Automated deployment requires the repository Actions secrets
`CONNECT_CLOUD_CLIENT_ID` and `CONNECT_CLOUD_CLIENT_SECRET`, created from
[Posit client credentials](https://login.posit.cloud/identity/credentials).
These credentials grant full account access; never commit them.

After finalizing the migration, keep the archived shinyapps.io application:
deleting it would remove the redirect from the old URL.

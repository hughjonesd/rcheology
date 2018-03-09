
container <- readline("Enter the name of the container: ")
system2("docker", c("cp", paste0(container, ":", "/rcheology/shared-data/."), "shared-data"))
  
result <- list.files(pattern="*.csv", path = "shared-data", full.names = TRUE) %>% 
      purrr::map_df(~readr::read_csv(., na="n/a", 
            col_types = readr::cols(S3method="c", generic="c")
            ))
readr::write_csv(result, path = "pkg_data_all.csv")

result <- as.data.frame(result)
usethis::use_data(result)


container <- readline("Enter the name of the container: ")
system2("docker", c("cp", paste0(container, ":", "/rcheology/docker-data/."), "docker-data"))
  
rcheology <- list.files(pattern="*.csv", path = "shared-data", full.names = TRUE) %>% 
      purrr::map_df(~readr::read_csv(., na="n/a", 
            col_types = readr::cols(S3method="c", generic="c")
            ))

rcheology <- as.data.frame(rcheology)
usethis::use_data(rcheology, overwrite = TRUE)

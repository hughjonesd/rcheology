
container <- readline("Enter the name of the container: ")
system2("docker", c("cp", paste0(container, ":", "/rcheology/docker-data/."), "docker-data"))
  
rcheology <- list.files(pattern="*.csv", path = "docker-data", full.names = TRUE) %>% 
      purrr::map_df(~readr::read_csv(.)) 

rcheology <- as.data.frame(rcheology)
usethis::use_data(rcheology, overwrite = TRUE)


# start system
image <- "rcheology"
system2("docker", c("build", "-t", image, "."))
container <- "rcheo_container"
system2("docker", c("run", "--name", container, image))


# get data
file.remove(list.files("docker-data", full.names = TRUE))
system2("docker", c("cp", paste0(container, ":", "/rcheology/docker-data/."), "docker-data"))
  
rcheology <- list.files(pattern="*.csv", path = "docker-data", full.names = TRUE) %>% 
      purrr::map_df(~readr::read_csv(.)) 

rcheology <- as.data.frame(rcheology)
dim(rcheology)
head(rcheology)
usethis::use_data(rcheology, overwrite = TRUE)

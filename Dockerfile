ARG baseimage=latest
FROM bioconductor/bioconductor_docker:$baseimage

WORKDIR /home/rstudio

COPY --chown=rstudio:rstudio . /home/rstudio/

RUN sh -c "Rscript -e \"options(repos = c(CRAN = 'https://cran.r-project.org')); BiocManager::install(ask=FALSE)\" && Rscript -e \"options(repos = c(CRAN = 'https://cran.r-project.org')); devtools::install('.', dependencies=TRUE, build_vignettes=TRUE, repos = BiocManager::repositories())\" "

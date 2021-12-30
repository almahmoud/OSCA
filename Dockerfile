ARG baseimage=latest
FROM bioconductor/bioconductor_docker:$baseimage

WORKDIR /home/rstudio

COPY --chown=rstudio:rstudio . /home/rstudio/

RUN Rscript -e "BiocManager::install(remotes::local_package_deps(dependencies=TRUE))"


# syntax=docker/dockerfile:latest

FROM rocker/tidyverse:latest

RUN R -e "install.packages('renv')"

# COPY renv.lock renv.lock
# RUN mkdir -p renv
# COPY .Rprofile .Rprofile
# COPY renv/activate.R renv/activate.R
# COPY renv/settings.dcf renv/settings.dcf
# ENV RENV_CONFIG_REPOS_OVERRIDE https://packagemanager.rstudio.com/cran/latest
# RUN sudo apt-get update
# RUN sudo apt-get install -y libssl-dev
# RUN R -e 'if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")'
# RUN R -e 'remotes::install_github("mdneuzerling/getsysreqs", force=TRUE)'
# RUN REQS=$(Rscript -e 'options(warn = -1); cat(getsysreqs::get_sysreqs("renv.lock"))' | sed s/"WARNING: ignoring environment value of R_HOME"//) \
#     && echo $REQS && sudo apt-get install -y $REQS

# RUN R -e "renv::restore()"

EXPOSE 8787
ENV PASSWORD password

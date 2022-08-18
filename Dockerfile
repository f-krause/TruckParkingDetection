
######################################
# Docker file for mybinder. Not 
# relevant for average user!
######################################

FROM python:3.9-slim
RUN pip install --no-cache-dir notebook jupyterlab

 
#We need to install some Linux packages
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

WORKDIR ${HOME}

# Make sure the contents of our repo are in ${HOME}
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

#docker run <image> jupyter notebook --NotebookApp.default_url=/lab/ <arguments from the mybinder launcher>



# Copied from: https://blog.ouseful.info/2019/03/24/screengrabs-using-selenium-in-mybinder/ (18.08.2022)

#Use a base Jupyter notebook container
FROM jupyter/base-notebook

#Using Selenium to automate a firefox or chrome browser needs geckodriver in place
ARG GECKO_VAR=v0.31.0
RUN wget https://github.com/mozilla/geckodriver/releases/download/$GECKO_VAR/geckodriver-$GECKO_VAR-linux64.tar.gz
RUN tar -x geckodriver -zf geckodriver-$GECKO_VAR-linux64.tar.gz -O > /geckodriver
RUN chmod +x /geckodriver
RUN rm geckodriver-$GECKO_VAR-linux64.tar.gz
 
#Install packages required to allow us to use eg firefox in a headless way
#https://www.kaggle.com/dierickx3/kaggle-web-scraping-via-headless-firefox-selenium
RUN apt-get update \
    && apt-get install -y libgtk-3-0 libdbus-glib-1-2 xvfb \
    && apt-get install -y firefox \
    && apt-get clean
ENV DISPLAY=":99"
 
#Copy repo files over
COPY ./notebooks ${HOME}/work

#And make sure they are owned by the notebook user...
RUN chown -R ${NB_USER} ${HOME}
 
#Reset the container user back to the notebook user
USER $NB_UID
 
#Install Selenium python package
RUN pip install --no-cache selenium
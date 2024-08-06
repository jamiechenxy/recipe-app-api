# TELL DOCKER THE VERSION OF PYTHON WE WILL USE -- alpine is minified version of Linx
FROM python:3.9-alpine3.13
LABEL maintainer="jamiechenxy"

# TELLS PYTHON TO PRINT ON THE CONSOLE IMMEDIATELY
ENV PYTHONUNBUFFERED 1

# copy requirements.txt, requirements.dev.txt and app directory to Docker
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
# define a working directory on Docker
WORKDIR /app
# define a local port exposed to Docker
EXPOSE 8000

# runs a command on the alpine image that we're using when we're building our image
# default DEV to flase, meaning that not in development by default.
ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    # apk add: alpine package keeper to add(install) a package; 
    # --update: (Deprecated but still seen) Update the package index before installation.
    # --no-cache: avoid saving the downloaded package files to the local cache.
    # --virtual .tmp-build-dev: creates a virtual package named .tmp-build-dev for temporary build dependencies.
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    # the wrapped is shell script/code. Meanning that to install "requirements.dev.txt" if variable DEV is true.
    # "fi" in the end is backwards "if", which is the syntax to end if statement in shell script. 
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    # #
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# PATH variable is automatically generated in Linx system.
# what it does is that whenever we run any Python command, it will run automatically from the virtual environment with the "PATH" set this way.
ENV PATH="/py/bin:$PATH"
# define the user we're switching to if we run something from this Docker file.
USER django-user
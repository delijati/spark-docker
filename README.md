# Spark docker image

This is a spark docker image.

## Usage

Build your image:

    $ docker build . --pull -t spark

Run:

    $ docker run --rm -ti -v `pwd`:/app/work spark bash -c "cd /app/work && python3 test.py 10"

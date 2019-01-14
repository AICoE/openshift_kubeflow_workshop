FROM tensorflow/tensorflow:1.12.0
MAINTAINER "Marcel Hild <mhild@redhat.com>"

RUN mkdir /home/tensorflow

# show python logs as they occur
ENV PYTHONUNBUFFERED=0

# run MNIST.py
ADD MNIST.py /home/tensorflow
ADD model.py /home/tensorflow
WORKDIR /home/tensorflow
ENTRYPOINT /usr/bin/python /home/tensorflow/model.py

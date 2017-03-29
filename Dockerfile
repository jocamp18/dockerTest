# Pull base image.
FROM centos:latest

# Build commands
RUN yum install -y python-setuptools mysql-connector-python mysql-devel gcc python-devel git &&\
easy_install pip &&\
mkdir /opt/projMan
#RUN easy_install pip
#RUN mkdir /opt/projMan
WORKDIR /opt/projMan
ADD . /opt/projMan
RUN pip install -r requirements.txt
ENV DATABASE_URL 'mysql://root:test@db/projman_db'

# Define default command.
#CMD python run.py && /opt/projMan/init.sh
CMD ["python", "run.py"]

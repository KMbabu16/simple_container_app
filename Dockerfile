# Use the Amazon ECR Public Gallery Python 3.9 image as the base image
FROM public.ecr.aws/sam/build-python3.9:latest

# Set up an app directory for your code
COPY . /app
WORKDIR /app

# Install pip and needed Python packages from requirements.txt
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Install additional packages
RUN wget -qO - https://apt.corretto.aws/corretto.key | apt-key add - && \
    echo "deb https://apt.corretto.aws stable main" | tee /etc/apt/sources.list.d/corretto.list && \
    apt-get update && \
    apt-get -y install jq && \
    pip install --upgrade awscli pytest

# Define an entrypoint which will run the main app using the Gunicorn WSGI server
ENTRYPOINT ["gunicorn", "-b", ":8080", "main:APP"]

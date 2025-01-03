# Use the official Python 3.9 image from Amazon ECR Public Gallery for AWS compatibility
FROM public.ecr.aws/sam/build-python3.9:latest

# Set environment variables for Python to run in an unbuffered and optimized mode
ENV PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    APP_HOME=/app

# Set up the application directory
WORKDIR ${APP_HOME}
COPY . ${APP_HOME}

# Add trusted GPG key and configure repository to resolve unsigned error
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl gnupg \
    && curl -fsSL https://apt.corretto.aws/corretto.key | gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list \
    && apt-get update \
    && apt-get -y install jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies from `requirements.txt`
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir --upgrade awscli pytest

# Expose the port for the Gunicorn server
EXPOSE 8080

# Define the Gunicorn entrypoint to run the app
ENTRYPOINT ["gunicorn", "-b", "0.0.0.0:8080", "main:APP"]

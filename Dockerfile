# Use the official Python image from the Docker Hub
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /Application

# Copy the requirements file into the container
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

# Copy the wait-for-it script into the container and make it executable
COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

# Install MySQL client to execute SQL script
RUN apt-get update && apt-get install -y default-mysql-client && rm -rf /var/lib/apt/lists/*

# Use wait-for-it to wait for MySQL to be ready, then run the setup script and Flask app
CMD /wait-for-it.sh mysql:3306 -- mysql -h mysql -u flask_user -pflask_password flask_db < setupDatabase.sql && gunicorn -b 0.0.0.0:$PORT main:app

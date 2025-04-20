FROM python:3.9-slim

# Set the working directory
WORKDIR /workspace

# Copy the requirements file
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the source code
COPY src/ .

# Command to run the application
CMD ["python", "main.py"]
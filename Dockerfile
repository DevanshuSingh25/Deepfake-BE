# # Use Python 3.11 slim base
# FROM python:3.11-slim

# # Set environment variables
# ENV PYTHONDONTWRITEBYTECODE=1
# ENV PYTHONUNBUFFERED=1

# # Set working directory
# WORKDIR /app

# # Install system-level dependencies required for dlib and face-recognition
# RUN apt-get update && apt-get install -y \
#     build-essential \
#     cmake \
#     gcc \
#     g++ \
#     curl \
#     libffi-dev \
#     libssl-dev \
#     libboost-all-dev \
#     libatlas-base-dev \
#     libglib2.0-0 \
#     libxext6 \
#     libsm6 \
#     libxrender1 \
#     python3-dev \
#     git \
#     rustc \
#     cargo \
#  && apt-get clean \
#  && rm -rf /var/lib/apt/lists/*

# # Copy requirements and clean platform-specific ones
# COPY django_application/requirements.txt /app/

# # Remove Windows-only dependencies from requirements
# RUN sed -i '/pywinpty/d' requirements.txt && \
#     sed -i '/pywin32/d' requirements.txt

# # Fix CMake compatibility issue with dlib
# ENV CMAKE_POLICY_DEFAULT_CMP0000=NEW
# ENV CMAKE_POLICY_DEFAULT_CMP0012=NEW
# ENV CMAKE_POLICY_DEFAULT_CMP0074=NEW
# ENV CMAKE_POLICY_DEFAULT_CMP0077=NEW
# ENV CMAKE_POLICY_DEFAULT_CMP0091=NEW
# ENV CMAKE_POLICY_VERSION=3.5

# # Upgrade pip and install Python dependencies
# RUN pip install --upgrade pip && pip install -r requirements.txt

# # Copy the rest of your app
# COPY . /app/

# # Expose Django port
# EXPOSE 8000

# # Run the Django app
# CMD ["python", "django_application/manage.py", "runserver", "0.0.0.0:8000"]


# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Install OS-level dependencies required by dlib, opencv, etc.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    wget \
    curl \
    git \
    ffmpeg \
    libsm6 \
    libxext6 \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libgtk2.0-dev \
    libboost-all-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy requirements first (for better Docker cache)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your application
COPY . .

# Set environment variables (uncomment if needed)
# ENV DJANGO_SETTINGS_MODULE=your_project.settings
# ENV PYTHONUNBUFFERED=1

# Collect static files (optional, for Django)
RUN python manage.py collectstatic --noinput

# Expose port 8000 for Django (adjust as needed)
EXPOSE 8000

# Default command (replace with your actual entry point if not Django)
CMD ["python", "django_application/manage.py", "runserver", "0.0.0.0:8000"]

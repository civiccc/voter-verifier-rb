FROM brigade/ruby:2.5.3-latest

# Copy all source code into the container
# See the .dockerignore file for a list of files that are excluded
COPY . /src

# Modify permissions so application user can access source files
RUN chown -R nobody /src

# Set working directory to the source directory
WORKDIR /src

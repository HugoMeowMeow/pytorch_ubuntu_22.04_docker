FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04
# Remove any third-party apt sources to avoid issues with expiring keys.
RUN rm -f /etc/apt/sources.list.d/*.list

# Install some basic utilities
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
    && rm -rf /var/lib/apt/lists/*

# Create a working directory
RUN mkdir /home/hugo/
WORKDIR /home/hugo

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user \
&& chown -R user:user /home/hugo
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
USER user

# All users can use /home/user as their home directory
ENV HOME=/home/hugo
RUN mkdir $HOME/.cache $HOME/.config \
 && chmod -R 777 $HOME

# Set up the Conda environment (using Miniforge)
ENV PATH=$HOME/mambaforge/bin:$PATH
COPY environment.yml /home/hugo/environment.yml
RUN curl -sLo ~/mambaforge.sh https://github.com/conda-forge/miniforge/releases/download/4.12.0-2/Mambaforge-4.12.0-2-Linux-x86_64.sh \
&& chmod +x ~/mambaforge.sh \
&& ~/mambaforge.sh -b -p ~/mambaforge \
&& rm ~/mambaforge.sh \    
&& mamba env update -n base -f /home/hugo/environment.yml \
&& rm /home/hugo/environment.yml \
&& mamba clean -ya

# Set the default command to python3
CMD ["python3"]

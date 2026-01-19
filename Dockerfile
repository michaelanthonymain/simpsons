FROM debian:bullseye

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    zlib1g-dev \
    libffi-dev \
    libssl-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libyaml-dev \
    wget \
    curl \
    git \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install Ruby 2.6.3 using ruby-build
RUN git clone https://github.com/rbenv/ruby-build.git \
    && PREFIX=/usr/local ./ruby-build/install.sh \
    && RUBY_CONFIGURE_OPTS="--disable-install-doc" ruby-build 2.6.3 /usr/local \
    && rm -rf ruby-build

# Install bundler (compatible with Ruby 2.6.3)
RUN gem install bundler -v 2.4.22

# Install Python 3.7.2 (without PGO for faster build)
RUN wget https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tgz \
    && tar xzf Python-3.7.2.tgz \
    && cd Python-3.7.2 \
    && ./configure \
    && make -j$(nproc) \
    && make altinstall \
    && cd .. \
    && rm -rf Python-3.7.2 Python-3.7.2.tgz

# Create symlink for python
RUN ln -sf /usr/local/bin/python3.7 /usr/local/bin/python

WORKDIR /app

# Copy application files
COPY app/ ./app/
COPY integration_tests/ ./integration_tests/

# Install Ruby dependencies
WORKDIR /app/app
RUN make bundle

# Install Python dependencies
WORKDIR /app/integration_tests
RUN rm -rf env && make env && make deps

WORKDIR /app

# Script to start server and run tests
RUN echo '#!/bin/bash\n\
cd /app/app\n\
make run-production &\n\
sleep 3\n\
cd /app/integration_tests\n\
SIMPSONS_BASE_URL=http://localhost:4567 make test\n\
' > /app/run_tests.sh && chmod +x /app/run_tests.sh

CMD ["/app/run_tests.sh"]

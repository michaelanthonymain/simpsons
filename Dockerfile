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

WORKDIR /app

# Copy application files
COPY app/ ./

# Install Ruby dependencies
RUN make bundle

EXPOSE 4567

CMD ["make", "run-production"]

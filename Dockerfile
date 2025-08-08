FROM ubuntu:24.04

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    gpg \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Add PostgreSQL 17 repository
RUN wget -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt noble-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Add Tarsnap repository (following official docs exactly)
RUN wget https://pkg.tarsnap.com/tarsnap-deb-packaging-key.asc \
  && gpg --dearmor tarsnap-deb-packaging-key.asc \
  && mv tarsnap-deb-packaging-key.asc.gpg tarsnap-archive-keyring.gpg \
  && cp tarsnap-archive-keyring.gpg /usr/share/keyrings/ \
  && rm tarsnap-deb-packaging-key.asc tarsnap-archive-keyring.gpg

RUN echo "deb [signed-by=/usr/share/keyrings/tarsnap-archive-keyring.gpg] http://pkg.tarsnap.com/deb/noble ./" > /etc/apt/sources.list.d/tarsnap.list

# Install packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client-17 \
    tarsnap \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip install --no-cache-dir --break-system-packages tarsnapper awscli

# Copy application files and set ownership
COPY --chown=appuser:appuser . /app
WORKDIR /app

# Switch to non-root user
USER appuser

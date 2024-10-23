FROM postgres:15

# Set enviroment variable
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=mydb
ENV PGDATA=/var/lib/postgresql/data/pgdata

# Create dir for custom initial script
RUN mkdir -p /docker-entrypoint-initdb.d

# Install additional packages if needed
RUN apt-get update && apt-get install -y \
    postgresql-contrib \
    && rm -rf /var/lib/apt/lists/*

# Create PostgreSQL configuration file directly in the image
RUN echo "listen_addresses = '*'" > /etc/postgresql/postgresql.conf && \
    echo "max_connections = 100" >> /etc/postgresql/postgresql.conf && \
    echo "shared_buffers = 128MB" >> /etc/postgresql/postgresql.conf && \
    echo "dynamic_shared_memory_type = posix" >> /etc/postgresql/postgresql.conf && \
    echo "max_wal_size = 1GB" >> /etc/postgresql/postgresql.conf && \
    echo "min_wal_size = 80MB" >> /etc/postgresql/postgresql.conf && \
    echo "log_timezone = 'UTC'" >> /etc/postgresql/postgresql.conf && \
    echo "datestyle = 'iso, mdy'" >> /etc/postgresql/postgresql.conf && \
    echo "timezone = 'UTC'" >> /etc/postgresql/postgresql.conf

# Create volume for persistent data storage
VOLUME ["/var/lib/postgresql/data"]

# Expose the PostgreSQL port
EXPOSE 5432

# Set the default command to run when starting the container
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]

# Health check to verify the database is running
HEALTHCHECK --interval=30s --timeout=3s \
    CMD pg_isready -U postgres || exit 1
FROM postgis/postgis:15-3.3

LABEL maintainer="EV Connect India"
LABEL description="PostgreSQL with PostGIS for EV Charging Station data"

ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=ev_connect_pass
ENV POSTGRES_DB=ev_connect_india

RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-15-postgis-3-scripts \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 5432

HEALTHCHECK --interval=30s --timeout=5s --retries=5 \
    CMD pg_isready -U postgres

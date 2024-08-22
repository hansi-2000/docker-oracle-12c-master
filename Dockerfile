FROM debian:bookworm-slim

# Update and install necessary packages
RUN apt update && apt upgrade -y && \
    apt install -y alien libaio1 jq && \
    apt install -y openssh-server openssh-client

# Add Oracle Instant Client RPM files
ADD oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm /tmp/
ADD oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm /tmp/
ADD oracle-instantclient12.2-tools-12.2.0.1.0-1.x86_64.rpm /tmp/

# Convert RPM packages to DEB format and install
RUN alien -i /tmp/oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm && \
    alien -i /tmp/oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm && \
    alien -i /tmp/oracle-instantclient12.2-tools-12.2.0.1.0-1.x86_64.rpm && \
    rm -f /tmp/oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm /tmp/oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm /tmp/oracle-instantclient12.2-tools-12.2.0.1.0-1.x86_64.rpm

# Set up Oracle Instant Client environment
RUN echo "/usr/lib/oracle/12.2/client64/lib" > /etc/ld.so.conf.d/oracle.conf && \
    ldconfig 

# Ensure the binaries are correctly linked
RUN if [ ! -f /usr/bin/sqlplus ]; then ln -s /usr/lib/oracle/12.2/client64/bin/sqlplus /usr/bin/sqlplus; fi && \
    if [ ! -f /usr/bin/expdp ]; then ln -s /usr/lib/oracle/12.2/client64/bin/expdp /usr/bin/expdp; fi

# Verify installation
RUN expdp -help || true && \
    sqlplus -v

RUN ssh -V


# docker run oracle_4 sleep infinity

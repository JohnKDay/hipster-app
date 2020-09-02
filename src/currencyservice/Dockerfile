FROM node:8-alpine as base

FROM base as builder

# Some packages (e.g. @google-cloud/profiler) require additional
# deps for post-install scripts
RUN apk add --update --no-cache \
    python \
    make \
    g++

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --only=production

FROM base

RUN GRPC_HEALTH_PROBE_VERSION=v0.2.0 && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/node_modules ./node_modules

COPY . .

EXPOSE 7000

ENTRYPOINT [ "node", "server.js" ]

FROM alpine:3.11.5 as df-runtime


RUN cd /etc/apk/keys && wget https://repo.deepfactor.io/repo/alpine/keys/dfbuild@deepfactor.io-5f35ef3a.rsa.pub
RUN echo "https://repo.deepfactor.io/repo/alpine" >> /etc/apk/repositories
RUN apk add deepfactor-runtime=1.0-r459

ARG APP_IMAGE

ENV DF_API_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyaWQiOiIxZDdkZmIyYS1mZDI3LTRmNjAtOWZlNS1hMmE2NTYwMWJmMDQiLCJ0b2tlbmlkIjoiOGZhOTg2ZGUtZjQ3MC00YmZiLWIzZDMtZjdkMzA5MzRkMzljIiwic3ViZG9tYWluIjoiZGYiLCJjdXN0b21lcmlkIjoiOGIwOGJkZGMtYjM5OS00ODQxLWIwZWUtMzBkYzAwN2YwNDA5IiwidXNlcmxldmVsIjoiQ1VTVE9NRVIiLCJyb2xlaWQiOiJjOTc4NTQzNS0xZTc1LTRkOTEtYjhkOS03NzcyYjMxMGZkZjciLCJyb2xlbmFtZSI6IkNfQURNSU4iLCJ0b2tlbl90eXBlIjoiREZfQVBJX1RPS0VOIiwiZXhwIjoxNjMwNTU1MDIzLCJpYXQiOjE1OTkwMTkwMjMsIm5iZiI6MTU5OTAxOTAyMywicG9ydGFsVVJMIjoiZGVlcGZhY3Rvci4xOTIuMTY4LjEuMTk5LmJhcmIuaW5hZmlzaC5uZXQiLCJjdXN0b21lclBvcnRhbFVSTCI6ImRmLmRlZXBmYWN0b3IuMTkyLjE2OC4xLjE5OS5iYXJiLmluYWZpc2gubmV0IiwicG9ydGFsQ0EiOiJNSUlGd0RDQ0E2aWdBd0lCQWdJVVh5d2VkUVFENC8rZWlhVVprSndnbGErS1hBc3dEUVlKS29aSWh2Y05BUUVMXG5CUUF3YVRFTE1Ba0dBMVVFQmhNQ1ZWTXhFekFSQmdOVkJBZ01Da05oYkdsbWIzSnVhV0V4RVRBUEJnTlZCQWNNXG5DRk5oYmlCS2IzTmxNUk13RVFZRFZRUUtEQXBFWldWd1JtRmpkRzl5TVIwd0d3WURWUVFEREJSRVpXVndSbUZqXG5kRzl5SUZCdmNuUmhiQ0JEUVRBZUZ3MHlNREE0TXpFd01qVXlNelZhRncwek1EQTRNamt3TWpVeU16VmFNR2t4XG5DekFKQmdOVkJBWVRBbFZUTVJNd0VRWURWUVFJREFwRFlXeHBabTl5Ym1saE1SRXdEd1lEVlFRSERBaFRZVzRnXG5TbTl6WlRFVE1CRUdBMVVFQ2d3S1JHVmxjRVpoWTNSdmNqRWRNQnNHQTFVRUF3d1VSR1ZsY0VaaFkzUnZjaUJRXG5iM0owWVd3Z1EwRXdnZ0lpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElDRHdBd2dnSUtBb0lDQVFDb09qaTdxOWhpXG5wbFFoOGNidTJybWZxdnJ2L1V2aXQ5MXBiOWowbDdhdlBwQ1hZeUg4SnZZZTZXRFZ5eThvVG41V1FRYlRDU0ZQXG5BMnZ2TkVtMXhpZkxZZmV2bForSWlzbXpJQXZvNkY5b2tQWkNlT0RkRy9ZRVgvUklraWN5Sm92YkVNenVmckRpXG5Od0tzR2hDZEg4QXJrTyt5L3pZSVBlSjRNNGxlWE5wNVRBODlNUGw5UUNUUURwQnF0Z0xSY2txRURQTzBhbFFpXG5FMnhPczhtWUtEUDV3Vy9CbUUvS3RkVEJMbmxxZmtSYTh6dzd2QXVsU21ucGRCQjNYdlptQWlMMHhXTFM5QkdhXG45bVNObVVTd0VyMFRSdVkxNWZ0MTRIN29neGw2VGllVEVWTnhIdml5dlJhL1RUSmJYN1NHdkFPOE1ENXhEYm1vXG4rOHgzZ1lOQkJlQlpnWVhmaVVBbTBKakQ2dkd1a2JlQ2V3emhKU3hwZlQrZ0x2R0RyeW4zWGtMU3FSMU1kYTZFXG50WjFYbjZUU1dNRFdaZEFjMGRRSHBrZCtvMmg3c3FiTVB5RkhQR3NUbnQxZGZpOXdwTUVyU3oyUEdzeCtaZ1NMXG41bWd5dlhRNGFQVzV6ZkJQVlhuVmt6UU9uL3BoRmUwUC81c0VLM1dMNzBJZjlFNDFOYUU0VFFyYnFaTjRDbENuXG53alRmOXMzdDlMT1pBNkg4d0VUQmxCaHRqMkhNM24vemJNcXExSldYZDJxdk5jZTNXZFVsS3J3YnErQStDMmtnXG5XYmpIeDZORDRXNSsyVU5malVPNVREZ1paWmtTVjlQTWNLSHlZdXRmZWRTdWNlMUdRamQvOVQ1ZnRaOXlEangxXG51UlF2eUNaOUQydXl1V1BqSFJSc0ovZTJrbW5jd1g4MFN3SURBUUFCbzJBd1hqQWRCZ05WSFE0RUZnUVVxWXk2XG5JczJLdzdpVDl3c21uZnVaQnNMTWwwb3dId1lEVlIwakJCZ3dGb0FVcVl5NklzMkt3N2lUOXdzbW5mdVpCc0xNXG5sMG93RHdZRFZSMFRBUUgvQkFVd0F3RUIvekFMQmdOVkhROEVCQU1DQVFZd0RRWUpLb1pJaHZjTkFRRUxCUUFEXG5nZ0lCQUJidkdYQ2Q5NnNLQWlaWFNwNGNsajhnY1V0dnZoQ2hPNTdsWmJqVmdIZy94UjVCaVJiQmNZb1E2Ym9ZXG5FWmF3VEEvbjBSZlcvM212RUN0eExPTXYrZUE1a1VUdW9mTUtiRWR6UVhDMzQ4aGM0MXl3UVF0dWVKTlpaby9vXG5IWDQwUnBDZk5yU1NxK2N3YkY4WDhvYzFpOEZiKzEzMmxDMEhaOUtYb2YzeGVPUGNxcmxMUlIxY2svSlJ3dFI2XG5vZXFrNUFNdjZTMXMzNG5nUGs2ek1GanNxRUFFUzNPQUdTSEpLNXBXaDg2dUZKRDdWRExoTkFvanlyVUlROWd4XG5jTkVNNFdWTitFemxNRGlQTDBVQ09vTDlEMHVZNXdrcGRpeThCNzBIb0tMNTNRRHZVUlRaaXJDYjBOckJIZjF3XG5pVWRIbm43MnovcGczdUFWSm41UHA0Nmc1NXZ6bDN0ZmJQNmJjSmZMYjZzdEp4b29teXVieXRMNktQc3doaVNxXG5ZcnJ3V2ExOXlvZmM3ME1tQVVPa3pYRjVaUC8vNHRwUm5PK3Zqa0xOTzNqenVvbXlmYUxIQk9sd2UxaDVja0hCXG56VjJ3aXFnbVVNU0Z0UDcxdXNhV3hYMW43K3BFRXNlSWtaaEZYemxaQkxFa2MrZ3MrNjFBQzRrWVNnQXpWR3kvXG5CeitnOEwyTW42MVNPOFJjVFFqWHVBL1Y4dGNXem1WdjBQWHA0MG8vV0RSVzAzdWMyQzhDNjE5K1FaU1BTSkZBXG45UmowY1F3V0dxdW1pMEtHRVFwcnE4TGk3YUkrdnUyZDI5N3pvTzBZZ1lxNEZPNXNYcHdub1ZXVitLemkvR0NXXG5vb2NHTHA5YmVlVHM1cUowT0ZZUlJBZlhTMVgrYzNFOG5KWnQ2T0tyNHRXbUJ5NjQifQ.fGeeL2ABb1II1CgFg7JiAV9T6RooR4E4uWwgsvVxC0g

# option: pass via build ARG or set here
ENV DF_APP "Hipster"
ENV DF_COMPONENT "currencyservice"

# If necessary, add --add-host=my-df-portal:10.0.0.1 to your image build AND run commands for DF portal DNS:
RUN dfctl register -a "$DF_APP" -c "$DF_COMPONENT" -o /usr/lib/libdf.so -v
# option: dfctl register/create individual components in container

# Warning: The above df-runtime container's built libdf.so install must match
#  the version of the target container's libc.so.
#  i.e. APP_IMAGE must contain a glibc >= 2.17

FROM builder
COPY --from=df-runtime /usr/lib/libdf.so /usr/lib/libdf.so

# Add runtime dependencies
RUN IMG_USER=`id -un`
USER root
RUN apk add libstdc++ libexecinfo
USER ${IMG_USER}


# The following is an optional smoke test for redhat and debian distro types.
RUN env LD_PRELOAD=/usr/lib/libdf.so sh -c 'apk list > /dev/null' || \
    (echo -e "\n\n\nError, DeepFactor dependency not met.\n\n\n/tmp/deepfactor.log:\n" \
    && cat /tmp/deepfactor.log && false)

# option: set LD_PRELOAD in app startup cmd or script
ENV LD_PRELOAD=/usr/lib/libdf.so


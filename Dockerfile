FROM ghcr.io/zhaofengli/attic:latest
COPY ./server.toml /attic/server.toml
EXPOSE 8080
CMD ["-f", "/attic/server.toml", "--mode", "monolithic"]

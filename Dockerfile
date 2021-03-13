FROM arm64v8/rust as build

ARG REVISION=d3a61446acaa64b1732bc0ead5880fbc5f8e3f31

RUN apt-get update && apt-get install build-essential

RUN cargo install --verbose --git https://github.com/holochain/holochain --rev ${REVISION} holochain
RUN cargo install --git https://github.com/holochain/holochain --rev ${REVISION} holochain_cli

RUN cargo install --git https://github.com/holochain/lair --rev v0.0.1-alpha.10 lair_keystore --bin lair-keystore

FROM arm64v8/ubuntu
COPY --from=build /usr/local/cargo/bin/holochain /usr/local/bin/holochain
COPY --from=build /usr/local/cargo/bin/lair-keystore /usr/local/bin/lair-keystore
COPY --from=build /usr/local/cargo/bin/hc /usr/local/bin/hc
ENV PATH="/usr/local/bin:${PATH}"

RUN apt-get update && apt-get install -y socat libssl-dev

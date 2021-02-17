FROM arm64v8/rust as build

RUN mkdir /holochain

WORKDIR /holochain
ARG REVISION=develop

ADD https://github.com/holochain/holochain/archive/$REVISION.tar.gz /holochain/$REVISION.tar.gz
RUN tar --strip-components=1 -zxvf $REVISION.tar.gz
 
RUN cargo install --path crates/holochain
#RUN cargo install --path crates/dna_util

RUN mkdir /lair
WORKDIR /lair
ADD https://github.com/holochain/lair/archive/master.tar.gz /lair/master.tar.gz
RUN tar --strip-components=1 -zxvf master.tar.gz
RUN cd crates/lair_keystore && cargo install --path .

FROM arm64v8/ubuntu
COPY --from=build /usr/local/bin/holochain /usr/local/cargo/bin/holochain
#COPY --from=build /usr/local/cargo/bin/dna-util /usr/local/cargo/bin/dna-util
COPY --from=build /usr/local/bin/lair-keystore /usr/local/cargo/bin/lair-keystore
#ENV PATH="/usr/local/cargo/bin:${PATH}"
#RUN rustup target add wasm32-unknown-unknown

RUN apt-get update && apt-get install curl -y
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash
RUN apt-get install -y nodejs
FROM rust:1.92

WORKDIR /usr/src/rust_test
COPY . .

RUN cargo build --release

CMD ["target/release/rust_test"]

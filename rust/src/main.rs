use axum::{response::IntoResponse, routing::get, Json, Router};
use rand::{rngs::SmallRng, Rng, SeedableRng};
use serde::Serialize;
use std::cell::RefCell;

#[derive(Serialize)]
struct UserProfile {
    id: i32,
    name: String,
    email: String,
    roles: &'static str,
    is_active: bool,
}

thread_local! {
    static RNG: RefCell<SmallRng> = RefCell::new(SmallRng::from_entropy());
}

async fn get_user_handler() -> impl IntoResponse {

    let id = RNG.with(|rng| {
        rng.borrow_mut().gen_range(1..=1_000_000)
    });

    Json(UserProfile {
        id,
        name: format!("User_{id}"),
        email: format!("dev_{id}@apple.com"),
        roles: if id % 2 == 0 { "admin" } else { "user" },
        is_active: id % 3 == 0,
    })
}

#[tokio::main]
async fn main() {
    let app = Router::new().route("/", get(get_user_handler));
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

use leptos::prelude::*;
use leptos_meta::{provide_meta_context, Title};
use leptos_router::{
    components::{Route, Router, Routes},
    StaticSegment,
};

fn main() {
    console_error_panic_hook::set_once();
    leptos::mount::mount_to_body(App);
}

#[component]
pub fn App() -> impl IntoView {
    // provides context that manages stylesheets, titles, meta tags, etc.
    provide_meta_context();

    view! { <h1>"Welcome to Leptos"</h1> }
}

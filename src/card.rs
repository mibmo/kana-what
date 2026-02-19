use std::collections::BTreeSet;
use std::sync::LazyLock;

use leptos::prelude::{component, view, ClassAttribute, IntoView};

pub type Kana = fixedstr::zstr<4>;
pub type Romaji = fixedstr::zstr<4>;
pub type Tag = fixedstr::zstr<8>;
pub type TagSet = BTreeSet<Tag>;

#[derive(Debug, Clone, PartialEq)]
pub struct CardData {
    kana: Kana,
    romaji: Romaji,
    syllabary: Syllabary,
    tags: TagSet,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Syllabary {
    Hiragana,
    Katakana,
}

#[component]
pub fn Card(card: CardData) -> impl IntoView {
    view! { <article class="card"></article> }
}

pub static CARDS: LazyLock<Vec<CardData>> = LazyLock::new(|| {
    vec![
        CardData {
            kana: Kana::from("あ"),
            romaji: Romaji::from("a"),
            syllabary: Syllabary::Hiragana,
            tags: TagSet::from(["vowel".into()]),
        },
        CardData {
            kana: Kana::from("え"),
            romaji: Romaji::from("e"),
            syllabary: Syllabary::Hiragana,
            tags: TagSet::from(["vowel".into()]),
        },
        CardData {
            kana: Kana::from("い"),
            romaji: Romaji::from("i"),
            syllabary: Syllabary::Hiragana,
            tags: TagSet::from(["vowel".into()]),
        },
        CardData {
            kana: Kana::from("お"),
            romaji: Romaji::from("o"),
            syllabary: Syllabary::Hiragana,
            tags: TagSet::from(["vowel".into()]),
        },
        CardData {
            kana: Kana::from("う"),
            romaji: Romaji::from("u"),
            syllabary: Syllabary::Hiragana,
            tags: TagSet::from(["vowel".into()]),
        },
        CardData {
            kana: Kana::from("ア"),
            romaji: Romaji::from("a"),
            syllabary: Syllabary::Katakana,
            tags: TagSet::from(["vowel".into()]),
        },
        CardData {
            kana: Kana::from("エ"),
            romaji: Romaji::from("e"),
            syllabary: Syllabary::Katakana,
            tags: TagSet::from(["vowel".into()]),
        },
        CardData {
            kana: Kana::from("イ"),
            romaji: Romaji::from("i"),
            syllabary: Syllabary::Katakana,
            tags: TagSet::from(["vowel".into()]),
        },
        CardData {
            kana: Kana::from("オ"),
            romaji: Romaji::from("o"),
            syllabary: Syllabary::Katakana,
            tags: TagSet::from(["vowel".into()]),
        },
        CardData {
            kana: Kana::from("ウ"),
            romaji: Romaji::from("u"),
            syllabary: Syllabary::Katakana,
            tags: TagSet::from(["vowel".into()]),
        },
    ]
});

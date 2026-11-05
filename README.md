# Wallet API

A small Rails API for an internal wallet system. Users, teams and stocks can each own a wallet, and money moves between wallets through deposit, withdrawal and transfer records.

## Running it

    bundle install
    bin/rails db:setup
    bin/rails server

`db:setup` also runs the seeds, which create two users (alice@example.com and bob@example.com, both with password `password123`), a team and a stock. Alice starts with 1000 in her wallet. Tests run with `bin/rails test`.

The stock price endpoints need a RapidAPI key in the `RAPIDAPI_KEY` environment variable. Everything else works without it.

## How it's put together

Wallets are polymorphic. Any model can have one by including the `Walletable` concern, which creates the wallet right after the record is created. User, Team and Stock all use it.

Transactions use single table inheritance. A `Deposit` has only a target wallet, a `Withdrawal` has only a source wallet, and a `Transfer` has both (and they can't be the same wallet). Amounts must be positive, and the source wallet needs enough balance.

There is no balance column. A wallet's balance is the sum of the transactions coming in minus the sum going out, so the transaction table is the only source of truth.

Every write happens inside a database transaction, and the wallets involved are locked with `lock!` before the balance check. Transfers lock both wallets in id order so two opposite transfers can't deadlock each other.

Authentication is done by hand, without extra gems. Passwords are hashed with PBKDF2 from OpenSSL (part of Ruby's standard library), and a login creates a `Session` with a random token from `has_secure_token`. Send it as `Authorization: Bearer <token>`.

A user can only withdraw or transfer out of their own wallet. Team and stock wallets don't have owners who can log in, so for now any signed-in user can move money out of them. That was the simplest thing that worked, and a real version would need some kind of membership model.

## Endpoints

    POST   /session                      email, password -> token
    DELETE /session                      log out
    GET    /wallets/:id                  wallet with balance
    GET    /wallets/:id/balance
    POST   /wallets/:id/deposit          amount
    POST   /wallets/:id/withdraw         amount
    POST   /wallets/:id/transfer         target_wallet_id, amount
    GET    /stock_prices/price           indices, identifier
    GET    /stock_prices/prices          indices
    GET    /stock_prices/price_all

Quick example:

    curl -X POST localhost:3000/session -d email=alice@example.com -d password=password123
    curl -H "Authorization: Bearer $TOKEN" localhost:3000/wallets/1/balance
    curl -X POST -H "Authorization: Bearer $TOKEN" localhost:3000/wallets/1/transfer \
         -d target_wallet_id=2 -d amount=100

## The stock price library

`lib/latest_stock_price` is a small client for the Latest Stock Price API on RapidAPI, structured like a gem (configuration, client, errors, version). It's set up in `config/initializers/latest_stock_price.rb` and offers `price`, `prices` and `price_all`.

I wasn't able to test this part against the real service. The RapidAPI link in the assignment now says "API not found". The nearest match I could find (a listing called "latest stock price" by prema123) only has a `price_all` endpoint, and calling it from the RapidAPI playground gave me `401 Invalid API key`, so I never saw a real response. I also asked about it by message and haven't heard back.

That means the paths and parameter names in `lib/latest_stock_price/client.rb` come from my reading of the assignment and are unconfirmed. If the real API differs, that file is the only place that needs to change. The unit tests stub the HTTP call, and without a key the endpoints return a 502 with a readable error instead of crashing.

## Not done

There are no controller tests and no concurrency tests. `lock!` only takes real row locks on PostgreSQL or MySQL, and the project uses SQLite by default, so the locking is best checked on Postgres. Session tokens also don't expire yet.

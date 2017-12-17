FROM elixir:1.5.2-alpine AS builder

RUN apk update
RUN apk add gawk git make curl python

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info

WORKDIR /app
ENV MIX_ENV prod
ADD . .
RUN mix deps.get
RUN mix release.init
RUN mix release --env=$MIX_ENV
RUN mix phx.digest

FROM alpine:3.6

WORKDIR /app
COPY --from=builder /app/_build/prod/rel/ex_meetup_amqp .

CMD ["./bin/ex_meetup_amqp", "foreground"]


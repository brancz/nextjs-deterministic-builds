# Determinsitic NextJS bulds

This repo intends to demonstrate how to build NextJS apps deterministically.

> Note: This currently does not work and is used to troubleshoot this with the NextJS community.

This repo is based on the [`with-docker`](https://github.com/vercel/next.js/tree/canary/examples/with-docker) example.

## Try

The intention is that two consecutive `next build` runs produce identical outputs. So this is expected to show no diff:

```
NODE_ENV=production yarn build && mv .next next1 && NODE_ENV=production yarn build && mv .next next2 && git diff --no-index next1 next2
```

# Determinsitic NextJS bulds

This repo intends to demonstrate how to build NextJS apps deterministically. The important part of making the build deterministic is the content of [`next.config.js`](./next.config.js). An important caveat is that if the NextJS preview mode is used, this makes it insecure, do not do this if you use preview mode!

This repo is based on the [`with-docker`](https://github.com/vercel/next.js/tree/canary/examples/with-docker) example. And extends it by making the container image being built also deterministic.

## Verify

The intention is that two consecutive `next build` runs produce identical outputs. So this is expected to show no diff, and print "Deterministic!" if everything works as expected:

```
rm -rf next1 next2 && NODE_ENV=production yarn build && mv .next next1 && rm -rf next1/cache/webpack && NODE_ENV=production yarn build && mv .next next2 && rm -rf next2/cache/webpack && git diff --no-index next1 next2 --exit-code && echo 'Deterministic!'
```

To build a byte-by-byte identical container image, use `podman` and force creation timestamps to be `0`:

```
podman build --no-cache --timestamp 0 .
```

Multiple runs of that yields identical image hashes. Since this is reproducible, it should be:

```
d7a74488f7ac04e35a9d75d04abe1a0ab0d49595f2f0e2e1d003d9f0f4dbd2f5
```

And run it, to see that it actually works:

```
podman run --rm -it -ePORT=3000 -p3000:3000 d7a74488f7ac04e35a9d75d04abe1a0ab0d49595f2f0e2e1d003d9f0f4dbd2f5
```

## Why `podman`

When investigating this, I realized that there are multiple things I had assumed to be true about tools to build containers are incorrect. Using `docker build` not even things like setting the `WORKDIR` results in a reproducible image (I could not figure out why, but I assume it has something to do with metadata added to layers). Docker's buildkit is slightly better, meta things like `WORKDIR` are deterministic, however, `COPY` is not either. I could only find `podman` to have the `--timestamp` flag to configure timestamps set for these.

# Unity Builder Buildkite Plugin

## Example

Add the following to your `pipeline.yml`:

```yml
steps:
  - command: ls
    plugins:
      - qkrsogusl3/unity-builder:
          app-center:
            name: "name"
            token: "token"
            id: 10
```


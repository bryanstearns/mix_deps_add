# MixDepsAdd

Adds a mix task for auto-adding dependencies to `mix.exs`, *if* you happen to
keep your `mix.exs` file's `deps` function in a simple canonical form.

```
$ mix deps.add httpoison hackney ../my_local_package
:httpoison, "~> 0.11.2"
:hackney, "~> 1.5.5"
:my_local_package, path: "../my_local_package"
```

For names without a slash, it looks up the latest released version on
[hex.pm](https://hex.pm); if there's a slash, it's treated as a local path.

## Installation
Install its archive, so that it's available in all of your projects:

```
$ mix archive.install https://github.com/bryanstearns/mix_deps_add/releases/download/0.1.3/mix_deps_add-0.1.3.ez
```

## Why?
I like how `npm install --save <name>` figures out the current version of
the package and updates your `package.json` by itself, so I decided to make a
Mix task to do it for my Elixir project dependencies. It's harder to do for
Mix because `mix.exs` is freeform Elixir code, but since the `deps` function
is pretty simple, I just require that it adheres to the usual format &
content... for example:

```
  defp deps do
    [
      {:hackney, "~> 1.5.5"},
      {:httpoison, "~> 0.11.1"},
      {:my_local_package, path: "../my_local_package"},
      {:poison, "~> 3.1.0"}
    ]
  end
```

(This is what you'd get if you ran the example command above, if `:poison`
was your only existing dependency.)

## <a name="rules"></a>The rules for your `deps/0` function
If these seem overly restrictive to you, please file an issue; I'm also open
to pull requests!

- It starts with the only "defp deps do" line in the file
- It ends with the next "end" line
- It contains nothing but the list of dependencies,
  each on its own line, separated by commas, wrapped by square brackets
- No comments allowed (for now)

It doesn't care if the square brackets are on their own lines; it'll put them
on their own lines and sort the dependencies alphabetically when it writes the
file back out.

Yes, it's a bit of a hack, but It Works On My Machine, so I'm shipping it.

## TODO, maybe

- [x] support adding more than one dependency at a time
- [x] support adding local projects with `path:`
- [ ] preserve comments within the `deps` function
- [ ] allow prerelease versions
- [ ] support "git:" dependencies
- [ ] add the [trailing comma](https://github.com/lexmag/elixir-style-guide#trailing-comma)

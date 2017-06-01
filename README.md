# MixDepsAdd

Adds a mix task for auto-adding dependencies to `mix.exs`, *if* you happen to
keep your `mix.exs` file's `deps` function in a simple canonical form.

```
$ mix deps.add httpoison hackney
:httpoison, "~> 0.11.2"
:hackney, "~> 1.5.5"
```

## Installation
Install its archive, so that it's available in all of your projects:

```
$ mix archive.install https://github.com/bryanstearns/mix_deps_add/releases/download/0.1.2/mix_deps_add-0.1.2.ez
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
      {:httpoison, "~> 0.11.1"},
      {:poison, "~> 3.1.0"}
    ]
  end
```

For now, it always adds the latest version found on [hex.pm](https://hex.pm);
I'll probably distinguish prerelease versions shortly.

## <a name="rules"></a>The rules for your `deps/0` function
- It starts with the only "defp deps do" line in the file
- It ends with the next "end" line
- It contains nothing but the list of dependencies,
  each on its own line, separated by commas, wrapped by square brackets
- No comments, though I might fix that.

It doesn't care if the square brackets are on their own lines; it'll put them
on their own lines and sort the dependencies alphabetically when it writes the
file back out.

If these seem overly restrictive to you, I'm open to pull requests! Yes, it's a bit of a hack, but It Works On My Machine, so I'm shipping it.

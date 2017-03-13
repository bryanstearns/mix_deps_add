  # These are the example dependencies listed by `mix help deps`
  defp deps do
    [
      {:plug, ">= 0.4.0"},
      {:foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1"},
      {:foobar, path: "path/to/foobar"}
    ]
  end

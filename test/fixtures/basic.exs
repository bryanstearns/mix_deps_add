defmodule Basic.Mixfile do
  use Mix.Project
  defp deps do
    [
      {:httpoison, "~> 0.11.1"},
      {:poison, "~> 3.1.0"}
    ]
  end
end

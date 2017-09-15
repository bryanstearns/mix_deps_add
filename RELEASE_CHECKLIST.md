## Checklist for releasing a new version

- make sure `CHANGELOG.md` lists all the changes
- update the version in `mix.exs`
- update `README.md`'s archive.install URL
- commit the last changes (& mention the new version in the commit message)
- run the tests one more time
- build the production release: `(export MIX_ENV=prod; mix clean && mix compile && mix archive.build && mix archive.install)`
- try the newly-installed version: `(cd ..; /bin/rm -rf test_mix_deps_add && mix new test_mix_deps_add && cd test_mix_deps_add && mix deps.add httpoison && cat mix.exs)`
- tag the new version: eg `git tag 1.0.3`
- push the latest commits and the tag: `git push origin master 1.0.3`
- create a new release [here](https://github.com/bryanstearns/mix_deps_add/releases/new);
  paste in the change list from CHANGELOG.md
- edit the `mix.exs` package version (bump and add "-pre") for next time

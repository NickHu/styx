/*
Small, opt-in helpers to build `nix run`-able flake apps around a built
site. These are plain functions (not `documentedFunction`s, they aren't
part of the templating library and don't show up in the generated library
docs) meant to be wired into a *site's own* flake, e.g.:

  apps.serve = styx.lib.apps.mkServe { site = self.packages.${system}.default; };

Styx itself does not ship a `styx serve`/`styx deploy` binary anymore:
`nix build`/`nix flake check` already cover building and testing a site,
and these helpers cover the handful of things Nix has no opinion on
(running a local file server, link-checking it, publishing to a
`gh-pages` branch).
*/
{pkgs}: let
  l = pkgs.lib // builtins;
in {
  /*
  Serve a built site locally with caddy.
  */
  mkServe = {
    site,
    host ? "127.0.0.1",
    port ? 8080,
  }: {
    type = "app";
    program = l.getExe (pkgs.writeShellApplication {
      name = "styx-serve";
      runtimeInputs = [pkgs.caddy];
      text = ''
        echo "serving ${site} on http://${host}:${toString port}"
        echo "press Ctrl+C to stop"
        exec caddy file-server --listen "${host}:${toString port}" --root "${site}"
      '';
    });
  };

  /*
  Serve a built site locally and run a link checker (lychee) against it.
  */
  mkLinkcheck = {
    site,
    host ? "127.0.0.1",
    port ? 8080,
  }: {
    type = "app";
    program = l.getExe (pkgs.writeShellApplication {
      name = "styx-linkcheck";
      runtimeInputs = [pkgs.caddy pkgs.lychee];
      text = ''
        caddy file-server --listen "${host}:${toString port}" --root "${site}" &>/dev/null &
        server=$!
        trap 'kill "$server" 2>/dev/null || true' EXIT
        sleep 1
        lychee "http://${host}:${toString port}"
      '';
    });
  };

  /*
  Publish a built site to a `gh-pages` branch, using a `git worktree`
  (created on demand) so the working tree of the calling repository is
  left untouched. Idempotent: safe to (re-)run at any time, it will
  create the branch/worktree the first time and just update them after.
  */
  mkGhPagesDeploy = {
    site,
    branch ? "gh-pages",
    worktree ? "gh-pages",
    remote ? "origin",
  }: {
    type = "app";
    program = l.getExe (pkgs.writeShellApplication {
      name = "styx-deploy-gh-pages";
      runtimeInputs = [pkgs.git];
      text = ''
        repoRoot="$(git rev-parse --show-toplevel)"
        cd "$repoRoot"

        if ! git show-ref --quiet --verify "refs/heads/${branch}"; then
          if git show-ref --quiet --verify "refs/remotes/${remote}/${branch}"; then
            echo "Fetching existing '${branch}' branch from '${remote}'..."
            git fetch "${remote}" "${branch}:${branch}"
            git worktree add "${worktree}" "${branch}"
          else
            echo "Creating orphan '${branch}' branch in './${worktree}'..."
            git worktree add --orphan -b "${branch}" "${worktree}"
            (cd "${worktree}" && git commit --allow-empty -m "initialize ${branch}")
          fi
        elif [ ! -d "${worktree}" ]; then
          git worktree add "${worktree}" "${branch}"
        fi

        (
          cd "${worktree}"
          git rm -rf --quiet . >/dev/null 2>&1 || true
          cp -RL "${site}"/. .
          chmod -R u+w .
          git add -A
          rev=$(git -C "$repoRoot" rev-parse --short HEAD)
          git commit -m "Deploy $rev" --allow-empty
        )

        echo "Committed to '${branch}' in './${worktree}'."
        echo "Push with: git -C '${worktree}' push -u ${remote} ${branch}"
      '';
    });
  };
}

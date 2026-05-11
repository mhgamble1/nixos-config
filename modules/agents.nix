{ pkgs, llm-agents-nix, ... }:

let
  agents = llm-agents-nix.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = with agents; [
    claude-code
    codex
    crush
    goose-cli
    gemini-cli
    letta-code
    opencode
    pi
  ];

  home.file.".claude/CLAUDE.md".source = ../home/mhg/claude/CLAUDE.md;
}

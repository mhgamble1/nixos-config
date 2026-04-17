{ pkgs, llm-agents-nix, ... }:

let
  agents = llm-agents-nix.packages.${pkgs.system};
in
{
  home.packages = [
    agents.crush
    agents.claude-code
    agents.codex
    agents.gemini-cli
    agents.opencode
  ];

  home.file.".claude/CLAUDE.md".source = ../home/mhg/claude/CLAUDE.md;
}

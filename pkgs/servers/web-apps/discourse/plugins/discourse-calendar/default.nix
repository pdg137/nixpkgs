{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-calendar";
  bundlerEnvArgs.gemdir = ./.;
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-calendar";
    rev = "09583aa7dd055d8424b166d3c22f61a505dfb64f";
    sha256 = "sha256-ckQaM8g3D8Y7/HwYJlI44gCQA0jUsdjH+RMY4cPNCRU=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-calendar";
    maintainers = with maintainers; [ ryantm ];
    license = licenses.mit;
    description = "Adds the ability to create a dynamic calendar in the first post of a topic";
  };
}

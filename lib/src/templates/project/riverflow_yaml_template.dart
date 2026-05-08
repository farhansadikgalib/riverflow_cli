/// Returns the riverflow.yaml content for a new Flutter project.
String riverflowYamlTemplate(String name) => '''
# Riverflow CLI Configuration
# https://github.com/riverflow-cli/riverflow_cli

project:
  name: $name
  architecture: clean  # clean | feature-first
  state_management: riverpod

generation:
  run_build_runner: true
  auto_register_routes: true

# Custom commands (optional)
# commands:
#   my_command:
#     description: "A custom command"
#     steps:
#       - "dart format ."
#       - "dart run build_runner build --delete-conflicting-outputs"
''';

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# SwiftLint
swiftlint.config_file = '.swiftlint.yml'
swiftlint.binary_path = 'Pods/SwiftLint/swiftlint'
swiftlint.max_num_violations = 20
swiftlint.verbose = true

# The argument "--force-exclude" is passed to SwiftLint by the danger-swiftlint plugin.
# But this SwiftLint argument doesn't work properly and has issues. So we re-disable it.
swiftlint.lint_files inline_mode: true, additional_swiftlint_args: '--no-force-exclude'

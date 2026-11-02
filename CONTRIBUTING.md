# Contributing to g-engine

Thank you for your interest in contributing to **g-engine**! We welcome contributions of all kinds, whether it's reporting bugs, improving documentation, submitting feature requests, or writing code.

Please take a moment to review this document before submitting your contribution.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Prerequisites](#prerequisites)
- [Setting Up the Development Environment](#setting-up-the-development-environment)
- [Development Workflow](#development-workflow)
  - [Code Formatting](#code-formatting)
  - [Building](#building)
  - [Running the Engine](#running-the-engine)
  - [Running Tests](#running-tests)
- [How to Report Bugs](#how-to-report-bugs)
- [How to Suggest Enhancements](#how-to-suggest-enhancements)
- [Submitting Pull Requests](#submitting-pull-requests)
  - [Branch Naming](#branch-naming)
  - [Commit Messages](#commit-messages)
  - [PR Guidelines & Checklist](#pr-guidelines--checklist)
- [License](#license)

---

## Code of Conduct

This project and everyone participating in it are governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

---

## Prerequisites

Before building `g-engine`, ensure you have the following installed on your system:

1. **Zig Compiler**:
   - Minimum version: **`0.17.0`** (see `minimum_zig_version` in `build.zig.zon`).
   - Check your version:
     ```bash
     zig version
     ```
2. **System Dependencies (SDL3)**:
   - `g-engine` uses SDL3 and targets **Linux**, **macOS**, and **Windows**.
   - While Zig fetches SDL3 source packages automatically:
     - On **Linux**: Your system must have development libraries for audio and display drivers (Wayland/X11, ALSA/PulseAudio/PipeWire development headers, pkg-config, etc.).
     - On **macOS**: Standard developer tools and frameworks.
     - On **Windows**: Standard Windows SDK and C runtime.

---

## Setting Up the Development Environment

1. **Clone the repository:**
   ```bash
   git clone https://github.com/bebewold/g-engine.git
   cd g-engine
   ```

2. **Fetch dependencies (optional, automatically fetched on first build):**
   ```bash
   zig build --fetch
   ```

---

## Development Workflow

### Code Formatting

All Zig code and build definition files must be formatted using the official Zig formatter before submitting a contribution:

```bash
# Check if source and build files adhere to standard formatting
zig fmt --check src/ build.zig build.zig.zon

# Auto-format all source and build files
zig fmt src/ build.zig build.zig.zon
```

### Building

Compile the project in Debug mode:

```bash
zig build
```

To compile with optimization:

```bash
# Available options: ReleaseSafe, ReleaseFast, ReleaseSmall
zig build -Doptimize=ReleaseFast
```

### Running the Application

Run the application directly:

```bash
zig build run
```

You can pass arguments to the application using `--`:

```bash
zig build run -- [arguments...]
```

### Running Tests

Run all unit and integration tests (Debug mode):

```bash
zig build test
```

We also recommend running tests with `ReleaseSafe` optimization to catch safety issues under compiler optimizations (matching our CI pipeline):

```bash
zig build test -Doptimize=ReleaseSafe
```

Make sure all tests pass without errors or memory leaks before committing.

---

## How to Report Bugs

If you find a bug:
1. **Search existing issues** to make sure it hasn't already been reported.
2. If it is new, open an issue using the **Bug Report** template.
3. Include:
   - Your OS and hardware architecture.
   - Exact Zig version (`zig version`).
   - Clear, step-by-step reproduction instructions.
   - Terminal logs or backtraces if a crash occurs.

---

## How to Suggest Enhancements

We are happy to discuss new features or architectural improvements:
1. Check existing issues and discussions to see if the proposal has already been discussed.
2. Open an issue using the **Feature Request** template.
3. Describe the problem your proposal solves, the expected behavior, and any design alternatives considered.

---

## Technical Tasks & Maintenance

For refactoring, CI/CD improvements, tooling, or infrastructure work:
1. Open an issue using the **Technical Task** template.
2. Clearly describe the motivation and outline the actionable acceptance criteria.

---

## Submitting Pull Requests

### Branch Naming

Create a dedicated branch for your work. If your branch addresses an existing issue, include the issue number in the branch name to make tracking easier:

- `feat/#<issue>-feature-name` (or `feat/feature-name`) for new features (e.g. `feat/#12-sprite-batching`)
- `fix/#<issue>-bug-description` (or `fix/bug-description`) for bug fixes (e.g. `fix/#42-window-freeze`)
- `docs/topic-name` for documentation updates
- `refactor/scope-name` for refactoring without behavior change
- `chore/task-name` for maintenance and toolchain updates

### Commit Messages

We encourage clear, descriptive commit messages, preferably following [Conventional Commits](https://www.conventionalcommits.org/):

```text
feat(renderer): add basic 2D sprite batching
fix(audio): handle buffer underrun in SDL callback
docs: update prerequisites in CONTRIBUTING.md
test: add regression test for window resize event
```

If resolving an issue, you can reference it directly in your commit message footer:

```text
fix(window): prevent freeze on resize event

Closes #42
```

### PR Guidelines & Checklist

Before opening a Pull Request:
- [ ] Code is formatted with `zig fmt src/ build.zig build.zig.zon`.
- [ ] Project builds cleanly with `zig build`.
- [ ] All tests pass locally with `zig build test` (and ideally `zig build test -Doptimize=ReleaseSafe`).
- [ ] Note: CI automatically runs tests under both `Debug` and `ReleaseSafe` on Linux.
- [ ] Relevant tests are added or updated for new code / bug fixes.
- [ ] Documentation is updated if public APIs or user workflows change.
- [ ] Commit history is clean and focused.

---

## License

By contributing to `g-engine`, you agree that your contributions will be licensed under the project's [GNU General Public License v3.0](LICENSE).

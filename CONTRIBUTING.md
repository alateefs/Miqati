# Contributing to Miqati

First off, thank you for considering contributing to Miqati! It's people like you that make Miqati such a great tool for the Muslim community.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* Use a clear and descriptive title
* Describe the exact steps which reproduce the problem
* Provide specific examples to demonstrate the steps
* Describe the behavior you observed after following the steps
* Explain which behavior you expected to see instead and why
* Include screenshots if possible
* Include device information (Android version, device model)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* Use a clear and descriptive title
* Provide a detailed description of the suggested enhancement
* Explain why this enhancement would be useful
* List some examples of how this enhancement would be used

### Pull Requests

* Fill in the required template
* Follow the Kotlin style guide
* Include comments in your code where necessary
* Update documentation as needed
* Add tests for new functionality
* Ensure all tests pass
* Update the CHANGELOG.md if applicable

## Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/miqati.git`
3. Create a branch: `git checkout -b feature/your-feature-name`
4. Make your changes and commit: `git commit -m 'Add some feature'`
5. Push to your fork: `git push origin feature/your-feature-name`
6. Open a Pull Request

## Coding Standards

### Kotlin Style Guide

* Follow the official [Kotlin coding conventions](https://kotlinlang.org/docs/coding-conventions.html)
* Use meaningful variable and function names
* Keep functions small and focused
* Use data classes for models
* Prefer immutability (`val` over `var`)
* Handle nullability explicitly
* Use coroutines for asynchronous operations

### Architecture

* Follow Clean Architecture principles
* Keep business logic in the domain layer
* UI should only display data and handle user interactions
* Use dependency injection with Hilt
* Follow MVVM pattern for presentation layer

### Testing

* Write unit tests for domain logic
* Write integration tests for repositories
* Write UI tests for critical user flows
* Aim for at least 80% code coverage

### Documentation

* Document public APIs with KDoc
* Add comments for complex logic
* Keep README.md up to date
* Update CHANGELOG.md for significant changes

## Questions?

Feel free to open an issue with the "question" label if you have any questions about contributing.

## License

By contributing to Miqati, you agree that your contributions will be licensed under the MIT License.

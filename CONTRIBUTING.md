# Contribution Guide for wuchuheng_email_storage

Thank you for considering contributing to wuchuheng_email_storage! Following these guidelines helps maintain code quality and streamline the development process.  
The project must be does the following things before you start developing:

- [x] Fork the repository.
- [x] Clone the repository to your local machine with the `git clone <git-repo-url> .` command.
- [x] Create a new branch for your feature or bug fix with the `git checkout -b feature/your-feature-name` command.
- [x] Configure the environment variables in the `.env` file in the root directory.
- [x] Install the git hooks with the `make install-git-hooks` command.

## Getting Started with Development

1. **Fork the Repository**: Fork the project on GitHub to your personal account.

2. **Clone Your Fork**: Clone your forked repository to your local machine.
    ```sh
    git clone https://github.com/wuchuheng/email_storage_dart.git
    ```

3. **Install Dependencies**: Install the project dependencies using the following command:

    ```sh
    dart pub get
    ```
4. **Setup Environment**: To manage sensitive data like API keys, we use a `.env` file. Copy the `.env.example` to `.env` and populate it with the necessary values.

    ```sh
    cp .env.example .env
    ```
   the configuration in the `.env` file must be filled in with the correct values.

## Code tree structure

```sh
.
├── .env                                           # Environment variables
├── .env.example
├── .git_hooks                                     # Git hooks
├── .gitignore
├── CHANGELOG.md
├── CONTRIBUTING.md
├── Makefile
├── README.md
├── analysis_options.yaml
├── example
├── lib
│   ├── src
│   │   ├── tcp_clients                       # TCP clients 
│   │   └── wuchuheng_email_storage_base.dart # Base class
│   └── wuchuheng_email_storage.dart                # Main class
├── pubspec.lock
├── pubspec.yaml
└── test

```


## Making Changes

1. **Branching**: Create a new branch for your feature or bug fix.

    ```sh
    git checkout -b feature/your-feature-name
    ```

2. **Code**: Write your code, adhering to the project's coding conventions.

3. **Commit**: Commit your changes with a meaningful message.

    ```sh
    git commit -am "feat: <your-feature-description>"
    ```

4. **Push**: Push your branch to your fork on GitHub.

    ```sh
    git push origin feature/your-feature-name
   

## Submitting a Pull Request

1. **Create Pull Request**: Visit your fork on GitHub and click the "New Pull Request" button.

2. **Select Branch**: Choose your feature branch as the base and the upstream repository's main branch as the compare branch.

3. **Describe Changes**: In the pull request description, summarize your changes, the problem they solve, and any relevant discussion points.

4. **Wait for Review**: Maintainers will review your code. Be prepared to make adjustments based on feedback.

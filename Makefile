# Install the git hooks for the project with the specified path: .git_hooks
install-git-hooks:
	@echo "Installing git hooks..."
	# Set the git hooks path.
	git config core.hooksPath .git_hooks
	@echo "Git hooks installed successfully!"
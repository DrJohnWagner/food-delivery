# =============================================================================
# DIABETES PREDICTION PIPELINE - MAKEFILE
# =============================================================================

# Project configuration
PROJECT_NAME := pima-indians-diabetes
PYTHON := python3
VENV_DIR := .venv
PIP := $(VENV_DIR)/bin/pip
PYTHON_VENV := $(VENV_DIR)/bin/python
PYTEST := $(VENV_DIR)/bin/pytest

# File patterns and directories
PYTHON_FILES := *.py
NOTEBOOK_FILES := *.ipynb
TEST_FILES := test_*.py
DATA_FILES := input_data/
SCRIPTS_DIR := scripts/
BACKUPS_DIR := backups/
CACHE_DIRS := __pycache__/ .pytest_cache/
LOG_FILES := *.log

# Build artifacts and outputs
BUILD_DIR := build/
DIST_DIR := dist/

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Default target
.PHONY: help
help: ## Show this help message
	@echo "$(GREEN)🧬 Diabetes Prediction Pipeline - Available Make Targets$(NC)"
	@echo "========================================================="
	@echo "$(YELLOW)🚀 Quick Start: make start$(NC) - Complete initial setup"
	@echo "$(YELLOW)🧪 Quick Test: make test$(NC) (default) or $(YELLOW)make test-ideal$(NC) (ideal notebook)"
	@echo "$(YELLOW)📦 Distribution: make dist$(NC) - Create distribution package"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

# =============================================================================
# SETUP AND ENVIRONMENT
# =============================================================================

.PHONY: start
start: ## Complete initial setup - create Python 3.10.13 venv and install all dependencies
	@echo "$(GREEN)🚀 Starting complete project setup...$(NC)"
	@echo "$(YELLOW)Checking for Python 3.10.13...$(NC)"
	@if command -v python3.10 >/dev/null 2>&1; then \
		echo "$(GREEN)✅ Found python3.10$(NC)"; \
		PYTHON_CMD=python3.10; \
	elif command -v python3 >/dev/null 2>&1 && python3 --version | grep -q "3\.10\."; then \
		echo "$(GREEN)✅ Found Python 3.10.x$(NC)"; \
		PYTHON_CMD=python3; \
	elif command -v python >/dev/null 2>&1 && python --version | grep -q "3\.10\."; then \
		echo "$(GREEN)✅ Found Python 3.10.x$(NC)"; \
		PYTHON_CMD=python; \
	else \
		echo "$(RED)❌ Python 3.10.13 not found!$(NC)"; \
		echo "$(YELLOW)Please install Python 3.10.13 first:$(NC)"; \
		echo "  - macOS: brew install python@3.10"; \
		echo "  - pyenv: pyenv install 3.10.13 && pyenv local 3.10.13"; \
		echo "  - Official: https://www.python.org/downloads/"; \
		exit 1; \
	fi; \
	echo "$(GREEN)🐍 Creating virtual environment with Python 3.10.x...$(NC)"; \
	$$PYTHON_CMD -m venv $(VENV_DIR); \
	echo "$(GREEN)📦 Upgrading pip...$(NC)"; \
	$(PIP) install --upgrade pip; \
	echo "$(GREEN)📚 Installing project dependencies...$(NC)"; \
	$(PIP) install -r requirements.txt; \
	echo "$(GREEN)🧪 Installing development dependencies...$(NC)"; \
	$(PIP) install pytest nbformat nbconvert jupyter ipython; \
	echo "$(GREEN)✅ Validating installation...$(NC)"; \
	$(PYTHON_VENV) --version; \
	$(PIP) list | grep -E "(pandas|numpy|scikit-learn|lightgbm|pytest)" || echo "$(YELLOW)⚠️  Some packages may not be installed$(NC)"; \
	echo "$(GREEN)🎉 Setup complete!$(NC)"; \
	echo "$(YELLOW)Next steps:$(NC)"; \
	echo "  1. Activate environment: source $(VENV_DIR)/bin/activate"; \
	echo "  2. Run tests: make test"; \
	echo "  3. Execute pipeline: make run-notebook"; \
	echo "  4. View all targets: make help"

.PHONY: venv
venv: ## Create virtual environment (basic version)
	@echo "$(GREEN)Creating virtual environment...$(NC)"
	$(PYTHON) -m venv $(VENV_DIR)
	$(PIP) install --upgrade pip
	@echo "$(GREEN)Virtual environment created. Activate with: source $(VENV_DIR)/bin/activate$(NC)"

.PHONY: install
install: venv ## Install dependencies
	@echo "$(GREEN)Installing dependencies...$(NC)"
	$(PIP) install -r requirements.txt
	@echo "$(GREEN)Dependencies installed successfully$(NC)"

.PHONY: install-dev
install-dev: install ## Install development dependencies
	@echo "$(GREEN)Installing development dependencies...$(NC)"
	$(PIP) install pytest nbformat nbconvert jupyter ipython
	@echo "$(GREEN)Development dependencies installed$(NC)"

# =============================================================================
# TESTING
# =============================================================================

.PHONY: test
test: ## Run all tests (default notebook)
	@echo "$(GREEN)Running all tests...$(NC)"
	rm -rf $(CACHE_DIRS)
	@if [ ! -f $(PYTEST) ]; then \
		echo "$(RED)pytest not found. Run 'make install-dev' first.$(NC)"; \
		exit 1; \
	fi
	$(PYTEST) test_notebook.py -v
	@echo "$(GREEN)All tests completed$(NC)"

.PHONY: test-ideal
test-ideal: ## Run all tests (ideal notebook)
	@echo "$(GREEN)Running all tests on ideal notebook...$(NC)"
	rm -rf $(CACHE_DIRS)
	@if [ ! -f $(PYTEST) ]; then \
		echo "$(RED)pytest not found. Run 'make install-dev' first.$(NC)"; \
		exit 1; \
	fi
	@if [ ! -f "ideal_notebook.ipynb" ]; then \
		echo "$(RED)❌ ideal_notebook.ipynb not found!$(NC)"; \
		exit 1; \
	fi
	TEST_NOTEBOOK=ideal_notebook.ipynb $(PYTEST) test_notebook.py -v
	@echo "$(GREEN)All tests completed for ideal notebook$(NC)"

.PHONY: test-notebook
test-notebook: ## Run tests on specific notebook (usage: make test-notebook NOTEBOOK=ideal_notebook.ipynb)
	@echo "$(GREEN)Running tests on $(or $(NOTEBOOK),notebook.ipynb)...$(NC)"
	rm -rf $(CACHE_DIRS)
	@if [ ! -f $(PYTEST) ]; then \
		echo "$(RED)pytest not found. Run 'make install-dev' first.$(NC)"; \
		exit 1; \
	fi
	@if [ ! -f "$(or $(NOTEBOOK),notebook.ipynb)" ]; then \
		echo "$(RED)Notebook '$(or $(NOTEBOOK),notebook.ipynb)' not found!$(NC)"; \
		echo "$(YELLOW)Available notebooks:$(NC)"; \
		ls -1 *.ipynb 2>/dev/null || echo "  No notebooks found"; \
		exit 1; \
	fi
	TEST_NOTEBOOK=$(or $(NOTEBOOK),notebook.ipynb) $(PYTEST) test_notebook.py -v
	@echo "$(GREEN)Tests completed for $(or $(NOTEBOOK),notebook.ipynb)$(NC)"

.PHONY: test-fast
test-fast: ## Run tests with minimal output
	@echo "$(GREEN)Running fast tests...$(NC)"
	rm -rf $(CACHE_DIRS)
	$(PYTEST) test_notebook.py -q

.PHONY: test-verbose
test-verbose: ## Run tests with maximum verbosity
	@echo "$(GREEN)Running verbose tests...$(NC)"
	rm -rf $(CACHE_DIRS)
	$(PYTEST) test_notebook.py -vv --tb=long

.PHONY: test-config
test-config: ## Run configuration tests only
	@echo "$(GREEN)Running configuration tests...$(NC)"
	rm -rf $(CACHE_DIRS)
	$(PYTEST) test_notebook.py::test_pipeline_configuration test_notebook.py::test_pipeline_class_created -v

.PHONY: test-pipeline
test-pipeline: ## Run pipeline execution tests only
	@echo "$(GREEN)Running pipeline tests...$(NC)"
	rm -rf $(CACHE_DIRS)
	$(PYTEST) test_notebook.py::test_end_to_end_pipeline_execution test_notebook.py::test_notebook_exec -v

.PHONY: test-performance
test-performance: ## Run performance tests only
	@echo "$(GREEN)Running performance tests...$(NC)"
	rm -rf $(CACHE_DIRS)
	$(PYTEST) test_notebook.py::test_model_performance_high_accuracy test_notebook.py::test_optimized_model_outperforms_simple -v

.PHONY: test-wrapper
test-wrapper: ## Run tests using wrapper script (usage: make test-wrapper NOTEBOOK=ideal_notebook.ipynb)
	@echo "$(GREEN)Running tests with wrapper script...$(NC)"
	rm -rf $(CACHE_DIRS)
	@if [ ! -f scripts/run_notebook_tests.py ]; then \
		echo "$(RED)❌ Wrapper script not found at scripts/run_notebook_tests.py$(NC)"; \
		exit 1; \
	fi
	$(PYTHON_VENV) scripts/run_notebook_tests.py $(or $(NOTEBOOK),notebook.ipynb) -v
	@echo "$(GREEN)Wrapper script tests completed$(NC)"

# =============================================================================
# NOTEBOOK EXECUTION
# =============================================================================

.PHONY: run-notebook
run-notebook: ## Execute the main notebook
	@echo "$(GREEN)Executing notebook...$(NC)"
	$(PYTHON_VENV) -c "import nbformat; from nbconvert.preprocessors import ExecutePreprocessor; \
		nb = nbformat.read('notebook.ipynb', as_version=4); \
		ep = ExecutePreprocessor(timeout=1800, kernel_name='python3'); \
		ep.preprocess(nb, {'metadata': {'path': '.'}}); \
		print('✅ Notebook executed successfully')"

.PHONY: run-pipeline
run-pipeline: ## Run the diabetes prediction pipeline directly
	@echo "$(GREEN)Running diabetes prediction pipeline...$(NC)"
	$(PYTHON_VENV) -c "exec(open('notebook.ipynb').read())"

# =============================================================================
# CLEANING
# =============================================================================

.PHONY: clean
clean: ## Clean build artifacts and cache files
	@echo "$(GREEN)Cleaning build artifacts and cache files...$(NC)"
	rm -rf $(CACHE_DIRS)
	rm -rf $(BUILD_DIR)
	rm -f $(LOG_FILES)
	rm -f input_data.zip
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)Cache and build artifacts cleaned$(NC)"

.PHONY: clean-test
clean-test: ## Clean test artifacts and cache
	@echo "$(GREEN)Cleaning test artifacts...$(NC)"
	rm -rf .pytest_cache/
	rm -rf .coverage
	rm -f coverage.xml
	rm -f test-results.xml
	find . -name "*.pyc" -delete
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)Test artifacts cleaned$(NC)"

.PHONY: clean-notebooks
clean-notebooks: ## Clean notebook output and checkpoints
	@echo "$(GREEN)Cleaning notebook outputs...$(NC)"
	find . -name "*.ipynb" -exec jupyter nbconvert --clear-output --inplace {} \; 2>/dev/null || \
		echo "$(YELLOW)jupyter not available, skipping notebook cleaning$(NC)"
	find . -name ".ipynb_checkpoints" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)Notebook outputs cleaned$(NC)"

.PHONY: clean-dist
clean-dist: ## Clean distribution files
	@echo "$(GREEN)Cleaning distribution files...$(NC)"
	rm -rf $(DIST_DIR)
	@echo "$(GREEN)Distribution files cleaned$(NC)"

.PHONY: clean-all
clean-all: clean clean-test clean-notebooks clean-dist ## Clean everything (build, test, notebooks, dist)
	@echo "$(GREEN)Full cleanup completed$(NC)"

# =============================================================================
# BACKUP AND DISTRIBUTION
# =============================================================================

.PHONY: backup
backup: ## Create a backup of the current state
	@echo "$(GREEN)Creating backup...$(NC)"
	mkdir -p $(BACKUPS_DIR)backup-$(shell date +%Y%m%d-%H%M%S)
	cp -r *.py *.ipynb *.md requirements.txt $(DATA_FILES) $(SCRIPTS_DIR) $(BACKUPS_DIR)backup-$(shell date +%Y%m%d-%H%M%S)/ 2>/dev/null || true
	@echo "$(GREEN)Backup created in $(BACKUPS_DIR)backup-$(shell date +%Y%m%d-%H%M%S)$(NC)"

.PHONY: zip-data
zip-data: ## Create zip archive of input data in root directory
	@echo "$(GREEN)Creating input data zip archive...$(NC)"
	@if [ ! -d input_data ]; then \
		echo "$(RED)❌ input_data directory not found$(NC)"; \
		exit 1; \
	fi
	cd input_data && zip -r ../input_data.zip .
	@echo "$(GREEN)✅ Created input_data.zip$(NC)"
	@ls -lh input_data.zip

.PHONY: dist
dist: ## Create complete distribution package with all files
	@echo "$(GREEN)Creating complete distribution package...$(NC)"
	@echo "$(YELLOW)Including: source code, notebooks, scripts, data, documentation$(NC)"
	@mkdir -p $(DIST_DIR)
	@zip -r $(DIST_DIR)$(PROJECT_NAME)-$(shell date +%Y%m%d-%H%M%S).zip \
		*.py *.ipynb *.md requirements.txt Makefile \
		$(SCRIPTS_DIR) $(DATA_FILES) \
		--exclude="*.pyc" "__pycache__/*" ".pytest_cache/*" \
		"$(BACKUPS_DIR)*" ".venv/*" "*.zip" "$(DIST_DIR)*" \
		2>/dev/null || true
	@echo "$(GREEN)✅ Distribution package created$(NC)"
	@ls -lh $(DIST_DIR)$(PROJECT_NAME)-*.zip 2>/dev/null || true

# =============================================================================
# QUALITY ASSURANCE
# =============================================================================

.PHONY: validate
validate: ## Validate project structure and requirements
	@echo "$(GREEN)Validating project structure...$(NC)"
	@echo "📁 Checking required files..."
	@test -f notebook.ipynb && echo "✅ notebook.ipynb found" || echo "❌ notebook.ipynb missing"
	@test -f ideal_notebook.ipynb && echo "✅ ideal_notebook.ipynb found" || echo "❌ ideal_notebook.ipynb missing"
	@test -f test_notebook.py && echo "✅ test_notebook.py found" || echo "❌ test_notebook.py missing"
	@test -f requirements.txt && echo "✅ requirements.txt found" || echo "❌ requirements.txt missing"
	@test -d $(DATA_FILES) && echo "✅ $(DATA_FILES) directory found" || echo "❌ $(DATA_FILES) directory missing"
	@test -f $(DATA_FILES)diabetes.csv && echo "✅ diabetes.csv found" || echo "❌ diabetes.csv missing"
	@test -d $(SCRIPTS_DIR) && echo "✅ $(SCRIPTS_DIR) directory found" || echo "❌ $(SCRIPTS_DIR) directory missing"
	@test -f $(SCRIPTS_DIR)run_notebook_tests.py && echo "✅ run_notebook_tests.py found" || echo "❌ run_notebook_tests.py missing"
	@echo "📊 Checking data integrity..."
	@$(PYTHON_VENV) -c "import pandas as pd; df = pd.read_csv('input_data/diabetes.csv'); print(f'✅ Dataset loaded: {df.shape[0]} rows, {df.shape[1]} columns')" 2>/dev/null || echo "❌ Cannot validate dataset"
	@echo "$(GREEN)Validation completed$(NC)"

.PHONY: check
check: validate test-config ## Run basic checks (validation + config tests)
	@echo "$(GREEN)Basic checks completed successfully$(NC)"

# =============================================================================
# DEVELOPMENT WORKFLOW
# =============================================================================

.PHONY: dev-setup
dev-setup: install-dev validate ## Complete development setup (use 'make start' for fresh setup)
	@echo "$(GREEN)Development environment ready!$(NC)"
	@echo "$(YELLOW)Next steps:$(NC)"
	@echo "  1. Run tests: make test"
	@echo "  2. Execute notebook: make run-notebook"
	@echo "  3. Create backup: make backup"

.PHONY: ci
ci: clean install-dev test validate ## Continuous integration pipeline
	@echo "$(GREEN)CI pipeline completed successfully$(NC)"

.PHONY: pre-commit
pre-commit: clean-test test validate ## Pre-commit validation
	@echo "$(GREEN)Pre-commit checks passed$(NC)"

# =============================================================================
# STATUS AND MONITORING
# =============================================================================

.PHONY: status
status: ## Show project status
	@echo "$(GREEN)Diabetes Prediction Pipeline - Project Status$(NC)"
	@echo "=============================================="
	@echo "📁 Project Directory: $(PWD)"
	@echo "🐍 Python: $(shell $(PYTHON) --version 2>/dev/null || echo 'Not found')"
	@echo "📦 Virtual Environment: $(if $(wildcard $(VENV_DIR)),✅ Active,❌ Not created)"
	@echo "🧪 Tests: $(shell find . -name 'test_*.py' | wc -l | tr -d ' ') test files"
	@echo "📓 Notebooks: $(shell find . -maxdepth 1 -name '*.ipynb' | wc -l | tr -d ' ') notebook files"
	@echo "📊 Data Files: $(shell find $(DATA_FILES) -name '*.csv' 2>/dev/null | wc -l | tr -d ' ') CSV files"
	@echo "🔧 Scripts: $(shell find $(SCRIPTS_DIR) -name '*.py' 2>/dev/null | wc -l | tr -d ' ') Python scripts"
	@echo "💾 Backup Files: $(shell find $(BACKUPS_DIR) -name '*' 2>/dev/null | wc -l | tr -d ' ') files in $(BACKUPS_DIR)"
	@echo ""
	@echo "$(YELLOW)Recent Activity:$(NC)"
	@echo "  Last modified notebook: $(shell ls -t *.ipynb 2>/dev/null | head -1 || echo 'None')"
	@echo "  Last test run: $(shell ls -t .pytest_cache 2>/dev/null && echo 'Found' || echo 'No cache found')"

.PHONY: info
info: ## Show detailed project information
	@echo "$(GREEN)Detailed Project Information$(NC)"
	@echo "============================"
	@echo ""
	@make status
	@echo ""
	@echo "$(YELLOW)Available Make Targets:$(NC)"
	@make help

# =============================================================================
# SPECIAL TARGETS
# =============================================================================

.DEFAULT_GOAL := help

# Ensure intermediate files aren't deleted
.PRECIOUS: $(VENV_DIR) requirements.txt

# Mark all phony targets
.PHONY: all clean install test help swap notebook-ids

# =============================================================================
# SWAP NOTEBOOKS
# =============================================================================

.PHONY: swap
swap: ## Swap notebook.ipynb and ideal_notebook.ipynb
	@echo "$(GREEN)Swapping notebook.ipynb and ideal_notebook.ipynb...$(NC)"
	@if [ ! -f notebook.ipynb ] || [ ! -f ideal_notebook.ipynb ]; then \
		echo "$(RED)❌ Both notebook.ipynb and ideal_notebook.ipynb must exist!$(NC)"; \
		exit 1; \
	fi
	mv notebook.ipynb notebook_tmp_swap.ipynb
	mv ideal_notebook.ipynb notebook.ipynb
	mv notebook_tmp_swap.ipynb ideal_notebook.ipynb
	@echo "$(GREEN)✅ Swap complete!$(NC)"

# =============================================================================
# NOTEBOOK UTILITIES
# =============================================================================

.PHONY: notebook-ids
notebook-ids: ## Add IDs to notebook cells
	@echo "$(GREEN)Adding IDs to notebook cells...$(NC)"
	@if [ ! -f add_notebook_ids.py ]; then \
		echo "$(RED)❌ add_notebook_ids.py not found!$(NC)"; \
		exit 1; \
	fi
	$(PYTHON_VENV) add_notebook_ids.py
	@echo "$(GREEN)✅ Notebook IDs added!$(NC)"
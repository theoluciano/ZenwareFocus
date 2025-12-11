# Zenware Focus - Makefile
# Convenient commands for building and managing the app

.PHONY: help build install run clean rebuild open test

# Default target - show help
help:
	@echo "╔═══════════════════════════════════════════════════════════╗"
	@echo "║          Zenware Focus - Build Commands                  ║"
	@echo "╚═══════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "  make build      - Build Zenware Focus.app"
	@echo "  make install    - Build and install to /Applications"
	@echo "  make run        - Launch the app"
	@echo "  make clean      - Remove built files"
	@echo "  make rebuild    - Clean and rebuild"
	@echo "  make open       - Open in Finder"
	@echo "  make test       - Run tests (if available)"
	@echo ""
	@echo "Quick start: make build && make run"
	@echo ""

# Build the .app bundle
build:
	@echo "🔨 Building Zenware Focus..."
	@./build-app.sh

# Build and install to Applications folder
install:
	@echo "📦 Installing Zenware Focus..."
	@./install.sh

# Launch the app
run:
	@echo "🚀 Launching Zenware Focus..."
	@open "Zenware Focus.app"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf "Zenware Focus.app"
	@rm -rf .build
	@echo "✅ Clean complete"

# Clean and rebuild
rebuild: clean build
	@echo "✅ Rebuild complete"

# Open app bundle in Finder
open:
	@open -R "Zenware Focus.app"

# Run Swift tests
test:
	@echo "🧪 Running tests..."
	@swift test

# Development build (not release)
dev:
	@echo "🔧 Building debug version..."
	@swift build
	@echo "✅ Debug build complete"
	@echo "Run with: swift run"

# Show app info
info:
	@echo "📊 Zenware Focus Information"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@if [ -d "Zenware Focus.app" ]; then \
		echo "Status:      ✅ Built"; \
		echo "Location:    $$(pwd)/Zenware Focus.app"; \
		echo "Size:        $$(du -sh "Zenware Focus.app" | cut -f1)"; \
		echo "Binary:      $$(file "Zenware Focus.app/Contents/MacOS/ZenwareFocus" | cut -d: -f2)"; \
	else \
		echo "Status:      ❌ Not built"; \
		echo "Run 'make build' to create the app"; \
	fi
	@echo ""

# Check if required tools are installed
check:
	@echo "🔍 Checking build environment..."
	@command -v swift >/dev/null 2>&1 && echo "✅ Swift:    $$(swift --version | head -1)" || echo "❌ Swift:    Not found"
	@command -v xcodebuild >/dev/null 2>&1 && echo "✅ Xcode:    $$(xcodebuild -version | head -1)" || echo "⚠️  Xcode:    Not found (optional)"
	@echo ""
TARGET_DIR=tester_dir
MAL_DIR=malicious_dir
INTERVAL=5
.PHONY: all pre-build antivirusd restore

pre-build:
	mkdir -p $(MAL_DIR)

antivirusd: pre-build
	./antivirusd.sh $(TARGET_DIR) $(MAL_DIR) $(INTERVAL)

restore: pre-build
	./restore.sh $(TARGET_DIR) $(MAL_DIR)

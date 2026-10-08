TARGET_DIR=tester
MAL_DIR=malicious_dir

.PHONY: all pre-build antivirusd restore

all: antivirusd restore

pre-build:
	mkdir -p $(MAL_DIR)

antivirusd: pre-build
	./antivirusd.sh $(TARGET_DIR) $(MAL_DIR)

restore: pre-build
	./restore.sh $(TARGET_DIR) $(MAL_DIR)



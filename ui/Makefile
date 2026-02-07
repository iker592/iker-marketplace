.PHONY: setup ui server server-bedrock build test fix lint preview clean all

setup:
	curl -fsSL https://bun.sh/install | bash
	bun install

deps:
	bun install

ui:
	bun run dev

server:
	bun run server

server-bedrock:
	CLAUDE_CODE_USE_BEDROCK=1 bun run server

build:
	bun run build

test:
	bun run test

fix:
	bun run fix

lint:
	bun run lint

preview:
	bun run preview

clean:
	rm -rf node_modules dist

all: fix test build
